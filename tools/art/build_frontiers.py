# Wild Frontiers' art (Pack 13, docs/PACK_13_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Ovid; Apollodorus; Ibsen's Peer Gynt, 1867; Asbjørnsen and Moe; "The City of Brass" in the Nights, Burton
# 1885, without its jinn; Andersen's "The Little Mermaid", 1837), never later versions.
# Run: python3 build_frontiers.py from tools/art/.
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


def centaur(c, step, k=1.0, held=None):
    """A centaur (shared): a horse's body with a man's chest, arms and head where the horse's neck would be."""
    def r(v):
        return int(round(v * k))
    def leg(x, d, hind):
        """A slim horse's leg: thick at the top, a knee (or a hock bent back), a thin cannon, a dark hoof."""
        x = r(x) + d
        bend = -1 if hind else 0
        poly(c, [(x - 1, r(30)), (x + 2, r(30)), (x + 1, r(38)), (x, r(38))], "h")       # upper leg, tapering
        c.rect(x + bend, r(38), x + bend + max(1, r(1.2)), r(45), "h")                   # the thin cannon
        c.px(x + bend, r(38), "H")                                                       # the knee or hock
        c.rect(x + bend - 1, r(45), x + bend + max(1, r(1.2)), r(46), "H")               # the hoof
    leg(7, -step, True); leg(29, step, False)                                            # far legs
    n = max(r(14), 4)
    for i in range(n):                                                                   # flowing tail
        t = i / (n - 1)
        x = r(5) - r(4) * math.sin(t * math.pi / 2) + math.sin(t * 4 + step) * 0.6 * k
        y = r(24) + r(14) * t
        c.px(round(x), round(y), "H"); c.px(round(x) + 1, round(y), "H")
    ellipse(c, r(20), r(28), 14 * k, 6 * k, "b")                                         # barrel
    ellipse(c, r(8), r(27), 6 * k, 6 * k, "b")                                           # rounded rump
    ellipse(c, r(30), r(28), 5.5 * k, 6.5 * k, "b")                                      # deep chest
    ellipse(c, r(19), r(32), 11 * k, 2 * k, "h")                                         # belly in shadow
    leg(11, step, True); leg(33, -step, False)                                           # near legs
    poly(c, [(r(28), r(12)), (r(38), r(12)), (r(37), r(24)), (r(31), r(28))], "s")       # man's torso
    poly(c, [(r(28), r(12)), (r(30), r(12)), (r(31), r(27)), (r(29), r(22))], "S")
    c.row(r(17), r(31), r(36), "S"); c.px(r(34), r(20), "S"); c.px(r(34), r(22), "S")   # chest and belly
    ellipse(c, r(29), r(13), 2 * k, 2 * k, "s"); ellipse(c, r(37), r(13), 2 * k, 2 * k, "s")   # shoulders
    c.rect(r(26), r(14), r(27), r(22), "S"); c.px(r(26), r(23), "S")                     # far arm
    poly(c, [(r(37), r(12)), (r(39), r(11)), (r(42), r(10)), (r(42), r(13)), (r(38), r(15))], "s")   # near arm, raised
    c.rect(r(32), r(9), r(34), r(12), "S")                                               # neck
    ellipse(c, r(33.5), r(5), 3.2 * k, 3.6 * k, "s")                                     # head
    ellipse(c, r(33), r(1.5), 3.4 * k, 1.6 * k, "H"); c.rect(r(30), r(1), r(31), r(9), "H")   # wild hair, top and back
    poly(c, [(r(32), r(8)), (r(37), r(8)), (r(36), r(11)), (r(33), r(11))], "H")         # beard on the chin
    c.px(r(35), r(4), "o"); c.px(r(37), r(5), "S"); c.row(r(3), r(34), r(36), "H")       # eye, nose, brow
    if held:
        held(c, r)


# --- Mount Pelion (Ovid, Met. 9.98-133, 12.210-535; Apollodorus 2.5.4, 2.7.6) ---------------------------------------

def centaur_raider(c, f):
    """A centaur raider (Ovid, Met. 12: the wild centaurs of Pelion): a small galloping centaur with a club."""
    centaur(c, STEP[f], 0.5, lambda c, r: c.rect(r(42), r(4), r(44), r(16), "w"))


