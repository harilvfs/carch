use dialoguer::Select;
use std::{env, fs, process::Command};

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

    // Get the current working directory
    let current_dir = env::current_dir().expect("Failed to get current directory");
    let script_dirs = vec![
        current_dir.join("scripts"),       // Relative path from the root
        current_dir.join("../scripts"),    // Relative path from the src directory
    ];

    // Iterate over each script directory and load scripts
    for script_dir in script_dirs {
        if let Ok(entries) = fs::read_dir(&script_dir) { // Borrow script_dir
            for entry in entries.filter_map(Result::ok) {
                let path = entry.path();
                if let Some(file_name) = path.file_name() {
                    if let Some(name) = file_name.to_str() {
                        if name.ends_with(".sh") {
                            // Trim the ".sh" extension and push to the scripts vector
                            let script_name = name.trim_end_matches(".sh");
                            scripts.push(script_name.to_string());
                        }
                    }
                }
            }
        } else {
            eprintln!("Failed to read the directory: {:?}", script_dir.clone()); // Clone here
        }
    }

    // Debugging output to verify scripts loaded
    println!("Scripts found: {:?}", scripts);

    scripts
}

fn display_submenu() {
    loop {
        let scripts = load_scripts(); // Load scripts each time the submenu is displayed

        if scripts.is_empty() {
            println!("No scripts found.");
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

    // Determine the script path based on the current working directory
    let current_dir = env::current_dir().expect("Failed to get current directory");
    let script_paths = vec![
        current_dir.join("scripts").join(format!("{}.sh", script_name)),
        current_dir.join("../scripts").join(format!("{}.sh", script_name)),
    ];

    let mut script_found = false;

    for script_path in script_paths {
        if script_path.exists() {
            let status = Command::new("bash")
                .arg(script_path)
                .status()
                .expect("Failed to run script");

            if status.success() {
                println!("{} completed successfully.", script_name);
            } else {
                println!("{} failed to complete.", script_name);
            }
            script_found = true;
            break; // Exit after finding and executing the first valid script
        }
    }

    if !script_found {
        println!("Script '{}' not found in either directory.", script_name);
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

