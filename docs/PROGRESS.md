# Mythriven — Progress Log

Cursor adds an entry after every task. Newest at the top.

**Current phase:** Phase 1 — Project setup
**Last reviewed with Claude:** (not yet)

---

<!-- Entry format:
## YYYY-MM-DD — Phase N — short title
- What changed:
- Files touched:
- Unfinished / next:
-->

## 2026-10-28 — Phase 1 — Project setup (v00.01.00)
- Agent: Claude Code (cloud), developer mode.
- What changed: created the Godot 4.7 project (`project.godot`, GL Compatibility renderer, landscape on phones, nearest-neighbor filtering); the folder structure from GAME_DESIGN.md plus `localization/` and `tests/`; Input Map actions (`move_up`, `move_down`, `move_left`, `move_right`, `summon_1`, `summon_2`, `resonance`, `aim`, `level_badge`, `pause`, plus `debug_menu` on F1) with keyboard, mouse, and gamepad bindings; JSON loader that checks every file against `data/schemas.json` and names the file and field in each error; starter `data/config.json` with every tuning value in the design so far; release content gate (refuses entries without `care_tier: "A"` and `lore_verified: true` in release builds, warns in dev builds); translation table `localization/text.csv` with all text through `tr()` and a pseudo-localization toggle; seeded RNG helper (`RunRng`) with separate world/spawns/loot generators; debug menu (F1 / three-finger tap) with FPS, version, and test buttons; empty main scene with a translation test label and the version in the corner; GUT 9.7.1 test add-on and automated tests; `VERSION` file.
- Files touched: `project.godot`, `VERSION`, `.gitignore`, `.gutconfig.json`, `CREDITS.md`, `START_HERE.md`, `addons/gut/` (third-party, unchanged), `data/config.json`, `data/schemas.json`, `localization/text.csv`, `scenes/main.tscn`, `scripts/core/` (`main.gd`, `data_loader.gd`, `json_validator.gd`, `content_gate.gd`, `run_rng.gd`, `localization.gd`, `debug_menu.gd`), `tests/` (4 test scripts + `fixtures/`), empty folders with `.gitkeep`, `docs/DECISIONS.md`, `docs/AI_STATUS.md`.
- Unfinished / next: Godot isn't installed where this was written, so the project has **not been opened or run yet**. Scripts passed only an offline syntax check. The owner needs to open the project, run the GUT tests, and work through the Phase 1 "Done when" list (see `docs/AI_STATUS.md`). Fix anything that fails, then write `docs/reports/PHASE_01_REPORT.md`. The mythology database files still need to be copied into `reference/`.
