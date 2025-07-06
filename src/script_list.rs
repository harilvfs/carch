use std::path::Path;
use std::time::{Duration, Instant};
use std::{fs, io};

use crossterm::event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode};
use crossterm::execute;
use crossterm::terminal::{
    EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode,
};
use ratatui::backend::CrosstermBackend;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph};
use ratatui::{Frame, Terminal};

struct ScriptListApp {
    scroll:            u16,
    categories:        Vec<String>,
    scripts:           Vec<Vec<String>>,
    selected_category: Option<usize>,
    cursor_position:   usize,
}

impl ScriptListApp {
    fn new(script_dir: &Path) -> Self {
        let mut app = ScriptListApp {
            scroll:            0,
            categories:        Vec::new(),
            scripts:           Vec::new(),
            selected_category: None,
            cursor_position:   0,
        };

        app.load_scripts(script_dir);
        app
    }

    fn load_scripts(&mut self, script_dir: &Path) {
        self.categories.clear();
        self.scripts.clear();

        if let Ok(entries) = fs::read_dir(script_dir) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.is_dir()
                    && let Some(category_name) = path.file_name().and_then(|n| n.to_str())
                {
                    self.categories.push(category_name.to_string());

                    let mut category_scripts = Vec::new();
                    if let Ok(script_entries) = fs::read_dir(&path) {
                        for script_entry in script_entries.flatten() {
                            let script_path = script_entry.path();
                            if script_path.is_file()
                                && script_path.extension().and_then(|ext| ext.to_str())
                                    == Some("sh")
                                && let Some(script_name) =
                                    script_path.file_stem().and_then(|n| n.to_str())
                            {
                                category_scripts.push(script_name.to_string());
                            }
                        }
                    }

                    category_scripts.sort();
                    self.scripts.push(category_scripts);
                }
            }
        }

        let mut sorted_data: Vec<(String, Vec<String>)> =
            self.categories.iter().cloned().zip(self.scripts.iter().cloned()).collect();

        sorted_data.sort_by(|a, b| a.0.cmp(&b.0));

        self.categories = sorted_data.iter().map(|(cat, _)| cat.clone()).collect();
        self.scripts = sorted_data.iter().map(|(_, scripts)| scripts.clone()).collect();
    }

    fn toggle_category(&mut self, index: usize) {
        if self.selected_category == Some(index) {
            self.selected_category = None;
        } else {
            self.selected_category = Some(index);
        }
    }

    fn toggle_current_category(&mut self) {
        if !self.categories.is_empty() {
            self.toggle_category(self.cursor_position);
        }
    }

    fn move_cursor_up(&mut self) {
        if self.cursor_position > 0 {
            self.cursor_position -= 1;
            if self.cursor_position < self.scroll as usize {
                self.scroll = self.cursor_position as u16;
            }
        }
    }

    fn move_cursor_down(&mut self) {
        if !self.categories.is_empty() && self.cursor_position < self.categories.len() - 1 {
            self.cursor_position += 1;
            if self.cursor_position > (self.scroll as usize) + 10 {
                self.scroll = (self.cursor_position - 10) as u16;
            }
        }
    }
}

pub fn list_scripts(script_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    if let Err(e) = display_script_list_tui(script_dir) {
        // fall back to text mode if TUI fails
        display_script_list_text(script_dir)?;
        return Err(e);
    }
    Ok(())
}

fn display_script_list_tui(script_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut app = ScriptListApp::new(script_dir);
    let tick_rate = Duration::from_millis(100);
    let mut last_tick = Instant::now();

    loop {
        terminal.draw(|f| ui(f, &app))?;

        let timeout =
            tick_rate.checked_sub(last_tick.elapsed()).unwrap_or_else(|| Duration::from_secs(0));

        if crossterm::event::poll(timeout)?
            && let Event::Key(key) = event::read()?
        {
            match key.code {
                KeyCode::Char('q') | KeyCode::Esc => break,
                KeyCode::Up | KeyCode::Char('k') => app.move_cursor_up(),
                KeyCode::Down | KeyCode::Char('j') => app.move_cursor_down(),
                KeyCode::PageUp => {
                    for _ in 0..10 {
                        app.move_cursor_up();
                    }
                }
                KeyCode::PageDown => {
                    for _ in 0..10 {
                        app.move_cursor_down();
                    }
                }
                KeyCode::Home => {
                    app.scroll = 0;
                    app.cursor_position = 0;
                }
                KeyCode::Enter => {
                    app.toggle_current_category();
                }
                _ => {}
            }
        }

        if last_tick.elapsed() >= tick_rate {
            last_tick = Instant::now();
        }
    }

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen, DisableMouseCapture)?;
    terminal.show_cursor()?;

    Ok(())
}

