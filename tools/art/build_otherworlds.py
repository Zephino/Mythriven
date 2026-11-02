# Otherworlds' art (Pack 12, docs/PACK_12_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Coimín's lay of Oisín; Lady Wilde; Yeats; O'Flaherty and the 1675 O-Brazile pamphlet; the Flying Dutchman
# legend of 1795-1821; Andersen's "The Shadow", 1847; Hunt and Bottrell's Cornish collections), never later versions.
# Run: python3 build_otherworlds.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly
from figure_kit import person

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
    """A living shadow (Andersen, "The Shadow"): a flat, man-shaped blackness that walks about by itself."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 16, x + 1 + d, 22, "k")
    poly(c, [(6, 8), (13, 8), (14, 17), (5, 17)], "k")
    ellipse(c, 9, 4, 3, 3.5, "k")
    c.rect(3, 9, 4, 15, "K"); c.rect(15, 9, 16, 15, "K")
    c.px(8, 4, "p"); c.px(11, 4, "p")


LIVING_SHADOW_PAL = {"o": "#05040a", "k": "#14101c", "K": "#1e1a28", "p": "#5a4a7a"}


def lamp_moth(c, f):
    """A lamp moth (the lamplit balconies of the southern city): a pale, dusty moth."""
    up = f % 2
    poly(c, [(6, 6), (1, 2 if up else 5), (2, 9), (6, 8)], "w"); poly(c, [(7, 6), (12, 2 if up else 5), (11, 9), (7, 8)], "W")
    c.rect(6, 5, 7, 9, "b"); c.px(5, 4, "b"); c.px(8, 4, "b")


LAMP_MOTH_PAL = {"o": "#2a241e", "w": "#e0d4c0", "W": "#c8bca8", "b": "#5a4a3a"}


def learned_man(c, step):
    """The Learned Man (Andersen, "The Shadow"): the kind scholar from the cold north, grown so thin and grey that he
    looks like a shadow himself, a book under his arm."""
    figure(c, step, "g", "s", "h", x0=15)
    c.rect(12, 24, 16, 32, "b"); c.row(28, 12, 16, "w")
    c.rect(19, 9, 25, 10, "k"); c.px(18, 10, "k"); c.px(26, 10, "k")


LEARNED_MAN_PAL = {"o": "#0e0e12", "k": "#1e1e24", "g": "#6a6a74", "s": "#c8c4c0", "h": "#9a9aa4", "b": "#5a2a1a",
                   "w": "#e8e0d0"}


def clear_sighted_princess(c, step):
    """The Princess Who Saw Too Clearly (Andersen, "The Shadow"): a king's daughter in a pale silk gown and a small
    crown, her eyes wide and bright."""
    figure(c, step, "w", "s", "y")
    poly(c, [(10, 30), (34, 30), (38, 50), (6, 50)], "W")
    c.rect(16, 1, 27, 3, "y"); c.px(18, 0, "y"); c.px(21, 0, "y"); c.px(24, 0, "y")
    c.rect(17, 9, 19, 11, "b"); c.rect(23, 9, 25, 11, "b"); c.px(18, 10, "k"); c.px(24, 10, "k")


PRINCESS_PAL = {"o": "#120e14", "k": "#1e1a24", "w": "#e8e4f4", "W": "#c8c4dc", "s": "#f0dcd0", "y": "#e8c040",
                "b": "#a8d8ff"}


def the_shadow(c, step):
    """The Shadow (Andersen, "The Shadow"): the shadow turned gentleman, all in black, very fine, in a tall hat, with
    rings on his fingers and a face as dark as a shadow's."""
    figure(c, step, "k", "d", "k")
    c.rect(16, 0, 27, 3, "k"); c.rect(14, 3, 29, 4, "k")
    c.rect(19, 18, 24, 22, "w")
    c.px(18, 10, "p"); c.px(24, 10, "p")
    for x, y in ((12, 32), (31, 32)):
        c.px(x, y, "y")


THE_SHADOW_PAL = {"o": "#05040a", "k": "#14101c", "d": "#2e2838", "w": "#e8e4f0", "p": "#a888e0", "y": "#e8c040"}


# --- The Knockers' Deep (Hunt, 1865; Bottrell, 1870-73) --------------------------------------------------------------

