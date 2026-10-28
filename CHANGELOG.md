# Changelog

One entry per change request, newest first (see `.cursor/rules/changelog.mdc`). The version here always matches `VERSION`. Work from before this changelog existed (versions 00.01.00–00.01.05: Phases 1–6 and the web link) is logged in `docs/PROGRESS.md`.

## Version 00.01.17
Date: 10/28/2026
Time: 5:47 PM

### Changes
- **Phase 10: Aegean Shore waves, elites, chests.**
  - The Aegean Shore's real enemy families replace the placeholders: Shades, Harpies, Sirens (casters), and Satyr skirmishers, plus Draugr brutes and Muspel Spark bombers from the shared families. All seven movement types: chasers, swarms, brutes, flyers that cross the screen in waves, casters that stop and fire a glowing shot, encirclers that close in from a ring (Deep Night), and bombers with a flashing fuse.
  - A minute-by-minute wave table (`data/waves_aegean_shore.json`); enemy HP grows from ×1 at 0:00 to ×3 at 30:00.
  - The four Ages (Dusk, Night, Deep Night, the Unraveling), each with its own light, drifting embers and threads, and a banner.
  - The thunderstorm hazard: telegraphed lightning strikes that hurt players and enemies.
  - Elites (Minotaur, Cyclops, Gorgon-kin) at 5:00, 15:00, 25:00 and at random times after, with modifiers shown as icons over their health bar: Hasted, Armored, Splitting, Warded, Elemental Aura, Summoner (two modifiers in Deep Night). Repeated freezes and stuns on elites get shorter, then they're immune for 5 s.
  - Gold coins (5% from enemies, guaranteed from elites); the HUD shows run gold.
  - Chests from every elite, with a reveal: a spinning Greek meander seal, a light that previews the reward (bronze, silver, gold), and rewards one at a time. Skippable after 0.5 s, never longer than 3 s.
  - All 16 standard evolutions (a level-8 weapon plus its paired passive evolves at the next chest), with a fusing reveal and a "New recipe discovered" banner.
  - The Codex lists every recipe; undiscovered ones are hidden. It opens from the new pause menu (Esc, Start, or the II button on touch).
