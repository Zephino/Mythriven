# Mythriven — Progress Log

Cursor adds an entry after every task. Newest at the top.

**Current phase:** Phase 7 — Fun checkpoint, next (Phases 1–6 built but not yet tested in Godot; the owner asked for Phases 3–6 to be built before testing, 2026-10-28)
**Last reviewed with Claude:** (not yet)

---

<!-- Entry format:
## YYYY-MM-DD — Phase N — short title
- What changed:
- Files touched:
- Unfinished / next:
-->

## 2026-10-28 — Fix — Windows too small on phones (v00.01.08)
- Cause: no screen scaling was set, so on high-resolution phone screens every menu, button, and label was drawn at its size in real pixels and looked tiny.
- Fix: `project.godot` display settings now use a 1152×648 design size with `canvas_items` stretch and `expand` aspect, so UI and world scale with the screen; new `scripts/ui/safe_area.gd` converts the phone's safe area into game coordinates for the touch joystick and the debug menu.
- Files touched: `project.godot`, `scripts/ui/safe_area.gd` (new), `scripts/ui/touch_joystick.gd`, `scripts/core/debug_menu.gd`, `CHANGELOG.md`, `docs/DECISIONS.md`, `docs/AI_STATUS.md`, `VERSION`.

## 2026-10-28 — Tools — License (v00.01.07)
- What changed: added `LICENSE` with the same proprietary All Rights Reserved copyright as WaveDefence (third-party add-ons keep their own licenses); the owner made the repo public for the GitHub Pages game link.
- Files touched: `LICENSE` (new), `START_HERE.md`, `CHANGELOG.md`, `docs/AI_STATUS.md`, `VERSION`, `project.godot` (version only).
- Unfinished / next: GitHub Pages must have **Source: GitHub Actions** switched on in the repo settings for the link to work.

