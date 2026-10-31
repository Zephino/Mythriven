# Jotunheim's art (Pack 2, docs/PACK_2_PLAN.md; docs/ART_RULES.md): the mountain giant (enemy), the bosses Hrungnir,
# Thrym and Ymir, and the gods Odin and Freyja. Run: python3 build_jotunheim.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def giant_body(c, w, h, skin, skin_d, fur, fur_d, step=0):
    """A big rough giant facing right, scaled to its canvas: thick legs, a fur wrap, a broad chest and shoulders,
    long arms, a heavy head. Returns where things are, for each giant's own details."""
    k = w / 30.0
    cx = w // 2
    leg_w, leg_h = max(3, round(4 * k)), round(12 * k)
    for n, d in enumerate((-step, step)):                                        # legs
        x = cx - round(5 * k) + n * round(6 * k) + d
        c.rect(x, h - 2 - leg_h, x + leg_w, h - 2, skin_d if n == 0 else skin)
        c.rect(x - 1, h - 2, x + leg_w + 1, h - 1, fur_d)
    waist, hip = h - 2 - leg_h, round(10 * k)
    top = waist - round(17 * k)
    poly(c, [(cx - hip, top + round(5 * k)), (cx + hip, top + round(5 * k)), (cx + hip + 1, waist), (cx - hip - 1, waist)], fur)
    poly(c, [(cx - hip, top + round(5 * k)), (cx - hip + 3, top + round(5 * k)), (cx - hip + 2, waist), (cx - hip - 1, waist)], fur_d)
    sh = round(11 * k)
    poly(c, [(cx - sh, top), (cx + sh, top), (cx + hip, top + round(6 * k)), (cx - hip, top + round(6 * k))], skin)   # shoulders
    poly(c, [(cx - sh, top), (cx - sh + 3, top), (cx - hip + 2, top + round(6 * k)), (cx - hip, top + round(6 * k))], skin_d)
    hr = round(6 * k)
    hy = top - hr + 1
    c.rect(cx - round(2 * k), top - 2, cx + round(2 * k), top, skin)            # neck
    ellipse(c, cx + 1, hy, hr, hr, skin)                                         # head
    c.px(cx + round(3 * k), hy - 1, "k"); c.px(cx + round(3 * k) + 1, hy - 1, "k")
    c.row(hy + round(3 * k), cx + 1, cx + round(4 * k), skin_d)
    arm = round(4 * k)
    c.rect(cx - sh - arm + 1, top + 1, cx - sh, top + round(14 * k), skin_d)     # far arm hanging
    return {"cx": cx, "k": k, "top": top, "waist": waist, "head": (cx + 1, hy, hr), "sh": sh, "arm": arm}


# --- Mountain giant, bergrisi (Snorri, Gylfaginning 42) ----------------------------------------------------------

BERG_PAL = {"o": "#140c08", "k": "#0a0604", "s": "#8a8478", "S": "#625c52", "f": "#5a4632", "F": "#3e3022",
            "r": "#7a7c80", "R": "#55565c", "h": "#3a3028"}


def bergrisi(c, f):
    g = giant_body(c, 30, 58, "s", "S", "f", "F", step=STEP[f])
    hx, hy, hr = g["head"]
    ellipse(c, hx - 1, hy - hr + 2, hr, 3, "h")                                  # matted hair
    x = g["cx"] + g["sh"]
    c.rect(x - 1, g["top"] - 8, x + 2, g["top"] + 2, "s")                        # arm raised overhead
    ellipse(c, x + 1, g["top"] - 11, 5, 4, "r"); ellipse(c, x, g["top"] - 12, 2.5, 1.5, "R")   # the boulder


# --- Hrungnir (Skaldskaparmal 17) ----------------------------------------------------------------------------------

HRUNG_DOC = ("Hrungnir, boss (docs/PACK_2_PLAN.md: Jotunheim). Snorri, Skaldskaparmal 17: the strongest of giants, whose "
             "heart was of hard stone, sharp-pointed with three corners, whose head too was stone, who held a stone "
             "shield before him and a whetstone as his weapon, until Thor's hammer broke it. A grey stone giant with "
             "a three-cornered stone heart, a slab shield and a great whetstone. Built by tools/art/build_jotunheim.py.")
