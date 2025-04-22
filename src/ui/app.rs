use std::collections::HashMap;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};

#[allow(unused_imports)]
use ratatui::widgets::ListState;
use crossterm::event::{KeyCode, MouseEvent, MouseEventKind};

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum AppMode {
    Normal,
    Preview,
    Search,
    Confirm,
}

pub struct StatefulList<T> {
    pub state: ratatui::widgets::ListState,
    pub items: Vec<T>,
}

impl<T> StatefulList<T> {
    pub fn new() -> StatefulList<T> {
        StatefulList {
            state: ratatui::widgets::ListState::default(),
            items: Vec::new(),
        }
    }

    pub fn with_items(items: Vec<T>) -> StatefulList<T> {
        let mut list = StatefulList::new();
        list.items = items;
        if !list.items.is_empty() {
            list.state.select(Some(0));
        }
        list
    }

    #[allow(dead_code)]
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

    #[allow(dead_code)]
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

pub struct ScriptItem {
    pub category: String,
    pub name: String,
    pub path: PathBuf,
    pub is_category_header: bool,
}

impl ScriptItem {
    pub fn full_name(&self) -> String {
        if self.is_category_header {
            self.category.clone()
        } else {
            format!("{}/{}", self.category, self.name)
        }
    }
}

pub struct UiOptions {
    pub show_preview: bool,
    pub log_mode: bool,
}

impl Default for UiOptions {
    fn default() -> Self {
        Self {
            show_preview: true,
            log_mode: false,
        }
    }
}

pub struct App {
    pub scripts: StatefulList<ScriptItem>,
    pub preview_content: String,
    pub preview_scroll: u16,
    pub mode: AppMode,
    pub categories: HashMap<String, Vec<usize>>,
    pub expanded_categories: HashMap<String, bool>,
    pub quit: bool,
    pub visible_items: Vec<usize>,
    pub list_state: ratatui::widgets::ListState,
    pub search_input: String,
    pub search_results: Vec<usize>,
    pub search_cursor_position: usize,
    pub search_selected_idx: usize,
    pub autocomplete_text: Option<String>,
    pub multi_selected_scripts: Vec<usize>,
    pub multi_select_mode: bool,
}

impl App {
    pub fn new() -> App {
        App {
            scripts: StatefulList::new(),
            preview_content: String::new(),
            preview_scroll: 0,
            mode: AppMode::Normal,
            categories: HashMap::new(),
            expanded_categories: HashMap::new(),
            quit: false,
            visible_items: Vec::new(),
            list_state: ratatui::widgets::ListState::default(),
            search_input: String::new(),
            search_results: Vec::new(),
            search_cursor_position: 0,
            search_selected_idx: 0,
            autocomplete_text: None,
            multi_selected_scripts: Vec::new(),
            multi_select_mode: false,
        }
    }

    pub fn load_scripts(&mut self, modules_dir: &Path) -> io::Result<()> {
        let mut script_items = Vec::new();
        let mut categories = HashMap::new();
        let mut current_index = 0;

        for category_entry in fs::read_dir(modules_dir)? {
            let category_entry = category_entry?;
            let category_path = category_entry.path();

            if category_path.is_dir() {
                let category_name = category_path
                    .file_name()
                    .unwrap_or_default()
                    .to_string_lossy()
                    .into_owned();

                script_items.push(ScriptItem {
                    category: category_name.clone(),
                    name: String::new(),
                    path: category_path.clone(),
                    is_category_header: true,
                });

                self.expanded_categories.insert(category_name.clone(), true);

                let category_header_index = current_index;
                current_index += 1;

                let mut category_indices = Vec::new();
                category_indices.push(category_header_index);

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
                            name: script_name,
                            path: script_path.clone(),
                            is_category_header: false,
                        };

                        category_indices.push(current_index);
                        script_items.push(script_item);
                        current_index += 1;
                    }
                }

