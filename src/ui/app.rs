use std::collections::HashMap;

use ratatui::layout::Rect;

use super::state::{
    App, AppMode, FocusedPanel, HelpState, MultiSelectState, PreviewState, SearchState,
    StatefulList,
};

impl<'a> App<'a> {
    /// makes a new `app` with a starting state.
    pub fn new() -> App<'a> {
        App {
            // set the starting mode to `normal`.
            mode:          AppMode::Normal,
            // the app shouldn't close by default.
            quit:          false,
            // the `categories` panel is focused at the start.
            focused_panel: FocusedPanel::Categories,
            // logging is off by default.
            log_mode:      false,

            // the lists of scripts and categories start empty.
            scripts:     StatefulList::new(),
            categories:  StatefulList::new(),
            all_scripts: HashMap::new(),

            // get the system info.
            system_info:            super::system_info::SystemInfo::new(),
            // the script panel area starts as a zero-sized box.
            script_panel_area:      Rect::default(),
            // set up the starting state for preview, search, multi-select, and help.
            preview:                PreviewState::default(),
            search:                 SearchState::default(),
            multi_select:           MultiSelectState::default(),
            help:                   HelpState::default(),
            // no pop-ups are shown at the start.
            run_script_popup:       None,
            // the list of scripts to run starts empty.
            script_execution_queue: Vec::new(),
        }
    }
}
