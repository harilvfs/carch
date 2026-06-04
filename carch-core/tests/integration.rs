//! Integration tests for the TUI app. No real terminal required.

use std::path::PathBuf;

use carch_core::ui::state::{App, AppMode, FocusedPanel, UiOptions};
use carch_core::ui::theme::Theme;
use carch_core::{extract_scripts, is_running_as_root};
use crossterm::event::{KeyCode, KeyEvent, KeyEventKind, KeyModifiers};
use tempfile::TempDir;

fn key(code: KeyCode) -> KeyEvent {
    KeyEvent {
        code,
        modifiers: KeyModifiers::NONE,
        kind: KeyEventKind::Press,
        state: crossterm::event::KeyEventState::NONE,
    }
}

fn make_app(modules_dir: &std::path::Path) -> App {
    let app = App::new(&UiOptions {
        log_mode:     false,
        theme:        "catppuccin-mocha".to_string(),
        theme_locked: false,
        is_root:      false,
    });
    let mut app = app;
    app.modules_dir = modules_dir.to_path_buf();
    app.load_scripts(modules_dir).expect("load embedded scripts");
    app
}

struct Fixture {
    _tmp:        TempDir,
    #[allow(dead_code)]
    modules_dir: PathBuf,
    app:         App,
}

fn fixture() -> Fixture {
    let tmp = TempDir::new().expect("temp dir");
    extract_scripts(tmp.path()).expect("extract embedded modules");
    let modules_dir = tmp.path().join("modules");
    let app = make_app(&modules_dir);
    Fixture { _tmp: tmp, modules_dir, app }
}

#[test]
fn extract_scripts_populates_modules() {
    let tmp = TempDir::new().unwrap();
    extract_scripts(tmp.path()).unwrap();

    let modules_dir = tmp.path().join("modules");
    assert!(modules_dir.is_dir(), "modules/ should be created");

    // At least one category and one .sh file should be extracted.
    let mut found_script = false;
    for entry in std::fs::read_dir(&modules_dir).unwrap() {
        let entry = entry.unwrap();
        if entry.path().is_dir()
            && let Ok(mut sub) = std::fs::read_dir(entry.path())
        {
            while let Some(Ok(ok)) = sub.next() {
                if ok.path().extension().is_some_and(|e| e == "sh") {
                    found_script = true;
                    #[cfg(unix)]
                    {
                        use std::os::unix::fs::PermissionsExt;
                        let mode = ok.path().metadata().unwrap().permissions().mode();
                        assert_ne!(mode & 0o111, 0, "{} should be executable", ok.path().display());
                    }
                }
            }
        }
    }
    assert!(found_script, "expected at least one .sh in extracted modules");
}

#[test]
fn app_starts_in_normal_mode_with_focused_categories() {
    let fx = fixture();
    assert_eq!(fx.app.mode, AppMode::Normal);
    assert_eq!(fx.app.focused_panel, FocusedPanel::Categories);
}

#[test]
fn app_loads_categories_and_scripts_from_embedded_modules() {
    let fx = fixture();
    assert!(!fx.app.categories.items.is_empty(), "categories should be loaded");
    assert!(!fx.app.all_scripts.is_empty(), "scripts map should be loaded");
    let total: usize = fx.app.all_scripts.values().map(|v: &Vec<_>| v.len()).sum();
    assert!(total > 0, "at least one script should be loaded");
}

#[test]
fn switching_focused_panel_with_h_and_l() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    assert_eq!(fx.app.focused_panel, FocusedPanel::Scripts);
    fx.app.handle_key_normal_mode(key(KeyCode::Char('h')));
    assert_eq!(fx.app.focused_panel, FocusedPanel::Categories);
}

#[test]
fn scripts_panel_lists_filtered_by_category() {
    let mut fx = fixture();
    fx.app.categories.state.select(Some(0));
    fx.app.update_script_list();
    let first_cat = fx.app.categories.items[0].clone();
    let expected = fx.app.all_scripts.get(&first_cat).map(Vec::len).unwrap_or(0);
    assert_eq!(fx.app.scripts.items.len(), expected);
    if expected > 0 {
        for item in &fx.app.scripts.items {
            assert_eq!(item.category, first_cat);
        }
    }
}

#[test]
fn j_k_navigates_within_focused_panel() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    let total = fx.app.scripts.items.len();
    if total < 2 {
        return;
    }
    let start = fx.app.scripts.state.selected();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('j')));
    let after = fx.app.scripts.state.selected();
    assert_eq!(after, start.map(|i| i + 1));
    fx.app.handle_key_normal_mode(key(KeyCode::Char('k')));
    assert_eq!(fx.app.scripts.state.selected(), start);
}

