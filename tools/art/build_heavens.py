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


# --- The Glass Mountain (Grimm KHM 25, KHM 196; Andersen, "The Snow Queen", 1844) -------------------------------------

def white_bee(c, f):
    """A white bee (Andersen: "the white bees are swarming", the grandmother's name for snowflakes): a snowflake with
    little wings."""
    for k in range(6):
        a = k / 6 * math.tau + f * 0.3
        for r in (1, 2, 3):
            c.px(6 + round(r * math.cos(a)), 6 + round(r * math.sin(a)), "w" if r < 3 else "b")


WHITE_BEE_PAL = {"o": "#6a7888", "w": "#ffffff", "b": "#c8e0f0"}


def snowflake_guard(c, f):
    """A snowflake guard of the Snow Queen (Andersen, 7th story: her advance guard of living snowflakes, shaped like
    horrid hedgehogs, knotted snakes and little fat bears): a squat white bear-shape of packed snow."""
    s = STEP[f]
    ellipse(c, 10, 10, 7, 6, "w"); ellipse(c, 10, 4, 4, 3, "w")
    c.px(8, 3, "k"); c.px(12, 3, "k"); c.px(6, 1, "w"); c.px(14, 1, "w")
    for k, d in enumerate((-s, s)):
        c.rect(6 + k * 6 + d, 15, 8 + k * 6 + d, 18, "b")
    for x, y in ((5, 8), (14, 11), (9, 13)):
        c.px(x, y, "b")


SNOW_GUARD_PAL = {"o": "#4a5a6a", "w": "#f4f8fc", "b": "#c8dcec", "k": "#2a3a4a"}


