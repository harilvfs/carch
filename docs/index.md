---
layout: home
pageClass: home-page

hero:
  name: Carch 
  image:
    src: /archx.png
    alt: Archlinux logo
    style: "width: 150px; height: auto;"
  tagline: An automated script for quick & easy Arch Linux system setup 🧩
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/introduction.md
    - theme: alt
      text: View on GitHub
      link: https://github.com/harilvfs/carch
features:
  - icon: <img width="35" height="35" src="https://cdn-icons-png.flaticon.com/128/10229/10229090.png" alt="setup"/>
    title: Easy Setup
    details: Quick and straightforward installation of essential packages.
  - icon: <img width="35" height="35" src="https://cdn-icons-png.flaticon.com/128/7425/7425907.png" alt="tui"/>
    title: TUI Navigation
    details: A text-based user interface that enhances user experience.
  - icon: <img width="35" height="35" src="https://cdn-icons-png.flaticon.com/128/3131/3131638.png" alt="scripts"/>
    title: Multiple Scripts
    details: Automate the setup of various environments, including Dwm and Hyprland.
  - icon: <img width="35" height="35" src="https://cdn-icons-png.flaticon.com/128/4205/4205106.png" alt="development"/>
    title: Active Development
    details: Continuous updates and new features based on community feedback.
---

<style>
:root {
  --vp-home-hero-name-color: transparent;
  --vp-home-hero-name-background: -webkit-linear-gradient(120deg, #bd34fe 30%, #41d1ff);

  --vp-home-hero-image-background-image: linear-gradient(-45deg, #bd34fe 50%, #47caff 50%);
  --vp-home-hero-image-filter: blur(44px);
}

@media (min-width: 640px) {
  :root {
    --vp-home-hero-image-filter: blur(56px);
  }
}

@media (min-width: 960px) {
  :root {
    --vp-home-hero-image-filter: blur(68px);
  }
}
</style>
