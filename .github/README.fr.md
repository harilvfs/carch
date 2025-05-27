[![lang: 🇫🇷 Français](https://img.shields.io/badge/lang-%F0%9F%87%AB%F0%9F%87%B7%20Français-ccd0da?logoColor=179299&labelColor=1c1c29)](https://github.com/harilvfs/carch/blob/main/.github/README.fr.md)

# Carch

Une collection de scripts Bash modulaires avec une belle interface utilisateur textuelle (*construite avec* [`ratatui`](https://github.com/ratatui-org/ratatui)) pour automatiser la configuration post-installation pour les utilisateurs Linux.  
C’est particulièrement utile si vous souhaitez démarrer rapidement avec vos *applications préférées* dans une configuration propre et prête à l’emploi.

*Prend actuellement en charge les distributions basées sur Arch et Fedora.*

<details>
<summary><strong>Aperçu</strong></summary>

![Aperçu](https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/.github/preview.gif)
  
</details>

[![Créé sur GitHub][create]][create-link] [![Problèmes GitHub][issues]][issues-link] [![PR GitHub][prs]][pr-links] [![Dernier commit][last-commit]][last-commit-link] [![Étoile GitHub][star]][star-link] [![Fork GitHub][fork]][fork-link] [![Téléchargements Carch][downloads]][downloads-link] [![Crates][crates]][crates-link] [![Discord][discord]][discord-link]

[![Statut du build GitHub Actions][check]][check-link]

<h4>

Pour les instructions d’installation, l’utilisation, les commandes et plus, consultez le [*site officiel de la documentation Carch*](https://carch.chalisehari.com.np/) disponible en :  [ 🇺🇸 ](https://carch.chalisehari.com.np) • [ 🇳🇵 ](https://carch.chalisehari.com.np/ne/) • [ 🇮🇳 ](https://carch.chalisehari.com.np/hi/) • [ 🇨🇳 ](https://carch.chalisehari.com.np/zh/) • [ 🇪🇸 ](https://carch.chalisehari.com.np/es/) • [ 🇦🇪 ](https://carch.chalisehari.com.np/ar/) • [ 🇫🇷 ](https://carch.chalisehari.com.np/fr/) • [ 🇰🇷 ](https://carch.chalisehari.com.np/ko/) • [ 🇩🇪 ](https://carch.chalisehari.com.np/de/) • [ 🇷🇺 ](https://carch.chalisehari.com.np/ru/)

</h4>

## 🙏 Contributeurs

Merci à tous les contributeurs !

[![Contributeurs](https://contrib.rocks/image?repo=harilvfs/carch)](https://github.com/harilvfs/carch/graphs/contributors)

## 💡 Inspiration

- [linutil de ChrisTitusTech](https://github.com/ChrisTitusTech/linutil)
- [ml4w](https://github.com/mylinuxforwork)
- Et la communauté plus large des scripts Linux.

## 📬 Contactez-moi

<a href="https://t.me/carchx" target="blank"><img src="https://github.com/harilvfs/DevIcons/blob/main/badges/badges_telegram.png?raw=true" width="45px"/></a>
<a href="https://discord.com/invite/8NJWstnUHd" target="blank"><img src="https://github.com/harilvfs/DevIcons/blob/main/badges/badges_discord.png?raw=true" width="45px"/></a>
<a href="mailto:harilvfs@chalisehari.com.np" target="_blank"><img src="https://github.com/harilvfs/DevIcons/blob/main/badges/badges_gmail.png?raw=true" alt="Mail" width="45px" /></a>

## ❤️ Support

Carch est gratuit et open-source. Si vous souhaitez soutenir son développement :

**Adresse Bitcoin**  
`bc1qaqpf4ptl9cwnhpmm4m8qs5vp3gffm8dtpxnqhc2tq3r59hsz08vsxpjg2p`

![qr](https://github.com/user-attachments/assets/9ec7ef93-d51a-4eed-b59a-f150abfd41f0)

**Sous licence [MIT](https://github.com/harilvfs/carch/blob/main/LICENSE)**

[check]: https://github.com/harilvfs/carch/actions/workflows/ci.yml/badge.svg
[check-link]: https://github.com/harilvfs/carch/actions/workflows/ci.yml

[preview]: https://github.com/harilvfs/carch/actions/workflows/preview.yml/badge.svg
[preview-link]: https://github.com/harilvfs/carch/actions/workflows/preview.yml

[issues]: https://img.shields.io/github/issues/harilvfs/carch?style=for-the-badge&color=dbb6ed&logoColor=85e185&labelColor=1c1c29&logo=data:image/png;base64,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
[issues-link]: https://github.com/harilvfs/carch/issues

[prs]: https://img.shields.io/github/issues-pr/harilvfs/carch?style=for-the-badge&color=ef9f9c&logoColor=85e185&labelColor=1c1c29&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAAsTAAALEwEAmpwYAAADCElEQVR4nO1Zu24TQRRdEiiCQDMh+QEKCioqKHgEIdEiRBGJEjoQVHxACBT0JCGAgEiQxEL5AqioCCA5Mw6SQVEgxjM2ysNeYsfxK+u9aIIX79rL4vVOVjzmSCMX9p47Z++9M54zmqagoPD/AFF2BxNeRoSnMOHPe2PJk9rfBERYAVMO9oEoH9dewW7PBwG6EGV3EeUl8RK0sBEF2PtiA25fWNL1AzGngLqIe798GKALE/7k528JK4Qy6b6Pa/sxZdcOx78OxMvw5m0J4GUBYCpnwtBaBY4tZB0iXMupafJ1sSOhCECUPRMB+yg35ooGfKgAWCIieRPG1k04upCxTyzSNPldiLL7jmwRPiFEhSIAE7ZgBX63uQXJLWgRITJhKw3ufAF8pLnUWgczEGEME/YQxb4clCpANJwVaHXLhFUDWkQ8zdXsb7f8u4b3GoiwPCKpszIFpC3y98Uq5GvQIuKxXg2YAe4chC/vi6b7pQgQ67xFfDmRhbIJDhHxCsC5T44emPbdAzPQLZofE55wLMtSBMwnT9mDX0pkYL5YhYxhwuvNKgwuZZyrEEkd73QVQpSfaXzPklIE1InHXdZ8l/rlo4H2gRnotje2NAFihxWblHfz8VEZOzG2cWqy0UvTJ8Q635SJiGvZdAi8kwLCCIKVgDagMuABrEqoDagS8gBWJdQGVAl5AKsS+pdLCM+xAfsBp344kWJsYRduTRqi0T2YsAeef6fbMbZ8cmuy4BbA9UDjZWz54MYxDofiy6UrK7Vbgwx6gqfWRn7+cxYm9CpM5mrtG1s+uafrftNQxoSrK7XZQCLsdXkxkfVvbAXkHvohYliKrTJbqPo2toJyj62bcHoxq3dsCGPCK1YQ4UT4NbaCck/lTOijKSu7xR0xth5lG8aW8HbCMs2kGFsi0HWesweZDM00C2JsfTMagYbTG4uWl+PHoZBimnVqbPXHONzgur5qwE0G0LM9GcKPyODGfk2zTo0tKbcsskwzP8aWaKbtSz6J91y9Tu6K+JRtmikoKGh/Lr4DXsKprenuoWcAAAAASUVORK5CYII=
[pr-links]: https://github.com/harilvfs/carch/pulls

[last-commit]:https://img.shields.io/github/last-commit/harilvfs/carch?style=for-the-badge&logo=github&color=7dc4e4&logoColor=7dc4e4&labelColor=1c1c29
[last-commit-link]: https://github.com/harilvfs/carch/commits/main/

[star]: https://img.shields.io/github/stars/harilvfs/carch?style=for-the-badge&logo=apachespark&color=eed49f&logoColor=eed49f&labelColor=1c1c29
[star-link]: https://github.com/harilvfs/carch/stargazers

[fork]: https://img.shields.io/github/forks/harilvfs/carch?style=for-the-badge&color=f4b8e4&logoColor=D9E0EE&labelColor=1c1c29&logo=data:image/png;base64,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
[fork-link]: https://github.com/harilvfs/carch/fork

[downloads]: https://img.shields.io/github/downloads/harilvfs/carch/total?style=for-the-badge&color=a6d189&logoColor=D9E0EE&labelColor=171b22&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFAAAABQCAMAAAC5zwKfAAAAb1BMVEVHcEz/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/IUf/////HUT/H0X/LlL/JEr/tsP/Pl//1Nv/yNL/mKr/8fP/SWj/a4T//P3/hpv/q7n/xM7/5On/VHFabXB/AAAAEXRSTlMA+q0VzSFh4ZF21wntVTI1yUkGfC4AAAMdSURBVFjDvZnp1qowDEVpKYKKYDAMH4KC+v7PeAs40hHEe364FOteaZukTXQcrdx4FVDmhwSAhD6jwSp2ndnydsG+Q72LhPtg582huTvqj2BPqE93U+301kxBG5CErb1JuA0YtbFGblcMrMRWWxteRAlYitDIwjwfJsg3GekGBCaJBNr99ihMFVLN3sQMpgtZrORtYJY28bI8FdFjMFtMso4uhS9Ehb3eBt/wAIOxP64M/ocmf1yN4k0fH4hpinqm/xGFW8MCZk1ZNplhGbcTJnw6J8n5hNaTNnpMm3C19r6zNgzN8g6YG+YM66eBm2WAG8/SQFvgw0SXLQVkQ7zsyFJAsuuB5iC2BQLtt8RfDuh7VjO2B/Zztkgz1kAI+B7vdTkBRSDqssTedeJQbVhdpygA+dNMiQxjdV7AtK2qvMBPIBZ5VbUpqjOEcgmx6ShlR3wBsSi7t40SGGi8sE8xPfEJvPM0iYc6TG9hT3wAsbgMz5QWAnOUbo3p/deXAgYgPHgX5RqC76g3+WnPpRiAr89qxwkdTZw8ieVf9/pnwQPiaA+7B/FdWh6AAxOJBh44ZBrRxCOaTZERTTy+KaZs+EE08rjbyB37cDigSHzxkA9QOLYs9DA7NacURX98Pkr5AGnOofLk0JyTczsmvvNaPqCRZ1hJ+sLiyn9f3fD1IH9ksuHzreIDrpIF5elLkmCx7safT4e3uL7d3uL30F2ekqoWgWEkOwJEIBw+Er8ayI8AySJKgCMfUAID6TE6H9gfo+JBPx/YH/SiJ1oCxV0mVH5ZGtwmadTA/nSQAHeK61w6JNQaFar770vhILhf5yQXzuHAu7ZHqdp+AslReScWrsRDJCTnRKe3SBpfiUUTs2Ni1DFTXtrFsoJHv4mXiyvoaQofTJurDnc9CryPak8szRDqJi//pCrzpharyY/STFY8ImapQpnkiuhHFuWtyg8tyttvC3AQCvDvWgRI3d83MfjGzG+zRP+nEcRtnDVrFi3aTAPq/c923/INyeVbpj9o6i7fdh6Qe+3EJzbGf9C6/8GfC3c7o/HfH5HBtn+wIlvD5rLlkQAAAABJRU5ErkJggg==
[downloads-link]: https://github.com/harilvfs/carch/releases/latest

[crates]: https://img.shields.io/crates/v/carch?style=for-the-badge&logo=rust&color=f5a97f&logoColor=fe640b&labelColor=171b22
[crates-link]: https://crates.io/crates/carch

[built-with-ratatui]: https://img.shields.io/badge/BUILT%20WITH-RATATUI-94e2d5?style=for-the-badge&logo=rust&logoColor=89dceb&labelColor=171b22
[ratatui-link]: https://github.com/ratatui/ratatui

[rust]: https://github.com/harilvfs/carch/actions/workflows/rust.yml/badge.svg
[rust-link]: https://github.com/harilvfs/carch/actions/workflows/rust.yml

[shell]: https://github.com/harilvfs/carch/actions/workflows/shellcheck.yml/badge.svg
[shell-link]: https://github.com/harilvfs/carch/actions/workflows/shellcheck.yml

[create]: https://img.shields.io/github/created-at/harilvfs/carch?color=C6A0F6&labelColor=1c1c29&style=for-the-badge&logo=github&logoColor=C6A0F6
[create-link]: https://github.com/harilvfs/carch/commit/89fd0f272b47f55e8cd3ae4f4c3f45dc716bb918

[discord]: https://img.shields.io/discord/757266205408100413.svg?label=Discord&logo=Discord&style=for-the-badge&color=8bd5ca&logoColor=e78284&labelColor=1c1c29
[discord-link]: https://discord.com/invite/8NJWstnUHd