use crossterm::event::{KeyCode, KeyEvent, KeyModifiers};
use log::info;
use oneshot::Receiver;
use portable_pty::{
    ChildKiller, CommandBuilder, ExitStatus, MasterPty, NativePtySystem, PtySize, PtySystem,
};
use ratatui::prelude::*;
use ratatui::symbols::border;
use ratatui::widgets::{Block, Clear, Widget};
use std::io::Write;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::thread::JoinHandle;
use tui_term::widget::PseudoTerminal;
use vt100_ctt::{Parser, Screen};

/// events that can be sent from the pop-up.
pub enum PopupEvent {
    /// tells the main app to close the pop-up.
    Close,
    /// no event.
    None,
}

/// holds the state for the pop-up that runs a script.
pub struct RunScriptPopup {
    /// the output from the command.
    buffer:         Arc<Mutex<Vec<u8>>>,
    /// the thread that the command is running in.
    command_thread: Option<JoinHandle<ExitStatus>>,
    /// used to kill the running command.
    child_killer:   Option<Receiver<Box<dyn ChildKiller + Send + Sync>>>,
    /// the thread that reads the command's output.
    _reader_thread: JoinHandle<()>,
    /// the master side of the pty.
    pty_master:     Box<dyn MasterPty + Send>,
    /// used to write to the command's input.
    writer:         Box<dyn Write + Send>,
    /// the exit status of the command.
    status:         Option<ExitStatus>,
    /// how far the user has scrolled up.
    scroll_offset:  usize,
}

impl RunScriptPopup {
    /// creates a new pop-up to run a script.
    pub fn new(script_path: PathBuf, log_mode: bool) -> Self {
        let pty_system = NativePtySystem::default();

        let mut cmd = CommandBuilder::new("bash");
        cmd.arg(script_path);

        let pair = pty_system
            .openpty(PtySize {
                rows:         24,
                cols:         80,
                pixel_width:  0,
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
                let mut buf = [0u8; 16384];
                while let Ok(size) = reader.read(&mut buf) {
                    if size == 0 {
                        break;
                    }
                    let mut mutex = command_buffer.lock().unwrap();
                    let data = &buf[0..size];
                    if log_mode {
                        info!("{}", &String::from_utf8_lossy(data));
                    }
                    mutex.extend_from_slice(data);
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

    /// handles key events for the pop-up.
    pub fn handle_key_event(&mut self, key: KeyEvent) -> PopupEvent {
        match key.code {
            KeyCode::Char('c') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                let _ = self.writer.write_all(&[3]);
                PopupEvent::None
            }
            KeyCode::Enter if self.is_finished() => PopupEvent::Close,
            KeyCode::Esc if self.is_finished() => PopupEvent::Close,
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

    /// checks if the script has finished running.
    fn is_finished(&self) -> bool {
        if let Some(command_thread) = &self.command_thread {
            command_thread.is_finished()
        } else {
            true
        }
    }

    /// creates a `screen` from the command's output buffer.
    fn screen(&mut self, size: Size) -> Screen {
        self.pty_master
            .resize(PtySize {
                rows:         size.height,
                cols:         size.width,
                pixel_width:  0,
                pixel_height: 0,
            })
            .unwrap();

        let mut parser = Parser::new(size.height, size.width, 1000);
        let mutex = self.buffer.lock().unwrap();
        parser.process(&mutex);
        parser.screen_mut().set_scrollback(self.scroll_offset);
        parser.screen().clone()
    }

    /// gets the exit status of the script.
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

    /// kills the running script.
    pub fn kill_child(&mut self) {
        if !self.is_finished()
            && let Some(killer_rx) = self.child_killer.take()
            && let Ok(mut killer) = killer_rx.recv()
        {
            let _ = killer.kill();
        }
    }

    /// sends key events to the running script.
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

impl Widget for &mut RunScriptPopup {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let block = if !self.is_finished() {
            Block::bordered()
                .border_set(border::ROUNDED)
                .border_style(Style::default().fg(Color::Rgb(137, 180, 250)))
                .title_style(Style::default().fg(Color::Rgb(137, 180, 250)).reversed())
                .title_bottom(Line::from("Press Ctrl-C to kill"))
        } else {
            let (title_text, style_color) = if self.get_exit_status().success() {
                (
                    Line::styled(
                        "Success! Press <Enter> to close",
                        Style::default().fg(Color::Green).reversed(),
                    ),
                    Color::Rgb(137, 180, 250),
                )
            } else {
                (
                    Line::styled(
                        "Failed! Press <Enter> to close",
                        Style::default().fg(Color::Red).reversed(),
                    ),
                    Color::Rgb(137, 180, 250),
                )
            };

            Block::bordered()
                .border_set(border::ROUNDED)
                .border_style(Style::default().fg(style_color))
                .title_top(title_text.centered())
        };

        let inner_area = block.inner(area);
        let screen = self.screen(inner_area.as_size());
        let pseudo_term = PseudoTerminal::new(&screen);

        Clear.render(area, buf);
        block.render(area, buf);
        pseudo_term.render(inner_area, buf);
    }
}
