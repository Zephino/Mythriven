# The Heavens' art (Pack 10, docs/PACK_10_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Herodotus, Pindar, Aratus, Ptolemy, Hyginus, Ovid, Apollodorus, Homer; the Grimms; Andersen, 1844), never later
# versions.
# Run: python3 build_heavens.py from tools/art/.
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


# --- Hyperborea (Herodotus 3.116, 4.13-36; Pindar, Pythian 10) --------------------------------------------------------

def arimaspian(c, f):
    """An Arimaspian (Herodotus 4.27: "one-eyed men" of the far north who steal gold from the griffins): a fur-clad raider
    with a single great eye."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    c.rect(5, 8, 14, 18, "f"); c.row(12, 5, 14, "F")
    ellipse(c, 9, 5, 3.5, 3, "s"); ellipse(c, 9, 5, 1.5, 1.2, "w"); c.px(9, 5, "k")
    c.rect(6, 1, 12, 2, "F"); c.rect(16, 3, 16, 17, "b"); c.rect(15, 2, 17, 4, "i")


ARIMASPIAN_PAL = {"o": "#0e0a08", "k": "#1e1814", "f": "#8a6a48", "F": "#6a4e34", "s": "#d0a080", "w": "#f0ece4",
                  "b": "#5a3a1a", "i": "#9aa0a8"}


def young_griffin(c, f):
    """A young griffin (Herodotus 3.116, 4.13: the griffins that guard the gold): a small eagle-headed, lion-bodied
    beast on golden wings."""
    up = f % 2
    poly(c, [(9, 7), (2, 1 if up else 6), (6, 9)], "y"); poly(c, [(11, 7), (18, 1 if up else 6), (14, 9)], "y")
    ellipse(c, 10, 10, 4, 3, "t"); ellipse(c, 14, 6, 2, 2, "w"); poly(c, [(15, 6), (18, 7), (15, 8)], "y")
    c.px(14, 5, "k"); c.px(6, 12, "t"); c.px(13, 13, "t")


YOUNG_GRIFFIN_PAL = {"o": "#2a1a08", "y": "#e8c040", "t": "#c8944a", "w": "#f0ece4", "k": "#1a1008"}


def feather_flurry(c, f):
    """A flurry of the north's "feathers" (Herodotus 4.31: the air beyond the north wind is full of feathers, which he
    took to be snow): a swirl of white flakes."""
    for k in range(6):
        a = k / 6 * math.tau + f * 0.4
        c.px(7 + round(4 * math.cos(a)), 6 + round(4 * math.sin(a)), "w")
        c.px(7 + round(2 * math.cos(a + 1)), 6 + round(2 * math.sin(a + 1)), "W")


FLURRY_PAL = {"o": "#6a7888", "w": "#ffffff", "W": "#c8d8e8"}


def arimaspian_chieftain(c, step):
    """The Arimaspian Chieftain (Herodotus 4.27): a great one-eyed raider of the north in furs and gold he has stolen
    from the griffins."""
    figure(c, step, "f", "s", "F")
    c.rect(16, 18, 26, 30, "F"); c.row(24, 16, 26, "y"); c.px(18, 22, "y"); c.px(24, 22, "y")
    c.rect(17, 9, 24, 13, "s"); ellipse(c, 21, 10, 2.5, 2, "w"); c.px(21, 10, "k")
    c.rect(32, 8, 33, 44, "b"); poly(c, [(33, 8), (40, 6), (40, 14), (33, 12)], "i")


CHIEFTAIN_PAL = dict(ARIMASPIAN_PAL, y="#e8c040")


def six_month_sleeper(c, step):
    """The Six-Month Sleeper (Herodotus 4.25: men of the far north who, it was said, sleep for six months of the year):
    a heavy, shaggy northerner wrapped in furs, eyes half-closed."""
    figure(c, step, "f", "s", "w", legs="F")
    c.rect(12, 18, 30, 34, "F"); c.rect(16, 13, 25, 16, "w")
    c.row(10, 17, 19, "k"); c.row(10, 22, 24, "k")


SLEEPER_PAL = {"o": "#0e0a08", "k": "#1e1814", "f": "#a89078", "F": "#7a6450", "s": "#e0c0a0", "w": "#e8e4dc"}


def griffin_matriarch(c, step):
    """The Griffin Matriarch (Herodotus 4.13; the gold-guarding griffins): a great griffin, eagle's head and wings on a
    lion's body, her feathers flecked with gold."""
    poly(c, [(26, 22), (6, 4 - step), (22, 26)], "y"); poly(c, [(34, 22), (54, 4 + step), (38, 26)], "Y")
    ellipse(c, 30, 32, 16, 9, "t")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(18 + k * 8 + d, 38, 20 + k * 8 + d, 48, "T")
    ellipse(c, 48, 22, 7, 7, "w"); poly(c, [(54, 22), (60, 26), (53, 27)], "y"); c.px(49, 20, "k")
    for k in range(10):
        c.px(13 - k, 30 + k // 3, "t")


MATRIARCH_PAL = {"o": "#2a1a08", "y": "#e8c040", "Y": "#c8a030", "t": "#c8944a", "T": "#a8743a", "w": "#f0ece4",
                 "k": "#1a1008"}


# --- The Empyrean (Aratus, Phaenomena; Ptolemy, Almagest; Hyginus 2.21-36; Ovid, Met. 2, Fasti 5; Apollodorus 1.4) ----

def star_hound(c, f):
    """A star hound (Aratus; Hyginus 2.35-36: Orion's dogs set among the stars): a hound picked out in points of light."""
    s = STEP[f]
    ellipse(c, 11, 9, 7, 3, "d")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 11, 5 + k * 4 + d, 15, "d")
    poly(c, [(16, 5), (22, 7), (22, 10), (16, 10)], "d")
    for x, y in ((6, 8), (11, 7), (16, 9), (20, 7), (5, 14), (13, 14)):
        c.px(x, y, "w")


