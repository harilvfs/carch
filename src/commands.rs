use std::env;
use std::fs;
use std::io::{self, Write};
use std::path::Path;

const CONFIG_DIR: &str = ".config/carch";
const LOG_FILE: &str = ".config/carch/carch.log";

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
    println!("To update Carch, please use one of the following methods:");
    println!("\nIf you installed via installation script:");
    println!("  bash -c \"$(curl -fsSL https://chalisehari.com.np/carchinstall)\" -- --update");
    println!("\nIf you installed via Cargo:");
    println!("  cargo install carch --force");
    Ok(())
}

pub fn uninstall() -> io::Result<()> {
    println!("To uninstall Carch, please use one of the following methods:");
    println!("\nIf you installed via installation script:");
    println!("  bash -c \"$(curl -fsSL https://chalisehari.com.np/carchinstall)\" -- --uninstall");
    println!("\nIf you installed via Cargo:");
    println!("  cargo uninstall carch");
    Ok(())
}