HRUNG_PAL = {"o": "#140c08", "k": "#0a0604", "s": "#8a8c90", "S": "#64666c", "f": "#4a4c52", "F": "#34363a",
             "q": "#a8aab0", "y": "#e0c060", "w": "#b8b4a8", "W": "#8a8478"}


def hrungnir(c, step):
    g = giant_body(c, 52, 72, "s", "S", "f", "F", step=step)
    cx, top, k = g["cx"], g["top"], g["k"]
    for x, y in ((cx - 6, top + 3), (cx + 2, top + 6), (cx - 2, top + 12)):      # cracks in the stone
        c.px(x, y, "F"); c.px(x + 1, y + 1, "F"); c.px(x + 2, y + 1, "F")
    poly(c, [(cx - 3, top + 4), (cx + 3, top + 4), (cx, top + 9)], "q"); c.px(cx, top + 5, "y")   # the three-cornered heart
    poly(c, [(cx - g["sh"] - 10, top), (cx - g["sh"] + 2, top - 3), (cx - g["sh"] + 4, top + 26), (cx - g["sh"] - 8, top + 29)], "S")
    poly(c, [(cx - g["sh"] - 8, top + 2), (cx - g["sh"], top - 1), (cx - g["sh"] + 2, top + 24), (cx - g["sh"] - 6, top + 27)], "s")
    x = cx + g["sh"]
    c.rect(x - 1, top + 2, x + 3, top + 7, "s")                                  # arm, swinging the whetstone
    poly(c, [(x + 2, top + 5), (x + 12, top - 16), (x + 15, top - 14), (x + 5, top + 8)], "w")
    poly(c, [(x + 12, top - 16), (x + 15, top - 14), (x + 15, top - 18)], "W")


# --- Thrym (Thrymskvida) -------------------------------------------------------------------------------------------

THRYM_DOC = ("Thrym, boss (docs/PACK_2_PLAN.md: Jotunheim). Thrymskvida, Poetic Edda: the lord of the giants, who sat on "
             "a mound plaiting golden collars for his dogs, and who stole Thor's hammer and hid it deep under the earth. "
             "A towering pale-blue frost giant in furs, golden dog-collars hanging from his belt. Built by "
             "tools/art/build_jotunheim.py.")
THRYM_PAL = {"o": "#140c08", "k": "#0a0604", "s": "#a8bcd0", "S": "#7a90a8", "f": "#6a5a48", "F": "#4a3e30",
             "h": "#e8eef4", "u": "#e8c050", "U": "#a88820"}


def thrym(c, step):
    g = giant_body(c, 50, 72, "s", "S", "f", "F", step=step)
    hx, hy, hr = g["head"]
    cx, top = g["cx"], g["top"]
    ellipse(c, hx - 2, hy - hr + 2, hr, 3, "h")                                  # frost-white hair
    poly(c, [(hx - 3, hy + 2), (hx + hr, hy + 2), (hx + 2, hy + hr + 5), (hx - 2, hy + hr + 3)], "h")   # long beard
    for n in range(3):                                                           # golden collars at his belt
        ellipse(c, cx - 6 + n * 6, top + 16, 2.6, 2.2, "u"); ellipse(c, cx - 6 + n * 6, top + 16, 1.2, 0.8, "f")
    x = cx + g["sh"]
    c.rect(x - 1, top + 1, x + 3, top + 14, "s")                                 # arm


# --- Ymir (Gylfaginning 5-6) ---------------------------------------------------------------------------------------

YMIR_DOC = ("Ymir, boss (docs/PACK_2_PLAN.md: Jotunheim). Snorri, Gylfaginning 5-6: the first of all giants, formed from "
            "the rime where the frost of Niflheim met the heat of Muspell, from whose body the gods later made the world. "
            "A colossal rime-white giant crusted with ice, icicles hanging from his arms and beard. Built by "
            "tools/art/build_jotunheim.py.")
YMIR_PAL = {"o": "#141820", "k": "#0a0c10", "s": "#dfe8f0", "S": "#a8b8c8", "f": "#8aa8c4", "F": "#6a88a8",
            "i": "#f4fbff", "b": "#7ac0e8"}


