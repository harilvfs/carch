use clap::CommandFactory;
use clap_complete::{Shell, generate};
use pico_args::Arguments;
use std::io::Cursor;
use xshell::{Shell as XShell, cmd};

mod args;

const HELP: &str = r#"
Usage: cargo xtask <COMMAND>

Commands:
  ci           Run all CI checks
  completions  Generate shell completion scripts
"#;

fn main() -> Result<(), anyhow::Error> {
    let mut args = Arguments::from_env();
    if args.contains(["-h", "--help"]) {
        print!("{HELP}");
        return Ok(());
    }

    let sh = XShell::new()?;
    let cmd = args.subcommand()?.unwrap_or_else(|| "ci".to_string());
    match cmd.as_str() {
        "ci" => {
            cmd!(sh, "cargo +nightly fmt --all --check").run()?;
            cmd!(sh, "cargo +nightly clippy --workspace").run()?;
            cmd!(sh, "cargo +nightly clippy --workspace -- -D warnings").run()?;
            cmd!(sh, "cargo +nightly check --workspace --locked").run()?;
            cmd!(sh, "cargo +nightly check --workspace --locked --no-default-features").run()?;
            cmd!(sh, "cargo +nightly check --workspace --locked --all-features").run()?;
            cmd!(sh, "taplo fmt --check").run()?;
            cmd!(sh, "cargo deny check").run()?;
            Ok(())
        }
        "completions" => {
            println!("Generating completions...");

            let mut cmd = crate::args::Cli::command();
            let mut buffer = Vec::new();

            // generate completions for Bash
            generate(Shell::Bash, &mut cmd, "carch", &mut Cursor::new(&mut buffer));
            sh.write_file("completions/bash/carch", &buffer)?;
            buffer.clear();

            // generate completions for Fish
            generate(Shell::Fish, &mut cmd, "carch", &mut Cursor::new(&mut buffer));
            sh.write_file("completions/fish/carch.fish", &buffer)?;
            buffer.clear();

            // generate completions for Zsh
            generate(Shell::Zsh, &mut cmd, "carch", &mut Cursor::new(&mut buffer));
            sh.write_file("completions/zsh/_carch", &buffer)?;

            println!("Completions generated successfully.");
            Ok(())
        }
        _ => {
            eprintln!("Invalid command: {cmd}");
            print!("{HELP}");
            Err(anyhow::anyhow!("Invalid command"))
        }
    }
}
