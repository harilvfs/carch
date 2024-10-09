use ratatui::{
    backend::{Backend, TermionBackend},
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::Span,
    widgets::{Block, Borders, List, ListItem},
    Terminal,
};
use std::fs;
use std::io;
use std::process::{Command, exit};
use termion::event::Key;
use termion::input::TermRead;
use termion::raw::IntoRawMode;

fn main() -> Result<(), io::Error> {
    // Set up terminal
    let stdout = io::stdout().into_raw_mode()?;
    let backend = TermionBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Main menu items
    let menu_items = vec!["Arch Setup", "Help & Info", "Exit"];
    let mut selected_index = 0;

    // Main loop
    loop {
        // Draw the UI
        terminal.draw(|f| {
            let area = f.area();
            let block = Block::default()
                .borders(Borders::ALL)
                .title("MainMenu");

            let items: Vec<ListItem> = menu_items
                .iter()
                .enumerate()
                .map(|(i, &item)| {
                    let style = if i == selected_index {
                        Style::default().fg(Color::Red).add_modifier(Modifier::BOLD)
                    } else {
                        Style::default().fg(Color::White)
                    };
                    ListItem::new(Span::styled(item, style))
                })
                .collect();

            let list = List::new(items)
                .block(block)
                .highlight_style(Style::default().fg(Color::Green));

            f.render_widget(list, area);
        })?;

        // Handle input
        let stdin = io::stdin();
        for evt in stdin.keys() {
            match evt? {
                Key::Char('q') => {
                    // Exit on 'q'
                    terminal.clear()?;
                    exit(0);
                }
                Key::Up => {
                    if selected_index > 0 {
                        selected_index -= 1;
                    }
                }
                Key::Down => {
                    if selected_index < menu_items.len() - 1 {
                        selected_index += 1;
                    }
                }
                Key::Char('\n') => {
                    match selected_index {
                        0 => display_submenu(&mut terminal)?,
                        1 => display_help(),
                        2 => {
                            terminal.clear()?;
                            exit(0);
                        }
                        _ => {}
                    }
                }
                _ => {}
            }
        }
    }
}

fn display_submenu<B: Backend>(terminal: &mut Terminal<B>) -> Result<(), io::Error> {
    // Load script names from the /scripts directory
    let script_dir = "./scripts";
    let script_names = load_scripts(script_dir)?;

    let mut selected_index = 0;

    loop {
        // Draw submenu UI
        terminal.draw(|f| {
            let area = f.area();
            let block = Block::default()
                .borders(Borders::ALL)
                .title("Arch Setup Scripts");

            let items: Vec<ListItem> = script_names
                .iter()
                .enumerate()
                .map(|(i, script)| {
                    let style = if i == selected_index {
                        Style::default().fg(Color::Red).add_modifier(Modifier::BOLD)
                    } else {
                        Style::default().fg(Color::White)
                    };
                    ListItem::new(Span::styled(script, style))
                })
                .collect();

            let list = List::new(items)
                .block(block)
                .highlight_style(Style::default().fg(Color::Green));

            f.render_widget(list, area);
        })?;

        // Handle input in submenu
        let stdin = io::stdin();
        for evt in stdin.keys() {
            match evt? {
                Key::Char('q') => {
                    // Exit on 'q'
                    return Ok(());
                }
                Key::Up => {
                    if selected_index > 0 {
                        selected_index -= 1;
                    }
                }
                Key::Down => {
                    if selected_index < script_names.len() - 1 {
                        selected_index += 1;
                    }
                }
                Key::Char('\n') => {
                    // Run the selected script
                    run_script(&script_names[selected_index]);
                }
                _ => {}
            }
        }
    }
}

fn load_scripts(dir: &str) -> Result<Vec<String>, io::Error> {
    let mut scripts = Vec::new();
    for entry in fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_file() {
            if let Some(ext) = path.extension() {
                if ext == "sh" {
                    if let Some(file_name) = path.file_stem() {
                        if let Some(file_name_str) = file_name.to_str() {
                            scripts.push(file_name_str.to_string());
                        }
                    }
                }
            }
        }
    }
    Ok(scripts)
}

fn run_script(script_name: &str) {
    // Run the selected script from the /scripts directory
    let script_path = format!("./scripts/{}.sh", script_name);
    println!("Running script: {}", script_path);

    if let Ok(mut child) = Command::new("bash")
        .arg(script_path)
        .spawn()
    {
        let _ = child.wait();
    } else {
        println!("Failed to run script: {}", script_name);
    }
}

fn display_help() {
    // Display help message
    println!("This tool helps to automate Arch Linux setup.");
    println!("For more information, visit: https://harilvfs.github.io/carch/");
}

