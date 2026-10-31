# Medusa, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_medusa.py from tools/art/.
# Writes data/art/bosses/medusa.json.
import math
import hero_kit as kit

DOC = ("Medusa, boss (GAME_DESIGN.md: The Aegean Shore bosses; art 10/31/2026). Built by tools/art/build_boss_medusa.py; "
       "rules in docs/ART_RULES.md. From Pseudo-Apollodorus, Bibliotheca 2.4.2: the Gorgons had heads twined about with "
       "the scales of serpents, great tusks like swine's, hands of bronze, and wings of gold; and Ovid, Metamorphoses 4 "
       "(snakes for hair). The short chiton is how archaic Greek vase paintings and temple reliefs show her. Bigger "
       "than a Hero (a boss).")

SIZE, ANCHOR = (46, 58), (24, 56)
STANCE = (20, 26)
WALK = [STANCE, (18, 28), STANCE, (22, 24), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#d8c4a4", "S": "#a88e72",                 # pallid skin
    "g": "#6aa04a", "G": "#3e6a2a",                 # serpents
    "u": "#e8c050", "U": "#a88028",                 # golden wings
    "b": "#c08a3a", "B": "#7a5020",                 # bronze hands
    "c": "#3e3452", "C": "#28203a",                 # dark chiton
    "y": "#d8b048",                                 # gold border
    "w": "#f4ecd8",                                 # tusks
    "n": "#5c3a1c",                                 # sandals
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


def wings(c):
    """A golden wing behind her, raised from the shoulder (owner 10/31/2026: the first, a fan of rods, didn't read as
    a wing): an arched top edge, a band of small covert feathers, then long flight feathers hanging down in a row,
    each with its own shadow line and a ragged tip."""
    sx, sy = 19, 22 + DY
    for x in range(3, sx + 1):
        k = (sx - x) / (sx - 3)
        top = round(sy - 20 * math.sin(math.pi / 2 * k))
        bottom = round(top + 5 + 9 * k + (2 if x % 3 == 0 else 0))
        for y in range(top, bottom + 1):
            c.px(x, y, "u")
        c.px(x, top + 3, "U")                                   # the edge of the covert feathers
        if x % 3 == 1:
            for y in range(top + 4, bottom + 1):
                c.px(x, y, "U")                                 # a line between flight feathers
        c.px(x, bottom, "U")


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


def draw(c, legs):
    back, front = legs
    d = DY
    wings(c)
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
    # Legs and sandals
    for x0 in (back, front):
        c.rect(x0, 38 + d, x0 + 3, 47 + d, "s"); c.rect(x0, 38 + d, x0, 47 + d, "S")
        c.row(44 + d, x0, x0 + 3, "n"); c.row(48 + d, x0, x0 + 4, "n")


if __name__ == "__main__":
    kit.build_boss("medusa", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/medusa.json")
