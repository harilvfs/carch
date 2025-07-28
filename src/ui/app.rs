use std::collections::HashMap;
use std::path::PathBuf;

use log::info;
use ratatui::layout::Rect;

use super::state::{
    App, AppMode, DescriptionState, FocusedPanel, HelpState, MultiSelectState, PreviewState,
    SearchState, StatefulList,
};
use crate::ui::state::{ScriptItem, UiOptions};
use crate::ui::theme::Theme;

impl<'a> App<'a> {
    /// makes a new app with a starting state
    pub fn new(_options: &UiOptions) -> App<'a> {
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
            // set the theme
            theme:         Theme::catppuccin_mocha(),

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

    pub fn cycle_theme(&mut self) {
        self.theme = match self.theme.name.as_str() {
            "Catppuccin Mocha" => Theme::dracula(),
            "Dracula" => Theme::gruvbox(),
            "Gruvbox" => Theme::nord(),
            "Nord" => Theme::rose_pine(),
            "Rosé Pine" => Theme::catppuccin_mocha(),
            _ => Theme::catppuccin_mocha(),
        }
    }

    /// toggles the description popup for the currently selected script
    pub fn toggle_description_popup(&mut self) {
        if self.mode == AppMode::Description {
            self.mode = AppMode::Normal;
            self.description.content = None;
            if self.log_mode {
                info!("Closed description popup");
            }
        } else if let Some(selected_script) = self.get_selected_script() {
            let desc_path = self.modules_dir.join(&selected_script.category).join("desc.toml");

            if self.log_mode {
                info!(
                    "Attempting to show description for script: {}/{}",
                    selected_script.category, selected_script.name
                );
                info!("Description file path: {}", desc_path.display());
            }

            if desc_path.exists() {
                if let Ok(content) = std::fs::read_to_string(&desc_path) {
                    if let Ok(table) = content.parse::<toml::Table>() {
                        let script_path = PathBuf::from(&selected_script.name);
                        let script_name_without_ext =
                            script_path.file_stem().and_then(|s| s.to_str());

                        if let Some(name) = script_name_without_ext {
                            if let Some(desc) = table
                                .get(name)
                                .and_then(|v| v.as_table())
                                .and_then(|t| t.get("description"))
                                .and_then(|v| v.as_str())
                            {
                                self.description.content = Some(desc.to_string());
                                self.mode = AppMode::Description;
                                if self.log_mode {
                                    info!(
                                        "Successfully loaded description and entered description mode."
                                    );
                                }
                            } else if self.log_mode {
                                info!(
                                    "No description found for script '{}' in desc.toml",
                                    selected_script.name
                                );
                            }
                        }
                    } else if self.log_mode {
                        info!("Failed to parse desc.toml at {}", desc_path.display());
                    }
                } else if self.log_mode {
                    info!("Failed to read desc.toml at {}", desc_path.display());
                }
            } else if self.log_mode {
                info!("desc.toml not found at {}", desc_path.display());
            }
        }
    }

    /// get the currently selected script
    pub fn get_selected_script(&self) -> Option<&ScriptItem> {
        self.scripts.state.selected().map(|i| &self.scripts.items[i])
    }
}
