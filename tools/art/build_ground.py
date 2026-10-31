# Ground tiles (docs/ART_RULES.md: Ground): one 16 x 16 tile per ground type in each level, two variants each so
# the ground doesn't look like a grid. Colours come from the level's own ground colours in data/levels.json
# (placeholder_color, placeholder_dots); this adds texture: cobbles, pebbles, grass blades, flowers, pine needles,
# snow sparkle, sand ripples, reeds, bog pools. Run: python3 build_ground.py from tools/art/.
# Writes data/art/ground/<tileset id>.json: frames named by ground id, each [variant 0, variant 1].
import json, os, random

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
N = 16


def hexc(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


def shade(c, f):
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(v * f))) for v in hexc(c))


class Tile:
    def __init__(self):
        self.g = [["b"] * N for _ in range(N)]

    def px(self, x, y, c):
        self.g[y % N][x % N] = c


def speckle(t, rnd, count, letters):
    for _ in range(count):
        t.px(rnd.randrange(N), rnd.randrange(N), rnd.choice(letters))


def cobbles(t, rnd):
    """Stone paving: rows of worn blocks with dark joints, each lit on its top edge."""
    for row in range(4):
        y0 = row * 4; off = (row % 2) * 4 + rnd.randrange(2)
        for x in range(N):
            t.px(x, y0, "d")
        for k in range(2):
            x0 = off + k * 8
            for y in range(y0, y0 + 4):
                t.px(x0, y, "d")
            for x in range(x0 + 1, x0 + 7):
                t.px(x, y0 + 1, "l")
    speckle(t, rnd, 4, "D")


def rock(t, rnd):
    """Bare rock: rough grey with cracks and lighter knobs."""
    speckle(t, rnd, 18, "dl")
    x, y = rnd.randrange(N), rnd.randrange(N)
    for _ in range(9):
        t.px(x, y, "D"); x += rnd.choice((1, 1, 0)); y += rnd.choice((1, 0, -1))


def dirt(t, rnd):
    """Earth with pebbles and darker clods."""
    speckle(t, rnd, 16, "d")
    for _ in range(3):
        x, y = rnd.randrange(N), rnd.randrange(N)
        t.px(x, y, "l"); t.px(x + 1, y, "l"); t.px(x, y + 1, "d")


def grass(t, rnd, flowers=False):
    """Grass: short blades lit at the tip; with flowers, a few blooms in the level's flower colour."""
    speckle(t, rnd, 10, "d")
    for _ in range(9):
        x, y = rnd.randrange(N), rnd.randrange(N)
        t.px(x, y, "d"); t.px(x, y - 1, "l")
    if flowers:
        for _ in range(3):
            x, y = rnd.randrange(N), rnd.randrange(N)
            t.px(x, y, "a"); t.px(x + 1, y, "a"); t.px(x, y + 1, "a"); t.px(x + 1, y + 1, "y")


def needles(t, rnd):
    """A forest floor of fallen pine needles."""
    speckle(t, rnd, 8, "d")
    for _ in range(10):
        x, y = rnd.randrange(N), rnd.randrange(N)
        c = rnd.choice("al")
        t.px(x, y, c); t.px(x + 1, y + 1, c)


def snow(t, rnd, packed=False):
    """Snow: soft drifts lit on top, glints of ice; packed snow is flatter and greyer."""
    speckle(t, rnd, 6 if packed else 4, "d")
    for _ in range(2 if packed else 3):
        x, y = rnd.randrange(N), rnd.randrange(N)
        for k in range(4):
            t.px(x + k, y, "l")
    speckle(t, rnd, 1 if packed else 3, "a")


def sand(t, rnd, dune=False):
    """Sand: fine grains; on dunes, wind ripples."""
    speckle(t, rnd, 14, "dl")
    if dune:
        for row in (3, 9, 14):
            for x in range(N):
                t.px(x, row + (1 if (x // 3) % 2 else 0), "a")


def reeds(t, rnd):
    """Reeds by the water: upright stems with dark heads."""
    speckle(t, rnd, 6, "d")
    for _ in range(5):
        x, y = rnd.randrange(N), rnd.randrange(N)
        for k in range(4):
            t.px(x, y + k, "l" if k < 3 else "d")
        t.px(x, y - 1, "a")


def bog(t, rnd):
    """Bog: dark wet ground with a still pool and tufts."""
    speckle(t, rnd, 10, "d")
    x, y = rnd.randrange(N), rnd.randrange(N)
    for dx in range(-2, 3):
        for dy in range(-1, 2):
            if abs(dx) + abs(dy) < 3:
                t.px(x + dx, y + dy, "a")
    t.px(x - 1, y - 1, "l")


def heather(t, rnd):
    """Heather: grass thick with small purple flowers."""
    grass(t, rnd)
    for _ in range(7):
        x, y = rnd.randrange(N), rnd.randrange(N)
        t.px(x, y, "a"); t.px(x, y - 1, "y")


STYLES = {"stone": cobbles, "dirt": dirt, "grass": grass, "flowers": lambda t, r: grass(t, r, True), "rock": rock,
          "pine_floor": needles, "packed_snow": lambda t, r: snow(t, r, True), "snow": snow, "sand": sand,
          "dune": lambda t, r: sand(t, r, True), "reeds": reeds, "bog": bog, "dark_grass": grass, "heather": heather}

if __name__ == "__main__":
    levels = [l for l in json.load(open(os.path.join(ROOT, "data", "levels.json"))) if isinstance(l, dict)]
    out_dir = os.path.join(ROOT, "data", "art", "ground")
    os.makedirs(out_dir, exist_ok=True)
    for level in levels:
        tiles = level["tileset"]
        letters = iter("ABCEFGHIJKLMNOPQRSTUVWXZ")
        palette, frames = {}, {}
        for ground in tiles["ground"]:
            base = ground["placeholder_color"]; accent = ground.get("placeholder_dots") or shade(base, 1.3)
            local = {"b": base, "d": shade(base, 0.86), "D": shade(base, 0.7), "l": shade(base, 1.12), "a": accent,
                     "y": "#ffe878" if ground["id"] in ("flowers",) else shade(accent, 1.25)}
            keymap = {}
            for k, c in local.items():
                letter = next(letters) if c not in palette.values() else [L for L, v in palette.items() if v == c][0]
                palette[letter] = c; keymap[k] = letter
            style = STYLES.get(ground["id"], dirt)
            variants = []
            for v in range(2):
                rnd = random.Random("%s/%s/%d" % (tiles["id"], ground["id"], v))
                t = Tile(); style(t, rnd)
                variants.append(["".join(keymap[c] for c in row) for row in t.g])
            frames[ground["id"]] = variants
        data = {"_doc": "Ground tiles for %s (docs/ART_RULES.md: Ground), built by tools/art/build_ground.py from the level's "
                        "ground colours. Each ground type has two variants." % tiles["id"],
                "size": [N, N], "palette": palette, "frames": frames}
        with open(os.path.join(out_dir, tiles["id"] + ".json"), "w") as f:
            json.dump(data, f, indent=1)
        print("wrote", tiles["id"], len(frames), "ground types,", len(palette), "colours")
