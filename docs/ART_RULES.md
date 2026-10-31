# Art rules: Hero sprites

**Status: draft.** Written from the first Hero (Heracles, 10/31/2026; second version after the owner's feedback that the first looked like "someone in a diaper": short, big-headed, in a short white tunic). It becomes the rule set for every other Hero once the owner approves how Heracles looks. Change these rules only with the owner's OK, and redraw Heracles if they change.

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
- **Drawn from shapes**: each Hero is built by a small script in `tools/art/` from simple shapes (hood, face, body, arm, clothes, legs, weapon), then the outline is added. Changing a part means changing one shape, not retyping rows.
- **Two shades per material**: a light colour and a shadow colour (light from the top-left). No gradients and no stray single pixels.
- **Clothing in strong, darker colours** (here a dark red chiton) so it never reads as underwear. Folds are vertical lines in the shadow colour.
- **Muscles as short lines**, not dots: a chest line and a stomach line in the skin shadow. Dots read as spots.
- **Every part has its own dark edge**, not just the outside of the figure: a dark line between the arm and the chest, a 1-pixel gap (filled by the outline) between the body and anything behind it (cloak) or held beside it (weapon). Parts must never run into each other.
- **A face that reads at a glance:** one dark eye pixel with a row of skin above it (the forehead) and skin around it. Nothing white touches the eye (it reads as a giant eyeball). Facial hair sits below it and is no more than 2 rows.
- **Cloaks and pelts read as fabric or fur**, never as a plank: they widen as they hang, have a ragged or folded edge, and show texture (lighter tufts or folds). Heracles' lion skin ends in the lion's hind paw with claws.
- **The signature weapon must be visible** and stand apart from the body and cloak: a different colour and value (lighter or darker), sticking out past the body.
- **Each Hero's iconic feature first.** Pick the one or two things people know them by, and make them big: Heracles' lion-skin hood and club.
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
| `c` / `C` | Signature weapon, light / shadow | #9a6232 / #553012 (club: handle in the hand, heavy rounded head by the feet, knots as dark marks) |
| `l` / `L` / `m` / `w` | Hero's own extras | lion pelt light / shadow / dark mane, white teeth |

Each pantheon later gets its own palette family (`GAME_DESIGN.md`: Art: Greek marble and bronze, Norse wood and iron, Egyptian sandstone and lapis, Celtic stone and green-gold).

## Frames
- `idle`: 1 frame.
- `walk`: 4 frames, played in turn while the Hero moves (one step every 6 game pixels walked; config `player.walk_frame_px`): left foot forward, standing, right foot forward, standing. Only the legs change.
- More frames later (attack, hurt) when the owner asks.

## Not done yet
- Mastery colour palettes (Hero select → Color) still tint only the placeholder square. With art, each Hero will need alternate palettes, using the same letters with different colours.
