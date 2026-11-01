# Otherworlds' art (Pack 12, docs/PACK_12_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Coimín's lay of Oisín; Lady Wilde; Yeats; O'Flaherty and the 1675 O-Brazile pamphlet; the Flying Dutchman
# legend of 1795-1821; Andersen's "The Shadow", 1847; Hunt and Bottrell's Cornish collections), never later versions.
# Run: python3 build_otherworlds.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def figure(c, step, robe, skin, hair, legs="k", x0=14, top=18, bottom=50):
    """A standing figure in a long robe (shared by the boss figures)."""
    for k, d in enumerate((-step, step)):
        c.rect(x0 + 2 + k * 6 + d, bottom - 2, x0 + 4 + k * 6 + d, bottom + 4, legs)
    poly(c, [(x0, top), (x0 + 14, top), (x0 + 17, bottom), (x0 - 3, bottom)], robe)
    c.rect(x0 + 2, top - 12, x0 + 11, top - 2, skin)
    c.rect(x0, top - 15, x0 + 13, top - 11, hair)
    c.px(x0 + 4, top - 8, "o"); c.px(x0 + 9, top - 8, "o")


# --- Tír na nÓg (Coimín's lay; Lady Wilde, 1887; Yeats, 1888) -------------------------------------------------------

def sidhe_warrior(c, f):
    """A sídhe warrior (the fairy host of the hills): a tall, fair fighter in green and gold with a slim spear."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "k")
    c.rect(6, 8, 13, 17, "g"); c.row(12, 6, 13, "y")
    c.rect(7, 2, 12, 7, "s"); c.rect(6, 0, 13, 2, "h"); c.rect(5, 2, 6, 9, "h")
    c.rect(16, 0, 16, 20, "w"); c.px(16, 0, "y"); c.px(16, 1, "y")


SIDHE_WARRIOR_PAL = {"o": "#10180a", "k": "#1e2a14", "g": "#3a8a4a", "y": "#e8c040", "s": "#f0dcc8", "h": "#f0d070",
                     "w": "#c8c0a8"}


def sidhe_piper(c, f):
    """A sídhe piper (the fairy music): a slight fairy in pale blue, playing a pipe, notes rising."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "k")
    poly(c, [(7, 8), (12, 8), (14, 18), (5, 18)], "b")
    c.rect(7, 2, 12, 7, "s"); c.rect(6, 0, 13, 2, "h")
    c.rect(12, 6, 16, 6, "w"); c.px(16 + f % 2, 3 - f % 2, "y")


SIDHE_PIPER_PAL = {"o": "#10141e", "k": "#1e2430", "b": "#a8c0e0", "s": "#f0dcc8", "h": "#c87a3a", "w": "#c8a878",
                   "y": "#f0e080"}


