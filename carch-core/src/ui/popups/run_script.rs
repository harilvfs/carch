use std::io::Write;
use std::path::PathBuf;
use std::sync::{Arc, Mutex, PoisonError};
use std::thread::JoinHandle;

use crossterm::event::{KeyCode, KeyEvent, KeyModifiers};
use log::info;
use portable_pty::{
    ChildKiller, CommandBuilder, ExitStatus, MasterPty, NativePtySystem, PtySize, PtySystem,
};
use ratatui::prelude::*;
use ratatui::symbols::border;
use ratatui::widgets::{Block, Clear, Widget};
use tui_term::widget::PseudoTerminal;
use vt100_ctt::Parser;

use crate::error::{CarchError, Result};
use crate::ui::theme::Theme;

const SCROLLBACK_LEN: usize = 1000;
const PAGE_STEP: usize = 10;

type ChildKillerSender = oneshot::Sender<Option<Box<dyn ChildKiller + Send + Sync>>>;
type ChildKillerReceiver = oneshot::Receiver<Option<Box<dyn ChildKiller + Send + Sync>>>;

pub enum PopupEvent {
    Close,
    None,
}

pub struct RunScriptPopup {
    buffer:         Arc<Mutex<Vec<u8>>>,
    command_thread: Option<JoinHandle<ExitStatus>>,
    child_killer:   Option<ChildKillerReceiver>,
    pty_master:     Box<dyn MasterPty + Send>,
    writer:         Box<dyn Write + Send>,
    status:         Option<ExitStatus>,
    parser:         Option<Parser>,
    parser_size:    (u16, u16),
    pty_size:       (u16, u16),
    processed_len:  usize,
    last_max_check: usize,
    scroll_offset:  usize,
    actual_max:     usize,
    auto_scroll:    bool,
    theme:          Theme,
    was_finished:   bool,
}

impl RunScriptPopup {
    pub fn new(script_path: PathBuf, log_mode: bool, theme: Theme) -> Result<Self> {
        let pty_system = NativePtySystem::default();

        let interpreter = match script_path.extension().and_then(|e| e.to_str()) {
            Some("py") => "python3",
            _ => "bash",
        };
        let mut cmd = CommandBuilder::new(interpreter);
        cmd.arg(script_path);

        let pair = pty_system
            .openpty(PtySize {
                rows:         24,
                cols:         80,
                pixel_width:  0,
                pixel_height: 0,
            })
            .map_err(|e| CarchError::Pty(format!("openpty: {e}")))?;

        let (tx, rx): (ChildKillerSender, ChildKillerReceiver) = oneshot::channel();
        let pair_slave = pair.slave;
        let command_handle = std::thread::spawn(move || -> ExitStatus {
            match pair_slave.spawn_command(cmd) {
                Ok(mut child) => {
                    let killer = child.clone_killer();
                    if tx.send(Some(killer)).is_err() {
                        log::warn!("child_killer receiver dropped before killer was sent");
                    }
                    child.wait().unwrap_or_else(|e| {
                        log::error!("child.wait failed: {e}");
                        ExitStatus::with_exit_code(1)
                    })
                }
                Err(e) => {
                    log::error!("spawn_command failed: {e}");
                    if tx.send(None).is_err() {
                        log::warn!("child_killer receiver dropped before None was sent");
                    }
                    ExitStatus::with_exit_code(1)
                }
            }
        });

        let mut reader = pair
            .master
            .try_clone_reader()
            .map_err(|e| CarchError::Pty(format!("try_clone_reader: {e}")))?;

        let command_buffer: Arc<Mutex<Vec<u8>>> = Arc::new(Mutex::new(Vec::new()));
        {
            let command_buffer = command_buffer.clone();
            std::thread::spawn(move || {
                let mut buf = [0u8; 16384];
                while let Ok(size) = reader.read(&mut buf) {
                    if size == 0 {
                        break;
                    }
                    let mut mutex = match command_buffer.lock() {
                        Ok(g) => g,
                        Err(p) => p.into_inner(),
                    };
                    let data = &buf[0..size];
                    if log_mode {
                        info!("{}", String::from_utf8_lossy(data));
                    }
                    mutex.extend_from_slice(data);
                }
            });
        }

        let writer =
            pair.master.take_writer().map_err(|e| CarchError::Pty(format!("take_writer: {e}")))?;

        Ok(Self {
            buffer: command_buffer,
            command_thread: Some(command_handle),
            child_killer: Some(rx),
            pty_master: pair.master,
            writer,
            status: None,
            parser: None,
            parser_size: (0, 0),
            pty_size: (0, 0),
            processed_len: 0,
            last_max_check: 0,
            scroll_offset: 0,
            actual_max: 0,
            auto_scroll: true,
            theme,
            was_finished: false,
        })
    }

