use std::io::{self, Stdout};
use std::path::Path;
use std::time::Duration;

use log::{debug, info};
use ratatui::prelude::*;

use crossterm::event::{self, Event, KeyCode, KeyEventKind};
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

fn render_normal_ui(f: &mut Frame, app: &mut App) {
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

fn ui(f: &mut Frame, app: &mut App) {
    render_normal_ui(f, app);

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

            let percent_x = (popup_width * 100).checked_div(area.width).unwrap_or(100);
            let percent_y = (popup_height * 100).checked_div(area.height).unwrap_or(100);

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

            let percent_x = (popup_width * 100).checked_div(area.width).unwrap_or(100);
            let percent_y = (popup_height * 100).checked_div(area.height).unwrap_or(100);

            let popup_area = centered_rect(percent_x, percent_y, area);
            popups::confirmation::render_confirmation_popup(f, app, popup_area);
        }
        AppMode::Help => {
            let area = app.script_panel_area;
            let popup_width = std::cmp::min(80, area.width.saturating_sub(4));
            let popup_height = std::cmp::min(20, area.height.saturating_sub(4));

            let percent_x = (popup_width * 100).checked_div(area.width).unwrap_or(100);
            let percent_y = (popup_height * 100).checked_div(area.height).unwrap_or(100);

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
            popups::description::render_description_popup(f, app, popup_area);
        }
        AppMode::Normal => {}
        AppMode::RootWarning => {
            let area = app.script_panel_area;
            let popup_area = centered_rect(80, 50, area);
            popups::root_warning::render_root_warning_popup(f, app, popup_area);
        }
        AppMode::TermuxWarning => {
            let area = app.script_panel_area;
            let popup_area = centered_rect(80, 50, area);
            popups::termux_warning::render_termux_warning_popup(f, app, popup_area);
        }
    }
}

fn setup_terminal() -> Result<Terminal<CrosstermBackend<Stdout>>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, Clear(ClearType::All))?;
    let backend = CrosstermBackend::new(stdout);
    Terminal::new(backend).map_err(Into::into)
}

fn cleanup_terminal(terminal: &mut Terminal<CrosstermBackend<io::Stdout>>) -> Result<()> {
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;
    Ok(())
}

pub fn run_ui_with_options(modules_dir: &Path, options: &UiOptions) -> Result<()> {
    if options.log_mode {
        info!("UI initialization started");
    }

    let mut terminal = setup_terminal()?;
    install_panic_hook();

    let result = run_ui_loop(modules_dir, options, &mut terminal);

    cleanup_terminal(&mut terminal)?;

    if options.log_mode {
        match &result {
            Ok(()) => info!("UI terminated normally"),
            Err(e) => log::error!("UI terminated with error: {e}"),
        }
    }

    result
}

fn run_ui_loop(
    modules_dir: &Path,
    options: &UiOptions,
    terminal: &mut Terminal<CrosstermBackend<Stdout>>,
) -> Result<()> {
    let mut app = App::new(options);
    app.modules_dir = modules_dir.to_path_buf();

    if options.log_mode {
        info!("Loading scripts from modules directory");
    }

    app.load_scripts(modules_dir)?;

    if options.log_mode {
        info!(
            "Loaded {} scripts in {} categories",
            app.all_scripts.values().map(Vec::len).sum::<usize>(),
            app.categories.items.len()
        );
    }

    while !app.quit {
        let popup_has_new_data =
            app.run_script_popup.as_mut().is_some_and(RunScriptPopup::has_new_data);

        if app.needs_redraw || popup_has_new_data {
            if app.last_size == Rect::default() {
                terminal.autoresize()?;
            }

            terminal.draw(|f| ui(f, &mut app))?;
            app.last_size = terminal.get_frame().area();
            app.needs_redraw = false;

            if let Some(popup) = app.run_script_popup.as_mut() {
                popup.acknowledge_data();
            }
        }

        let poll_duration = if app.mode == AppMode::RunScript {
            Duration::from_millis(16)
        } else {
            Duration::from_millis(100)
        };

        if event::poll(poll_duration)?
            && let Ok(event) = event::read()
        {
            app.needs_redraw = true;
            handle_event(&mut app, event, options)?;
        }
    }

    Ok(())
}

fn install_panic_hook() {
    use std::sync::Once;
    static ONCE: Once = Once::new();
    ONCE.call_once(|| {
        let original = std::panic::take_hook();
        std::panic::set_hook(Box::new(move |info| {
            let _ = disable_raw_mode();
            let _ = execute!(io::stdout(), LeaveAlternateScreen);
            original(info);
        }));
    });
}

fn handle_event(app: &mut App, event: Event, options: &UiOptions) -> Result<()> {
    match event {
        Event::Key(key) => {
            if matches!(key.kind, KeyEventKind::Release | KeyEventKind::Repeat) {
                return Ok(());
            }

            if options.log_mode {
                let key_name = match key.code {
                    KeyCode::Char(c) => format!("Char('{c}')"),
                    _ => format!("{:?}", key.code),
                };
                debug!("Key pressed: {} in mode: {:?}", key_name, app.mode);
            }

            if app.mode == AppMode::RunScript {
                if let Some(popup) = &mut app.run_script_popup {
                    match popup.handle_key_event(key) {
                        crate::ui::popups::run_script::PopupEvent::Close => {
                            app.run_script_popup = None;
                            if let Some(script_path) = app.script_execution_queue.pop_front() {
                                match RunScriptPopup::new(
                                    script_path,
                                    app.log_mode,
                                    app.theme.clone(),
                                ) {
                                    Ok(next_popup) => {
                                        app.run_script_popup = Some(next_popup);
                                    }
                                    Err(e) => {
                                        log::error!("Failed to start next script popup: {e}");
                                        app.run_script_popup = None;
                                        app.mode = AppMode::Normal;
                                    }
                                }
                            } else {
                                app.mode = AppMode::Normal;
                            }
                        }
                        crate::ui::popups::run_script::PopupEvent::None => {}
                    }
                }
            } else {
                match app.mode {
                    AppMode::Normal => app.handle_key_normal_mode(key),
                    AppMode::Preview => app.handle_key_preview_mode(key),
                    AppMode::Search => app.handle_search_input(key),
                    AppMode::Confirm => app.handle_key_confirmation_mode(key),
                    AppMode::Help => app.handle_key_help_mode(key),
                    AppMode::Description => app.handle_key_description_mode(key),
                    AppMode::RootWarning => app.handle_key_root_warning_mode(key),
                    AppMode::TermuxWarning => app.handle_key_termux_warning_mode(key),
                    AppMode::RunScript => {}
                }
            }
        }
        Event::Resize(_, _) => {
            app.needs_redraw = true;
        }
        _ => {}
    }
    Ok(())
}
