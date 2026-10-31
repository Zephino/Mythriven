/**
 * Sign in with Google (GAME_DESIGN.md: Cloud saves across PC and phone /
 * Accounts). Works the same on the web, PC, and phones: the game opens a page
 * in the browser, the player signs in with Google there, and the game asks
 * this Worker until the sign-in is done.
 *
 *   POST /auth/start             {code?} → {login, url}: the game opens `url`
 *   GET  /auth/google?login=…    sends the browser to Google's sign-in page
 *   GET  /auth/callback          Google sends the browser back here
 *   GET  /auth/poll?login=…      the game asks until it gets {state: "done", code}
 *
 * An account is Google's id for the player, kept only as a hash; no name or
 * email is asked for or kept (scope "openid"). Each account owns one cloud
 * save (a sync code, see cloud.js); signing in on a device links that device
 * to it. A device that already had cloud saves brings its save to a new account.
 *
 * Secrets (Cloudflare dashboard → the Worker → Settings → Variables and
 * Secrets): GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET. Without them /auth/start
 * answers 503 and the game says sign-in isn't set up.
 * Binding: ACCOUNTS (Durable Object class AccountVault, see wrangler.toml)
 */

import { CODE_ALPHABET, CODE_LENGTH, normalizeCode } from "./cloud.js";

/** How long a sign-in may take, from opening the page to finishing. */
export const LOGIN_TTL_MS = 10 * 60_000;
const GOOGLE_AUTH = "https://accounts.google.com/o/oauth2/v2/auth";
const GOOGLE_TOKEN = "https://oauth2.googleapis.com/token";
const GOOGLE_ISSUERS = ["https://accounts.google.com", "accounts.google.com"];

/** Lets the web version of the game call these (browsers ask first, with OPTIONS). */
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Accept",
  "Access-Control-Max-Age": "86400",
};

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" },
  });
}

