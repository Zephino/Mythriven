# Skadi, god (docs/ART_RULES.md: Gods). Run: python3 build_god_skadi.py from tools/art/.
# Writes data/art/gods/skadi.json.
import math
import hero_kit as kit
from hero_kit import poly

DOC = ("Skadi, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_skadi.py; rules in "
       "docs/ART_RULES.md. From Snorri Sturluson's Prose Edda (Gylfaginning 23: she goes about on skis with her bow and "
       "shoots wild animals; Skaldskaparmal: the ski-goddess) and the Poetic Edda (Grimnismal 11: she lives in "
       "Thrymheim in the mountains). A huntress of the snowy mountains: a fur-trimmed hooded cloak, a long braid, a "
       "wool dress, fur boots, a bow in her hand. Not based on any modern version.")

SIZE, ANCHOR = (50, 62), (22, 60)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f2d2bc", "S": "#c8a08a",                 # pale northern skin
    "h": "#e8d8a8", "H": "#b8a670",                 # pale gold braid
    "f": "#e8e8ec", "F": "#b0b4bc",                 # white fur
    "c": "#5a7a9a", "C": "#3e5670",                 # blue-grey cloak
    "d": "#2e3e5a", "D": "#1e2a40",                 # dark blue wool dress
    "w": "#9a6232", "W": "#6a4020", "e": "#efe6d2",  # bow, bowstring
    "b": "#8a7a6a",                                 # fur boots
}


def bow(c, x):
    """Her hunting bow, upright in her hand, the string drawn straight."""
    for y in range(12, 46):
        t = (y - 29) / 17
        c.px(round(x + 3 * (1 - t * t)), y, "w")
    c.px(x + 3, 29, "W"); c.px(x + 3, 30, "W")
    for y in range(12, 46):
        c.px(x, y, "e")


def draw(c, legs):
    back, front = legs
    # Cloak hanging behind her
    poly(c, [(15, 18), (20, 18), (19, 52), (9, 54), (11, 30)], "c")
    for y in range(24, 54, 3):
        c.px(12, y, "C")
    # Far arm
    c.rect(13, 21, 15, 34, "S")
    # Hood, fur-trimmed, a braid falling over her shoulder
    poly(c, [(14, 6), (20, 3), (26, 5), (27, 10), (16, 18), (13, 12)], "c")
    c.rect(14, 5, 15, 16, "C")
    for x, y in [(18, 4), (21, 3), (24, 4), (26, 7), (27, 10)]:
        c.px(x, y, "f"); c.px(x, y + 1, "F")                    # fur round the hood's edge
    # Face: forehead, eye, nose
    c.rect(19, 8, 26, 16, "s"); c.rect(19, 8, 20, 16, "S")
    c.px(24, 11, "k"); c.px(27, 12, "s"); c.px(27, 13, "s"); c.row(15, 22, 24, "S")
    c.rect(20, 17, 24, 18, "s")
    # Fur collar, and her braid
    c.rect(16, 19, 27, 21, "f"); c.row(21, 16, 27, "F")
    for y in range(17, 33):
        c.px(17, y, "h" if y % 2 else "H"); c.px(18, y, "H" if y % 2 else "h")
    # Long dark wool dress to the ankle, a fur-trimmed hem
    for y in range(22, 55):
        x0, x1 = (16, 27) if y < 42 else (15 - (y - 42) // 6, 28 + (y - 42) // 6)
        c.row(y, x0, x1, "d")
        if y > 36:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "D")
    c.rect(16, 22, 17, 41, "D")
    for y in range(17, 33):
        c.px(17, y, "h" if y % 2 else "H"); c.px(18, y, "H" if y % 2 else "h")
    c.row(55, 13, 30, "f"); c.row(56, 13, 30, "F")
    c.row(31, 16, 27, "W")                                         # belt
    # Near arm, holding the bow
    c.rect(26, 22, 28, 28, "d"); c.rect(25, 23, 25, 28, "o")
    c.rect(28, 28, 32, 30, "s"); c.row(30, 28, 32, "S")
    bow(c, 33)
    c.rect(32, 27, 35, 31, "s"); c.row(31, 32, 35, "S")
    # Fur boots
    for x0 in (back, front):
        c.rect(x0, 57, x0 + 4, 59, "b"); c.row(57, x0, x0 + 4, "f")


if __name__ == "__main__":
    kit.build_boss("skadi", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods",
                  seated={"style": "norse", "hip": 40, "lap": "d", "shin": "d", "foot": "b"})
    print("wrote data/art/gods/skadi.json")