fn ui(f: &mut Frame, app: &ScriptListApp) {
    let size = f.area();

    let width = (size.width as f32 * 0.8) as u16;
    let height = (size.height as f32 * 0.8) as u16;
    let main_area = centered_rect(width, height, size);

    f.render_widget(Clear, main_area);

    let block = Block::default()
        .title(Span::styled(
            " AVAILABLE SCRIPTS ",
            Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD),
        ))
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::Cyan))
        .border_type(BorderType::Rounded);

    let mut content = Vec::new();

    content.push(Line::from(Span::styled(
        "Available script categories:",
        Style::default().fg(Color::Cyan),
    )));
    content.push(Line::from(""));

    for (i, category) in app.categories.iter().enumerate() {
        let is_cursor_here = i == app.cursor_position;
        let is_selected = app.selected_category == Some(i);

        let cursor_indicator = if is_cursor_here { "➤ " } else { "  " };

        let category_style = if is_selected {
            Style::default().fg(Color::Green).add_modifier(Modifier::BOLD)
        } else if is_cursor_here {
            Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)
        } else {
            Style::default().fg(Color::Cyan)
        };

        content.push(Line::from(vec![
            Span::styled(cursor_indicator, Style::default().fg(Color::Yellow)),
            Span::styled(format!("{category}:"), category_style),
        ]));

        if is_selected {
            if app.scripts[i].is_empty() {
                content.push(Line::from(Span::styled(
                    "    No scripts found in this category",
                    Style::default().fg(Color::DarkGray),
                )));
            } else {
                for script in &app.scripts[i] {
                    content.push(Line::from(Span::styled(
                        format!("    - {script}"),
                        Style::default().fg(Color::Yellow),
                    )));
                }
            }
        }

        content.push(Line::from(""));
    }

    content.push(Line::from(""));
    content.push(Line::from(vec![
        Span::styled("↑/↓", Style::default().fg(Color::DarkGray)),
        Span::styled("/", Style::default().fg(Color::DarkGray)),
        Span::styled("j/k", Style::default().fg(Color::DarkGray)),
        Span::styled(" navigate  ", Style::default().fg(Color::DarkGray)),
        Span::styled("Enter", Style::default().fg(Color::DarkGray)),
        Span::styled(" expand/collapse  ", Style::default().fg(Color::DarkGray)),
        Span::styled("q", Style::default().fg(Color::DarkGray)),
        Span::styled(" quit", Style::default().fg(Color::DarkGray)),
    ]));

    let script_paragraph =
        Paragraph::new(content).block(block).alignment(Alignment::Left).scroll((app.scroll, 0));

    f.render_widget(script_paragraph, main_area);
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

pub fn display_script_list_text(script_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    println!("\x1b[36mAvailable scripts:\x1b[0m");

    let mut categories = Vec::new();
    if let Ok(entries) = fs::read_dir(script_dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir()
                && let Some(name) = path.file_name().and_then(|n| n.to_str())
            {
                categories.push((name.to_string(), path));
            }
        }
    }

    categories.sort_by(|a, b| a.0.cmp(&b.0));

    for (category, path) in categories {
        println!("\x1b[36m{category}:\x1b[0m");

        let mut script_files = Vec::new();
        if let Ok(script_entries) = fs::read_dir(&path) {
            for script_entry in script_entries.flatten() {
                let script_path = script_entry.path();
                if script_path.is_file()
                    && script_path.extension().and_then(|ext| ext.to_str()) == Some("sh")
                    && let Some(script_name) = script_path.file_stem().and_then(|n| n.to_str())
                {
                    script_files.push(script_name.to_string());
                }
            }
        }

        script_files.sort();

        if script_files.is_empty() {
            println!("  No scripts found in {category}");
        } else {
            for script in script_files {
                println!("  - {script}");
            }
        }
        println!();
    }

    Ok(())
}
