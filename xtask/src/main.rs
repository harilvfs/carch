use std::collections::BTreeMap;
use std::fmt::Write as _;

use clap::CommandFactory;
use pico_args::Arguments;
use toml::Value;
use xshell::{Shell as XShell, cmd};

const HELP: &str = r"
Usage: cargo xtask <COMMAND>

Commands:
  ci                  Run all CI checks
  ogen                Generate overview.md (alias: generate-overview)
  man                 Generate manpage from clap definitions
";

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
            cmd!(sh, "cargo +nightly test --workspace --locked").run()?;
            cmd!(sh, "taplo fmt --check").run()?;
            cmd!(sh, "cargo deny check").run()?;
            Ok(())
        }
        "generate-overview" | "ogen" => {
            println!("Generating overview.md...");

            let mut markdown = String::from("## Overview:\n\n");
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
                                    categories
                                        .entry(dir_name.to_string())
                                        .or_default()
                                        .push((key.clone(), description.to_string()));
                                }
                            }
                        }
                    }
                }
            }

            for (category, scripts) in categories {
                let _ = writeln!(markdown, "### {category}\n");
                for (name, description) in scripts {
                    let _ = writeln!(markdown, "- **{name}**: *{description}*");
                }
                markdown.push('\n');
            }

            sh.create_dir("docs")?;
            sh.write_file("docs/overview.md", &markdown)?;
            println!("overview.md generated successfully in docs/.");
            Ok(())
        }
        "man" => {
            let mut cmd = carch_cli::args::Cli::command();
            cmd = cmd.name("carch");

            let date = std::process::Command::new("date")
                .arg("+%B %d, %Y")
                .output()
                .ok()
                .and_then(|o| String::from_utf8(o.stdout).ok())
                .map(|s| s.trim().to_string())
                .unwrap_or_else(|| "June 18, 2026".into());

            let man = clap_mangen::Man::new(cmd.clone())
                .title("carch")
                .section("1")
                .date(&date)
                .source("Carch")
                .manual("Carch");

            let out_dir = sh.current_dir();
            let man_path = out_dir.join("man/carch.1");
            sh.create_dir("man")?;

            use std::io::Write;
            let mut buf = Vec::new();
            man.render(&mut buf)?;
            let mut content = String::from_utf8(buf)?;

            for sub in cmd.get_subcommands() {
                let name = sub.get_name();
                let escaped = name.replace('-', "\\-");
                let old = format!("carch\\-{escaped}(1)");
                let new = format!("\\fB{name}\\fR");
                content = content.replace(&old, &new);
            }
            content = content.replace("carch\\-help(1)", "\\fBhelp\\fR");

            let mut file = std::fs::File::create(&man_path)?;
            file.write_all(content.as_bytes())?;
            writeln!(
                file,
                r#".SH DOCUMENTATION
Comprehensive documentation for Carch is available at:
.br
https://carch.chalisehari.com.np

.SH AUTHOR
Hari Chalise <harilvfs@chalisehari.com.np>

.SH REPORTING BUGS
If you encounter bugs or issues, please report them at:
.br
https://github.com/harilvfs/carch/issues
"#
            )?;

            println!("Manpage generated at {}", man_path.display());
            Ok(())
        }
        _ => {
            eprintln!("Invalid command: {cmd}");
            print!("{HELP}");
            Err(anyhow::anyhow!("Invalid command"))
        }
    }
}
