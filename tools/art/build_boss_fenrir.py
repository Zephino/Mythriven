# Fenrir, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_fenrir.py from tools/art/.
# Writes data/art/bosses/fenrir.json.
import math
import hero_kit as kit

DOC = ("Fenrir, boss (GAME_DESIGN.md: Midgard's Edge bosses; art 10/31/2026). Built by tools/art/build_boss_fenrir.py; "
       "rules in docs/ART_RULES.md. From Snorri Sturluson's Prose Edda, Gylfaginning 34 and 51: the monstrous wolf, "
       "Loki's son, bound by the gods with Gleipnir, a fetter 'smooth and soft as a silken ribbon', who breaks free at "
       "Ragnarok and goes with his jaws gaping, the upper against the sky and the lower against the earth. A huge grey "
       "wolf on four legs, snarling (owner 10/31/2026: a first version with a long boxy body, gaping jaws and the "
       "broken ribbon of Gleipnir round his neck was redone).")

SIZE, ANCHOR = (74, 54), (36, 52)
# Leg x offsets for each frame (standing, then 4 running frames): front pair, back pair.
WALK = [(0, 0), (3, -3), (0, 0), (-3, 3), (0, 0)]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "f": "#8a8e96", "F": "#5c6068", "D": "#3e424a",  # grey fur, shadow, dark back
    "l": "#c4c6ca",                                 # pale belly and throat
    "y": "#e8c040",                                 # eye
    "r": "#8a2020", "w": "#f0ead8",                 # mouth, teeth
}


def ellipse(c, cx, cy, rx, ry, col):
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                c.px(x, y, col)


def poly(c, pts, col):
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


def front_leg(c, x, col, shade):
    """A long, slender foreleg straight down from the shoulder, a paw."""
    poly(c, [(x - 1, 27), (x + 5, 27), (x + 4, 36), (x + 3, 47), (x, 47), (x, 36)], col)
    c.rect(x, 47, x + 4, 48, shade); c.px(x, 37, shade); c.px(x, 38, shade)


def hind_leg(c, x, col, shade):
    """A hind leg: a muscled thigh, the lower leg slanting back to the hock, then down to the paw."""
    ellipse(c, x + 3, 29, 5.5, 6, col)
    poly(c, [(x + 1, 32), (x + 7, 33), (x + 1, 41), (x + 2, 47), (x - 1, 47), (x - 2, 40)], col)
    c.rect(x - 1, 47, x + 3, 48, shade); c.px(x - 2, 40, shade); c.px(x - 1, 41, shade)


def draw(c, legs):
    front, back = legs
    # Far legs (behind, in shadow)
    hind_leg(c, 17 - back, "F", "D")
    front_leg(c, 44 + front, "F", "D")
    # Bushy tail hanging down behind, curving
    for i in range(16):
        t = i / 15
        ellipse(c, 13 - t * 6, 22 + t * 15 - t * t * 3, 3.6 - t * 1.4 + math.sin(t * 3.1) * 0.8, 3.2 - t * 1.0, "f")
    c.px(8, 34, "F"); c.px(9, 32, "F"); c.px(7, 36, "D")
    # Body: high shoulders, the back sloping down to the hips, a deep chest, the belly tucked up
    poly(c, [(13, 23), (19, 19), (31, 19), (42, 14), (49, 14), (54, 20), (55, 27), (51, 32), (44, 31), (34, 28),
             (25, 29), (16, 30)], "f")
    # Strong neck rising to the head
    poly(c, [(44, 15), (51, 8), (58, 8), (60, 16), (56, 25), (50, 20)], "f")
    for x in range(12, 60):                                # a darker saddle along the back
        for y in range(6, 24):
            if c.g[y][x] == "f" and (c.g[y - 1][x] == "." or c.g[y - 2][x] == "."):
                c.px(x, y, "D")
    poly(c, [(50, 20), (56, 22), (55, 28), (51, 31), (48, 27)], "l")   # pale chest
    poly(c, [(30, 27), (42, 29), (44, 31), (34, 29)], "F")             # shadow under the belly
    # Near legs
    hind_leg(c, 22 + back, "f", "F")
    front_leg(c, 49 - front, "f", "F")
    # Head: skull, pointed ears, a long tapering muzzle, a black nose, a snarl, a yellow eye
    ellipse(c, 58, 12, 5, 4.5, "f")
    poly(c, [(51, 8), (52, 1), (56, 7)], "F")                           # far ear
    poly(c, [(54, 9), (56, 0), (60, 8)], "f"); poly(c, [(55, 6), (56, 3), (57, 7)], "D")
    poly(c, [(60, 9), (70, 11), (71, 14), (68, 17), (60, 18)], "f")    # muzzle
    ellipse(c, 57, 9, 4, 3, "f")                                       # the rise of his brow above the muzzle
    c.px(57, 7, "D"); c.px(58, 7, "D"); c.px(59, 7, "D")
    c.rect(70, 11, 71, 12, "k")                                         # nose
    c.row(15, 62, 69, "k")                                              # the line of the mouth, drawn back
    c.px(66, 16, "w"); c.px(68, 16, "w"); c.px(64, 16, "w")             # bared fangs
    c.row(16, 61, 63, "r")
    c.px(60, 10, "y"); c.px(61, 10, "y"); c.px(61, 11, "k")
    poly(c, [(55, 14), (61, 17), (59, 20), (55, 19)], "l")              # pale cheek ruff


if __name__ == "__main__":
    kit.build_boss("fenrir", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/fenrir.json")
