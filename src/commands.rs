use crate::error::{CarchError, Result};
use log::info;
use std::fs;
use std::io::{self, Write};
use std::process::{Command, Stdio};
use tempfile::tempdir;

const GITHUB_API_URL: &str = "https://api.github.com/repos/harilvfs/carch/releases/latest";
const PKGS_URL: &str = "https://github.com/carch-org/pkgs";

/// the supported package managers.
enum PkgManager {
    Pacman,
    Dnf,
    Zypper,
}

/// how the user installed the app via cargo or pkgbuilds.
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

/// checks if a command exists on the system.
fn command_exists(command: &str) -> bool {
    Command::new("sh")
        .arg("-c")
        .arg(format!("command -v {command}"))
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok_and(|s| s.success())
}

/// figures out which package manager is being used.
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

/// runs a command and checks if it was successful.
fn run_command(command: &mut Command) -> Result<()> {
    let status = command.status()?;
    if !status.success() {
        return Err(CarchError::Command(format!("command failed with exit code {status}")));
    }
    Ok(())
}

/// gets the download url for the latest rpm release from github.
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

/// asks the user how they installed the app.
fn get_installation_method() -> Result<InstallMethod> {
    print!(
        "from which install media have you installed carch? (c)argo, (p)ackage manager, or (e)xit: "
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

/// updates the app.
pub fn update() -> Result<()> {
    if !command_exists("carch") {
        println!("carch is not installed. please install it first.");
        return Ok(());
    }

    match get_installation_method()? {
        InstallMethod::Cargo => update_via_cargo(),
        InstallMethod::PackageManager(pm) => update_via_package_manager(pm),
        InstallMethod::Exit => {
            println!("exiting update.");
            Ok(())
        }
        InstallMethod::Invalid => {
            println!("invalid choice. please run the command again.");
            Ok(())
        }
    }
}

/// updates the app using cargo.
fn update_via_cargo() -> Result<()> {
    info!("updating via cargo...");
    run_command(Command::new("cargo").arg("install").arg("carch").arg("--force"))?;
    println!("update done.");
    Ok(())
}

/// updates the app using a package manager.
fn update_via_package_manager(pm: PkgManager) -> Result<()> {
    match pm {
        PkgManager::Pacman => update_for_arch(),
        PkgManager::Dnf => update_for_fedora(),
        PkgManager::Zypper => update_for_opensuse(),
    }
}

/// updates the app for arch linux.
fn update_for_arch() -> Result<()> {
    info!("updating for arch linux...");
    let temp_dir = tempdir()?;
    let pkgs_dir = temp_dir.path();
    run_command(Command::new("git").arg("clone").arg(PKGS_URL).arg(pkgs_dir))?;
    let carch_bin_path = pkgs_dir.join("carch-bin");
    run_command(Command::new("makepkg").arg("-si").current_dir(carch_bin_path))?;
    println!("update done.");
    Ok(())
}

/// updates the app for fedora.
fn update_for_fedora() -> Result<()> {
    info!("updating for fedora...");
    let url = get_latest_rpm_url()?;
    let rpm_path = std::env::temp_dir().join("carch.rpm");
    run_command(Command::new("wget").arg("-O").arg(&rpm_path).arg(&url))?;
    run_command(Command::new("sudo").arg("dnf").arg("install").arg(&rpm_path))?;
    fs::remove_file(&rpm_path)?;
    println!("update done.");
    Ok(())
}

/// updates the app for opensuse.
fn update_for_opensuse() -> Result<()> {
    info!("updating for opensuse...");
    let url = get_latest_rpm_url()?;
    let rpm_path = std::env::temp_dir().join("carch.rpm");
    run_command(Command::new("wget").arg("-O").arg(&rpm_path).arg(&url))?;
    run_command(Command::new("sudo").arg("zypper").arg("install").arg(&rpm_path))?;
    fs::remove_file(&rpm_path)?;
    println!("update done.");
    Ok(())
}

/// uninstalls the app.
pub fn uninstall() -> Result<()> {
    if !command_exists("carch") {
        println!("carch is not installed.");
        return Ok(());
    }

    match get_installation_method()? {
        InstallMethod::Cargo => uninstall_via_cargo(),
        InstallMethod::PackageManager(pm) => uninstall_via_package_manager(pm),
        InstallMethod::Exit => {
            println!("exiting uninstallation.");
            Ok(())
        }
        InstallMethod::Invalid => {
            println!("invalid choice. please run the command again.");
            Ok(())
        }
    }
}

/// uninstalls the app using cargo.
fn uninstall_via_cargo() -> Result<()> {
    info!("uninstalling via cargo...");
    run_command(Command::new("cargo").arg("uninstall").arg("carch"))?;
    println!("uninstallation done.");
    Ok(())
}

/// uninstalls the app using a package manager.
fn uninstall_via_package_manager(pm: PkgManager) -> Result<()> {
    match pm {
        PkgManager::Pacman => uninstall_for_arch(),
        PkgManager::Dnf => uninstall_for_fedora(),
        PkgManager::Zypper => uninstall_for_opensuse(),
    }
}

/// uninstalls the app for arch linux.
fn uninstall_for_arch() -> Result<()> {
    info!("uninstalling for arch linux...");
    let _ = run_command(
        Command::new("sudo").arg("pacman").arg("-R").arg("--noconfirm").arg("carch-bin"),
    );
    let _ = run_command(
        Command::new("sudo").arg("pacman").arg("-R").arg("--noconfirm").arg("carch-bin-debug"),
    );
    println!("uninstallation done.");
    Ok(())
}

/// uninstalls the app for fedora.
fn uninstall_for_fedora() -> Result<()> {
    info!("uninstalling for fedora...");
    run_command(Command::new("sudo").arg("dnf").arg("remove").arg("-y").arg("carch"))?;
    println!("uninstallation done.");
    Ok(())
}

/// uninstalls the app for opensuse.
fn uninstall_for_opensuse() -> Result<()> {
    info!("uninstalling for opensuse...");
    run_command(Command::new("sudo").arg("zypper").arg("remove").arg("-y").arg("carch"))?;
    println!("uninstallation done.");
    Ok(())
}
