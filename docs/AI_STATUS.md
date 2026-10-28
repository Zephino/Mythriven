# AI Development Handoff

Last updated: 2026-10-28
Agent: Claude Code (cloud), developer mode
Branch: `ccr-f867c6c5-ejkt2t` (based on `main` at `27bcc72`), to be merged into `main` once the owner confirms how
Task: Phase 1 — Project setup
Version: 00.01.00
Status: Built, but **not yet run in Godot**. Waiting for the owner to test.
Last verified commit: run `git rev-parse HEAD` before resuming.

## Completed
- Every Phase 1 "Build" item from `docs/BUILD_PLAN.md` is written; `docs/PROGRESS.md` lists them.
- GUT 9.7.1 added (owner approved), recorded in `CREDITS.md`.
- Decisions the design didn't cover are logged in `docs/DECISIONS.md`.

## Tests
- Godot is not installed in the cloud container and its download site is blocked, so **nothing has been run in Godot**. Don't claim any Done-when item is passed yet.
- Done: every `.gd` file passes an offline GDScript syntax check (gdtoolkit `gdparse` 4.5), and every JSON file parses.
- Automated tests written (run them in the editor's GUT tab): `tests/test_json_validator.gd`, `tests/test_content_gate.gd`, `tests/test_run_rng.gd`, `tests/test_data_files.gd`.

## How to test Phase 1 (owner, in Godot 4.7.2)
1. **Opens with zero errors or warnings:** import the project (see `START_HERE.md`), press F5, check the **Output** panel at the bottom: it should be empty of red/yellow lines.
2. **Debug menu with FPS:** with the game running, press **F1**. A panel shows the version (`Version 00.01.00`) and `FPS: …`. Arrow keys / D-pad move between buttons; F1 or **Close** hides it. (Mobile: tap with three fingers.)
3. **Broken JSON names the file and field:** in the debug menu click **Check test data files**. It lists `broken_example.json: field 'speed' should be number, but it is string` and `broken_example.json: missing required field 'limits.max_count'`. To try it yourself, open `tests/fixtures/example.json`, change `"speed": 1.5` to `"speed": "fast"`, save, and click the button again. Undo afterwards. (You can also break a key in `data/config.json`, for example rename `"enemy_cap"`, and restart: a red message appears on screen and in Output.)
4. **Translation label and pseudo-localization:** the middle of the screen says "Translation test: this text comes from the translation table." In the debug menu turn on **Pseudo-localization**: the text becomes longer, accented, and wrapped in [brackets]. Turn it off to go back.
5. **Tier B refused in release:** in the debug menu turn on **Pretend this is a release build**, then click **Run content gate test**. It shows `1 loaded, 2 refused`: `test_tier_b` and `test_tier_a_unverified` are refused. With the switch off it shows `3 loaded, 0 refused, 2 warnings`.
6. **Same seed, same sequence:** click **Show seeded RNG sequences** several times, and restart the game and click again. The numbers for world, spawns, and loot are identical every time.
7. **Automated tests:** GUT tab → **Run All**; all should be green.

If anything fails, copy the red text from the Output panel into a new message.

## Things most likely to need a fix on first open (couldn't be checked without Godot)
- Pseudo-localization relies on `TranslationServer.pseudolocalization_enabled` and `reload_pseudolocalization()`; if the label doesn't change, this is where to look.
- Hand-written `project.godot` input bindings: check **Project → Project Settings → Input Map** shows all 11 actions with their keys and buttons.
- Godot will create `.uid` files and a `localization/text.csv.import` file on first open; commit them.

## Cursor-rule compliance (`.cursor/rules/`, all 9 read)
- `mythriven.mdc`: Phase 1 only; no names or lore invented (test fixtures use neutral ids like `test_tier_b`); all text through `tr()`; tuning numbers in `data/config.json`; static typing; every script under 300 lines; `reference/` not loaded.
- `think-before-acting.mdc`: plan, assumptions, and confidence stated to the owner before changes; open questions asked.
- `dependencies.mdc`: GUT approved by owner, exact version pinned, license checked (MIT, fonts OFL), recorded in `CREDITS.md`, setup in `START_HERE.md`. **Exception:** "Run the project and confirm zero new errors" could not be done (no Godot here).
- `documentation.mdc`: `START_HERE.md`, `CREDITS.md`, JSON `_doc` notes, PROGRESS and DECISIONS updated; `GAME_DESIGN.md` not edited.
- `testing.mdc`: GUT tests in `res://tests/` for JSON validation, content gate, seeded RNG. **Exception:** tests not yet run, so no phase report written.
- `version.mdc`: version `00.01.00` in `VERSION` and `project.godot`, shown in the debug menu and in the main scene's corner (no title screen yet), and in PROGRESS.
- `git-workflow.mdc`: commit message `v00.01.00 Phase 1: …`; no secrets; no history rewriting; no tags created.
- `accessibility-for-interfaces.mdc` (debug menu): keyboard/gamepad focus order with wrap-around, first button focused on open, 72 px touch targets, mobile safe-area offset, text through `tr()` in growing containers.
- `bug-investigation.mdc`: no bugs fixed in this task.

## Blockers
- Owner asked to "use the main branch". `AGENTS.md` says never commit directly to `main`. Work is pushed to the session branch until the owner says whether to push straight to `main` or merge through a pull request.
- The GitHub connection failed to start in this cloud session, so Claude can't open a pull request from here until it's fixed.

## Next action
- Owner: run the 7 checks above and report results.
- Agent: fix anything that fails, then write `docs/reports/PHASE_01_REPORT.md` and stop for review.