def centaur_slinger(c, f):
    """A centaur slinger (Ovid, Met. 12: centaurs hurling rocks): a small centaur with a stone raised to throw."""
    centaur(c, STEP[f], 0.5, lambda c, r: ellipse(c, r(42), r(9), 1.5, 1.5, "g"))


CENTAUR_PAL = {"S": "#a8744a", "o": "#120e0a", "h": "#5a3a1e", "b": "#8a6040", "H": "#3a2412", "s": "#c8946a", "w": "#6a4a2a",
               "g": "#9a9a92", "r": "#8a1a3a", "y": "#e8c040", "Y": "#b08a20", "f": "#f08a2a"}
EURYTUS_PAL = dict(CENTAUR_PAL, s="#d88a6a", S="#b0664a")


def eurytus(c, step):
    """Eurytus (Ovid, Met. 12.219-240: "wildest of the wild centaurs", drunk at the wedding): a big red-faced centaur
    with a great embossed wine-bowl held up in both hands, wine slopping over."""
    def bowl(c, r):
        ellipse(c, r(41), r(5), 6, 3, "y"); c.rect(r(36), r(3), r(46), r(4), "r"); c.row(r(6), r(37), r(45), "Y")
        for x in (37, 40, 43):
            c.px(x, 6, "Y")                                                              # embossing
    centaur(c, step, 1.0, bowl)
    c.px(43, 9, "r"); c.px(44, 11, "r"); c.px(38, 8, "r")                                # wine slopping over


def rhoetus(c, step):
    """Rhoetus (Ovid, Met. 12.271-290: he snatched a burning brand from the altar): a centaur swinging a blazing log."""
    def brand(c, r):
        c.rect(r(42), r(2), r(44), r(14), "w"); c.px(r(43), r(6), "H")
        ellipse(c, r(43), r(2), 3, 3, "f")
        for x, y in ((43, -1), (41, 0), (45, 0), (43, 1), (44, -2)):
            c.px(x, y, "y")                                                              # blazing
    centaur(c, step, 1.0, brand)


def nessus(c, step):
    """Nessus (Ovid, Met. 9.98-133: the ferryman centaur of the river Evenus): a dark, powerful centaur, his flank
    stained with his venomed blood, an arrow standing in his back."""
    def arrow(c, r):
        c.rect(r(22), r(14), r(23), r(24), "w"); c.px(r(22), r(13), "g"); c.px(r(23), r(13), "g")
        for x, y in ((18, 28), (22, 30), (26, 27)):
            c.px(r(x), r(y), "r")
    centaur(c, step, 1.0, arrow)


NESSUS_PAL = dict(CENTAUR_PAL, h="#2a1e14", b="#4a3626", H="#1a120a", s="#a8785a", S="#7a5a3a", r="#5a8a2a")


# --- Dovrefjell (Ibsen, Peer Gynt, 1867; Asbjørnsen and Moe, 1841-44) -----------------------------------------------

def troll_head(c, x, y, k=1.0, eye=True, col="g", shade="G"):
    """A Norwegian troll's head (Asbjørnsen and Moe; Peer Gynt), facing right: a lumpy skull, shaggy hair, small
    eyes, big ears and a long drooping nose with a wart."""
    ellipse(c, x, y, 4.5 * k, 4.2 * k, col)
    for i in range(int(6 * k) + 1):
        c.px(x - round(4 * k) + i, y - round(4 * k) - (i % 2), "h")                      # shaggy hair
    c.rect(x - round(5 * k), y - round(3 * k), x - round(4 * k), y + round(2 * k), "h")
    ellipse(c, x - 3.6 * k, y + 0.5, 1.2 * k, 1.8 * k, shade)                            # big ear
    poly(c, [(x + round(2 * k), y - 1), (x + round(7 * k), y + round(3 * k)), (x + round(6 * k), y + round(5 * k)), (x + round(2 * k), y + round(2 * k))], shade)   # long drooping nose
    c.px(x + round(5 * k), y + round(2 * k), "W")                                        # a wart
    if eye:
        c.px(x + 1, y - 1, "k"); c.px(x - 1, y - 1, "k")
    else:
        c.px(x + 1, y - 1, "K"); c.px(x - 1, y - 1, "K")                                 # empty sockets
    c.row(y + round(3 * k), x - 1, x + 1, "k")                                           # mouth


