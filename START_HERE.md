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
