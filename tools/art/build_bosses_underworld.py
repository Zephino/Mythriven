# The Underworld's bosses (Pack 2, docs/PACK_2_PLAN.md; docs/ART_RULES.md: Bosses). Run:
# python3 build_bosses_underworld.py from tools/art/. Writes data/art/bosses/<id>.json for Cerberus (three pictures:
# cerberus with three heads, cerberus_2 and cerberus_1 as his heads fall), Thanatos and Typhon.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

# --- Cerberus (Hesiod, Theogony 311; Apollodorus, Library 2.5.12) ----------------------------------------------

CERB_DOC = ("Cerberus, boss (docs/PACK_2_PLAN.md: the Underworld). Hesiod, Theogony 311 (the hound of Hades) and "
            "Apollodorus, Library 2.5.12: three heads of dogs, a serpent for a tail, and the heads of all kinds of "
            "snakes along his back. A huge dark hound with three snarling heads, glowing eyes, and a serpent tail. "
            "{note} Built by tools/art/build_bosses_underworld.py.")
CERB_SIZE, CERB_ANCHOR = (80, 60), (40, 58)
CERB_WALK = [(0, 0), (3, -3), (0, 0), (-3, 3), (0, 0)]
CERB_PAL = {"o": "#140c08", "k": "#0a0604", "f": "#3a2e2a", "F": "#2a201c", "D": "#1a1412", "l": "#5a4a40",
            "y": "#f08a30", "r": "#8a2020", "w": "#f0ead8", "g": "#4a6a3a", "G": "#6a8a4a", "x": "#2a1e1a"}


def cerb_leg(c, x, top, col, shade):
    poly(c, [(x - 1, top), (x + 6, top), (x + 5, top + 12), (x + 4, 55), (x, 55), (x, top + 10)], col)
    c.rect(x - 1, 55, x + 5, 56, shade)


def dog_head(c, x, y, col, lost=False):
    """One of Cerberus' heads at (x, y) (the back of the skull): a heavy brow, a blunt snarling muzzle, bared teeth.
    `lost`: a fallen head, drawn as a dark stump at the neck instead."""
    if lost:
        ellipse(c, x + 2, y + 6, 3.5, 3, "D"); c.px(x + 3, y + 6, "r"); c.px(x + 2, y + 7, "r")
        return
    ellipse(c, x + 3, y + 4, 5, 4.5, col)
    poly(c, [(x + 2, y), (x + 3, y - 5), (x + 6, y + 1)], col)                       # ear
    poly(c, [(x + 6, y + 2), (x + 14, y + 4), (x + 14, y + 8), (x + 6, y + 9)], col)  # muzzle
    c.rect(x + 13, y + 4, x + 14, y + 5, "k")                                       # nose
    c.row(y + 7, x + 8, x + 14, "k")                                                # the mouth, drawn back
    c.px(x + 9, y + 8, "w"); c.px(x + 11, y + 8, "w"); c.px(x + 13, y + 8, "w")       # fangs
    c.px(x + 6, y + 3, "y"); c.px(x + 7, y + 3, "y")                                # a glowing eye


def cerberus(heads):
    def draw(c, legs):
        front, back = legs
        cerb_leg(c, 20 - back, 36, "F", "D")                       # far legs
        cerb_leg(c, 52 + front, 34, "F", "D")
        for i in range(18):                                        # the serpent tail, curling up behind
            t = i / 17
            x = 15 - t * 10 + math.sin(t * 5) * 2
            y = 34 - t * 18
            ellipse(c, x, y, 2.4 - t, 2.2 - t * 0.8, "g")
        ellipse(c, 6, 15, 2.6, 2, "G"); c.px(4, 15, "k"); c.px(3, 16, "r")
        poly(c, [(16, 34), (22, 26), (40, 25), (52, 22), (60, 24), (62, 34), (56, 40), (24, 40)], "f")   # body
        for x in range(18, 60):                                    # the darker line of the back
            for y in range(20, 32):
                if c.g[y][x] == "f" and c.g[y - 1][x] == ".":
                    c.px(x, y, "D")
        for k in range(5):                                         # snake heads along his back
            x = 26 + k * 6
            c.px(x, 23 - (k % 2), "g"); c.px(x + 1, 22 - (k % 2), "G"); c.px(x + 1, 21 - (k % 2), "g")
        poly(c, [(28, 38), (52, 38), (50, 41), (30, 41)], "D")    # shadow under the belly
        cerb_leg(c, 26 + back, 36, "f", "F")                       # near legs
        cerb_leg(c, 57 - front, 34, "f", "F")
        # Three necks rising from the shoulders, and the heads: back (top), middle, front.
        spots = [(44, 1), (60, 7), (56, 17)]
        for k, (hx, hy) in enumerate(spots):
            poly(c, [(52, 26), (58, 24), (hx + 4, hy + 8), (hx, hy + 7)], "f" if k != 0 else "F")
        for k, (hx, hy) in enumerate(spots):
            dog_head(c, hx, hy, "f" if k != 0 else "F", lost=k >= heads)
    return draw


