# The Slavic Wilds' art (Pack 3, docs/PACK_3_PLAN.md; docs/ART_RULES.md): enemies (leshy, rusalka, grey wolf,
# firebird-kin), the bosses (Zmey Gorynych; Baba Yaga in her mortar, and her hut on chicken legs; Koschei the Deathless
# and his egg) and the gods Perun and Mokosh. From Afanasyev's Russian Fairy Tales, the byliny and the Russian Primary
# Chronicle; Ivan Bilibin's illustrations (1899-1902) are a fair guide to the old look. Run: python3 build_slavic.py
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def leshy(c, f):
    """A leshy, the forest master (Afanasyev): a shaggy old man of the woods with a bark-grey face, a beard of moss
    and leaves, who leads travellers astray."""
    s = STEP[f]
    for x, d in ((8, -s), (13, s)):
        c.rect(x + d, 22, x + 2 + d, 28, "b")
    poly(c, [(6, 10), (17, 10), (19, 23), (4, 23)], "g")
    c.rect(8, 3, 15, 10, "f"); c.px(10, 6, "y"); c.px(13, 6, "y")
    poly(c, [(7, 8), (16, 8), (14, 17), (9, 17)], "m")                                  # beard of moss
    for x, y in ((6, 2), (5, 0), (16, 2), (17, 0), (11, 1)):
        c.px(x, y, "b")                                                                  # twigs in his hair
    c.rect(18, 12, 19, 18, "f")
    for k in range(14):
        c.px(20, 24 - k, "b")                                                            # a crooked staff


LESHY_PAL = {"o": "#10140a", "b": "#5a4028", "g": "#4a5a32", "f": "#8a8a7a", "y": "#e0e060", "m": "#6a8a3a"}


def rusalka(c, f):
    """A rusalka (Slavic folklore): a pale water-maiden with long green hair, wet and dripping, by rivers and pools."""
    sway = [0, 1, 0, -1, 0][f]
    poly(c, [(7, 9), (13, 9), (15 + sway, 24), (5 + sway, 24)], "w")
    c.rect(7, 2, 13, 8, "s"); c.px(11, 5, "k")
    c.rect(5, 1, 7, 18, "h"); c.rect(13, 1, 14, 14, "h"); c.rect(7, 0, 13, 2, "h")    # long green hair
    for y in range(12, 24, 3):
        c.px(9 + (y % 2), y, "d")                                                        # water dripping
    c.rect(14, 10, 15, 14, "s")


RUSALKA_PAL = {"o": "#0c1418", "k": "#06080a", "w": "#d8e8e8", "s": "#e0eaea", "h": "#4a8a6a", "d": "#7ab0d8"}


def wolf(c, f):
    """The grey wolf (Afanasyev, "Tsarevich Ivan, the Firebird and the Grey Wolf"): a big grey forest wolf."""
    s = STEP[f]
    ellipse(c, 11, 9, 8, 3.5, "g")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 12, 6 + k * 4 + d, 16, "G" if k % 2 else "g")
    poly(c, [(17, 5), (23, 7), (23, 10), (17, 10)], "g")
    c.px(18, 3, "g"); c.px(19, 4, "g"); c.px(21, 7, "y"); c.px(23, 9, "k")
    c.rect(0, 8, 3, 9, "G")
    c.row(7, 5, 15, "G")


WOLF_PAL = {"o": "#141210", "k": "#080706", "g": "#7a7266", "G": "#5a544a", "y": "#e0c040"}


def firebird(c, f):
    """Firebird-kin (Afanasyev, the Firebird): a bird whose feathers shine like fire, with a long flowing tail."""
    flap = [0, -2, -4, -2, 0][f]
    ellipse(c, 10, 8, 4, 3, "f")
    poly(c, [(9, 6), (4, 0 + flap), (12, 6)], "y")
    poly(c, [(13, 7), (17, 6), (16, 9)], "f"); c.px(15, 7, "k")
    for k in range(3):
        poly(c, [(7, 9), (0 + k, 13 + k * 2), (3 + k, 14 + k * 2)], ("r", "f", "y")[k])
    c.px(12, 4, "y")


