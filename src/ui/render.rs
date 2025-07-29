use log::{debug, info};
use ratatui::prelude::*;
use std::io::{self, Stdout};
use std::path::Path;
use std::time::Duration;

use crossterm::event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode};
use crossterm::execute;
use crossterm::terminal::{
    Clear, ClearType, EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode,
};
use ratatui::backend::CrosstermBackend;
use ratatui::layout::{Constraint, Direction, Layout};
use ratatui::{Frame, Terminal};

use super::popups::run_script::RunScriptPopup;
use super::state::{App, AppMode, UiOptions};
use super::widgets::category_list::render_category_list;
use super::widgets::header::render_header;
use super::widgets::script_list::render_script_list;
use super::widgets::status_bar::render_status_bar;
use crate::error::Result;
use crate::ui::popups;

/// helper function to create a centered rect using a certain percentage of the available rect 'r'
fn centered_rect(percent_x: u16, percent_y: u16, r: Rect) -> Rect {
    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage((100 - percent_y) / 2),
            Constraint::Percentage(percent_y),
            Constraint::Percentage((100 - percent_y) / 2),
        ])
        .split(r);

    Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage((100 - percent_x) / 2),
            Constraint::Percentage(percent_x),
            Constraint::Percentage((100 - percent_x) / 2),
        ])
        .split(popup_layout[1])[1]
}

/// draws the main ui for normal mode
/// this includes the header, category list, script list, and status bar
fn render_normal_ui(f: &mut Frame, app: &mut App, _options: &UiOptions) {
    let area = Layout::default()
        .direction(Direction::Vertical)
        .margin(1)
        .constraints([Constraint::Min(0)])
        .split(f.area())[0];

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Length(3), Constraint::Min(0), Constraint::Length(1)])
        .split(area);

    render_header(f, app, chunks[0]);

    let main_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(20), Constraint::Percentage(80)])
        .split(chunks[1]);

    app.script_panel_area = main_chunks[1];

    render_category_list(f, app, main_chunks[0]);
    render_script_list(f, app, main_chunks[1]);

    render_status_bar(f, app, chunks[2]);
}

/// the main function for drawing the ui
/// it calls other drawing functions based on the current appmode
fn ui(f: &mut Frame, app: &mut App, options: &UiOptions) {
    // always draw the normal ui as the bottom layer
    render_normal_ui(f, app, options);

    // draw pop-ups on top of the normal ui based on the current mode
    // for popups with dynamic sizes, we calculate the percentage of the area to use
    // this allows us to use the centered_rect function while preserving the intended size
    match app.mode {
        AppMode::RunScript => {
            if let Some(popup) = &mut app.run_script_popup {
                let area = app.script_panel_area;
                let popup_area = centered_rect(83, 80, area);
                f.render_widget(popup, popup_area);
            }
        }
        AppMode::Search => {
            let area = app.script_panel_area;
            let popup_width = std::cmp::min(70, area.width.saturating_sub(8));
            let popup_height = std::cmp::min(16, area.height.saturating_sub(6));

            let percent_x = if area.width > 0 { (popup_width * 100) / area.width } else { 100 };
            let percent_y = if area.height > 0 { (popup_height * 100) / area.height } else { 100 };

            let popup_area = centered_rect(percent_x, percent_y, area);
            popups::search::render_search_popup(f, app, popup_area);
        }
        AppMode::Confirm => {
            let area = app.script_panel_area;
            let popup_width = std::cmp::min(60, area.width.saturating_sub(8));
            let popup_height = if app.multi_select.enabled && !app.multi_select.scripts.is_empty() {
                std::cmp::min(20, area.height.saturating_sub(6))
            } else {
                11
            };

            let percent_x = if area.width > 0 { (popup_width * 100) / area.width } else { 100 };
            let percent_y = if area.height > 0 { (popup_height * 100) / area.height } else { 100 };

            let popup_area = centered_rect(percent_x, percent_y, area);
            popups::confirmation::render_confirmation_popup(f, app, popup_area);
        }
        AppMode::Help => {
            let area = app.script_panel_area;
            let popup_width = std::cmp::min(80, area.width.saturating_sub(4));
            let popup_height = std::cmp::min(20, area.height.saturating_sub(4));

            let percent_x = if area.width > 0 { (popup_width * 100) / area.width } else { 100 };
            let percent_y = if area.height > 0 { (popup_height * 100) / area.height } else { 100 };

            let popup_area = centered_rect(percent_x, percent_y, area);
            let max_scroll = popups::help::render_help_popup(f, app, popup_area);
            app.help.max_scroll = max_scroll;
        }
        AppMode::Preview => {
            let area = app.script_panel_area;
            let popup_area = centered_rect(83, 80, area);
            popups::preview::render_preview_popup(f, app, popup_area);
        }
        AppMode::Description => {
            let area = app.script_panel_area;
            let popup_area = centered_rect(80, 80, area);
            popups::description::render_description_popup(f, &mut *app, popup_area);
        }
        AppMode::Normal => {
            // no pop-up to draw in normal mode
        }
        AppMode::RootWarning => {
            let area = app.script_panel_area;
            let popup_area = centered_rect(80, 50, area);
            popups::root_warning::render_root_warning_popup(f, app, popup_area);
        }
    }
}

