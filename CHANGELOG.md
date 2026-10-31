# Changelog

One entry per change request, newest first (see `.cursor/rules/changelog.mdc`). The version here always matches `VERSION`. Work from before this changelog existed (versions 00.01.00–00.01.05: Phases 1–6 and the web link) is logged in `docs/PROGRESS.md`.

## Version 00.02.66
Date: 10/31/2026
Time: 2:44 PM

### Changes
- **Pack 2, the Land Between the Rivers, is built and open** (`docs/PACK_2_PLAN.md`). Beat Apep (the Two Lands' 30:00 boss) to unlock it. With it, all four Pack 2 levels and all three new Heroes are in the game.
  - **The land:** flood plains of reeds and dry, cracked earth; date palms, Euphrates poplars and cedars; ruined mud-brick ziggurats and carved boundary stones (kudurru); herons, ibises, onagers and wild boar.
  - **Floods** (the hazard): the water rises in long bands across the plain. Wading through slows you and puts out burning (on monsters too).
  - **Monsters:** scorpion-men with bows (Gilgamesh IX), lion-headed ugallu, whirling raging storms (umu dabrutu) and river serpents (all among Tiamat's brood in the Enuma Elish).
  - **Bosses:**
    - **Humbaba** (10:00): seven radiances (golden rings) take every hit until they are stripped one by one. Wind strips them twice as fast; a Guard Break or Shamash's summon tears one away (Gilgamesh II-V). He has words for Gilgamesh.
    - **The Bull of Heaven** (20:00): every few seconds his snort cracks pits open round you. They stay for the whole fight, hurting and slowing anyone standing in them (Gilgamesh VI).
    - **Tiamat** (30:00, an original design, never the five-headed dragon of modern games): she brings forth her brood of monsters, and waves of the salt sea roll across the arena, pushing and hurting you (Enuma Elish).
  - **Gods** (both found at peaceful shrines):
    - **Enki** (Water): summon **Waters of the Abzu** heals every Hero 30% and Soaks every monster on screen.
    - **Shamash** (Holy): summon **Thirteen Winds** pins every monster on screen for 4 s and strikes them, and tears away one of Humbaba's radiances.
  - **New Hero: Gilgamesh** (King-warrior; HP 140, Speed 90, Armor 2), drawn from the epic and the ancient reliefs, never from Fate/Grand Order. Signature weapon: the **great axe**. Legend Trait **Enkidu**: his friend fights beside him, running out to strike the nearest monster and everything round it; monsters can't harm him. Passive **Two-thirds divine**: +10% Max HP and Might. Unlock: defeat Humbaba.
- A "Defeat ..." achievement for each of the twelve Pack 2 bosses, like Pack 1's.
- New throne style for Mesopotamian gods, a stepped mud-brick shrine altar, and the eight-pointed star of Shamash on the chest seal.
- Fixes for Avalon's Shadow: the Welsh gods' pantheon now reads "Welsh" (it showed a raw text key), and its Ancient Ruins use standing stones.
- Brambles and floods now only release a slow they caused themselves, so they never cancel a boss's slowing zone.
- 5 new tests (292 tests pass).

### Reason
The owner asked to finish Pack 2 ("okay lets finnish the pack"). This is its fourth and last level, built from the approved plan. Still open from the plan: new Resonance pairs and Banter lines, to talk through with the owner first.

## Version 00.02.65
Date: 10/31/2026
Time: 2:28 PM

### Changes
- **Pack 2, Avalon's Shadow, is built and open** (`docs/PACK_2_PLAN.md`). Beat Balor (the Misty Isles' 30:00 boss) to unlock it.
  - **The land:** green fields and dark woods with ruined castles, old stones and a misty lake.
  - **Enchanted brambles** (the hazard): thorny shoots creep out across the ground, then a bramble thicket springs up and slows any Hero caught in it (to 40% speed) for 7 s before it withers.
  - **Monsters:** black knights on horseback (Malory), enchanted hounds (Pwyll), the afanc lake beast (Welsh tradition), and will-o'-the-wisps (British folklore).
  - **Bosses:**
    - **The Green Knight** (10:00): the beheading game (Sir Gawain and the Green Knight). The first time he is "slain" he picks up his head, comes back at half health and attacks faster, once.
    - **Mordred** (20:00): five black knights ride out round him at the start of each phase, and while any of them live he takes half damage (a dark ring shows it). He has words for King Arthur (Malory).
    - **Twrch Trwyth** (30:00): the great boar charges with his young boars (Culhwch and Olwen). Each Guard Break knocks loose one of the three treasures between his ears (the comb, the razor and the shears), which drops a chest and gold.
  - **Gods:**
    - **Rhiannon** (Wind): her shrine can't be caught by running; stand still beside it to bind her, as Pwyll had to ask her to stop. Summon **Birds of Rhiannon**: their song puts every monster on screen to sleep for 3 s (bosses are only slowed).
    - **Arawn** (Dark, a duel trial): summon **Hounds of Annwn**: five white, red-eared hounds run out and hunt monsters for you for 7 s, then go back to the Otherworld.
- New tests for the four new boss and hazard rules (287 tests pass).

### Reason
The owner asked to finish Pack 2 ("okay lets finnish the pack"). Avalon's Shadow is the third of its four levels, built from the approved plan.

## Version 00.02.64
Date: 10/31/2026
Time: 2:17 PM

### Changes
- **Roads lead from the start to the mountains.** Each mountain now also has a long trail from its first way up, winding all the way back to where the run begins and ending just off the Hero at the start. A run starts with a few trails leaving the starting area, each leading to a mountain. Its other roads still wander out round it as before. New settings `world.road_trail_end_px` (130) and `world.road_trail_max_px`. The long trails fade only at their very end, so you can see them from the start.
- Trees now check only the clear zones near them (filed in a coarse grid), so the many zones along the long trails cost nothing extra.

### Reason
The owner said the mountains are hard to find and asked for the road to the mountain to come closer to where the run starts.

## Version 00.02.63
Date: 10/31/2026
Time: 2:12 PM

### Changes
- **Pack 2, Jotunheim, is built and open** (`docs/PACK_2_PLAN.md`). Beat Surtr (Midgard's Edge's 30:00 boss) to unlock it.
  - **The land:** glacier ice, bare rock and snow under a cold light; spruce, pine and dead trees; snow drifts; runestones and giant-sized stone steps; frozen ponds you slide on.
  - **Rockslides** (the hazard): a boulder's shadow grows, it crashes down, and rubble settles.
  - **Monsters:** frost giants and their casters, giant wolves, trolls, and the new **mountain giants** (*bergrisar*, Gylfaginning 42), who hurl boulders.
  - **Bosses:**
    - **Hrungnir** (10:00): the stone giant with a three-cornered stone heart, a slab shield and a whetstone (Skáldskaparmál 17). He shrugs off most harm until Lightning cracks the stone; a Guard Break cracks it too, so any Hero can win.
    - **Thrym** (20:00): the frost-giant lord with golden dog-collars (Þrymskviða). He steals one of your weapons for 20 s and drops it in his golden hoard; reach the hoard to take it back.
    - **Ymir** (30:00): the first giant, made of rime (Gylfaginning 5–6). He splits into three frost shapes and only the real one casts a shadow; his "Endless Winter" freezes the ground except for safe circles.
  - **Gods:**
    - **Odin** (Wind, rare): binding him is a sacrifice of 30% of your Max HP, for +20% crit chance and +15% Wind damage. Summon **Gungnir**: the spear that never misses strikes the strongest enemies on screen, and his ravens mark them to take more damage.
    - **Freyja** (Holy, Chase trial): +15% Max HP and a slow heal. Summon **Falcon Cloak**: you fly unharmed for a moment, and the monsters you slay rise to fight for you.
  - **Beowulf** (Geatish; HP 135, Speed 95, Armor 1), in a mail shirt and boar-crested helmet (Beowulf 303–306):
    - Weapon: heavy blows with his bare hands, and at level 8 the **giant-made sword** from Grendel's mother's hall.
    - Legend Trait, **Grip:** every 9 s he seizes a monster (an elite first, never a boss) and hurls it. It takes double damage, and everything where it lands is hit.
    - Passive, **the strength of thirty men:** +50% knockback.
    - Unlock: defeat 100 giants and trolls in Jotunheim in one run.
- Tests for each boss and Beowulf. Jotunheim passes every full-level check, including a playthrough of its bosses.

### Reason
The owner asked to finish Pack 2. Jotunheim is level 2 of 4.

## Version 00.02.62
Date: 10/31/2026
Time: 2:05 PM

### Changes
- **Groundwork for the rest of Pack 2** (no change to how the game plays):
  - Charming a monster is now shared by the whole game (Orpheus' song uses it, and the gods of the next levels will). A charmed monster does no harm to Heroes and turns on the monsters next to it. New settings `enemies.charm_strike_*`.
  - Each run counts kills by monster family, and achievements can ask for kills of certain families on a certain level (Beowulf's unlock).
  - A weapon can change its picture at a set level (Beowulf's bare hands become the giant-made sword).
  - A Hero can hit with more knockback (Beowulf's passive).

### Reason
The owner asked to finish Pack 2. These shared pieces come first, then Jotunheim, Avalon's Shadow and the Land Between the Rivers, one at a time.

## Version 00.02.61
Date: 10/31/2026
Time: 2:01 PM

### Changes
- **Show FPS (a setting).** Settings → Gameplay → "Show FPS" (off by default). When it's on, the frames per second show above the timer in the top bar, the pair centred like Kills and Alive.
- **Smoother with lots of monsters.** Measured first: with 450 monsters spread out like a real run, the monsters' work each frame went from about 7.3 ms to about 3.8 ms.
  - **Far-off monsters do less:** monsters more than about a screen from every Hero (off screen, `performance.lod_far_px`) move on every other frame, twice as far each time, so they keep their speed. They aren't pushed apart from each other until they come near. Monsters on screen move every frame as before.
  - **Drawing monsters** no longer looks up settings by name for every monster every frame; they're read once per frame.
- Tests unchanged and passing.

### Reason
The owner asked for an FPS display as a setting, above the timer, centred, and for anything that can be done to start preventing the frame-rate drop with many monsters.

## Version 00.02.60
Date: 10/31/2026
Time: 1:51 PM

### Changes
- **"Alive" counter on the HUD.** Under "Kills" in the top bar, in slightly smaller text: how many monsters are alive in the world right now (large animals and bosses count too). Kills moved up a little so the pair sits centred in the bar. New setting `ui.hud_alive_scale`.

### Reason
The owner's friend sees the frame rate drop when lots of monsters are on screen. The owner asked for a counter of monsters alive under Kills, with Kills moved up so everything stays centred, to track how the number alive affects the frame rate.

## Version 00.02.59
Date: 10/31/2026
Time: 1:50 PM

### Changes
- **Orpheus, and the Underworld is open.** The last step of the Underworld (`docs/PACK_2_PLAN.md`). "Coming soon" is gone: beat Kronos on the Aegean Shore and the Underworld can be played.
  - **Orpheus** (Greek, Song-bard; HP 95, Speed 100, Armor 0): the singer of Thrace, in a laurel wreath, pale chiton and blue mantle (Ovid, *Metamorphoses* 10–11; Virgil, *Georgics* 4; Attic vase painting).
    - **Lyre of Orpheus:** his signature weapon, the tortoise-shell lyre of the Hymn to Hermes. Rings of music pulse out round him (Wind).
    - **Legend Trait, Charming Song:** every 12 s his song charms up to 10 monsters round him for 3.5 s (not bosses). They do no harm to Heroes and turn on the monsters near them; a note bobs over each one. The HUD shows when the next song comes.
    - **Passive, Outsinging the Sirens:** +10% attack speed for him and for allies near him in co-op (he drowned out the Sirens, *Argonautica* 4).
    - **Unlock:** the new achievement "Survive 20:00 in the Underworld".
  - Hecate and Persephone now appear at shrines too.
- Tests for Orpheus. The Underworld now passes every full-level check, including a playthrough of all three bosses.

### Reason
The owner said "let's move on, it looks okay": finishing the Underworld with Orpheus and releasing it.

## Version 00.02.58
Date: 10/31/2026
Time: 1:40 PM

### Changes
- **Quieter by default:** the default volume is now 70% (was 80%). Players who already changed their volume keep their own setting.
- **A softer pickup sound.** The pickup blip used to climb more than two octaves (to about 3,000 Hz) during a quick run of pickups, which is what made it ear-piercing. Now it:
  - starts lower (520 Hz, was 660);
  - climbs at most one octave, more slowly (still on the same pleasant five-note scale);
  - plays a little quieter (−16 dB, was −12).

### Reason
The owner said the pickup sound is ear-piercing and asked for the sound to be turned down 10% by default.

## Version 00.02.57
Date: 10/31/2026
Time: 1:39 PM

### Changes
- **Roads to the mountains.** Every mountain now has winding roads leading to it: one from the foot of each way up from the ground (the handholds and the rope-ladder spot), wandering out across the land for one to two screens and fading into the ground at the far end. Come across a road and follow it, and it takes you to the mountain.
  - Randomly generated from the run's seed, like the mountains, so every co-op player sees the same roads.
  - No trees grow on them.
  - Each land has its own road: a dusty track on the Aegean Shore, packed earth in Midgard's Edge, sand in the Two Lands, mud in the Misty Isles, ash in the Underworld. Darker edges, worn ruts and stones along the sides.
  - New settings `world.road_*`, and a "road" colour per level.

### Reason
The owner asked for a randomly generated road or path in the map that leads to the mountains.

## Version 00.02.56
Date: 10/31/2026
Time: 1:33 PM

### Changes
- **The Underworld's gods, Hecate and Persephone** (step 5 of `docs/PACK_2_PLAN.md`; the level is still "Coming soon").
  - **Hecate** (Dark, Control, uncommon, peaceful shrine): a dark-robed goddess with two torches (Hymn to Demeter; Greek vases).
    - Blessing: +15% Dark damage, and your hits Hex enemies. Meter: kills.
    - Summon, **Three Ways:** three crossroads portals open round you, ringed with torch flames, and fling enemies away, Hexed.
  - **Persephone** (Earth, Sustain, uncommon, Endurance trial): a crowned queen with a pomegranate and wheat (Hymn to Demeter; the Locri reliefs).
    - Blessing: +10% Max HP and a slow heal. Meter: damage taken.
    - Summon, **Return of Spring:** heals half your HP, and flowers bloom round you that root the enemies in them.
  - Myths and sources in the Pantheon Compendium; both sit on the Greek shrine throne.
- Gods from a level that's still "Coming soon" don't appear at shrines yet.
- Art by `tools/art/build_gods_underworld.py`.

### Reason
Building Pack 2, approved by the owner: the Underworld, one part at a time.

## Version 00.02.55
Date: 10/31/2026
Time: 1:30 PM

### Changes
- **The Underworld's three bosses** (step 4 of `docs/PACK_2_PLAN.md`; the level is still "Coming soon"). Each is about 20% tougher than the Pack 1 boss at the same time.
  - **Cerberus (10:00):** the three-headed hound of Hades, with a serpent's tail and snakes along his back (Apollodorus 2.5.12). Each head has its own attack: the fire head's fan of flames, the biting head's lunge, the howling head's call to the shades. Each phase one head falls ("One of Cerberus' heads falls!"), his picture loses it, and its attack goes with it, until only the biting head is left, lunging faster.
  - **Thanatos (20:00):** Death himself, grey-bearded, black-robed and winged, with a sword (Euripides' *Alcestis*; the Sarpedon vase). He marks a Hero for death with a 10-second countdown over their head. Hit him hard enough before it runs out and the mark breaks (a pale ring shows how close); if not, it takes half your Max HP. **Heracles** breaks it twice as easily and gets his own line, since in the myth he wrestled Death and won. The dead rise to fight for him in phase 2.
  - **Typhon (30:00):** a towering giant with a serpent's body below the waist, dark wings, and serpent heads from his shoulders (Hesiod, *Theogony*; Apollodorus 1.6.3). Serpent heads rear up all round the arena edge and fire volleys inward, more of them each phase. From phase 2 his storms sweep everyone round the arena, turning the other way each phase. Plus the "Fire of the Hundred Heads" cast.
  - Myths and sources in the Bestiary. Art by `tools/art/build_bosses_underworld.py`.
- Bosses can change their picture during a fight (used by Cerberus). Tests for all three bosses.

### Reason
Building Pack 2, approved by the owner: the Underworld, one part at a time.

## Version 00.02.54
Date: 10/31/2026
Time: 1:24 PM

### Changes
- **The Underworld's monsters and wave table** (step 3 of `docs/PACK_2_PLAN.md`; the level is still "Coming soon").
  - **Furies-kin:** dark-robed winged huntresses with snakes in their hair (the Erinyes of Aeschylus' *Eumenides*, as Greek vases paint them; none of the three named Furies). A fast swarm, and hunters that sweep across the screen.
  - **Skeletal hoplites:** the armed dead of the *Odyssey*, book 11, as bones in a crested bronze Corinthian helmet with a round shield and spear. A walking soldier, and a slow, heavily armoured shield-bearer from 10:00.
  - **Stymphalian birds:** crane-sized marsh birds with straight bronze beaks (Pausanias 8.22). Flocks, and from 6:00 birds that shoot their bronze feathers like arrows (Apollonius, *Argonautica* 2).
  - **Shades** (already in the game) drift in the air, and a ring of them closes in from 20:00.
  - Each has its myth and source in the Bestiary. The elites are the Greek ones (Minotaur, Gorgon, Cyclops).
- Art built by the new `tools/art/build_enemies_underworld.py`.

### Reason
Building Pack 2, approved by the owner: the Underworld, one part at a time.

## Version 00.02.53
Date: 10/31/2026
Time: 1:20 PM

### Changes
- **Pack 2, the Underworld: the level and its hazards** (steps 1–2 of `docs/PACK_2_PLAN.md`). It's marked **"Coming soon"** in level select until its monsters, bosses, gods and Orpheus are built, so nobody plays a half-made level.
  - **Level select** now has a heading for each pack: "Pack 1: Legends of the West", "Pack 2: Deeper Myths".
  - **Unlocks:** beating Kronos (the Aegean Shore's 30:00 boss) opens the Underworld, and it says so: "Locked: defeat Kronos on the Aegean Shore". Pack 1's old rule (the 20:00 boss opens the rest of the pack) now applies to Pack 1 only.
  - **Pack 2 is harder:** enemy HP +20%, spawns +15%, enemy damage +10% (setting `enemies.pack_difficulty`).
  - **The look:**
    - Ground: a grey asphodel meadow, ash, dark rock, and cracked rock with ember seams.
    - A gloomy grey-violet light over everything (new level setting "tint").
    - Trees and plants: black poplars, willows, cypress and dead trees; asphodel and pomegranate bushes; basalt rocks.
    - Scenery: Greek grave steles and lekythoi.
    - Animals: bats, owls, grey lizards, moths, and the black cattle of Hades. Large animals can now belong to particular levels.
  - **Hazards:**
    - **Rivers of the dead:** long black pools that slow you and slowly drain HP (never below 1).
    - **The chasms open:** cracks glow and spread, then the ground collapses into a dark pit that closes again.
- Tests for the unlocks, "coming soon" and the Pack 2 difficulty. Art rules for the Underworld.

### Reason
Building Pack 2, approved by the owner: the Underworld first, one part at a time.

## Version 00.02.52
Date: 10/31/2026
Time: 1:11 PM

### Changes
- **Pack 2 approved.** `docs/PACK_2_PLAN.md` is marked approved, with the owner's answers:
  - The Hero unlocks are as suggested.
  - Pack 2 is harder: enemy HP +20%, spawns +15%, enemy damage +10%.
  - Two monsters had no source, so they're replaced with real ones from the myths:
    - Jotunheim's "ice wisps" become the mountain giants (*bergrisar*, Prose Edda).
    - The Rivers' "dust demons" become the raging storms (*umū dabrūtu*, Enuma Elish).
- GAME_DESIGN.md (Pack roadmap and the Act II table) and docs/DECISIONS.md are updated with dated notes.
- The Underworld is next.

### Reason
The owner approved the Pack 2 plan ("plan looks great"), liked the Hero unlocks, let Claude name the two unsourced monsters, and asked for Pack 2 to be harder by Claude's judgement.

## Version 00.02.51
Date: 10/31/2026
Time: 1:05 PM

### Changes
- **Pack 2 plan written for the owner to approve:** `docs/PACK_2_PLAN.md` ("Deeper Myths").
  - The four levels, each with its look, hazard, 4 monster families, 3 bosses and 2 local gods, all from the existing design with sources.
  - Unlocks from each sister Pack 1 level.
  - The three new Heroes (Orpheus, Beowulf, Gilgamesh), with suggested stats, kits and unlocks.
  - The build order, and the questions for the owner.
- No game changes yet.

### Reason
The owner's friend has been testing Pack 1 and having a lot of fun, so the owner decided it's time to add more packs. The owner chose: one level at a time; each level unlocks from its sister Pack 1 level; new Heroes Orpheus, Gilgamesh and Beowulf; and the plan written first.

## Version 00.02.50
Date: 10/31/2026
Time: 12:53 PM

### Changes
- **Bow Heroes scaled down a little** (Atalanta, Odysseus, Tomoe Gozen):
  - **A fan of arrows:** their bows shoot one more arrow at every level, so 2 to start, spread in a fan (Huntress's Bow 20°, Great Bow 18°, Tomoe's arrows 22°).
  - **Less damage:** each arrow deals about 45% of the old damage. A single enemy usually takes one arrow of the fan, so single targets take about half the damage; crowds take about the same as before. Examples at level 1: Huntress's Bow 13 → 6 per arrow, Great Bow 26 → 12, Tomoe's arrows 11 → 5.
  - **+1 Armor:** Atalanta 0 → 1, Tomoe Gozen 0 → 1, Odysseus 1 → 2.
  - **Tomoe's sword keeps its full damage:** only her arrows changed. Weapons can now give arrows their own damage (`arrow_damage`).
- GAME_DESIGN.md: the Hero table shows the new Armor, with a dated note.

### Reason
The owner asked for the ranged characters to be scaled a little: less damage, another arrow (2 with the bow in a fan), and 1 more point of Armor, for all three bow Heroes.

## Version 00.02.49
Date: 10/31/2026
Time: 12:49 PM

### Changes
- **Buy rerolls when you level up.** The level-up screen always has a Reroll button now.
  - Each Hero gets **1 free reroll** at the start of a run and **1 more every 5 levels** ("Reroll (free: 1)").
  - After the free ones and any reroll tokens (from the Wandering Trader or found), you **buy** one with run gold: **25**, doubling each time you buy one in the same run (25, 50, 100, 200…). The button shows the price and is greyed when you can't afford it.
  - **Co-op:** each player gets their own Reroll button on their turn, with their own free rerolls, paying from their own share of the gold. Their turn's timer keeps running.
  - A run taken over on another device keeps its free rerolls and prices.
- New settings `level_up.free_rerolls_start`, `free_reroll_every_levels`, `reroll_price`, `reroll_price_mult`. GAME_DESIGN.md has a dated note.

### Reason
The owner asked for a way to buy rerolls when you level up: a price that rises with each purchase, 1 free reroll and another every 5 levels, and co-op players each paying with their own gold.

## Version 00.02.48
Date: 10/31/2026
Time: 12:45 PM

### Changes
- **Fixed the Bladed Discus's unlock text.** Unlocks showed "Earn the achievement “ACH_TRIGGER_4_RESONANCES_NAME”" because the weapon pointed to an achievement id that doesn't exist (`trigger_4_resonances`). It now points to the real one, `resonances_4`, and reads "Earn the achievement “Trigger 4 different Resonances”". The unlock itself always worked: that achievement's reward gives the weapon.
- Unlocks and Hero select now look an achievement's name up from `achievements.json` instead of building its key.
- A new test checks that every weapon and Hero unlocked by an achievement names a real one.

### Reason
The owner spotted the raw text on the Unlocks page and asked what it was.

## Version 00.02.47
Date: 10/31/2026
Time: 12:36 PM

### Changes
- **A more professional leaderboard.** It's now a ranked table in the menus' frame over the painted backdrop, instead of plain text on a dark screen.
  - Column headings: #, Player, Weapons, Time, Level, Kills.
  - The top three ranks are marked in gold, silver and bronze.
  - Each row has the Hero's portrait, the player's name with their Hero under it, and the weapons' icons (on wider screens). Time, level and kills sit in lined-up columns.
  - Your own runs are lit gold.
  - Tapping a row (or pressing Enter on it) opens that run's whole build: weapons and upgrades with their levels, and the game version it was played on.
  - Refresh and Back are in the top bar.
- New settings `leaderboard.column_px`, `weapons_from_px`, `medal_colors`, `portrait_px`, `weapon_icon_px`.

### Reason
The owner asked for the leaderboard to look more professional too.

## Version 00.02.46
Date: 10/31/2026
Time: 12:34 PM

### Changes
- **The first sign-in asks about this device's progress.** The first time a device signs in with Google (or links with a sync code), if it has any progress, it asks: "This device has progress: 157 gold, 2 Heroes unlocked, 14 achievements. Bring it into your account?"
  - **Yes, bring it:** combined with the account's progress. Unlocks from both are kept; gold is the higher of the two, never both added.
  - **No, use my account's:** the device switches to the account's progress. Its own is kept aside in a file (`save.put_aside_file`), not deleted.
  - It's asked only once per device. Later sign-ins combine as before. A device with nothing earned isn't asked.
- **Start over.** Settings → Start over… deletes all progress (gold, unlocked Heroes and weapons, gods' levels, records, achievements, Bestiary, Codex and the rest) after a clear warning. Cancel is chosen by default. Settings and username stay, and first-run tips show again. It can't be used during a run. With cloud saves on, the reset wins on every device: older progress elsewhere never comes back (the save now records when it was reset, `reset_at`). Scores already on the online leaderboard stay there.
- Tests for both.

### Reason
The owner asked for the game to ask, on the first sign-in only, whether to take this device's data, and for a way to reset your data and start over from nothing.

## Version 00.02.45
Date: 10/31/2026
Time: 12:28 PM

### Changes
- **The rest of the menus in the new layout** (after the owner approved the mock-ups):
  - **List + detail:** the Pantheon Compendium (gods by pantheon, then Resonances and Words of Legend) and the Hall of Heroes.
  - **Cards:**
    - Unlocks: Heroes, weapons and cosmetics with pictures; a price button, how to earn it, or "Unlocked".
    - Omens: an On/Off button and the gold bonus.
    - Achievements and secrets: earned ones first, marked "Earned".
    - The Oracle's hints.
    - Level select: best time, bosses beaten and local gods, a Play button, and Swift Mode beside it.
  - **Codex** is now a page inside the Hall: evolutions with the evolved weapon's picture (unfound ones as dark shapes with a hint), then infusions and Resonances.
  - **Settings** are grouped under headings (Sound and text, Effects, Gameplay, Touch controls, More), with each setting's name on the left and its value on a button on the right.
  - **Co-op and Account:** explanations are in softer, smaller text, so the buttons stand out.
  - Anything not met or unlocked yet shows as a dark shape.

### Reason
The owner liked the mock-ups ("much better") and asked for the rest of the menus to match.

## Version 00.02.44
Date: 10/31/2026
Time: 12:23 PM

### Changes
- **Menus, first pages in the new layout (mock-ups for the owner).**
  - The Hall of Legends has three tabs in its top bar (Progress, Lore, Records) beside Begin a Last Stand. A second row picks the page, which opens inside the Hall. The Hall remembers the tab you were on, and the gold shows in the corner.
  - Offerings shows each god as a card: picture, name and level, pantheon and role, what the next level gives, and a price button. Gods not met yet are a dark shape with "???".
  - The Bestiary is a list with a detail panel: pictures and names on the left; the chosen creature's big picture, times defeated, weaknesses, and myth with its source on the right. It also counts how many have been found.
- Shared building blocks for the rest of the menus: wider pages, tabs, item cards, list + detail. New `ui.menu_*` settings for their sizes and colours. Text in them follows the Text size setting.

### Reason
The owner liked how the menus look but wanted the information on them to look better. The owner chose list + detail for reading pages, three tabs for the Hall, item cards for shop pages, and mock-ups first.

## Version 00.02.43
Date: 10/31/2026
Time: 12:05 PM

### Changes
- **Take over a run on another device.** While you're playing a solo run (on a PC, say), opening the game on another device signed in to the same account (a phone) asks: "You have a game in progress on another device (Heracles, 12:30, Aegean Shore). Take it over?" Take it over, and the run carries on there with the whole build: level, time, Hero level and XP, weapons, passives, stats, gods and their meters, gold, tokens, ropes, the shrines and chests already used, and bosses already beaten. The fight that was on screen starts fresh. The first device steps aside to the title with a message ("Continued on another device") and banks nothing, so nothing is lost or paid out twice. "Not now" leaves it alone and doesn't ask again for that run.
- **Still a roguelike: no saving for later.** The snapshot only goes with a run that's still being played. Leaving or closing a run ends it as before, and a run whose device stopped playing can't be taken over. Co-op games can't be taken over.
- While playing, the game now tells the cloud it's still playing every 15 seconds (was 30), sending the run's snapshot with it (new setting `meta.play_beat_s`).
- Cloud server (`leaderboard-api/src/cloud.js`): `/cloud/play` takes the snapshot with each beat and has two new actions, `peek` and `takeover`; the device that was taken over hears so on its next beat. New tests.
- Bosses remember which ones were beaten, so a taken-over run doesn't bring them back.

### Reason
The owner asked for a way to take over a game in progress from another device (for example, from a PC to a phone), with the whole build carried over, the first device stepping aside, and the question asked when the game opens. The owner also said: it's a roguelike, so leaving a game ends it and there's no saving for later.

## Version 00.02.42
Date: 10/31/2026
Time: 12:01 PM

### Changes
- **No half a Hero at the edge of the title screen.** On narrow screens (phones) the backdrop is cropped at the sides, which could leave the last Hero played half off the right edge. They're now kept wholly on screen, and left out when there's no room for them beside the menu buttons.

### Reason
The owner saw part of a character at the edge of the main menu that shouldn't be there.

## Version 00.02.41
Date: 10/31/2026
Time: 11:56 AM

### Changes
- **Some hidden groves are empty.** About 3 in 10 hidden groves now turn out to hold nothing when you step inside: no chest and no guards. The grove with the hidden shrine is never empty.
- New setting `world.grove_empty_chance` (0.3).

### Reason
The owner asked for the clusters of trees to have nothing in them sometimes.

## Version 00.02.40
Date: 10/31/2026
Time: 11:49 AM

### Changes
- **Hero select fits phones.** On phones and small windows (less than 1000 px of room) the Heroes are a scrolling list of portraits and names on the left; tapping one shows their whole card on the right, with a big "Play as …" button under it. Before, the two columns of full cards ran off the right of the screen. On a PC the cards stay as they were, but the panel is never wider than the window.
- New settings `heroes.compact_below_px`, `heroes.compact_list_px`, `heroes.compact_portrait_scale`.

### Reason
The owner said the character screen needs to be fixed for mobile devices.

## Version 00.02.39
Date: 10/31/2026
Time: 11:45 AM

### Changes
- **Debug menu (F1) testing buttons** for the new world: "Go to the nearest mountain" (puts you at the foot of its cliff, by the handholds), "Get a rope", and "Go to the nearest hidden grove" (puts you outside its way in). Test and dev builds only.

### Reason
The owner asked how to find a mountain to test it.

## Version 00.02.38
Date: 10/31/2026
Time: 11:42 AM

### Changes
- **You go in by walking into the door**, not by standing on the building. Every entrance is now solid except its doorway: a shrine's front wall and columns (with the back of the doorway closed), the Ancient Ruins' stone arch, and a mountain cave's mouth block Heroes and walking monsters, like trees do. Going in only starts when you stand in the doorway itself (gods.shrine_door and gods.arch_door say how wide and deep the doorways are); standing beside it, on top of it, or behind it doesn't count.

### Reason
The owner said players have to walk in the door, not over the structure, to go through doors.

## Version 00.02.37
Date: 10/31/2026
Time: 11:32 AM

### Changes
- **Medusa hits harder.** Her shots deal about 50% more in every phase (now 10-18, were 7-12), she attacks every 2.2 s instead of 2.6 s, touching her deals 14 instead of 10, and her petrifying gaze comes every 7 s instead of 8. She stays a little below Achilles (the 20-minute boss) so the Aegean bosses still get harder in order.

### Reason
The owner said Medusa needs to deal more damage.

## Version 00.02.36
Date: 10/31/2026
Time: 11:26 AM

### Changes
- **New menus** (as agreed with the owner, `docs/DECISIONS.md` "Menus"):
  - **Six painted backdrops**: a Greek temple on a cliff at dusk over the wine-dark sea; a Norse longhouse by a fjord under the northern lights; an Egyptian temple gateway and obelisk by the Nile at sunset; a stone circle in moonlit mist; a road over the hills to a stone shrine at dawn; a campfire at night below a lit temple. One is picked at random each time the game loads, never the same one twice in a row.
  - **Matching buttons and panels** for each: marble and gold (Greek and the campfire), wood and iron (Norse), sandstone and lapis (Egyptian), mossy stone (the stone circle and the hill road). Every screen that session uses them, in the menus and in the run.
  - A pixel-art **MYTHRIVEN logo** in carved gold above the title screen's buttons.
  - **Narrow centred buttons** instead of full-width ones, on every menu screen; gold and the version in the bottom corners. Hero select's cards sit in a centred panel over the backdrop.
  - On the title screen your **Heroes walk the road toward the shrine** (or gather round the campfire), and the **Hero you played last stands on the right**.
- New `tools/art/build_menu_art.py`, `scripts/ui/meta/menu_backdrop.gd`; four styles added to `tools/art/build_ui.py`; new `ui.menu_*` and `ui.hero_select_width_px` settings. Rules in `docs/ART_RULES.md` (Menu backdrops and logo).

### Reason
The owner asked to work on the menu as agreed: a logo, a centred column of buttons, random backdrops that never repeat in a row with matching frame styles, Heroes walking toward a shrine and the last-used Hero on the right.

## Version 00.02.35
Date: 10/31/2026
Time: 11:10 AM

### Changes
- **Mountains** (World plan step 5). Now and then raised ground rises from the land, ringed by cliffs nobody can walk through, with two higher peaks, in each land's own rock.
  - **Handholds** cut into a cliff: anyone can climb, slowly.
  - A **rope ladder** rolled at the top of a cliff: hanging it uses a rope, then it's a quick way up for everyone.
  - A **rope bridge** between the two peaks, broken: mending it uses a rope.
  - A **cave** on the far peak: gather at its mouth to go in. Inside is a dungeon of rough rock, stalagmites and glowing crystals, full of the level's monsters, with a ledge at its end. Touch the chest there and you come back out to the mouth, where a big chest and a pile of gold wait. Each cave can be looted once.
- Every Hero has a height (ground, raised ground, peak) and walks only on their own; walking monsters too. Monsters can't climb, so while you're up top some appear up there with you; flyers and bosses go anywhere. Trees keep clear of mountains.
- **Ropes**: buy one from the Wandering Trader (45 gold) or find one in a chest (15%). Your ropes show next to your gold. Without one, the ladder and bridge tell you where to get one.
- Fixed: flat ground pieces (mountain tops) no longer get the "light from above" bands, which made them look like rows of bricks.
- `GAME_DESIGN.md` (World) updated with a dated note (owner decision). New `tools/art/build_mountain_parts.py`, `tools/art/build_cave_parts.py`, `scripts/world/mountains.gd`, `scripts/world/cave_dungeon.gd`; `world.mountain_*`, `world.climb_*`, `world.cave_*`, `chests.rope_chance` and a Trader price for the rope.

### Reason
The owner approved the world plan: mountains to climb with a treasure cave on top, climbing holes, rope ladders and rope bridges, and a rope to buy or find to get through.

## Version 00.02.34
Date: 10/31/2026
Time: 11:02 AM

### Changes
- **Hidden groves** (World plan step 3). Now and then thick forest hides a clearing: a ring of trees too close to pass, roofed over with leaves so it looks like more forest. A few trees in the ring can be walked through (the way in, with two trees standing before it so the path winds), and a faint glint shows there now and then. Step inside and the leaves fade away to show the clearing: a chest (sometimes a big one), guarded by monsters that wake as you come in. Every co-op player has the same groves; what's inside is decided once, when the first Hero steps in.
- **The hidden shrine** (World plan step 4). Rarely, a grove holds a god's shrine instead of a chest (at most one a run). Binding there opens a **third god slot for the rest of the run**: a third god button appears beside the other two (keyboard: F). With three gods bound, a new god asks which to let go, as before.
- New `scripts/world/hidden_groves.gd`; `world.grove_*` settings; a `summon_3` input; Shrines can grant the extra slot; GodManager `max_slots`.

### Reason
The owner approved the world plan: trees you can't walk through unless something is hidden in them, revealing a space when you enter, holding a chest or a hidden shrine that gives a new god slot, and hard to reach.

## Version 00.02.33
Date: 10/31/2026
Time: 10:57 AM

### Changes
- **Wildlife** (World plan step 2). Each land has its own real animals wandering about, only for looks: they can't be hurt, do nothing, and scatter or fly off when you come near.
  - Aegean Shore: hares, wall lizards, tortoises, sparrows, gulls, swallowtail butterflies, cicadas.
  - Midgard's Edge: red squirrels, mountain hares, red foxes, ravens, ptarmigan.
  - The Two Lands: jerboas, desert lizards, sacred ibises, sparrows, butterflies, dragonflies.
  - The Misty Isles: hedgehogs, hares, frogs, wrens, robins, butterflies, and fireflies at night.
- At most 12 are out at once (`world.critters_max`), appearing just off screen and leaving when far away, so they don't slow the game. None during boss fights or in dungeons.
- **Large animals** can be hurt: wild goats and roe deer (Aegean), reindeer and elk (Midgard), gazelles and Nubian ibex (Two Lands), red deer (Misty Isles). They wander, run from you, never hurt anyone, give little XP (0.5) and drop healing far more often (40%). At most 2 at a time. They don't appear in the Bestiary.
- New `tools/art/build_critters.py`, `scripts/world/critters.gd`; a "flee" movement for animals; enemies.json `animal` and `heal_chance`; new `world.critter*` and `world.large_animal*` settings.

### Reason
The owner asked for woodland critters that can't be killed and are only for looks, capped on screen so they don't lag, and larger animals that can be hurt, drop healing more and give less XP.

## Version 00.02.32
Date: 10/31/2026
Time: 10:52 AM

### Changes
- **Forests, rocks and bushes** (World plan step 1, `docs/WORLD_PLAN.md`). Every level now has its own trees, bushes and stone, weathered like the rest of the world: olive, cypress, Aleppo pine and holm oak on the Aegean Shore; snowy spruce, Scots pine and birch in Midgard's Edge; date and doum palms, acacia and sycamore fig in the Two Lands; oak, ash, rowan, yew and hawthorn on the Misty Isles. Trees come in three sizes (two drawings each); there are three bushes per land.
- **Rocks** in four styles (rounded, flat slab, tall jagged, split) and three sizes, often lying in **clusters** of mixed sizes, plus small stones and pebbles. **Sand dunes** in the desert and **snow drifts** in the north.
- **Density:** a smooth map makes open fields, light woods and thick forest across the world (the desert is sparse, the north thick). Thick forest always leaves gaps to get through.
- **Trees and big boulders block** the Hero and walking monsters, who slide round them; ghosts, harpies, spirits, fire sparks and bosses go over. Small stones, dunes and drifts slow you a little; bushes and pebbles you walk over. Weapons and shots pass through trees.
- Trees in front of the Hero fade where they'd hide them; the rest are drawn behind, by depth.
- **No hiding in the woods:** monsters spawn on the side that's open to the Heroes.
- **Kept clear:** the start of the run, boss arenas, shrines and points of interest. Inside a dungeon the forest outside doesn't block anything.
- The old olive tree, pine, reeds and gorse decorations were replaced by the new plants (the ruins, columns, runestones, obelisks and standing stones stay).
- `GAME_DESIGN.md` (World) updated with a dated note (owner decision). New `tools/art/build_flora.py`, `scripts/world/flora.gd`; levels.json `flora` (density and tree weights); enemies.json `flies`; new `world.*` and `enemies.spawn_side_tries` settings. Rules in `docs/ART_RULES.md`.

### Reason
The owner approved the world plan: several kinds of trees, rocks and bushes in different sizes and densities, trees that block, bushes you walk over, rock clusters, dunes and snow drifts.

## Version 00.02.31
Date: 10/31/2026
Time: 10:43 AM

### Changes
- Fixed: the Mirrored Shield and Tyr's Oath level-up cards showed a stray "STAT_NONE +0%" line. Passives that raise no stat now show no stat line.

### Reason
The owner was sent a screenshot of the Mirrored Shield card showing "STAT_NONE +0%".

## Version 00.02.30
Date: 10/31/2026
Time: 10:30 AM

### Changes
- **The whole world now has the shrines' less cartoony look**: all 12 scenery pieces (olive trees, columns, ruins, pines, runestones, longhouses, obelisks, tombs, reeds, standing stones, stone circles, gorse), the Ancient Ruins dungeon parts and its stairway, and the chests are weathered the same way: soft dark edges instead of black outlines, a fine grain, light from above, chips and stains, slightly muted colours. Fire, snow, gorse flowers and the chests' gold keep their brightness.
- The weathering is now one shared tool (`tools/art/weathering.py`) used by the shrine, dungeon, scenery and chest builders, so everything new in the world can get the same look. The shrines come out exactly as before.

### Reason
The owner liked the less cartoony shrine style and asked to finish the world in it before the menu.

## Version 00.02.29
Date: 10/31/2026
Time: 10:23 AM

### Changes
- **Shrines look less cartoony**: all four shrine sets (Greek marble, Norse timber, Egyptian sandstone, Celtic dry-stone) are weathered. The black outlines are now soft dark edges in each part's own colour, the stone and wood have a fine grain, light falls from above (brighter tops, darker feet), there are chips and stains, and the colours are a little less bright. Fire is unchanged.
- The doorway has depth (a little light at the threshold, darker inside, shadowed sides) instead of a flat black box; the wall casts a soft shadow on the paving; the paving's front corners are worn away and its outer stones fade into the ground.
- The menu redesign agreed so far is written down in `docs/DECISIONS.md` (not built yet; still being talked through).

### Reason
The owner asked for the shrine to look less cartoony, and gave their choices for the menu design.

## Version 00.02.28
Date: 10/31/2026
Time: 10:12 AM

### Changes
- **Walking through dungeon doors**: when the party goes in, each Hero walks up into the doorway and fades into the dark. On the ruins' stairway they also go down the steps, sinking out of sight under the stone arch (the arch's front is drawn over them, so they pass under it). Inside, they come up the entry steps out of the darkness. Leaving, they climb up out of the doorway and step away into the world.
- Fixed: coming out of a dungeon, the ground was grey for a moment. The world's ground now stays loaded where you went in.
- New settings `gods.door_walk_s`, `gods.door_depth_px`, `gods.door_step_px`, `gods.door_front_z`, `gods.door_sink_fraction`; the ruins parts gain `entrance_front`.

### Reason
The owner wanted the Heroes to look like they walk through the door instead of just standing behind the structure.

## Version 00.02.27
Date: 10/31/2026
Time: 10:02 AM

### Changes
- **No circles round the dungeon entrances**: the ruins' stairway and the shrines' doorways show just their pictures. A ring appears only while the party stands at one, filling up until they go in, and only on that entrance.
- Fixed: with two shrine entrances on screen, the other one kept resetting the time to go in (the ruins had the same fix in 00.02.26; now it's fixed for both in one place).

### Reason
The owner said the circles aren't needed where there are the new sprites.

## Version 00.02.26
Date: 10/31/2026
Time: 10:00 AM

### Changes
- **The Ancient Ruins are now dungeons.** In the world they're a ruined stone stairway going down. Gather at it (in co-op, everyone standing must be there together) and you go in; the run outside pauses, just like the shrine dungeons.
- **A new set of dungeon pictures** for them, separate from the shrines: cracked and mossy flagstones, broken dark stone walls, snapped pillars, a stone dais, torches, rubble, skulls and bones, broken urns, cobwebs, and small debris scattered along the corridors.
- Inside: a random maze that fills with the level's monsters until you reach the **treasure vault** at the far end, lit by torches. Touching the chest takes you back out and gives the Ruins' gift choice (a weapon or passive level, a heal, or gold) as before.
- Fixed while building it: with two ruins on screen, the farther one kept resetting the gathering timer.
- `GAME_DESIGN.md` (World discoveries; Finding gods) updated with dated notes (owner decision). New `tools/art/build_dungeon_parts.py`, `scripts/world/ruins_dungeon.gd`; the shrine dungeon's end room and its parts can now be swapped. Rules in `docs/ART_RULES.md` (Dungeons).

### Reason
The owner wanted the Ancient Ruins (a ring of columns) to look better and be a dungeon, with a new set of sprites for the dungeon generator.

## Version 00.02.25
Date: 10/31/2026
Time: 9:54 AM

### Changes
- **Every menu and screen has a frame**: panels and buttons are dark stone with a bronze trim, lighting up when you point at or select them, grey when unavailable. This covers the title, Hall of Legends, settings, level-up, chests, boons, the HUD boxes, and every other screen, because it's set once for the whole game.
- **Level-up cards have icons**: the weapon's picture (spells show their flying picture), an icon for every passive (belt, winged sandals, hourglass, eye, lodestone, bronze shield, ferryman's coin, golden apple, bell, polished shield, Tyr's hand), stat cards use the matching passive's icon (crit has its own), gold shows a coin and healing shows ambrosia.
- **Hero select shows each Hero's picture** beside their details. The **title screen** shows your unlocked Heroes standing in a row.
- **God buttons show the god** instead of a letter, and the **banter bubble** shows who is talking instead of a coloured square.
- New `tools/art/build_ui.py`, `scripts/ui/ui_theme.gd`; new settings `ui.frame_scale`, `ui.frame_padding_px`, `ui.icon_px`, `ui.portrait_scale`, `ui.title_hero_scale`, `ui.button_text_color`, `ui.button_hover_text_color`, `ui.button_disabled_text_color`. Rules in `docs/ART_RULES.md` (Menus).

### Reason
The owner chose menu and screen art next (item 3 of the to-do list).

## Version 00.02.24
Date: 10/31/2026
Time: 9:23 AM

### Changes
- **Ground tiles**: every level's ground is now textured pixel art instead of flat colour: paving stones, rock with cracks, earth with pebbles, grass blades, flowers, pine needles, snow drifts with glints, sand and dune ripples, Nile reeds, bog pools and heather. Each type has two versions so it doesn't look like a grid. Made by `tools/art/build_ground.py` from each level's existing colours.
- **Scenery pictures** for all 12 decorations: olive trees, broken columns and marble ruins (Aegean Shore); snowy pines, red-painted runestones and longhouse ruins (Midgard's Edge); obelisks, rock-cut tombs and papyrus (The Two Lands); standing stones, stone circles and gorse (The Misty Isles). Made by `tools/art/build_scenery.py`.
- **Hazards**: the Aegean thunderstorm crackles on its warning spots, then a lightning bolt comes down (also on co-op partners' screens). The blizzard blows snow, the sandstorm blows streaks of sand, and the mist drifts in banks.
- **Ground patches** look like what they are: frozen ponds, quicksand slowly turning, and fairy rings of little mushrooms with rising lights. Gods' ground effects show as thorns or flames.
- **Points of interest**: Ancient Ruins are a ring of the level's own ruins, the Dragon's Hoard is a heap of gold round a gold chest, the Monster's Lair has a dark den with bones, and the Wandering Trader has a market stall with a striped awning.
- New settings `world.weather_particles`, `world.weather_particle_speed_px_s`; levels.json hazards gain `particles` and `particle_color`. Rules in `docs/ART_RULES.md` (Ground, Scenery, Hazards and ground patches, Points of interest).

### Reason
The owner asked to finish the effects: hazards, ground and scenery were the ones left.

## Version 00.02.23
Date: 10/31/2026
Time: 4:18 AM

### Changes
- **Enemy shots** look like their element: a flame tail, a point of ice, crackling sparks, a ripple, a tumbling stone, a black heart, little rays or a curl of wind, each with a short trail. They keep their dark outline so they're always easy to see.
- **Pickups are pictures**: XP gems (blue, green, gold by size), gold coins, ambrosia (a little cup), wooden chests bound with iron, and big chests bound with gold.
- **God summons** in each god's style: Tyche's wheel spins round you throwing coins, Cernunnos' stags gallop across, Thor's hammer spins out and back with lightning, Skadi's ice arrows rain down, Sekhmet's wind scorches across with sand and embers, Poseidon's wave has a foaming crest, Ra's sun barque sails overhead, and the Morrígan's crows sweep across the screen. The two-god Resonances got matching effects too (heat and blizzard waves, a frozen wave, rain with lightning jumping between soaked enemies, a blazing sun).
- **Boss special attacks**: gathering sparks before a burst, sweeps with arrows showing their direction, dashed charge lines with arrowheads, closing rings on strike spots. Medusa's victims stand as stone statues and her eyes blaze, Kronos' slowed time is a clock face, Fenrir is bound by wooden posts and chain links, Balor has standing stones and a glowing eye beam, Set's whirlwinds carry sand, Surtr's ring has flames all round, Ferdiad's ford flows, and Achilles burns with rage.
- **Hero trait effects**: Cú Chulainn really leaps (rises and falls, shadow underneath, dust on landing); Väinämöinen's verses circle him as lights; Tomoe Gozen kicks up dust and speed lines; Achilles glints gold when his front blocks and flashes red when hit in the heel; Arthur's shield wall is a proper shield; Atalanta races to a stone post for a golden apple; Odysseus' traps are staked pits and his decoy is himself disguised as a beggar; Heracles flashes when a Labor is done; Scáthach glints when a lesson levels a weapon.
- New pictures from `tools/art/build_pickups.py` and `tools/art/build_summons.py`. New settings `enemies.shot_trail_steps`, `chests.art_scale`, `heroes.leap_height_px`, `heroes.verse_color`, `heroes.dust_color`, `heroes.heel_guard_color`, `heroes.heel_hit_color`, `heroes.labor_ring_px`, `heroes.decoy_tint`. Pickup sizes changed to picture heights (`xp.orb_size_px`, `pickups.gold_size_px`, `pickups.ambrosia_size_px`). Removed `chests.color` and `chests.trim_color`. Rules in `docs/ART_RULES.md`.

### Reason
The owner asked for enemy shots, god summons, boss special attacks, hero trait effects and pickups.

## Version 00.02.22
Date: 10/31/2026
Time: 4:02 AM

### Changes
- **Spell hits burst in their element's style**: fire puffs with flying embers, ice shatters into shards, lightning crackles, water splashes, wind curls, holy light flashes as a star, dark shadow collapses inward, earth throws up pebbles and dust, fortune glints gold. Every non-physical hit (spells and infused weapons) shows one; evolved spells' bursts are bigger.
- **Statuses show on enemies**: flames (Burn), frost specks (Chill), a block of ice (Frozen), sparks (Shock), drips (Soaked), green bubbles (Poison), a halo (Smite), a dark swirl (Hex), circling stars (Stun). Only for enemies on screen, at most 120 at once. The status colour now tints enemy pictures more lightly so you can still see the monster.
- **Reactions have their own effects**: Conduct sends lightning arcing out, Steam Burst billows clouds, Shatter throws ice shards, Spread blows a gust, each with a white flash in the middle.
- **Evolved spells look different**: Inferno is a great white-hot fireball, Absolute Zero a spinning snowflake, Cyclone a big whirl of wind, Judgment a blazing star. Tempest's bolts are thicker with forks; Oblivion leaves a dark pool under twice the wisps.
- New settings `effects.burst_px`, `effects.burst_s`, `effects.reaction_s`, `enemies.art_status_tint`, `enemies.status_marks_max`, `enemies.status_marks_margin_px`. Rules in `docs/ART_RULES.md` (Spells, Statuses).

### Reason
The owner asked for all four spell-effect pieces: hit bursts per element, status visuals on enemies, reaction effects, and evolved spells that look distinct.

## Version 00.02.21
Date: 10/31/2026
Time: 3:51 AM

### Changes
- **Monsters spawn inside the shrine dungeons** until you reach the god: every 2.5 s, 3 of the level's ordinary monsters (no elites, bosses, flyers or bombers) appear in the corridors 5-12 tiles from the party, up to 18 at once. The walls stop them as they do you. As soon as someone steps into the god's throne room, the rest vanish and no more come.
- **Nothing spawns outside while you're inside**, and the enemies already outside wait where they are (they sleep), then carry on when you come out. Enemy shots, pickups and XP keep working inside so you can fight and collect. The clock still stops while you're inside.
- Monsters left in the dungeon when you leave are removed.
- `GAME_DESIGN.md` (Finding gods) updated with a dated note (owner decision). New settings `gods.dungeon_first_spawn_s`, `gods.dungeon_spawn_every_s`, `gods.dungeon_spawn_count`, `gods.dungeon_max_enemies`, `gods.dungeon_spawn_min_tiles`, `gods.dungeon_spawn_max_tiles`.

### Reason
The owner said that while you're inside, enemies should stop spawning outside and spawn inside until you make it to the shrine with the god.

## Version 00.02.20
Date: 10/31/2026
Time: 3:48 AM

### Changes
- **Shrines are now dungeon entrances.** In the world a shrine is an entrance in its people's style (a wall with a dark doorway, columns, fire bowls). Standing in the doorway for 1.5 s takes the party inside; in co-op every standing player must be in the doorway together or it can't start.
- **While you're inside, the run outside pauses:** the clock, enemies, spawns, enemy shots, hazards, bosses, pickups and the Unraveling all stop, and start again when you come out.
- **The dungeon is built at random** from the same parts: different sizes, sometimes a twisting maze, sometimes wide halls with loops. There are **no monsters** inside. The walls block you. The corridors lead to the **god's throne room** at the far end (a little bigger than before: 9-13 cells wide, 6-8 deep), where the god sits on their throne or walks about inside.
- **At the altar** a peaceful god binds after 2 s, and the party is **warped back out** to where they went in. For a trial god, reaching the altar warps you out and starts the trial at the shrine. Walking back out of the entrance also leaves.
- Co-op: joining players go in and out with the host and see the same dungeon (built from the shrine's shared seed).
- `GAME_DESIGN.md` (Finding gods) and `docs/ART_RULES.md` updated. New settings `gods.dungeon_gather_s`, `gods.dungeon_offset_px`, `gods.dungeon_dark_color`, `gods.dungeon_floor_tint`. A new test checks 30 dungeons: the same seed builds the same dungeon, they vary in size, and the way through always reaches the god's altar.

### Reason
The owner asked for bigger shrines, made like a dungeon with the shrine at the end, warping you out once the shrine is unlocked, with no monsters in the shrine with the god; the run pauses inside (in co-op all party members have to go in together), and the dungeon is random, sometimes maze-like.

## Version 00.02.19
Date: 10/31/2026
Time: 3:38 AM

### Changes
- **Shrines are built at random from building parts.** Each god's shrine is now a small temple of their people, laid out differently every time round the altar you walk to:
  - Parts for four peoples (`data/art/shrines/`, built by `tools/art/build_shrine_parts.py`): a Greek marble temple (slab floors, walls with a gold band, Doric columns, a marble altar, an amphora); a Norse timber hall (plank floors, plank walls with a turf cap, carved posts, a stone hörgr altar, a painted shield); an Egyptian sandstone temple (painted walls, papyrus columns, an altar with a lotus offering, a small gilded obelisk); a Celtic drystone enclosure (grass and flagstones, spiral-carved standing stones, a slab altar, a cauldron). Each has fire bowls.
  - The layout (`scripts/gods/shrine_layout.gd`): 7, 9 or 11 cells wide and 5-7 deep; walls on three sides; an entrance in the front wall (1 or 3 wide, sometimes off-centre) flanked by columns; the throne at the back with columns beside it in the bigger ones; the altar in the middle between two fire bowls; 1-3 decorations against the walls.
  - **The god either sits on their throne or walks about inside the shrine**, on a loop that never leaves its walls (the empty throne then stands at the back). Each god's art gained an empty-throne frame for this.
  - Drawn back to front, so the god walks in front of the back wall and behind the front wall. Co-op players all see the same shrine (it is built from a seed the host shares).
- The walls are pictures only: they don't block players or enemies.
- New setting `gods.temple_walk_speed_px`; `docs/ART_RULES.md` explains the parts and the layout; a new test checks shrines vary in size, the same seed builds the same shrine, some gods sit and some walk, and a walking god never leaves the shrine.

### Reason
The owner asked for castle or shrine parts to build a random castle or shrine round the altar, with the god either sitting on the throne or walking around inside it, confined to that area.

## Version 00.02.18
Date: 10/31/2026
Time: 3:33 AM

### Changes
- Fix: the fortune element (Tyche) had no spell picture, so one test failed in 00.02.17. Fortune shots now fly as a spinning gold coin. All tests pass again.

### Reason
Follow-up to the spell pictures the owner asked for.

## Version 00.02.17
Date: 10/31/2026
Time: 3:32 AM

### Changes
- **Spells look like what they are** instead of coloured orbs:
  - Ember flies as a fireball with streaming flames; Frost as pointed ice shards; Breeze as a spinning gust of wind; Runo Song's verses as a fireball, an ice shard and a lightning bolt in turn; Glimmer's lights as spinning motes of holy light with four rays.
  - Spark and Tempest call a jagged lightning bolt down from the sky onto each spot they strike, with a flash where it lands.
  - Shade and Oblivion show wisps of shadow swirling round the Hero each time they hit.
  - Every element has a picture (fire, ice, lightning, wind, holy, dark, water, earth), so infused shots and later spells fly as their element too. Built by `tools/art/build_spells.py`; new setting `effects.bolt_height_px`.
- `docs/ART_RULES.md`: a Spells section. A test checks every element has a spell picture and that Ember flies as a fireball.

### Reason
The owner asked to work on the spells next (and for the full sprite sheet to show all the walking frames too).

## Version 00.02.16
Date: 10/31/2026
Time: 3:24 AM

### Changes
- **Every enemy type now has a picture** (all 46: the 12 bosses, the 12 Aegean Shore enemies, and these 22), each with a standing frame and 4 moving frames, from its source:
  - Midgard's Edge: the draugr and the draugr brute (Grettis saga: swollen, dark-blue walking dead with glowing eyes; the brute with a rusted sword); frost giants and their caster (Gylfaginning: pale icy-blue, icicle beards, furs, a shard of ice); Muspell sparks and the bomber (living flames); the troll and the troll elite (long-nosed, mossy, with a club; the elite already turning to stone, Alvíssmál); the wolves of the Ironwood. Loki's illusions are copies of Loki's own picture, so they fool the player.
  - The Two Lands: scarabs (the heart scarab; Khepri); the restless dead in linen wrappings; the shabti guardian (Book of the Dead spell 6: a blue faience figure with a striped wig, hoes in crossed arms, a band of writing); the sand cobra, hood spread.
  - The Misty Isles: the redcap (Henderson 1866: long teeth, talons, red eyes, grey hair, a blood-red cap, iron boots, a pikestaff); the sluagh, the host of the dead (Carmina Gadelica), as dark winged spirits; the kelpie, a grey water-horse with a weed-tangled, dripping mane; a Fomorian caster (seaweed hair, one great eye, a driftwood staff with a shell).
  - The two placeholder test enemies (dark blobs) and the god's trial avatar (a figure of golden light, only seen for a god without art).
- `tools/art/build_enemies_rest.py` builds them.

### Reason
The owner asked to draw all 46 enemies without waiting for their input until every one is drawn.

## Version 00.02.15
Date: 10/31/2026
Time: 3:21 AM

### Changes
- **Enemies can have pixel art**, drawn hundreds at a time: every enemy type with a picture is packed into one atlas and drawn by one MultiMesh with a small shader, so it stays fast. They face the way they move, walk (or flap, or bob) as they move, flash white when hit, and take status and wind-up tints. Enemies without art keep their circle for now.
- **The 12 Aegean Shore enemies are drawn**, each from its source:
  - Shades of the dead (Odyssey 11): pale hooded ghosts with dark hollows for eyes, trailing into mist; the flyer reaches out; the encircler is a darker violet.
  - Harpies (Argonautica 2) and the Siren (Odyssey 12; the Siren vase): birds with women's heads and talons; the Siren is pale-feathered, red-gold haired, with a lyre.
  - A satyr (as Greek vases paint them: bearded, horse's ears and tail); the Spartoi (crested bronze helmet, shield and spear, rising out of the earth); a fire-breathing bronze bull of Aeëtes.
  - Elites: the Minotaur (a man with a bull's head); a Cyclops (one round eye, a sheepskin, an olive-wood club); a Gorgon sister (serpent hair, tusk, bronze hand, golden wings, running).
- New settings `enemies.walk_frame_px` and `enemies.art_*_tint`; `docs/ART_RULES.md` has an Enemies section; a test checks every enemy art file.

### Reason
The owner asked to start on the enemies (spells next).

## Version 00.02.14
Date: 10/31/2026
Time: 3:13 AM

### Changes
- **Hammers smash the ground.** The War Hammer (and Quake Hammer) no longer swings in an arc: it comes down from overhead onto a spot in front of the Hero and hits everything around that spot, knocking it outward, with a shockwave ring that appears as the hammer lands. The Quake Hammer adds its wider quake ring on every smash. New pattern `smash` with the level value `smash_radius_px`.
- Effect rings can be held back a moment (`spawn_ring` delay), so a hammer's shockwave waits for the hammer to land.
- `GAME_DESIGN.md` and `docs/ART_RULES.md`: the weapon rule now says spears jab, javelins are thrown, bows shoot arrows, swords and clubs swing, hammers smash the ground. A new test checks a hammer hits the spot it lands on and all round it, but not behind the Hero.

### Reason
The owner said: "Spears jab. Javelins are thrown. Hammers smash ground."

## Version 00.02.13
Date: 10/31/2026
Time: 3:09 AM

### Changes
- **Spears jab again; javelins are thrown.** The Gáe Bolg (and Thirty Barbs), Achilles' Spear and Shield and Scáthach's spear are back to a piercing thrust along a line with their old numbers (reach, width), and the Gáe Bolg's kills burst into barbs as before. The javelin (and Rain of Javelins) is still thrown and flies as its picture.
- **You see the jab:** the spear's own picture shoots out from the Hero's hand toward the target and draws back (the held spear is hidden while it jabs).
- The held weapon now hides and reappears on time during swings and jabs even when the Hero is standing still.
- `GAME_DESIGN.md` (Gáe Bolg, and the weapon rule) and `docs/ART_RULES.md` updated; the unused flying-spear pictures were removed. Tests check spears jab, javelins are thrown, and every flying picture exists.

### Reason
The owner asked to put spears back to jab, and javelins to throwing.

## Version 00.02.12
Date: 10/31/2026
Time: 3:06 AM

### Changes
- Wrote the owner's weapon rule into `GAME_DESIGN.md` (Weapons) and `docs/ART_RULES.md`: how a weapon attacks follows what it is. Spears and javelins are thrown and fly to enemies; bows stay in the Hero's hand and shoot arrows; swords, clubs and hammers are swung from the hand; axes, discs and sling-stones fly spinning. Every attack starts from the Hero. The game already works this way (00.02.11).

### Reason
The owner stated: "Arrows get shot. Swords get swung", so it's kept as a rule.

## Version 00.02.11
Date: 10/31/2026
Time: 3:03 AM

### Changes
- **Spears are thrown.** The Gáe Bolg (and Thirty Barbs), Achilles' Spear and Shield and Scáthach's spear now fly at their target as their own pictures and pierce through several enemies (3 at level 1, more as they level), instead of a thrust along a line. Enemies the Gáe Bolg kills still burst into barbs. Their reach was doubled to suit a throw. `GAME_DESIGN.md` updated (owner decision).
- **Thrown weapons and shots fly as pictures** instead of coloured dots: javelins and spears point along their flight; throwing axes, the bladed discus and Lugh's sling-stone spin; every bow shoots a real arrow (steel point, feathered fletching). New pictures in `data/art/projectiles/`; weapons say which with `projectile_art` and `projectile_spin_deg_s`. Spells keep their coloured orbs for now.
- **Attacks come from the Hero:** everything thrown or shot leaves from the Hero's hand, and every melee swing (clubs, swords, Excalibur, the tachi, hammers) shows the weapon itself sweeping from the hand through the swing (the held weapon is hidden while it swings). New setting `effects.swing_s`.
- The Gáe Bolg test now checks a thrown spear: it flies as a picture, kills, pierces to the next enemy, and bursts into barbs. Every `projectile_art` must have a picture.

### Reason
The owner asked for effects coming from the character, and said spears are thrown, so they need to fly to enemies.

## Version 00.02.10
Date: 10/31/2026
Time: 2:57 AM

### Changes
- **All 16 weapon pictures redrawn with their own style** (no more shared pictures), each drawn pixel by pixel from its source:
  - Swords: the Greek xiphos with a leaf-shaped bronze blade and disc pommel; **Excalibur** with a long blade, a dark fuller, a bright shining edge, a glint, an ornate gold cross-guard with curled ends and a jewel, a gold-wrapped grip and a jewelled pommel; Tomoe's tachi with a curved blade, a round tsuba and a wrapped grip.
  - Spears: the light **javelin** with its leather throwing loop; **Achilles'** great spear of Pelian ash (Iliad 16) with a broad bronze head and butt-spike; the **Gáe Bolg** with a dark red shaft and rows of backward barbs; **Scáthach's** Irish spear with a long slender head, bronze socket rings and a dark shaft.
  - Heracles' knotted olive-wood club, a war hammer with a beak-spike, a bearded throwing axe, a toothed bronze discus, Lugh's sling with its stone, a tall yew longbow, Atalanta's recurved bow with horn tips, Odysseus' great horn bow bound with gold, and Väinämöinen's kantele with its strings and tuning pegs.
- Achilles and Scáthach the bosses hold their new spears. `docs/ART_RULES.md` updated.

### Reason
The owner wants more style in the weapons (Excalibur looked like the other sword, only bigger; the spears all looked the same), effects coming from the character, and spears thrown at enemies. This is the first step; the other two follow.

## Version 00.02.09
Date: 10/31/2026
Time: 2:50 AM

### Changes
- **The last five gods have sprites, each standing and seated on their throne** (all 8 Pack 1 gods are now done):
  - **Skadi** (Prose Edda: she goes on skis with her bow, hunting in the mountains): a fur-trimmed blue-grey hooded cloak, a long pale-gold braid, a dark blue wool dress with a fur hem, fur boots, her bow; Norse high seat.
  - **Sekhmet** (Book of the Heavenly Cow; her statues from the temple of Mut at Karnak): a lioness head, a striped wig, the sun disk with a rearing cobra, a broad collar, a close red linen dress ("Lady of the Red Linen"), an ankh and a papyrus sceptre; Egyptian gilded throne.
  - **Ra** (Book of the Heavenly Cow; the Amduat; tomb paintings of Ra-Horakhty): a falcon head with the dark mark under the eye, the sun disk and cobra, a striped wig, a broad collar, a pleated kilt with a gold belt and panel, the was-sceptre; Egyptian gilded throne.
  - **Poseidon** (Homer; Hesiod; vase paintings and the Artemision bronze): dark hair bound with a gold fillet, a dark beard, his chest bare, a sea-blue himation over one shoulder and round his hips, the trident; Greek marble throne.
  - **The Morrígan** (Táin Bó Cúailnge; Táin Bó Regamna, the red-haired woman in the red cloak; Cath Maige Tuired): red hair and brows, a red cloak, a dark dress, a grey spear, and a hooded crow, her bird shape, on her shoulder; Celtic carved throne.

### Reason
The owner asked for a throne for each god with the god sitting in it, then a completed sprite sheet.

## Version 00.02.08
Date: 10/31/2026
Time: 2:47 AM

### Changes
- **Every god has a throne, and sits on it at their shrine.** The throne stands in for the altar (the binding ring is unchanged). Gods still stand and move in their trials.
  - Thrones in the style of each god's people: Greek marble with a gold-edged pediment (Tyche), a Norse carved wooden high seat with carved pillar tops (Thor), Celtic carved oak with bronze knotwork and a ring-head (Cernunnos); an Egyptian gilded throne with blue inlay and a lion's paw is ready for Sekhmet and Ra.
  - The seated pose is made from each god's standing art (body lowered onto the seat, thighs along it, shins down), so later changes to a god carry over.
- Replaces the gods walking round their altars (00.02.06). Settings `gods.altar_walk_*` were removed; new `gods.throne_feet_px`. A test checks every god has a seated frame.

### Reason
The owner asked for a throne for each god with the god sitting in it, then a completed sprite sheet.

## Version 00.02.07
Date: 10/31/2026
Time: 2:40 AM

### Changes
- **Thor wears a gold crown** with three points, sitting on his red hair with a dark line under it so it stands apart from his head (as on King Arthur). The crown is the owner's choice, not from the sources; noted in his art file.

### Reason
The owner asked to put a crown on Thor.

## Version 00.02.06
Date: 10/31/2026
Time: 2:38 AM

### Changes
- **Gods walk slowly round their altar** (using their walking frames) instead of standing on it: behind the altar on the far side of the circle, in front of it on the near side. Each altar starts its god at a different point, so they don't walk in step. New settings `gods.altar_walk_radius_px`, `gods.altar_walk_speed_px` and `gods.altar_walk_squash`; `gods.shrine_art_feet_px` is no longer used and was removed.

- **Thor's sprite**, from Snorri Sturluson's Prose Edda (his three treasures: the hammer Mjöllnir with its rather short handle, Megingjörð the belt of strength, and the iron gloves he needs to grip the hammer) and the sagas' red-bearded Thor:
  - red hair to his shoulders, a full red beard, a heavy brow;
  - a blue-grey wool tunic with a woven border, trousers with leg wraps, leather shoes (Viking Age dress);
  - a wide leather belt of strength with gold fittings; an iron glove on the hand raising Mjöllnir, shaped like Viking Age Thor's-hammer pendants.
  - Nothing from Marvel's Thor (no winged helmet, no red cape), as `GAME_DESIGN.md` requires.

### Reason
The owner approved Cernunnos and asked for the next god, and suggested the gods should sit on a throne or walk around the altar the player walks to to unlock them.

## Version 00.02.05
Date: 10/31/2026
Time: 2:35 AM

### Changes
- **Cernunnos' sprite**, from the few ancient images of him (kept light, as `GAME_DESIGN.md` asks): the antlered god of the Gundestrup cauldron (National Museum of Denmark) and the name on the Pillar of the Boatmen (Paris):
  - a stag's antlers spreading wide from his head, with tines; short brown hair, beardless;
  - a gold torc round his neck, and another torc held out in his hand;
  - a ram-horned serpent held in his other hand;
  - a close-fitting green garment with a belt, trousers and shoes. (The cauldron shows him seated cross-legged; here he stands.)

### Reason
The owner approved Tyche and asked for the next god.

## Version 00.02.04
Date: 10/31/2026
Time: 2:32 AM

### Changes
- **Gods can have pixel-art sprites.** A god with art stands in their shrine (instead of a coloured dot), and appears in person in their trial: as the duel opponent (instead of the avatar's circle, flashing when hit), at the centre of an endurance trial, and as the one you chase (and their decoys) in a chase trial, always facing the nearest player. Gods without art keep their dot and circles for now.
- **Tyche's sprite**, goddess of fortune (Hesiod, Theogony; Pindar, Olympian 12: she steers ships at sea), as Hellenistic statues such as the Tyche of Antioch show her:
  - a crown shaped like a city's walls and towers; dark hair in a knot;
  - a long blue chiton with a saffron mantle draped across her;
  - the cornucopia (horn of plenty) spilling fruit in one arm, the ship's steering oar in her hand.
- `docs/ART_RULES.md`: a Gods section. New setting `gods.shrine_art_feet_px`; a test checks every god art file.

### Reason
The owner asked to do the gods next (and, after the gods, to redo all the weapons).

## Version 00.02.03
Date: 10/31/2026
Time: 2:28 AM

### Changes
- **Balor's sprite**, from Cath Maige Tuired (The Second Battle of Mag Tuired): the old Fomorian king whose destroying eye was opened only in battle, when four men lifted its lid with a polished handle passed through it:
  - a huge, grim old giant (as big as Kronos and Surtr) with grey-pale skin, long dark hair and a long dark beard;
  - his one great eye glowing orange under a heavy, half-raised lid, the polished handle jutting forward through the lid;
  - a dark green mantle behind him, a leather war-belt studded with bronze, a leather kilt, boots; an open hand reaching forward; 4 walking frames.
- **All 12 Pack 1 bosses now have sprites.**

### Reason
The owner approved Ferdiad and asked for the next boss, and for a complete sprite sheet.

## Version 00.02.02
Date: 10/31/2026
Time: 2:26 AM

### Changes
- **Ferdiad holds his shield across the front of his body** (on his far arm, from his chest to his iron apron), with a dark ring around it so it stands apart. His sword arm stays in front of it.

### Reason
The owner said the shield can cover the front of his body.

## Version 00.02.01
Date: 10/31/2026
Time: 2:25 AM

### Changes
- **Scáthach the boss now has a sprite**: her Hero sprite holding her spear, drawn twice as big, like Achilles the boss.
- **Ferdiad's sprite**, from the Táin Bó Cúailnge (Book of Leinster), arming himself for the combat at the ford against Cú Chulainn:
  - a rounded bronze helmet set with gems, a gold crest along its ridge; young and beardless, brown hair, fair skin;
  - a red silk tunic with gold edging, an apron of brown leather, and over it an apron of iron plates to the knee;
  - a great round bronze shield with rows of gold bosses on his far arm, with its own dark edge;
  - a curved sword raised in his hand; 4 walking frames.
- The art tools build bosses who are also Heroes with one shared helper (`kit.build_hero_boss`).

### Reason
The owner asked what's next after Apep and Set's fixed arm.

## Version 00.02.00
Date: 10/31/2026
Time: 2:23 AM

### Changes
- **Set's arm redrawn**: his upper arm now hangs clear of his chest with its own dark edge (the gold armband on it), the forearm reaches forward, and a small hand wraps round the was-sceptre, with the staff showing above and below it. Before, the arm ran into his chest and ended in a block of a fist.

### Reason
The owner asked why Set's body (asked as "Ammit") meshed with his arm, with a weird arm or hand holding the staff.

## Version 00.01.99
Date: 10/31/2026
Time: 2:22 AM

### Changes
- **Apep's sprite**, from the Book of Gates and the Amduat (the vast serpent of chaos who attacks the sun's boat each night) and the Book of Overthrowing Apep:
  - a huge serpent, the biggest boss of the Two Lands (84 × 72): a coil along the ground curling back over itself (with a dark edge where it crosses), then his neck rearing up;
  - purple-black scales darker than the night, with a sheen along his back, dark bands, and a pale belly;
  - a heavy wedge-shaped head, jaws open with fangs, a red eye;
  - his coils sway as he moves (4 frames).

### Reason
The owner approved Set's new head and asked for the next boss.

## Version 00.01.98
Date: 10/31/2026
Time: 2:20 AM

### Changes
- **Set's head redrawn**: a short, deep muzzle with a slight downward curve instead of the long thin snout, and his tall ears now widen to flat, squared tips (the Set animal's best-known feature), with a heavier brow over the eye.

### Reason
The owner said Set looked like an anteater.

## Version 00.01.97
Date: 10/31/2026
Time: 2:19 AM

### Changes
- **Set's sprite**, as Egyptian temple reliefs and papyri show him (for example at Karnak and Abydos), lord of the desert and storms (The Contendings of Horus and Set; Plutarch, On Isis and Osiris):
  - a man's body with the head of the "Set animal": tall flat-topped ears, a long curved snout, a yellow eye, reddish colouring (Plutarch);
  - a striped wig falling to his shoulders, a broad collar of blue, gold and red beads, a gold armband;
  - red-brown skin, as Egyptian painting shows men; a pleated linen kilt to the knee with a gold belt and front panel; sandals;
  - the was-sceptre in his hand: a gold staff topped with the Set animal's head and forked at the foot; 4 walking frames.

### Reason
The owner approved Ammit and asked for the next boss.

## Version 00.01.96
Date: 10/31/2026
Time: 2:17 AM

### Changes
- **Ammit's sprite**, from the Book of the Dead, spell 125 (the weighing of the heart), as painted in the Papyrus of Ani (British Museum): the Devourer of the Dead, with the head of a crocodile, the forepart of a lion, and the hindquarters of a hippopotamus:
  - a green crocodile head with a long snout, jaws open with teeth, a yellow eye;
  - a lion's tawny forepart and legs, with her mane painted in blue and gold stripes as in the papyrus;
  - a hippopotamus's heavy rump, short thick legs and little tail; 4 walking frames.
- The art tools share ellipse and polygon helpers for boss bodies (`tools/art/hero_kit.py`).

### Reason
The owner approved Surtr and asked for the next boss, and for a sprite sheet.

## Version 00.01.95
Date: 10/31/2026
Time: 2:13 AM

### Changes
- **Surtr's sprite**, from the Poetic Edda (Völuspá 52: he comes from the south with fire, and the sun shines from his sword) and Snorri Sturluson's Prose Edda (Gylfaginning 4 and 51: the giant who guards Muspell, the land of fire; at Ragnarök fire burns before and behind him and his sword shines brighter than the sun):
  - a huge fire giant, as big as Kronos: skin like coal with embers glowing through the cracks, burning eyes, hair and beard of flame;
  - a soot-dark leather kilt with iron studs;
  - his blazing white-hot sword raised, flames licking up the blade;
  - fire burning behind him and at his feet; 4 walking frames.

### Reason
The owner approved Loki and asked for the next boss.

## Version 00.01.94
Date: 10/31/2026
Time: 2:06 AM

### Changes
- **Loki's sprite**, from Snorri Sturluson's Prose Edda and Viking Age finds:
  - "pleasing and handsome in appearance" (Gylfaginning 33): a sly face with a slanted brow, russet hair swept back, a short pointed beard;
  - his lips sewn shut, as the dwarf Brokkr did to him (Skáldskaparmál 35) and as the Snaptun stone (Denmark, about 1000 AD) shows him: stitches across his mouth;
  - Viking Age dress from finds like Birka and Hedeby: a dark red knee-length tunic with a woven gold border, a belt, a dark blue cloak pinned at his shoulder with a silver pin, grey trousers with leg wraps, leather shoes;
  - a flame dancing over his open hand (his wildfire attack); 4 walking frames.
  - Nothing from Marvel's Loki (no horned helmet, no green and gold), as `GAME_DESIGN.md` requires.

### Reason
The owner approved the new Fenrir and asked to continue with the bosses.

## Version 00.01.93
Date: 10/31/2026
Time: 2:04 AM

### Changes
- **Fenrir redrawn**:
  - a real wolf's build: high shoulders, the back sloping down to the hips, a deep chest, the belly tucked up, long slender forelegs, muscled hind legs that bend back at the hock, a bushy hanging tail;
  - a wolf's head: tall pointed ears, a brow, a long tapering muzzle with a black nose, a snarl with bared fangs instead of gaping jaws, a yellow eye, a pale cheek ruff;
  - the white ribbon (Gleipnir) round his neck is gone.

### Reason
The owner didn't like the first Fenrir: the body shape, the head and jaws, and the white ribbon.

## Version 00.01.92
Date: 10/31/2026
Time: 2:00 AM

### Changes
- **Fenrir's sprite**, from Snorri Sturluson's Prose Edda (Gylfaginning 34 and 51):
  - a huge grey wolf on four legs, darker along his back, with a pale chest and throat, a bushy tail, and a yellow eye;
  - his jaws gaping (at Ragnarök they open from the earth to the sky), with fangs;
  - Gleipnir, the fetter "smooth and soft as a silken ribbon" the gods bound him with, broken but still round his neck, its torn end fluttering back;
  - 4 running frames (his legs move in pairs).

### Reason
The owner approved Kronos and asked for the next boss.

## Version 00.01.91
Date: 10/31/2026
Time: 1:57 AM

### Changes
- **Kronos' sprite**, from Hesiod's Theogony (the youngest Titan, who overthrew his father with the great jagged sickle of grey adamant that Gaia made, then swallowed his children):
  - a huge old man, the biggest boss so far (68 × 72), with long grey hair down his back and a long grey beard;
  - a dark purple himation (mantle) over one shoulder with a gold edge, his chest bare on the other side, the mantle falling to his shins; sandals;
  - the jagged adamant sickle raised in his hand; 4 walking frames.

### Reason
The owner approved Achilles the boss and asked for Kronos next.

## Version 00.01.90
Date: 10/31/2026
Time: 1:55 AM

### Changes
- **No red ring around bosses that have a sprite** (Medusa and Achilles so far): the sprite, drawn above the horde, stands out by itself. Bosses still drawn as circles keep their ring, and the arrow at the edge of the screen still points to any boss that's off screen.
- Removed the setting `bosses.marker.art_ring_mult` (no longer used).

### Reason
The owner said that now bosses have sprites, they don't need a red ring around them.

## Version 00.01.89
Date: 10/31/2026
Time: 1:54 AM

### Changes
- **Achilles the boss now has a sprite**: his Hero sprite (crested bronze helmet, shield across his body, red chiton, tin greaves) holding his spear, drawn twice as big, so players recognise the Hero they're duelling and he stands out as a boss. He walks with the Hero's 4 frames and faces the way he moves.
- `tools/art/build_boss_achilles.py` builds it from the Hero art; `docs/ART_RULES.md` notes the rule for bosses who are also Heroes.

### Reason
The owner approved Medusa and asked for the next boss.

## Version 00.01.88
Date: 10/31/2026
Time: 1:53 AM

### Changes
- **Medusa has a serpent's tail instead of legs**: thick under her chiton, curving down to the ground and trailing behind her to a thin tip, with a pale belly and darker bands across its back. It sways as she moves (her walking frames).
- This goes against the sources on purpose (the ancient Medusa has a woman's legs; the tail is the well-known modern image), at the owner's choice; noted in her art file and `docs/ART_RULES.md`.

### Reason
The owner would rather her feet area be snake-like.

## Version 00.01.87
Date: 10/31/2026
Time: 1:51 AM

### Changes
- **Medusa has no wings now**, as in Ovid's telling. She keeps her serpent hair, tusk, bronze hands, dark chiton, and her legs: the ancient sources and art give her a woman's body; a snake's tail in place of legs is a modern invention (the 1981 film and later games), which `GAME_DESIGN.md` asks us not to copy.

### Reason
The owner asked: "wasn't Medusa a snake herself? no wings too."

## Version 00.01.86
Date: 10/31/2026
Time: 1:50 AM

### Changes
- **Medusa's golden wing redrawn** so it reads as a wing: raised from her shoulder with an arched top edge, a band of small feathers along it, and long flight feathers hanging down in a row, each with its own shadow line and a ragged tip. (Before, it was a fan of thick rods.)

### Reason
The owner asked what the yellow thing behind her was.

## Version 00.01.85
Date: 10/31/2026
Time: 1:48 AM

### Changes
- **Bosses can have pixel-art sprites.** A boss with art is drawn as its picture instead of a coloured circle: bigger than the Heroes, facing the way it moves, walking while it moves, flashing white when hit and tinted by statuses. The red marker ring now goes round the whole picture. Bosses without art keep their circle for now.
- **Medusa's sprite**, from Pseudo-Apollodorus (Bibliotheca 2.4.2: heads twined with serpents, great tusks like a boar's, hands of bronze, wings of gold) and Ovid (Metamorphoses 4, snakes for hair):
  - writhing green serpents for hair, each with its own dark edge and eye;
  - golden feathered wings; bronze clawed hands; a tusk at her mouth; pallid skin;
  - a dark short chiton with a gold border, as archaic Greek vase paintings and temple reliefs show her; sandals; 4 walking frames.
- `docs/ART_RULES.md`: a Bosses section. New settings `bosses.art_hit_flash` and `bosses.marker.art_ring_mult`; a test checks every boss art file.

### Reason
The owner asked to do the bosses next (then the gods), and is OK with boss sprites being bigger than normal so they look better.

## Version 00.01.84
Date: 10/31/2026
Time: 1:42 AM

### Changes
- **Odysseus' pilos is now small and red**: a little rounded red felt cap sitting on top of his dark hair, with his hair showing below it all round.

### Reason
The owner asked: "wouldn't it be a small red pilos".

## Version 00.01.83
Date: 10/31/2026
Time: 1:40 AM

### Changes
- **Odysseus' hat redrawn**: his pilos is now a snug, rounded, egg-shaped felt cap with no brim, in dark red-brown felt, the way Greek vase paintings show it. The old one was wider with a brim, in khaki.

### Reason
The owner said Odysseus' hat made him look like an elephant safari hunter.

## Version 00.01.82
Date: 10/31/2026
Time: 1:38 AM

### Changes
- **Hero colours now work with the new sprites.** The Color button on Hero select (colours unlocked by mastery 2 to 5: silver, teal, purple, gold) now recolours the Hero's clothes in their sprite, instead of only tinting the old placeholder square. Skin, hair, metal and weapons keep their colours, and each piece of cloth keeps its light and shadow.
  - Which parts change: Heracles' chiton, Cú Chulainn's mantle, Väinämöinen's coat, Tomoe Gozen's armour and its cords, Achilles' chiton and leather strips, King Arthur's surcoat, Atalanta's chiton, Odysseus' tunic, Scáthach's léine.
- Each art file lists its clothing colours under `recolor`; `docs/ART_RULES.md` explains it. A new test checks that clothes change and skin doesn't.

### Reason
The owner asked for Hero colour options next.

## Version 00.01.81
Date: 10/31/2026
Time: 1:35 AM

### Changes
- **King Arthur's crown** is back to the first design (00.01.74: worn low on his head, its original gold), moved up one pixel with a dark line between the bottom of the crown and his forehead so the two stay apart. The 00.01.80 version (crown up on his hair) is undone.

### Reason
The owner liked the crown better before; it just needed a definition between the bottom of the crown and his head.

## Version 00.01.80
Date: 10/31/2026
Time: 1:33 AM

### Changes
- **King Arthur's crown** now sits on top of his brown hair, with a band of hair between it and his face, so the gold stands out instead of running into his forehead. Brighter gold with a darker lower edge and a small jewel glint.

### Reason
The owner said King Arthur's crown blended into his head.

## Version 00.01.79
Date: 10/31/2026
Time: 1:31 AM

### Changes
- **Scáthach's sprite**, from Tochmarc Emire (The Wooing of Emer, where she trains Cú Chulainn at Dún Scáith, the fortress of shadows) and Aided Óenfir Aífe:
  - the tales don't describe her looks, so her clothes follow the early Irish dress in the same tales (as Cú Chulainn's): a léine (tunic) to the knees in madder brown, a dark shadow-coloured brat (mantle) over her shoulders held by a silver brooch, a belt, and shoes;
  - long black hair falling down her back; fair skin;
  - not based on any modern version (GAME_DESIGN.md avoids the Fate/Grand Order designs);
  - built on the shared Hero body, with the same walk. She holds her spear.
- All nine Pack 1 Heroes now have sprites.

### Reason
The owner asked to go on to the next Hero.

## Version 00.01.78
Date: 10/31/2026
Time: 1:29 AM

### Changes
- **Odysseus' sprite**, from Homer's Odyssey and Greek art:
  - the pilos, a pointed felt traveller's and sailor's cap, which is how Greek vase painters and sculptors mark Odysseus;
  - a dark beard (Odyssey 16) and dark hair under the cap; Mediterranean skin;
  - a purple tunic to the knees with a gold brooch at the shoulder, from the purple cloak and gold brooch he wore to Troy (Odyssey 19); a belt with a gold buckle, and sandals;
  - built on the shared Hero body, with the same walk. He holds his Great Bow (the contest of the bow, Odyssey 21).

### Reason
The owner asked to go on to Odysseus.

## Version 00.01.77
Date: 10/31/2026
Time: 1:28 AM

### Changes
- **Atalanta's arrows removed**: nothing sticks up behind her shoulder now. Her bow shows she's an archer; her hair knot is clear again.

### Reason
The owner said "no" to the arrows above her shoulder.

## Version 00.01.76
Date: 10/31/2026
Time: 1:27 AM

### Changes
- **Atalanta's quiver** is no longer drawn beside her. Her quiver is on her back, so from the side only the arrows show: two light wooden shafts with red feathers, sticking up behind her shoulder.

### Reason
The owner said the quiver looked like a rocket, and that you wouldn't really see a quiver from the front of a person, maybe just arrows above the shoulders.

## Version 00.01.75
Date: 10/31/2026
Time: 1:25 AM

### Changes
- **Atalanta's sprite**, from Ovid's Metamorphoses (book 8, the Calydonian boar hunt) and Apollodorus' Library (3.9.2):
  - plain dark hair gathered in a single knot at the back (Ovid);
  - a belted huntress's chiton to the knees in deep teal (so she stands out on grass), fastened at the throat with a gold brooch (Ovid);
  - an ivory quiver on her back with red-fletched arrows showing at the top, on a shoulder strap (Ovid);
  - laced leather hunting boots; Mediterranean skin, like Heracles and Achilles;
  - built on the shared Hero body, with the same walk. She holds her Huntress Bow.

### Reason
The owner asked to go on to Atalanta.

## Version 00.01.74
Date: 10/31/2026
Time: 1:18 AM

### Changes
- **King Arthur's sprite**, from Malory's Le Morte d'Arthur and Geoffrey of Monmouth's History of the Kings of Britain:
  - a gold crown on brown hair and a short beard (as in the medieval Nine Worthies pictures), fair skin;
  - a coat of mail (Geoffrey) on his arms, neck and legs, drawn as rows of rings;
  - a blue surcoat to the knees with a gold crown on the chest (from the three gold crowns on blue that medieval rolls of arms give Arthur), split at the front, with a belt and gold buckle;
  - Excalibur's scabbard (Malory, book 1 ch. 25) hanging at his far hip, with gold fittings;
  - leather boots; built on the shared Hero body, with the same walk. He holds Excalibur.

### Reason
The owner approved Heracles without the hood and asked to go on to King Arthur.

## Version 00.01.73
Date: 10/31/2026
Time: 1:16 AM

### Changes
- **Heracles no longer wears the lion hood.** He now has short, curly dark hair (one solid mass with a curled top and shadow at the back), a clear forehead and eye, and his beard. The lion's paws at his throat went with it.
- `docs/ART_RULES.md`: the example of an iconic feature is now Heracles' club and build and Achilles' helmet and shield; the lion pelt colours were removed from the palette table.

### Reason
The owner approved Achilles ("perfect") and asked to remove the hat on Heracles.

## Version 00.01.72
Date: 10/31/2026
Time: 1:14 AM

### Changes
- **Achilles' head redrawn**:
  - a rounded bronze helmet with a light shine on top, a dark brim with a nose guard, a cheek guard, and a guard over the back of the neck;
  - the gold crest is now its own ridge running over the top of the helmet (with a dark line between them) and falling down behind as a horsehair tail;
  - a bigger, clearer face: forehead under the brim, eye, nose and mouth;
  - golden hair showing below the helmet at the back.

### Reason
The owner said his head looked weird (the crest and helmet ran together into one gold blob, and the face was small).

## Version 00.01.71
Date: 10/31/2026
Time: 1:11 AM

### Changes
- **Achilles' shield now covers his body**: he holds it on his far arm across his chest and stomach, in front of his breastplate, with a dark ring around it so it stands apart. His spear arm stays in front of the shield.

### Reason
The owner asked: "the shield should cover his body no?"

## Version 00.01.70
Date: 10/31/2026
Time: 1:08 AM

### Changes
- **Achilles' sprite**, from Homer's Iliad:
  - golden hair (Iliad 1) showing below a bronze helmet with a crest of gold (Iliad 18, the armour Hephaestus forged);
  - a bronze breastplate with chest and stomach lines;
  - the great round shield on his far arm, with a dark rim, an inner ring and a gold boss, kept apart from his body by its own edge;
  - a skirt of leather strips over a red chiton, tin greaves (Iliad 18), and sandals;
  - built on the shared Hero body, with the same walk. He holds his Spear and Shield's spear.

### Reason
The owner approved Tomoe Gozen and asked to move on to the next Hero.

## Version 00.01.69
Date: 10/31/2026
Time: 1:05 AM

### Changes
- **Tomoe Gozen's sprite**, from The Tale of the Heike (Book 9: beautiful, fair-skinned, long-haired, a strong archer and swordswoman):
  - long black hair tied high with a red cord, falling to her waist;
  - Heike-era armour of dark lacquered plates stitched with red cord, with square laced shoulder guards and a plated skirt in three panels;
  - white hakama, iron shin guards, and sandals;
  - built on the shared Hero body, with the same walk.
- **A Japanese tachi** for her Sword and Bow (curved blade, round guard, wrapped grip), replacing the Greek sword it used before.
- `docs/ART_RULES.md`: weapons fit the Hero's culture, and armour reads as stitched plates, not stripes.

### Reason
The owner asked to move on to Tomoe Gozen.

## Version 00.01.68
Date: 10/31/2026
Time: 1:02 AM

### Changes
- **Väinämöinen's skin is fair**, a little weathered and ruddy, instead of the warm tan close to Heracles'. That fits a Finnish folk figure (the Kalevala doesn't say). New rule in `docs/ART_RULES.md`: skin tone fits each Hero's people and region, set per Hero and checked next to the others.

### Reason
The owner asked whether Väinämöinen's skin tone was right.

## Version 00.01.67
Date: 10/31/2026
Time: 1:00 AM

### Changes
- **Väinämöinen's sprite**, from the Kalevala ("old and steadfast Väinämöinen", the eternal singer):
  - an old man with long white hair down his back, a long white beard over his chest, and bushy white brows;
  - a dark blue-grey wool coat to the knees with a red woven belt picked out in gold, and leather boots;
  - built on the shared Hero body, with the same walk.
- **His kantele** (the harp-like instrument he makes in Kalevala runos 40 and 44) is the picture for his Runo Song, so he carries it until another weapon outlevels it: a wedge-shaped wooden box with strings.
- `docs/ART_RULES.md`: spells aren't held, except where the myth gives the spell an object (his kantele).

### Reason
The owner liked Cú Chulainn and asked to move on to the next Hero.

## Version 00.01.66
Date: 10/31/2026
Time: 12:54 AM

### Changes
- **Cú Chulainn's sprite**, from the Táin Bó Cúailnge's description of him:
  - hair of three colours (dark at the roots, blood-red in the middle, gold at the spiky tips), swept up and back;
  - young and beardless;
  - a crimson mantle over his shoulders with a gold brooch;
  - a linen tunic to the knees with red embroidery at the neck, down the front, and a deep hem;
  - a leather belt and leather shoes.
  - He holds the Gáe Bolg (or whatever weapon he uses most) and has the same 4-frame walk.
  - Kept clear of the Fate/Grand Order design, which GAME_DESIGN.md names as one to avoid.
- **Shared Hero body** `tools/art/hero_kit.py` (canvas, pose, both arms, the hand point, legs, walking frames, outline). Heracles' builder now uses it (his art is pixel-for-pixel unchanged).
- `docs/ART_RULES.md` marked **approved** after Heracles, with notes on the shared body and on drawing hair as one solid shaped mass.

### Reason
The owner approved Heracles and asked to start Cú Chulainn.

## Version 00.01.65
Date: 10/31/2026
Time: 12:49 AM

### Changes
- **Weapons held ready instead of dragged.** Heracles' weapon arm bends forward with his fist in front of his belly:
  - clubs, swords, hammers and axes are raised, blade or head up and tipped forward, ready to strike;
  - spears, javelins and bows stand upright, tipped forward a little;
  - the sling hangs from his hand.
- The 00.01.64 tilt (weapons hanging at his side) looked like he was dragging them. Rules updated in `docs/ART_RULES.md`.

### Reason
The owner said the weapons all looked like he was dragging them.

## Version 00.01.64
Date: 10/31/2026
Time: 12:22 AM

### Changes
- **Weapons are held more naturally.** Instead of hanging stiffly straight, each weapon tilts the way a real fighter holds it, and the handle visibly passes through the fist:
  - clubs, swords, hammers, axes and slings swing forward from the wrist;
  - spears, javelins and bows tip forward.
  The lean is set per weapon in `tools/art/build_weapons.py`; the rule is in `docs/ART_RULES.md`.

### Reason
The owner asked for weapons to look like they're held more realistically.

## Version 00.01.63
Date: 10/31/2026
Time: 12:14 AM

### Changes
- **Weapons hang clear of Heracles' body.** His weapon arm now angles out from his side (forearm outward, fist two pixels further out), so whatever he holds has a gap between it and his tunic and legs. Rule added to `docs/ART_RULES.md`.

### Reason
The owner said weapons were too close to the body.

## Version 00.01.62
Date: 10/31/2026
Time: 12:09 AM

### Changes
- **Heroes hold the weapon they use most.** The weapon in a Hero's hand is their highest-level weapon that has a picture. On a tie it's the one they got first, so Heracles starts with his club. Level a sword above the club and he's holding the sword.
  - Spells aren't held. Evolved weapons use their base weapon's picture for now.
  - In co-op, every player's Hero shows their own weapon.
- **15 held-weapon pictures** in `data/art/weapons/`, built by `tools/art/build_weapons.py`: club, Greek sword (also for Sword and Bow), Excalibur (longer, gold guard), war hammer, throwing axe, javelin, spear (Spear and Shield, Scáthach's spear), Gáe Bolg (barbed), bows (longbow, great bow, huntress bow), bladed discus, sling.
- Heracles' art no longer includes the club; it marks his hand, and the weapon is drawn behind his fist so his fingers wrap round it.
- `docs/ART_RULES.md`: a Weapons section. Tests check every weapon picture and the "used most" choice.

### Reason
The owner chose option 2: show whichever weapon the Hero uses most, instead of always the club.

## Version 00.01.61
Date: 10/31/2026
Time: 12:04 AM

### Changes
- **Heracles has his left arm.** The far arm hangs at his left side in the skin's shadow colour (it's further away), with a fist and its own dark edge against his chest. New rule in `docs/ART_RULES.md`: both arms show.

### Reason
The owner asked for a left arm where the cloak used to be.

## Version 00.01.60
Date: 10/30/2026
Time: 11:05 PM

### Changes
- **Heracles' cloak is gone.** The lion skin now shows as the lion-head hood and the paws knotted at his throat, giving a cleaner outline. `docs/ART_RULES.md`: keep cloaks only if they help the silhouette.

### Reason
The owner asked to remove the cloak.

## Version 00.01.59
Date: 10/30/2026
Time: 11:03 PM

### Changes
- **Heracles' body stands apart from his club and cloak.** Each part now has its own dark edge:
  - a 1-pixel outline separates the body from the lion-skin cloak behind it;
  - a dark line runs between his arm and his chest;
  - the club sits a pixel further out, its handle end showing above his fist, with fingers wrapped round it.
- New rule in `docs/ART_RULES.md`: every part gets its own dark edge, and parts never run into each other.

### Reason
The owner said his body blended into the weapon and the cloak.

## Version 00.01.58
Date: 10/30/2026
Time: 11:00 PM

### Changes
- **Heracles' lion-skin cloak looks like fur now**, not a plank: it drapes off his back shoulder and widens as it hangs, with a dark furry edge, lighter tufts, a ragged hem, and the lion's hind paw with white claws at the bottom. A new line in `docs/ART_RULES.md`: cloaks and pelts must read as fabric or fur.

### Reason
The owner asked what the strip on Heracles' left was (the lion-skin cloak, which read as a plank).

## Version 00.01.57
Date: 10/30/2026
Time: 10:58 PM

### Changes
- **Heracles redrawn from scratch** after the owner's feedback (the first one looked like "someone in a diaper").
  - Taller, heroic proportions: 24 × 34 pixels, head about a quarter of his height, longer legs.
  - The lion-head hood (ear, eye, teeth at the tip of the snout) and a slim lion-skin cloak behind.
  - A short beard, and a bare, muscled chest with the lion's paws knotted at the throat.
  - A **dark red chiton to the knees** with folds and a bronze buckle (no short white tunic), and laced sandals.
  - His **club** in dark wood: a handle in his hand, widening into a heavy rounded head by his feet.
- He's now built from shapes by `tools/art/build_heracles.py`, with the dark outline added automatically, so parts are easy to change. The HP bar sits just above whatever height a Hero's art is.
- `docs/ART_RULES.md` updated with the lessons: heroic proportions, clothing to the knees in strong colours, muscles as lines (not dots), nothing white touching the eye, an arm shadow line, and a weapon that stands apart from the body.

### Reason
The owner asked to remake Heracles completely ("kinda looks like someone in a diaper") and asked what the thing on his right was (the club, now redrawn so it reads as one).

## Version 00.01.56
Date: 10/30/2026
Time: 10:53 PM

### Changes
- **First Hero sprite: Heracles** (art style test, owner request). Pixel art drawn in code: 18 × 20 pixels, from Greek art and Pseudo-Apollodorus.
  - What it shows: the Nemean lion's skin as a hood and cloak (ear, eye and teeth), its paws knotted on his chest, a beard, a white chiton with a belt, sandals, and his club.
  - Faces the way he moves, with a 4-frame walk.
  - Greyed when fallen, faded as a Shade, stone-grey when petrified.
  - Other Heroes keep the coloured square until they get art.
- How art works: `data/art/<hero>.json` holds rows of letters (1 letter = 1 pixel) plus a palette; `scripts/art/pixel_art.gd` turns them into images. A test checks every art file.
- **Draft art rules** in `docs/ART_RULES.md` (size, outline, shading, face, weapon, sources, palette letters, frames), to become the rule set for the other Heroes once the owner approves Heracles' look.
- The HP bar over a Hero sits 4 pixels higher (above the taller sprite).

### Reason
The owner chose code-drawn sprites (option 1), starting with one Hero, then a rule set for the rest.

## Version 00.01.55
Date: 10/30/2026
Time: 10:28 PM

### Changes
- **The Unraveling ring is now a wall that closes in.** When the Unraveling starts (after the 30:00 boss, or at 33:00):
  - Heroes can't leave the ring (like a boss arena's edge).
  - Every 30 s it closes in by a tenth of its starting size, in a short visible squeeze.
  - "The ring closes in N s" counts down at the top of the screen.
  - After ten steps it closes onto the players and the run ends, even with the F1 god mode on. The end screen says the Unraveling ended the run.
  - In co-op each device keeps its own Hero inside, and the host ends the run for everyone.
- Numbers to tune in config.json: run_arc.unraveling_step_s (30), unraveling_step_pct (0.1), unraveling_step_anim_s (3). The start banner and the death-recap tip describe the new rule.

### Reason
The owner wants players kept inside the circle, closing every 30 seconds until it closes onto them and the round ends, even in god mode.

## Version 00.01.54
Date: 10/30/2026
Time: 10:17 PM

### Changes
- **W A S D work in every menu and pop-up** (level-up cards, chests, god choices, Boons, Trader, pause menu, title menus), moving between buttons like the arrow keys. **Space** (or Enter) presses the selected button. Arrow keys and gamepad still work, and text boxes still take the letters as typing. The in-run HUD buttons never take keyboard focus, so walking with WASD can't press them. Checked in the game: S and W moved through the pause menu, and Space pressed Resume.

### Reason
The owner asked to move around pop-up menus with WASD and select with the space bar on PC.

## Version 00.01.53
Date: 10/30/2026
Time: 10:15 PM

### Changes
- **Move with the mouse on PC**, the same way as on phones: hold the left mouse button anywhere (except on a button), and the joystick appears there; drag to move; let go to stop. Keyboard and gamepad still work. On phones the touch itself drives the joystick, and the pretend mouse clicks phones also send are ignored, so nothing happens twice. Checked in the game: dragging right moved the Hero right, and letting go stopped him.

### Reason
The owner asked for mouse movement on PC, like on mobile.

## Version 00.01.52
Date: 10/30/2026
Time: 9:48 PM

### Changes
- **F1 debug gold never reaches the account.** Gold from the debug menu's Give gold can still be spent in the run (Trader), but it's left out when the run's gold is banked. That covers the end of a run, quitting, and the "run cut short" checkpoint.
  - Trader purchases use debug gold first, so real gold isn't lost by spending.
  - In co-op, the host's debug gold is left out on every player's device too.
- The changelog entry and status file for this version were added in a second commit (the first one went out without them).

### Reason
The owner asked that F1 menu gold not count towards account gold outside the game.

## Version 00.01.51
Date: 10/30/2026
Time: 9:29 PM

### Changes
- **Update app now really updates, the same way as Wave Defence.** It used to clear the saved copy and reload, but the browser could still use game files it remembered (GitHub lets browsers keep files for 10 minutes), so the old version came back.
  - The web build writes the version into the page and adds `web/update.js`.
  - Every game file is now asked for with its version (`index.pck?v=00.01.51`), so old and new files can never mix.
  - Update app clears the saved copy and reloads with fresh files.
- **Opening the game picks up new versions by itself.** In the first 30 s it fetches the page fresh from the internet, and if a newer version is online it switches to it (never mid-run). This replaces the 00.01.48 check, which could still be fooled by the browser's memory.
- The build's final check now confirms the site shows this exact version.
- Tested with a local server that tells the browser to keep files for 10 minutes (as GitHub does): reopening switched to the newer version by itself, and Update app loaded the newest version with every game file fresh.

### Reason
The owner found the Update app button didn't update, and asked for it to clear the cache like Wave Defence's.

## Version 00.01.50
Date: 10/30/2026
Time: 9:22 PM

### Changes
- **The username belongs to the Google sign-in.** When you're not signed in with Google:
  - the Username box isn't shown in Settings → Account and cloud save;
  - the title screen shows no "Playing as";
  - co-op lobbies show no name;
  - the leaderboard uses the name typed on that device, as before.
- Sign in again and your username comes back (it's kept with the account's cloud save).

### Reason
The owner saw the username box and "Playing as" while not signed in to Google.

## Version 00.01.49
Date: 10/30/2026
Time: 9:18 PM

### Changes
- "Playing as (username)" on the title screen only shows while signed in with Google. Signed in without a username, it says "Signed in with Google."; not signed in, nothing.

### Reason
The owner asked for "Playing as" to show only when signed in to a Google account.

## Version 00.01.48
Date: 10/30/2026
Time: 9:15 PM

### Changes
- **The web version updates itself.** Since 00.01.44 (installable app) the browser keeps a saved copy of the game and kept using it until every tab was closed, so new versions didn't show up. Now, in the first 30 seconds after the game opens, it checks for a newer version and switches to it straight away (the page reloads once). It never does this mid-run. Checked in Chrome: with a newer version online, reopening the page reloaded itself into the new version.
- Settings → Update app still forces it at any time.

### Reason
The owner's game stayed on 00.01.45 after newer versions were online.

## Version 00.01.47
Date: 10/30/2026
Time: 9:10 PM

### Changes
- **Usernames instead of real names.** Settings → Account and cloud save now starts with a **Username** box (up to 12 letters, numbers, spaces, - or _).
  - The username is saved with your progress, so it follows you to every device through cloud saves.
  - The title screen says "Playing as (username)".
  - The username is your leaderboard name, and other players see it in co-op lobbies (e.g. "Player 2 · Zeph").
- **The real name is never fetched.** Sign-in now asks Google only for the account id and email, never the name. The email is only shown to you, on your own device ("Signed in with Google (you@gmail.com)"). A Google name saved on a device by version 00.01.42 is deleted. The privacy page says so.
- **Settings sync better.** Settings were already in the cloud save. Now the device that changed them last wins (not just the device played last), and settings from the cloud take effect at once after a sync.
- Fixed a menu bug: a page whose first item is a text box crashed when picking where keyboard focus starts.

### Reason
The owner doesn't want their real name shown, asked for a username saved through cloud saves, and asked for settings to be saved in the cloud too.

## Version 00.01.46
Date: 10/30/2026
Time: 9:07 PM

### Changes
- **Invite friends during a solo run.** The pause menu now has **Invite friends** and **Open to public**. Either one turns the run into an online game hosted on this device, without stopping it.
  - Invite friends shows a 6-digit code; friends type it and join straight into the run (with the catch-up chest).
  - Open to public also puts the game on the Public Games list.
  - Once online, the pause menu shows the code and a **Make public** / **Make friends-only (code)** switch.
- A solo player now has player number 1 (the host's number), so a run can go online with nothing renumbered. The pause menu also remembers that it paused the game itself, so closing it after going online still un-pauses.
- Worker: the host can send {t:"public", on} to put a game on the public list or take it off.
- Tested with two game windows through a local Worker: a solo run went online from the pause menu, and a friend joined with the code and saw the same enemies and positions. New tests: 1 game, 1 Worker.

### Reason
The owner asked to invite friends while playing solo, and to switch a game between public and closed.

## Version 00.01.45
Date: 10/30/2026
Time: 8:52 PM

### Changes
- **The "Mythriven is updating…" page no longer gets stuck.** It reloaded with a plain refresh, which a browser or GitHub's cache could answer with the same page again. It now reloads every 10 s at a fresh address, so it always gets the newest site, and it says to press Ctrl+F5 if it's still showing after a few minutes.

### Reason
The owner saw the updating page stay up even though the game had finished publishing.

## Version 00.01.44
Date: 10/30/2026
Time: 8:48 PM

### Changes
- **Settings → Fullscreen** (on/off), in the browser and on PC. Phone apps are always full screen.
- **Settings → Install app** (web version). The web build is now installable as an app (progressive web app): it opens full screen from the home screen or desktop.
  - Chrome and Edge, on PC and Android: the button opens the browser's "Install Mythriven?" box.
  - iPhone and iPad: the button explains Share → Add to Home Screen.
  - Other browsers: it points to the browser's menu.
  - When already installed, it says "Installed as an app".
- **Settings → Update app** (web version): forgets the saved copy of the game and reloads, so the newest version is always one tap away. Progress is safe, because it's saved separately. Not available during a run or co-op game.
- The installable build doesn't add the extra browser isolation rules (the game doesn't need them, and they could block the Google sign-in window). Checked in Chrome: the page is installable, and Update app clears the saved copy and reloads the game.

### Reason
The owner asked for Fullscreen, Install app, and Update app settings, for the mobile apps and to force the newest version.

## Version 00.01.43
Date: 10/30/2026
Time: 8:43 PM

### Changes
- **The game link no longer shows the README after an update.** GitHub publishes the repository itself a minute before the game build replaces it.
  - A holding page (`index.html` at the top of the repository) now says "Mythriven is updating…" and reloads itself until the game is back.
  - The web build waits for GitHub's own publish to finish, so the game is always published last.
  - After publishing, the build checks that the site really shows the game, and fails with a clear message if it doesn't.
- The permanent fix is still the owner's one-time setting: GitHub → Settings → Pages → Source → "GitHub Actions".

### Reason
The owner landed on the README again and asked for a check.

## Version 00.01.42
Date: 10/30/2026
Time: 8:40 PM

### Changes
- **Your Google name and email show in the game.** The title screen says "Signed in as (your name)" at the top. Settings → Account and cloud save shows your name, email, and what's on the account (gold banked, Heroes unlocked, achievements), then the sync status. It stays after closing the game, because it's saved on the device. The server still keeps only the hashed Google id; the name and email go only to the player's own device. The privacy page says so.
- Sign-in now asks Google for the basic profile (name and email) as well as the id. Players who signed in before see "Show my Google name (sign in again)".
- Sign out removes the name and email from the device.

### Reason
The owner wants the signed-in account's info shown, and kept between sessions.

## Version 00.01.41
Date: 10/30/2026
Time: 8:37 PM

### Changes
- **The "Signed in!" page closes itself** about a second after signing in, so the player lands back in the game. It also has a **Close** button. When a browser won't let the page close a tab (the PC and phone apps open the browser on their own), a line says to switch back to Mythriven. Checked in Chrome: a tab opened by the web game closes on its own.

### Reason
The owner asked for the sign-in window to close itself or have a close button.

## Version 00.01.40
Date: 10/30/2026
Time: 8:33 PM

### Changes
- **Fixed: "Couldn't reach the sign-in service" on the web version.** Before the game's sign-in request, the browser asks the Worker for permission, and the Worker's answer was missing the details browsers need, so the browser blocked the request. The Worker now answers it fully. Checked in Chrome against a local copy of the Worker: the sign-in start and the one-device check both get through.

### Reason
The owner's first sign-in test on the web link showed "Couldn't reach the sign-in service".

## Version 00.01.39
Date: 10/30/2026
Time: 8:28 PM

### Changes
- **Privacy policy page** at `https://mythriven.thebotcoder.workers.dev/privacy`, served by the Worker (`src/privacy.js`). Google needs it to publish the sign-in so anyone can use it. It says what the game keeps (the hashed Google id, cloud saves, the one-device id, leaderboard names and scores, anonymous suggestions), that there are no ads or tracking, and how to have data deleted (by email to the owner's support address).
- README setup steps updated with the Branding page links.

### Reason
Google's Branding page asks for a home page and privacy policy before the sign-in can be published.

## Version 00.01.38
Date: 10/30/2026
Time: 8:08 PM

### Changes
- **Sign in with Google** (Settings → Account and cloud save). It works the same on the web, PC, and phones: a Google page opens in the browser, the player signs in there, and the game links that device to the account's cloud save. Progress then follows the player between PC and phone. Only Google's id is used (stored hashed), never a name or email. The 12-character code stays as the option for players without Google. Needs the owner's one-time Google setup (`leaderboard-api/README.md`, "Sign in with Google").
- **One device at a time.** An account (or sync code) can only play on one device at a time, and never twice in the same co-op game. Starting a run or a co-op game on a second device shows "Your account is already playing on another device". Going back to the title lets go; a closed game lets go within about 90 s. If another device takes over while one was offline, that device's run ends with a message. Offline play is still allowed.
- Worker: `/auth/start`, `/auth/google`, `/auth/callback`, `/auth/poll` (new `AccountVault` Durable Object, migration v4) and `/cloud/play` (the one-device claim, kept with each cloud save).
- New tests: 4 game tests, 7 Worker tests. Two game windows on one account were run against a local Worker: the second was turned away from a solo run and from hosting co-op until the first went back to the title.

### Reason
The owner chose free Google sign-in, wants the account on PC and phone, and asked that an account never play on two devices or in two games at once.

## Version 00.01.37
Date: 10/30/2026
Time: 7:55 PM

### Changes
- **Co-op god trials wait for everyone.** When a player touches a trial shrine in co-op, the ring appears and shows "everyone into the ring: 1 / 3 inside". The trial starts only when every standing player is inside. If not everyone arrives within 30 s, it's called off, and touching the shrine again restarts it. Everyone who took part earns the god when it's won, even if they were downed during it. The trial fails only when nobody taking part is still standing in the ring. Solo trials are unchanged.
- **Bosses are always easy to see.** A boss is drawn again on top of the crowd (with a dark outline), so other enemies never cover it. A big red arrow at the edge of the screen points to any boss that's off screen.
- **Build plan boxes ticked** where the work is truly done (45). Seven are left empty with the reason: the intended lore warnings, gamepad not tried by a person, and frame rate and memory not measured. Phase 20 now names Cloudflare instead of Epic Online Services.

### Reason
The owner asked that trials wait for all players, that bosses always be easy to see, and that the done boxes be ticked.

## Version 00.01.36
Date: 10/30/2026
Time: 7:50 PM

### Changes
- Recorded the owner's decision to wait on the Steam Cloud backup until the game is on Steam.
- Review notes: added the co-op trial gap (only the player who starts a god trial can earn the god; the design says everyone in the ring). Updated the old decisions row that said joining mid-run wasn't supported.

### Reason
The owner decided to wait on Steam and asked what still needs fixing in Phases 1–20.

## Version 00.01.35
Date: 10/30/2026
Time: 7:41 PM

### Changes
- **Friends can join during a run.** Friend-code games can now be joined at any time, like public games: type the code mid-run and you go straight into the run. The Worker no longer turns friends away once a run has started.
- **Catch-up chest for players who join mid-run.** They get one chest's worth of upgrades for every 5 minutes already played (up to 6), shown in one chest reveal. No gold, because gold goes to the whole team. Numbers are in `config.json` (`coop.late_join_chest_every_s`, `coop.late_join_chests_max`) to tune.
- Pack 1 approved by the owner: tag `phase-20-approved`. Owner answers recorded in the review.

### Reason
The owner approved Pack 1, asked for catch-up rewards every 5 minutes for late joiners, and asked for joining mid-run in friend games.

## Version 00.01.34
Date: 10/29/2026
Time: 11:31 PM

### Changes
- **Review of Phases 1–20** (`docs/reviews/PHASE_01-20_REVIEW.md`): Approved with fixes. Every phase is done except Phase 19's art, audio, and lore sign-off, which the owner is leaving for later. The fixes: the Steam Cloud backup isn't built (decide later), the build plan's boxes and Phase 20 text need updating, and the progress header was out of date (updated). Five yes/no decisions for the owner.
- **Plan for Packs 2, 3, and 4** (`docs/PACK_PLAN.md`): levels, gods, bosses, hazards, and phases (21–39), taken from `GAME_DESIGN.md` without inventing anything. Each pack lists the owner decisions it needs. Pack 4's realms still need 8 bosses designed.
- Recorded the owner's playtests: co-op between a PC and a phone works ("a lot of fun"), and the game works on phones.

### Reason
The owner reported the playtests and asked for the review and a plan for Packs 2–4.

## Version 00.01.33
Date: 10/29/2026
Time: 11:16 PM

### Changes
- New written rule in `AGENTS.md`, `CLAUDE.md`, `docs/AI_WORKFLOW.md`, and Cursor's `.cursor/rules/git-workflow.mdc`: all AI tools commit and push straight to `main` (no feature branches or pull requests) until the owner says otherwise. GitHub keeps only the `main` and `data` branches. Never force-push; run the tests before every push.

### Reason
The owner asked for a rule to push to main from now on.

## Version 00.01.32
Date: 10/29/2026
Time: 11:08 PM

### Changes
- **Public Games.** A new **Public Games** button on the title screen, separate from the friend-code Co-op button. It lists open public games (level, how many players, and whether they're in the lobby or in a run) with **Refresh**, and **Host a public game** puts yours on the list. Only games with the same version of the game and a free place are listed; friend games are never listed.
- **Join a game in progress.** Public games can be joined during a run. The newcomer's Hero appears beside the host's Hero with its signature weapon, sharing the team's level, and their game first receives a snapshot of the world so far (enemies, builds, shrines and chests, the Age, how far the world has moved). If someone leaves mid-run, the next player to join takes their place (their Shade makes way).
- A public game's host can press **Start** alone; others join during the run. Back to Co-op Lobby works the same for public games.
- Worker: a new `PublicGames` Durable Object keeps the list (`GET /lobby/public`, migration v3). Games are dropped from it when the host leaves, or after 2.5 minutes without word. Public rooms allow joining after the run starts; friend rooms still don't.
- Fixed a harmless error in the menus when a screen refreshed twice in one moment.

### Reason
The owner asked for an online mode to find or host public games, with joining in progress, separate from the friend codes.

## Version 00.01.31
Date: 10/29/2026
Time: 7:07 PM

### Changes
- **Back to Co-op Lobby after a co-op run.** The end screen of a co-op run now has **Back to Co-op Lobby** (selected first). Everyone returns to the same lobby with the same game code and Heroes; the lobby shows who is "still on the results screen", and the host's **Start** opens again once everyone is back. Friends can also join with the code between runs. **Back to Title** still leaves the game.
- The Worker's lobby accepts a new "open" message from the host so joining works again between runs (its test checks this).

### Reason
The owner asked for a "back to co-op menu" button.

## Version 00.01.30
Date: 10/29/2026
Time: 7:04 PM

### Changes
- **Back to Title on the end screen.** After a run ends there's now a **Back to Title** button (solo and co-op). In co-op, where Retry and Change Hero are hidden, it's the button selected first, and it also leaves the co-op game. The leaderboard line in co-op now says co-op runs don't go on the leaderboard (it wrongly said debug options were used).

### Reason
The owner found no back button after dying in co-op.

## Version 00.01.29
Date: 10/29/2026
Time: 7:00 PM

### Changes
- **Fix: a blank dark screen after the end-of-run Hall of Legends.** The end screen's **Hall of Legends** button opened the Hall with nothing behind it, so pressing **Back** closed the only screen and left an empty dark screen (in co-op and solo alike). The Hall now opens on top of the title screen, so Back returns to the title. A new automated test checks it.

### Reason
The owner died in a co-op run, went to the Hall, pressed Back, and got a dark screen.

## Version 00.01.28
Date: 10/29/2026
Time: 5:54 PM

### Changes
- **Typing on a phone in the web version.** A browser game can't open the phone's keyboard by itself, so the text boxes (co-op join code, cloud-save code, leaderboard name, and the suggestion form) took no typing on phones. Now, in a phone browser, tapping one of them opens the phone's own text pop-up with the keyboard; what you type goes into the box. PC and desktop browsers type as before.

### Reason
The owner couldn't type the co-op join code on a phone.

## Version 00.01.27
Date: 10/29/2026
Time: 5:44 PM

### Changes
- **Suggest a Feature is back on the main screen.** It was on Hero select, which used to be the first screen; since the title screen arrived (Phase 15) it was hidden one step in. It's now a button on the title screen (and no longer on Hero select), opening the same in-game form. README updated.

### Reason
The owner asked where the suggestion button went.

## Version 00.01.26
Date: 10/29/2026
Time: 4:04 PM

### Changes
- **Quit button on the title screen everywhere.** It was only shown on PC. Now it's on the web link and phones too. In a browser the game asks to close its tab; most browsers don't let a page close a tab it didn't open itself, so then it says "Thanks for playing! Your progress is saved. You can close this tab now." with a **Keep playing** button. Quitting during co-op leaves the game first.

### Reason
The owner asked for a quit button on the main page.

## Version 00.01.25
Date: 10/29/2026
Time: 1:29 PM

### Changes
- **Phase 20: Cloud saves** (through your Cloudflare Worker, as you chose, instead of Epic Online Services).
  - **Settings → Cloud save → Turn on cloud save** gives you a private 12-character code. On your other device, choose **Link this device** and type the code: both now share the same progress.
  - Unlocks, discoveries, and achievements from both devices are combined; god levels, mastery, and records keep the higher value; gold comes from the device you played last (a newly linked device takes the cloud's gold, so linking never loses any).
  - It syncs when the game starts, soon after a purchase or the end of a run, and at most every 30 seconds during a run when you earn something lasting. The game still works fully offline and catches up later.
  - No account, name, or email: the Worker only keeps the save, filed under a scrambled form of the code. "Sign in with Google / Apple / Steam" can be added later (it needs developer sign-ups only you can do).
  - The Worker gets a new storage type (Cloudflare Durable Objects, free plan). It deploys automatically with this push; see `leaderboard-api/README.md` if Cloudflare asks anything.
  - 7 new Worker tests and 7 new game tests; also tested end to end against a local copy of the Worker with two "devices".
- **Phase 20: Online co-op** (up to 4 Heroes, 6-digit codes, through your Cloudflare Worker).
  - **Title → Co-op → Host a game** shows a 6-digit code; friends choose **Join** and type it. In the lobby everyone picks a Hero (the same Hero is allowed); the host picks the level and Swift Mode, and the host's Omens apply to everyone. **Start** opens once a friend has joined and everyone has a Hero.
  - The host's game runs the world; each player's own device moves their Hero, so moving never lags. Everyone sees the same enemies, shots, bosses, shrines, chests, points of interest, hazards, banners, and banter.
  - **Fairness rules from the design:** gods are personal (each player has their own 2 slots and buttons; everyone touching a shrine gets their own copy); one shared XP bar; on a level-up the game pauses and players pick their own cards one at a time (20 s each, the first picker rotates); every coin counts for every player, and the Trader spends only the buyer's share; a chest opens for the player who touched it; each player picks their own Boon after a boss.
  - **Revives:** at 0 HP you're downed and bleed out over 20 s; an ally standing beside you for 3 s (then 5 s) revives you at 30% HP; 2 revives each. After that you become a **Wandering Shade**: a ghost that still collects XP and gold for the team and gives allies nearby +10% god charge. The run ends when no one is left fighting.
  - Enemies get +60% HP and +50% spawns per extra player; bosses ×(1 + 0.75 per extra player). Players can't move more than about 1.5 screens apart. The pause menu doesn't pause co-op. If the host leaves, the run ends for everyone with a message.
  - The end screen shows your own recap plus a team summary. Co-op runs don't go on the leaderboard (it's for solo scores).
  - The Worker gets a second Durable Object type (`LobbyRoom`) that only passes messages between the players; nothing is stored after a game.
  - 11 new game tests and 8 new Worker tests (226 game tests and 37 Worker tests, all passing). Also played automatically with two copies of the game talking through a local copy of the Worker: lobby, level-up turns, downs and revives, gods and summons, a 400-enemy horde, and Medusa all matched on both screens.

### Reason
The owner asked to finish building the game through Phase 20 (co-op and cloud saves), using Cloudflare for both.

## Version 00.01.24
Date: 10/29/2026
Time: 12:47 PM

### Changes
- **Decisions review, round 1.** Marked your answers in `docs/DECISIONS.md`: 14 old decisions closed because later work replaced them; 22 approved; 5 batches of writing approved as draft text (lore check still to come). Questions 3, 5, 10, 11, and the tip placement are still open.
- **The Aegean Shore now has its own Greek monsters.** The Norse Draugr brutes and Muspel Spark bombers it borrowed are replaced by the **Spartoi** (armoured warriors who sprang from sown dragon's teeth) and **bronze bulls** (King Aeëtes' fire-breathing bulls that Jason yoked). Same strength as before. Their Bestiary text needs your review.
- **Whole-screen joystick.** On touch screens the joystick now works wherever you touch, except on a button; Settings can still limit it to the left or right side.
- **Bosses go through the lore check** like Heroes and gods, so a release build won't include a boss whose lore you haven't approved.
- `GAME_DESIGN.md` updated for these (walking through enemies, joystick, settings kept between runs, boss lore check, the two new Greek families).
- 3 new automated tests (208 in all).

### Reason
The owner answered the decisions questions.

## Version 00.01.23
Date: 10/29/2026
Time: 12:44 AM

### Changes
- **Review of the owner's Cloudflare and Suggest a Feature work.**
  - **Fix: the leaderboard could stop saving scores on Cloudflare's free plan.** The Worker wrote to its KV storage on every request, even just viewing the board, to count requests per player. The free plan allows about 1,000 KV writes a day, and after that score submissions failed with a server error. Now only sending (scores, suggestions) is counted, and if KV writes still fail, the score is saved anyway (on GitHub). Two new Worker tests cover this (22 in all, passing).
  - The suggestion form's two scripts now use tabs like every other script, and an empty reply from the server no longer prints extra engine errors.
  - Everything else checked out well: careful cleaning of player text, escaping before it reaches GitHub, @-mentions blocked, daily caps, and no personal data sent.

- **Phase 19: Polish (the parts that can be done without real art, music, or a phone).**
  - **Settings screen**, from the title screen and the pause menu. It has volume, text size, how see-through your own attack effects are (30–100%), screen shake and hit flash (Off / Low / Full), damage numbers on/off, element tags on damage numbers, colourblind-friendly element colours, auto-summon, auto-collect, touch control size, joystick side (left or right), banter on/off, and first-run tips on/off. Every change is saved at once.
  - **Screen shake** when you summon a god or break a boss's Guard, as the design describes. It's gentle, and you can turn it down or off.
  - **First-run tips**: a short line the first time you level up, see a shrine, hit a weakness, fill a god's meter, and have a Resonance ready. Each one shows only once, and Settings can turn them off or show them again.
  - **Phones with notches**: menus, the HUD, the god buttons, and pop-ups now stay inside the safe part of the screen.
  - **Exports** leave out the automated tests, the test tool, and the reference folder (the debug menu's test files stay).
  - **Lore checklist** (`docs/LORE_CHECK.md`): every launch Hero, god, and boss with its source, ready for you to approve. Nothing is marked verified until you say so.
  - Removed two stray files from an earlier bot test.
  - 9 new automated tests (205 in all, all passing).

### Reason
The owner asked to look over the Cloudflare and feature-suggestion code, then move on to the next phase.

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
- **Phase 17: The Two Lands** (the Egyptian level): desert, reeds, obelisks, and tombs, with a scarab-clasp chest seal.
  - **Hazards:** sandstorms and quicksand.
  - **Enemies:** scarab swarms, restless mummies, Shabti Guardians, and sand serpents.
  - **Bosses:** **Ammit** (10:00): every hit you take tips her scale, and a full tip means a devouring lunge. **Set** (20:00) shrinks your vision to a small circle in a sandstorm and strikes from its edge, then brings pulling cyclones. **Apep** (30:00) swallows one of your gods and uses its power against you. Hit the orb inside him while it glows to free the god; freeing Ra is the secret The Sun's Return.
  - Local gods Sekhmet and Ra. Draft lines for Set and Apep meeting Ra.
- **Phase 18: The Misty Isles** (the Irish level): green hills, bogs, and stone circles, with a Celtic-knot chest seal.
  - **Hazards:** mist banks that hide what's around you, and fairy rings that carry you to their partner ring.
  - **Enemies:** Redcaps, the Sluagh (swarms and flying hosts), Kelpies, and Fomorian casters.
  - **Bosses:** **Scáthach** (10:00) names each technique before she uses it (real hero-feats from the tales) and gets faster each time it repeats. Defeating her unlocks her as a Hero: each weapon card also levels another weapon. **Ferdiad** (20:00) fights across a slowing river ford, with horn-skin that blocks hits from the front; as Cú Chulainn, beat him without leaving the river for The Ford secret. **Balor of the Evil Eye** (30:00) sweeps a beam from his eye, so hide behind the stone circles; hit the open eye 5 times for Lugh's Sling.
  - Local gods Cernunnos and the Morrígan.
- 16 more automated tests (196 in all, all passing), including a full run through every level's three bosses.

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
