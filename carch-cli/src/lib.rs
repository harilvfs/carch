use carch_core::error::{CarchError, Result};
use carch_core::extract_scripts;
use carch_core::ui::render::run_ui_with_options;
use carch_core::ui::state::UiOptions;
use log::{error, info};
use tempfile::TempDir;

pub mod args;
pub mod commands;

use crate::args::Settings;

pub fn run_tui(settings: Settings) -> Result<()> {
    if settings.log_mode {
        info!("Starting TUI application");
    }

    let temp_dir = TempDir::new().map_err(|e| CarchError::TempDir(e.to_string()))?;
    let scripts_path = temp_dir.path();
    extract_scripts(scripts_path)?;

    if settings.log_mode {
        info!("Using scripts directory: {}", scripts_path.display());
    }

    let modules_dir = scripts_path.join("modules");
    if !modules_dir.exists() || !modules_dir.is_dir() {
        let error_msg = format!("Modules directory not found at {}", modules_dir.display());
        error!("{error_msg}");
        return Err(CarchError::ModulesDirNotFound(error_msg));
    }

    let ui_options = UiOptions {
        log_mode:     settings.log_mode,
        theme:        settings.theme,
        theme_locked: settings.theme_locked,
        is_root:      std::env::var("USER").unwrap_or_default() == "root",
    };

    if settings.log_mode {
        info!("TUI initialized with settings: log_mode={}", settings.log_mode);
    }

    let result = run_ui_with_options(&modules_dir, ui_options);

    if settings.log_mode {
        info!("Carch application exiting normally");
    }

    result
}
