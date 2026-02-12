use log::info;
use std::path::{Path, PathBuf};
use std::{fs, io};

use super::state::{
    App, AppMode, FocusedPanel, ScriptItem, SearchResult, SearchState, StatefulList,
};
use fuzzy_matcher::FuzzyMatcher;

impl<'a> App<'a> {
    pub fn load_scripts(&mut self, modules_dir: &Path) -> io::Result<()> {
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
                scripts_in_category.sort_by(|a, b| a.name.cmp(&b.name));
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

            if self.log_mode {
                if prev_mode == AppMode::Normal && self.mode == AppMode::Preview {
                    info!("Entered preview mode");
                } else if prev_mode == AppMode::Preview && self.mode == AppMode::Normal {
                    info!("Exited preview mode");
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
        if self.mode == AppMode::Search {
            if let Some(selected_idx) = self.search.results.get(self.search.selected_idx) {
                return Some(selected_idx.item.path.clone());
            }
        } else if let Some(script_item) =
            self.scripts.state.selected().and_then(|idx| self.scripts.items.get(idx))
        {
            return Some(script_item.path.clone());
        }
        None
    }

    pub fn toggle_search_mode(&mut self) {
        let prev_mode = self.mode;
        self.mode = if self.mode == AppMode::Search { AppMode::Normal } else { AppMode::Search };

        if self.log_mode {
            if prev_mode != AppMode::Search && self.mode == AppMode::Search {
                info!("Entered search mode");
            } else if prev_mode == AppMode::Search && self.mode != AppMode::Search {
                info!("Exited search mode");
            }
        }

        if self.mode == AppMode::Search {
            self.search = SearchState::default();
            self.perform_search();
        }
    }

    pub fn perform_search(&mut self) {
        self.search.results.clear();

        if self.search.input.is_empty() {
            let mut all_scripts: Vec<_> = self
                .all_scripts
                .values()
                .flat_map(|scripts| scripts.iter().cloned())
                .map(|item| SearchResult { item, score: 0, indices: Vec::new() })
                .collect();
            all_scripts.sort_by(|a, b| a.item.name.cmp(&b.item.name));
            self.search.results = all_scripts;
            return;
        }

        let mut results = Vec::new();
        for item in self.all_scripts.values().flat_map(|scripts| scripts.iter()) {
            let choice = format!("{}/{}", item.category, item.name);
            if let Some((score, indices)) =
                self.search.matcher.fuzzy_indices(&choice, &self.search.input)
            {
                results.push(SearchResult { item: item.clone(), score, indices });
            }
        }

        results.sort_by_key(|b| std::cmp::Reverse(b.score));
        self.search.results = results;
    }

    pub fn next(&mut self) {
        if self.log_mode {
            info!("Navigating next in {:?}", self.focused_panel);
        }
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
        if self.log_mode {
            info!("Navigating previous in {:?}", self.focused_panel);
        }
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

    pub fn is_script_selected(&self, script_path: &Path) -> bool {
        self.multi_select.scripts.contains(&script_path.to_path_buf())
    }

    pub fn toggle_help_mode(&mut self) {
        self.mode = if self.mode == AppMode::Help { AppMode::Normal } else { AppMode::Help };
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

    pub fn handle_key_root_warning_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            crossterm::event::KeyCode::Char('y') | crossterm::event::KeyCode::Char('Y') => {
                self.mode = AppMode::Normal;
            }
            crossterm::event::KeyCode::Char('n') | crossterm::event::KeyCode::Char('N') => {
                self.quit = true;
            }
            _ => {}
        }
    }
}
