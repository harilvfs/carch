use crate::error::{CarchError, Result};
use log::info;
use std::fs;
use std::io::{self, Write};
use std::process::{Command, Stdio};

const GITHUB_API_URL: &str = "https://api.github.com/repos/harilvfs/carch/releases/latest";
const PKGS_URL: &str = "https://github.com/carch-org/pkgs";

enum PkgManager {
    Pacman,
    Dnf,
    Zypper,
}

enum InstallMethod {
    Cargo,
    PackageManager(PkgManager),
    Exit,
    Invalid,
}

#[derive(serde::Deserialize)]
struct GitHubRelease {
    assets: Vec<GitHubAsset>,
}

#[derive(serde::Deserialize)]
struct GitHubAsset {
    browser_download_url: String,
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

fn detect_package_manager() -> Result<PkgManager> {
    if command_exists("pacman") {
        Ok(PkgManager::Pacman)
    } else if command_exists("dnf") {
        Ok(PkgManager::Dnf)
    } else if command_exists("zypper") {
        Ok(PkgManager::Zypper)
    } else {
        Err(CarchError::UnsupportedPackageManager)
    }
}

fn run_command(command: &mut Command) -> Result<()> {
    let status = command.status()?;
    if !status.success() {
        return Err(CarchError::Command(format!("Command failed with exit code {status}")));
    }
    Ok(())
}

fn get_latest_rpm_url() -> Result<String> {
    let client = reqwest::blocking::Client::builder().user_agent("carch").build()?;
    let response: GitHubRelease = client.get(GITHUB_API_URL).send()?.json()?;

    for asset in response.assets {
        if asset.browser_download_url.ends_with(".rpm") {
            return Ok(asset.browser_download_url);
        }
    }
    Err(CarchError::NoRpmFound)
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
        "p" | "package manager" => InstallMethod::PackageManager(detect_package_manager()?),
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
        InstallMethod::PackageManager(pm) => update_via_package_manager(pm),
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

fn update_via_package_manager(pm: PkgManager) -> Result<()> {
    match pm {
        PkgManager::Pacman => update_for_arch(),
        PkgManager::Dnf => update_for_fedora(),
        PkgManager::Zypper => update_for_opensuse(),
    }
}

fn update_for_arch() -> Result<()> {
    info!("Updating for Arch Linux...");
    let home_dir = dirs::home_dir().ok_or(CarchError::HomeDirNotFound)?;
    let pkgs_dir = home_dir.join("pkgs");
    if pkgs_dir.exists() {
        fs::remove_dir_all(&pkgs_dir)?;
    }
    run_command(Command::new("git").arg("clone").arg(PKGS_URL).arg(&pkgs_dir))?;
    let carch_bin_path = pkgs_dir.join("carch-bin");
    run_command(Command::new("makepkg").arg("-si").current_dir(carch_bin_path))?;
    println!("Update done.");
    Ok(())
}

fn update_for_fedora() -> Result<()> {
    info!("Updating for Fedora...");
    let url = get_latest_rpm_url()?;
    let rpm_path = std::env::temp_dir().join("carch.rpm");
    run_command(Command::new("wget").arg("-O").arg(&rpm_path).arg(&url))?;
    run_command(Command::new("sudo").arg("dnf").arg("install").arg(&rpm_path))?;
    fs::remove_file(&rpm_path)?;
    println!("Update done.");
    Ok(())
}

fn update_for_opensuse() -> Result<()> {
    info!("Updating for openSUSE...");
    let url = get_latest_rpm_url()?;
    let rpm_path = std::env::temp_dir().join("carch.rpm");
    run_command(Command::new("wget").arg("-O").arg(&rpm_path).arg(&url))?;
    run_command(Command::new("sudo").arg("zypper").arg("install").arg(&rpm_path))?;
    fs::remove_file(&rpm_path)?;
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
        InstallMethod::PackageManager(pm) => uninstall_via_package_manager(pm),
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

fn uninstall_via_package_manager(pm: PkgManager) -> Result<()> {
    match pm {
        PkgManager::Pacman => uninstall_for_arch(),
        PkgManager::Dnf => uninstall_for_fedora(),
        PkgManager::Zypper => uninstall_for_opensuse(),
    }
}

fn uninstall_for_arch() -> Result<()> {
    info!("Uninstalling for Arch Linux...");
    let _ = run_command(
        Command::new("sudo").arg("pacman").arg("-R").arg("--noconfirm").arg("carch-bin"),
    );
    let _ = run_command(
        Command::new("sudo").arg("pacman").arg("-R").arg("--noconfirm").arg("carch-bin-debug"),
    );
    println!("Uninstallation done.");
    Ok(())
}

fn uninstall_for_fedora() -> Result<()> {
    info!("Uninstalling for Fedora...");
    run_command(Command::new("sudo").arg("dnf").arg("remove").arg("-y").arg("carch"))?;
    println!("Uninstallation done.");
    Ok(())
}

fn uninstall_for_opensuse() -> Result<()> {
    info!("Uninstalling for openSUSE...");
    run_command(Command::new("sudo").arg("zypper").arg("remove").arg("-y").arg("carch"))?;
    println!("Uninstallation done.");
    Ok(())
}
