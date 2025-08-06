use clap::CommandFactory;
use clap_complete::{Shell, generate};
use pico_args::Arguments;
use std::collections::BTreeMap;
use std::io::Cursor;
use toml::Value;
use xshell::{Shell as XShell, cmd};

mod args;

const HELP: &str = r#"
Usage: cargo xtask <COMMAND>

Commands:
  ci                  Run all CI checks
  completions         Generate shell completion scripts
  ogen                Generate overview.md (alias: generate-overview)
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

            // completions for Bash
            generate(Shell::Bash, &mut cmd, "carch", &mut Cursor::new(&mut buffer));
            sh.write_file("completions/bash/carch", &buffer)?;
            buffer.clear();

            // completions for Fish
            generate(Shell::Fish, &mut cmd, "carch", &mut Cursor::new(&mut buffer));
            sh.write_file("completions/fish/carch.fish", &buffer)?;
            buffer.clear();

            // completions for Zsh
            generate(Shell::Zsh, &mut cmd, "carch", &mut Cursor::new(&mut buffer));
            sh.write_file("completions/zsh/_carch", &buffer)?;

            println!("Completions generated successfully.");
            Ok(())
        }
        "generate-overview" | "ogen" => {
            println!("Generating overview.md...");

            let mut markdown = String::from("## Scripts Descriptions:\n\n");
            let mut categories: BTreeMap<String, Vec<(String, String)>> = BTreeMap::new();

            let desc_files = sh.read_dir("carch-core/src/modules")?;
            for entry in desc_files {
                let path = entry.as_path();
                if path.is_dir() {
                    let dir_name = path.file_name().unwrap().to_str().unwrap();
                    let desc_path = path.join("desc.toml");
                    if desc_path.exists() {
                        let content = sh.read_file(&desc_path)?;
                        let value: Value = toml::from_str(&content)?;
                        if let Some(table) = value.as_table() {
                            for (key, val) in table {
                                if let Some(inner_table) = val.as_table()
                                    && let Some(description) =
                                        inner_table.get("description").and_then(|v| v.as_str())
                                {
                                    let script_name = key.to_string();
                                    let script_description = description.to_string();
                                    categories
                                        .entry(dir_name.to_string())
                                        .or_default()
                                        .push((script_name, script_description));
                                }
                            }
                        }
                    }
                }
            }

            for (category, scripts) in categories {
                markdown.push_str(&format!("### {category}\n\n"));
                for (name, description) in scripts {
                    markdown.push_str(&format!("- **{name}**: *{description}*\n"));
                }
                markdown.push('\n');
            }

            sh.create_dir("docs")?;
            sh.write_file("docs/overview.md", &markdown)?;
            println!("overview.md generated successfully in docs/.");
            Ok(())
        }
        _ => {
            eprintln!("Invalid command: {cmd}");
            print!("{HELP}");
            Err(anyhow::anyhow!("Invalid command"))
        }
    }
}
