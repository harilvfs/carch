[![carch](https://raw.githubusercontent.com/harilvfs/assets/refs/heads/main/carch/carch.jpg)](https://carch.chalisehari.com.np)

## [5.2.4](https://github.com/harilvfs/carch/compare/v5.2.3...v5.2.4) - 2025-07-23


### 🚀 Features


- [3786272](https://github.com/harilvfs/carch/commit/3786272eb415c25089f977b7bff748bf0f7047dd)  *(script)* Add install script by @harilvfs

- [ca2a37f](https://github.com/harilvfs/carch/commit/ca2a37f8bbb6073fb6e00180aa17f37b4c36b7a7)  *(version)* Use reqwest for update checks by @harilvfs

- [e4e766b](https://github.com/harilvfs/carch/commit/e4e766b2e1e7e4a88cdd099139d936d67dc8b9c7)  *(opensuse)* Add slock/i3lock compatibility note and config by @harilvfs

- [1322b4a](https://github.com/harilvfs/carch/commit/1322b4aafad83a011cb8036bebc5e10f0e1222e8)  *(dev)* Introduce xtask for development tasks by @harilvfs

- [d5198d1](https://github.com/harilvfs/carch/commit/d5198d194cce5bba4fedf5423ba5c9fcac5bdee4)  *(search)* Using fuzzy matcher by @harilvfs

- [0784a6f](https://github.com/harilvfs/carch/commit/0784a6f0a18dde4388a0229b7c7df16386168161) Make cargo-deny conditional in xtask by @harilvfs

- [ced9a89](https://github.com/harilvfs/carch/commit/ced9a89ab6fa45354e2a751651bc3c02a7b07388)  *(package)* Add mpv player by @harilvfs

- [5c172fe](https://github.com/harilvfs/carch/commit/5c172fe2725faffd29c67cb1ff908976e701b9bb)  *(script)* Remove strict set -e ( unexpected happen ) by @harilvfs

- [b19f128](https://github.com/harilvfs/carch/commit/b19f1281b350e045dbbeed24ed60ebebb5c8ae9a)  *(tui)* Run scripts inside popup tui using portable pty (#530) by @harilvfs in [#530](https://github.com/harilvfs/carch/pull/530)

- [b196dcd](https://github.com/harilvfs/carch/commit/b196dcd7a5615d55e9d01a719e8d2a3e94d68ccb)  *(logging)* Capture script execution output in logs by @harilvfs



### 🐛 Bug Fixes


- [b7b8639](https://github.com/harilvfs/carch/commit/b7b86390875a5f6fd76497c62eed2bbb3ea23f4a)  *(pages)* Some typos man-pages by @harilvfs

- [7c81823](https://github.com/harilvfs/carch/commit/7c818238ed0e561bbee12692230d74b45f57fce2)  *(commands)* Correct package names for arch linux uninstallation by @harilvfs

- [5509727](https://github.com/harilvfs/carch/commit/550972720200ca04551b420c5628152b05112fd2)  *(ui)* Prevent unfocused panels from fading by @harilvfs

- [75cdc60](https://github.com/harilvfs/carch/commit/75cdc60d3a74c383bec3395be9421d5a99098bcf)  *(fmt)* Toml checks by @harilvfs

- [3bcc63a](https://github.com/harilvfs/carch/commit/3bcc63a7bf0bfd2207b8b7fa7b9e87af142dd654)  *(navigation)* My nonsense mistake by @harilvfs

- [1798e7c](https://github.com/harilvfs/carch/commit/1798e7c8c28aa54eb842a4a073c3d1f4c943de9e)  *(lint)* Correct clippy & fmt issue by @harilvfs

- [ffc5cdc](https://github.com/harilvfs/carch/commit/ffc5cdc3ba6d5b05cc19f8b3c1edbe0cdd80c0ff)  *(deps)* Replace OpenSSL with rustls in reqwest for MUSL builds by @harilvfs

- [5d130de](https://github.com/harilvfs/carch/commit/5d130de368ea65375ecad3f916a1a0b42f393667)  *(check)* Allow CDLA-Permissive-2.0 & ISC license by @harilvfs



### 🚜 Refactor


- [0178cea](https://github.com/harilvfs/carch/commit/0178cea8427ae77b9c405cea25e8d3cb1106db74)  *(cli)* Use clap for argument parsing by @harilvfs

- [f44f40e](https://github.com/harilvfs/carch/commit/f44f40e3b1f75c47ff280465e0c796e42f8cc11d)  *(commands)* Improve structure by @harilvfs

- [3ce80ee](https://github.com/harilvfs/carch/commit/3ce80ee806ebd3f2bf1aa9efacc10eb01103de32)  *(ui)* Decouple UI state into smaller components by @harilvfs

- [bc29d20](https://github.com/harilvfs/carch/commit/bc29d206d439d0bf76438b68790bc0fc279eb806)  *(ui)* Separate ui modules by @harilvfs

- [e193895](https://github.com/harilvfs/carch/commit/e1938951e2e3cafce15029eaeff441264711f146)  *(ui)* Modularize popups and rendering widgets by @harilvfs

- [9789feb](https://github.com/harilvfs/carch/commit/9789febcaf6b1367ba039a2072c407f626dc7694) Use temporary directory for script extraction by @harilvfs



### 📚 Documentation


- [89a1d5b](https://github.com/harilvfs/carch/commit/89a1d5b97561f8ceeacfea3af881203b4307f3a0)  *(readme)* Add social links by @harilvfs



### 🎨 Styling


- [5dde4d4](https://github.com/harilvfs/carch/commit/5dde4d4006a0e58d7ba6a61957fd8e6508aef135)  *(tui)* Using more better color by @harilvfs



### ⚙️ Miscellaneous Tasks


- [16badb6](https://github.com/harilvfs/carch/commit/16badb62b09388490d5755fce00b23468718c3e7)  *(release)* Fix version prefix by @harilvfs

- [911ccf7](https://github.com/harilvfs/carch/commit/911ccf7ac8f44b041d586632b126e5c2a9f1cade) Apply set -euo pipefail to all scripts by @harilvfs

- [3388494](https://github.com/harilvfs/carch/commit/33884942b9e24dfe17e0457574e7f4b1fb16f83c)  *(cargo)* Cleanup by @harilvfs

- [77fa578](https://github.com/harilvfs/carch/commit/77fa578fa9d049b2366a8421e7396c9fd7966d43)  *(notify)* Add autorun on release published by @harilvfs

- [d331495](https://github.com/harilvfs/carch/commit/d331495f0a1c29c0c8a38ba49e0d09e904f9fb48)  *(notify)* Simplify release note by @harilvfs

- [e9a59b5](https://github.com/harilvfs/carch/commit/e9a59b598fd7e5e4eca6a31c0b68fb41c0cd3327) Switch to taiki-e/install-action by @harilvfs

- [ff170b2](https://github.com/harilvfs/carch/commit/ff170b2afc74eaeca9efcaacf2b7cea76c69dd88)  *(commands)* Add missing commands entry by @harilvfs

- [8c1879f](https://github.com/harilvfs/carch/commit/8c1879fc7914db8f39109fe5418584dc12efc019)  *(preview)* Update tape adapting the tui changes by @harilvfs

- [c46b89d](https://github.com/harilvfs/carch/commit/c46b89d0aa701e5ceb94f90d89ce446792b72c16)  *(crates)* Bump version locally by @harilvfs

- [99631e7](https://github.com/harilvfs/carch/commit/99631e7c1df05bd811ac834dc3951457fa340cae)  *(cmds)* Update commands on manpages by @harilvfs



## [5.2.3](https://github.com/harilvfs/carch/compare/v5.2.2...v5.2.3) - 2025-07-16


### 🚀 Features


- [063aa13](https://github.com/harilvfs/carch/commit/063aa1347e5589176be70208341908d645df7beb) Initial support for opensuse (#524) by @harilvfs in [#524](https://github.com/harilvfs/carch/pull/524)

- [c98c1c6](https://github.com/harilvfs/carch/commit/c98c1c6f8b45fda585da26a3778665ad13972201)  *(cmd)* Implement direct update and uninstall by @harilvfs

- [8e10e2d](https://github.com/harilvfs/carch/commit/8e10e2dac36f7b44bdd6f5b9a512b0f4dcd54ceb)  *(script)* Add reusable check_fzf function by @harilvfs

- [0b2abae](https://github.com/harilvfs/carch/commit/0b2abae5909887795c1cda46166f4b7660e28cac)  *(package-git)* Add opensuse support by @harilvfs



### 🐛 Bug Fixes


- [1d621ab](https://github.com/harilvfs/carch/commit/1d621ab1e98b412e58d2f63f8e0d48d1124ced7f)  *(desktop)* Binary dir & desc by @harilvfs

- [9934ac7](https://github.com/harilvfs/carch/commit/9934ac73e163d744879f90ea7cb86e285dce99c9)  *(lint)* Shell format by @harilvfs



### 📚 Documentation


- [f8ce413](https://github.com/harilvfs/carch/commit/f8ce413961cb41bddf6202954cd9714b60457068)  *(readme)* Add preview by @harilvfs

- [f54a44b](https://github.com/harilvfs/carch/commit/f54a44b3379d88d9ed25e7e54fe5c7e01eae4721) Update help and completions for commands by @harilvfs

- [44cc5a3](https://github.com/harilvfs/carch/commit/44cc5a3db31084b8511683b260c74fd0f91a741a)  *(readme)* Add opensuse support by @harilvfs



### 🎨 Styling


- [27de3c8](https://github.com/harilvfs/carch/commit/27de3c895455589b2903fbc7cb7ee901941bde85)  *(lint)* Fix fmt by @harilvfs



### ⚙️ Miscellaneous Tasks


- [0bc78a3](https://github.com/harilvfs/carch/commit/0bc78a3ed96c22e5d117f7a631b6231a0e608361) Remove pre-release by @harilvfs

- [a0a9d36](https://github.com/harilvfs/carch/commit/a0a9d36b8edb40996b0f1f4aa35d1ecb25359ae5)  *(cmd)* Clean up command for new changes by @harilvfs

- [6c03caf](https://github.com/harilvfs/carch/commit/6c03caf6888330e4da848f4e154604063c68c447)  *(install)* Remove Go installer (using RPM/PKGBUILD instead) (#525) by @harilvfs in [#525](https://github.com/harilvfs/carch/pull/525)

- [893d285](https://github.com/harilvfs/carch/commit/893d285489446b93b39ac740975589d7a19e889b) Clean old .gitignore dir by @harilvfs

- [12370c0](https://github.com/harilvfs/carch/commit/12370c00a389b424ddedfa6480d02e8b96cdabd9) Update man pages commands by @harilvfs

- [ef6202c](https://github.com/harilvfs/carch/commit/ef6202c08cc744efb0101594b3a70a89c5dd1e19)  *(man)* Fix typo by @harilvfs

- [24dce83](https://github.com/harilvfs/carch/commit/24dce834db322ff869b1fb400d5477ab54d0a41b) Remove go for editorconfig by @harilvfs



## [5.2.2](https://github.com/harilvfs/carch/compare/v5.2.1...v5.2.2) - 2025-07-12


### 🐛 Bug Fixes


- [a9fc2f4](https://github.com/harilvfs/carch/commit/a9fc2f4a8ffc535c2c306db9da5007a118d8fc76)  *(preview)* Infinite scrolling on script preview by @harilvfs



### 💼 Other


- [a7d50e4](https://github.com/harilvfs/carch/commit/a7d50e46b7b91c9e805d3fee18a75aee42a2a173)  *(deps)* Bump Version by @harilvfs

- [81ad3ef](https://github.com/harilvfs/carch/commit/81ad3ef0d779afd468e9f75e8ffda0b93478927c)  *(deps)* Bump version sysinfo to 0.36.0 by @harilvfs



### 📚 Documentation


- [38d2608](https://github.com/harilvfs/carch/commit/38d2608ce6ce8af73ebfe95c86bbfa3598572978)  *(readme)* Cleanup & re-structure by @harilvfs

- [27bd556](https://github.com/harilvfs/carch/commit/27bd556de5e0b6aaed40ad14ecfac3f1537e53c7)  *(readme)* Add label by @harilvfs



## [5.2.1](https://github.com/harilvfs/carch/compare/v5.1.7...v5.2.1) - 2025-07-07


### 🚀 Features


- [b71a5f7](https://github.com/harilvfs/carch/commit/b71a5f719a3b99f530b4060ecbb2ed95ffed96f4)  *(installer)* Enhance ui/ux and usability by @harilvfs

- [837e6d5](https://github.com/harilvfs/carch/commit/837e6d5d538465689457bcb9f4404017982f6603)  *(ui)* Change fullscreen preview to a popup (#514) by @harilvfs

- [4abee3d](https://github.com/harilvfs/carch/commit/4abee3d2f8edced61cb04837eacc08b5380169a8)  *(ui)* Remove tui side-preview by @harilvfs

- [6a52c0a](https://github.com/harilvfs/carch/commit/6a52c0af64bfaffda3a3eff49c56fe84b0776de9)  *(cli)* Remove obsolete --no-preview and --list-scripts commands by @harilvfs

- [255bb91](https://github.com/harilvfs/carch/commit/255bb91c8a3b211d6c3d8bd2bce35ed403123a5a)  *(ui)* Implement dynamic category folder icons by @harilvfs

- [3a3a1e7](https://github.com/harilvfs/carch/commit/3a3a1e71568790bf28d70e38fa7bfc7ced13140e)  *(tui)* Improve navigation by @harilvfs

- [abec1a3](https://github.com/harilvfs/carch/commit/abec1a3c75a9bc612c6d2c2f5e5d1bc0b2c891cc)  *(tui)* Change unfocused highlight to cyan by @harilvfs

- [2d349cc](https://github.com/harilvfs/carch/commit/2d349cc533576cc65588878200aec6211732621d)  *(tui)* Enhance navigation and keybindings by @harilvfs

- [00553b9](https://github.com/harilvfs/carch/commit/00553b998ed99a32f24bc1142de7c39329db3129)  *(script)* Add cleanup to bash setup by @harilvfs

- [b948248](https://github.com/harilvfs/carch/commit/b9482485011cfe91fe3b543cf6303f1ee0a10223)  *(ui)* Replace static title with system info header by @harilvfs

- [337848f](https://github.com/harilvfs/carch/commit/337848f657290a9aebb5f0bddadb68e0c73d8481)  *(tui)* Add syntax highlighting for script preview by @harilvfs

- [513ef6f](https://github.com/harilvfs/carch/commit/513ef6f5e2da11f3a8dd32eaf19ebdb5d2ad186b)  *(tui)* Add 'h' key to exit preview mode by @harilvfs



### 🐛 Bug Fixes


- [56ee64a](https://github.com/harilvfs/carch/commit/56ee64a39a81f5b30211a41c00c1a2e0e685dcbc)  *(lint)* Clippy warning by @harilvfs

- [de18d84](https://github.com/harilvfs/carch/commit/de18d84399db4bae50894ff97e3c438fc6291541)  *(tui)* Multi-select by @harilvfs

- [f5db8ae](https://github.com/harilvfs/carch/commit/f5db8aedb4c80df3b0e98092d974501ac1f36246)  *(tui)* Icon visibility by @harilvfs

- [80953da](https://github.com/harilvfs/carch/commit/80953dafe650888a7d418ba1715bab3501667a4e)  *(scripts)* Replace ${RESET} with ${NC} by @harilvfs



### 🚜 Refactor


- [c0a8e04](https://github.com/harilvfs/carch/commit/c0a8e0459fd2eb707a947049cd47c7ea044d6db7)  *(core)* Improve code structure (#513) by @harilvfs

- [7013be7](https://github.com/harilvfs/carch/commit/7013be7b4417ce4152fea9cbcbf985d6a89f469d)  *(ui)* New tui design (#515) by @harilvfs

- [4d4a761](https://github.com/harilvfs/carch/commit/4d4a761bbf1cce76f6c99c15f3146bdfb00061cd)  *(ui)* Center popup styling by @harilvfs



### 📚 Documentation


- [1dbe0f0](https://github.com/harilvfs/carch/commit/1dbe0f0e946c291ed6f206e599a6a005cb319b8c)  *(readme)* Improve guide by @harilvfs

- [ec695cc](https://github.com/harilvfs/carch/commit/ec695ccf4963e3df1a3f5c4031428e46e061a9c3)  *(readme)* Cleanup by @harilvfs

- [ade65ef](https://github.com/harilvfs/carch/commit/ade65ef694a0d9fbfd868b34d44b5f22b97f6d9c)  *(readme)* Fix typo cli by @harilvfs

- [1ede19c](https://github.com/harilvfs/carch/commit/1ede19c52bd3e9a403bd5ab9d3be662c793e21c3)  *(tui)* Add panel switching hints to help popup by @harilvfs

- [137d57f](https://github.com/harilvfs/carch/commit/137d57f022921e042f81e13966969ae3e94e1e4f)  *(readme)* Add quick test guide (#518) by @aayushrg7



### 🎨 Styling


- [308f8b0](https://github.com/harilvfs/carch/commit/308f8b0aa6af88a185956d157a5cce236c8730f4)  *(tui)* Correct colors by @harilvfs

- [873dcbd](https://github.com/harilvfs/carch/commit/873dcbd162c94f7ca38fadb15802afe9d32d5f40)  *(lint)* Fix formatting by @harilvfs

- [0b7e195](https://github.com/harilvfs/carch/commit/0b7e195748e6016ab46ade8ec45e822fa058198d)  *(tui)* Remove gray highlighter by @harilvfs

- [7e9eb2f](https://github.com/harilvfs/carch/commit/7e9eb2f9a37aac6631f215d3e9473ef9e08c2fd8)  *(tui)* Remove fade effect switching tui's by @harilvfs



### ⚙️ Miscellaneous Tasks


- [fe636ef](https://github.com/harilvfs/carch/commit/fe636ef48e76c2a7768ca37f9df722608bceaf69)  *(preview)* Update tape adapting new tui design by @harilvfs



## [5.1.7](https://github.com/harilvfs/carch/compare/v5.1.6...v5.1.7) - 2025-07-02


### 🚀 Features


- [3c32f84](https://github.com/harilvfs/carch/commit/3c32f84435b8880372715f98ae3e2de6d0c8a829)  *(setup)* Remove i3wm & sway setup scripts from tui (#510) by @harilvfs



### 🐛 Bug Fixes


- [a2fe529](https://github.com/harilvfs/carch/commit/a2fe529f050cf43579d9f4f09c3797a124cec392)  *(install)* Go fmt by @harilvfs



### 🚜 Refactor


- [6a0adc6](https://github.com/harilvfs/carch/commit/6a0adc6a16b40fd43470475dab26fc00fe9c0100)  *(install)* Remove confirmation prompt & banner by @harilvfs

- [140798d](https://github.com/harilvfs/carch/commit/140798da23b1f560afd0322b1820d694ffa5c4b8)  *(install)* Reducing crap by @harilvfs

- [51c4d82](https://github.com/harilvfs/carch/commit/51c4d8291b36db807b6f32e4f877b8236d132869)  *(script)* Remove custom spinner by @harilvfs



### 🎨 Styling


- [3023c67](https://github.com/harilvfs/carch/commit/3023c67b886385e926240ac3681b5980e4eac182)  *(install)* Clean up notes by @harilvfs

- [d8ea6bd](https://github.com/harilvfs/carch/commit/d8ea6bdad08d99e957ed8701e8e49f364e0018b6)  *(install)* Remove text;s by @harilvfs

- [3d127fd](https://github.com/harilvfs/carch/commit/3d127fdf1feaaaf6ff3d8d1499a62cd21d23cb4f)  *(lint)* Shfmt all `sh` scripts by @harilvfs

- [3b96403](https://github.com/harilvfs/carch/commit/3b964031f98bbf9ab8b1b47c41f70760942d7b33)  *(tui)* Change color to cyan by @harilvfs



## [5.1.6](https://github.com/harilvfs/carch/compare/v5.1.5...v5.1.6) - 2025-06-30


### 🚀 Features


- [924346d](https://github.com/harilvfs/carch/commit/924346d4ff0071bd2948c2ce88a18e225c72d04c)  *(package)* Add zulip desktop by @harilvfs

- [aa97f86](https://github.com/harilvfs/carch/commit/aa97f860cc57683974b7574eb1d7f87065739567)  *(package)* Add java development kit (openjdk) by @harilvfs

- [30faf9f](https://github.com/harilvfs/carch/commit/30faf9f4d87a113cf45f6a38fc859c8ddd179f1b)  *(package)* Add uad (universal android debloater) by @harilvfs



### 🐛 Bug Fixes


- [933a48a](https://github.com/harilvfs/carch/commit/933a48a12c987ecd82b527e26878472d33079d23) Simplifying flatpak command by @harilvfs



### 🎨 Styling


- [8d550c2](https://github.com/harilvfs/carch/commit/8d550c284f8926e1dfdf78068a461cdd3b62d26d)  *(theme)* Add catppuccin color scheme alacritty by @harilvfs



## [5.1.5](https://github.com/harilvfs/carch/compare/v5.1.4...v5.1.5) - 2025-06-20


### 🚜 Refactor


- [bee6d97](https://github.com/harilvfs/carch/commit/bee6d97446e90c8db93c2975ecfb1ddab2b66862) Remove https strip from running commands by @harilvfs



### ⚙️ Miscellaneous Tasks


- [6bee2f0](https://github.com/harilvfs/carch/commit/6bee2f078027359b43336e582830022199b3eb48)  *(lint)* Fix fmt by @harilvfs



## [5.1.4](https://github.com/harilvfs/carch/compare/v5.1.3...v5.1.4) - 2025-06-16


### 🚀 Features


- [7ed4ecd](https://github.com/harilvfs/carch/commit/7ed4ecd3b0e3fcd1b9b73d958571198122082ced)  *(installer)* Rewrite install script in Go (#499) by @harilvfs

- [253d102](https://github.com/harilvfs/carch/commit/253d10230f118feb569adbd77c52d8544eb51bfe)  *(installer)* Rewrite install script in Go (#500) by @harilvfs



### 🐛 Bug Fixes


- [a88a884](https://github.com/harilvfs/carch/commit/a88a8847c5718e0b31fef689dda2727efac63e5f) Use #!/usr/bin/env bash for better portability by @harilvfs



### 🚜 Refactor


- [38c6b0e](https://github.com/harilvfs/carch/commit/38c6b0ebb5ad71367dfd6ed0acb3ce3397a596be) Update CLI heading by @harilvfs



### 📚 Documentation


- [023f143](https://github.com/harilvfs/carch/commit/023f143ebf447bd444ab20c4db781e5445ec9827)  *(readme)* Add built with ratatui badge by @harilvfs



### 🎨 Styling


- [7804b97](https://github.com/harilvfs/carch/commit/7804b977d8bb9496357e5be02f79be2d78ee7d35) Spacing issue by @harilvfs



### ⚙️ Miscellaneous Tasks


- [5f3785b](https://github.com/harilvfs/carch/commit/5f3785b5a35cba712e60e27805fccfd4ee9bf92e) Fix renovate schedule by @harilvfs

- [3d4cbe7](https://github.com/harilvfs/carch/commit/3d4cbe749a3c0f2bc0bacf678b6075f1f4e2f43e) Adding dependabot by @harilvfs

- [e89ffeb](https://github.com/harilvfs/carch/commit/e89ffeb618c8e0a8f026cb0b2e8ba14b44912eea) Update project description by @harilvfs

- [04ffc79](https://github.com/harilvfs/carch/commit/04ffc796b65d3d1499cb0fc5629b08e7adcaf78d)  *(release)* Add carch installer binary build by @harilvfs

- [363220d](https://github.com/harilvfs/carch/commit/363220d334c6d8d0df0f3262ff0452cd0d2798b7)  *(lint)* Add go lang lint & check by @harilvfs

- [6df96cf](https://github.com/harilvfs/carch/commit/6df96cf6fa5c34f6b4c9c63ae8a9d9d9c7eb571d) Add Dependabot configuration for Go module by @harilvfs

- [1fdd160](https://github.com/harilvfs/carch/commit/1fdd160c91ffc295896b2db06822750c80e79f06) Add editorconfig settings for Go files by @harilvfs

- [44c8aae](https://github.com/harilvfs/carch/commit/44c8aae92c23435422bbccbc6278ddc072c8ba1e)  *(config)* Remove . from desktop file by @harilvfs



## [5.1.3](https://github.com/harilvfs/carch/compare/v5.1.2...v5.1.3) - 2025-06-11


### 🚀 Features


- [dee1074](https://github.com/harilvfs/carch/commit/dee1074946c2241d2a5bca4d7742f0bf3ba74bd3)  *(dwm)* Add xautolock for slock by @harilvfs



### 📚 Documentation


- [ca94c8b](https://github.com/harilvfs/carch/commit/ca94c8b984c3ac8044bf1b83f6c63fbb8a201385) Making readme more minimal (#492) by @aayushrg7

- [3af69dc](https://github.com/harilvfs/carch/commit/3af69dc14c9d4625f12feb583cab56bea540cb96)  *(readme)* Add preview (#493) by @aayushrg7

- [09d90a2](https://github.com/harilvfs/carch/commit/09d90a223ee35c6fd88ee9be19441054ac0e23bc)  *(readme)* Add arrow by @harilvfs

- [5adafb0](https://github.com/harilvfs/carch/commit/5adafb02f40c57b2c38136bb1cc1b9dfc632be6b)  *(readme)* Some improvement (#494) by @aayushrg7

- [68aa53b](https://github.com/harilvfs/carch/commit/68aa53b559a91ca12a025200d1354b4aa890c8af) Add base64 logo as for ratatui by @harilvfs

- [ce9f53c](https://github.com/harilvfs/carch/commit/ce9f53c3a73896eb2cdd42384e98af31cd9c86e7)  *(readme)* Final one (#495) by @aayushrg7



### 🎨 Styling


- [989ee84](https://github.com/harilvfs/carch/commit/989ee84526c2a051fc2909eee897e6cdde310d4e)  *(script)* Change color to `TEAL` by @harilvfs



### ⚙️ Miscellaneous Tasks


- [c0de5ab](https://github.com/harilvfs/carch/commit/c0de5ab61f794f746dc78f29ea910c291cea0cfb) Change lto from "fat" to true by @harilvfs

- [1d229f7](https://github.com/harilvfs/carch/commit/1d229f787757994983191d07218d52c8bfa4ccc4)  *(xinitrc)* Xautolock with slock by @harilvfs

- [9b2cf37](https://github.com/harilvfs/carch/commit/9b2cf3776f38ac80d7431d8393e60c7c36d45429)  *(xinitrc)* Change time to 10 min by @harilvfs



## [5.1.2](https://github.com/harilvfs/carch/compare/v5.1.1...v5.1.2) - 2025-06-07


### 🚀 Features


- [af6b246](https://github.com/harilvfs/carch/commit/af6b246db2a4f1c3c179c19844df751ea9fcb983)  *(package)* Add ungoogled-chromium browser by @harilvfs

- [2125457](https://github.com/harilvfs/carch/commit/2125457b25737e0f05fa7617dd580a10837c8fcf)  *(font)* Add font awesome & terminus font by @harilvfs

- [c09ac62](https://github.com/harilvfs/carch/commit/c09ac622e81759127cf660a05d55b9caac873772)  *(fedora)* Add manual ffmpeg installation by @harilvfs



### 🐛 Bug Fixes


- [f4513ce](https://github.com/harilvfs/carch/commit/f4513ce5ee83c82cec4a512a089fd91d9370d0fc)  *(script)* Exit only on missing dependencies (#483) by @aayushrg7

- [e4296ae](https://github.com/harilvfs/carch/commit/e4296aeb2a8aecac9c29d9fe113da1fd62f13e8d)  *(script)* Correct theme and icon paths by @harilvfs



### 💼 Other


- [b52293d](https://github.com/harilvfs/carch/commit/b52293d46ecacd8d4ba29c9b150af9fd88832851)  *(config)* Set portable rustflags for targets by @harilvfs

- [8ad944f](https://github.com/harilvfs/carch/commit/8ad944f7c25afa30c9365f6bd1206a24bf1552d4)  *(config)* Remove alias by @harilvfs



### 🚜 Refactor


- [9b5e4fd](https://github.com/harilvfs/carch/commit/9b5e4fda5c8d7c8a97f8bd0b0ef9b55ccdebc005) Manual SSR build for Arch and Fedora (#487) by @harilvfs



### 📚 Documentation


- [2694f9a](https://github.com/harilvfs/carch/commit/2694f9a1980deffe785643855ce8cf9e8a177dbc)  *(style)* Remove using of bold text's (#482) by @aayushrg7

- [16a7da2](https://github.com/harilvfs/carch/commit/16a7da2ab43c3fce5e7b4835426dbcc95bb55bf9) Add install note (#488) by @aayushrg7



### 🎨 Styling


- [a5641fe](https://github.com/harilvfs/carch/commit/a5641fe78e45d6496af91a876e9e0b45fbf61168)  *(script)* Cleanup by @harilvfs

- [baf3ae8](https://github.com/harilvfs/carch/commit/baf3ae891cb04877d1d921a1de47dceedd4b88ce) Use docs link in text format (#486) by @aayushrg7

- [4e2cebb](https://github.com/harilvfs/carch/commit/4e2cebbcf1141e91de7bbc8205c600bfb67a3b8d)  *(script)* Using same exit style by @harilvfs

- [092a646](https://github.com/harilvfs/carch/commit/092a64677e078c1b7340c82c6592f68e7d74e261) Add some spices install script by @harilvfs



### ⚙️ Miscellaneous Tasks


- [2e3a540](https://github.com/harilvfs/carch/commit/2e3a540d1e1ca4ce535ecc419de9f0464d4e5158)  *(crate)* Add rust nightly by @harilvfs

- [f0e917e](https://github.com/harilvfs/carch/commit/f0e917e53155d0f3f862dc764eb61c71ec397dbc) Auto merge changelog by @harilvfs

- [4d36756](https://github.com/harilvfs/carch/commit/4d36756ec96461ceba8d01fb90299412ffb81a25) Seprating docs & changelog ci by @harilvfs

- [e38ef7b](https://github.com/harilvfs/carch/commit/e38ef7b6dc4567bae2655ab870c6301b9132cb69)  *(script)* Remove comments (#485) by @aayushrg7

- [5b9068c](https://github.com/harilvfs/carch/commit/5b9068cbcb083a8cf0cb6f2f18c79529db896cf2)  *(config)* Add bacon.toml by @harilvfs

- [57e83aa](https://github.com/harilvfs/carch/commit/57e83aa743e4ac453ab844bdb377fa6a8f98bd22)  *(script)* Update hyprland setup script url by @harilvfs

- [b33cb7b](https://github.com/harilvfs/carch/commit/b33cb7b7804c2f99ae4eecb1edb6006fefa3db55) Update project description (#489) by @harilvfs

- [49bc389](https://github.com/harilvfs/carch/commit/49bc38978d666740717877114a9d9abd92d015db) Cleanup non needed logic by @harilvfs

- [2bb1205](https://github.com/harilvfs/carch/commit/2bb1205e9b26d97b9dd36091d30db2a48d2816eb) Cleanup by @harilvfs



## [5.1.1](https://github.com/harilvfs/carch/compare/v5.1.0...v5.1.1) - 2025-06-03


### 🚀 Features


- [7683cef](https://github.com/harilvfs/carch/commit/7683ceff91e07151387d13b10776bb84a6c774ac)  *(package)* Add git-cliff by @harilvfs

- [e8dede9](https://github.com/harilvfs/carch/commit/e8dede901751304cd571c3ad9faabc9ba482c4ad)  *(config)* Add committed for lint by @harilvfs



### 🐛 Bug Fixes


- [679d605](https://github.com/harilvfs/carch/commit/679d605bceba37b35804ecdb65c498a21fc267d5)  *(lint)* Shell check error by @harilvfs



### 💼 Other


- [28b5346](https://github.com/harilvfs/carch/commit/28b53468f45f77489093dea78ad97db12600e15b)  *(command)* Fix update link by @harilvfs

- [3f8b57c](https://github.com/harilvfs/carch/commit/3f8b57ce5cbef82226a36df2eda4d4f085a45a04)  *(lint)* Cargo fmt by @harilvfs

- [bfc580d](https://github.com/harilvfs/carch/commit/bfc580d8989c00af336e53b7f968674fa8157c18)  *(lint)* Cargo fmt by @harilvfs

- [3483cbd](https://github.com/harilvfs/carch/commit/3483cbdad8a0f8e15e87dd8d8be9f4735808d1cd)  *(lint)* Fix linting issues by @harilvfs

- [b770da1](https://github.com/harilvfs/carch/commit/b770da17a7adcb76598a013d1b154bee01a7ad98) Update note & config link by @harilvfs

- [4454580](https://github.com/harilvfs/carch/commit/44545808942b0d3d0ab6fb12e758f5fac67c7710)  *(lint)* Add taplo for toml fmt by @harilvfs

- [afc9923](https://github.com/harilvfs/carch/commit/afc992363b499ac879bb6c2ebf9631756bddf0ba)  *(config)* Comment out target cpu by @harilvfs



### 🚜 Refactor


- [dafb681](https://github.com/harilvfs/carch/commit/dafb6816499e7bc494d2216108ec073bfae03f0e) Using body from git-cliff by @harilvfs

- [98578ec](https://github.com/harilvfs/carch/commit/98578eca6d7034530579cee72afc014ee6f57aad)  *(script)* Redoing the install script by @harilvfs



### 📚 Documentation


- [4a23748](https://github.com/harilvfs/carch/commit/4a23748f3dda5898d16439b29f2c22fac164575e)  *(badge)* Add deps status by @harilvfs

- [98eb3d5](https://github.com/harilvfs/carch/commit/98eb3d5aca9aa12cfb59a3a31890341f5ef1de05)  *(lang)* Add deps badges by @harilvfs

- [db80cd9](https://github.com/harilvfs/carch/commit/db80cd90f655e8a536815e1a094d2e780247f78b)  *(readme)* Add contributing & badges by @harilvfs

- [a6bcf14](https://github.com/harilvfs/carch/commit/a6bcf14491a75713b2837033cde8b8d466f07ed9)  *(update)* Adapt link with diff lang by @harilvfs

- [8496b9d](https://github.com/harilvfs/carch/commit/8496b9d5d04b6966e0def754dde6669c0904be95)  *(link)* Add telegram badge by @harilvfs

- [72b9fe9](https://github.com/harilvfs/carch/commit/72b9fe98de297852cea11664710cf310e6c5425d)  *(clenup)* Remove duplicate badge by @harilvfs

- [c0c906f](https://github.com/harilvfs/carch/commit/c0c906fa7cddf45c337b7ec8440520335d2f3d83) Update docs redirect url by @harilvfs

- [8c59e5b](https://github.com/harilvfs/carch/commit/8c59e5b9f8f1722e94a7d668eaabd37783001eae)  *(update)* Redoing whole readme (#471) by @harilvfs

- [049840d](https://github.com/harilvfs/carch/commit/049840ddd5899ff0acf8747ccd3246bcb5eff719) Fix image size in readme (#472) by @aayushrg7

- [3084bac](https://github.com/harilvfs/carch/commit/3084bac264576c1a6dd4402ebaa0f807352d7e87)  *(readme)* Fix dev version url by @harilvfs

- [7a068a3](https://github.com/harilvfs/carch/commit/7a068a3c6f154a546808341b4bedfc24e4f3c9a1) Add Prerequisites note (#473) by @aayushrg7

- [d3e0cfa](https://github.com/harilvfs/carch/commit/d3e0cfa4bf1ca0269011378f7b0af3aa406cb38c)  *(badge)* Add license (#474) by @aayushrg7



### 🎨 Styling


- [86405c5](https://github.com/harilvfs/carch/commit/86405c51d4c755acb9b1b1ab2b0ab19ae62c6144)  *(colors)* Add catppuccin colors palette by @harilvfs

- [680ed7f](https://github.com/harilvfs/carch/commit/680ed7f2b1d53f5b3a89631b8b601db856de6a7c)  *(script)* Changing color to catppuccin teal by @harilvfs

- [1298e1f](https://github.com/harilvfs/carch/commit/1298e1f5f8a7ea338dcc24122da385d1a2ad7652)  *(config)* Fix deny with taplo fmt by @harilvfs

- [f6e7879](https://github.com/harilvfs/carch/commit/f6e7879a3818bcc0359eca2030e9d71598f3406c)  *(config)* Fix formatting & toml lint by @harilvfs

- [100151c](https://github.com/harilvfs/carch/commit/100151c37b7bb07c98f81b258f8631fdce1f9456)  *(config)* Remove unused headings & cleanup by @harilvfs



### ⚙️ Miscellaneous Tasks


- [0bd0ce3](https://github.com/harilvfs/carch/commit/0bd0ce373fe9f820f338d9295518b7f1304f4305)  *(rust)* Using nightly for lint by @harilvfs

- [a00245d](https://github.com/harilvfs/carch/commit/a00245d372095138d84d24721dbd01ab6b0d4416)  *(rust)* Using nightly for linting by @harilvfs

- [bd9ead9](https://github.com/harilvfs/carch/commit/bd9ead91fe21ccc935077bed32fbe67f482379c9)  *(deny)* Add cargo-deny configuration by @harilvfs

- [1f44d5e](https://github.com/harilvfs/carch/commit/1f44d5ee730fc99b4469fbfc7aa40017d5fda274) Fix typos and taplo fmt check by @harilvfs

- [5ae0ab4](https://github.com/harilvfs/carch/commit/5ae0ab42222b764b43bfa7f076a0dddb77adb3e7) Remove dependabot in favor of renovate by @harilvfs

- [3ccbc6b](https://github.com/harilvfs/carch/commit/3ccbc6b4ab5915da5906cce0551cd5bc265313b1)  *(config)* Support multiple versions in deny by @harilvfs

- [3c70f1e](https://github.com/harilvfs/carch/commit/3c70f1eef634ca0914c12d9b86026f172d47ddcd)  *(rust)* Add cargo deny check by @harilvfs

- [e42a816](https://github.com/harilvfs/carch/commit/e42a816b10c373af94660016aa063b568c0cdf25)  *(config)* Add .cargo/config.toml by @harilvfs

- [5cc8ca6](https://github.com/harilvfs/carch/commit/5cc8ca6641895a5cf691433addf0d928d0da5b8b) Add ci to auto-comment on prs by @harilvfs

- [284897f](https://github.com/harilvfs/carch/commit/284897f060b3e1be052ccd32f9c4ea0b9f06a653) Cleanup by @harilvfs

- [0b649ba](https://github.com/harilvfs/carch/commit/0b649ba3b3e8e86b9dfc57771502e365875e5c73)  *(pre-release)* Add verbose at build by @harilvfs

- [7173f91](https://github.com/harilvfs/carch/commit/7173f91a870692138a199c1a5bb6f36259866c09)  *(release)* Fix binary build by @harilvfs

- [62ac86f](https://github.com/harilvfs/carch/commit/62ac86fe917f74993617082c9ab54e8b38ee1512)  *(rust)* Add bacon.toml by @harilvfs

- [fc0439b](https://github.com/harilvfs/carch/commit/fc0439b02452e017f0499d71f4840f6818cf041f)  *(rust)* Comment out debug log for script execution by @harilvfs

- [89200d3](https://github.com/harilvfs/carch/commit/89200d356de6f786a3cc5468b1408ff27884c433)  *(config)* Add carch banner cliff by @harilvfs

- [ada20eb](https://github.com/harilvfs/carch/commit/ada20eb6410fb3cc9ef23aee7df3629c8af7087c)  *(lint)* Ignore toml files by @harilvfs

- [aa899e7](https://github.com/harilvfs/carch/commit/aa899e739668e1b73972aebd45be9a6d950f72d2)  *(typos)* Fix job in ci by @harilvfs

- [eda1b4d](https://github.com/harilvfs/carch/commit/eda1b4dff170d09d4cd1f0abd2366fdd68772282)  *(config)* Fix carch banner cliff by @harilvfs

- [50e49fa](https://github.com/harilvfs/carch/commit/50e49faf1f1b24fb6fe81435c5de4744d3c30944)  *(release)* Adding strip header by @harilvfs

- [0adcfc7](https://github.com/harilvfs/carch/commit/0adcfc7e3e73b4e94db8cb61eca48edf418f4b54)  *(release)* Add carch banner by @harilvfs

- [336a505](https://github.com/harilvfs/carch/commit/336a5058c0fb7aacbe74d315403394de95d4b46f)  *(script)* Fix some unheld logic & cleanup by @harilvfs

- [0ba6f5b](https://github.com/harilvfs/carch/commit/0ba6f5bbe2ed3e4f5b614cba3fa0537467bd63ef)  *(lint)* Using only the subpath to trigger ci by @harilvfs



## [5.1.0](https://github.com/harilvfs/carch/compare/v5.0.0...v5.1.0) - 2025-05-31


### 🚀 Features


- [91da4f4](https://github.com/harilvfs/carch/commit/91da4f4090168f969ca699aca99c02845cb0796c) Exit early if fzf is not installed by @harilvfs

- [5ea5ff2](https://github.com/harilvfs/carch/commit/5ea5ff2398f9ad683d1740cb01fca0dbe98a7b11) Add joypixel emoji font [ font script ] by @harilvfs

- [f30dacf](https://github.com/harilvfs/carch/commit/f30dacfc71768a12ffbeaa19c0807a5107e8a7e3) Add num lock [ dwm ] by @harilvfs



### 💼 Other


- [e0f9cdf](https://github.com/harilvfs/carch/commit/e0f9cdf697963e52155f2a98e727f74c968b346d) Rounded script list & help [ ui ] (#464) by @harilvfs

- [2d50d32](https://github.com/harilvfs/carch/commit/2d50d32cb75a7239739960af55e0239f3d0fcf14) Change the fastfetch config url by @harilvfs

- [170fc7d](https://github.com/harilvfs/carch/commit/170fc7df7cc8a73e1f7cbbe48a0b0d1f5ed39fae) Replace product name with carch by @harilvfs

- [5d16fd0](https://github.com/harilvfs/carch/commit/5d16fd0dd0a4f66b0fa9879c9e7fb8dc465ca77e) Gitattributes [ not needed ] by @harilvfs



### 🚜 Refactor


- [2228876](https://github.com/harilvfs/carch/commit/22288767c866f15f5e60a8c38bae03fa2a4b19c6) Split package functions into sourced scripts (#465) by @harilvfs



### 📚 Documentation


- [742189a](https://github.com/harilvfs/carch/commit/742189ad1189dfef2f22472004fe10552277798e)  *(scripts)* Cleanup by @harilvfs



### ⚙️ Miscellaneous Tasks


- [7e314f9](https://github.com/harilvfs/carch/commit/7e314f928c4e86c7dbe9418ffa22b031e020e9c0)  *(colors)* Embed colors.sh and adjust sourcing for runtime scripts (#463) by @harilvfs

- [f6c72a1](https://github.com/harilvfs/carch/commit/f6c72a15c635d6d3fcade22fb9f5a271742d8b72) Add trash-cli as need in profiles by @harilvfs

- [0c55512](https://github.com/harilvfs/carch/commit/0c55512cd282f8b0a758119ffa89e10e1ca9125d)  *(desktop)* Add Keywords field to improve discoverability by @harilvfs

- [f7422d2](https://github.com/harilvfs/carch/commit/f7422d245cd3ce195831d49c3c1182a85f6b27a9) Add .editorconfig by @harilvfs



## [5.0.0](https://github.com/harilvfs/carch/compare/v4.4.7...v5.0.0) - 2025-05-27


### 🚀 Features


- [2382c16](https://github.com/harilvfs/carch/commit/2382c16be48d4edb6d804a92e60f85a21d4f12a8) Add defaulting option to [ zsh bash ] scripts (#456) by @nissxnix

- [e32ffb1](https://github.com/harilvfs/carch/commit/e32ffb11e510fb86ee2b338abb993ddc86282a4a) Add lynx browser [ package script ] by @harilvfs

- [7f39144](https://github.com/harilvfs/carch/commit/7f39144f15ff591899bfcb3b13fca8414ba0bb3c) Add tokyo night theme preset [ bash prompt ] by @harilvfs



### 💼 Other


- [35d75e8](https://github.com/harilvfs/carch/commit/35d75e85f266e6577ce4dc65001be1615f53eeea) Typo by @harilvfs

- [b6cd731](https://github.com/harilvfs/carch/commit/b6cd731564fc51ed05afb7e808d69dc47fefd73b) Use default fmt by @harilvfs



### 🚜 Refactor


- [b9b6a86](https://github.com/harilvfs/carch/commit/b9b6a86558b5e603df59a8e759a13678b6633a06) Removing normal prompt using fzf [ menu ] (#458) by @harilvfs

- [8c48836](https://github.com/harilvfs/carch/commit/8c48836cc8f666e5d3b51447ccb450c8da4901b9) Fix alphabet layout by @harilvfs

- [a6587c3](https://github.com/harilvfs/carch/commit/a6587c31500e39c56d0dce6da0c8cc25b536759a) Add pokemon color script [ swaywm ] by @harilvfs

- [05e29cd](https://github.com/harilvfs/carch/commit/05e29cdeb1893fa8805e9b06df9f428b21e37ea1) Redoing the i3wm setup script by @harilvfs



### 📚 Documentation


- [919be89](https://github.com/harilvfs/carch/commit/919be89159bd8c6cc7c646e9a0ef95c6b547aab6) Minor improvement to markdown side (#457) by @nissxnix

- [c6f70b1](https://github.com/harilvfs/carch/commit/c6f70b11cbf740c6f9a2bb603cfcccdf26edc394) Change color to flamingo by @harilvfs

- [c0c414a](https://github.com/harilvfs/carch/commit/c0c414ab912319dbf5d2a2b22b6a05ad52acd527) Change color by @harilvfs

- [7c7de43](https://github.com/harilvfs/carch/commit/7c7de435c18b383d879a914686e0ec50a75466b2) No more this typos by @harilvfs

- [db37c17](https://github.com/harilvfs/carch/commit/db37c17db6d16eef5fc82f029127753b8f00e07c) Match color with docs style by @harilvfs

- [407d056](https://github.com/harilvfs/carch/commit/407d056035473d8789a1e5477b3167cd100031ac) Adapt color change from readme by @harilvfs

- [87d776e](https://github.com/harilvfs/carch/commit/87d776ede9b02b7cd92dbd93d3b506280ce98ed1) Adapt color change from readme by @harilvfs

- [7f996f1](https://github.com/harilvfs/carch/commit/7f996f17e84e6b8f3f27e1a4f33c667bac23f327) Add workflow status by @harilvfs

- [a33a1d7](https://github.com/harilvfs/carch/commit/a33a1d7cfced8db502312c9669082b5921e4c3ae) Add workflow status by @harilvfs

- [7f81e9f](https://github.com/harilvfs/carch/commit/7f81e9f1d62c3800680f250e71424989bc535c8d) Add workflow status by @harilvfs

- [2b0e213](https://github.com/harilvfs/carch/commit/2b0e21320f9528e74aa86c905e9c9900f3948561) Fix coc mail by @harilvfs

- [3f540a7](https://github.com/harilvfs/carch/commit/3f540a765c4444730b88f6ee21dffce68eb283a6) Cleanup by @harilvfs

- [4b8055e](https://github.com/harilvfs/carch/commit/4b8055e0d50e024dfe8f9e3ccbaca16186a3b607) Redoing the readme part (#459) by @aayushrg7

- [5af5a16](https://github.com/harilvfs/carch/commit/5af5a1640b1c10f45a879563e8b6bd84ecc8da35) Cleanup by @harilvfs

- [513481a](https://github.com/harilvfs/carch/commit/513481a3c20207e23069e4014489b55e0cc144ac) Add traslation [ chinese & spanish ] by @harilvfs

- [4a01a93](https://github.com/harilvfs/carch/commit/4a01a93105348d496188fcba46326f5d52de7611) Fix nepali & spanish lang by @harilvfs

- [8c28e64](https://github.com/harilvfs/carch/commit/8c28e648dafd4971967c1a0679b065f517234d0b) Badges by @harilvfs

- [0ef6190](https://github.com/harilvfs/carch/commit/0ef6190cf417321564b3039b0e6ad8063070d622) Badges by @harilvfs

- [81f03eb](https://github.com/harilvfs/carch/commit/81f03eb02bfac6a4ed4e92b0c90800e99eea6c31) Using h tag by @harilvfs

- [d1a6064](https://github.com/harilvfs/carch/commit/d1a6064a27815ff303a982e51dee931a0c323d94) Add translation for arabic & french by @harilvfs

- [3f097b4](https://github.com/harilvfs/carch/commit/3f097b4275fefe927e6f14235a88488ebde8f3fb) Fix lang by @harilvfs

- [6536204](https://github.com/harilvfs/carch/commit/6536204dd43c39fade270906f1ea6b514110ceaa) Fix original lang [ language code ] by @harilvfs

- [55358e9](https://github.com/harilvfs/carch/commit/55358e916a37380174bebec024d658dfaa6f52dc) Add korean lang by @harilvfs

- [eeacf26](https://github.com/harilvfs/carch/commit/eeacf2655c71721200b5e18560f156e531cfd17a) Fix missing heading by @harilvfs

- [b2674fb](https://github.com/harilvfs/carch/commit/b2674fbc25de276b84e9003bd679f0201730f52b) Using space [ flags ] by @harilvfs

- [16cb27d](https://github.com/harilvfs/carch/commit/16cb27dcbd15ee053d0522a21a8df610dae1889f) Fix spacing issue by @harilvfs

- [d9d6a21](https://github.com/harilvfs/carch/commit/d9d6a212bc15483f7ea72edaf1ca59d463402e25) Add translation for russ & german by @harilvfs



### 🎨 Styling


- [d4b998c](https://github.com/harilvfs/carch/commit/d4b998c3ba6a9e77f5d94392f8dafec97d8acf44) Remove spaces by @harilvfs

- [752657f](https://github.com/harilvfs/carch/commit/752657fe1931f1c91242f0fb1de52e53c538fa07) Remove emoji [ bash ] by @harilvfs

- [1fc838e](https://github.com/harilvfs/carch/commit/1fc838e28603d1194d634cba15ee2287da426f1d) Remove blank spaces by @harilvfs



### ⚙️ Miscellaneous Tasks


- [8fb6c2b](https://github.com/harilvfs/carch/commit/8fb6c2b513a8c4830d94161ba15b22d187789a2e) Fix assign failing by @harilvfs

- [e76fe3a](https://github.com/harilvfs/carch/commit/e76fe3a8da8e9f5900c8a6ec05ecbb51c7dddd38) Fix comment by @harilvfs

- [f1ba567](https://github.com/harilvfs/carch/commit/f1ba5679112ad7ec6f302b5edadf2075dacdf92f) Add eza for terminal scripts (#455) by @nissxnix

- [9123752](https://github.com/harilvfs/carch/commit/9123752f3b01d1b8bff24b45374afd2730848a17) Testing by @harilvfs

- [fed55b1](https://github.com/harilvfs/carch/commit/fed55b13c3048ec7c1b42c38bfd6c152226b1708) Fix cli formatting by @harilvfs

- [459af8e](https://github.com/harilvfs/carch/commit/459af8e6075f2259b3b2e24078cac48674107e2e) Fix typos by @harilvfs

- [e402879](https://github.com/harilvfs/carch/commit/e40287976426a9fe3ecfe22e9cbc7b8c9389585e) Fix dependencies issue [ i3wm script ] by @harilvfs



## [4.4.7](https://github.com/harilvfs/carch/compare/v4.4.6...v4.4.7) - 2025-05-23


### 🚀 Features


- [6356255](https://github.com/harilvfs/carch/commit/635625517d947f52b73bbeca87ba53cb3b2ff09d) Add floorp browser [ package script ] by @harilvfs

- [a704041](https://github.com/harilvfs/carch/commit/a704041f33f10ad51c5c880ad031680d2cf0be04)  *(script)* Add st terminal [ package script ] by @harilvfs

- [0e3f4d1](https://github.com/harilvfs/carch/commit/0e3f4d190354e3fbf2a763d89f40d1e4c792fea5) Add option for defaulting fish shell by @harilvfs

- [4986fc4](https://github.com/harilvfs/carch/commit/4986fc476efdb54cf80d1a26d0716c04840e7ab3) Adding traslation on nepali lang by @harilvfs



### 💼 Other


- [00720fa](https://github.com/harilvfs/carch/commit/00720fa988db97473be7e4a8f802d4d53158fdbb) Unused color [ package script ] by @harilvfs

- [8e9a8f9](https://github.com/harilvfs/carch/commit/8e9a8f932939d5e510ab287a3878abcd704fd4ab) Unused colors [ all scripts ] by @harilvfs

- [83ad6de](https://github.com/harilvfs/carch/commit/83ad6de717e870dce38e64e7fd98dc5cf057b31a) Adapt with links url changes by @harilvfs

- [bb05e89](https://github.com/harilvfs/carch/commit/bb05e899c8ca314918d182bb8523351be4a31b92) I forget to update [fixes] by @harilvfs

- [a6ac659](https://github.com/harilvfs/carch/commit/a6ac659ee58c566bb6f3968f105c11b8d36bd80b) Fix repository url by @harilvfs

- [78449b1](https://github.com/harilvfs/carch/commit/78449b1a89d2fa57c2ca93467469be152dd1cae2) Emojis [ scripts ] by @harilvfs



### 🚜 Refactor


- [736dfaf](https://github.com/harilvfs/carch/commit/736dfaf3ba94a330f2ae3a926e0ed1af98fe042b)  *(script)* Fix category for filemanager tools by @harilvfs

- [a896e88](https://github.com/harilvfs/carch/commit/a896e889ee8bb2ba34656c2eb38d88f533986dae) Make fish shell compatible by @harilvfs

- [fdfd264](https://github.com/harilvfs/carch/commit/fdfd2643455de44953a6ece84838d4bb31edde29) Change fastfetch config url [harilvfs/dwm] by @harilvfs



### 📚 Documentation


- [eea0513](https://github.com/harilvfs/carch/commit/eea0513eb2b1bee3423caf65bfdc82546d72053a) Add repo status testing by @harilvfs

- [38d736a](https://github.com/harilvfs/carch/commit/38d736a575e2acc05ff4a1ced37b7e4c8828bc8c) Cleanup by @harilvfs

- [0e9dcef](https://github.com/harilvfs/carch/commit/0e9dceff8ec1818efb1b357dcd6d291aa24d806d) Add docs link by @harilvfs

- [e84ace1](https://github.com/harilvfs/carch/commit/e84ace1e9f7ec41ca6852e223858fec2023cb6bb) Fix typos by @harilvfs

- [3a60125](https://github.com/harilvfs/carch/commit/3a60125f2dfbdb4a492ef3537232ef40683beafd) Final output by @harilvfs

- [5d3ff1e](https://github.com/harilvfs/carch/commit/5d3ff1e3fe91b8458d368056dcaa7452d436109b) Change install url [ fish compatible by @harilvfs

- [6db8a99](https://github.com/harilvfs/carch/commit/6db8a99ccd75509c89fcc833be3e2fe8e9128141) Cleanup spaces by @harilvfs

- [fe9ddb7](https://github.com/harilvfs/carch/commit/fe9ddb78678a81bed86cb5a48fbd050b5f8b5fda) Fix install link by @harilvfs

- [238dc05](https://github.com/harilvfs/carch/commit/238dc05f20c1ed4579dfee5776c739c33d69aa8d) Fix install with fish shell by @harilvfs

- [967dc64](https://github.com/harilvfs/carch/commit/967dc64d5a7308c70947d1a89bea328f43474e58) Fix direct link by @harilvfs

- [6d0f8d2](https://github.com/harilvfs/carch/commit/6d0f8d2272a3be87d33ab67ab7a1540d3b91bd57) Change direct links by @harilvfs

- [94d686a](https://github.com/harilvfs/carch/commit/94d686ad35968f0d1045b850ae1d878a60e98199) Cleanup not needed badges by @harilvfs

- [ed2e897](https://github.com/harilvfs/carch/commit/ed2e897c1d45e10d6da788a95723db6476be373c) Improve typos' by @harilvfs

- [4a68842](https://github.com/harilvfs/carch/commit/4a6884201653ae4719c7e74471df6b553fa0d998) Add support qr by @harilvfs

- [f7a48e9](https://github.com/harilvfs/carch/commit/f7a48e92eebe9649a6e882735ee37c7ada183ddf) Fix typos by @harilvfs

- [01ea2c4](https://github.com/harilvfs/carch/commit/01ea2c4c61f4644ee0623a84f00186c9a7fc2f6e) Finalizing readme on nepali lang by @harilvfs

- [f31003f](https://github.com/harilvfs/carch/commit/f31003f71a401d4c88931a5baab1bb42c9c59314) Cleanup by @harilvfs

- [a4a32c4](https://github.com/harilvfs/carch/commit/a4a32c490f18f341be8baf959c5c16392e04cb6b) Add translation of README for nepali & hindi lang (#452) by @aayushrg7

- [e86a997](https://github.com/harilvfs/carch/commit/e86a9975e9222deb07f7aac7f9867ec109854cce) Bec of cargo readme by @harilvfs



### 🎨 Styling


- [c6fa331](https://github.com/harilvfs/carch/commit/c6fa3315c0b2de584c6d71ffce0d9f8db00d57d0) Fix shell style formatting by @harilvfs

- [18347c4](https://github.com/harilvfs/carch/commit/18347c4855949ef9bc6a225badecbd21f23a3a3f) Arrow at frontend by @harilvfs

- [356c414](https://github.com/harilvfs/carch/commit/356c41462d5dbcf527c0e500e981b40a83693d7a) Remove blank spaces by @harilvfs



### ⚙️ Miscellaneous Tasks


- [c140aaf](https://github.com/harilvfs/carch/commit/c140aaf0380c01cd98992a9231581e1fe4fdc272) Maybe final by @harilvfs



## [4.4.6](https://github.com/harilvfs/carch/compare/v4.4.5...v4.4.6) - 2025-05-20


### 🚀 Features


- [5a5b436](https://github.com/harilvfs/carch/commit/5a5b436279008c7ea2ec332981d1bd8999f4d7ab)  *(script)* Add pre-release install option by @harilvfs

- [4abef69](https://github.com/harilvfs/carch/commit/4abef69a8001b0274b635c32b961753cd4d04953) Add script to update tmux plugin by @harilvfs



### 🐛 Bug Fixes


- [49dad8f](https://github.com/harilvfs/carch/commit/49dad8fb5e09e2c1873449eda6f0cbbc128b4504)  *(script)* Add removing greetd [ sddm script ] by @harilvfs

- [1ce89eb](https://github.com/harilvfs/carch/commit/1ce89ebebdf9df83a893d646519d86db1c2406c1) Typos [ grub theme script ] by @harilvfs

- [1119916](https://github.com/harilvfs/carch/commit/111991664fa738db38b2218d8c4fe4f7175bd8d5) Typos [ pre-release ] build by @harilvfs

- [8da7197](https://github.com/harilvfs/carch/commit/8da71976dbf8494947766ef611708e1198d25050) Typos [ release notes ] by @harilvfs

- [864ac84](https://github.com/harilvfs/carch/commit/864ac8496610ebc96cd036ad6c8373277072e555) Artifact versioning by @harilvfs

- [341ab01](https://github.com/harilvfs/carch/commit/341ab01d3781db97a4193922b5719a8e334e9af2) Ci dir by @harilvfs



### 💼 Other


- [93eceed](https://github.com/harilvfs/carch/commit/93eceed8d608d959385445cb43274fdf46e08ec7) Typos by @harilvfs

- [4dfd4eb](https://github.com/harilvfs/carch/commit/4dfd4ebd4b2a8b403319e06a08526e91074b9ed1) No needed prompts [ grub script ] by @harilvfs

- [22ce8e8](https://github.com/harilvfs/carch/commit/22ce8e8938a395d23f02c1deff05f287705d9e1b) Artifact upload by @harilvfs

- [7543eff](https://github.com/harilvfs/carch/commit/7543effb79b0cb331a7f458185a2156190cfb59e) Shenanigans by @harilvfs



### 🚜 Refactor


- [a30320f](https://github.com/harilvfs/carch/commit/a30320f94a59fe1fc862265b7766b737bcab61aa) Redoing the lts kernel script by @harilvfs

- [941314d](https://github.com/harilvfs/carch/commit/941314dc612527e922a87ec4b740736e6e69dfe9)  *(scripts)* Relocate shell scripts by @harilvfs



### 📚 Documentation


- [c216b93](https://github.com/harilvfs/carch/commit/c216b93ddc41ec24bdf356ae3af8b4798adbbea8) Cleanup by @harilvfs



### 🎨 Styling


- [8cbaeac](https://github.com/harilvfs/carch/commit/8cbaeacbb07d118c61401409c4f1b4412b7145e0)  *(script)* Fix with shell style check by @harilvfs



### ⚙️ Miscellaneous Tasks


- [a322b56](https://github.com/harilvfs/carch/commit/a322b56a81c593b5b18440ae4e5e1b795eb0d4ea)  *(release)* Seprate for pre-release by @harilvfs

- [ca8a379](https://github.com/harilvfs/carch/commit/ca8a379cca0203fd8ab66ed26dcc856a689a30ae) Add ci monitor & check by @harilvfs

- [f8be525](https://github.com/harilvfs/carch/commit/f8be525f567fb49e9803a353c9a0f5a2711b18c9) Add status by @harilvfs



## [4.4.5](https://github.com/harilvfs/carch/compare/v4.4.4...v4.4.5) - 2025-05-15


### 🚀 Features


- [6537726](https://github.com/harilvfs/carch/commit/6537726b2cf8f0ff8d9737bd707cc5ec51e1d97b) Add extension script & structure changes (#447) by @harilvfs

- [636c8c2](https://github.com/harilvfs/carch/commit/636c8c2945c867ea768d18421cf0dfcc48b18aef)  *(audio)* Check if multilib is enabled by @harilvfs

- [257ca5d](https://github.com/harilvfs/carch/commit/257ca5d330466a9d2f82f955c9dfcf6dbe3e34b8) Add ghostery extensions [ browser script ] by @harilvfs



### 🐛 Bug Fixes


- [c2e5683](https://github.com/harilvfs/carch/commit/c2e5683df1c0f93826233ca96395d7ec192e6c9e) Note in i3wm setup script by @harilvfs

- [1e932fd](https://github.com/harilvfs/carch/commit/1e932fddeb2c120a2e50cc2a6b1aba44c9999a12) Some formatting issue by @harilvfs



### 💼 Other


- [bb6fb13](https://github.com/harilvfs/carch/commit/bb6fb138e2573a9d4be91949ed32ffc0a54229b7)  *(deps)* Bump actions/github-script from 6 to 7 (#443) by @dependabot[bot]

- [c0acfa5](https://github.com/harilvfs/carch/commit/c0acfa56ca99770b0fcee227575e50ff89a709df)  *(deps)* Bump actions/checkout from 3 to 4 (#444) by @dependabot[bot]

- [d3e163d](https://github.com/harilvfs/carch/commit/d3e163d29d10b804ee257fe4e18f2349da5b811b)  *(deps)* Bump tempfile from 3.19.1 to 3.20.0 (#445) by @dependabot[bot]

- [b7821d3](https://github.com/harilvfs/carch/commit/b7821d38e3beb0bc68dfe362e71d3f803e8b85b2)  *(deps)* Bump ctrlc from 3.4.6 to 3.4.7 (#446) by @dependabot[bot]

- [3d94b20](https://github.com/harilvfs/carch/commit/3d94b20f99067fb656910b6e7b14a7345785480e) Emojis from script by @harilvfs

- [f875cd7](https://github.com/harilvfs/carch/commit/f875cd771d909856371625d2372e86767cf5d2c5) Emojis from script by @harilvfs

- [a3eae72](https://github.com/harilvfs/carch/commit/a3eae72bc9d05d3265396c47208398193b8e0287)  *(test)* Move readme to .github by @harilvfs

- [e2507fc](https://github.com/harilvfs/carch/commit/e2507fcbfbeb3b12bb72758f232f78c2ead217bf) Readme dir on cargo by @harilvfs

- [c24664a](https://github.com/harilvfs/carch/commit/c24664a17ba9335ced65d1b9b154f17c54bfcaec) Ok now it look fine by @harilvfs



### 🚜 Refactor


- [b03508d](https://github.com/harilvfs/carch/commit/b03508d0eb37ded21712925678cb129270f55a3f) Simplify logic [ extension script ] by @harilvfs

- [7e587a2](https://github.com/harilvfs/carch/commit/7e587a29f4eaaee6d9ac9c231f2c4904c07a7575) Minor improvement hyprland script by @harilvfs



### 📚 Documentation


- [51e7610](https://github.com/harilvfs/carch/commit/51e76102fd6a7a3fd138458297b61d9ea35c03b4) Fix typos by @harilvfs

- [7e85bb4](https://github.com/harilvfs/carch/commit/7e85bb4964104a0c3eb987189028f5a2cf81d171) Add description by @harilvfs

- [6de5099](https://github.com/harilvfs/carch/commit/6de50996f602b5853ae90ec1c10ce0f8dee10af3) Add carch created badge by @harilvfs

- [6bed6c1](https://github.com/harilvfs/carch/commit/6bed6c12400903ecb48117289714be5fdf809d7a) Add carch created badge by @harilvfs

- [52eaab4](https://github.com/harilvfs/carch/commit/52eaab4d756d3661aaf5f116dc8043fc4bd6ae3e) Change label color by @harilvfs

- [f740480](https://github.com/harilvfs/carch/commit/f74048057b0fe731be0bea17b7c02c9b329208d2) Adjust colors by @harilvfs

- [dbc0892](https://github.com/harilvfs/carch/commit/dbc08927c7e67f4885d78884dbee329130228a4b) Final color changes by @harilvfs

- [f0600ed](https://github.com/harilvfs/carch/commit/f0600ed0f092f720bda93745262ec7b421ee68ee) Add browser section by @harilvfs

- [e874c26](https://github.com/harilvfs/carch/commit/e874c26a438f4ce983280b2ac8a213af6891f082) Add distro icon by @harilvfs

- [629d3e7](https://github.com/harilvfs/carch/commit/629d3e7fcd85c55511ada1ec8cba8270f1ab04f4) Differentiate by @harilvfs

- [ec2c824](https://github.com/harilvfs/carch/commit/ec2c824ebeb2e1fa88736747fe9f3f09e2e252af) Improve typos by @harilvfs



### 🎨 Styling


- [062477f](https://github.com/harilvfs/carch/commit/062477faaf5b22384d47dc868941918d6126b459) Remove typos by @harilvfs



### ⚙️ Miscellaneous Tasks


- [935d28c](https://github.com/harilvfs/carch/commit/935d28cdf72c522231228a26bd3172bb8df33782) Using theme url my dwm repo by @harilvfs



## [4.4.4](https://github.com/harilvfs/carch/compare/v4.4.3...v4.4.4) - 2025-05-11


### 🚀 Features


- [f202969](https://github.com/harilvfs/carch/commit/f2029693189458678d6393fd011e096c43fb4062) Add brightness control script by @harilvfs

- [fd1784e](https://github.com/harilvfs/carch/commit/fd1784e526cc04efb0d30d6963d81b45b8e85c94) Add Electrum Bitcoin wallet install script by @harilvfs

- [8bfc2bf](https://github.com/harilvfs/carch/commit/8bfc2bfc9efd2fc927f8a62f9f11e4f5643d2c9e) Add cleanup script by @harilvfs



### 📚 Documentation


- [5a1eeae](https://github.com/harilvfs/carch/commit/5a1eeaedf06e96f48b0bb4531fcb2a3c0425b182) Add brightness detail by @harilvfs

- [b5997a5](https://github.com/harilvfs/carch/commit/b5997a593697cda96e38810b29e9ef66b5878c5a) Remove emoji as andreas kling said 😆 by @harilvfs

- [fd23969](https://github.com/harilvfs/carch/commit/fd23969b531c320b89d0f74e8480fb7febcb28ce) Add support by @harilvfs



### 🎨 Styling


- [85c5dad](https://github.com/harilvfs/carch/commit/85c5dad1748a596442eacfcbd4030fe7ca80dde7) Remove spaces by @harilvfs



### ⚙️ Miscellaneous Tasks


- [04a2d0e](https://github.com/harilvfs/carch/commit/04a2d0e624b382c912709e272635dc9d63f8b02c) Add ci to update release in docs site by @harilvfs

- [2285805](https://github.com/harilvfs/carch/commit/2285805934c5cb2369c4b25dbf5027a21bb93721) Style check shell scripts by @harilvfs



## [4.4.3](https://github.com/harilvfs/carch/compare/v4.4.2...v4.4.3) - 2025-05-07


### 🐛 Bug Fixes


- [b9e239c](https://github.com/harilvfs/carch/commit/b9e239c279b7acb5ee75f69b9273149a5a02827d) Timing on vhs preview tape by @harilvfs



### 💼 Other


- [8f775d2](https://github.com/harilvfs/carch/commit/8f775d26cce1e79311b7f9dfebebf005ea942851)  *(deps)* Bump chrono from 0.4.40 to 0.4.41 (#437) by @dependabot[bot]

- [35f2fda](https://github.com/harilvfs/carch/commit/35f2fdaaf35516d46caa1843142c2bf8e8931fe8)  *(deps)* Bump crate-ci/typos from 1.31.1 to 1.32.0 (#438) by @dependabot[bot]



### 🚜 Refactor


- [7cacef8](https://github.com/harilvfs/carch/commit/7cacef8c9f8b3f274aa662d2c03328939b0245bf) Add back to menu & improve [ Fastfetch ] by @harilvfs



### 📚 Documentation


- [c0978b1](https://github.com/harilvfs/carch/commit/c0978b1995fc1224b930611e90d811a531eafeda) Add passing check by @harilvfs

- [c10dbcb](https://github.com/harilvfs/carch/commit/c10dbcb84c65e9890ce6648995d4af94d72a6a58) Fix duplication by @harilvfs

- [a4a472d](https://github.com/harilvfs/carch/commit/a4a472d33a92442ba892d3f271e09b6edfbd27e5) Fix duplication by @harilvfs

- [a148ecd](https://github.com/harilvfs/carch/commit/a148ecd70508935940acb9dc89e90dd001fcd1cd) Add note by @harilvfs



### 🎨 Styling


- [446ae5a](https://github.com/harilvfs/carch/commit/446ae5a762b73f91c196437400248f6b3b50e80b) Fix formatting by @harilvfs

- [49fc633](https://github.com/harilvfs/carch/commit/49fc6337f62855b0583ae044440e787ef0310d01) Fix typos by @harilvfs

- [3403214](https://github.com/harilvfs/carch/commit/340321479f66dee8dacde580dc9a147b1ee0f23b) Fix date formatting by @harilvfs

- [3237e25](https://github.com/harilvfs/carch/commit/3237e25a6546c243e3f84c6fa342a132c581c351) Fix typos by @harilvfs

- [4fbcd53](https://github.com/harilvfs/carch/commit/4fbcd53b80167c51cf6f7788a6e6775f492ecc24) Remove spaces by @harilvfs

- [b6c8885](https://github.com/harilvfs/carch/commit/b6c888509bed9b726418444a317c943b6e15d0fe) Remove spaces [remaining one] by @harilvfs

- [4f1112c](https://github.com/harilvfs/carch/commit/4f1112cb750c8d95e4b91f091f47d3559c79b2c8) Remove spaces [dev scripts] by @harilvfs

- [d77cb58](https://github.com/harilvfs/carch/commit/d77cb58683a7b1a8745bcacedcdde5cd710eee16) Remove spaces install script by @harilvfs



### ⚙️ Miscellaneous Tasks


- [bcddd16](https://github.com/harilvfs/carch/commit/bcddd1660ada44970e93993b361cea14f2dcab6c) Add cargo crate publish by @harilvfs

- [db64d01](https://github.com/harilvfs/carch/commit/db64d0138aeaba4b7afa73d3d5ab1be219867649) Add man pages & cargo version update by @harilvfs

- [96da505](https://github.com/harilvfs/carch/commit/96da5054acdb56eb2ae9977af81c727b06687fd8) Update release to commit cargo.lock by @harilvfs



## [4.4.2](https://github.com/harilvfs/carch/compare/v4.4.1...v4.4.2) - 2025-05-04


### 🚀 Features


- [6b5a8b6](https://github.com/harilvfs/carch/commit/6b5a8b6087847f334081f5dfd3b6bee03e01ec3b) Add either with image or standard fastfetch by @harilvfs



### 🐛 Bug Fixes


- [eb8897a](https://github.com/harilvfs/carch/commit/eb8897aaf8ef9c0fdc5c683f8e04a47b980d210e) Description typos by @harilvfs

- [62b4f06](https://github.com/harilvfs/carch/commit/62b4f06d97a0ccad0397d76be1061f0588a55685) Directly include in package install by @harilvfs

- [f473d51](https://github.com/harilvfs/carch/commit/f473d51d5411c3c6ea204ce9344d0fb2a6848d51) Spacing issue by @harilvfs

- [ca36d12](https://github.com/harilvfs/carch/commit/ca36d1283adce8ca45b8e91ff681a3fff01373e2) Logging detail by @harilvfs

- [77efe1a](https://github.com/harilvfs/carch/commit/77efe1a255a0068865e368af12ba338bcc7c6292) Typos by @harilvfs



### 💼 Other


- [6b6e9ca](https://github.com/harilvfs/carch/commit/6b6e9cac45deed9eed242443494d63c7748ccf99) Add log dir detail by @harilvfs

- [b6883da](https://github.com/harilvfs/carch/commit/b6883dacac5978d19602eeb60e4dd9134002118c) Add help info for multi-select by @harilvfs

- [134706a](https://github.com/harilvfs/carch/commit/134706a728554dfab732b9a6d711b04e532b0dc2) Update multiselect info by @harilvfs



### ⚙️ Miscellaneous Tasks


- [a29e4bf](https://github.com/harilvfs/carch/commit/a29e4bf1a107ae7ed0158748676c997da6b030a4) Add yazi tui based filemanager by @harilvfs



## [4.4.1](https://github.com/harilvfs/carch/compare/v4.3.7...v4.4.1) - 2025-04-30


### 🐛 Bug Fixes


- [5c450c8](https://github.com/harilvfs/carch/commit/5c450c84797e8abb3bb37f28f7fc72aba149d555) Man pages by @harilvfs



### 💼 Other


- [f114969](https://github.com/harilvfs/carch/commit/f114969a127ffc1d0b0f13e79e40d6e0097bfe47)  *(deps)* Bump actions/setup-node from 3 to 4 (#431) by @dependabot[bot]

- [755c3a3](https://github.com/harilvfs/carch/commit/755c3a319919a0a13aead8a212bc8756891d7551) Undeed things removed package script by @harilvfs

- [672c88b](https://github.com/harilvfs/carch/commit/672c88b038f7a58fe220b372f622983f88532da0) Figlet stuff (#432) by @harilvfs



### 📚 Documentation


- [e5e9575](https://github.com/harilvfs/carch/commit/e5e95758ff9dd5c72559cd24b0c14a88268883e4) Update docs link by @harilvfs



### ⚙️ Miscellaneous Tasks


- [23b3851](https://github.com/harilvfs/carch/commit/23b38513fcfc707e2434aa58c69bf807f899d282) Add dependencies ffmpeg by @harilvfs



## [4.3.7](https://github.com/harilvfs/carch/compare/v4.3.6...v4.3.7) - 2025-04-27


### 🚀 Features


- [d8b385e](https://github.com/harilvfs/carch/commit/d8b385effc5ce0e2492f02a3cdde7bbb4cf7a8da) Add thorium browser support for fedora by @harilvfs



### 💼 Other


- [1501f8b](https://github.com/harilvfs/carch/commit/1501f8b7bae5df5bed8e0cfc486878628e79b958) Changelog v4.3.6 by @harilvfs

- [e3ca4ef](https://github.com/harilvfs/carch/commit/e3ca4efe602860c4ada858e8b9ef60651fa52d7c) Change help toggle to mode by @harilvfs



### 📚 Documentation


- [de724ec](https://github.com/harilvfs/carch/commit/de724ec831eba377a45a56cdd8564adb829315da) Update changelog for v4.3.6 (#419) by @harilvfs

- [c4b9661](https://github.com/harilvfs/carch/commit/c4b96619dfc53c7e94870698e7880485fbdaaee4) Update changelog for v4.3.6 (#422) by @harilvfs



### ⚙️ Miscellaneous Tasks


- [315aec1](https://github.com/harilvfs/carch/commit/315aec1c39f9e8147bcedbdbd67a687fc2d13da0) Test changelog workflow by @harilvfs

- [9e9ea69](https://github.com/harilvfs/carch/commit/9e9ea693118a4641ea492365c574c77b6fa77c50) Cleanup by @harilvfs

- [ed85917](https://github.com/harilvfs/carch/commit/ed859178c55b57507a7d8cc44c4c5d1715dbcfe1) Final touch up by @harilvfs



## [4.3.6](https://github.com/harilvfs/carch/compare/v4.3.5...v4.3.6) - 2025-04-24


### 🚀 Features


- [16fbdd5](https://github.com/harilvfs/carch/commit/16fbdd56b39d2747ad73207c0cefc5d335efd791) Added foot & ghostty setup script (#412) by @harilvfs

- [f18c1e7](https://github.com/harilvfs/carch/commit/f18c1e7e0ab7c33ab99d05d575f90f6964c7f6e8) Add install script (#413) by @harilvfs

- [7b2ccb0](https://github.com/harilvfs/carch/commit/7b2ccb0be8dc2ee7020123f7ccb12872400fa514) Add audio setup script by @harilvfs

- [f34fc0d](https://github.com/harilvfs/carch/commit/f34fc0d64e2306a7338ec8d0be9b7302f14083c5) Add bluetooth setup script by @harilvfs

- [2d2f233](https://github.com/harilvfs/carch/commit/2d2f233aa9bc7cf96737e52df11c26eeb008cd29) Add noto & dejavu fonts by @harilvfs

- [97a38af](https://github.com/harilvfs/carch/commit/97a38afd1b4ba80f92c1848f5180328035740fc8) Add multi select in package script by @harilvfs



### 🐛 Bug Fixes


- [e55115b](https://github.com/harilvfs/carch/commit/e55115b8dbf5b89b2aa9ffbffc007667525d46d5) Color code in fish script by @harilvfs

- [b904d17](https://github.com/harilvfs/carch/commit/b904d178520436814202d35d86be703ceaec8aa2) Xinitrc calling & promt by @harilvfs

- [f8a565b](https://github.com/harilvfs/carch/commit/f8a565be85b820b91c7649dffb4c5acbd59d4855) Chaotic aur failing by @harilvfs

- [6c50370](https://github.com/harilvfs/carch/commit/6c5037017351bcc9a3516fadc2b01f64f4aac866) Typos by @harilvfs

- [50df9e0](https://github.com/harilvfs/carch/commit/50df9e076524775d00f4ac33bcc247fd8d1404d5) Minor fixes to script side by @harilvfs

- [2852e0f](https://github.com/harilvfs/carch/commit/2852e0f6ffa06f6002c03a7f11c7aebc46f0c422) Tui in runnin tty env by @harilvfs



### 💼 Other


- [839f662](https://github.com/harilvfs/carch/commit/839f662343109a49b83b99ab62ca4fafa04cf3f6) Changelog by @harilvfs

- [357379f](https://github.com/harilvfs/carch/commit/357379fb349ecd46c5e3f7dc2475533267e28177)  *(deps)* Bump crossterm from 0.26.1 to 0.29.0 (#411) by @dependabot[bot]

- [0c0eb2e](https://github.com/harilvfs/carch/commit/0c0eb2e7e2bd673f0611ce342fed8339cc4b75ee) Change desktop entry with cargo dir by @harilvfs

- [eed4633](https://github.com/harilvfs/carch/commit/eed46330d8c053b890cf9f75eb3d7d34f4b2b15d) Cleanup old dir by @harilvfs

- [8e3eb76](https://github.com/harilvfs/carch/commit/8e3eb76156f0d0f6601b5cb684ccd6e9d5d562e5) Cleanup old typo by @harilvfs

- [d667586](https://github.com/harilvfs/carch/commit/d667586898bc9002a5ecef6e1bc3bbc509dc9c07) Old command by @harilvfs

- [c075e37](https://github.com/harilvfs/carch/commit/c075e37d826332381473a267d5cfb5899f83f9a2) Cleanup script & commands by @harilvfs

- [697438d](https://github.com/harilvfs/carch/commit/697438dac86ac642a8bbb6bc6bfb6e7f5caf0b18) Cleanup cache file by @harilvfs

- [cdf810e](https://github.com/harilvfs/carch/commit/cdf810e4fefc8248cbf45d2de43552cdf2071850) Cargo fmt by @harilvfs

- [ff8eae8](https://github.com/harilvfs/carch/commit/ff8eae86c7e3c58cfe6032784bdf2fdc8fe89273) Changes adapt from ratatui v29 (#414) by @harilvfs

- [fffa938](https://github.com/harilvfs/carch/commit/fffa938c0fb663c811568d25753afa67766fc440) Structure changed ui (#415) by @harilvfs

- [2b104d2](https://github.com/harilvfs/carch/commit/2b104d29dbecbe18b539c5023a2a036204d43d9a) Eza manual install fedora side by @harilvfs

- [a5c6c50](https://github.com/harilvfs/carch/commit/a5c6c504696ef3b0778e3999b3bffb503ac1e455) Change title style & colors by @harilvfs

- [e3acbff](https://github.com/harilvfs/carch/commit/e3acbff716bcc036e8f5f5a8145eefc2cd6deb6c) Bump version 4.3.6 [ stable ] by @harilvfs

- [6b6a4f2](https://github.com/harilvfs/carch/commit/6b6a4f22f0182b267b85cf5eef5bee9462390d65) Add some use case dependencies by @harilvfs



### 🚜 Refactor


- [270f9fa](https://github.com/harilvfs/carch/commit/270f9fae16e4fcf4fdc2be8e5ee0cf048f869b81) Cleanup & fix fall back npm by @harilvfs



### 📚 Documentation


- [cf6040f](https://github.com/harilvfs/carch/commit/cf6040f31c018889a48cac5af7c2ebb66be697db) Add guide for desktop by @harilvfs

- [16316db](https://github.com/harilvfs/carch/commit/16316db9605ebe26edfb32d701cb6263465b877e) Fix typos by @harilvfs

- [5a5fa5c](https://github.com/harilvfs/carch/commit/5a5fa5c5c41cd50cbb5935bb2d578ca0cb04212e) Fix link by @harilvfs

- [aa8ea6d](https://github.com/harilvfs/carch/commit/aa8ea6dc04f6b6dc85df73b70264b2ce8acc5f90) Added man pages by @harilvfs

- [688403d](https://github.com/harilvfs/carch/commit/688403d695a03edd4ac56e3d63a1ffc27c6868d7) Remove old command by @harilvfs

- [bef31bf](https://github.com/harilvfs/carch/commit/bef31bf13185a5895ff6449b8aeb3f315742e485) Cleanup by @harilvfs

- [ec85f39](https://github.com/harilvfs/carch/commit/ec85f39b92910d060a03742b848b365ee210113d) Fix typos by @harilvfs



### ⚙️ Miscellaneous Tasks


- [77f2e52](https://github.com/harilvfs/carch/commit/77f2e52cd040d00083944bb85259a3cc438d9486) Add slock dependencies by @harilvfs

- [066177e](https://github.com/harilvfs/carch/commit/066177e2713175c01b9fbd31d39c54efca460273) Finally added gnome-keyring by @harilvfs

- [4497a3a](https://github.com/harilvfs/carch/commit/4497a3a1801e9252716fdf75248e35140d5c8350) Minor left over pacman by @harilvfs

- [8afeeca](https://github.com/harilvfs/carch/commit/8afeeca9baeaeb6ee05d2f8439c60c40c8e43bd2) Add wayland dependencies needed by @harilvfs

- [74e2e2a](https://github.com/harilvfs/carch/commit/74e2e2aec6776d158f65a10153af3f8972973a52) Add papirus icon theme by @harilvfs

- [366cfab](https://github.com/harilvfs/carch/commit/366cfab8ac13038bb713e7a677814c30b86df310) Wayland dependencies by @harilvfs

- [a3c0bde](https://github.com/harilvfs/carch/commit/a3c0bde70a2120815ec62d4209bc7db7f00ddb70) Add some missing dependenceis by @harilvfs

- [dba578a](https://github.com/harilvfs/carch/commit/dba578a1459ce850e51043e5019b192a5bd37ba5) Lefted dependencies by @harilvfs

- [05f8cbb](https://github.com/harilvfs/carch/commit/05f8cbb5a1e600d1c2ff3143c475303d6bc5952b) Add man pages dependencies by @harilvfs

- [178a92e](https://github.com/harilvfs/carch/commit/178a92ee8c97bed684f83ea9ee9a38997860f8c9) Add gtk dependencies by @harilvfs



## [4.3.5](https://github.com/harilvfs/carch/compare/v4.3.4...v4.3.5) - 2025-04-20


### 🐛 Bug Fixes


- [c8088b4](https://github.com/harilvfs/carch/commit/c8088b496ba2c22f1ad84d76408837ce89c9c525) Font installation by @harilvfs



### 💼 Other


- [106558f](https://github.com/harilvfs/carch/commit/106558fa220e5a9a3506c0b494be2b0f5d46b424) V4.3.4 changelog by @harilvfs

- [61048a2](https://github.com/harilvfs/carch/commit/61048a2322ca3615596c5f7d37a00f5893c433bb) Recovering needed stuffs by @harilvfs

- [bbfde9f](https://github.com/harilvfs/carch/commit/bbfde9faca26253d8d7b1918e3e6ec9b4fffe1d4)  *(deps)* Bump crossterm from 0.25.0 to 0.26.1 (#400) by @dependabot[bot]

- [0337a67](https://github.com/harilvfs/carch/commit/0337a670854216477ba8b54e7bbe15b745a720ee) Bump Version 4.3.5 👾 [ Bug Fixes ] by @harilvfs



### ⚙️ Miscellaneous Tasks


- [bf4f85f](https://github.com/harilvfs/carch/commit/bf4f85fdca3a1b47b167b5baa880c2afe1c2b652) Update preview to use prerelease by @harilvfs



## [4.3.4](https://github.com/harilvfs/carch/compare/v4.3.3...v4.3.4) - 2025-04-16


### 🚀 Features


- [e90adac](https://github.com/harilvfs/carch/commit/e90adacc8a1b7fe4f14c19eeb9cf4cc97dc842fd) Added Multi Select (#405) by @harilvfs

- [c7bf1f6](https://github.com/harilvfs/carch/commit/c7bf1f620edea4d0a5a0563e82ec869bc70e52cd) Add lazygit package by @harilvfs



### 🐛 Bug Fixes


- [ffb5ebc](https://github.com/harilvfs/carch/commit/ffb5ebc0ce26ba8f233b8faa4d0af7eadcd3ad58) Prerelease by @harilvfs



### 💼 Other


- [cf8160f](https://github.com/harilvfs/carch/commit/cf8160fd2a458827f96ce8da31b4fbf3d680c2f8) Changelog by @harilvfs

- [e8fb377](https://github.com/harilvfs/carch/commit/e8fb377d48aa3c879b35bf987fae7d4777067d8b) Duplicate changelog by @harilvfs

- [44926ac](https://github.com/harilvfs/carch/commit/44926acd611d9b91ff030f686e34a6731c8fbdc0) Using one script for test by @harilvfs

- [2d30996](https://github.com/harilvfs/carch/commit/2d30996d7c50930cdba4547f8f518dd28340074b) Back to old by @harilvfs

- [80e1164](https://github.com/harilvfs/carch/commit/80e1164c850323426dbfb7f92d08a79e294a956d) Fix install script (#404) by @harilvfs

- [46c6b98](https://github.com/harilvfs/carch/commit/46c6b98313f30b94ea53df21e8ec6386310788f0) Relaying on cargo crate (#406) by @harilvfs

- [2b2480f](https://github.com/harilvfs/carch/commit/2b2480f1e4a5729dd5f4a329708dee7bc12a7a1b) Assets (#407) by @harilvfs

- [7988a00](https://github.com/harilvfs/carch/commit/7988a005791f65fcd0baff7d9275cc68dd3c5907) Make command to support cargo (#408) by @harilvfs

- [8503654](https://github.com/harilvfs/carch/commit/85036543cafb092bc1429d2dccef54dfc113fd4d) Updater script by @harilvfs

- [0f275d4](https://github.com/harilvfs/carch/commit/0f275d45f839923efb0b8eec5c871e99747955a4) Bump Version 4.3.4 👾 by @harilvfs



### 📚 Documentation


- [ff4383c](https://github.com/harilvfs/carch/commit/ff4383c2d061c42badac19c990f3e3a7d20bf104) Update readme by @harilvfs

- [d32be78](https://github.com/harilvfs/carch/commit/d32be78f599e5c5d0e66d3dd23f0f4a954ca2a86) Update installation by @harilvfs

- [5fe536a](https://github.com/harilvfs/carch/commit/5fe536a48bf23a81a9c05b54b6a836397b8a0acf) Update guide by @harilvfs

- [cfde151](https://github.com/harilvfs/carch/commit/cfde151edd4676f32ddb3c185c86165d26cc5f82) Update build by @harilvfs

- [8ba125d](https://github.com/harilvfs/carch/commit/8ba125d3da39e8d30acb95672296a09a779e0438) Update man pages by @harilvfs



### ⚙️ Miscellaneous Tasks


- [a1dc7f0](https://github.com/harilvfs/carch/commit/a1dc7f0c7d464b0fd7236af0a43373e39a1b63d8) Testing preview by @harilvfs

- [0d2bd90](https://github.com/harilvfs/carch/commit/0d2bd90a0d359bd856c429d530d4c76b7becfd23) Back to old vhs docker not working by @harilvfs



## [4.3.3](https://github.com/harilvfs/carch/compare/v4.3.2...v4.3.3) - 2025-04-14


### 🚀 Features


- [ae8d361](https://github.com/harilvfs/carch/commit/ae8d361a4aeb54a7d2102221d5ac6bac76fb6ceb) Add Carch Installer (#402) by @harilvfs



### 🐛 Bug Fixes


- [7914269](https://github.com/harilvfs/carch/commit/791426963f907825087872b3dbc10902d59e4b22) Carch Uninstallation by @harilvfs

- [d701f46](https://github.com/harilvfs/carch/commit/d701f46be3b47c3b6cb6aa32a9ee625835aefc0f) Preview tape by @harilvfs

- [26d9601](https://github.com/harilvfs/carch/commit/26d9601a26d8e78d45eae66292f697b7e5a962ed) Preview tape by @harilvfs

- [5fe24ad](https://github.com/harilvfs/carch/commit/5fe24ad0def50bfac662ff37de87771c6e97ff24) Preview tape by @harilvfs

- [4e6bd53](https://github.com/harilvfs/carch/commit/4e6bd537a8ab1b6bd0787b55cdb710c038100c9d) Back to old by @harilvfs



### 💼 Other


- [a91ede5](https://github.com/harilvfs/carch/commit/a91ede56831d21cb8b8e8766ef1bdce49dd831b1) Minimize timing by @harilvfs

- [719d78c](https://github.com/harilvfs/carch/commit/719d78ced3f5339480e17d35078e855413c9f951) Cargo fmt by @harilvfs

- [54468e9](https://github.com/harilvfs/carch/commit/54468e9267bae22b620f07bb6c7edc16e9eed73b) Testing by @harilvfs

- [2ad113d](https://github.com/harilvfs/carch/commit/2ad113d9ffd247f99a83bb96806fc3416e01c648) Cleanup some text's by @harilvfs

- [bc02136](https://github.com/harilvfs/carch/commit/bc02136efa50ba8746134a76a050b9d9ff06cdc8) Clean up by @harilvfs

- [63e4e5c](https://github.com/harilvfs/carch/commit/63e4e5cc32f5d58a454778e16e14564277491979) Minor Typos Fixxed by @harilvfs

- [d2edbcb](https://github.com/harilvfs/carch/commit/d2edbcb3c67c402e9cdc19c05024fb7edf5b2d8b) Bump Version 4.3.3 by @harilvfs



### ⚙️ Miscellaneous Tasks


- [8d2550d](https://github.com/harilvfs/carch/commit/8d2550da749faff5f13b525496af93434dbd21aa) May be fixed? by @harilvfs

- [b7fc695](https://github.com/harilvfs/carch/commit/b7fc6953f1d7ee80e320d79ef55dbb308f7d88f8) Remove release drafter  (#401) by @harilvfs

- [847c112](https://github.com/harilvfs/carch/commit/847c112ae19328257255985f64b01f8401c2655a) Back to normal by @harilvfs

- [efebd1a](https://github.com/harilvfs/carch/commit/efebd1a7e3ab0ec32c4c3745f51c724921102c5b) Ignore path like markdown by @harilvfs

- [0e144f1](https://github.com/harilvfs/carch/commit/0e144f1dc76c2dbe290488cc827bf0e14b48aa1d) Add ci category by @harilvfs

- [eb68b22](https://github.com/harilvfs/carch/commit/eb68b22effb7bc7058b2bbd5ba7eb33ad454fc25) Testing commit notes by @harilvfs

- [5d8d29f](https://github.com/harilvfs/carch/commit/5d8d29ffe5d15f3dd3d649023eb6cc8aa0eaf35d) Nonsense by @harilvfs

- [544151e](https://github.com/harilvfs/carch/commit/544151e7f89a6731bb7f9c76373a941b234437f6) Fix Path ignore by @harilvfs

- [7fb6fdc](https://github.com/harilvfs/carch/commit/7fb6fdc7d8d81f1100d63c1b6d6b7852afbc76ba) Still prerelease got problem by @harilvfs

- [c8ac1f6](https://github.com/harilvfs/carch/commit/c8ac1f69362fbf303f10e195f55f39249314b301) Update release by @harilvfs



## [4.3.2](https://github.com/harilvfs/carch/compare/v4.3.1...v4.3.2) - 2025-04-13


### 🚀 Features


- [ea03b7a](https://github.com/harilvfs/carch/commit/ea03b7afcead1f22589a91eceb14d3bfb4f4eb11) Added Confirmation Before Running Scripts (#387) by @harilvfs

- [3e7d004](https://github.com/harilvfs/carch/commit/3e7d0047c54a2d3e4afc80216a195093a6524c41) Added Script For Dev Branch by @harilvfs



### 🐛 Bug Fixes


- [98538ff](https://github.com/harilvfs/carch/commit/98538ff1ac4dc80c5a191dccb322cc99036ad702) Typos by @harilvfs

- [f75a407](https://github.com/harilvfs/carch/commit/f75a4071dd6d740e57d4bc40af920c9698bdf5a4) Typos by @harilvfs

- [185c70d](https://github.com/harilvfs/carch/commit/185c70d0d8f9d00cfe208fcce6b5873ce02ea948) Typos by @harilvfs

- [100a97a](https://github.com/harilvfs/carch/commit/100a97a1ebb99a7a33823b099cf9955e3104f132) Typos by @harilvfs

- [79df421](https://github.com/harilvfs/carch/commit/79df421d0dc2ed52cc046dc65c3138f0ef02068a) My Mistake by @harilvfs

- [ae983eb](https://github.com/harilvfs/carch/commit/ae983eb196da366d13338d5195dd1a8ceb4cd70f) Typos by @harilvfs

- [8ccc39b](https://github.com/harilvfs/carch/commit/8ccc39baa741ceab694d0736165f66c0cf63090b) Prereelase making draft by @harilvfs



### 💼 Other


- [bea9a64](https://github.com/harilvfs/carch/commit/bea9a64e7c36b7d7874826f0cd35399a0b7ac731) Changing License To MIT by @harilvfs

- [6da69ab](https://github.com/harilvfs/carch/commit/6da69ab4cd6f50223f4443d4e98c6a22f1b2589b) Man Pages by @harilvfs

- [ab127b1](https://github.com/harilvfs/carch/commit/ab127b1648d581a0f6c61a6d576a0bd938accab6) Typos & Cleanup by @harilvfs

- [ed48796](https://github.com/harilvfs/carch/commit/ed487965e13b5d65d2841a44c8eea1c513a1107e) Cleanup Script that is not needed in carch (#384) by @harilvfs

- [e9e7149](https://github.com/harilvfs/carch/commit/e9e714996dd1aa63ddd543a1a48a6224c0103834) Cleanup by @harilvfs

- [19833a0](https://github.com/harilvfs/carch/commit/19833a060ad22f17e253829ea1c5a0124bfe0934) Sudo permission not needed here by @harilvfs

- [6341226](https://github.com/harilvfs/carch/commit/63412263717b69c1c43552bf085349329462f15a) Running scripts from cache (#388) by @harilvfs

- [3dc1cad](https://github.com/harilvfs/carch/commit/3dc1cad10ca76f5eee4dbe127fa1d98e88b422c7) Fzf confirmation (#389) by @harilvfs

- [1467170](https://github.com/harilvfs/carch/commit/1467170f65fe88755f11e7b165eedf1f663ecb24) Unused commands by @harilvfs

- [e10d960](https://github.com/harilvfs/carch/commit/e10d960138df622dd874ce7a87bae44c0bb2f796) Preview with new tui by @harilvfs

- [a7ea73f](https://github.com/harilvfs/carch/commit/a7ea73f0269add8713b806f243cafd6da1fab441) Improve fzf menu style (#390) by @harilvfs

- [79bf251](https://github.com/harilvfs/carch/commit/79bf251364049d2d25bf6d0ee1ea220b64d2e311) Changing Fzf Menu Style by @harilvfs

- [520caea](https://github.com/harilvfs/carch/commit/520caeacb8a0e266f36d13f82eaceeb3e7246fff) Changelog updater for carch.spec by @harilvfs

- [c061a16](https://github.com/harilvfs/carch/commit/c061a162315b056894b9967e4944f464df0d39c0) Ttf-joypixel as it has been removed by @harilvfs

- [5bb00b4](https://github.com/harilvfs/carch/commit/5bb00b4c0fa0100b9a6ada04fefd3b8d4aea97cf) Bump Version 4.3.2 [ Stable ] by @harilvfs



### 🧩 UI/UX


- [014d0da](https://github.com/harilvfs/carch/commit/014d0da89d9a245cd4d94cebf4369307b83a7a96) Improve Heading & Add Help Info (#386) by @harilvfs



### 🚜 Refactor


- [2b5f0e7](https://github.com/harilvfs/carch/commit/2b5f0e71815c0714fa7da7f62294cfcd020e3023) Rewriting Carch in Rust 🦀 (#385) by @harilvfs

- [f0df87b](https://github.com/harilvfs/carch/commit/f0df87b980f16c09917dd247728ea145b787ce5a) Cleanup & Simplified Install Script (#391) by @harilvfs



### 📚 Documentation


- [39178ef](https://github.com/harilvfs/carch/commit/39178ef25371f2b4f430f101008e8a24b4d93386) Add note by @harilvfs

- [ca47a7e](https://github.com/harilvfs/carch/commit/ca47a7ec7f5b7b43d954be1e5b1b781a04e6f438) Update readme by @harilvfs



### ⚙️ Miscellaneous Tasks


- [90a3516](https://github.com/harilvfs/carch/commit/90a3516f2a10409d59db1547a46b9d813ed6a49d) Update label workflow by @harilvfs

- [b8b8396](https://github.com/harilvfs/carch/commit/b8b8396d68d1682d0e742e5e18a97521caa6d4c2) Testing prerelease by @harilvfs

- [789be48](https://github.com/harilvfs/carch/commit/789be48a645f5b2f0e8c11de030c4819e8f90f4a) Update prerelease by @harilvfs

- [573a91b](https://github.com/harilvfs/carch/commit/573a91b0524651971fc1f0f42c07409a9930d8a5) Add manual runner by @harilvfs

- [a375693](https://github.com/harilvfs/carch/commit/a3756930fabf1366cee5718a17bb5c96eeb0efe4) Lets see if this work by @harilvfs

- [11ba3bb](https://github.com/harilvfs/carch/commit/11ba3bb7a3d0261afca06ac73005c9ff1e445d83) Cleanup & fixes by @harilvfs

- [9cc3823](https://github.com/harilvfs/carch/commit/9cc38238913fb4ee5edea6c09239954d60ac7fab) Add prerelease by @harilvfs



## [4.3.1](https://github.com/harilvfs/carch/compare/v4.2.7...v4.3.1) - 2025-04-09


### 🚀 Features


- [3655960](https://github.com/harilvfs/carch/commit/3655960f8f021ea7258e8f864e0c738bd11d8913) Add timer to log carch execution (#367) by @harilvfs



### 🐛 Bug Fixes


- [042e9dd](https://github.com/harilvfs/carch/commit/042e9dd1908ec48efda56d20ba1bbd919b2900b2) Mailing address by @harilvfs

- [4956aca](https://github.com/harilvfs/carch/commit/4956aca2da4f303d2cc398d4df87758821f640a7) Spacing problem in config file by @harilvfs

- [a3517de](https://github.com/harilvfs/carch/commit/a3517de02255d1d1e54d13cae02b1b6258f243e9) Script spacing issue in conf file (#363) by @harilvfs

- [846173b](https://github.com/harilvfs/carch/commit/846173b7e718a55fb4891ecef0ae7bb436247806) Shell formatting by @harilvfs

- [1a5cc42](https://github.com/harilvfs/carch/commit/1a5cc425d9d355f505fa37361af78f8764a0c855) My Nonsense Mistake (#368) by @harilvfs

- [22db0c1](https://github.com/harilvfs/carch/commit/22db0c1c3dca6cc30222c8b5347329f0a6e48284) Once Again My Mistake (#369) by @harilvfs

- [ee27d84](https://github.com/harilvfs/carch/commit/ee27d84da870ba0c33b607598e90fa23e9d34462) Clippy Warning by @harilvfs



### 💼 Other


- [1a52385](https://github.com/harilvfs/carch/commit/1a523859c8ebdb854cecadabd216d78dc9e84207) Simplifying hardcoded parts (#364) by @harilvfs

- [239cab7](https://github.com/harilvfs/carch/commit/239cab74d24bb690da160b55bdb53bf61f60656e) Spaces Causing Error by @harilvfs

- [f5e6993](https://github.com/harilvfs/carch/commit/f5e69935b63e8643aa1f6e7bba9721b5ad2064fe) Spaces Causing Error [ conf ] by @harilvfs

- [84c8cab](https://github.com/harilvfs/carch/commit/84c8cab5e6738e8436cb72eae42e4f76b539b368) Simplify by @harilvfs

- [ddd3cbe](https://github.com/harilvfs/carch/commit/ddd3cbe7854549d2ac85d4104837493a2f199472) Kinda add some stuffs by @harilvfs

- [1bfedc2](https://github.com/harilvfs/carch/commit/1bfedc2f80866840afcadfa1c199352c2fb7602b)  *(deps)* Bump softprops/action-gh-release from 1 to 2 (#373) by @dependabot[bot]

- [efa2764](https://github.com/harilvfs/carch/commit/efa27643a69c13b230798f67a612921db9b02818)  *(deps)* Bump actions/checkout from 3 to 4 (#372) by @dependabot[bot]

- [76d0a92](https://github.com/harilvfs/carch/commit/76d0a92037366d3de6ea9b2121ec1118bb782599)  *(deps)* Bump crate-ci/typos from 1.31.0 to 1.31.1 (#371) by @dependabot[bot]

- [0ae9665](https://github.com/harilvfs/carch/commit/0ae966583622a343078a3e1806d8ff8d21f7f9d3)  *(deps)* Bump peter-evans/create-pull-request from 7.0.5 to 7.0.8 (#370) by @dependabot[bot]

- [f6cc29c](https://github.com/harilvfs/carch/commit/f6cc29c4ccc6da6bc91efb7a2177854e3a3f940c) Added Tab Config (#375) by @harilvfs

- [04634f6](https://github.com/harilvfs/carch/commit/04634f668d494f16a2cd3d6355cc7b84018586ae) Migrate --help info in Rust (#376) by @harilvfs

- [8ed604e](https://github.com/harilvfs/carch/commit/8ed604e87da90deb535e4782fa1f804155d4d817) Creating a TUI to Display Help Info (#377) by @harilvfs

- [7fa562d](https://github.com/harilvfs/carch/commit/7fa562ded0761c566917eeac765eb7cb13470019) Preview tape by @harilvfs

- [097055d](https://github.com/harilvfs/carch/commit/097055d7021d8d038d2952a76e7b53b4414050cf) Separate Script to Avoid Conflicts (#378) by @harilvfs

- [f1193f0](https://github.com/harilvfs/carch/commit/f1193f02b13b87d9cf0fff54877afb394c1cb9dc) Tui For List Scripts Command (#379) by @harilvfs

- [5b2bca0](https://github.com/harilvfs/carch/commit/5b2bca03c5eef1ec73581cd4ad13e274b23d187b) Clean Up After Running Script (#380) by @harilvfs

- [d4d4a02](https://github.com/harilvfs/carch/commit/d4d4a02bb021fff8bac20f05b3bd2e6f9a61c182) No Dependencies Checkup In Main Script by @harilvfs

- [4e73f09](https://github.com/harilvfs/carch/commit/4e73f0951d32e331e17a2278f1729fce8d0025e1) No Dependencies Checkup In Main Script by @harilvfs



### ⚡ Performance


- [e4944d8](https://github.com/harilvfs/carch/commit/e4944d8e625d843e4b561a9815b9b9cb17fd6d86) Pre-populating Script (#365) by @harilvfs



### ⚙️ Miscellaneous Tasks


- [aa5bb93](https://github.com/harilvfs/carch/commit/aa5bb934684bab83907345a68f8a32fd259a0760) Change Preview Pr Title by @harilvfs

- [64f62ed](https://github.com/harilvfs/carch/commit/64f62ed57bf2e29fb717a2531659a361138f6469) Update Dependencies Handling (#366) by @harilvfs

- [2628a5f](https://github.com/harilvfs/carch/commit/2628a5f2096b24d15cf341a92d08170141d517cf) Add Perf Labeling [ Missing One ] by @harilvfs

- [8e5ec8f](https://github.com/harilvfs/carch/commit/8e5ec8f90d20e41a72ff422e7c04747ff03a6e75) Font Dependencies [ Kitty Conf ] (#374) by @harilvfs



## [4.2.7](https://github.com/harilvfs/carch/compare/v4.2.6...v4.2.7) - 2025-04-04


### 🐛 Bug Fixes


- [daa7062](https://github.com/harilvfs/carch/commit/daa70628fcf1c8b4d036adc875d0f5a300584229) Fixes For Install Script [ archxfedora ] by @harilvfs

- [06048cf](https://github.com/harilvfs/carch/commit/06048cffb3cfcb8db54d319f5956674ddd07688e) Testing Release Drafter by @harilvfs

- [5c2a431](https://github.com/harilvfs/carch/commit/5c2a43170e8cf929220c71c29e378cdbbc85ad69) Testing Release Drafter by @harilvfs



### 💼 Other


- [e2f6367](https://github.com/harilvfs/carch/commit/e2f636795c37b448d602a0354881e008acf370a4) Removing Version Text From Menu (#356) by @harilvfs

- [eeb547f](https://github.com/harilvfs/carch/commit/eeb547f9a79395ee2317cad53c07d529e048b58e) Simplifying the banner (#360) by @harilvfs

- [63e8241](https://github.com/harilvfs/carch/commit/63e8241ebfda1d1c719326b842514114ef935aa0) Upgrading Release Drafter by @harilvfs

- [c85de2a](https://github.com/harilvfs/carch/commit/c85de2a45d4754b52289d5ae960a5a201b01c986) Menu Borders by @harilvfs

- [d0cb1df](https://github.com/harilvfs/carch/commit/d0cb1dff6a3ef8422d8f6f3c7bbbe9523f980e4b) Preview tape by @harilvfs



### 📚 Documentation


- [341bc62](https://github.com/harilvfs/carch/commit/341bc62301179f347336f28f74a4169e93e49f6f) Build Pass & Cleanup Space by @harilvfs



### ⚡ Performance


- [9ce0690](https://github.com/harilvfs/carch/commit/9ce0690f8e59e76d2cea70394bb19523c64ee24d) Reduce Rust code and improve performance (#361) by @harilvfs



## [4.2.6](https://github.com/harilvfs/carch/compare/v4.2.5...v4.2.6) - 2025-03-31


### 🚀 Features


- [08208c0](https://github.com/harilvfs/carch/commit/08208c0051bc677be37e1dc80ab6fb983206603c) Added support for using DWM from TTY (#342) by @harilvfs

- [4ad3171](https://github.com/harilvfs/carch/commit/4ad3171fdf19c42f12de502e91a22b069a139adb) Add New Commands (#353) by @harilvfs



### 🐛 Bug Fixes


- [8d5d7bc](https://github.com/harilvfs/carch/commit/8d5d7bc32f89b0fd0894479e9e75fa8196bb9c8c) Simplify Distro Detection Logic (#340) by @harilvfs

- [e749d16](https://github.com/harilvfs/carch/commit/e749d1622bfc4ee0e007b1e0a2f14bab1831e5df) Update updater for new repo structure (#345) by @harilvfs

- [2f33def](https://github.com/harilvfs/carch/commit/2f33def5db82241a9484e448efe70065757d3b03) Updates to Carch installer for Arch & Fedora (#349) by @harilvfs

- [2d4a090](https://github.com/harilvfs/carch/commit/2d4a0903367493e25284e209a56bebea0e6cc939) Final Carch Banner by @harilvfs

- [cb832e7](https://github.com/harilvfs/carch/commit/cb832e722119af1bc523c81b42838740bc5e31c0) Build Script by @harilvfs



### 💼 Other


- [87f3cfd](https://github.com/harilvfs/carch/commit/87f3cfda75d766f943e8653d9681f3fc6abd0a0f) Bump Version 4.2.6 by @harilvfs

- [9766117](https://github.com/harilvfs/carch/commit/9766117a8a10787fdf002864d4941a0fd4d59009) Logging In RPM Build by @harilvfs

- [ca4ba7d](https://github.com/harilvfs/carch/commit/ca4ba7de184bfdd4d13f9ce4b815e61dce21d771) Man pages Months April by @harilvfs

- [98e1e50](https://github.com/harilvfs/carch/commit/98e1e50e6d39262b135333988a60ae856677bd8a) Commands now compatible with new options (#354) by @harilvfs



### 🚜 Refactor


- [087afc8](https://github.com/harilvfs/carch/commit/087afc848a4eb7c9d1a22db468b06a0c5702c7f9) Improve handling when figlet is missing (#341) by @harilvfs

- [4f2c576](https://github.com/harilvfs/carch/commit/4f2c576a542bafbc5ffb0613dec250f05550a3b3) Rework banner and improve fzf menu (#346) by @harilvfs

- [a44eb77](https://github.com/harilvfs/carch/commit/a44eb77c84e7feb63eeda42427500d70ee67f67f) Redoing the Main Menu (#348) by @harilvfs

- [7597dd4](https://github.com/harilvfs/carch/commit/7597dd4b76493f02dd73acf3fade44ffbe5dd278) Install Fedora RPMs directly (#351) by @harilvfs



### 📚 Documentation


- [5aec483](https://github.com/harilvfs/carch/commit/5aec483f0f7a21829736d39165457ed6b49d60cd) Add Description to scripts (#347) by @harilvfs

- [c2a9d10](https://github.com/harilvfs/carch/commit/c2a9d100904819ec4e3183135192f20d54a53594) Add note by @harilvfs



### ⚙️ Miscellaneous Tasks


- [9edb327](https://github.com/harilvfs/carch/commit/9edb327aeb00e86c4add32615eb7df4aa90282b6) Clean up [ Font Script ] (#344) by @harilvfs

- [55b4b7a](https://github.com/harilvfs/carch/commit/55b4b7a5a3f725ee6533c9c4dd421546c86ed96d) Add CI/CD Category by @harilvfs

- [f8f9161](https://github.com/harilvfs/carch/commit/f8f916177814fdea0e966618248cb56832abc3e8) Update PR Template by @harilvfs

- [467a270](https://github.com/harilvfs/carch/commit/467a270c116a8d11d91316eba191deee4fa09315) RPM Builder For Carch [ Fedora ] (#352) by @harilvfs

- [6f16bb3](https://github.com/harilvfs/carch/commit/6f16bb3b62af8ac44b945e34a34978e8f32441b3) Clean UP by @harilvfs

- [5f5bddd](https://github.com/harilvfs/carch/commit/5f5bdddc1201f98a6b43ebd4e014cda21cd2685a) Fix Rpm Badge by @harilvfs

- [af06e29](https://github.com/harilvfs/carch/commit/af06e29cb396b293a82a34ed1179c8e214ced9cd) Add Rpm Build by @harilvfs

- [93434d1](https://github.com/harilvfs/carch/commit/93434d1539fe31af5d581fe016a313110038b76e) Working As Rpm Build by @harilvfs



## [4.2.5](https://github.com/harilvfs/carch/compare/v4.2.4...v4.2.5) - 2025-03-27


### 🐛 Bug Fixes


- [0935be1](https://github.com/harilvfs/carch/commit/0935be1d8a7dfbf8b873071ce6570978ecfc6da2) AUR helper Swaywm (#335) by @harilvfs



### 💼 Other


- [4e71f09](https://github.com/harilvfs/carch/commit/4e71f093b4410cbd4b934e5100633fac4e819f16) Link To Cargo Docs by @harilvfs



### 🚜 Refactor


- [0ffa8e1](https://github.com/harilvfs/carch/commit/0ffa8e1ec719f54536dd49350656fb4a53f11230) Rework On Install Script (#339) by @harilvfs



## [4.2.4](https://github.com/harilvfs/carch/compare/v4.2.3...v4.2.4) - 2025-03-22


### 🚀 Features


- [ccd1f5e](https://github.com/harilvfs/carch/commit/ccd1f5eac9935f0121ebaea617ed3ddc8735ee51) Add Dunst Setup Script (#332) by @harilvfs

- [cb9e195](https://github.com/harilvfs/carch/commit/cb9e1955c8c7c338b594effdcd02bce8e7539ebf) Add Colors To Help Menu (#334) by @harilvfs



### 🚜 Refactor


- [8da71c0](https://github.com/harilvfs/carch/commit/8da71c01dabdc16ae827f97c1274ea99cbe07038) Completely Remove Gum From Scripts (#333) by @harilvfs



### ⚙️ Miscellaneous Tasks


- [bd2d2be](https://github.com/harilvfs/carch/commit/bd2d2be033fb1e0d586d93a9167a5a98b7caba6c) Label Pr by @harilvfs

- [f1f8434](https://github.com/harilvfs/carch/commit/f1f84348f43e139e16dd56588ac49e63f131bd0e) Fix label Formatting by @harilvfs



## [4.2.3](https://github.com/harilvfs/carch/compare/v4.2.2...v4.2.3) - 2025-03-19


### 💼 Other


- [8e7f2fc](https://github.com/harilvfs/carch/commit/8e7f2fce2b36249e713f5d062772f0e097fd3649) Add Note by @harilvfs



## [4.1.7](https://github.com/harilvfs/carch/compare/v4.1.6...v4.1.7) - 2025-03-09


### 🚀 Features


- [59df9a1](https://github.com/harilvfs/carch/commit/59df9a1fe94e9b7f20d019b8e3b18346e22267e0) Added Carch Search (#300) by @harilvfs



## [4.1.2](https://github.com/harilvfs/carch/compare/v4.1.1...v4.1.2) - 2025-01-07


### 💼 Other


- [e39dfb1](https://github.com/harilvfs/carch/commit/e39dfb13a7508d90c9f5ea1e57a37f072e8ece81) Commit untracked changes in the submodule by @harilvfs



## [4.0.0](https://github.com/harilvfs/carch/compare/v3.0.9...v4.0.0) - 2024-12-18


### 💼 Other


- [967f8c9](https://github.com/harilvfs/carch/commit/967f8c9d4bf3892162ee8b4d2b4337c6f5453b1b) Enhance CLI Installation Tip Section (#162) by @harilvfs



## [3.0.9](https://github.com/harilvfs/carch/compare/v3.0.8...v3.0.9) - 2024-12-01


### 💼 Other


- [0824d0f](https://github.com/harilvfs/carch/commit/0824d0fcb28105ea3d237324057b63e39f6fb7f0) Core Structure Overhaul (#117) by @harilvfs



## [3.0.8](https://github.com/harilvfs/carch/compare/v3.0.7...v3.0.8) - 2024-11-22


### 💼 Other


- [9396347](https://github.com/harilvfs/carch/commit/9396347707cd355ac8b29d4fdc7917673ea01815) Mobile Side View on Documentation Website (#104) by @harilvfs



## [3.0.1] - 2024-10-10


<!-- generated by git-cliff -->
