use serde::Deserialize;
use std::error::Error;
use std::io;

#[derive(Deserialize)]
struct Release {
    tag_name: String,
}

pub fn get_current_version() -> String {
    let version = env!("CARGO_PKG_VERSION");
    format!("Carch version {version}")
}

pub fn get_latest_version() -> Result<String, Box<dyn Error>> {
    let client = reqwest::blocking::Client::builder().user_agent("carch").build()?;
    let response =
        client.get("https://api.github.com/repos/harilvfs/carch/releases/latest").send()?;

    if !response.status().is_success() {
        return Err("Failed to fetch latest version information".into());
    }

    let release: Release = response.json()?;
    let version = release.tag_name.trim_start_matches('v').to_string();
    Ok(version)
}

pub fn check_for_updates() -> io::Result<()> {
    println!("Checking for updates...");

    let current_version = env!("CARGO_PKG_VERSION");

    match get_latest_version() {
        Ok(latest_version) => {
            println!("Current version: {current_version}");
            println!("Latest version: {latest_version}");

            if latest_version != current_version {
                println!("\nA new version of Carch is available!");
                println!("Run 'carch --update' to update.");
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
