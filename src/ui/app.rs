use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::{fs, io};

use crossterm::event::{KeyCode, MouseEvent, MouseEventKind};
#[allow(unused_imports)]
use ratatui::layout::Rect;
use ratatui::text::Text;

use super::system_info::SystemInfo;

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum AppMode {
    Normal,
    Search,
    Confirm,
    Help,
    Preview,
}

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum FocusedPanel {
    Categories,
    Scripts,
}

pub struct StatefulList<T> {
    pub state: ratatui::widgets::ListState,
    pub items: Vec<T>,
}

impl<T> StatefulList<T> {
    pub fn new() -> StatefulList<T> {
        StatefulList { state: ratatui::widgets::ListState::default(), items: Vec::new() }
    }

    pub fn with_items(items: Vec<T>) -> StatefulList<T> {
        let mut list = StatefulList::new();
        list.items = items;
        if !list.items.is_empty() {
            list.state.select(Some(0));
        }
        list
    }

    pub fn next(&mut self) {
        let i = match self.state.selected() {
            Some(i) => {
                if i >= self.items.len() - 1 {
                    0
                } else {
                    i + 1
                }
            }
            None => 0,
        };
        self.state.select(Some(i));
    }

    pub fn previous(&mut self) {
        let i = match self.state.selected() {
            Some(i) => {
                if i == 0 {
                    self.items.len() - 1
                } else {
                    i - 1
                }
            }
            None => 0,
        };
        self.state.select(Some(i));
    }
}

#[derive(Clone)]
pub struct ScriptItem {
    pub category: String,
    pub name:     String,
    pub path:     PathBuf,
}

#[derive(Default)]
pub struct UiOptions {
    pub show_preview: bool,
    pub log_mode:     bool,
}

// --- State Structs ---

#[derive(Default)]
pub struct PreviewState<'a> {
    pub content:    String,
    pub scroll:     u16,
    pub max_scroll: u16,
    pub cache:      HashMap<PathBuf, Text<'a>>,
}

#[derive(Default)]
pub struct SearchState {
    pub input:           String,
    pub results:         Vec<ScriptItem>,
    pub cursor_position: usize,
    pub selected_idx:    usize,
    pub autocomplete:    Option<String>,
}

#[derive(Default)]
pub struct MultiSelectState {
    pub enabled: bool,
    pub scripts: Vec<PathBuf>,
}

#[derive(Default)]
pub struct HelpState {
    pub scroll:     u16,
    pub max_scroll: u16,
}

pub struct App<'a> {
    // Core state
    pub mode:          AppMode,
    pub quit:          bool,
    pub focused_panel: FocusedPanel,

    // Data
    pub scripts:     StatefulList<ScriptItem>,
    pub categories:  StatefulList<String>,
    pub all_scripts: HashMap<String, Vec<ScriptItem>>,

    // UI and Sub-states
    pub system_info:       SystemInfo,
    pub script_panel_area: Rect,
    pub preview:           PreviewState<'a>,
    pub search:            SearchState,
    pub multi_select:      MultiSelectState,
    pub help:              HelpState,
}

