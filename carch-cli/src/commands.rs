use carch_core::error::{CarchError, Result};
use log::info;
use std::fs;
use std::io::{self, Write};
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
                println!("\nUpdate available!");
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

enum Distro {
    Termux,
    Arch,
    Fedora,
    OpenSuse,
}

fn is_termux() -> bool {
    std::env::var("TERMUX_VERSION").is_ok()
        || std::path::Path::new("/data/data/com.termux").exists()
}

fn detect_distro() -> Result<Distro> {
    if is_termux() {
        return Ok(Distro::Termux);
    }
    if command_exists("pacman") {
        return Ok(Distro::Arch);
    }
    if command_exists("dnf") {
        return Ok(Distro::Fedora);
    }
    if command_exists("zypper") {
        return Ok(Distro::OpenSuse);
    }
    Err(CarchError::Command(
        "Unsupported distribution. Carch supports Arch, Fedora, openSUSE, and Termux.".into(),
    ))
}

fn detect_termux_arch() -> Result<&'static str> {
    let out = Command::new("uname").arg("-m").output()?;
    let arch = String::from_utf8_lossy(&out.stdout);
    let arch = arch.trim();
    match arch {
        "aarch64" | "arm64" => Ok("aarch64"),
        a if a.starts_with("armv7") || a == "armv8l" || a == "arm" => Ok("arm"),
        other => Err(CarchError::Command(format!("Unsupported Termux architecture: {other}"))),
    }
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

fn get_latest_release_url(asset_pattern: &str) -> Result<String> {
    let client = reqwest::blocking::Client::new();
    let body = client
        .get("https://api.github.com/repos/harilvfs/carch/releases/latest")
        .header("User-Agent", "carch-cli")
        .send()?
        .text()?;

    for line in body.lines() {
        if !line.contains("browser_download_url") {
            continue;
        }
        for token in line.split('"') {
            if token.starts_with("https://") && token.ends_with(asset_pattern) {
                return Ok(token.to_string());
            }
        }
    }

    Err(CarchError::Command(format!("Could not find release asset matching '{asset_pattern}'")))
}

fn get_rpm_url() -> Result<String> {
    get_latest_release_url(".rpm")
}

fn termux_install_deb(deb_arch: &str) -> Result<()> {
    println!("==> Fetching latest .deb package for {deb_arch}...");

    let pattern = format!("_{deb_arch}.deb");
    let deb_url = get_latest_release_url(&pattern)?;

    let tmp_dir =
        std::env::var("PREFIX").map(|p| format!("{p}/tmp")).unwrap_or_else(|_| "/tmp".into());

    let mut tmp_deb = Builder::new().prefix("carch_").suffix(".deb").tempfile_in(&tmp_dir)?;

    println!("==> Downloading .deb package...");
    let bytes = reqwest::blocking::get(&deb_url)?.bytes()?;
    tmp_deb.write_all(&bytes)?;

    let tmp_path = tmp_deb.path().to_path_buf();

    println!("==> Installing .deb package...");
    run_command(Command::new("dpkg").arg("-i").arg(&tmp_path))?;

    fs::remove_file(&tmp_path).ok();
    Ok(())
}

fn install_for_distro(distro: &Distro) -> Result<()> {
    match distro {
        Distro::Termux => {
            let arch = detect_termux_arch()?;
            println!("==> Detected Termux architecture: {arch}");
            termux_install_deb(arch)
        }
        Distro::Arch => {
            println!("==> Cloning PKGBUILD...");
            let home = std::env::var("HOME")
                .map_err(|_| CarchError::Command("$HOME is not set".into()))?;
            let pkgs_dir = std::path::PathBuf::from(home).join("pkgs");

            if pkgs_dir.exists() {
                fs::remove_dir_all(&pkgs_dir)?;
            }

            run_command(
                Command::new("git")
                    .arg("clone")
                    .arg("https://github.com/carch-org/pkgs")
                    .arg(&pkgs_dir)
                    .stdout(Stdio::null())
                    .stderr(Stdio::null()),
            )?;

            let carch_bin_dir = pkgs_dir.join("carch-bin");
            run_command(
                Command::new("makepkg").arg("-si").arg("--noconfirm").current_dir(&carch_bin_dir),
            )
        }
        Distro::Fedora | Distro::OpenSuse => {
            println!("==> Downloading carch RPM...");
            let rpm_url = get_rpm_url()?;

            let bytes = reqwest::blocking::get(&rpm_url)?.bytes()?;
            let rpm_path = std::path::PathBuf::from("/tmp/carch.rpm");
            fs::write(&rpm_path, &bytes)?;

            match distro {
                Distro::Fedora => run_command(
                    Command::new("sudo").arg("dnf").arg("install").arg("-y").arg(&rpm_path),
                ),
                Distro::OpenSuse => run_command(
                    Command::new("sudo")
                        .arg("zypper")
                        .arg("install")
                        .arg("-y")
                        .arg("--allow-unsigned-rpm")
                        .arg(&rpm_path),
                ),
                _ => unreachable!(),
            }
        }
    }
}

fn uninstall_for_distro(distro: &Distro) -> Result<()> {
    match distro {
        Distro::Termux => {
            let installed = Command::new("dpkg")
                .args(["-s", "carch"])
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .status()
                .is_ok_and(|s| s.success());

            if installed {
                run_command(Command::new("dpkg").arg("-r").arg("carch"))?;
                println!("==> carch has been removed.");
            } else {
                println!("==> carch is not installed.");
            }
            Ok(())
        }
        Distro::Arch => run_command(
            Command::new("sudo")
                .arg("pacman")
                .arg("-R")
                .arg("carch-bin")
                .arg("carch-bin-debug")
                .arg("--noconfirm"),
        ),
        Distro::Fedora => {
            run_command(Command::new("sudo").arg("dnf").arg("remove").arg("carch").arg("-y"))
        }
        Distro::OpenSuse => {
            run_command(Command::new("sudo").arg("zypper").arg("remove").arg("-y").arg("carch"))
        }
    }
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
            let distro = detect_distro()?;
            install_for_distro(&distro)?;
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
            let distro = detect_distro()?;
            uninstall_for_distro(&distro)?;
        }
    }

    println!("Uninstallation done.");
    Ok(())
}
