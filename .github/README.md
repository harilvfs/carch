<div align="center">

<img src="https://raw.githubusercontent.com/harilvfs/assets/refs/heads/main/carch/carch.jpg"/>

</div>

<br>

![CI](https://img.shields.io/github/actions/workflow/status/harilvfs/carch/ci.yml?branch=main&style=flat&color=1c1c29&labelColor=black&logo=github&logoColor=white)

[![deps status](https://img.shields.io/endpoint?url=https://deps.rs/repo/github/harilvfs/carch/status.json&style=flat-square&color=blue)](https://deps.rs/repo/github/harilvfs/carch)


<div align="center">

[![GitHub Issues][issues]][issues-link] [![Github Prs][prs]][pr-links] [![Github Commit][last-commit]][last-commit-link] [![Github Star][star]][star-link] [![Github Fork][fork]][fork-link] [![License][license]][license-link] \
[![Carch Downloads][downloads]][downloads-link] [![Crates][crates]][crates-link] [![Built with ratatui][built-with-ratatui]][ratatui-link] \
[![discord][discord]][discord-link] [![telegram]][telegram-link] \
[![github actions build status][check]][check-link] [![deps status][deps-badge]][deps] 

[Testing](https://carch.chalisehari.com.np/#how-to-use) •
[Installation](https://carch.chalisehari.com.np/getting-started/installation) • 
[Contributing](https://carch.chalisehari.com.np/project/contributing) • 
[Changelog](https://github.com/harilvfs/carch/blob/main/CHANGELOG.md) • 
[Docs](https://carch.chalisehari.com.np) •
[Preview ↗](https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/.github/preview.gif)

</div>

<br>

*[Carch](https://carch.chalisehari.com.np)* is collection of modular Bash scripts with a beautiful TUI (*built with* [`ratatui`](https://github.com/ratatui-org/ratatui)) to automate post-installation setup for Linux users.
It’s especially useful if you want to quickly start using your *favorite apps* with a clean and ready-to-use setup. (*Currently supports Arch & Fedora based distros*)

**Prerequisite:** `fzf` is required for the TUI interface in the Carch scripts. Make sure it’s installed before using Carch.

For more check out [docs](https://carch.chalisehari.com.np)

License: [MIT](https://github.com/harilvfs/carch/blob/main/LICENSE)

[check]: https://github.com/harilvfs/carch/actions/workflows/ci.yml/badge.svg
[check-link]: https://github.com/harilvfs/carch/actions/workflows/ci.yml

[issues]: https://img.shields.io/github/issues/harilvfs/carch?style=flat&color=1c1c29&logoColor=white&labelColor=black&logo=github
[issues-link]: https://github.com/harilvfs/carch/issues

[prs]: https://img.shields.io/github/issues-pr/harilvfs/carch?style=flat&color=1c1c29&logoColor=white&labelColor=black&logo=github
[pr-links]: https://github.com/harilvfs/carch/pulls

[last-commit]:https://img.shields.io/github/last-commit/harilvfs/carch?style=flat&logo=github&color=1c1c29&logoColor=white&labelColor=black
[last-commit-link]: https://github.com/harilvfs/carch/commits/main/

[star]: https://img.shields.io/github/stars/harilvfs/carch?style=flat&logo=apachespark&color=1c1c29&logoColor=white&labelColor=black
[star-link]: https://github.com/harilvfs/carch/stargazers

[fork]: https://img.shields.io/github/forks/harilvfs/carch?style=flat&color=1c1c29&logoColor=white&labelColor=black&logo=github
[fork-link]: https://github.com/harilvfs/carch/fork

[downloads]: https://img.shields.io/github/downloads/harilvfs/carch/total?style=flat&color=1c1c29&logoColor=white&labelColor=black&logo=github
[downloads-link]: https://github.com/harilvfs/carch/releases/latest

[crates]: https://img.shields.io/crates/v/carch?style=flat&logo=rust&color=1c1c29&logoColor=white&labelColor=black
[crates-link]: https://crates.io/crates/carch

[built-with-ratatui]: https://img.shields.io/badge/Built%20With-Ratatui-171b22?style=flat&logo=data:image/png;base64,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&logoColor=white&labelColor=black
[ratatui-link]: https://github.com/ratatui/ratatui

[discord]: https://img.shields.io/discord/757266205408100413.svg?label=Discord&logo=Discord&style=flat&color=1c1c29&logoColor=white&labelColor=black
[discord-link]: https://discord.com/invite/8NJWstnUHd

[deps-badge]: https://deps.rs/repo/github/harilvfs/carch/status.svg?path=%2F&subject=deps%3Acore&style=flat
[deps]: https://deps.rs/repo/github/harilvfs/carch?path=%2F

[telegram]: https://img.shields.io/badge/Telegram-carchx-1c1c29?style=flat&labelColor=black&logo=telegram&logoColor=white
[telegram-link]: https://t.me/carchx

[license]: https://img.shields.io/github/license/harilvfs/carch?color=1c1c29&labelColor=black&style=flat&logo=github&logoColor=white
[license-link]: https://github.com/harilvfs/carch/blob/main/LICENSE 
