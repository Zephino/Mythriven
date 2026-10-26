# Mythriven — Build Plan

This is the working checklist Cursor builds from. `GAME_DESIGN.md` is the source of truth for *what* the game is; this file says *what to build in each phase and how we know it's done*.

**Rules for using this file**

- Work on **one phase at a time**, in order. Never start a phase until the previous one is marked done in `docs/PROGRESS.md`.
- Each phase lists **Build**, **Done when** (every box must be checked), and **Not yet** (things that belong to later phases — don't build them early).
- When a phase is finished, Cursor writes a report using `docs/reports/PHASE_REPORT_TEMPLATE.md`. The owner reviews it with Claude before the next phase starts.
- If anything here seems to conflict with `GAME_DESIGN.md`, stop and ask. Don't guess.
- Scope: **Pack 1 only** (Aegean Shore, Midgard's Edge, The Two Lands, The Misty Isles).

Section names in brackets, like [Core mechanics], refer to sections of `GAME_DESIGN.md`.

---

## Phase 1 — Project setup

**Build**
- Godot 4 project named **Mythriven** in the project root, using GDScript with static typing.
- Folder structure from [Tech stack and performance rules], plus `localization/`.
- Input Map actions: `move_up`, `move_down`, `move_left`, `move_right`, `summon_1`, `summon_2`, `resonance`, `aim`, `level_badge`, `pause`, with keyboard and gamepad bindings from [Controls and smart targeting].
- JSON loader for `res://data/` that validates required fields and reports a clear error naming the file and field.
- Starter `config.json` with every tuning value mentioned so far (can be placeholders).
- Release content gate: entries without `care_tier: "A"` and `lore_verified: true` are refused in release builds, loaded with a warning in dev builds.
- Translation system: `localization/` table, all text through `tr()`, a pseudo-localization toggle [Translation-ready text].
- Seeded RNG helpers: separate generators for world, spawns, and loot.
- Debug menu shell (F1 on PC, three-finger tap on mobile) showing FPS.
- Empty main scene that runs.

**Done when**
- [ ] Project opens in Godot with zero errors or warnings.
- [ ] Pressing F1 shows the debug menu with an FPS counter.
- [ ] Breaking a field in a test JSON file shows an error that names the file and field.
- [ ] A test label shows text from the translation table; the pseudo-localization toggle changes it.
- [ ] A test entry with `care_tier: "B"` is refused when running as a release build.
- [ ] The same seed always produces the same sequence from each RNG.

**Not yet:** player, map, enemies, art.

---

## Phase 2 — Player movement

**Build**
- Player stored in a list of players (never a single global player).
- 8-direction movement: WASD/arrows, gamepad stick and D-pad, floating virtual joystick on the left half of a touch screen.
- Facing direction = last movement direction.
- Placeholder square sprite; camera follows smoothly with slight look-ahead.

**Done when**
- [ ] Movement works with keyboard, gamepad, and touch (test touch with Godot's "Emulate Touch From Mouse").
- [ ] The joystick only appears while touched.
- [ ] Diagonal movement isn't faster than straight movement.
- [ ] The camera never jitters.

**Not yet:** map, enemies, weapons.

---

## Phase 3 — Endless map

**Build**
- Chunk manager: 32×32 tiles of 16 px, 5×5 chunks loaded around each player [Endless world and discoveries].
- Ground painted with `FastNoiseLite`; decorations seeded by `run_seed + chunk_x + chunk_y`, no collision.
- Tileset and decoration list read from `levels.json` (one entry: The Aegean Shore, placeholder art).
- World origin shift past ~50,000 px.

**Done when**
- [ ] Walking 5 minutes in any direction shows no seams, gaps, or stutter.
- [ ] Returning to a spot shows the same ground and decorations.
- [ ] Memory use stays flat during a long walk (check Godot's Monitors).
- [ ] 60 FPS while walking.

**Not yet:** POIs, hazards, other levels.

---

## Phase 4 — Enemies core

**Build**
- Object pools for enemies; spatial hash grid (~64 px cells).
- Chaser and swarm movement; ring spawning just off screen; recycling enemies left far behind.
- **No stacking:** body radius and push-apart separation at 30 Hz, up to 8 neighbors [Core mechanics].
- Contact damage once per 0.5 s per touching enemy; **no invulnerability frames**.
- Player HP and death; debug-menu options to spawn N enemies and toggle god mode.

**Done when**
- [ ] 500 enemies at 60 FPS on PC.
- [ ] Enemies form a ring around a standing player and never overlap.
- [ ] Standing still while surrounded kills the player.
- [ ] No objects are created or freed during play (pools only).

**Not yet:** weapons, XP, elites, bosses.

---

## Phase 5 — Weapons and smart targeting

**Build**
- Heracles' Great Club as the first weapon, built from a reusable fire-pattern script.
- Targeting types: `targeted`, `melee`, `orbit`/`aura`, `random`, `directional`, `range_switch`; retarget every 0.1 s [Controls and smart targeting].
- Damage formula exactly as in [Core mechanics], plus knockback and damage numbers.
- Each weapon has its own attack interval and per-enemy hit interval in data.

**Done when**
- [ ] The club hits the nearest enemy even while the player runs away from it.
- [ ] A small test verifies the damage formula order (Might, crit, weakness/resistance, Armor, minimum 1).
- [ ] Damage numbers appear and use pooled objects.

**Not yet:** XP, level-ups, elements.

---

## Phase 6 — XP, level-ups, and the run log

**Build**
- XP orbs (1/5/25), pickup radius, merging above 300 orbs, XP bar.
- Rising-pitch pickup sounds: pentatonic, 12-step cap, 0.4 s chain window, 0.6 s reset, 20 sounds/s limit [Screens, HUD, art, audio].
- Level-up screen: 3 cards (4 with high Luck) mixing items, stats, and skills; soft curves instead of hard caps; Gold/Heal cards when everything is maxed; Auto-collect setting [Core mechanics].
- Weapon levels 1–8; the 9 passives; a few general weapons.
- Banked level-ups (solo); run timer stops during level-ups.
- Basic run log saved at the end of each run (time, cause of death, build).

**Done when**
- [ ] Collecting orbs quickly climbs the scale and holds at the top note.
- [ ] A magnet-style pickup of hundreds of orbs doesn't spam sound.
- [ ] Every level-up offers at least one useful card; maxed builds get Gold/Heal.
- [ ] Auto-collect resolves maxed level-ups without pausing.
- [ ] A run log file exists after each run.

**Not yet:** elements, Heroes other than Heracles, gods.

---

## Phase 7 — Fun checkpoint (no new features)

**Do**
- Play many 10-minute runs. Tune speeds, spawn rates, damage, and XP in `config.json`.
- Write down what feels good and bad in `docs/PROGRESS.md`.
- Send the Phase 7 report to Claude for review.

**Done when**
- [ ] The owner says moving and killing feels fun on its own.

---

## Phase 8 — Elements

**Build**
- 8 elements + Physical, one status each, stored as data on pooled enemies and ticked at 5 Hz [Elements, statuses, and reactions].
- Weakness ×1.5 / resistance ×0.5, Armor, the 4 reactions, spell tier names, effect budgets.
- Players are only affected by elemental statuses from 30:00, at reduced strength [Core mechanics].

**Done when**
- [ ] Each status and reaction works and is visible.
- [ ] 500 enemies with statuses still run at 60 FPS.
- [ ] Effect budgets recycle the oldest effects when full.

---

## Phase 9 — Heroes

**Build**
- `heroes.json` (with `name_key`, `care_tier`, `lore_source`, `lore_verified`), Hero select screen.
- Heracles, Cú Chulainn, Väinämöinen, Tomoe Gozen with Legend Traits, passives, signature weapons, and expertise [Heroes], [Core mechanics].
- The four extra general weapons (Javelin, Longbow, Bronze Sword, War Hammer).

**Done when**
- [ ] Each Hero plays noticeably differently.
- [ ] Expertise bonuses apply only to the right weapon categories and show an "Expert" badge.
- [ ] Heracles' Labors appear and reward correctly.

---

## Phase 10 — Aegean Shore waves, elites, chests

**Build**
- Per-level wave table for the Aegean Shore; its enemy families; all movement types; Ages and their visuals; thunderstorm hazard.
- Elites with modifiers and diminishing crowd control.
- Chests with the pantheon-themed reveal; standard evolutions; Codex [Discovery and feel].

**Done when**
- [ ] A full 30-minute Aegean run shows all Ages and elites.
- [ ] Evolutions trigger correctly and the reveal shows the recipe.
- [ ] Chest reveal is skippable after 0.5 s.

---

## Phase 11 — Gods

**Build**
- Shrines (50% local pantheon), peaceful binding, Duel/Endurance/Chase trials.
- Two god buttons and meters, Blessings, summons enhanced by player stats, Divine Links, Patronage, auto-summon setting.
- Banter lines on binding [Gods (summons)], [Discovery and feel].

**Done when**
- [ ] All 8 Pack 1 gods can be found, bound, and summoned.
- [ ] Each trial type can be won and failed.
- [ ] Both god buttons work independently on PC, gamepad, and touch.

---

## Phase 12 — Resonance and infusions

**Build**
- The 5 Resonances with Harmony and the Resonance button; 8 infusion templates and Empowered [Divine Resonance and Patronage].

**Done when**
- [ ] Each Resonance triggers only when both meters are full and the pair is compatible.
- [ ] Infused weapon names build automatically.

---

## Phase 13 — Aegean Shore bosses

**Build**
- Boss pattern library, arena rule, telegraphs, cast bars, Guard gauge.
- Medusa, Achilles (and his Hero unlock), Kronos. Bosses spawn on time even if the last is alive.
- Boons, the Unraveling, boss-entrance banter [Bosses], [Core mechanics].

**Done when**
- [ ] Every attack is telegraphed and dodgeable.
- [ ] Defeating Achilles unlocks him and saves immediately.
- [ ] **The Aegean Shore is a complete vertical slice. Full review with Claude before continuing.**

---

## Phase 14 — World discoveries

**Build**
- Region layer, 5 POI types, compass, Wandering Trader, 2 world events [Endless world and discoveries].

**Done when**
- [ ] The same seed always places the same POIs.
- [ ] Trader purchases reduce banked gold.

---

## Phase 15 — Meta, saving, and discovery

**Build**
- Save v3 in the cloud-sync-ready format; persistence rule (save the moment something persistent is earned); quit rule (10% after 5:00, none before); Steam Cloud backup.
- Hall of Legends menus, level select, offerings, unlocks, bestiary, Pantheon Compendium, Hall of Heroes, achievements, Omens; King Arthur and Atalanta.
- Death recap, secrets, the Oracle, Odysseus; Swift Mode [Death, permanent progression, and saving], [Discovery and feel].

**Done when**
- [ ] Force-closing the game mid-run never loses an unlock.
- [ ] Quitting before and after 5:00 banks the correct gold.
- [ ] The death recap shows a relevant tip.

---

## Phases 16–18 — Remaining Pack 1 levels

One phase each: **Midgard's Edge**, **The Two Lands**, **The Misty Isles**. Each needs its tileset, hazard, enemy families, wave table, 3 bosses, and local gods [Regional levels].

**Done when (each)**
- [ ] A full 30-minute run is playable with all 3 bosses.
- [ ] Hazards pause during boss arenas.
- [ ] Review with Claude before the next level.

---

## Phase 19 — Polish

Art, audio, accessibility settings, onboarding tips, mobile UI and safe areas, a performance pass on a real mid-range phone, exports. Verify every launch Hero, god, and boss's lore and set `lore_verified: true`.

---

## Phase 20 — Co-op and cloud saves

Only once single-player is stable: Epic Online Services setup, cross-platform cloud sync with merge rules, 6-digit lobby codes, turn-based co-op level-ups, fairness rules, Wandering Shade mode [Online co-op], [Cloud saves].
