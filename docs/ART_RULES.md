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

## Gods
- One file per god: `data/art/gods/<god id>.json`, built by `tools/art/build_god_<id>.py` (`kit.build_boss` with `folder="gods"`). A god without a file keeps their coloured dot or circle.
- Boss-sized (about 48 × 62), from myth descriptions and museum-era art (never Marvel, God of War, Hades, Smite and the like: `GAME_DESIGN.md`: Gods).
- Each god also has a **seated** frame on a **throne** in the style of their people (owner request 10/31/2026): Greek marble with gold, a Norse carved wooden high seat, Celtic carved oak with bronze knotwork, an Egyptian gilded throne with blue inlay and a lion's paw. `kit.build_boss(..., seated={...})` makes it from the standing frame: the body above the hips lowered onto the seat, thighs along it, shins down (`seated_frame` in `tools/art/hero_kit.py`).
- In the game the god sits on their throne at their shrine (it stands in for the altar; config `gods.throne_feet_px`), and appears in person in their trial: as the duel opponent (in place of the avatar's circle, flashing when hit), at the centre of an endurance trial, and as the one being chased (and their decoys) in a chase trial, facing the nearest player.

## Mastery colours
- Hero select → Color picks one of the colours mastery unlocks (config `heroes.mastery_palettes`: mastery 2–5 unlock colours 1–4; owner request 10/31/2026). It recolours the **Hero's clothes only**: each art file lists those palette letters under `recolor` (set in its build script), and they take the colour's hue and saturation while keeping their own brightness, so light cloth and its shadow stay apart. Skin, hair, metal and weapons keep their colours.
- A new Hero's script must pass `recolor=[...]` to `kit.build` with the letters of their main clothing.
