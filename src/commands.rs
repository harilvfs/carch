use std::env;
use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::process::Command;

const CONFIG_DIR: &str = ".config/carch";
const LOG_FILE: &str = ".config/carch/carch.log";

pub fn get_version() -> String {
    let version = env!("CARGO_PKG_VERSION");
    format!("Carch version {}", version)
}

pub fn log_message(log_type: &str, message: &str) -> io::Result<()> {
    let log_file = format!("{}/{}", env::var("HOME").unwrap_or_else(|_| String::from("~")), LOG_FILE);
    let config_dir = format!("{}/{}", env::var("HOME").unwrap_or_else(|_| String::from("~")), CONFIG_DIR);
    
    if !Path::new(&config_dir).exists() {
        fs::create_dir_all(&config_dir)?;
    }
    
    let mut file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(log_file)?;
    
    let timestamp = chrono::Local::now().format("%Y-%m-%d %H:%M:%S").to_string();
    let log_entry = format!("{} [{}] {}\n", timestamp, log_type, message);
    
    file.write_all(log_entry.as_bytes())?;
    
    Ok(())
}

pub fn detect_distro() -> String {
    if Path::new("/etc/arch-release").exists() || Command::new("pacman").arg("-V").status().is_ok() {
        return String::from("arch");
    }
    
    if Path::new("/etc/fedora-release").exists() || Command::new("dnf").arg("--version").status().is_ok() {
        return String::from("fedora");
    }
    
    String::from("unknown")
}

pub fn check_update() -> io::Result<()> {
    println!("Checking for updates...");
    
    let installed_version = env!("CARGO_PKG_VERSION");
    println!("Installed version: {}", installed_version);
    
    let output = Command::new("curl")
        .args([
            "-s", 
            "https://api.github.com/repos/harilvfs/carch/releases/latest"
        ])
        .output()?;
    
    if !output.status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            "Failed to fetch latest version information"
        ));
    }
    
    let response = String::from_utf8_lossy(&output.stdout);
    
    let latest_version = response
        .lines()
        .find(|line| line.contains("tag_name"))
        .and_then(|line| {
            let parts: Vec<&str> = line.split('"').collect();
            if parts.len() >= 4 {
                Some(parts[3].trim_start_matches('v').to_string())
            } else {
                None
            }
        });
    
    match latest_version {
        Some(version) => {
            println!("Latest version: {}", version);
            
            if version != installed_version {
                println!("Update available: Carch {} → {}", installed_version, version);
                println!("Run `carch --update` to update.");
            } else {
                println!("Carch is up to date ({}).", installed_version);
            }
        },
        None => {
            return Err(io::Error::new(
                io::ErrorKind::Other,
                "Failed to parse latest version information"
            ));
        }
    }
    
    Ok(())
}

pub fn update() -> io::Result<()> {
    println!("Updating Carch...");
    
    let distro = detect_distro();
    
    let base_url = "https://chalisehari.com.np";
    
    match distro.as_str() {
        "fedora" => {
            println!("Detected Fedora. Running the Fedora update script...");
            let status = Command::new("bash")
                .arg("-c")
                .arg(format!("curl -L {}/fedora | bash", base_url))
                .status()?;
            
            if !status.success() {
                return Err(io::Error::new(
                    io::ErrorKind::Other,
                    "Failed to update Carch on Fedora"
                ));
            }
        },
        "arch" => {
            println!("Detected Arch Linux. Running the Arch update script...");
            let status = Command::new("bash")
                .arg("-c")
                .arg(format!("curl -L {}/arch | bash", base_url))
                .status()?;
            
            if !status.success() {
                return Err(io::Error::new(
                    io::ErrorKind::Other,
                    "Failed to update Carch on Arch Linux"
                ));
            }
        },
        _ => {
            return Err(io::Error::new(
                io::ErrorKind::Other,
                format!("Unsupported distribution: {}", distro)
            ));
        }
    }
    
    println!("Update completed successfully!");
    Ok(())
}

pub fn uninstall() -> io::Result<()> {
    println!("Uninstalling Carch...");
    
    let distro = detect_distro();
    
    match distro.as_str() {
        "fedora" => {
            println!("Detected Fedora. Checking if Carch is installed...");
            
            let status = Command::new("rpm")
                .args(["-q", "carch"])
                .status()?;
            
            if status.success() {
                println!("Removing Carch package...");
                let uninstall_status = Command::new("sudo")
                    .args(["dnf", "remove", "-y", "carch"])
                    .status()?;
                
                if !uninstall_status.success() {
                    return Err(io::Error::new(
                        io::ErrorKind::Other,
                        "Failed to uninstall Carch from Fedora"
                    ));
                }
                
                println!("Carch has been uninstalled from Fedora.");
                log_message("INFO", "Carch uninstalled successfully via DNF.")?;
            } else {
                println!("Carch RPM package not found on the system.");
                log_message("WARNING", "Carch not found during uninstall attempt.")?;
            }
        },
        "arch" => {
            println!("Detected Arch Linux. Checking if Carch is installed...");
            
            let pacman_check_carch = Command::new("pacman")
                .args(["-Q", "carch"])
                .status()?;
            
            let pacman_check_carch_git = Command::new("pacman")
                .args(["-Q", "carch-git"])
                .status()?;
            
            if pacman_check_carch.success() {
                println!("Removing Carch package...");
                let uninstall_status = Command::new("sudo")
                    .args(["pacman", "-R", "carch", "--noconfirm"])
                    .status()?;
                
                if !uninstall_status.success() {
                    return Err(io::Error::new(
                        io::ErrorKind::Other,
                        "Failed to uninstall Carch from Arch Linux"
                    ));
                }
                
                println!("Carch has been uninstalled from Arch Linux.");
                log_message("INFO", "Carch uninstalled successfully from Arch Linux.")?;
            } else if pacman_check_carch_git.success() {
                println!("Removing Carch-git package...");
                let uninstall_status = Command::new("sudo")
                    .args(["pacman", "-R", "carch-git", "--noconfirm"])
                    .status()?;
                
                if !uninstall_status.success() {
                    return Err(io::Error::new(
                        io::ErrorKind::Other,
                        "Failed to uninstall Carch-git from Arch Linux"
                    ));
                }
                
                println!("Carch-git has been uninstalled from Arch Linux.");
                log_message("INFO", "Carch-git uninstalled successfully from Arch Linux.")?;
            } else {
                println!("Carch package not found on the system.");
                log_message("WARNING", "Carch not found during uninstall attempt on Arch Linux.")?;
            }
        },
        _ => {
            return Err(io::Error::new(
                io::ErrorKind::Other,
                format!("Unsupported distribution: {}", distro)
            ));
        }
    }
    
    let config_dir = format!("{}/{}", env::var("HOME").unwrap_or_else(|_| String::from("~")), CONFIG_DIR);
    if Path::new(&config_dir).exists() {
        println!("Removing configuration directory...");
        fs::remove_dir_all(&config_dir)?;
        println!("Configuration directory removed.");
        log_message("INFO", "Configuration directory removed during uninstallation.")?;
    }
    
    println!("Carch has been completely uninstalled.");
    Ok(())
} 
