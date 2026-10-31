# The shared Hero body for code-drawn sprites (docs/ART_RULES.md). Every Hero
# uses the same canvas, pose, arms, hand point, legs, and walking frames, so
# they all match; each Hero's own script only draws what's theirs (head, face,
# hair, clothes, footwear, extras). Then the outline is added and the art file
# written to data/art/<hero id>.json.
import json, os

W, H = 24, 34
HAND = (22, 17)           # where the held weapon's grip goes (front fist)
ANCHOR = (14, 32)         # under the middle of the feet
STANCE = (11, 15)         # back and front leg x when standing
WALK = [(10, 16), STANCE, (12, 14), STANCE]   # left foot forward, together, right foot forward, together


class Canvas:
    def __init__(self, w=W, h=H):
        self.w, self.h = w, h
        self.g = [["." for _ in range(w)] for _ in range(h)]

    def px(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.g[y][x] = c

    def rect(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.px(x, y, c)

    def row(self, y, x0, x1, c):
        self.rect(x0, y, x1, y, c)

    def outline(self):
        """A dark outline (o) round every filled pixel; returns the rows."""
        fill = [r[:] for r in self.g]
        for y in range(self.h):
            for x in range(self.w):
                if fill[y][x] == "." and any(0 <= x + dx < self.w and 0 <= y + dy < self.h and fill[y + dy][x + dx] != "."
                                             for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    self.g[y][x] = "o"
        return ["".join(r) for r in self.g]


def far_arm(c):
    """The far (left) arm hanging at the side, in the skin's shadow colour, with a fist."""
    c.rect(7, 14, 8, 20, "S"); c.px(8, 14, "s"); c.px(8, 15, "s")
    c.rect(7, 21, 8, 21, "s")


def weapon_arm(c):
    """The front arm bent forward, fist in front of the belly at HAND, holding the weapon ready."""
    c.rect(18, 14, 19, 17, "s"); c.rect(17, 15, 17, 17, "o"); c.px(19, 14, "S")
    c.rect(19, 18, 21, 18, "s"); c.px(19, 18, "S")
    c.rect(21, 17, 22, 18, "s")


def legs(c, back, front, footwear):
    """Two legs (6 pixels of skin below the clothing, rows 26-31); footwear(c, x0) draws on each."""
    for x0 in (back, front):
        c.rect(x0, 26, x0 + 2, 31, "s"); c.px(x0, 26, "S"); c.px(x0, 27, "S")
        footwear(c, x0)


def build(hero_id, draw, palette, doc, out_dir=None, recolor=None):
    """draw(canvas, back_leg, front_leg) draws one frame. Writes data/art/<hero_id>.json.
    recolor lists the palette letters of the Hero's clothes, which take the colour of a mastery palette
    (Hero select: Color; config heroes.mastery_palettes) while skin, hair and metal stay as they are."""
    def frame(legs_x):
        c = Canvas()
        draw(c, *legs_x)
        return c.outline()
    idle = frame(STANCE)
    walk = [idle if pose == STANCE else frame(pose) for pose in WALK]
    art = {"_doc": doc, "size": [W, H], "anchor": list(ANCHOR), "hand": list(HAND), "palette": palette,
           "recolor": list(recolor or []), "frames": {"idle": [idle], "walk": walk}}
    out_dir = out_dir or os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art")
    with open(os.path.join(out_dir, hero_id + ".json"), "w") as f:
        json.dump(art, f, indent=1)
    return art


def build_boss(boss_id, draw, palette, doc, size, anchor, walk_legs):
    """A boss's art (bigger than a Hero, drawn on its own canvas): draw(canvas, legs) draws one frame for each entry
    of walk_legs (the first is the standing pose). Writes data/art/bosses/<boss_id>.json."""
    def frame(legs):
        c = Canvas(*size)
        draw(c, legs)
        return c.outline()
    idle = frame(walk_legs[0])
    walk = [frame(legs) for legs in walk_legs[1:]]
    art = {"_doc": doc, "size": list(size), "anchor": list(anchor), "palette": palette,
           "frames": {"idle": [idle], "walk": walk}}
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "bosses")
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, boss_id + ".json"), "w") as f:
        json.dump(art, f, indent=1)
    return art


