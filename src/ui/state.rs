use std::collections::HashMap;
use std::path::PathBuf;

use fuzzy_matcher::skim::SkimMatcherV2;
use ratatui::layout::Rect;
use ratatui::text::Text;

use super::popups::run_script::RunScriptPopup;
use super::theme::Theme;

/// shows the different modes the app can be in
/// each mode changes how user input works and what's on the screen
#[derive(PartialEq, Debug, Clone, Copy)]
pub enum AppMode {
    /// the normal mode where you can move around categories and scripts
    Normal,
    /// the mode for finding scripts
    Search,
    /// the mode for saying yes to something, like running a script
    Confirm,
    /// the mode for showing the help pop-up
    Help,
    /// the mode for looking at a script's code
    Preview,
    /// the mode for showing the run script pop-up
    RunScript,
    /// the mode for showing the description pop-up
    Description,
}

/// shows which panel is currently being used
/// this decides which panel gets user input
#[derive(PartialEq, Debug, Clone, Copy)]
pub enum FocusedPanel {
    /// the panel that lists the script groups
    Categories,
    /// the panel that lists the scripts in the chosen group
    Scripts,
}

/// a list that keeps track of its own state
/// it remembers which item is selected and lets you move through the list
pub struct StatefulList<T> {
    /// the list's state, like which item is selected
    pub state: ratatui::widgets::ListState,
    /// the items in the list
    pub items: Vec<T>,
}

impl<T> StatefulList<T> {
    /// makes a new, empty list
    pub fn new() -> StatefulList<T> {
        StatefulList { state: ratatui::widgets::ListState::default(), items: Vec::new() }
    }

    /// makes a new list with some items
    /// if the list isn't empty, the first item is picked
    pub fn with_items(items: Vec<T>) -> StatefulList<T> {
        let mut list = StatefulList::new();
        list.items = items;
        if !list.items.is_empty() {
            list.state.select(Some(0));
        }
        list
    }

    /// picks the next item in the list
    /// if it's at the end, it goes back to the start
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

    /// picks the previous item in the list
    /// if it's at the start, it goes to the end
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

/// a single script that can be run
#[derive(Clone, Debug)]
pub struct ScriptItem {
    /// the group the script is in
    pub category: String,
    /// the name of the script
    pub name:     String,
    /// the path to the script file
    pub path:     PathBuf,
}

/// holds the ui options you can set at the start
#[derive(Default, Clone)]
pub struct UiOptions {
    /// if true, turn on logging
    pub log_mode: bool,
    /// the theme to use
    pub theme:    Option<String>,
}

/// holds the state for the script preview panel
#[derive(Default)]
pub struct PreviewState<'a> {
    /// the code of the script being looked at
    pub content:    String,
    /// how far down you've scrolled in the preview
    pub scroll:     u16,
    /// the furthest you can scroll down
    pub max_scroll: u16,
    /// a cache to store script previews you've already loaded
    pub cache:      HashMap<PathBuf, Text<'a>>,
}

/// a single search result
#[derive(Clone, Debug)]
pub struct SearchResult {
    /// the script that matched the search
    pub item:    ScriptItem,
    /// the match score from the fuzzy finder
    pub score:   i64,
    /// the letters in the item's name that matched the search
    pub indices: Vec<usize>,
}

/// holds the state for the search feature
#[derive(Default)]
pub struct SearchState {
    /// what the user is searching for
    pub input:           String,
    /// the list of search results
    pub results:         Vec<SearchResult>,
    /// where the cursor is in the search box
    pub cursor_position: usize,
    /// the chosen search result
    pub selected_idx:    usize,
    /// a possible autocomplete suggestion
    pub autocomplete:    Option<String>,
    /// the fuzzy finder used for searching
    pub matcher:         SkimMatcherV2,
}

/// holds the state for the multi-select mode
#[derive(Default)]
pub struct MultiSelectState {
    /// if true, multi-select mode is on
    pub enabled: bool,
    /// the list of chosen scripts
    pub scripts: Vec<PathBuf>,
}

/// holds the state for the help pop-up
#[derive(Default)]
pub struct HelpState {
    /// how far down you've scrolled in the help pop-up
    pub scroll:     u16,
    /// the furthest you can scroll down
    pub max_scroll: u16,
}

/// holds the state for the description pop-up
#[derive(Default)]
pub struct DescriptionState {
    /// the content of the description
    pub content:    Option<String>,
    /// how far down you've scrolled
    pub scroll:     u16,
    /// the furthest you can scroll
    pub max_scroll: u16,
}

/// the main state for the whole app
/// it holds all the data needed to show the ui and handle what the user does
pub struct App<'a> {
    /// the current app mode
    pub mode:          AppMode,
    /// if true, the app should close
    pub quit:          bool,
    /// the panel that's currently being used
    pub focused_panel: FocusedPanel,
    /// if true, logging is on
    pub log_mode:      bool,
    /// the path to the modules directory
    pub modules_dir:   PathBuf,
    /// the current theme
    pub theme:         Theme,

    /// the list of scripts for the chosen group
    pub scripts:     StatefulList<ScriptItem>,
    /// the list of script groups
    pub categories:  StatefulList<String>,
    /// a map of all scripts, sorted by group
    pub all_scripts: HashMap<String, Vec<ScriptItem>>,

    /// the part of the screen the script panel uses
    pub script_panel_area:      Rect,
    /// the state of the script preview panel
    pub preview:                PreviewState<'a>,
    /// the state of the search feature
    pub search:                 SearchState,
    /// the state of the multi-select mode
    pub multi_select:           MultiSelectState,
    /// the state of the help pop-up
    pub help:                   HelpState,
    /// the state of the description pop-up
    pub description:            DescriptionState,
    /// an optional pop-up for running a script
    pub run_script_popup:       Option<RunScriptPopup>,
    /// a list of scripts waiting to be run
    pub script_execution_queue: Vec<PathBuf>,
}
