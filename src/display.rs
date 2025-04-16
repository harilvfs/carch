use std::io;
use std::time::{Duration, Instant};

use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode},
    execute,
    terminal::{EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode},
};
use ratatui::{
    Frame, Terminal,
    backend::{Backend, CrosstermBackend},
    layout::{Alignment, Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Span, Spans},
    widgets::{Block, Borders, Clear, Paragraph, Wrap},
};

struct App {
    scroll: u16,
    content_height: u16,
    available_height: u16,
}

impl App {
    fn new() -> App {
        App {
            scroll: 0,
            content_height: 0,
            available_height: 0,
        }
    }

    fn scroll_up(&mut self) {
        if self.needs_scrolling() {
            self.scroll = self.scroll.saturating_sub(1);
        }
    }

    fn scroll_down(&mut self) {
        if self.needs_scrolling() {
            let max_scroll = self.content_height.saturating_sub(self.available_height);
            self.scroll = (self.scroll + 1).min(max_scroll);
        }
    }

    fn needs_scrolling(&self) -> bool {
        self.content_height > self.available_height
    }

    fn update_dimensions(&mut self, content_height: u16, available_height: u16) {
        self.content_height = content_height;
        self.available_height = available_height;

        if !self.needs_scrolling() {
            self.scroll = 0;
        } else {
            let max_scroll = self.content_height.saturating_sub(self.available_height);
            if self.scroll > max_scroll {
                self.scroll = max_scroll;
            }
        }
    }
}

pub fn display_help() -> Result<(), Box<dyn std::error::Error>> {
    display_help_tui()?;
    Ok(())
}

fn display_help_tui() -> Result<(), Box<dyn std::error::Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut app = App::new();
    let tick_rate = Duration::from_millis(100);
    let mut last_tick = Instant::now();

    loop {
        terminal.draw(|f| ui(f, &mut app))?;

        let timeout = tick_rate
            .checked_sub(last_tick.elapsed())
            .unwrap_or_else(|| Duration::from_secs(0));

        if crossterm::event::poll(timeout)? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Char('q') | KeyCode::Esc => break,
                    KeyCode::Up | KeyCode::Char('k') => {
                        if app.needs_scrolling() {
                            app.scroll_up();
                        }
                    }
                    KeyCode::Down | KeyCode::Char('j') => {
                        if app.needs_scrolling() {
                            app.scroll_down();
                        }
                    }
                    KeyCode::PageUp => {
                        if app.needs_scrolling() {
                            for _ in 0..10 {
                                app.scroll_up();
                            }
                        }
                    }
                    KeyCode::PageDown => {
                        if app.needs_scrolling() {
                            for _ in 0..10 {
                                app.scroll_down();
                            }
                        }
                    }
                    KeyCode::Home => {
                        if app.needs_scrolling() {
                            app.scroll = 0;
                        }
                    }
                    _ => {}
                }
            }
        }

        if last_tick.elapsed() >= tick_rate {
            last_tick = Instant::now();
        }
    }

    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    Ok(())
}

fn ui<B: Backend>(f: &mut Frame<B>, app: &mut App) {
    let size = f.size();

    let width = (size.width as f32 * 0.8) as u16;
    let height = (size.height as f32 * 0.8) as u16;
    let help_area = centered_rect(width, height, size);

    f.render_widget(Clear, help_area);

    let block = Block::default()
        .title(Span::styled(
            " CARCH HELP ",
            Style::default()
                .fg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        ))
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::Cyan));

    let inner_height = help_area.height.saturating_sub(2);

    let help_content = vec![
        Spans::from(Span::styled(
            "Usage: carch [OPTIONS]",
            Style::default().fg(Color::Cyan),
        )),
        Spans::from(""),
        Spans::from(Span::styled("Options:", Style::default().fg(Color::Cyan))),
        Spans::from(vec![
            Span::styled(
                "  --help, -h              ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Show this help message and exit."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --version, -v           ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Show the program version."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --list-scripts, -l      ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("List all available scripts."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --no-preview            ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Run without displaying script previews in menus."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --log                   ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Enable logging for the current session only."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --update                ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Update Carch to the latest version."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --uninstall             ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Uninstall Carch completely."),
        ]),
        Spans::from(""),
        Spans::from(Span::styled(
            "Note: Carch is only available as a cargo crate.",
            Style::default().fg(Color::Green),
        )),
        Spans::from(""),
    ];

    let estimated_content_height = help_content.len() as u16;
    app.update_dimensions(estimated_content_height, inner_height);

    let mut final_content = help_content.clone();
    if app.needs_scrolling() {
        final_content.push(Spans::from(vec![
            Span::styled("↑/↓", Style::default().fg(Color::DarkGray)),
            Span::styled("/", Style::default().fg(Color::DarkGray)),
            Span::styled("j/k", Style::default().fg(Color::DarkGray)),
            Span::styled(" scroll  ", Style::default().fg(Color::DarkGray)),
            Span::styled("PgUp/PgDn", Style::default().fg(Color::DarkGray)),
            Span::styled(" page  ", Style::default().fg(Color::DarkGray)),
            Span::styled("Home", Style::default().fg(Color::DarkGray)),
            Span::styled(" top  ", Style::default().fg(Color::DarkGray)),
            Span::styled("q", Style::default().fg(Color::DarkGray)),
            Span::styled(" quit", Style::default().fg(Color::DarkGray)),
        ]));
    } else {
        final_content.push(Spans::from(vec![
            Span::styled("q", Style::default().fg(Color::DarkGray)),
            Span::styled(" quit", Style::default().fg(Color::DarkGray)),
        ]));
    }

    let help_paragraph = Paragraph::new(final_content)
        .block(block)
        .alignment(Alignment::Left)
        .wrap(Wrap { trim: true })
        .scroll((app.scroll, 0));

    f.render_widget(help_paragraph, help_area);
}

fn centered_rect(width: u16, height: u16, r: Rect) -> Rect {
    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints(
            [
                Constraint::Length((r.height.saturating_sub(height)) / 2),
                Constraint::Length(height),
                Constraint::Length((r.height.saturating_sub(height)) / 2),
            ]
            .as_ref(),
        )
        .split(r);

    Layout::default()
        .direction(Direction::Horizontal)
        .constraints(
            [
                Constraint::Length((r.width.saturating_sub(width)) / 2),
                Constraint::Length(width),
                Constraint::Length((r.width.saturating_sub(width)) / 2),
            ]
            .as_ref(),
        )
        .split(popup_layout[1])[1]
}
