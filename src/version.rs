use std::error::Error;
use std::io;
use std::process::Command;

pub fn get_current_version() -> String {
    let version = env!("CARGO_PKG_VERSION");
    format!("Carch version {version}")
}

pub fn get_latest_version() -> Result<String, Box<dyn Error>> {
    if Command::new("curl").arg("--version").output().is_err() {
        return Err("curl is not installed. Please install it to check for updates.".into());
    }

    let output = Command::new("curl")
        .args(["-s", "https://api.github.com/repos/harilvfs/carch/releases/latest"])
        .output()?;

    if !output.status.success() {
        return Err("Failed to fetch latest version information".into());
    }

    let response = String::from_utf8_lossy(&output.stdout);

    let tag_name = response
        .lines()
        .find(|line| line.contains("\"tag_name\""))
        .and_then(|line| {
            let parts: Vec<&str> = line.split(":").collect();
            if parts.len() >= 2 {
                let version_part = parts[1].trim();
                let cleaned = version_part
                    .trim_start_matches('"')
                    .trim_end_matches('"')
                    .trim_end_matches(',')
                    .trim_start_matches('v')
                    .trim();
                Some(cleaned.to_string())
            } else {
                None
            }
        })
        .ok_or("Could not parse version from GitHub response")?;

    Ok(tag_name)
}

pub fn check_for_updates() -> io::Result<()> {
    println!("Checking for updates...");

    let current_version = env!("CARGO_PKG_VERSION");

    match get_latest_version() {
        Ok(latest_version) => {
            let latest =
                latest_version.trim().trim_start_matches('v').trim_matches('"').trim_matches('\'');

            println!("Current version: {current_version}");
            println!("Latest version: {latest}");

            if latest != current_version {
                println!("\nA new version of Carch is available!");
                println!("\nTo update via installation script:");
                println!("  bash -c \"$(curl -fsSL chalisehari.com.np/carchinstall)\" -- update");
                println!("\nOr if you installed via Cargo:");
                println!("  cargo install carch --force");
            } else {
                println!("\nYou are using the latest version of Carch.");
            }
        }
        Err(e) => {
            eprintln!("Error checking for updates: {e}");
            return Err(io::Error::other(e.to_string()));
        }
    }

    Ok(())
}
