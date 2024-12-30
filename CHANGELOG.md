# Changelog

All notable changes to this project will be documented in this file.

## [v4.1.1](https://github.com/harilvfs/carch/compare/v4.1.0...v4.1.1) (2024-12-30)

**This release will be the last release of 2024. We will be back in 2025 with more updates and features.**  

> [!NOTE]  
> The upcoming releases will be delayed or less frequent compared to before. I will be focusing on:  
>
> - Developing a TUI for Carch  
> - Learning Bash scripting  
> - Exploring Rust or other languages  

> [!IMPORTANT]
> Thisrelease is not the last but marks a shift to less frequent updates as I dedicate time to improve skills and make Carch better and more stable. Stay tuned for something new!

## ✨ Main Highlights of This Release  

### 🚀 Key Features  
- **Enhanced Installation Support**  
  - Improved compatibility for both stable and rolling-release systems.  

- **📜 Logging**  
  - Added a log file to track the installation process for better troubleshooting.  

- **⚡ Auto-Completion for CLI**  
  - Added shell auto-completion support for:  
    - **Bash**  
    - **Zsh**  
    - **Fish**  
  *(Currently available only for the CLI version of Carch)*  

### 🛠️ Additional Updates  
- **🖼️ Desktop Entry**  
  - Added a Carch icon for better desktop integration.  

- **📋 New Commands**  
  - Introduced more useful commands to the CLI version of Carch.  

- **⚙️ Configuration File**  
  - Added a configuration file to enhance customization for the CLI version.  

### 🐛 Bug Fixes  
- Resolved numerous bugs for a smoother experience.  

### Changed

* Making Script Clean 🧹 by @harilvfs in https://github.com/harilvfs/carch/pull/208
* Making Setup Installation `clean` 🧹 by @harilvfs in https://github.com/harilvfs/carch/pull/209

### Added

* Add [Logging] Carch by @harilvfs in https://github.com/harilvfs/carch/pull/206
* Add logging `Carch` [GTK] by @harilvfs in https://github.com/harilvfs/carch/pull/207
* Add Carch Icons [Desktop Entry] by @harilvfs in https://github.com/harilvfs/carch/pull/211
* Added Icon For Desktop Entry by @harilvfs in https://github.com/harilvfs/carch/pull/212
* Add Uninstall Command [Carch] by @harilvfs in https://github.com/harilvfs/carch/pull/213
* Add Some Packages [Package Script] by @harilvfs in https://github.com/harilvfs/carch/pull/214
* Added Useful Command [Carch --[options]] by @harilvfs in https://github.com/harilvfs/carch/pull/215
* Config File Example by @harilvfs in https://github.com/harilvfs/carch/pull/216
* Added Commands Completions [ZSH BASH FISH] by @harilvfs in https://github.com/harilvfs/carch/pull/219

### Fixed

* Fix Completions Removel by @harilvfs in https://github.com/harilvfs/carch/pull/222
* Script Fixes [BUG] by @harilvfs in https://github.com/harilvfs/carch/pull/210

## [v4.1.0](https://github.com/harilvfs/carch/compare/v4.0.0...v4.1.0) (2024-12-26)

### AUR Packages Update

You can now use the `carch` package for a stable release and `carch-git` for the rolling release version.  

