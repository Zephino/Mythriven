# Tyche, god (docs/ART_RULES.md: Gods). Run: python3 build_god_tyche.py from tools/art/.
# Writes data/art/gods/tyche.json.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

DOC = ("Tyche, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_tyche.py; rules in "
       "docs/ART_RULES.md. Goddess of fortune: Hesiod, Theogony 360 (a daughter of Ocean); Pindar, Olympian 12 (Tyche "
       "the Saviour, who steers swift ships at sea). As Hellenistic statues show her (the Tyche of Antioch by "
       "Eutychides, and later copies): a crown shaped like a city's walls and towers, a long chiton with a mantle "
       "draped round her, the cornucopia (horn of plenty) in one arm and the ship's steering oar in her hand.")

SIZE, ANCHOR = (48, 62), (22, 60)
STANCE = (18, 23)
WALK = [STANCE, (16, 25), STANCE, (20, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#e8b48a", "S": "#b8835c",                 # Mediterranean skin
    "h": "#4a2c18", "H": "#2e1a0c",                 # dark hair
    "c": "#e0d4b0", "C": "#a89a74",                 # the stone of her mural crown
    "b": "#3a5a9a", "B": "#26406e",                 # long blue chiton
    "y": "#e0a830", "Y": "#a87a1c",                 # saffron mantle
    "g": "#e0b848", "G": "#a07a20",                 # gold cornucopia
    "r": "#c83a30", "p": "#6a3a8a", "l": "#6aa040",  # fruit: apples, grapes, leaves
    "w": "#9a6232", "W": "#6a4020",                 # wooden steering oar
    "n": "#6a4a2a",                                 # sandals
}


def cornucopia(c):
    """The horn of plenty in her far arm: a curved gold horn opening upward, spilling fruit."""
    for i in range(14):
        t = i / 13
        x = 11 - math.sin(t * 2.2) * 5; y = 37 - t * 15
        r = 0.8 + t * 2.4
        for yy in range(int(y - r) - 1, int(y + r) + 2):
            for xx in range(int(x - r) - 1, int(x + r) + 2):
                if math.hypot(xx - x, yy - y) <= r:
                    c.px(xx, yy, "g")
        if i % 3 == 0:
            c.px(round(x), round(y), "G")                  # bands round the horn
    ellipse(c, 7.5, 19.5, 3.5, 2.5, "l")
    c.rect(5, 18, 6, 19, "r"); c.rect(9, 17, 10, 18, "r"); c.px(7, 17, "p"); c.px(8, 16, "p"); c.px(7, 18, "p")


def oar(c, x):
    """The steering oar: a long wooden shaft, its broad blade resting on the ground."""
    c.rect(x, 14, x + 1, 50, "w"); c.rect(x, 14, x, 50, "W")
    poly(c, [(x - 1, 49), (x + 3, 49), (x + 3, 58), (x - 1, 58)], "w"); c.rect(x - 1, 49, x - 1, 58, "W")
    c.rect(x - 1, 13, x + 2, 13, "W")


def draw(c, legs):
    back, front = legs
    # Mural crown: battlements and towers of a city wall
    c.rect(15, 4, 26, 8, "c"); c.row(8, 15, 26, "C")
    for x in (15, 18, 21, 24):
        c.rect(x, 2, x + 1, 3, "c")
    c.rect(20, 5, 21, 7, "C"); c.px(17, 6, "C"); c.px(24, 6, "C")
    # Dark hair waved back into a knot
    c.rect(14, 9, 18, 18, "h"); c.rect(11, 10, 13, 13, "h"); c.rect(14, 9, 15, 18, "H"); c.px(11, 11, "H")
    # Face: forehead, eye, nose, chin
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S")
    c.px(23, 12, "k"); c.px(26, 13, "s"); c.px(26, 14, "s"); c.row(16, 21, 23, "S")
    c.rect(19, 18, 23, 19, "s"); c.px(19, 18, "S")
    # Far arm, holding the cornucopia against her shoulder
    c.rect(12, 21, 14, 33, "S")
    cornucopia(c)
    c.rect(10, 33, 14, 35, "s")
    # Long blue chiton to her feet, folds
    for y in range(20, 57):
        x0, x1 = (16, 27) if y < 44 else (15 - (y - 44) // 6, 28 + (y - 44) // 6)
        c.row(y, x0, x1, "b")
        if y > 34:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "B")
    c.rect(16, 20, 17, 43, "B")
    # Saffron mantle draped from her far shoulder across her body to the knee
    for y in range(21, 46):
        reach = 16 + int((y - 21) * 0.55)
        c.row(y, max(16, reach - 6), min(reach + 5, 28), "y")
        c.px(min(reach + 5, 28), y, "Y")
    for y in range(24, 46):
        x = 16 + int((y - 21) * 0.55) + 1
        if 16 < x < 27 and y % 2 == 0:
            c.px(x, y, "Y")                                  # a fold running down the drape
    # Near arm, the hand on the steering oar
    c.rect(26, 21, 28, 28, "s"); c.rect(25, 22, 25, 28, "o")
    c.rect(28, 28, 32, 30, "s"); c.row(30, 28, 32, "S")
    oar(c, 34)
    c.rect(33, 27, 36, 30, "s"); c.row(30, 33, 36, "S")
    # Sandalled feet below the hem
    for x0 in (back, front):
        c.rect(x0, 57, x0 + 4, 58, "s"); c.row(58, x0, x0 + 4, "n")


if __name__ == "__main__":
    kit.build_boss("tyche", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods",
                  seated={"style": "greek", "hip": 40, "lap": "b", "shin": "b", "foot": "n", "keep": range(32, 38)})
    print("wrote data/art/gods/tyche.json")
