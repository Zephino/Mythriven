/**
 * The list of public co-op games (GAME_DESIGN.md: Online co-op / Public games).
 *
 *   GET /lobby/public   the open public games: [{code, players, level, version, in_run}]
 *
 * One PublicGames Durable Object holds the list. Each public game's LobbyRoom
 * tells it how the game is doing whenever that changes, and at least once a
 * minute while the game is open; a game not heard from for a while is dropped,
 * so the list never shows games that are gone. Friend games (shared codes) are
 * never listed.
 *
 * Binding: PUBLIC_GAMES (Durable Object class PublicGames, see wrangler.toml)
 */

import { MAX_PLAYERS } from "./lobby.js";

/** A game not heard from for this long is no longer listed. */
export const STALE_MS = 150_000;
/** How often an open public game tells the list it's still there. */
export const REFRESH_MS = 60_000;
/** Most games kept, and shown at once. */
export const MAX_GAMES = 200;
export const MAX_SHOWN = 30;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" },
  });
}

function listFor(env) {
  return env.PUBLIC_GAMES.get(env.PUBLIC_GAMES.idFromName("public"));
}

/** GET /lobby/public */
export async function handlePublicList(request, env) {
  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: { "Access-Control-Allow-Origin": "*" } });
  if (!env.PUBLIC_GAMES) return json({ games: [] });
  return listFor(env).fetch(new Request("https://public/list"));
}

/** From a LobbyRoom: this game's latest state, or `null` when it has closed. */
export async function tellPublicList(env, code, entry) {
  if (!env || !env.PUBLIC_GAMES) return;
  try {
    await listFor(env).fetch(
      new Request("https://public/put", { method: "POST", body: JSON.stringify({ code, entry }) }),
    );
  } catch (err) {
    console.log("public list update failed:", String(err));
  }
}

/** Only short, plain values are kept (the host's game sends them). */
export function cleanEntry(entry, now) {
  if (!entry || typeof entry !== "object") return null;
  const text = (v, max) => (typeof v === "string" ? v.slice(0, max) : "");
  return {
    players: Math.max(0, Math.min(MAX_PLAYERS, parseInt(entry.players, 10) || 0)),
    level: text(entry.level, 40),
    version: text(entry.version, 20),
    in_run: entry.in_run === true,
    seen: now,
  };
}

export class PublicGames {
  constructor(state) {
    this.state = state;
  }

  async games() {
    return (await this.state.storage.get("games")) || {};
  }

  async fetch(request) {
    const url = new URL(request.url);
    const now = Date.now();
    const games = await this.games();
    for (const code of Object.keys(games)) {
      if (now - games[code].seen > STALE_MS) delete games[code];
    }
    if (url.pathname === "/put") {
      const body = await request.json();
      if (typeof body.code !== "string" || !/^[0-9]{6}$/.test(body.code)) return json({ error: "bad code" }, 400);
      const entry = cleanEntry(body.entry, now);
      if (entry === null) delete games[body.code];
      else if (games[body.code] || Object.keys(games).length < MAX_GAMES) games[body.code] = entry;
      await this.state.storage.put("games", games);
      return json({ ok: true });
    }
    const shown = Object.entries(games)
      .filter(([, g]) => g.players > 0 && g.players < MAX_PLAYERS)
      .sort((a, b) => b[1].seen - a[1].seen)
      .slice(0, MAX_SHOWN)
      .map(([code, g]) => ({ code, players: g.players, level: g.level, version: g.version, in_run: g.in_run }));
    return json({ games: shown });
  }
}
