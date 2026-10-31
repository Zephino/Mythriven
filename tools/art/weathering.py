# Weathering (owner request 10/31/2026: less cartoony; the shrines' look, used for the whole world).
# Every part is aged after it's drawn: the black outline becomes a soft dark edge in the part's own colour, surfaces
# get a fine grain, light from above (brighter at the top, darker at the foot), chips and stains, and colours lose a
# little of their brightness. Letters in `keep` (fire, flowers) are left as drawn. The colours are then gathered into
# a new palette. Frames named in FLAT get no light bands (they lie flat).
import random

# Frames that lie flat on the ground get no light bands (they'd look like rows of bricks when tiled).
FLAT = ("floor", "top", "plank", "plank_broken")

KEYS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&*+-=?@^_~<>:;,|/()[]{}"


def _rgb(h):
    return [int(h[i:i + 2], 16) for i in (1, 3, 5)]


def weather(pal, frames, seed, keep=(), outline="o"):
    """Ages `frames`; returns (palette, frames). Uses the finest colour steps that fit in one palette."""
    for step in (6, 8, 10, 12, 16):
        try:
            return _weather(pal, frames, seed, keep, outline, step)
        except IndexError:
            continue
    raise ValueError("too many colours to weather")


def _weather(pal, frames, seed, keep, outline, step):
    rnd = random.Random(seed)
    keep = set(keep)
    out_frames, colours = {}, {}

    def key_of(c):
        c = tuple(max(0, min(255, int(round(v / step) * step))) for v in c)
        if c not in colours:
            colours[c] = KEYS[len(colours)]
        return colours[c]

    for name, pictures in frames.items():
        aged = []
        for rows in pictures:
            h, w = len(rows), len(rows[0])
            grid = [[None if ch == "." else (ch, _rgb(pal[ch])) for ch in row] for row in rows]
            new = []
            for y in range(h):
                line = ""
                for x in range(w):
                    cell = grid[y][x]
                    if cell is None:
                        line += "."
                        continue
                    ch, c = cell
                    if ch in keep:
                        line += key_of(c)
                        continue
                    if ch == outline:
                        # A soft edge: the darkest neighbouring colour, much darker, instead of black.
                        near = [grid[y + dy][x + dx][1] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                                if 0 <= x + dx < w and 0 <= y + dy < h and grid[y + dy][x + dx] is not None
                                and grid[y + dy][x + dx][0] != outline and grid[y + dy][x + dx][0] not in keep]
                        base = min(near, key=sum) if near else c
                        line += key_of([v * 0.42 for v in base])
                        continue
                    grey = sum(c) / 3.0
                    c = [v * 0.85 + grey * 0.15 for v in c]                               # a little less vivid
                    # Light from above, in a few bands; a fine grain of three tones.
                    light = 1.06 - 0.16 * round(3 * y / max(h - 1, 1)) / 3 if name not in FLAT else 1.0
                    grain = rnd.choice((0.95, 1.0, 1.0, 1.05))
                    stain = 0.86 if rnd.random() < 0.06 else 1.0                          # chips and stains
                    line += key_of([v * light * grain * stain * 0.94 for v in c])
                new.append(line)
            aged.append(new)
        out_frames[name] = aged
    return {k: "#%02x%02x%02x" % c for c, k in colours.items()}, out_frames
