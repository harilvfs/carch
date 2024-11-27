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
      link: /get-started
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
  --vp-home-hero-name-background: -webkit-linear-gradient(120deg, var(--vp-c-purple-3), var(--vp-c-brand-3));

  --vp-home-hero-image-filter: blur(44px);
}

:root {
  --overlay-gradient: color-mix(in srgb, var(--vp-c-brand-1), transparent 55%);
}

.dark {
  --overlay-gradient: color-mix(in srgb, var(--vp-c-brand-1), transparent 85%);
}

.home-page {
  background:
    linear-gradient(215deg, var(--overlay-gradient), transparent 40%),
    radial-gradient(var(--overlay-gradient), transparent 40%) no-repeat -60vw -40vh / 105vw 200vh,
    radial-gradient(var(--overlay-gradient), transparent 65%) no-repeat 50% calc(100% + 20rem) / 60rem 30rem;

  .VPFeature code {
    background-color: var(--vp-code-line-highlight-color);
    color: var(--vp-code-color);
    padding: 2px;
    border-radius: 4px;
    padding: 3px 6px;
  }

  .VPFooter {
    background-color: transparent !important;
    border: none;
  }

  .VPNavBar:not(.top) {
    background-color: transparent !important;
    -webkit-backdrop-filter: blur(16px);
    backdrop-filter: blur(16px);

    div.divider {
      display: none;
    }
  }
}

@media (min-width: 640px) {
  :root {
    --vp-home-hero-image-filter: blur(76px);
  }
}

@media (min-width: 960px) {
  :root {
    --vp-home-hero-image-filter: blur(68px);
  }
}
</style>
