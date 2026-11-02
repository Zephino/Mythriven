# The Abyss's art (Pack 11, docs/PACK_11_PLAN.md; docs/ART_RULES.md), one realm at a time. Ashkarrow is the game's own
# invented city (nothing from any religion); the rest is drawn only from the old texts (the Historia Brittonum, "Lludd
# and Llefelys", Plato's Timaeus and Critias, the Eddas), never later versions.
# Run: python3 build_abyss.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly
from figure_kit import person
from build_gothic import rim

STEP = [0, -1, 0, 1, 0]


def figure(c, step, robe, skin, hair, legs="k", x0=14, top=18, bottom=50):
    """A standing figure in a long robe (shared by the boss figures)."""
    for k, d in enumerate((-step, step)):
        c.rect(x0 + 2 + k * 6 + d, bottom - 2, x0 + 4 + k * 6 + d, bottom + 4, legs)
    poly(c, [(x0, top), (x0 + 14, top), (x0 + 17, bottom), (x0 - 3, bottom)], robe)
    c.rect(x0 + 2, top - 12, x0 + 11, top - 2, skin)
    c.rect(x0, top - 15, x0 + 13, top - 11, hair)
    c.px(x0 + 4, top - 8, "o"); c.px(x0 + 9, top - 8, "o")


# --- Ashkarrow (invented for Mythriven) ----------------------------------------------------------------------------

