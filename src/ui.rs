use std::collections::HashMap;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};
use std::time::Duration;

use crossterm::{
    event::{
        self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, MouseEvent, MouseEventKind,
    },
    execute,
    terminal::{EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode},
};
use ratatui::{
    Frame, Terminal,
    backend::{Backend, CrosstermBackend},
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Span, Spans, Text},
    widgets::{Block, BorderType, Borders, List, ListItem, Paragraph, Wrap},
};

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum AppMode {
    Normal,
    Preview,
    Search,
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

            let ui_options = crate::ui::UiOptions::default();
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
            if selected < self.scripts.items.len()
                && !self.scripts.items[selected].is_category_header
            {
                let prev_mode = self.mode;
                self.mode = match self.mode {
                    AppMode::Normal => AppMode::Preview,
                    AppMode::Preview => AppMode::Normal,
                    AppMode::Search => AppMode::Normal,
                };

                let ui_options = crate::ui::UiOptions::default();
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
        if self.preview_scroll > 0 {
            self.preview_scroll -= 1;
        }
    }

    pub fn scroll_preview_down(&mut self) {
        let line_count = self.preview_content.lines().count() as u16;

        let max_scroll = if line_count > 20 { line_count - 20 } else { 0 };

        if self.preview_scroll < max_scroll {
            self.preview_scroll += 1;
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

        let ui_options = crate::ui::UiOptions::default();
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
                    self.toggle_search_mode();
                    self.scripts.state.select(Some(selected_result));
                    self.update_preview();

                    self.ensure_selected_visible();
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
            if item.name.to_lowercase().contains(&search_term)
                || item.category.to_lowercase().contains(&search_term)
            {
                self.search_results.push(idx);
            }
        }
    }

    pub fn ensure_selected_visible(&mut self) {
        if let Some(selected) = self.scripts.state.selected() {
            let selected_item = &self.scripts.items[selected];

            if !self.visible_items.contains(&selected) {
                if !selected_item.is_category_header {
                    self.expanded_categories
                        .insert(selected_item.category.clone(), true);
                    self.update_visible_items();
                }
            }
        }
    }

    pub fn handle_key_normal_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('q') => self.quit = true,
            KeyCode::Char('p') => self.toggle_preview_mode(),
            KeyCode::Char('/') => self.toggle_search_mode(),
            KeyCode::Down => self.next(),
            KeyCode::Up => self.previous(),
            KeyCode::Enter => {
                if let Some(selected) = self.scripts.state.selected() {
                    if selected < self.scripts.items.len() {
                        let is_category = self.scripts.items[selected].is_category_header;

                        if is_category {
                            let category = self.scripts.items[selected].category.clone();
                            self.toggle_category(&category);
                        }
                    }
                }
            }
            _ => {}
        }
    }

    pub fn handle_key_preview_mode(&mut self, key: crossterm::event::KeyEvent) {
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => self.toggle_preview_mode(),
            KeyCode::Up => self.scroll_preview_up(),
            KeyCode::Down => self.scroll_preview_down(),
            KeyCode::PageUp => {
                for _ in 0..10 {
                    self.scroll_preview_up();
                }
            }
            KeyCode::PageDown => {
                for _ in 0..10 {
                    self.scroll_preview_down();
                }
            }
            _ => {}
        }
    }

    pub fn handle_mouse(&mut self, event: MouseEvent) {
        match event.kind {
            MouseEventKind::ScrollDown => match self.mode {
                AppMode::Normal => self.next(),
                AppMode::Preview => self.scroll_preview_down(),
                AppMode::Search => {}
            },
            MouseEventKind::ScrollUp => match self.mode {
                AppMode::Normal => self.previous(),
                AppMode::Preview => self.scroll_preview_up(),
                AppMode::Search => {}
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
            if item.category.to_lowercase().starts_with(&search_term)
                && item.category.len() > search_term.len()
                && item.category.len() < shortest_len
            {
                best_match = Some(item.category.clone());
                shortest_len = item.category.len();
            }

            if !item.is_category_header {
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
        }

        self.autocomplete_text = best_match;
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

#[allow(dead_code)]
pub fn run_ui<F>(modules_dir: &Path, run_script_callback: F) -> io::Result<()>
where
    F: Fn(&Path) -> io::Result<()>,
{
    run_ui_with_options(modules_dir, run_script_callback, UiOptions::default())
}

pub fn run_ui_with_options<F>(
    modules_dir: &Path,
    run_script_callback: F,
    options: UiOptions,
) -> io::Result<()>
where
    F: Fn(&Path) -> io::Result<()>,
{
    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "UI initialization started");
    }

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut app = App::new();

    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "Loading scripts from modules directory");
    }

    app.load_scripts(modules_dir)?;

    if options.log_mode {
        let _ = crate::commands::log_message(
            "INFO",
            &format!(
                "Loaded {} scripts in {} categories",
                app.scripts
                    .items
                    .iter()
                    .filter(|s| !s.is_category_header)
                    .count(),
                app.categories.len()
            ),
        );
    }

    if !options.show_preview {
        app.mode = AppMode::Normal;

        if options.log_mode {
            let _ = crate::commands::log_message("INFO", "Preview mode disabled by configuration");
        }
    }

    while !app.quit {
        terminal.draw(|f| ui(f, &mut app, &options))?;

        if let Ok(true) = event::poll(Duration::from_millis(100)) {
            if let Ok(event) = event::read() {
                match event {
                    Event::Key(key) => {
                        if options.log_mode {
                            let key_name = match key.code {
                                KeyCode::Char(c) => format!("Char('{}')", c),
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
                                if key.code == KeyCode::Char('p') && !options.show_preview {
                                    if options.log_mode {
                                        let _ = crate::commands::log_message(
                                            "INFO",
                                            "Preview toggle attempted but previews are disabled",
                                        );
                                    }
                                } else {
                                    app.handle_key_normal_mode(key);
                                }
                            }
                            AppMode::Preview => {
                                if !options.show_preview {
                                    app.mode = AppMode::Normal;
                                    if options.log_mode {
                                        let _ = crate::commands::log_message(
                                            "INFO",
                                            "Exiting preview mode because previews are disabled",
                                        );
                                    }
                                } else {
                                    app.handle_key_preview_mode(key);
                                }
                            }
                            AppMode::Search => app.handle_search_input(key),
                        }

                        if let KeyCode::Enter = key.code {
                            if app.mode == AppMode::Normal {
                                if let Some(selected) = app.scripts.state.selected() {
                                    if selected < app.scripts.items.len()
                                        && !app.scripts.items[selected].is_category_header
                                    {
                                        if let Some(script_path) = app.get_script_path() {
                                            if options.log_mode {
                                                let script_name = script_path
                                                    .file_name()
                                                    .unwrap_or_default()
                                                    .to_string_lossy();
                                                let _ = crate::commands::log_message(
                                                    "INFO",
                                                    &format!(
                                                        "Selected script for execution: {}",
                                                        script_name
                                                    ),
                                                );
                                            }

                                            disable_raw_mode()?;
                                            execute!(
                                                terminal.backend_mut(),
                                                LeaveAlternateScreen,
                                                DisableMouseCapture
                                            )?;
                                            terminal.show_cursor()?;

                                            if options.log_mode {
                                                let _ = crate::commands::log_message(
                                                    "INFO",
                                                    "Exiting UI to run script",
                                                );
                                            }

                                            run_script_callback(&script_path)?;

                                            if options.log_mode {
                                                let _ = crate::commands::log_message(
                                                    "INFO",
                                                    "Script execution completed, returning to UI",
                                                );
                                            }

                                            enable_raw_mode()?;
                                            let mut stdout = io::stdout();
                                            execute!(
                                                stdout,
                                                EnterAlternateScreen,
                                                EnableMouseCapture
                                            )?;

                                            let backend = CrosstermBackend::new(stdout);
                                            terminal = Terminal::new(backend)?;
                                            terminal.clear()?;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Event::Mouse(mouse_event) => {
                        if options.log_mode {
                            let _ = crate::commands::log_message(
                                "DEBUG",
                                &format!("Mouse event: {:?}", mouse_event),
                            );
                        }
                        app.handle_mouse(mouse_event);
                    }
                    _ => {}
                }
            }
        }
    }

    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "User requested application exit");
    }

    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    print!("\x1B[2J\x1B[1;1H");

    if options.log_mode {
        let _ = crate::commands::log_message("INFO", "UI terminated normally");
    }

    Ok(())
}

fn ui<B: Backend>(f: &mut Frame<B>, app: &mut App, options: &UiOptions) {
    if app.mode == AppMode::Preview && !options.show_preview {
        app.mode = AppMode::Normal;
    }

    if app.mode == AppMode::Preview && options.show_preview {
        render_fullscreen_preview(f, app);
        return;
    }

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(1)
        .constraints([Constraint::Length(3), Constraint::Min(0)])
        .split(f.size());

    render_title(f, chunks[0]);

    let main_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(40), Constraint::Percentage(60)])
        .split(chunks[1]);

    render_script_list(f, app, main_chunks[0]);

    if options.show_preview {
        render_preview(f, app, main_chunks[1]);
    } else {
        let preview_disabled_text = vec![Spans::from(vec![Span::styled(
            "Preview disabled (--no-preview)",
            Style::default().fg(Color::Gray),
        )])];

        let preview_disabled = Paragraph::new(preview_disabled_text)
            .block(create_rounded_block().title("Preview"))
            .alignment(ratatui::layout::Alignment::Center);

        f.render_widget(preview_disabled, main_chunks[1]);
    }

    if app.mode == AppMode::Search {
        render_search_popup(f, app);
    }
}

fn render_title<B: Backend>(f: &mut Frame<B>, area: Rect) {
    let title = Paragraph::new(vec![
        Spans::from(vec![Span::styled(
            "CARCH",
            Style::default()
                .fg(Color::Magenta)
                .add_modifier(Modifier::BOLD),
        )]),
        Spans::from(vec![Span::styled(
            "Automate Your Linux Setup",
            Style::default().fg(Color::Cyan),
        )]),
    ])
    .alignment(ratatui::layout::Alignment::Center);

    f.render_widget(title, area);
}

fn create_rounded_block() -> Block<'static> {
    Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
}

