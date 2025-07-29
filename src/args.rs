use crate::error::{CarchError, Result};
use crate::{commands, version};
use clap::{ArgAction, CommandFactory, Parser, Subcommand};
use clap_complete::Shell;
use env_logger::{Builder, Target};
use log::info;
use std::fs::{self, OpenOptions};
use std::io;

#[derive(Parser)]
#[command(author, about, long_about = None, version = env!("CARGO_PKG_VERSION"))]
#[command(disable_version_flag = true)]
pub struct Cli {
    #[command(subcommand)]
    pub command:          Option<Commands>,
    #[arg(long, global = true, help = "Enable logging, output is on ~/.config/carch/carch.log")]
    pub log:              bool,
    #[arg(short = 'v', long = "version", action = ArgAction::Version, help = "Print version information")]
    version:              Option<bool>,
    #[arg(short = 'c', long, global = true, help = "Set theme to Catppuccin Mocha")]
    pub catppuccin_mocha: bool,
    #[arg(short = 'd', long, global = true, help = "Set theme to Dracula")]
    pub dracula:          bool,
    #[arg(short = 'g', long, global = true, help = "Set theme to Gruvbox")]
    pub gruvbox:          bool,
    #[arg(short = 'n', long, global = true, help = "Set theme to Nord")]
    pub nord:             bool,
    #[arg(short = 'r', long, global = true, help = "Set theme to Rosé Pine")]
    pub rose_pine:        bool,
}

#[derive(Subcommand)]
pub enum Commands {
    #[command(about = "Check for updates")]
    CheckUpdate,
    #[command(about = "Update the application")]
    Update,
    #[command(about = "Uninstall the application")]
    Uninstall,
    #[command(about = "Generate completions for a shell")]
    Completions {
        #[arg(value_enum)]
        shell: Shell,
    },
}

#[derive(Clone, Default)]
pub struct Settings {
    pub log_mode:     bool,
    pub theme:        String,
    pub theme_locked: bool,
}

pub fn parse_args() -> Result<()> {
    let cli = Cli::parse();
    let mut settings = Settings { ..Default::default() };

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

    if cli.catppuccin_mocha {
        settings.theme = "catppuccin-mocha".to_string();
        settings.theme_locked = true;
    } else if cli.dracula {
        settings.theme = "dracula".to_string();
        settings.theme_locked = true;
    } else if cli.gruvbox {
        settings.theme = "gruvbox".to_string();
        settings.theme_locked = true;
    } else if cli.nord {
        settings.theme = "nord".to_string();
        settings.theme_locked = true;
    } else if cli.rose_pine {
        settings.theme = "rose-pine".to_string();
        settings.theme_locked = true;
    } else {
        settings.theme = "catppuccin-mocha".to_string();
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
        Some(Commands::Completions { shell }) => {
            let mut cmd = Cli::command();
            let name = cmd.get_name().to_string();
            clap_complete::generate(shell, &mut cmd, name, &mut io::stdout());
            Ok(())
        }
        None => crate::run_tui(settings),
    }
}
