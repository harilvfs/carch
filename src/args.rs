use crate::error::{CarchError, Result};
use crate::{commands, version};
use clap::{ArgAction, Parser, Subcommand};
use env_logger::{Builder, Target};
use log::info;
use std::fs::{self, OpenOptions};

#[derive(Parser)]
#[command(author, about, long_about = None, version = env!("CARGO_PKG_VERSION"))]
#[command(disable_version_flag = true)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,
    #[arg(long, global = true, help = "Enable logging")]
    pub log:     bool,
    #[arg(long, global = true, help = "Set the theme [default: catppuccin]")]
    pub theme:   Option<String>,
    #[arg(short = 'v', long = "version", action = ArgAction::Version, help = "Print version information")]
    version:     Option<bool>,
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

#[derive(Clone, Default)]
pub struct Settings {
    pub log_mode: bool,
    pub theme:    Option<String>,
}

pub fn parse_args() -> Result<()> {
    let cli = Cli::parse();
    let mut settings = Settings::default();

    if cli.log {
        settings.log_mode = true;
        let log_dir = dirs::home_dir().ok_or(CarchError::HomeDirNotFound)?.join(".config/carch");
        fs::create_dir_all(&log_dir)?;
        let log_file = log_dir.join("carch.log");

        let file = OpenOptions::new().create(true).append(true).open(log_file)?;

        Builder::new()
            .target(Target::Pipe(Box::new(file)))
            .filter(None, log::LevelFilter::Info)
            .init();
        info!("Carch TUI started");
    }

    if let Some(theme) = cli.theme {
        settings.theme = Some(theme);
    }

    match cli.command {
        Some(Commands::CheckUpdate) => {
            info!("Checking for updates");
            version::check_for_updates()
        }
        Some(Commands::Update) => {
            info!("Running update process");
            commands::update()
        }
        Some(Commands::Uninstall) => {
            info!("Running uninstall process");
            commands::uninstall()
        }
        None => crate::run_tui(settings),
    }
}
