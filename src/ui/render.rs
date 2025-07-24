use log::{debug, info};
use ratatui::prelude::*;
use std::io;
use std::path::Path;
use std::time::Duration;

use crossterm::event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode};
use crossterm::execute;
use crossterm::terminal::{
    EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode,
};
use ratatui::backend::CrosstermBackend;
use ratatui::layout::{Constraint, Direction, Layout};
use ratatui::{Frame, Terminal};

use super::actions::load_scripts;
use super::popups::run_script::RunScriptPopup;
use super::state::{App, AppMode, UiOptions};
use super::widgets::category_list::render_category_list;
use super::widgets::header::render_header;
use super::widgets::script_list::render_script_list;
use super::widgets::status_bar::render_status_bar;
use crate::error::Result;
use crate::ui::popups;

fn render_normal_ui(f: &mut Frame, app: &mut App, options: &UiOptions) {
    if app.mode == AppMode::Preview && !options.show_preview {
        app.mode = AppMode::Normal;
    }

    let area = Layout::default()
        .direction(Direction::Vertical)
        .margin(1)
        .constraints([Constraint::Min(0)])
        .split(f.area())[0];

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Length(4), Constraint::Min(0), Constraint::Length(1)])
        .split(area);

    render_header(f, app, chunks[0]);

    let main_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(30), Constraint::Percentage(70)])
        .split(chunks[1]);

    app.script_panel_area = main_chunks[1];

    render_category_list(f, app, main_chunks[0]);
    render_script_list(f, app, main_chunks[1]);

    render_status_bar(f, app, chunks[2]);
}

fn ui(f: &mut Frame, app: &mut App, options: &UiOptions) {
    match app.mode {
        AppMode::RunScript => {
            render_normal_ui(f, app, options);
            if let Some(popup) = &mut app.run_script_popup {
                let area = app.script_panel_area;
                let popup_area = Rect {
                    x:      area.x + area.width / 12,
                    y:      area.y + area.height / 10,
                    width:  area.width * 5 / 6,
                    height: area.height * 4 / 5,
                };
                f.render_widget(popup, popup_area);
            }
        }
        AppMode::Search => {
            render_normal_ui(f, app, options);
            popups::search::render_search_popup(f, app, app.script_panel_area);
        }
        AppMode::Confirm => {
            render_normal_ui(f, app, options);
            popups::confirmation::render_confirmation_popup(f, app, app.script_panel_area);
        }
        AppMode::Help => {
            render_normal_ui(f, app, options);
            let max_scroll = popups::help::render_help_popup(f, app, app.script_panel_area);
            app.help.max_scroll = max_scroll;
        }
        AppMode::Normal => {
            render_normal_ui(f, app, options);
        }
        AppMode::Preview => {
            render_normal_ui(f, app, options);
            popups::preview::render_preview_popup(f, app, app.script_panel_area);
        }
    }
}

fn cleanup_terminal(terminal: &mut Terminal<CrosstermBackend<io::Stdout>>) -> Result<()> {
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen, DisableMouseCapture)?;
    terminal.show_cursor()?;
    Ok(())
}

#[allow(dead_code)]
pub fn run_ui(modules_dir: &Path) -> Result<()> {
    run_ui_with_options(modules_dir, UiOptions::default())
}

pub fn run_ui_with_options(modules_dir: &Path, options: UiOptions) -> Result<()> {
    if options.log_mode {
        info!("UI initialization started");
    }

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut app = App::new();
    app.log_mode = options.log_mode;

    if options.log_mode {
        info!("Loading scripts from modules directory");
    }

    load_scripts(&mut app, modules_dir)?;

    if options.log_mode {
        info!(
            "Loaded {} scripts in {} categories",
            app.all_scripts.values().map(|v| v.len()).sum::<usize>(),
            app.categories.items.len()
        );
    }

    if !options.show_preview {
        app.mode = AppMode::Normal;

        if options.log_mode {
            info!("Preview mode disabled by configuration");
        }
    }

    while !app.quit {
        terminal.autoresize()?;

        terminal.draw(|f| ui(f, &mut app, &options))?;

        let poll_duration = if app.mode == AppMode::RunScript {
            Duration::from_millis(16)
        } else {
            Duration::from_millis(100)
        };

        if let Ok(true) = event::poll(poll_duration)
            && let Ok(event) = event::read()
        {
            match event {
                Event::Key(key) => {
                    if options.log_mode {
                        let key_name = match key.code {
                            KeyCode::Char(c) => format!("Char('{c}')"),
                            KeyCode::Enter => "Enter".to_string(),
                            KeyCode::Esc => "Escape".to_string(),
                            KeyCode::Up => "Up".to_string(),
                            KeyCode::Down => "Down".to_string(),
                            KeyCode::Left => "Left".to_string(),
                            KeyCode::Right => "Right".to_string(),
                            _ => format!("{:?}", key.code),
                        };
                        debug!("Key pressed: {} in mode: {:?}", key_name, app.mode);
                    }

                    if app.mode == AppMode::RunScript {
                        if let Some(popup) = &mut app.run_script_popup {
                            match popup.handle_key_event(key) {
                                crate::ui::popups::run_script::PopupEvent::Close => {
                                    app.run_script_popup = None;
                                    if !app.script_execution_queue.is_empty() {
                                        let script_path = app.script_execution_queue.remove(0);
                                        let next_popup =
                                            RunScriptPopup::new(script_path, app.log_mode);
                                        app.run_script_popup = Some(next_popup);
                                    } else {
                                        app.mode = AppMode::Normal;
                                    }
                                }
                                crate::ui::popups::run_script::PopupEvent::None => {}
                            }
                        }
                    } else {
                        match app.mode {
                            AppMode::Normal => {
                                if key.code == KeyCode::Char('p') && !options.show_preview {
                                    if options.log_mode {
                                        info!("Preview toggle attempted but previews are disabled");
                                    }
                                } else {
                                    app.handle_key_normal_mode(key);
                                }
                            }
                            AppMode::Preview => {
                                app.handle_key_preview_mode(key);
                            }
                            AppMode::Search => app.handle_search_input(key),
                            AppMode::Confirm => {
                                app.handle_key_confirmation_mode(key);
                            }
                            AppMode::Help => {
                                app.handle_key_help_mode(key);
                            }
                            AppMode::RunScript => {
                                // Already handled
                            }
                        }
                    }
                }
                Event::Mouse(mouse_event) => {
                    if options.log_mode {
                        debug!("Mouse event: {mouse_event:?}");
                    }
                    app.handle_mouse(mouse_event);
                }
                _ => {}
            }
        }
    }

    cleanup_terminal(&mut terminal)?;

    if options.log_mode {
        info!("User requested application exit");
    }

    if options.log_mode {
        info!("UI terminated normally");
    }

    Ok(())
}