/// gets the terminal ready for the tui
/// this means turning on raw mode and going to the alternate screen
fn setup_terminal() -> Result<Terminal<CrosstermBackend<Stdout>>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture, Clear(ClearType::All))?;
    let backend = CrosstermBackend::new(stdout);
    Terminal::new(backend).map_err(Into::into)
}

/// cleans up the terminal after the tui closes
/// this means leaving the alternate screen and turning off raw mode
fn cleanup_terminal(terminal: &mut Terminal<CrosstermBackend<io::Stdout>>) -> Result<()> {
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen, DisableMouseCapture)?;
    terminal.show_cursor()?;
    Ok(())
}

/// the main function for running the tui
/// it sets up the app, runs the main event loop, and cleans up the terminal
pub fn run_ui_with_options(modules_dir: &Path, options: UiOptions) -> Result<()> {
    if options.log_mode {
        info!("UI initialization started");
    }

    let mut terminal = setup_terminal()?;
    let mut app = App::new(&options);
    app.log_mode = options.log_mode;
    app.modules_dir = modules_dir.to_path_buf();

    if options.log_mode {
        info!("Loading scripts from modules directory");
    }

    app.load_scripts(modules_dir)?;

    if options.log_mode {
        info!(
            "Loaded {} scripts in {} categories",
            app.all_scripts.values().map(|v| v.len()).sum::<usize>(),
            app.categories.items.len()
        );
    }

    // the main event loop
    // it keeps running until the user quits the app
    while !app.quit {
        terminal.autoresize()?;
        terminal.draw(|f| ui(f, &mut app, &options))?;

        // check for events with a timeout. the timeout is shorter in runscript mode
        // to make the ui feel faster while a script is running
        let poll_duration = if app.mode == AppMode::RunScript {
            Duration::from_millis(16)
        } else {
            Duration::from_millis(100)
        };

        if event::poll(poll_duration)?
            && let Ok(event) = event::read()
        {
            handle_event(&mut app, event, &options)?;
        }
    }

    cleanup_terminal(&mut terminal)?;

    if options.log_mode {
        info!("UI terminated normally");
    }

    Ok(())
}

/// handles events from the terminal, like key presses and mouse clicks
/// it updates the app state based on the event and the current appmode
fn handle_event(app: &mut App, event: Event, options: &UiOptions) -> Result<()> {
    match event {
        Event::Key(key) => {
            if options.log_mode {
                let key_name = match key.code {
                    KeyCode::Char(c) => format!("Char('{c}')"),
                    _ => format!("{:?}", key.code),
                };
                debug!("Key pressed: {} in mode: {:?}", key_name, app.mode);
            }

            // runscript mode has special event handling to work with the
            // script running pop-up
            if app.mode == AppMode::RunScript {
                if let Some(popup) = &mut app.run_script_popup {
                    match popup.handle_key_event(key) {
                        crate::ui::popups::run_script::PopupEvent::Close => {
                            app.run_script_popup = None;
                            // if there are more scripts in the queue, run the next one
                            if let Some(script_path) = app.script_execution_queue.pop() {
                                let next_popup = RunScriptPopup::new(
                                    script_path,
                                    app.log_mode,
                                    app.theme.clone(),
                                );
                                app.run_script_popup = Some(next_popup);
                            } else {
                                app.mode = AppMode::Normal;
                            }
                        }
                        crate::ui::popups::run_script::PopupEvent::None => {}
                    }
                }
            } else {
                // pass key handling to the right function based on the current mode
                match app.mode {
                    AppMode::Normal => app.handle_key_normal_mode(key),
                    AppMode::Preview => app.handle_key_preview_mode(key),
                    AppMode::Search => app.handle_search_input(key),
                    AppMode::Confirm => app.handle_key_confirmation_mode(key),
                    AppMode::Help => app.handle_key_help_mode(key),
                    AppMode::Description => app.handle_key_description_mode(key),
                    AppMode::RootWarning => app.handle_key_root_warning_mode(key),
                    AppMode::RunScript => {
                        // already handled above
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
    Ok(())
}
