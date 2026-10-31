# Achilles (docs/ART_RULES.md). Run: python3 tools/art/build_achilles.py
# Writes data/art/achilles.json on the shared body in hero_kit.py.
import math
import hero_kit as kit

DOC = ("Achilles (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_achilles.py on the shared body in "
       "tools/art/hero_kit.py; rules in docs/ART_RULES.md. From Homer's Iliad: golden-haired (1.197); the armour Hephaestus "
       "forges in book 18: a helmet with a crest of gold, a corslet brighter than fire, greaves of tin, and the great round "
       "shield, carried here on his far arm (it stays whatever weapon he holds). Bronze breastplate, a skirt of leather "
       "strips over a red chiton, and sandals. His spear is drawn separately (data/art/weapons/) at his hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#e2a676", "S": "#b0724a",                 # Mediterranean skin, as Heracles
    "a": "#d8b060",                                 # golden hair (xanthos)
    "g": "#c89a3c", "G": "#8a6420",                 # bronze (helmet, breastplate, shield)
    "u": "#f0cc58", "y": "#fff0b0",                 # gold crest, shield boss highlight
    "b": "#6a4422", "B": "#4a2e16",                 # leather strips
    "r": "#a83a2c",                                 # red chiton
    "i": "#c4c8d0", "I": "#8a8e96",                 # tin greaves
    "n": "#5c3a1c",                                 # sandals
}


def greaves(c, x0):
    c.rect(x0, 28, x0 + 2, 30, "i"); c.px(x0, 28, "I"); c.px(x0, 29, "I")
    c.row(31, x0, x0 + 3, "n")


def shield(c):
    """The great round shield on his far arm: bronze, with a darker rim, an inner ring, and a gold boss."""
    cx, cy = 6.5, 18.5
    for y in range(11, 27):
        for x in range(0, 14):
            d = math.hypot(x - cx, y - cy)
            if d <= 6.4 and x < 9:
                c.px(x, y, "G" if d > 5.5 or 3.2 < d <= 4.0 else "g")
            elif d <= 6.4 and x == 9:
                c.px(x, y, "o")                     # its own edge against the body
    c.rect(6, 18, 7, 19, "u"); c.px(6, 18, "y")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    shield(c)
    # Bronze helmet with cheek guards, a gold crest sweeping back, golden hair at the nape
    c.rect(10, 3, 16, 6, "g"); c.row(3, 10, 15, "G")        # dome, dark band under the crest
    c.rect(10, 7, 11, 10, "g"); c.rect(16, 6, 17, 7, "g")    # back of the helmet, nose guard
    c.px(10, 6, "G"); c.px(10, 8, "G")
    c.row(1, 10, 14, "u"); c.row(2, 9, 15, "u")              # the crest of gold
    c.rect(7, 2, 9, 4, "u"); c.rect(7, 5, 8, 9, "u"); c.px(7, 9, "G")
    c.rect(9, 9, 10, 11, "a")                                # golden hair below the helmet
    # Face in the helmet's opening: eye, mouth
    c.rect(12, 7, 15, 10, "s"); c.px(12, 7, "S"); c.px(12, 8, "S")
    c.px(14, 8, "k"); c.px(16, 9, "s"); c.px(14, 10, "S")
    c.rect(12, 11, 15, 12, "s"); c.px(12, 11, "S")
    # Bronze breastplate with chest and stomach lines
    c.rect(10, 13, 17, 19, "g"); c.rect(10, 13, 11, 19, "G")
    c.row(15, 12, 13, "G"); c.row(15, 15, 16, "G"); c.px(14, 16, "G"); c.px(14, 17, "G"); c.px(14, 18, "G")
    kit.weapon_arm(c)
    # Skirt of leather strips over a red chiton
    for x in range(10, 18):
        c.rect(x, 20, x, 23, "b" if x % 2 == 0 else "B")
    c.row(20, 10, 17, "G")
    c.row(24, 9, 18, "r"); c.row(25, 9, 18, "r")
    kit.legs(c, back_leg, front_leg, greaves)


if __name__ == "__main__":
    kit.build("achilles", draw, PALETTE, DOC)
    print("wrote data/art/achilles.json")
