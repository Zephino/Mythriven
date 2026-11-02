# Otherworlds' art (Pack 12, docs/PACK_12_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Coimín's lay of Oisín; Lady Wilde; Yeats; O'Flaherty and the 1675 O-Brazile pamphlet; the Flying Dutchman
# legend of 1795-1821; Andersen's "The Shadow", 1847; Hunt and Bottrell's Cornish collections), never later versions.
# Run: python3 build_otherworlds.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly
from figure_kit import person
from build_gothic import rim

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
    """The Fomor (Coimín's lay: the Fomorian giant Oisín fought for three days and nights; the Fomorians, the old sea
    raiders, later told of as misshapen): a huge hunched sea-giant with grey-green skin crusted with barnacles,
    seaweed for hair and beard, one great bulging eye and one small squinting one, tusks jutting up from his jaw, long
    arms, a hide wrapped round his waist hung with weed, and a great knotted club over his shoulder."""
    for x, d in ((16, -step), (34, step)):                                               # short, thick, bowed legs
        c.rect(x + d, 42, x + 8 + d, 53, "g"); c.rect(x + d, 42, x + 2 + d, 53, "G")
        c.rect(x - 1 + d, 53, x + 9 + d, 56, "G"); c.px(x + 1 + d, 56, "k"); c.px(x + 5 + d, 56, "k")
    poly(c, [(8, 20), (50, 20), (46, 42), (12, 42)], "g")                                # hulking torso
    poly(c, [(8, 20), (15, 20), (17, 42), (12, 42)], "G")
    ellipse(c, 29, 35, 12, 7, "g"); ellipse(c, 25, 37, 6, 4, "G")                        # gut
    c.row(27, 18, 26, "G"); c.row(27, 32, 40, "G")
    poly(c, [(12, 40), (46, 40), (47, 47), (42, 45), (37, 48), (31, 45), (25, 48), (19, 45), (13, 47)], "f")   # hide
    for x in (16, 28, 40):
        c.rect(x, 42, x, 50, "m"); c.px(x + 1, 51, "M")                                  # weed hanging from it
    poly(c, [(8, 20), (2, 26), (1, 44), (7, 46), (10, 28)], "G")                         # long far arm
    ellipse(c, 4, 47, 4, 3.4, "g"); c.px(3, 48, "G")                                     # huge fist
    for t in range(30):                                                                  # the knotted club
        x, y = 47 + t * 0.3, 30 - t
        ellipse(c, x, y, 1.8 + t * 0.06, 1.8 + t * 0.06, "b")
    ellipse(c, 56, 3, 4.5, 4, "b")
    for x, y in ((52, 16), (54, 8), (57, 4), (50, 22)):
        c.px(x, y, "B"); c.px(x + 1, y, "B")                                             # its knots
    poly(c, [(44, 20), (51, 22), (52, 32), (46, 33), (45, 26)], "g")                     # near arm, gripping the club
    ellipse(c, 48, 31, 3.6, 3.2, "g"); c.px(46, 30, "G")
    ellipse(c, 28, 14, 8.5, 7.5, "g"); c.px(20, 15, "G"); c.px(21, 17, "G")             # lumpy head, sunk low
    c.row(9, 21, 35, "G"); c.row(10, 20, 24, "G")                                        # heavy brow
    ellipse(c, 24, 13, 2.6, 2.4, "w"); c.px(24, 13, "k"); c.px(25, 13, "r")             # one great bulging eye
    c.row(13, 31, 33, "k"); c.px(32, 12, "G")                                            # one small, squinting
    ellipse(c, 29, 16, 1.6, 1.4, "G")                                                    # nose
    c.row(19, 23, 34, "k"); c.px(24, 18, "w"); c.px(25, 17, "w"); c.px(33, 18, "w"); c.px(32, 17, "w")   # mouth, tusks
    for x in range(19, 38, 2):
        c.px(x, 6 + (x % 3), "m"); c.px(x, 7 + (x % 3), "M")                             # seaweed hair
    for x, y0 in ((19, 10), (37, 10), (21, 8), (35, 9)):
        c.rect(x, y0, x, y0 + 8, "m")
    for x in range(24, 34, 2):
        c.rect(x, 20, x, 24 + (x % 4), "m")                                              # weedy beard
    for x, y in ((12, 22), (14, 25), (40, 23), (43, 26), (18, 32), (38, 36), (10, 30)):
        c.px(x, y, "c"); c.px(x + 1, y, "C")                                             # barnacles


FOMOR_PAL = {"o": "#10140e", "g": "#6e8a6a", "G": "#4e6a4c", "w": "#f0ece0", "k": "#141810", "r": "#a83a2a",
             "b": "#5a3a1a", "B": "#3a2410", "f": "#6a4a2a", "m": "#3a6a3a", "M": "#24482a", "c": "#d8d4c4",
             "C": "#9a968a"}


