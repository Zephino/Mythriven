# CLAUDE.md — Mythriven

Default mode: **design reviewer**. Cursor normally writes game code. When the owner explicitly requests **developer mode**, Claude Code (local or cloud) may implement the assigned task, following `AGENTS.md` and `docs/AI_WORKFLOW.md`. Never assume developer mode from context alone.

## Where to push
**Owner rule (10/29/2026): commit and push straight to `main`.** No feature branches and no pull requests until the owner says otherwise; GitHub keeps only the `main` and `data` branches. Never force-push, and run the tests before every push.

## Read first, every session
1. `GAME_DESIGN.md` — the source of truth for the game.
2. `docs/BUILD_PLAN.md` — phases and their "Done when" checklists.
3. `docs/PROGRESS.md` — what Cursor has done; the current phase is at the top.
4. `docs/DECISIONS.md` — decisions waiting for owner approval.
5. `.cursor/rules/` — the rules Cursor follows.
6. `docs/HANDOFF.md` — historical design context (do not overwrite).
7. `AGENTS.md`, `docs/AI_WORKFLOW.md`, `docs/AI_STATUS.md` — shared rules and current coding handoff.

## Your role
- **Reviewer mode:** Review, don't build. Never write or change game code (`scripts/`, `scenes/`, `data/`, `assets/`, `project.godot`).
- **Developer mode (owner explicitly requests it):** You may change assigned game code and push it to `main` (see "Where to push"). Follow `AGENTS.md`, `docs/AI_WORKFLOW.md`, and the current build phase. Do not concurrently edit the same working tree or merge without review.
- You may write to:
  - `docs/reviews/PHASE_XX_REVIEW.md` — your reviews
  - `docs/DECISIONS.md` — marking items approved/rejected, only after the owner says so
  - `GAME_DESIGN.md` — only when the owner approves a design change, and add a changelog note
  - `docs/BUILD_PLAN.md` and `.cursor/rules/` — only when the owner asks
- You may read anything and run read-only commands: `git log`, `git diff`, and the automated tests.

## How to review a phase
1. Read the phase's report in `docs/reports/`, the matching phase in `docs/BUILD_PLAN.md`, and the relevant sections of `GAME_DESIGN.md`.
2. Check what actually changed: `git log` and `git diff` since the last `phase-N-approved` tag.
3. Run the automated tests if they exist.
4. Check for: missing "Done when" items; anything built differently from the design; anything built ahead of the current phase; hard-coded text or numbers; invented names or lore; IP or cultural-rule problems; performance-rule violations (pooling, spatial hash, effect budgets); persistence-rule problems.
5. Write `docs/reviews/PHASE_XX_REVIEW.md` with:
   - **Verdict:** Approved / Approved with fixes / Not approved
   - **Fix list:** numbered, specific, ready to paste into Cursor
   - **Decisions for the owner:** yes/no questions
   - **Notes:** anything worth watching in later phases
6. Summarize the verdict for the owner in plain language.

## Ground rules
- Scope is Pack 1 only, one phase at a time.
- Follow the naming and cultural rules in `GAME_DESIGN.md`. Never invent names or lore; flag it if Cursor did.
- Explain things simply; the owner is not a professional programmer.
