# Medusa, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_medusa.py from tools/art/.
# Writes data/art/bosses/medusa.json.
import math
import hero_kit as kit

DOC = ("Medusa, boss (GAME_DESIGN.md: The Aegean Shore bosses; art 10/31/2026). Built by tools/art/build_boss_medusa.py; "
       "rules in docs/ART_RULES.md. From Pseudo-Apollodorus, Bibliotheca 2.4.2: the Gorgons had heads twined about with "
       "the scales of serpents, great tusks like swine's, and hands of bronze (their wings of gold are left out at the "
       "owner's request, 10/31/2026, as in Ovid's telling); and Ovid, Metamorphoses 4 (snakes for hair). In the ancient "
       "sources and art she has a woman's legs; she has a serpent's tail instead at the owner's request (10/31/2026), "
       "the well-known modern image. The short chiton is how archaic Greek vase paintings and temple reliefs show her. Bigger "
       "than a Hero (a boss).")

SIZE, ANCHOR = (46, 58), (24, 56)
# Her tail sways as she moves: the phase of each frame (standing, then 4 walking frames).
WALK = [0.0, 1.0, 0.0, -1.0, 0.0]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#d8c4a4", "S": "#a88e72",                 # pallid skin
    "g": "#6aa04a", "G": "#3e6a2a",                 # serpents
    "b": "#c08a3a", "B": "#7a5020",                 # bronze hands
    "c": "#3e3452", "C": "#28203a",                 # dark chiton
    "y": "#d8b048",                                 # gold border
    "w": "#f4ecd8",                                 # tusks
    "t": "#5a8a3a", "T": "#36581f", "v": "#d0c48a",  # serpent tail: scales, darker bands, pale belly
}


def capsule(c, a, b, r, col, cond=None):
    (ax, ay), (bx, by) = a, b
    dx, dy = bx - ax, by - ay
    L2 = dx * dx + dy * dy or 1
    for y in range(c.h):
        for x in range(c.w):
            t = max(0, min(1, ((x - ax) * dx + (y - ay) * dy) / L2))
            if math.hypot(x - (ax + t * dx), y - (ay + t * dy)) <= r:
                c.px(x, y, col)


DY = 6   # everything sits 6 pixels down, leaving room above for her serpents


def serpents(c):
    """Her hair: serpents writhing up and back from her head, each a solid body with its own dark edge, a head,
    and an eye."""
    head = (25, 11 + DY)
    bodies = []
    for ang, length, phase in [(-165, 9, 0.0), (-135, 10, 1.4), (-105, 10, 2.4), (-75, 9, 0.8), (-45, 7, 1.9)]:
        a = math.radians(ang)
        nx, ny = math.cos(a), math.sin(a)
        pts = [(head[0] + nx * (4 + t / 2) - ny * math.sin(t / 2 * 0.8 + phase) * 1.6,
                head[1] + ny * (4 + t / 2) + nx * math.sin(t / 2 * 0.8 + phase) * 1.6) for t in range(length * 2 + 1)]
        bodies.append((pts, a))
    for pts, a in bodies:
        for p, q in zip(pts, pts[1:]):
            capsule(c, p, q, 2.1, "o")
        ex, ey = pts[-1]
        capsule(c, pts[-2], (ex + math.cos(a) * 1.5, ey + math.sin(a) * 1.5), 2.4, "o")
    for pts, a in bodies:
        for p, q in zip(pts, pts[1:]):
            capsule(c, p, q, 1.1, "g")
        ex, ey = pts[-1]
        capsule(c, pts[-2], (ex + math.cos(a) * 1.5, ey + math.sin(a) * 1.5), 1.5, "G")
        c.px(round(ex + math.cos(a)), round(ey + math.sin(a)), "k")


def tail(c, sway):
    """A serpent's tail in place of legs (owner request 10/31/2026, going against the sources on purpose: the ancient
    Medusa has a woman's legs, the tail is the well-known modern image): thick under her chiton, curving down to the
    ground and trailing behind her, tapering to a tip, with a pale belly and darker bands across its back. `sway`
    moves the trailing part for the walking frames."""
    path = [(25, 44, 5.0), (25, 48, 4.6), (23, 52, 4.0), (18, 54, 3.4), (12, 54 - sway, 2.8), (7, 52 - sway * 2, 2.0),
            (3, 49 - sway * 2, 1.2)]
    pts = []
    for (ax, ay, ar), (bx, by, br) in zip(path, path[1:]):
        for i in range(8):
            t = i / 8
            pts.append((ax + (bx - ax) * t, ay + (by - ay) * t, ar + (br - ar) * t))
    pts.append(path[-1])
    for x, y, r in pts:
        for yy in range(int(y - r) - 1, int(y + r) + 2):
            for xx in range(int(x - r) - 1, int(x + r) + 2):
                if math.hypot(xx - x, yy - y) <= r:
                    c.px(xx, yy, "t")
    for x, y, r in pts:
        c.px(round(x), round(y + r * 0.7), "v")              # the pale belly along the underside
        if r > 1.5:
            c.px(round(x), round(y + r * 0.7) - 1, "v")
    for k, (x, y, r) in enumerate(pts):
        if k % 5 == 0 and r > 1.5:
            c.px(round(x), round(y - r * 0.5), "T"); c.px(round(x), round(y - r * 0.5) + 1, "T")   # bands


def draw(c, legs):
    d = DY
    tail(c, legs)                                            # behind her chiton, which hangs over its top
    # Far arm, a bronze hand
    c.rect(18, 20 + d, 19, 30 + d, "S"); c.rect(18, 31 + d, 19, 32 + d, "B")
    serpents(c)
    # Head in profile: rounded pallid face, eye, nose, a tusk at the mouth, serpent-scaled hair over the scalp
    c.rect(22, 8 + d, 28, 14 + d, "s"); c.row(15 + d, 23, 27, "s"); c.rect(22, 8 + d, 23, 14 + d, "S")
    c.row(7 + d, 22, 27, "G"); c.rect(21, 8 + d, 22, 12 + d, "G"); c.px(23, 8 + d, "g"); c.px(25, 7 + d, "g")
    c.px(29, 11 + d, "s"); c.px(26, 10 + d, "k")
    c.px(28, 14 + d, "w"); c.px(28, 15 + d, "w")
    c.rect(23, 16 + d, 26, 18 + d, "s"); c.px(23, 16 + d, "S")
    # Dark chiton to the knees with a gold border, folds, a belt
    for y in range(19 + d, 38 + d):
        x0, x1 = (20, 30) if y < 34 + d else (19, 31)
        c.row(y, x0, x1, "c")
        if y > 27 + d:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "C")
    c.rect(20, 19 + d, 21, 27 + d, "C")
    c.row(37 + d, 19, 31, "y"); c.row(19 + d, 22, 28, "y")
    c.row(27 + d, 20, 30, "B")
    # Near arm reaching forward, a bronze clawed hand
    c.rect(29, 20 + d, 31, 24 + d, "s"); c.rect(28, 21 + d, 28, 24 + d, "o")
    c.rect(31, 24 + d, 35, 25 + d, "s"); c.px(31, 25 + d, "S")
    c.rect(35, 22 + d, 37, 26 + d, "b"); c.px(38, 22 + d, "B"); c.px(38, 24 + d, "B"); c.px(38, 26 + d, "B"); c.px(35, 26 + d, "B")


if __name__ == "__main__":
    kit.build_boss("medusa", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/medusa.json")
