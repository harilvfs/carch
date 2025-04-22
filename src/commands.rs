use std::env;
use std::fs;
use std::io::{self, Write, stdin, stdout};
use std::path::Path;
use std::process::Command;

const CONFIG_DIR: &str = ".config/carch";
const LOG_FILE: &str = ".config/carch/carch.log";
const INSTALL_SCRIPT_URL: &str = "https://raw.githubusercontent.com/harilvfs/carch/main/install.sh";

#[derive(Debug, PartialEq)]
pub enum InstallMethod {
    Cargo,
    Script,
}

pub fn get_version() -> String {
    let version = env!("CARGO_PKG_VERSION");
    format!("Carch version {}", version)
}

pub fn log_message(log_type: &str, message: &str) -> io::Result<()> {
    let log_file = format!(
        "{}/{}",
        env::var("HOME").unwrap_or_else(|_| String::from("~")),
        LOG_FILE
    );
    let config_dir = format!(
        "{}/{}",
        env::var("HOME").unwrap_or_else(|_| String::from("~")),
        CONFIG_DIR
    );

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

fn detect_install_method() -> InstallMethod {
    let script_installed = Path::new("/usr/local/bin/carch").exists();

    let cargo_available = Command::new("cargo").arg("--version").output().is_ok();

    let cargo_installed = if cargo_available {
        match Command::new("cargo").args(["install", "--list"]).output() {
            Ok(output) => {
                if output.status.success() {
                    let output_str = String::from_utf8_lossy(&output.stdout);
                    output_str.contains("carch")
                } else {
                    false
                }
            }
            Err(_) => false,
        }
    } else {
        false
    };

    if cargo_installed && script_installed {
        println!("Carch appears to be installed via both cargo and installation script.");
        println!("Which installation method would you like to use?");
        println!(
            "1) Cargo (crates.io) - for developers and users who installed via 'cargo install'"
        );
        println!("2) Installation script - for users who installed via the install.sh script");

        for _ in 0..3 {
            print!("Enter your choice (1 or 2): ");
            let _ = stdout().flush();

            let mut input = String::new();
            match stdin().read_line(&mut input) {
                Ok(_) => match input.trim() {
                    "1" => return InstallMethod::Cargo,
                    "2" => return InstallMethod::Script,
                    _ => println!("Invalid choice. Please enter 1 or 2."),
                },
                Err(_) => {
                    println!("Error reading input, defaulting to script method.");
                    return InstallMethod::Script;
                }
            }
        }

        println!("Too many invalid attempts, defaulting to script method.");
        InstallMethod::Script
    } else if cargo_installed {
        InstallMethod::Cargo
    } else if script_installed {
        InstallMethod::Script
    } else if cargo_available {
        println!("Could not definitively determine installation method.");
        println!("Defaulting to cargo since it's available in your system.");
        InstallMethod::Cargo
    } else {
        println!("Could not determine installation method.");
        println!("Defaulting to script method.");
        InstallMethod::Script
    }
}

fn run_script_with_args(arg: &str) -> io::Result<()> {
    let temp_dir = env::temp_dir();
    let script_path = temp_dir.join("carch_install.sh");

    println!("Downloading installation script...");
    let download_status = Command::new("curl")
        .args([
            "-sSL",
            INSTALL_SCRIPT_URL,
            "-o",
            script_path.to_str().unwrap(),
        ])
        .status()?;

    if !download_status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            "Failed to download installation script",
        ));
    }

    println!("Making script executable...");
    let chmod_status = Command::new("chmod")
        .args(["+x", script_path.to_str().unwrap()])
        .status()?;

    if !chmod_status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            "Failed to make installation script executable",
        ));
    }

    println!("Running script with '{}' option...", arg);
    let run_status = Command::new(script_path.to_str().unwrap())
        .arg(arg)
        .status()?;

    if !run_status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            format!("Installation script failed with {} option", arg),
        ));
    }

    fs::remove_file(script_path)?;

    Ok(())
}

pub fn update() -> io::Result<()> {
    println!("Determining installation method...");
    let install_method = detect_install_method();

    match install_method {
        InstallMethod::Cargo => {
            println!("Updating Carch via cargo...");
            println!("This may take a moment...");

            let status = Command::new("cargo")
                .args(["install", "carch", "--force"])
                .status()?;

            if !status.success() {
                return Err(io::Error::new(
                    io::ErrorKind::Other,
                    "Failed to update Carch via cargo. Check your cargo installation.",
                ));
            }

            println!("Carch successfully updated via cargo!");
        }
        InstallMethod::Script => {
            run_script_with_args("--update")?;
            println!("Carch successfully updated via installation script!");
        }
    }

    Ok(())
}

pub fn uninstall() -> io::Result<()> {
    println!("Determining installation method...");
    let install_method = detect_install_method();

    match install_method {
        InstallMethod::Cargo => {
            println!("Uninstalling Carch via cargo...");

            let status = Command::new("cargo")
                .args(["uninstall", "carch"])
                .status()?;

            if !status.success() {
                return Err(io::Error::new(
                    io::ErrorKind::Other,
                    "Failed to uninstall Carch via cargo. Check if it's installed correctly.",
                ));
            }
        }
        InstallMethod::Script => {
            run_script_with_args("--uninstall")?;
        }
    }

    let config_dir = format!(
        "{}/{}",
        env::var("HOME").unwrap_or_else(|_| String::from("~")),
        CONFIG_DIR
    );

    if Path::new(&config_dir).exists() {
        println!("Removing configuration directory...");
        fs::remove_dir_all(&config_dir)?;
        println!("Configuration directory removed.");
        log_message(
            "INFO",
            "Configuration directory removed during uninstallation.",
        )?;
    }

    println!("Carch has been completely uninstalled.");
    Ok(())
}