#[test]
fn home_and_end_jump_to_top_and_bottom() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    let total = fx.app.scripts.items.len();
    if total < 2 {
        return;
    }
    fx.app.handle_key_normal_mode(key(KeyCode::End));
    assert_eq!(fx.app.scripts.state.selected(), Some(total - 1));
    fx.app.handle_key_normal_mode(key(KeyCode::Home));
    assert_eq!(fx.app.scripts.state.selected(), Some(0));
}

#[test]
fn t_cycles_theme_and_updates_app_theme() {
    let mut fx = fixture();
    let original = fx.app.theme.name.clone();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('t')));
    let new_name = fx.app.theme.name.clone();
    assert_ne!(new_name, original, "theme should have changed");
}

#[test]
fn m_toggles_multi_select_mode() {
    let mut fx = fixture();
    assert!(!fx.app.multi_select.enabled);
    fx.app.handle_key_normal_mode(key(KeyCode::Char('m')));
    assert!(fx.app.multi_select.enabled);
    fx.app.handle_key_normal_mode(key(KeyCode::Esc));
    assert!(!fx.app.multi_select.enabled);
}

#[test]
fn space_selects_script_in_multi_select_mode() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    let scripts_len = fx.app.scripts.items.len();
    if scripts_len == 0 {
        return;
    }
    fx.app.handle_key_normal_mode(key(KeyCode::Char('m')));
    fx.app.handle_key_normal_mode(key(KeyCode::Char(' ')));
    assert_eq!(fx.app.multi_select.scripts.len(), 1);
    fx.app.handle_key_normal_mode(key(KeyCode::Char(' ')));
    assert_eq!(fx.app.multi_select.scripts.len(), 0);
}

#[test]
fn preview_popup_opens_and_closes() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    if fx.app.scripts.items.is_empty() {
        return;
    }
    fx.app.update_preview();
    let before_content = fx.app.preview.content.clone();
    fx.app.toggle_preview_mode();
    assert_eq!(fx.app.mode, AppMode::Preview);
    fx.app.handle_key_preview_mode(key(KeyCode::Esc));
    assert_eq!(fx.app.mode, AppMode::Normal);
    let _ = before_content;
}

#[test]
fn update_preview_loads_script_content() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    if fx.app.scripts.items.is_empty() {
        return;
    }
    fx.app.update_preview();
    assert!(!fx.app.preview.content.is_empty());
    assert_ne!(fx.app.preview.content, "No script selected");
    assert_ne!(fx.app.preview.content, "Error loading script content");
}

#[test]
fn description_popup_loads_from_desc_toml() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    if fx.app.scripts.items.is_empty() {
        return;
    }
    fx.app.toggle_description_popup();
    assert_eq!(fx.app.mode, AppMode::Description);
    let content = fx.app.description.content.as_deref().unwrap_or("");
    assert!(
        !content.contains("No description available"),
        "expected real description, got fallback: {content:?}",
    );
    fx.app.handle_key_description_mode(key(KeyCode::Esc));
    assert_eq!(fx.app.mode, AppMode::Normal);
}

#[test]
fn description_popup_falls_back_when_desc_missing() {
    let tmp = TempDir::new().unwrap();
    extract_scripts(tmp.path()).unwrap();
    let modules_dir = tmp.path().join("modules");
    for entry in walkdir(&modules_dir) {
        if entry.file_name().and_then(|n| n.to_str()) == Some("desc.toml") {
            let _ = std::fs::remove_file(&entry);
        }
    }
    let app = make_app(&modules_dir);
    let mut fx = Fixture { _tmp: tmp, modules_dir, app };
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    if fx.app.scripts.items.is_empty() {
        return;
    }
    fx.app.toggle_description_popup();
    assert_eq!(fx.app.mode, AppMode::Description);
    let content = fx.app.description.content.as_deref().unwrap_or("");
    assert!(content.contains("No description available"), "expected fallback, got: {content:?}",);
}

fn walkdir(dir: &std::path::Path) -> Vec<std::path::PathBuf> {
    let mut out = Vec::new();
    if let Ok(read) = std::fs::read_dir(dir) {
        for entry in read.flatten() {
            let path = entry.path();
            if path.is_dir() {
                out.extend(walkdir(&path));
            } else {
                out.push(path);
            }
        }
    }
    out
}

#[test]
fn search_opens_with_slash_and_closes_with_esc() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('/')));
    assert_eq!(fx.app.mode, AppMode::Search);
    fx.app.handle_search_input(key(KeyCode::Esc));
    assert_eq!(fx.app.mode, AppMode::Normal);
}

