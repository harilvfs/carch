use crate::ui::render::run_ui_with_options;
use crate::ui::state::UiOptions;
use include_dir::{Dir, include_dir};
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use tempfile::TempDir;

mod args;
mod commands;
mod ui;
mod version;

static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/modules");
const EXECUTABLE_MODE: u32 = 0o755;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    args::parse_args()
}

pub fn run_tui(settings: args::Settings) -> Result<(), Box<dyn std::error::Error>> {
    if settings.log_mode {
        let _ = commands::log_message("INFO", "Starting TUI application");
    }

    let temp_dir = TempDir::new().map_err(|e| {
        let error_msg = format!("Failed to create temp directory: {e}");
        if settings.log_mode {
            let _ = commands::log_message("ERROR", &error_msg);
        }
        error_msg
    })?;

    let scripts_path = temp_dir.path();
    extract_scripts(scripts_path)?;

    if settings.log_mode {
        let _ = commands::log_message(
            "INFO",
            &format!("Using scripts directory: {}", scripts_path.display()),
        );
    }

    let modules_dir = scripts_path.join("modules");
    if !modules_dir.exists() || !modules_dir.is_dir() {
        let error_msg = format!("Modules directory not found at {}", modules_dir.display());
        if settings.log_mode {
            let _ = commands::log_message("ERROR", &error_msg);
        }
        return Err(error_msg.into());
    }

    let ui_options =
        UiOptions { show_preview: settings.show_preview, log_mode: settings.log_mode };

    if settings.log_mode {
        let _ = commands::log_message(
            "INFO",
            &format!(
                "TUI initialized with settings: show_preview={}, log_mode={}",
                settings.show_preview, settings.log_mode
            ),
        );
    }

    let result = run_ui_with_options(&modules_dir, ui_options);

    if settings.log_mode {
        let _ = commands::log_message("INFO", "Carch application exiting normally");
    }

    result.map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
}

pub fn extract_scripts(temp_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let modules_dir = temp_path.join("modules");
    fs::create_dir_all(&modules_dir)
        .map_err(|e| format!("Failed to create modules directory: {e}"))?;

    extract_dir_recursive(&EMBEDDED_DIR, &modules_dir)?;

    let preview_link = temp_path.join("preview_scripts");
    if fs::remove_file(&preview_link).is_err() {
        // ignore if the link doesn't exist yet
    }

    std::os::unix::fs::symlink(&modules_dir, &preview_link)
        .map_err(|e| format!("Failed to create preview symlink: {e}"))?;

    Ok(())
}

fn extract_dir_recursive(
    dir: &include_dir::Dir,
    target_path: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    fs::create_dir_all(target_path)
        .map_err(|e| format!("Failed to create directory {}: {}", target_path.display(), e))?;

    for entry in dir.entries() {
        match entry {
            include_dir::DirEntry::File(file) => {
                let file_path = target_path.join(file.path().file_name().unwrap_or_default());
                fs::write(&file_path, file.contents())
                    .map_err(|e| format!("Failed to write file {}: {}", file_path.display(), e))?;

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

fn set_executable(path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let mut perms = fs::metadata(path)
        .map_err(|e| format!("Failed to get metadata for {}: {}", path.display(), e))?
        .permissions();
    perms.set_mode(EXECUTABLE_MODE);
    fs::set_permissions(path, perms)
        .map_err(|e| format!("Failed to set permissions for {}: {}", path.display(), e))?;
    Ok(())
}