FIRE_PAL = {"o": "#2a0c04", "k": "#100402", "f": "#f08020", "y": "#f8d850", "r": "#e03a20"}


# --- Bosses --------------------------------------------------------------------------------------------------------

def zmey(c, step):
    """Zmey Gorynych (the byliny: Dobrynya Nikitich and the Serpent): the great winged dragon of the mountains with
    three heads on long necks, breathing fire."""
    ellipse(c, 34, 40, 16, 10, "g")
    ellipse(c, 34, 44, 12, 5, "G")
    poly(c, [(26, 34), (6, 14 + step), (20, 36)], "w"); poly(c, [(42, 34), (62, 14 - step), (48, 36)], "w")   # wings
    for k, d in enumerate((-step, step, step, -step)):
        x = 22 + k * 8 + d
        c.rect(x, 48, x + 2, 56, "G"); c.row(56, x - 1, x + 3, "y")
    for k, (hx, hy) in enumerate(((20, 10), (34, 4), (48, 10))):                         # three heads on long necks
        for t in range(10):
            ellipse(c, 34 + (hx - 34) * t / 10, 34 + (hy - 34) * t / 10, 2.5, 2.5, "g")
        poly(c, [(hx - 4, hy - 3), (hx + 5, hy - 2), (hx + 6, hy + 2), (hx - 3, hy + 3)], "g")
        c.px(hx + 1, hy - 1, "y"); c.px(hx + 6, hy + 1, "f"); c.px(hx + 7, hy + 1, "f")
    c.rect(48, 44, 60, 46, "G"); c.px(61, 45, "G")                                      # tail


ZMEY_PAL = {"o": "#08100a", "g": "#3a6a3a", "G": "#244a26", "w": "#5a3a2a", "y": "#e8c040", "f": "#f08020"}


