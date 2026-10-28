/**
 * Mythriven leaderboard rules: what a score must look like, how the board is
 * sorted, and how many rows it keeps. No network code here, so it can be
 * tested with `npm test`.
 *
 * A score (one row):
 *   name     player-chosen, letters/numbers/space/_/- only, up to 12
 *   hero     Hero id, e.g. "heracles"
 *   time_s   seconds survived (the main ranking)
 *   level    level reached (first tie-break)
 *   kills    enemies defeated (second tie-break)
 *   weapons  [{ id, level }]    the weapons held at the end
 *   passives [{ id, level }]    the upgrades (passive items) taken
 *   version  game version, "XX.XX.XX"
 *   date     set by the Worker, never by the game
 */

export const MAX_ENTRIES = 100;
export const MAX_NAME_LENGTH = 12;
export const MAX_ITEMS = 12;
export const MAX_ITEM_LEVEL = 20;
export const MAX_TIME_S = 6 * 60 * 60;
export const MAX_LEVEL = 2000;
export const MAX_KILLS = 1_000_000;
/** No one defeats more than this many enemies per second on average. */
export const MAX_KILLS_PER_S = 300;
export const ABOUT =
  "Mythriven shared leaderboard. Written only by the leaderboard Worker; edits by hand are overwritten.";

const ID_PATTERN = /^[a-z0-9_]{1,32}$/;
const VERSION_PATTERN = /^\d{2}\.\d{2}\.\d{2}$/;
/** Script / markup characters: a name containing any of these is refused outright. */
const INJECTION_MARKERS = ["'", '"', ";", "--", "/*", "*/", "\\", "`", "<", ">"];

export function looksLikeInjection(raw) {
  const s = String(raw ?? "");
  for (const marker of INJECTION_MARKERS) {
    if (s.includes(marker)) return true;
  }
  for (let i = 0; i < s.length; i++) {
    const code = s.charCodeAt(i);
    if (code < 32) return true;
  }
  return false;
}

/** Keeps A–Z, a–z, 0–9, space, _ and -; trims; cuts to 12. */
export function sanitizeName(raw) {
  let cleaned = "";
  for (const ch of String(raw ?? "")) {
    if (/[A-Za-z0-9 _-]/.test(ch)) cleaned += ch;
  }
  cleaned = cleaned.replace(/ {2,}/g, " ").trim();
  return cleaned.slice(0, MAX_NAME_LENGTH).trim();
}

function wholeNumber(raw, min, max) {
  const n = Number(raw);
  if (!Number.isFinite(n) || !Number.isInteger(n) || n < min || n > max) return null;
  return n;
}

/** [{id, level}] from either a list of {id, level} or an {id: level} object. */
function normalizeItems(raw) {
  let pairs = [];
  if (Array.isArray(raw)) {
    pairs = raw.map((item) => [item?.id, item?.level]);
  } else if (raw && typeof raw === "object") {
    pairs = Object.entries(raw);
  } else if (raw !== undefined && raw !== null) {
    return null;
  }
  if (pairs.length > MAX_ITEMS) return null;
  const seen = new Set();
  const out = [];
  for (const [id, level] of pairs) {
    const cleanId = String(id ?? "");
    const cleanLevel = wholeNumber(level, 1, MAX_ITEM_LEVEL);
    if (!ID_PATTERN.test(cleanId) || cleanLevel === null || seen.has(cleanId)) return null;
    seen.add(cleanId);
    out.push({ id: cleanId, level: cleanLevel });
  }
  return out;
}

/**
 * Checks one score. Returns { entry } when it's acceptable, or { error } with
 * a short reason. `date` is added by the caller.
 */
export function validateScore(body) {
  if (!body || typeof body !== "object" || Array.isArray(body)) return { error: "invalid json" };
  if (looksLikeInjection(body.name)) return { error: "invalid name" };
  const name = sanitizeName(body.name);
  if (!name) return { error: "invalid name" };
  const hero = String(body.hero ?? "");
  if (!ID_PATTERN.test(hero)) return { error: "invalid hero" };
  const time_s = wholeNumber(body.time_s, 1, MAX_TIME_S);
  if (time_s === null) return { error: "invalid time" };
  const level = wholeNumber(body.level, 1, MAX_LEVEL);
  if (level === null || level > time_s + 1) return { error: "invalid level" };
  const kills = wholeNumber(body.kills, 0, MAX_KILLS);
  if (kills === null || kills > time_s * MAX_KILLS_PER_S) return { error: "invalid kills" };
  const weapons = normalizeItems(body.weapons);
  if (weapons === null || weapons.length === 0) return { error: "invalid weapons" };
  const passives = normalizeItems(body.passives);
  if (passives === null) return { error: "invalid passives" };
  const version = String(body.version ?? "");
  if (!VERSION_PATTERN.test(version)) return { error: "invalid version" };
  return { entry: { name, hero, time_s, level, kills, weapons, passives, version } };
}

/** Longest survival first, then highest level, then most kills, then earliest. */
export function compareEntries(a, b) {
  return (
    b.time_s - a.time_s ||
    b.level - a.level ||
    b.kills - a.kills ||
    String(a.date ?? "").localeCompare(String(b.date ?? ""))
  );
}

/** The same run sent twice (for example a double tap on Submit). */
export function isDuplicate(entries, entry) {
  return entries.some(
    (e) =>
      e.name === entry.name &&
      e.hero === entry.hero &&
      e.time_s === entry.time_s &&
      e.level === entry.level &&
      e.kills === entry.kills,
  );
}

/** Rebuilds a board from stored data, dropping anything malformed. */
export function normalizeBoard(raw) {
  const entries = [];
  for (const item of Array.isArray(raw?.entries) ? raw.entries : []) {
    const checked = validateScore(item);
    if (!checked.entry) continue;
    const date = String(item.date ?? "");
    checked.entry.date = /^\d{4}-\d{2}-\d{2}T[\d:.]+Z$/.test(date) ? date : "";
    entries.push(checked.entry);
  }
  entries.sort(compareEntries);
  return {
    _about: ABOUT,
    updated: typeof raw?.updated === "string" ? raw.updated : "",
    entries: entries.slice(0, MAX_ENTRIES),
  };
}

/** True when `entry` would make the board (it isn't full, or beats the last row). */
export function qualifies(board, entry) {
  if (board.entries.length < MAX_ENTRIES) return true;
  return compareEntries(entry, board.entries[board.entries.length - 1]) < 0;
}

/** Adds `entry` (with its date) and returns the new board. */
export function addEntry(board, entry, nowIso) {
  const entries = [...board.entries, { ...entry, date: nowIso }];
  entries.sort(compareEntries);
  return { _about: ABOUT, updated: nowIso, entries: entries.slice(0, MAX_ENTRIES) };
}

export function emptyBoard() {
  return { _about: ABOUT, updated: "", entries: [] };
}
