use crate::error::{CarchError, Result};
use serde::Deserialize;

#[derive(Deserialize)]
struct Release {
    tag_name: String,
}

pub fn get_current_version() -> String {
    let version = env!("CARGO_PKG_VERSION");
    format!("Carch version {version}")
}

pub fn get_latest_version() -> Result<String> {
    let client = reqwest::blocking::Client::builder().user_agent("carch").build()?;
    let response =
        client.get("https://api.github.com/repos/harilvfs/carch/releases/latest").send()?;

    if !response.status().is_success() {
        return Err(CarchError::Command("Failed to fetch latest version information".to_string()));
    }

    let release: Release = response.json()?;
    let version = release.tag_name.trim_start_matches('v').to_string();
    Ok(version)
}
