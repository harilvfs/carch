// .vitepress/config.js
export default {
  title: 'Carch',
  description: 'Documentation website of carch',
  base: "/carch/",
  lastUpdated: true,

  head: [
        ["link", { rel: "icon", href: "/carch/penguin.webp" }],
    ],

  themeConfig: {
    siteTitle: "Carch",
    logo: "archx.png",
    outline: "deep",
    docsDir: "/docs",
    editLink: {
      pattern: "https://github.com/harilvfs/carch/tree/main/docs/:path",
      text: "Edit this page on GitHub",
    },
    nav: [
      { text: "Home", link: "/" },
      { text: "Contact", link: "/contact" },
      { 
          text: 'Changelog',
          link: 'https://github.com/harilvfs/carch/blob/main/CHANGELOG.md'
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
      { icon: "telegram", link: "https://t.me/harilvfs" },
      { icon: "discord", link: "https://discord.com/invite/8NJWstnUHd" },
    ],
    footer: {
      message: "Released under the Apache 2.0 License.",
      copyright: "Copyright © 2024 Hari Chalise",
    },
    search: {
      provider: "local",
      },
    returnToTopLabel: 'Go to Top',
    sidebarMenuLabel: 'Menu',
    },
};

