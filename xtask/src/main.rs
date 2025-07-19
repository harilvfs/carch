use pico_args::Arguments;
use xshell::{cmd, Shell};

const HELP: &str = r#"
Usage: cargo xtask <COMMAND>

Commands:
  ci    Run all CI checks
"#;

fn main() -> Result<(), anyhow::Error> {
    let mut args = Arguments::from_env();
    if args.contains(["-h", "--help"]) {
        print!("{}", HELP);
        return Ok(());
    }

    let sh = Shell::new()?;
    let cmd = args.subcommand()?.unwrap_or_else(|| "ci".to_string());

    match cmd.as_str() {
        "ci" => {
            cmd!(sh, "cargo +nightly fmt --all --check").run()?;
            cmd!(sh, "cargo +nightly clippy").run()?;
            cmd!(sh, "cargo +nightly clippy -- -D warnings").run()?;
            cmd!(sh, "cargo +nightly check --workspace --locked").run()?;
            cmd!(sh, "cargo +nightly check --workspace --locked --no-default-features").run()?;
            cmd!(sh, "cargo +nightly check --workspace --locked --all-features").run()?;
            cmd!(sh, "taplo fmt --check").run()?;

            if std::env::var("CI").is_err() && cmd!(sh, "which cargo-deny").run().is_ok() {
                cmd!(sh, "cargo deny check").run()?;
            }

            Ok(())
        }
        _ => {
            eprintln!("Invalid command: {}", cmd);
            print!("{}", HELP);
            Err(anyhow::anyhow!("Invalid command"))
        }
    }
}
