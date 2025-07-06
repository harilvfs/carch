use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::{fs, io};

use crossterm::event::{KeyCode, MouseEvent, MouseEventKind};
#[allow(unused_imports)]
use ratatui::layout::Rect;

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

impl ScriptItem {}

pub struct UiOptions {
    pub show_preview: bool,
    pub log_mode:     bool,
}

impl Default for UiOptions {
    fn default() -> Self {
        Self { show_preview: true, log_mode: false }
    }
}

pub struct App {
    pub scripts:                StatefulList<ScriptItem>,
    pub preview_content:        String,
    pub preview_scroll:         u16,
    pub mode:                   AppMode,
    pub all_scripts:            HashMap<String, Vec<ScriptItem>>,
    pub categories:             StatefulList<String>,
    pub focused_panel:          FocusedPanel,
    pub quit:                   bool,
    pub search_input:           String,
    pub search_results:         Vec<ScriptItem>,
    pub search_cursor_position: usize,
    pub search_selected_idx:    usize,
    pub autocomplete_text:      Option<String>,
    pub multi_selected_scripts: Vec<usize>,
    pub multi_select_mode:      bool,
    pub help_scroll:            u16,
    pub help_max_scroll:        u16,
    pub script_panel_area:      Rect,
}

impl App {
    pub fn new() -> App {
        App {
            scripts:                StatefulList::new(),
            preview_content:        String::new(),
            preview_scroll:         0,
            mode:                   AppMode::Normal,
            all_scripts:            HashMap::new(),
            categories:             StatefulList::new(),
            focused_panel:          FocusedPanel::Categories,
            quit:                   false,
            search_input:           String::new(),
            search_results:         Vec::new(),
            search_cursor_position: 0,
            search_selected_idx:    0,
            autocomplete_text:      None,
            multi_selected_scripts: Vec::new(),
            multi_select_mode:      false,
            help_scroll:            0,
            help_max_scroll:        0,
            script_panel_area:      Rect::default(),
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
                            path:     script_path.clone(),
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
            match fs::read_to_string(script_path) {
                Ok(content) => {
                    self.preview_content = content;
                    self.preview_scroll = 0;
                }
                Err(_) => {
                    self.preview_content = "Error loading script content".to_string();
                }
            }
        } else {
            self.preview_content = "No script selected".to_string();
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
        if self.preview_scroll > 0 {
            self.preview_scroll -= 1;
        }
    }

    pub fn scroll_preview_down(&mut self) {
        self.preview_scroll += 1;
    }

    pub fn scroll_preview_page_up(&mut self) {
        if self.preview_scroll > 10 {
            self.preview_scroll -= 10;
        } else {
            self.preview_scroll = 0;
        }
    }

    pub fn scroll_preview_page_down(&mut self) {
        self.preview_scroll += 10;
    }

    pub fn get_script_path(&self) -> Option<PathBuf> {
        self.scripts.state.selected().map(|i| self.scripts.items[i].path.clone())
    }

    pub fn toggle_search_mode(&mut self) {
        let prev_mode = self.mode;
        self.mode = match self.mode {
            AppMode::Search => AppMode::Normal,
            _ => AppMode::Search,
        };

        let ui_options = UiOptions::default();
        if ui_options.log_mode {
            if prev_mode != AppMode::Search && self.mode == AppMode::Search {
                let _ = crate::commands::log_message("INFO", "Entered search mode");
            } else if prev_mode == AppMode::Search && self.mode != AppMode::Search {
                let _ = crate::commands::log_message("INFO", "Exited search mode");
            }
        }

        if self.mode == AppMode::Search {
            self.search_input = String::new();
            self.search_results = Vec::new();
            self.search_cursor_position = 0;
            self.search_selected_idx = 0;
            self.autocomplete_text = None;
        }
    }

    pub fn handle_search_input(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Esc => self.toggle_search_mode(),
            KeyCode::Enter => {
                if !self.search_results.is_empty() {
                    let selected_item = self.search_results[self.search_selected_idx].clone();

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
                if !self.search_results.is_empty() {
                    self.search_selected_idx =
                        (self.search_selected_idx + 1) % self.search_results.len();
                }
            }
            KeyCode::Up => {
                if !self.search_results.is_empty() {
                    self.search_selected_idx = if self.search_selected_idx > 0 {
                        self.search_selected_idx - 1
                    } else {
                        self.search_results.len() - 1
                    };
                }
            }
            KeyCode::Tab => {
                if let Some(autocomplete) = self.autocomplete_text.take() {
                    self.search_input = autocomplete;
                    self.search_cursor_position = self.search_input.len();
                    self.perform_search();
                    self.update_autocomplete();
                }
            }
            KeyCode::Char(c) => {
                self.search_input.push(c);
                self.search_cursor_position += 1;
                self.perform_search();
                self.update_autocomplete();
                self.search_selected_idx = 0;
            }
            KeyCode::Backspace => {
                if self.search_cursor_position > 0 {
                    self.search_input.remove(self.search_cursor_position - 1);
                    self.search_cursor_position -= 1;
                    self.perform_search();
                    self.update_autocomplete();
                    self.search_selected_idx = 0;
                }
            }
            KeyCode::Left => {
                if self.search_cursor_position > 0 {
                    self.search_cursor_position -= 1;
                }
                self.autocomplete_text = None;
            }
            KeyCode::Right => {
                if self.search_cursor_position < self.search_input.len() {
                    self.search_cursor_position += 1;
                }
                if self.search_cursor_position == self.search_input.len()
                    && self.autocomplete_text.is_some()
                {
                    self.search_input = self.autocomplete_text.take().unwrap();
                    self.search_cursor_position = self.search_input.len();
                    self.perform_search();
                }
            }
            _ => {}
        }
    }

    pub fn perform_search(&mut self) {
        self.search_results.clear();

        if self.search_input.is_empty() {
            return;
        }

        let search_term = self.search_input.to_lowercase();

        for scripts in self.all_scripts.values() {
            for item in scripts {
                if item.name.to_lowercase().contains(&search_term)
                    || item.category.to_lowercase().contains(&search_term)
                {
                    self.search_results.push(item.clone());
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
                if self.multi_select_mode {
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
                self.focused_panel = FocusedPanel::Scripts;
                if !self.scripts.items.is_empty() {
                    self.scripts.state.select(Some(0));
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
                    && !(self.multi_select_mode && self.multi_selected_scripts.is_empty())
                {
                    self.mode = AppMode::Confirm;
                }
            }
            KeyCode::Char(' ') => {
                if self.multi_select_mode {
                    self.toggle_script_selection();
                }
            }
            _ => {}
        }
    }

    pub fn handle_key_preview_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc | KeyCode::Char('p') => {
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
                self.preview_scroll = 0;
            }
            KeyCode::End => {
                let line_count = self.preview_content.lines().count() as u16;
                self.preview_scroll = if line_count > 0 { line_count } else { 0 };
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
                    self.help_scroll = self.help_scroll.saturating_add(2);
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
                    self.help_scroll = self.help_scroll.saturating_sub(2);
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
        self.autocomplete_text = None;

        if self.search_input.is_empty() {
            return;
        }

        let search_term = self.search_input.to_lowercase();
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

        self.autocomplete_text = best_match;
    }

    pub fn handle_key_confirmation_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('y') | KeyCode::Char('Y') => {
                self.mode = AppMode::Normal;
            }
            KeyCode::Char('n') | KeyCode::Char('N') | KeyCode::Esc => {
                self.mode = AppMode::Normal;
            }
            _ => {}
        }
    }

    pub fn toggle_multi_select_mode(&mut self) {
        self.multi_select_mode = !self.multi_select_mode;
        if !self.multi_select_mode {
            self.multi_selected_scripts.clear();
        }
    }

    pub fn toggle_script_selection(&mut self) {
        if let Some(selected) = self.scripts.state.selected() {
            if self.multi_selected_scripts.contains(&selected) {
                self.multi_selected_scripts.retain(|&x| x != selected);
            } else {
                self.multi_selected_scripts.push(selected);
            }
        }
    }

    pub fn run_selected_scripts<F>(&self, run_script_callback: &F) -> io::Result<()>
    where
        F: Fn(&Path) -> io::Result<()>,
    {
        for &script_idx in &self.multi_selected_scripts {
            if script_idx < self.scripts.items.len() {
                let script_path = &self.scripts.items[script_idx].path;
                run_script_callback(script_path)?;
            }
        }
        Ok(())
    }

    pub fn is_script_selected(&self, idx: usize) -> bool {
        self.multi_selected_scripts.contains(&idx)
    }

    pub fn toggle_help_mode(&mut self) {
        self.mode = if self.mode == AppMode::Help { AppMode::Normal } else { AppMode::Help };
    }

    pub fn handle_key_help_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Esc | KeyCode::Char('q') | KeyCode::Char('?') => {
                self.mode = AppMode::Normal;
                self.help_scroll = 0;
            }
            KeyCode::Char('j') | KeyCode::Down => {
                self.help_scroll = (self.help_scroll + 1).min(self.help_max_scroll);
            }
            KeyCode::Char('k') | KeyCode::Up => {
                self.help_scroll = self.help_scroll.saturating_sub(1);
            }
            KeyCode::Home => {
                self.help_scroll = 0;
            }
            KeyCode::End => {
                self.help_scroll = self.help_max_scroll;
            }
            KeyCode::PageDown => {
                self.help_scroll = (self.help_scroll + 10).min(self.help_max_scroll);
            }
            KeyCode::PageUp => {
                self.help_scroll = self.help_scroll.saturating_sub(10);
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
