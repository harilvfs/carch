<div align="center">
 <img src="https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/assets/icons/product_logo_128.png" width="100" />
</div>

# Carch
A Simple Script That May Help You Automate Linux System Setups.

<details>
<summary><strong>Preview 👀</strong></summary>

![Preview](https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/.github/preview.gif)
  
</details>

Currently Supports Arch or Fedora Based Distros.

[![GitHub Issues][issues]][issues-link] [![Github Prs][prs]][pr-links] [![Github Commit][last-commit]][last-commit-link] [![Github Star][star]][star-link] [![Github Fork][fork]][fork-link] [![Carch Downloads][downloads]][downloads-link] [![Crates][crates]][crates-link] [![Carch Docs][carch-docs]][carch-docs-link]

## About

What the heck is this script btw? Good question tbh! It's none other than a bash script designed to be simple enough for anyone. Like, anyone can simply run it by selecting the options. What the heck does this actually do? You will see different scripts on the menu, separated or defined as categories like system, terminal, desktop, development.. etc. As for the categories, there you will see script names — like in terminal you will see something like `terminal/Kitty`. Then when you actually run the script, it will install Kitty as well as apply my preconfigured setup that is minimal, beautiful, and simple enough for everyone to use. Same as you will find different scripts there — just choose and run. The script will handle everything for you in just a few clicks, like installing a window manager or any other thing you find in the menu.

> [!NOTE]
> Yeah, the script is fully automated, but that doesn't mean it will work on every machine or system. Maybe your system has some very specific preconfigured setup, so maybe the script will not work there.
> As in the menu, you can see the preview of the scripts — you can always walk around to see what the script actually does.

