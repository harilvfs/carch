use std::error::Error;
use std::fs;
use std::io::{self, Write};
use std::process::{Command, Stdio};

const CONFIG_DIR: &str = ".config/carch";
const LOG_FILE: &str = ".config/carch/carch.log";

enum PkgManager {
    Pacman,
    Dnf,
    Zypper,
    Unsupported,
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

fn detect_package_manager() -> PkgManager {
    if command_exists("pacman") {
        PkgManager::Pacman
    } else if command_exists("dnf") {
        PkgManager::Dnf
    } else if command_exists("zypper") {
        PkgManager::Zypper
    } else {
        PkgManager::Unsupported
    }
}

fn run_command(command: &mut Command) -> io::Result<()> {
    let status = command.status()?;
    if !status.success() {
        return Err(io::Error::other(format!("Command failed with exit code {status}")));
    }
    Ok(())
}

fn get_latest_rpm_url() -> Result<String, Box<dyn Error + Send + Sync>> {
    let client = reqwest::blocking::Client::builder().user_agent("carch").build()?;
    let release_url = "https://api.github.com/repos/harilvfs/carch/releases/latest";
    let response: GitHubRelease = client.get(release_url).send()?.json()?;

    for asset in response.assets {
        if asset.browser_download_url.ends_with(".rpm") {
            return Ok(asset.browser_download_url);
        }
    }
    Err("No RPM found in the latest release".into())
}

fn get_installation_method() -> io::Result<String> {
    print!(
        "From which install media have you installed carch? (c)argo, (p)ackage manager, or (e)xit: "
    );
    io::stdout().flush()?;
    let mut choice = String::new();
    io::stdin().read_line(&mut choice)?;
    Ok(choice.trim().to_lowercase())
}

pub fn log_message(log_type: &str, message: &str) -> io::Result<()> {
    let home_dir = dirs::home_dir()
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "Home directory not found"))?;
    let log_file = home_dir.join(LOG_FILE);
    let config_dir = home_dir.join(CONFIG_DIR);

    if !config_dir.exists() {
        fs::create_dir_all(&config_dir)?;
    }

    let mut file = fs::OpenOptions::new().create(true).append(true).open(log_file)?;
    let timestamp = chrono::Local::now().format("%Y-%m-%d %H:%M:%S").to_string();
    let log_entry = format!("{timestamp} [{log_type}] {message}\n");
    file.write_all(log_entry.as_bytes())
}

pub fn update() -> io::Result<()> {
    if !command_exists("carch") {
        println!("Carch is not installed. Please install it first.");
        return Ok(());
    }

    match get_installation_method()?.as_str() {
        "c" | "cargo" => {
            println!("Updating via cargo...");
            run_command(Command::new("cargo").arg("install").arg("carch").arg("--force"))?;
            println!("Update done.");
        }
        "p" | "package manager" => match detect_package_manager() {
            PkgManager::Pacman => {
                println!("Updating for Arch Linux...");
                let home_dir = dirs::home_dir().ok_or_else(|| {
                    io::Error::new(io::ErrorKind::NotFound, "Home directory not found")
                })?;
                let pkgs_dir = home_dir.join("pkgs");
                if pkgs_dir.exists() {
                    fs::remove_dir_all(&pkgs_dir)?;
                }
                run_command(
                    Command::new("git")
                        .arg("clone")
                        .arg("https://github.com/carch-org/pkgs")
                        .arg(&pkgs_dir),
                )?;
                let carch_bin_path = pkgs_dir.join("carch-bin");
                run_command(Command::new("makepkg").arg("-si").current_dir(carch_bin_path))?;
                println!("Update done.");
            }
            PkgManager::Dnf => {
                println!("Updating for Fedora...");
                let url = get_latest_rpm_url().map_err(io::Error::other)?;
                let rpm_path = std::env::temp_dir().join("carch.rpm");
                run_command(Command::new("wget").arg("-O").arg(&rpm_path).arg(&url))?;
                run_command(Command::new("sudo").arg("dnf").arg("install").arg(&rpm_path))?;
                fs::remove_file(&rpm_path)?;
                println!("Update done.");
            }
            PkgManager::Zypper => {
                println!("Updating for openSUSE...");
                let url = get_latest_rpm_url().map_err(io::Error::other)?;
                let rpm_path = std::env::temp_dir().join("carch.rpm");
                run_command(Command::new("wget").arg("-O").arg(&rpm_path).arg(&url))?;
                run_command(Command::new("sudo").arg("zypper").arg("install").arg(&rpm_path))?;
                fs::remove_file(&rpm_path)?;
                println!("Update done.");
            }
            PkgManager::Unsupported => {
                println!("Unsupported package manager for this option.");
            }
        },
        "e" | "exit" => {
            println!("Exiting update.");
        }
        _ => {
            println!("Invalid choice. Please run the command again.");
        }
    }
    Ok(())
}

pub fn uninstall() -> io::Result<()> {
    if !command_exists("carch") {
        println!("Carch is not installed.");
        return Ok(());
    }

    match get_installation_method()?.as_str() {
        "c" | "cargo" => {
            println!("Uninstalling via cargo...");
            run_command(Command::new("cargo").arg("uninstall").arg("carch"))?;
            println!("Uninstallation done.");
        }
        "p" | "package manager" => match detect_package_manager() {
            PkgManager::Pacman => {
                println!("Uninstalling for Arch Linux...");
                let _ = run_command(
                    Command::new("sudo")
                        .arg("pacman")
                        .arg("-R")
                        .arg("--noconfirm")
                        .arg("carch-bin"),
                );
                let _ = run_command(
                    Command::new("sudo")
                        .arg("pacman")
                        .arg("-R")
                        .arg("--noconfirm")
                        .arg("carch-bin-debug"),
                );
                println!("Uninstallation done.");
            }
            PkgManager::Dnf => {
                println!("Uninstalling for Fedora...");
                run_command(Command::new("sudo").arg("dnf").arg("remove").arg("-y").arg("carch"))?;
                println!("Uninstallation done.");
            }
            PkgManager::Zypper => {
                println!("Uninstalling for openSUSE...");
                run_command(
                    Command::new("sudo").arg("zypper").arg("remove").arg("-y").arg("carch"),
                )?;
                println!("Uninstallation done.");
            }
            PkgManager::Unsupported => {
                println!("Unsupported package manager for this option.");
            }
        },
        "e" | "exit" => {
            println!("Exiting uninstallation.");
        }
        _ => {
            println!("Invalid choice. Please run the command again.");
        }
    }
    Ok(())
}
