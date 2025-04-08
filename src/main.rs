use include_dir::{Dir, include_dir};
use std::env;
use std::fs;
use std::io;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::Command;
use std::time::{Duration, Instant};
use tempfile::TempDir;

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

static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/scripts");
const EXECUTABLE_MODE: u32 = 0o755;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();

    if args.len() > 1 && (args[1] == "--help" || args[1] == "-h") {
        if display_help_tui().is_err() {
            display_help_text();
        }
        return Ok(());
    }

    let temp_dir = TempDir::new().map_err(|e| format!("Failed to create temp directory: {}", e))?;
    let temp_path = temp_dir.path();
    extract_and_set_permissions(temp_path)?;

    let script_args = env::args().skip(1);
    let script_path = temp_path.join("carch");
    let status = Command::new(&script_path)
        .args(script_args)
        .current_dir(temp_path)
        .status()
        .map_err(|e| format!("Failed to execute {}: {}", script_path.display(), e))?;

    std::process::exit(status.code().unwrap_or(1));
}

struct App {
    scroll: u16,
}

impl App {
    fn new() -> App {
        App { scroll: 0 }
    }

    fn scroll_up(&mut self) {
        self.scroll = self.scroll.saturating_sub(1);
    }

    fn scroll_down(&mut self) {
        self.scroll = self.scroll.saturating_add(1);
    }
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
        terminal.draw(|f| ui(f, &app))?;

        let timeout = tick_rate
            .checked_sub(last_tick.elapsed())
            .unwrap_or_else(|| Duration::from_secs(0));

        if crossterm::event::poll(timeout)? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Char('q') | KeyCode::Esc => break,
                    KeyCode::Up => app.scroll_up(),
                    KeyCode::Down => app.scroll_down(),
                    KeyCode::PageUp => {
                        for _ in 0..10 {
                            app.scroll_up();
                        }
                    }
                    KeyCode::PageDown => {
                        for _ in 0..10 {
                            app.scroll_down();
                        }
                    }
                    KeyCode::Home => app.scroll = 0,
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

fn ui<B: Backend>(f: &mut Frame<B>, app: &App) {
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
                "  --gen-config            ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Generate a default configuration file in ~/.config/carch/carch.conf."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --config <conf dir>     ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Use a specific configuration file to load selected scripts."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  -c                      ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Use the default configuration file to load selected scripts."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --run-script <name>, -r ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Run the specified script."),
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
                "  --search, -s            ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Search for scripts by keyword."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --no-preview            ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Run without displaying script previews in menus (one-time)."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --disable-preview       ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Permanently disable script previews in menus."),
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
                "  --enable-logging        ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Permanently enable logging in the configuration file."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --update                ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Update Carch using the latest script."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --check-update          ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Check if a new version of Carch is available."),
        ]),
        Spans::from(vec![
            Span::styled(
                "  --uninstall             ",
                Style::default().fg(Color::Yellow),
            ),
            Span::raw("Uninstall Carch and remove all associated files."),
        ]),
        Spans::from(""),
        Spans::from(vec![
            Span::styled("↑/↓", Style::default().fg(Color::DarkGray)),
            Span::styled(" scroll  ", Style::default().fg(Color::DarkGray)),
            Span::styled("PgUp/PgDn", Style::default().fg(Color::DarkGray)),
            Span::styled(" page  ", Style::default().fg(Color::DarkGray)),
            Span::styled("Home", Style::default().fg(Color::DarkGray)),
            Span::styled(" top  ", Style::default().fg(Color::DarkGray)),
            Span::styled("q", Style::default().fg(Color::DarkGray)),
            Span::styled(" quit", Style::default().fg(Color::DarkGray)),
        ]),
    ];

    let help_paragraph = Paragraph::new(help_content)
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

// fallback to normal for terminals that don't support TUI
fn display_help_text() {
    println!("\x1b[36mUsage: carch [OPTIONS]\x1b[0m");
    println!();
    println!("\x1b[36mOptions:\x1b[0m");
    println!("\x1b[33m  --help, -h              \x1b[0mShow this help message and exit.");
    println!("\x1b[33m  --version, -v           \x1b[0mShow the program version.");
    println!(
        "\x1b[33m  --gen-config            \x1b[0mGenerate a default configuration file in ~/.config/carch/carch.conf."
    );
    println!(
        "\x1b[33m  --config <conf dir>     \x1b[0mUse a specific configuration file to load selected scripts."
    );
    println!(
        "\x1b[33m  -c                      \x1b[0mUse the default configuration file to load selected scripts."
    );
    println!("\x1b[33m  --run-script <name>, -r \x1b[0mRun the specified script.");
    println!("\x1b[33m  --list-scripts, -l      \x1b[0mList all available scripts.");
    println!("\x1b[33m  --search, -s            \x1b[0mSearch for scripts by keyword.");
    println!(
        "\x1b[33m  --no-preview            \x1b[0mRun without displaying script previews in menus (one-time)."
    );
    println!(
        "\x1b[33m  --disable-preview       \x1b[0mPermanently disable script previews in menus."
    );
    println!(
        "\x1b[33m  --log                   \x1b[0mEnable logging for the current session only."
    );
    println!(
        "\x1b[33m  --enable-logging        \x1b[0mPermanently enable logging in the configuration file."
    );
    println!("\x1b[33m  --update                \x1b[0mUpdate Carch using the latest script.");
    println!(
        "\x1b[33m  --check-update          \x1b[0mCheck if a new version of Carch is available."
    );
    println!(
        "\x1b[33m  --uninstall             \x1b[0mUninstall Carch and remove all associated files."
    );
    println!();
}

fn extract_and_set_permissions(temp_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    EMBEDDED_DIR
        .extract(temp_path)
        .map_err(|e| format!("Failed to extract embedded files: {}", e))?;

    let main_script_path = temp_path.join("carch");
    set_executable(&main_script_path)?;

    let scripts_dir = temp_path.join("scripts");
    if scripts_dir.exists() && scripts_dir.is_dir() {
        for entry in fs::read_dir(&scripts_dir)
            .map_err(|e| format!("Failed to read scripts directory: {}", e))?
            .flatten()
        {
            let path = entry.path();
            if path.is_file() && path.extension().is_some_and(|ext| ext == "sh") {
                set_executable(&path)?;
            }
        }
    }

    let preview_link = temp_path.join("preview_scripts");
    if fs::remove_file(&preview_link).is_err() {
        // ignore if the link doesn't exist yet
    }

    std::os::unix::fs::symlink(&scripts_dir, &preview_link)
        .map_err(|e| format!("Failed to create preview symlink: {}", e))?;

    let env_file = temp_path.join("carch_env.sh");
    let env_content = format!(
        "#!/bin/bash\n\
         export CARCH_TEMP_DIR=\"{}\"\n\
         export CARCH_SCRIPTS_DIR=\"{}/scripts\"\n",
        temp_path.display(),
        temp_path.display()
    );

    fs::write(&env_file, env_content)
        .map_err(|e| format!("Failed to write environment file: {}", e))?;
    set_executable(&env_file)?;

    Ok(())
}

fn set_executable(path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let mut perms = fs::metadata(path)
        .map_err(|e| format!("Failed to get metadata for {}: {}", path.display(), e))?
        .permissions();
    perms.set_mode(EXECUTABLE_MODE);
    fs::set_permissions(path, perms)
        .map_err(|e| format!("Failed to set permissions for {}: {}", path.display(), e))?;
    Ok(())
}