Yeah, most scripts are stable, but if you find any bugs, errors, or anything else, please open a [bug report](https://github.com/harilvfs/carch/issues).  
Or if you have any feature suggestions or improvements from your side, you're always welcome to open a [feature request](https://github.com/harilvfs/carch/issues) too.

## Installation

Carch mainly supports two mainline distributions: Arch and Fedora Linux. For installation, run the following command in your terminal:

### Arch Linux

<pre><code>bash &lt;(curl -L https://chalisehari.com.np/arch)</code></pre>

### Fedora Linux

<pre><code>bash &lt;(curl -L https://chalisehari.com.np/fedora)</code></pre>

Yeah, it supports Arch and Fedora-based distros too. But if you get stuck in some problem, feel free to give feedback on the issues tab.

## Commands

Carch supports some commands too. You can view them by running:

<pre><code>carch --help</code></pre>

## Roadmap 

You can find the full roadmap in the Carch [documentation](https://carch-org.github.io/docs/project/roadmap.html)

## Contributing

PRs & any type of contributions are welcome. Before contributing, first read the contributing [guide](https://carch-org.github.io/docs/project/contributing.html)

## Code of Conduct

We make sure everyone has a welcoming environment for using Carch, as well as contributing or doing any other stuff. So make sure to follow our [code of conduct](https://carch-org.github.io/docs/project/codeofconduct.html)

## Contributors

We thank everyone who has contributed to Carch in various ways — reporting bugs, giving feedback for improvements, or contributing to Carch through PRs.

[![Contributors](https://contrib.rocks/image?repo=harilvfs/carch)](https://github.com/harilvfs/carch/graphs/contributors)

## Inspiration

Likewise, this project was created as a casual bash script as I was just tinkering here and there with scripting. Then after some time, I thought, why not make this script something useful to me or anyone else who wants to use it?

My main inspiration to shape this project is:

- **[ChrisTitusTech `linutil` project](https://github.com/ChrisTitusTech/linutil/)**
- **[ml4w](https://github.com/mylinuxforwork)** — ml4w's scripting logic is insanely good. I got many ideas from him.
- As well as some minor and many ideas from many people..

## Reach Me  
> Got a question or feedback? Hit me up via:  
>
> [Telegram](https://t.me/carchx) • [Discord](https://discord.com/invite/8NJWstnUHd) • [Email](mailto:harilvfs@chalisehari.com.np)

<br>

<div align="center">

Carch is [MIT licensed](https://github.com/harilvfs/carch/blob/main/LICENSE), so you're free to fork and use it as you like. Thank you!

</div>

[check]: https://github.com/harilvfs/carch/actions/workflows/release.yml/badge.svg
[link]: https://github.com/harilvfs/carch/actions/workflows/release.yml

[preview]: https://github.com/harilvfs/carch/actions/workflows/preview.yml/badge.svg
[link]: https://github.com/harilvfs/carch/actions/workflows/preview.yml

[issues]: https://img.shields.io/github/issues/harilvfs/carch?style=for-the-badge&color=dbb6ed&logoColor=85e185&labelColor=1c1c29&logo=data:image/png;base64,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
[issues-link]: https://github.com/harilvfs/carch/issues

[prs]: https://img.shields.io/github/issues-pr/harilvfs/carch?style=for-the-badge&color=ef9f9c&logoColor=85e185&labelColor=1c1c29&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAAsTAAALEwEAmpwYAAADCElEQVR4nO1Zu24TQRRdEiiCQDMh+QEKCioqKHgEIdEiRBGJEjoQVHxACBT0JCGAgEiQxEL5AqioCCA5Mw6SQVEgxjM2ysNeYsfxK+u9aIIX79rL4vVOVjzmSCMX9p47Z++9M54zmqagoPD/AFF2BxNeRoSnMOHPe2PJk9rfBERYAVMO9oEoH9dewW7PBwG6EGV3EeUl8RK0sBEF2PtiA25fWNL1AzGngLqIe798GKALE/7k528JK4Qy6b6Pa/sxZdcOx78OxMvw5m0J4GUBYCpnwtBaBY4tZB0iXMupafJ1sSOhCECUPRMB+yg35ooGfKgAWCIieRPG1k04upCxTyzSNPldiLL7jmwRPiFEhSIAE7ZgBX63uQXJLWgRITJhKw3ufAF8pLnUWgczEGEME/YQxb4clCpANJwVaHXLhFUDWkQ8zdXsb7f8u4b3GoiwPCKpszIFpC3y98Uq5GvQIuKxXg2YAe4chC/vi6b7pQgQ67xFfDmRhbIJDhHxCsC5T44emPbdAzPQLZofE55wLMtSBMwnT9mDX0pkYL5YhYxhwuvNKgwuZZyrEEkd73QVQpSfaXzPklIE1InHXdZ8l/rlo4H2gRnotje2NAFihxWblHfz8VEZOzG2cWqy0UvTJ8Q635SJiGvZdAi8kwLCCIKVgDagMuABrEqoDagS8gBWJdQGVAl5AKsS+pdLCM+xAfsBp344kWJsYRduTRqi0T2YsAeef6fbMbZ8cmuy4BbA9UDjZWz54MYxDofiy6UrK7Vbgwx6gqfWRn7+cxYm9CpM5mrtG1s+uafrftNQxoSrK7XZQCLsdXkxkfVvbAXkHvohYliKrTJbqPo2toJyj62bcHoxq3dsCGPCK1YQ4UT4NbaCck/lTOijKSu7xR0xth5lG8aW8HbCMs2kGFsi0HWesweZDM00C2JsfTMagYbTG4uWl+PHoZBimnVqbPXHONzgur5qwE0G0LM9GcKPyODGfk2zTo0tKbcsskwzP8aWaKbtSz6J91y9Tu6K+JRtmikoKGh/Lr4DXsKprenuoWcAAAAASUVORK5CYII="
[pr-links]: https://github.com/harilvfs/carch/pulls

[last-commit]:https://img.shields.io/github/last-commit/harilvfs/carch?style=for-the-badge&logo=github&color=7dc4e4&logoColor=D9E0EE&labelColor=1c1c29
[last-commit-link]: https://github.com/harilvfs/carch/commits/main/

[star]: https://img.shields.io/github/stars/harilvfs/carch?style=for-the-badge&logo=apachespark&color=eed49f&logoColor=D9E0EE&labelColor=1c1c29
[star-link]: https://github.com/harilvfs/carch/stargazers

[fork]: https://img.shields.io/github/forks/harilvfs/carch?style=for-the-badge&color=9dc3ea&logoColor=D9E0EE&labelColor=1c1c29&logo=data:image/png;base64,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
[fork-link]: https://github.com/harilvfs/carch/fork

[downloads]: https://img.shields.io/github/downloads/harilvfs/carch/total?style=for-the-badge&color=e0ea9d&logoColor=D9E0EE&labelColor=171b22&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFAAAABQCAMAAAC5zwKfAAAAb1BMVEVHcEz/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/////HUT/H0X/LlL/JEr/tsP/Pl//1Nv/yNL/mKr/8fP/SWj/a4T//P3/hpv/q7n/xM7/5On/VHFabXB/AAAAEXRSTlMA+q0VzSFh4ZF21wntVTI1yUkGfC4AAAMdSURBVFjDvZnp1qowDEVpKYKKYDAMH4KC+v7PeAs40hHEe364FOteaZukTXQcrdx4FVDmhwSAhD6jwSp2ndnydsG+Q72LhPtg582huTvqj2BPqE93U+301kxBG5CErb1JuA0YtbFGblcMrMRWWxteRAlYitDIwjwfJsg3GekGBCaJBNr99ihMFVLN3sQMpgtZrORtYJY28bI8FdFjMFtMso4uhS9Ehb3eBt/wAIOxP64M/ocmf1yN4k0fH4hpinqm/xGFW8MCZk1ZNplhGbcTJnw6J8n5hNaTNnpMm3C19r6zNgzN8g6YG+YM66eBm2WAG8/SQFvgw0SXLQVkQ7zsyFJAsuuB5iC2BQLtt8RfDuh7VjO2B/Zztkgz1kAI+B7vdTkBRSDqssTedeJQbVhdpygA+dNMiQxjdV7AtK2qvMBPIBZ5VbUpqjOEcgmx6ShlR3wBsSi7t40SGGi8sE8xPfEJvPM0iYc6TG9hT3wAsbgMz5QWAnOUbo3p/deXAgYgPHgX5RqC76g3+WnPpRiAr89qxwkdTZw8ieVf9/pnwQPiaA+7B/FdWh6AAxOJBh44ZBrRxCOaTZERTTy+KaZs+EE08rjbyB37cDigSHzxkA9QOLYs9DA7NacURX98Pkr5AGnOofLk0JyTczsmvvNaPqCRZ1hJ+sLiyn9f3fD1IH9ksuHzreIDrpIF5elLkmCx7safT4e3uL7d3uL30F2ekqoWgWEkOwJEIBw+Er8ayI8AySJKgCMfUAID6TE6H9gfo+JBPx/YH/SiJ1oCxV0mVH5ZGtwmadTA/nSQAHeK61w6JNQaFar770vhILhf5yQXzuHAu7ZHqdp+AslReScWrsRDJCTnRKe3SBpfiUUTs2Ni1DFTXtrFsoJHv4mXiyvoaQofTJurDnc9CryPak8szRDqJi//pCrzpharyY/STFY8ImapQpnkiuhHFuWtyg8tyttvC3AQCvDvWgRI3d83MfjGzG+zRP+nEcRtnDVrFi3aTAPq/c923/INyeVbpj9o6i7fdh6Qe+3EJzbGf9C6/8GfC3c7o/HfH5HBtn+wIlvD5rLlkQAAAABJRU5ErkJggg==
[downloads-link]: https://github.com/harilvfs/carch/releases/tag/v4.1.5

[crates]: https://img.shields.io/crates/v/carch?style=for-the-badge&logo=rust&color=f5a97f&logoColor=fe640b&labelColor=171b22
[crates-link]: https://crates.io/crates/carch

[carch-docs]: https://img.shields.io/badge/CARCH-DOCS-90EE90?style=for-the-badge&labelColor=1c1c29&logo=data:image/png;base64,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
[carch-docs-link]: https://carch-org.github.io/docs
