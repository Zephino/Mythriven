# Art rules: Hero sprites

**Status: approved** by the owner on 10/31/2026, after Heracles (the first Hero; his first version looked like "someone in a diaper": short, big-headed, in a short white tunic). These are the rules for every Hero. Change them only with the owner's OK, and redraw the Heroes already made if they change.

## Format
- One file per Hero: `data/art/<hero id>.json`. The game finds it by the Hero's id; a Hero without a file keeps the coloured-square placeholder.
- Each frame is rows of letters, **1 letter = 1 pixel**. `.` is see-through. Every other letter is a colour listed in `palette`.
- `size` is [width, height] and `anchor` is the pixel under the middle of the feet. The game places the anchor at the bottom of the Hero's body.
- Drawn **facing right**. The game mirrors it to face left.
- A test checks every file: all rows are the same width, all frames are the same height, every letter is in the palette, and the file is named after a real Hero.

## Size and proportions
- **24 × 34 pixels** canvas for a normal-sized Hero. The figure is about 32 pixels tall; the extra width is for the signature weapon.
- **Heroic proportions, not cute:** the head (hood or helmet included) is about a quarter of the height. Legs are at least 6 pixels long below the clothing, and the clothing reaches the knees or lower. No short white "nappy" garments.
- 1 art pixel = 1 game pixel. The camera zooms 2×, so a Hero is about 48 × 68 pixels on screen.
- Bigger or smaller Heroes (for example a giant) only when the myth says so, and with the owner's OK.

## Look
- **A dark outline** around the whole figure (`o`, a very dark brown, not black), added automatically around every filled pixel. It keeps Heroes readable against any ground.
- **Drawn from shapes on one shared body**: `tools/art/hero_kit.py` holds what every Hero shares (canvas, pose, far arm, weapon arm and hand point, legs, the 4 walking frames, the outline, writing the file). Each Hero's own script (`tools/art/build_<hero id>.py`) only draws what's theirs: head, face, hair, clothes, footwear, extras. Run it with `python3 tools/art/build_<hero id>.py` from `tools/art/`.
- **Hair is one solid mass with a shaped edge** (spikes, waves, braids), coloured in bands, never single-pixel strands (each gets its own outline and turns into a checkerboard). Cú Chulainn's is built from overlapping spike wedges around his head, coloured outward from the scalp.
- **Two shades per material**: a light colour and a shadow colour (light from the top-left). No gradients and no stray single pixels.
- **Clothing in strong, darker colours** (here a dark red chiton) so it never reads as underwear. Folds are vertical lines in the shadow colour.
- **Muscles as short lines**, not dots: a chest line and a stomach line in the skin shadow. Dots read as spots.
- **Both arms show.** The far arm hangs on the far side in the skin's shadow colour (it's further away), with a dark edge between it and the chest.
- **Every part has its own dark edge**, not just the outside of the figure: a dark line between the arm and the chest, a 1-pixel gap (filled by the outline) between the body and anything behind it (cloak) or held beside it (weapon). Parts must never run into each other.
- **A face that reads at a glance:** one dark eye pixel with a row of skin above it (the forehead) and skin around it. Nothing white touches the eye (it reads as a giant eyeball). Facial hair sits below it and is no more than 2 rows.
- **Cloaks and pelts read as fabric or fur**, never as a plank: they widen as they hang, have a ragged or folded edge, and show texture (lighter tufts or folds). Keep them only if they help: the owner had Heracles' lion-skin cloak removed, since a long strip behind a small figure muddies the silhouette, and later his lion hood too.
- **The weapon must be visible** and stand apart from the body: a different colour and value, sticking out past the body (see Weapons).
- **Each Hero's iconic feature first.** Pick the one or two things people know them by, and make them big: Heracles' club and build, Achilles' crested helmet and great shield. Leave out anything that muddies the silhouette.
- **Skin tone fits the Hero's people and region**, from sources where they say, else what's typical there, never a default. Each Hero's script sets its own `s` / `S` and notes why (Heracles: Mediterranean; Cú Chulainn: fair Irish; Väinämöinen: fair, weathered Finnic north). Check it next to the other Heroes.
- **Only from sources.** Clothing, weapons and symbols come from the Hero's myth and from historical and museum sources (see `GAME_DESIGN.md`: Art, and `docs/LORE_CHECK.md`). No stereotypes and no modern pop-culture versions. Write the sources in the file's `_doc`.

