use include_dir::{Dir, include_dir};
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::atomic::{AtomicBool, Ordering};
use std::{fs, io};
use tempfile::TempDir;

mod args;
mod commands;
mod display;
mod script_list;
mod ui;
mod version;

static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/modules");
const EXECUTABLE_MODE: u32 = 0o755;

static CLEANUP_NEEDED: AtomicBool = AtomicBool::new(false);

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let settings = args::Settings::default();
    if settings.cleanup_cache {
        setup_cleanup_handlers(settings.log_mode);
    }

    let result = args::parse_args();

    if settings.cleanup_cache && CLEANUP_NEEDED.load(Ordering::SeqCst) {
        cleanup_cache_dir(settings.log_mode);
    }

    result
}

pub fn run_tui(settings: args::Settings) -> Result<(), Box<dyn std::error::Error>> {
    if settings.log_mode {
        let _ = commands::log_message("INFO", "Starting TUI application");
    }

    let scripts_path = get_scripts_path(settings.log_mode)?;

    if settings.cleanup_cache {
        CLEANUP_NEEDED.store(true, Ordering::SeqCst);
    }

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
        ui::UiOptions { show_preview: settings.show_preview, log_mode: settings.log_mode };

    if settings.log_mode {
        let _ = commands::log_message(
            "INFO",
            &format!(
                "TUI initialized with settings: show_preview={}, log_mode={}",
                settings.show_preview, settings.log_mode
            ),
        );
    }

    let result = ui::run_ui_with_options(
        &modules_dir,
        |script_path| {
            if settings.log_mode {
                let _ = commands::log_message(
                    "INFO",
                    &format!("Running script: {}", script_path.display()),
                );
            }

            let result = Command::new("bash")
                .arg(script_path)
                .status()
                .map_err(|e| io::Error::other(format!("Failed to execute script: {e}")));

            if settings.log_mode {
                match &result {
                    Ok(status) => {
                        let _ = commands::log_message(
                            "INFO",
                            &format!(
                                "Script {} completed with exit code: {}",
                                script_path.display(),
                                status.code().map_or(String::from("unknown"), |c| c.to_string())
                            ),
                        );
                    }
                    Err(e) => {
                        let _ = commands::log_message(
                            "ERROR",
                            &format!("Script {} failed with error: {}", script_path.display(), e),
                        );
                    }
                }
            }

            result?;

            println!("Press Enter to return...");
            let mut buffer = String::new();
            io::stdin().read_line(&mut buffer)?;

            Ok(())
        },
        ui_options,
    );

    if settings.log_mode {
        let _ = commands::log_message("INFO", "Carch application exiting normally");
    }

    result.map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
}

fn get_scripts_path(log_mode: bool) -> Result<PathBuf, Box<dyn std::error::Error>> {
    if let Some(cache_dir) = get_cache_dir() {
        let carch_cache = cache_dir.join("carch");
        let modules_dir = carch_cache.join("modules");

        if !carch_cache.exists() {
            if log_mode {
                let _ = commands::log_message(
                    "INFO",
                    &format!("Creating cache directory at {}", carch_cache.display()),
                );
            }
            fs::create_dir_all(&carch_cache)
                .map_err(|e| format!("Failed to create cache directory: {e}"))?;
        }

        let should_extract = !modules_dir.exists() || scripts_need_update(&modules_dir);

        if should_extract {
            if log_mode {
                let _ = commands::log_message("INFO", "Extracting scripts to cache directory");
            }
            extract_scripts(&carch_cache)?;
        } else if log_mode {
            let _ = commands::log_message("INFO", "Using existing cached scripts");
        }

        return Ok(carch_cache);
    }

    if log_mode {
        let _ = commands::log_message(
            "INFO",
            "Cache directory not available, using temporary directory",
        );
    }

    let temp_dir = TempDir::new().map_err(|e| {
        let error_msg = format!("Failed to create temp directory: {e}");
        if log_mode {
            let _ = commands::log_message("ERROR", &error_msg);
        }
        error_msg
    })?;

    let temp_path = temp_dir.path().to_path_buf();

    std::mem::forget(temp_dir);

    extract_scripts(&temp_path)?;

    Ok(temp_path)
}

fn get_cache_dir() -> Option<PathBuf> {
    dirs::cache_dir()
}

fn scripts_need_update(modules_dir: &Path) -> bool {
    let version_file = modules_dir.join(".version");

    if !version_file.exists() {
        return true;
    }

    let stored_version = match fs::read_to_string(&version_file) {
        Ok(content) => match content.trim().parse::<u64>() {
            Ok(timestamp) => timestamp,
            Err(_) => return true,
        },
        Err(_) => return true,
    };

    let current_version = version::get_current_version();

    format!("{stored_version}") != current_version
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

    let version_file = modules_dir.join(".version");
    let current_version = version::get_current_version();
    fs::write(&version_file, current_version)
        .map_err(|e| format!("Failed to write version file: {e}"))?;

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

fn cleanup_cache_dir(log_mode: bool) {
    if let Some(cache_dir) = get_cache_dir() {
        let carch_cache = cache_dir.join("carch");

        if carch_cache.exists() {
            if log_mode {
                let _ = commands::log_message(
                    "INFO",
                    &format!("Cleaning up cache directory at {}", carch_cache.display()),
                );
            }

            if let Err(e) = fs::remove_dir_all(&carch_cache) {
                if log_mode {
                    let _ = commands::log_message(
                        "ERROR",
                        &format!("Failed to clean up cache directory: {e}"),
                    );
                }
                eprintln!("Warning: Failed to clean up cache directory: {e}");
            } else if log_mode {
                let _ = commands::log_message("INFO", "Cache directory cleaned up successfully");
            }
        }
    }
}

fn setup_cleanup_handlers(log_mode: bool) {
    let log_mode_copy = log_mode;

    if let Err(e) = ctrlc::set_handler(move || {
        if CLEANUP_NEEDED.load(Ordering::SeqCst) {
            cleanup_cache_dir(log_mode_copy);
        }
        std::process::exit(0);
    }) {
        if log_mode {
            let _ = commands::log_message("ERROR", &format!("Failed to set cleanup handler: {e}"));
        }
        eprintln!("Warning: Failed to set up cleanup handler: {e}");
    }
}
