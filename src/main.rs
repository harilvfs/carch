use crate::error::{CarchError, Result};
use crate::ui::render::run_ui_with_options;
use crate::ui::state::UiOptions;
use args::Settings;
use include_dir::{Dir, include_dir};
use log::{error, info};
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use tempfile::TempDir;

mod args;
mod commands;
mod error;
mod ui;
mod version;

static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/modules");

const EXECUTABLE_MODE: u32 = 0o755;

fn main() -> Result<()> {
    args::parse_args()
}

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

pub fn extract_scripts(temp_path: &Path) -> Result<()> {
    let modules_dir = temp_path.join("modules");
    fs::create_dir_all(&modules_dir)
        .map_err(|e| CarchError::CreateDir(modules_dir.display().to_string(), e))?;

    extract_dir_recursive(&EMBEDDED_DIR, &modules_dir)?;

    let preview_link = temp_path.join("preview_scripts");
    if fs::remove_file(&preview_link).is_err() {
        // ignore if the link doesn't exist yet
    }

    std::os::unix::fs::symlink(&modules_dir, &preview_link)
        .map_err(|e| CarchError::Symlink(e.to_string()))?;

    Ok(())
}

fn extract_dir_recursive(dir: &Dir, target_path: &Path) -> Result<()> {
    fs::create_dir_all(target_path)
        .map_err(|e| CarchError::CreateDir(target_path.display().to_string(), e))?;

    for entry in dir.entries() {
        match entry {
            include_dir::DirEntry::File(file) => {
                let file_path = target_path.join(file.path().file_name().unwrap_or_default());
                fs::write(&file_path, file.contents())
                    .map_err(|e| CarchError::WriteFile(file_path.display().to_string(), e))?;

                if file_path.extension().is_some_and(|ext| ext == "sh") {
                    set_executable(&file_path)?;
                }
            }
            include_dir::DirEntry::Dir(subdir) => {
                let subdir_path = target_path.join(subdir.path().file_name().unwrap_or_default());
                extract_dir_recursive(subdir, &subdir_path)?;
            }
        }
    }

    Ok(())
}

fn set_executable(path: &Path) -> Result<()> {
    let mut perms = fs::metadata(path)
        .map_err(|e| CarchError::Metadata(path.display().to_string(), e))?
        .permissions();
    perms.set_mode(EXECUTABLE_MODE);
    fs::set_permissions(path, perms)
        .map_err(|e| CarchError::SetPermissions(path.display().to_string(), e))?;
    Ok(())
}
