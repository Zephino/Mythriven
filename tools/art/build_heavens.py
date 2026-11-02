# The Heavens' art (Pack 10, docs/PACK_10_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Herodotus, Pindar, Aratus, Ptolemy, Hyginus, Ovid, Apollodorus, Homer; the Grimms; Andersen, 1844), never later
# versions.
# Run: python3 build_heavens.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly
from figure_kit import person
from build_gothic import rim, raven as gothic_raven, wolf as gothic_wolf, WOLF_WALK
from build_avalon import hound

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
    """An Arimaspian (Herodotus 4.27: "one-eyed men" of the far north who steal gold from the griffins): a raider in a
    fur hood and a fur coat belted with a pouch of stolen gold, a single great eye in the middle of his face, and an axe."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 21, "F"); c.rect(x + d, 22, x + 2 + d, 23, "k")      # fur boots
    poly(c, [(5, 9), (13, 9), (14, 19), (4, 19)], "f"); poly(c, [(5, 9), (7, 9), (6, 19), (4, 19)], "F")
    c.row(19, 4, 14, "W"); c.row(18, 4, 14, "W")                                         # white fur hem
    c.row(14, 5, 13, "b"); ellipse(c, 12, 15, 1.5, 1.5, "y"); c.px(12, 15, "Y")          # belt, pouch of gold
    c.rect(3, 10, 4, 14, "F"); c.px(3, 15, "s")                                          # far arm
    ellipse(c, 9, 5, 3.4, 3.4, "W"); ellipse(c, 9, 5, 2.6, 2.8, "s")                     # fur hood round the face
    ellipse(c, 9, 4, 1.6, 1.4, "w"); c.px(9, 4, "k"); c.px(10, 4, "e"); c.row(2, 8, 10, "S")   # the single great eye
    c.row(7, 8, 10, "h"); c.px(9, 8, "h")                                                # beard
    poly(c, [(6, 2), (12, 2), (11, 0), (7, 0)], "W")
    c.rect(15, 3, 15, 17, "b"); c.px(15, 18, "b")                                        # axe haft
    poly(c, [(16, 3), (19, 1), (19, 7), (16, 6)], "i"); c.px(19, 1, "I"); c.px(19, 7, "I")
    c.px(14, 12, "s")                                                                    # hand


ARIMASPIAN_PAL = {"o": "#0e0a08", "k": "#1e1814", "f": "#8a6a48", "F": "#6a4e34", "W": "#e8e0d0", "s": "#d0a080",
                  "S": "#a07a5a", "w": "#f0ece4", "e": "#4a8ac8", "h": "#4a3020", "b": "#5a3a1a", "i": "#b0b6be",
                  "I": "#7a8088", "y": "#e8c040", "Y": "#fff0a0"}


def young_griffin(c, f):
    """A young griffin (Herodotus 3.116, 4.13: the griffins that guard the gold): a small beast with an eagle's white
    head and hooked golden beak and a lion's tawny body and tufted tail, flying on golden wings."""
    up = f % 2
    poly(c, [(8, 7), (11, 7), (5, 0 if up else 13), (2, 1 if up else 12)], "Y")          # far wing
    ellipse(c, 9, 9, 5, 2.6, "t"); c.row(11, 6, 12, "T")                                 # lion body
    c.px(5, 11, "T"); c.px(4, 12, "T"); c.px(12, 11, "T"); c.px(13, 12, "T")            # tucked legs
    for k in range(4):
        c.px(4 - k, 8 - k // 2, "t")                                                     # tail
    c.px(0, 6, "T"); c.px(1, 6, "T")                                                     # its tuft
    ellipse(c, 15, 6, 2.6, 2.4, "w"); c.px(13, 5, "W")                                   # eagle head
    c.px(16, 5, "k")
    c.px(17, 6, "y"); c.px(18, 7, "y"); c.px(17, 7, "Y")                                 # hooked beak
    poly(c, [(9, 7), (12, 7), (14, 0 if up else 14), (10, 1 if up else 13)], "y")        # near wing
    for k in range(3):
        c.px(10 + k, (2 if up else 12) + (k if up else -k), "Y")                         # feather lines


YOUNG_GRIFFIN_PAL = {"o": "#2a1a08", "y": "#e8c040", "Y": "#b89028", "t": "#c8944a", "T": "#9a6a32", "w": "#f4f0e8",
                     "W": "#c8c0b0", "k": "#1a1008"}


def feather_flurry(c, f):
    """A flurry of the north's "feathers" (Herodotus 4.31: the air beyond the north wind is full of feathers, which he
    took to be snow): white feathers and flakes tumbling round in the wind."""
    for k in range(3):
        a = k / 3 * math.tau + f * 0.5
        x, y = 7 + 4 * math.cos(a), 6 + 3.6 * math.sin(a)
        dx, dy = round(math.cos(a + 1.6)), round(math.sin(a + 1.6))
        for t in (-1, 0, 1):
            c.px(round(x) + dx * t, round(y) + dy * t, "w")                               # a little feather
        c.px(round(x) + dx * 2, round(y) + dy * 2, "W")                                  # its quill
        c.px(round(x) - dy, round(y) + dx, "W")
    for k in range(3):
        a = k / 3 * math.tau + 1 - f * 0.3
        c.px(7 + round(2 * math.cos(a)), 6 + round(2 * math.sin(a)), "b")                # flakes


FLURRY_PAL = {"o": "#6a7888", "w": "#ffffff", "W": "#c8d8e8", "b": "#e0ecf8"}


def arimaspian_chieftain(c, step):
    """The Arimaspian Chieftain (Herodotus 4.27): a great one-eyed raider of the north in a fur hood and a cloak of
    furs, his single great eye glaring, hung with the gold he has stolen from the griffins (a torc at his neck, rings
    on his arm, a sack bulging with it), and a broad axe."""
    poly(c, [(4, 18), (12, 16), (14, 30), (6, 32)], "b"); c.px(7, 19, "y"); c.px(9, 23, "y"); c.px(6, 26, "Y")   # sack of gold
    person(c, step, cx=20, skin="s", skin_d="S", hair="W", hair_d="V", hair_style="short", beard="h",
           garment="tunic", robe="f", robe_d="F", legs="F", boots="k", belt="b", cloak=("F", "k"), arm_forward=True)
    for x in (18, 22):
        c.px(x, 10, "s"); c.px(x, 9, "s")                                                # paint out the two eyes
    ellipse(c, 20, 9, 2, 1.6, "w"); c.px(20, 9, "k"); c.px(21, 9, "e"); c.row(7, 18, 22, "h")   # the single great eye
    ellipse(c, 20, 5, 6, 3.5, "W"); c.rect(14, 5, 15, 12, "W"); c.rect(25, 5, 26, 12, "W")   # fur hood
    for x in range(15, 26, 3):
        c.px(x, 4, "V")
    poly(c, [(13, 17), (27, 17), (25, 20), (15, 20)], "W"); c.row(18, 15, 25, "V")       # fur collar
    c.row(16, 16, 24, "y"); c.px(16, 17, "Y"); c.px(24, 17, "Y")                         # gold torc
    c.row(28, 15, 25, "b"); ellipse(c, 20, 28, 1.6, 1.4, "y")                            # belt and buckle
    c.row(42, 13, 27, "W")                                                               # fur hem
    c.px(29, 21, "y"); c.px(30, 22, "y"); c.px(31, 21, "y")                              # gold arm rings
    c.rect(35, 2, 36, 44, "b")                                                           # the axe
    poly(c, [(37, 4), (41, 0), (41, 14), (37, 11)], "i"); c.rect(41, 0, 41, 14, "I"); c.row(7, 37, 40, "I")


CHIEFTAIN_PAL = {"o": "#0e0a08", "k": "#2a1e16", "f": "#8a6a48", "F": "#6a4e34", "W": "#e8e0d0", "V": "#b8b0a0",
                 "s": "#d0a080", "S": "#a07a5a", "w": "#f0ece4", "e": "#4a8ac8", "h": "#4a3020", "H": "#2a1a10",
                 "m": "#7a4a3a", "b": "#5a3a1a", "i": "#b0b6be", "I": "#7a8088", "y": "#e8c040", "Y": "#fff0a0",
                 "l": "#6a4e34"}


def six_month_sleeper(c, step):
    """The Six-Month Sleeper (Herodotus 4.25: men of the far north who, it was said, sleep for six months of the year):
    a huge, stooping old northerner wrapped in a great shaggy bearskin, frost on his shoulders and snow in his long
    white hair and beard, his eyes heavy with sleep and his mouth wide in a yawn, leaning on a staff."""
    poly(c, [(7, 14), (31, 14), (36, 52), (2, 52)], "F")                                 # the shaggy bearskin
    poly(c, [(9, 14), (29, 14), (32, 50), (6, 50)], "f")
    for y in range(18, 50, 4):
        for x in range(6 + (y // 4) % 2 * 2, 33, 4):
            c.px(x, y, "F"); c.px(x + 1, y + 1, "F")                                     # shaggy fur
    for k, d in enumerate((-step, step)):
        c.rect(13 + k * 9 + d, 50, 18 + k * 9 + d, 54, "k")                              # fur boots
    ellipse(c, 19, 15, 12, 4, "w"); c.px(10, 14, "W"); c.px(26, 15, "W")                 # frost on his shoulders
    ellipse(c, 19, 9, 6, 6.5, "s"); c.px(14, 10, "S")                                    # head, stooping forward
    ellipse(c, 19, 4, 7, 4, "w"); c.rect(12, 4, 13, 18, "w"); c.rect(25, 4, 26, 16, "w")   # long white hair
    c.row(9, 16, 18, "S"); c.row(9, 21, 23, "S"); c.row(10, 16, 18, "k"); c.row(10, 21, 23, "k")   # heavy-lidded eyes
    c.px(19, 11, "S")
    poly(c, [(14, 13), (24, 13), (23, 26), (19, 30), (15, 26)], "w")                     # long beard
    for x, y in ((16, 17), (18, 22), (21, 19), (22, 24)):
        c.px(x, y, "W")
    ellipse(c, 19, 15, 2.2, 1.6, "m"); c.px(19, 15, "k")                                 # a wide yawn
    c.rect(36, 6, 37, 54, "b"); c.px(36, 5, "B")                                         # staff
    ellipse(c, 34, 27, 2.5, 2.5, "f"); ellipse(c, 36, 26, 1.8, 1.8, "s")                 # hand on it
    for x, y in ((8, 24), (30, 30), (12, 40), (27, 44), (4, 48)):
        c.px(x, y, "w")                                                                  # snow caught in the fur


SLEEPER_PAL = {"o": "#0e0a08", "k": "#1e1814", "f": "#8a7058", "F": "#5e4a38", "s": "#e0c0a0", "S": "#b89878",
               "w": "#f4f4f8", "W": "#c0c8d4", "m": "#5a2a20", "b": "#6a4a2a", "B": "#8a6a44"}


def griffin_matriarch(c, step):
    """The Griffin Matriarch (Herodotus 4.13; the gold-guarding griffins): a great griffin with a lion's sleek tawny body,
    haunches and tufted tail, an eagle's taloned forelegs feathered to the knee, a long feathered neck and a fierce
    white eagle's head with pointed ears and a hooked golden beak, and great golden wings raised up and swept back,
    her feathers flecked with gold."""
    def feather(x, y, dx, dy, length, col, shade):
        n = math.hypot(dx, dy)
        dx, dy = dx / n, dy / n
        for t in range(int(length)):
            px, py = round(x + dx * t), round(y + dy * t)
            c.px(px, py, col); c.px(px + 1, py, shade if t > 1 else col)
        c.px(round(x + dx * length), round(y + dy * length), shade)

    def wing(sh, wr, tip, col, shade, light):
        poly(c, [sh, wr, tip, (tip[0] - 14, tip[1] + 10), (sh[0] - 14, sh[1] - 2)], col)
        for k in range(7):                                                               # primaries, fanning back
            t = k / 6
            x, y = wr[0] + (tip[0] - wr[0]) * t, wr[1] + (tip[1] - wr[1]) * t
            feather(x, y, -1, 0.9 - t * 0.6, 12 + t * 6, col, shade)
        for k in range(5):                                                               # secondaries
            t = k / 5
            x, y = sh[0] + (wr[0] - sh[0]) * t, sh[1] + (wr[1] - sh[1]) * t
            feather(x, y, -1, 0.5, 11, col, shade)
        for t in range(10):                                                              # the leading edge
            x = sh[0] + (wr[0] - sh[0]) * t / 9; y = sh[1] + (wr[1] - sh[1]) * t / 9
            ellipse(c, x, y, 1.8, 1.8, col); c.px(round(x) + 1, round(y), light)
        for t in range(10):
            x = wr[0] + (tip[0] - wr[0]) * t / 9; y = wr[1] + (tip[1] - wr[1]) * t / 9
            c.px(round(x), round(y), light); c.px(round(x) + 1, round(y), col)

    def talons(x, y, col):
        c.px(x - 2, y, col); c.px(x - 3, y + 1, "k")                                     # back toe
        for dx in (1, 3, 5):
            c.px(x + dx - 1, y, col); c.px(x + dx, y + 1, "k")                           # three toes forward, black claws

    wing((36, 24), (35, 11 - step), (29, 4 - step), "Y", "T", "y")                        # far wing
    poly(c, [(15 + step, 36), (20 + step, 36), (19 + step, 44), (16 + step, 49), (12 + step, 49), (14 + step, 44)], "T")   # far hind leg
    c.rect(41 - step, 38, 43 - step, 48, "Y"); talons(42 - step, 49, "Y")               # far foreleg
    for i in range(20):                                                                  # the lion's tail
        t = i / 19
        ellipse(c, 8 - t * 6, 30 - t * 10 + t * t * 14, 1.3, 1.3, "t")
    ellipse(c, 2, 34, 2.4, 2.8, "T"); c.px(1, 36, "k")                                   # its tuft
    ellipse(c, 13, 33, 8, 8, "t")                                                        # haunch
    ellipse(c, 25, 33, 12, 6, "t")                                                       # barrel, belly tucked
    ellipse(c, 36, 32, 8, 8, "t")                                                        # deep chest
    poly(c, [(14, 38), (36, 37), (34, 40), (16, 40)], "T")                               # belly shadow
    ellipse(c, 24, 28, 12, 2.5, "u")                                                     # light along the back
    poly(c, [(9, 32), (18, 32), (18, 40), (14, 46), (17, 49), (10, 50), (8, 46), (11, 41)], "t")   # near hind leg
    c.px(10, 38, "T"); c.px(15, 44, "T"); ellipse(c, 13, 49.5, 3.5, 1.2, "T")           # hock, paw
    wing((34, 26), (31, 12 + step), (23, 5 + step), "y", "Y", "u")                       # near wing
    poly(c, [(33, 30), (40, 22), (44, 12), (50, 12), (50, 20), (46, 30), (42, 38), (34, 38)], "w")   # feathered neck
    for x, y in ((40, 26), (43, 21), (45, 16), (38, 32), (42, 30), (46, 24)):
        c.px(x, y, "W"); c.px(x + 1, y + 1, "W")                                         # feather scallops
    poly(c, [(36, 36), (42, 36), (41, 42), (37, 42)], "w")                               # feathered upper foreleg
    c.px(38, 40, "W"); c.px(40, 39, "W")
    c.rect(38 + step, 42, 40 + step, 48, "y"); talons(39 + step, 49, "y")               # scaly lower leg, talons
    c.px(39 + step, 44, "Y"); c.px(39 + step, 46, "Y")
    poly(c, [(45, 8), (46, 3), (48, 8)], "w"); poly(c, [(48, 7), (50, 2), (51, 8)], "W")   # pointed ears
    ellipse(c, 50, 13, 5.5, 4.8, "w"); c.px(46, 15, "W"); c.px(47, 16, "W")             # eagle head
    c.row(10, 49, 54, "W"); c.px(53, 11, "W")                                            # fierce brow
    c.px(52, 12, "k"); c.px(51, 12, "y")                                                 # eye
    poly(c, [(54, 11), (58, 12), (61, 15), (60, 19), (58, 17), (54, 17)], "y")           # hooked golden beak
    c.px(60, 19, "Y"); c.px(59, 18, "Y"); c.row(16, 55, 58, "Y"); c.px(55, 12, "Y")      # its hook and gape
    for x, y in ((20, 30), (28, 31), (24, 35), (32, 30), (11, 31)):
        c.px(x, y, "y")                                                                  # gold flecks


MATRIARCH_PAL = {"o": "#2a1a08", "y": "#e8c040", "Y": "#b89028", "t": "#c8944a", "T": "#9a6a32", "u": "#dcae6a",
                 "w": "#f4f0e8", "W": "#c8c0b0", "k": "#1a1008"}


# --- The Empyrean (Aratus, Phaenomena; Ptolemy, Almagest; Hyginus 2.21-36; Ovid, Met. 2, Fasti 5; Apollodorus 1.4) ----

def star_hound(c, f):
    """A star hound (Aratus; Hyginus 2.35-36: Orion's dogs set among the stars): a lean hound of the night sky, deep
    blue edged with starlight, with bright stars at its eye, shoulder and haunch."""
    hound(c, f, "d", "D")
    rim(c, "dD", "b")
    for x, y in ((6, 8), (13, 8), (17, 7), (4, 13), (12, 14)):
        c.px(x, y, "w")
    c.px(19, 5, "y")                                                                     # its eye, the brightest star


STAR_HOUND_PAL = {"o": "#0a0c1a", "k": "#0a0c1a", "d": "#2a3470", "D": "#1c2454", "b": "#6a8ae0", "w": "#f0f4ff",
                  "y": "#fff4a0"}


def star_mote(c, f):
    """A star mote (Aratus: the countless lesser stars no one has named): a small bright star with a soft glow,
    twinkling."""
    for d in range(-2, 3):
        c.px(5 + d, 5, "y"); c.px(5, 5 + d, "y")
    c.px(4, 4, "g"); c.px(6, 6, "g"); c.px(4, 6, "g"); c.px(6, 4, "g")
    c.px(5, 5, "w"); c.px(5, 4, "w"); c.px(5, 6, "w"); c.px(4, 5, "w"); c.px(6, 5, "w")
    if f % 2:
        c.px(5, 0, "y"); c.px(5, 10, "y"); c.px(0, 5, "y"); c.px(10, 5, "y")             # the twinkle


STAR_MOTE_PAL = {"o": "#1a1a30", "w": "#ffffff", "y": "#f0e080", "g": "#a08a40"}


def comet(c, f):
    """A comet (Aristotle, Meteorologica 1.6-7: the "hairy stars"): a blazing head trailing long streaming hair of
    light, white near the head, then gold, then blue."""
    for strand, (dy, n) in enumerate(((-2, 10), (0, 15), (2, 11), (-1, 13), (1, 12))):
        for k in range(n):
            x = 14 - k
            y = 6 + dy * k / 10 + math.sin(k * 0.6 + f + strand) * 0.6
            c.px(x, round(y), "w" if k < 3 else ("y" if k < 8 else "b"))
    ellipse(c, 16, 6, 3, 3, "y"); ellipse(c, 16, 6, 2, 2, "w")
    c.px(19, 6, "Y"); c.px(16, 3, "Y"); c.px(16, 9, "Y")


COMET_PAL = {"o": "#1a1a30", "w": "#ffffff", "y": "#f0d080", "Y": "#fff8d0", "b": "#7a98e0"}


def scorpion(c, step):
    """The Scorpion (Hyginus 2.26; Ovid, Fasti 5.537-544): the great scorpion Earth sent to kill Orion, set among the
    stars: a scorpion of the night sky edged with starlight, seen from the side, its segmented body low to the ground on
    eight legs, its great pincers reaching forward, and its jointed tail curled high over its back with the sting
    glowing red; Antares burns red at its heart."""
    def claw(x0, y0, col, light):
        """A scorpion's claw facing forward, its two fingers open."""
        for dy, row in enumerate(("......xxxx.", "..xxxxxxxxx", ".xxxxxx....", "xxxxxx.....", ".xxxxxx....",
                                  "..xxxxxxxx.", "......xxx..")):
            for dx, ch in enumerate(row):
                if ch == "x":
                    c.px(x0 + dx, y0 + dy, col)
        c.row(y0 + 2, x0 + 2, x0 + 4, light)

    def line(pts, r, col):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            for t in range(9):
                ellipse(c, ax + (bx - ax) * t / 8, ay + (by - ay) * t / 8, r, r, col)
    for k in range(4):                                                                   # far legs
        x = 20 + k * 5 + 2
        lift = step if k % 2 else -step
        line([(x, 35), (x - 2, 37), (x - 4 + lift, 43)], 0.7, "D")
    line([(39, 31), (42, 27), (45, 26)], 0.9, "D")                                       # far arm
    claw(45, 22, "D", "D")                                                               # far claw, raised
    for k, (x, y, r) in enumerate(((11, 29, 3.0), (8, 23, 2.8), (9, 17, 2.7), (13, 12, 2.5), (19, 9, 2.3))):
        ellipse(c, x, y, r, r, "d"); c.px(round(x - r + 1), y, "D")                      # tail segments, curling up
        if k:
            c.px(x, round(y + r), "D")                                                   # joints
    ellipse(c, 24, 9, 2.6, 2.2, "d")                                                     # the bulb of the sting
    c.px(27, 10, "r"); c.px(28, 11, "r"); c.px(28, 12, "R"); c.px(27, 13, "R")          # the sting, hooked down
    for k in range(6):                                                                   # segmented body
        ellipse(c, 15 + k * 4, 33 - (1 if 1 <= k <= 4 else 0), 3, 4.4, "d")
    for k in range(1, 6):
        c.rect(13 + k * 4, 30, 13 + k * 4, 36, "D")
    c.row(37, 13, 36, "D")
    poly(c, [(34, 29), (40, 29), (43, 31), (43, 36), (34, 37)], "d")                     # head, a rounded shield
    c.row(29, 35, 39, "l"); c.px(41, 30, "w"); c.px(39, 30, "w")                         # eyes on top
    for k in range(4):                                                                   # near legs
        x = 18 + k * 5
        lift = -step if k % 2 else step
        line([(x, 36), (x - 2, 38), (x - 4 + lift, 44)], 0.8, "d")
    line([(42, 34), (44, 37), (46, 34)], 1.0, "d")                                       # near arm, bent forward
    claw(46, 30, "d", "l")                                                               # near claw, open
    rim(c, "dl", "b")
    for x, y in ((15, 32), (31, 31), (11, 23), (13, 12), (37, 33), (49, 33)):
        c.px(x, y, "w")                                                                  # its stars
    ellipse(c, 23, 32, 1.2, 1.2, "R"); c.px(23, 32, "r")                                 # Antares, red at its heart


SCORPION_PAL = {"o": "#0a0c1a", "l": "#5a4a8a", "d": "#3a2a5a", "D": "#261c40", "b": "#9a7ae0", "r": "#ff5a6a", "R": "#c02a4a",
                "w": "#f0f4ff"}


def great_bear(c, step):
    """The Great Bear (Ovid, Metamorphoses 2.401-530; Aratus 26-62): Callisto, turned into a bear and set among the
    stars, where she turns round the pole and never sinks into the sea: a great shaggy bear of night-blue edged with
    starlight, with a broad, level back, a broad head carried low with a long snout and ears at the back, thick legs on
    broad clawed paws, and her seven bright stars along her back."""
    poly(c, [(19 + step, 30), (25 + step, 30), (25 + step, 44), (19 + step, 44)], "D")       # far hind leg
    c.rect(18 + step, 44, 26 + step, 46, "k")
    poly(c, [(32 - step, 30), (38 - step, 30), (38 - step, 44), (32 - step, 44)], "D")       # far foreleg
    c.rect(31 - step, 44, 39 - step, 46, "k")
    poly(c, [(4, 28), (6, 21), (12, 19), (22, 19), (30, 19), (36, 19), (40, 20), (41, 23), (42, 26), (43, 31),
             (44, 34), (36, 36), (18, 36), (10, 34)], "d")                               # body, humped at the shoulder
    poly(c, [(10, 31), (44, 31), (44, 34), (36, 36), (18, 36), (10, 34)], "D")           # belly in shadow
    poly(c, [(8, 21), (12, 19), (22, 19), (30, 19), (36, 19), (40, 20), (37, 21), (30, 21), (20, 21), (10, 22)], "l")   # light along the back
    ellipse(c, 4, 23, 2, 1.6, "d")                                                       # stubby tail
    for x, y in ((14, 24), (20, 23), (26, 23), (32, 22), (37, 23), (17, 28), (24, 27), (31, 25), (38, 23), (40, 26)):
        c.px(x, y, "D")                                                                  # shaggy fur
    poly(c, [(8, 22), (21, 23), (21, 33), (19, 39), (20, 44), (12, 44), (12, 38), (8, 32)], "d")   # near hind leg
    c.rect(11 - step, 44, 21 - step, 47, "k"); c.row(44, 12 - step, 20 - step, "D")
    poly(c, [(36, 24), (45, 24), (45, 38), (44, 44), (37, 44), (37, 36)], "d")            # near foreleg
    c.rect(36 + step, 44, 47 + step, 47, "k"); c.row(44, 37 + step, 46 + step, "D")
    for x in (13, 16, 19):
        c.px(x - step, 48, "w")                                                          # claws
    for x in (40, 43, 46):
        c.px(x + step, 48, "w")
    head = ("...dd...dd............",                                                    # the head in profile:
            "..dDDd.dDDd...........",                                                    # ears at the back,
            "..dddddddddl..........",                                                    # a broad brow sloping
            ".dddddddddddl.........",                                                    # down into a long,
            "ddddddddddddddl.......",                                                    # deep snout,
            "ddddddddddddddddl.....",                                                    # a heavy jaw,
            "dddddddddddddddddddl..",                                                    # a black nose
            "ddddddddddddddddddddkk",
            "dddddddddddddddddddkkk",
            "ddddddddddddddddddddk.",
            ".ddddddddddddddddddk..",
            "..DDDDDDDDDDDDDDDkk...",
            "...DDDDDDDDDDDD.......",
            ".....DDDDDDDD.........")
    for dy, row in enumerate(head):
        for dx, ch in enumerate(row):
            if ch != ".":
                c.px(40 + dx, 23 + dy, ch)
    for y in range(27, 35):
        c.px(40, y, "D")                                                                 # the line of the neck
    rim(c, "dDl", "b")
    c.rect(49, 29, 50, 29, "k"); c.px(49, 28, "w")                                       # eye
    for x, y in ((12, 23), (18, 21), (24, 22), (30, 21), (35, 21), (39, 23), (28, 27)):    # the seven stars
        c.px(x, y, "w"); c.px(x - 1, y, "y"); c.px(x + 1, y, "y")


BEAR_PAL = {"o": "#06081a", "d": "#3a4f9a", "D": "#24326a", "l": "#5068b8", "b": "#8aa8f8", "k": "#141c3a",
            "w": "#ffffff", "y": "#c8d4ff"}


def orion(c, step):
    """Orion (Apollodorus 1.4.3-5; Aratus; Ptolemy, Almagest 8: the stars of his shoulders, belt and sword): the
    giant hunter, broad and bearded, in a tunic of deep night-blue spangled with stars, raising a great knotted club
    over his head, a gold belt set with three bright stars and a sword
    hanging from it; red Betelgeuse burns at his shoulder and blue-white Rigel at his foot."""
    person(c, step, cx=20, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="short", beard="h",
           garment="tunic", robe="d", robe_d="D", legs="s", boots="b", belt="y", arm_forward=True)
    for y in range(12, 17):
        c.px(18 + (y % 2), y, "H"); c.px(22 - (y % 2), y, "H")                           # curls in his beard
    c.rect(11, 17, 13, 19, "d")                                                          # sleeve
    for t in range(6):
        c.rect(11 - t // 2, 16 - t, 12 - t // 2, 16 - t, "s")                            # upper arm, raised
    c.px(10, 12, "S"); c.px(9, 11, "s"); c.px(9, 10, "s")                                # forearm
    c.rect(5, 0, 8, 10, "b"); ellipse(c, 6, 2, 3, 3, "b")                                # the great knotted club
    c.px(4, 1, "B"); c.px(8, 4, "B"); c.px(5, 6, "B"); c.px(7, 9, "B"); c.px(3, 3, "B")
    ellipse(c, 9, 9, 1.6, 1.6, "s"); c.px(10, 9, "S")                                    # fist round it
    for x, y in ((15, 21), (24, 23), (17, 33), (23, 37), (19, 26)):
        c.px(x, y, "c")                                                                  # stars on his tunic
    c.rect(15, 29, 15, 41, "i"); c.row(29, 13, 17, "y"); c.px(15, 41, "I")               # sword hanging from the belt
    for x in (17, 20, 23):
        c.px(x, 28, "w")                                                                 # the belt's three stars
    for x, y, col in ((26, 17, "r"), (16, 52, "c")):
        c.px(x, y, col); c.px(x - 1, y, "Y"); c.px(x + 1, y, "Y"); c.px(x, y - 1, "Y")   # Betelgeuse, Rigel


ORION_PAL = {"o": "#06081a", "k": "#1a1410", "s": "#c88a5a", "S": "#a06a3e", "d": "#24306a", "D": "#18204e",
             "h": "#2a1a10", "H": "#140c06", "m": "#7a3a2a", "c": "#c8d4ff", "Y": "#fff4c0", "w": "#ffffff",
             "r": "#ff7a3a", "p": "#c8944a", "P": "#9a6a32", "b": "#6a4a2a", "B": "#4a3220", "i": "#c8d0e8",
             "I": "#8a90a0", "y": "#e8c040", "l": "#c88a5a"}


# --- The Glass Mountain (Grimm KHM 25, KHM 196; Andersen, "The Snow Queen", 1844) -------------------------------------

class _Offset:
    """Draws onto a canvas shifted by (dx, dy), so a small figure can be placed several times on one picture."""
    def __init__(self, c, dx, dy):
        self.c, self.dx, self.dy = c, dx, dy
        self.w, self.h, self.g = c.w, c.h, c.g

    def px(self, x, y, col):
        self.c.px(x + self.dx, y + self.dy, col)

    def rect(self, x0, y0, x1, y1, col):
        self.c.rect(x0 + self.dx, y0 + self.dy, x1 + self.dx, y1 + self.dy, col)

    def row(self, y, x0, x1, col):
        self.rect(x0, y, x1, y, col)


def white_bee(c, f):
    """A white bee (Andersen: "the white bees are swarming", the grandmother's name for snowflakes): a six-armed
    snowflake with little frosty wings beating and two dark eyes at its heart."""
    up = f % 2
    ellipse(c, 4, 2 if up else 4, 2, 1.4, "W"); ellipse(c, 8, 2 if up else 4, 2, 1.4, "W")   # little wings
    for k in range(6):
        a = math.radians(30 + k * 60)
        for r in (1, 2, 3, 4):
            c.px(6 + round(r * math.cos(a)), 7 + round(r * math.sin(a)), "w" if r < 4 else "b")
        bx, by = 6 + 3 * math.cos(a), 7 + 3 * math.sin(a)
        c.px(round(bx + 1.2 * math.cos(a + 1.2)), round(by + 1.2 * math.sin(a + 1.2)), "b")   # side branches
        c.px(round(bx + 1.2 * math.cos(a - 1.2)), round(by + 1.2 * math.sin(a - 1.2)), "b")
    c.px(6, 7, "b"); c.px(5, 7, "k"); c.px(7, 7, "k")


WHITE_BEE_PAL = {"o": "#6a7888", "w": "#ffffff", "W": "#d8ecfa", "b": "#a8d0ec", "k": "#2a3a4a"}


def snowflake_guard(c, f):
    """A snowflake guard of the Snow Queen (Andersen, 7th story: her advance guard of living snowflakes, shaped like
    horrid hedgehogs, knotted snakes and little fat bears): a little fat bear of packed snow with icy spines bristling
    along its back like a hedgehog's, glaring eyes and icy fangs."""
    s = STEP[f]
    for x, d in ((5, -s), (11, s)):
        c.rect(x + d, 14, x + 2 + d, 18, "b"); c.row(19, x + d, x + 2 + d, "B")         # stubby legs
    ellipse(c, 9, 11, 7, 5, "w"); ellipse(c, 8, 14, 6, 2, "b")                           # fat body
    for k in range(6):
        x = 3 + k * 2
        c.px(x, 6, "i"); c.px(x - 1, 5, "i"); c.px(x - 2, 4, "I")                       # icy spines
    ellipse(c, 15, 8, 3.6, 3.2, "w"); c.px(13, 5, "w"); c.px(17, 5, "w")                # head, round ears
    c.px(16, 7, "k"); c.px(15, 6, "B"); c.px(17, 6, "B")                                 # glaring eye, brow
    c.px(18, 9, "B"); c.row(10, 15, 18, "k"); c.px(16, 11, "i"); c.px(18, 11, "i")      # snout, mouth, icy fangs


SNOW_GUARD_PAL = {"o": "#4a5a6a", "w": "#f4f8fc", "b": "#c8dcec", "B": "#8aa4bc", "k": "#2a3a4a", "i": "#a8e0f8",
                  "I": "#e0f6ff"}


def seven_ravens(c, step):
    """The Seven Ravens (Grimm, KHM 25): seven brothers changed into ravens by their father's hasty word, who live in
    the glass mountain; their little sister freed them. Seven big black ravens flying together, wedge-tailed and
    heavy-beaked, their wings beating out of time."""
    for k, (x, y) in enumerate(((40, 26), (2, 22), (22, 26), (12, 12), (32, 13), (24, 1), (42, 3))):
        gothic_raven(_Offset(c, x, y), (k + step) % 2)


RAVENS_PAL = {"o": "#3a3a46", "k": "#141418", "K": "#26262e", "B": "#4a4a56", "w": "#c8c8d0"}


def rinkrank(c, step):
    """Old Rinkrank (Grimm, KHM 196): the old man who lived in the glass mountain and made the king's daughter his
    servant; he came and went by a ladder he let down, and she caught his long grey beard in the window and would not
    let go until he gave it to her. A bald old man with a grey fringe and bushy brows, a beard down to his knees, a
    shabby brown coat, carrying his ladder."""
    for t in range(45):                                                                  # the ladder, behind him
        c.px(31 - t // 22, 8 + t, "L"); c.px(37 - t // 22, 8 + t, "L")
    for y in range(11, 52, 5):
        c.row(y, 31 - (y - 8) // 22, 37 - (y - 8) // 22, "w")
    person(c, step, cx=20, skin="s", skin_d="S", hair="g", hair_d="G", hair_style="short", garment="robe",
           robe="b", robe_d="B", robe_l="n", belt="k", boots="k", head_y=12)
    c.row(6, 17, 23, "s"); c.row(7, 16, 24, "s"); c.px(18, 7, "S")                       # bald crown
    c.row(10, 16, 18, "g"); c.row(10, 22, 24, "g")                                       # bushy grey brows
    ellipse(c, 20, 14, 1.5, 1.4, "S")                                                    # big nose
    poly(c, [(16, 15), (24, 15), (25, 28), (23, 40), (20, 46), (17, 40), (15, 28)], "g")   # beard to his knees
    for x, y in ((18, 20), (21, 24), (19, 30), (22, 34), (20, 40), (17, 26), (23, 22)):
        c.px(x, y, "G")
    ellipse(c, 29, 32, 1.8, 1.8, "s")                                                    # hand on the ladder


RINKRANK_PAL = {"o": "#0e0a08", "k": "#1e1814", "b": "#6a5040", "B": "#4a3828", "n": "#7e6250", "s": "#e0c0a0",
                "S": "#b89878", "g": "#c0c0c0", "G": "#8a8a8a", "m": "#8a5a4a", "L": "#7a5a3a", "w": "#9a7a54",
                "l": "#4a3828"}


def snow_queen(c, step):
    """The Snow Queen (Andersen, 1844): "a lady, tall and slender, and dazzling white; her cloak and cap were of snow".
    Her palace walls were driven snow; she kissed Kai, and he no longer felt the cold. Pale as ice, with long silver
    hair, a crown of icicles, a high collar and cloak of snow, a gown glittering with frost, and frost spilling from her
    outstretched hand."""
    poly(c, [(10, 17), (32, 17), (39, 54), (3, 54)], "W")                                # cloak of snow
    poly(c, [(10, 17), (14, 17), (8, 54), (3, 54)], "B")
    for x, y in ((6, 40), (36, 46), (10, 30), (33, 34)):
        c.px(x, y, "i")
    person(c, step, cx=21, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="long", garment="gown",
           robe="w", robe_d="W", robe_l="i", belt="i", boots="b", eye="b", mouth="m", arm_forward=True, head_y=12)
    for x, h in ((16, 3), (18, 5), (20, 4), (21, 7), (22, 4), (24, 5), (26, 3)):
        c.rect(x, 7 - h, x, 6, "i"); c.px(x, 7 - h, "I")                                 # crown of icicles
    c.row(7, 16, 26, "I")
    poly(c, [(13, 18), (15, 15), (21, 20), (27, 15), (29, 18), (27, 22), (15, 22)], "w")   # high collar of snow
    c.px(15, 16, "W"); c.px(27, 16, "W")
    for x, y in ((18, 28), (24, 33), (19, 40), (25, 45), (16, 47), (22, 36)):
        c.px(x, y, "i")                                                                  # frost on her gown
    for x, y in ((38, 21), (40, 24), (37, 27), (39, 19), (41, 22)):
        c.px(x, y, "I")                                                                  # frost from her hand


SNOW_QUEEN_PAL = {"o": "#4a5a6a", "k": "#2a3a4a", "w": "#f4f8fc", "W": "#c8dcec", "B": "#a8bccc", "s": "#eef2f8",
                  "S": "#c8d4e0", "h": "#e8f0f8", "H": "#b0c4d8", "b": "#5a8ab0", "m": "#8aa8c8", "i": "#a8e0f8",
                  "I": "#e0f6ff", "l": "#c8dcec"}


# --- Demos Oneiron (Odyssey 19.560-569, 24.12; Ovid, Metamorphoses 11.583-649) -----------------------------------------

def dream(c, f):
    """A dream (Ovid 11.613-615: empty dreams lie all about the House of Sleep, as many as the ears of the harvest, the
    leaves of the woods, the sands of the shore): a pale, glowing wisp with sleepy closed eyes, trailing away into
    nothing, little stars twinkling round it."""
    s = STEP[f]
    poly(c, [(3, 6), (11, 6), (10, 10), (7 + s, 13), (6 - s, 11), (4, 10)], "W")         # trailing wisp
    ellipse(c, 7, 5, 4.5, 4, "w"); ellipse(c, 6, 4, 2.5, 2, "l")                         # glowing head
    c.px(5, 6, "k"); c.px(6, 6, "k"); c.px(8, 6, "k"); c.px(9, 6, "k")                   # closed sleepy eyes
    c.px(7, 8, "p")
    if f % 2:
        c.px(1, 2, "y"); c.px(12, 9, "y")                                                # twinkling stars
    else:
        c.px(12, 1, "y"); c.px(1, 9, "y")


DREAM_PAL = {"o": "#3a2a5a", "w": "#d8c8f0", "W": "#a890d0", "l": "#f0e8ff", "k": "#5a4a7a", "p": "#c890c8",
             "y": "#fff0a0"}


def nightmare_beast(c, f):
    """A nightmare beast (Ovid 11.638-640: the shapes of beasts that Phobetor brings): a shadowy wolf-like beast with a
    bristling mane, too many glowing eyes, bared fangs, and smoke trailing from it."""
    s = STEP[f]
    for k in range(5):
        c.px(3 - k, 7 + (k + f) % 2, "p"); c.px(4 - k, 9 + (k + f + 1) % 2, "p")         # smoky tail
    ellipse(c, 10, 8, 7, 3.5, "k")
    for k, d in enumerate((-s, s, s, -s)):
        x = 5 + k * 3 + d
        c.rect(x, 10, x + 1, 14, "K" if k % 2 else "k"); c.px(x + 1, 15, "w")
    for x in range(5, 16, 2):
        c.px(x, 4, "k"); c.px(x - 1, 3, "K")                                             # bristling mane
    poly(c, [(15, 4), (21, 6), (23, 9), (16, 11)], "k"); poly(c, [(15, 4), (16, 1), (18, 5)], "k")   # head, ear
    c.row(9, 18, 23, "m"); c.px(19, 10, "w"); c.px(22, 10, "w")                          # open jaws, fangs
    for x, y in ((17, 6), (19, 7), (18, 5), (20, 5)):
        c.px(x, y, "r")                                                                  # too many eyes


NIGHTMARE_PAL = {"o": "#120a1a", "k": "#2a1a3a", "K": "#1a1028", "r": "#f04a8a", "p": "#6a3a8a", "w": "#e8e0f0",
                 "m": "#5a0a2a"}


def phantasos(form):
    """Phantasos (Ovid 11.641-643): the dream-shaper of things without life: earth, rock, water, wood. Here as a
    standing stone with a sleeping face, mossy and cracked, dream-light drifting round it; or as a figure of water
    rising from a pool, its arms flowing and splashing."""
    def rock(c, step):
        poly(c, [(10, 52), (8, 30), (12, 14), (20, 6), (30, 5), (37, 12), (40, 28), (39, 52)], "g")   # the stone
        poly(c, [(10, 52), (8, 30), (12, 14), (17, 10), (14, 30), (15, 52)], "G")
        poly(c, [(30, 5), (37, 12), (39, 24), (32, 12)], "l")                            # light on its shoulder
        for t in range(10):
            c.px(22 - t // 4, 8 + t, "G")                                                # cracks
        c.row(42, 12, 37, "G"); c.row(43, 14, 30, "k")
        c.row(21, 17, 21, "G"); c.row(21, 27, 31, "G")                                   # heavy brows
        c.row(24, 17, 21, "k"); c.px(16, 23, "k"); c.px(22, 23, "k")                     # closed, sleeping eyes
        c.row(24, 27, 31, "k"); c.px(26, 23, "k"); c.px(32, 23, "k")
        poly(c, [(23, 22), (26, 22), (27, 31), (22, 31)], "l"); c.rect(22, 24, 22, 31, "G")   # nose ridge
        c.row(35, 20, 29, "k"); c.row(36, 21, 28, "G")                                   # mouth, slack in sleep
        for x, y in ((14, 47), (15, 48), (32, 49), (33, 48), (20, 8), (21, 7), (28, 6), (34, 46)):
            c.px(x, y, "m")                                                              # moss
        c.rect(5, 50, 7, 52, "G"); c.rect(41, 50, 43, 52, "G")                           # rubble at its foot
        for x, y in ((3, 12 + step), (44, 18 - step), (5, 32), (45, 38 + step), (40, 6)):
            c.px(x, y, "p"); c.px(x + 1, y, "P")                                         # dream-light drifting

    def water(c, step):
        ellipse(c, 24, 50, 20, 4, "b"); ellipse(c, 24, 49, 18, 2.5, "B")                 # the pool
        poly(c, [(16, 50), (18, 36), (14, 24), (16, 18), (32, 18), (34, 24), (30, 36), (32, 50)], "b")   # body of water
        for k in range(3):
            for y in range(18, 50):
                x = 19 + k * 5 + round(math.sin((y + step * 2) / 3 + k))
                if c.g[y][x] == "b":
                    c.px(x, y, "B")                                                      # currents flowing down it
        for t in range(10):                                                              # arm flowing down
            ellipse(c, 15 - t * 0.8, 21 + t * 1.2, 2.2 - t * 0.1, 2.2 - t * 0.1, "b")
        for t in range(10):                                                              # arm raised
            ellipse(c, 33 + t * 0.7, 20 - t * 1.0, 2.2 - t * 0.1, 2.2 - t * 0.1, "b")
        for x, y in ((40, 8), (42, 10), (39, 6), (43, 7), (6, 34), (8, 36), (5, 32)):
            c.px(x, y, "w")                                                              # splashes
        ellipse(c, 24, 12, 6, 6, "b"); ellipse(c, 23, 10, 3, 2.5, "B")                   # head
        poly(c, [(18, 8), (24, 2), (33, 5), (30, 9)], "B"); c.px(33, 6, "w"); c.px(34, 8, "w")   # a crest like a wave
        c.px(21, 12, "w"); c.px(27, 12, "w"); c.row(15, 22, 26, "d")                     # glowing eyes, mouth
        for x, y in ((10, 46 + step), (38, 45 - step), (24, 44)):
            c.px(x, y, "w")                                                              # drops
    return rock if form == "rock" else water


PHANTASOS_PAL = {"o": "#0e1020", "g": "#6a6878", "G": "#4a4858", "l": "#8e8c9c", "k": "#2a2838", "m": "#6a8a4a",
                 "p": "#c8a8f0", "P": "#8a6ac0", "b": "#4a7ac0", "B": "#8ab8f0", "w": "#ffffff", "d": "#1a3a6a"}


def morpheus(c, step):
    """Morpheus (Ovid 11.633-638): the dream-shaper of men, who copies a man's walk, face and voice, and his very
    dress, better than any other. A slender youth in a grey robe and a deep violet cloak, with little wings at his
    temples, a poppy at his belt, holding up a pale mask: the face he will wear."""
    person(c, step, cx=21, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="short", garment="robe",
           robe="g", robe_d="G", robe_l="l", belt="y", boots="k", cloak=("p", "P"), arm_forward=True)
    for side in (-1, 1):                                                                 # wings at his temples:
        x0 = 21 + side * 5                                                               # small fans of feathers
        for ang, length, col in ((20, 7, "W"), (40, 7, "w"), (60, 5, "w")):
            a = math.radians(ang)
            for t in range(length):
                c.px(x0 + side * round(t * math.cos(a)), 9 - round(t * math.sin(a)), col)
    c.px(17, 29, "r"); c.px(18, 29, "r"); c.px(17, 30, "r"); c.px(18, 30, "k")           # a poppy at his belt
    ellipse(c, 38, 21, 3.5, 4.4, "m"); c.px(37, 20, "k"); c.px(39, 20, "k")              # the mask he holds up
    c.row(23, 37, 39, "M"); c.px(38, 22, "M"); c.px(36, 18, "M")
    c.px(35, 25, "p"); c.px(35, 26, "p"); c.px(34, 27, "P")                              # its ribbon


MORPHEUS_PAL = {"o": "#120e1a", "k": "#1e1828", "g": "#6a6480", "G": "#4e4862", "l": "#8a84a0", "p": "#3a2a5a",
                "P": "#2a1e44", "s": "#e8d8c8", "S": "#c0a890", "h": "#2a2030", "H": "#1a1420", "w": "#f0ecf8",
                "W": "#b8b0cc", "m": "#f4f0e8", "M": "#b8b0a0", "y": "#c8a8e8", "r": "#d8304a", "b": "#1e1828",
                "e": "#1e1828"}


def phobetor(form):
    """Phobetor (Ovid 11.638-641): "called Icelus by the gods, Phobetor by mortal men", who becomes a beast, a bird or a
    long serpent: the bringer of nightmares. As a beast, a shaggy black wolf-thing with a bristling mane, a cluster of
    glowing eyes, gaping fanged jaws and smoke trailing from it; as a bird, a huge ragged black bird with a hooked
    beak, its wings spread wide; as a serpent, a long striped serpent rearing from its coils, crested and fanged."""
    wolf_body = gothic_wolf(snarl=True, big_head=True)

    def beast(c, legs):
        """On the great wolf's body: smoke trailing from its back and tail, bristling hackles, and a cluster of eyes."""
        wolf_body(c, legs)
        for x in range(20, 50, 3):
            for y in range(6, 24):
                if c.g[y][x] in "fD":
                    c.px(x, y - 1, "D"); c.px(x - 1, y - 2, "D"); break                  # bristling hackles
        for x, y in ((57, 9), (59, 7), (62, 9), (58, 11), (63, 7)):
            c.px(x, y, "r")                                                              # too many eyes
        c.px(60, 10, "r"); c.px(61, 10, "r")
        rim(c, "fFD", "p")
        step = legs[0] // 3
        for k in range(10):                                                              # smoke trailing away
            c.px(6 - k // 2, 36 + k, "p"); c.px(4 - k // 3 + step, 30 + k, "P")

    def feather(c, x, y, dx, dy, length, col, shade):
        n = math.hypot(dx, dy)
        dx, dy = dx / n, dy / n
        for t in range(int(length)):
            px, py = round(x + dx * t), round(y + dy * t)
            c.px(px, py, col); c.px(px + 1, py, shade if t > 1 else col)

    def wing(c, sh, wr, tip, col, shade):
        """A ragged wing raised high: a leading edge from shoulder to wrist to tip, long fingered flight feathers hanging
        back from it, of uneven length."""
        poly(c, [sh, wr, tip, (tip[0] - 8, tip[1] + 14), (sh[0] - 10, sh[1] + 6)], col)
        for k in range(7):
            t = k / 6
            x, y = wr[0] + (tip[0] - wr[0]) * t, wr[1] + (tip[1] - wr[1]) * t
            feather(c, x, y, -0.6, 1, 13 + t * 5 + (k % 2) * 3, col, shade)
        for k in range(5):
            t = k / 5
            x, y = sh[0] + (wr[0] - sh[0]) * t, sh[1] + (wr[1] - sh[1]) * t
            feather(c, x, y, -0.4, 1, 10 + (k % 2) * 2, col, shade)
        for t in range(10):
            x = sh[0] + (wr[0] - sh[0]) * t / 9; y = sh[1] + (wr[1] - sh[1]) * t / 9
            ellipse(c, x, y, 1.6, 1.6, col)

    def bird(c, step):
        wing(c, (30, 24), (24, 8 - step), (10, 2 - step), "K", "q")                      # far wing, raised back
        poly(c, [(22, 30), (8, 38), (10, 42), (14, 40), (15, 44), (19, 41), (21, 44), (25, 34)], "k")   # fanned tail
        c.px(12, 40, "q"); c.px(17, 41, "q")
        ellipse(c, 30, 29, 9, 6, "k"); ellipse(c, 33, 31, 5, 3, "q")                     # body, ragged breast
        for x, y in ((31, 30), (34, 32), (29, 33), (36, 30)):
            c.px(x, y, "K")
        for x0 in (31, 35):                                                              # talons reaching forward
            for t in range(6):
                c.px(x0 + t // 2, 34 + t, "K")
            c.px(x0 + 2, 40, "w"); c.px(x0 + 4, 40, "w"); c.px(x0, 41, "w")
        poly(c, [(34, 26), (39, 18), (44, 18), (40, 28)], "k")                           # neck
        ellipse(c, 43, 17, 4.5, 4, "k"); poly(c, [(40, 14), (37, 9), (42, 13)], "k")    # head, ragged crest
        poly(c, [(46, 15), (55, 17), (55, 21), (52, 19), (46, 20)], "p")                 # long hooked beak
        c.px(54, 22, "p"); c.px(53, 22, "p")
        c.px(44, 16, "r"); c.px(42, 16, "r"); c.px(43, 17, "m")                          # glowing eyes
        wing(c, (33, 23), (30, 6 + step), (22, 0 + step), "k", "K")                      # near wing, raised back
        rim(c, "kK", "p")

    def serpent(c, step):
        def bez(p0, p1, p2, p3, t):
            u = 1 - t
            return (u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                    u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1])
        pts = []
        for k in range(60):                                                              # the coils
            t = k / 59
            pts.append((4 + 40 * t, 45 - 7 * abs(math.sin(2 * math.pi * t + step * 0.3)), 1.5 + 3.2 * t))
        for k in range(36):                                                              # rearing up
            x, y = bez((44, 45), (60, 38), (40, 24), (50, 16), k / 35)
            pts.append((x, y, 4.6 - 0.6 * k / 35))
        for x, y, r in pts:
            ellipse(c, x, y, r, r, "K")
        for i, (x, y, r) in enumerate(pts):
            ellipse(c, x - 0.5, y - 0.6, max(r - 1.2, 0.6), max(r - 1.2, 0.6), "p" if (i // 5) % 2 else "k")   # stripes
        ellipse(c, 52, 13, 5.5, 4, "k")                                                  # broad head
        poly(c, [(55, 11), (61, 13), (60, 17), (54, 17)], "k")
        for x in range(46, 56, 2):
            c.px(x, 9 - (x % 4 == 0), "p")                                               # crest
        c.px(54, 12, "r"); c.px(56, 12, "r")                                             # eyes
        c.px(58, 17, "w"); c.px(60, 17, "w")                                             # fangs
        c.px(62, 15, "r"); c.px(63, 14, "r"); c.px(63, 16, "r")                          # forked tongue
        rim(c, "kK", "p")
    return {"beast": beast, "bird": bird, "serpent": serpent}[form]


PHOBETOR_PAL = {"o": "#0a0612", "k": "#2a1a3a", "K": "#1a1028", "q": "#3a2650", "p": "#6a3a9a", "r": "#f04a8a",
                "w": "#e8e0f0", "m": "#5a0a2a"}
PHOBETOR_BEAST_PAL = {"o": "#0a0612", "k": "#0a0612", "f": "#2e1e40", "F": "#20142e", "D": "#160c22", "l": "#4a3262",
                      "w": "#e8e0f0", "r": "#f04a8a", "y": "#f04a8a", "g": "#6a3a9a", "p": "#6a3a9a", "P": "#4a2a72"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_heavens.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("arimaspian", arimaspian, ARIMASPIAN_PAL, doc(arimaspian.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("young_griffin", young_griffin, YOUNG_GRIFFIN_PAL, doc(young_griffin.__doc__), (20, 16), (10, 15), walk, folder="enemies")
    kit.build_boss("feather_flurry", feather_flurry, FLURRY_PAL, doc(feather_flurry.__doc__), (14, 12), (7, 11), walk, folder="enemies")
    kit.build_boss("arimaspian_chieftain", arimaspian_chieftain, CHIEFTAIN_PAL, doc(arimaspian_chieftain.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("six_month_sleeper", six_month_sleeper, SLEEPER_PAL, doc(six_month_sleeper.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("griffin_matriarch", griffin_matriarch, MATRIARCH_PAL, doc(griffin_matriarch.__doc__), (64, 54), (30, 52), [0, 1, 0, -1, 0])
    kit.build_boss("star_hound", star_hound, STAR_HOUND_PAL, doc(star_hound.__doc__), (24, 16), (11, 15), walk, folder="enemies")
    kit.build_boss("star_mote", star_mote, STAR_MOTE_PAL, doc(star_mote.__doc__), (11, 11), (5, 10), walk, folder="enemies")
    kit.build_boss("comet", comet, COMET_PAL, doc(comet.__doc__), (20, 12), (10, 11), walk, folder="enemies")
    kit.build_boss("scorpion", scorpion, SCORPION_PAL, doc(scorpion.__doc__), (58, 46), (26, 44), [0, 1, 0, -1, 0])
    kit.build_boss("great_bear", great_bear, BEAR_PAL, doc(great_bear.__doc__), (62, 50), (30, 48), [0, 1, 0, -1, 0])
    kit.build_boss("orion", orion, ORION_PAL, doc(orion.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
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
    kit.build_boss("phobetor", phobetor("beast"), PHOBETOR_BEAST_PAL, doc(phobetor.__doc__), (74, 54), (36, 52), WOLF_WALK)
    kit.build_boss("phobetor_beast", phobetor("beast"), PHOBETOR_BEAST_PAL, doc(phobetor.__doc__ + " Here, as a beast."),
                   (74, 54), (36, 52), WOLF_WALK)
    for form in ("bird", "serpent"):
        kit.build_boss("phobetor_" + form, phobetor(form), PHOBETOR_PAL, doc(phobetor.__doc__ + " Here, as a %s." % form),
                       (64, 52), (30, 50), [0, 1, 0, -1, 0])
    print("wrote the Heavens' art")
