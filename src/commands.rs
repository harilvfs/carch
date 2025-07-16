use std::fs;
use std::io::{self, Write};
use std::process::Command;

const CONFIG_DIR: &str = ".config/carch";
const LOG_FILE: &str = ".config/carch/carch.log";

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

    file.write_all(log_entry.as_bytes())?;

    Ok(())
}

pub fn update() -> io::Result<()> {
    if !Command::new("sh")
        .arg("-c")
        .arg("command -v carch")
        .output()
        .is_ok_and(|o| o.status.success())
    {
        println!("Carch is not installed. Please install it first.");
        return Ok(());
    }

    print!(
        "From which install media have you installed carch? (c)argo, (p)ackagebuild, or (e)xit: "
    );
    io::stdout().flush()?;
    let mut choice = String::new();
    io::stdin().read_line(&mut choice)?;

    match choice.trim().to_lowercase().as_str() {
        "c" | "cargo" => {
            println!("Updating via cargo...");
            Command::new("cargo").arg("install").arg("carch").arg("--force").status()?;
            println!("Update done.");
        }
        "p" | "packagebuild" => {
            if Command::new("sh")
                .arg("-c")
                .arg("command -v pacman")
                .output()
                .is_ok_and(|o| o.status.success())
            {
                println!("Updating for Arch Linux...");
                let home_dir = dirs::home_dir().ok_or_else(|| {
                    io::Error::new(io::ErrorKind::NotFound, "Home directory not found")
                })?;
                let pkgs_dir = home_dir.join("pkgs");
                if pkgs_dir.exists() {
                    fs::remove_dir_all(&pkgs_dir)?;
                }
                Command::new("git")
                    .arg("clone")
                    .arg("https://github.com/carch-org/pkgs")
                    .arg(&pkgs_dir)
                    .status()?;
                let carch_bin_path = pkgs_dir.join("carch-bin");
                Command::new("makepkg").arg("-si").current_dir(carch_bin_path).status()?;
                println!("Update done.");
            } else if Command::new("sh")
                .arg("-c")
                .arg("command -v dnf")
                .output()
                .is_ok_and(|o| o.status.success())
            {
                println!("Updating for Fedora...");
                let url_output = Command::new("sh")
                    .arg("-c")
                    .arg(r#"curl -s https://api.github.com/repos/harilvfs/carch/releases/latest | grep 'browser_download_url.*rpm' | cut -d '"' -f 4"#)
                    .output()?;
                let url = String::from_utf8_lossy(&url_output.stdout).trim().to_string();
                if url.is_empty() {
                    println!("Could not find the latest RPM release.");
                    return Ok(());
                }
                let rpm_path = std::env::temp_dir().join("carch.rpm");
                Command::new("wget").arg("-O").arg(&rpm_path).arg(&url).status()?;
                Command::new("sudo").arg("dnf").arg("install").arg(&rpm_path).status()?;
                fs::remove_file(&rpm_path)?;
                println!("Update done.");
            } else if Command::new("sh")
                .arg("-c")
                .arg("command -v zypper")
                .output()
                .is_ok_and(|o| o.status.success())
            {
                println!("Updating for openSUSE...");
                let url_output = Command::new("sh")
                    .arg("-c")
                    .arg(r#"curl -s https://api.github.com/repos/harilvfs/carch/releases/latest | grep 'browser_download_url.*rpm' | cut -d '"' -f 4"#)
                    .output()?;
                let url = String::from_utf8_lossy(&url_output.stdout).trim().to_string();
                if url.is_empty() {
                    println!("Could not find the latest RPM release.");
                    return Ok(());
                }
                let rpm_path = std::env::temp_dir().join("carch.rpm");
                Command::new("wget").arg("-O").arg(&rpm_path).arg(&url).status()?;
                Command::new("sudo").arg("zypper").arg("install").arg(&rpm_path).status()?;
                fs::remove_file(&rpm_path)?;
                println!("Update done.");
            } else {
                println!("Unsupported package manager for this option.");
            }
        }
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
    if !Command::new("sh")
        .arg("-c")
        .arg("command -v carch")
        .output()
        .is_ok_and(|o| o.status.success())
    {
        println!("Carch is not installed.");
        return Ok(());
    }

    print!(
        "From which install media have you installed carch? (c)argo, (p)ackagebuild, or (e)xit: "
    );
    io::stdout().flush()?;
    let mut choice = String::new();
    io::stdin().read_line(&mut choice)?;

    match choice.trim().to_lowercase().as_str() {
        "c" | "cargo" => {
            println!("Uninstalling via cargo...");
            Command::new("cargo").arg("uninstall").arg("carch").status()?;
            println!("Uninstallation done.");
        }
        "p" | "packagebuild" => {
            if Command::new("sh")
                .arg("-c")
                .arg("command -v pacman")
                .output()
                .is_ok_and(|o| o.status.success())
            {
                println!("Uninstalling for Arch Linux...");
                let _ = Command::new("sudo").arg("pacman").arg("-R").arg("carch-bin").status();
                let _ =
                    Command::new("sudo").arg("pacman").arg("-R").arg("carch-bin-debug").status();
                println!("Uninstallation done.");
            } else if Command::new("sh")
                .arg("-c")
                .arg("command -v dnf")
                .output()
                .is_ok_and(|o| o.status.success())
            {
                println!("Uninstalling for Fedora...");
                Command::new("sudo").arg("dnf").arg("remove").arg("carch").status()?;
                println!("Uninstallation done.");
            } else if Command::new("sh")
                .arg("-c")
                .arg("command -v zypper")
                .output()
                .is_ok_and(|o| o.status.success())
            {
                println!("Uninstalling for openSUSE...");
                Command::new("sudo").arg("zypper").arg("remove").arg("carch").status()?;
                println!("Uninstallation done.");
            } else {
                println!("Unsupported package manager for this option.");
            }
        }
        "e" | "exit" => {
            println!("Exiting uninstallation.");
        }
        _ => {
            println!("Invalid choice. Please run the command again.");
        }
    }
    Ok(())
}
