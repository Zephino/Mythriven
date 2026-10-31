/**
 * The privacy policy (GET /privacy), linked from Google's sign-in screen
 * (Google Auth Platform → Branding). Plain text about what the game and this
 * Worker keep; update it whenever that changes.
 */

const CONTACT = "thebotcoder@gmail.com";

const SECTIONS = [
  ["What Mythriven keeps", [
    "<b>Sign in with Google:</b> only Google's account id for you, stored scrambled (hashed). Mythriven never asks Google for your name, email, or picture.",
    "<b>Cloud save:</b> your game progress (unlocks, gold, records, settings), stored under your account or your private sync code, so it can follow you between devices.",
    "<b>One device at a time:</b> a random id for the device currently playing your save, kept for about 90 seconds after it stops.",
    "<b>Leaderboard:</b> the name you type (up to 12 characters) and your run's score, shown publicly. Co-op runs aren't sent.",
    "<b>Suggestions:</b> the text you send, posted anonymously as a GitHub issue on the game's repository.",
  ]],
  ["What it doesn't do", [
    "No ads, no tracking, no analytics, and nothing is sold or shared with anyone.",
    "Co-op games only pass messages between the players; nothing about a co-op game is kept after it ends.",
    "Your progress is also saved on your own device and the game works without an account.",
  ]],
  ["Deleting your data", [
    `In the game, Settings → Account and cloud save → Sign out (or Turn off) stops syncing on that device. To have your cloud save and account deleted from the server, email ${CONTACT}.`,
  ]],
  ["Where it's stored", [
    "On Cloudflare (Workers and Durable Objects), which runs the game's online features. The leaderboard is also kept on the game's GitHub repository.",
  ]],
];

export function privacyPage() {
  const body = SECTIONS.map(([title, items]) => `<h2>${title}</h2><ul>${items.map((i) => `<li>${i}</li>`).join("")}</ul>`).join("");
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Mythriven — Privacy policy</title><style>body{font-family:system-ui,sans-serif;background:#1b1622;color:#f2ead8;max-width:720px;
margin:0 auto;padding:16px;line-height:1.5}h1{font-size:1.6em}h2{font-size:1.15em;margin-top:1.5em}a{color:#e7c46a}</style></head>
<body><h1>Mythriven — Privacy policy</h1><p>Last updated October 31, 2026. Mythriven is a game made by one developer. This page says what it keeps about you.</p>
${body}<p><a href="https://zephino.github.io/Mythriven/">Play Mythriven</a></p></body></html>`;
  return new Response(html, { headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "public, max-age=3600" } });
}