def seven_ravens(c, step):
    """The Seven Ravens (Grimm, KHM 25): seven brothers changed into ravens by their father's hasty word, who live in
    the glass mountain; their little sister freed them. Seven black ravens flying together as one."""
    for k in range(7):
        x = 8 + (k % 4) * 12 + (k // 4) * 6
        y = 10 + (k // 4) * 16 + ((k + step) % 2) * 2
        poly(c, [(x, y), (x - 7, y - 5 + step), (x - 3, y + 2)], "k"); poly(c, [(x + 2, y), (x + 9, y - 5 - step), (x + 5, y + 2)], "k")
        ellipse(c, x + 1, y + 2, 3, 2, "K"); c.px(x + 4, y + 1, "y")


RAVENS_PAL = {"o": "#2a2a34", "k": "#141418", "K": "#1e1e24", "y": "#e8c040"}


def rinkrank(c, step):
    """Old Rinkrank (Grimm, KHM 196): the old man with the long grey beard who lived in the glass mountain and made the
    king's daughter his servant, until she caught his beard in the window."""
    figure(c, step, "b", "s", "g", legs="B")
    poly(c, [(15, 12), (27, 12), (25, 44), (17, 44)], "g")                                          # the long grey beard
    c.rect(30, 20, 31, 46, "B"); c.rect(29, 18, 32, 20, "B")


RINKRANK_PAL = {"o": "#0e0a08", "k": "#1e1814", "b": "#5a4a3a", "B": "#3a2e24", "s": "#e0c0a0", "g": "#b8b8b8"}


def snow_queen(c, step):
    """The Snow Queen (Andersen, 1844): "a lady, tall and slender, and dazzling white; her cloak and cap were of snow".
    Her palace walls were driven snow; she kissed Kai, and he no longer felt the cold."""
    figure(c, step, "w", "s", "W", legs="b")
    poly(c, [(10, 18), (32, 18), (36, 52), (6, 52)], "W")
    poly(c, [(14, 18), (28, 18), (31, 50), (11, 50)], "w")
    for k in range(5):
        c.px(14 + k * 3, 1 - k % 2, "i"); c.px(14 + k * 3, 2, "i")                                 # an icy crown
    c.rect(14, 3, 27, 4, "i")
    c.px(18, 10, "b"); c.px(23, 10, "b")


SNOW_QUEEN_PAL = {"o": "#4a5a6a", "k": "#2a3a4a", "w": "#f4f8fc", "W": "#c8dcec", "s": "#f0f4f8", "b": "#5a8ab0",
                  "i": "#a8e0f8"}


# --- Demos Oneiron (Odyssey 19.560-569, 24.12; Ovid, Metamorphoses 11.583-649) -----------------------------------------

def dream(c, f):
    """A dream (Ovid 11.613-615: empty dreams lie all about the House of Sleep, as many as the ears of the harvest, the
    leaves of the woods, the sands of the shore): a pale wisp with a dim face."""
    s = STEP[f]
    poly(c, [(4, 4), (10, 4), (12, 11 + s), (2, 11 - s)], "w")
    c.px(6, 6, "k"); c.px(8, 6, "k")
    c.px(3, 12, "W"); c.px(11, 12 - s, "W")


DREAM_PAL = {"o": "#3a2a5a", "w": "#d8c8f0", "W": "#a890d0", "k": "#4a3a6a"}


def nightmare_beast(c, f):
    """A nightmare beast (Ovid 11.638-640: the shapes of beasts that Phobetor brings): a shadowy wolf-like beast with
    too many glowing eyes."""
    s = STEP[f]
    ellipse(c, 11, 9, 7, 3.5, "k")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 11, 5 + k * 4 + d, 15, "K")
    poly(c, [(16, 5), (22, 7), (22, 10), (16, 10)], "k")
    for x, y in ((18, 6), (20, 7), (17, 8)):
        c.px(x, y, "r")
    for k in range(5):
        c.px(4 - k, 8 + k % 2, "p")


NIGHTMARE_PAL = {"o": "#120a1a", "k": "#2a1a3a", "K": "#1a1028", "r": "#f04a8a", "p": "#6a3a8a"}


def phantasos(form):
    """Phantasos (Ovid 11.641-643): the dream-shaper of things without life: earth, rock, water, wood. Here as a rock
    with a sleeping face, or as a figure of water."""
    def draw(c, step):
        if form == "rock":
            ellipse(c, 24, 32, 20, 16, "g"); ellipse(c, 22, 28, 14, 10, "G")
            c.row(28, 17, 20, "k"); c.row(28, 26, 29, "k"); c.row(36, 20, 27, "k")
            for x, y in ((10, 24), (36, 36), (30, 20)):
                c.px(x, y, "l"); c.px(x + 1, y, "l")
            return
        for y in range(8, 50):
            w = 4 + int(8 * math.sin(min(y, 46) / 46 * math.pi)) + ((y + step) % 5 == 0)
            c.rect(24 - w, y, 24 + w, y, "b" if (y + step) % 4 else "B")
        c.px(21, 16, "w"); c.px(27, 16, "w")
        for k in range(5):
            c.px(14 + k * 5, 50 + k % 2, "B")
    return draw


PHANTASOS_PAL = {"o": "#0e1020", "g": "#6a6878", "G": "#7e7c8c", "k": "#2a2838", "l": "#7a8a5a", "b": "#5a8ad0",
                 "B": "#8ab0e8", "w": "#ffffff"}


def morpheus(c, step):
    """Morpheus (Ovid 11.633-638): the dream-shaper of men, who copies a man's walk, face and voice, and his very dress;
    a winged youth in grey, his face half a mask."""
    for side in (-1, 1):
        for k in range(7):
            x = 21 + side * (10 + k * 2)
            c.rect(min(x, x + side), 12 + k, max(x, x + side), 26 - k // 2, "w" if k % 2 else "W")
    figure(c, step, "g", "s", "h")
    c.rect(21, 7, 25, 15, "W")                                                                       # half a mask


MORPHEUS_PAL = {"o": "#120e1a", "k": "#1e1828", "g": "#6a6478", "s": "#e8d8c8", "h": "#2a2030", "w": "#e8e4f0",
                "W": "#b8b0c8"}


def phobetor(form):
    """Phobetor (Ovid 11.638-641): "called Icelus by the gods, Phobetor by mortal men", who becomes a beast, a bird or a
    long serpent: the bringer of nightmares."""
    def draw(c, step):
        if form == "beast":
            ellipse(c, 26, 30, 18, 10, "k")
            for k, d in enumerate((-step, step, step, -step)):
                c.rect(12 + k * 9 + d, 36, 15 + k * 9 + d, 48, "K")
            poly(c, [(42, 18), (56, 22), (56, 30), (42, 32)], "k")
            for x, y in ((46, 21), (49, 23), (52, 21), (47, 25)):
                c.px(x, y, "r")
            c.row(30, 50, 56, "w")
            return
        if form == "bird":
            poly(c, [(28, 26), (2, 8 + step * 2), (22, 32)], "k"); poly(c, [(32, 26), (58, 8 - step * 2), (38, 32)], "K")
            ellipse(c, 30, 30, 7, 6, "k"); poly(c, [(34, 26), (42, 28), (34, 31)], "p"); c.px(33, 27, "r")
            for k in range(4):
                c.px(26 - k * 2, 38 + k, "K")
            return
        for k in range(16):
            ellipse(c, 8 + k * 3, 34 + round(6 * math.sin(k / 2.2 + step * 0.5)), 4, 3, "k" if k % 2 else "p")
        ellipse(c, 56, 30, 5, 4, "k"); c.px(58, 29, "r"); c.row(32, 60, 63, "r")
    return draw


PHOBETOR_PAL = {"o": "#0a0612", "k": "#2a1a3a", "K": "#1a1028", "p": "#5a2a7a", "r": "#f04a8a", "w": "#e8e0f0"}


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
    kit.build_boss("white_bee", white_bee, WHITE_BEE_PAL, doc(white_bee.__doc__), (13, 13), (6, 12), walk, folder="enemies")
    kit.build_boss("snowflake_guard", snowflake_guard, SNOW_GUARD_PAL, doc(snowflake_guard.__doc__), (20, 20), (10, 19), walk, folder="enemies")
    kit.build_boss("seven_ravens", seven_ravens, RAVENS_PAL, doc(seven_ravens.__doc__), (60, 40), (30, 38), [0, 1, 0, -1, 0])
    kit.build_boss("rinkrank", rinkrank, RINKRANK_PAL, doc(rinkrank.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("snow_queen", snow_queen, SNOW_QUEEN_PAL, doc(snow_queen.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    kit.build_boss("dream", dream, DREAM_PAL, doc(dream.__doc__), (14, 14), (7, 13), walk, folder="enemies")
    kit.build_boss("nightmare_beast", nightmare_beast, NIGHTMARE_PAL, doc(nightmare_beast.__doc__), (24, 16), (11, 15), walk, folder="enemies")
    kit.build_boss("phantasos", phantasos("rock"), PHANTASOS_PAL, doc(phantasos.__doc__), (48, 54), (24, 52), [0, 1, 0, 1, 0])
    for form in ("rock", "water"):
        kit.build_boss("phantasos_" + form, phantasos(form), PHANTASOS_PAL, doc(phantasos.__doc__ + " Here, as %s." % form),
                       (48, 54), (24, 52), [0, 1, 0, 1, 0])
    kit.build_boss("morpheus", morpheus, MORPHEUS_PAL, doc(morpheus.__doc__), (44, 56), (21, 54), [0, 1, 0, -1, 0])
    kit.build_boss("phobetor", phobetor("beast"), PHOBETOR_PAL, doc(phobetor.__doc__), (64, 52), (30, 50), [0, 1, 0, -1, 0])
    for form in ("beast", "bird", "serpent"):
        kit.build_boss("phobetor_" + form, phobetor(form), PHOBETOR_PAL, doc(phobetor.__doc__ + " Here, as a %s." % form),
                       (64, 52), (30, 50), [0, 1, 0, -1, 0])
    print("wrote the Heavens' art")