## Palette letters (shared where possible)
| Letter | Use | Heracles |
| --- | --- | --- |
| `o` | Outline | #24160e |
| `s` / `S` | Skin, light / shadow | #e2a676 / #b0724a |
| `k` | Eye | #140c08 |
| `h` | Hair and beard | #3e2414 |
| `H` | Hair and beard shadow | #2a180c |
| `r` / `R` | Main cloth, light / shadow | #a83a2c / #7a2620 (dark red chiton) |
| `b` / `y` | Belt and sandals / metal buckle | #5c3a1c / #d8b048 |
| other letters | Hero's own extras | (Heracles has none since his lion hood was removed) |

Each pantheon later gets its own palette family (`GAME_DESIGN.md`: Art: Greek marble and bronze, Norse wood and iron, Egyptian sandstone and lapis, Celtic stone and green-gold).

## Weapons
- A Hero **holds the weapon they use most** (owner request 10/31/2026): the highest level among their weapons that have a picture. On a tie, the one they got first, so every Hero starts holding their signature weapon. Spells (Ember, Frost, Spark, Breeze, Glimmer, Shade) aren't held, except where the myth gives the spell an object: Väinämöinen's Runo Song is shown as his kantele (Kalevala runos 40 and 44). An evolved weapon uses its base weapon's picture until it gets its own.
- Weapons are their own pictures in `data/art/weapons/<weapon id>.json`, built by `tools/art/build_weapons.py`: each drawn pixel by pixel, upright, with its **grip** marked, then tipped forward and outlined.
- **Every weapon looks like itself** (owner request 10/31/2026): no shared pictures. Each has its own silhouette and colours from its source (the leaf-shaped bronze xiphos; Excalibur's ornate gold guard, jewelled pommel and shining edge; Gáe Bolg's barbs; Achilles' great ash spear with its bronze head; Scáthach's dark-shafted Irish spear with bronze socket rings; the javelin's throwing loop; the yew longbow, Atalanta's recurved bow, Odysseus' horn bow).
- The Hero's art has no weapon, and marks its **hand**: the pixel in the front fist. The weapon stays **clear of the body**, with at least a 1-pixel gap from the clothing and legs (owner request 10/31/2026). The game draws the weapon behind the Hero with its grip on the hand, so the fingers wrap round it.
- **Held ready, never dragged** (owner requests 10/31/2026): the weapon arm bends forward with the fist in front of the belly. Swords, clubs, hammers and axes are raised, blade or head up and tipped forward (about 1 pixel forward for every 2 up). Spears, javelins and bows stand upright, tipped forward about 1 in 8. A sling hangs from the hand. The handle passes through the fist. (Hanging weapons tilted at the side looked like he was dragging them.)
- Shared weapon colours: wood `c`/`C`, blade `e`/`E`, bronze fittings `g`/`G`, leather `b`, iron heads `i`/`I`, bright gold `u` (Excalibur), bowstring and strings `w`.
- **Attacks follow what the weapon is** (owner rule 10/31/2026): spears jab (their picture shoots out from the hand and draws back); javelins are thrown and fly as their own picture; bows stay in the hand and shoot arrows; swords and clubs swing from the hand (their picture sweeps through the swing); hammers come down from overhead and smash the ground with a shockwave; axes, discs and sling-stones fly spinning. Everything starts from the Hero's hand.
- A weapon must fit the Hero's culture: Tomoe Gozen's Sword and Bow is a curved Japanese tachi, not the Greek sword.
- **Armour reads as plates**: rows of plates with a lighter top edge, joined by dotted cord stitches (solid stripes read as a striped shirt).

## Frames
- `idle`: 1 frame.
- `walk`: 4 frames, played in turn while the Hero moves (one step every 6 game pixels walked; config `player.walk_frame_px`): left foot forward, standing, right foot forward, standing. Only the legs change.
- More frames later (attack, hurt) when the owner asks.

## Bosses
- One file per boss: `data/art/bosses/<enemy id>.json`, built by `tools/art/build_boss_<id>.py` with `kit.build_boss` (its own canvas size, anchor, and walking poses). A boss without a file keeps its circle.
- **Bigger than Heroes** (owner OK 10/31/2026: bosses may be bigger than normal so they look better). Medusa is 46 × 58 on a body of radius 18 (no wings, and a serpent's tail in place of legs: both owner requests. The tail goes against the sources on purpose: the ancient Medusa has a woman's legs; the tail is the well-known modern image.)
- The same rules as Heroes: outline, two shades per material, every part with its own dark edge, solid masses (Medusa's serpents each get a dark edge so they don't run into each other), and only from sources, written in the file's `_doc`.
- A boss who is also a Hero (Achilles, Scáthach) is their Hero art holding their signature weapon, drawn twice as big (`kit.build_hero_boss` in `tools/art/hero_kit.py` composes it), so players recognise them. Rebuild it after changing the Hero's art.
- In the game the boss's art replaces its circle (BossController draws it above the horde, facing the way it moves, walking while it moves, flashing white when hit and tinted by statuses). A boss with art has no red marker ring (owner request 10/31/2026: the sprite stands out by itself); the arrow at the screen edge still points to it when it's off screen.

## Spells
- Spells are not held (see Weapons), but they look like what they are (owner request 10/31/2026). Every spell or infused shot without its own picture flies as its element's: a fireball (fire), an ice shard (ice), a bolt (lightning), a spinning gust (wind), a mote of light with four rays (holy), a swirling shadow orb (dark), a water drop (water), a tumbling stone (earth), a spinning gold coin (fortune). Pictures in `data/art/projectiles/element_<element>.json`, built by `tools/art/build_spells.py`. Runo Song's verses fly as fire, ice and lightning in turn; Glimmer's lights circle the Hero spinning.
- Spark and Tempest call a jagged lightning bolt down from the sky onto each spot they strike (config `effects.bolt_height_px`); Shade and Oblivion show wisps of shadow swirling round the Hero.
- Evolved spells look distinct (owner request 10/31/2026): Inferno flies as a great white-hot fireball, Absolute Zero as a spinning snowflake, Cyclone as a big whirl of wind, Judgment as a blazing eight-rayed star (`data/art/projectiles/<weapon id>.json`, from `EVOLVED` in `tools/art/build_spells.py`). Tempest's bolts are thicker with forks; Oblivion leaves a dark pool under twice the wisps.
- Every spell hit bursts in its element's style (`scripts/combat/effects.gd` `_draw_burst`): flames and embers, ice shards, crackling sparks, a splash, a curling puff, a star of light, shadow collapsing in, pebbles and dust, glints of gold. Evolved spells' bursts are bigger. Reactions have their own: lightning arcing out (Conduct), billowing steam (Steam Burst), flying shards (Shatter), a spreading gust (Spread). Config `effects.burst_px`, `effects.burst_s`, `effects.reaction_s`.

## Enemy shots
- Every enemy and boss shot keeps its dark outline (GAME_DESIGN.md: Readable bullets) and looks like its element (owner request 10/31/2026): a short fading trail (`enemies.shot_trail_steps`), a bright core, and its element's mark: a flame tail (fire), a point of ice (ice), crackling sparks (lightning), a ripple (water), a rough tumbling stone (earth), a black heart (dark), little rays (holy), a curl (wind). Shots without an element stay red. Drawn in `scripts/enemies/enemy_projectiles.gd`.

## Pickups
- Pictures in `data/art/pickups/`, built by `tools/art/build_pickups.py`. XP gems, gold coins and ambrosia (a little two-handled cup, Odyssey 5.93) are drawn in light greys and tinted by their colours (`xp.orb_colors` by tier, `pickups.gold_color`, `pickups.ambrosia_color`); their `*_size_px` is now the picture's height. Chests are wooden and iron-bound; big chests (bosses, points of interest) are bound with gold (`chests.art_scale`). The golden apple of Atalanta's race is here too.

## Summons
- Summon pictures in `data/art/summons/`, built by `tools/art/build_summons.py`, each from its source in its `_doc`: Cernunnos' stag (Gundestrup cauldron), Mjölnir with its short handle (Skáldskaparmál), the Morrígan's crow (Táin Bó Cúailnge), Ra's sun barque (Book of the Dead, Amduat).
- Drawn in `scripts/gods/summon_layer.gd`: Tyche's wheel turns round the Hero throwing coins; stags gallop across; the hammer spins out and back trailing lightning; ice arrows rain over a frosted screen; Sekhmet's wind is a scorching band of streaking sand and embers; Poseidon's wave has a foaming crest; the sun barque sails over in its glow; crows sweep across and circle the fated. Resonances (`scripts/gods/resonance_layer.gd`): heat and blizzard bands, a frozen wave, rain with lightning leaping between the soaked, a blazing sun for the Eye of Ra.

## Boss specials
- Shared warnings (`scripts/bosses/pattern_runner.gd`) stay orange for areas and red for "about to fire" (GAME_DESIGN.md: Telegraphs): sparks gather into the boss before a burst; sweeps have edges and chevrons showing their direction; charges a dashed line and an arrowhead; strikes a second ring closing in and a cross.
- Each boss's own: Medusa's victims stand as stone figures and her eyes blaze as the gaze builds; Kronos' slowed time is a clock face with sweeping hands; Fenrir's posts are wooden with chains link by link; Balor's standing stones and a layered beam from his eye; Set's whirlwinds of sand; flames along Surtr's burning ring; water running across Ferdiad's ford; flames round Achilles in his rage.

## Hero traits
- Cú Chulainn rises and falls on his leap (`heroes.leap_height_px`), his shadow shrinking under him, with dust on landing. Väinämöinen's verses circle him as motes of light (`heroes.verse_color`). Tomoe Gozen kicks up dust as her momentum builds, and streaks of speed when she charges (`heroes.dust_color`). Achilles shows a gold glint where his front turns a blow and a red flash at the heel when struck from behind. Arthur's raised shield is a curved band with a rim and a boss. Atalanta's goal is a stone turning post, as on a Greek race-course, and her apple a golden apple. Odysseus' traps are pits ringed with stakes; his decoy is himself in a beggar's rags (Odyssey 13), faded. Heracles gets a burst of light on each Labor done; Scáthach a glint of gold when a lesson raises a weapon.

## Ground
- Each level's ground types are 16 x 16 tiles, two variants each, in `data/art/ground/<tileset id>.json`, built by `tools/art/build_ground.py` from the level's own ground colours in `levels.json`: paving, rock, earth, grass, flowers, pine needles, snow, sand, dune ripples, reeds, bog and heather. `scripts/world/level_art.gd` uses them; a level without them keeps plain coloured tiles.

## Scenery
- Each decoration has a picture in `data/art/scenery/<decoration id>.json`, built by `tools/art/build_scenery.py`, standing on the bottom of its spot: olive tree, broken column, marble ruin (Aegean Shore); snowy pine, painted runestone, longhouse ruin (Midgard's Edge); obelisk, rock-cut tomb, papyrus (The Two Lands); standing stone, stone circle, gorse (The Misty Isles).

## Hazards and ground patches
- Thunderstorm strikes crackle while they build and land as a bolt from the sky (shared in co-op). Weather blows particles across the screen: snow (blizzard), streaks of sand (sandstorm), drifting banks of mist; levels.json hazard `particles` and `particle_color`, config `world.weather_particles` and `world.weather_particle_speed_px_s`.
- Ground patches are drawn as what they are (GAME_DESIGN.md): frozen ponds (slide), quicksand turning round a sinking middle (slow), fairy rings of little mushrooms with rising motes (teleport). The gods' ground effects show as thorns (earth) or flames (fire).

## Points of interest
- Ancient Ruins are a ring of the level's own ruin (columns, runestones, obelisks or standing stones); a Dragon's Hoard is a heap of gold round a gold-bound chest; a Monster's Lair has a dark den mouth with bones; the Wandering Trader has a stall with a striped awning.

## Menus
- Every panel and button is framed in dark stone with a bronze trim (`data/art/ui/frames.json`, built by `tools/art/build_ui.py`): 12 x 12 frames stretched by their 4 px edges, drawn at `ui.frame_scale`. Normal, hover, pressed, focus (a bright bronze outline over the button) and disabled (grey). `scripts/ui/ui_theme.gd` sets them on the default theme, so every screen uses them without its own styling; button text is cream (`ui.button_*_text_color`).
- Icons (`data/art/ui/icons.json`): one per passive, from its name or source (Hermes' winged sandals, the obol paid to Charon, Perseus' polished shield, Tyr's hand), plus crit. Level-up cards show the weapon's picture (a spell's flying picture), the passive's icon, the icon of the passive that raises the same stat, a coin for gold and ambrosia for healing, all centred on a square at `ui.icon_px`.
- Hero select shows each Hero's picture (`ui.portrait_scale`); the title screen shows the unlocked Heroes standing in a row (`ui.title_hero_scale`); the god buttons show their gods; the banter bubble shows the speaker over their colour.

## Statuses
- Enemies show their statuses as small marks over their picture (`scripts/enemies/enemy_status_marks.gd`): flames (Burn), frost specks (Chill, more with more stacks), a block of ice (Frozen), sparks (Shock), drips (Soaked), rising bubbles (Poison, more with more stacks), a halo (Smite), a dark swirl (Hex), circling stars (Stun). Only enemies on screen, up to `enemies.status_marks_max`. The status colour tints the picture lightly (`enemies.art_status_tint`) so the marks and the art both show.

## Enemies
- One file per enemy type: `data/art/enemies/<enemy id>.json`, built per level by `tools/art/build_enemies_<level>.py` (`kit.build_boss` with `folder="enemies"`): a standing frame and 4 moving frames (legs stepping, wings beating, or a ghost bobbing). An enemy without a file keeps its circle.
- Sized to their body: small swarms about 14 × 18, ordinary enemies about 14-26 wide, elites up to about 40 × 54. Feet at the bottom of the body; they face the way they move.
- From the source in `data/enemies.json` (`myth_source`) and Greek, Norse, Egyptian or Irish art, written in the file's `_doc`.
- Drawn hundreds at a time from one atlas (`scripts/art/enemy_sprites.gd`): hit flashes, statuses and wind-ups tint the picture (config `enemies.art_*_tint`).

## Gods
- One file per god: `data/art/gods/<god id>.json`, built by `tools/art/build_god_<id>.py` (`kit.build_boss` with `folder="gods"`). A god without a file keeps their coloured dot or circle.
- Boss-sized (about 48 × 62), from myth descriptions and museum-era art (never Marvel, God of War, Hades, Smite and the like: `GAME_DESIGN.md`: Gods).
- Each god also has a **seated** frame on a **throne** in the style of their people (owner request 10/31/2026): Greek marble with gold, a Norse carved wooden high seat, Celtic carved oak with bronze knotwork, an Egyptian gilded throne with blue inlay and a lion's paw. `kit.build_boss(..., seated={...})` makes it from the standing frame: the body above the hips lowered onto the seat, thighs along it, shins down (`seated_frame` in `tools/art/hero_kit.py`).
- **Shrines are built at random from parts** (owner request 10/31/2026): each people has a set in `data/art/shrines/<pantheon>.json` (built by `tools/art/build_shrine_parts.py`): two floor tiles, a wall, a column, an altar, a fire bowl and a decoration (Greek marble temple with Doric columns and an amphora; Norse timber hall with carved posts, a stone hörgr and a painted shield; Egyptian sandstone temple with painted walls, papyrus columns and an obelisk; Celtic drystone enclosure with spiral-carved standing stones and a cauldron). `scripts/gods/shrine_layout.gd` lays out a shrine from a seed: 7, 9 or 11 cells wide and 5-7 deep, walls on three sides and an entrance with columns at the front, the throne at the back, the altar (the shrine's position) in the middle between two fire bowls, and 1-3 decorations.
- The god either sits on their throne or walks about inside the shrine on a loop that never leaves it (the empty throne then stands at the back; each god art has a `throne` frame for it). Everything is drawn back to front. The walls are only pictures: they don't block anyone.
- **The shrine is a dungeon entrance** (owner decisions 10/31/2026): in the world it is drawn as an entrance (floor, a wall with a dark doorway, columns and fire bowls). Inside, `scripts/gods/shrine_dungeon.gd` builds a dungeon from the same parts (a maze of 2-tile-wide corridors, sometimes knocked through into loops and halls) ending in the throne room above. Walls block players and monsters inside the dungeon; monsters spawn in the corridors until the party reaches the throne room.
- Gods appear in person in their trial: as the duel opponent (in place of the avatar's circle, flashing when hit), at the centre of an endurance trial, and as the one being chased (and their decoys) in a chase trial, facing the nearest player.

## Mastery colours
- Hero select → Color picks one of the colours mastery unlocks (config `heroes.mastery_palettes`: mastery 2–5 unlock colours 1–4; owner request 10/31/2026). It recolours the **Hero's clothes only**: each art file lists those palette letters under `recolor` (set in its build script), and they take the colour's hue and saturation while keeping their own brightness, so light cloth and its shadow stay apart. Skin, hair, metal and weapons keep their colours.
- A new Hero's script must pass `recolor=[...]` to `kit.build` with the letters of their main clothing.
