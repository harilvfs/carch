use std::io::{stdout};
use std::process::{Command, Stdio};
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
    terminal::{EnterAlternateScreen, LeaveAlternateScreen},
   };

const HELP_MESSAGE: &str = "This tool helps to automate Arch Linux setup.\n\
                            Select 'Arch Setup' to install packages and configure the system.\n\
                            Press Enter to return to the menu.";

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut stdout = stdout();
    execute!(stdout, EnterAlternateScreen)?;
    crossterm::terminal::enable_raw_mode()?;

    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut menu_state = ListState::default();
    menu_state.select(Some(0)); 
    let mut output_message = String::new();

    loop {
        terminal.draw(|f| {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints(
                    [Constraint::Percentage(60), Constraint::Percentage(40)].as_ref(),
                )
                .split(f.area());

            let menu_items = vec![
                ListItem::new(Span::raw("Arch Setup")),
                ListItem::new(Span::raw("Hyprland Setup")),  
                ListItem::new(Span::raw("Help & Info")),
                ListItem::new(Span::raw("Exit")),
            ];

            let menu = List::new(menu_items)
                .block(Block::default().borders(Borders::ALL).title("Linux System Arch Setup"))
                .highlight_style(Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD))
                .highlight_symbol(">> ");

            f.render_stateful_widget(menu, chunks[0], &mut menu_state);

            let output_paragraph = Paragraph::new(Span::raw(&output_message))
                .block(Block::default().borders(Borders::ALL).title("Output"));

            f.render_widget(output_paragraph, chunks[1]);
        })?;

        if let Event::Key(key) = event::read()? {
            match key.code {
                KeyCode::Down => {
                    let i = menu_state.selected().unwrap_or(0);
                    let next_index = if i >= 3 { 0 } else { i + 1 };  
                    menu_state.select(Some(next_index));
                }
                KeyCode::Up => {
                    let i = menu_state.selected().unwrap_or(0);
                    let next_index = if i == 0 { 3 } else { i - 1 };  
                    menu_state.select(Some(next_index));
                }
                KeyCode::Enter => match menu_state.selected() {
                    Some(0) => {
                        output_message = String::from("Running Arch Setup...\nPress Enter to return to menu.");
                    }
                    Some(1) => {  
                        // Running Hyprland setup
                        output_message = String::from("Running Hyprland Setup...\n");

                        // Execute the cloning command and capture the output
                        let output = Command::new("git")
                            .args(&["clone", "https://github.com/your/repo/hyprland.git", "$HOME/.config/hyprland"])
                            .stdout(Stdio::piped())
                            .stderr(Stdio::piped())
                            .output()
                            .expect("Failed to execute command");

                        // Convert the output to a string
                        let stdout = String::from_utf8_lossy(&output.stdout);
                        let stderr = String::from_utf8_lossy(&output.stderr);

                        // Update output_message with the command output
                        output_message.push_str("Cloning into '$HOME/.config/hyprland'...\n");
                        output_message.push_str(&stdout);
                        output_message.push_str(&stderr);
                        output_message.push_str("Hyprland setup completed successfully!\n");
                    }
                    Some(2) => {
                        output_message = String::from(HELP_MESSAGE);
                    }
                    Some(3) => break, 
                    _ => unreachable!(),
                },
                KeyCode::Char('q') => break, 
                _ => {}
            }
        }
    }

    crossterm::terminal::disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;

    Ok(())
}

