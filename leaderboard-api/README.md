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
   - Repository permissions → **Contents: Read and write** and **Issues: Read and write**. These allow the Worker to save leaderboards and create suggestion issues. No other permissions are needed.
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

## Cloudflare Git-connected deployment

If Cloudflare's **Settings → Builds** says "You can now push a commit to your Git
repository to start your first build," make sure these settings are saved:

- Git repository: `Zephino/Mythriven`
- Production branch: `main`
- Root directory: `leaderboard-api` (not the repository root)
- Build command: blank / None
- Deploy command: `npx wrangler deploy`

The Worker name in `wrangler.toml` is `mythriven`, and `LEADERBOARD_KV` is
bound to the `mythriven-data` namespace. Once these settings are saved, a
new push to `main` should trigger Cloudflare's first build. **Check the
Cloudflare deployment status separately**; a successful GitHub Pages build does
not confirm that the Worker deployed successfully.

## Anonymous suggestions

Mythriven's **Suggest a Feature** button sits on the **main Hero-selection screen only**.
Clicking it opens a dialog inside the game (not GitHub), with a category, short
title, description, and Send/Close buttons. Players don't need any account or
have to give an email address.

```text
Player in-game suggestion window
           |
           |  POST /suggestions (category, title, description)
           v
   Cloudflare Worker   -- checks length, category and daily limits
           |
           |  GitHub Issues API (private server-side GITHUB_TOKEN)
           v
   GitHub: Zephino/Mythriven -> Issues
```

**One-time owner setup on Windows**

1. Install [Node.js LTS](https://nodejs.org/en/download) if you don't already have it.
2. Sign up for a free [Cloudflare account](https://dash.cloudflare.com/sign-up) if you don't already have one.
3. In GitHub, create a [fine-grained personal access token](https://github.com/settings/personal-access-tokens/new):
   - Repository owner: **Zephino**; access: **Only select repositories** -> **Mythriven**.
   - Repository permissions: **Contents -> Read and write** (for leaderboard storage) and **Issues -> Read and write** (for suggestions).
   - Don't turn on other repository permissions.
   - Copy the token privately; **never paste it into ChatGPT or commit it**.
4. Download or pull the latest Mythriven repository, then double-click
   **`leaderboard-api/Setup-Leaderboard.bat`**. Its setup window will install
   dependencies, sign in to Cloudflare, create the KV storage binding, securely
   store your token as a Cloudflare secret, and deploy the Worker.
5. The setup writes the public Worker address to **`scripts/net/online_config.gd`**.
   Commit and push that file to `main`, plus `leaderboard-api/wrangler.toml`
   if its KV binding was updated. The Worker address is public and safe to commit;
   **GITHUB_TOKEN is never stored in either file**.
6. Test **`https://YOUR-WORKER-NAME.YOUR-SUBDOMAIN.workers.dev/suggestions`**;
   you should receive `{"accepting":true}`. This confirms storage and token
   bindings exist, **not** that the token has the right permissions. To finish,
   open the deployed [game](https://zephino.github.io/Mythriven/), enter a
   short test suggestion, and check [GitHub Issues](https://github.com/Zephino/Mythriven/issues)
   for the new **[Player suggestion]** issue.
7. To receive email notifications, on GitHub choose **Watch -> All Activity**
   or **Custom -> Issues** for this repo, and make sure GitHub email
   notifications are enabled in your account settings.

**If the Worker is already set up for leaderboards:** create or update a
fine-grained token with **Issues: Read and write** permission too, then run
`npx wrangler secret put GITHUB_TOKEN` in `leaderboard-api/` and
`npx wrangler deploy`. You can reuse the existing KV binding and Worker URL.

**If GitHub Pages shows the README instead of the game:** use
[Repository Settings -> Pages](https://github.com/Zephino/Mythriven/settings/pages)
and set **Build and deployment -> Source = GitHub Actions**, then rerun the
[Web build](https://github.com/Zephino/Mythriven/actions/workflows/web.yml).
Otherwise the default Pages/Jekyll job can overwrite the Godot export.

**Automatic technical details:** The game attaches the version from
`project.godot`, whether the build is Web or native, the broad device type
(desktop/phone/tablet), OS category (e.g. Windows/Android/iOS), and browser
category for Web players. These are shown in the form before submission and
included in the resulting GitHub Issue to help reproduce problems. Detection
can be inaccurate (particularly on tablets or privacy-focused browsers).
**Full user-agent strings, device IDs, precise hardware model names, and IP
addresses are not copied into Issues.** A browser user-agent may be examined
locally only to categorize the browser and OS. The fields are client-reported
diagnostics and are not trusted for security decisions. Older game builds
without this metadata remain supported.

**Suggestion input security:** Suggestion submissions use Workers KV counters and
the GitHub Issues JSON API; there are **no SQL queries or SQL database** in
this feature, so SQL injection is not an applicable attack path today. The
Worker validates an explicit category allowlist, title/description lengths,
request byte limits, and the spam honeypot *server-side* regardless of any
client-side form controls. It normalizes/removes nonprinting control and
bidirectional-spoofing characters, collapses title newlines, and escapes user
text for GitHub Markdown so issue bodies cannot impersonate headings or
inject HTML formatting. Quotes, semicolons and SQL-looking phrases are kept
as ordinary text, not treated as executable commands. If future development
adds any SQL database, use **parameterized queries/prepared statements**
for every user-controlled value; escaping/keyword filtering is not a substitute.

**Practical limits:** Each address can submit up to three suggestions per UTC
day; there's also a site-wide daily cap of 40. These KV-based counters are
best-effort, not a substitute for CAPTCHA or stronger bot protection if the
game attracts abuse. The service sends no player identity or device identifier
to GitHub; the suggestion text, category, and the coarse environment details
shown in the form appear in a **public** Issue.
The Worker uses a per-day hash of the connecting IP for its temporary limits.
Do not put private information in suggestions.
