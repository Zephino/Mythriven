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


# --- Ys (Le Grand 1636; Barzaz Breiz 1839; Souvestre 1844; Sebillot; Le Braz 1893; Paracelsus) ------------------------

def undine(c, f):
    """An undine, the water spirit of Paracelsus (1566): a woman of water, blue-green and flowing."""
    sway = [0, 1, 0, -1, 0][f]
    poly(c, [(7, 9), (13, 9), (16 + sway, 24), (4 + sway, 24)], "w")
    for y in range(12, 24, 3):
        c.row(y, 6 + sway * (y > 18), 14 + sway * (y > 18), "W")
    c.rect(7, 2, 13, 8, "s"); c.px(11, 5, "k")
    c.rect(5, 1, 7, 16, "h"); c.rect(7, 0, 13, 2, "h")


UNDINE_PAL = {"o": "#08202a", "k": "#04101a", "w": "#4aa0b8", "W": "#7ac8d8", "s": "#c8e8f0", "h": "#2a7a8a"}


def mari_morgan(c, f):
    """A mari-morgan (Breton folklore, gathered by Paul Sebillot): a sea-fairy with long golden hair who sings and
    draws sailors down to her palaces under the waves."""
    s = STEP[f]
    poly(c, [(7, 9), (13, 9), (14, 20), (6, 20)], "g")
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 20, x + 1 + d, 24, "s")
    c.rect(7, 2, 13, 8, "s"); c.px(11, 5, "k"); c.row(7, 10, 12, "r")
    c.rect(5, 1, 7, 18, "h"); c.rect(13, 1, 14, 14, "h"); c.rect(7, 0, 13, 2, "h")
    c.px(15, 10, "p"); c.px(16, 9, "p")                                                  # a pearl comb


MORGAN_PAL = {"o": "#0a1a20", "k": "#060a0e", "g": "#3a8a7a", "s": "#e8d8c8", "h": "#e0c050", "r": "#c84050",
              "p": "#f0f0f0"}


def drowned(c, f):
    """One of the drowned of Ys (the Barzaz Breiz: the city drowned when the sea gates were opened): a pale, sodden
    townsman draped in weed, slow and heavy."""
    s = STEP[f]
    for x, d in ((7, -s), (12, s)):
        c.rect(x + d, 19, x + 2 + d, 25, "b")
    c.rect(6, 9, 15, 19, "c"); c.rect(6, 9, 7, 19, "C")
    c.rect(7, 2, 14, 8, "p"); c.px(12, 5, "k"); c.px(9, 5, "k")
    for x in range(6, 16, 3):
        c.rect(x, 10, x, 16, "w")                                                        # weed hanging off him
    c.rect(16, 10, 17, 15, "p")


DROWNED_PAL = {"o": "#0a1418", "k": "#06080a", "b": "#2a3a40", "c": "#4a5a62", "C": "#34444c", "p": "#b8c8c8",
               "w": "#3a6a3a"}


