//! Persistent CLI state at `~/.config/carch/state.toml`.

use carch_core::error::{CarchError, Result};
use std::path::PathBuf;
use std::{env, fs};

const STATE_FILE_NAME: &str = "state.toml";

fn state_path() -> Result<PathBuf> {
    let home = env::var("HOME").map_err(|_| CarchError::HomeDirNotFound)?;
    Ok(PathBuf::from(home).join(".config/carch").join(STATE_FILE_NAME))
}

fn ensure_parent_dir(path: &std::path::Path) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| CarchError::CreateDir(parent.display().to_string(), e))?;
    }
    Ok(())
}

pub fn save_favorite_theme(theme: &str) -> Result<()> {
    if theme.is_empty() {
        return Err(CarchError::Command("Theme name must not be empty".to_string()));
    }
    let path = state_path()?;
    ensure_parent_dir(&path)?;
    let contents = format!("theme = \"{}\"\n", escape_toml_string(theme));
    let tmp = path.with_extension("toml.tmp");
    fs::write(&tmp, contents).map_err(|e| CarchError::WriteFile(tmp.display().to_string(), e))?;
    fs::rename(&tmp, &path).map_err(|e| CarchError::WriteFile(path.display().to_string(), e))?;
    Ok(())
}

/// Returns the saved favorite theme, or `None` if it isn't set.
pub fn load_favorite_theme() -> Option<String> {
    let path = state_path().ok()?;
    let content = fs::read_to_string(&path).ok()?;
    let table: toml::Table = content.parse().ok()?;
    table.get("theme")?.as_str().map(str::to_string)
}

pub fn clear_favorite_theme() -> Result<bool> {
    let path = state_path()?;
    match fs::remove_file(&path) {
        Ok(()) => Ok(true),
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(false),
        Err(e) => Err(CarchError::WriteFile(path.display().to_string(), e)),
    }
}

fn escape_toml_string(s: &str) -> String {
    s.replace('\\', "\\\\")
        .replace('"', "\\\"")
        .replace('\n', "\\n")
        .replace('\r', "\\r")
        .replace('\t', "\\t")
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::{Mutex, PoisonError};

    static HOME_LOCK: Mutex<()> = Mutex::new(());

    struct ScopedHome {
        _guard: std::sync::MutexGuard<'static, ()>,
        prev:   Option<String>,
        tmp:    PathBuf,
    }

    impl ScopedHome {
        fn new() -> Self {
            let guard = HOME_LOCK.lock().unwrap_or_else(PoisonError::into_inner);
            let tmp = std::env::temp_dir().join(format!(
                "carch_state_test_{}_{}",
                std::process::id(),
                std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_nanos()
            ));
            std::fs::create_dir_all(&tmp).unwrap();
            let prev = std::env::var("HOME").ok();
            // SAFETY: serialized by HOME_LOCK above.
            unsafe {
                std::env::set_var("HOME", &tmp);
            }
            ScopedHome { _guard: guard, prev, tmp }
        }
    }

    impl Drop for ScopedHome {
        fn drop(&mut self) {
            match &self.prev {
                Some(p) => unsafe {
                    std::env::set_var("HOME", p);
                },
                None => unsafe {
                    std::env::remove_var("HOME");
                },
            }
            let _ = std::fs::remove_dir_all(&self.tmp);
        }
    }

    #[test]
    fn save_then_load_roundtrip() {
        let _h = ScopedHome::new();
        save_favorite_theme("dracula").unwrap();
        assert_eq!(load_favorite_theme().as_deref(), Some("dracula"));
    }

    #[test]
    fn load_returns_none_when_no_state_file() {
        let _h = ScopedHome::new();
        assert_eq!(load_favorite_theme(), None);
    }

    #[test]
    fn save_rejects_empty_theme() {
        let _h = ScopedHome::new();
        let err = save_favorite_theme("").unwrap_err();
        assert!(matches!(err, CarchError::Command(_)));
    }

    #[test]
    fn save_escapes_special_chars_in_theme_name() {
        let _h = ScopedHome::new();
        save_favorite_theme(r#"a"b"#).unwrap();
        assert_eq!(load_favorite_theme().as_deref(), Some(r#"a"b"#));
    }

    #[test]
    fn clear_removes_state_file() {
        let _h = ScopedHome::new();
        save_favorite_theme("nord").unwrap();
        assert!(clear_favorite_theme().unwrap());
        assert_eq!(load_favorite_theme(), None);
    }

    #[test]
    fn clear_returns_false_when_no_file() {
        let _h = ScopedHome::new();
        assert!(!clear_favorite_theme().unwrap());
    }

    #[test]
    fn save_overwrites_previous_value() {
        let _h = ScopedHome::new();
        save_favorite_theme("dracula").unwrap();
        save_favorite_theme("gruvbox").unwrap();
        assert_eq!(load_favorite_theme().as_deref(), Some("gruvbox"));
    }

    #[test]
    fn state_file_path_is_under_config_carch() {
        let _h = ScopedHome::new();
        save_favorite_theme("nord").unwrap();
        let path = state_path().unwrap();
        assert!(path.ends_with(".config/carch/state.toml"));
        assert!(path.exists());
    }

    #[test]
    fn escape_handles_special_chars() {
        assert_eq!(escape_toml_string("plain"), "plain");
        assert_eq!(escape_toml_string(r#"a"b"#), r#"a\"b"#);
        assert_eq!(escape_toml_string("a\\b"), "a\\\\b");
        assert_eq!(escape_toml_string("a\nb"), "a\\nb");
    }
}
