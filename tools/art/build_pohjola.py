# Pohjola's art (Pack 3, docs/PACK_3_PLAN.md; docs/ART_RULES.md): enemies (Hiisi forest-spirit, Pohjola's wolf, viper
# of the snake field, frost wisp), the bosses (the Elk of Hiisi, Iku-Turso, Louhi and Louhi as the great eagle) and
# the gods Ukko and Ilmatar. Drawn from the Kalevala (Lonnrot, 1849). Run: python3 build_pohjola.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def hiisi(c, f):
    """A Hiisi forest-spirit (Kalevala 13-14): a small, gnarled, mossy goblin of the wild woods with twig-like limbs."""
    s = STEP[f]
    for x, d in ((6, -s), (10, s)):
        c.rect(x + d, 13, x + 1 + d, 17, "b")
    ellipse(c, 9, 10, 5, 4, "g")
    ellipse(c, 9, 5, 4, 3.5, "G")
    c.px(7, 4, "y"); c.px(11, 4, "y")
    c.rect(8, 7, 10, 7, "k")
    for x, y in ((5, 1), (6, 2), (12, 2), (13, 1)):
        c.px(x, y, "b")                                                                  # twig horns
    c.rect(14, 8, 15, 10, "b"); c.rect(2, 8, 3, 10, "b")                                 # twig arms
    c.px(9, 11, "m"); c.px(7, 12, "m")                                                   # moss


HIISI_PAL = {"o": "#0e140a", "k": "#060804", "g": "#4a5a32", "G": "#5e6e3e", "b": "#5a4028", "y": "#e0e060", "m": "#8aa04a"}


def wolf(c, f):
    """One of Pohjola's wolves (Kalevala 32-33): a lean grey wolf of the north, tail low, pale eyes."""
    s = STEP[f]
    ellipse(c, 11, 9, 8, 3.5, "g")
    c.rect(4, 7, 18, 8, "G")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 12, 6 + k * 4 + d, 16, "G" if k % 2 else "g")
    poly(c, [(17, 5), (23, 7), (23, 10), (17, 10)], "g")
    c.px(18, 3, "g"); c.px(19, 4, "g"); c.px(21, 7, "y"); c.px(23, 9, "k")
    c.rect(0, 8, 3, 9, "G")


WOLF_PAL = {"o": "#14161a", "k": "#08090a", "g": "#8a8e96", "G": "#62666e", "y": "#d8f0ff"}


def viper(c, f):
    """A viper of Pohjola's snake field (Kalevala 19): a small dark zig-zag-backed adder coiled to strike."""
    s = STEP[f]
    for x in range(1, 15):
        y = 7 + round(1.4 * math.sin((x + s * 2) / 2.0))
        c.rect(x, y, x, y + 1, "v")
        if x % 3 == 0:
            c.px(x, y, "k")
    poly(c, [(14, 3), (18, 4), (18, 6), (14, 6)], "v"); c.px(16, 4, "r"); c.px(19, 6, "r")


VIPER_PAL = {"o": "#0a0c0a", "k": "#141414", "v": "#5a5a48", "r": "#c83030"}


def frost_wisp(c, f):
    """A frost wisp (Kalevala 30: Pakkanen, the Frost, sent by Louhi): a drifting cold glow of ice crystals."""
    r = 4 + (f % 2)
    ellipse(c, 7, 8, r, r + 1, "b")
    ellipse(c, 7, 8, r - 2, r - 1, "w")
    for a in range(0, 360, 60):
        x, y = 7 + round(7 * math.cos(math.radians(a + f * 10))), 8 + round(7 * math.sin(math.radians(a + f * 10)))
        c.px(x, y, "w")
    c.px(6, 7, "k"); c.px(8, 7, "k")


WISP_PAL = {"o": "#1a2a3a", "k": "#2a4a6a", "b": "#8ac8f0", "w": "#f0faff"}


# --- Bosses --------------------------------------------------------------------------------------------------------

def elk(c, step):
    """The Elk of Hiisi (Kalevala 13-14): the great elk Hiisi made, that no skier could catch; Lemminkainen chased it
    across Pohjola. A huge dark elk with great palmate antlers and burning eyes."""
    ellipse(c, 30, 30, 20, 10, "b")
    c.rect(14, 22, 44, 26, "B")
    for k, d in enumerate((-step, step, step, -step)):
        x = 15 + k * 9 + d
        c.rect(x, 36, x + 2, 50, "B" if k % 2 == 0 else "b")
        c.rect(x, 50, x + 2, 51, "k")
    poly(c, [(44, 24), (52, 14), (56, 16), (50, 30)], "b")                             # neck
    poly(c, [(51, 12), (62, 16), (62, 21), (53, 20)], "b")                             # long head
    c.rect(59, 19, 62, 22, "B"); c.px(56, 15, "y")
    c.rect(52, 22, 54, 26, "B")                                                         # the bell under its throat
    for x0, stem in ((44, 53), (55, 56)):                                              # broad palmate antlers
        c.rect(stem, 6, stem + 1, 13, "a")
        c.rect(x0, 4, x0 + 8, 7, "a")
        for k in range(5):
            c.px(x0 + k * 2, 2 + (k % 2), "a")
    c.rect(8, 26, 10, 30, "B")


