use include_dir::{include_dir, Dir};
use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::Command;
use tempfile::TempDir;

static EMBEDDED_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/scripts");

fn main() {
    let temp_dir = TempDir::new().expect("Failed to create temp directory");
    let temp_path = temp_dir.path();

    extract_embedded_files(temp_path);

    let args: Vec<String> = env::args().skip(1).collect();

    let mut cmd = Command::new(temp_path.join("carch"));
    let status = cmd
        .args(args)
        .current_dir(temp_path)
        .status()
        .expect("Failed to execute carch script");

    std::process::exit(status.code().unwrap_or(1));
}

fn extract_embedded_files(temp_path: &Path) {
    EMBEDDED_DIR
        .extract(temp_path)
        .expect("Failed to extract embedded files");

    make_scripts_executable(temp_path);
}

fn make_scripts_executable(dir_path: &Path) {
    let carch_path = dir_path.join("carch");
    if carch_path.exists() {
        let mut perms = fs::metadata(&carch_path)
            .expect("Failed to get file metadata")
            .permissions();
        perms.set_mode(0o755);
        fs::set_permissions(&carch_path, perms).expect("Failed to set permissions");
    }

    let scripts_dir = dir_path.join("scripts");
    if scripts_dir.exists() && scripts_dir.is_dir() {
        for entry in fs::read_dir(&scripts_dir).expect("Failed to read scripts directory") {
            if let Ok(entry) = entry {
                let path = entry.path();
                if path.is_file() && path.extension().map_or(false, |ext| ext == "sh") {
                    let mut perms = fs::metadata(&path)
                        .expect("Failed to get file metadata")
                        .permissions();
                    perms.set_mode(0o755);
                    fs::set_permissions(&path, perms).expect("Failed to set permissions");
                }
            }
        }
    }
}
