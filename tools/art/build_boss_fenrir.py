# Fenrir, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_fenrir.py from tools/art/.
# Writes data/art/bosses/fenrir.json.
import math
import hero_kit as kit

DOC = ("Fenrir, boss (GAME_DESIGN.md: Midgard's Edge bosses; art 10/31/2026). Built by tools/art/build_boss_fenrir.py; "
       "rules in docs/ART_RULES.md. From Snorri Sturluson's Prose Edda, Gylfaginning 34 and 51: the monstrous wolf, "
       "Loki's son, bound by the gods with Gleipnir, a fetter 'smooth and soft as a silken ribbon', who breaks free at "
       "Ragnarok and goes with his jaws gaping, the upper against the sky and the lower against the earth. A huge grey "
       "wolf on four legs, jaws open, the broken ribbon of Gleipnir still round his neck.")

SIZE, ANCHOR = (74, 54), (36, 52)
# Leg x offsets for each frame (standing, then 4 running frames): front pair, back pair.
WALK = [(0, 0), (3, -3), (0, 0), (-3, 3), (0, 0)]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "f": "#8a8e96", "F": "#5c6068", "D": "#3e424a",  # grey fur, shadow, dark back
    "l": "#c4c6ca",                                 # pale belly and throat
    "y": "#e8c040",                                 # eye
    "r": "#8a2020", "w": "#f0ead8",                 # mouth, teeth
    "g": "#e8e0f0", "G": "#a89cb8",                 # Gleipnir, the silken fetter
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
    """A straight foreleg: thick at the shoulder, a slim lower leg, a paw."""
    poly(c, [(x - 1, 32), (x + 5, 32), (x + 4, 40), (x + 3, 48), (x, 48), (x, 40)], col)
    c.rect(x, 48, x + 4, 49, shade); c.px(x, 41, shade); c.px(x, 42, shade)


def hind_leg(c, x, col, shade):
    """A hind leg: a heavy thigh, the hock bending back, a slim lower leg, a paw."""
    ellipse(c, x + 3, 33, 5, 6, col)
    poly(c, [(x, 36), (x + 5, 37), (x + 1, 43), (x + 3, 48), (x, 48), (x - 2, 43)], col)
    c.rect(x - 1, 48, x + 3, 49, shade); c.px(x - 2, 43, shade); c.px(x - 1, 44, shade)


def draw(c, legs):
    front, back = legs
    # Far legs (behind, in shadow)
    hind_leg(c, 19 - back, "F", "D")
    front_leg(c, 45 + front, "F", "D")
    # Bushy tail hanging down behind, curving
    for i in range(16):
        t = i / 15
        ellipse(c, 15 - t * 9, 24 + t * 14 - t * t * 4, 3.4 - t * 1.6, 3.0 - t * 1.2, "f")
    c.px(7, 36, "F"); c.px(8, 35, "F"); c.px(10, 32, "F"); c.px(6, 37, "D")
    # Body: a lean belly tucked up, a deep chest, darker along the back
    ellipse(c, 30, 26, 14, 7, "f")
    ellipse(c, 45, 26, 9, 10, "f")
    for x in range(14, 56):
        for y in range(14, 30):
            if c.g[y][x] == "f" and (c.g[y - 1][x] == "." or c.g[y - 2][x] == "."):
                c.px(x, y, "D")
    ellipse(c, 46, 31, 6, 4, "l")                       # pale chest
    c.row(32, 24, 36, "F")                              # the shadow under his belly
    # Near legs
    hind_leg(c, 24 + back, "f", "F")
    front_leg(c, 50 - front, "f", "F")
    # Ruff of fur on the neck
    for k in range(6):
        c.px(50 + k, 13 + (k % 2), "D")
    # Head: skull, ears, a yellow eye
    ellipse(c, 58, 19, 6.5, 6, "f")
    poly(c, [(53, 15), (55, 6), (59, 14)], "f"); poly(c, [(55, 9), (56, 9), (57, 13), (55, 13)], "D")
    # Gaping jaws (Gylfaginning 51): the upper raised, the lower dropped, the mouth open between, with fangs
    poly(c, [(61, 14), (72, 11), (73, 15), (63, 20)], "f")
    c.px(72, 11, "k"); c.px(73, 12, "k"); c.px(72, 12, "k")             # nose
    poly(c, [(62, 24), (71, 27), (70, 30), (60, 28)], "f")
    poly(c, [(61, 20), (72, 15), (71, 27), (61, 24)], "r")
    for x, y in [(65, 18), (68, 17), (71, 16), (65, 25), (68, 26)]:
        c.px(x, y, "w"); c.px(x, y + (1 if y < 22 else -1), "w")
    c.row(13, 62, 70, "D")
    c.px(59, 16, "y"); c.px(60, 16, "y"); c.px(60, 17, "k")
    c.row(26, 55, 60, "l"); c.row(27, 56, 60, "l")       # pale throat
    # Gleipnir, broken, still round his neck: a pale silken band, its torn end fluttering back over his shoulders
    for y in range(13, 30):
        x = 52 - (y - 13) // 5
        c.px(x, y, "g"); c.px(x + 1, y, "G")
    for k, (x, y) in enumerate([(50, 13), (48, 12), (46, 12), (44, 11), (42, 11)]):
        c.px(x, y, "g"); c.px(x + 1, y, "g" if k % 2 else "G")


if __name__ == "__main__":
    kit.build_boss("fenrir", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/fenrir.json")
