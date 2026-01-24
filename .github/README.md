<div align="center">

[![Built Wit Ratatui][ratatui]][ratatui-link]
[![Build Status][check]][check-link]
[![Crates.io][crates]][crates-link]
[![Downloads][downloads]][downloads-link]
[![License][license]][license-link]

</div>

_[Carch](https://carch.chalisehari.com.np)_ is **a collection** of modular Bash scripts with a beautiful TUI (_built with_ [`ratatui`](https://github.com/ratatui-org/ratatui)) to automate post-installation setup for Linux users.
It’s especially useful if you want to quickly set up and start using your _favorite apps_ on a clean, ready-to-use system. (_Currently supports Arch, Fedora, and openSUSE-based distros_)

<div align="center">

[Overview](https://carch.chalisehari.com.np/reference/overview-scripts) •
[Installation](https://carch.chalisehari.com.np/getting-started/installation) •
[Contributing](https://carch.chalisehari.com.np/project/contributing) •
[Changelog ⇢](https://github.com/harilvfs/carch/blob/main/CHANGELOG.md)

</div>

<img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/.github/preview.gif"/>

<h3> Quick Run/Test </h3>

<h4> Stable Release </h4>

```sh
bash -c "$(curl -fsSL chalisehari.com.np/carch)"
```

<h4> Dev Release </h4>

```sh
bash -c "$(curl -fsSL chalisehari.com.np/carch)" -- --dev
```

For more, see the [documentation](https://carch.chalisehari.com.np). You can also join us on [Discord](https://discord.com/invite/8NJWstnUHd) or [Telegram](https://t.me/carchx) for help and discussions.

<!-- Catppuccin Footer -->
<!-- Source: https://github.com/catppuccin/catppuccin -->

<p align="center">
	<img src="https://raw.githubusercontent.com/harilvfs/assets/refs/heads/main/carch/catppuccin-footer.svg" />
</p>

<!-- Badges -->

[ratatui]: https://img.shields.io/badge/Built_With-Ratatui-000?logo=ratatui&logoColor=fff&labelColor=000&color=fff
[ratatui-link]: https://ratatui.rs/
[check]: https://img.shields.io/github/actions/workflow/status/harilvfs/carch/ci.yml?branch=main&style=flat&color=fff&labelColor=000&logo=GitHub%20Actions&logoColor=fff&label=CI
[check-link]: https://github.com/harilvfs/carch/actions/workflows/ci.yml
[downloads]: https://img.shields.io/github/downloads/harilvfs/carch/total?style=flat&color=fff&logoColor=fff&labelColor=000&logo=github
[downloads-link]: https://github.com/harilvfs/carch/releases/latest
[crates]: https://img.shields.io/crates/v/carch-cli?style=flat&logo=rust&color=fff&logoColor=fff&labelColor=000
[crates-link]: https://crates.io/crates/carch-cli
[license]: https://img.shields.io/github/license/harilvfs/carch?color=fff&labelColor=000&style=flat&logo=github&logoColor=fff
[license-link]: https://github.com/harilvfs/carch/blob/main/LICENSE