def finvarra(c, step):
    """Finvarra (Lady Wilde, 1887: the king of the fairies of the West, under the hill of Knockma): a slender, handsome
    fairy king with black hair to his shoulders, a trimmed black beard and a pale face, a silver crown, a tunic of black
    worked with silver, high boots, a long black
    cloak lined with deep green on which the gold of the hills glints, and a silver wand with a glowing tip."""
    person(c, step, cx=20, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="shoulder",
           garment="tunic", robe="k", robe_d="K", legs="K", boots="k", belt="w", cloak=("K", "g"), arm_forward=True,
           crown="w", eye="e")
    c.row(13, 19, 21, "S"); c.px(20, 15, "h"); c.px(20, 16, "h"); c.px(19, 15, "h"); c.px(21, 15, "h")   # pointed beard
    for x, h in ((16, 2), (18, 3), (20, 4), (22, 3), (24, 2)):
        c.rect(x, 5 - h, x, 4, "w")                                                      # points of the silver crown
    c.px(20, 1, "j")
    for y in range(19, 39, 3):
        c.px(19, y, "w"); c.px(21, y + 1, "w")                                           # silver worked down his tunic
    c.row(39, 14, 26, "w")
    for x, y in ((9, 26), (31, 32), (8, 40), (33, 44), (12, 48), (30, 22), (6, 50)):
        c.px(x, y, "y")                                                                  # the gold of the hills glinting
    c.rect(35, 10, 35, 26, "w")                                                          # silver wand
    ellipse(c, 35, 9, 1.6, 1.6, "j"); c.px(35, 8, "J"); c.px(33, 7 - step, "J"); c.px(37, 6 + step, "J")


FINVARRA_PAL = {"o": "#0e0a10", "k": "#1e1a24", "K": "#2e2a3a", "g": "#1e4a32", "s": "#f0e0d0", "S": "#c8b0a0",
                "h": "#14101a", "H": "#0a080e", "e": "#2a6a4a", "m": "#a86a6a", "w": "#d8dce8", "y": "#e8c040",
                "j": "#a8f0c8", "J": "#e8fff4", "l": "#2e2a3a", "b": "#2e2a3a"}


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
    """The Necromancer of O'Brazile (the 1675 pamphlet: the enchanter whose spell hid the island until fire was lit on
    its shore): a gaunt old man in a deep grey hood, with a long white beard, sunken cheeks and eyes glowing sea-green,
    in a black gown sewn with silver signs, a staff topped with a glowing sea-green stone, his other hand raised to
    cast, and the sea-mist of his spell curling round his feet."""
    person(c, step, cx=20, skin="s", skin_d="S", hair="w", hair_d="W", hair_style="none", beard="w",
           garment="gown", robe="k", robe_d="K", robe_l="e", belt="e", boots="K", cloak=("h", "H"), arm_forward=True,
           eye="g")
    ellipse(c, 20, 8, 7, 7.5, "h"); poly(c, [(13, 8), (20, -1), (27, 8)], "h")          # deep grey hood
    poly(c, [(13, 9), (16, 9), (15, 20), (12, 18)], "H"); poly(c, [(24, 9), (27, 9), (28, 18), (25, 20)], "H")
    ellipse(c, 20, 10, 4, 4.6, "s"); c.px(17, 12, "S"); c.px(23, 12, "S")               # gaunt face in it
    c.row(8, 17, 19, "H"); c.row(8, 21, 23, "H")                                         # shadowed brows
    c.px(18, 10, "g"); c.px(22, 10, "g")                                                 # eyes glowing sea-green
    c.px(20, 12, "S")
    poly(c, [(17, 13), (23, 13), (23, 22), (20, 28), (17, 22)], "w")                     # long white beard
    c.px(19, 17, "W"); c.px(21, 21, "W"); c.px(20, 24, "W")
    for x, y, sign in ((16, 32, 0), (23, 36, 1), (18, 42, 2), (24, 46, 0), (15, 48, 1)):   # silver signs on his gown
        if sign == 0:
            c.px(x, y, "e"); c.px(x - 1, y, "e"); c.px(x + 1, y, "e"); c.px(x, y - 1, "e"); c.px(x, y + 1, "e")
        elif sign == 1:
            c.px(x, y, "e"); c.px(x + 1, y - 1, "e"); c.px(x + 1, y + 1, "e")
        else:
            c.px(x, y, "e"); c.px(x + 1, y, "e"); c.px(x, y + 1, "e"); c.px(x + 1, y + 1, "e")
    poly(c, [(12, 18), (9, 12), (7, 6), (9, 5), (12, 12), (14, 16)], "K")                # far arm raised to cast
    ellipse(c, 8, 4, 1.8, 1.8, "s")
    for x, y in ((6, 1 - step), (10, 0 + step), (5, 4), (11, 2)):
        c.px(x, y, "g")                                                                  # sea-green sparks
    c.rect(35, 8, 36, 52, "b"); c.px(35, 8, "B")                                         # staff
    poly(c, [(33, 6), (35, 3), (38, 3), (39, 6), (36, 9)], "b")                          # gnarled head
    ellipse(c, 36, 4, 2, 2, "g"); c.px(36, 3, "G")                                       # glowing sea-green stone
    for k in range(8):                                                                   # sea-mist curling at his feet
        x = 4 + k * 5 + step
        c.px(x, 52 - (k % 2), "m"); c.px(x + 1, 52 - (k % 2), "m"); c.px(x + 2, 51 - (k % 2), "M")
    for x, y in ((2, 48), (38, 47), (6, 44)):
        c.px(x, y, "M"); c.px(x + 1, y, "m")