def spriggan(c, f):
    """A spriggan (Hunt, 1865: the ugliest of the Cornish fairies, guarding buried treasure): a squat, grey-brown,
    big-headed little man with a scowl."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    c.rect(5, 10, 14, 18, "b")
    ellipse(c, 9, 6, 5, 4.5, "s")
    c.px(7, 5, "k"); c.px(11, 5, "k"); c.row(8, 7, 11, "k")
    c.rect(3, 11, 4, 16, "s"); c.rect(15, 11, 16, 16, "s")


SPRIGGAN_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#5a4a3a", "s": "#8a7a6a"}


def knocker(c, f):
    """A knocker (Hunt, 1865: the little folk of the tin mines): a tiny miner-imp with a hammer, mid-knock."""
    up = f % 2
    c.rect(4, 6, 8, 10, "b"); ellipse(c, 6, 4, 2.5, 2, "s"); c.px(5, 4, "k"); c.px(7, 4, "k")
    c.rect(9, 2 + up, 9, 7, "w"); c.rect(8, 1 + up, 11, 2 + up, "i")
    c.px(4, 11, "k"); c.px(8, 11, "k")


KNOCKER_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#6a5a42", "s": "#a8907a", "w": "#7a5a3a", "i": "#8a8e96"}


def piskie(c, f):
    """A piskie (Hunt, 1865: the little laughing folk who lead people astray): a tiny green-clad sprite, laughing,
    with a spark of light."""
    up = f % 2
    c.rect(4, 6 - up, 7, 10 - up, "g"); ellipse(c, 5, 3 - up, 2, 2, "s"); c.px(5, 3 - up, "k")
    poly(c, [(4, 1 - up), (6, -2 - up), (7, 1 - up)], "g")
    c.px(10, 2 + up, "y"); c.px(11, 3 + up, "y")


PISKIE_PAL = {"o": "#10180a", "k": "#1e1814", "g": "#5a9a3a", "s": "#e0c0a0", "y": "#f8e080"}


def old_knocker(c, step):
    """The Old Knocker (Hunt, 1865): the oldest knocker of the mine, a gnarled little old man in a tinner's hat with a
    candle stuck on it, and a pick in his hand."""
    figure(c, step, "b", "s", "w", x0=15, top=22)
    c.rect(15, 5, 29, 7, "h"); c.rect(18, 2, 26, 5, "h"); c.rect(21, 0, 22, 2, "y")
    poly(c, [(18, 26), (26, 26), (24, 38), (20, 38)], "w")
    c.rect(33, 16, 34, 44, "t"); poly(c, [(28, 16), (40, 14), (40, 17), (28, 18)], "i")


OLD_KNOCKER_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#5a4a3a", "s": "#c8a888", "w": "#e8e4dc", "h": "#4a3a2a",
                   "y": "#f8d060", "t": "#6a4a2a", "i": "#8a8e96"}


def joan_the_wad(c, step):
    """Joan the Wad (Hunt, 1865: "Jack o' the lantern, Joan the wad"): a little piskie woman in green and brown, holding
    up a burning wad of straw that lights her laughing face."""
    figure(c, step, "g", "s", "h", x0=14, top=24, bottom=50)
    c.rect(30, 14, 31, 30, "t")
    ellipse(c, 30, 11, 4, 5, "r"); ellipse(c, 30, 12, 2, 3, "y")
    c.row(19, 18, 23, "k")


JOAN_PAL = {"o": "#10140a", "k": "#1e1814", "g": "#4a7a3a", "s": "#e0c0a0", "h": "#6a4a2a", "t": "#c8a860",
            "r": "#e8702a", "y": "#ffd060"}


def great_spriggan(scale):
    """The Spriggan (Hunt, 1865; Bottrell, 1870-73: the treasure guard who can swell to a giant's size): an ugly,
    knotted grey-brown fairy with long arms, small in his own shape and huge when swollen."""
    def draw(c, step):
        k = scale
        for i, d in enumerate((-step, step)):
            c.rect(int((14 + i * 12) * k) + d, int(40 * k), int((20 + i * 12) * k) + d, int(52 * k), "b")
        ellipse(c, int(23 * k), int(30 * k), 14 * k, 12 * k, "b")
        ellipse(c, int(23 * k), int(12 * k), 9 * k, 8 * k, "s")
        c.px(int(19 * k), int(11 * k), "e"); c.px(int(27 * k), int(11 * k), "e")
        c.row(int(16 * k), int(19 * k), int(27 * k), "k")
        c.rect(int(4 * k), int(22 * k), int(9 * k), int(44 * k), "s"); c.rect(int(37 * k), int(22 * k), int(42 * k), int(44 * k), "s")
        for x, y in ((16, 26), (28, 34), (20, 38)):
            c.px(int(x * k), int(y * k), "B")
    return draw


SPRIGGAN_BOSS_PAL = {"o": "#120e0a", "k": "#1e1814", "b": "#5a4a3a", "B": "#3a2e22", "s": "#8a7a6a", "e": "#e8c040"}


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
