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
    print("wrote the Elemental Planes' art")
