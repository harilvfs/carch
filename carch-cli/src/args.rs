use carch_core::error::{CarchError, Result};
use carch_core::{commands, version};
use clap::builder::styling::{AnsiColor, Style};
use clap::{ArgAction, Parser, Subcommand};
use env_logger::{Builder, Target};
use log::info;
use std::env;
use std::fs::{self, OpenOptions};
use std::path::PathBuf;

fn styles() -> clap::builder::Styles {
    clap::builder::Styles::styled()
        .header(Style::new().fg_color(Some(AnsiColor::Green.into())).bold())
        .usage(Style::new().fg_color(Some(AnsiColor::Green.into())).bold())
        .literal(Style::new().fg_color(Some(AnsiColor::Cyan.into())))
        .placeholder(Style::new().fg_color(Some(AnsiColor::Cyan.into())))
}

#[derive(Parser)]
#[command(author, about, long_about = None, styles = styles())]
pub struct Cli {
    #[command(subcommand)]
    pub command:          Option<Commands>,
    #[arg(
        short = 'l',
        long,
        global = true,
        help = "Enable logging, output is on ~/.config/carch/carch.log"
    )]
    pub log:              bool,
    #[arg(short = 'v', long = "version", action = ArgAction::Version, help = "Print version information")]
    #[arg(short = 'v', long = "version", action = ArgAction::SetTrue, help = "Print version information")]
    version:              bool,
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
}

#[derive(Clone, Default)]
pub struct Settings {
    pub log_mode:     bool,
    pub theme:        String,
    pub theme_locked: bool,
}

pub fn parse_args() -> Result<()> {
    let cli = Cli::parse();

    if cli.version {
        println!("{}", version::get_current_version());
        return Ok(());
    }

    let mut settings = Settings { ..Default::default() };

    if cli.log {
        settings.log_mode = true;
        let home_dir = env::var("HOME").map_err(|_| CarchError::HomeDirNotFound)?;
        let log_dir = PathBuf::from(home_dir).join(".config/carch");
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
        None => crate::run_tui(settings),
    }
}
