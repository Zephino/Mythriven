/**
 * Cloud saves (GAME_DESIGN.md: Cloud saves across PC and phone).
 *
 *   GET /cloud/save   the player's saved progress ({ save, updated } or { save: null })
 *   PUT /cloud/save   store the player's (already merged) progress
 *   POST /cloud/play  {device, action: "claim" | "beat" | "release" | "peek" | "takeover", run?}:
 *                     the one-device-at-a-time rule (owner decision 10/30/2026). A
 *                     save can be played on one device at a time: claiming it
 *                     while another device holds it answers 409 {busy: true}.
 *                     The device sends "beat" every few seconds while playing; a
 *                     claim not renewed for LEASE_MS lapses (a closed game).
 *                     Taking over a run (owner decisions 10/31/2026): a solo
 *                     run's "beat" carries a snapshot of it (`run`). Another
 *                     device can "peek" at it and "takeover": the claim moves
 *                     to that device, which gets the snapshot, and the old
 *                     device's next beat answers 409 {busy, taken}. It's a
 *                     roguelike, so a run nobody is playing can't be taken
 *                     over: the snapshot goes with the claim (released, or
 *                     lapsed after LEASE_MS) and is only handed over while the
 *                     other device is still beating (RUN_FRESH_MS).
 *
 * A player is known only by their private sync code, sent as
 * `Authorization: Bearer <code>`. The Worker never stores the code itself:
 * each save lives in its own Durable Object named by the code's SHA-256 hash,
 * so nobody can list saves or read one without the code. No names, emails,
 * or other personal data are kept.
 *
 * The game merges its save with the cloud copy before sending (unlocks are
 * combined, the higher level wins, gold comes from the newest device), so the
 * Worker just keeps what it is given.
 *
 * Binding: SAVE_VAULT (Durable Object class SaveVault, see wrangler.toml)
 */

export const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
export const CODE_LENGTH = 12;
export const MAX_SAVE_BYTES = 256_000;
/** A device may write at most once every this many ms (the game waits 30 s). */
export const MIN_WRITE_GAP_MS = 5_000;
/** A device's claim to play lapses after this long without a "beat". */
export const LEASE_MS = 90_000;
/** A run snapshot older than this (the device stopped beating) can't be taken over. */
export const RUN_FRESH_MS = 45_000;
/** The largest /cloud/play request (a beat with its run snapshot). */
export const MAX_PLAY_BYTES = 32_000;

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, PUT, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Accept, Authorization",
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
  };
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders() });
}

/** The code without dashes or spaces, upper-case; "" if it isn't a valid code. */
export function normalizeCode(raw) {
  if (typeof raw !== "string") return "";
  const code = raw.replace(/[\s-]/g, "").toUpperCase();
  if (code.length !== CODE_LENGTH) return "";
  for (const ch of code) {
    if (!CODE_ALPHABET.includes(ch)) return "";
  }
  return code;
}

export async function hashCode(code) {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode("mythriven-save:" + code));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

/** A save the Worker will keep: a JSON object from the game, not too big. */
export function validateSave(text) {
  if (typeof text !== "string" || text.length === 0) return { error: "empty save" };
  if (text.length > MAX_SAVE_BYTES) return { error: "save too large" };
  let save;
  try {
    save = JSON.parse(text);
  } catch {
    return { error: "invalid json" };
  }
  if (!save || typeof save !== "object" || Array.isArray(save)) return { error: "invalid save" };
  if (!Number.isFinite(save.save_version)) return { error: "invalid save" };
  return { save };
}

/** Routes /cloud/save and /cloud/play to the player's own SaveVault. */
export async function handleCloud(request, env) {
  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders() });
  if (!env.SAVE_VAULT) return json({ error: "cloud saves are not set up" }, 503);
  const auth = request.headers.get("Authorization") || "";
  const code = normalizeCode(auth.replace(/^Bearer\s+/i, ""));
  if (!code) return json({ error: "invalid code" }, 401);
  if (new URL(request.url).pathname === "/cloud/play") {
    if (request.method !== "POST") return json({ error: "method not allowed" }, 405);
    const text = await request.text();
    if (text.length > MAX_PLAY_BYTES) return json({ error: "too large" }, 413);
    const stub = env.SAVE_VAULT.get(env.SAVE_VAULT.idFromName(await hashCode(code)));
    return stub.fetch("https://vault/play", { method: "POST", body: text });
  }
  if (request.method !== "GET" && request.method !== "PUT") return json({ error: "method not allowed" }, 405);
  let body = "";
  if (request.method === "PUT") {
    const declared = parseInt(request.headers.get("content-length") || "0", 10);
    if (Number.isFinite(declared) && declared > MAX_SAVE_BYTES) return json({ error: "save too large" }, 413);
    body = await request.text();
    const checked = validateSave(body);
    if (checked.error) return json({ error: checked.error }, checked.error === "save too large" ? 413 : 400);
  }
  const stub = env.SAVE_VAULT.get(env.SAVE_VAULT.idFromName(await hashCode(code)));
  return stub.fetch("https://vault/save", { method: request.method, body: request.method === "PUT" ? body : undefined });
}

/** One player's cloud save. */
export class SaveVault {
  constructor(state) {
    this.storage = state.storage;
  }

  async fetch(request) {
    if (new URL(request.url).pathname === "/play") return this.play(await request.text());
    if (request.method === "GET") {
      const save = (await this.storage.get("save")) ?? null;
      const updated = (await this.storage.get("updated")) ?? 0;
      return json({ save: save ? JSON.parse(save) : null, updated });
    }
    const now = Date.now();
    const last = (await this.storage.get("updated")) ?? 0;
    if (now - last < MIN_WRITE_GAP_MS) return json({ error: "too soon", updated: last }, 429);
    const text = await request.text();
    await this.storage.put({ save: text, updated: now });
    return json({ ok: true, updated: now });
  }

  /** One device at a time: claim, keep ("beat"), let go of, peek at, or take over the right to play. */
  async play(text) {
    let body;
    try {
      body = JSON.parse(text);
    } catch {
      return json({ error: "invalid json" }, 400);
    }
    const device = typeof body.device === "string" && /^[A-Za-z0-9]{8,40}$/.test(body.device) ? body.device : "";
    const actions = ["claim", "beat", "release", "peek", "takeover"];
    if (!device || !actions.includes(body.action)) return json({ error: "invalid request" }, 400);
    const run = body.run && typeof body.run === "object" && !Array.isArray(body.run) ? body.run : null;
    const now = Date.now();
    const lease = (await this.storage.get("lease")) ?? null;
    const heldByOther = lease && lease.device !== device && lease.until > now;
    const liveRun = heldByOther && lease.run && now - (lease.beat ?? 0) <= RUN_FRESH_MS ? lease.run : null;
    if (body.action === "release") {
      if (lease && lease.device === device) await this.storage.delete("lease");
      return json({ ok: true });
    }
    if (body.action === "peek") return json({ run: liveRun });
    if (body.action === "takeover") {
      if (heldByOther && !liveRun) return json({ busy: true }, 409);
      await this.storage.put("lease", { device, until: now + LEASE_MS, beat: now, run: null, from: heldByOther ? lease.device : "" });
      return json({ ok: true, run: liveRun });
    }
    if (heldByOther) return json(lease.from === device ? { busy: true, taken: true } : { busy: true }, 409);
    const kept = body.action === "beat" ? run : null;
    await this.storage.put("lease", { device, until: now + LEASE_MS, beat: now, run: kept, from: lease && lease.device === device ? lease.from ?? "" : "" });
    return json({ ok: true });
  }
}
