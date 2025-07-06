use std::io;
use std::path::Path;
use std::time::Duration;

#[allow(unused_imports)]
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, MouseEvent},
    execute,
    terminal::{EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode},
};
use ratatui::backend::CrosstermBackend;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem, Paragraph};
use ratatui::{Frame, Terminal};

use super::app::{App, AppMode, UiOptions};
use crate::ui::popups;
use crate::version;

fn create_rounded_block() -> Block<'static,> {
    Block::default()
        .borders(Borders::ALL,)
        .border_type(BorderType::Rounded,)
        .border_style(Style::default().fg(Color::Cyan,),)
        .style(Style::default().bg(Color::Reset,),)
}

fn render_title(f: &mut Frame, area: Rect,) {
    let title_block =
        Block::default().borders(Borders::NONE,).border_style(Style::default().fg(Color::Blue,),);

    let inner_area = title_block.inner(area,);

    let title = Paragraph::new(vec![
        Line::from(vec![Span::styled(
            "CARCH",
            Style::default().fg(Color::Cyan,).add_modifier(Modifier::BOLD,),
        )],),
        Line::from(vec![Span::styled(
            "Automate Your Linux System Setup",
            Style::default().fg(Color::Rgb(235, 235, 210,),).add_modifier(Modifier::ITALIC,),
        )],),
        Line::from(vec![Span::styled(
            "───────────────────────",
            Style::default().fg(Color::DarkGray,),
        )],),
    ],)
    .alignment(Alignment::Center,);

    f.render_widget(title_block, area,);
    f.render_widget(title, inner_area,);
}

fn render_script_list(f: &mut Frame, app: &mut App, area: Rect,) {
    let mut list_items = Vec::new();

    for &idx in &app.visible_items {
        let item = &app.scripts.items[idx];

        if item.is_category_header {
            let expanded = *app.expanded_categories.get(&item.category,).unwrap_or(&true,);
            let prefix = if expanded { "▼ " } else { "▶ " };

            list_items.push(ListItem::new(Line::from(vec![Span::styled(
                format!("{}{}", prefix, item.category),
                Style::default().fg(Color::Yellow,).add_modifier(Modifier::BOLD,),
            )],),),);
        } else {
            let is_selected = app.is_script_selected(idx,);
            let prefix = if is_selected { "[✓] " } else { "    " };

            list_items.push(ListItem::new(Line::from(vec![
                Span::styled(
                    prefix,
                    if is_selected {
                        Style::default().fg(Color::Green,).add_modifier(Modifier::BOLD,)
                    } else {
                        Style::default().fg(Color::Gray,)
                    },
                ),
                Span::styled(
                    &item.name,
                    if is_selected {
                        Style::default().fg(Color::Green,).add_modifier(Modifier::BOLD,)
                    } else {
                        Style::default().fg(Color::Gray,)
                    },
                ),
            ],),),);
        }
    }

    let title = if app.multi_select_mode {
        Line::from(vec![Span::styled(
            format!("[{} selected]", app.multi_selected_scripts.len()),
            Style::default().fg(Color::Yellow,),
        )],)
    } else {
        Line::from(vec![Span::styled("Select a script to run", Style::default(),)],)
    };

    let block = create_rounded_block().title(title,);

    let mut script_list = List::new(list_items,)
        .block(block,)
        .highlight_style(
            Style::default()
                .bg(Color::Rgb(235, 235, 210,),)
                .fg(Color::Black,)
                .add_modifier(Modifier::BOLD,),
        )
        .highlight_symbol("",);

    if let Some(selected,) = app.scripts.state.selected()
        && selected < app.scripts.items.len()
        && app.scripts.items[selected].is_category_header
    {
        script_list = script_list.highlight_style(
            Style::default().bg(Color::Yellow,).fg(Color::Black,).add_modifier(Modifier::BOLD,),
        );
    }

    if let Some(selected,) = app.scripts.state.selected() {
        let visible_pos = app.visible_items.iter().position(|&i| i == selected,);
        if let Some(pos,) = visible_pos {
            app.list_state.select(Some(pos,),);
        } else if !app.visible_items.is_empty() {
            app.list_state.select(Some(0,),);
            app.scripts.state.select(Some(app.visible_items[0],),);
        }
    }

    f.render_stateful_widget(script_list, area, &mut app.list_state,);
}


