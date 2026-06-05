use crate::commands;
use crate::state::{clear_favorite_theme, load_favorite_theme, save_favorite_theme};
use carch_core::error::{CarchError, Result};
use carch_core::{VALID_THEMES, is_valid_theme, version};
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
    /// Save the given theme as favorite and exit.
    #[arg(long, global = true, value_name = "THEME")]
    pub fav:              Option<String>,
    /// Clear the saved favorite theme.
    #[arg(long, global = true, conflicts_with = "fav")]
    pub unfav:            bool,
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

    if let Some(theme) = cli.fav.as_deref() {
        if !is_valid_theme(theme) {
            return Err(CarchError::Command(format!(
                "Unknown theme '{theme}'. Valid themes: {}",
                VALID_THEMES.join(", ")
            )));
        }
        return save_favorite_theme(theme).map(|()| {
            println!("Favorite theme set to '{theme}'. It will be used on future launches.");
        });
    }
    if cli.unfav {
        match clear_favorite_theme() {
            Ok(true) => println!("Favorite theme cleared."),
            Ok(false) => println!("No favorite theme was set."),
            Err(e) => return Err(e),
        }
        return Ok(());
    }

    let mut settings = Settings::default();

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

    let explicit_theme =
        cli.catppuccin_mocha || cli.dracula || cli.gruvbox || cli.nord || cli.rose_pine;

    settings.theme = if cli.catppuccin_mocha {
        "catppuccin-mocha".to_string()
    } else if cli.dracula {
        "dracula".to_string()
    } else if cli.gruvbox {
        "gruvbox".to_string()
    } else if cli.nord {
        "nord".to_string()
    } else if cli.rose_pine {
        "rose-pine".to_string()
    } else if let Some(fav) = load_favorite_theme() {
        // Saved favorite is locked so `t` can't overwrite it.
        settings.theme_locked = true;
        fav
    } else {
        "catppuccin-mocha".to_string()
    };

    if explicit_theme {
        settings.theme_locked = true;
    }

    match cli.command {
        Some(Commands::CheckUpdate) => {
            info!("Checking for updates");
            commands::check_for_updates()
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
