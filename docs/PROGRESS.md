# Mythriven — Progress Log

Cursor adds an entry after every task. Newest at the top.

**Current phase:** Phase 2 — Player movement (Phase 1 built but not yet tested; owner approved starting Phase 2 on 2026-10-28)
**Last reviewed with Claude:** (not yet)

---

<!-- Entry format:
## YYYY-MM-DD — Phase N — short title
- What changed:
- Files touched:
- Unfinished / next:
-->

## 2026-10-28 — Phase 2 — Work moved onto main (v00.01.03)
- What changed: at the owner's instruction, Phases 1–2 (versions 00.01.00–00.01.03) were pushed straight to `main` with no pull request. Recorded in `docs/DECISIONS.md`. No game code changed.
- Files touched: `docs/DECISIONS.md`, `docs/PROGRESS.md`, `docs/AI_STATUS.md`, `VERSION`, `project.godot` (version only).
- Unfinished / next: owner to test Phases 1–2 at their PC (still not run in Godot).

## 2026-10-28 — Phase 2 — Owner decisions recorded (v00.01.02)
- What changed: marked three Phase 2 decisions in `docs/DECISIONS.md`. 8-direction snapping is approved by the owner. The placeholder size/speed/zoom and the joystick placement are approved with the choice delegated to Claude. No game code changed.
- Files touched: `docs/DECISIONS.md`, `docs/PROGRESS.md`, `VERSION`, `project.godot` (version only).
- Unfinished / next: owner to test Phases 1–2 at their PC.

## 2026-10-28 — Phase 2 — Player movement (v00.01.01)
- Agent: Claude Code (cloud), developer mode. Started before Phase 1 was tested or reviewed, at the owner's request ("work on the next step, I'll test manually later").
- What changed: `GameAuthority` autoload holding the list of players (`spawn_player`, `remove_player`, `local_player`); placeholder square player with a facing dot; 8-direction movement at full speed from WASD/arrows, gamepad stick/D-pad, or a floating touch joystick (left half of the screen, visible only while touched); facing = last movement direction; camera with frame-rate-independent smooth follow and slight look-ahead; dev-only reference grid so movement is visible before the map exists; debug menu now shows player count/position/facing/speed, a grid toggle, and "Move player back to start". The Phase 1 translation test label moved from the screen centre to the bottom centre so it doesn't cover the player.
- Files touched: `scripts/core/game_authority.gd` (new), `scripts/player/player.gd` (new), `scripts/player/player_input.gd` (new), `scripts/ui/virtual_joystick.gd` (new), `scripts/world/game_camera.gd` (new), `scripts/world/debug_grid.gd` (new), `scripts/core/main.gd`, `scripts/core/debug_menu.gd`, `data/config.json` (`player`, `camera`, `joystick`, `debug.grid_*`), `data/schemas.json`, `localization/text.csv`, `tests/test_player_movement.gd` (new), `project.godot` (GameAuthority autoload, version), `VERSION`, docs.
- Unfinished / next: not run in Godot (none available in the cloud session). Owner to test Phases 1 and 2 together (see `docs/AI_STATUS.md`). Phase 2 report waits for those tests. Phase 3 (endless map) should wait for owner go-ahead.

## 2026-10-28 — Phase 1 — Project setup (v00.01.00)
- Agent: Claude Code (cloud), developer mode.
- What changed: created the Godot 4.7 project (`project.godot`, GL Compatibility renderer, landscape on phones, nearest-neighbor filtering); the folder structure from GAME_DESIGN.md plus `localization/` and `tests/`; Input Map actions (`move_up`, `move_down`, `move_left`, `move_right`, `summon_1`, `summon_2`, `resonance`, `aim`, `level_badge`, `pause`, plus `debug_menu` on F1) with keyboard, mouse, and gamepad bindings; JSON loader that checks every file against `data/schemas.json` and names the file and field in each error; starter `data/config.json` with every tuning value in the design so far; release content gate (refuses entries without `care_tier: "A"` and `lore_verified: true` in release builds, warns in dev builds); translation table `localization/text.csv` with all text through `tr()` and a pseudo-localization toggle; seeded RNG helper (`RunRng`) with separate world/spawns/loot generators; debug menu (F1 / three-finger tap) with FPS, version, and test buttons; empty main scene with a translation test label and the version in the corner; GUT 9.7.1 test add-on and automated tests; `VERSION` file.
- Files touched: `project.godot`, `VERSION`, `.gitignore`, `.gutconfig.json`, `CREDITS.md`, `START_HERE.md`, `addons/gut/` (third-party, unchanged), `data/config.json`, `data/schemas.json`, `localization/text.csv`, `scenes/main.tscn`, `scripts/core/` (`main.gd`, `data_loader.gd`, `json_validator.gd`, `content_gate.gd`, `run_rng.gd`, `localization.gd`, `debug_menu.gd`), `tests/` (4 test scripts + `fixtures/`), empty folders with `.gitkeep`, `docs/DECISIONS.md`, `docs/AI_STATUS.md`.
- Unfinished / next: Godot isn't installed where this was written, so the project has **not been opened or run yet**. Scripts passed only an offline syntax check. The owner needs to open the project, run the GUT tests, and work through the Phase 1 "Done when" list (see `docs/AI_STATUS.md`). Fix anything that fails, then write `docs/reports/PHASE_01_REPORT.md`. The mythology database files still need to be copied into `reference/`.
