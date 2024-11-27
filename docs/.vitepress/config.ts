// .vitepress/config.js
export default {
  title: 'Carch',
  description: 'Documentation website of carch',
  lastUpdated: true,
  themeConfig: {
    siteTitle: "Carch",
    repo: "harilvfs/carch",
    docsDir: "/docs",
    editLink: {
      pattern: "https://github.com/harilvfs/carch/tree/main/docs/:path",
      text: "Edit this page on GitHub",
    },
    nav: [
      { text: "Home", link: "/" },
      { text: "Contact", link: "/contact" },
      { 
        text: "Changelog",
        items: [
          { text: "v3.0.1", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.1" },
          { text: "v3.0.2", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.2" },
          { text: "v3.0.3", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.3" },
          { text: "v3.0.4", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.4" },
          { text: "v3.0.5", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.5" },
          { text: "v3.0.6", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.6" },
          { text: "v3.0.7", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.7" },
          { text: "v3.0.8", link: "https://github.com/harilvfs/carch/releases/tag/v3.0.8" },
        ],
      },
    ],
    sidebar: [
      {
        text: "Getting Started",
        collapsible: true,
        collapsed: false,
        items: [
          { text: "Introduction", link: "/getting-started/introduction" },
          { text: "Preview", link: "/getting-started/preview.md" },
        ],
      },
      {
        text: "Installation",
        collapsible: true,
        collapsed: false,
        items: [
          { text: "Terminal", link: "/installation/cli" },
          { text: "Commands", link: "/installation/cmd" },
          { text: "GTK", link: "/installation/gtk" },
          { text: "Arch [AUR]", link: "/installation/aur" },
        ],
      },
      {
        text: "Utilities",
        collapsible: true,
        collapsed: false,
        items: [
          { text: "Overview Scripts", link: "/scripts/scripts" },
        ],
      },
      {
        text: "Collaboration",
        collapsible: true,
        collapsed: false,
        items: [
          { text: "Roadmap", link: "/github/roadmap" },
          { text: "Contributing", link: "/github/contributing" },
          { text: "Code of Conduct", link: "/github/codeofconduct" },
        ],
      },
     {
        text: "Acknowledgment",
        collapsible: true,
        collapsed: false,
        items: [
          { text: "Inspiration", link: "/acknowledgment/inspiration" },
          { text: "Contributions", link: "/acknowledgment/contributors" },
        ],
      },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/harilvfs/carch" },
      { icon: "twitter", link: "https://twitter.com/harilvfs" },
      { icon: "discord", link: "https://discord.com/invite/8NJWstnUHd" },
    ],
    search: {
      provider: "local",
      },
     markdown: {
      theme: "material-palenight",
      lineNumbers: true,
    },
    returnToTopLabel: 'Go to Top',
    sidebarMenuLabel: 'Menu',
    },
    footer: {
      message: "Released under the Apache 2.0 License.",
      copyright: "Copyright © 2024 Hari Chalise",
    },
};

