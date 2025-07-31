use clap::{ArgAction, Parser, Subcommand};

#[derive(Parser)]
#[command(author, about, long_about = None, version = env!("CARGO_PKG_VERSION"))]
#[command(disable_version_flag = true)]
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
}