#[test]
fn esc_preserves_in_progress_query() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('/')));
    for ch in "git".chars() {
        fx.app.handle_search_input(key(KeyCode::Char(ch)));
    }
    fx.app.handle_search_input(key(KeyCode::Esc));
    assert_eq!(fx.app.mode, AppMode::Normal);
    assert_eq!(fx.app.search.input, "git");
}

#[test]
fn search_finds_matching_script() {
    let mut fx = fixture();
    let some_script_name = fx
        .app
        .all_scripts
        .values()
        .flatten()
        .next()
        .map(|s| s.name.clone())
        .expect("at least one script");
    fx.app.handle_key_normal_mode(key(KeyCode::Char('/')));
    for ch in some_script_name.chars() {
        fx.app.handle_search_input(key(KeyCode::Char(ch)));
    }
    assert!(
        !fx.app.search.results.is_empty(),
        "expected search to find a match for {some_script_name:?}",
    );
}

#[test]
fn search_handles_utf8_query_safely() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('/')));
    for ch in "café😀".chars() {
        fx.app.handle_search_input(key(KeyCode::Char(ch)));
    }
    fx.app.handle_search_input(key(KeyCode::Esc));
}

#[test]
fn help_popup_opens_with_question_mark() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('?')));
    assert_eq!(fx.app.mode, AppMode::Help);
    fx.app.handle_key_help_mode(key(KeyCode::Esc));
    assert_eq!(fx.app.mode, AppMode::Normal);
}

#[test]
fn q_quits_app() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('q')));
    assert!(fx.app.quit);
}

#[test]
fn confirmation_popup_for_single_script() {
    let mut fx = fixture();
    fx.app.handle_key_normal_mode(key(KeyCode::Char('l')));
    if fx.app.scripts.items.is_empty() {
        return;
    }
    fx.app.handle_key_normal_mode(key(KeyCode::Enter));
    assert_eq!(fx.app.mode, AppMode::Confirm);
    fx.app.handle_key_confirmation_mode(key(KeyCode::Esc));
    assert_eq!(fx.app.mode, AppMode::Normal);
}

#[test]
fn root_warning_popup_when_is_root_true() {
    let tmp = TempDir::new().unwrap();
    extract_scripts(tmp.path()).unwrap();
    let modules_dir = tmp.path().join("modules");
    let opts = UiOptions {
        log_mode:     false,
        theme:        "catppuccin-mocha".into(),
        theme_locked: false,
        is_root:      true,
    };
    let mut app = App::new(&opts);
    app.modules_dir = modules_dir.clone();
    app.load_scripts(&modules_dir).unwrap();
    assert_eq!(app.mode, AppMode::RootWarning);
    app.handle_key_root_warning_mode(key(KeyCode::Char('y')));
    assert_eq!(app.mode, AppMode::Normal);
}

#[test]
fn is_running_as_root_matches_user_check() {
    #[cfg(unix)]
    {
        let expected = unsafe { libc::geteuid() == 0 };
        assert_eq!(is_running_as_root(), expected);
    }
    #[cfg(not(unix))]
    {
        assert!(!is_running_as_root());
    }
}

#[test]
fn theme_name_round_trips_through_options() {
    let opts = UiOptions {
        log_mode:     false,
        theme:        "dracula".into(),
        theme_locked: false,
        is_root:      false,
    };
    let app = App::new(&opts);
    assert_eq!(app.theme.name, Theme::dracula().name);
}

#[test]
fn has_description_matches_desc_toml() {
    let fx = fixture();
    let (cat, name) = fx
        .app
        .all_scripts
        .values()
        .flatten()
        .next()
        .map(|s| (s.category.clone(), s.name.clone()))
        .expect("at least one script");
    assert!(fx.app.has_description(&cat, &name));
}

#[test]
fn has_description_false_when_no_desc_toml() {
    let tmp = TempDir::new().unwrap();
    extract_scripts(tmp.path()).unwrap();
    let modules_dir = tmp.path().join("modules");
    for entry in walkdir(&modules_dir) {
        if entry.file_name().and_then(|n| n.to_str()) == Some("desc.toml") {
            let _ = std::fs::remove_file(&entry);
        }
    }
    let app = make_app(&modules_dir);
    let (cat, name) = app
        .all_scripts
        .values()
        .flatten()
        .next()
        .map(|s| (s.category.clone(), s.name.clone()))
        .expect("at least one script");
    assert!(!app.has_description(&cat, &name));
}
