import { test } from "node:test";
import assert from "node:assert/strict";
import worker from "../src/index.js";
import { SaveVault, hashCode, normalizeCode, validateSave, MIN_WRITE_GAP_MS, LEASE_MS } from "../src/cloud.js";

/** A stand-in for Cloudflare's Durable Objects: one SaveVault per name. */
function fakeVaults() {
  const vaults = new Map();
  return {
    names: vaults,
    idFromName(name) {
      return name;
    },
    get(id) {
      if (!vaults.has(id)) {
        const data = new Map();
        const storage = {
          async get(key) {
            return data.get(key);
          },
          async put(entries, value) {
            if (typeof entries === "string") data.set(entries, value);
            else for (const [k, v] of Object.entries(entries)) data.set(k, v);
          },
          async delete(key) {
            data.delete(key);
          },
        };
        vaults.set(id, new SaveVault({ storage }));
      }
      const vault = vaults.get(id);
      return { fetch: (url, init) => vault.fetch(new Request(url, init)) };
    },
  };
}

function request(method, code, body) {
  const headers = { Authorization: `Bearer ${code}` };
  return new Request("https://w.example/cloud/save", { method, headers, body });
}

const CODE = "ABCD-EFGH-JK23";

test("codes are checked and tidied", () => {
  assert.equal(normalizeCode("abcd efgh jk23"), "ABCDEFGHJK23");
  assert.equal(normalizeCode("ABCD-EFGH-JK2"), "", "too short");
  assert.equal(normalizeCode("ABCD-EFGH-JK2O"), "", "O is not used (looks like 0)");
  assert.equal(normalizeCode(42), "");
});

test("a save must be a game save object", () => {
  assert.ok(validateSave(JSON.stringify({ save_version: 3, gold: 5 })).save);
  assert.equal(validateSave("[]").error, "invalid save");
  assert.equal(validateSave("{").error, "invalid json");
  assert.equal(validateSave(JSON.stringify({ gold: 5 })).error, "invalid save");
  assert.equal(validateSave("x".repeat(300_000)).error, "save too large");
});

test("a save is stored and read back with the same code only", async () => {
  const env = { SAVE_VAULT: fakeVaults() };
  let res = await worker.fetch(request("GET", CODE), env);
  assert.deepEqual(await res.json(), { save: null, updated: 0 });
  res = await worker.fetch(request("PUT", CODE, JSON.stringify({ save_version: 3, gold: 77 })), env);
  assert.equal(res.status, 200);
  res = await worker.fetch(request("GET", "abcdefghjk23"), env);
  assert.equal((await res.json()).save.gold, 77);
  res = await worker.fetch(request("GET", "ZZZZ-ZZZZ-ZZZZ"), env);
  assert.equal((await res.json()).save, null, "another code sees nothing");
});

test("the code itself is never used as a storage name", async () => {
  const env = { SAVE_VAULT: fakeVaults() };
  await worker.fetch(request("GET", CODE), env);
  const names = [...env.SAVE_VAULT.names.keys()];
  assert.deepEqual(names, [await hashCode("ABCDEFGHJK23")]);
  assert.ok(!names[0].includes("ABCD"));
});

test("bad codes, bad saves, and rapid writes are refused", async () => {
  const env = { SAVE_VAULT: fakeVaults() };
  assert.equal((await worker.fetch(request("GET", "nope"), env)).status, 401);
  assert.equal((await worker.fetch(request("PUT", CODE, "{}"), env)).status, 400);
  const save = JSON.stringify({ save_version: 3 });
  assert.equal((await worker.fetch(request("PUT", CODE, save), env)).status, 200);
  assert.equal((await worker.fetch(request("PUT", CODE, save), env)).status, 429, `within ${MIN_WRITE_GAP_MS} ms`);
});

test("cloud saves answer the browser's preflight with Authorization allowed", async () => {
  const res = await worker.fetch(new Request("https://w.example/cloud/save", { method: "OPTIONS" }), {});
  assert.equal(res.status, 204);
  assert.match(res.headers.get("Access-Control-Allow-Headers"), /Authorization/);
  assert.match(res.headers.get("Access-Control-Allow-Methods"), /PUT/);
});

test("without the Durable Object set up, cloud saves say so", async () => {
  const res = await worker.fetch(request("GET", CODE), {});
  assert.equal(res.status, 503);
});

function play(code, device, action) {
  return new Request("https://w.example/cloud/play", {
    method: "POST",
    headers: { Authorization: `Bearer ${code}` },
    body: JSON.stringify({ device, action }),
  });
}

test("a save is played on one device at a time", async () => {
  const env = { SAVE_VAULT: fakeVaults() };
  assert.equal((await worker.fetch(play(CODE, "pcdevice01", "claim"), env)).status, 200);
  assert.equal((await worker.fetch(play(CODE, "phonedev01", "claim"), env)).status, 409, "the phone is turned away");
  assert.equal((await worker.fetch(play(CODE, "pcdevice01", "beat"), env)).status, 200, "the PC keeps playing");
  assert.equal((await worker.fetch(play(CODE, "phonedev01", "beat"), env)).status, 409);
  assert.equal((await worker.fetch(play(CODE, "pcdevice01", "release"), env)).status, 200);
  assert.equal((await worker.fetch(play(CODE, "phonedev01", "claim"), env)).status, 200, "free once the PC stops");
  assert.equal((await worker.fetch(play(CODE, "pcdevice01", "beat"), env)).status, 409, "the PC hears it lost the save");
  assert.equal((await worker.fetch(play("ZZZZ-ZZZZ-ZZ22", "pcdevice01", "claim"), env)).status, 200, "other saves are separate");
});

test("a claim lapses when the device stops sending beats (a closed game)", async () => {
  const env = { SAVE_VAULT: fakeVaults() };
  await worker.fetch(play(CODE, "pcdevice01", "claim"), env);
  const realNow = Date.now;
  Date.now = () => realNow() + LEASE_MS + 1000;
  try {
    assert.equal((await worker.fetch(play(CODE, "phonedev01", "claim"), env)).status, 200);
  } finally {
    Date.now = realNow;
  }
});

test("play requests need a valid device and action", async () => {
  const env = { SAVE_VAULT: fakeVaults() };
  assert.equal((await worker.fetch(play(CODE, "x", "claim"), env)).status, 400);
  assert.equal((await worker.fetch(play(CODE, "pcdevice01", "steal"), env)).status, 400);
  assert.equal((await worker.fetch(play("bad", "pcdevice01", "claim"), env)).status, 401);
});
