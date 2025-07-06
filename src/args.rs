use crate::{commands, display, script_list, version};
use std::env;
use tempfile::TempDir;

#[derive(Copy, Clone)]
pub struct Settings {
    pub show_preview:  bool,
    pub log_mode:      bool,
    pub cleanup_cache: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Self { show_preview: true, log_mode: false, cleanup_cache: true }
    }
}

pub fn parse_args() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let mut settings = Settings::default();

    if args.iter().any(|arg| arg == "--log") {
        settings.log_mode = true;
        let _ = commands::log_message("INFO", "Carch application started");
    }

    if args.iter().any(|arg| arg == "--no-cleanup") {
        settings.cleanup_cache = false;
        if settings.log_mode {
            let _ = commands::log_message("INFO", "Cache cleanup disabled");
        }
    }

    if args.len() > 1 {
        match args[1].as_str() {
            "--help" | "-h" => {
                if settings.log_mode {
                    let _ = commands::log_message("INFO", "Displaying help information");
                }
                display::display_help()
            }
            "--list-scripts" | "-l" => {
                if settings.log_mode {
                    let _ = commands::log_message("INFO", "Listing available scripts");
                }
                let temp_dir =
                    TempDir::new().map_err(|e| format!("Failed to create temp directory: {e}"))?;
                let temp_path = temp_dir.path();
                crate::extract_scripts(temp_path)?;
                let modules_dir = temp_path.join("modules");
                if !modules_dir.exists() || !modules_dir.is_dir() {
                    let error_msg =
                        format!("Modules directory not found at {}", modules_dir.display());
                    if settings.log_mode {
                        let _ = commands::log_message("ERROR", &error_msg);
                    }
                    return Err(error_msg.into());
                }
                script_list::list_scripts(&modules_dir)
            }
            "--version" | "-v" => {
                let version_str = version::get_current_version();

                if settings.log_mode {
                    let _ = commands::log_message("INFO", &format!("Version query: {version_str}"));
                }

                println!("{version_str}");
                Ok(())
            }
            "--check-update" => {
                if settings.log_mode {
                    let _ = commands::log_message("INFO", "Checking for updates");
                }
                version::check_for_updates().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
            }
            "--update" => {
                if settings.log_mode {
                    let _ = commands::log_message("INFO", "Running update process");
                }
                commands::update().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
            }
            "--uninstall" => {
                if settings.log_mode {
                    let _ = commands::log_message("INFO", "Running uninstall process");
                }
                commands::uninstall().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
            }
            "--no-preview" => {
                settings.show_preview = false;
                if settings.log_mode {
                    let _ = commands::log_message("INFO", "Preview mode disabled");
                }
                if args.len() > 2 {
                    let remaining_args = args[2..].to_vec();
                    process_remaining_args(remaining_args, settings)
                } else {
                    crate::run_tui(settings)
                }
            }
            "--log" => {
                if args.len() > 2 {
                    let remaining_args = args[2..].to_vec();
                    process_remaining_args(remaining_args, settings)
                } else {
                    crate::run_tui(settings)
                }
            }
            "--no-cleanup" => {
                if args.len() > 2 {
                    let remaining_args = args[2..].to_vec();
                    process_remaining_args(remaining_args, settings)
                } else {
                    crate::run_tui(settings)
                }
            }
            _ => {
                let error_msg =
                    format!("Error: Unknown option '{}'. Use --help for usage.", args[1]);
                if settings.log_mode {
                    let _ = commands::log_message("ERROR", &error_msg);
                }
                eprintln!("{error_msg}");
                Ok(())
            }
        }
    } else {
        crate::run_tui(settings)
    }
}

fn process_remaining_args(
    args: Vec<String>,
    settings: Settings,
) -> Result<(), Box<dyn std::error::Error>> {
    if args.is_empty() {
        return crate::run_tui(settings);
    }

    match args[0].as_str() {
        "--version" | "-v" => {
            let version_str = version::get_current_version();

            if settings.log_mode {
                let _ = commands::log_message("INFO", &format!("Version query: {version_str}"));
            }

            println!("{version_str}");
            Ok(())
        }
        "--check-update" => {
            if settings.log_mode {
                let _ = commands::log_message("INFO", "Checking for updates");
            }
            version::check_for_updates().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
        }
        "--update" => {
            if settings.log_mode {
                let _ = commands::log_message("INFO", "Running update process");
            }
            commands::update().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
        }
        "--uninstall" => {
            if settings.log_mode {
                let _ = commands::log_message("INFO", "Running uninstall process");
            }
            commands::uninstall().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
        }
        _ => {
            let error_msg = format!("Error: Unknown option '{}'. Use --help for usage.", args[0]);
            if settings.log_mode {
                let _ = commands::log_message("ERROR", &error_msg);
            }
            eprintln!("{error_msg}");
            Ok(())
        }
    }
}
