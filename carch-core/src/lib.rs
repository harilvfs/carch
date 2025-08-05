use crate::error::{CarchError, Result};
use include_dir::{Dir, include_dir};
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;

pub mod error;
pub mod ui;
pub mod version;

static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/modules");

const EXECUTABLE_MODE: u32 = 0o755;

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
