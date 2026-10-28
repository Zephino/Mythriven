# Mythriven — Start Here

This folder holds the game, the design, and the build docs. Cursor builds the game; Claude checks Cursor's work against the design so the game stays the way it was planned.

## What's in this folder

| File | What it's for | Who edits it |
| --- | --- | --- |
| `GAME_DESIGN.md` | The full game design: the source of truth | Only you, using a fresh export from Claude |
| `.cursor/rules/mythriven.mdc` | Rules Cursor follows automatically in every chat | You (via Claude) |
| `docs/BUILD_PLAN.md` | Phase-by-phase checklist with "Done when" tests | You (via Claude) |
| `docs/CURSOR_PROMPTS.md` | Prompts to copy into Cursor | You |
| `docs/PROGRESS.md` | Log of every task Cursor finishes | Cursor |
| `docs/DECISIONS.md` | Decisions Cursor had to make that the design didn't cover | Cursor writes, you approve |
| `docs/reports/` | One report per finished phase | Cursor |
| `reference/` | Your mythology database (design notes only) | You |
| `VERSION` | The build version (XX.XX.XX), also shown in the game's corner and debug menu | The coding agent, once per change request |
| `CREDITS.md` | Every add-on, font, and asset from outside the project, with its license | The coding agent |

## Setting up the game project (first time)

1. Install **Godot 4.7.2** (standard version, not .NET) from https://godotengine.org/download.
2. Open Godot. In the Project Manager, click **Import**, browse to this folder, select `project.godot`, then click **Import** (or **Open**).
3. Wait for the first import to finish. Godot creates a hidden `.godot/` folder and some `.uid` files; the `.uid` files should be committed, `.godot/` is ignored by Git.
4. Press **F5** (or the ▶ button at the top right) to run the game.
5. The test add-on **GUT** is already included in `addons/gut/` and switched on. To check it: **Project → Project Settings → Plugins** tab; "Gut" should show **Enabled**.

## Play in your browser

Every push to `main` builds the game for the web and publishes it at:

**https://zephino.github.io/Mythriven/**

It works on PC and phone browsers. It's a test build, so **F1** (or a three-finger tap) opens the debug menu. Click or tap the game once if the controls don't respond. The build takes a few minutes after each push. Progress is shown in the repo's **Actions** tab under "Web build".

One-time setup: on GitHub open the repo → **Settings** → **Pages** (left side) → under **Build and deployment**, set **Source** to **GitHub Actions**. Then on the **Actions** tab, open **Web build** → **Run workflow**.

## Running the automated tests

- **In the editor:** click the **GUT** tab at the bottom of the editor, then **Run All**. Every test should show green.
- **From a terminal** (optional): `godot --headless -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json`

The tests live in `tests/`. The mythology database files belong in `reference/` (see `reference/README.md`); the game never loads them.

## The loop for every phase

1. **Start:** open a new Cursor chat and paste the "Start a phase" prompt from `docs/CURSOR_PROMPTS.md`.
2. **Build and test:** Cursor works through the phase. Test each thing it builds the way it tells you to.
3. **Report:** when the phase is done, Cursor writes `docs/reports/PHASE_XX_REPORT.md` and stops.
4. **Review with Claude:** in your Claude chat, upload (or paste) the report, `docs/PROGRESS.md`, and `docs/DECISIONS.md`. Optionally upload the scripts Cursor changed, or a short screen recording of the game. Claude checks them against the design and replies with:
   - **Approved**, or
   - a **Fix list** to paste into Cursor (use the "Apply Claude's review" prompt), and
   - any decisions that need your yes/no.
5. **Update the design if needed:** if you approve a change, Claude updates the design doc. Download the new `GAME_DESIGN.md` and replace the old one in this folder.
6. **Next phase:** only after the review passes.

## Tips

- One phase at a time. If Cursor starts building something from a later phase, stop it and paste the "Check that Cursor is on track" prompt.
- If Cursor seems confused, start a new chat with the "Continue a phase" prompt. Long chats drift.
- Commit your work with Git (or copy the folder) after each approved phase, so you can always go back.
- Keep this Claude conversation (or the design doc) as the place where design decisions are made.
