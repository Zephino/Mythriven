# The Elemental Planes' art (Pack 4, docs/PACK_4_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the
# old texts (the Eddas, Paracelsus, Breton legend, Aristophanes, the Thousand and One Nights), never later versions.
# Muspelheim: salamander, son of Muspell, the hounds Gifr and Geri (awake and asleep), Vidofnir, Sinmara.
# Run: python3 build_realms.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


# --- Muspelheim (Gylfaginning 4-5, 51; Fjolsvinnsmal; Paracelsus) ------------------------------------------------------

def salamander(c, f):
    """A salamander, the fire spirit of Paracelsus (Liber de Nymphis, 1566): a small lizard of living flame."""
    s = STEP[f]
    for x in range(2, 17):
        y = 8 + round(0.8 * math.sin((x + s * 2) / 2.0))
        c.rect(x, y, x, y + 2, "f" if x % 3 else "F")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 3 + d, 11, 5 + k * 3 + d, 13, "F")
    poly(c, [(16, 6), (21, 7), (21, 10), (16, 11)], "f"); c.px(18, 7, "w")
    for x in range(3, 16, 3):
        c.px(x, 6 - (x % 2), "y")                                                       # flames along its back


SAL_PAL = {"o": "#2a0804", "f": "#f07a20", "F": "#c8401a", "y": "#ffe060", "w": "#ffffff"}


def son_of_muspell(c, f):
    """A son of Muspell (Gylfaginning 51: the sons of Muspell ride out at Ragnarok behind Surtr): a fire giant of
    black cinder-skin cracked with glowing seams."""
    s = STEP[f]
    for x, d in ((8, -s), (14, s)):
        c.rect(x + d, 20, x + 2 + d, 27, "k")
        c.row(28, x - 1 + d, x + 3 + d, "k")
    ellipse(c, 12, 14, 7, 7, "b")
    ellipse(c, 12, 5, 4.5, 4.5, "b")
    for x, y in ((9, 12), (12, 16), (15, 13), (11, 9), (10, 5), (14, 6)):
        c.px(x, y, "f"); c.px(x + 1, y + 1, "y")                                         # glowing cracks
    c.rect(4, 0, 6, 3, "f"); c.rect(17, 0, 19, 3, "f"); c.rect(9, 0, 15, 1, "f")       # hair of flame
    c.rect(18, 11, 20, 18, "b")
    for k in range(10):
        c.px(21, 19 - k, "f")                                                            # a burning blade
    c.px(10, 4, "y"); c.px(14, 4, "y")


MUSPELL_PAL = {"o": "#140604", "k": "#0a0302", "b": "#2e2420", "f": "#f07a20", "y": "#ffe060"}


def hound(asleep):
    """Gifr and Geri, the two hounds who guard the flame-ringed hall in Fjolsvinnsmal (13-18): one sleeps while the
    other keeps watch, by turns."""
    def draw(c, step):
        if asleep:
            ellipse(c, 24, 26, 18, 7, "g"); ellipse(c, 24, 29, 15, 4, "G")
            poly(c, [(38, 22), (48, 24), (48, 29), (38, 29)], "g"); c.row(26, 42, 45, "k")   # head down, eyes shut
            c.rect(4, 26, 8, 28, "G")
            return
        ellipse(c, 24, 20, 17, 8, "g")
        for k, d in enumerate((-step, step, step, -step)):
            c.rect(10 + k * 9 + d, 26, 13 + k * 9 + d, 36, "G" if k % 2 else "g")
        poly(c, [(38, 10), (52, 14), (52, 20), (38, 21)], "g")
        c.px(46, 14, "y"); c.rect(49, 18, 52, 20, "k"); c.row(19, 46, 50, "w")
        c.px(40, 6, "g"); c.px(41, 7, "g"); c.px(43, 6, "g")
        c.rect(3, 15, 8, 17, "G")
        for k in range(6):
            c.px(14 + k * 4, 11, "f")                                                    # embers in its coat
    return draw


HOUND_PAL = {"o": "#120604", "k": "#080202", "g": "#5a2a1a", "G": "#3a1a10", "y": "#ffd040", "w": "#f0e8d8",
             "f": "#f08030"}


def vidofnir(c, step):
    """Vidofnir (Fjolsvinnsmal 18-26): the shining cock who sits on the world-tree, gleaming like gold."""
    ellipse(c, 24, 26, 12, 10, "u")
    for k in range(5):                                                                   # the great arched tail
        poly(c, [(14, 22), (2 + k * 2, 4 + k * 3), (8 + k * 2, 8 + k * 3)], ("r", "u", "U", "r", "u")[k])
    ellipse(c, 34, 14, 5, 5, "u")
    poly(c, [(38, 13), (44, 15), (38, 17)], "y"); c.px(35, 12, "k")
    c.rect(32, 6, 36, 9, "r"); c.px(31, 7, "r"); c.px(37, 7, "r")                       # comb
    c.rect(37, 17, 38, 21, "r")                                                          # wattle
    poly(c, [(20, 22), (30, 24), (24, 32)], "U")                                         # wing
    for k, d in enumerate((-step, step)):
        c.rect(20 + k * 8 + d, 35, 21 + k * 8 + d, 44, "y")
        c.row(45, 18 + k * 8 + d, 23 + k * 8 + d, "y")
    for k in range(6):
        c.px(16 + k * 4, 30 + (k % 2), "w")                                             # gleam


