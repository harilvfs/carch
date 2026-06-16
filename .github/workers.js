// Cloudflare Worker
// Redirects chalisehari.com.np/carch to the raw setup.sh on GitHub

const ROUTES = {
  "/carch": "https://raw.githubusercontent.com/harilvfs/carch/refs/heads/main/setup.sh",
//  "/i3wm": "https://raw.githubusercontent.com/harilvfs/i3wmdotfiles/refs/heads/main/setup.sh",
//  "/dwm": "https://raw.githubusercontent.com/harilvfs/dwm/refs/heads/main/setup.sh",
//  "/swaywm": "https://raw.githubusercontent.com/harilvfs/swaydotfiles/refs/heads/main/setup.sh",
};

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const target = ROUTES[url.pathname];

    if (target) {
      const upstream = await fetch(target);
      const body = await upstream.text();
      return new Response(body, {
        status: 200,
        headers: { "content-type": "text/plain; charset=utf-8" },
      });
    }

    return fetch(request);
  },
};
