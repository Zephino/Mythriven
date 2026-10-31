# Achilles (docs/ART_RULES.md). Run: python3 tools/art/build_achilles.py
# Writes data/art/achilles.json on the shared body in hero_kit.py.
import math
import hero_kit as kit

DOC = ("Achilles (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_achilles.py on the shared body in "
       "tools/art/hero_kit.py; rules in docs/ART_RULES.md. From Homer's Iliad: golden-haired (1.197); the armour Hephaestus "
       "forges in book 18: a helmet with a crest of gold, a corslet brighter than fire, greaves of tin, and the great round "
       "shield, held on his far arm across his body (it stays whatever weapon he holds). Bronze breastplate, a skirt of leather "
       "strips over a red chiton, and sandals. His spear is drawn separately (data/art/weapons/) at his hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#e2a676", "S": "#b0724a",                 # Mediterranean skin, as Heracles
    "a": "#e0b860", "A": "#b08a3a",                 # golden hair (xanthos)
    "g": "#c89a3c", "G": "#8a6420",                 # bronze (helmet, breastplate, shield)
    "u": "#f0cc58", "v": "#c8a030", "y": "#fff0b0",  # gold crest and its shadow, bronze highlight
    "b": "#6a4422", "B": "#4a2e16",                 # leather strips
    "r": "#a83a2c",                                 # red chiton
    "i": "#c4c8d0", "I": "#8a8e96",                 # tin greaves
    "n": "#5c3a1c",                                 # sandals
}


def greaves(c, x0):
    c.rect(x0, 28, x0 + 2, 30, "i"); c.px(x0, 28, "I"); c.px(x0, 29, "I")
    c.row(31, x0, x0 + 3, "n")


def shield(c):
    """The great round shield, held on his far arm across his body (owner request 10/31/2026): bronze, with a
    darker rim, an inner ring, and a gold boss. A dark ring keeps it apart from the body behind it."""
    cx, cy = 11.5, 18.5
    for y in range(11, 27):
        for x in range(4, 20):
            d = math.hypot(x - cx, y - cy)
            if d <= 5.5:
                c.px(x, y, "G" if d > 4.6 or 2.4 < d <= 3.2 else "g")
            elif d <= 6.3 and c.g[y][x] != ".":
                c.px(x, y, "o")
    c.rect(11, 18, 12, 19, "u"); c.px(11, 18, "y")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    # Bronze helmet: a rounded dome, a brim with a nose guard, a cheek guard, and a guard over the nape
    c.row(3, 11, 16, "g"); c.rect(10, 4, 17, 6, "g")
    c.px(12, 4, "y"); c.px(13, 4, "y"); c.px(11, 5, "y")       # light on the bronze
    c.row(7, 10, 17, "G"); c.rect(17, 8, 17, 9, "G")           # brim and nose guard
    c.rect(10, 8, 11, 10, "g"); c.px(10, 10, "G")              # nape guard
    c.rect(12, 8, 12, 10, "g"); c.px(12, 11, "G")             # cheek guard
    # The crest of gold (Iliad 18): a ridge over the helmet, apart from it, with its tail falling behind
    c.row(2, 10, 17, "o"); c.px(10, 3, "o"); c.px(17, 3, "o")
    c.row(1, 8, 16, "u"); c.px(17, 2, "u"); c.px(16, 1, "v")
    c.rect(6, 2, 9, 2, "u"); c.rect(6, 3, 8, 7, "u"); c.rect(6, 8, 7, 9, "u")
    c.px(6, 5, "v"); c.px(6, 7, "v"); c.px(6, 9, "v")
    c.rect(9, 3, 9, 8, "o")
    # Golden hair below the nape guard
    c.rect(9, 11, 11, 12, "a"); c.px(9, 12, "A")
    # Face: forehead under the brim, eye, nose, mouth, chin
    c.rect(13, 8, 16, 12, "s"); c.px(15, 9, "k"); c.px(18, 10, "s"); c.px(17, 10, "s"); c.px(17, 11, "s")
    c.px(15, 11, "S"); c.px(14, 12, "S")
    # Bronze breastplate with chest and stomach lines
    c.rect(10, 13, 17, 19, "g"); c.rect(10, 13, 11, 19, "G")
    c.row(15, 12, 13, "G"); c.row(15, 15, 16, "G"); c.px(14, 16, "G"); c.px(14, 17, "G"); c.px(14, 18, "G")
    # Skirt of leather strips over a red chiton
    for x in range(10, 18):
        c.rect(x, 20, x, 23, "b" if x % 2 == 0 else "B")
    c.row(20, 10, 17, "G")
    c.row(24, 9, 18, "r"); c.row(25, 9, 18, "r")
    shield(c)
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, greaves)


if __name__ == "__main__":
    kit.build("achilles", draw, PALETTE, DOC)
    print("wrote data/art/achilles.json")