- **Phase 11: Gods.**
  - The 8 launch gods: Tyche, Cernunnos, Thor, Skadi, Sekhmet, Poseidon, Ra, and the Morrígan, each with the design's Blessing, meter trigger, and summon.
  - Shrines appear about every 3 minutes (first at 1:30), 1.5–2 screens away, with an arrow at the screen edge; they fade after 90 s. Half the time it's one of the Aegean Shore's own gods (Tyche, Poseidon); rare gods never before 8:00. Each shrine looks like its pantheon's (temple, runestone, obelisk, stone circle).
  - Peaceful shrines bind after standing at them for 2 s. Trials: **Duel** (the god fights inside a ring with two attack patterns; leave the ring or take over 60 s and you fail), **Endurance** (survive 40 s in the ring), **Chase** (touch the fleeing god 3 times in 40 s while decoys appear). A third god asks which one to release, or decline.
  - Two god buttons with meter rings (bottom right; Q / E on PC, LB / RB on a gamepad). Auto-summon in the pause menu.
  - Patronage (+15% charge for gods of the Hero's own pantheon; +8% for all gods for Väinämöinen and Tomoe Gozen) and each Hero's Divine Link.
  - Short banter lines when a god is found, bound, or summoned, including Heracles with Poseidon and Cú Chulainn with the Morrígan. All lines are drafts for owner review.
  - The shared attack pattern library (radial burst, spiral, aimed fan, line sweep, ground circles, charge with trail, falling strikes, summon adds, safe zone), with orange ground markers and a red flash before every attack.
- Fixed: the debug menu printed errors when a run ended; a Codex test compared text the wrong way.

### Reason
The owner asked to build Phases 10–14.

## Version 00.01.16
Date: 10/28/2026
Time: 5:15 PM

### Changes
- Added the new leaderboard settings to the data rules (`data/schemas.json`), which fixes the two automated tests that failed in 00.01.15.
- Leaderboard rows that name a weapon this version doesn't have (for example from an older or newer version) now show its id quietly instead of printing an error (the last failing automated test).
- Re-published the web game: GitHub's second publisher (the "Deploy from a branch" Pages setting) finished last and replaced the game with a plain text page.

### Reason
The owner couldn't load the game after 00.01.15.

## Version 00.01.15
Date: 10/28/2026
Time: 5:11 PM

### Changes
- **Shared online leaderboard.** After a run, type a name and press **Submit score**. Each score records the name, Hero, time survived, level, kills, every weapon with its level, and every upgrade (passive item) with its level. A **Leaderboard** button on Hero select and the death screen shows the best 100 runs from all players (ranked by time survived, then level, then kills).
- Scores are stored by a small online service (`leaderboard-api/`, a Cloudflare Worker) that checks every score and is the only thing that can write `leaderboard.json` on the new **`data`** branch. The game never holds a GitHub key, so players can't change the board by hand.
- Runs where the F1 debug menu's game options were used (god mode, gain a level, …) can't be submitted.
- The name you type is remembered for next time.
- One-time owner setup steps are in `leaderboard-api/README.md` (until then the board reads from GitHub and Submit says online scores aren't switched on yet).
- Fixed the one failing automated test from 00.01.14 (a test comparing text the wrong way; the game itself was fine). New tests for the leaderboard (game side and service side).

### Reason
The owner asked for a leaderboard that all players can see, logging the Hero, weapons, and upgrades, stored on the `data` branch where only the game can change it.

## Version 00.01.14
Date: 10/28/2026
Time: 5:02 PM

### Changes
- Difficulty now grows with your level: every **5 levels** enemies spawn 25% faster, and every **10 levels** enemies get +50% HP and +25% contact damage. All steps are in `data/config.json` → `enemies.level_scaling`.
- The debug enemy line shows the current spawn and enemy HP multipliers.
- New automated test for the scaling; bumped the version to 00.01.14.

### Reason
The owner asked for more enemies every 5 levels and higher difficulty every 10 levels.

## Version 00.01.13
Date: 10/28/2026
Time: 5:01 PM

### Changes
- **Phase 9: Heroes.** A Hero select screen opens the game: Heracles, Cú Chulainn, Väinämöinen, and Tomoe Gozen, with the design's stats, signature weapons, Legend Traits, passives, and expertise (`heroes.json`, content-gated).
- **Heracles:** Great Club; Twelve Labors (HUD goals, each giving a bonus for the run, up to 12); Lion's Hide (+2 Armor, first hit every 8 s halved).
- **Cú Chulainn:** Gáe Bolg (piercing line thrust; kills burst into barbs); Salmon Leap (every 8 s, 3 tiles, untargetable 0.8 s, landing shockwave, landing shadow); Battle Frenzy (below 30% HP: +30% attack speed, +15% Area).
- **Väinämöinen:** Runo Song (bolts cycling Fire → Ice → Lightning); Song of Power (each reaction he causes adds a Verse: +3% spell damage, up to 10, 6 s each); Eternal Sage (statuses last 30% longer).
- **Tomoe Gozen:** Sword and Bow (sword up close, arrows farther away); Cavalry Charge (Momentum from moving: +4% attack speed and +2% speed per stack; at 10 stacks a charge every 5 s that tramples and dodges the next hit); +10% Crit Chance.
- **Expertise:** weapons in a Hero's expert categories get +25% attack speed, +15% damage, and an extra projectile or pierce at level 8, with an "Expert!" badge on cards.
- Four new general weapons: Javelin, Longbow, Bronze Sword, War Hammer.
- Death screen: **Change Hero** next to Retry (Retry keeps the same Hero). HUD shows the Hero's trait (current Labor, Momentum, Verses, leap timer).
- Debug menu: finish the current Labor, back to Hero select; the info line shows the Hero.
- New automated tests for Heroes.

### Reason
The owner asked to continue with the next phase after confirming the spells work.

## Version 00.01.12
Date: 10/28/2026
Time: 4:49 PM

### Changes
- The debug button "Give me all six spells" now really gives all six (test only: it ignores the normal 6-weapon limit) and shows which spells it added.
- Bumped the version to 00.01.12.

### Reason
The owner didn't see six spells: with the Great Club (and any other weapon) already taking slots, the 6-weapon limit stopped the button from adding them all.

## Version 00.01.11
Date: 10/28/2026
Time: 4:39 PM

### Changes
- **Phase 8: Elements.** 8 elements plus Physical, each with one status stored as data on pooled enemies and ticked 5 times a second: Burn, Chill (3 stacks = Frozen), Shock, Soaked, Poison, Gust, Smite, Hex.
- Weakness ×1.5 (big yellow "!" numbers) and resistance ×0.5 (small grey numbers); Hex lowers Armor.
- The 4 reactions (Conduct, Steam Burst, Shatter, Spread) with their names popping up, plus the counterplay rules; at most 30 reactions per second (effect budget).
- Six spell weapons from the design: Ember, Frost, Spark, Breeze, Glimmer, Shade, with new strike, orbit, and aura attack patterns. Spells rename as they level (Ember → Flame → Blaze), shown on the level-up card with its own sound.
- From 30:00, enemies pass their element's status to players at half duration, Chill never freezes, and there's 2 s of immunity after each status.
- Placeholder enemies now have elements (chaser: Water; swarm: Dark) so weaknesses can be tested.
- Debug menu: give all six spells, apply each status to nearby enemies, freeze nearby enemies, jump the timer to 30:00, and a status count line.
- New automated tests for elements; data files keep a readable layout.

### Reason
The owner asked to build Phases 7–14 one phase at a time; Phase 7 is the owner's play-test, so Phase 8 comes first.

## Version 00.01.10
Date: 10/28/2026
Time: 4:29 PM

### Changes
- README: added "What you can play right now" (current weapons, passives, level-ups, Ambrosia), a controls table for PC, gamepad, and phones (including the debug menu), a phase-by-phase status table for all 20 phases showing Phase 7 as current, and a table linking the project documents. Kept the existing look, play link, and license section.
- Bumped the version to 00.01.10.

### Reason
The owner asked for a better README on GitHub and a reminder of all the phases.

## Version 00.01.09
Date: 10/28/2026
Time: 4:06 PM

### Changes
- Phones and tablets now show everything 1.5× bigger than PC (menus, HUD, buttons, text, joystick, and the game world), on top of the normal screen scaling. Setting: `ui.handheld_scale` in `data/config.json`.
- New healing item, **Ambrosia** (from the design's special pickups): each kill has a 2% chance to drop one; it heals 30 HP and flies to you like an XP orb, but only when you're hurt. Debug menu: "Drop an Ambrosia".
- Eased the placeholder difficulty: placeholder chasers now deal 3 contact damage (was 5), swarm enemies 2 (was 3), and enemies spawn 1.5 per second (was 2).
- New automated test for Ambrosia; bumped the version to 00.01.09.

### Reason
The owner wanted bigger windows on mobile and found it very hard to get past level 1–2 without any way to heal.

## Version 00.01.08
Date: 10/28/2026
Time: 2:03 PM

### Changes
- The game now has a fixed design size (1152×648) and scales everything (menus, HUD, buttons, text, the joystick, and the game world) to fit the screen, keeping the full width or height visible and showing a little more on wider or taller screens.
- New `SafeArea` helper so the touch joystick and the debug menu stay clear of phone notches after scaling.
- Bumped the version to 00.01.08.

### Reason
The owner found the windows too small on mobile: the game was drawn at the phone's full pixel resolution with nothing scaled up.

## Version 00.01.07
Date: 10/28/2026
Time: 8:02 AM

### Changes
- Added `LICENSE`: the same proprietary "All Rights Reserved" copyright as WaveDefence (Copyright (c) 2026 Zephino), pointing to the Zephino/Mythriven repo, with a note that third-party add-ons keep their own licenses.
- Added the license line and the `LICENSE` file to `START_HERE.md`.
- Re-ran the web build now that the repository is public.
- Bumped the version to 00.01.07.

### Reason
The owner made the repository public so the game can have a free GitHub Pages link, and asked to use the same copyright as WaveDefence.

## Version 00.01.06
Date: 10/28/2026
Time: 2:29 AM

### Changes
- Added the changelog rule as `.cursor/rules/changelog.mdc` (always applies).
- Created this `CHANGELOG.md`.
- Added an automated test that checks the newest changelog entry matches `VERSION`.
- Bumped the version to 00.01.06 in `VERSION` and `project.godot`.
- Fixed two bugs found by the first real Godot run on GitHub: the touch joystick class was renamed from `VirtualJoystick` to `TouchJoystick` (Godot 4.7 added a built-in class with that name), and `RunState` no longer declares `level` twice (the level's data is now `level_data`).

### Reason
The owner asked for every change request to be recorded with its version, date, time, what changed, and why. The bug fixes were needed because the GitHub web build couldn't compile the game, which stopped the playable link from being published.
