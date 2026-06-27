use crate::args::Cli;
use carch_core::error::{CarchError, Result};
use clap::CommandFactory;
use std::fs;
use std::path::PathBuf;

#[cfg(target_os = "linux")]
const DESKTOP_FILE: &str = "[Desktop Entry]
Name=Carch
Comment=A Rust-based CLI tool to streamline and automate your Linux system\u{2019}s initial setup
Exec=carch
Icon=utilities-terminal
Type=Application
Terminal=true
Categories=Utility;
Keywords=linux;setup;script;configuration;automate;system;
";

fn is_termux() -> bool {
    std::env::var("TERMUX_VERSION").is_ok() || std::env::var("PREFIX").is_ok()
}

fn is_root() -> bool {
    std::env::var("EUID").is_ok_and(|v| v == "0")
}

fn termux_prefix() -> PathBuf {
    std::env::var("PREFIX")
        .map(PathBuf::from)
        .unwrap_or_else(|_| PathBuf::from("/data/data/com.termux/files/usr"))
}

fn bash_completion_dir() -> PathBuf {
    if is_termux() {
        termux_prefix().join("share/bash-completion/completions")
    } else if is_root() {
        PathBuf::from("/usr/share/bash-completion/completions")
    } else {
        dirs::data_dir()
            .unwrap_or_else(|| PathBuf::from("~/.local/share"))
            .join("bash-completion/completions")
    }
}

fn zsh_completion_dir() -> PathBuf {
    if is_termux() {
        termux_prefix().join("share/zsh/site-functions")
    } else if is_root() {
        PathBuf::from("/usr/share/zsh/site-functions")
    } else {
        dirs::data_dir()
            .unwrap_or_else(|| PathBuf::from("~/.local/share"))
            .join("zsh/site-functions")
    }
}

fn fish_completion_dir() -> PathBuf {
    if is_termux() {
        termux_prefix().join("share/fish/vendor_completions.d")
    } else if is_root() {
        PathBuf::from("/usr/share/fish/vendor_completions.d")
    } else {
        dirs::data_dir()
            .unwrap_or_else(|| PathBuf::from("~/.local/share"))
            .join("fish/vendor_completions.d")
    }
}

fn man_dir() -> PathBuf {
    if is_termux() {
        termux_prefix().join("share/man/man1")
    } else if is_root() {
        PathBuf::from("/usr/share/man/man1")
    } else {
        dirs::data_dir().unwrap_or_else(|| PathBuf::from("~/.local/share")).join("man/man1")
    }
}

fn write_file(path: &PathBuf, content: &[u8], dry_run: bool) -> Result<()> {
    if dry_run {
        return Ok(());
    }
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, content)?;
    Ok(())
}

pub fn run_setup(dry_run: bool) -> Result<()> {
    let mut cmd = Cli::command();
    cmd = cmd.name("carch");

    if dry_run {
        println!("(dry run) Would install:");
    }

    let mut installed = Vec::new();

    let bash_path = bash_completion_dir().join("carch");
    let mut bash_content = Vec::new();
    clap_complete::generate(
        clap_complete::Shell::Bash,
        &mut cmd.clone(),
        "carch",
        &mut bash_content,
    );
    write_file(&bash_path, &bash_content, dry_run)?;
    installed.push(format!("bash completions → {}", bash_path.display()));

    let zsh_path = zsh_completion_dir().join("_carch");
    let mut zsh_content = Vec::new();
    clap_complete::generate(clap_complete::Shell::Zsh, &mut cmd.clone(), "carch", &mut zsh_content);
    write_file(&zsh_path, &zsh_content, dry_run)?;
    installed.push(format!("zsh completions → {}", zsh_path.display()));

    let fish_path = fish_completion_dir().join("carch.fish");
    let mut fish_content = Vec::new();
    clap_complete::generate(
        clap_complete::Shell::Fish,
        &mut cmd.clone(),
        "carch",
        &mut fish_content,
    );
    write_file(&fish_path, &fish_content, dry_run)?;
    installed.push(format!("fish completions → {}", fish_path.display()));

    let date = std::process::Command::new("date")
        .arg("+%B %d, %Y")
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_else(|| "unknown".to_string());

    let man = clap_mangen::Man::new(cmd.clone())
        .title("carch")
        .section("1")
        .date(date.trim())
        .source("Carch")
        .manual("Carch");

    let mut buf = Vec::new();
    man.render(&mut buf)?;

    let mut content = String::from_utf8(buf)
        .map_err(|e| CarchError::Command(format!("man page UTF-8 error: {e}")))?;
    for sub in cmd.get_subcommands() {
        let name = sub.get_name();
        let escaped = name.replace('-', "\\-");
        let old = format!("carch\\-{escaped}(1)");
        let new = format!("\\fB{name}\\fR");
        content = content.replace(&old, &new);
    }
    content = content.replace("carch\\-help(1)", "\\fBhelp\\fR");

    let man_path = man_dir().join("carch.1");
    write_file(&man_path, content.as_bytes(), dry_run)?;
    installed.push(format!("man page → {}", man_path.display()));

    if !is_termux() {
        let desktop_dir = if is_root() {
            PathBuf::from("/usr/share/applications")
        } else {
            dirs::data_dir().unwrap_or_else(|| PathBuf::from("~/.local/share")).join("applications")
        };
        let desktop_path = desktop_dir.join("carch.desktop");
        write_file(&desktop_path, DESKTOP_FILE.as_bytes(), dry_run)?;
        installed.push(format!("desktop file → {}", desktop_path.display()));
    }

    for msg in &installed {
        if dry_run {
            println!("  {msg}");
        } else {
            println!("✓ {msg}");
        }
    }

    Ok(())
}
