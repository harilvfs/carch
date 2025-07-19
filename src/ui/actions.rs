use std::path::{Path, PathBuf};
use std::{fs, io};

use super::state::{App, AppMode, FocusedPanel, ScriptItem, SearchState, StatefulList, UiOptions};

pub fn load_scripts(app: &mut App, modules_dir: &Path) -> io::Result<()> {
    let mut categories = Vec::new();
    let mut all_scripts = std::collections::HashMap::new();

    for category_entry in fs::read_dir(modules_dir)? {
        let category_entry = category_entry?;
        let category_path = category_entry.path();

        if category_path.is_dir() {
            let category_name =
                category_path.file_name().unwrap_or_default().to_string_lossy().into_owned();
            categories.push(category_name.clone());

            let mut scripts_in_category = Vec::new();
            for script_entry in fs::read_dir(&category_path)? {
                let script_entry = script_entry?;
                let script_path = script_entry.path();

                if script_path.is_file() && script_path.extension().unwrap_or_default() == "sh" {
                    let script_name =
                        script_path.file_stem().unwrap_or_default().to_string_lossy().into_owned();

                    let script_item = ScriptItem {
                        category: category_name.clone(),
                        name:     script_name,
                        path:     script_path,
                    };
                    scripts_in_category.push(script_item);
                }
            }
            all_scripts.insert(category_name, scripts_in_category);
        }
    }

    categories.sort();
    app.categories = StatefulList::with_items(categories);
    app.all_scripts = all_scripts;

    update_script_list(app);
    update_preview(app);

    Ok(())
}

pub fn update_script_list(app: &mut App) {
    if let Some(scripts) = app
        .categories
        .state
        .selected()
        .and_then(|i| app.categories.items.get(i))
        .and_then(|name| app.all_scripts.get(name))
    {
        app.scripts = StatefulList::with_items(scripts.clone());
        if app.focused_panel == FocusedPanel::Scripts && !app.scripts.items.is_empty() {
            app.scripts.state.select(Some(0));
        } else {
            app.scripts.state.select(None);
        }
    }
}

pub fn update_preview(app: &mut App) {
    if let Some(selected) = app.scripts.state.selected() {
        let script_path = &app.scripts.items[selected].path;
        if !app.preview.cache.contains_key(script_path) {
            match fs::read_to_string(script_path) {
                Ok(content) => {
                    app.preview.content = content;
                    app.preview.scroll = 0;
                }
                Err(_) => {
                    app.preview.content = "Error loading script content".to_string();
                }
            }
        }
    } else {
        app.preview.content = "No script selected".to_string();
    }
}

pub fn toggle_preview_mode(app: &mut App) {
    if app.scripts.state.selected().is_some() {
        let prev_mode = app.mode;
        app.mode = match app.mode {
            AppMode::Normal => AppMode::Preview,
            AppMode::Preview => AppMode::Normal,
            _ => AppMode::Normal,
        };

        let ui_options = UiOptions::default();
        if ui_options.log_mode {
            if prev_mode == AppMode::Normal && app.mode == AppMode::Preview {
                let _ = crate::commands::log_message("INFO", "Entered full-screen preview mode");
            } else if prev_mode == AppMode::Preview && app.mode == AppMode::Normal {
                let _ = crate::commands::log_message("INFO", "Exited full-screen preview mode");
            }
        }
        update_preview(app);
    }
}

pub fn scroll_preview_up(app: &mut App) {
    app.preview.scroll = app.preview.scroll.saturating_sub(1);
}

pub fn scroll_preview_down(app: &mut App) {
    app.preview.scroll = (app.preview.scroll + 1).min(app.preview.max_scroll);
}

pub fn scroll_preview_page_up(app: &mut App) {
    app.preview.scroll = app.preview.scroll.saturating_sub(10);
}

pub fn scroll_preview_page_down(app: &mut App) {
    app.preview.scroll = (app.preview.scroll + 10).min(app.preview.max_scroll);
}

pub fn get_script_path(app: &App) -> Option<PathBuf> {
    app.scripts.state.selected().map(|i| app.scripts.items[i].path.clone())
}