def ellipse(c, cx, cy, rx, ry, col):
    """Fills an ellipse (for boss bodies)."""
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                c.px(x, y, col)


def poly(c, pts, col):
    """Fills a polygon given as (x, y) corners (for boss bodies)."""
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    for y in range(int(min(ys)), int(max(ys)) + 1):
        for x in range(int(min(xs)), int(max(xs)) + 1):
            inside = False
            j = len(pts) - 1
            for i in range(len(pts)):
                (xi, yi), (xj, yj) = pts[i], pts[j]
                if (yi > y + 0.5) != (yj > y + 0.5) and x + 0.5 < (xj - xi) * (y + 0.5 - yi) / (yj - yi) + xi:
                    inside = not inside
                j = i
            if inside:
                c.px(x, y, col)


# --- Bosses who are also Heroes (Achilles, Scáthach): their Hero art holding their weapon, drawn bigger -----------

def compose(hero, weapon):
    """The Hero's frames with the weapon behind them at the hand (as the game draws a Hero), on one canvas, with the
    weapon's colours given letters the Hero's palette doesn't use. Returns (frames, palette, anchor)."""
    palette = dict(hero["palette"])
    spare = iter(c for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" if c not in palette)
    remap = {}
    for letter, colour in weapon["palette"].items():
        same = next((k for k, v in palette.items() if v == colour), None)
        remap[letter] = same or next(spare)
        palette[remap[letter]] = colour
    wx = hero["hand"][0] - weapon["grip"][0]
    wy = hero["hand"][1] - weapon["grip"][1]
    ww, wh = weapon["size"]
    hw, hh = hero["size"]
    x0, y0 = min(0, wx), min(0, wy)
    x1, y1 = max(hw, wx + ww), max(hh, wy + wh)
    w_rows = weapon["frames"]["idle"][0]

    def one(rows):
        g = [["."] * (x1 - x0) for _ in range(y1 - y0)]
        for y, row in enumerate(w_rows):
            for x, ch in enumerate(row):
                if ch != ".":
                    g[wy + y - y0][wx + x - x0] = remap[ch]
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch != ".":
                    g[y - y0][x - x0] = ch
        return ["".join(r) for r in g]

    frames = {name: [one(rows) for rows in hero["frames"][name]] for name in hero["frames"]}
    return frames, palette, [hero["anchor"][0] - x0, hero["anchor"][1] - y0], [x1 - x0, y1 - y0]


def scale(rows, k):
    return ["".join(ch * k for ch in row) for row in rows for _ in range(k)]



def build_hero_boss(hero_id, weapon_id, doc, scale_by=2):
    """Writes data/art/bosses/<hero_id>.json: the Hero's art (data/art/<hero_id>.json) holding the weapon
    (data/art/weapons/<weapon_id>.json), `scale_by` times as big, so players recognise the Hero they're fighting."""
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art")
    hero = json.load(open(os.path.join(root, hero_id + ".json")))
    weapon = json.load(open(os.path.join(root, "weapons", weapon_id + ".json")))
    frames, palette, anchor, size = compose(hero, weapon)
    art = {"_doc": doc, "size": [size[0] * scale_by, size[1] * scale_by],
           "anchor": [anchor[0] * scale_by + scale_by // 2, anchor[1] * scale_by + scale_by // 2], "palette": palette,
           "frames": {name: [scale(rows, scale_by) for rows in list_] for name, list_ in frames.items()}}
    os.makedirs(os.path.join(root, "bosses"), exist_ok=True)
    with open(os.path.join(root, "bosses", hero_id + ".json"), "w") as f:
        json.dump(art, f, indent=1)
    return art
