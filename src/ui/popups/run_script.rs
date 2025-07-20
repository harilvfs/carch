use crossterm::event::{KeyCode, KeyEvent, KeyModifiers};
use oneshot::Receiver;
use portable_pty::{
    ChildKiller, CommandBuilder, ExitStatus, MasterPty, NativePtySystem, PtySize, PtySystem,
};
use ratatui::{
    prelude::*,
    symbols::border,
    widgets::{Block, Paragraph, Widget},
};
use std::{
    io::Write,
    path::PathBuf,
    sync::{Arc, Mutex},
    thread::JoinHandle,
};
use tui_term::widget::PseudoTerminal;
use vt100_ctt::{Parser, Screen};

pub enum PopupEvent {
    Close,
    None,
}

pub enum RunScriptPopup {
    Loading,
    Loaded(RunScriptPopupLoaded),
}

impl RunScriptPopup {
    pub fn new(script_path: PathBuf) -> (Self, Receiver<RunScriptPopupLoaded>) {
        let (tx, rx) = oneshot::channel();

        std::thread::spawn(move || {
            let loaded = RunScriptPopupLoaded::new(script_path);
            let _ = tx.send(loaded);
        });

        (Self::Loading, rx)
    }

    pub fn handle_key_event(&mut self, key: KeyEvent) -> PopupEvent {
        if let Self::Loaded(popup) = self {
            popup.handle_key_event(key)
        } else {
            PopupEvent::None
        }
    }

    pub fn kill_child(&mut self) {
        if let Self::Loaded(popup) = self {
            popup.kill_child();
        }
    }
}

pub struct RunScriptPopupLoaded {
    buffer: Arc<Mutex<Vec<u8>>>,
    command_thread: Option<JoinHandle<ExitStatus>>,
    child_killer: Option<Receiver<Box<dyn ChildKiller + Send + Sync>>>,
    _reader_thread: JoinHandle<()>,
    pty_master: Box<dyn MasterPty + Send>,
    writer: Box<dyn Write + Send>,
    status: Option<ExitStatus>,
    scroll_offset: usize,
}

impl RunScriptPopupLoaded {
    pub fn new(script_path: PathBuf) -> Self {
        let pty_system = NativePtySystem::default();

        let mut cmd = CommandBuilder::new("bash");
        cmd.arg(script_path);

        let pair = pty_system
            .openpty(PtySize {
                rows: 24,
                cols: 80,
                pixel_width: 0,
                pixel_height: 0,
            })
            .unwrap();

        let (tx, rx) = oneshot::channel();
        let command_handle = std::thread::spawn(move || {
            let mut child = pair.slave.spawn_command(cmd).unwrap();
            let killer = child.clone_killer();
            tx.send(killer).unwrap();
            child.wait().unwrap()
        });

        let mut reader = pair.master.try_clone_reader().unwrap();

        let command_buffer: Arc<Mutex<Vec<u8>>> = Arc::new(Mutex::new(Vec::new()));
        let reader_handle = {
            let command_buffer = command_buffer.clone();
            std::thread::spawn(move || {
                let mut buf = [0u8; 8192];
                loop {
                    if let Ok(size) = reader.read(&mut buf) {
                        if size == 0 {
                            break;
                        }
                        let mut mutex = command_buffer.lock().unwrap();
                        mutex.extend_from_slice(&buf[0..size]);
                    } else {
                        break;
                    }
                }
            })
        };

        let writer = pair.master.take_writer().unwrap();
        Self {
            buffer: command_buffer,
            command_thread: Some(command_handle),
            child_killer: Some(rx),
            _reader_thread: reader_handle,
            pty_master: pair.master,
            writer,
            status: None,
            scroll_offset: 0,
        }
    }

    pub fn handle_key_event(&mut self, key: KeyEvent) -> PopupEvent {
        match key.code {
            KeyCode::Char('c') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                self.kill_child();
                PopupEvent::None
            }
            KeyCode::Enter if self.is_finished() => PopupEvent::Close,
            KeyCode::PageUp => {
                self.scroll_offset = self.scroll_offset.saturating_add(10);
                PopupEvent::None
            }
            KeyCode::PageDown => {
                self.scroll_offset = self.scroll_offset.saturating_sub(10);
                PopupEvent::None
            }
            _ => {
                self.handle_passthrough_key_event(key);
                PopupEvent::None
            }
        }
    }

    fn is_finished(&self) -> bool {
        if let Some(command_thread) = &self.command_thread {
            command_thread.is_finished()
        } else {
            true
        }
    }

    fn screen(&mut self, size: Size) -> Screen {
        self.pty_master
            .resize(PtySize {
                rows: size.height,
                cols: size.width,
                pixel_width: 0,
                pixel_height: 0,
            })
            .unwrap();

        let mut parser = Parser::new(size.height, size.width, 1000);
        let mutex = self.buffer.lock().unwrap();
        parser.process(&mutex);
        parser.screen_mut().set_scrollback(self.scroll_offset);
        parser.screen().clone()
    }

    fn get_exit_status(&mut self) -> ExitStatus {
        if self.command_thread.is_some() {
            let handle = self.command_thread.take().unwrap();
            let exit_status = handle.join().unwrap();
            self.status = Some(exit_status.clone());
            exit_status
        } else {
            self.status.as_ref().unwrap().clone()
        }
    }

    pub fn kill_child(&mut self) {
        if !self.is_finished() {
            if let Some(killer_rx) = self.child_killer.take() {
                if let Ok(mut killer) = killer_rx.recv() {
                    let _ = killer.kill();
                }
            }
        }
    }

    fn handle_passthrough_key_event(&mut self, key: KeyEvent) {
        let input_bytes = match key.code {
            KeyCode::Char(ch) => ch.to_string().into_bytes(),
            KeyCode::Enter => vec![b'\n'],
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

impl Widget for &mut RunScriptPopup {
    fn render(self, area: Rect, buf: &mut Buffer) {
        match self {
            RunScriptPopup::Loading => {
                let block = Block::bordered()
                    .border_set(border::ROUNDED)
                    .title_top(Line::from("Loading script...").centered());
                let text = Paragraph::new("Please wait...").centered();
                let text_area = block.inner(area);

                block.render(area, buf);
                text.render(text_area, buf);
            }
            RunScriptPopup::Loaded(popup) => popup.render(area, buf),
        }
    }
}

impl Widget for &mut RunScriptPopupLoaded {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let block = if !self.is_finished() {
            Block::bordered()
                .border_set(border::ROUNDED)
                .title_top(Line::from("Running script...").centered())
                .title_style(Style::default().reversed())
                .title_bottom(Line::from("Press Ctrl-C to KILL"))
        } else {
            let title_line = if self.get_exit_status().success() {
                Line::styled(
                    "SUCCESS! Press <ENTER> to close",
                    Style::default().fg(Color::Green).reversed(),
                )
            } else {
                Line::styled(
                    "FAILED! Press <ENTER> to close",
                    Style::default().fg(Color::Red).reversed(),
                )
            };

            Block::bordered()
                .border_set(border::ROUNDED)
                .title_top(title_line.centered())
        };

        let inner_area = block.inner(area);
        let screen = self.screen(inner_area.as_size());
        let pseudo_term = PseudoTerminal::new(&screen);

        block.render(area, buf);
        pseudo_term.render(inner_area, buf);
    }
}
