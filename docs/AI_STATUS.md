# AI Development Handoff

Last updated: 2026-10-29
Agent: Claude Code (cloud), developer mode
Branch: `main` (owner asked for direct pushes to `main`, and for only `main` and `data` to exist on GitHub)
Task: Phase 20 (Co-op and cloud saves) through the owner's Cloudflare Worker
Version: 00.01.34
Status: All 20 build phases have code, plus Public Games with joining in progress (00.01.32); 234 Godot tests and 40 Worker tests pass; co-op and public games were played automatically with two and three copies of the game. The owner played co-op between a PC and a phone and tested phones (10/29/2026): both work. Phases 1–20 reviewed: Approved with fixes (`docs/reviews/PHASE_01-20_REVIEW.md`). Packs 2–4 planned in `docs/PACK_PLAN.md` (not started). Needs: art and audio, the lore sign-off, the owner's go-ahead for Pack 2.
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
2. **Debug menu:** F1 shows `Version 00.01.23` and `FPS: …`. Arrow keys / D-pad move between buttons.
3. **Broken JSON:** **Check test data files** lists two errors for `broken_example.json`, naming `speed` and `limits.max_count`.
4. **Translation:** in the debug menu, turn on **Show translation test line**; the bottom of the screen says "Translation test: …". **Pseudo-localization** makes it longer, accented, and in [brackets].
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

**Phase 8 — Elements**
1. F1 → **Give me all six spells**. Ember (orange bolts), Frost (ice spread), Spark (strikes), Breeze (wind wave in your direction), Glimmer (circling lights), and Shade (dark aura) all attack.
2. Grey-blue chasers are Water: Spark (lightning) hits them for big yellow numbers with "!"; Ember (fire) hits them for small grey numbers.
3. Enemies change tint when Burning, Chilled, Frozen, Shocked, Soaked, Poisoned, or Hexed; the debug line counts each status.
4. **Soak nearby enemies**, then let Spark hit: "Conduct!" appears and lightning chains. **Freeze nearby enemies**, then the Great Club hits: "Shatter!". **Chill**, then Ember: "Steam Burst!". **Burn**, then Breeze: "Spread!".
5. Level a spell from 3 to 4: the card says "Ember → Flame" and plays a different sound.
6. **Jump the timer to 30:00**: enemies that touch you now pass on their status ("on you" in the debug line), for half as long, never freezing you.
7. **Fill to the enemy cap** with all spells: write down the FPS.

**Phase 9 — Heroes**
1. The game opens on **Choose your Hero** with four cards. Pick each in turn (F1 → **Back to Hero select** to switch).
2. **Heracles** (gold square): the HUD shows "Labor 1: The Nemean Lion (defeat enemies 0 / 50)". Finish it (or F1 → **Finish the current Labor**): a "Labor complete" banner and +1 Armor. The first hit every 8 s does half damage.
3. **Cú Chulainn** (green): every 8 s he leaps 3 tiles the way you move, a dark shadow marks the landing, and a green ring hits enemies there. Below 30% HP the HUD says "Battle Frenzy!".
4. **Väinämöinen** (blue): Runo Song bolts change colour Fire → Ice → Lightning. Reactions add Verses (HUD "Verses 3 / 10").
5. **Tomoe Gozen** (red): sword slashes up close, arrows farther away. Keep moving: Momentum climbs to 10, then "Charge!" tramples enemies; standing still halves Momentum.
6. Level-up cards for weapons the Hero is expert in say "Expert!" (Heracles: Longbow, Throwing Axe, Bladed Discus).
7. After dying, **Retry** keeps the Hero, **Change Hero** goes back to the select screen.