pub fn toggle_search_mode(app: &mut App) {
    let prev_mode = app.mode;
    app.mode = if app.mode == AppMode::Search { AppMode::Normal } else { AppMode::Search };

    let ui_options = UiOptions::default();
    if ui_options.log_mode {
        if prev_mode != AppMode::Search && app.mode == AppMode::Search {
            let _ = crate::commands::log_message("INFO", "Entered search mode");
        } else if prev_mode == AppMode::Search && app.mode != AppMode::Search {
            let _ = crate::commands::log_message("INFO", "Exited search mode");
        }
    }

    if app.mode == AppMode::Search {
        app.search = SearchState::default();
        perform_search(app);
    }
}

pub fn perform_search(app: &mut App) {
    app.search.results.clear();
    let search_term = app.search.input.to_lowercase();

    for scripts in app.all_scripts.values() {
        for item in scripts {
            if app.search.input.is_empty()
                || item.name.to_lowercase().contains(&search_term)
                || item.category.to_lowercase().contains(&search_term)
            {
                app.search.results.push(item.clone());
            }
        }
    }
}

pub fn next(app: &mut App) {
    match app.focused_panel {
        FocusedPanel::Categories => {
            app.categories.next();
            update_script_list(app);
            update_preview(app);
        }
        FocusedPanel::Scripts => {
            app.scripts.next();
            update_preview(app);
        }
    }
}

pub fn previous(app: &mut App) {
    match app.focused_panel {
        FocusedPanel::Categories => {
            app.categories.previous();
            update_script_list(app);
            update_preview(app);
        }
        FocusedPanel::Scripts => {
            app.scripts.previous();
            update_preview(app);
        }
    }
}

pub fn update_autocomplete(app: &mut App) {
    app.search.autocomplete = None;

    if app.search.input.is_empty() {
        return;
    }

    let search_term = app.search.input.to_lowercase();
    let mut best_match = None;
    let mut shortest_len = usize::MAX;

    for (category_name, scripts) in &app.all_scripts {
        for item in scripts {
            if item.name.to_lowercase().starts_with(&search_term)
                && item.name.len() > search_term.len()
                && item.name.len() < shortest_len
            {
                best_match = Some(item.name.clone());
                shortest_len = item.name.len();
            }

            let full_path = format!("{}/{}", category_name, item.name);
            if full_path.to_lowercase().starts_with(&search_term)
                && full_path.len() > search_term.len()
                && full_path.len() < shortest_len
            {
                shortest_len = full_path.len();
                best_match = Some(full_path);
            }
        }
    }

    app.search.autocomplete = best_match;
}

pub fn toggle_multi_select_mode(app: &mut App) {
    app.multi_select.enabled = !app.multi_select.enabled;
    if !app.multi_select.enabled {
        app.multi_select.scripts.clear();
    }
}

pub fn toggle_script_selection(app: &mut App) {
    if let Some(selected) = app.scripts.state.selected() {
        let script_path = &app.scripts.items[selected].path;
        if app.multi_select.scripts.contains(script_path) {
            app.multi_select.scripts.retain(|p| p != script_path);
        } else {
            app.multi_select.scripts.push(script_path.clone());
        }
    }
}

pub fn run_selected_scripts<F>(app: &App, run_script_callback: &F) -> io::Result<()>
where
    F: Fn(&Path) -> io::Result<()>,
{
    for script_path in &app.multi_select.scripts {
        run_script_callback(script_path)?;
    }
    Ok(())
}

pub fn is_script_selected(app: &App, script_path: &Path) -> bool {
    app.multi_select.scripts.contains(&script_path.to_path_buf())
}

pub fn toggle_help_mode(app: &mut App) {
    app.mode = if app.mode == AppMode::Help { AppMode::Normal } else { AppMode::Help };
}

pub fn top(app: &mut App) {
    match app.focused_panel {
        FocusedPanel::Categories => {
            app.categories.state.select(Some(0));
            update_script_list(app);
            update_preview(app);
        }
        FocusedPanel::Scripts => {
            app.scripts.state.select(Some(0));
            update_preview(app);
        }
    }
}

pub fn bottom(app: &mut App) {
    match app.focused_panel {
        FocusedPanel::Categories => {
            let last_idx = app.categories.items.len() - 1;
            app.categories.state.select(Some(last_idx));
            update_script_list(app);
            update_preview(app);
        }
        FocusedPanel::Scripts => {
            let last_idx = app.scripts.items.len() - 1;
            app.scripts.state.select(Some(last_idx));
            update_preview(app);
        }
    }
}