## 2026-10-28 — Fix — Game didn't compile in real Godot (v00.01.06)
- Cause (from the first GitHub Actions run with real Godot 4.7.2): (1) `class_name VirtualJoystick` clashes with a new built-in Godot 4.7 class; (2) `RunState` declared `level` twice (the level's data and the XP level number), which stopped `RunState` and everything using it (GameAuthority, main scene, several tests) from compiling. The tests that didn't depend on those (validator, content gate, data files, damage formula, RNG, movement) all passed.
- Fix: renamed the class to `TouchJoystick` (`scripts/ui/touch_joystick.gd`); renamed the level data to `RunState.level_data`.
- Files touched: `scripts/ui/touch_joystick.gd` (renamed), `scripts/player/player_input.gd`, `scripts/core/main.gd`, `scripts/core/run_state.gd`, `scripts/meta/run_log.gd`, `CHANGELOG.md`.

## 2026-10-28 — Tools — Changelog rule (v00.01.06)
- What changed: added the owner's changelog rule (`.cursor/rules/changelog.mdc`) and `CHANGELOG.md`, plus a test that the newest changelog entry matches `VERSION`. No game code changed.
- Files touched: `.cursor/rules/changelog.mdc`, `CHANGELOG.md` (new), `tests/test_data_files.gd`, `docs/AI_STATUS.md`, `VERSION`, `project.godot` (version only).
- Unfinished / next: none.

## 2026-10-28 — Tools — Playable web link (v00.01.05)
- What changed: added a Web export preset and a GitHub Actions workflow (`.github/workflows/web.yml`). On every push to `main` it installs Godot 4.7.2, runs the automated tests, exports a debug web build, and publishes it to GitHub Pages at https://zephino.github.io/Mythriven/ (same idea as WaveDefence, but built automatically). No game code changed.
- Files touched: `export_presets.cfg`, `.github/workflows/web.yml` (new), `START_HERE.md`, `docs/DECISIONS.md`, `docs/AI_STATUS.md`, `VERSION`, `project.godot` (version only).
- Unfinished / next: GitHub Pages must be switched on once in the repo settings. The repo is private, so Pages needs a paid GitHub plan or a public repo (owner to decide).

## 2026-10-28 — Phase 6 — XP, level-ups, and the run log (v00.01.04)
- What changed: XP orbs worth 1 / 5 / 25 (pooled, one MultiMesh) dropped on every kill; orbs inside the Pickup Radius fly to the player; above 300 orbs, distant ones merge (no XP lost); shared XP bar with the design's curve (5 XP for level 2, ~10% more per level); rising-pitch pickup sound (generated placeholder blip, pentatonic scale, 12-step cap, 0.4 s chain window, 0.6 s reset, 20 sounds/s limit, 8-player pool); level-up screen that pauses the game and the run timer, with 3 cards (4 with high Luck) mixing new weapons, weapon levels, the 9 passives and their levels, and stat cards; owned items slightly favoured, maxed items never offered, no hard caps (soft curves); Gold and Heal cards once every weapon and passive slot is full and maxed; Auto-collect (Off / Gold / Heal / Smart) resolves maxed level-ups instantly without pausing; banked level-ups ("Save for later", reopen with Tab, Y/Triangle, or the level badge); weapon levels 1–8; two general weapons, Throwing Axe (lobbed, piercing) and Bladed Discus (boomerang), with a pooled projectile system; HUD with XP bar, level badge, timer, and kills; a basic run log (time, cause of death, build, seed, version) written to `user://run_logs/` at the end of every run. Debug menu: level/XP/orb line, gain a level, drop a pile of orbs, pull every orb (magnet), max out the build, end the run now.
- Files touched: `scripts/world/xp_orbs.gd`, `scripts/core/pickup_chain.gd`, `scripts/core/pickup_audio.gd`, `scripts/combat/projectiles.gd`, `scripts/combat/fire_patterns/projectile_pattern.gd`, `scripts/meta/level_up_rules.gd`, `scripts/meta/run_log.gd`, `scripts/ui/level_up_screen.gd`, `scripts/ui/card_text.gd`, `scripts/ui/hud.gd`, `scripts/core/debug_actions_progress.gd` (all new); `scripts/core/game_authority.gd`, `scripts/core/main.gd`, `scripts/core/run_state.gd`, `scripts/combat/combat_system.gd`, `scripts/player/player.gd`, `scripts/player/player_stats.gd`; `data/passives.json` (new), `data/weapons.json` (8 levels each, 2 new weapons), `data/config.json` (`xp.*`, `level_up.*`, `pickups.sound_*`, `projectiles`, `run_log`, `ui.xp_bar_height_px`, `debug.test_orb_count`), `data/schemas.json`, `localization/text.csv`, `tests/test_progression.gd` (new).
- Unfinished / next: Hero Legend Trait "skill" cards come with Heroes (Phase 9); evolution-recipe card help with evolutions (Phase 10); gold pickups and banking with Phase 15. Phase 7 (fun checkpoint) is next, and it needs the owner playing on a PC.

## 2026-10-28 — Phase 5 — Weapons and smart targeting (v00.01.04)
- What changed: Heracles' Great Club (`weapons.json`) as the starting weapon, built from a reusable fire-pattern script (`ArcPattern`: a melee slam arc toward the target, and a small quake ring on every 4th slam); smart targeting for all six types (`targeted`, `melee`, `orbit`/`aura`, `random`, `directional`, `range_switch`), with targets picked again every 0.1 s and elites/bosses preferred within 1.5× the nearest distance once they exist; the damage formula in the design's exact order (`Damage.hit`); player stats with soft curves (`PlayerStats`: cooldown ÷ (1 + bonus), Move Speed past +100% and Area past +150% count half); knockback (reduced by each enemy's knockback resist); white hit flash; enemy death through `GameAuthority.kill_enemy` (frees the pooled slot, counts the kill); pooled damage numbers (bigger and orange on crits, can be switched off); pooled swing/quake effects with a budget (oldest reused). Each weapon level has its own attack interval and per-enemy hit interval in data. Debug menu: kill count, "Spawn one enemy behind you".
- Files touched: `scripts/combat/` (`combat_system.gd`, `damage.gd` (Phase 4), `effects.gd`, `fire_patterns/fire_pattern.gd`, `fire_patterns/arc_pattern.gd`, `weapons/weapon_instance.gd`), `scripts/player/` (`player_stats.gd`, `targeting.gd` new; `player.gd`), `scripts/ui/damage_numbers.gd`, `scripts/core/` (`game_authority.gd`, `main.gd`, `debug_actions_combat.gd`), `scripts/enemies/enemy_manager.gd`, `data/weapons.json` (new), `data/config.json` (`effects`, `ui.damage_number_*`, `combat.range_switch_tiles`, `combat.priority_target_range_mult`, `player.starting_weapon`, `player.placeholder_pickup_radius_px`, `debug.spawn_behind_px`), `data/schemas.json`, `localization/text.csv`, `tests/test_damage.gd`, `tests/test_weapons.gd`.
- Unfinished / next: Hero expertise bonuses come with Heroes (Phase 9); weakness/resistance with elements (Phase 8).

## 2026-10-28 — Phase 4 — Enemies core (v00.01.04)
- What changed: enemies are pooled data in arrays (`EnemyManager`, cap 500 from config) drawn with one MultiMesh, so no nodes are created or freed during play; spatial hash grid with 64 px cells (`SpatialHash`); chaser and swarm movement toward the nearest living player; ring spawning just outside the visible screen, as single enemies or packs (`EnemySpawner`, placeholder steady rate until the Phase 10 wave tables); enemies more than 2 screen-widths from every player are moved to the ring ahead, not deleted; no stacking (push-apart at 30 Hz, up to 8 neighbours, bigger enemies push smaller ones), and enemies can't enter the player, so crowds form a ring; contact damage once per 0.5 s per touching enemy on its own timer, with no invulnerability frames; player HP, an HP bar over the player, Armor, and death through `GameAuthority`; death screen with time survived, what felled you, and Retry. Two placeholder enemies in `enemies.json`. Debug menu: enemy count/HP/time line, spawn a ring of chasers, spawn a swarm pack, fill to the 500 cap (stress test), remove all, automatic spawning on/off, god mode, heal.
- Files touched: `scripts/enemies/enemy_manager.gd`, `scripts/enemies/spawner.gd`, `scripts/core/spatial_hash.gd`, `scripts/core/placeholder_art.gd`, `scripts/core/text_format.gd`, `scripts/combat/damage.gd`, `scripts/ui/death_screen.gd`, `scripts/core/debug_actions_combat.gd` (all new); `scripts/player/player.gd`, `scripts/core/game_authority.gd`, `scripts/core/main.gd`; `data/enemies.json` (new), `data/config.json` (`player.*` HP and bar, `enemies.*` spawning, `debug.spawn_count`), `data/schemas.json`, `localization/text.csv`, `tests/test_enemies.gd` (new).
- Unfinished / next: FPS with 500 enemies must be measured on the owner's PC ("Fill to the enemy cap").

## 2026-10-28 — Phase 3 — Endless map (v00.01.04)
- Agent: Claude Code (cloud), developer mode. The owner asked for Phases 3–6 in one go, before Phases 1–2 were tested.
- What changed: `levels.json` with The Aegean Shore (placeholder tileset colours, decorations, local gods and bosses from GAME_DESIGN.md); chunk manager keeping a 5×5 grid of 32×32-tile chunks (16 px tiles) around each player, with pooled chunks and ground painted a few rows per frame so walking doesn't stutter; ground from FastNoiseLite (stone, dirt, grass, flowers); decorations (olive trees, broken columns, marble ruins) placed by a generator seeded from the run seed and chunk position, no collision; world origin shift past 50,000 px (`WorldRoot`); `RunState` with the run seed (random each run unless `run.fixed_seed` is set); a fourth RNG stream, `combat`. The debug menu was reworked so each system adds its own options (`add_button` / `add_check` / `add_info`); the player options moved to `scripts/core/debug_actions.gd`, and a seed/chunk info line and a "Jump far east" button were added. The reference grid is now off by default, since the ground shows movement.
- Files touched: `data/levels.json` (new), `data/config.json` (`run`, `world.build_tiles_per_frame`, `debug.teleport_px`), `data/schemas.json`, `scripts/world/` (`world_root.gd`, `chunk_manager.gd`, `chunk.gd`, `level_art.gd` new; `debug_grid.gd`), `scripts/core/` (`run_state.gd`, `debug_actions.gd` new; `main.gd`, `debug_menu.gd`, `game_authority.gd`, `run_rng.gd`), `localization/text.csv`, `tests/test_world.gd` (new), `VERSION`, `project.godot`.
- Unfinished / next: not run in Godot. Memory/FPS checks need the owner's PC.

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
