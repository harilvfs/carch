use carch_core::error::{CarchError, Result};
use carch_core::version;
use log::info;
use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::process::{Command, Stdio};

pub fn check_for_updates() -> Result<()> {
    println!("Checking for updates...");

    let current_version = version::current_version();

    match version::get_latest_version() {
        Ok(latest_version) => {
            println!("Current version: {current_version}");
            println!("Latest version: {latest_version}");

            if latest_version == current_version {
                println!("\nYou are using the latest version of Carch.");
            } else {
                println!("\nUpdate available!");
                println!("Run 'carch update' to update to the latest version.");
            }
        }
        Err(e) => {
            eprintln!("Error checking for updates: {e}");
            return Err(e);
        }
    }

    Ok(())
}

fn command_exists(command: &str) -> bool {
    Command::new("sh")
        .arg("-c")
        .arg(format!("command -v {command}"))
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok_and(|s| s.success())
}

fn run_command(command: &mut Command) -> Result<()> {
    let status = command.status()?;
    if !status.success() {
        return Err(CarchError::Command(format!("Command failed with exit code {status}")));
    }
    Ok(())
}

fn run_install_script() -> Result<()> {
    let response = reqwest::blocking::get(
        "https://raw.githubusercontent.com/harilvfs/carch/main/scripts/install.sh",
    )
    .and_then(|r| r.error_for_status())
    .map_err(|e| CarchError::Command(format!("Failed to download install script: {e}")))?;

    let script = response
        .text()
        .map_err(|e| CarchError::Command(format!("Failed to read install script: {e}")))?;

    let mut child = Command::new("sh")
        .stdin(Stdio::piped())
        .spawn()
        .map_err(|e| CarchError::Command(format!("Failed to run install script: {e}")))?;

    use std::io::Write;
    child
        .stdin
        .take()
        .ok_or_else(|| CarchError::Command("Failed to pipe install script".into()))?
        .write_all(script.as_bytes())
        .map_err(|e| CarchError::Command(format!("Failed to pipe install script: {e}")))?;

    let status =
        child.wait().map_err(|e| CarchError::Command(format!("Install script failed: {e}")))?;

    if !status.success() {
        return Err(CarchError::Command(
            "Install script failed. Try manually: curl -fsSL chalisehari.com.np/carch | sh -s -- install".into(),
        ));
    }
    Ok(())
}

enum InstallMethod {
    Cargo,
    CargoBinstall,
    InstallScript,
}

fn get_install_method() -> Result<InstallMethod> {
    print!("Installed via (c)argo, (b)install, or (i)nstall script? ");
    io::stdout().flush()?;
    let mut choice = String::new();
    io::stdin().read_line(&mut choice)?;
    match choice.trim().to_lowercase().as_str() {
        "c" | "cargo" => Ok(InstallMethod::Cargo),
        "b" | "binstall" | "cargo-binstall" => Ok(InstallMethod::CargoBinstall),
        "i" | "install script" => Ok(InstallMethod::InstallScript),
        _ => Err(CarchError::Command("Invalid choice. Please run the command again.".into())),
    }
}

fn get_install_method_for_uninstall() -> Result<InstallMethod> {
    print!("Installed via (c)argo or (i)nstall script? ");
    io::stdout().flush()?;
    let mut choice = String::new();
    io::stdin().read_line(&mut choice)?;
    match choice.trim().to_lowercase().as_str() {
        "c" | "cargo" => Ok(InstallMethod::Cargo),
        "i" | "install script" => Ok(InstallMethod::InstallScript),
        _ => Err(CarchError::Command("Invalid choice. Please run the command again.".into())),
    }
}

pub fn update() -> Result<()> {
    if !command_exists("carch") {
        println!("Carch is not installed. Please install it first.");
        return Ok(());
    }

    info!("Starting update...");
    println!("Updating carch...");

    match get_install_method()? {
        InstallMethod::Cargo => {
            run_command(Command::new("cargo").arg("install").arg("carch-cli").arg("--force"))?;
        }
        InstallMethod::CargoBinstall => {
            run_command(Command::new("cargo").arg("binstall").arg("carch-cli").arg("--force"))?;
        }
        InstallMethod::InstallScript => {
            run_install_script()?;
        }
    }

    println!("Update done.");
    Ok(())
}

pub fn uninstall() -> Result<()> {
    if !command_exists("carch") {
        println!("Carch is not installed.");
        return Ok(());
    }

    info!("Starting uninstall...");

    match get_install_method_for_uninstall()? {
        InstallMethod::Cargo | InstallMethod::CargoBinstall => {
            run_command(Command::new("cargo").arg("uninstall").arg("carch-cli"))?;
        }
        InstallMethod::InstallScript => {
            println!("Removing carch...");

            let is_termux = std::env::var("TERMUX_VERSION").is_ok()
                || Path::new("/data/data/com.termux").exists();
            let is_root = std::env::var("EUID").is_ok_and(|v| v == "0");

            let binary_paths: Vec<String> = if is_termux {
                let prefix =
                    std::env::var("PREFIX").unwrap_or("/data/data/com.termux/files/usr".into());
                vec![
                    format!("{prefix}/bin/carch"),
                    format!("{prefix}/share/bash-completion/completions/carch"),
                    format!("{prefix}/share/zsh/site-functions/_carch"),
                    format!("{prefix}/share/fish/vendor_completions.d/carch.fish"),
                    format!("{prefix}/share/man/man1/carch.1"),
                ]
            } else if let Ok(home) = std::env::var("HOME") {
                if is_root {
                    vec![
                        "/usr/local/bin/carch".into(),
                        "/usr/share/bash-completion/completions/carch".into(),
                        "/usr/share/zsh/site-functions/_carch".into(),
                        "/usr/share/fish/vendor_completions.d/carch.fish".into(),
                        "/usr/share/man/man1/carch.1".into(),
                        "/usr/share/applications/carch.desktop".into(),
                    ]
                } else {
                    let data = format!("{home}/.local/share");
                    vec![
                        "/usr/local/bin/carch".into(),
                        format!("{data}/bash-completion/completions/carch"),
                        format!("{data}/zsh/site-functions/_carch"),
                        format!("{data}/fish/vendor_completions.d/carch.fish"),
                        format!("{data}/man/man1/carch.1"),
                        format!("{data}/applications/carch.desktop"),
                    ]
                }
            } else {
                vec![]
            };

            for path in &binary_paths {
                if Path::new(path).exists() {
                    if is_termux || is_root {
                        run_command(Command::new("rm").arg("-f").arg(path))?;
                    } else {
                        run_command(Command::new("sudo").arg("rm").arg("-f").arg(path))?;
                    }
                    println!("  Removed {path}");
                }
            }

            if let Ok(home) = std::env::var("HOME") {
                let config_dir = Path::new(&home).join(".config/carch");
                if config_dir.exists() {
                    fs::remove_dir_all(&config_dir)?;
                    println!("  Removed {config_dir:?}");
                }
            }

            println!("carch has been removed.");
        }
    }

    println!("Uninstallation done.");
    Ok(())
}