impl<'a> App<'a> {
    pub fn new() -> App<'a> {
        App {
            mode:          AppMode::Normal,
            quit:          false,
            focused_panel: FocusedPanel::Categories,

            scripts:     StatefulList::new(),
            categories:  StatefulList::new(),
            all_scripts: HashMap::new(),

            system_info:       SystemInfo::new(),
            script_panel_area: Rect::default(),
            preview:           PreviewState::default(),
            search:            SearchState::default(),
            multi_select:      MultiSelectState::default(),
            help:              HelpState::default(),
        }
    }

    pub fn load_scripts(&mut self, modules_dir: &Path) -> io::Result<()> {
        let mut categories = Vec::new();
        let mut all_scripts = HashMap::new();

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

                    if script_path.is_file() && script_path.extension().unwrap_or_default() == "sh"
                    {
                        let script_name = script_path
                            .file_stem()
                            .unwrap_or_default()
                            .to_string_lossy()
                            .into_owned();

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
        self.categories = StatefulList::with_items(categories);
        self.all_scripts = all_scripts;

        self.update_script_list();
        self.update_preview();

        Ok(())
    }

    pub fn update_script_list(&mut self) {
        if let Some(scripts) = self
            .categories
            .state
            .selected()
            .and_then(|i| self.categories.items.get(i))
            .and_then(|name| self.all_scripts.get(name))
        {
            self.scripts = StatefulList::with_items(scripts.clone());
            if self.focused_panel == FocusedPanel::Scripts && !self.scripts.items.is_empty() {
                self.scripts.state.select(Some(0));
            } else {
                self.scripts.state.select(None);
            }
        }
    }

    pub fn update_preview(&mut self) {
        if let Some(selected) = self.scripts.state.selected() {
            let script_path = &self.scripts.items[selected].path;
            if !self.preview.cache.contains_key(script_path) {
                match fs::read_to_string(script_path) {
                    Ok(content) => {
                        self.preview.content = content;
                        self.preview.scroll = 0;
                    }
                    Err(_) => {
                        self.preview.content = "Error loading script content".to_string();
                    }
                }
            }
        } else {
            self.preview.content = "No script selected".to_string();
        }
    }

    pub fn toggle_preview_mode(&mut self) {
        if self.scripts.state.selected().is_some() {
            let prev_mode = self.mode;
            self.mode = match self.mode {
                AppMode::Normal => AppMode::Preview,
                AppMode::Preview => AppMode::Normal,
                _ => AppMode::Normal,
            };

            let ui_options = UiOptions::default();
            if ui_options.log_mode {
                if prev_mode == AppMode::Normal && self.mode == AppMode::Preview {
                    let _ =
                        crate::commands::log_message("INFO", "Entered full-screen preview mode");
                } else if prev_mode == AppMode::Preview && self.mode == AppMode::Normal {
                    let _ = crate::commands::log_message("INFO", "Exited full-screen preview mode");
                }
            }
            self.update_preview();
        }
    }

    pub fn scroll_preview_up(&mut self) {
        self.preview.scroll = self.preview.scroll.saturating_sub(1);
    }

    pub fn scroll_preview_down(&mut self) {
        self.preview.scroll = (self.preview.scroll + 1).min(self.preview.max_scroll);
    }

    pub fn scroll_preview_page_up(&mut self) {
        self.preview.scroll = self.preview.scroll.saturating_sub(10);
    }

    pub fn scroll_preview_page_down(&mut self) {
        self.preview.scroll = (self.preview.scroll + 10).min(self.preview.max_scroll);
    }

    pub fn get_script_path(&self) -> Option<PathBuf> {
        self.scripts.state.selected().map(|i| self.scripts.items[i].path.clone())
    }

    pub fn toggle_search_mode(&mut self) {
        let prev_mode = self.mode;
        self.mode = if self.mode == AppMode::Search { AppMode::Normal } else { AppMode::Search };

        let ui_options = UiOptions::default();
        if ui_options.log_mode {
            if prev_mode != AppMode::Search && self.mode == AppMode::Search {
                let _ = crate::commands::log_message("INFO", "Entered search mode");
            } else if prev_mode == AppMode::Search && self.mode != AppMode::Search {
                let _ = crate::commands::log_message("INFO", "Exited search mode");
            }
        }

        if self.mode == AppMode::Search {
            self.search = SearchState::default();
        }
    }

    pub fn handle_search_input(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Esc => self.toggle_search_mode(),
            KeyCode::Enter => {
                if !self.search.results.is_empty() {
                    let selected_item = self.search.results[self.search.selected_idx].clone();

                    if let Some(category_idx) =
                        self.categories.items.iter().position(|c| *c == selected_item.category)
                    {
                        self.categories.state.select(Some(category_idx));
                        self.update_script_list();

                        if let Some(script_idx) =
                            self.scripts.items.iter().position(|s| s.name == selected_item.name)
                        {
                            self.scripts.state.select(Some(script_idx));
                        }
                    }

                    self.update_preview();
                    self.toggle_search_mode();
                    self.focused_panel = FocusedPanel::Scripts;
                    self.mode = AppMode::Confirm;
                }
            }
            KeyCode::Down => {
                if !self.search.results.is_empty() {
                    self.search.selected_idx =
                        (self.search.selected_idx + 1) % self.search.results.len();
                }
            }
            KeyCode::Up => {
                if !self.search.results.is_empty() {
                    self.search.selected_idx = if self.search.selected_idx > 0 {
                        self.search.selected_idx - 1
                    } else {
                        self.search.results.len() - 1
                    };
                }
            }
            KeyCode::Tab => {
                if let Some(autocomplete) = self.search.autocomplete.take() {
                    self.search.input = autocomplete;
                    self.search.cursor_position = self.search.input.len();
                    self.perform_search();
                    self.update_autocomplete();
                }
            }
            KeyCode::Char(c) => {
                self.search.input.push(c);
                self.search.cursor_position += 1;
                self.perform_search();
                self.update_autocomplete();
                self.search.selected_idx = 0;
            }
            KeyCode::Backspace => {
                if self.search.cursor_position > 0 {
                    self.search.input.remove(self.search.cursor_position - 1);
                    self.search.cursor_position -= 1;
                    self.perform_search();
                    self.update_autocomplete();
                    self.search.selected_idx = 0;
                }
            }
            KeyCode::Left => {
                if self.search.cursor_position > 0 {
                    self.search.cursor_position -= 1;
                }
                self.search.autocomplete = None;
            }
            KeyCode::Right => {
                if self.search.cursor_position < self.search.input.len() {
                    self.search.cursor_position += 1;
                }
                if self.search.cursor_position == self.search.input.len()
                    && self.search.autocomplete.is_some()
                {
                    self.search.input = self.search.autocomplete.take().unwrap();
                    self.search.cursor_position = self.search.input.len();
                    self.perform_search();
                }
            }
            _ => {}
        }
    }

    pub fn perform_search(&mut self) {
        self.search.results.clear();

        if self.search.input.is_empty() {
            return;
        }

        let search_term = self.search.input.to_lowercase();

        for scripts in self.all_scripts.values() {
            for item in scripts {
                if item.name.to_lowercase().contains(&search_term)
                    || item.category.to_lowercase().contains(&search_term)
                {
                    self.search.results.push(item.clone());
                }
            }
        }
    }

    pub fn handle_key_normal_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('q') => {
                self.quit = true;
            }
            KeyCode::Esc => {
                if self.multi_select.enabled {
                    self.toggle_multi_select_mode();
                }
            }
            KeyCode::Char('j') | KeyCode::Down => {
                self.next();
            }
            KeyCode::Char('k') | KeyCode::Up => {
                self.previous();
            }
            KeyCode::Char('h') | KeyCode::Left => {
                self.focused_panel = FocusedPanel::Categories;
                self.scripts.state.select(None);
            }
            KeyCode::Char('l') | KeyCode::Right => {
                if self.focused_panel == FocusedPanel::Scripts {
                    if self.scripts.state.selected().is_some()
                        && !(self.multi_select.enabled && self.multi_select.scripts.is_empty())
                    {
                        self.mode = AppMode::Confirm;
                    }
                } else {
                    self.focused_panel = FocusedPanel::Scripts;
                    if !self.scripts.items.is_empty() {
                        self.scripts.state.select(Some(0));
                    }
                }
            }
            KeyCode::Home => {
                self.top();
            }
            KeyCode::End => {
                self.bottom();
            }
            KeyCode::Char('/') => {
                self.toggle_search_mode();
            }
            KeyCode::Char('p') => {
                self.toggle_preview_mode();
            }
            KeyCode::Char('m') => {
                self.toggle_multi_select_mode();
            }
            KeyCode::Char('?') => {
                self.toggle_help_mode();
            }
            KeyCode::Enter => {
                if self.focused_panel == FocusedPanel::Scripts
                    && self.scripts.state.selected().is_some()
                    && !(self.multi_select.enabled && self.multi_select.scripts.is_empty())
                {
                    self.mode = AppMode::Confirm;
                }
            }
            KeyCode::Char(' ') => {
                if self.multi_select.enabled {
                    self.toggle_script_selection();
                }
            }
            _ => {}
        }
    }

    pub fn handle_key_preview_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc | KeyCode::Char('p') | KeyCode::Char('h') => {
                self.mode = AppMode::Normal;
            }
            KeyCode::Char('j') | KeyCode::Down => {
                self.scroll_preview_down();
            }
            KeyCode::Char('k') | KeyCode::Up => {
                self.scroll_preview_up();
            }
            KeyCode::PageDown => {
                self.scroll_preview_page_down();
            }
            KeyCode::PageUp => {
                self.scroll_preview_page_up();
            }
            KeyCode::Home => {
                self.preview.scroll = 0;
            }
            KeyCode::End => {
                self.preview.scroll = self.preview.max_scroll;
            }
            _ => {}
        }
    }

    pub fn handle_mouse(&mut self, event: MouseEvent) {
        match event.kind {
            MouseEventKind::ScrollDown => match self.mode {
                AppMode::Normal => self.next(),
                AppMode::Preview => {
                    for _ in 0..2 {
                        self.scroll_preview_down();
                    }
                }
                AppMode::Search => {}
                AppMode::Confirm => {}
                AppMode::Help => {
                    self.help.scroll = self.help.scroll.saturating_add(2);
                }
            },
            MouseEventKind::ScrollUp => match self.mode {
                AppMode::Normal => self.previous(),
                AppMode::Preview => {
                    for _ in 0..2 {
                        self.scroll_preview_up();
                    }
                }
                AppMode::Search => {}
                AppMode::Confirm => {}
                AppMode::Help => {
                    self.help.scroll = self.help.scroll.saturating_sub(2);
                }
            },
            _ => {}
        }
    }

    pub fn next(&mut self) {
        match self.focused_panel {
            FocusedPanel::Categories => {
                self.categories.next();
                self.update_script_list();
                self.update_preview();
            }
            FocusedPanel::Scripts => {
                self.scripts.next();
                self.update_preview();
            }
        }
    }

    pub fn previous(&mut self) {
        match self.focused_panel {
            FocusedPanel::Categories => {
                self.categories.previous();
                self.update_script_list();
                self.update_preview();
            }
            FocusedPanel::Scripts => {
                self.scripts.previous();
                self.update_preview();
            }
        }
    }

    pub fn update_autocomplete(&mut self) {
        self.search.autocomplete = None;

        if self.search.input.is_empty() {
            return;
        }

        let search_term = self.search.input.to_lowercase();
        let mut best_match = None;
        let mut shortest_len = usize::MAX;

        for (category_name, scripts) in &self.all_scripts {
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

        self.search.autocomplete = best_match;
    }

    pub fn handle_key_confirmation_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('y') | KeyCode::Char('Y') | KeyCode::Char('l') => {
                self.mode = AppMode::Normal;
            }
            KeyCode::Char('n')
            | KeyCode::Char('N')
            | KeyCode::Esc
            | KeyCode::Char('h')
            | KeyCode::Char('q') => {
                self.mode = AppMode::Normal;
            }
            _ => {}
        }
    }

    pub fn toggle_multi_select_mode(&mut self) {
        self.multi_select.enabled = !self.multi_select.enabled;
        if !self.multi_select.enabled {
            self.multi_select.scripts.clear();
        }
    }

    pub fn toggle_script_selection(&mut self) {
        if let Some(selected) = self.scripts.state.selected() {
            let script_path = &self.scripts.items[selected].path;
            if self.multi_select.scripts.contains(script_path) {
                self.multi_select.scripts.retain(|p| p != script_path);
            } else {
                self.multi_select.scripts.push(script_path.clone());
            }
        }
    }

    pub fn run_selected_scripts<F>(&self, run_script_callback: &F) -> io::Result<()>
    where
        F: Fn(&Path) -> io::Result<()>,
    {
        for script_path in &self.multi_select.scripts {
            run_script_callback(script_path)?;
        }
        Ok(())
    }

    pub fn is_script_selected(&self, script_path: &Path) -> bool {
        self.multi_select.scripts.contains(&script_path.to_path_buf())
    }

    pub fn toggle_help_mode(&mut self) {
        self.mode = if self.mode == AppMode::Help { AppMode::Normal } else { AppMode::Help };
    }

    pub fn handle_key_help_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Esc | KeyCode::Char('q') | KeyCode::Char('?') => {
                self.mode = AppMode::Normal;
                self.help.scroll = 0;
            }
            KeyCode::Char('j') | KeyCode::Down => {
                self.help.scroll = (self.help.scroll + 1).min(self.help.max_scroll);
            }
            KeyCode::Char('k') | KeyCode::Up => {
                self.help.scroll = self.help.scroll.saturating_sub(1);
            }
            KeyCode::Home => {
                self.help.scroll = 0;
            }
            KeyCode::End => {
                self.help.scroll = self.help.max_scroll;
            }
            KeyCode::PageDown => {
                self.help.scroll = (self.help.scroll + 10).min(self.help.max_scroll);
            }
            KeyCode::PageUp => {
                self.help.scroll = self.help.scroll.saturating_sub(10);
            }
            _ => {}
        }
    }

    pub fn top(&mut self) {
        match self.focused_panel {
            FocusedPanel::Categories => {
                self.categories.state.select(Some(0));
                self.update_script_list();
                self.update_preview();
            }
            FocusedPanel::Scripts => {
                self.scripts.state.select(Some(0));
                self.update_preview();
            }
        }
    }

    pub fn bottom(&mut self) {
        match self.focused_panel {
            FocusedPanel::Categories => {
                let last_idx = self.categories.items.len() - 1;
                self.categories.state.select(Some(last_idx));
                self.update_script_list();
                self.update_preview();
            }
            FocusedPanel::Scripts => {
                let last_idx = self.scripts.items.len() - 1;
                self.scripts.state.select(Some(last_idx));
                self.update_preview();
            }
        }
    }
}
