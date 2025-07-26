use thiserror::Error;

/// defines all the possible errors that can happen in the app
#[derive(Debug, Error)]
pub enum CarchError {
    /// for when something goes wrong with reading or writing files
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    /// for when a web request fails
    #[error("Request error: {0}")]
    Reqwest(#[from] reqwest::Error),
    /// for when a command that was run fails
    #[error("Command failed: {0}")]
    Command(String),
    /// for when we can't find an rpm file in a release
    #[error("No RPM found in the latest release")]
    NoRpmFound,
    /// for when the package manager isn't supported
    #[error("Unsupported package manager")]
    UnsupportedPackageManager,
    /// for when we can't find the user's home folder
    #[error("Home directory not found")]
    HomeDirNotFound,
    /// for when we can't make a temporary folder
    #[error("Failed to create temp directory: {0}")]
    TempDir(String),
    /// for when we can't find the `modules` folder
    #[error("Modules directory not found at {0}")]
    ModulesDirNotFound(String),
    /// for when we can't make the preview symlink
    #[error("Failed to create preview symlink: {0}")]
    Symlink(String),
    /// for when we can't make a folder
    #[error("Failed to create directory {0}: {1}")]
    CreateDir(String, std::io::Error),
    /// for when we can't write to a file
    #[error("Failed to write file {0}: {1}")]
    WriteFile(String, std::io::Error),
    /// for when we can't get info about a file
    #[error("Failed to get metadata for {0}: {1}")]
    Metadata(String, std::io::Error),
    /// for when we can't set the permissions for a file
    #[error("Failed to set permissions for {0}: {1}")]
    SetPermissions(String, std::io::Error),
}

pub type Result<T> = std::result::Result<T, CarchError>;
