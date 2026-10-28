# Mythriven — Decisions Log

Any decision not already covered by GAME_DESIGN.md goes here. Cursor marks new entries **needs owner approval**. The owner reviews them with Claude; approved decisions are added to GAME_DESIGN.md by Claude, and a fresh GAME_DESIGN.md is downloaded into the project.

| Date | Phase | Decision | Why | Status |
| --- | --- | --- | --- | --- |
| | | | | needs owner approval / approved / rejected |
| 2026-10-28 | 1 | Engine pinned to **Godot 4.7.2** (latest stable); GUT 9.7.1 for tests. | Owner asked for latest stable; GUT 9.7.x is the release made for Godot 4.7. | approved (owner, 2026-10-28) |
| 2026-10-28 | 1 | Renderer: **GL Compatibility** on PC and mobile. | Runs on the widest range of phones and is fast for 2D; can switch to "Mobile" later if needed. | needs owner approval |
| 2026-10-28 | 1 | Release content gate is tested with a debug-menu switch, "Pretend this is a release build", instead of a real export. Fixture entries live in `tests/fixtures/gate_entries.json`. | Owner left the choice to Claude; a real export needs export templates. A real release export can still be checked later. | approved (owner delegated, 2026-10-28) |
| 2026-10-28 | 1 | Gated data files are marked `"gated": true` in `data/schemas.json`. heroes.json, gods.json, and levels.json will be gated when they are added (Phases 3/9/11). | The design requires the gate for Hero and god entries; levels also carry `care_tier`. | needs owner approval |
| 2026-10-28 | 1 | Required fields and types for every data file are listed in `data/schemas.json`. Keys starting with `_` are notes. Unknown keys load with a warning; missing or wrongly typed keys stop the file loading. | The design says "validated at startup" but gives no format for the rules. | needs owner approval |
| 2026-10-28 | 1 | Extra Input Map action `debug_menu` (F1). `resonance` is bound to R only for now; Q+E and LB+RB "together" combos are handled in code in Phase 12. `aim` = hold left mouse button, or move the right stick. | The design lists F1 and the combos but they aren't single Input Map bindings. | needs owner approval |
| 2026-10-28 | 1 | Pseudo-localization uses Godot's built-in pseudo-localization (accents, brackets, +40% length), with settings in `config.json` → `localization`. | Matches the design's example "[Ŀéṽéŀ Ûƥ!!!]" without new code. | needs owner approval |
| 2026-10-28 | 1 | Until a title screen exists (Phase 15), the version is shown in the bottom-right corner of the main scene. | The version rule asks for the title screen, which doesn't exist yet. | needs owner approval |
| 2026-10-28 | 1 | The `tests/` folder (with fixtures) will be excluded from release exports when export presets are made (Phase 19). | Test fixtures aren't game content. | needs owner approval |
| 2026-10-28 | 1 | Work goes to `main` through a pull request rather than direct commits (pending owner confirmation). | Owner asked to "use main"; AGENTS.md forbids committing directly to main. | needs owner approval |
| 2026-10-28 | 2 | Stick and joystick movement is snapped to the nearest of 8 directions at full speed (no slow walking from a half-tilted stick). Switch: `player.snap_to_8_directions` in config.json. | The design says "8 directions"; this is the literal reading and keeps diagonals the same speed. | approved (owner, 2026-10-28) |
| 2026-10-28 | 2 | Placeholder player speed 100 px/s, size 16 px, and camera zoom 2× in config.json until Heroes (Phase 9) and the screen resolution are decided. | The design gives Hero speeds (90–125) but not their units or the base screen size. | approved (owner delegated to Claude, 2026-10-28) |
| 2026-10-28 | 2 | The player list and player spawning live in the `GameAuthority` autoload. | The design says players are a list and spawns go through GameAuthority. | needs owner approval |
| 2026-10-28 | 2 | A faint reference grid (dev builds only, toggle in debug menu) shows movement until the map exists. Not part of the game. | Without a map the camera-follow can't be seen. | needs owner approval |
| 2026-10-28 | 2 | Touch joystick area is the left 50% of the screen (`joystick.screen_fraction`), inside the safe area on phones; sizes 80 px / 32 px knob until the Phase 19 settings. | Design says "left half"; sizes not specified. | approved (owner delegated to Claude, 2026-10-28) |
| 2026-10-28 | 2 | Phase 2 was started before Phase 1 was tested or reviewed. | Owner asked to keep going and test both later. | approved (owner, 2026-10-28) |
