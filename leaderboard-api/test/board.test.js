import { test } from "node:test";
import assert from "node:assert/strict";
import worker from "../src/index.js";
import {
  MAX_ENTRIES,
  addEntry,
  emptyBoard,
  normalizeBoard,
  qualifies,
  sanitizeName,
  validateScore,
} from "../src/board.js";

function score(overrides = {}) {
  return {
    name: "Ari",
    hero: "heracles",
    time_s: 600,
    level: 20,
    kills: 900,
    weapons: [{ id: "great_club", level: 8 }, { id: "longbow", level: 3 }],
    passives: { spartan_shield: 2 },
    version: "00.01.15",
    ...overrides,
  };
}

test("a normal score is accepted and passives become a list", () => {
  const { entry, error } = validateScore(score());
  assert.equal(error, undefined);
  assert.deepEqual(entry.passives, [{ id: "spartan_shield", level: 2 }]);
});

test("names keep only safe characters and are cut to 12", () => {
  assert.equal(sanitizeName("  Zeph  ino!!  "), "Zeph ino");
  assert.equal(sanitizeName("ABCDEFGHIJKLMNOP"), "ABCDEFGHIJKL");
  assert.equal(validateScore(score({ name: "<script>" })).error, "invalid name");
  assert.equal(validateScore(score({ name: "!!!" })).error, "invalid name");
});

test("impossible numbers are refused", () => {
  assert.equal(validateScore(score({ time_s: 0 })).error, "invalid time");
  assert.equal(validateScore(score({ time_s: 12.5 })).error, "invalid time");
  assert.equal(validateScore(score({ level: 5000 })).error, "invalid level");
  assert.equal(validateScore(score({ time_s: 10, level: 2, kills: 99999 })).error, "invalid kills");
  assert.equal(validateScore(score({ weapons: [] })).error, "invalid weapons");
  assert.equal(validateScore(score({ weapons: [{ id: "BAD ID", level: 1 }] })).error, "invalid weapons");
  assert.equal(validateScore(score({ passives: { might: 99 } })).error, "invalid passives");
  assert.equal(validateScore(score({ hero: "../main" })).error, "invalid hero");
  assert.equal(validateScore(score({ version: "1" })).error, "invalid version");
});

test("longest survival ranks first, then level, then kills", () => {
  let board = emptyBoard();
  board = addEntry(board, validateScore(score({ name: "A", time_s: 300 })).entry, "2026-10-28T00:00:00Z");
  board = addEntry(board, validateScore(score({ name: "B", time_s: 900 })).entry, "2026-10-28T00:00:01Z");
  board = addEntry(board, validateScore(score({ name: "C", time_s: 900, level: 25 })).entry, "2026-10-28T00:00:02Z");
  assert.deepEqual(board.entries.map((e) => e.name), ["C", "B", "A"]);
});

test("the board keeps only the best 100", () => {
  let board = emptyBoard();
  for (let i = 1; i <= MAX_ENTRIES; i++) {
    board = addEntry(board, validateScore(score({ name: `P${i}`, time_s: 100 + i })).entry, "2026-10-28T00:00:00Z");
  }
  assert.equal(qualifies(board, validateScore(score({ time_s: 50 })).entry), false);
  assert.equal(qualifies(board, validateScore(score({ time_s: 5000 })).entry), true);
});

test("hand-edited junk in the stored file is dropped", () => {
  const board = normalizeBoard({ entries: [score({ date: "2026-10-28T00:00:00Z" }), { name: "x", time_s: "lots" }, 7] });
  assert.equal(board.entries.length, 1);
});

function fakeEnv() {
  const store = new Map();
  return {
    LEADERBOARD_KV: {
      async get(key) {
        return store.has(key) ? JSON.parse(store.get(key)) : null;
      },
      async put(key, value) {
        store.set(key, value);
      },
    },
  };
}

function post(body, ip = "1.2.3.4") {
  return new Request("https://example.workers.dev/leaderboard", {
    method: "POST",
    headers: { "Content-Type": "application/json", "CF-Connecting-IP": ip },
    body: JSON.stringify(body),
  });
}

test("the Worker saves a score and refuses a duplicate", async () => {
  const env = fakeEnv();
  await env.LEADERBOARD_KV.put("board", JSON.stringify(emptyBoard()));
  const first = await (await worker.fetch(post(score()), env)).json();
  assert.equal(first.accepted, true);
  assert.equal(first.entries.length, 1);
  assert.match(first.entries[0].date, /^\d{4}-/);
  const again = await (await worker.fetch(post(score()), env)).json();
  assert.equal(again.accepted, false);
  const bad = await worker.fetch(post(score({ kills: -1 })), env);
  assert.equal(bad.status, 400);
  const board = await (await worker.fetch(new Request("https://example.workers.dev/leaderboard"), env)).json();
  assert.equal(board.entries.length, 1);
});

test("one player can't flood the board", async () => {
  const env = fakeEnv();
  await env.LEADERBOARD_KV.put("board", JSON.stringify(emptyBoard()));
  const statuses = [];
  for (let i = 0; i < 5; i++) {
    statuses.push((await worker.fetch(post(score({ time_s: 100 + i }), "9.9.9.9"), env)).status);
  }
  assert.deepEqual(statuses, [200, 200, 200, 429, 429]);
});
