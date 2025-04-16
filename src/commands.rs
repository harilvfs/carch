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

pub fn update() -> io::Result<()> {
    println!("Updating Carch...");

    let status = Command::new("cargo")
        .args(["install", "carch", "--force"])
        .status()?;

    if !status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            "Failed to update Carch via cargo",
        ));
    }

    println!("Carch successfully updated!");
    Ok(())
}

pub fn uninstall() -> io::Result<()> {
    println!("Uninstalling Carch...");

    let status = Command::new("cargo")
        .args(["uninstall", "carch"])
        .status()?;

    if !status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            "Failed to uninstall Carch",
        ));
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
