# Ferdiad, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_ferdiad.py from tools/art/.
# Writes data/art/bosses/ferdiad.json.
import math
import hero_kit as kit
from hero_kit import poly

DOC = ("Ferdiad, boss (GAME_DESIGN.md: The Misty Isles bosses; art 10/31/2026). Built by tools/art/build_boss_ferdiad.py; "
       "rules in docs/ART_RULES.md. From the Táin Bó Cúailnge (Book of Leinster), the combat at the ford, where he arms "
       "himself against Cú Chulainn: a girdle-apron of striped silk, over it an apron of brown leather and an apron of "
       "iron; a crested helmet set with gems; a great shield with many bosses; a curved sword. His horn-skin (no weapon "
       "could pierce it) is the training he shared with Cú Chulainn under Scáthach. Fair skin.")

SIZE, ANCHOR = (48, 60), (22, 58)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f0c8a8", "S": "#c49478",                 # fair skin
    "h": "#7a5030",                                 # brown hair
    "g": "#c89a3c", "G": "#8a6420",                 # bronze (helmet, shield)
    "u": "#f0d060",                                 # gold
    "j": "#c03030", "J": "#3a7ac0",                 # gems
    "t": "#b83a2c", "R": "#802418", "T": "#e0b040",  # silk tunic: red, shadow, gold edging
    "b": "#6a4422", "B": "#4a2e16",                 # brown leather apron, shoes
    "i": "#9aa0a8", "I": "#5c6068",                 # iron apron, sword
    "e": "#d8dce0",                                 # blade
}


def shield(c):
    """The great shield on his far arm, round, bronze, with rows of bosses."""
    cx, cy, r = 9.5, 30.5, 8.5
    for y in range(20, 42):
        for x in range(0, 20):
            d = math.hypot(x - cx, y - cy)
            if d <= r:
                c.px(x, y, "G" if d > r - 1.2 else "g")
    for ring, count in ((6.0, 12), (3.2, 6)):
        for k in range(count):
            a = math.tau * k / count
            c.px(round(cx + math.cos(a) * ring), round(cy + math.sin(a) * ring), "u")
    c.rect(9, 30, 10, 31, "u")
    c.rect(17, 22, 17, 39, "o")                       # its own edge against his body


def sword(c):
    """The curved sword, raised: a steel blade sweeping up and curving back at the tip, a gold guard above his fist."""
    for i in range(19):
        x = 37 + i * 0.7 - (i / 18) ** 2 * 6; y = 24 - i
        c.px(round(x), round(y), "e"); c.px(round(x) + 1, round(y), "i")
    c.rect(34, 25, 40, 25, "u")


def draw(c, legs):
    back, front = legs
    shield(c)
    # Brown hair at the back of his neck, below the helmet
    c.rect(14, 10, 17, 17, "h")
    # A rounded helmet set with gems, a gold crest along its ridge
    c.row(4, 17, 23, "g"); c.row(5, 16, 24, "g"); c.rect(15, 6, 25, 9, "g")
    c.rect(15, 6, 16, 9, "G"); c.px(16, 5, "G"); c.row(10, 15, 25, "G")
    c.row(3, 17, 23, "u"); c.row(2, 16, 22, "u"); c.px(15, 3, "u"); c.px(14, 4, "u"); c.px(13, 5, "u")
    for x, gem in ((18, "j"), (20, "J"), (22, "j"), (24, "J")):
        c.px(x, 8, gem)
    # Face: young and beardless, forehead under the helmet's rim, eye, nose
    c.rect(18, 11, 25, 17, "s"); c.rect(18, 11, 19, 17, "S")
    c.px(23, 13, "k"); c.px(26, 13, "s"); c.px(26, 14, "s"); c.px(23, 16, "S")
    c.rect(19, 18, 23, 19, "s"); c.px(19, 18, "S")
    # Tunic of silk, red with gold edging (not stripes: they read as a sports shirt)
    c.rect(17, 20, 27, 30, "t"); c.rect(17, 20, 18, 30, "R")
    c.row(20, 19, 24, "T"); c.rect(22, 21, 22, 30, "T")
    # Over it an apron of brown leather, and over that an apron of iron plates to the knee
    c.row(31, 16, 28, "b")
    for y in range(32, 44):
        x0, x1 = (16, 28) if y < 40 else (15, 29)
        c.row(y, x0, x1, "i")
        if (y - 32) % 3 == 0:
            c.row(y, x0, x1, "I")
    for y in range(32, 44, 3):
        for x in range(17, 29, 3):
            c.px(x, y + 1, "I")
    c.row(44, 15, 29, "b")
    # Near arm raising the curved sword
    c.rect(26, 20, 28, 24, "s"); c.rect(25, 21, 25, 25, "o")
    c.rect(28, 24, 33, 26, "s"); c.row(26, 28, 33, "S")
    sword(c)
    c.rect(34, 26, 38, 29, "s"); c.row(29, 34, 38, "S")         # fist round the hilt
    # Legs and shoes
    for x0 in (back, front):
        c.rect(x0, 45, x0 + 3, 54, "s"); c.rect(x0, 45, x0, 54, "S")
        c.rect(x0, 54, x0 + 4, 56, "B")


if __name__ == "__main__":
    kit.build_boss("ferdiad", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/ferdiad.json")