VIDOFNIR_PAL = {"o": "#1a0e04", "k": "#0a0602", "u": "#f0c040", "U": "#c8901c", "r": "#d83020", "y": "#e8a030",
                "w": "#fff8d0"}


def sinmara(c, step):
    """Sinmara (Fjolsvinnsmal 26-30): the giantess of the fire realm who keeps the weapon Laevateinn locked in an iron
    chest with nine locks. A tall giantess in dark robes edged with flame, ash-pale, with a ring of keys."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 7 + d, 58, 19 + k * 7 + d, 64, "k")
    poly(c, [(13, 22), (33, 22), (38, 58), (8, 58)], "r")
    poly(c, [(13, 22), (18, 22), (13, 58), (8, 58)], "R")
    for y in range(50, 58, 2):
        c.row(y, 9 + (58 - y) // 6, 37 - (58 - y) // 6, "f")                             # hem of flame
    c.rect(17, 8, 28, 20, "s"); c.rect(17, 8, 18, 20, "S"); c.px(25, 12, "y"); c.px(21, 12, "y")
    c.rect(15, 2, 30, 8, "h"); c.rect(14, 6, 17, 30, "h")                                # dark hair, smouldering
    for x in range(15, 30, 3):
        c.px(x, 1, "f")
    c.row(34, 12, 34, "u")
    for k in range(5):
        c.rect(22 + k * 2, 35, 22 + k * 2, 39, "u")                                      # her keys
    c.rect(33, 24, 35, 32, "s")
    for k in range(26):
        c.px(36 + k // 6, 34 - k, "f" if k % 2 else "y")                                 # Laevateinn, a blade of flame


SINMARA_PAL = {"o": "#120404", "k": "#080202", "r": "#2a1a1e", "R": "#1a0e12", "s": "#d8c8c0", "S": "#a89890",
               "h": "#2a1210", "f": "#f07a20", "y": "#ffe060", "u": "#b8a060"}


# --- Niflheim (Gylfaginning 4-5, 16; Grimnismal 32-35; Voluspa 39, 44; Vafthrudnismal 37) ----------------------------

def rime_wraith(c, f):
    """A rime wraith (Niflheim; Gylfaginning 5: the rime and frost of Ginnungagap): a pale, drifting shape of frost
    mist with hollow eyes."""
    sway = [0, 1, 0, -1, 0][f]
    for y in range(2, 20):
        half = 4 - abs(y - 9) * 0.25 if y < 14 else 3 - (y - 14) * 0.5
        c.rect(round(8 - half + sway * (y > 12)), y, round(8 + half + sway * (y > 12)), y, "w" if y % 3 else "W")
    c.px(6, 7, "k"); c.px(10, 7, "k")
    c.px(3, 12, "W"); c.px(13, 11, "W")


WRAITH_PAL = {"o": "#2a3a4a", "w": "#e8f2f8", "W": "#b8d0e0", "k": "#2a4a6a"}


def hvergelmir_serpent(c, f):
    """A serpent of Hvergelmir (Grimnismal 34: more serpents lie under the world-tree than any fool knows): a pale,
    ice-scaled snake from the roaring spring."""
    s = STEP[f]
    for x in range(1, 17):
        y = 7 + round(1.4 * math.sin((x + s * 2) / 2.2))
        c.rect(x, y, x, y + 1, "s" if x % 3 else "S")
    poly(c, [(16, 3), (21, 4), (21, 6), (16, 7)], "s"); c.px(18, 4, "k"); c.px(22, 6, "r")


SERP_PAL = {"o": "#1a2a34", "s": "#a8c8d8", "S": "#7a9ab0", "k": "#0a1a24", "r": "#c83030"}


def hraesvelgr(c, step):
    """Hraesvelgr (Vafthrudnismal 37; Gylfaginning 18): the giant in the shape of an eagle who sits at the end of the
    heavens; the wind comes from his wings. A vast pale eagle, wings spread."""
    ellipse(c, 40, 34, 10, 14, "b")
    for side in (-1, 1):
        pts = [(40, 26), (40 + side * 38, 12 + step * side), (40 + side * 34, 26), (40 + side * 38, 34), (40, 38)]
        poly(c, pts, "B" if side < 0 else "b")
        for k in range(6):
            c.rect(40 + side * (12 + k * 4), 30 + k, 40 + side * (12 + k * 4), 34 + k, "w")
    ellipse(c, 40, 18, 6, 5, "w")
    poly(c, [(40, 20), (47, 22), (42, 25)], "u"); c.px(42, 17, "k")
    for k in range(4):
        c.rect(34 + k * 4, 48, 34 + k * 4, 53, "u")


HRAES_PAL = {"o": "#18202a", "k": "#080c10", "b": "#8a9aa8", "B": "#6a7a88", "w": "#e8eef4", "u": "#d8b048"}


def garmr(c, step):
    """Garmr (Voluspa 44: Garm bays loudly before Gnipahellir; Grimnismal 44: the best of hounds): a huge grey hound,
    its chest dark with blood, baying."""
    ellipse(c, 26, 22, 18, 9, "g")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(11 + k * 10 + d, 28, 14 + k * 10 + d, 40, "G" if k % 2 else "g")
    poly(c, [(40, 10), (54, 6), (56, 14), (42, 22)], "g")                               # head raised, baying
    c.rect(52, 12, 56, 15, "k"); c.px(48, 9, "y")
    c.px(43, 6, "g"); c.px(44, 5, "g")
    ellipse(c, 40, 24, 5, 6, "r")                                                        # the blood on its breast
    c.rect(4, 17, 9, 19, "G")


GARMR_PAL = {"o": "#10100e", "k": "#060604", "g": "#6a6a66", "G": "#4a4a46", "r": "#7a1a18", "y": "#e8d040"}


def nidhoggr(c, step):
    """Nidhoggr (Grimnismal 35; Voluspa 39, 66): the dragon who gnaws the roots of the world-tree from beneath, and
    flies over the plain with corpses in its wings. A dark winged dragon coiled among great roots."""
    for k in range(4):                                                                   # the roots of the tree
        c.rect(2 + k * 18, 46 - k % 2 * 3, 14 + k * 18, 49, "r")
    for k in range(8):
        ellipse(c, 10 + k * 7, 38 + round(3 * math.sin(k / 1.4 + step * 0.4)), 6, 5, "d" if k % 2 else "D")
    poly(c, [(30, 32), (14, 10 + step), (34, 30)], "w"); poly(c, [(42, 32), (58, 10 - step), (46, 30)], "w")
    poly(c, [(58, 26), (70, 28), (72, 34), (60, 36)], "d")
    c.rect(66, 32, 72, 35, "D"); c.row(33, 66, 72, "t"); c.px(63, 29, "y")
    poly(c, [(60, 26), (58, 18), (63, 25)], "t")


NID_PAL = {"o": "#08080c", "d": "#2a2a3a", "D": "#1a1a26", "w": "#3a2a3a", "r": "#5a4430", "t": "#d8d0b8",
           "y": "#c8f040"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_realms.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("salamander", salamander, SAL_PAL, doc(salamander.__doc__), (22, 15), (11, 14), walk, folder="enemies")
    kit.build_boss("son_of_muspell", son_of_muspell, MUSPELL_PAL, doc(son_of_muspell.__doc__), (24, 30), (12, 28), walk,
                   folder="enemies")
    kit.build_boss("gifr_and_geri", hound(False), HOUND_PAL, doc(hound.__doc__), (56, 40), (26, 38), [0, 1, 0, -1, 0])
    kit.build_boss("gifr_and_geri_asleep", hound(True), HOUND_PAL, doc(hound.__doc__ + " Here, asleep."), (56, 40), (26, 38),
                   [0, 0, 0, 0, 0])
    kit.build_boss("vidofnir", vidofnir, VIDOFNIR_PAL, doc(vidofnir.__doc__), (48, 48), (24, 46), [0, 1, 0, -1, 0])
    kit.build_boss("sinmara", sinmara, SINMARA_PAL, doc(sinmara.__doc__), (46, 66), (22, 64), [0, 1, 0, -1, 0])
    kit.build_boss("rime_wraith", rime_wraith, WRAITH_PAL, doc(rime_wraith.__doc__), (16, 22), (8, 21), walk, folder="enemies")
    kit.build_boss("hvergelmir_serpent", hvergelmir_serpent, SERP_PAL, doc(hvergelmir_serpent.__doc__), (24, 12), (11, 10),
                   walk, folder="enemies")
    kit.build_boss("hraesvelgr", hraesvelgr, HRAES_PAL, doc(hraesvelgr.__doc__), (80, 56), (40, 54), [0, 1, 0, -1, 0])
    kit.build_boss("garmr", garmr, GARMR_PAL, doc(garmr.__doc__), (58, 42), (28, 40), [0, 1, 0, -1, 0])
    kit.build_boss("nidhoggr", nidhoggr, NID_PAL, doc(nidhoggr.__doc__), (74, 52), (36, 50), [0, 1, 0, -1, 0])
    print("wrote the Elemental Planes' art")