def ymir(c, step):
    g = giant_body(c, 66, 88, "s", "S", "f", "F", step=step)
    hx, hy, hr = g["head"]
    cx, top = g["cx"], g["top"]
    ellipse(c, hx - 2, hy - hr + 3, hr + 1, 4, "i")                              # rime-white hair
    poly(c, [(hx - 4, hy + 3), (hx + hr, hy + 3), (hx + 3, hy + hr + 9), (hx - 3, hy + hr + 6)], "i")   # long rime beard
    for x in range(hx - 2, hx + 4, 2):
        c.px(x, hy + hr + 8, "b"); c.px(x, hy + hr + 9, "b")                     # icicles from the beard
    x = cx + g["sh"]
    c.rect(x - 1, top + 1, x + 4, top + 20, "s")                                 # arm
    for y in (top + 8, top + 13, top + 18):
        c.px(x + 5, y, "b"); c.px(x + 5, y + 1, "i")                             # icicles hanging from it
    for px_, py in ((cx - 8, top + 8), (cx + 5, top + 20), (cx - 3, g["waist"] + 8)):   # crusts of ice
        ellipse(c, px_, py, 3, 2, "i")


# --- Odin and Freyja (gods) ---------------------------------------------------------------------------------------

GOD_SIZE, GOD_ANCHOR = (48, 62), (22, 60)
STANCE = (18, 23)
GOD_WALK = [STANCE, (16, 25), STANCE, (20, 21), STANCE]
SEATED = {"style": "norse", "hip": 40, "lap": "b", "shin": "b", "foot": "n", "keep": range(32, 38)}

ODIN_DOC = ("Odin, god (docs/PACK_2_PLAN.md: Jotunheim). The All-Father: one eye given for a drink from Mimir's well "
            "(Gylfaginning 15), his spear Gungnir and his ravens Huginn and Muninn (Grimnismal 20; Gylfaginning 38); in "
            "the sagas he comes as a tall old one-eyed man in a broad hat and a dark-blue cloak (Volsunga saga 3). "
            "Built by tools/art/build_jotunheim.py.")
FREYJA_DOC = ("Freyja, god (docs/PACK_2_PLAN.md: Jotunheim). Her necklace Brisingamen and her falcon-feather cloak "
              "(Thrymskvida 3, 13); she takes half the slain to her hall Folkvangr (Grimnismal 14; Gylfaginning 24). "
              "A golden-haired goddess in a green gown with the gold necklace at her throat and a cloak of falcon "
              "feathers. Built by tools/art/build_jotunheim.py.")
ODIN_PAL = {"o": "#140c08", "k": "#0a0604", "s": "#e2b490", "S": "#b2845e", "h": "#c8c8cc", "b": "#2a3a6a",
            "B": "#1a2648", "m": "#3a3a40", "M": "#24242a", "w": "#7a5a3a", "i": "#c8ccd4", "r": "#1a1a20", "n": "#4a3a2a"}
FREYJA_PAL = {"o": "#24160e", "k": "#140c08", "s": "#ecc4a0", "S": "#bc946e", "h": "#e0b848", "H": "#b08a28",
              "b": "#3a7a4a", "B": "#265a34", "u": "#f0cc58", "U": "#b08a28", "m": "#8a6a4a", "M": "#5e4630",
              "q": "#c8b090", "n": "#6a4a2a"}


def robe(c, main, fold):
    for y in range(20, 57):
        x0, x1 = (16, 27) if y < 44 else (15 - (y - 44) // 6, 28 + (y - 44) // 6)
        c.row(y, x0, x1, main)
        if y > 34:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, fold)
    c.rect(16, 20, 17, 43, fold)


def feet(c, legs):
    for x0 in legs:
        c.rect(x0, 57, x0 + 4, 58, "s"); c.row(58, x0, x0 + 4, "n")


def odin(c, legs):
    robe(c, "b", "B")
    for y in range(18, 52):                                                      # dark cloak behind
        c.px(15, y, "M"); c.px(14, y, "m")
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S")
    c.px(23, 12, "k"); c.rect(21, 11, 22, 12, "r")                              # one eye; the other closed
    poly(c, [(17, 15), (26, 15), (24, 22), (19, 22)], "h")                       # grey beard
    c.rect(14, 6, 29, 7, "m"); c.rect(17, 2, 26, 6, "M")                         # broad-brimmed hat
    c.rect(28, 21, 30, 30, "s")
    c.rect(32, 4, 33, 58, "w"); poly(c, [(31, 4), (34, 4), (32, 0)], "i")       # Gungnir
    for x, y in ((12, 18), (27, 17)):                                            # the ravens on his shoulders
        ellipse(c, x, y, 2.4, 1.8, "r"); c.px(x + 2, y, "k")
    feet(c, legs)