    pub fn has_new_data(&mut self) -> bool {
        let now_finished = self.is_finished();
        if now_finished != self.was_finished {
            return true;
        }
        if self.auto_scroll
            && let Ok(buf) = self.buffer.try_lock()
            && buf.len() > self.processed_len
        {
            return true;
        }
        false
    }

    pub fn acknowledge_data(&mut self) {
        self.was_finished = self.is_finished();
    }

    pub fn handle_key_event(&mut self, key: KeyEvent) -> PopupEvent {
        let ctrl = key.modifiers.contains(KeyModifiers::CONTROL);
        let shift = key.modifiers.contains(KeyModifiers::SHIFT);

        match key.code {
            KeyCode::Char('c') if ctrl => {
                let _ = self.writer.write_all(&[3]);
                PopupEvent::None
            }
            KeyCode::Char('q') | KeyCode::Enter | KeyCode::Esc if self.is_finished() => {
                PopupEvent::Close
            }
            KeyCode::Up if shift => {
                self.scroll_up(1);
                PopupEvent::None
            }
            KeyCode::Down if shift => {
                self.scroll_down(1);
                PopupEvent::None
            }
            KeyCode::PageUp => {
                self.scroll_up(PAGE_STEP);
                PopupEvent::None
            }
            KeyCode::PageDown => {
                self.scroll_down(PAGE_STEP);
                PopupEvent::None
            }
            KeyCode::Char('g') if !ctrl => {
                self.scroll_to_top();
                PopupEvent::None
            }
            KeyCode::Char('G') => {
                self.scroll_to_bottom();
                PopupEvent::None
            }
            _ => {
                self.handle_passthrough_key_event(key);
                PopupEvent::None
            }
        }
    }

    fn scroll_up(&mut self, n: usize) {
        if n == 0 {
            return;
        }
        let max = self.max_scrollback();
        let next = self.scroll_offset.saturating_add(n).min(max);
        self.scroll_offset = next;
        self.auto_scroll = next == 0;
    }

    fn scroll_down(&mut self, n: usize) {
        if n == 0 {
            return;
        }
        if self.scroll_offset > n {
            self.scroll_offset -= n;
        } else {
            self.scroll_offset = 0;
        }
        self.auto_scroll = self.scroll_offset == 0;
    }

    fn scroll_to_top(&mut self) {
        let max = self.max_scrollback();
        self.scroll_offset = max;
        self.auto_scroll = max == 0;
    }

    fn scroll_to_bottom(&mut self) {
        self.scroll_offset = 0;
        self.auto_scroll = true;
    }

    fn max_scrollback(&self) -> usize {
        self.actual_max
    }

    fn is_finished(&self) -> bool {
        self.command_thread.as_ref().is_none_or(JoinHandle::is_finished)
    }

