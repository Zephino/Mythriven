# Mythriven leaderboard service

A tiny free **Cloudflare Worker** (an always-on mini web service) that keeps the
shared leaderboard. It is the only thing allowed to write the board.

```
Game ──POST score──▶ Worker (checks it) ──▶ Workers KV (fast copy)
                                        └─▶ GitHub: leaderboard.json on the `data` branch
Game ◀──GET board── Worker  (or straight from GitHub before the Worker is set up)
```

- The game **never holds a GitHub key**. The key lives only on Cloudflare as a
  secret, so players can't edit the `data` branch; they can only send a score
  through the Worker, which refuses anything malformed or impossible.
- Each score keeps: name, Hero, time survived, level, kills, weapons (with
  levels), upgrades (passive items with levels), game version, and the date
  (set by the Worker). Best 100 are kept, ranked by time survived, then level,
  then kills.
- The board on GitHub: https://github.com/Zephino/Mythriven/blob/data/leaderboard.json

## One-time setup (owner only, on your PC)

You need: [Node.js LTS](https://nodejs.org/), a free Cloudflare account, and a
GitHub token. **Never paste the token into a chat**; only into the setup app.

1. **GitHub token.** Open https://github.com/settings/personal-access-tokens/new
   - Token name: `mythriven-leaderboard`; Expiration: 1 year (set a reminder).
   - Repository access: **Only select repositories** → `Zephino/Mythriven`.
   - Repository permissions → **Contents: Read and write**. Nothing else.
   - Generate, and copy it.
2. **Run the setup app.** Double-click `leaderboard-api/Setup-Leaderboard.bat`
   (Windows) or run `bash setup-leaderboard.sh` (Mac/Linux). It installs the
   tools, logs you into Cloudflare in your browser, creates the storage,
   stores the token as a Cloudflare secret, deploys the Worker, and writes the
   Worker's address into `scripts/net/online_config.gd`.
   - If it says you need a **workers.dev subdomain**: pick any name on the
     page that opens, then click **5. Retry deploy only**.
3. **Push** the changed `scripts/net/online_config.gd` to `main` (or ask
   Claude to). The web game rebuilds itself and starts sending scores.
4. Check it: open `<your worker address>/leaderboard` in a browser; you
   should see `{"_about": ..., "entries": []}`.

## Protecting the `data` branch (recommended)

Only you (and collaborators you add) can push to your repo at all; strangers
can't. This adds a safety net against accidents:

GitHub → the Mythriven repo → **Settings → Rules → Rulesets → New ruleset →
New branch ruleset**
- Name: `data branch`; Enforcement: **Active**
- Target branches → **Add target → Include by pattern** → `data`
- Tick **Restrict deletions** and **Block force pushes**. Leave the rest off
  (turning on "Restrict updates" would also block the Worker).
- **Create**.

## If the token expires

Make a new one (step 1), then in this folder run
`npx wrangler secret put GITHUB_TOKEN` and paste it there. No game change needed.

## Honest limits

Scores come from players' browsers, so a determined cheater could fake one.
The Worker refuses impossible numbers (for example more kills than possible in
the time, unknown-looking ids, huge levels), double submissions, and more than
3 scores a minute from one address. Runs where the F1 debug menu was used are
never sent. To remove a bad score, ask Claude: it can be removed from the
Worker's storage.

## For developers

- `src/board.js`: the rules (what a score must look like, ranking, size).
- `src/index.js`: the web service (GET/POST, rate limits, GitHub commit).
- `npm test`: checks the rules and the service with a pretend storage.
- `.gdignore` keeps Godot from importing this folder.
