use carch_core::error::{CarchError, Result};
use log::info;
use std::fs;
use std::io::{self, Write};
use std::os::unix::fs::PermissionsExt;
use std::process::{Command, Stdio};
use tempfile::Builder;

use carch_core::version;

pub fn check_for_updates() -> Result<()> {
    println!("Checking for updates...");

    let current_version = env!("CARGO_PKG_VERSION");

    match version::get_latest_version() {
        Ok(latest_version) => {
            println!("Current version: {current_version}");
            println!("Latest version: {latest_version}");

            if latest_version != current_version {
                println!("\nA new version of Carch is available!");
                println!("Run 'carch update' to update to the latest version.");
            } else {
                println!("\nYou are using the latest version of Carch.");
            }
        }
        Err(e) => {
            eprintln!("Error checking for updates: {e}");
            return Err(e);
        }
    }

    Ok(())
}

enum InstallMethod {
    Cargo,
    PackageManager,
    Exit,
    Invalid,
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

fn get_installation_method() -> Result<InstallMethod> {
    print!(
        "From which install media have you installed carch? (c)argo, (p)ackage manager, or (e)xit: "
    );
    io::stdout().flush()?;
    let mut choice = String::new();
    io::stdin().read_line(&mut choice)?;
    Ok(match choice.trim().to_lowercase().as_str() {
        "c" | "cargo" => InstallMethod::Cargo,
        "p" | "package manager" => InstallMethod::PackageManager,
        "e" | "exit" => InstallMethod::Exit,
        _ => InstallMethod::Invalid,
    })
}

fn run_script_from_url(action: &str) -> Result<()> {
    info!("Downloading install script...");
    let script_contents =
        reqwest::blocking::get("https://chalisehari.com.np/carchinstall")?.bytes()?;

    let mut temp_script = Builder::new().prefix("carch-install-").suffix(".sh").tempfile()?;
    temp_script.write_all(&script_contents)?;

    let temp_path = temp_script.path().to_path_buf();
    let mut perms = fs::metadata(&temp_path)?.permissions();
    perms.set_mode(0o755); // rwxr-xr-x
    fs::set_permissions(&temp_path, perms)?;

    info!("Executing install script with action: {action}");
    run_command(Command::new("sh").arg(&temp_path).arg(action))?;

    Ok(())
}

pub fn update() -> Result<()> {
    if !command_exists("carch") {
        println!("Carch is not installed. Please install it first.");
        return Ok(());
    }

    match get_installation_method()? {
        InstallMethod::Cargo => update_via_cargo(),
        InstallMethod::PackageManager => update_via_package_manager(),
        InstallMethod::Exit => {
            println!("Exiting update.");
            Ok(())
        }
        InstallMethod::Invalid => {
            println!("Invalid choice. Please run the command again.");
            Ok(())
        }
    }
}

fn update_via_cargo() -> Result<()> {
    info!("Updating via cargo...");
    run_command(Command::new("cargo").arg("install").arg("carch").arg("--force"))?;
    println!("Update done.");
    Ok(())
}

fn update_via_package_manager() -> Result<()> {
    info!("Updating via install script...");
    run_script_from_url("update")?;
    println!("Update done.");
    Ok(())
}

pub fn uninstall() -> Result<()> {
    if !command_exists("carch") {
        println!("Carch is not installed.");
        return Ok(());
    }

    match get_installation_method()? {
        InstallMethod::Cargo => uninstall_via_cargo(),
        InstallMethod::PackageManager => uninstall_via_package_manager(),
        InstallMethod::Exit => {
            println!("Exiting uninstallation.");
            Ok(())
        }
        InstallMethod::Invalid => {
            println!("Invalid choice. Please run the command again.");
            Ok(())
        }
    }
}

fn uninstall_via_cargo() -> Result<()> {
    info!("Uninstalling via cargo...");
    run_command(Command::new("cargo").arg("uninstall").arg("carch"))?;
    println!("Uninstallation done.");
    Ok(())
}

fn uninstall_via_package_manager() -> Result<()> {
    info!("Uninstalling via install script...");
    run_script_from_url("uninstall")?;
    println!("Uninstallation done.");
    Ok(())
}
