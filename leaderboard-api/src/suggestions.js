/**
 * Anonymous Mythriven player feedback. Submissions become GitHub Issues using
 * a server-side token; no player account, email, or token is required.
 *
 * Defense in depth: strict field limits, optional honey-pot, per-IP and global
 * daily caps. Cloudflare KV limits are best-effort, not atomic bot protection.
 */
export const SUGGESTION_CATEGORIES = Object.freeze([
  "hero", "god", "weapon", "enemy", "region", "gameplay", "ui", "other",
]);

const MAX_BODY_BYTES = 6000;
const MAX_TITLE = 100;
const MAX_DESCRIPTION = 2000;
const DAILY_IP_LIMIT = 3;
const DAILY_GLOBAL_LIMIT = 40;

const jsonHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Accept",
  "Content-Type": "application/json; charset=utf-8",
  "Cache-Control": "no-store",
};

function reply(value, status = 200) {
  return new Response(JSON.stringify(value), { status, headers: jsonHeaders });
}

/** Plain text only. Replace @ to prevent unwanted GitHub user mentions. */
function clean(value) {
  return typeof value === "string"
    ? value.replace(/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/g, "").replace(/@/g, "＠").trim()
    : "";
}

export function validateSuggestion(body) {
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    return { error: "invalid suggestion" };
  }
  // Invisible spam trap; normal in-game form always sends an empty string.
  if (body.website !== undefined && body.website !== "") {
    return { error: "invalid suggestion" };
  }
  const category = clean(body.category);
  const title = clean(body.title);
  const description = clean(body.description);
  if (!SUGGESTION_CATEGORIES.includes(category)) return { error: "invalid category" };
  if (title.length < 5 || title.length > MAX_TITLE) return { error: "title must be 5–100 characters" };
  if (description.length < 20 || description.length > MAX_DESCRIPTION) {
    return { error: "description must be 20–2000 characters" };
  }
  if ((description.match(/https?:\/\//gi) || []).length > 2) {
    return { error: "too many links" };
  }
  return { category, title, description };
}

function markdownQuote(text) {
  return text.split("\n").map((line) => "> " + line).join("\n");
}

async function keyFor(ip, env, day) {
  // Hash identifiers in KV so raw IP addresses aren't stored as keys.
  const input = new TextEncoder().encode(`${day}:${ip}:${env.GITHUB_TOKEN}`);
  const digest = await crypto.subtle.digest("SHA-256", input);
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, "0")).join("");
}

export function suggestionStatus(env) {
  return reply({ accepting: Boolean(env.GITHUB_TOKEN && env.LEADERBOARD_KV) });
}

/**
 * Request handler, factored so tests can inject a fake GitHub fetch.
 * A GitHub 201 response is the only success: never claim a suggestion
 * was delivered when GitHub rejected it or the Worker is unconfigured.
 */
export async function handleSuggestionPost(request, env, ip, githubFetch = fetch) {
  if (!env.GITHUB_TOKEN || !env.LEADERBOARD_KV) {
    return reply({ error: "suggestion service not configured" }, 503);
  }
  const declared = Number(request.headers.get("content-length") || 0);
  if (declared > MAX_BODY_BYTES) return reply({ error: "message too large" }, 413);
  const raw = await request.text();
  if (new TextEncoder().encode(raw).length > MAX_BODY_BYTES) {
    return reply({ error: "message too large" }, 413);
  }
  let incoming;
  try { incoming = JSON.parse(raw); }
  catch { return reply({ error: "invalid json" }, 400); }

  const checked = validateSuggestion(incoming);
  if (checked.error) return reply({ error: checked.error }, 400);

  const day = new Date().toISOString().slice(0, 10);
  const ipKey = "suggest:ip:" + await keyFor(ip, env, day);
  const globalKey = "suggest:global:" + day;
  const [ipCount, globalCount] = await Promise.all([
    env.LEADERBOARD_KV.get(ipKey),
    env.LEADERBOARD_KV.get(globalKey),
  ]);
  if (Number(ipCount || 0) >= DAILY_IP_LIMIT || Number(globalCount || 0) >= DAILY_GLOBAL_LIMIT) {
    return reply({ error: "daily submission limit reached; try again tomorrow" }, 429);
  }

  const owner = env.GITHUB_OWNER || "Zephino";
  const repo = env.GITHUB_REPO || "Mythriven";
  const issue = {
    title: `[Player suggestion] ${checked.title}`,
    body: [
      "Anonymous suggestion from the **Mythriven** main menu.",
      "",
      `**Category:** ${checked.category}`,
      "",
      "**Suggestion:**",
      markdownQuote(checked.description),
      "",
      "*Submitted without a player account. Please do not post personal information.*",
    ].join("\n"),
  };
  let response;
  try {
    response = await githubFetch(`https://api.github.com/repos/${owner}/${repo}/issues`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        Accept: "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "Content-Type": "application/json",
        "User-Agent": "mythriven-feedback-worker",
      },
      body: JSON.stringify(issue),
    });
  } catch {
    return reply({ error: "could not reach the suggestion service" }, 502);
  }
  if (response.status !== 201) {
    console.log("Create GitHub issue failed:", response.status);
    return reply({ error: "could not save suggestion; please try again later" }, 502);
  }

  // Caps are intentionally best-effort: KV read-modify-write is not atomic.
  try {
    await Promise.all([
      env.LEADERBOARD_KV.put(ipKey, String(Number(ipCount || 0) + 1), { expirationTtl: 90000 }),
      env.LEADERBOARD_KV.put(globalKey, String(Number(globalCount || 0) + 1), { expirationTtl: 90000 }),
    ]);
  } catch (err) {
    console.log("Suggestion rate counter write failed:", String(err));
  }
  const result = await response.json().catch(() => ({}));
  return reply({ accepted: true, issue_number: Number(result.number || 0) }, 201);
}