For installation instructions, refer to the [official guide](https://carch-org.github.io/docs/installation/aur.html).  

> [!NOTE]  
> This release includes **critical updates and improvements**:  
>  
> - Enhanced installation support for **both stable and rolling-release systems**.  
> - **AUR fixes**: Both `carch` and `carch-git` packages are now fixed and available for installation.  
>  
> 🔄 **Why the Delay?**  
> The release was slightly delayed as I had to reinstall my system, which required additional setup time. Thank you for your patience!  
>  
> ✅ **Next Steps:**  
> Everything is up to date. Feel free to check the **PKGBUILD** for better insights into the installation process.

### Changed

* Refactor Setup Script by @harilvfs in https://github.com/harilvfs/carch/pull/196
* Refactor Installation Script by @harilvfs in https://github.com/harilvfs/carch/pull/197
* Refactor Whole Scripts [Carch] by @harilvfs in https://github.com/harilvfs/carch/pull/198
* Update Script for Man Pages Handling by @harilvfs in https://github.com/harilvfs/carch/pull/201

### Added

* Add Returing To Menu [Back] by @harilvfs in https://github.com/harilvfs/carch/pull/191
* Include `GTK` & `CLI` [Main Script] by @harilvfs in https://github.com/harilvfs/carch/pull/192
* man-page for [Carch] 📄 by @harilvfs in https://github.com/harilvfs/carch/pull/200

### Fixed

* Fix `SDDM` Theme Dir  [Scripts] by @harilvfs in https://github.com/harilvfs/carch/pull/187
* Fix Carch `Installation` ⛓️ by @harilvfs in https://github.com/harilvfs/carch/pull/189
* Fix Gum Bug 🐛 [Package Script] by @harilvfs in https://github.com/harilvfs/carch/pull/190
* Fix Script [DIR] by @harilvfs in https://github.com/harilvfs/carch/pull/194
* Fix PULL REQUEST TEMPLATE by @harilvfs in https://github.com/harilvfs/carch/pull/199

### Removed

* Remove Gtk Script [Include In Main Script] by @harilvfs in https://github.com/harilvfs/carch/pull/193
* Remove CLI/GTK As Include [Main Script] by @harilvfs in https://github.com/harilvfs/carch/pull/195

## [v4.0.0](https://github.com/harilvfs/carch/compare/v3.0.9...v4.0.0) (2024-12-18)

*Note: In this version, I have moved carch docs stuff to the carch-org [repository](https://github.com/carch-org/docs). Updates and maintenance will now happen there.*

> [!IMPORTANT]
> This release was not extensively tested and may not perform as expected on newly installed Arch Linux systems. **We recommend using the stable AUR package** (`carch`) for now, as the `git` version is currently unstable.  
> 
> Carch has now entered a **development phase** where the entire repository structure and scripts will be refactored. Expect significant changes in the future!  
> 
> Thank you for your patience and support. 🙏

### Changed

* Update CHANGELOG.md for v3.0.9 by @smritics in https://github.com/harilvfs/carch/pull/148
* Update PKGBUILD v3.0.9 by @smritics in https://github.com/harilvfs/carch/pull/149
* Update Carch to v3.0.9 by @harilvfs in https://github.com/harilvfs/carch/pull/153
* Update GTK to v3.0.9 by @harilvfs in https://github.com/harilvfs/carch/pull/154
* Refinements to Documentation by @harilvfs in https://github.com/harilvfs/carch/pull/157
* Update binary build to latest version by @harilvfs in https://github.com/harilvfs/carch/pull/160
* Transfer Docs to Carch-Org Repository by @harilvfs in https://github.com/harilvfs/carch/pull/173
* Change `core.sh` To Carch [ No Binary ] 🪶 by @harilvfs in https://github.com/harilvfs/carch/pull/176
* Move Cli From [ Binary ] `Bash` Script by @harilvfs in https://github.com/harilvfs/carch/pull/177
* From Binary To `Gtk` Bash Script 📜 by @harilvfs in https://github.com/harilvfs/carch/pull/178
* Transfer `Contrib` `Install` `Roadmap` To [Docs] ✈️ by @harilvfs in https://github.com/harilvfs/carch/pull/181

### Added

* Add Changelog to Top Navigation [Docs] by @harilvfs in https://github.com/harilvfs/carch/pull/150
* Add Carch Version Info [Docs] by @harilvfs in https://github.com/harilvfs/carch/pull/151
* Add CarchCLI Installation Guide [Docs] by @harilvfs in https://github.com/harilvfs/carch/pull/155
* Add terminal installation to packages script by @harilvfs in https://github.com/harilvfs/carch/pull/158
* Design Carch Banner by @harilvfs in https://github.com/harilvfs/carch/pull/166
* Bring Back Imp Stuffs by @harilvfs in https://github.com/harilvfs/carch/pull/168
* Astal Vitepress CSS [Index] by @harilvfs in https://github.com/harilvfs/carch/pull/170
* Add Gum Spin [Packages Script] by @harilvfs in https://github.com/harilvfs/carch/pull/182
* Add Gum Spin To `Hyprland` Script by @harilvfs in https://github.com/harilvfs/carch/pull/183

### Fixed

* Revert "Update .gitignore to Exclude Binary Files" by @harilvfs in https://github.com/harilvfs/carch/pull/164
* Fix and Update AUR Package Build [ docs ] by @harilvfs in https://github.com/harilvfs/carch/pull/172
* Fix Script Detection and Bugs by @harilvfs in https://github.com/harilvfs/carch/pull/179

### Removed

* Remove /bin Scripts [Unnecessary] by @harilvfs in https://github.com/harilvfs/carch/pull/156
* Remove Unused 'aboutinfo' Markdown from [docs] by @harilvfs in https://github.com/harilvfs/carch/pull/165
* Remove Npm [Docs] Stuffs by @harilvfs in https://github.com/harilvfs/carch/pull/174

## [v3.0.9](https://github.com/harilvfs/carch/compare/v3.0.8...v3.0.9) (2024-12-02)

*Note: This release primarily focuses on building and enhancing the Carch documentation.*

### Changed

* Update Markdown Documentation for Docs by @smritics in https://github.com/harilvfs/carch/pull/113
* Enhance Carch-GTK Interface and Functionality by @smritics in https://github.com/harilvfs/carch/pull/115
* Refactor Installation Script by @harilvfs in https://github.com/harilvfs/carch/pull/116
* Refactor: Core Structure Overhaul by @harilvfs in https://github.com/harilvfs/carch/pull/117
* Docs: Update Markdown Documentation by @smritics in https://github.com/harilvfs/carch/pull/119
* Refine Carch Documentation by @harilvfs in https://github.com/harilvfs/carch/pull/123
* Simplify Installation Guide by @smritics in https://github.com/harilvfs/carch/pull/125
* Document CLI Changes by @smritics in https://github.com/harilvfs/carch/pull/126
* Comprehensive Documentation Refactor by @harilvfs in https://github.com/harilvfs/carch/pull/129
* Refactor Documentation for Improved Visual Appeal by @harilvfs in https://github.com/harilvfs/carch/pull/136
* Enhance Documentation with Beautiful Updates by @harilvfs in https://github.com/harilvfs/carch/pull/138
* Apache 2.0 License by @aayushrg7 in https://github.com/harilvfs/carch/pull/139
* Enhance Pull Request Template by @aayushrg7 in https://github.com/harilvfs/carch/pull/140
* Refactor Documentation & Some Fixes by @harilvfs in https://github.com/harilvfs/carch/pull/141
* Enhancement on docs by @harilvfs in https://github.com/harilvfs/carch/pull/143
* CSS Changes [ Remove White Space ] by @harilvfs in https://github.com/harilvfs/carch/pull/144
* Create Changelog for Carch by @smritics in https://github.com/harilvfs/carch/pull/146

### Added

* Add GTK and Related Dependencies by @aayushrg7 in https://github.com/harilvfs/carch/pull/112
* Add CLI Commands Guide to Documentation by @harilvfs in https://github.com/harilvfs/carch/pull/118
* Add screen clearing on exit to GTK application by @harilvfs in https://github.com/harilvfs/carch/pull/122
* Add CLI Guide to Documentation by @harilvfs in https://github.com/harilvfs/carch/pull/127

### Fixed

* Fix Documentation Headings by @harilvfs in https://github.com/harilvfs/carch/pull/114
* Fix scripts.zip upload workflow by @smritics in https://github.com/harilvfs/carch/pull/121
* Fix broken image link by @harilvfs in https://github.com/harilvfs/carch/pull/134
* Fix image width to '150' by @harilvfs in https://github.com/harilvfs/carch/pull/145

### Removed

* Remove carchscripts.zip in favor of scripts.zip by @harilvfs in https://github.com/harilvfs/carch/pull/120
* Remove Transparency from Top Section by @harilvfs in https://github.com/harilvfs/carch/pull/142

## [v3.0.8](https://github.com/harilvfs/carch/compare/v3.0.7...v3.0.8) (2024-11-23)

### Changed

* Update cxfs script for version 3.0.7 by @smritics in https://github.com/harilvfs/carch/pull/56
* Update package.json to version 3.0.7 by @smritics in https://github.com/harilvfs/carch/pull/57
* Refac Sddm Script Heading  by @smritics in https://github.com/harilvfs/carch/pull/58
* Rebase Carch structure for cleaner design by @harilvfs in https://github.com/harilvfs/carch/pull/64
* Rebase Carch Package Build Structure by @harilvfs in https://github.com/harilvfs/carch/pull/65
* Update package to latest structure by @harilvfs in https://github.com/harilvfs/carch/pull/73
* Update Folder Structure to Align with bin Convention by @harilvfs in https://github.com/harilvfs/carch/pull/81
* Update PKGBUILD for AUR Package by @smritics in https://github.com/harilvfs/carch/pull/84
* Update docs for latest installation commit by @harilvfs in https://github.com/harilvfs/carch/pull/108
* Refine Installation Guide and Add GTK Setup Instructions by @smritics in https://github.com/harilvfs/carch/pull/107

### Added

* Carch GTK by @harilvfs in https://github.com/harilvfs/carch/pull/109
* Add script zip checklist to PR template by @smritics in https://github.com/harilvfs/carch/pull/60
* Add essential packages to the package script. by @smritics in https://github.com/harilvfs/carch/pull/75
* Add AUR installation method to the guide by @aayushrg7 in https://github.com/harilvfs/carch/pull/85
* Add AUR package installation instructions to the documentation by @aayushrg7 in https://github.com/harilvfs/carch/pull/86
* Add AUR package version badge to Carch by @aayushrg7 in https://github.com/harilvfs/carch/pull/87
* Add carch-gtk Setup Script by @harilvfs in https://github.com/harilvfs/carch/pull/96
* Add GUI/GTK Check Box Completion by @harilvfs in https://github.com/harilvfs/carch/pull/97
* Add Yazi File Manager to Package Script by @smritics in https://github.com/harilvfs/carch/pull/98
* Add GTK Installation Guide to Documentation by @aayushrg7 in https://github.com/harilvfs/carch/pull/99
* Add GTK Installation Support to Setup Script by @harilvfs in https://github.com/harilvfs/carch/pull/106

### Fixed

* Fix Font Installation Process by @harilvfs in https://github.com/harilvfs/carch/pull/62
* Fix Roadmap Link by @harilvfs in https://github.com/harilvfs/carch/pull/71
* Fix .gitignore directory handling and update README badges by @smritics in https://github.com/harilvfs/carch/pull/74
* Fix Image Source Link in Documentation by @smritics in https://github.com/harilvfs/carch/pull/100
* Fix: Mobile Side View on Documentation Website by @harilvfs in https://github.com/harilvfs/carch/pull/104

### Removed

* Remove unnecessary badges from README by @harilvfs in https://github.com/harilvfs/carch/pull/78
* Remove discord chat badges from README by @harilvfs in https://github.com/harilvfs/carch/pull/79
* Remove Installation Guide from README by @aayushrg7 in https://github.com/harilvfs/carch/pull/80
* Remove 'Inspiration' tag by @aayushrg7 in https://github.com/harilvfs/carch/pull/92

## [v3.0.7](https://github.com/harilvfs/carch/compare/v3.0.6...v3.0.7) (2024-11-15)

### Changed

* Docs Refactor  by @harilvfs in https://github.com/harilvfs/carch/pull/22
* Docs Light/Dark Mode Switcher by @harilvfs in https://github.com/harilvfs/carch/pull/25
* Update Completed Roadmap Tasks On Carch by @harilvfs in https://github.com/harilvfs/carch/pull/32
* Package Installation & Menu Script Refactor by @harilvfs in https://github.com/harilvfs/carch/pull/38
* Update CXFS Figlet Heading to Carch by @smritics in https://github.com/harilvfs/carch/pull/46

### Added

* Add Option to Install Music Packages in Package Script by @harilvfs in https://github.com/harilvfs/carch/pull/26
* Add Spotify to Music Packages by @harilvfs in https://github.com/harilvfs/carch/pull/28
* Add more essential packages to installation script by @harilvfs in https://github.com/harilvfs/carch/pull/29
* Add Tor Browser Installation into Packages Installation Script by @harilvfs in https://github.com/harilvfs/carch/pull/33
* Add Gum Interactive Menus and Confirmation to Setup Scripts by @harilvfs in https://github.com/harilvfs/carch/pull/39
* Add Rhythmbox To Music [Package Installation] by @harilvfs in https://github.com/harilvfs/carch/pull/43
* Add a tag for netflix unoffical package by @harilvfs in https://github.com/harilvfs/carch/pull/45
* Add note for dwm setup & version in cxfs by @smritics in https://github.com/harilvfs/carch/pull/53

### Removed

* Remove Reddit Badge From README.md by @harilvfs in https://github.com/harilvfs/carch/pull/27
* Remove Script Zip File  by @harilvfs in https://github.com/harilvfs/carch/pull/30
* Remove comments from zip workflow by @harilvfs in https://github.com/harilvfs/carch/pull/37
* Remove Echo On Running Script by @harilvfs in https://github.com/harilvfs/carch/pull/44

## [v3.0.6](https://github.com/harilvfs/carch/compare/v3.0.5...v3.0.6) (2024-11-09)

### Changed

- Replace Whiptail and Dialog with Gum and Figlet for Simplified Menu by @harilvfs in https://github.com/harilvfs/carch/pull/19
- Update Docs Workflow by @harilvfs in https://github.com/harilvfs/carch/pull/18

## [v3.0.5](https://github.com/harilvfs/carch/compare/v3.0.4...v3.0.5) (2024-11-06)

### Changed

- **Theme and Icon Setup**: Improved setup script with directory checks.
- **Clean UI Improvements**: Simplified setup interfaces and enhanced visuals.

### Added

- **ASCII Text Headings**: Added clear ASCII headers for better script readability.
- **Wallpaper Setup**: New script to download wallpapers to `~/Pictures/wallpapers`, with input validation for setup confirmation.
- **Input Validation**: Added strict `y/n` validation to ensure accurate user responses in setup scripts.

### Fixed

- **Bugs Fixes**: Fixed some minor & known bugs.

## [v3.0.4](https://github.com/harilvfs/carch/compare/v3.0.3...v3.0.4) (2024-10-22)

### Changed

- **AUR Package Removal:**
  - The `carch` AUR package has been removed.
  - Installation now happens fully through the setup script.
  - Add Menu Selection Memory Feature and Improve Navigation in Carch by @harilvfs in https://github.com/harilvfs/carch/pull/12

### Added

- **Desktop Entry Added:**
  - The `carch.desktop` file is now created automatically during setup.
  - This desktop entry allows easy access to Carch from your system’s application menu.

## [v3.0.3](https://github.com/harilvfs/carch/compare/v3.0.2...v3.0.3) (2024-10-16)

### Changed

- Simplified the setup script.
- Improved package installation with display fixes.
- Bumped version to 3.0.3.
- Updated Hyprland setup.

### Added

- Added exit option in the LTS kernel setup.
- Added binary build process.
- Included `carch.desktop` for easier access.
- Added DWM dependencies.
- Added i3wm Setup.
- Added SwayWM Setup.

### Fixed

- Resolved known issues for a more stable experience.
- Fixed Aur `PKGBUILD`.

## [v3.0.2](https://github.com/harilvfs/carch/compare/v3.0.1...v3.0.2) (2024-10-12)

### Changed

- Refactor setup script for speed & reliability by @harilvfs in https://github.com/harilvfs/carch/pull/9

## [v3.0.1](https://github.com/harilvfs/carch/compare/v1.0...v3.0.1) (2024-10-11)

*Tag Changes Here*

### Changed

- Bump crossterm from 0.26.1 to 0.28.1 by @dependabot in https://github.com/harilvfs/carch/pull/7
- Bump dialoguer from 0.9.0 to 0.11.0 by @dependabot in https://github.com/harilvfs/carch/pull/6

*Note: In this version, we are incorporating Rust, so expect Dependabot PR updates.* 

## [v2.0](https://github.com/harilvfs/carch/compare/2024-10-08...2024-10-09) (2024-10-09)

### Changed

- Menu impl to whipstail & dialog by @harilvfs in https://github.com/harilvfs/carch/pull/3

### Added

- Themes and icons setup script with fixes for X11 and Wayland environments.

### Fixed

- Menu navigation using `dialog` for better interaction.
- Known Bugs.
- Hyprland setup script.


## [v1.0](https://github.com/harilvfs/carch/commits/2024-10-08) (2024-10-08)

### Removed

- Remove unused code & comments  by @harilvfs in https://github.com/harilvfs/carch/pull/1

### Added

- Hyprland setup script Added by @aayushrg7 in https://github.com/harilvfs/carch/pull/2
