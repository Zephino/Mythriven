# The Land Between the Rivers' art (Pack 2, docs/PACK_2_PLAN.md; docs/ART_RULES.md): enemies (scorpion-man, ugallu,
# raging storm, river serpent), the bosses (Humbaba, the Bull of Heaven, Tiamat), the gods Enki and Shamash, the Hero
# Gilgamesh and his companion Enkidu. Drawn from the epic and the ancient seals and reliefs, never from modern
# adaptations (Gilgamesh is never Fate/Grand Order's golden-armoured design; Tiamat is never a five-headed dragon).
# Run: python3 build_rivers.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


# --- Scorpion-man (Epic of Gilgamesh, Tablet IX; Assyrian seals) ------------------------------------------------------

def scorpion_man(c, f):
    """A bearded man above, a scorpion below: bird-taloned legs, a segmented tail curling up over his back, a bow."""
    s = STEP[f]
    for k, (x, d) in enumerate(((9, -s), (15, s))):                                    # bird-taloned legs
        c.rect(x + d, 20, x + 1 + d, 26, "t")
        c.row(27, x - 1 + d, x + 2 + d, "T")
    c.rect(9, 12, 16, 20, "s"); c.rect(9, 12, 10, 20, "S")                             # bare chest
    c.row(19, 9, 16, "r"); c.row(20, 9, 16, "R")                                       # belted kilt
    c.rect(10, 4, 15, 10, "s"); c.px(14, 6, "k")
    c.rect(10, 3, 15, 4, "h"); c.rect(9, 1, 14, 2, "h"); c.px(15, 2, "x")             # horned cap
    poly(c, [(10, 8), (15, 8), (14, 13), (11, 13)], "h")                               # square curled beard
    for y in range(9, 14, 2):
        c.row(y, 11, 14, "H")
    # the scorpion's tail: segments rising from the small of his back, over his head, the sting forward
    pts = [(8, 18), (5, 15), (4, 11), (5, 7), (7, 4), (10, 2)]
    for k, (x, y) in enumerate(pts):
        ellipse(c, x, y, 1.6, 1.6, "a" if k % 2 else "A")
    c.px(12, 1, "k"); c.px(11, 2, "A")
    c.rect(17, 12, 18, 16, "s")                                                        # arm and bow
    for y in range(6, 23):
        c.px(20 + round(2 * math.sin((y - 6) / 16 * math.pi)), y, "w")
    c.rect(19, 6, 19, 22, "W")


SCORP_PAL = {"o": "#1a120c", "k": "#0c0806", "s": "#c89870", "S": "#9a7050", "h": "#1e1814", "H": "#3a3028",
             "x": "#d8b048", "r": "#8a3a2a", "R": "#5a2418", "t": "#6a5a3a", "T": "#4a3e28", "a": "#8a6a3a",
             "A": "#5e4826", "w": "#9a6a3a", "W": "#e8dcc0"}


# --- Ugallu (the "big weather-beast"; Enuma Elish I; Neo-Assyrian protective reliefs) ------------------------------

def ugallu(c, f):
    """A lion-headed demon on a man's body, with a lion's ears and mane, a raised dagger and a mace."""
    s = STEP[f]
    for k, (x, d) in enumerate(((8, -s), (13, s))):
        c.rect(x + d, 18, x + 1 + d, 25, "l")
        c.row(26, x - 1 + d, x + 2 + d, "k")                                           # bird's talons
    c.rect(7, 10, 15, 19, "c"); c.rect(7, 10, 8, 19, "C")                              # a short kilt-tunic
    c.row(17, 7, 15, "r")
    ellipse(c, 11, 6, 5, 4.5, "m")                                                     # the mane
    ellipse(c, 13, 6, 3.5, 3, "l"); c.rect(15, 6, 17, 8, "l")                          # lion's face, muzzle
    c.px(14, 5, "k"); c.px(17, 7, "k"); c.row(9, 15, 17, "w")                          # eye, nose, bared teeth
    c.rect(9, 1, 10, 2, "l"); c.rect(13, 1, 14, 2, "l")                                # ears
    c.rect(16, 10, 17, 14, "l")                                                        # arm raised
    for k in range(6):
        c.px(18, 9 - k, "i")                                                           # the dagger
    c.rect(17, 10, 19, 10, "u")


