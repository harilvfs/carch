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
    println!("==> Downloading and running install script...");
    let status = Command::new("sh")
        .arg("-c")
        .arg(
            "curl -fsSL https://raw.githubusercontent.com/harilvfs/carch/main/scripts/install.sh | sh",
        )
        .status()?;
    if !status.success() {
        return Err(CarchError::Command(
            "Install script failed. Try manually: curl -fsSL https://raw.githubusercontent.com/harilvfs/carch/main/scripts/install.sh | sh".into(),
        ));
    }
    Ok(())
}

enum InstallMethod {
    Cargo,
    InstallScript,
}

fn get_install_method() -> Result<InstallMethod> {
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
    println!("==> Updating carch...");

    match get_install_method()? {
        InstallMethod::Cargo => {
            run_command(Command::new("cargo").arg("install").arg("carch-cli").arg("--force"))?;
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

    match get_install_method()? {
        InstallMethod::Cargo => {
            run_command(Command::new("cargo").arg("uninstall").arg("carch-cli"))?;
        }
        InstallMethod::InstallScript => {
            println!("==> Removing carch...");

            let binary_paths = if std::env::var("TERMUX_VERSION").is_ok()
                || Path::new("/data/data/com.termux").exists()
            {
                let prefix =
                    std::env::var("PREFIX").unwrap_or("/data/data/com.termux/files/usr".into());
                vec![format!("{prefix}/bin/carch"), format!("{prefix}/share/man/man1/carch.1")]
            } else {
                vec![
                    "/usr/local/bin/carch".into(),
                    "/usr/share/bash-completion/completions/carch".into(),
                    "/usr/share/zsh/site-functions/_carch".into(),
                    "/usr/share/fish/vendor_completions.d/carch.fish".into(),
                    "/usr/share/man/man1/carch.1".into(),
                    "/usr/share/applications/carch.desktop".into(),
                ]
            };

            for path in &binary_paths {
                if Path::new(path).exists() {
                    run_command(Command::new("sudo").arg("rm").arg("-f").arg(path))?;
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

            println!("==> carch has been removed.");
        }
    }

    println!("Uninstallation done.");
    Ok(())
}
