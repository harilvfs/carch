use std::collections::HashMap;
use std::path::PathBuf;

use ratatui::layout::Rect;

use super::state::{
    App, AppMode, DescriptionState, FocusedPanel, HelpState, MultiSelectState, PreviewState,
    SearchState, StatefulList,
};
use crate::ui::state::ScriptItem;

impl<'a> App<'a> {
    /// makes a new app with a starting state
    pub fn new() -> App<'a> {
        App {
            // set the starting mode to normal
            mode:          AppMode::Normal,
            // the app shouldn't close by default
            quit:          false,
            // the categories panel is focused at the start
            focused_panel: FocusedPanel::Categories,
            // logging is off by default
            log_mode:      false,
            // path starts empty and is set when the ui is initialized
            modules_dir:   PathBuf::new(),

            // the lists of scripts and categories start empty
            scripts:     StatefulList::new(),
            categories:  StatefulList::new(),
            all_scripts: HashMap::new(),

            // the script panel area starts as a zero-sized box
            script_panel_area:      Rect::default(),
            // set up the starting state for preview, search, multi-select, and help
            preview:                PreviewState::default(),
            search:                 SearchState::default(),
            multi_select:           MultiSelectState::default(),
            help:                   HelpState::default(),
            description:            DescriptionState::default(),
            // no pop-ups are shown at the start
            run_script_popup:       None,
            // the list of scripts to run starts empty
            script_execution_queue: Vec::new(),
        }
    }

    /// toggles the description popup for the currently selected script
    pub fn toggle_description_popup(&mut self) {
        if self.mode == AppMode::Description {
            self.mode = AppMode::Normal;
            self.description.content = None;
        } else if let Some(selected_script) = self.get_selected_script() {
            let desc_path = self.modules_dir.join(&selected_script.category).join("desc.toml");

            if desc_path.exists()
                && let Ok(content) = std::fs::read_to_string(desc_path)
                && let Ok(table) = content.parse::<toml::Value>()
            {
                let script_path = PathBuf::from(&selected_script.name);
                let script_name_without_ext = script_path.file_stem().and_then(|s| s.to_str());

                if let Some(name) = script_name_without_ext
                    && let Some(desc) =
                        table.get(name).and_then(|v| v.get("description")).and_then(|v| v.as_str())
                {
                    self.description.content = Some(desc.to_string());
                    self.mode = AppMode::Description;
                }
            }
        }
    }

    /// get the currently selected script
    pub fn get_selected_script(&self) -> Option<&ScriptItem> {
        self.scripts.state.selected().map(|i| &self.scripts.items[i])
    }
}
