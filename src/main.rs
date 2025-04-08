use include_dir::{Dir, include_dir};
use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::Command;
use tempfile::TempDir;

static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/scripts");

const EXECUTABLE_MODE: u32 = 0o755;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let temp_dir = TempDir::new().map_err(|e| format!("Failed to create temp directory: {}", e))?;
    let temp_path = temp_dir.path();

    extract_and_set_permissions(temp_path)?;

    let args = env::args().skip(1);

    let script_path = temp_path.join("carch");
    let status = Command::new(&script_path)
        .args(args)
        .current_dir(temp_path)
        .status()
        .map_err(|e| format!("Failed to execute {}: {}", script_path.display(), e))?;

    std::process::exit(status.code().unwrap_or(1));
}

fn extract_and_set_permissions(temp_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    EMBEDDED_DIR
        .extract(temp_path)
        .map_err(|e| format!("Failed to extract embedded files: {}", e))?;

    let main_script_path = temp_path.join("carch");
    set_executable(&main_script_path)?;

    let scripts_dir = temp_path.join("scripts");
    if scripts_dir.exists() && scripts_dir.is_dir() {
        for entry in fs::read_dir(&scripts_dir)
            .map_err(|e| format!("Failed to read scripts directory: {}", e))?
            .flatten()
        {
            let path = entry.path();
            if path.is_file() && path.extension().is_some_and(|ext| ext == "sh") {
                set_executable(&path)?;
            }
        }
    }

    let preview_link = temp_path.join("preview_scripts");
    if fs::remove_file(&preview_link).is_err() {
    
    }
    std::os::unix::fs::symlink(&scripts_dir, &preview_link)
        .map_err(|e| format!("Failed to create preview symlink: {}", e))?;

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

fn set_executable(path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let mut perms = fs::metadata(path)
        .map_err(|e| format!("Failed to get metadata for {}: {}", path.display(), e))?
        .permissions();
    perms.set_mode(EXECUTABLE_MODE);
    fs::set_permissions(path, perms)
        .map_err(|e| format!("Failed to set permissions for {}: {}", path.display(), e))?;
    Ok(())
}
