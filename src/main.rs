use include_dir::{Dir, include_dir};
use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::Command;
use tempfile::TempDir;

// Store all our scripts in the binary
static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/scripts");

// Linux permission mode for executable files (rwxr-xr-x)
const EXECUTABLE_MODE: u32 = 0o755;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Create a temp folder that will delete itself when the program ends
    let temp_dir = TempDir::new().map_err(|e| format!("Failed to create temp directory: {}", e))?;
    let temp_path = temp_dir.path();

    // Extract our scripts and make them runnable
    extract_and_set_permissions(temp_path)?;

    // Get any arguments the user passed (skip the first one which is the program name)
    let args = env::args().skip(1);

    // Run our main script with the user's arguments
    let script_path = temp_path.join("carch");
    let status = Command::new(&script_path)
        .args(args)
        .current_dir(temp_path) // Run from the temp folder so scripts can find each other
        .status()
        .map_err(|e| format!("Failed to execute {}: {}", script_path.display(), e))?;

    // Exit with the same code as our script (or 1 if something weird happened)
    std::process::exit(status.code().unwrap_or(1));
}

fn extract_and_set_permissions(temp_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    // Extract all files from our embedded directory
    EMBEDDED_DIR
        .extract(temp_path)
        .map_err(|e| format!("Failed to extract embedded files: {}", e))?;

    // Make the main script executable
    let main_script_path = temp_path.join("carch");
    set_executable(&main_script_path)?;

    // Find all .sh scripts and make them executable too
    let scripts_dir = temp_path.join("scripts");
    if scripts_dir.exists() && scripts_dir.is_dir() {
        // Look at each file in the scripts folder
        for entry in fs::read_dir(&scripts_dir)
            .map_err(|e| format!("Failed to read scripts directory: {}", e))?
            .flatten()
        // Skip any entries we can't read
        {
            let path = entry.path();
            // If it's a .sh file, make it executable
            if path.is_file() && path.extension().is_some_and(|ext| ext == "sh") {
                set_executable(&path)?;
            }
        }
    }

    // Create a shortcut to the scripts folder for the fzf preview feature
    let preview_link = temp_path.join("preview_scripts");
    if fs::remove_file(&preview_link).is_err() {
        // Ignore if the link doesn't exist yet
    }
    std::os::unix::fs::symlink(&scripts_dir, &preview_link)
        .map_err(|e| format!("Failed to create preview symlink: {}", e))?;

    // Create a helper file that scripts can source to know where stuff is
    let env_file = temp_path.join("carch_env.sh");
    let env_content = format!(
        "#!/bin/bash\n\
         export CARCH_TEMP_DIR=\"{}\"\n\
         export CARCH_SCRIPTS_DIR=\"{}/scripts\"\n",
        temp_path.display(),
        temp_path.display()
    );
    fs::write(&env_file, env_content)
        .map_err(|e| format!("Failed to write environment file: {}", e))?;
    set_executable(&env_file)?;

    Ok(())
}

// Make a file executable (like chmod +x)
fn set_executable(path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let mut perms = fs::metadata(path)
        .map_err(|e| format!("Failed to get metadata for {}: {}", path.display(), e))?
        .permissions();
    perms.set_mode(EXECUTABLE_MODE);
    fs::set_permissions(path, perms)
        .map_err(|e| format!("Failed to set permissions for {}: {}", path.display(), e))?;
    Ok(())
}
