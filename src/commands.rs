use std::fs;
use std::io::{self, Write};

const CONFIG_DIR: &str = ".config/carch";
const LOG_FILE: &str = ".config/carch/carch.log";

pub fn log_message(log_type: &str, message: &str,) -> io::Result<(),> {
    let home_dir = dirs::home_dir()
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "Home directory not found",),)?;
    let log_file = home_dir.join(LOG_FILE,);
    let config_dir = home_dir.join(CONFIG_DIR,);

    if !config_dir.exists() {
        fs::create_dir_all(&config_dir,)?;
    }

    let mut file = fs::OpenOptions::new().create(true,).append(true,).open(log_file,)?;

    let timestamp = chrono::Local::now().format("%Y-%m-%d %H:%M:%S",).to_string();
    let log_entry = format!("{timestamp} [{log_type}] {message}\n");

    file.write_all(log_entry.as_bytes(),)?;

    Ok((),)
}

pub fn update() -> io::Result<(),> {
    println!("To update Carch, please use one of the following methods:");
    println!("\nIf you installed via installation script:");
    println!("  bash -c \"$(curl -fsSL chalisehari.com.np/carchinstall)\" -- update");
    println!("\nIf you installed via Cargo:");
    println!("  cargo install carch --force");
    Ok((),)
}

pub fn uninstall() -> io::Result<(),> {
    println!("To uninstall Carch, please use one of the following methods:");
    println!("\nIf you installed via installation script:");
    println!("  bash -c \"$(curl -fsSL chalisehari.com.np/carchinstall)\" -- uninstall");
    println!("\nIf you installed via Cargo:");
    println!("  cargo uninstall carch");
    Ok((),)
}
