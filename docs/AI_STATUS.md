# AI Development Handoff

Last updated: 2026-10-28
Agent: Claude Code (cloud), developer mode
Branch: `main` (owner asked for direct pushes to `main`; the session branch `ccr-f867c6c5-ejkt2t` holds the same commits)
Task: Phases 3–6 (endless map, enemies, weapons, XP and level-ups), built in one go at the owner's request
Version: 00.01.08
Status: Phases 1–6 built, **none run in Godot yet**. Owner will test at their PC. Phase 7 (fun checkpoint) is next and needs the owner playing.
Last verified commit: run `git rev-parse HEAD` before resuming.

## Completed
- Phase 1: project setup (see `docs/PROGRESS.md`). GUT 9.7.1 added (owner approved), recorded in `CREDITS.md`.
- Phase 2: players-as-list, 8-direction movement (keyboard, gamepad, touch joystick), facing, camera.
- Phase 3: endless pooled chunk map with noise ground and seeded decorations from `levels.json`, origin shift.
- Phase 4: pooled array enemies (cap 500, one MultiMesh), spatial hash, chasers and swarms, ring spawning and recycling, no stacking, contact damage without invulnerability, HP and death screen.
- Phase 5: Great Club, all six targeting types, damage formula in design order, knockback, pooled damage numbers.
- Phase 6: XP orbs with merging, capped rising-pitch pickup sound, level-up cards, 9 passives, weapon levels 1–8, Throwing Axe and Bladed Discus, Auto-collect, banked level-ups, HUD, run log.
- Decisions the design didn't cover are in `docs/DECISIONS.md` ("needs owner approval").