    fn sync_parser(&mut self, size: Size) {
        let (cols, rows) = (size.width, size.height);

        if self.pty_size != (cols, rows) {
            let _ = self.pty_master.resize(PtySize { rows, cols, pixel_width: 0, pixel_height: 0 });
            self.pty_size = (cols, rows);
        }

        let parser = self.parser.get_or_insert_with(|| Parser::new(rows, cols, SCROLLBACK_LEN));

        if self.parser_size != (cols, rows) {
            parser.screen_mut().set_size(rows, cols);
            self.parser_size = (cols, rows);
        }

        let new_bytes: Vec<u8> = {
            let buf = self.buffer.lock().unwrap_or_else(PoisonError::into_inner);
            if self.processed_len <= buf.len() {
                buf[self.processed_len..].to_vec()
            } else {
                self.processed_len = 0;
                buf[..].to_vec()
            }
        };
        let got_new = !new_bytes.is_empty();
        if got_new {
            parser.process(&new_bytes);
            self.processed_len += new_bytes.len();
        }

        if got_new || self.last_max_check == 0 {
            parser.screen_mut().set_scrollback(usize::MAX);
            self.actual_max = parser.screen().scrollback();
            self.last_max_check = self.processed_len;
        }

        if self.scroll_offset > self.actual_max {
            self.scroll_offset = self.actual_max;
            self.auto_scroll = self.actual_max == 0;
        }

        parser.screen_mut().set_scrollback(self.scroll_offset);
    }

    fn get_exit_status(&mut self) -> ExitStatus {
        if self.command_thread.is_some() {
            let handle = self.command_thread.take().unwrap();
            let exit_status = handle.join().unwrap_or_else(|_| ExitStatus::with_exit_code(1));
            self.status = Some(exit_status.clone());
            exit_status
        } else {
            self.status.clone().unwrap_or_else(|| ExitStatus::with_exit_code(1))
        }
    }

    pub fn kill_child(&mut self) {
        if !self.is_finished()
            && let Some(killer_rx) = self.child_killer.take()
            && let Ok(Some(mut killer)) = killer_rx.recv()
        {
            let _ = killer.kill();
        }
    }

    fn handle_passthrough_key_event(&mut self, key: KeyEvent) {
        let input_bytes = match key.code {
            KeyCode::Char(ch) => ch.to_string().into_bytes(),
            KeyCode::Enter => vec![b'\r'],
            KeyCode::Backspace => vec![0x7f],
            KeyCode::Left => vec![27, 91, 68],
            KeyCode::Right => vec![27, 91, 67],
            KeyCode::Up => vec![27, 91, 65],
            KeyCode::Down => vec![27, 91, 66],
            KeyCode::Tab => vec![9],
            KeyCode::Home => vec![27, 91, 72],
            KeyCode::End => vec![27, 91, 70],
            KeyCode::BackTab => vec![27, 91, 90],
            KeyCode::Delete => vec![27, 91, 51, 126],
            KeyCode::Insert => vec![27, 91, 50, 126],
            KeyCode::Esc => vec![27],
            _ => return,
        };
        let _ = self.writer.write_all(&input_bytes);
    }
}

impl Drop for RunScriptPopup {
    fn drop(&mut self) {
        if !self.is_finished()
            && let Some(rx) = self.child_killer.take()
            && let Ok(Some(mut killer)) = rx.recv()
        {
            let _ = killer.kill();
        }
    }
}

impl Widget for &mut RunScriptPopup {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let running = !self.is_finished();

        let block = if running {
            Block::bordered()
                .border_set(border::ROUNDED)
                .border_style(Style::default().fg(self.theme.primary))
                .title_style(Style::default().fg(self.theme.primary).reversed())
                .title_bottom(Line::from(
                    "Shift+↑/↓: scroll   PgUp/PgDn: page   g/G: top/bottom   Ctrl-C: kill",
                ))
        } else {
            let (title_text, style_color) = if self.get_exit_status().success() {
                (
                    Line::styled(
                        "Success! Press <Enter> to close",
                        Style::default().fg(self.theme.success).reversed(),
                    ),
                    self.theme.success,
                )
            } else {
                (
                    Line::styled(
                        "Failed! Press <Enter> to close",
                        Style::default().fg(self.theme.error).reversed(),
                    ),
                    self.theme.error,
                )
            };

            Block::bordered()
                .border_set(border::ROUNDED)
                .border_style(Style::default().fg(style_color))
                .title_top(title_text.centered())
        };

        let inner_area = block.inner(area);
        self.sync_parser(inner_area.as_size());

        Clear.render(area, buf);
        block.render(area, buf);

        if let Some(parser) = self.parser.as_ref() {
            let pseudo_term = PseudoTerminal::new(parser.screen());
            pseudo_term.render(inner_area, buf);
        }
    }
}