def tail(c, x, y, n, step):
    """A troll's cow-tail with a tuft at its end."""
    for i in range(n):
        c.px(x - i // 2, y + i, "G")
    ellipse(c, x - n // 2, y + n, 1.4, 1.6, "h")


def dovre_troll(c, f):
    """A Dovre troll (Peer Gynt: the Dovre-King's courtiers; Asbjørnsen and Moe): a lumpy green-grey troll with a long
    drooping nose, small eyes and big ears, shaggy hair, a pot belly in a mossy hide, a cow's tail with a tuft, and a
    knotted club."""
    s = STEP[f]
    tail(c, 4, 14, 7, s)
    for x, d in ((6, -s), (11, s)):
        c.rect(x + d, 18, x + 2 + d, 21, "g"); c.row(22, x - 1 + d, x + 3 + d, "G"); c.row(23, x - 1 + d, x + 3 + d, "k")
    ellipse(c, 9, 14, 5.5, 5.5, "g"); ellipse(c, 10, 15, 3.5, 3.5, "v")                 # pot belly
    poly(c, [(4, 16), (14, 16), (14, 19), (4, 19)], "f"); c.px(6, 17, "m"); c.px(11, 18, "m")   # mossy hide
    c.rect(3, 11, 4, 17, "G"); c.px(3, 18, "g")                                          # far arm
    troll_head(c, 10, 6)
    c.rect(15, 11, 16, 13, "g")                                                          # near arm
    for t in range(9):
        c.px(17 + t // 4, 14 - t, "b")                                                   # club
    ellipse(c, 19, 5, 1.6, 1.6, "b")


DOVRE_TROLL_PAL = {"o": "#10140e", "k": "#1a1e14", "K": "#0a0c08", "g": "#6a7a5a", "G": "#4a5a3a", "v": "#7a8a68",
                   "h": "#3a3226", "W": "#8a6a5a", "f": "#5a4a36", "m": "#4a7a3a", "b": "#5a3a1a"}


def troll_brat(c, f):
    """A troll brat (Peer Gynt: the Dovre-King's troll children, who bit and pinched Peer): a small, big-headed troll
    child with a long nose, a grin, little claws reaching out, and a tufted tail."""
    up = f % 2
    tail(c, 3, 8 - up, 3, 0)
    c.px(4, 12, "k"); c.px(7, 12, "k")
    ellipse(c, 6, 9, 3, 2.5, "g")
    troll_head(c, 6, 5 - up, 0.7)
    c.px(10, 8 - up, "g"); c.px(11, 7 - up, "w"); c.px(11, 9 - up, "w")                  # little claws, pinching


TROLL_BRAT_PAL = dict(DOVRE_TROLL_PAL, w="#e8e0d0")


def hedal_trolls(c, step):
    """The Hedal Trolls (Asbjørnsen and Moe, "The Boys Who Met the Trolls in the Hedal Woods": three trolls with only
    one eye between them, which they passed from one to another): three huge grey trolls shoulder to shoulder, long
    nosed and shaggy, two with empty sockets groping with their hands, the middle one holding the single glowing eye up
    in his fist."""
    for k, (x, sz) in enumerate(((12, 1.0), (40, 1.0), (26, 1.15))):                    # back two first, the middle one in front
        d = step if k % 2 else -step
        tail(c, x - 8, 34, 8, step)
        for lx in (x - 5, x + 2):
            c.rect(lx + d, 44, lx + 3 + d, 53, "G"); c.row(54, lx - 1 + d, lx + 4 + d, "k")
        ellipse(c, x, 34, 9 * sz, 12 * sz, "g" if k < 2 else "v")                        # hulking body
        ellipse(c, x + 1, 38, 6 * sz, 5 * sz, "G")
        poly(c, [(x - 8, 42), (x + 8, 42), (x + 7, 47), (x - 7, 47)], "f")               # hide
        troll_head(c, x, 17 - round(sz * 2), 1.6 * sz, eye=False, col="g" if k < 2 else "v")
        if k < 2:
            c.rect(x + 7, 26, x + 9, 34, "g"); c.px(x + 10, 35, "g"); c.px(x + 11, 34, "g")   # groping hands
    c.rect(33, 22, 35, 30, "v"); ellipse(c, 34, 20, 2.8, 2.8, "v")                       # the middle one's fist, raised
    ellipse(c, 34, 17, 2.4, 2.4, "w"); c.px(34, 17, "e"); c.px(35, 17, "k")              # the single eye
    for x, y in ((31, 14), (37, 14), (34, 13)):
        c.px(x, y, "e")                                                                  # glowing


HEDAL_PAL = {"o": "#10120e", "k": "#2a2e24", "K": "#0a0c08", "g": "#7a8070", "G": "#5a6050", "v": "#8a907e",
             "h": "#3a3a30", "W": "#8a6a5a", "f": "#5a4a36", "w": "#f0ece0", "e": "#f0c040"}


def great_boyg(c, step):
    """The Great Bøyg (Peer Gynt, Act II: the shapeless, slimy thing in the dark that can't be fought, only gone round,
    and says "Go round about"): a vast heap of slimy coils of darkness with a dull sheen along them, no face at all,
    mist creeping from under it."""
    coils = []
    for k in range(7):
        a = k / 7 * math.tau + step * 0.15
        coils.append((30 + 15 * math.cos(a), 30 + 9 * math.sin(a), 9 - (k % 3)))
    for x, y, r in sorted(coils, key=lambda p: p[1]):                                    # coils, back to front
        ellipse(c, x, y, r + 1, r * 0.8 + 1, "K"); ellipse(c, x, y, r, r * 0.8, "k")
        for t in range(-3, 4):
            c.px(round(x + t), round(y - r * 0.8 + 1 + abs(t) // 2), "s")               # slimy sheen along the top
    ellipse(c, 30, 26, 10, 9, "k")                                                       # its heaped middle
    for t in range(-5, 6):
        c.px(30 + t, 18 + abs(t) // 2, "s")
    for x in range(4, 58, 3):
        c.px(x, 44 + (x + step) % 3, "m"); c.px(x + 1, 45 + (x + step) % 2, "M")        # mist creeping from under it
    for x, y in ((14, 14), (46, 12), (8, 26)):
        c.px(x, y, "M")


BOYG_PAL = {"o": "#05060a", "k": "#1a2024", "K": "#0e1216", "s": "#4a5a52", "m": "#6a7478", "M": "#4a5458"}


def mountain_king(c, step):
    """The Mountain King (Peer Gynt: the old Dovre-King on his throne, with crown and sceptre): an old troll king with
    green-grey skin, a huge drooping nose, small eyes, big ears and a long white beard, a gold crown, a royal red cloak
    with an ermine collar over a green robe, a sceptre, and his cow's tail with its tuft hanging below the cloak."""
    for i in range(10):
        c.px(9 - i // 3, 42 + i, "G")
    ellipse(c, 6, 52, 1.6, 1.8, "h")                                                     # cow's tail and tuft
    person(c, step, cx=20, skin="g", skin_d="G", hair="w", hair_d="W", hair_style="short", garment="robe",
           robe="v", robe_d="V", robe_l="l", belt="y", boots="k", cloak=("r", "R"), arm_forward=True)
    ellipse(c, 15, 11, 1.4, 2.2, "G"); ellipse(c, 25, 11, 1.4, 2.2, "G")                 # big ears
    poly(c, [(21, 9), (27, 13), (26, 16), (21, 13)], "G"); c.px(25, 13, "W")             # huge drooping nose, a wart
    poly(c, [(15, 14), (25, 14), (24, 26), (20, 32), (16, 26)], "w")                     # long white beard
    c.px(18, 20, "W"); c.px(21, 24, "W")
    poly(c, [(12, 16), (28, 16), (27, 20), (13, 20)], "w"); c.px(15, 18, "k"); c.px(20, 17, "k"); c.px(25, 18, "k")   # ermine collar
    for x in range(14, 27, 3):
        c.rect(x, 2, x, 5, "y"); c.px(x, 1, "Y")                                         # gold crown
    c.row(5, 14, 26, "y"); c.px(20, 4, "j")
    c.rect(35, 10, 35, 50, "y"); ellipse(c, 35, 9, 2, 2, "y"); c.px(35, 9, "j")          # sceptre


MOUNTAIN_KING_PAL = {"o": "#10140e", "k": "#1a1e14", "r": "#8a2a2a", "R": "#5a1a1a", "g": "#7a8a6a", "G": "#5a6a4a",
                     "v": "#3a5a3a", "V": "#2a4228", "l": "#5a7a50", "w": "#ece8e0", "W": "#b8b4ac", "h": "#3a3226",
                     "y": "#e8c040", "Y": "#fff0a0", "j": "#e83a3a", "m": "#4a3a30", "s": "#7a8a6a", "S": "#5a6a4a"}


# --- The City of Brass ("The City of Brass", the Nights; Burton, 1885; no jinn) --------------------------------------

def brass_soldier(c, f):
    """A brass soldier (the tale's brass figures): a stiff automaton of polished brass with a round shield."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "B")
    c.rect(6, 8, 13, 17, "y"); c.row(12, 6, 13, "B")
    c.rect(7, 2, 12, 7, "y"); c.rect(8, 4, 11, 4, "k")
    ellipse(c, 4, 12, 3, 4, "B"); c.px(4, 12, "y")
    c.rect(15, 4, 15, 18, "s")


BRASS_SOLDIER_PAL = {"o": "#2a1a08", "k": "#1a1008", "y": "#d8a840", "B": "#9a6a1a", "s": "#c8ccd4"}


def locust(c, f):
    """A locust (the desert road): a long green-brown grasshopper with whirring wings."""
    up = f % 2
    c.rect(2, 6, 11, 7, "g"); c.px(12, 6, "k")
    poly(c, [(4, 6), (10, 2 + up), (11, 5)], "w")
    c.px(4, 9, "G"); c.px(7, 9, "G"); c.px(3, 10, "G")


LOCUST_PAL = {"o": "#1a1408", "g": "#8a8a3a", "G": "#5a5a2a", "w": "#d8d4b0", "k": "#1a1408"}


def wall_watcher(c, step):
    """The Watcher on the Wall ("The City of Brass": the vision that beckoned each man who climbed the wall): a tall,
    veiled figure of shimmering light standing on a brass battlement, one hand raised to beckon."""
    c.rect(4, 42, 38, 52, "B"); c.row(42, 4, 38, "y")
    for x in range(4, 38, 8):
        c.rect(x, 38, x + 4, 42, "B")
    poly(c, [(15, 10), (27, 10), (31, 40), (11, 40)], "w")
    ellipse(c, 21, 7, 5, 5, "W")
    c.rect(28, 4 - step, 30, 14, "W")
    for x, y in ((14, 20), (26, 26), (18, 34)):
        c.px(x, y, "y")


WATCHER_PAL = {"o": "#4a3a20", "w": "#f4ecd8", "W": "#fff8e8", "y": "#e8c040", "B": "#9a6a1a"}


def queens_guardians(c, step):
    """The Queen's Guardians ("The City of Brass": two automatons with swords beside the dead queen's bier): two
    figures, one of steel and one of brass, each with a raised sword."""
    for k, (body, dark) in enumerate((("s", "S"), ("y", "B"))):
        x0 = 4 + k * 22
        for i, d in enumerate((-step, step)):
            c.rect(x0 + 3 + i * 6 + d, 44, x0 + 5 + i * 6 + d, 54, dark)
        c.rect(x0, 18, x0 + 14, 44, body); c.row(30, x0, x0 + 14, dark)
        c.rect(x0 + 3, 6, x0 + 11, 16, body); c.rect(x0 + 4, 10, x0 + 10, 10, "k")
        c.rect(x0 + 16, 2, x0 + 17, 30, "W"); c.rect(x0 + 14, 28, x0 + 19, 29, dark)


GUARDIANS_PAL = {"o": "#1a1408", "k": "#1a1008", "s": "#a8acb4", "S": "#6a6e76", "y": "#d8a840", "B": "#9a6a1a",
                 "W": "#e8ecf4"}


def brass_horseman(c, step):
    """The Brass Horseman ("The City of Brass": the horseman of brass on a pillar, spear in hand, who points the way):
    a rider and horse all of brass, the spear levelled."""
    for i, d in enumerate((-step, step, step, -step)):
        c.rect(14 + i * 8 + d, 36, 16 + i * 8 + d, 50, "B")
    ellipse(c, 28, 32, 16, 7, "y")
    poly(c, [(40, 30), (48, 18), (54, 22), (46, 34)], "y"); c.px(51, 21, "k")
    c.rect(24, 12, 32, 28, "y"); c.rect(25, 4, 31, 11, "y"); c.rect(24, 2, 32, 4, "B")
    c.px(27, 7, "k"); c.px(30, 7, "k")
    c.rect(18, 16, 60, 17, "B"); poly(c, [(60, 14), (64, 16), (60, 19)], "s")
    for i in range(6):
        c.px(12 - i, 30 + i, "B")


HORSEMAN_PAL = {"o": "#2a1a08", "k": "#1a1008", "y": "#d8a840", "B": "#9a6a1a", "s": "#c8ccd4"}


# --- The Sea King's Hall (Andersen, "The Little Mermaid", 1837) -------------------------------------------------------

def water_snake(c, f):
    """A water snake (Andersen: the Sea Witch's fat water-snakes, "her little chickens"): a thick, slimy green-brown
    snake, swimming."""
    for k in range(9):
        ellipse(c, 2 + k * 2, 12 + round(3 * math.sin(k / 1.6 + f * 0.8)), 2.5, 2, "g" if k % 2 else "G")
    ellipse(c, 19, 12 + round(3 * math.sin(8 / 1.6 + f * 0.8)), 3, 2.5, "g"); c.px(20, 11 + round(3 * math.sin(8 / 1.6 + f * 0.8)), "y")


WATER_SNAKE_PAL = {"o": "#0e140a", "g": "#5a6a3a", "G": "#3a4a2a", "y": "#e8d040"}


def silver_fish(c, f):
    """A silver fish (Andersen: the little fish that swim in and out of the Sea King's windows)."""
    up = f % 2
    ellipse(c, 6, 5, 4, 2.5, "s"); poly(c, [(2, 5), (0, 2 + up), (0, 8 - up)], "S")
    c.px(8, 4, "k"); c.row(6, 4, 8, "w")


SILVER_FISH_PAL = {"o": "#2a3a4a", "s": "#c8d8e8", "S": "#8aa0b8", "w": "#ffffff", "k": "#1a2a3a"}


def polyp_wood(c, step):
    """The Polyp Wood (Andersen: the polyps round the Sea Witch's house, half animal and half plant, like
    hundred-headed snakes, holding the white bones of drowned men): a thicket of slimy, writhing green arms rising from
    the sea floor."""
    ellipse(c, 30, 48, 24, 6, "G")
    for k in range(7):
        x0 = 8 + k * 7
        for y in range(48, 10 + (k % 3) * 6, -1):
            x = x0 + round(3 * math.sin(y / 5.0 + k + step * 0.5))
            c.rect(x, y, x + 2, y, "g" if (y + k) % 4 else "G")
        c.px(x0 + round(3 * math.sin(11 / 5.0 + k)), 10 + (k % 3) * 6, "p")
    c.rect(20, 44, 30, 45, "w"); c.px(19, 43, "w"); c.px(31, 43, "w")


POLYP_PAL = {"o": "#0e140a", "g": "#6a8a4a", "G": "#4a6a3a", "p": "#c87a8a", "w": "#e8e4dc"}


def witch_snakes(c, step):
    """The Witch's Water Snakes (Andersen: the Sea Witch's "little chickens"): a knot of great fat water-snakes,
    coiled and rearing."""
    for k in range(14):
        a = k / 14 * math.tau
        ellipse(c, 28 + round(16 * math.cos(a)), 34 + round(9 * math.sin(a)), 5, 4, "g" if k % 2 else "G")
    for x, h in ((18, 14), (36, 8)):
        for y in range(34, h, -1):
            c.rect(x + round(2 * math.sin(y / 3.0 + step)), y, x + 3 + round(2 * math.sin(y / 3.0 + step)), y, "g")
        ellipse(c, x + 2, h, 4, 3, "G"); c.px(x + 3, h - 1, "y")


SNAKES_PAL = WATER_SNAKE_PAL


def sea_witch(c, step):
    """The Sea Witch (Andersen, 1837; not any film): a squat old witch on the sea floor, her hair like sea-weed, a fat
    water-snake round her shoulders and a toad on her hand."""
    figure(c, step, "d", "s", "g")
    c.rect(10, 4, 14, 26, "g"); c.rect(29, 4, 33, 26, "g")
    for k in range(10):
        c.px(12 + k * 2, 20 + round(2 * math.sin(k)), "G")
    ellipse(c, 34, 32, 3, 2, "t"); c.px(35, 31, "y")
    c.px(18, 10, "y"); c.px(23, 10, "y")


SEA_WITCH_PAL = {"o": "#0a0e10", "k": "#141a1e", "d": "#2a3a3a", "s": "#8aa098", "g": "#3a5a2a", "G": "#5a6a3a",
                 "t": "#6a7a3a", "y": "#e8d040"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_frontiers.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("centaur_raider", centaur_raider, CENTAUR_PAL, doc(centaur_raider.__doc__), (24, 26), (12, 25), walk, folder="enemies")
    kit.build_boss("centaur_slinger", centaur_slinger, CENTAUR_PAL, doc(centaur_slinger.__doc__), (24, 26), (12, 25), walk, folder="enemies")
    kit.build_boss("eurytus", eurytus, EURYTUS_PAL, doc(eurytus.__doc__), (48, 50), (22, 48), [0, 1, 0, -1, 0])
    kit.build_boss("rhoetus", rhoetus, CENTAUR_PAL, doc(rhoetus.__doc__), (48, 50), (22, 48), [0, 1, 0, -1, 0])
    kit.build_boss("nessus", nessus, NESSUS_PAL, doc(nessus.__doc__), (48, 50), (22, 48), [0, 1, 0, -1, 0])
    kit.build_boss("dovre_troll", dovre_troll, DOVRE_TROLL_PAL, doc(dovre_troll.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("troll_brat", troll_brat, TROLL_BRAT_PAL, doc(troll_brat.__doc__), (13, 13), (6, 12), walk, folder="enemies")
    kit.build_boss("hedal_trolls", hedal_trolls, HEDAL_PAL, doc(hedal_trolls.__doc__), (58, 58), (28, 56), [0, 1, 0, -1, 0])
    kit.build_boss("great_boyg", great_boyg, BOYG_PAL, doc(great_boyg.__doc__), (60, 52), (30, 50), [0, 1, 0, -1, 0])
    kit.build_boss("mountain_king", mountain_king, MOUNTAIN_KING_PAL, doc(mountain_king.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("brass_soldier", brass_soldier, BRASS_SOLDIER_PAL, doc(brass_soldier.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("locust", locust, LOCUST_PAL, doc(locust.__doc__), (14, 12), (7, 11), walk, folder="enemies")
    kit.build_boss("wall_watcher", wall_watcher, WATCHER_PAL, doc(wall_watcher.__doc__), (42, 54), (21, 52), [0, 1, 0, -1, 0])
    kit.build_boss("queens_guardians", queens_guardians, GUARDIANS_PAL, doc(queens_guardians.__doc__), (48, 56), (24, 54), [0, 1, 0, -1, 0])
    kit.build_boss("brass_horseman", brass_horseman, HORSEMAN_PAL, doc(brass_horseman.__doc__), (66, 52), (32, 50), [0, 1, 0, -1, 0])
    kit.build_boss("water_snake", water_snake, WATER_SNAKE_PAL, doc(water_snake.__doc__), (24, 20), (12, 19), walk, folder="enemies")
    kit.build_boss("silver_fish", silver_fish, SILVER_FISH_PAL, doc(silver_fish.__doc__), (12, 10), (6, 9), walk, folder="enemies")
    kit.build_boss("polyp_wood", polyp_wood, POLYP_PAL, doc(polyp_wood.__doc__), (60, 54), (30, 52), [0, 1, 0, -1, 0])
    kit.build_boss("witch_snakes", witch_snakes, SNAKES_PAL, doc(witch_snakes.__doc__), (56, 46), (28, 44), [0, 1, 0, -1, 0])
    kit.build_boss("sea_witch", sea_witch, SEA_WITCH_PAL, doc(sea_witch.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    print("wrote Wild Frontiers' art")