fn render_status_bar(f: &mut Frame, app: &App, area: Rect,) {
    let mode_text = match app.mode {
        AppMode::Normal => {
            if app.multi_select_mode {
                "MULTI-SELECT (Space to select) | (Esc To Exit)"
            } else {
                "NORMAL"
            }
        },
        AppMode::Preview => "PREVIEW",
        AppMode::Search => "SEARCH",
        AppMode::Confirm => "CONFIRM",
        AppMode::Help => "HELP",
    };

    let mode_color = match app.mode {
        AppMode::Normal => {
            if app.multi_select_mode {
                Color::Magenta
            } else {
                Color::Green
            }
        },
        AppMode::Preview => Color::Cyan,
        AppMode::Search => Color::Yellow,
        AppMode::Confirm => Color::Red,
        AppMode::Help => Color::Blue,
    };

    let selected_count = if app.multi_select_mode {
        format!(" {} selected ", app.multi_selected_scripts.len())
    } else {
        String::new()
    };

    let has_selected = !selected_count.is_empty();
    let version = version::get_current_version();

    let status = Line::from(vec![
        Span::styled(
            format!(" MODE: {mode_text} "),
            Style::default().bg(mode_color,).fg(Color::Black,).add_modifier(Modifier::BOLD,),
        ),
        Span::raw(" ",),
        if has_selected {
            Span::styled(
                selected_count,
                Style::default().bg(Color::Yellow,).fg(Color::Black,).add_modifier(Modifier::BOLD,),
            )
        } else {
            Span::raw("",)
        },
        if has_selected { Span::raw(" ",) } else { Span::raw("",) },
        Span::styled(
            " ?: Help | q: Quit ",
            Style::default().bg(Color::Rgb(203, 166, 247,),).fg(Color::Black,),
        ),
        Span::raw(" ",),
        Span::styled(
            format!(" {version} "),
            Style::default().bg(Color::Cyan,).fg(Color::Black,).add_modifier(Modifier::BOLD,),
        ),
    ],);

    let status_widget = Paragraph::new(status,).style(Style::default().bg(Color::Reset,),);

    f.render_widget(status_widget, area,);
}

fn render_normal_ui(f: &mut Frame, app: &mut App, options: &UiOptions,) {
    if app.mode == AppMode::Preview && !options.show_preview {
        app.mode = AppMode::Normal;
    }

    let area = Layout::default()
        .direction(Direction::Vertical,)
        .margin(2,)
        .constraints([Constraint::Min(0,),],)
        .split(f.area(),)[0];

    let chunks = Layout::default()
        .direction(Direction::Vertical,)
        .constraints([
            Constraint::Length(3,),
            Constraint::Min(0,),
            Constraint::Length(1,),
            Constraint::Length(1,),
        ],)
        .split(area,);

    render_title(f, chunks[0],);

    render_script_list(f, app, chunks[1],);

    let help_text =
        Paragraph::new(vec![Line::from(vec![Span::raw("Press 'p' to preview a script.",)],)],)
            .alignment(Alignment::Center,);

    f.render_widget(help_text, chunks[2],);
    render_status_bar(f, app, chunks[3],);
}

fn ui(f: &mut Frame, app: &mut App, options: &UiOptions,) {
    match app.mode {
        AppMode::Search => {
            render_normal_ui(f, app, options,);
            popups::render_search_popup(f, app,);
        },
        AppMode::Confirm => {
            render_normal_ui(f, app, options,);
            popups::render_confirmation_popup(f, app,);
        },
        AppMode::Help => {
            render_normal_ui(f, app, options,);
            let max_scroll = popups::render_help_popup(f, app,);
            app.help_max_scroll = max_scroll;
        },
        AppMode::Normal => {
            render_normal_ui(f, app, options,);
        },
        AppMode::Preview => {
            render_normal_ui(f, app, options,);
            popups::render_preview_popup(f, app,);
        },
    }
}

fn cleanup_terminal(terminal: &mut Terminal<CrosstermBackend<io::Stdout,>,>,) -> io::Result<(),> {
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen, DisableMouseCapture)?;
    terminal.show_cursor()?;
    terminal.clear()?;
    Ok((),)
}

#[allow(dead_code)]
pub fn run_ui<F,>(modules_dir: &Path, run_script_callback: F,) -> io::Result<(),>
where
    F: Fn(&Path,) -> io::Result<(),>,
{
    run_ui_with_options(modules_dir, run_script_callback, UiOptions::default(),)
}

