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
    def __init__(self):
        self.g = [["." for _ in range(W)] for _ in range(H)]

    def px(self, x, y, c):
        if 0 <= x < W and 0 <= y < H:
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
        for y in range(H):
            for x in range(W):
                if fill[y][x] == "." and any(0 <= x + dx < W and 0 <= y + dy < H and fill[y + dy][x + dx] != "."
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
