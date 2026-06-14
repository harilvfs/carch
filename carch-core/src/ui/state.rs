use std::collections::{HashMap, VecDeque};
use std::path::PathBuf;

use fuzzy_matcher::skim::SkimMatcherV2;
use ratatui::layout::Rect;
use ratatui::text::Text;

use super::popups::run_script::RunScriptPopup;
use super::theme::Theme;

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
pub enum AppMode {
    Normal,
    Search,
    Confirm,
    Help,
    Preview,
    RunScript,
    Description,
    RootWarning,
}

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
pub enum FocusedPanel {
    Categories,
    Scripts,
}

pub struct StatefulList<T> {
    pub state: ratatui::widgets::ListState,
    pub items: Vec<T>,
}

impl<T> Default for StatefulList<T> {
    fn default() -> Self {
        Self::new()
    }
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
        if self.items.is_empty() {
            self.state.select(None);
            return;
        }
        let i = match self.state.selected() {
            Some(i) if i + 1 < self.items.len() => i + 1,
            _ => 0,
        };
        self.state.select(Some(i));
    }

    pub fn previous(&mut self) {
        if self.items.is_empty() {
            self.state.select(None);
            return;
        }
        let last = self.items.len() - 1;
        let i = match self.state.selected() {
            Some(0) | None => last,
            Some(i) => i - 1,
        };
        self.state.select(Some(i));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn next_on_empty_does_not_panic() {
        let mut list: StatefulList<u32> = StatefulList::new();
        list.next();
        list.next();
        list.next();
        assert_eq!(list.state.selected(), None);
    }

    #[test]
    fn previous_on_empty_does_not_panic() {
        let mut list: StatefulList<u32> = StatefulList::new();
        list.previous();
        list.previous();
        assert_eq!(list.state.selected(), None);
    }

    #[test]
    fn next_wraps_to_start() {
        let mut list = StatefulList::with_items(vec!["a", "b", "c"]);
        assert_eq!(list.state.selected(), Some(0));
        list.next();
        assert_eq!(list.state.selected(), Some(1));
        list.next();
        assert_eq!(list.state.selected(), Some(2));
        list.next();
        assert_eq!(list.state.selected(), Some(0));
    }

    #[test]
    fn previous_wraps_to_end() {
        let mut list = StatefulList::with_items(vec!["a", "b", "c"]);
        list.previous();
        assert_eq!(list.state.selected(), Some(2));
        list.previous();
        assert_eq!(list.state.selected(), Some(1));
    }

    #[test]
    fn single_item_next_keeps_selection() {
        let mut list = StatefulList::with_items(vec!["only"]);
        list.next();
        assert_eq!(list.state.selected(), Some(0));
        list.previous();
        assert_eq!(list.state.selected(), Some(0));
    }
}

#[derive(Clone, Debug)]
pub struct ScriptItem {
    pub category: String,
    pub name:     String,
    pub path:     PathBuf,
}

#[derive(Default, Clone)]
pub struct UiOptions {
    pub log_mode:     bool,
    pub theme:        String,
    pub theme_locked: bool,
    pub is_root:      bool,
}

#[derive(Default)]
pub struct PreviewState {
    pub content:    String,
    pub scroll:     u16,
    pub max_scroll: u16,
    pub cache:      HashMap<PathBuf, Text<'static>>,
}

#[derive(Clone, Debug)]
pub struct SearchResult {
    pub item:    ScriptItem,
    pub score:   i64,
    pub indices: Vec<usize>,
}

#[derive(Default)]
pub struct SearchState {
    pub input:           String,
    pub results:         Vec<SearchResult>,
    pub cursor_position: usize,
    pub selected_idx:    usize,
    pub autocomplete:    Option<String>,
    pub matcher:         SkimMatcherV2,
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

#[derive(Default)]
pub struct DescriptionState {
    pub content:    Option<String>,
    pub scroll:     u16,
    pub max_scroll: u16,
}

pub struct App {
    pub mode:          AppMode,
    pub quit:          bool,
    pub focused_panel: FocusedPanel,
    pub log_mode:      bool,
    pub modules_dir:   PathBuf,
    pub theme:         Theme,
    pub theme_locked:  bool,
    pub distro:        String,

    pub scripts:     StatefulList<ScriptItem>,
    pub categories:  StatefulList<String>,
    pub all_scripts: HashMap<String, Vec<ScriptItem>>,

    pub script_panel_area:      Rect,
    pub preview:                PreviewState,
    pub search:                 SearchState,
    pub multi_select:           MultiSelectState,
    pub help:                   HelpState,
    pub description:            DescriptionState,
    pub run_script_popup:       Option<RunScriptPopup>,
    pub script_execution_queue: VecDeque<PathBuf>,

    pub needs_redraw: bool,
    pub last_size:    Rect,
}
