use std::collections::{HashMap, VecDeque};
use std::path::PathBuf;
use std::process::Command;

use log::info;
use ratatui::layout::Rect;

use super::state::{
    App, AppMode, DescriptionState, FocusedPanel, HelpState, MultiSelectState, PreviewState,
    SearchState, StatefulList,
};
use crate::ui::state::{ScriptItem, UiOptions};
use crate::ui::theme::Theme;

fn detect_distro() -> String {
    if let Ok(content) = std::fs::read_to_string("/etc/os-release") {
        for line in content.lines() {
            if let Some(value) = line.strip_prefix("ID=") {
                let id = value.trim_matches('"');
                let name = match id {
                    "arch" | "manjaro" | "endeavouros" => "Arch",
                    "fedora" => "Fedora",
                    "opensuse-tumbleweed" | "opensuse-leap" | "opensuse" => "openSUSE",
                    "debian" | "ubuntu" | "linuxmint" | "pop" | "zorin" => "Debian",
                    "alpine" => "Alpine",
                    "void" => "Void",
                    "gentoo" => "Gentoo",
                    "nixos" => "NixOS",
                    "termux" => "Termux",
                    _ => "",
                };
                if !name.is_empty() {
                    return name.to_string();
                }
            }
        }
        for line in content.lines() {
            if let Some(value) = line.strip_prefix("PRETTY_NAME=") {
                return value.trim_matches('"').to_string();
            }
        }
    }

    if std::env::var("TERMUX_VERSION").is_ok() {
        return "Termux".to_string();
    }

    let checks: &[(&str, &str)] = &[
        ("dnf", "Fedora"),
        ("zypper", "openSUSE"),
        ("apt", "Debian"),
        ("pacman", "Arch"),
        ("apk", "Alpine"),
        ("xbps-install", "Void"),
        ("emerge", "Gentoo"),
        ("nix", "NixOS"),
        ("pkg", "Termux"),
    ];

    for (cmd, name) in checks {
        if Command::new("command").args(["-v", cmd]).output().is_ok() {
            return name.to_string();
        }
    }

    "Linux".to_string()
}

impl App {
    pub fn new(options: &UiOptions) -> App {
        let theme = match options.theme.as_str() {
            "dracula" => Theme::dracula(),
            "gruvbox" => Theme::gruvbox(),
            "nord" => Theme::nord(),
            "rose-pine" => Theme::rose_pine(),
            _ => Theme::catppuccin_mocha(),
        };

        let distro = detect_distro();

        let mode = if options.is_root {
            AppMode::RootWarning
        } else if distro == "Termux" {
            AppMode::TermuxWarning
        } else {
            AppMode::Normal
        };

        App {
            mode,
            quit: false,
            focused_panel: FocusedPanel::Categories,
            log_mode: options.log_mode,
            modules_dir: PathBuf::new(),
            theme,
            theme_locked: options.theme_locked,
            distro,

            scripts: StatefulList::new(),
            categories: StatefulList::new(),
            all_scripts: HashMap::new(),

            script_panel_area: Rect::default(),
            preview: PreviewState::default(),
            search: SearchState::default(),
            multi_select: MultiSelectState::default(),
            help: HelpState::default(),
            description: DescriptionState::default(),
            run_script_popup: None,
            script_execution_queue: VecDeque::new(),

            needs_redraw: true,
            last_size: Rect::default(),
        }
    }

    pub fn cycle_theme(&mut self) {
        self.theme = match self.theme.name.as_str() {
            "Catppuccin Mocha" => Theme::dracula(),
            "Dracula" => Theme::gruvbox(),
            "Gruvbox" => Theme::nord(),
            "Nord" => Theme::rose_pine(),
            _ => Theme::catppuccin_mocha(),
        }
    }

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

            let desc = read_description(&desc_path, &selected_script.name);

            if self.log_mode {
                match &desc {
                    Some(_) => {
                        info!("Successfully loaded description and entered description mode.");
                    }
                    None => info!(
                        "No description available for script '{}/{}'",
                        selected_script.category, selected_script.name
                    ),
                }
            }

            self.description.content = Some(desc.unwrap_or_else(|| {
                format!(
                    "No description available for '{}/{}'.",
                    selected_script.category, selected_script.name
                )
            }));
            self.description.scroll = 0;
            self.mode = AppMode::Description;
        }
    }

    pub fn get_selected_script(&self) -> Option<&ScriptItem> {
        self.scripts.state.selected().map(|i| &self.scripts.items[i])
    }
}

fn read_description(desc_path: &std::path::Path, script_name: &str) -> Option<String> {
    let content = std::fs::read_to_string(desc_path).ok()?;
    let table: toml::Table = content.parse().ok()?;
    let stem = std::path::Path::new(script_name).file_stem().and_then(|s| s.to_str())?;
    table
        .get(stem)
        .and_then(|v| v.as_table())
        .and_then(|t| t.get("description"))
        .and_then(|v| v.as_str())
        .map(str::to_string)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn write_desc(dir: &std::path::Path, content: &str) -> std::path::PathBuf {
        let path = dir.join("desc.toml");
        std::fs::write(&path, content).unwrap();
        path
    }

    #[test]
    fn read_description_found() {
        let dir = std::env::temp_dir().join(format!("carch_test_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = write_desc(
            &dir,
            r#"
[install]
description = "Installs packages"
"#,
        );
        let desc = read_description(&path, "install.sh");
        assert_eq!(desc.as_deref(), Some("Installs packages"));
        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn read_description_missing_file() {
        let path = std::path::Path::new("/tmp/this_file_should_not_exist_carch.toml");
        let _ = std::fs::remove_file(path);
        assert_eq!(read_description(path, "x"), None);
    }

    #[test]
    fn read_description_malformed_toml() {
        let dir = std::env::temp_dir().join(format!("carch_test_bad_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join("desc.toml");
        std::fs::write(&path, "this is = not valid toml [[[").unwrap();
        assert_eq!(read_description(&path, "install"), None);
        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn read_description_missing_key() {
        let dir = std::env::temp_dir().join(format!("carch_test_k_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join("desc.toml");
        std::fs::write(
            &path,
            r#"[other]
description = "x"
"#,
        )
        .unwrap();
        assert_eq!(read_description(&path, "install"), None);
        let _ = std::fs::remove_dir_all(&dir);
    }
}