def freyja(c, legs):
    for y in range(18, 50):                                                      # falcon-feather cloak
        for x in range(12, 16):
            c.px(x, y, "m" if (x + y) % 3 else "q")
    robe(c, "b", "B")
    c.rect(14, 8, 18, 22, "h"); c.rect(14, 8, 15, 22, "H")                       # long golden hair
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S")
    c.px(23, 12, "k"); c.row(16, 21, 23, "S")
    c.rect(17, 7, 25, 8, "h")
    c.row(19, 18, 25, "u"); c.px(21, 20, "U"); c.px(22, 20, "u"); c.px(23, 20, "U")   # Brisingamen
    c.rect(26, 21, 28, 28, "s")
    feet(c, legs)


# --- Beowulf (the Old English poem) --------------------------------------------------------------------------------

BEO_DOC = ("Beowulf (docs/PACK_2_PLAN.md: Jotunheim's Hero; art 10/31/2026). Built by tools/art/build_jotunheim.py on the "
           "shared body in tools/art/hero_kit.py. From the Old English poem: the Geat who tore off Grendel's arm "
           "bare-handed, with the hand-grip of thirty men (lines 379-381), in a ring-mail shirt (byrnie) and a helmet "
           "with boar figures over the cheek-guards (lines 303-306, 1448-1454). Fair-skinned, a fair beard.")
BEO_PAL = {"o": "#24160e", "k": "#140c08", "s": "#e8c0a0", "S": "#b8906e", "h": "#c89a4a", "H": "#9a7230",
           "i": "#9aa2ac", "I": "#6a727c", "u": "#d0a048", "U": "#8a6420", "b": "#5a3e26", "B": "#3a2818"}


def beowulf(c, back_leg, front_leg):
    kit.far_arm(c)
    c.rect(10, 3, 16, 6, "i"); c.rect(10, 3, 10, 7, "I"); c.row(2, 11, 15, "u")  # helmet, boar crest in gold
    c.px(13, 1, "u"); c.px(14, 1, "U")
    c.rect(12, 7, 16, 12, "s"); c.px(12, 8, "S"); c.px(15, 9, "k"); c.px(17, 9, "s")
    c.rect(12, 11, 16, 13, "h"); c.px(12, 12, "H")                               # fair beard
    for y in range(14, 25):                                                      # ring-mail shirt
        c.row(y, 9, 18, "i")
        for x in range(9 + (y % 2), 19, 2):
            c.px(x, y, "I")
    c.row(20, 9, 18, "b"); c.px(14, 20, "u")                                     # belt and buckle
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, lambda c, x0: (c.rect(x0, 28, x0 + 2, 30, "b"), c.row(31, x0, x0 + 3, "B")))


if __name__ == "__main__":
    kit.build_boss("bergrisi", bergrisi, BERG_PAL,
                   "Mountain giant, bergrisi (docs/PACK_2_PLAN.md: Jotunheim). Snorri, Gylfaginning 42 (the builder of "
                   "Asgard's wall was a bergrisi). A grey-skinned hill giant in rough furs, hurling a boulder. Built by "
                   "tools/art/build_jotunheim.py.", (30, 58), (15, 56), [0, 1, 2, 3, 4], folder="enemies")
    for name, draw, pal, doc, size, anchor in (
            ("hrungnir", hrungnir, HRUNG_PAL, HRUNG_DOC, (52, 72), (26, 70)),
            ("thrym", thrym, THRYM_PAL, THRYM_DOC, (50, 72), (25, 70)),
            ("ymir", ymir, YMIR_PAL, YMIR_DOC, (66, 88), (33, 86))):
        kit.build_boss(name, draw, pal, doc, size, anchor, [0, 1, 0, -1, 0])
    kit.build_boss("odin", odin, ODIN_PAL, ODIN_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    kit.build_boss("freyja", freyja, FREYJA_PAL, FREYJA_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    kit.build("beowulf", beowulf, BEO_PAL, BEO_DOC, recolor=["b", "B"])
    print("wrote Jotunheim's art")
