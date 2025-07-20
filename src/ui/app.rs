use std::collections::HashMap;

use ratatui::layout::Rect;

use super::state::{
    App, AppMode, FocusedPanel, HelpState, MultiSelectState, PreviewState, SearchState,
    StatefulList,
};

impl<'a> App<'a> {
    pub fn new() -> App<'a> {
        App {
            mode:          AppMode::Normal,
            quit:          false,
            focused_panel: FocusedPanel::Categories,

            scripts:     StatefulList::new(),
            categories:  StatefulList::new(),
            all_scripts: HashMap::new(),

            system_info:       super::system_info::SystemInfo::new(),
            script_panel_area: Rect::default(),
            preview:           PreviewState::default(),
            search:            SearchState::default(),
            multi_select:      MultiSelectState::default(),
            help:              HelpState::default(),
            run_script_popup: None,
            run_script_receiver: None,
        }
    }
}