NECROMANCER_PAL = {"o": "#0e0a10", "k": "#1e1a24", "K": "#2e2a36", "h": "#4a4a5a", "H": "#32323e", "s": "#d0bca8",
                   "S": "#a08a78", "w": "#e8e4dc", "W": "#b8b4ac", "e": "#c8ccd8", "b": "#5a3a1a", "B": "#3a2410",
                   "g": "#4ae0b0", "G": "#c8fff0", "m": "#c8d0d8", "M": "#9aa4b0", "l": "#1e1a24"}


def flying_dutchman(pal_phantom):
    """The Flying Dutchman (Barrington, 1795; Blackwood's, 1821): Vanderdecken's ship, a high-sterned Dutch ship
    beating against the wind for ever: a curved, planked hull with a gold stripe and gunports, a high stern castle with
    lit windows and a lantern, a bowsprit, three masts with their yards and torn, billowing square sails, rigging, and
    a tattered flag."""
    def draw(c, step):
        for x0, x1 in ((20, 5), (34, 5), (48, 5), (20, 64), (48, 66)):                   # rigging
            n = abs(x1 - x0)
            for t in range(n):
                c.px(x0 + (x1 - x0) * t // n, 4 + t * 26 // n, "r")
        for x in (20, 34, 48):
            c.rect(x, 3, x + 1, 36, "m")                                                 # masts
        for x, top, wide in ((20, 5, 5), (34, 3, 6), (48, 7, 5)):                        # billowing sails, torn at the foot
            for k, (y0, y1, w) in enumerate(((top, top + 9, wide - 2), (top + 11, top + 23, wide))):
                c.row(y0, x - w - 1, x + w + 2, "m")                                     # the yard
                for xx in range(x - w, x + w + 2):
                    u = (xx - (x - w)) / (2 * w + 1)
                    belly = round(math.sin(u * math.pi) * (2 + step * 0.5))              # the sail bellies out below
                    for yy in range(y0 + 1, y1 + belly + 1):
                        c.px(xx + (1 if yy > y0 + (y1 - y0) // 2 else 0), yy, "s")
                    c.px(xx + 1, y1 + belly, "S")                                        # its curved foot
                for yy in range(y0 + 1, y1 + 1):
                    c.px(x - w + 1, yy, "S"); c.px(x - w + 2, yy, "S")                   # shade on its far side
                    c.px(x + 1, yy, "S")                                                 # a seam down the middle
                for xx in (x - w + 3, x + w - 1):
                    c.px(xx + 1, y1 + 2, "."); c.px(xx + 2, y1 + 1, ".")                 # ragged tears at the foot
        poly(c, [(20, 3), (13, 1), (16, 3 + step), (12, 5)], "f")                         # tattered flag at the mast-head
        for t in range(10):
            c.px(58 + t, 35 - t // 2, "m")                                               # bowsprit
        poly(c, [(4, 30), (18, 33), (54, 33), (66, 30), (61, 42), (52, 47), (14, 47), (8, 42)], "b")   # curved hull
        poly(c, [(4, 22), (19, 24), (19, 34), (4, 31)], "b"); c.row(22, 4, 18, "y")       # high stern castle
        for x in (7, 11, 15):
            c.rect(x, 26, x + 1, 28, "w")                                                # its lit windows
        c.px(5, 20, "y"); c.px(5, 19, "w")                                               # stern lantern
        c.row(33, 18, 56, "y"); c.row(36, 7, 62, "y")                                    # rail, gold stripe
        for y in (39, 42, 45):
            c.row(y, 9, 58 - (y - 39), "B")                                              # planking
        for x in range(22, 56, 7):
            c.rect(x, 37, x + 1, 38, "B")                                                # gunports
        for x, y in ((2, 46), (66, 44), (36, 49), (14, 49), (56, 49)):
            c.px(x, y, "S")                                                              # spray
    return draw


DUTCHMAN_PAL = {"o": "#0a0a0e", "b": "#4a3220", "B": "#2a1a0e", "y": "#c8a040", "m": "#2a1e14", "s": "#d0c8b0",
                "S": "#8a8270", "r": "#5a4a3a", "f": "#7a1a1a", "w": "#ffd070"}
PHANTOM_PAL = {"o": "#4a6a6a", "b": "#7a9c94", "B": "#5a7a74", "y": "#c8f0e0", "m": "#6a8c86", "s": "#d8f4ec",
               "S": "#a0c8c0", "r": "#8ab0a8", "f": "#a8d8cc", "w": "#e8fff8"}


# --- The Shadow's Court (Andersen, "The Shadow", 1847) ---------------------------------------------------------------

def living_shadow(c, f):
    """A living shadow (Andersen, "The Shadow"): a flat, man-shaped blackness, long-limbed and thin, that walks about by
    itself, its edges faintly violet, its feet trailing away into a pool of shadow."""
    s = STEP[f]
    ellipse(c, 10, 22, 8, 1.6, "K")                                                      # the pool it trails into
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 15, x + 1 + d, 21, "k")
    poly(c, [(6, 7), (13, 7), (14, 16), (5, 16)], "k")                                   # thin body
    poly(c, [(6, 8), (3, 12), (2, 18), (4, 18), (5, 13)], "k"); poly(c, [(13, 8), (16, 12), (17, 18), (15, 18), (14, 13)], "k")   # long arms
    ellipse(c, 9, 3.5, 2.8, 3.2, "k")
    rim(c, "k", "p")
    c.px(8, 3, "e"); c.px(10, 3, "e")                                                    # faint eyes


LIVING_SHADOW_PAL = {"o": "#05040a", "k": "#14101c", "K": "#1e1a28", "p": "#4a3a6a", "e": "#a888e0"}


def lamp_moth(c, f):
    """A lamp moth (the lamplit balconies of the house opposite): a pale, dusty moth with eye-spots on its wings,
    feathery antennae and a furry body, fluttering."""
    up = f % 2
    t = 1 if up else 4
    poly(c, [(6, 5), (1, t), (0, t + 4), (3, 9), (6, 8)], "w"); poly(c, [(7, 5), (12, t), (13, t + 4), (10, 9), (7, 8)], "w")
    c.px(3, t + 2, "b"); c.px(10, t + 2, "b"); c.px(3, t + 3, "y"); c.px(10, t + 3, "y")   # eye-spots
    c.px(1, t + 3, "W"); c.px(12, t + 3, "W")
    c.rect(6, 4, 7, 10, "f"); c.px(6, 11, "F")                                           # furry body
    c.px(5, 3, "F"); c.px(4, 2, "F"); c.px(8, 3, "F"); c.px(9, 2, "F")                   # feathery antennae


LAMP_MOTH_PAL = {"o": "#2a241e", "w": "#e8dcc8", "W": "#b8ac98", "b": "#5a4a3a", "y": "#e8c060", "f": "#c8b49a",
                 "F": "#8a7a64"}


def learned_man(c, step):
    """The Learned Man (Andersen, "The Shadow"): the kind scholar from the cold north, grown so thin and grey that he
    looks like a shadow himself: gaunt and stooped, with thin grey hair, round spectacles, a long grey coat and a
    white cravat, a quill behind his ear and a stack of books under his arm."""
    person(c, step, cx=21, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="short", garment="robe",
           robe="g", robe_d="G", robe_l="l", belt=None, boots="k", eye="k")
    c.px(16, 13, "S"); c.px(25, 13, "S")                                                 # gaunt cheeks
    c.rect(18, 9, 19, 10, "i"); c.rect(22, 9, 23, 10, "i"); c.px(20, 9, "k")             # round spectacles
    c.px(19, 10, "k"); c.px(23, 10, "k")
    poly(c, [(19, 15), (23, 15), (22, 21), (20, 21)], "w")                               # white cravat
    for y in range(22, 50, 4):
        c.px(22, y, "k")                                                                 # buttons
    c.rect(26, 3, 26, 8, "q"); c.px(27, 2, "q"); c.px(25, 2, "Q")                        # quill behind his ear
    for k, col in enumerate(("r", "n", "u")):                                            # stack of books under his arm
        c.rect(7 - k, 26 + k * 3, 15 - k, 28 + k * 3, col); c.row(27 + k * 3, 7 - k, 7 - k, "w")
    for x, y in ((12, 52), (30, 52)):
        c.px(x, y, "K")


LEARNED_MAN_PAL = {"o": "#0e0e12", "k": "#1e1e24", "K": "#2a2a34", "g": "#6a6a74", "G": "#4e4e58", "l": "#8a8a94",
                   "s": "#d0c8c0", "S": "#a8a098", "h": "#9a9aa4", "H": "#6a6a74", "m": "#8a6a6a", "w": "#e8e0d0",
                   "i": "#c8e0f0", "q": "#f0f0f0", "Q": "#a8a8a8", "r": "#7a2a1a", "n": "#2a4a6a", "u": "#4a6a2a"}


def clear_sighted_princess(c, step):
    """The Princess Who Saw Too Clearly (Andersen, "The Shadow": she suffered from seeing far too clearly): a king's
    daughter with golden hair coiled high, a small gold crown, wide bright eyes that glint like light, a lace collar, and
    a pale silk gown with a sash and a jewelled hem, holding a little fan."""
    person(c, step, cx=21, skin="s", skin_d="S", hair="y", hair_d="Y", hair_style="bun", garment="gown",
           robe="w", robe_d="W", robe_l="v", belt="p", boots="k", arm_forward=True, crown="y", eye="b")
    c.rect(18, 9, 19, 10, "b"); c.rect(23, 9, 24, 10, "b")                               # wide, bright eyes
    c.px(18, 9, "L"); c.px(23, 9, "L")
    for x, y in ((15, 7), (27, 7), (14, 10), (28, 10)):
        c.px(x, y, "L")                                                                  # light glinting off them
    poly(c, [(16, 16), (21, 19), (26, 16), (25, 19), (21, 21), (17, 19)], "v")            # lace collar
    for x in range(12, 31, 3):
        c.px(x, 52, "j")                                                                 # jewelled hem
    poly(c, [(35, 20), (40, 16), (41, 21), (36, 23)], "p"); c.px(38, 19, "w")            # little fan


PRINCESS_PAL = {"o": "#120e14", "k": "#1e1a24", "w": "#ece8f6", "W": "#c4c0da", "v": "#ffffff", "s": "#f0dcd0",
                "S": "#c8b0a4", "y": "#e8c040", "Y": "#b08a20", "b": "#4aa0e8", "L": "#e8f8ff", "p": "#c87ab0",
                "j": "#4ae0c8", "m": "#c87a7a", "l": "#ece8f6"}


def the_shadow(c, step):
    """The Shadow (Andersen, "The Shadow"): the shadow turned gentleman, all in black and very fine: a tall black hat, a
    black frock coat, a white shirt-front and cravat, rings glinting on his fingers, a cane with a gold knob, a face as
    dark as a shadow with pale violet eyes, and his feet fading into a pool of shadow."""
    ellipse(c, 21, 53, 12, 2, "K")                                                       # the pool of shadow
    person(c, step, cx=21, skin="d", skin_d="k", hair="k", hair_d="k", hair_style="short", garment="tunic",
           robe="k", robe_d="K", legs="k", boots="k", belt=None, arm_forward=True, eye="p", mouth="k")
    poly(c, [(14, 17), (28, 17), (30, 40), (26, 42), (21, 34), (16, 42), (12, 40)], "k")   # frock coat and tails
    poly(c, [(19, 17), (23, 17), (23, 26), (19, 26)], "w"); c.px(21, 18, "k"); c.px(21, 21, "k")   # shirt-front
    c.row(17, 19, 23, "w")                                                               # cravat
    c.rect(15, 0, 27, 4, "k"); c.row(5, 12, 30, "k"); c.row(4, 15, 27, "K")              # tall black hat
    c.px(35, 23, "y"); c.px(7, 31, "y")                                                  # rings glinting
    c.rect(36, 24, 36, 52, "K"); ellipse(c, 36, 23, 1.6, 1.6, "y")                       # cane, gold knob
    rim(c, "kK", "q")
    c.px(19, 10, "p"); c.px(23, 10, "p")


THE_SHADOW_PAL = {"o": "#05040a", "k": "#14101c", "K": "#241e30", "d": "#2e2838", "w": "#e8e4f0", "p": "#c8a8f0",
                  "y": "#e8c040", "q": "#3e3456", "m": "#14101c", "l": "#14101c"}


# --- The Knockers' Deep (Hunt, 1865; Bottrell, 1870-73) --------------------------------------------------------------

def spriggan(c, f):
    """A spriggan (Hunt, 1865: the ugliest of the Cornish fairies, guarding buried treasure): a squat, grey-brown,
    big-headed little man with pointed ears, a huge nose, a scowl, long knobbly arms and a ragged mossy tunic, a gold
    coin clutched in his hand."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 21, "s"); c.row(22, x - 1 + d, x + 2 + d, "k"); c.row(23, x - 1 + d, x + 2 + d, "k")
    poly(c, [(5, 11), (14, 11), (15, 18), (4, 18)], "b"); c.px(5, 18, "B"); c.px(9, 18, "B"); c.px(13, 18, "B")   # ragged tunic
    c.px(7, 13, "m"); c.px(11, 15, "m")                                                  # moss
    poly(c, [(5, 11), (3, 13), (2, 18), (4, 18), (5, 14)], "s"); c.px(2, 19, "S")        # long knobbly arms
    poly(c, [(14, 11), (16, 13), (17, 18), (15, 18), (14, 14)], "s"); c.px(17, 19, "y")  # with a gold coin
    ellipse(c, 9, 6, 5, 4.5, "s"); c.px(5, 7, "S")                                       # big head
    poly(c, [(4, 5), (0, 2), (4, 7)], "s"); poly(c, [(14, 5), (18, 2), (14, 7)], "s")    # pointed ears
    c.row(4, 6, 8, "S"); c.row(4, 10, 12, "S")                                           # scowling brows
    c.px(7, 5, "e"); c.px(11, 5, "e")
    ellipse(c, 9, 7, 1.4, 1.6, "S"); c.px(9, 9, "S")                                     # huge nose
    c.row(10, 7, 11, "k"); c.px(8, 10, "w")                                              # scowl, a snaggle tooth
    c.row(1, 7, 11, "h"); c.px(6, 2, "h"); c.px(12, 2, "h")                              # wiry hair


SPRIGGAN_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#5a4a3a", "B": "#3a2e22", "s": "#8a7a6a", "S": "#64564a",
                "m": "#4a6a3a", "y": "#f0c840", "e": "#e8c040", "w": "#e8e0d0", "h": "#3a3028"}


def knocker(c, f):
    """A knocker (Hunt, 1865: the little folk of the tin mines, who knock where the rich lodes lie): a tiny big-headed
    miner-imp in a tinner's cap with a candle on it, swinging his hammer mid-knock."""
    up = f % 2
    c.px(4, 11, "k"); c.px(5, 11, "k"); c.px(8, 11, "k"); c.px(9, 11, "k")               # feet
    c.rect(4, 7, 8, 10, "b"); c.px(4, 8, "B")                                            # body
    ellipse(c, 6, 5, 3, 2.6, "s"); c.px(5, 5, "k"); c.px(7, 5, "k"); c.px(6, 6, "S")     # big head
    c.row(2, 3, 9, "h"); c.rect(4, 1, 8, 2, "h"); c.px(6, 0, "y")                        # tinner's cap with a candle
    c.px(9, 7, "s")
    if up:
        c.rect(10, 1, 10, 6, "w"); c.rect(9, 0, 12, 1, "i")                              # hammer raised
    else:
        c.rect(10, 7, 12, 7, "w"); c.rect(12, 6, 12, 9, "i"); c.px(12, 10, "y")          # hammer down, a spark


KNOCKER_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#6a5a42", "B": "#4a3e2c", "s": "#a8907a", "S": "#806a56",
               "h": "#4a3a2a", "y": "#ffd060", "w": "#7a5a3a", "i": "#9aa0a8"}


def piskie(c, f):
    """A piskie (Hunt, 1865: the little laughing folk who lead people astray): a tiny sprite in green with a pointed red
    cap, laughing, hopping, with a little glowing light bobbing beside it."""
    up = f % 2
    c.px(4, 11 - up, "k"); c.px(7, 11 - up, "k")
    c.rect(4, 7 - up, 7, 10 - up, "g"); c.px(4, 8 - up, "G")                             # green coat
    ellipse(c, 5.5, 4.5 - up, 2.2, 2, "s"); c.px(5, 4 - up, "k"); c.px(7, 4 - up, "k"); c.px(6, 6 - up, "m")   # laughing face
    poly(c, [(3, 3 - up), (8, 3 - up), (4, -1 - up)], "r")                               # pointed red cap
    c.px(2, 8 - up, "s"); c.px(9, 7 - up, "s")
    ellipse(c, 11, 4 + up, 1.4, 1.4, "y"); c.px(11, 4 + up, "Y")                         # the bobbing light


PISKIE_PAL = {"o": "#10180a", "k": "#1e1814", "g": "#5a9a3a", "G": "#3a6a24", "s": "#e0c0a0", "m": "#a84a3a",
              "r": "#c83a2a", "y": "#f8e080", "Y": "#ffffff"}


def old_knocker(c, step):
    """The Old Knocker (Hunt, 1865): the oldest knocker of the mine, a gnarled little old man with a long white beard,
    a big nose and bright eyes, in a tinner's hard hat with a candle stuck on it in a lump of clay, a leather jerkin,
    and a miner's pick over his shoulder."""
    person(c, step, cx=20, skin="s", skin_d="S", hair="w", hair_d="W", hair_style="short", beard="w",
           garment="tunic", robe="b", robe_d="B", legs="l", boots="k", belt="t", arm_forward=True, head_y=14)
    ellipse(c, 20, 16, 1.6, 1.4, "S")                                                    # big nose
    poly(c, [(15, 17), (25, 17), (24, 30), (20, 35), (16, 30)], "w")                     # long white beard
    c.px(18, 22, "W"); c.px(21, 26, "W"); c.px(19, 30, "W")
    ellipse(c, 20, 8, 7, 3, "h"); c.row(10, 11, 29, "h"); c.row(11, 12, 28, "H")         # tinner's hard hat
    ellipse(c, 20, 5, 1.6, 1.2, "c"); c.rect(20, 1, 20, 4, "w"); c.px(20, 0, "y"); c.px(21, 0, "Y")   # candle in clay
    for t in range(30):                                                                  # pick over his shoulder
        c.px(34 - t // 3, 36 - t, "t")
    poly(c, [(22, 6), (26, 4), (31, 5), (25, 7)], "i"); c.px(31, 6, "i")
    ellipse(c, 33, 26, 2, 2, "s")


OLD_KNOCKER_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#6a4e34", "B": "#4a3424", "l": "#5a4a3a", "s": "#c8a888",
                   "S": "#a08066", "w": "#ece8e0", "W": "#b8b4ac", "h": "#5a4a36", "H": "#3a2e22", "c": "#9a7a5a",
                   "y": "#ffd060", "Y": "#fff4c0", "t": "#6a4a2a", "i": "#9aa0a8", "m": "#8a5a4a"}


def joan_the_wad(c, step):
    """Joan the Wad (Hunt, 1865: "Jack o' the lantern, Joan the wad"): a little piskie woman with pointed ears and wild
    brown hair, in a green dress and a brown shawl, barefoot, laughing, holding up a burning wad of straw that lights
    her face."""
    person(c, step, cx=18, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="shoulder", garment="gown",
           robe="g", robe_d="G", robe_l="v", belt="h", boots="s", ears=True, arm_forward=True, mouth="m")
    poly(c, [(11, 17), (25, 17), (23, 26), (13, 26)], "u"); c.px(14, 24, "U"); c.px(22, 24, "U")   # brown shawl
    for x, y in ((13, 3), (23, 3), (12, 6), (24, 6)):
        c.px(x, y, "h")                                                                  # wild hair
    c.row(13, 17, 19, "m")                                                               # laughing
    c.rect(31, 12, 32, 24, "t")                                                          # the wad of straw on its stick
    ellipse(c, 31.5, 10, 3, 3, "t"); c.px(30, 11, "T"); c.px(33, 10, "T")
    for x, y, col in ((31, 6 - step, "r"), (30, 5, "r"), (32, 4 + step, "y"), (31, 3, "y"), (33, 7, "r"), (29, 7, "y"), (31, 1, "Y")):
        c.px(x, y, col)                                                                  # burning
    for x, y in ((27, 9), (26, 12), (24, 8)):
        c.px(x, y, "L")                                                                  # its light on her


JOAN_PAL = {"o": "#10140a", "k": "#1e1814", "g": "#4a7a3a", "G": "#345a28", "v": "#6a9a52", "s": "#e8c8a8",
            "S": "#c0a080", "h": "#6a4a2a", "H": "#4a3018", "m": "#a84a3a", "u": "#7a5a3a", "U": "#5a4028",
            "t": "#c8a860", "T": "#9a7a3a", "r": "#e8702a", "y": "#ffd060", "Y": "#fff8d0", "L": "#ffe8a0",
            "l": "#e8c8a8", "b": "#e8c8a8"}


def great_spriggan(scale):
    """The Spriggan (Hunt, 1865; Bottrell, 1870-73: the treasure guard who can swell to a giant's size): an ugly, knotted
    grey-brown fairy, hunched and lumpy, with a big head, a huge hooked nose, small glowing eyes, pointed ears, wild
    hair like roots, a wide snaggle-toothed grin, very long arms with knobbly hands, short bandy legs, a ragged mossy
    tunic and a pouch of gold at his belt; small in his own shape and huge when swollen."""
    def base(c, step):
        for x, d in ((16, -step), (26, step)):                                           # short bandy legs
            poly(c, [(x + d, 40), (x + 5 + d, 40), (x + 6 + d, 50), (x + 1 + d, 50)], "s")
            c.rect(x - 1 + d, 50, x + 7 + d, 52, "S"); c.px(x + d, 53, "k"); c.px(x + 6 + d, 53, "k")
        poly(c, [(12, 20), (34, 20), (36, 42), (10, 42)], "b")                           # hunched, lumpy body
        ellipse(c, 23, 26, 10, 6, "b"); ellipse(c, 18, 30, 4, 5, "B")
        for x in range(10, 37, 4):
            c.px(x, 42, "B"); c.px(x + 1, 43, "B")                                       # ragged hem
        for x, y in ((16, 24), (28, 30), (20, 36), (31, 24)):
            c.px(x, y, "m"); c.px(x + 1, y, "m")                                         # moss
        c.row(38, 11, 35, "B"); ellipse(c, 30, 40, 2.6, 2.2, "u"); c.px(30, 39, "y"); c.px(31, 41, "y")   # belt, pouch of gold
        poly(c, [(12, 21), (6, 26), (4, 44), (8, 45), (10, 30)], "s")                    # very long arms
        poly(c, [(34, 21), (40, 26), (42, 44), (38, 45), (36, 30)], "s")
        for x in (6, 40):
            ellipse(c, x, 46, 3, 2.6, "s"); c.px(x - 2, 48, "k"); c.px(x, 49, "k"); c.px(x + 2, 48, "k")   # knobbly hands
        c.px(5, 34, "S"); c.px(41, 34, "S")
        ellipse(c, 23, 12, 10, 9, "s"); c.px(14, 13, "S"); c.px(15, 16, "S")             # big head
        poly(c, [(14, 9), (6, 3), (13, 13)], "s"); poly(c, [(32, 9), (40, 3), (33, 13)], "s")   # pointed ears
        for x in range(14, 33, 2):
            c.px(x, 3 + (x % 3), "h"); c.px(x + 1, 2 + (x % 4), "h")                     # wild hair like roots
        c.row(8, 17, 21, "S"); c.row(8, 25, 29, "S")                                     # knotted brows
        c.px(19, 10, "e"); c.px(27, 10, "e")                                             # small glowing eyes
        poly(c, [(22, 10), (25, 10), (27, 16), (24, 18), (22, 16)], "S")                 # huge hooked nose
        c.row(19, 17, 29, "k"); c.px(18, 18, "k"); c.px(28, 18, "k")                     # wide grin
        c.px(20, 19, "w"); c.px(24, 19, "w"); c.px(27, 19, "w")                          # snaggle teeth

    def draw(c, step):
        if scale == 1.0:
            base(c, step)
            return
        small = kit.Canvas(46, 56)
        base(small, step)
        for y in range(c.h):
            for x in range(c.w):
                sx, sy = int(x / scale), int(y / scale)
                if sy < small.h and sx < small.w and small.g[sy][sx] != ".":
                    c.px(x, y, small.g[sy][sx])
    return draw


SPRIGGAN_BOSS_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#5a4a3a", "B": "#3a2e22", "s": "#8a7a6a", "S": "#64564a",
                     "e": "#ffd040", "m": "#4a6a3a", "h": "#3a3028", "w": "#e8e0d0", "u": "#7a5a3a", "y": "#f0c840"}


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
    kit.build_boss("flying_dutchman", flying_dutchman(False), DUTCHMAN_PAL, doc(flying_dutchman.__doc__), (70, 52), (35, 50), [0, 1, 0, -1, 0])
    kit.build_boss("flying_dutchman_phantom", flying_dutchman(True), PHANTOM_PAL, doc(flying_dutchman.__doc__ + " Here, as a phantom."), (70, 52), (35, 50), [0, 1, 0, -1, 0])
    kit.build_boss("living_shadow", living_shadow, LIVING_SHADOW_PAL, doc(living_shadow.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("lamp_moth", lamp_moth, LAMP_MOTH_PAL, doc(lamp_moth.__doc__), (14, 12), (7, 11), walk, folder="enemies")
    kit.build_boss("learned_man", learned_man, LEARNED_MAN_PAL, doc(learned_man.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    kit.build_boss("clear_sighted_princess", clear_sighted_princess, PRINCESS_PAL, doc(clear_sighted_princess.__doc__), (44, 56), (21, 54), [0, 1, 0, -1, 0])
    kit.build_boss("the_shadow", the_shadow, THE_SHADOW_PAL, doc(the_shadow.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("spriggan", spriggan, SPRIGGAN_PAL, doc(spriggan.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("knocker", knocker, KNOCKER_PAL, doc(knocker.__doc__), (13, 13), (6, 12), walk, folder="enemies")
    kit.build_boss("piskie", piskie, PISKIE_PAL, doc(piskie.__doc__), (13, 12), (6, 11), walk, folder="enemies")
    kit.build_boss("old_knocker", old_knocker, OLD_KNOCKER_PAL, doc(old_knocker.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    kit.build_boss("joan_the_wad", joan_the_wad, JOAN_PAL, doc(joan_the_wad.__doc__), (38, 56), (19, 54), [0, 1, 0, -1, 0])
    kit.build_boss("great_spriggan", great_spriggan(1.0), SPRIGGAN_BOSS_PAL, doc(great_spriggan.__doc__), (46, 56), (23, 54), [0, 1, 0, -1, 0])
    kit.build_boss("great_spriggan_swollen", great_spriggan(1.8), SPRIGGAN_BOSS_PAL, doc(great_spriggan.__doc__ + " Here, swollen."), (82, 100), (41, 98), [0, 1, 0, -1, 0])
    print("wrote Otherworlds' art")
