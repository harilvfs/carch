use dialoguer::Select;
use std::{fs, process::Command};

const SCRIPT_DIR: &str = "../scripts"; // Path to the scripts directory
const HELP_MESSAGE: &str = "This tool helps to automate Arch Linux setup.\n\n\
                            Select 'Arch Setup' to install packages and configure the system.\n\
                            For more information, visit: https://harilvfs.github.io/carch/";

fn main() {
    display_main_menu();
}

fn display_main_menu() {
    loop {
        let options = &["Arch Setup", "Help & Info", "Exit"];
        let selection = Select::new()
            .with_prompt("Linux System Arch Setup")
            .default(0)
            .items(options)
            .interact()
            .unwrap();

        match selection {
            0 => display_submenu(), // Load scripts and display submenu for Arch Setup
            1 => display_help(),
            2 => {
                println!("Exiting...");
                break;
            }
            _ => unreachable!(),
        }
    }
}

fn load_scripts() -> Vec<String> {
    let mut scripts = Vec::new();
    // Read the scripts directory and collect script names
    if let Ok(entries) = fs::read_dir(SCRIPT_DIR) {
        for entry in entries.filter_map(Result::ok) {
            let path = entry.path();
            if let Some(file_name) = path.file_name() {
                if let Some(name) = file_name.to_str() {
                    if name.ends_with(".sh") {
                        // Check for .sh scripts
                        // Trim the ".sh" extension and push to the scripts vector
                        let script_name = name.trim_end_matches(".sh");
                        scripts.push(script_name.to_string());
                    }
                }
            }
        }
    } else {
        eprintln!("Failed to read the directory: {}", SCRIPT_DIR);
    }

    // Debugging output to verify scripts loaded
    println!("Scripts found: {:?}", scripts);

    scripts
}

fn display_submenu() {
    loop {
        let scripts = load_scripts(); // Load scripts each time the submenu is displayed

        if scripts.is_empty() {
            println!("No scripts found in the '{}' directory.", SCRIPT_DIR);
            println!("Press Enter to return to the menu...");
            let _ = std::io::stdin().read_line(&mut String::new());
            break;
        }

        // Create display names for the menu, adding numbering
        let script_names: Vec<String> = scripts
            .iter()
            .enumerate()
            .map(|(i, name)| format!("{}: {}", i + 1, name))
            .collect();

        let mut options = script_names.clone();
        options.push("Exit".to_string()); // Convert &str to String here

        let selection = Select::new()
            .with_prompt("Arch Setup Options")
            .default(0)
            .items(&options)
            .interact()
            .unwrap();

        if selection == script_names.len() {
            break; // Exit option selected
        }

        // Get the selected script name (remove numbering)
        let script_name = &scripts[selection];
        run_script(script_name);
    }
}

fn run_script(script_name: &str) {
    println!("Running {}...", script_name);

    // Execute the script using bash
    let status = Command::new("bash")
        .arg(format!("{}/{}.sh", SCRIPT_DIR, script_name))
        .status()
        .expect("Failed to run script");

    if status.success() {
        println!("{} completed successfully.", script_name);
    } else {
        println!("{} failed to complete.", script_name);
    }

    // Wait for user input to continue
    println!("Press Enter to return to the menu...");
    let _ = std::io::stdin().read_line(&mut String::new());
}

fn display_help() {
    println!("{}", HELP_MESSAGE);
    // Wait for user input to return to the menu
    println!("Press Enter to return to the menu...");
    let _ = std::io::stdin().read_line(&mut String::new());
}