def baba_yaga(c, step):
    """Baba Yaga (Afanasyev, "Vasilisa the Beautiful"): the bony-legged old witch of the forest who flies in a mortar,
    steering with the pestle and sweeping away her tracks with a broom."""
    bob = [0, -1, 0, 1, 0][step % 5] if step >= 0 else 0
    poly(c, [(10, 30 + bob), (32, 30 + bob), (29, 48 + bob), (13, 48 + bob)], "w")      # the wooden mortar
    c.row(33 + bob, 10, 32, "W"); c.row(42 + bob, 11, 31, "W")
    c.rect(15, 14 + bob, 27, 30 + bob, "r")                                              # her shawl
    c.rect(16, 4 + bob, 25, 13 + bob, "s"); c.px(22, 7 + bob, "k")
    poly(c, [(24, 9 + bob), (29, 11 + bob), (25, 12 + bob)], "s")                        # long hooked nose
    c.rect(14, 2 + bob, 26, 5 + bob, "h"); c.rect(14, 4 + bob, 16, 14 + bob, "h")       # grey hair under a kerchief
    c.rect(13, 1 + bob, 27, 2 + bob, "r")
    for k in range(24):                                                                  # the pestle she steers with
        c.px(32 + k // 6, 34 - k + bob, "b")
    for k in range(10):
        c.px(6 + k // 3, 34 + k + bob, "b")                                              # the broom behind
    c.rect(2, 44 + bob, 8, 47 + bob, "y")


YAGA_PAL = {"o": "#120c08", "k": "#080604", "w": "#8a6a44", "W": "#5e4628", "r": "#8a2a2a", "s": "#c8b098",
            "h": "#a8a8a0", "b": "#6a4a2a", "y": "#c8a860"}


def hut(c, step):
    """Baba Yaga's hut on chicken legs (Afanasyev): a little log hut that turns round on its own two great hen's legs."""
    for k, d in enumerate((-step, step)):
        x = 12 + k * 14 + d
        c.rect(x, 30, x + 2, 44, "l")
        for t in range(3):
            c.px(x - 2 + t * 2, 45, "l"); c.px(x - 3 + t * 3, 46, "l")                    # hen's toes
    for k in range(6):
        c.rect(4, 12 + k * 3, 38, 14 + k * 3, "b" if k % 2 else "B")
        c.px(3, 12 + k * 3, "t"); c.px(39, 12 + k * 3, "t")
    poly(c, [(2, 12), (21, 1), (40, 12)], "R")                                           # roof
    c.rect(17, 18, 24, 24, "y"); c.rect(20, 18, 21, 24, "B")                             # a lit window
    c.rect(6, 29, 36, 30, "B")


HUT_PAL = {"o": "#120c08", "b": "#7a5a3a", "B": "#5a4028", "t": "#a88a5a", "R": "#4a3424", "y": "#f0d070",
           "l": "#d8a040"}


def koschei(c, step):
    """Koschei the Deathless (Afanasyev, "The Death of Koschei the Deathless"): a gaunt, skeletal old sorcerer-king in
    a crown and dark armour; his death is hidden far away in a needle, in an egg, in a duck, in a hare, in a chest."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 6 + d, 46, 18 + k * 6 + d, 54, "a")
    poly(c, [(13, 18), (29, 18), (31, 46), (11, 46)], "A")
    poly(c, [(9, 18), (13, 18), (12, 50), (6, 48)], "r")                                 # a dark red cloak
    c.rect(16, 6, 25, 16, "s"); c.rect(16, 6, 17, 16, "S")
    c.px(19, 10, "k"); c.px(23, 10, "k"); c.rect(20, 13, 23, 14, "k")                   # sunken eyes, hollow cheeks
    c.rect(18, 15, 23, 22, "h")                                                          # thin long beard
    c.row(5, 16, 25, "u"); c.px(17, 3, "u"); c.px(20, 2, "u"); c.px(24, 3, "u")         # crown
    for y in range(22, 44, 3):
        c.row(y, 14, 28, "a")                                                            # ribs of dark armour
    c.rect(29, 22, 31, 30, "s")
    for k in range(20):
        c.px(32 + k // 4, 28 - k, "i")                                                   # a sword


KOSCHEI_PAL = {"o": "#0c0a10", "k": "#060408", "a": "#3a3a46", "A": "#24242e", "r": "#5a1a20", "s": "#c8c0b0",
               "S": "#9a9282", "h": "#d8d4cc", "u": "#d8b048", "i": "#c8ccd4"}


def koschei_egg(c, step):
    """The egg that holds Koschei's death (a needle in an egg, in a duck, in a hare, in an iron chest under an oak)."""
    ellipse(c, 8, 10, 6, 8, "w")
    ellipse(c, 6, 7, 2, 3, "W")
    c.rect(7, 4, 8, 16, "i")                                                             # the needle inside


EGG_PAL = {"o": "#2a2a1a", "w": "#f4ecd0", "W": "#ffffff", "i": "#c8a040"}


# --- Perun and Mokosh (the Russian Primary Chronicle, 980) -------------------------------------------------------------

GOD_SIZE, GOD_ANCHOR = (48, 62), (22, 60)
STANCE = (18, 23)
GOD_WALK = [STANCE, (16, 25), STANCE, (20, 21), STANCE]
SEATED = {"style": "norse", "hip": 40, "lap": "b", "shin": "b", "foot": "n", "keep": range(32, 48)}

PERUN_DOC = ("Perun, god (docs/PACK_3_PLAN.md: the Slavic Wilds). The Russian Primary Chronicle (980): Vladimir set up "
             "Perun's image at Kiev, of wood with a head of silver and a moustache of gold. A god of thunder with a "
             "silver-grey head of hair, a golden moustache, an axe. Built by tools/art/build_slavic.py.")
MOKOSH_DOC = ("Mokosh, god (docs/PACK_3_PLAN.md: the Slavic Wilds). The Russian Primary Chronicle (980) names her among "
              "Vladimir's gods; little else is known, and later folk custom tied her to spinning. A woman in a "
              "embroidered red-and-white dress and headdress, holding a spindle. Built by tools/art/build_slavic.py.")
PERUN_PAL = {"o": "#14100c", "k": "#0a0806", "s": "#dcb898", "S": "#ac8868", "h": "#c8ccd4", "u": "#e0b040",
             "b": "#6a2a24", "B": "#4a1a18", "i": "#c8ccd4", "w": "#7a5a3a", "y": "#f0e070", "n": "#3a2a20"}
MOKOSH_PAL = {"o": "#14100c", "k": "#0a0806", "s": "#ecd0b8", "S": "#bc9e88", "h": "#7a4a2a", "b": "#ece6da",
              "B": "#b02a2a", "u": "#e0b040", "w": "#a8784a", "n": "#6a4a2a"}


def robe(c, main, fold):
    for y in range(20, 57):
        x0, x1 = (16, 27) if y < 44 else (15 - (y - 44) // 6, 28 + (y - 44) // 6)
        c.row(y, x0, x1, main)
        if y > 34:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, fold)
    c.rect(16, 20, 17, 43, fold)
    for x0 in STANCE:
        c.rect(x0, 57, x0 + 4, 58, "s"); c.row(58, x0, x0 + 4, "n")


def perun(c, legs):
    robe(c, "b", "B")
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S"); c.px(23, 12, "k")
    c.rect(17, 5, 26, 9, "h"); c.rect(16, 8, 17, 16, "h")                              # silver hair
    c.row(15, 19, 26, "u"); c.px(27, 16, "u"); c.px(18, 16, "u")                       # golden moustache
    c.rect(26, 21, 28, 28, "s")
    for k in range(20):
        c.px(30, 34 - k, "w")
    poly(c, [(30, 13), (37, 10), (37, 19), (30, 17)], "i"); c.px(39, 12, "y"); c.px(40, 16, "y")


def mokosh(c, legs):
    robe(c, "b", "B")
    for y in range(24, 56, 4):
        for x in range(17, 27, 3):
            c.px(x, y, "B")                                                             # red embroidery
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S"); c.px(23, 12, "k")
    c.rect(16, 3, 27, 9, "B"); c.row(4, 16, 27, "u")                                   # a tall headdress
    c.rect(16, 9, 17, 20, "h")
    c.rect(26, 21, 28, 28, "s")
    c.rect(29, 18, 30, 34, "w"); ellipse(c, 29.5, 31, 2.5, 2, "w"); c.rect(28, 20, 31, 23, "b")   # spindle and wool


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_slavic.py."
    walk = [0, 1, 2, 3, 4]
    for name, draw, pal, size, anchor in (("leshy", leshy, LESHY_PAL, (22, 30), (11, 29)),
                                          ("rusalka", rusalka, RUSALKA_PAL, (20, 26), (10, 25)),
                                          ("grey_wolf", wolf, WOLF_PAL, (24, 18), (11, 17)),
                                          ("firebird_kin", firebird, FIRE_PAL, (20, 20), (10, 19))):
        kit.build_boss(name, draw, pal, doc(draw.__doc__), size, anchor, walk, folder="enemies")
    for name, draw, pal, size, anchor in (("zmey_gorynych", zmey, ZMEY_PAL, (66, 58), (34, 56)),
                                          ("baba_yaga", baba_yaga, YAGA_PAL, (42, 50), (21, 48)),
                                          ("baba_yaga_hut", hut, HUT_PAL, (42, 48), (21, 46)),
                                          ("koschei", koschei, KOSCHEI_PAL, (42, 56), (21, 54)),
                                          ("koschei_egg", koschei_egg, EGG_PAL, (16, 20), (8, 18))):
        kit.build_boss(name, draw, pal, doc(draw.__doc__), size, anchor, [0, 1, 0, -1, 0])
    kit.build_boss("perun", perun, PERUN_PAL, PERUN_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    kit.build_boss("mokosh", mokosh, MOKOSH_PAL, MOKOSH_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    print("wrote the Slavic Wilds' art")