STAR_HOUND_PAL = {"o": "#0a0c1a", "d": "#2a3060", "w": "#f0f4ff"}


def star_mote(c, f):
    """A star mote: a small bright point of the sky, twinkling."""
    for d in range(-2, 3):
        c.px(5 + d, 5, "w" if d == 0 else "y"); c.px(5, 5 + d, "w" if d == 0 else "y")
    if f % 2:
        c.px(3, 3, "y"); c.px(7, 7, "y"); c.px(3, 7, "y"); c.px(7, 3, "y")


STAR_MOTE_PAL = {"o": "#1a1a30", "w": "#ffffff", "y": "#f0e080"}


def comet(c, f):
    """A comet (Aratus: the hairy stars): a bright head with a long streaming tail."""
    ellipse(c, 16, 6, 2.5, 2.5, "w")
    for k in range(12):
        c.px(13 - k, 6 - k // 4 + (k + f) % 2, "y" if k < 6 else "b")


COMET_PAL = {"o": "#1a1a30", "w": "#ffffff", "y": "#f0e0a0", "b": "#8aa8e8"}


def scorpion(c, step):
    """The Scorpion (Hyginus 2.26; Ovid, Fasti 5.537-544): the great scorpion Earth sent to kill Orion, set among the
    stars; drawn in the dark of the sky with stars at its joints, its tail curled to strike."""
    ellipse(c, 26, 32, 12, 7, "d")
    for k in range(8):
        a = math.pi * (1.1 + k * 0.12)
        c.rect(26 + round(math.cos(a) * 14) - k, 30 - k * 3, 28 + round(math.cos(a) * 14) - k, 32 - k * 3, "d")
    poly(c, [(33, 8), (37, 2), (36, 9)], "r")
    for side in (-1, 1):
        for k in range(3):
            c.px(26 + side * (12 + k * 3), 36 + k + (step if k % 2 else -step), "d")
        ellipse(c, 26 + side * 18, 24, 4, 3, "d")
    for x, y in ((26, 32), (20, 30), (32, 30), (30, 18), (33, 10), (44, 24), (8, 24)):
        c.px(x, y, "w")


SCORPION_PAL = {"o": "#0a0c1a", "d": "#3a2a4a", "r": "#e83a6a", "w": "#f0f4ff"}


def great_bear(c, step):
    """The Great Bear (Ovid, Metamorphoses 2.401-530; Aratus 26-62): Callisto, turned into a bear and set among the
    stars, where she turns round the pole and never sinks into the sea; a great bear of night-blue picked out in her
    seven bright stars."""
    ellipse(c, 30, 30, 22, 12, "d")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(14 + k * 10 + d, 38, 18 + k * 10 + d, 48, "D")
    ellipse(c, 50, 24, 9, 8, "d"); c.px(54, 22, "w"); c.px(46, 16, "d"); c.px(53, 16, "d")
    for x, y in ((10, 26), (16, 24), (22, 24), (28, 26), (34, 30), (40, 28), (44, 24)):
        c.rect(x, y, x + 1, y + 1, "w")


BEAR_PAL = {"o": "#06081a", "d": "#2a3a6a", "D": "#1e2a50", "w": "#ffffff"}


def orion(c, step):
    """Orion (Apollodorus 1.4.3-5; Aratus): the giant hunter, with his club and the three bright stars of his belt."""
    figure(c, step, "d", "s", "h", legs="D")
    c.rect(16, 18, 26, 34, "D"); c.row(28, 16, 26, "y")
    c.px(18, 28, "w"); c.px(21, 28, "w"); c.px(24, 28, "w")                                        # the belt's three stars
    c.rect(32, 4, 35, 30, "b"); ellipse(c, 33, 4, 3, 3, "b")                                       # his club
    c.rect(4, 20, 9, 26, "y")


ORION_PAL = {"o": "#06081a", "k": "#141a30", "d": "#2a3a6a", "D": "#1e2a50", "s": "#d8c0a0", "h": "#3a2a1a",
             "y": "#d8b860", "w": "#ffffff", "b": "#6a4a2a"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_heavens.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("arimaspian", arimaspian, ARIMASPIAN_PAL, doc(arimaspian.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("young_griffin", young_griffin, YOUNG_GRIFFIN_PAL, doc(young_griffin.__doc__), (20, 16), (10, 15), walk, folder="enemies")
    kit.build_boss("feather_flurry", feather_flurry, FLURRY_PAL, doc(feather_flurry.__doc__), (14, 12), (7, 11), walk, folder="enemies")
    kit.build_boss("arimaspian_chieftain", arimaspian_chieftain, CHIEFTAIN_PAL, doc(arimaspian_chieftain.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("six_month_sleeper", six_month_sleeper, SLEEPER_PAL, doc(six_month_sleeper.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("griffin_matriarch", griffin_matriarch, MATRIARCH_PAL, doc(griffin_matriarch.__doc__), (62, 52), (30, 50), [0, 1, 0, -1, 0])
    kit.build_boss("star_hound", star_hound, STAR_HOUND_PAL, doc(star_hound.__doc__), (24, 16), (11, 15), walk, folder="enemies")
    kit.build_boss("star_mote", star_mote, STAR_MOTE_PAL, doc(star_mote.__doc__), (11, 11), (5, 10), walk, folder="enemies")
    kit.build_boss("comet", comet, COMET_PAL, doc(comet.__doc__), (20, 12), (10, 11), walk, folder="enemies")
    kit.build_boss("scorpion", scorpion, SCORPION_PAL, doc(scorpion.__doc__), (52, 46), (26, 44), [0, 1, 0, -1, 0])
    kit.build_boss("great_bear", great_bear, BEAR_PAL, doc(great_bear.__doc__), (62, 50), (30, 48), [0, 1, 0, -1, 0])
    kit.build_boss("orion", orion, ORION_PAL, doc(orion.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    print("wrote the Heavens' art")