def morvarch(c, step):
    """Morvarc'h (Albert Le Grand; Souvestre): King Gradlon's black sea-horse, who could gallop over the waves; on it
    the king escaped the drowning of Ys. A great dark horse, its mane and tail foaming like surf."""
    from build_avalon import horse
    ellipse(c, 30, 46, 26, 4, "f")                                                       # the surf under its hooves
    horse(c, 8, 26, "h", "H", step, length=36)
    for k in range(8):
        c.px(41 + k, 18 - k // 2, "w"); c.px(42 + k, 19 - k // 2, "f")                    # foaming mane
    for k in range(6):
        c.px(5 - k // 2, 28 + k * 2, "w")


MORVARCH_PAL = {"o": "#06080e", "k": "#020306", "h": "#1a2030", "H": "#10141e", "w": "#e8f4f8", "f": "#8ac0d8"}


def ankou(c, step):
    """The Ankou (Anatole Le Braz, La Legende de la mort, 1893): the Breton figure of death, a tall gaunt figure in a
    long coat and wide hat, with a scythe whose blade is turned outward; the axle of his cart creaks in the night."""
    c.rect(4, 44, 22, 50, "b"); c.rect(4, 44, 22, 45, "B")                              # his cart behind him
    ellipse(c, 8, 52, 4, 4, "B"); ellipse(c, 18, 52, 4, 4, "B")
    for k, d in enumerate((-step, step)):
        c.rect(24 + k * 5 + d, 46, 25 + k * 5 + d, 54, "k")
    poly(c, [(22, 18), (34, 18), (36, 46), (20, 46)], "c")
    c.rect(24, 8, 32, 17, "s"); c.px(26, 12, "k"); c.px(30, 12, "k"); c.rect(27, 14, 29, 15, "k")   # skull face
    c.rect(20, 5, 36, 8, "c")                                                            # wide hat
    for k in range(34):
        c.px(38, 48 - k, "b")                                                            # the scythe's long snath
    poly(c, [(38, 14), (46, 18), (48, 24), (40, 18)], "i")                               # blade turned outward


ANKOU_PAL = {"o": "#08080a", "k": "#040406", "c": "#1e1e24", "s": "#d8d4c8", "b": "#4a3a2a", "B": "#2e2418",
             "i": "#c8ccd4"}


def dahut(morgan):
    """Dahut (Albert Le Grand; the Barzaz Breiz): King Gradlon's daughter, who stole the key of the sea gates from her
    sleeping father and opened them, and the sea drowned Ys. Breton tradition says she lives on as a mari-morgan."""
    def draw(c, step):
        if morgan:
            for y in range(36, 56):
                c.rect(16 + (y - 36) // 3 + step, y, 26 - (y - 36) // 4 + step, y, "t" if y % 3 else "T")  # sea-weed train
        else:
            for k, d in enumerate((-step, step)):
                c.rect(16 + k * 5 + d, 50, 18 + k * 5 + d, 54, "k")
            poly(c, [(14, 20), (28, 20), (32, 52), (10, 52)], "r")
            c.row(30, 12, 30, "u"); c.row(44, 11, 31, "u")
        if morgan:
            poly(c, [(14, 20), (28, 20), (30, 38), (12, 38)], "t")
        c.rect(16, 8, 25, 18, "s"); c.px(22, 12, "k"); c.px(19, 12, "k")
        c.rect(15, 4, 26, 8, "h"); c.rect(13, 7, 16, 34, "h"); c.rect(26, 7, 28, 26, "h")   # long golden hair
        c.row(3, 17, 24, "u"); c.px(18, 2, "u"); c.px(23, 2, "u")                          # a princess's circlet
        c.rect(28, 24, 30, 30, "s")
        c.rect(31, 26, 34, 27, "u"); c.px(35, 25, "u"); c.px(35, 28, "u")                  # the golden key
    return draw


DAHUT_PAL = {"o": "#0c0a10", "k": "#060408", "r": "#2a3a7a", "u": "#e0c050", "s": "#ecd4c0", "h": "#e0c050",
             "t": "#2a7a6a", "T": "#1a5a4a"}


# --- Cloud-Cuckoo-Land (Aristophanes, The Birds, 414 BC; the Thousand and One Nights; Paracelsus) ---------------------

def sylph(c, f):
    """A sylph, the air spirit of Paracelsus (1566): a slight, pale figure of the air with gauzy wings."""
    flap = [0, -1, -2, -1, 0][f]
    poly(c, [(6, 9), (1, 3 + flap), (8, 7)], "w"); poly(c, [(12, 9), (17, 3 + flap), (10, 7)], "w")
    poly(c, [(7, 8), (11, 8), (12, 18), (6, 18)], "b")
    c.rect(7, 2, 11, 7, "s"); c.px(10, 4, "k"); c.rect(6, 1, 12, 2, "h")
    c.px(8, 19, "b"); c.px(10, 20, "b")


SYLPH_PAL = {"o": "#2a3a5a", "k": "#1a2a4a", "w": "#e0f0ff", "b": "#a8c8f0", "s": "#f0f4f8", "h": "#f0e8b0"}


def bird_flock(c, f):
    """The birds' army (Aristophanes, The Birds: the chorus of birds, owls, jays and crows among them): a small dark
    bird darting in a flock."""
    flap = [0, -2, -3, -2, 0][f]
    ellipse(c, 8, 7, 3.5, 2.5, "b")
    poly(c, [(7, 6), (2, 2 + flap), (9, 6)], "B"); poly(c, [(9, 6), (14, 2 + flap), (8, 6)], "B")
    c.px(11, 6, "k"); c.px(12, 7, "y")
    c.rect(3, 7, 4, 8, "B")


FLOCK_PAL = {"o": "#10101a", "k": "#000000", "b": "#3a3a4a", "B": "#24242e", "y": "#e0b040"}


def storm_gust(c, f):
    """A storm gust of the sky between earth and heaven (The Birds): a whirling knot of wind and cloud."""
    turn = f * 2
    for k in range(3):
        r = 7 - k * 2
        for a in range(0, 360, 20):
            x = 9 + round(r * math.cos(math.radians(a + turn * 20 + k * 40)))
            y = 9 + round(r * 0.7 * math.sin(math.radians(a + turn * 20 + k * 40)))
            c.px(x, y, "w" if (a // 20 + k) % 2 else "W")


GUST_PAL = {"o": "#4a5a7a", "w": "#f0f4ff", "W": "#b8c8e0"}


def hoopoe(c, step):
    """The Hoopoe (The Birds: Tereus, once a king, turned into a hoopoe, who rules the birds): a great hoopoe with its
    crown of black-tipped crest feathers raised, barred wings, a long curved bill."""
    ellipse(c, 24, 28, 12, 9, "b")
    for k in range(5):
        c.rect(14 + k * 4, 26, 15 + k * 4, 34, "k" if k % 2 else "w")                    # barred wings
    ellipse(c, 34, 16, 6, 5, "b")
    for k in range(7):                                                                   # the crest
        c.rect(28 + k * 2, 4 + abs(3 - k), 29 + k * 2, 11, "b")
        c.px(28 + k * 2, 3 + abs(3 - k), "k")
    for k in range(10):
        c.px(39 + k, 17 + k // 4, "B")                                                   # long curved bill
    c.px(36, 15, "k")
    for k, d in enumerate((-step, step)):
        c.rect(20 + k * 8 + d, 36, 21 + k * 8 + d, 44, "B")
    poly(c, [(12, 26), (2, 22), (4, 30)], "k")


HOOPOE_PAL = {"o": "#1a0e06", "k": "#141010", "b": "#d89a5a", "B": "#6a4a2a", "w": "#f0ece0"}


def iris(c, step):
    """Iris (The Birds: the gods' messenger, caught as she flies through the birds' sky), messenger of the gods, on
    golden wings, with a rainbow streaming behind her."""
    for k, colour in enumerate(("r", "y", "g", "b", "v")):
        for x in range(0, 16):
            c.px(x, 30 + k + round(2 * math.sin(x / 3.0)), colour)                       # the rainbow behind her
    poly(c, [(20, 22), (8, 8 + step), (18, 24)], "u"); poly(c, [(28, 22), (40, 8 - step), (30, 24)], "u")   # wings
    poly(c, [(19, 20), (29, 20), (32, 50), (16, 50)], "w")
    c.rect(20, 8, 28, 18, "s"); c.px(26, 12, "k")
    c.rect(18, 5, 29, 9, "h"); c.rect(17, 8, 19, 22, "h")
    c.rect(29, 22, 31, 28, "s")
    for k in range(14):
        c.px(32, 30 - k, "u")                                                            # a herald's staff
    c.rect(31, 15, 33, 16, "u")


IRIS_PAL = {"o": "#1a1420", "k": "#0a0610", "w": "#f0ecf4", "s": "#f0d8c0", "h": "#3a2a1a", "u": "#e8c040",
            "r": "#e04040", "y": "#f0d040", "g": "#40c060", "b": "#4080e0", "v": "#8a50d0"}


def roc(c, step):
    """The Roc (the Thousand and One Nights, the voyages of Sindbad): a bird so vast that it hid the sun and fed its
    young on elephants. Dark brown, with a hooked golden beak and talons."""
    ellipse(c, 42, 34, 12, 16, "b")
    for side in (-1, 1):
        pts = [(42, 26), (42 + side * 40, 10 + step * side), (42 + side * 36, 28), (42 + side * 40, 38), (42, 40)]
        poly(c, pts, "B" if side < 0 else "b")
        for k in range(7):
            c.rect(42 + side * (12 + k * 4), 32 + k, 42 + side * (12 + k * 4), 36 + k, "B" if side > 0 else "b")
    ellipse(c, 42, 16, 7, 6, "b")
    poly(c, [(44, 16), (52, 20), (46, 23)], "u"); c.px(44, 14, "k")
    for k in range(4):
        c.rect(36 + k * 4, 50, 36 + k * 4, 56, "u")
        c.px(37 + k * 4, 56, "u")


ROC_PAL = {"o": "#120a04", "k": "#060402", "b": "#6a4a2a", "B": "#4a3018", "u": "#e0b040"}


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
    kit.build_boss("undine", undine, UNDINE_PAL, doc(undine.__doc__), (20, 26), (10, 25), walk, folder="enemies")
    kit.build_boss("mari_morgan", mari_morgan, MORGAN_PAL, doc(mari_morgan.__doc__), (20, 26), (10, 25), walk, folder="enemies")
    kit.build_boss("drowned_of_ys", drowned, DROWNED_PAL, doc(drowned.__doc__), (20, 26), (10, 25), walk, folder="enemies")
    kit.build_boss("morvarch", morvarch, MORVARCH_PAL, doc(morvarch.__doc__), (60, 52), (28, 50), [0, 1, 0, -1, 0])
    kit.build_boss("ankou", ankou, ANKOU_PAL, doc(ankou.__doc__), (52, 58), (28, 56), [0, 1, 0, -1, 0])
    kit.build_boss("dahut", dahut(False), DAHUT_PAL, doc(dahut.__doc__), (40, 58), (20, 56), [0, 1, 0, -1, 0])
    kit.build_boss("dahut_morgan", dahut(True), DAHUT_PAL, doc(dahut.__doc__ + " Here, as the mari-morgan."), (40, 58),
                   (20, 56), [0, 1, 0, -1, 0])
    kit.build_boss("sylph", sylph, SYLPH_PAL, doc(sylph.__doc__), (18, 22), (9, 21), walk, folder="enemies")
    kit.build_boss("bird_flock", bird_flock, FLOCK_PAL, doc(bird_flock.__doc__), (16, 12), (8, 11), walk, folder="enemies")
    kit.build_boss("storm_gust", storm_gust, GUST_PAL, doc(storm_gust.__doc__), (18, 18), (9, 17), walk, folder="enemies")
    kit.build_boss("hoopoe", hoopoe, HOOPOE_PAL, doc(hoopoe.__doc__), (52, 46), (24, 44), [0, 1, 0, -1, 0])
    kit.build_boss("iris", iris, IRIS_PAL, doc(iris.__doc__), (44, 54), (24, 52), [0, 1, 0, -1, 0])
    kit.build_boss("roc", roc, ROC_PAL, doc(roc.__doc__), (86, 60), (42, 58), [0, 1, 0, -1, 0])
    print("wrote the Elemental Planes' art")
