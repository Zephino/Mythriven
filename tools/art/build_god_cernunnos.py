# Cernunnos, god (docs/ART_RULES.md: Gods). Run: python3 build_god_cernunnos.py from tools/art/.
# Writes data/art/gods/cernunnos.json.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

DOC = ("Cernunnos, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_cernunnos.py; rules in "
       "docs/ART_RULES.md. Known mainly from a few ancient images, so only what they show: the antlered god of the "
       "Gundestrup cauldron (National Museum of Denmark), beardless, wearing a torc at his neck, holding a torc in one "
       "hand and a ram-horned serpent in the other, in a close-fitting garment; and the name on the Pillar of the "
       "Boatmen (Paris). Shown standing; the cauldron shows him seated cross-legged among beasts.")

SIZE, ANCHOR = (54, 70), (26, 68)
STANCE = (21, 27)
WALK = [STANCE, (19, 29), STANCE, (23, 25), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#ecc4a0", "S": "#bc9070",                 # fair skin
    "h": "#5a3a22",                                 # short brown hair
    "a": "#c8b088", "A": "#8a7452",                 # antlers
    "u": "#e8c050", "U": "#a88028",                 # gold torcs
    "g": "#3e6a3e", "G": "#284a2a",                 # close-fitting green garment
    "t": "#5a4a3a", "T": "#3a2e22",                 # trousers, shoes
    "r": "#6aa040", "R": "#3e6a2a", "w": "#d8d0b8",  # serpent, ram's horns
}


def line(c, a, b, col, thick=False):
    (ax, ay), (bx, by) = a, b
    n = max(abs(bx - ax), abs(by - ay), 1)
    for i in range(n + 1):
        x = round(ax + (bx - ax) * i / n); y = round(ay + (by - ay) * i / n)
        c.px(x, y, col)
        if thick:
            c.px(x + 1, y, col)


def antlers(c):
    """A stag's antlers spreading wide from his head (owner 10/31/2026: thin, straight ones looked like a rabbit's
    ears): a thick main beam on each side curving out and up, with tines rising from it."""
    for beam, tines in (([(21, 11), (17, 7), (13, 4), (10, 1)], [((19, 9), (21, 5)), ((15, 5), (15, 0)), ((20, 10), (16, 10))]),
                        ([(25, 11), (29, 7), (33, 4), (37, 1)], [((27, 9), (26, 4)), ((31, 5), (31, 0)), ((26, 10), (30, 10))])):
        for a, b in zip(beam, beam[1:]):
            line(c, a, b, "a", thick=True)
        for a, b in tines:
            line(c, a, b, "a")
        for a, b in zip(beam, beam[1:]):
            line(c, (a[0], a[1] + 1), (b[0], b[1] + 1), "A")


def serpent(c):
    """The ram-horned serpent held in his far hand, its body curving down, its horned head raised."""
    for i in range(20):
        t = i / 19
        x = 10 + math.sin(t * 4) * 2.5; y = 44 - t * 20
        for yy in range(int(y) - 1, int(y) + 2):
            for xx in range(int(x) - 1, int(x) + 2):
                c.px(xx, yy, "r")
        if i % 3 == 0:
            c.px(round(x), round(y), "R")
    ellipse(c, 11, 22, 2.5, 2, "r"); c.px(12, 21, "k")
    c.px(9, 20, "w"); c.px(8, 21, "w"); c.px(8, 22, "w"); c.px(9, 23, "w")     # the ram's horn, curled


def draw(c, legs):
    back, front = legs
    antlers(c)
    # Far arm, holding the serpent
    c.rect(14, 28, 16, 38, "S"); c.rect(12, 38, 16, 41, "s")
    serpent(c)
    c.rect(12, 38, 15, 40, "s")
    # Head: short hair, beardless face
    c.rect(18, 11, 28, 14, "h"); c.rect(17, 14, 20, 22, "h")
    c.rect(21, 14, 28, 23, "s"); c.rect(21, 14, 22, 23, "S")
    c.px(26, 17, "k"); c.px(29, 18, "s"); c.px(29, 19, "s"); c.row(21, 25, 27, "S")
    c.rect(22, 24, 26, 25, "s")
    # The torc round his neck: a gold ring with heavy round ends
    c.row(26, 20, 28, "u"); c.px(19, 26, "U"); c.px(29, 26, "U"); c.rect(23, 27, 25, 27, "U")
    # Close-fitting garment with a belt, to the knee
    for y in range(27, 50):
        x0, x1 = (18, 30) if y < 45 else (17, 31)
        c.row(y, x0, x1, "g")
    c.rect(18, 27, 19, 49, "G")
    for y in range(29, 50):
        if y % 3 == 0:
            c.px(24, y, "G")                                 # a seam down the front
    c.row(26, 21, 27, "u")
    c.row(41, 18, 30, "T")
    # Near arm held out, a gold torc in his hand
    c.rect(29, 28, 31, 34, "s"); c.rect(28, 29, 28, 34, "o")
    c.rect(31, 34, 37, 36, "s"); c.row(36, 31, 37, "S")
    for a in range(0, 360, 20):
        r = math.radians(a)
        if not 70 < a < 110:                        # the gap between the torc's ends
            c.px(round(41 + math.cos(r) * 4), round(31 + math.sin(r) * 4), "u")
    c.px(40, 35, "U"); c.px(42, 35, "U")
    c.rect(37, 33, 40, 36, "s"); c.row(36, 37, 40, "S")
    # Trousers and shoes
    for x0 in (back, front):
        c.rect(x0, 50, x0 + 4, 63, "t"); c.rect(x0, 50, x0, 63, "T")
        c.rect(x0, 63, x0 + 5, 65, "T")


if __name__ == "__main__":
    kit.build_boss("cernunnos", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods",
                  seated={"style": "celtic", "hip": 44, "lap": "g", "shin": "t", "foot": "T"})
    print("wrote data/art/gods/cernunnos.json")
