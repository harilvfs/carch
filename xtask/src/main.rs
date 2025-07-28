use pico_args::Arguments;
use xshell::{Shell, cmd};

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
            cmd!(sh, "cargo deny check").run()?;
            Ok(())
        }
        "completions" => {
            println!("Building carch binary...");
            cmd!(sh, "cargo build --release").run()?;
            let carch_bin = sh.current_dir().join("build/release/carch");

            println!("Generating completions...");
            let bash_completions = cmd!(sh, "{carch_bin} completions bash").read()?;
            sh.write_file("completions/bash/carch", bash_completions)?;

            let fish_completions = cmd!(sh, "{carch_bin} completions fish").read()?;
            sh.write_file("completions/fish/carch.fish", fish_completions)?;

            let zsh_completions = cmd!(sh, "{carch_bin} completions zsh").read()?;
            sh.write_file("completions/zsh/_carch", zsh_completions)?;

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
