use std::{
    env,
    fs,
    io::{self, stdout, BufRead, BufReader},
    process::{Command, Stdio},
};
use colored::*;
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::Span,
    widgets::{Block, Borders, List, ListItem, Paragraph},
    Terminal,
    widgets::ListState,
};
use crossterm::{
    event::{self, Event, KeyCode},
    execute,
};

const HELP_MESSAGE: &str = "This tool helps to automate Arch Linux setup.\n\n\
                            Select 'Arch Setup' to install packages and configure the system.\n\
                            For more information, visit: https://harilvfs.github.io/carch/";

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut stdout = stdout();
    execute!(stdout, crossterm::terminal::EnterAlternateScreen)?;
    crossterm::terminal::enable_raw_mode()?;

    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut menu_state = ListState::default();
    menu_state.select(Some(0)); // Set initial selection
    let mut output_log = Vec::new();

    loop {
        terminal.draw(|f| {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints(
                    [Constraint::Percentage(30), Constraint::Percentage(60), Constraint::Percentage(10)].as_ref(),
                )
                .split(f.area());

            let menu_items = vec![
                ListItem::new(Span::raw("Arch Setup")),
                ListItem::new(Span::raw("Help & Info")),
                ListItem::new(Span::raw("Exit")),
            ];

            let menu = List::new(menu_items)
                .block(Block::default().borders(Borders::ALL).title("Linux System Arch Setup"))
                .highlight_style(Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD))
                .highlight_symbol(">> ");

            f.render_stateful_widget(menu, chunks[0], &mut menu_state);

            // Display the output of the script in the bottom area of the TUI
            let output_paragraph = Paragraph::new(output_log.join("\n"))
                .block(Block::default().borders(Borders::ALL).title("Script Output"));

            f.render_widget(output_paragraph, chunks[1]);
        })?;

        if let Event::Key(key) = event::read()? {
            match key.code {
                KeyCode::Down => {
                    let i = menu_state.selected().unwrap_or(0);
                    let next_index = if i >= 2 { 0 } else { i + 1 };
                    menu_state.select(Some(next_index));
                }
                KeyCode::Up => {
                    let i = menu_state.selected().unwrap_or(0);
                    let next_index = if i == 0 { 2 } else { i - 1 };
                    menu_state.select(Some(next_index));
                }
                KeyCode::Enter => match menu_state.selected() {
                    Some(0) => display_submenu(&mut terminal, &mut output_log)?, // Arch Setup
                    Some(1) => display_help()?, // Help & Info
                    Some(2) => break, // Exit
                    _ => unreachable!(),
                },
                KeyCode::Char('q') => break, // Exit on 'q'
                _ => {}
            }
        }
    }

    // Cleanup and exit
    crossterm::terminal::disable_raw_mode()?;
    execute!(terminal.backend_mut(), crossterm::terminal::LeaveAlternateScreen)?;

    Ok(())
}

fn display_submenu(terminal: &mut Terminal<CrosstermBackend<io::Stdout>>, output_log: &mut Vec<String>) -> Result<(), Box<dyn std::error::Error>> {
    let scripts = load_scripts();

    if scripts.is_empty() {
        output_log.push("No scripts found.".red().to_string());
        return Ok(());
    }

    let mut submenu_state = ListState::default();
    submenu_state.select(Some(0));

    loop {
        terminal.draw(|f| {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints(
                    [Constraint::Percentage(30), Constraint::Percentage(60), Constraint::Percentage(10)].as_ref(),
                )
                .split(f.area());

            let script_items: Vec<ListItem> = scripts
                .iter()
                .map(|script| ListItem::new(Span::raw(script)))
                .collect();

            let submenu = List::new(script_items)
                .block(Block::default().borders(Borders::ALL).title("Arch Setup Options"))
                .highlight_style(Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD))
                .highlight_symbol(">> ");

            f.render_stateful_widget(submenu, chunks[0], &mut submenu_state);

            let output_paragraph = Paragraph::new(output_log.join("\n"))
                .block(Block::default().borders(Borders::ALL).title("Script Output"));
            f.render_widget(output_paragraph, chunks[1]);

            // Display input buffer for continuation
            let input_paragraph = Paragraph::new("Press Enter to continue...")
                .block(Block::default().borders(Borders::ALL).title("Input"));
            f.render_widget(input_paragraph, chunks[2]);
        })?;

        if let Event::Key(key) = event::read()? {
            match key.code {
                KeyCode::Down => {
                    let i = submenu_state.selected().unwrap_or(0);
                    let next_index = if i >= scripts.len() - 1 { 0 } else { i + 1 };
                    submenu_state.select(Some(next_index));
                }
                KeyCode::Up => {
                    let i = submenu_state.selected().unwrap_or(0);
                    let next_index = if i == 0 { scripts.len() - 1 } else { i - 1 };
                    submenu_state.select(Some(next_index));
                }
                KeyCode::Enter => {
                    let script_name = &scripts[submenu_state.selected().unwrap()];
                    run_script(script_name, output_log)?;
                }
                KeyCode::Char('q') => break, // Exit on 'q'
                _ => {}
            }
        }
    }

    Ok(())
}

fn load_scripts() -> Vec<String> {
    let mut scripts = Vec::new();
    let current_dir = env::current_dir().expect("Failed to get current directory");
    let script_dirs = vec![
        current_dir.join("scripts"),
        current_dir.join("../scripts"),
    ];

    for script_dir in script_dirs {
        if let Ok(entries) = fs::read_dir(&script_dir) {
            for entry in entries.filter_map(Result::ok) {
                let path = entry.path();
                if let Some(file_name) = path.file_name() {
                    if let Some(name) = file_name.to_str() {
                        if name.ends_with(".sh") {
                            let script_name = name.trim_end_matches(".sh");
                            scripts.push(script_name.to_string());
                        }
                    }
                }
            }
        }
    }

    scripts
}

fn run_script(script_name: &str, output_log: &mut Vec<String>) -> Result<(), Box<dyn std::error::Error>> {
    let current_dir = env::current_dir().expect("Failed to get current directory");
    let script_paths = vec![
        current_dir.join("scripts").join(format!("{}.sh", script_name)),
        current_dir.join("../scripts").join(format!("{}.sh", script_name)),
    ];

    let mut script_found = false;

    for script_path in script_paths {
        if script_path.exists() {
            let output = Command::new("bash")
                .arg(script_path)
                .stdout(Stdio::piped())
                .spawn()?
                .stdout
                .ok_or("Failed to open script stdout")?;

            let reader = BufReader::new(output);
            for line in reader.lines() {
                let line = line.unwrap_or_else(|_| "Error reading line".into());
                output_log.push(line);
            }

            script_found = true;
            break;
        }
    }

    if !script_found {
        output_log.push(format!("Script '{}' not found.", script_name));
    }

    output_log.push("Press Enter to return to the submenu...".into());
    let _ = std::io::stdin().read_line(&mut String::new());

    Ok(())
}

fn display_help() -> Result<(), Box<dyn std::error::Error>> {
    println!("{}", HELP_MESSAGE.blue());
    println!("Press Enter to return to the menu...");
    let _ = std::io::stdin().read_line(&mut String::new());
    Ok(())
}