                categories.insert(category_name, category_indices);
            }
        }

        self.scripts = StatefulList::with_items(script_items);
        self.categories = categories;
        self.update_visible_items();

        if !self.visible_items.is_empty() {
            let default_select = self
                .visible_items
                .iter()
                .find(|&&idx| {
                    idx < self.scripts.items.len() && !self.scripts.items[idx].is_category_header
                })
                .copied();

            if let Some(script_idx) = default_select {
                self.scripts.state.select(Some(script_idx));
            }
        }

        self.update_preview();

        Ok(())
    }

    pub fn update_visible_items(&mut self) {
        self.visible_items.clear();

        for i in 0..self.scripts.items.len() {
            let item = &self.scripts.items[i];

            if item.is_category_header {
                self.visible_items.push(i);
            } else if let Some(expanded) = self.expanded_categories.get(&item.category) {
                if *expanded {
                    self.visible_items.push(i);
                }
            }
        }

        let current_selected = self.scripts.state.selected();
        if let Some(selected) = current_selected {
            if !self.visible_items.contains(&selected) && !self.visible_items.is_empty() {
                let selected_category = if selected < self.scripts.items.len() {
                    self.scripts.items[selected].category.clone()
                } else {
                    String::new()
                };

                let category_header = self.visible_items.iter().find(|&&idx| {
                    idx < self.scripts.items.len()
                        && self.scripts.items[idx].is_category_header
                        && self.scripts.items[idx].category == selected_category
                });

                if let Some(&header_idx) = category_header {
                    self.scripts.state.select(Some(header_idx));
                } else {
                    self.scripts.state.select(Some(self.visible_items[0]));
                }
            }
        } else if !self.visible_items.is_empty() {
            self.scripts.state.select(Some(self.visible_items[0]));
        }

        if let Some(selected) = self.scripts.state.selected() {
            if let Some(pos) = self.visible_items.iter().position(|&i| i == selected) {
                self.list_state.select(Some(pos));
            }
        }
    }

    pub fn update_preview(&mut self) {
        if let Some(selected) = self.scripts.state.selected() {
            if selected < self.scripts.items.len() {
                if self.scripts.items[selected].is_category_header {
                    self.preview_content = format!(
                        "No preview available for category: {}\n\nPlease select a script to see its content.",
                        self.scripts.items[selected].category
                    );
                    self.preview_scroll = 0;
                    return;
                }

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
            }
        }
    }

    pub fn toggle_category(&mut self, category: &str) {
        if let Some(expanded) = self.expanded_categories.get_mut(category) {
            *expanded = !*expanded;

            let ui_options = UiOptions::default();
            if ui_options.log_mode {
                let _ = crate::commands::log_message(
                    "INFO",
                    &format!(
                        "Category '{}' {}",
                        category,
                        if *expanded { "expanded" } else { "collapsed" }
                    ),
                );
            }

            let currently_selected = self.scripts.state.selected();

            self.update_visible_items();

            if let Some(selected_idx) = currently_selected {
                if selected_idx < self.scripts.items.len() {
                    let selected_item = &self.scripts.items[selected_idx];

                    if !self.visible_items.contains(&selected_idx)
                        && selected_item.category == category
                        && !selected_item.is_category_header
                    {
                        if let Some(&header_idx) = self.visible_items.iter().find(|&&idx| {
                            idx < self.scripts.items.len()
                                && self.scripts.items[idx].is_category_header
                                && self.scripts.items[idx].category == category
                        }) {
                            self.scripts.state.select(Some(header_idx));
                        }
                    }
                }
            }

            if let Some(selected) = self.scripts.state.selected() {
                if let Some(pos) = self.visible_items.iter().position(|&i| i == selected) {
                    self.list_state.select(Some(pos));
                }
            }

            self.update_preview();
        }
    }

    pub fn toggle_preview_mode(&mut self) {
        if let Some(selected) = self.scripts.state.selected() {
            if selected < self.scripts.items.len() {
                let prev_mode = self.mode;
                self.mode = match self.mode {
                    AppMode::Normal => AppMode::Preview,
                    AppMode::Preview => AppMode::Normal,
                    AppMode::Search => AppMode::Normal,
                    AppMode::Confirm => AppMode::Normal,
                };

                let ui_options = UiOptions::default();
                if ui_options.log_mode {
                    if prev_mode == AppMode::Normal && self.mode == AppMode::Preview {
                        let _ = crate::commands::log_message(
                            "INFO",
                            "Entered full-screen preview mode",
                        );
                    } else if prev_mode == AppMode::Preview && self.mode == AppMode::Normal {
                        let _ =
                            crate::commands::log_message("INFO", "Exited full-screen preview mode");
                    }
                }

                self.update_preview();
            }
        }
    }

    pub fn scroll_preview_up(&mut self) {
        let scroll_amount = 3;
        if self.preview_scroll > scroll_amount {
            self.preview_scroll -= scroll_amount;
        } else {
            self.preview_scroll = 0;
        }
    }

    pub fn scroll_preview_down(&mut self) {
        let line_count = self.preview_content.lines().count() as u16;

        let max_scroll = if line_count > 0 { line_count } else { 0 };

        let scroll_amount = 3;
        if self.preview_scroll + scroll_amount < max_scroll {
            self.preview_scroll += scroll_amount;
        } else if self.preview_scroll < max_scroll {
            self.preview_scroll = max_scroll;
        }
    }

    pub fn get_script_path(&self) -> Option<PathBuf> {
        self.scripts.state.selected().and_then(|i| {
            if i < self.scripts.items.len() && !self.scripts.items[i].is_category_header {
                Some(self.scripts.items[i].path.clone())
            } else {
                None
            }
        })
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
                    let selected_result = self.search_results[self.search_selected_idx];
                    self.scripts.state.select(Some(selected_result));
                    self.update_preview();
                    self.ensure_selected_visible();
                    self.toggle_search_mode();
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

        for (idx, item) in self.scripts.items.iter().enumerate() {
            if !item.is_category_header
                && (item.name.to_lowercase().contains(&search_term)
                    || item.category.to_lowercase().contains(&search_term))
            {
                self.search_results.push(idx);
            }
        }
    }

    pub fn ensure_selected_visible(&mut self) {
        if let Some(selected) = self.scripts.state.selected() {
            let selected_item = &self.scripts.items[selected];

            if !self.visible_items.contains(&selected) && !selected_item.is_category_header {
                self.expanded_categories
                    .insert(selected_item.category.clone(), true);
                self.update_visible_items();
            }
        }
    }

    pub fn handle_key_normal_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('q') => self.quit = true,
            KeyCode::Char('p') => self.toggle_preview_mode(),
            KeyCode::Char('/') => self.toggle_search_mode(),
            KeyCode::Char('m') => self.toggle_multi_select_mode(),
            KeyCode::Esc => {
                if self.multi_select_mode {
                    self.toggle_multi_select_mode();
                }
            }
            KeyCode::Char('j') => self.next(),
            KeyCode::Char('k') => self.previous(),
            KeyCode::Char(' ') => {
                if self.multi_select_mode {
                    self.toggle_script_selection();
                }
            }
            KeyCode::Enter => {
                if self.multi_select_mode && !self.multi_selected_scripts.is_empty() {
                    self.mode = AppMode::Confirm;
                }
            }
            KeyCode::Down => self.next(),
            KeyCode::Up => self.previous(),
            _ => {}
        }
    }

    pub fn handle_key_preview_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Esc | KeyCode::Char('q') => self.toggle_preview_mode(),
            KeyCode::Char('j') | KeyCode::Down => self.scroll_preview_down(),
            KeyCode::Char('k') | KeyCode::Up => self.scroll_preview_up(),
            KeyCode::PageDown => {
                for _ in 0..5 {
                    self.scroll_preview_down();
                }
            }
            KeyCode::PageUp => {
                for _ in 0..5 {
                    self.scroll_preview_up();
                }
            }
            KeyCode::Home => {
                self.preview_scroll = 0;
            }
            KeyCode::End => {
                let line_count = self.preview_content.lines().count() as u16;
                let max_scroll = if line_count > 0 { line_count } else { 0 };
                self.preview_scroll = max_scroll;
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
            },
            _ => {}
        }
    }

    pub fn next(&mut self) {
        if self.visible_items.is_empty() {
            return;
        }

        let current_selected = self.scripts.state.selected();
        let next_visible_pos = current_selected
            .and_then(|sel| self.visible_items.iter().position(|&idx| idx == sel))
            .map(|pos| {
                if pos + 1 < self.visible_items.len() {
                    pos + 1
                } else {
                    0
                }
            })
            .unwrap_or(0);

        if next_visible_pos < self.visible_items.len() {
            self.scripts
                .state
                .select(Some(self.visible_items[next_visible_pos]));
        }

        self.update_preview();
    }

    pub fn previous(&mut self) {
        if self.visible_items.is_empty() {
            return;
        }

        let current_selected = self.scripts.state.selected();
        let prev_visible_pos = current_selected
            .and_then(|sel| self.visible_items.iter().position(|&idx| idx == sel))
            .map(|pos| {
                if pos > 0 {
                    pos - 1
                } else {
                    self.visible_items.len() - 1
                }
            })
            .unwrap_or(0);

        if prev_visible_pos < self.visible_items.len() {
            self.scripts
                .state
                .select(Some(self.visible_items[prev_visible_pos]));
        }

        self.update_preview();
    }

    pub fn update_autocomplete(&mut self) {
        self.autocomplete_text = None;

        if self.search_input.is_empty() {
            return;
        }

        let search_term = self.search_input.to_lowercase();
        let mut best_match = None;
        let mut shortest_len = usize::MAX;

        for item in &self.scripts.items {
            if item.is_category_header {
                continue;
            }

            if item.name.to_lowercase().starts_with(&search_term)
                && item.name.len() > search_term.len()
                && item.name.len() < shortest_len
            {
                best_match = Some(item.name.clone());
                shortest_len = item.name.len();
            }

            let full_path = format!("{}/{}", item.category, item.name);
            if full_path.to_lowercase().starts_with(&search_term)
                && full_path.len() > search_term.len()
                && full_path.len() < shortest_len
            {
                shortest_len = full_path.len();
                best_match = Some(full_path);
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
            if selected < self.scripts.items.len()
                && !self.scripts.items[selected].is_category_header
            {
                if self.multi_selected_scripts.contains(&selected) {
                    self.multi_selected_scripts.retain(|&x| x != selected);
                } else {
                    self.multi_selected_scripts.push(selected);
                }
            }
        }
    }

    pub fn run_selected_scripts<F>(&self, run_script_callback: &F) -> io::Result<()>
    where
        F: Fn(&Path) -> io::Result<()>,
    {
        for &script_idx in &self.multi_selected_scripts {
            if script_idx < self.scripts.items.len()
                && !self.scripts.items[script_idx].is_category_header
            {
                let script_path = &self.scripts.items[script_idx].path;
                run_script_callback(script_path)?;
            }
        }
        Ok(())
    }

    pub fn is_script_selected(&self, idx: usize) -> bool {
        self.multi_selected_scripts.contains(&idx)
    }
}