pub fn run_ui_with_options<F,>(
    modules_dir: &Path,
    run_script_callback: F,
    options: UiOptions,
) -> io::Result<(),>
where
    F: Fn(&Path,) -> io::Result<(),>,
{
    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "UI initialization started",);
    }

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout,);
    let mut terminal = Terminal::new(backend,)?;

    terminal.clear()?;

    let mut app = App::new();

    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "Loading scripts from modules directory",);
    }

    app.load_scripts(modules_dir,)?;

    if options.log_mode {
        let _ = crate::commands::log_message(
            "INFO",
            &format!(
                "Loaded {} scripts in {} categories",
                app.scripts.items.iter().filter(|s| !s.is_category_header).count(),
                app.categories.len()
            ),
        );
    }

    if !options.show_preview {
        app.mode = AppMode::Normal;

        if options.log_mode {
            let _ = crate::commands::log_message("INFO", "Preview mode disabled by configuration",);
        }
    }

    while !app.quit {
        terminal.autoresize()?;

        terminal.draw(|f| ui(f, &mut app, &options,),)?;

        if let Ok(true,) = event::poll(Duration::from_millis(100,),)
            && let Ok(event,) = event::read()
        {
            match event {
                Event::Key(key,) => {
                    if options.log_mode {
                        let key_name = match key.code {
                            KeyCode::Char(c,) => format!("Char('{c}')"),
                            KeyCode::Enter => "Enter".to_string(),
                            KeyCode::Esc => "Escape".to_string(),
                            KeyCode::Up => "Up".to_string(),
                            KeyCode::Down => "Down".to_string(),
                            KeyCode::Left => "Left".to_string(),
                            KeyCode::Right => "Right".to_string(),
                            _ => format!("{:?}", key.code),
                        };
                        let _ = crate::commands::log_message(
                            "DEBUG",
                            &format!("Key pressed: {} in mode: {:?}", key_name, app.mode),
                        );
                    }

                    match app.mode {
                        AppMode::Normal => {
                            if key.code == KeyCode::Char('p',) && !options.show_preview {
                                if options.log_mode {
                                    let _ = crate::commands::log_message(
                                        "INFO",
                                        "Preview toggle attempted but previews are disabled",
                                    );
                                }
                            } else if key.code == KeyCode::Enter {
                                if let Some(selected,) = app.scripts.state.selected()
                                    && selected < app.scripts.items.len()
                                {
                                    let is_category =
                                        app.scripts.items[selected].is_category_header;

                                    if is_category {
                                        let category = app.scripts.items[selected].category.clone();
                                        app.toggle_category(&category,);
                                    } else if app.multi_select_mode {
                                        if !app.multi_selected_scripts.is_empty() {
                                            app.mode = AppMode::Confirm;
                                        }
                                    } else {
                                        app.mode = AppMode::Confirm;
                                    }
                                }
                            } else {
                                app.handle_key_normal_mode(key,);
                            }
                        },
                        AppMode::Preview => {
                            app.handle_key_preview_mode(key,);
                        },
                        AppMode::Search => app.handle_search_input(key,),
                        AppMode::Confirm => {
                            app.handle_key_confirmation_mode(key,);
                            if key.code == KeyCode::Char('y',) || key.code == KeyCode::Char('Y',) {
                                if app.multi_select_mode && !app.multi_selected_scripts.is_empty() {
                                    cleanup_terminal(&mut terminal,)?;

                                    if options.log_mode {
                                        let _ = crate::commands::log_message(
                                            "INFO",
                                            &format!(
                                                "Exiting UI to run {} selected scripts",
                                                app.multi_selected_scripts.len()
                                            ),
                                        );
                                    }

                                    app.run_selected_scripts(&run_script_callback,)?;

                                    if options.log_mode {
                                        let _ = crate::commands::log_message(
                                            "INFO",
                                            "Multiple script execution completed, returning to UI",
                                        );
                                    }

                                    enable_raw_mode()?;
                                    let mut stdout = io::stdout();
                                    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;

                                    let backend = CrosstermBackend::new(stdout,);
                                    terminal = Terminal::new(backend,)?;
                                    terminal.clear()?;
                                } else if let Some(script_path,) = app.get_script_path() {
                                    if options.log_mode {
                                        let script_name = script_path
                                            .file_name()
                                            .unwrap_or_default()
                                            .to_string_lossy();
                                        let _ = crate::commands::log_message(
                                            "INFO",
                                            &format!(
                                                "Selected script for execution: {script_name}"
                                            ),
                                        );
                                    }

                                    cleanup_terminal(&mut terminal,)?;

                                    if options.log_mode {
                                        let _ = crate::commands::log_message(
                                            "INFO",
                                            "Exiting UI to run script",
                                        );
                                    }

                                    run_script_callback(&script_path,)?;

                                    if options.log_mode {
                                        let _ = crate::commands::log_message(
                                            "INFO",
                                            "Script execution completed, returning to UI",
                                        );
                                    }

                                    enable_raw_mode()?;
                                    let mut stdout = io::stdout();
                                    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;

                                    let backend = CrosstermBackend::new(stdout,);
                                    terminal = Terminal::new(backend,)?;
                                    terminal.clear()?;
                                }
                            }
                        },
                        AppMode::Help => {
                            app.handle_key_help_mode(key,);
                        },
                    }
                },
                Event::Mouse(mouse_event,) => {
                    if options.log_mode {
                        let _ = crate::commands::log_message(
                            "DEBUG",
                            &format!("Mouse event: {mouse_event:?}"),
                        );
                    }
                    app.handle_mouse(mouse_event,);
                },
                _ => {},
            }
        }
    }

    cleanup_terminal(&mut terminal,)?;

    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "User requested application exit",);
    }

    print!("\x1B[2J\x1B[1;1H");

    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "UI terminated normally",);
    }

    Ok((),)
}