fn render_script_list<B: Backend>(f: &mut Frame<B>, app: &mut App, area: Rect) {
    let mut list_items = Vec::new();

    for &idx in &app.visible_items {
        let item = &app.scripts.items[idx];

        if item.is_category_header {
            let expanded = *app.expanded_categories.get(&item.category).unwrap_or(&true);
            let prefix = if expanded { "▼ " } else { "▶ " };

            list_items.push(ListItem::new(Spans::from(vec![Span::styled(
                format!("{}{}", prefix, item.category),
                Style::default()
                    .fg(Color::Yellow)
                    .add_modifier(Modifier::BOLD),
            )])));
        } else {
            list_items.push(ListItem::new(Spans::from(vec![
                Span::raw("  "),
                Span::styled(&item.name, Style::default().fg(Color::Gray)),
            ])));
        }
    }

    let title = Spans::from(vec![
        Span::styled("Select a script to run ", Style::default()),
        Span::styled("(/: search)", Style::default().fg(Color::Gray)),
    ]);

    let block = create_rounded_block().title(title);

    let mut script_list = List::new(list_items)
        .block(block)
        .highlight_style(
            Style::default()
                .bg(Color::Rgb(235, 235, 210))
                .fg(Color::Black)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("");

    if let Some(selected) = app.scripts.state.selected() {
        if selected < app.scripts.items.len() && app.scripts.items[selected].is_category_header {
            script_list = script_list.highlight_style(
                Style::default()
                    .bg(Color::Yellow)
                    .fg(Color::Black)
                    .add_modifier(Modifier::BOLD),
            );
        }
    }

    if let Some(selected) = app.scripts.state.selected() {
        let visible_pos = app.visible_items.iter().position(|&i| i == selected);
        if let Some(pos) = visible_pos {
            app.list_state.select(Some(pos));
        } else if !app.visible_items.is_empty() {
            app.list_state.select(Some(0));
            app.scripts.state.select(Some(app.visible_items[0]));
        }
    }

    f.render_stateful_widget(script_list, area, &mut app.list_state);
}

fn render_preview<B: Backend>(f: &mut Frame<B>, app: &App, area: Rect) {
    let selected_script = app
        .scripts
        .state
        .selected()
        .and_then(|i| app.scripts.items.get(i).map(|s| s.full_name()));

    let title = match selected_script {
        Some(name) => {
            if let Some(selected) = app.scripts.state.selected() {
                if app.scripts.items[selected].is_category_header {
                    String::from("Preview: Select a script to see preview")
                } else {
                    format!("Preview: {} (Press 'p' for full screen)", name)
                }
            } else {
                String::from("Preview")
            }
        }
        None => String::from("Preview"),
    };

    let preview_text = Text::from(app.preview_content.clone());

    let preview = Paragraph::new(preview_text)
        .block(create_rounded_block().title(title))
        .wrap(Wrap { trim: false })
        .scroll((app.preview_scroll, 0));

    f.render_widget(preview, area);
}

fn render_fullscreen_preview<B: Backend>(f: &mut Frame<B>, app: &App) {
    let area = f.size();

    let margin_horizontal = (area.width as f32 * 0.1) as u16;
    let margin_vertical = (area.height as f32 * 0.1) as u16;

    let smaller_area = Rect {
        x: margin_horizontal,
        y: margin_vertical,
        width: area.width - (margin_horizontal * 2),
        height: area.height - (margin_vertical * 2),
    };

    let selected_script = app
        .scripts
        .state
        .selected()
        .and_then(|i| app.scripts.items.get(i).map(|s| s.full_name()));

    let title = match selected_script {
        Some(name) => format!("Preview: {} (Press ESC or 'q' to close)", name),
        None => String::from("Preview (Press ESC or 'q' to close)"),
    };

    let preview_area = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Min(1), Constraint::Length(1)])
        .split(smaller_area);

    let preview_text = Text::from(app.preview_content.clone());

    let block = create_rounded_block()
        .title(title)
        .border_style(Style::default().fg(Color::Cyan));

    let preview = Paragraph::new(preview_text)
        .block(block)
        .wrap(Wrap { trim: false })
        .scroll((app.preview_scroll, 0));

    f.render_widget(preview, preview_area[0]);

    let help_text = Paragraph::new(vec![Spans::from(vec![
        Span::styled("↑/↓: Scroll  ", Style::default().fg(Color::Gray)),
        Span::styled(
            "PgUp/PgDown: Scroll faster  ",
            Style::default().fg(Color::Gray),
        ),
        Span::styled("ESC/q: Close preview", Style::default().fg(Color::Gray)),
    ])])
    .alignment(ratatui::layout::Alignment::Center);

    f.render_widget(help_text, preview_area[1]);
}