/** The page the player sees in the browser at the end. */
function page(title, text, status = 200) {
  const html = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Mythriven</title><style>body{font-family:system-ui,sans-serif;background:#1b1622;color:#f2ead8;display:flex;
min-height:100vh;align-items:center;justify-content:center;margin:0;padding:16px;text-align:center}h1{font-size:1.6em}</style>
</head><body><div><h1>${title}</h1><p>${text}</p></div></body></html>`;
  return new Response(html, { status, headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" } });
}

function randomHex(bytes) {
  return [...crypto.getRandomValues(new Uint8Array(bytes))].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export function newSyncCode() {
  return [...crypto.getRandomValues(new Uint8Array(CODE_LENGTH))].map((b) => CODE_ALPHABET[b % CODE_ALPHABET.length]).join("");
}

export function isLoginId(text) {
  return typeof text === "string" && /^[0-9a-f]{32}$/.test(text);
}

async function sha256(text) {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

/** The claims inside a Google ID token (it came straight from Google over HTTPS, so it's trusted as is). */
export function tokenClaims(idToken) {
  try {
    const part = idToken.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    return JSON.parse(atob(part + "=".repeat((4 - (part.length % 4)) % 4)));
  } catch {
    return null;
  }
}

function vault(env, name) {
  return env.ACCOUNTS.get(env.ACCOUNTS.idFromName(name));
}

async function load(env, name) {
  const res = await vault(env, name).fetch("https://account/get");
  return (await res.json()).value ?? null;
}

/** `expires`: forget the value at this time (sign-ins in progress). */
async function store(env, name, value, expires = 0) {
  await vault(env, name).fetch("https://account/put", { method: "POST", body: JSON.stringify({ value, expires }) });
}

/** Routes /auth/*. */
export async function handleAuth(request, env) {
  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: CORS });
  if (!env.ACCOUNTS || !env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) {
    return json({ error: "sign-in is not set up" }, 503);
  }
  const url = new URL(request.url);
  switch (url.pathname) {
    case "/auth/start":
      return start(request, env, url);
    case "/auth/google":
      return toGoogle(env, url);
    case "/auth/callback":
      return callback(env, url);
    case "/auth/poll":
      return poll(env, url);
  }
  return json({ error: "not found" }, 404);
}

async function start(request, env, url) {
  if (request.method !== "POST") return json({ error: "method not allowed" }, 405);
  let body = {};
  try {
    body = JSON.parse((await request.text()) || "{}");
  } catch {}
  const login = randomHex(16);
  // The device's own cloud save, if it has one: a new account keeps it.
  const created = Date.now();
  await store(env, "login:" + login, { state: "waiting", created, device_code: normalizeCode(body.code || "") }, created + LOGIN_TTL_MS);
  return json({ login, url: `${url.origin}/auth/google?login=${login}` });
}

async function toGoogle(env, url) {
  const login = url.searchParams.get("login") || "";
  const ticket = isLoginId(login) ? await load(env, "login:" + login) : null;
  if (!ticket || ticket.state !== "waiting" || Date.now() - ticket.created > LOGIN_TTL_MS) {
    return page("Sign-in expired", "Go back to Mythriven and press Sign in with Google again.", 400);
  }
  const params = new URLSearchParams({
    client_id: env.GOOGLE_CLIENT_ID,
    redirect_uri: `${url.origin}/auth/callback`,
    response_type: "code",
    scope: "openid",
    state: login,
    prompt: "select_account",
  });
  return Response.redirect(`${GOOGLE_AUTH}?${params}`, 302);
}

async function callback(env, url) {
  const login = url.searchParams.get("state") || "";
  const ticket = isLoginId(login) ? await load(env, "login:" + login) : null;
  if (!ticket || ticket.state !== "waiting" || Date.now() - ticket.created > LOGIN_TTL_MS) {
    return page("Sign-in expired", "Go back to Mythriven and press Sign in with Google again.", 400);
  }
  const code = url.searchParams.get("code");
  if (!code) {
    await store(env, "login:" + login, { ...ticket, state: "cancelled" }, ticket.created + LOGIN_TTL_MS);
    return page("Sign-in cancelled", "You can close this tab and go back to Mythriven.");
  }
  const res = await fetch(GOOGLE_TOKEN, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      code,
      client_id: env.GOOGLE_CLIENT_ID,
      client_secret: env.GOOGLE_CLIENT_SECRET,
      redirect_uri: `${url.origin}/auth/callback`,
      grant_type: "authorization_code",
    }),
  });
  const claims = res.ok ? tokenClaims((await res.json()).id_token || "") : null;
  if (!claims || !claims.sub || claims.aud !== env.GOOGLE_CLIENT_ID || !GOOGLE_ISSUERS.includes(claims.iss)) {
    console.log("google sign-in failed:", res.status);
    return page("Sign-in failed", "Something went wrong with Google. Go back to Mythriven and try again.", 502);
  }
  const accountName = "google:" + (await sha256("mythriven-account:" + claims.sub));
  let account = await load(env, accountName);
  if (!account) {
    account = { code: ticket.device_code || newSyncCode(), created: Date.now() };
    await store(env, accountName, account);
  }
  await store(env, "login:" + login, { state: "done", created: ticket.created, code: account.code }, ticket.created + LOGIN_TTL_MS);
  return page("Signed in!", "You can close this tab and go back to Mythriven.");
}

async function poll(env, url) {
  const login = url.searchParams.get("login") || "";
  if (!isLoginId(login)) return json({ error: "invalid login" }, 400);
  const ticket = await load(env, "login:" + login);
  if (!ticket || Date.now() - ticket.created > LOGIN_TTL_MS) return json({ state: "expired" });
  if (ticket.state !== "done") return json({ state: ticket.state });
  // Handed over once, then forgotten.
  await vault(env, "login:" + login).fetch("https://account/delete", { method: "POST" });
  return json({ state: "done", code: ticket.code });
}

/** One account, or one sign-in in progress: a small stored value. */
export class AccountVault {
  constructor(state) {
    this.storage = state.storage;
  }

  async fetch(request) {
    const path = new URL(request.url).pathname;
    if (path === "/put") {
      const body = await request.json();
      await this.storage.put("value", body.value);
      if (body.expires && this.storage.setAlarm) await this.storage.setAlarm(body.expires);
      return json({ ok: true });
    }
    if (path === "/delete") {
      await this.storage.deleteAll();
      return json({ ok: true });
    }
    return json({ value: (await this.storage.get("value")) ?? null });
  }

  /** A sign-in that was never finished is forgotten. */
  async alarm() {
    await this.storage.deleteAll();
  }
}