**Phase 10 — Aegean waves, elites, chests (00.01.17)**
1. Enemies are now coloured by element: brown-grey Satyrs walk at you, small dark Shade swarms and pale-green Harpy flocks rush in packs, and lines of flyers cross the screen in a wave and leave.
2. F1 → **Jump to the next Age**: at 10:00 the light turns blue, embers drift, and a "Night falls" banner shows. Blue Sirens stop at a distance, glow white, then fire a slow shot with a dark outline; big grey-green Draugr brutes appear. At 20:00 (Deep Night) threads drift at the screen edges, a ring of Shades closes in, and orange Muspel Sparks flash and explode next to you.
3. At 2:00 (or F1 → **Start the thunderstorm**) "A thunderstorm rolls in!": orange circles fill up, then lightning strikes them, hurting you and enemies.
4. F1 → **Spawn an elite**: a big enemy with a health bar and coloured modifier icons. Splitting ones leave 3 small copies; Warded ones show a blue shield bar that Glimmer (Holy) breaks at once. It drops gold coins and a chest.
5. Walk onto the chest: the game pauses, a spinning ring cracks while light grows bronze, silver, or gold, then the rewards appear one by one. Tap or press a key after half a second to skip; it never lasts more than 3 s.
6. F1 → **Make a weapon ready to evolve**, then **Open a chest now**: the weapon and passive names fly together into the evolved weapon (e.g. "Labor-Breaker": every slam quakes), and "New recipe discovered" appears.
7. Esc (Start on a gamepad, **II** on touch) opens the pause menu; **Codex** lists all 16 recipes, with the ones you found filled in.

