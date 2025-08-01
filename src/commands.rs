use crate::error::{CarchError, Result};
use log::info;
use std::io::{self, Write};
use std::process::{Command, Stdio};

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
    run_command(
        Command::new("sh")
            .arg("-c")
            .arg("curl -fsSL https://chalisehari.com.np/carchinstall | bash -s -- update"),
    )?;
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
    run_command(
        Command::new("sh")
            .arg("-c")
            .arg("curl -fsSL https://chalisehari.com.np/carchinstall | bash -s -- uninstall"),
    )?;
    println!("Uninstallation done.");
    Ok(())
}
