import { test } from "node:test";
import assert from "node:assert/strict";
import worker from "../src/index.js";
import { LobbyRoom, HOST_ID, MAX_PLAYERS, MAX_MESSAGES_PER_S, isCode, randomCode } from "../src/lobby.js";
import { PublicGames, STALE_MS, cleanEntry } from "../src/public_games.js";

/** Stand-ins for Cloudflare's WebSockets and Durable Object state. */
class FakeSocket {
  constructor() {
    this.sent = [];
    this.closed = null;
    this.attachment = null;
  }
  send(data) {
    this.sent.push(typeof data === "string" ? JSON.parse(data) : [...data]);
  }
  close(code, reason) {
    this.closed = { code, reason };
  }
  serializeAttachment(v) {
    this.attachment = v;
  }
  deserializeAttachment() {
    return this.attachment;
  }
}

function fakeStorage(data) {
  return {
    async get(k) {
      return data.get(k);
    },
    async put(k, v) {
      if (typeof k === "object") for (const [a, b] of Object.entries(k)) data.set(a, b);
      else data.set(k, v);
    },
    async deleteAll() {
      data.clear();
    },
  };
}

/** A PublicGames list the rooms can reach, as `env.PUBLIC_GAMES`. */
function fakePublicList() {
  const list = new PublicGames({ storage: fakeStorage(new Map()) });
  const env = { PUBLIC_GAMES: { idFromName: (n) => n, get: () => list } };
  env.games = async () => (await (await list.fetch(new Request("https://public/list"))).json()).games;
  return env;
}

function fakeRoom(env = {}) {
  const sockets = [];
  const data = new Map();
  const state = {
    acceptWebSocket(ws) {
      sockets.push(ws);
    },
    getWebSockets() {
      return sockets.filter((ws) => !ws.closed);
    },
    storage: fakeStorage(data),
  };
  // Responses with status 101 aren't allowed in Node, so the room's reply is faked too.
  const room = new LobbyRoom(state, env, () => [new FakeSocket(), new FakeSocket()]);
  const original = room.fetch.bind(room);
  room.connect = async (role, code = "123456", isPublic = false) => {
    const headers = new Headers({ "X-Lobby-Code": code, "X-Lobby-Role": role });
    if (isPublic) headers.set("X-Lobby-Public", "1");
    const before = sockets.length;
    let res;
    try {
      res = await original(new Request("https://lobby/connect", { headers }));
    } catch (err) {
      // new Response(null, {status: 101}) throws in Node: the socket was still accepted.
      if (sockets.length > before) return { status: 101, socket: sockets[sockets.length - 1] };
      throw err;
    }
    return { status: res.status, text: await res.text() };
  };
  return { room, sockets };
}

test("codes are 6 digits", () => {
  for (let i = 0; i < 50; i++) assert.ok(isCode(randomCode()));
  assert.equal(isCode("12345"), false);
  assert.equal(isCode("12a456"), false);
});

test("the host gets id 1 and players join with 2, 3, 4", async () => {
  const { room } = fakeRoom();
  const host = await room.connect("host");
  assert.equal(host.status, 101);
  assert.equal(host.socket.sent[0].t, "welcome");
  assert.equal(host.socket.sent[0].id, HOST_ID);
  const ids = [];
  for (let i = 0; i < MAX_PLAYERS - 1; i++) ids.push((await room.connect("join")).socket.sent[0].id);
  assert.deepEqual(ids, [2, 3, 4]);
  assert.deepEqual(host.socket.sent.slice(1).map((m) => m.id), [2, 3, 4], "the host hears each join");
  const fifth = await room.connect("join");
  assert.equal(fifth.status, 409, "4 players at most");
});

test("joining needs a host, and a code in use can't be hosted again", async () => {
  const { room } = fakeRoom();
  assert.equal((await room.connect("join")).status, 404);
  await room.connect("host");
  assert.equal((await room.connect("host")).status, 409);
});

test("friend games can be joined during a run and between runs", async () => {
  const { room } = fakeRoom();
  const host = await room.connect("host");
  await room.webSocketMessage(host.socket, JSON.stringify({ t: "start" }));
  assert.equal((await room.connect("join")).status, 101, "joining a run in progress");
  await room.webSocketMessage(host.socket, JSON.stringify({ t: "open" }));
  assert.equal((await room.connect("join")).status, 101, "joining again between runs");
});

test("binary messages are relayed with the sender's id, to everyone or one player", async () => {
  const { room } = fakeRoom();
  const host = (await room.connect("host")).socket;
  const a = (await room.connect("join")).socket;
  const b = (await room.connect("join")).socket;
  host.sent = [];
  a.sent = [];
  b.sent = [];
  await room.webSocketMessage(host, new Uint8Array([0, 7, 8]).buffer);
  assert.deepEqual(a.sent, [[1, 7, 8]]);
  assert.deepEqual(b.sent, [[1, 7, 8]]);
  assert.deepEqual(host.sent, [], "not echoed back");
  await room.webSocketMessage(a, new Uint8Array([1, 9]).buffer);
  assert.deepEqual(host.sent, [[2, 9]]);
  assert.equal(b.sent.length, 1, "only to the host");
});

