use thiserror::Error;

#[derive(Debug, Error)]
pub enum CarchError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Request error: {0}")]
    Reqwest(#[from] reqwest::Error),
    #[error("Command failed: {0}")]
    Command(String),
    #[error("No RPM found in the latest release")]
    NoRpmFound,
    #[error("Unsupported package manager")]
    UnsupportedPackageManager,
    #[error("Home directory not found")]
    HomeDirNotFound,
    #[error("Failed to create temp directory: {0}")]
    TempDir(String),
    #[error("Modules directory not found at {0}")]
    ModulesDirNotFound(String),
    #[error("Failed to create preview symlink: {0}")]
    Symlink(String),
    #[error("Failed to create directory {0}: {1}")]
    CreateDir(String, std::io::Error),
    #[error("Failed to write file {0}: {1}")]
    WriteFile(String, std::io::Error),
    #[error("Failed to get metadata for {0}: {1}")]
    Metadata(String, std::io::Error),
    #[error("Failed to set permissions for {0}: {1}")]
    SetPermissions(String, std::io::Error),
}

pub type Result<T> = std::result::Result<T, CarchError>;
