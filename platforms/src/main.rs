use std::env;
use std::io;
use std::io::Write;
use std::path::Path;
use std::path::PathBuf;
use std::process::Command;
use std::time::Duration;

use crossterm::{
    cursor,
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{
        Clear as TermClear, ClearType, EnterAlternateScreen, LeaveAlternateScreen,
        disable_raw_mode, enable_raw_mode,
    },
};
use ratatui::{
    Frame, Terminal,
    backend::{Backend, CrosstermBackend},
    layout::{Alignment, Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Span, Spans},
    widgets::{Block, BorderType, Borders, Clear, List, ListItem, Paragraph},
};

enum AppState {
    Choosing,
    Confirming,
    Installing,
    Finished,
    PostInstall,
}

struct App {
    state: AppState,
    options: Vec<&'static str>,
    selected: usize,
    status_message: String,
    quit: bool,
    selected_script: Option<PathBuf>,
    return_to_menu: bool,
}

impl App {
    fn new() -> App {
        App {
            state: AppState::Choosing,
            options: vec!["Arch Linux", "Fedora Linux"],
            selected: 0,
            status_message: String::new(),
            quit: false,
            selected_script: None,
            return_to_menu: false,
        }
    }

    fn next(&mut self) {
        if self.selected < self.options.len() - 1 {
            self.selected += 1;
        } else {
            self.selected = 0;
        }
    }

    fn previous(&mut self) {
        if self.selected > 0 {
            self.selected -= 1;
        } else {
            self.selected = self.options.len() - 1;
        }
    }

    fn run_installer(&mut self) {
        self.state = AppState::Installing;
        self.status_message = format!("Selected {} for installation", self.options[self.selected]);

        let (package_manager, expected_distro) = match self.selected {
            0 => ("pacman", "Arch Linux"),
            1 => ("dnf", "Fedora Linux"),
            _ => ("", ""),
        };

        if !package_manager.is_empty() && !check_package_manager_exists(package_manager) {
            self.status_message = format!(
                "Error: {} package manager not found.\nThis suggests you are not running {}.\nCannot continue with installation.",
                package_manager, expected_distro
            );
            self.state = AppState::Finished;
            return;
        }

        let exe_path = env::current_exe().unwrap_or_else(|_| PathBuf::from("."));
        let exe_dir = exe_path.parent().unwrap_or_else(|| Path::new("."));

        let script_path = match self.selected {
            0 => "arch/install.sh",
            1 => "fedora/install.sh",
            _ => "",
        };

        let possible_paths = [
            PathBuf::from(script_path),
            exe_dir.join(script_path),
            Path::new("platforms").join(script_path),
            Path::new("..").join(script_path),
        ];

        let script_full_path = possible_paths.iter().find(|p| p.exists()).cloned();

        match script_full_path {
            Some(path) => {
                self.selected_script = Some(path);
                self.status_message = format!(
                    "Selected: {}\nExiting TUI to run script...",
                    self.options[self.selected]
                );
                self.quit = true;
            }
            None => {
                self.status_message = "Error: Installation script not found.".to_string();
                self.state = AppState::Finished;
            }
        };
    }
}

fn check_package_manager_exists(package_manager: &str) -> bool {
    let output = Command::new("which").arg(package_manager).output();

    match output {
        Ok(output) => output.status.success(),
        Err(_) => false,
    }
}

fn main() -> Result<(), io::Error> {
    let mut should_continue = true;

    while should_continue {
        enable_raw_mode()?;
        let mut stdout = io::stdout();
        execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
        let backend = CrosstermBackend::new(stdout);
        let mut terminal = Terminal::new(backend)?;

        let mut app = App::new();
        let res = run_app(&mut terminal, &mut app);

        disable_raw_mode()?;
        execute!(
            terminal.backend_mut(),
            LeaveAlternateScreen,
            DisableMouseCapture
        )?;
        terminal.show_cursor()?;

        if let Err(err) = res {
            eprintln!("{:?}", err);
            break;
        }

        if app.quit && app.selected_script.is_some() {
            let script_path = app.selected_script.unwrap();
            let status = Command::new("bash")
                .arg("-c")
                .arg(format!("source '{}'", script_path.display()))
                .status();

            enable_raw_mode()?;
            let mut stdout = io::stdout();
            execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
            let backend = CrosstermBackend::new(stdout);
            let mut terminal = Terminal::new(backend)?;

            let mut post_app = App::new();
            post_app.state = AppState::PostInstall;

            match status {
                Ok(exit_status) => {
                    if exit_status.success() {
                        post_app.status_message = format!(
                            "Installation of {} completed successfully!",
                            app.options[app.selected]
                        );
                    } else {
                        post_app.status_message = format!(
                            "Installation of {} failed with status code: {:?}",
                            app.options[app.selected],
                            exit_status.code()
                        );
                    }
                }
                Err(e) => {
                    post_app.status_message = format!("Failed to run installer: {}", e);
                }
            }

            let post_res = run_app(&mut terminal, &mut post_app);

            disable_raw_mode()?;
            execute!(
                terminal.backend_mut(),
                LeaveAlternateScreen,
                DisableMouseCapture
            )?;
            terminal.show_cursor()?;

            if let Err(err) = post_res {
                eprintln!("{:?}", err);
                break;
            }

            should_continue = post_app.return_to_menu;
        } else {
            should_continue = false;
        }
    }

    clear_screen()?;
    Ok(())
}