UGALLU_PAL = {"o": "#1a120c", "k": "#0c0806", "l": "#c8a060", "m": "#8a5a2a", "c": "#7a6a8a", "C": "#58486a",
              "r": "#c8a040", "w": "#f0ece0", "i": "#c8ccd4", "u": "#b08a3a"}


# --- Raging storm, umu dabrutu (Enuma Elish I: one of the eleven Tiamat made) -----------------------------------------

def raging_storm(c, f):
    """A whirling storm-beast: a funnel of dust and wind, spinning, with two burning eyes in the cloud."""
    turn = f * 2
    for y in range(2, 25):
        half = 2 + (24 - y) * 0.32 if y < 20 else 1.5
        sway = round(2 * math.sin((y + turn) / 3.0))
        for x in range(int(10 - half) + sway, int(10 + half) + 1 + sway):
            c.px(x, y, "d" if (x + y + turn) % 4 < 2 else "D")
    for k in range(4):
        y = 5 + k * 5
        c.row(y, 6 + k, 14 - k + (turn % 3), "l")
    c.px(8, 7, "y"); c.px(12, 7, "y")


STORM_PAL = {"o": "#2a2018", "d": "#b8a07a", "D": "#8a7452", "l": "#e0d4b8", "y": "#f0a020"}


# --- River serpent (Enuma Elish: Tiamat's serpents) -------------------------------------------------------------------

def river_serpent(c, f):
    """A water snake rearing to strike, its body in loose waves along the ground, scaled in river-green."""
    s = STEP[f]
    for x in range(1, 20):
        y = 11 + round(1.5 * math.sin((x + s * 2) / 2.5))
        c.rect(x, y, x, y + 1, "g" if x % 3 else "G")
    for y in range(4, 12):
        c.rect(19 + (y < 8), y, 20 + (y < 8), y, "g")
    poly(c, [(19, 3), (24, 3), (25, 5), (19, 6)], "g")
    c.px(22, 4, "y"); c.px(25, 6, "r"); c.px(26, 7, "r")                               # eye, forked tongue
    c.row(6, 20, 23, "b")


SERPENT_PAL = {"o": "#0c1a14", "g": "#3a7a5a", "G": "#24563e", "b": "#c8d8a0", "y": "#f0d040", "r": "#c83030"}


# --- Humbaba (Epic of Gilgamesh, Tablets II-V; Old Babylonian clay masks) ---------------------------------------------