# --- Thanatos (Euripides, Alcestis; the Sarpedon krater) ---------------------------------------------------------

THAN_DOC = ("Thanatos, boss (docs/PACK_2_PLAN.md: the Underworld). Death himself, brother of Sleep (Hesiod, Theogony "
            "211-212, 758-766). Euripides' Alcestis brings him on stage black-robed with a sword to cut a lock of the "
            "dying; the Sarpedon krater paints him as a bearded, winged warrior. A tall dark-robed winged figure with "
            "a grey beard, grey wings and a drawn sword. Built by tools/art/build_bosses_underworld.py.")
THAN_SIZE, THAN_ANCHOR = (56, 60), (26, 58)
THAN_WALK = [0, 1, 0, -1, 0]
THAN_PAL = {"o": "#140c10", "k": "#0a0608", "s": "#c8a890", "S": "#9a7a64", "h": "#9a9aa0", "d": "#24202a",
            "D": "#16121a", "w": "#7a7a84", "W": "#54545e", "i": "#c8ccd4", "I": "#8a8e98", "u": "#b88a3a"}


def thanatos(c, step):
    for side, col in ((-1, "W"), (1, "w")):                       # great grey wings, half spread
        root = (26, 18)
        tip = (26 + side * 24, 4 + abs(step))
        poly(c, [root, (26 + side * 4, 14), tip, (26 + side * 22, 14), (26 + side * 12, 26)], col)
        for k in range(4):
            c.row(10 + k * 4, min(26, 26 + side * (20 - k * 4)), max(26, 26 + side * (20 - k * 4)), "W" if col == "w" else "D")
    poly(c, [(20, 18), (32, 18), (36, 56), (16, 56)], "d")         # long black robe
    poly(c, [(20, 18), (24, 18), (20, 56), (16, 56)], "D")
    c.rect(22, 56, 24, 57, "k"); c.rect(28 + step, 56, 30 + step, 57, "k")   # feet below the hem
    ellipse(c, 27, 12, 4.5, 5, "s")                               # head
    poly(c, [(23, 13), (31, 13), (30, 19), (24, 19)], "h")        # grey beard
    c.rect(23, 6, 31, 9, "h")                                     # grey hair
    c.px(29, 11, "k")
    c.rect(32, 24, 36, 26, "S")                                   # sword arm
    for x in range(36, 52):                                       # the drawn sword, raised
        c.px(x, 26 - (x - 36) // 3, "i"); c.px(x, 27 - (x - 36) // 3, "I")
    c.rect(35, 24, 36, 28, "u")                                   # hilt


# --- Typhon (Hesiod, Theogony 820-868; Apollodorus, Library 1.6.3) -----------------------------------------------

TYPH_DOC = ("Typhon, boss (docs/PACK_2_PLAN.md: the Underworld). Hesiod, Theogony 820-868: from his shoulders grew "
            "a hundred heads of a snake, with eyes flashing fire. Apollodorus, Library 1.6.3: a man above the thighs, "
            "below them huge coils of vipers, his body winged. A towering giant whose lower body is a mass of serpent "
            "coils, dark wings behind him, and serpent heads writhing from his shoulders. Built by "
            "tools/art/build_bosses_underworld.py.")
TYPH_SIZE, TYPH_ANCHOR = (96, 92), (48, 90)
TYPH_WALK = [0, 1, 2, 1, 0]
TYPH_PAL = {"o": "#140c08", "k": "#0a0604", "s": "#8a6a52", "S": "#6a4e3c", "h": "#2a2220", "g": "#3e5a34",
            "G": "#5a7a44", "q": "#26381e", "y": "#f0a030", "r": "#8a2020", "w": "#3a3238", "W": "#28222a"}


def typhon(c, wr):
    for side, col in ((-1, "W"), (1, "w")):                       # dark wings
        poly(c, [(48, 34), (48 + side * 46, 6 + wr * 2), (48 + side * 40, 30), (48 + side * 26, 46)], col)
    # Below the waist, one huge serpent body looping down to the ground: a thick shaded tube with a pale belly line.
    path = []
    for i in range(70):
        t = i / 69
        path.append((48 + math.sin(t * math.pi * 3.2) * 20 * (0.4 + t * 0.6), 54 + t * 32))
    for x, y in path:                                              # shadow side
        ellipse(c, x + 1, y + 1.5, 7.5, 5.5, "q")
    for x, y in path:
        ellipse(c, x, y, 7, 5, "g")
    for i, (x, y) in enumerate(path):
        c.px(round(x), round(y) + 3, "G")                          # pale belly scales
        if i % 4 == 0:
            c.px(round(x) - 3, round(y) - 2, "q"); c.px(round(x) + 2, round(y) - 3, "q")   # scale marks
    tx, ty = path[-1]
    poly(c, [(tx, ty - 3), (tx + 14, ty + 1), (tx, ty + 3)], "g")  # the tail's end
    poly(c, [(36, 34), (60, 34), (58, 56), (38, 56)], "s")         # the giant's chest
    poly(c, [(36, 34), (41, 34), (40, 56), (38, 56)], "S")
    poly(c, [(36, 36), (30, 34), (24, 22), (28, 20), (34, 30), (38, 32)], "s")   # arms raised to hurl rocks
    poly(c, [(60, 36), (66, 34), (72, 22), (68, 20), (62, 30), (58, 32)], "S")
    ellipse(c, 25, 18, 4, 3.5, "W"); ellipse(c, 71, 18, 4, 3.5, "W")             # rocks in his hands
    c.px(24, 17, "y"); c.px(71, 17, "y")
    ellipse(c, 48, 27, 6, 7, "s")                                   # head
    c.rect(42, 19, 54, 23, "h")                                     # wild dark hair
    c.px(46, 26, "y"); c.px(51, 26, "y")                            # eyes flashing fire
    c.row(31, 45, 51, "k")
    for k in range(9):                                              # serpent heads from his shoulders
        ang = math.pi + k * math.pi / 8
        x0, y0 = 48 + math.cos(ang) * 10, 34
        for t in range(10):
            x = x0 + math.cos(ang) * t * 2.2
            y = y0 + math.sin(ang) * t * 1.4 - t * 0.6 + math.sin(t + k + wr) * 1.2
            c.px(round(x), round(y), "g"); c.px(round(x) + 1, round(y), "q")
        hx = round(x0 + math.cos(ang) * 22); hy = round(y0 + math.sin(ang) * 14 - 6)
        ellipse(c, hx, hy, 2.4, 1.8, "G"); c.px(hx + (1 if math.cos(ang) > 0 else -1), hy, "y")


if __name__ == "__main__":
    notes = {3: "", 2: "One head has fallen.", 1: "Two heads have fallen."}
    for heads, name in ((3, "cerberus"), (2, "cerberus_2"), (1, "cerberus_1")):
        kit.build_boss(name, cerberus(heads), CERB_PAL, CERB_DOC.format(note=notes[heads]), CERB_SIZE, CERB_ANCHOR, CERB_WALK)
        print("wrote data/art/bosses/%s.json" % name)
    kit.build_boss("thanatos", thanatos, THAN_PAL, THAN_DOC, THAN_SIZE, THAN_ANCHOR, THAN_WALK)
    print("wrote data/art/bosses/thanatos.json")
    kit.build_boss("typhon", typhon, TYPH_PAL, TYPH_DOC, TYPH_SIZE, TYPH_ANCHOR, TYPH_WALK)
    print("wrote data/art/bosses/typhon.json")
