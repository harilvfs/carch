use crate::error::{CarchError, Result};
use serde::Deserialize;

#[derive(Deserialize)]
struct Release {
    tag_name: String,
}

/// The raw `Cargo.toml` version (no leading `v`).
#[must_use]
pub fn current_version() -> &'static str {
    env!("CARGO_PKG_VERSION")
}

/// User-facing version string with the `v` prefix.
#[must_use]
pub fn get_current_version() -> String {
    format!("v{}", current_version())
}

/// Fetch the latest release tag (with the leading `v` stripped).
pub fn get_latest_version() -> Result<String> {
    let client = reqwest::blocking::Client::builder().user_agent("carch").build()?;
    let response =
        client.get("https://api.github.com/repos/harilvfs/carch/releases/latest").send()?;

    if !response.status().is_success() {
        return Err(CarchError::Command("Failed to fetch latest version information".to_string()));
    }

    let release: Release = response.json()?;
    Ok(release.tag_name.trim_start_matches('v').to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn current_version_is_nonempty() {
        assert!(!current_version().is_empty());
    }

    #[test]
    fn current_version_is_valid_semver_shape() {
        // Either X.Y.Z or X.Y.Z-pre.N
        let v = current_version();
        let first = v.split('.').next().unwrap_or("");
        assert!(first.chars().all(|c| c.is_ascii_digit()), "expected digit prefix, got {v:?}");
    }

    #[test]
    fn get_current_version_has_v_prefix() {
        let v = get_current_version();
        assert!(v.starts_with('v'), "expected 'v' prefix, got {v:?}");
        // Stripping the prefix should give us back current_version
        assert_eq!(&v[1..], current_version());
    }
}