def ash_fiend(c, f):
    """An ash fiend (Ashkarrow, the game's own): one of the grey, hunched dwellers of the city of ash, made of ash with
    embers glowing through the cracks; long arms with claws, ember eyes, sparks rising off its shoulders."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "a"); c.row(23, x + d - 1, x + 2 + d, "a")
    ellipse(c, 9, 12, 5.5, 6, "g"); ellipse(c, 7, 14, 3.5, 4.5, "a")                    # hunched body
    poly(c, [(4, 9), (2, 14), (1, 19), (3, 19), (5, 14)], "a"); c.px(1, 20, "e"); c.px(3, 20, "e")   # long far arm
    poly(c, [(13, 9), (16, 13), (17, 19), (15, 19), (14, 14)], "g"); c.px(15, 20, "e"); c.px(17, 20, "e")   # near arm, claws
    for x, y in ((8, 10), (9, 11), (10, 13), (11, 14), (7, 16), (8, 17)):
        c.px(x, y, "e")                                                                  # glowing cracks
    ellipse(c, 12, 6, 3, 2.6, "g"); c.px(11, 4, "a")                                     # head, thrust forward
    c.px(12, 6, "E"); c.px(14, 6, "E"); c.row(8, 12, 14, "a")
    c.px(6, 5 - s, "e"); c.px(9, 3 + s, "E")                                             # sparks rising


ASH_FIEND_PAL = {"o": "#120c0a", "g": "#5e5654", "a": "#3e3634", "e": "#f07a2a", "E": "#ffd060"}


def cinder_imp(c, f):
    """A cinder imp (Ashkarrow, the game's own): a little spark of the city with arms and legs, a flame for a body,
    swarming out of the cracks in the streets."""
    s = STEP[f]
    c.px(4 - s, 10, "R"); c.px(4 - s, 11, "k"); c.px(8 + s, 10, "R"); c.px(8 + s, 11, "k")   # little legs
    poly(c, [(2, 9), (10, 9), (9, 4), (7, 1 + (f % 2)), (6, 3), (4, 0 + (f % 2)), (3, 4)], "r")   # flame body
    ellipse(c, 6, 7, 2.5, 2.2, "y"); c.px(6, 8, "Y")                                     # bright core
    c.px(5, 6, "k"); c.px(7, 6, "k")                                                     # eyes
    c.px(1, 6 - s, "r"); c.px(0, 5 - s, "y"); c.px(11, 6 + s, "r"); c.px(12, 5 + s, "y")   # arms flung out
    c.px(10, 1 + s, "y")


CINDER_IMP_PAL = {"o": "#2a0e06", "r": "#e8502a", "R": "#a83018", "y": "#ffd060", "Y": "#fff4c0", "k": "#1a0a06"}


def chain_warden(c, step):
    """The Chain Warden (Ashkarrow, the game's own): the keeper of the city's gate, a hulking gaoler in a charred hood
    and scorched leather, wrapped in red-hot chains he throws at anyone who tries to leave; ember eyes in the dark of
    his hood, a coil of chain and a great hook in his hand."""
    person(c, step, cx=20, skin="a", skin_d="k", hair="k", hair_d="k", hair_style="none", garment="tunic",
           robe="g", robe_d="a", legs="a", boots="k", belt="K", arm_forward=True, eye="e", mouth="k")
    ellipse(c, 20, 9, 7, 7.5, "K"); ellipse(c, 21, 11, 4.5, 4.5, "k")                    # charred hood
    poly(c, [(13, 13), (27, 13), (29, 20), (11, 20)], "K")
    c.px(19, 11, "e"); c.px(23, 11, "e"); c.px(19, 10, "E")                              # ember eyes
    for t in range(16):                                                                  # red-hot chains crossing him
        x, y = 13 + t, 18 + t * 0.9
        c.px(round(x), round(y), "r" if t % 2 else "R")
        x2 = 27 - t
        c.px(round(x2), round(y), "R" if t % 2 else "r")
    c.row(28, 14, 26, "r")
    for t in range(18):                                                                  # the chain hanging from his hand
        x = 35 + round(2 * math.sin(t / 3 + step))
        c.px(x, 24 + t, "r" if t % 2 else "R"); c.px(x + 1, 24 + t, "R" if t % 2 else "r")
    poly(c, [(34, 42), (38, 42), (39, 46), (36, 49), (33, 47), (35, 46), (36, 44)], "i")   # the great hook
    c.px(36, 49, "e")
    for x, y in ((8, 40), (31, 34), (12, 30)):
        c.px(x, y, "E")                                                                  # sparks


WARDEN_PAL = {"o": "#120c0a", "k": "#1a1412", "K": "#2a2220", "g": "#4a4240", "a": "#363030", "r": "#f07a2a",
              "R": "#a83a1a", "e": "#ff8a3a", "E": "#ffd060", "i": "#8a8a90", "s": "#363030", "S": "#1a1412",
              "m": "#1a1412", "l": "#363030", "b": "#1a1412"}


def ash_colossus(c, step):
    """The Ash Colossus (Ashkarrow, the game's own): a giant heaped up out of the hot ash of the city, lumpy and
    broad-shouldered, its small head sunk between its shoulders, huge arms hanging to the ground; glowing cracks run
    all over it, embers drift up off it and smoke rises from its back."""
    for x, d in ((16, -step), (34, step)):                                               # legs like heaps of ash
        ellipse(c, x + 5 + d, 46, 7, 8, "a"); ellipse(c, x + 4 + d, 44, 5, 6, "g")
    ellipse(c, 30, 30, 20, 16, "a"); ellipse(c, 27, 27, 17, 13, "g")                     # the great heaped body
    ellipse(c, 22, 22, 9, 6, "l")                                                        # light on its shoulder
    for x, y, r in ((12, 18, 6), (48, 18, 6)):                                           # lumpy shoulders
        ellipse(c, x, y, r, r - 1, "g")
    for side, x in ((-1, 7), (1, 53)):                                                   # huge arms to the ground
        poly(c, [(x - 4, 18), (x + 4, 18), (x + 5 + side * 2, 44), (x - 5 + side * 2, 44)], "a" if side < 0 else "g")
        ellipse(c, x + side * 2, 47, 6, 4, "a")
        for k in range(3):
            c.px(x + side * 2 - 3 + k * 3, 51, "E")                                      # glowing knuckles
    ellipse(c, 30, 12, 6, 5, "g"); ellipse(c, 29, 11, 4, 3, "l")                         # small sunken head
    c.px(28, 12, "E"); c.px(32, 12, "E"); c.row(15, 28, 32, "e")                         # ember eyes, glowing mouth
    cracks = [((20, 24), (26, 30), (24, 38)), ((34, 22), (38, 30), (44, 34)), ((28, 34), (32, 40)), ((14, 30), (18, 36))]
    for path in cracks:                                                                  # glowing cracks
        for (ax, ay), (bx, by) in zip(path, path[1:]):
            n = max(abs(bx - ax), abs(by - ay))
            for t in range(n + 1):
                c.px(round(ax + (bx - ax) * t / n), round(ay + (by - ay) * t / n), "e")
    for x, y in ((24, 30), (40, 31), (30, 38)):
        c.px(x, y, "E")
    for x, y in ((14, 6 - step), (44, 4 + step), (36, 2 - step), (22, 3 + step)):
        c.px(x, y, "s"); c.px(x + 1, y - 1, "s")                                         # smoke rising
    for x, y in ((10, 10 + step), (50, 9 - step), (30, 4)):
        c.px(x, y, "E")                                                                  # drifting embers


COLOSSUS_PAL = {"o": "#120c0a", "g": "#6a6260", "a": "#4a4240", "l": "#867e7a", "e": "#f07a2a", "E": "#ffc060",
                "s": "#8a8280"}


def lord_of_ashkarrow(c, step):
    """The Lord of Ashkarrow (Ashkarrow, the game's own): the master of the city of ash, tall and grey as ash, crowned
    with glowing cinders, in robes of charcoal under a mantle of ember red with a high collar, holding a sceptre
    topped with a burning brazier."""
    person(c, step, cx=20, skin="g", skin_d="G", hair="k", hair_d="K", hair_style="short", garment="robe",
           robe="k", robe_d="K", robe_l="a", belt="e", boots="K", cloak=("r", "R"), arm_forward=True, eye="E")
    poly(c, [(12, 15), (16, 12), (20, 18), (24, 12), (28, 15), (27, 20), (13, 20)], "r")   # high ember-red collar
    poly(c, [(12, 15), (16, 12), (16, 15), (14, 20), (13, 20)], "R")
    for x, h in ((15, 3), (17, 5), (19, 4), (20, 6), (21, 4), (23, 5), (25, 3)):
        c.rect(x, 5 - h, x, 4, "e"); c.px(x, 5 - h, "E")                                 # crown of glowing cinders
    c.row(5, 15, 25, "k")
    for y in range(22, 50, 4):
        c.px(20, y, "e")                                                                 # embers down his robe
    c.rect(36, 12, 37, 50, "k")                                                          # sceptre
    poly(c, [(33, 9), (40, 9), (39, 13), (34, 13)], "i")                                 # its brazier
    for x, y in ((35, 8), (36, 6 - step), (37, 4 + step), (38, 7), (36, 3)):
        c.px(x, y, "E" if y < 6 else "e")                                                # burning in it


LORD_PAL = {"o": "#0e0a0a", "k": "#2a2426", "K": "#1a1416", "a": "#3e3638", "g": "#7a7270", "G": "#5a5250",
            "r": "#a8321a", "R": "#7a2210", "e": "#f07a2a", "E": "#ffd060", "i": "#6a6260", "m": "#3e3638",
            "s": "#7a7270", "S": "#5a5250", "h": "#2a2426", "H": "#1a1416", "l": "#1a1416", "b": "#1a1416"}


# --- Dinas Emrys (Historia Brittonum 40-42; "Lludd and Llefelys", tr. Lady Charlotte Guest, 1849) ----------------------

def coraniad(c, f):
    """A Coraniad ("Lludd and Llefelys": the first plague of Britain, a people who heard every word the wind touched): a
    small cloaked figure with long pointed ears turned to catch every sound, a sly face."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k"); c.row(23, x + d, x + 2 + d, "k")
    poly(c, [(5, 9), (13, 9), (15, 19), (3, 19)], "c"); poly(c, [(5, 9), (7, 9), (6, 19), (3, 19)], "C")   # grey-blue cloak
    c.px(9, 10, "y")                                                                     # brooch
    ellipse(c, 9, 5, 3.2, 3.2, "s")
    poly(c, [(6, 4), (2, 0), (3, 3), (6, 7)], "s"); c.px(4, 3, "S")                      # long pointed ears
    poly(c, [(12, 4), (16, 0), (15, 3), (12, 7)], "s"); c.px(14, 3, "S")
    c.row(1, 7, 11, "h"); c.row(2, 6, 12, "h")                                           # hair
    c.px(8, 5, "k"); c.px(11, 5, "k"); c.row(7, 9, 11, "S")                              # sly eyes, smirk
    if f % 2:
        c.px(17, 3, "w"); c.px(18, 4, "w"); c.px(17, 5, "w")                             # sound reaching its ear


CORANIAD_PAL = {"o": "#14141e", "k": "#1e1e28", "c": "#6a7a9a", "C": "#4a5a7a", "s": "#d8c0a8", "S": "#b09880",
                "h": "#4a3a2a", "y": "#c8ccd4", "w": "#e8ecf8"}


def wyrmling(c, f):
    """A wyrmling (Historia Brittonum 42: the dragons under Vortigern's tower, called "worms"): a little white dragon
    with tiny wings beating, a long tail and a pale blue eye."""
    up = f % 2
    for k in range(5):
        c.px(4 - k, 8 + (k % 2), "W")                                                    # tail
    ellipse(c, 7, 8, 3.5, 2, "w")                                                        # body
    poly(c, [(6, 7), (9, 7), (6, 1 if up else 4), (4, 2 if up else 5)], "W")             # little wing
    c.px(5, 10, "W"); c.px(9, 10, "W")                                                   # legs
    ellipse(c, 12, 6, 2.2, 1.8, "w"); c.px(14, 6, "w"); c.px(15, 7, "W")                 # head, snout
    c.px(12, 5, "b"); c.px(11, 4, "W")                                                   # eye, horn


WYRMLING_PAL = {"o": "#3a3a48", "w": "#f0f0ec", "W": "#b8c4d8", "b": "#4a8ad0"}


def coraniaid(c, step):
    """The Coraniaid ("Lludd and Llefelys": the first plague of Britain, whose hearing was so sharp that every word the
    wind touched reached them): a tall, lean figure in a grey-blue cloak with a silver brooch, long pointed ears, one
    hand cupped to an ear, listening, with a sly smile; the sound rings round its ear."""
    person(c, step, cx=20, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="short", garment="robe",
           robe="c", robe_d="C", robe_l="l", belt="y", boots="k", cloak=("C", "k"), arm_forward=False)
    poly(c, [(16, 9), (10, 3), (11, 7), (16, 12)], "s"); c.px(13, 7, "S"); c.px(12, 6, "S")   # long pointed ears
    poly(c, [(24, 9), (30, 3), (29, 7), (24, 12)], "s"); c.px(27, 7, "S"); c.px(28, 6, "S")
    c.row(13, 19, 22, "S"); c.px(22, 12, "S")                                            # sly smile
    poly(c, [(27, 18), (31, 16), (31, 11), (29, 10), (27, 13)], "c"); ellipse(c, 30, 10, 2, 2, "s")   # hand cupped to its ear
    for r in (4, 6):
        for a in range(-3, 4):
            ang = -0.6 + a * 0.25
            c.px(31 + round(r * math.cos(ang)), 6 + round(r * math.sin(ang)), "w")       # sound reaching its ear
    c.px(20, 19, "y"); c.px(19, 19, "y")                                                 # silver brooch


CORANIAID_PAL = {"o": "#14141e", "k": "#1e1e28", "c": "#6a7a9a", "C": "#4a5a7a", "l": "#8a9ab8", "s": "#d8c0a8",
                 "S": "#b09880", "h": "#4a3a2a", "H": "#2a2018", "y": "#c8ccd4", "w": "#e8ecf8", "m": "#8a5a4a",
                 "b": "#1e1e28"}


def feast_magician(c, step):
    """The Magician of the Feast ("Lludd and Llefelys": the third plague of Britain, a mighty man of magic who played
    such sweet music that the whole court fell asleep, then carried off all the food and drink): a tall man in a deep
    purple robe and a dark cloak, a harp in his arms, a great hamper of stolen food on his back with a ham, a loaf and
    a flagon poking out, and sleepy sparkles drifting from the harp."""
    poly(c, [(4, 16), (14, 14), (15, 38), (5, 40)], "b"); poly(c, [(4, 16), (7, 15), (8, 39), (5, 40)], "B")   # the hamper
    for y in range(18, 38, 4):
        c.row(y, 5, 14, "B")
    ellipse(c, 7, 13, 3, 2.4, "p"); c.px(6, 12, "P")                                     # a ham
    ellipse(c, 12, 12, 2.4, 1.8, "y")                                                    # a loaf
    c.rect(9, 9, 10, 13, "i"); c.px(9, 8, "i")                                           # a flagon
    person(c, step, cx=22, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="shoulder", beard="h",
           garment="robe", robe="m", robe_d="M", robe_l="n", belt="y", boots="k", cloak=("k", "K"), arm_forward=True)
    poly(c, [(28, 16), (33, 16), (36, 34), (32, 34)], "y"); poly(c, [(29, 18), (32, 18), (34, 32), (32, 32)], ".")   # harp
    poly(c, [(28, 16), (30, 16), (32, 34), (30, 34)], "Y")
    for y in range(19, 32, 2):
        c.row(y, 30 + (y - 18) // 8, 33 + (y - 18) // 6, "w")                            # its strings
    for x, y in ((38, 12 + step), (40, 18 - step), (37, 6), (41, 26 + step)):
        c.px(x, y, "z"); c.px(x + 1, y - 1, "Z")                                         # sleepy sparkles


MAGICIAN_PAL = {"o": "#120e0a", "k": "#1e1814", "K": "#2a2220", "m": "#4a2a6a", "M": "#341c4c", "n": "#6a4a8a",
                "s": "#d8b090", "S": "#b08868", "h": "#3a2a1a", "H": "#24180e", "b": "#8a6a3a", "B": "#5a4424",
                "p": "#c8706a", "P": "#a8504a", "y": "#e8c040", "Y": "#b08a20", "i": "#9aa0a8", "w": "#f0ecd8",
                "z": "#c8b0f0", "Z": "#8a70c0", "l": "#1e1814"}


def white_dragon(c, step):
    """The White Dragon (Historia Brittonum 40-42; "Lludd and Llefelys"): one of the two dragons buried in Dinas Emrys,
    which fought the other in the air and was driven off. A great white dragon on four clawed legs, scaled in white
    shading to ice-blue, with great bat-like wings raised, a long curving neck with spines down it, a horned head with
    a glowing blue eye and frost on its breath, and a long tail ending in a point."""
    def bez(p0, p1, p2, p3, t):
        u = 1 - t
        return (u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1])

    def wing(sh, wr, tips, bone, skin):
        """A bat-like wing: an arm from shoulder to wrist, fingers fanning to the tips, skin stretched between them."""
        pts = [sh, wr] + tips
        for a, b in zip(tips, tips[1:]):
            poly(c, [wr, a, ((a[0] + b[0]) / 2 + 1, (a[1] + b[1]) / 2 + 2), b], skin)  # scalloped skin
        poly(c, [sh, wr, tips[-1]], skin)
        for t in range(10):
            ellipse(c, sh[0] + (wr[0] - sh[0]) * t / 9, sh[1] + (wr[1] - sh[1]) * t / 9, 1.2, 1.2, bone)
        for tip in tips:
            n = int(max(abs(tip[0] - wr[0]), abs(tip[1] - wr[1])))
            for t in range(n + 1):
                c.px(round(wr[0] + (tip[0] - wr[0]) * t / n), round(wr[1] + (tip[1] - wr[1]) * t / n), bone)
        c.px(wr[0], wr[1] - 1, bone); c.px(wr[0] + 1, wr[1] - 2, "k")                    # the wing-claw

    f = step * 2
    wing((40, 26), (38, 7 - f), [(22, 2 - f), (18, 12 - f), (22, 21), (30, 26)], "W", "M")   # far wing
    for x, d in ((22, step), (44, -step)):                                               # far legs
        c.rect(x + d, 38, x + 3 + d, 48, "W"); c.row(49, x + d, x + 4 + d, "k")
    tail = [bez((20, 34), (8, 32), (10, 46), (0, 42), k / 29) for k in range(30)]       # the long tail
    for k, (x, y) in enumerate(tail):
        r = 4 - 3.2 * k / 29
        ellipse(c, x, y, r, r, "w"); c.px(round(x), round(y + r - 1), "W")
    poly(c, [(0, 40), (-2, 42), (0, 45), (3, 42)], "W")                                  # its pointed tip
    ellipse(c, 30, 34, 13, 7, "w"); ellipse(c, 30, 38, 11, 3, "W")                       # body, belly in shadow
    for x in range(20, 42, 3):
        c.px(x, 39, "c"); c.px(x + 1, 40, "c")                                           # belly scales
    neck = [bez((40, 32), (50, 28), (44, 16), (54, 12), k / 19) for k in range(20)]      # the long curving neck
    for k, (x, y) in enumerate(neck):
        ellipse(c, x, y, 4 - k * 0.06, 4 - k * 0.06, "w")
    for k, (x, y) in enumerate(neck[::3]):
        c.px(round(x + 3), round(y + 1), "c")                                            # throat plates
    for k, (x, y) in enumerate(tail[:18:3] + [(20 + i * 4, 27) for i in range(6)] + neck[::3]):
        c.px(round(x) - 1, round(y) - 4, "W"); c.px(round(x), round(y) - 5, "W")         # spines down its back
    c.rect(16 - step, 36, 22 - step, 46, "w"); ellipse(c, 19 - step, 37, 5, 5, "w")      # near hind leg
    c.row(47, 15 - step, 23 - step, "W"); c.px(15 - step, 48, "k"); c.px(19 - step, 48, "k"); c.px(23 - step, 48, "k")
    c.rect(38 + step, 38, 42 + step, 46, "w"); c.row(47, 37 + step, 44 + step, "W")      # near foreleg
    c.px(38 + step, 48, "k"); c.px(41 + step, 48, "k"); c.px(44 + step, 48, "k")
    ellipse(c, 56, 12, 5, 4, "w")                                                        # head
    poly(c, [(58, 9), (69, 12), (69, 15), (58, 17)], "w")                                # long snout
    c.row(15, 60, 69, "k"); c.row(16, 60, 68, "W")                                       # jaw
    for x in range(61, 69, 2):
        c.px(x, 15, "i")                                                                 # teeth
    c.px(68, 12, "k"); c.px(57, 11, "b"); c.px(58, 11, "B")                              # nostril, glowing blue eye
    c.row(10, 55, 59, "W")                                                               # brow ridge
    for k in range(8):
        c.px(53 - k, 9 - k // 2, "W")                                                    # horns sweeping back
        c.px(53 - k, 11 - k // 3, "W")
    wing((38, 26), (40, 5 + f), [(26, 0 + f), (22, 10 + f), (26, 20), (34, 26)], "W", "m")   # near wing
    for x, y in ((70, 14), (71, 16), (71, 13)):
        c.px(x, y, "i")                                                                  # frost on its breath
    rim(c, "wWmM", "l")


WHITE_DRAGON_PAL = {"o": "#2a2a38", "w": "#eef2f4", "W": "#b8c8dc", "c": "#d8e4ee", "m": "#d0dcea", "M": "#a8b8cc",
                    "b": "#4a9ae8", "B": "#c8e8ff", "i": "#c8e8ff", "k": "#3a4458", "l": "#ffffff"}


# --- Atlantis (Plato, Timaeus 24e-25d; Critias 113b-121c) ----------------------------------------------------------



def atlantean_hoplite(c, f):
    """An Atlantean hoplite (Critias 119a: the heavy-armed soldiers): a soldier in a bronze helmet with a round shield
    and spear."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "k")
    c.rect(6, 8, 13, 17, "t"); c.rect(7, 2, 12, 7, "s")
    c.rect(6, 0, 13, 3, "b"); c.rect(8, 0, 11, 0, "r")
    ellipse(c, 4, 12, 3.5, 4.5, "b"); c.px(4, 12, "B")
    c.rect(16, 0, 16, 20, "w"); c.px(16, 0, "b")


HOPLITE_PAL = {"o": "#120e0a", "k": "#2a1e14", "t": "#c8b890", "s": "#c8946a", "b": "#c8963a", "B": "#8a5a1a",
               "r": "#a83a2a", "w": "#7a5a3a"}


def atlantean_slinger(c, f):
    """An Atlantean slinger (Critias 119b): a light-armed soldier in a short tunic, whirling his sling."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "k")
    c.rect(6, 8, 13, 16, "t"); c.rect(7, 2, 12, 7, "s"); c.rect(7, 1, 12, 2, "h")
    a = f * 1.2
    c.px(14, 5, "s"); c.px(15 + round(2 * math.cos(a)), 3 + round(2 * math.sin(a)), "g")


SLINGER_PAL = {"o": "#120e0a", "k": "#2a1e14", "t": "#3a6a9a", "s": "#c8946a", "h": "#2a1a10", "g": "#8a8a8a"}


def poseidons_bull(c, step):
    """Poseidon's Bull (Critias 119d-e: the bulls that ranged free in Poseidon's temple): a great white bull with
    gilded horns, head lowered to charge."""
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 9 + d, 34, 16 + k * 9 + d, 45, "W"); c.rect(12 + k * 9 + d, 44, 16 + k * 9 + d, 45, "k")
    ellipse(c, 26, 28, 18, 9, "w")
    ellipse(c, 36, 22, 10, 9, "w")
    c.row(36, 12, 42, "W"); c.row(35, 14, 40, "W")
    ellipse(c, 48, 30, 6, 7, "w"); c.rect(46, 34, 52, 37, "p"); c.px(48, 36, "k"); c.px(51, 36, "k")
    poly(c, [(44, 25), (40, 18), (38, 14), (42, 17), (46, 24)], "y")
    poly(c, [(52, 25), (56, 18), (58, 14), (56, 19), (53, 26)], "y")
    c.px(46, 28, "k"); c.px(51, 28, "k")
    for k in range(8):
        c.px(8 - k // 2, 26 + k, "W")
    c.rect(4, 33, 5, 35, "k")


POSEIDON_BULL_PAL = {"o": "#1a1a20", "w": "#f0ece4", "W": "#c8c4bc", "p": "#d8a8a0", "y": "#e8c040", "k": "#1a1a20"}


def gadeirus(c, step):
    """Gadeirus (Critias 114b: Atlas' twin, king of the land toward the Pillars of Heracles): a king in a sea-blue robe
    with a gold diadem and a trident-headed staff."""
    figure(c, step, "b", "s", "h")
    c.row(3, 15, 26, "y"); c.px(20, 2, "y")
    c.rect(13, 24, 29, 25, "y")
    c.rect(33, 4, 34, 48, "w")
    for x in (31, 33, 36):
        c.rect(x, 0, x, 5, "y")
    c.row(5, 31, 36, "y")


GADEIRUS_PAL = {"o": "#0e0a08", "k": "#1e1814", "b": "#2a5a8a", "s": "#c8946a", "h": "#3a2a1a", "y": "#e8c040",
                "w": "#7a5a3a"}


def atlas_king(c, step):
    """Atlas (Critias 114a, 116: the first king of Atlantis, not the Titan): a tall king in deep blue, a cloak of
    gleaming orichalcum red-gold, and a crown."""
    figure(c, step, "b", "s", "h")
    poly(c, [(12, 18), (30, 18), (34, 50), (8, 50)], "r")
    c.rect(15, 18, 27, 50, "b")
    for x in range(15, 28, 3):
        c.rect(x, 1, x + 1, 4, "y")
    c.row(4, 15, 28, "y"); c.row(16, 18, 23, "h")


ATLAS_PAL = {"o": "#0e0a08", "k": "#1e1814", "b": "#1e3a6a", "s": "#c8946a", "h": "#e8e4dc", "y": "#e8c040",
             "r": "#d86a3a"}


# --- Ginnungagap (Völuspá 3; Vafþrúðnismál 35; Gylfaginning 4-7) ---------------------------------------------------

def venom_rime(c, f):
    """Venom rime (Gylfaginning 5: the Élivágar's venom hardened like slag, and rime grew over it): a crawling heap of
    pale green-white ice with dark venom showing through."""
    s = STEP[f]
    ellipse(c, 10, 14, 8, 7, "w")
    ellipse(c, 10, 15, 5, 4, "g")
    for x, y in ((6, 9), (13, 8), (10, 6), (15, 12)):
        c.px(x, y, "W")
    c.px(8, 12, "k"); c.px(12, 12, "k")
    c.rect(3 + s, 20, 5 + s, 21, "W"); c.rect(15 - s, 20, 17 - s, 21, "W")


VENOM_RIME_PAL = {"o": "#1a2a24", "w": "#d0e8e0", "W": "#f4fcff", "g": "#4a7a5a", "k": "#102018"}


def rime_drop(c, f):
    """A rime drop (Gylfaginning 5: the drops of thawing rime that quickened with life): a falling drop of meltwater
    with a glint of life in it."""
    up = f % 2
    poly(c, [(5, 1 + up), (2, 7), (5, 10), (8, 7)], "w")
    c.px(4, 6, "W"); c.px(5, 7, "y")


RIME_DROP_PAL = {"o": "#2a3a4a", "w": "#c8e4f8", "W": "#ffffff", "y": "#ffd060"}


def audhumla(c, step):
    """Auðumbla (Gylfaginning 6: the first cow, made from the dripping rime): a vast, pale, hornless cow with frost in
    her coat and four streams of milk."""
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 9 + d, 34, 16 + k * 9 + d, 46, "W"); c.rect(12 + k * 9 + d, 45, 16 + k * 9 + d, 46, "k")
    ellipse(c, 28, 26, 20, 11, "w")
    for x, y in ((18, 22), (26, 18), (34, 24), (22, 30), (38, 30)):
        c.px(x, y, "i"); c.px(x + 1, y, "i")
    ellipse(c, 50, 22, 7, 7, "w"); c.rect(52, 25, 57, 29, "p"); c.px(51, 20, "k")
    poly(c, [(46, 16), (44, 12), (48, 15)], "W")
    c.rect(24, 36, 30, 38, "p")
    for k in range(4):
        c.px(24 + k * 2, 39 + k % 2, "m")
    for k in range(8):
        c.px(8 - k // 2, 24 + k, "W")


AUDHUMLA_PAL = {"o": "#2a2a34", "w": "#ece8e0", "W": "#c8ccd4", "i": "#c8e4f8", "p": "#d8a8a8", "k": "#2a2a34",
                "m": "#ffffff"}


def bergelmir(c, step):
    """Bergelmir (Vafþrúðnismál 35; Gylfaginning 7: the frost giant who lived through the flood of Ymir's blood on his
    lúðr): a frost giant with a rime-white beard, grey-blue skin, his furs dark with blood at the hem, an oar in his
    hand."""
    figure(c, step, "f", "s", "w", legs="F")
    poly(c, [(16, 15), (27, 15), (24, 30), (19, 30)], "w"); c.row(48, 11, 31, "r"); c.row(49, 11, 31, "r")
    c.rect(33, 4, 34, 44, "b"); c.rect(32, 38, 35, 48, "b")


BERGELMIR_PAL = {"o": "#0e1218", "k": "#1e2430", "f": "#5a6a7a", "F": "#3a4654", "s": "#8aa0b8", "w": "#eef4fa",
                 "r": "#8a1a1a", "b": "#6a4a2a"}


def void_herald(form):
    """The Herald of the Void (Mythriven's own, in the Eddas' Ginnungagap): a tall, faceless shape of darkness standing
    between rime and fire, one or the other burning along its edges."""
    def draw(c, step):
        edge, glow = ("i", "w") if form == "rime" else ("r", "y")
        for k, d in enumerate((-step, step)):
            c.rect(16 + k * 6 + d, 46, 18 + k * 6 + d, 52, "k")
        poly(c, [(20, 2), (26, 2), (36, 48), (10, 48)], "k")
        poly(c, [(21, 6), (25, 6), (32, 46), (14, 46)], "K")
        for y in range(4, 48, 4):
            w = 3 + y // 4
            c.px(23 - w, y, edge); c.px(23 + w, y, edge)
        c.px(21, 10, glow); c.px(25, 10, glow)
        for k in range(5):
            c.px(8 + k * 7, 50 - (k % 2) * 2, edge)
    return draw


VOID_HERALD_PAL = {"o": "#05050a", "k": "#0e0e18", "K": "#1e1a30", "i": "#c8e4f8", "w": "#ffffff", "r": "#e8602a",
                   "y": "#ffd060"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_abyss.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("ash_fiend", ash_fiend, ASH_FIEND_PAL, doc(ash_fiend.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("cinder_imp", cinder_imp, CINDER_IMP_PAL, doc(cinder_imp.__doc__), (13, 12), (6, 11), walk, folder="enemies")
    kit.build_boss("chain_warden", chain_warden, WARDEN_PAL, doc(chain_warden.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("ash_colossus", ash_colossus, COLOSSUS_PAL, doc(ash_colossus.__doc__), (60, 56), (30, 54), [0, 1, 0, -1, 0])
    kit.build_boss("lord_of_ashkarrow", lord_of_ashkarrow, LORD_PAL, doc(lord_of_ashkarrow.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("coraniad", coraniad, CORANIAD_PAL, doc(coraniad.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("wyrmling", wyrmling, WYRMLING_PAL, doc(wyrmling.__doc__), (16, 12), (8, 11), walk, folder="enemies")
    kit.build_boss("coraniaid", coraniaid, CORANIAID_PAL, doc(coraniaid.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("feast_magician", feast_magician, MAGICIAN_PAL, doc(feast_magician.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("white_dragon", white_dragon, WHITE_DRAGON_PAL, doc(white_dragon.__doc__), (72, 56), (34, 54), [0, 1, 0, -1, 0])
    kit.build_boss("atlantean_hoplite", atlantean_hoplite, HOPLITE_PAL, doc(atlantean_hoplite.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("atlantean_slinger", atlantean_slinger, SLINGER_PAL, doc(atlantean_slinger.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("poseidons_bull", poseidons_bull, POSEIDON_BULL_PAL, doc(poseidons_bull.__doc__), (58, 48), (28, 46), [0, 1, 0, -1, 0])
    kit.build_boss("gadeirus", gadeirus, GADEIRUS_PAL, doc(gadeirus.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("atlas_king", atlas_king, ATLAS_PAL, doc(atlas_king.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("venom_rime", venom_rime, VENOM_RIME_PAL, doc(venom_rime.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("rime_drop", rime_drop, RIME_DROP_PAL, doc(rime_drop.__doc__), (11, 12), (5, 11), walk, folder="enemies")
    kit.build_boss("audhumla", audhumla, AUDHUMLA_PAL, doc(audhumla.__doc__), (60, 48), (30, 46), [0, 1, 0, -1, 0])
    kit.build_boss("bergelmir", bergelmir, BERGELMIR_PAL, doc(bergelmir.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("void_herald", void_herald("rime"), VOID_HERALD_PAL, doc(void_herald.__doc__), (46, 56), (23, 54), [0, 1, 0, -1, 0])
    for form in ("rime", "fire"):
        kit.build_boss("void_herald_" + form, void_herald(form), VOID_HERALD_PAL, doc(void_herald.__doc__ + " Here, as %s." % form),
                       (46, 56), (23, 54), [0, 1, 0, -1, 0])
    print("wrote the Abyss's art")