ELK_PAL = {"o": "#120c08", "k": "#080604", "b": "#4a3626", "B": "#2e2218", "a": "#c8b490", "y": "#f0a020"}


def turso(c, step):
    """Iku-Turso (Kalevala 42): the sea monster who rose against the ship and was lifted out by his ears. A hulking
    dark water-beast with great ears and many horns rising from a ring of broken ice."""
    ellipse(c, 30, 52, 26, 6, "w")                                                      # broken ice round him
    ellipse(c, 30, 52, 20, 4, "d")                                                      # the dark water
    poly(c, [(14, 52), (18, 26), (42, 26), (46, 52)], "b")
    ellipse(c, 30, 22, 13, 11, "b")
    poly(c, [(19, 16), (8, 8), (12, 20), (18, 24)], "B")                                # the great ears
    poly(c, [(41, 16), (52, 8), (48, 20), (42, 24)], "B")
    for k in range(5):                                                                  # many horns
        c.rect(22 + k * 4, 8 - (k % 2) * 2, 23 + k * 4, 12, "h")
    c.rect(24, 24, 36, 28, "k"); c.row(25, 25, 35, "w")                                 # maw, teeth
    c.px(25, 19, "y"); c.px(35, 19, "y")
    for x, d in ((12, step), (48, -step)):                                              # arms clawing up from the water
        c.rect(x, 34 + d, x + 3, 50, "B")
        for k in range(3):
            c.px(x + k, 33 + d, "h")


TURSO_PAL = {"o": "#06100e", "k": "#020404", "b": "#2a4a44", "B": "#1a3430", "h": "#c8c0a8", "y": "#e0f060",
             "w": "#e0eef4", "d": "#0e2a34"}