**Phase 11 — Gods (00.01.17)**
1. At 1:30 a shrine appears with an arrow at the screen edge pointing to it (or F1 → **Place the next god's shrine next to you**, which goes through all 8 gods in turn). When it comes into view, the god says a line in a bubble at the bottom left.
2. Peaceful shrines (Tyche, Cernunnos, Ra): stand on it; a ring fills in 2 s and the god joins. A god button with a meter ring appears at the bottom right.
3. Trial shrines: Thor and Poseidon fight inside a ring (Duel; leaving it fails), Sekhmet rains attacks for 40 s (Endurance), Skadi and the Morrígan flee while decoys appear (Chase: touch the real one 3 times). Every attack shows an orange marker or a red flash first.
4. Fill the meters (F1 → **Fill god meters**) and press Q / E (LB / RB, or tap the buttons): each summon does something different (Thor's hammer flies out and back, Ra's sun crosses the screen, Skadi freezes everything, and so on). The two buttons work separately.
5. With two gods bound, a third asks which to release, or Decline.
6. Heracles: after a summon his next 3 Great Club slams make full shockwaves. Cú Chulainn's leap landings apply his gods' elements. Väinämöinen's Runo Song adds his gods' elements. Tomoe's gods charge faster at full Momentum.
7. Pause menu → **Auto-summon**: full gods fire by themselves in big crowds.

**Phase 12 — Resonance and infusions (00.01.17)**
1. Bind a pair that resonates (F1 → **Bind the next god now** until you have, for example, Sekhmet + Skadi; or Poseidon + Thor): "Resonance discovered: …" appears.
2. F1 → **Fill god meters**: both god rings pulse together and a **Resonance!** button appears above them. Tap it, press R, or press Q and E together (LB + RB): a big combined effect plays and both meters empty. Pressing one button alone still summons just that god.
3. A pair that doesn't resonate (Tyche + Thor) never shows the button.
4. Get a weapon to level 8 (F1 → **Make a weapon ready to evolve** also does that), bind a god, then open a chest without the evolution passive: the weapon is infused, e.g. "Thunder Gáe Bolg", and its hits change colour. With two gods bound you choose which. A god of the weapon's own element makes it "Empowered".
5. Pause → **Codex** lists infusions and Resonances you've found.

**Phase 13 — Aegean Shore bosses (00.01.17)**
1. At 10:00 (or F1 → **Summon Medusa now**) "Medusa appears!": nearby enemies burst into XP, a gold arena ring keeps you in, and a boss bar shows her name, phase, HP, Guard gauge, weakness (Wind) and resistance (Earth).
2. Every attack shows an orange marker or a red flash first. Medusa's Gaze: an orange cone fills; if you're walking toward her when it fires you turn grey and can't move for 1.5 s. Walk away or sideways instead. Her third phase adds stone statues that stop shots.
3. Keep hitting: the gold Guard bar fills (twice as fast with her weakness). When full, "Guard Break!": she's stunned 4 s and takes extra damage. F1 → **Break the boss's Guard** / **Skip the boss to its next phase** help test.
4. Achilles (20:00, or F1): hits from in front barely hurt him; get behind him. Defeat him: "New Hero unlocked: Achilles!" and he's on the Hero select screen from then on, even after restarting.
5. Kronos (30:00): purple slow-time circles, shots that fly back along their paths, and a pull toward him in his last phase.
6. After each boss: a big chest, gold, and **Choose a Boon** (pick one of three).
7. When Kronos falls (or at 33:00, or F1 → **Start the Unraveling**) a ring forms around you and shrinks; outside it is dark and hurts more and more.

**Phase 14 — World discoveries (00.01.17)**
1. Near the start there's always a ring of columns (Ancient Ruins). Stand inside: a white ring fills over 10 s while more enemies come; then choose a level-up, a full heal, or gold.
2. Walk around: icons at the screen edge point to points of interest within 4 screens ("?" when farther than 2). F1 → **Place the next point of interest nearby** cycles through all five.
3. Dragon's Hoard: a gold box in a big circle; defeat 50 enemies inside it and it drops a chest and gold. Monster's Lair: a broken ring of walls; walk close and 3 elites with guards appear; defeat the elites for a big chest. Hidden Shrine: an extra shrine appears.
4. Wandering Trader (green stall with a red roof): walking up opens the shop. F1 → **Give 500 gold**, then buy things: the gold in the corner goes down. Prices are higher after 10:00. Reroll and Banish buttons then show on the level-up screen.
5. At 7:00 (or F1 → **Start a Chaos Surge**) "Chaos Surge!": more enemies and double XP for 60 s. At 13:00 (or F1 → **Start a Divine Storm**) god meters fill twice as fast while lightning strikes around you.

**Phase 15 — Meta, saving, and discovery (00.01.22)**
1. The game opens on the **title**: Play, Hall of Legends, Leaderboard, Quit (PC). Play → choose a level → choose a Hero (locked Heroes say how to unlock them; **Back** returns).
2. Die: the results screen shows what felled you (with its element), the most damage in the last 10 s, your build, gods, top weapon %, time, gold banked, your personal best, anything unlocked, and a **Tip** that fits the death (e.g. Medusa's gaze). **Hall of Legends** goes to the Hall.
3. **Gold**: dying keeps all the run's gold. Pause → **Quit run** before 5:00 keeps none, after 5:00 keeps 10%. Closing the game mid-run counts as quitting (settled the next time it starts).
4. **Hall of Legends**: Offerings (gods you've bound; offer gold to raise them to level 10), Unlocks (buy King Arthur for 1,000 gold and Breeze / Glimmer / Shade; equip cosmetics), Omens (after surviving 10:00), Bestiary (entries on first kill; weakness at 25 kills, myth at 100), Pantheon Compendium, Hall of Heroes, Codex, Achievements (secrets show ???), the Oracle (a hint every 5 runs).
5. Survive 20:00 → Atalanta unlocks. Survive 10:00 without picking up any gold → Odysseus. Defeat Medusa without being petrified → the Mirrored Shield passive. Beat Kronos → Swift Mode for the Aegean Shore (toggle in level select): bosses at 7/14/21 min.
6. The timer shows your best time for that Hero and level ("3:12 (best 9:40)") and a banner when you pass it.
7. King Arthur: stand still → a shield arc blocks shots in front. Atalanta: a golden marker appears every 25 s; reach it for XP and speed. Odysseus: stand still for traps; every 20 s a decoy draws enemies away.

**Phases 16–18 — Midgard's Edge, The Two Lands, The Misty Isles (00.01.22)**
1. Beat Achilles (the Aegean Shore's 20:00 boss): "New level" lines appear and level select shows the other three levels (F1 can jump the timer).
2. Each level looks different (snow and pines; sand, reeds, and obelisks; green hills and stone circles) and has its own chest seal.
3. Around 2:00 its weather arrives: a blizzard pushes you and closes your vision; a sandstorm the same; mist only hides the edges. It stops during boss fights. Frozen ponds make you slide, quicksand slows you, and stepping into a fairy ring carries you to its partner.
4. Bosses at 10/20/30 min (or F1's boss spawns). **Fenrir**: chained to four posts, he breaks free in phase 3. **Loki**: three copies appear in phase 2; only the real one has a shadow; in phase 3 he swaps places with you and a fake shrine bursts into fire. **Surtr**: an orange fire ring closes in. **Ammit**: a scale over her tips each time you're hit; full = devouring lunge. **Set**: the screen goes sandy except a small circle; cyclones pull in phase 3. **Apep**: swallows one of your gods (Ra if you have him); hit Apep while the orb in him glows to free the god. **Scáthach**: names each technique on the cast bar; repeats come faster. **Ferdiad**: a blue river strip slows you; his front is armored (circle him). **Balor**: when the eye opens, hide behind a stone circle; the red beam sweeps.
5. Secrets now findable: Tyr's Oath (beat Fenrir below 30% health), The Sun's Return (free Ra from Apep), Lugh's Sling (hit Balor's open eye 5 times), The Ford (as Cú Chulainn, beat Ferdiad without leaving the river).
6. Beating Scáthach unlocks her as a Hero (Trainer of Heroes: every weapon card also levels another weapon).

**Phase 19 — Polish (00.01.23)**
1. Title screen and pause menu each have **Settings**. Pressing a row steps its value; everything is saved at once and kept after closing the game.
2. **Volume** changes the sound right away (0% = silent). **Text size** 140% makes menu text bigger (pages opened after the change).
3. **Your attack effects** at 30–40%: your weapon swings, projectiles, and god summons get see-through; enemy attacks stay solid.
4. **Screen shake**: summoning a god or breaking a boss's Guard shakes the screen a little; Low is gentler, Off none. **Hit flash** Off: enemies no longer flash white when hit.
5. **Damage numbers** Off hides them. **Element tags** On adds "Fi", "Ic", "Li"… after numbers. **Colourblind-friendly colours** On changes the element colours (start a new run to see enemies recoloured).
6. **Auto-summon** and **Auto-collect** are remembered between runs (the pause-menu switch and the level-up box change the same setting).
7. **Touch control size** 150% makes the joystick and god buttons bigger. **Joystick side**: Whole screen (default, 00.01.24) starts the joystick wherever you touch except on a button; Left / Right limit it to that half. With Right, the god buttons and banter bubble swap corners so nothing overlaps.
10. (00.01.24) On the Aegean Shore, Night brings **Spartoi** (big, slow, armoured) and Deep Night **bronze bulls** (run at you and burst after a short flash) instead of Draugr and Muspel Sparks.
8. **First-run tips**: in your next run a tip appears the first time you level up, see a shrine, hit a weakness, fill a god's meter, and have a Resonance ready, each once ever. **Show first-run tips again** resets them; **First-run tips** Off stops them.
9. On a phone with a notch, menus, the HUD, and god buttons stay clear of the notch and rounded corners.

**Phase 20 — Cloud saves (00.01.25)**
1. Settings → **Cloud save** → **Turn on cloud save**: it shows a code like `ABCD-EFGH-JK23` and "Cloud save is on."
2. On another device or browser: Settings → Cloud save, type the code, **Link this device**. Within a few seconds that device has the first one's unlocks and gold (a line says the gold came from the other device).
3. Earn something on either device; on the other, **Sync now** (or restart) shows it.

**Phase 20 — Co-op (00.01.25)** (two devices or two browser windows; each needs the same version)
1. Title → **Co-op** → **Host a game**: a 6-digit code appears. On the other device: Co-op, type the code, **Join**. Both lists show both players.
2. Each picks a Hero (the same is fine); the host picks the level (and Swift Mode if unlocked); the host presses **Start**. Both games start on the same map.
3. Move on each device: the other Hero glides along; enemies, shots, damage numbers, gold, and XP match on both screens.
4. Level-up: the game pauses on both; one player sees their cards while the other sees "Player N is choosing…", then they swap (20 s each).
5. Shrines: each player who stands on a peaceful shrine binds their own copy; each has their own god buttons; summons show on both screens.
6. Let one Hero fall: they're downed (red ring shrinking). The other stands beside them for 3 s: revived at 30% HP. After 2 revives (or bleeding out) they become a see-through Shade that still collects XP.
7. Walk far apart: you stop at about 1.5 screens. Pause menu: the game keeps running.
8. When everyone is down or a Shade, both see the end screen with a Team section. If the host closes their game, the other sees "The host left, so the game ended."

**Leaderboard (00.01.15)**
1. Hero select has a **Leaderboard** button: it shows "No scores yet" (or the scores), and **Close** / Esc returns.
2. Die without touching F1: the death screen has a name box and **Submit score**. Until the owner setup in `leaderboard-api/README.md` is done, scores are saved on this device (00.01.21): it says so, **Submit score** → "Score saved!", and **Leaderboard** is titled "Leaderboard (this device)" and lists your saved runs, best first. They're still there after closing and reopening the game (on the web, in the same browser).
3. After setup: type a name, **Submit score** → "Score submitted!"; **Leaderboard** lists it with the Hero, weapons, and upgrades. Within a few minutes it also appears in `leaderboard.json` on the `data` branch.
4. Use any F1 game option (e.g. God mode), then die: the death screen says the run can't go on the leaderboard.

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
