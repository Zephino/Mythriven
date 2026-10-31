# Kronos, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_kronos.py from tools/art/.
# Writes data/art/bosses/kronos.json.
import math
import hero_kit as kit

DOC = ("Kronos, boss (GAME_DESIGN.md: The Aegean Shore bosses; art 10/31/2026). Built by tools/art/build_boss_kronos.py; "
       "rules in docs/ART_RULES.md. From Hesiod, Theogony 137-210 and 453-506: the youngest Titan, 'of crooked counsel', "
       "who took the great jagged sickle of grey adamant that Gaia made and overthrew his father, then swallowed his own "
       "children. Shown as Greek art shows the elder gods: a huge old man with long grey hair and a long beard, a "
       "himation (mantle) of dark purple draped over one shoulder, sandals, the sickle in his hand. Much bigger than a "
       "Hero (a Titan).")

SIZE, ANCHOR = (68, 72), (30, 70)
STANCE = (25, 33)
WALK = [STANCE, (23, 35), STANCE, (27, 31), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#d8a07a", "S": "#a8704e",                 # weathered skin
    "h": "#c8c4bc", "H": "#8e8a84",                 # grey hair and beard
    "p": "#5a4878", "P": "#3a2e52",                 # dark purple himation
    "y": "#c8a048",                                 # gold border
    "e": "#c8ccd4", "E": "#7a808a",                 # grey adamant sickle
    "c": "#7a4a26",                                 # wooden grip
    "n": "#5c3a1c",                                 # sandals
}


def sickle(c):
    """The great jagged sickle of adamant (Theogony 162, 175): a wooden grip rising from his fist, and a curved blade
    sweeping forward and down, with teeth along its inner edge."""
    c.rect(51, 24, 52, 35, "c")
    cx, cy = 58.0, 23.0
    for y in range(10, 34):
        for x in range(49, 68):
            d = math.hypot(x - cx, y - cy)
            ang = math.degrees(math.atan2(y - cy, x - cx))
            if 6.0 <= d <= 9.5 and (ang <= 60 or ang >= 160 or ang <= -100):
                if -100 >= ang or ang >= 160 or ang <= 60:
                    c.px(x, y, "E" if d > 8.5 else "e")
    for ang in range(-80, 60, 18):                     # teeth on the inner edge
        a = math.radians(ang)
        c.px(round(cx + math.cos(a) * 5.2), round(cy + math.sin(a) * 5.2), "e")


def draw(c, legs):
    back, front = legs
    # Far arm hanging at his side
    c.rect(18, 26, 21, 44, "S"); c.rect(18, 45, 21, 47, "s")
    # Long grey hair: a rounded crown, waves falling down his back, a dark edge where it meets the beard
    c.row(3, 26, 33, "h"); c.row(4, 24, 35, "h"); c.row(5, 23, 37, "h"); c.rect(22, 6, 38, 9, "h")
    c.rect(21, 10, 29, 22, "h"); c.rect(20, 14, 21, 23, "h"); c.row(23, 21, 28, "h")
    c.rect(20, 14, 22, 23, "H"); c.rect(25, 12, 25, 21, "H"); c.row(6, 27, 31, "H"); c.row(8, 32, 36, "H")
    # Face in profile: forehead, brow, deep-set eye, nose, cheek
    c.rect(30, 10, 38, 18, "s"); c.rect(30, 10, 31, 18, "S")
    c.row(12, 34, 38, "S"); c.px(36, 14, "k"); c.px(35, 14, "k")
    c.rect(39, 13, 40, 16, "s"); c.px(40, 16, "S"); c.px(33, 16, "S")
    # Bare chest on the near side; the himation over his far shoulder, across to the near hip
    c.rect(23, 25, 41, 45, "s"); c.rect(23, 25, 25, 45, "S")
    c.row(33, 33, 37, "S"); c.px(35, 36, "S"); c.px(35, 39, "S")
    for y in range(25, 46):
        reach = 23 + int((y - 25) * 0.9)
        c.row(y, 22, min(reach, 42), "p")
    for y in range(25, 46):
        c.px(22, y, "P"); c.px(23, y, "P")
    for y in range(25, 46):
        x = 23 + int((y - 25) * 0.9)
        if x <= 42:
            c.px(x, y, "y")                                   # the mantle's gold edge
    c.rect(30, 19, 33, 24, "S")
    # Long grey beard from the cheek to the chest, tapering to a point, with wavy bands
    for y in range(18, 32):
        w = min(8, 3 + (y - 18)) if y < 24 else 8 - (y - 24)
        c.row(y, 38 - w, 38, "h")
    for y in (21, 25, 29):
        c.row(y, 32, 37, "H")
    c.px(38, 18, "s"); c.px(37, 18, "s"); c.px(36, 19, "H")
    c.rect(30, 19, 31, 24, "S")                              # his neck in shadow, behind the beard
    # The himation to his shins, folds
    for y in range(46, 61):
        x0, x1 = (21, 43) if y < 56 else (20, 44)
        c.row(y, x0, x1, "p")
        for x in range(x0 + 2, x1, 4):
            c.px(x, y, "P")
    c.rect(21, 46, 23, 60, "P"); c.row(60, 20, 44, "y")
    # Near arm, bent forward, fist holding the sickle
    c.rect(40, 25, 43, 33, "s"); c.rect(39, 26, 39, 33, "o"); c.px(43, 25, "S")
    c.rect(43, 33, 50, 36, "s"); c.px(43, 36, "S")
    c.rect(49, 32, 53, 37, "s"); c.px(49, 37, "S"); c.px(53, 32, "S")
    sickle(c)
    c.rect(50, 33, 53, 36, "s"); c.row(34, 50, 53, "S")      # fingers wrapped round the grip
    # Legs and sandals
    for x0 in (back, front):
        c.rect(x0, 61, x0 + 5, 67, "s"); c.rect(x0, 61, x0 + 1, 67, "S")
        c.row(65, x0, x0 + 5, "n"); c.row(68, x0, x0 + 6, "n")


if __name__ == "__main__":
    kit.build_boss("kronos", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/kronos.json")
