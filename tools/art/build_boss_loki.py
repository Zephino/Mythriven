# Loki, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_loki.py from tools/art/.
# Writes data/art/bosses/loki.json.
import math
import hero_kit as kit

DOC = ("Loki, boss (GAME_DESIGN.md: Midgard's Edge bosses; art 10/31/2026). Built by tools/art/build_boss_loki.py; "
       "rules in docs/ART_RULES.md. From Snorri Sturluson's Prose Edda: 'pleasing and handsome in appearance, evil in "
       "character, very changeable in his ways' (Gylfaginning 33), and the dwarf Brokkr sewing his lips shut "
       "(Skaldskaparmal 35), the stitched mouth carved on the Snaptun stone (Denmark, about 1000 AD). Viking Age dress "
       "from finds such as Birka and Hedeby: a knee-length tunic with a woven border, a cloak pinned at the shoulder, "
       "trousers with leg wraps, leather shoes. The flame in his hand is his wildfire attack. Not based on any modern "
       "version (GAME_DESIGN.md: never Marvel's Loki: no horned helmet, no green and gold).")

SIZE, ANCHOR = (44, 58), (22, 56)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#ecc4a0", "S": "#bc9070",                 # fair Norse skin
    "h": "#a8603a", "H": "#744028",                 # russet hair and short beard
    "r": "#6e2a2a", "R": "#4a1a1c",                 # dark red tunic
    "y": "#d0a040",                                 # woven border
    "c": "#2c3a5a", "C": "#1c2640",                 # dark blue cloak
    "i": "#d0d4dc",                                 # silver brooch
    "t": "#5a5a62", "T": "#3c3c44",                 # grey trousers
    "w": "#c8b48a",                                 # leg wraps
    "b": "#4a2e16",                                 # shoes and belt
    "f": "#ff9030", "F": "#ffe080", "q": "#c84020",  # flame (his wildfire)
}


def flame(c, x, y):
    """A small flame dancing over his open hand: dark red outside, orange, a bright yellow heart."""
    for yy in range(y - 8, y + 1):
        for xx in range(x - 4, x + 5):
            h = (y - yy) / 8
            half = 3.5 * (1 - h) ** 0.7 + 0.5
            if abs(xx - x - math.sin(h * 3) * 1.0) <= half:
                c.px(xx, yy, "q")
    for yy in range(y - 6, y + 1):
        for xx in range(x - 3, x + 4):
            h = (y - yy) / 6
            if abs(xx - x - math.sin(h * 3) * 0.8) <= 2.2 * (1 - h) + 0.3:
                c.px(xx, yy, "f")
    c.rect(x - 1, y - 2, x + 1, y, "F"); c.px(x, y - 3, "F")


def draw(c, legs):
    back, front = legs
    # His cloak behind him, pinned at the far shoulder, hanging to his calves with folds
    for y in range(18, 46):
        x0 = 11 - (y - 18) // 6
        c.row(y, x0, 16, "c")
        c.px(x0, y, "C")
    for y in range(24, 46, 1):
        c.px(13, y, "C")
    # Far arm in shadow
    c.rect(12, 20, 13, 31, "S"); c.rect(12, 32, 13, 33, "s")
    # Russet hair swept back from his brow in waves, a short pointed beard
    c.row(5, 18, 23, "h"); c.row(6, 16, 25, "h"); c.rect(15, 7, 25, 8, "h"); c.rect(14, 9, 18, 15, "h")
    c.px(13, 9, "h"); c.px(12, 10, "h"); c.px(13, 12, "h"); c.px(12, 13, "h"); c.px(13, 15, "h"); c.px(25, 9, "h")
    c.rect(14, 9, 15, 15, "H"); c.row(7, 18, 21, "H"); c.px(22, 8, "H"); c.px(17, 6, "H")
    # A handsome face in profile: forehead, a sly slanted brow, eye, a sharp nose
    c.rect(19, 9, 24, 16, "s"); c.rect(19, 9, 20, 16, "S")
    c.px(22, 10, "H"); c.px(23, 10, "H"); c.px(24, 11, "H")
    c.px(23, 12, "k"); c.px(25, 12, "s"); c.px(25, 13, "s"); c.px(26, 13, "s")
    # His lips sewn shut (the Snaptun stone): a dark line with stitches across it
    c.row(15, 22, 25, "H"); c.px(25, 14, "s")
    for x in (22, 24):
        c.px(x, 14, "S"); c.px(x, 16, "S")
    c.rect(20, 17, 24, 18, "h"); c.px(24, 19, "h"); c.px(23, 19, "h"); c.rect(20, 17, 20, 18, "H")
    c.rect(19, 19, 22, 20, "s"); c.rect(18, 16, 19, 19, "S")
    # Tunic to the knees with a woven border at the neck and hem, belted
    for y in range(20, 40):
        x0, x1 = (16, 26) if y < 36 else (15, 27)
        c.row(y, x0, x1, "r")
        if y > 29:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "R")
    c.rect(16, 20, 17, 29, "R")
    c.row(20, 18, 23, "y"); c.row(39, 15, 27, "y")
    c.row(29, 16, 26, "b"); c.px(22, 29, "i")
    # The cloak's pin on his shoulder
    c.rect(16, 21, 17, 22, "i")
    # Near arm held out, palm up, the flame over his hand
    c.rect(25, 21, 27, 26, "s"); c.rect(24, 22, 24, 26, "o")
    c.rect(27, 26, 32, 27, "s"); c.px(27, 27, "S")
    c.rect(32, 25, 35, 27, "s"); c.row(28, 32, 35, "S")
    flame(c, 34, 23)
    # Trousers with leg wraps, and shoes
    for x0 in (back, front):
        c.rect(x0, 40, x0 + 3, 51, "t"); c.rect(x0, 40, x0, 51, "T")
        for y in range(44, 52, 2):
            c.row(y, x0, x0 + 3, "w")
        c.rect(x0, 52, x0 + 4, 53, "b")


if __name__ == "__main__":
    kit.build_boss("loki", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/loki.json")