def humbaba(c, step):
    """The guardian of the Cedar Forest: a towering ogre whose face is one coiled line, as on the old clay masks, a
    grimacing mouth, lion's claws, wrapped in the seven radiances (drawn in the game as rings)."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 12 + d, 50, 21 + k * 12 + d, 64, "b" if k == 0 else "B")
        for t in range(3):
            c.px(15 + k * 12 + d + t * 3, 65, "w")                                     # claws
    poly(c, [(12, 24), (40, 24), (42, 52), (10, 52)], "b")                             # massive body
    poly(c, [(12, 24), (18, 24), (16, 52), (10, 52)], "B")
    c.rect(10, 44, 42, 46, "r")                                                        # a belt
    for y in range(28, 44, 4):
        c.row(y, 20, 34, "B")                                                          # hide folds
    for side, x in ((-1, 6), (1, 42)):                                                 # arms with lion's paws
        c.rect(x, 26, x + 4, 42, "b")
        for t in range(3):
            c.px(x + t * 2, 43, "w")
    # the head: a broad face made of one coiled line, like the clay masks
    ellipse(c, 26, 13, 12, 11, "f")
    for r in range(2, 11, 3):
        for a in range(0, 360, 8):
            x = 26 + r * math.cos(math.radians(a + r * 30))
            y = 13 + r * 0.9 * math.sin(math.radians(a + r * 30))
            c.px(round(x), round(y), "F")
    c.rect(18, 18, 34, 21, "k"); c.row(19, 19, 33, "w")                                # grimacing mouth, teeth
    c.px(21, 9, "y"); c.px(31, 9, "y")


HUMBABA_PAL = {"o": "#1a120a", "k": "#0c0804", "b": "#7a5a3a", "B": "#5a4028", "f": "#b88a5a", "F": "#7a5432",
               "r": "#5a6a3a", "w": "#efe6d2", "y": "#f0c040"}


# --- The Bull of Heaven (Epic of Gilgamesh, Tablet VI) ---------------------------------------------------------------

def bull_of_heaven(c, step):
    """The great bull Anu gave Ishtar: a vast black bull, its horns of lapis lazuli (Tablet VI: thirty minas of
    lapis each), the snort that opens pits in the earth."""
    ellipse(c, 30, 26, 22, 13, "b")
    ellipse(c, 30, 31, 18, 7, "B")
    c.rect(18, 14, 34, 16, "b")                                                        # the great hump of the shoulders
    for k, d in enumerate((-step, step, step, -step)):
        x = 14 + k * 10 + d
        c.rect(x, 36, x + 3, 47, "B" if k % 2 == 0 else "b")
        c.rect(x, 47, x + 3, 48, "k")                                                  # hooves
    poly(c, [(48, 16), (60, 20), (62, 30), (50, 32)], "b")                             # lowered head
    c.rect(58, 26, 62, 30, "B"); c.px(61, 27, "k"); c.px(54, 21, "r")                  # muzzle, eye red with rage
    poly(c, [(50, 16), (46, 8), (44, 2), (48, 6), (52, 14)], "j")                      # lapis horns, curving up
    poly(c, [(56, 17), (60, 9), (64, 4), (62, 10), (58, 18)], "j")
    c.px(45, 3, "J"); c.px(63, 5, "J")
    c.rect(7, 22, 9, 34, "B"); c.rect(6, 34, 9, 36, "k")                               # tail
    for k in range(5):
        c.px(30 + k * 4, 13, "u")                                                      # gold bands on the hump


BULL_PAL = {"o": "#0c0a10", "k": "#06050a", "b": "#2e2a34", "B": "#1c1a22", "j": "#2a4aa8", "J": "#6a8ae0",
            "r": "#d03020", "u": "#d8b048"}


# --- Tiamat (Enuma Elish; an original design, not the five-headed dragon of modern games) -----------------------------

def tiamat(c, step):
    """Tiamat, the salt sea, mother of the eleven monsters: an original design of a vast sea-serpent of dark salt
    water rising in coils, foam along her back, a long tail (Tablet V: Marduk bent it into the sky) and two great
    eyes (Tablet V: from them he made the Tigris and Euphrates flow)."""
    for k in range(3):                                                                 # coils resting on the ground
        ellipse(c, 14 + k * 20, 52, 11, 6, "b" if k % 2 else "B")
        c.row(47, 6 + k * 20, 22 + k * 20, "f")
    for y in range(10, 50):                                                            # the rising neck
        x = 38 + round(5 * math.sin(y / 7.0 + step * 0.3))
        c.rect(x - 5, y, x + 5, y, "b")
        c.px(x - 5, y, "B")
        if y % 3 == 0:
            c.px(x + 6, y, "f")                                                        # foam on her back
    poly(c, [(30, 4), (52, 2), (58, 10), (34, 14)], "b")                               # long head
    c.rect(48, 9, 58, 12, "B"); c.row(10, 50, 57, "w")                                 # jaw, teeth
    ellipse(c, 40, 6, 2.5, 2, "e"); ellipse(c, 46, 5, 2.5, 2, "e")                     # two great eyes
    c.px(40, 6, "k"); c.px(46, 5, "k")
    for k in range(5):
        c.px(31 + k * 4, 2 - (k % 2), "f")                                             # a crest of spray
    c.rect(66, 44, 70, 52, "b"); c.rect(68, 38, 70, 44, "B"); c.px(70, 37, "f")       # the tail lifting


TIAMAT_PAL = {"o": "#06100e", "k": "#020606", "b": "#1e4a4a", "B": "#123232", "f": "#c8e8e4", "w": "#efe6d2",
              "e": "#e0f060"}


# --- Enki and Shamash (the Adda seal, c. 2300 BC; the Shamash tablet of Nabu-apla-iddina) ----------------------------

GOD_SIZE, GOD_ANCHOR = (48, 62), (22, 60)
STANCE = (18, 23)
GOD_WALK = [STANCE, (16, 25), STANCE, (20, 21), STANCE]
SEATED = {"style": "mesopotamian", "hip": 40, "lap": "b", "shin": "b", "foot": "n", "keep": range(36, 48)}

ENKI_DOC = ("Enki (Ea), god (docs/PACK_2_PLAN.md: the Land Between the Rivers). From the Adda seal (c. 2300 BC): a "
            "bearded god in a horned crown and a flounced robe, streams of fresh water with fish flowing from his "
            "shoulders, the waters of the Abzu. Built by tools/art/build_rivers.py.")
SHAMASH_DOC = ("Shamash (Utu), god (docs/PACK_2_PLAN.md: the Land Between the Rivers). From the Adda seal and the "
               "Shamash tablet: the sun god in a horned crown and a flounced robe, rays rising from his shoulders, his "
               "saw-toothed blade in his hand. Built by tools/art/build_rivers.py.")
ENKI_PAL = {"o": "#14100c", "k": "#0a0806", "s": "#c89870", "S": "#9a7050", "h": "#1e1814", "b": "#e8e0cc",
            "B": "#b8ae98", "u": "#d8b048", "w": "#5aa0e0", "W": "#c8e8f8", "f": "#e0e8f0", "n": "#6a4a2a"}
SHAMASH_PAL = {"o": "#14100c", "k": "#0a0806", "s": "#c89870", "S": "#9a7050", "h": "#1e1814", "b": "#e8d8a8",
               "B": "#b8a070", "u": "#d8b048", "y": "#f8d860", "Y": "#f0a030", "i": "#c8ccd4", "n": "#6a4a2a"}


def flounced_robe(c, main, fold):
    """The tiered, flounced robe of the gods on the seals: rows of flounces from shoulder to ankle."""
    for y in range(20, 57):
        x0, x1 = (16, 27) if y < 44 else (15 - (y - 44) // 6, 28 + (y - 44) // 6)
        c.row(y, x0, x1, main)
        if (y - 20) % 4 == 3:
            for x in range(x0, x1 + 1, 2):
                c.px(x, y, fold)
    for x0 in STANCE:
        c.rect(x0, 57, x0 + 4, 58, "s"); c.row(58, x0, x0 + 4, "n")


def god_head(c):
    c.rect(18, 9, 25, 16, "s"); c.rect(18, 9, 19, 16, "S"); c.px(23, 12, "k")
    poly(c, [(17, 14), (26, 14), (25, 22), (18, 22)], "h")                             # long square beard
    for y in range(16, 22, 2):
        c.row(y, 19, 24, "o")
    c.rect(15, 9, 17, 22, "h")                                                         # hair gathered behind
    c.rect(17, 3, 26, 8, "u")                                                          # the horned crown: tiers
    for y in (4, 6):
        c.row(y, 17, 26, "o")
    c.px(16, 4, "u"); c.px(15, 3, "u"); c.px(27, 4, "u"); c.px(28, 3, "u")             # horns curving out


def enki(c, legs):
    flounced_robe(c, "b", "B")
    god_head(c)
    c.rect(26, 22, 28, 28, "s")
    for k in range(14):                                                                # two streams from the shoulders
        c.px(28 + k, 21 + k * 2 // 3, "w"); c.px(29 + k, 21 + k * 2 // 3, "W")
        c.px(14 - k // 2, 21 + k, "w"); c.px(13 - k // 2, 21 + k, "W")
    c.rect(34, 25, 36, 26, "f"); c.px(37, 25, "f")                                     # fish swimming up them
    c.rect(9, 30, 11, 31, "f"); c.px(8, 30, "f")


def shamash(c, legs):
    flounced_robe(c, "b", "B")
    god_head(c)
    for sx, side in ((16, -1), (27, 1)):                                               # rays rising from his shoulders
        for a in (-0.5, 0.0, 0.5):
            ang = math.pi * (0.5 + side * 0.25) + a * side
            for t in range(2, 9):
                c.px(sx - round(math.cos(ang) * t),
                     21 - round(math.sin(ang) * t), "y" if t % 2 else "Y")
    c.rect(26, 22, 28, 28, "s")
    c.rect(29, 18, 31, 32, "i")                                                        # the saw-toothed blade
    for y in range(18, 32, 2):
        c.px(32, y, "i")
    c.rect(29, 28, 31, 30, "u")


# --- Gilgamesh and Enkidu (the Standard Babylonian epic; the hero on the Assyrian reliefs) ---------------------------

GIL_DOC = ("Gilgamesh (docs/PACK_2_PLAN.md: the Land Between the Rivers' Hero; art 10/31/2026). Built by "
           "tools/art/build_rivers.py on the shared body in tools/art/hero_kit.py. Drawn from the epic and the ancient "
           "reliefs, never from modern adaptations (never Fate/Grand Order's golden-armoured design): long hair and "
           "beard in rows of curls, a gold fillet, a short-sleeved tunic over a fringed kilt with a red border, "
           "sandals; he carries his great axe (Tablet II-III).")
GIL_PAL = {"o": "#1e140c", "k": "#0e0a06", "s": "#c89870", "S": "#9a7050", "h": "#1a1410", "H": "#3a2e24",
           "u": "#d8b048", "b": "#e6dcc4", "B": "#b8ac90", "r": "#8a2a20", "n": "#6a4a2a"}


def gilgamesh(c, back_leg, front_leg):
    kit.far_arm(c)
    c.rect(9, 3, 16, 12, "h")                                                          # hair falling to the shoulders
    for y in range(5, 13, 2):
        c.px(9, y, "H"); c.px(10, y + 1, "H")                                          # its curls
    c.rect(11, 5, 16, 11, "s"); c.px(11, 6, "S"); c.px(15, 7, "k"); c.px(17, 8, "s")
    c.row(4, 10, 16, "u")                                                              # the gold fillet
    c.rect(11, 10, 16, 15, "h")                                                        # square beard, rows of curls
    for y in (11, 13, 15):
        c.row(y, 12, 16, "H")
    for y in range(14, 25):
        c.row(y, 9, 18, "b")
    c.rect(9, 14, 10, 24, "B")
    c.row(20, 9, 18, "u")                                                              # belt
    for x in range(9, 19, 2):
        c.px(x, 25, "r")                                                               # fringed, red-bordered hem
    c.row(24, 9, 18, "r")
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, lambda c, x0: (c.row(31, x0, x0 + 3, "n"), c.px(x0 + 1, 30, "n")))


ENKIDU_DOC = ("Enkidu, Gilgamesh's companion (docs/PACK_2_PLAN.md: Gilgamesh's Legend Trait). Epic of Gilgamesh, "
              "Tablet I: made from clay in the wilderness, his whole body shaggy with hair, the locks of his head long "
              "like a woman's; he fought beside Gilgamesh against Humbaba and the Bull of Heaven. A shaggy wild man in "
              "a hide kilt with an axe. Built by tools/art/build_rivers.py.")
ENKIDU_PAL = {"o": "#1e140c", "k": "#0e0a06", "s": "#b88a62", "S": "#8a6444", "h": "#5a3a22", "H": "#3a2412",
              "b": "#8a6a44", "B": "#5e4628", "i": "#c8a050"}


def enkidu(c, f):
    s = [0, -1, 0, 1, 0][f]
    for x, d in ((9, -s), (13, s)):
        c.rect(x + d, 24, x + 2 + d, 31, "s"); c.px(x + d, 26, "H"); c.px(x + 1 + d, 28, "H")   # hairy legs
    c.rect(8, 12, 16, 21, "s"); c.rect(8, 12, 9, 21, "S")
    for y in range(13, 21, 2):
        c.px(11 + (y % 4), y, "H"); c.px(14 - (y % 3), y + 1, "H")                     # shaggy hair on his body
    c.rect(8, 21, 16, 24, "b"); c.row(24, 8, 16, "B")                                  # hide kilt
    c.rect(7, 2, 16, 13, "h")                                                          # long locks
    c.rect(10, 4, 15, 10, "s"); c.px(14, 6, "k")
    c.rect(10, 9, 15, 12, "H")                                                         # beard
    c.rect(17, 13, 18, 18, "s")
    for k in range(12):
        c.px(19, 18 - k, "b")                                                          # an axe raised
    poly(c, [(19, 6), (23, 4), (23, 10), (20, 9)], "i")


if __name__ == "__main__":
    def doc(text):
        return text + " Built by tools/art/build_rivers.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("scorpion_man", scorpion_man, SCORP_PAL, doc("Scorpion-man (docs/PACK_2_PLAN.md: the Land Between "
                   "the Rivers). Epic of Gilgamesh, Tablet IX (the scorpion-people who guard the gate of Mount Mashu) and "
                   "the Assyrian seals: a bearded man above, bird's talons and a scorpion's tail below, a bow in hand."),
                   (24, 30), (12, 28), walk, folder="enemies")
    kit.build_boss("ugallu", ugallu, UGALLU_PAL, doc("Ugallu (docs/PACK_2_PLAN.md: the Land Between the Rivers). Enuma "
                   "Elish I (the ugallu among Tiamat's eleven) and the Neo-Assyrian protective reliefs: a lion-headed "
                   "demon on a man's body with bird's feet, a dagger raised."), (22, 28), (11, 27), walk, folder="enemies")
    kit.build_boss("raging_storm", raging_storm, STORM_PAL, doc("Raging storm, umu dabrutu (docs/PACK_2_PLAN.md: the "
                   "Land Between the Rivers). Enuma Elish I (one of the eleven Tiamat made): a whirling storm-beast of "
                   "dust and wind with burning eyes."), (20, 26), (10, 25), walk, folder="enemies")
    kit.build_boss("river_serpent", river_serpent, SERPENT_PAL, doc("River serpent (docs/PACK_2_PLAN.md: the Land "
                   "Between the Rivers). Enuma Elish (Tiamat's serpents): a green water snake rearing to strike."),
                   (28, 16), (12, 14), walk, folder="enemies")
    kit.build_boss("humbaba", humbaba, HUMBABA_PAL, doc("Humbaba, boss (docs/PACK_2_PLAN.md: the Land Between the "
                   "Rivers). Epic of Gilgamesh, Tablets II-V, and the Old Babylonian clay masks whose face is one coiled "
                   "line: the guardian of the Cedar Forest, wrapped in seven radiances."), (52, 68), (26, 66), [0, 1, 0, -1, 0])
    kit.build_boss("bull_of_heaven", bull_of_heaven, BULL_PAL, doc("The Bull of Heaven, boss (docs/PACK_2_PLAN.md: the "
                   "Land Between the Rivers). Epic of Gilgamesh, Tablet VI: the great bull Anu gave Ishtar, its snort "
                   "opening pits in the earth, its horns of lapis lazuli."), (68, 50), (32, 48), [0, 1, 0, -1, 0])
    kit.build_boss("tiamat", tiamat, TIAMAT_PAL, doc("Tiamat, boss (docs/PACK_2_PLAN.md: the Land Between the Rivers). "
                   "Enuma Elish. An original design, not the five-headed dragon of modern games: the salt sea as a vast "
                   "sea-serpent rising from her coils, her long tail, her two great eyes."), (72, 60), (36, 58),
                   [0, 1, 0, -1, 0])
    kit.build_boss("enki", enki, ENKI_PAL, ENKI_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    kit.build_boss("shamash", shamash, SHAMASH_PAL, SHAMASH_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    kit.build("gilgamesh", gilgamesh, GIL_PAL, GIL_DOC, recolor=["b", "B"])
    kit.build_boss("enkidu", enkidu, ENKIDU_PAL, ENKIDU_DOC, (24, 34), (12, 32), walk, folder="companions")
    print("wrote the Land Between the Rivers' art")
