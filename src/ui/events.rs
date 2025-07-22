use crossterm::event::{KeyCode, KeyEvent, MouseEvent, MouseEventKind};

use super::actions::{
    bottom, get_script_path, next, perform_search, previous, scroll_preview_down,
    scroll_preview_page_down, scroll_preview_page_up, scroll_preview_up, toggle_help_mode,
    toggle_multi_select_mode, toggle_preview_mode, toggle_script_selection, toggle_search_mode,
    top, update_autocomplete, update_preview,
};
use super::popups::run_script::RunScriptPopup;
use super::state::{App, AppMode, FocusedPanel};

impl<'a> App<'a> {
    pub fn handle_search_input(&mut self, key: KeyEvent) {
        match key.code {
            KeyCode::Esc => toggle_search_mode(self),
            KeyCode::Enter => {
                if !self.search.results.is_empty() {
                    let selected_item = self.search.results[self.search.selected_idx].clone();

                    if let Some(category_idx) =
                        self.categories.items.iter().position(|c| *c == selected_item.item.category)
                    {
                        self.categories.state.select(Some(category_idx));
                        super::actions::update_script_list(self);

                        if let Some(script_idx) = self
                            .scripts
                            .items
                            .iter()
                            .position(|s| s.name == selected_item.item.name)
                        {
                            self.scripts.state.select(Some(script_idx));
                        }
                    }

                    update_preview(self);
                    toggle_search_mode(self);
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
                    perform_search(self);
                    update_autocomplete(self);
                }
            }
            KeyCode::Char(c) => {
                self.search.input.push(c);
                self.search.cursor_position += 1;
                perform_search(self);
                update_autocomplete(self);
                self.search.selected_idx = 0;
            }
            KeyCode::Backspace => {
                if self.search.cursor_position > 0 {
                    self.search.input.remove(self.search.cursor_position - 1);
                    self.search.cursor_position -= 1;
                    perform_search(self);
                    update_autocomplete(self);
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
                    perform_search(self);
                }
            }
            _ => {}
        }
    }

    pub fn handle_key_normal_mode(&mut self, key: KeyEvent) {
        match key.code {
            KeyCode::Char('q') => {
                self.quit = true;
            }
            KeyCode::Esc => {
                if self.multi_select.enabled {
                    toggle_multi_select_mode(self);
                }
            }
            KeyCode::Char('j') | KeyCode::Down => {
                next(self);
            }
            KeyCode::Char('k') | KeyCode::Up => {
                previous(self);
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
                top(self);
            }
            KeyCode::End => {
                bottom(self);
            }
            KeyCode::Char('/') => {
                toggle_search_mode(self);
            }
            KeyCode::Char('p') => {
                toggle_preview_mode(self);
            }
            KeyCode::Char('m') => {
                toggle_multi_select_mode(self);
            }
            KeyCode::Char('?') => {
                toggle_help_mode(self);
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
                    toggle_script_selection(self);
                }
            }
            _ => {}
        }
    }

    pub fn handle_key_preview_mode(&mut self, key: KeyEvent) {
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc | KeyCode::Char('p') | KeyCode::Char('h') => {
                self.mode = AppMode::Normal;
            }
            KeyCode::Char('j') | KeyCode::Down => {
                scroll_preview_down(self);
            }
            KeyCode::Char('k') | KeyCode::Up => {
                scroll_preview_up(self);
            }
            KeyCode::PageDown => {
                scroll_preview_page_down(self);
            }
            KeyCode::PageUp => {
                scroll_preview_page_up(self);
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
                AppMode::Normal => next(self),
                AppMode::Preview => {
                    for _ in 0..2 {
                        scroll_preview_down(self);
                    }
                }
                AppMode::Search => {}
                AppMode::Confirm => {}
                AppMode::Help => {
                    self.help.scroll = self.help.scroll.saturating_add(2);
                }
                AppMode::RunScript => {}
            },
            MouseEventKind::ScrollUp => match self.mode {
                AppMode::Normal => previous(self),
                AppMode::Preview => {
                    for _ in 0..2 {
                        scroll_preview_up(self);
                    }
                }
                AppMode::Search => {}
                AppMode::Confirm => {}
                AppMode::Help => {
                    self.help.scroll = self.help.scroll.saturating_sub(2);
                }
                AppMode::RunScript => {}
            },
            _ => {}
        }
    }

    pub fn handle_key_confirmation_mode(&mut self, key: KeyEvent) {
        match key.code {
            KeyCode::Char('y') | KeyCode::Char('Y') | KeyCode::Char('l') => {
                if self.multi_select.enabled && !self.multi_select.scripts.is_empty() {
                    self.script_execution_queue = self.multi_select.scripts.clone();
                } else if let Some(script_path) = get_script_path(self) {
                    self.script_execution_queue.push(script_path);
                }

                if !self.script_execution_queue.is_empty() {
                    let script_path = self.script_execution_queue.remove(0);
                    let popup = RunScriptPopup::new(script_path);
                    self.run_script_popup = Some(popup);
                    self.mode = AppMode::RunScript;
                } else {
                    self.mode = AppMode::Normal;
                }
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

    pub fn handle_key_help_mode(&mut self, key: KeyEvent) {
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
}
