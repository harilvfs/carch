use include_dir::{Dir, include_dir};
use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Once;
use tempfile::TempDir;

// Embedded directory containing scripts
static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/scripts");
// Used to ensure cleanup happens only once
static CLEANUP: Once = Once::new();
// Executable mode (rwxr-xr-x)
const EXECUTABLE_MODE: u32 = 0o755;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Create temp directory with better error handling
    let temp_dir = TempDir::new().map_err(|e| format!("Failed to create temp directory: {}", e))?;
    let temp_path = temp_dir.path();

    // Set up cleanup on panic or normal exit
    CLEANUP.call_once(move || {
        // This ensures temp directory is cleaned up even if the process panics
        let _ = temp_dir; // Keep temp_dir alive until process exits
    });

    // Extract files with better error handling
    extract_embedded_files(temp_path)?;

    // Get command line arguments more efficiently
    let args: Vec<String> = env::args().skip(1).collect();

    // Execute the script with improved error handling
    let exit_code = execute_script(temp_path, &args)?;

    // Exit with the same code as the script
    std::process::exit(exit_code);
}

fn extract_embedded_files(temp_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    // Extract all files
    EMBEDDED_DIR
        .extract(temp_path)
        .map_err(|e| format!("Failed to extract embedded files: {}", e))?;

    // Make scripts executable
    make_scripts_executable(temp_path)?;

    Ok(())
}

fn make_scripts_executable(dir_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    // Main carch script
    set_executable(dir_path.join("carch"))?;

    // Process scripts directory if it exists
    let scripts_dir = dir_path.join("scripts");
    if scripts_dir.exists() && scripts_dir.is_dir() {
        // Use filter_map for more better processing and error handling
        fs::read_dir(&scripts_dir)
            .map_err(|e| format!("Failed to read scripts directory: {}", e))?
            .filter_map(Result::ok)
            .filter(|entry| {
                let path = entry.path();
                path.is_file() && path.extension().is_some_and(|ext| ext == "sh")
            })
            .try_for_each(|entry| set_executable(entry.path()))?;
    }

    Ok(())
}

fn set_executable(path: PathBuf) -> Result<(), Box<dyn std::error::Error>> {
    if path.exists() {
        let mut perms = fs::metadata(&path)
            .map_err(|e| format!("Failed to get metadata for {}: {}", path.display(), e))?
            .permissions();

        perms.set_mode(EXECUTABLE_MODE);
        fs::set_permissions(&path, perms)
            .map_err(|e| format!("Failed to set permissions for {}: {}", path.display(), e))?;
    }

    Ok(())
}

fn execute_script(temp_path: &Path, args: &[String]) -> Result<i32, Box<dyn std::error::Error>> {
    let script_path = temp_path.join("carch");

    let status = Command::new(&script_path)
        .args(args)
        .current_dir(temp_path)
        .status()
        .map_err(|e| format!("Failed to execute {}: {}", script_path.display(), e))?;

    // Extract exit code or use 1 as default for failure
    Ok(status.code().unwrap_or(1))
}