## Tests
- Godot is not installed in the cloud container and its download site is blocked, so **nothing has been run in Godot**. Don't claim any Done-when item is passed yet.
- Done offline: every `.gd` file passes a GDScript syntax check (gdtoolkit 4.5); every data file passes a Python copy of the game's JSON validator; every translation key used in code exists in `localization/text.csv`; every script is under 300 lines.
- Automated tests written (editor's GUT tab → Run All): `test_json_validator`, `test_content_gate`, `test_run_rng`, `test_data_files`, `test_player_movement`, `test_world`, `test_enemies`, `test_damage`, `test_weapons`, `test_progression`.

## How to test (owner, in Godot 4.7.2 or the web link)
Play at **https://zephino.github.io/Mythriven/** (once GitHub Pages is switched on; see `START_HERE.md`), or run the game in Godot with **F5**. **F1** opens the debug menu (three-finger tap on a phone); most checks use its buttons. If anything fails, copy the red text from the **Output** panel at the bottom into a new message.

**Phase 1 — Project setup**
1. **No errors:** after pressing F5, the Output panel has no red or yellow lines.
2. **Debug menu:** F1 shows `Version 00.01.08` and `FPS: …`. Arrow keys / D-pad move between buttons.
3. **Broken JSON:** **Check test data files** lists two errors for `broken_example.json`, naming `speed` and `limits.max_count`.
4. **Translation:** the bottom of the screen says "Translation test: …". **Pseudo-localization** makes it longer, accented, and in [brackets].
5. **Content gate:** turn on **Pretend this is a release build**, then **Run content gate test** shows `1 loaded, 2 refused`.
6. **Seeded RNG:** **Show seeded RNG sequences** gives the same numbers every time, even after restarting.

**Phase 2 — Player movement**
1. WASD / arrows / left stick / D-pad move the yellow square in 8 directions. The dark dot shows the last direction moved.
2. The debug info line shows `speed 100` both straight and diagonal.
3. Touch: **Project → Project Settings**, switch on **Advanced Settings**, **Input Devices → Pointing**, tick **Emulate Touch From Mouse**, run. Dragging on the left half shows a joystick only while held. Untick afterwards.
4. The camera follows smoothly, a little ahead of your movement, with no shaking.

**Phase 3 — Endless map**
1. The ground is stone, dirt, grass, and flowers with olive trees, columns, and ruins. Walk 5 minutes in one direction: no gaps, seams, or stutter.
2. Note a spot, walk far away, come back (or press **Move player back to start**): the same ground and decorations.
3. Memory stays flat: **Debugger** panel (bottom) → **Monitors** tab → tick **Memory → Static**; walk for a few minutes; it levels off instead of climbing. The debug line shows `25 chunks loaded`.
4. Press **Jump far east** 5–6 times: the "origin shift" numbers in the debug line change and nothing jumps or flickers.
5. FPS stays at 60 while walking.

**Phase 4 — Enemies core**
1. Grey circles (and occasional packs of small purple ones) spawn just off screen and walk toward you.
2. **Fill to the enemy cap** spawns up to 500. FPS should stay at 60 on PC; write down the FPS shown.
3. Turn on **God mode** and stand still: enemies form a ring around you and never overlap each other.
4. Turn God mode off and stand still in a crowd: your HP bar drops and you die. The death screen shows time survived and what felled you; **Retry** starts again.
5. Enemies you run far away from reappear ahead of you instead of vanishing.

**Phase 5 — Weapons and smart targeting**
1. The Great Club slams automatically toward the nearest enemy, even one behind you while you run away (try **Spawn one enemy behind you**). Every 4th slam makes a small ring.
2. Hit enemies flash white, get pushed back a little, and show damage numbers; crits are bigger and orange.
3. Enemies die when their HP runs out; the debug line counts kills.

**Phase 6 — XP, level-ups, and the run log**
1. Kills drop blue orbs; walking near pulls them in, and the XP bar at the top fills.
2. Collecting orbs quickly plays notes that climb a scale and then hold at the top note. **Drop a pile of XP orbs**, then **Pull every orb to you**: the sound runs up quickly and doesn't turn into a wall of noise.
3. A level-up pauses the game (the timer stops) and shows 3 cards. Pick one, or **Save for later**: the badge shows `Lv 3 (+1)`, and **Tab** (or tapping the badge) reopens it.
4. **Max out the build**, then **Gain a level**: the cards include Gold and Heal. Set **Auto-collect** to Smart or Gold, and the next level-ups resolve without pausing.
5. After you die (or **End the run now**), the death screen says "Run log saved." The file is in `%APPDATA%\Godot\app_userdata\Mythriven\run_logs` on Windows.
6. Automated tests: GUT tab → **Run All**; all green.

## Things most likely to need a fix on first open (couldn't be checked without Godot)
- Pseudo-localization (`TranslationServer.pseudolocalization_enabled`).
- Hand-written `project.godot` input bindings: **Project → Project Settings → Input Map** should list 11 actions.
- MultiMesh drawing of enemies, orbs, and projectiles (circles may be invisible, upside down, or the wrong size).
- Hand-written `.tscn`; Godot will add `.uid` / `.import` files on first open, which should be committed.

## Cursor-rule compliance (`.cursor/rules/`, all 10 read and rechecked)
- `mythriven.mdc`: built the listed phases only, in order (Phases 3–6 at once by owner request); no lore invented: enemies are marked placeholders, and every weapon, passive, and level name comes from GAME_DESIGN.md; text through `tr()`; tuning numbers, colours, and sizes in JSON; static typing; scripts under 300 lines; players are a list; game events go through `GameAuthority`; pooling and the spatial hash for enemies, projectiles, orbs, effects, and damage numbers; `reference/` not loaded. Run items are `persists: false`.
- `think-before-acting.mdc`: open design questions logged in `docs/DECISIONS.md` instead of guessed silently.
- `dependencies.mdc`: no new dependencies since GUT.
- `documentation.mdc`: PROGRESS, DECISIONS, JSON `_doc` notes, this file; `GAME_DESIGN.md` not edited.
- `testing.mdc`: GUT tests for the damage formula order, XP curve, level-up card rules, soft curves, seeded generation, JSON validation, content gate. **Exception:** tests not yet run, so no phase reports written; FPS not yet measured.
- `version.mdc`: 00.01.04 for Phases 3–6, 00.01.05 for the web link; in `VERSION`, `project.godot`, debug menu, main scene corner, and PROGRESS.
- `git-workflow.mdc`: one commit per phase with `v00.01.04 Phase N: …`; no secrets; no history rewriting; no tags. **Exception:** pushed straight to `main` by owner request.
- `accessibility-for-interfaces.mdc`: level-up screen, death screen, HUD badge, and debug menu are keyboard/gamepad/touch usable with focus order, first control focused, 72 px targets, text through `tr()` in wrapping containers. A Settings screen for accessibility options comes in Phase 19.
- `bug-investigation.mdc`: no bugs fixed in this task.
- `changelog.mdc` (added 00.01.06 by owner request): one `CHANGELOG.md` entry per change request, newest first, matching `VERSION`; checked by `tests/test_data_files.gd`.
- **Exception:** the review gates between phases in `mythriven.mdc` were skipped at the owner's explicit request.

## Blockers
- None for coding. Godot isn't available in the cloud session, so all testing waits for the owner's PC.

## Next action
- Owner: run the checks above and report anything that fails.
- Agent: fix failures, then write `docs/reports/PHASE_01_REPORT.md` … `PHASE_06_REPORT.md`. Phase 7 is the owner's fun checkpoint (play and tune `config.json`); don't start Phase 8 until the owner says the core is fun.
