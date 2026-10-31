# Art rules: Hero sprites

**Status: draft.** Written from the first Hero (Heracles, 10/31/2026). It becomes the rule set for every other Hero once the owner approves how Heracles looks. Change these rules only with the owner's OK, and redraw Heracles if they change.

## Format
- One file per Hero: `data/art/<hero id>.json`. The game finds it by the Hero's id; a Hero without a file keeps the coloured-square placeholder.
- Each frame is rows of letters, **1 letter = 1 pixel**. `.` is see-through. Every other letter is a colour listed in `palette`.
- `size` is [width, height] and `anchor` is the pixel under the middle of the feet. The game places the anchor at the bottom of the Hero's body.
- Drawn **facing right**. The game mirrors it to face left.
- A test checks every file: all rows are the same width, all frames are the same height, every letter is in the palette, and the file is named after a real Hero.

## Size and scale
- **18 × 20 pixels** for a normal-sized Hero. The body is about 14 pixels wide and the head is about 8. Extra width is for the signature weapon.
- 1 art pixel = 1 game pixel. The camera zooms 2×, so a Hero is about 36 × 40 pixels on screen.
- Bigger or smaller Heroes (for example a giant) only when the myth says so, and with the owner's OK.

## Look
- **A dark outline** around the whole figure (`o`, a very dark brown, not black). It keeps Heroes readable against any ground.
- **Two shades per material**: a light colour and a shadow colour (light from the top-left). No gradients and no stray single pixels.
- **A face that reads at a glance:** one dark eye pixel, set under the brow, with skin around it. Facial hair or a helmet sits below or around the eye, never over it.
- **The signature weapon must be visible** and stand apart from the body and cloak: a different colour and value (lighter or darker), sticking out past the body.
- **Each Hero's iconic feature first.** Pick the one or two things people know them by, and make them big: Heracles' lion-skin hood and club.
- **Only from sources.** Clothing, weapons and symbols come from the Hero's myth and from historical and museum sources (see `GAME_DESIGN.md`: Art, and `docs/LORE_CHECK.md`). No stereotypes and no modern pop-culture versions. Write the sources in the file's `_doc`.

## Palette letters (shared where possible)
| Letter | Use | Heracles |
| --- | --- | --- |
| `o` | Outline | #2a1810 |
| `s` / `S` | Skin, light / shadow | #e8b080 / #b87a50 |
| `k` | Eye | #1a1010 |
| `h` | Hair and beard | #4a2a16 |
| `t` / `T` | Main cloth, light / shadow | #ece2c8 / #b8aa88 |
| `b` | Belt and sandals | #6a4020 |
| `c` / `C` | Signature weapon, light / shadow | #b07a40 / #5a3418 (club) |
| `l` / `L` / `m` / `w` | Hero's own extras | lion pelt light / shadow / dark mane, white teeth |

Each pantheon later gets its own palette family (`GAME_DESIGN.md`: Art: Greek marble and bronze, Norse wood and iron, Egyptian sandstone and lapis, Celtic stone and green-gold).

## Frames
- `idle`: 1 frame.
- `walk`: 4 frames, played in turn while the Hero moves (one step every 6 game pixels walked; config `player.walk_frame_px`): left foot forward, standing, right foot forward, standing. Only the legs change.
- More frames later (attack, hurt) when the owner asks.

## Not done yet
- Mastery colour palettes (Hero select → Color) still tint only the placeholder square. With art, each Hero will need alternate palettes, using the same letters with different colours.