def red_eared_hound(c, step):
    """The Red-Eared Hound (Coimín's lay: a white hound with red ears chasing a hornless fawn over the sea): a lean
    white hound, running, its ears blood-red."""
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(10 + k * 7 + d, 22, 11 + k * 7 + d, 32, "W")
    ellipse(c, 22, 18, 14, 6, "w")
    ellipse(c, 38, 12, 6, 5, "w"); c.rect(42, 13, 46, 15, "w"); c.px(46, 13, "k")
    poly(c, [(35, 8), (33, 2), (38, 7)], "r"); poly(c, [(38, 7), (40, 1), (41, 7)], "r")
    c.px(39, 11, "k")
    for k in range(8):
        c.px(8 - k, 16 - k // 2, "w")


HOUND_PAL = {"o": "#2a1e1e", "w": "#f4f0ec", "W": "#d8d4cc", "r": "#c82a2a", "k": "#1a1414"}


def fomor(c, step):
    """The Fomor (Coimín's lay: the Fomorian giant Oisín fought for three days and nights): a huge, misshapen giant,
    grey-green, heavy-browed, a club over his shoulder."""
    for k, d in enumerate((-step, step)):
        c.rect(18 + k * 14 + d, 42, 25 + k * 14 + d, 54, "G")
    ellipse(c, 30, 30, 17, 14, "g")
    ellipse(c, 30, 12, 9, 8, "g")
    for x in (26, 34):
        ellipse(c, x, 11, 2, 1.5, "w"); c.px(x, 11, "k")
    c.row(16, 26, 34, "k")
    c.rect(8, 22, 13, 40, "G"); c.rect(47, 22, 52, 40, "G")
    c.rect(50, 4, 54, 24, "b"); ellipse(c, 52, 4, 4, 4, "b")
    c.rect(18, 36, 42, 40, "f")


FOMOR_PAL = {"o": "#10140e", "g": "#7a8a6a", "G": "#5a6a4a", "w": "#f0ece0", "k": "#141810", "b": "#5a3a1a",
             "f": "#6a4a2a"}


def finvarra(c, step):
    """Finvarra (Lady Wilde, 1887: the king of the fairies of the West, under the hill of Knockma): a slender fairy
    king in black and silver with a silver crown, on whose cloak the gold of the hills glints."""
    figure(c, step, "k", "s", "h")
    poly(c, [(12, 18), (30, 18), (34, 50), (8, 50)], "K")
    c.rect(15, 18, 27, 50, "k")
    for x, y in ((11, 30), (31, 34), (13, 44), (29, 46)):
        c.px(x, y, "y")
    for x in range(15, 28, 4):
        c.rect(x, 1, x + 1, 4, "w")
    c.row(4, 15, 28, "w"); c.row(22, 16, 26, "w")


FINVARRA_PAL = {"o": "#0e0a10", "k": "#1e1a24", "K": "#2e2a3a", "s": "#f0e0d0", "h": "#e8e0c8", "w": "#d8dce8",
                "y": "#e8c040"}


# --- Hy-Brasil (O'Flaherty, 1684; the O-Brazile pamphlet, 1675; the Flying Dutchman, 1795-1821) --------------------

def black_rabbit(c, f):
    """A black rabbit (the O-Brazile pamphlet, 1675: the island swarming with great black rabbits)."""
    up = f % 2
    ellipse(c, 6, 8 - up, 4, 3, "k"); ellipse(c, 10, 6 - up, 2.5, 2, "k")
    c.rect(9, 1 - up, 9, 4 - up, "k"); c.rect(11, 1 - up, 11, 4 - up, "K")
    c.px(11, 6 - up, "w"); c.px(2, 7 - up, "w")


BLACK_RABBIT_PAL = {"o": "#0a0a0e", "k": "#24222a", "K": "#3a3844", "w": "#e8e4dc"}


def dutchman_sailor(c, f):
    """A sailor of the Flying Dutchman (Blackwood's, 1821): a grey-green, sea-worn sailor in an old Dutch coat and
    wide breeches, holding a bundle of letters."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    c.rect(5, 14, 14, 18, "b"); c.rect(6, 8, 13, 14, "c")
    c.rect(7, 2, 12, 7, "s"); c.rect(5, 1, 14, 2, "k"); c.rect(7, 0, 12, 0, "k")
    c.rect(14, 10, 16, 12, "w"); c.px(15, 11, "r")


SAILOR_PAL = {"o": "#0e1210", "k": "#1e2420", "b": "#4a5a5a", "c": "#5a6a4a", "s": "#a8b8a0", "w": "#e8e0c8",
              "r": "#a82a2a"}


def great_black_rabbit(c, step):
    """The Great Black Rabbit (the O-Brazile pamphlet, 1675): the biggest of the island's black rabbits, crouched to
    spring, ears flat back."""
    ellipse(c, 24, 26, 16, 11, "k")
    ellipse(c, 38, 18, 8, 7, "k")
    poly(c, [(34, 12), (24, 2 + step), (28, 2 + step), (37, 11)], "K")
    poly(c, [(38, 11), (32, 0 - step), (36, 0 - step), (41, 11)], "k")
    c.px(41, 17, "r"); c.px(42, 17, "r"); c.rect(45, 20, 46, 21, "p")
    ellipse(c, 8, 26, 4, 4, "w")
    c.rect(32, 32, 38, 36, "K"); c.rect(14, 32, 24, 36, "K")


GREAT_RABBIT_PAL = {"o": "#0a0a0e", "k": "#24222a", "K": "#3a3844", "w": "#e8e4dc", "r": "#c83a2a", "p": "#a87a7a"}


def obrazile_necromancer(c, step):
    """The Necromancer of O'Brazile (the 1675 pamphlet: the enchanter whose spell hid the island): an old man in a
    black gown sewn with silver signs, a staff topped with a sea-green stone."""
    figure(c, step, "k", "s", "w")
    poly(c, [(16, 15), (27, 15), (24, 32), (19, 32)], "w")
    for x, y in ((14, 36), (26, 40), (18, 46), (28, 30)):
        c.px(x, y, "e"); c.px(x + 1, y + 1, "e")
    c.rect(33, 6, 34, 50, "b"); ellipse(c, 33, 5, 3, 3, "g")


NECROMANCER_PAL = {"o": "#0e0a10", "k": "#1e1a24", "s": "#d8c0a8", "w": "#e8e4dc", "e": "#c8ccd8", "b": "#5a3a1a",
                   "g": "#4ac0a0"}


def flying_dutchman(pal_phantom):
    """The Flying Dutchman (Barrington, 1795; Blackwood's, 1821): Vanderdecken's ship, a high-sterned Dutch ship with
    torn sails, beating against the wind."""
    def draw(c, step):
        poly(c, [(4, 34), (58, 34), (52, 46), (12, 46)], "b")
        c.rect(44, 26, 56, 34, "b"); c.row(30, 46, 54, "y")
        c.row(38, 8, 54, "B")
        for x in (14, 30, 46):
            c.rect(x, 4, x + 1, 34, "m")
        for x, top in ((10, 6), (26, 4), (42, 8)):
            poly(c, [(x, top + step), (x + 10, top + 2), (x + 9, top + 18), (x + 1, top + 16 - step)], "s")
            c.px(x + 4, top + 8, "S"); c.px(x + 6, top + 11, "S")
    return draw


DUTCHMAN_PAL = {"o": "#0a0a0e", "b": "#3a2a1a", "B": "#24180e", "y": "#c8a040", "m": "#2a1e14", "s": "#c8c0a8",
                "S": "#5a5448"}
PHANTOM_PAL = {"o": "#6a8a8a", "b": "#8aa8a0", "B": "#6a8a84", "y": "#c8e0d0", "m": "#7a9a94", "s": "#d8ece4",
               "S": "#a8c8c0"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_otherworlds.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("sidhe_warrior", sidhe_warrior, SIDHE_WARRIOR_PAL, doc(sidhe_warrior.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("sidhe_piper", sidhe_piper, SIDHE_PIPER_PAL, doc(sidhe_piper.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("red_eared_hound", red_eared_hound, HOUND_PAL, doc(red_eared_hound.__doc__), (50, 36), (24, 34), [0, 1, 0, -1, 0])
    kit.build_boss("fomor", fomor, FOMOR_PAL, doc(fomor.__doc__), (60, 58), (30, 56), [0, 1, 0, -1, 0])
    kit.build_boss("finvarra", finvarra, FINVARRA_PAL, doc(finvarra.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("black_rabbit", black_rabbit, BLACK_RABBIT_PAL, doc(black_rabbit.__doc__), (14, 12), (7, 11), walk, folder="enemies")
    kit.build_boss("dutchman_sailor", dutchman_sailor, SAILOR_PAL, doc(dutchman_sailor.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("great_black_rabbit", great_black_rabbit, GREAT_RABBIT_PAL, doc(great_black_rabbit.__doc__), (50, 40), (24, 38), [0, 1, 0, -1, 0])
    kit.build_boss("obrazile_necromancer", obrazile_necromancer, NECROMANCER_PAL, doc(obrazile_necromancer.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("flying_dutchman", flying_dutchman(False), DUTCHMAN_PAL, doc(flying_dutchman.__doc__), (62, 50), (31, 48), [0, 1, 0, -1, 0])
    kit.build_boss("flying_dutchman_phantom", flying_dutchman(True), PHANTOM_PAL, doc(flying_dutchman.__doc__ + " Here, as a phantom."), (62, 50), (31, 48), [0, 1, 0, -1, 0])
    print("wrote Otherworlds' art")