fn clear_screen() -> io::Result<()> {
    let mut stdout = io::stdout();
    execute!(stdout, TermClear(ClearType::All), cursor::MoveTo(0, 0))?;
    stdout.flush()?;
    Ok(())
}

fn run_app<B: Backend>(terminal: &mut Terminal<B>, app: &mut App) -> io::Result<()> {
    loop {
        terminal.draw(|f| ui(f, app))?;

        if app.quit {
            return Ok(());
        }

        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press {
                    match app.state {
                        AppState::Choosing => match key.code {
                            KeyCode::Char('q') => app.quit = true,
                            KeyCode::Char('j') | KeyCode::Down => app.next(),
                            KeyCode::Char('k') | KeyCode::Up => app.previous(),
                            KeyCode::Enter => app.state = AppState::Confirming,
                            _ => {}
                        },
                        AppState::Confirming => match key.code {
                            KeyCode::Char('y') | KeyCode::Char('Y') => app.run_installer(),
                            KeyCode::Char('n') | KeyCode::Char('N') | KeyCode::Esc => {
                                app.state = AppState::Choosing
                            }
                            _ => {}
                        },
                        AppState::Finished => match key.code {
                            KeyCode::Enter => {
                                app.state = AppState::Choosing;
                                app.selected = 0;
                                app.status_message = String::new();
                                app.selected_script = None;
                                app.quit = false;
                            }
                            KeyCode::Char('q') | KeyCode::Char('Q') | KeyCode::Esc => {
                                app.quit = true;
                            }
                            _ => {}
                        },
                        AppState::PostInstall => match key.code {
                            KeyCode::Enter | KeyCode::Char('m') | KeyCode::Char('M') => {
                                app.return_to_menu = true;
                                app.quit = true;
                            }
                            KeyCode::Char('q') | KeyCode::Char('Q') | KeyCode::Esc => {
                                app.return_to_menu = false;
                                app.quit = true;
                            }
                            _ => {}
                        },
                        _ => {}
                    }
                }
            }
        }
    }
}

fn ui<B: Backend>(f: &mut Frame<B>, app: &App) {
    let size = f.size();

    let popup_width = 60;
    let popup_height = 15;
    let popup_area = Rect {
        x: (size.width - popup_width) / 2,
        y: (size.height - popup_height) / 2,
        width: popup_width,
        height: popup_height,
    };

    f.render_widget(Clear, popup_area);

    match app.state {
        AppState::Choosing => draw_selection_ui(f, app, popup_area),
        AppState::Confirming => draw_confirmation_ui(f, app, popup_area),
        AppState::Installing => draw_installing_ui(f, app, popup_area),
        AppState::Finished => draw_finished_ui(f, app, popup_area),
        AppState::PostInstall => draw_post_install_ui(f, app, popup_area),
    }
}