test("only the host can send room commands, and too many messages are dropped", async () => {
  const { room } = fakeRoom();
  const host = (await room.connect("host")).socket;
  const a = (await room.connect("join")).socket;
  await room.webSocketMessage(a, JSON.stringify({ t: "start" }));
  assert.equal((await room.connect("join")).status, 101, "a player can't start the game");
  host.sent = [];
  for (let i = 0; i < MAX_MESSAGES_PER_S + 20; i++) await room.webSocketMessage(a, new Uint8Array([1, 1]).buffer);
  assert.ok(host.sent.length <= MAX_MESSAGES_PER_S);
});

test("when the host leaves the game ends for everyone; a player leaving is announced", async () => {
  const { room } = fakeRoom();
  const host = (await room.connect("host")).socket;
  const a = (await room.connect("join")).socket;
  const b = (await room.connect("join")).socket;
  a.closed = { code: 1000 };
  await room.webSocketClose(a);
  assert.deepEqual(b.sent.at(-1), { t: "leave", id: 2 });
  host.closed = { code: 1000 };
  await room.webSocketClose(host);
  assert.equal(b.closed.code, 4000);
});

test("the lobby route needs a WebSocket and a valid code", async () => {
  const env = { LOBBY: { idFromName: (n) => n, get: () => ({ fetch: async () => new Response("ok") }) } };
  assert.equal((await worker.fetch(new Request("https://w.example/lobby?code=123456"), env)).status, 426);
  const ws = { headers: { Upgrade: "websocket" } };
  assert.equal((await worker.fetch(new Request("https://w.example/lobby?code=12", ws), env)).status, 400);
  assert.equal((await worker.fetch(new Request("https://w.example/lobby?code=123456", ws), {})).status, 503);
});

test("a public game is listed, can be joined during a run, and leaves the list when it ends", async () => {
  const env = fakePublicList();
  const { room } = fakeRoom(env);
  const host = (await room.connect("host", "222222", true)).socket;
  await room.webSocketMessage(host, JSON.stringify({ t: "info", level: "aegean", version: "00.01.32" }));
  assert.deepEqual(await env.games(), [{ code: "222222", players: 1, level: "aegean", version: "00.01.32", in_run: false }]);
  await room.webSocketMessage(host, JSON.stringify({ t: "start" }));
  const late = await room.connect("join", "222222");
  assert.equal(late.status, 101, "joining a public game in progress");
  assert.deepEqual((await env.games()).map((g) => [g.players, g.in_run]), [[2, true]]);
  host.closed = { code: 1000 };
  await room.webSocketClose(host);
  assert.deepEqual(await env.games(), [], "gone when the host leaves");
});

test("friend games are never listed, and full or silent games aren't shown", async () => {
  const env = fakePublicList();
  const { room } = fakeRoom(env);
  await room.connect("host", "333333");
  assert.deepEqual(await env.games(), []);
  const list = env.PUBLIC_GAMES.get();
  const put = (code, entry) => list.fetch(new Request("https://public/put", { method: "POST", body: JSON.stringify({ code, entry }) }));
  await put("444444", { players: MAX_PLAYERS, level: "x" });
  await put("555555", { players: 1, level: "<b>".repeat(50) });
  assert.deepEqual((await env.games()).map((g) => g.code), ["555555"], "a full game isn't shown");
  assert.equal((await env.games())[0].level.length, 40, "text is cut short");
  const realNow = Date.now;
  Date.now = () => realNow() + STALE_MS + 1000;
  try {
    assert.deepEqual(await env.games(), [], "a game not heard from is dropped");
  } finally {
    Date.now = realNow;
  }
  assert.equal(cleanEntry(null, 0), null);
});

test("the public list route answers without the list set up", async () => {
  const res = await worker.fetch(new Request("https://w.example/lobby/public"), {});
  assert.deepEqual(await res.json(), { games: [] });
});

test("a host can put a game on the public list and take it off again", async () => {
  const env = fakePublicList();
  const { room } = fakeRoom(env);
  const host = (await room.connect("host", "666666")).socket;
  await room.webSocketMessage(host, JSON.stringify({ t: "start" }));
  assert.deepEqual(await env.games(), [], "a friend game isn't listed");
  await room.webSocketMessage(host, JSON.stringify({ t: "info", level: "aegean_shore", version: "1" }));
  await room.webSocketMessage(host, JSON.stringify({ t: "public", on: true }));
  assert.deepEqual((await env.games()).map((g) => [g.code, g.in_run]), [["666666", true]], "listed, in a run");
  await room.webSocketMessage(host, JSON.stringify({ t: "public", on: false }));
  assert.deepEqual(await env.games(), [], "taken off the list");
});