def louhi(c, step):
    """Louhi, mistress of Pohjola (Kalevala 7-47): the gap-toothed old woman of the North, a sorceress queen in dark
    robes with the keys of her house at her belt, who hid the sun and the moon in a mountain."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 6 + d, 50, 19 + k * 6 + d, 54, "k")
    poly(c, [(14, 22), (30, 22), (34, 52), (10, 52)], "r")                              # robe
    poly(c, [(14, 22), (19, 22), (15, 52), (10, 52)], "R")
    c.row(36, 12, 32, "u")
    for k in range(4):
        c.rect(20 + k * 2, 37, 20 + k * 2, 40, "u")                                     # keys
    c.rect(16, 8, 27, 20, "s"); c.rect(16, 8, 17, 20, "S")
    c.rect(14, 4, 29, 9, "h"); c.rect(13, 9, 15, 26, "h")                               # grey hair
    c.px(24, 12, "k"); c.px(20, 12, "k")
    c.row(17, 20, 25, "k"); c.px(21, 17, "w"); c.px(24, 17, "w")                       # gap-toothed grin
    c.rect(30, 24, 32, 30, "s")
    for k in range(18):
        c.px(33, 34 - k, "b")                                                           # staff
    c.rect(32, 14, 34, 16, "y")


LOUHI_PAL = {"o": "#100a10", "k": "#08060a", "r": "#3a2a4a", "R": "#24182e", "u": "#b8a060", "s": "#d8b898",
             "S": "#a88868", "h": "#c8c8cc", "w": "#f0ece0", "b": "#5a4028", "y": "#a0e0ff"}


def louhi_eagle(c, step):
    """Louhi as the great eagle (Kalevala 43): she takes the shape of a huge eagle, with claws made of scythes, and
    carries a hundred men on her wings to win back the Sampo."""
    ellipse(c, 36, 30, 10, 14, "b")
    for side in (-1, 1):                                                                # vast wings
        pts = [(36, 22), (36 + side * 34, 10 + step * side), (36 + side * 30, 22), (36 + side * 34, 30), (36, 34)]
        poly(c, pts, "B" if side < 0 else "b")
        for k in range(5):
            c.rect(36 + side * (12 + k * 4), 26 + k, 36 + side * (12 + k * 4), 30 + k, "w")
    ellipse(c, 36, 14, 6, 5, "h")
    poly(c, [(36, 16), (42, 18), (38, 21)], "u"); c.px(38, 13, "k")
    for k in range(4):                                                                  # scythe claws
        c.rect(30 + k * 4, 44, 30 + k * 4, 50, "i")
        c.px(31 + k * 4, 50, "i"); c.px(32 + k * 4, 49, "i")
    poly(c, [(31, 42), (41, 42), (39, 50), (33, 50)], "B")


EAGLE_PAL = {"o": "#0c0806", "k": "#060402", "b": "#5a4430", "B": "#3a2c1e", "w": "#8a7058", "h": "#c8c0b0",
             "u": "#d8a030", "i": "#c8ccd4"}


# --- Ukko and Ilmatar (the Kalevala) ----------------------------------------------------------------------------------

GOD_SIZE, GOD_ANCHOR = (48, 62), (22, 60)
STANCE = (18, 23)
GOD_WALK = [STANCE, (16, 25), STANCE, (20, 21), STANCE]
SEATED = {"style": "norse", "hip": 40, "lap": "b", "shin": "b", "foot": "n", "keep": range(32, 48)}

UKKO_DOC = ("Ukko, god (docs/PACK_3_PLAN.md: Pohjola). The Kalevala (the chief god of the sky, called on throughout) and "
            "Mikael Agricola's list of Finnish gods (1551). An old sky-god with a long white beard, in a cloud-grey "
            "mantle, his thunder-axe in hand. Built by tools/art/build_pohjola.py.")
ILMATAR_DOC = ("Ilmatar, god (docs/PACK_3_PLAN.md: Pohjola). Kalevala 1: the maiden of the air who sank to the sea; a "
               "teal laid its eggs on her knee, and the broken eggs became the earth, the sky, the sun and moon. A young "
               "woman in pale sky-blue, an egg of light in her hands. Built by tools/art/build_pohjola.py.")
UKKO_PAL = {"o": "#14100c", "k": "#0a0806", "s": "#e0b898", "S": "#b08868", "h": "#eceae4", "b": "#6a7480",
            "B": "#4a525c", "i": "#c8ccd4", "w": "#7a5a3a", "y": "#f0e070", "n": "#3a2a20"}
ILMATAR_PAL = {"o": "#14100c", "k": "#0a0806", "s": "#ecd0b8", "S": "#bc9e88", "h": "#e8d090", "b": "#a8c8e8",
               "B": "#7a9ec0", "w": "#ffffff", "y": "#fff0a0", "n": "#6a5a4a"}


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


def face(c):
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S"); c.px(23, 12, "k"); c.row(16, 21, 23, "S")


def ukko(c, legs):
    robe(c, "b", "B")
    face(c)
    c.rect(17, 5, 26, 9, "h"); c.rect(16, 8, 17, 18, "h")                              # white hair
    poly(c, [(17, 15), (26, 15), (24, 28), (19, 28)], "h")                              # long white beard
    c.rect(26, 21, 28, 28, "s")
    for k in range(20):
        c.px(30, 34 - k, "w")                                                           # the axe-haft
    poly(c, [(30, 13), (37, 10), (37, 19), (30, 17)], "i"); c.px(37, 14, "y")           # the thunder-axe, sparking
    c.px(39, 12, "y"); c.px(40, 16, "y")


def ilmatar(c, legs):
    c.rect(14, 8, 18, 30, "h"); c.rect(14, 8, 15, 30, "S")                             # long fair hair
    robe(c, "b", "B")
    face(c)
    c.rect(17, 6, 25, 8, "h")
    ellipse(c, 24, 30, 3, 3.5, "w"); c.px(23, 29, "y")                                  # the egg of light she holds
    c.rect(21, 27, 22, 32, "s"); c.rect(26, 27, 27, 32, "s")
    for y in range(36, 56, 5):
        c.px(20 + (y % 3), y, "w")                                                      # the air's shimmer on her robe


if __name__ == "__main__":
    def doc(text):
        return text + " Built by tools/art/build_pohjola.py."
    walk = [0, 1, 2, 3, 4]
    for name, draw, pal, size, anchor in (("hiisi", hiisi, HIISI_PAL, (18, 18), (9, 17)),
                                          ("pohjola_wolf", wolf, WOLF_PAL, (24, 18), (11, 17)),
                                          ("snake_field_viper", viper, VIPER_PAL, (20, 12), (9, 10)),
                                          ("frost_wisp", frost_wisp, WISP_PAL, (16, 18), (7, 17))):
        kit.build_boss(name, draw, pal, doc(draw.__doc__.strip()), size, anchor, walk, folder="enemies")
    for name, draw, pal, size, anchor in (("elk_of_hiisi", elk, ELK_PAL, (64, 54), (30, 52)),
                                          ("iku_turso", turso, TURSO_PAL, (60, 60), (30, 58)),
                                          ("louhi", louhi, LOUHI_PAL, (44, 56), (22, 54)),
                                          ("louhi_eagle", louhi_eagle, EAGLE_PAL, (72, 54), (36, 52))):
        kit.build_boss(name, draw, pal, doc(" ".join(draw.__doc__.split())), size, anchor, [0, 1, 0, -1, 0])
    kit.build_boss("ukko", ukko, UKKO_PAL, UKKO_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    kit.build_boss("ilmatar", ilmatar, ILMATAR_PAL, ILMATAR_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    print("wrote Pohjola's art")
