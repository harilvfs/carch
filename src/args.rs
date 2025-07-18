use crate::{commands, version};
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    pub command:    Option<Commands>,
    #[arg(long, global = true, help = "Enable logging")]
    pub log:        bool,
    #[arg(long, global = true, help = "Disable cache cleanup")]
    pub no_cleanup: bool,
}

#[derive(Subcommand)]
pub enum Commands {
    #[command(about = "Check for updates")]
    CheckUpdate,
    #[command(about = "Update the application")]
    Update,
    #[command(about = "Uninstall the application")]
    Uninstall,
}

#[derive(Copy, Clone)]
pub struct Settings {
    pub show_preview:  bool,
    pub log_mode:      bool,
    pub cleanup_cache: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Self { show_preview: true, log_mode: false, cleanup_cache: true }
    }
}

pub fn parse_args() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();
    let mut settings = Settings::default();

    if cli.log {
        settings.log_mode = true;
        let _ = commands::log_message("INFO", "Carch application started");
    }

    if cli.no_cleanup {
        settings.cleanup_cache = false;
        if settings.log_mode {
            let _ = commands::log_message("INFO", "Cache cleanup disabled");
        }
    }

    match cli.command {
        Some(Commands::CheckUpdate) => {
            if settings.log_mode {
                let _ = commands::log_message("INFO", "Checking for updates");
            }
            version::check_for_updates().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
        }
        Some(Commands::Update) => {
            if settings.log_mode {
                let _ = commands::log_message("INFO", "Running update process");
            }
            commands::update().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
        }
        Some(Commands::Uninstall) => {
            if settings.log_mode {
                let _ = commands::log_message("INFO", "Running uninstall process");
            }
            commands::uninstall().map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
        }
        None => crate::run_tui(settings),
    }
}
