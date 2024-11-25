import { defineConfig } from "vitepress";

export default defineConfig({
  title: "Carch",
  description: "Documentation for Carch",
  base: "/carch/",
  lastUpdated: true,
  themeConfig: {
    repo: "harilvfs/carch",
    docsDir: "site/docs",
    editLink: {
      pattern: "https://github.com/harilvfs/carch/edit/main/site/docs/:path",
      text: "Edit this page on GitHub",
    },
    nav: [
      { text: "Home", link: "/" },
      { text: "Get Started", link: "/getting_started/installation" },
    ],
    sidebar: [
      {
        text: "Getting Started",
        items: [
          { text: "Introduction", link: "/getting_started/introduction" },
          { text: "Installation", link: "/getting_started/installation" },
          { text: "Basics", link: "/getting_started/basics" },
        ],
      },
      {
        text: "Configuration",
        collapsible: true,
        collapsed: false,
        items: [
          { text: "Feature", link: "/configuration/feature" },
          { text: "Scripts", link: "/configuration/scripts" },
          { text: "Roadmap", link: "/configuration/roadmap" },
          { text: "Codeofconduct", link: "/configuration/codeofconduct" },
          { text: "Inspiration", link: "/configuration/inspiration" },
          { text: "Acknowledgment", link: "/configuration/acknowledgment" },
          { text: "Constributing", link: "/configuration/contributing" },
          { text: "Contact", link: "/configuration/contact" },
          { text: "Repo", link: "/configuration/repo" },
          { text: "License", link: "/configuration/license" },
          
        ],
      },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/harilvfs/carch" },
      { icon: "discord", link: "https://discord.com/invite/8NJWstnUHd" },
      { icon: "twitter", link: "https://twitter.com/harilvfs" },
    ],
    search: {
      provider: "local",
    },
  },
});
