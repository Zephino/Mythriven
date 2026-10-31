# The Underworld's gods, Hecate and Persephone (Pack 2, docs/PACK_2_PLAN.md; docs/ART_RULES.md: Gods). Run:
# python3 build_gods_underworld.py from tools/art/. Writes data/art/gods/<id>.json, drawn in the same frame as Tyche
# so they sit on the Greek shrine throne the same way.
import hero_kit as kit
from hero_kit import ellipse, poly

SIZE, ANCHOR = (48, 62), (22, 60)
STANCE = (18, 23)
WALK = [STANCE, (16, 25), STANCE, (20, 21), STANCE]
SEATED = {"style": "greek", "hip": 40, "lap": "b", "shin": "b", "foot": "n", "keep": range(32, 38)}

HECATE_DOC = ("Hecate, god (docs/PACK_2_PLAN.md: the Underworld). Hesiod, Theogony 411-452 (honoured by Zeus above "
              "all); the Homeric Hymn to Demeter 52 (she comes bearing a torch to help search for Persephone); "
              "Greek vase painting shows her in a long robe holding two torches. A goddess in a dark violet peplos "
              "and black mantle, a torch raised in each hand. Built by tools/art/build_gods_underworld.py.")
PERSEPHONE_DOC = ("Persephone, god (docs/PACK_2_PLAN.md: the Underworld). The Homeric Hymn to Demeter: Demeter's "
                  "daughter, carried off by Hades, who ate the pomegranate seed and so returns below for part of every "
                  "year, and comes back up with the spring. As Greek art shows her (the Locri pinakes, vase painting): "
                  "a crowned queen in a pale chiton holding a pomegranate and ears of wheat. Built by "
                  "tools/art/build_gods_underworld.py.")

HECATE_PAL = {"o": "#140c10", "k": "#0a0608", "s": "#e2b490", "S": "#b2845e", "h": "#1c1418", "H": "#0e0a0c",
              "b": "#4a3060", "B": "#2e1e40", "m": "#1e1a22", "M": "#121016", "t": "#7a5030", "f": "#f0a030",
              "F": "#ffe080", "n": "#3a2a2a"}
PERSEPHONE_PAL = {"o": "#24160e", "k": "#140c08", "s": "#e8bc96", "S": "#b88a64", "h": "#5a3418", "H": "#3a200c",
                  "b": "#e8e2d4", "B": "#b8b0a0", "m": "#5a8a4a", "M": "#3e6a32", "u": "#e0b848", "U": "#a07a20",
                  "r": "#b02a3a", "R": "#7a1a28", "w": "#e0c060", "n": "#6a4a2a"}


def face(c):
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S")
    c.px(23, 12, "k"); c.px(26, 13, "s"); c.px(26, 14, "s"); c.row(16, 21, 23, "S")
    c.rect(19, 18, 23, 19, "s"); c.px(19, 18, "S")


def robe(c, main, fold, mantle, mantle_d):
    for y in range(20, 57):
        x0, x1 = (16, 27) if y < 44 else (15 - (y - 44) // 6, 28 + (y - 44) // 6)
        c.row(y, x0, x1, main)
        if y > 34:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, fold)
    c.rect(16, 20, 17, 43, fold)
    for y in range(20, 40):                               # a mantle over the shoulders, falling behind
        c.row(y, 15, 17 + max(0, 6 - (y - 20) // 3), mantle)
        c.px(15, y, mantle_d)


def feet(c, legs):
    for x0 in legs:
        c.rect(x0, 57, x0 + 4, 58, "s"); c.row(58, x0, x0 + 4, "n")


def torch(c, x, y):
    c.rect(x, y, x + 1, y + 12, "t")
    ellipse(c, x + 0.5, y - 2, 2.2, 3, "f"); c.px(x, y - 3, "F"); c.px(x + 1, y - 2, "F")


def hecate(c, legs):
    c.rect(14, 6, 26, 18, "h"); c.rect(14, 6, 15, 18, "H")        # dark hair under a veil
    c.rect(13, 5, 27, 6, "m")
    face(c)
    robe(c, "b", "B", "m", "M")
    c.rect(12, 21, 14, 30, "S"); c.rect(10, 27, 13, 29, "s")         # far arm raising a torch
    torch(c, 10, 14)
    c.rect(26, 21, 28, 28, "s"); c.rect(28, 26, 32, 28, "s")          # near arm, a torch held out
    torch(c, 32, 12)
    feet(c, legs)


def persephone(c, legs):
    c.rect(14, 9, 18, 20, "h"); c.rect(11, 10, 13, 15, "h"); c.rect(14, 9, 15, 20, "H")   # hair, long
    c.rect(16, 5, 25, 8, "u"); c.row(5, 16, 25, "U")                  # a queen's crown (stephane)
    for x in (17, 20, 23):
        c.px(x, 4, "u")
    face(c)
    robe(c, "b", "B", "m", "M")
    c.rect(12, 21, 14, 31, "S"); c.rect(10, 31, 14, 33, "s")          # far arm, ears of wheat against the shoulder
    for k in range(4):
        c.rect(9 + k, 14 + k, 9 + k, 31, "w")
        c.px(9 + k, 13 + k, "u")
    c.rect(26, 21, 28, 28, "s"); c.rect(28, 27, 31, 29, "s")          # near hand holding out the pomegranate
    ellipse(c, 33, 27, 2.6, 2.6, "r"); c.px(34, 26, "R"); c.px(33, 24, "R")
    feet(c, legs)


if __name__ == "__main__":
    kit.build_boss("hecate", hecate, HECATE_PAL, HECATE_DOC, SIZE, ANCHOR, WALK, folder="gods", seated=SEATED)
    print("wrote data/art/gods/hecate.json")
    kit.build_boss("persephone", persephone, PERSEPHONE_PAL, PERSEPHONE_DOC, SIZE, ANCHOR, WALK, folder="gods", seated=SEATED)
    print("wrote data/art/gods/persephone.json")
