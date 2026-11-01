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
    print("wrote the Heavens' art")