fn draw_selection_ui<B: Backend>(f: &mut Frame<B>, app: &App, area: Rect) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Color::Cyan))
        .title("Carch Installer");

    f.render_widget(block.clone(), area);
    let inner_area = block.inner(area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(2)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(5),
            Constraint::Length(2),
        ])
        .split(inner_area);

    let title_text = vec![
        Spans::from(vec![
            Span::styled("╭─", Style::default().fg(Color::DarkGray)),
            Span::styled("★ ", Style::default().fg(Color::Yellow)),
            Span::styled(
                "CARCH",
                Style::default()
                    .fg(Color::Magenta)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled(" ★", Style::default().fg(Color::Yellow)),
            Span::styled("─╮", Style::default().fg(Color::DarkGray)),
        ]),
        Spans::from(vec![
            Span::styled("╰─", Style::default().fg(Color::DarkGray)),
            Span::styled(
                " Select Your Distribution ",
                Style::default()
                    .fg(Color::Cyan)
                    .add_modifier(Modifier::ITALIC),
            ),
            Span::styled("─╯", Style::default().fg(Color::DarkGray)),
        ]),
    ];

    let title = Paragraph::new(title_text).alignment(Alignment::Center);

    f.render_widget(title, chunks[0]);

    let items: Vec<ListItem> = app
        .options
        .iter()
        .enumerate()
        .map(|(i, &item)| {
            let content = Spans::from(Span::styled(
                item,
                Style::default().fg(if i == app.selected {
                    Color::Yellow
                } else {
                    Color::White
                }),
            ));
            ListItem::new(content)
        })
        .collect();

    let list = List::new(items)
        .block(Block::default().borders(Borders::NONE))
        .highlight_style(
            Style::default()
                .bg(Color::Rgb(235, 235, 210))
                .fg(Color::Black)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("");

    let mut list_state = ratatui::widgets::ListState::default();
    list_state.select(Some(app.selected));

    f.render_stateful_widget(list, chunks[1], &mut list_state);

    let help_text = Paragraph::new(vec![Spans::from(vec![
        Span::styled("j/k: Navigate  ", Style::default().fg(Color::Gray)),
        Span::styled("Enter: Select  ", Style::default().fg(Color::Gray)),
        Span::styled("q: Quit", Style::default().fg(Color::Gray)),
    ])])
    .alignment(Alignment::Center);

    f.render_widget(help_text, chunks[2]);
}

fn draw_confirmation_ui<B: Backend>(f: &mut Frame<B>, app: &App, area: Rect) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Color::White))
        .title("Confirm");

    f.render_widget(block.clone(), area);
    let inner_area = block.inner(area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(2)
        .constraints([Constraint::Length(3), Constraint::Min(2)])
        .split(inner_area);

    let confirm_text = Paragraph::new(vec![
        Spans::from(vec![Span::styled(
            format!("Install {} ?", app.options[app.selected]),
            Style::default()
                .fg(Color::White)
                .add_modifier(Modifier::BOLD),
        )]),
        Spans::from(Span::raw("")),
    ])
    .alignment(Alignment::Center);

    let options_text = Paragraph::new(vec![Spans::from(vec![
        Span::styled("[", Style::default().fg(Color::Gray)),
        Span::styled(
            "Y",
            Style::default()
                .fg(Color::Green)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled("] to continue   [", Style::default().fg(Color::Gray)),
        Span::styled(
            "N",
            Style::default().fg(Color::Red).add_modifier(Modifier::BOLD),
        ),
        Span::styled("] to abort", Style::default().fg(Color::Gray)),
    ])])
    .alignment(Alignment::Center);

    f.render_widget(confirm_text, chunks[0]);
    f.render_widget(options_text, chunks[1]);
}

fn draw_installing_ui<B: Backend>(f: &mut Frame<B>, app: &App, area: Rect) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Color::Blue))
        .title("Installing");

    f.render_widget(block.clone(), area);
    let inner_area = block.inner(area);

    let text = Paragraph::new(vec![
        Spans::from(Span::raw("")),
        Spans::from(vec![Span::styled(
            &app.status_message,
            Style::default()
                .fg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        )]),
        Spans::from(Span::raw("")),
        Spans::from(vec![Span::styled(
            "Please wait...",
            Style::default().fg(Color::Gray),
        )]),
    ])
    .alignment(Alignment::Center);

    f.render_widget(text, inner_area);
}

fn draw_finished_ui<B: Backend>(f: &mut Frame<B>, app: &App, area: Rect) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Color::Green))
        .title("Installation Complete");

    f.render_widget(block.clone(), area);
    let inner_area = block.inner(area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(2)
        .constraints([Constraint::Min(5), Constraint::Length(2)])
        .split(inner_area);

    let text = Paragraph::new(app.status_message.clone())
        .style(Style::default().fg(Color::Cyan))
        .alignment(Alignment::Center)
        .wrap(ratatui::widgets::Wrap { trim: true });

    let help_text = Paragraph::new(vec![Spans::from(vec![
        Span::styled("Press ", Style::default().fg(Color::Gray)),
        Span::styled(
            "Enter",
            Style::default()
                .fg(Color::Green)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled(" to return to menu or ", Style::default().fg(Color::Gray)),
        Span::styled(
            "q",
            Style::default().fg(Color::Red).add_modifier(Modifier::BOLD),
        ),
        Span::styled(" to exit", Style::default().fg(Color::Gray)),
    ])])
    .alignment(Alignment::Center);

    f.render_widget(text, chunks[0]);
    f.render_widget(help_text, chunks[1]);
}

fn draw_post_install_ui<B: Backend>(f: &mut Frame<B>, app: &App, area: Rect) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Color::Green))
        .title("Installation Complete");

    f.render_widget(block.clone(), area);
    let inner_area = block.inner(area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(2)
        .constraints([Constraint::Min(5), Constraint::Length(2)])
        .split(inner_area);

    let text = Paragraph::new(app.status_message.clone())
        .style(
            Style::default()
                .fg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        )
        .alignment(Alignment::Center)
        .wrap(ratatui::widgets::Wrap { trim: true });

    let help_text = Paragraph::new(vec![Spans::from(vec![
        Span::styled("Press ", Style::default().fg(Color::Gray)),
        Span::styled(
            "M",
            Style::default()
                .fg(Color::Green)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled(" to return to menu or ", Style::default().fg(Color::Gray)),
        Span::styled(
            "Q",
            Style::default().fg(Color::Red).add_modifier(Modifier::BOLD),
        ),
        Span::styled(" to exit", Style::default().fg(Color::Gray)),
    ])])
    .alignment(Alignment::Center);

    f.render_widget(text, chunks[0]);
    f.render_widget(help_text, chunks[1]);
}
