use crate::commands;
use crate::state::{clear_favorite_theme, load_favorite_theme, save_favorite_theme};
use carch_core::error::{CarchError, Result};
use carch_core::{VALID_THEMES, is_valid_theme, version};
use clap::builder::styling::{AnsiColor, Style};
use clap::{ArgAction, CommandFactory, Parser, Subcommand};
use env_logger::{Builder, Target};
use log::info;
use std::env;
use std::fs::{self, OpenOptions};
use std::path::PathBuf;
use std::time::{SystemTime, UNIX_EPOCH};

fn timestamped_log_filename() -> String {
    let secs = SystemTime::now().duration_since(UNIX_EPOCH).map(|d| d.as_secs()).unwrap_or(0);

    let days = (secs / 86400) as i64 + 719468;
    let era = days.div_euclid(146097);
    let doe = (days - era * 146097) as u64;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let year_era = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let day = (doy - (153 * mp + 2) / 5 + 1) as u32;
    let month = if mp < 10 { mp + 3 } else { mp - 9 } as u32;
    let year = (year_era + if month <= 2 { 1 } else { 0 }) as u32;

    let tod = secs % 86400;
    let hour = (tod / 3600) as u32;
    let minute = ((tod % 3600) / 60) as u32;
    let second = (tod % 60) as u32;

    format!("carch-{year:04}{month:02}{day:02}-{hour:02}{minute:02}{second:02}.log")
}

const MAX_LOG_FILES: usize = 5;

fn rotate_logs(log_dir: &std::path::Path) {
    let mut logs: Vec<PathBuf> = fs::read_dir(log_dir)
        .into_iter()
        .flatten()
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .filter(|p| p.extension().is_some_and(|ext| ext == "log"))
        .collect();

    logs.sort();

    if logs.len() > MAX_LOG_FILES {
        for old in &logs[..logs.len() - MAX_LOG_FILES] {
            let _ = fs::remove_file(old);
        }
    }
}

fn styles() -> clap::builder::Styles {
    clap::builder::Styles::styled()
        .header(Style::new().fg_color(Some(AnsiColor::Green.into())).bold())
        .usage(Style::new().fg_color(Some(AnsiColor::Green.into())).bold())
        .literal(Style::new().fg_color(Some(AnsiColor::Cyan.into())))
        .placeholder(Style::new().fg_color(Some(AnsiColor::Cyan.into())))
}

#[derive(Parser)]
#[command(
    author,
    about = "A CLI tool to streamline and automate Linux system’s initial setup",
    styles = styles()
)]
pub struct Cli {
    #[command(subcommand)]
    pub command:   Option<Commands>,
    #[arg(short = 'v', long = "version", action = ArgAction::SetTrue, help = "Print version information")]
    version:       bool,
    #[arg(
        long,
        global = true,
        value_name = "THEME",
        help = "Set and persist theme (catppuccin-mocha, dracula, gruvbox, nord, rose-pine, or default to reset)"
    )]
    pub set_theme: Option<String>,
}

#[derive(Subcommand)]
pub enum Commands {
    #[command(about = "Install shell completions, man page, and desktop file")]
    Setup {
        #[arg(long, help = "Preview what would be installed without writing files")]
        dry_run: bool,
    },
    #[command(about = "Check for updates")]
    CheckUpdate,
    #[command(about = "Update the application")]
    Update,
    #[command(about = "Uninstall the application")]
    Uninstall,
    #[command(about = "Generate shell completions (bash, zsh, fish)")]
    Completions {
        #[arg(value_enum, help = "Shell to generate completions for")]
        shell: clap_complete::Shell,
    },
}

#[derive(Clone, Default)]
pub struct Settings {
    pub log_mode:     bool,
    pub theme:        String,
    pub theme_locked: bool,
    pub log_path:     Option<String>,
}

pub fn parse_args() -> Result<()> {
    let cli = Cli::parse();

    if cli.version {
        println!("{}", version::get_current_version());
        return Ok(());
    }

    let mut settings = Settings { log_mode: true, ..Default::default() };

    if let Some(theme) = &cli.set_theme {
        if theme == "default" {
            let _ = clear_favorite_theme();
            println!("Default theme restored.");
        } else if is_valid_theme(theme) {
            save_favorite_theme(theme)?;
            println!("{theme} has been set as your default theme.");
        } else {
            return Err(CarchError::Command(format!(
                "Unknown theme '{theme}'. Valid themes: {}",
                VALID_THEMES.join(", ")
            )));
        }
        return Ok(());
    } else if let Some(fav) = load_favorite_theme() {
        settings.theme = fav;
        settings.theme_locked = true;
    } else {
        settings.theme = "catppuccin-mocha".to_string();
    }

    match cli.command {
        Some(Commands::Setup { dry_run }) => crate::setup::run_setup(dry_run),
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
        Some(Commands::Completions { shell }) => {
            let mut cmd = Cli::command();
            clap_complete::generate(shell, &mut cmd, "carch", &mut std::io::stdout());
            Ok(())
        }
        None => {
            let home_dir = env::var("HOME").map_err(|_| CarchError::HomeDirNotFound)?;
            let log_dir = PathBuf::from(home_dir).join(".config/carch");
            fs::create_dir_all(&log_dir)?;
            let log_file = log_dir.join(timestamped_log_filename());

            let file =
                OpenOptions::new().create(true).write(true).truncate(true).open(&log_file)?;

            Builder::new()
                .target(Target::Pipe(Box::new(file)))
                .filter(None, log::LevelFilter::Info)
                .init();
            info!("Carch TUI started");

            rotate_logs(&log_dir);

            settings.log_path = Some(log_file.display().to_string());
            let result = crate::run_tui(settings);

            let has_issues = fs::read_to_string(&log_file)
                .map(|content| {
                    content.lines().any(|line| {
                        line.contains("error") || line.contains("failed") || line.contains("Failed")
                    })
                })
                .unwrap_or(false);

            if has_issues || result.is_err() {
                println!("Log saved: {}", log_file.display());
            }

            result
        }
    }
}
