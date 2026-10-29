# Changelog

One entry per change request, newest first (see `.cursor/rules/changelog.mdc`). The version here always matches `VERSION`. Work from before this changelog existed (versions 00.01.00–00.01.05: Phases 1–6 and the web link) is logged in `docs/PROGRESS.md`.

## Version 00.01.22
Date: 10/29/2026
Time: 12:19 AM

### Changes
- **Phase 15: Meta, saving, and discovery.**
  - **Saving.** Progress is kept in a save file and saved the moment something is earned, so closing the game never loses an unlock. A backup is kept in case the file breaks. The save is ready for cross-device cloud sync later.
  - **Gold between runs.** When you fall you keep all the gold from the run. Quitting from the pause menu keeps none before 5:00 and 10% after. Closing the game mid-run counts as quitting.
  - **Title screen and Hall of Legends.** Play → choose a level → choose a Hero. The Hall has Offerings (spend gold to raise a god you've bound from level 1 to 10), Unlocks (King Arthur for 1,000 gold; Breeze, Glimmer, and Shade for 300–500; equip cosmetics), Omens, the Bestiary, the Pantheon Compendium (gods, Resonances, and every banter line you've heard), the Hall of Heroes, the Codex, Achievements, and the Oracle.
  - **New Heroes.** King Arthur (Excalibur; Shield Wall blocks shots when you stand still; immune to burning and poison), Atalanta (Huntress's Bow; The Race: reach golden markers for XP and speed; unlocked by surviving 20:00), and **Odysseus**, a secret Hero (Great Bow; lays traps and leaves a decoy).
  - **33 achievements** (some unlock things: Omens, Atalanta, the Bladed Discus) and **8 secrets** shown as ??? until found, with a hint from the Oracle every 5 runs. Secrets found so far can give Odysseus, the Mirrored Shield, and cosmetics; the ones for Fenrir, Apep, Balor, and Ferdiad come with their levels.
  - **Omens** (after surviving 10:00): Haste, Frailty, the Horde, Silent Gods, each adding gold. **Swift Mode** for a level after beating its 30:00 boss: bosses at 7, 14, and 21 minutes, faster everything, more gold.
  - **Records and mastery.** Best times per Hero, level, and Omen set; the timer shows your best and celebrates passing it. Playing a Hero raises their mastery and unlocks new colours.
  - **Death recap.** What felled you, what hurt you most in the last 10 seconds, your build and top weapon, gods, gold banked, your best time, anything unlocked, and a tip chosen for how you died.
  - Weapons and passives that must be unlocked no longer appear on level-up cards until they are.
  - 21 new automated tests (180 in all, all passing), including closing the game mid-run without losing unlocks and quitting before and after 5:00.
  - Merged the newest work on main (the Suggest a Feature form and the online leaderboard connection). The Suggest button now sits in Hero select's bottom row with Leaderboard, Color, and Back, and its form opens on top of Hero select.

- **Phase 16: Midgard's Edge** (the Norse level), opened by beating the Aegean Shore's 20:00 boss.
  - Snowy pine forest with runestones and longhouse ruins (placeholder art), and a Norse-style chest seal.
  - **Hazards:** blizzards that push you and close in your vision, and frozen ponds you slide across. Both pause during boss fights.
  - **Enemies:** Draugr, Frost Thursar (walkers and casters), Muspel Sparks (swarms and bombers), Trolls, and the Great Troll elite.
  - **Bosses:** **Fenrir** (10:00) starts chained to posts and snaps his chains each phase until he runs free; his howl calls wolves. Beat him below 30% health for the Tyr's Oath secret. **Loki** (20:00) splits into copies, and only the real one casts a shadow. Copies burst into fire when hit, and later he swaps places with you and fakes a shrine. **Surtr** (30:00): the arena's edge burns inward, with his "Flames of Muspelheim" cast.
  - Local gods Thor and Skadi. Draft lines for Loki meeting Thor or Skadi.
- **A hazard library** the other levels reuse: weather (push wind and vision) and ground patches (slide, slow, teleport).

### Reason
The owner asked to build Phases 15 to 18.

## Version 00.01.21
Date: 10/28/2026
Time: 9:35 PM

### Changes
- **Local leaderboard.** Until online scores are set up, **Submit score** on the death screen saves your run on this device, and the Leaderboard (from Hero select or the death screen) shows "Leaderboard (this device)" with your best 100 runs: longest time first, then level, then kills, each with its Hero, weapons, and upgrades. Scores stay after closing the game (on the web, in the same browser). Runs that used the debug menu still can't be submitted. Once the online board is set up, the game switches to it automatically.
- New tests for the local board (159 tests, all passing).

### Reason
The owner asked for a local leaderboard until the online one is set up.

## Version 00.01.20
Date: 10/28/2026
Time: 9:30 PM

### Changes
- **Bosses are easier to see:** every living boss has a bold red ring that pulses slowly, so Medusa no longer blends into the grass.
- **"All twelve Labors complete!"** now shows for 4 seconds and then clears, instead of staying on screen for the rest of the run.
- **The "Translation test" line is hidden** during play. It can be turned on in the debug menu (F1): **Show translation test line**.
- **Heracles' Labors are spread over the run** to match the slower leveling (for example, the Nemean Lion now needs 100 kills, the Cretan Bull level 20, and the Apples of the Hesperides level 40). Before, all twelve were done by about 9 minutes; now about 8 are done by 13 minutes, and the last ones land around 22–25 minutes.
- New test for the Labors message (156 tests, all passing).

### Reason
The owner said yes to the four suggested changes after the balance pass: easier-to-see bosses, the Labors message, moving the translation test line to the debug menu, and re-checking the Labors.

## Version 00.01.19
Date: 10/28/2026
Time: 9:00 PM

### Changes
- **Slower leveling (owner approved).** Each level now needs a fixed 30 XP more than the last, plus 1.5%, instead of 10% more. In bot playtests: about level 9 at 3:00, 25 at 10:00, 50 at 20:00, and 65+ near the end, so there are choices the whole run and a full build comes late. Before, players hit level 30 by 3:00 and had every weapon maxed by 10:00. GAME_DESIGN.md updated.
- **A more dangerous start (owner approved).** More enemies in the first 10 minutes (1.6 per second at the start, rising to 2.75 by 8:00; was 1.0–2.2), more Shade swarms, Harpy swarms from 2:00, and Shade flyers crossing the screen from the start. Spawns after 10:00 are 20% higher too, since slower leveling also slows the extra spawns that come with your level.
- **Väinämöinen has 100 HP** (was 85; owner approved). GAME_DESIGN.md updated.
- **Shorter boss fights.** Medusa, Achilles, and Kronos have less HP and smaller Guard gauges, so fights last about 2–3 minutes with the slower leveling (they would have lasted about 5).
- Tests updated for the new XP curve and Väinämöinen's HP.

### Reason
The owner approved slowing leveling and making the first 10 minutes more dangerous (with more HP for Väinämöinen) after the playtest report. Each change was checked with full bot playtests of all four starting Heroes.

## Version 00.01.18
Date: 10/28/2026
Time: 8:06 PM

### Changes
- **Playtest by a bot.** Played full 36-minute runs of the real game, with a bot steering each Hero (Heracles, Cú Chulainn, Väinämöinen, Tomoe Gozen) and one with god mode to see every Age, boss, and event. No script errors in any run.
- **Fix: god trials during boss fights.** A god's Trial could start, or keep running, while a boss was being fought, and when it ended it set the spawn rate back to normal, so the full horde returned mid-boss. Now Trials don't start during a boss fight; a Trial already running when a boss arrives is called off without failing, and its shrine stays so you can try again after the fight. The boss fight's spawn rate is never reset by a Trial.
- **Fix: "Felled by" on the death screen** now also names a god (when a Trial kills you) and the Unraveling. Before, only enemies were named.
- New test for the Trial/boss fix (155 tests, all passing).
- Added Godot's ID files (`.uid`) for scripts and tests from Phases 7–14, plus the translation table's import file, so the project opens the same way everywhere (Godot recommends keeping these in the repository).

### Reason
The owner asked to test the game and get an honest assessment of where it's at. The playtest found these two bugs.

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
- **Phase 12: Resonance and infusions.**
  - The 5 launch Resonances: Sun and Snow (Sekhmet + Skadi), Storm Over the Sea (Poseidon + Thor), Burning Greenwood (Cernunnos + Sekhmet), Frozen Deluge (Skadi + Poseidon), and Eye of Ra (Ra + Sekhmet). Each has an always-on Harmony while both gods are bound and a Resonance summon when both meters are full: tap the Resonance button that appears above the god buttons, press R, or Q+E / LB+RB together. It uses both meters; summoning either god alone still works. A "Resonance discovered" banner shows the first time.
  - Divine infusions with all 8 templates (Sunfire, Winter, Thunder, Greenwood, Tidal, Fortune's, Solar, Raven): a level-8 weapon (evolved or not) plus a bound god → the next chest infuses it with the god's element and effect. With two eligible gods you choose. A god of the weapon's own element makes it **Empowered** (+50% status chance and duration). Names build automatically ("Thunder Gáe Bolg", "Winter Barbs").
  - The Codex also lists infusions and Resonances found. Väinämöinen's reactions during a Resonance count double for Verses.
- **Phase 13: Aegean Shore bosses.**
  - **Medusa** (10:00): serpent-hair volleys, then her Gaze (an orange cone charges; anyone moving toward her when it fires is petrified for 1.5 s), then stone statues that block shots.
  - **Achilles** (20:00): spear rushes, shield-charge combos, then rage. The Heel: −80% damage from the front, ×2 from behind, so circle him. Defeating him **unlocks Achilles as a Hero** (saved at once): Spear and Shield, The Heel (less damage from the front, more from behind), Shield of Achilles (+2 Armor).
  - **Kronos** (30:00): scythe sweeps, then slow-time zones, then he pulls you in while bullets spiral out; once per phase he sends his shots back along their paths.
  - Bosses arrive on time even if the last one is still alive. When a boss appears, regular enemies on screen burst into XP orbs, an arena ring keeps you in, only weak fodder spawns, and the thunderstorm and elites pause.
  - Boss bars show the name, phase, HP, the Guard gauge (damage fills it, weakness hits twice as fast; when full: Guard Break, 4 s stun, +50% damage taken, cast cancelled), weaknesses and resistances, and a cast bar naming big attacks.
  - Rewards: a big chest, a gold bonus (+50 / +100 / +200), and a **Boon** (choose 1 of 3 run-wide effects, like +1 projectile on all weapons).
  - **The Unraveling** begins when Kronos falls or at 33:00: a ring shrinks 10% a minute and the world outside frays; outside it you take rising damage.
  - Boss entrance lines (Kronos has a special line for Heracles, his grandson).
- **Phase 14: World discoveries.**
  - The world is split into regions (4×4 chunks); about a third hold a point of interest, the same ones every time for the same seed. The start always has Ancient Ruins nearby.
  - **Hidden Shrine** (an extra shrine, more often an uncommon or rare god), **Ancient Ruins** (stand in the circle 10 s while enemies pour in, then choose a level-up, a full heal, or gold), **Dragon's Hoard** (defeat 50 enemies inside its circle to break the seal: chest + gold), **Monster's Lair** (3 elites with guards inside a ring of walls: big chest + gold), and the **Wandering Trader**.
  - The Trader sells, for run gold: Reroll token (25), Traveler's bread (50), Whetstone (75), Incense (40), Banish token (60); prices rise ×1.5 each Age. Reroll and Banish buttons appear on the level-up screen when you have tokens.
  - A compass at the screen edge shows points of interest within 4 screens ("?" until within 2).
  - World events: **Chaos Surge** (60 s, twice the enemies and XP) and **Divine Storm** (45 s, god meters charge twice as fast while lightning strikes random spots), more often later in the run.
- Fixed: the debug menu printed errors when a run ended; a Codex test compared text the wrong way; a boss's "clean slate" missed enemies that had just spawned.

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
