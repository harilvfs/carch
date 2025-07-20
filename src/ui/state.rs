use std::collections::HashMap;
use std::path::PathBuf;

use fuzzy_matcher::skim::SkimMatcherV2;
use ratatui::layout::Rect;
use ratatui::text::Text;

use super::popups::run_script::RunScriptPopup;
use super::system_info::SystemInfo;

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum AppMode {
    Normal,
    Search,
    Confirm,
    Help,
    Preview,
    RunScript,
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

#[derive(Clone, Debug)]
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

#[derive(Default)]
pub struct PreviewState<'a> {
    pub content:    String,
    pub scroll:     u16,
    pub max_scroll: u16,
    pub cache:      HashMap<PathBuf, Text<'a>>,
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
pub struct HelpState {
    pub scroll:     u16,
    pub max_scroll: u16,
}

pub struct App<'a> {
    pub mode:          AppMode,
    pub quit:          bool,
    pub focused_panel: FocusedPanel,

    pub scripts:     StatefulList<ScriptItem>,
    pub categories:  StatefulList<String>,
    pub all_scripts: HashMap<String, Vec<ScriptItem>>,

    pub system_info:       SystemInfo,
    pub script_panel_area: Rect,
    pub preview:           PreviewState<'a>,
    pub search:            SearchState,
    pub help:              HelpState,
    pub run_script_popup:  Option<RunScriptPopup>,
}