fn render_search_popup<B: Backend>(f: &mut Frame<B>, app: &App) {
    let area = f.size();

    let popup_width = std::cmp::min(70, area.width - 8);
    let popup_height = std::cmp::min(16, area.height - 6);

    let popup_area = Rect {
        x: (area.width - popup_width) / 2,
        y: (area.height - popup_height) / 2,
        width: popup_width,
        height: popup_height,
    };

    f.render_widget(ratatui::widgets::Clear, popup_area);

    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(3),
            Constraint::Length(1),
        ])
        .split(popup_area);

    let popup_block = create_rounded_block()
        .title("Search")
        .border_style(Style::default().fg(Color::Cyan));

    f.render_widget(popup_block, popup_area);

    let display_text = if let Some(ref autocomplete) = app.autocomplete_text {
        let base = &app.search_input;
        let completion = &autocomplete[base.len()..];

        Spans::from(vec![
            Span::styled(base.clone(), Style::default()),
            Span::styled(completion, Style::default().fg(Color::DarkGray)),
        ])
    } else {
        Spans::from(app.search_input.clone())
    };

    let input = Paragraph::new(display_text)
        .block(create_rounded_block().title("Type to search (Tab to complete)"))
        .style(Style::default())
        .alignment(ratatui::layout::Alignment::Left);

    f.render_widget(input, popup_layout[0]);

    if app.search_cursor_position <= app.search_input.len() {
        f.set_cursor(
            popup_layout[0].x + 1 + app.search_cursor_position as u16,
            popup_layout[0].y + 1,
        );
    }

    let mut result_items = Vec::new();

    let max_display = (popup_height - 5) as usize;
    let result_count = app.search_results.len();

    let display_count = std::cmp::min(result_count, max_display);
    let start_idx = if result_count <= max_display {
        0
    } else {
        let half_display = max_display / 2;
        if app.search_selected_idx < half_display {
            0
        } else if app.search_selected_idx >= result_count - half_display {
            result_count - max_display
        } else {
            app.search_selected_idx - half_display
        }
    };

    for i in 0..display_count {
        let result_idx = start_idx + i;
        if result_idx < app.search_results.len() {
            let script_idx = app.search_results[result_idx];

            if script_idx < app.scripts.items.len() {
                let item = &app.scripts.items[script_idx];
                let display_text = if item.is_category_header {
                    item.category.clone()
                } else {
                    format!("{}/{}", item.category, item.name)
                };

                result_items.push(ListItem::new(Spans::from(vec![Span::styled(
                    display_text,
                    Style::default().fg(Color::Gray),
                )])));
            }
        }
    }

    let result_count_text = format!("Found {} results", app.search_results.len());

    let search_results = List::new(result_items)
        .block(create_rounded_block().title(result_count_text))
        .highlight_style(
            Style::default()
                .bg(Color::Rgb(235, 235, 210))
                .fg(Color::Black)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("");

    let mut search_list_state = ratatui::widgets::ListState::default();
    search_list_state.select(Some(app.search_selected_idx.saturating_sub(start_idx)));

    f.render_stateful_widget(search_results, popup_layout[1], &mut search_list_state);

    let help_text = Paragraph::new(vec![Spans::from(vec![
        Span::styled("↑/↓: Navigate  ", Style::default().fg(Color::Gray)),
        Span::styled("Tab: Complete  ", Style::default().fg(Color::Gray)),
        Span::styled("Enter: Select  ", Style::default().fg(Color::Gray)),
        Span::styled("Esc: Cancel", Style::default().fg(Color::Gray)),
    ])])
    .alignment(ratatui::layout::Alignment::Center);

    f.render_widget(help_text, popup_layout[2]);
}
