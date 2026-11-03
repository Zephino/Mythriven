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
    """A centaur (shared): a horse's body, with a rounded haunch, a deep chest and slim jointed legs, and a man's
    torso, arms and bearded head rising where the horse's neck would be. Drawn on a 56x60 picture at k=1."""
    def r(v):
        return int(round(v * k))

    def seg(ax, ay, bx, by, w, col):
        n = max(abs(r(bx) - r(ax)), abs(r(by) - r(ay)), 1)
        for t in range(n + 1):
            x = r(ax) + (r(bx) - r(ax)) * t / n
            y = r(ay) + (r(by) - r(ay)) * t / n
            ellipse(c, x, y, max(w * k, 0.6), max(w * k, 0.6), col)

    def hind(x, d, col, shade):
        """A hind leg: thigh, gaskin sloping back to the hock, a straight cannon, fetlock and hoof."""
        seg(x, 40, x - 2, 49, 2.2, col); seg(x - 2, 49, x - 1 + d, 56, 1.2, col)
        c.px(r(x - 2), r(49), shade)
        c.rect(r(x - 3 + d), r(57), r(x + 0.5 + d), r(58), shade)

    def fore(x, d, col, shade):
        """A foreleg: forearm, knee, cannon, fetlock and hoof."""
        seg(x, 40, x, 49, 1.9, col); seg(x, 49, x + d, 56, 1.2, col)
        c.px(r(x), r(49), shade)
        c.rect(r(x - 1.5 + d), r(57), r(x + 1.5 + d), r(58), shade)

    hind(12, step, "h", "H"); fore(33, -step, "h", "H")                                   # far legs
    n = max(r(18), 5)
    for i in range(n):                                                                   # flowing tail
        t = i / (n - 1)
        x = 6 - 5 * math.sin(t * math.pi / 2) + math.sin(t * 4 + step) * 0.7
        y = 30 + 16 * t
        ellipse(c, r(x), r(y), max(1.5 * k * (1 - t * 0.4), 0.6), max(1.5 * k, 0.6), "H")
    ellipse(c, r(12), r(34), 8 * k, 8 * k, "b")                                          # rounded haunch
    ellipse(c, r(22), r(35), 11 * k, 6.5 * k, "b")                                       # barrel
    ellipse(c, r(33), r(34), 6 * k, 8 * k, "b")                                          # deep chest
    ellipse(c, r(22), r(39), 10 * k, 2.6 * k, "h")                                       # belly in shadow
    ellipse(c, r(18), r(28), 9 * k, 2 * k, "L")                                          # light along the back
    hind(16, -step, "b", "H"); fore(36, step, "b", "H")                                  # near legs
    c.px(r(14), r(46), "h"); c.px(r(36), r(46), "h")
    # the man's torso, rising from the horse's chest
    poly(c, [(r(29), r(14)), (r(40), r(14)), (r(39), r(24)), (r(37), r(31)), (r(31), r(31)), (r(30), r(24))], "s")
    poly(c, [(r(29), r(14)), (r(31), r(14)), (r(32), r(30)), (r(30), r(24))], "S")
    c.row(r(19), r(32), r(38), "S"); c.px(r(35), r(22), "S"); c.px(r(35), r(25), "S"); c.px(r(35), r(28), "S")
    ellipse(c, r(30), r(15), 2.4 * k, 2.2 * k, "s"); ellipse(c, r(39), r(15), 2.4 * k, 2.2 * k, "s")   # shoulders
    seg(29, 16, 27, 24, 1.4, "S"); ellipse(c, r(27), r(25), 1.4 * k, 1.4 * k, "S")       # far arm hanging
    seg(39, 15, 42, 18, 1.4, "s"); seg(42, 18, 42, 12, 1.3, "s")                         # near arm, raised
    ellipse(c, r(42), r(11), 1.6 * k, 1.6 * k, "s")
    c.rect(r(33), r(10), r(35), r(13), "S")                                              # neck
    ellipse(c, r(34), r(7), 3.6 * k, 4.2 * k, "s")                                       # head
    ellipse(c, r(33.5), r(3.2), 3.8 * k, 1.8 * k, "H")                                   # wild hair, on top
    c.rect(r(30), r(3), r(31), r(13), "H")                                               # and down his back
    poly(c, [(r(32), r(9)), (r(38), r(9)), (r(37), r(13)), (r(33), r(13))], "H")         # beard on the jaw
    c.row(r(5), r(35), r(37), "H")                                                       # brow
    c.px(r(36), r(6), "o"); c.px(r(38), r(7), "S"); c.px(r(31), r(7), "S")              # eye, nose, ear
    if held:
        held(c, r)


# --- Mount Pelion (Ovid, Met. 9.98-133, 12.210-535; Apollodorus 2.5.4, 2.7.6) ---------------------------------------

def centaur_raider(c, f):
    """A centaur raider (Ovid, Met. 12: the wild centaurs of Pelion): a small galloping centaur with a club."""
    centaur(c, STEP[f], 0.5, lambda c, r: c.rect(r(42), r(0), r(44), r(14), "w"))


def centaur_slinger(c, f):
    """A centaur slinger (Ovid, Met. 12: centaurs hurling rocks): a small centaur with a stone raised to throw."""
    centaur(c, STEP[f], 0.5, lambda c, r: ellipse(c, r(42), r(8), 1.5, 1.5, "g"))


CENTAUR_PAL = {"S": "#a8744a", "o": "#120e0a", "h": "#5a3a1e", "b": "#8a6040", "L": "#a87a54", "H": "#3a2412", "s": "#c8946a", "w": "#6a4a2a",
               "g": "#9a9a92", "r": "#8a1a3a", "y": "#e8c040", "Y": "#b08a20", "f": "#f08a2a"}
EURYTUS_PAL = dict(CENTAUR_PAL, s="#d88a6a", S="#b0664a")


class _Down:
    """Draws onto a canvas shifted down by dy (to leave room above a figure)."""
    def __init__(self, c, dy):
        self.c, self.dy, self.w, self.h, self.g = c, dy, c.w, c.h, c.g

    def px(self, x, y, col):
        self.c.px(x, y + self.dy, col)

    def rect(self, x0, y0, x1, y1, col):
        self.c.rect(x0, y0 + self.dy, x1, y1 + self.dy, col)

    def row(self, y, x0, x1, col):
        self.c.row(y + self.dy, x0, x1, col)


def eurytus(c, step):
    """Eurytus (Ovid, Met. 12.219-240: "wildest of the wild centaurs", drunk at the wedding): a big red-faced centaur
    holding a great embossed wine-bowl high over his head in both hands, red wine slopping over its rim."""
    def bowl(c, r):
        for (ax, ay), (bx, by), col in (((40, 14), (45, -2), "s"), ((30, 15), (27, -2), "S")):   # both arms raised
            n = max(abs(bx - ax), abs(by - ay))
            for t in range(n + 1):
                ellipse(c, ax + (bx - ax) * t / n, ay + (by - ay) * t / n, 1.3, 1.3, col)
        ellipse(c, 45, -3, 1.6, 1.6, "s"); ellipse(c, 27, -3, 1.6, 1.6, "S")            # hands
        poly(c, [(24, -8), (48, -8), (44, -3), (28, -3)], "y")                           # the wide, shallow bowl
        c.row(-8, 24, 48, "Y"); c.rect(34, -3, 38, -2, "Y")                              # its rim and foot
        c.row(-9, 26, 46, "r")                                                           # the wine in it
        for x in (29, 33, 37, 41):
            c.px(x, -6, "Y")                                                             # embossing
        for x, y in ((23, -7), (22, -5), (49, -7), (50, -5), (50, -3), (22, -3)):
            c.px(x, y, "r")                                                              # slopping over the rim
    centaur(_Down(c, 10), step, 1.0, bowl)


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
        c.rect(r(20), r(20), r(21), r(30), "w"); c.px(r(19), r(19), "g"); c.px(r(22), r(19), "g")   # arrow in his back
        for x, y in ((16, 34), (21, 36), (26, 33), (12, 38)):
            c.px(r(x), r(y), "r")
    centaur(c, step, 1.0, arrow)


NESSUS_PAL = dict(CENTAUR_PAL, h="#2a1e14", b="#4a3626", L="#5e4632", H="#1a120a", s="#a8785a", S="#7a5a3a", r="#5a8a2a")


# --- Dovrefjell (Ibsen, Peer Gynt, 1867; Asbjørnsen and Moe, 1841-44) -----------------------------------------------

def troll(c, ox, step, k=1.0, eye="open", col="g", shade="G", king=False):
    """A Norwegian troll (Asbjørnsen and Moe; Peer Gynt), drawn at scale k from x = ox, feet on y = 54*k: huge and
    hunched, a mossy back with a little fir tree grown on it, short bowed legs and big feet, long arms with huge
    hands, a heavy-browed head thrust forward with small eyes, a big ear and a long drooping nose with a wart, shaggy
    hair, and a cow's tail with a tuft. eye: "open", "none" (empty sockets) or "holding" (holding up the one eye)."""
    def r(v):
        return int(round(v * k))

    def seg(ax, ay, bx, by, w, cl):
        n = max(abs(r(bx) - r(ax)), abs(r(by) - r(ay)), 1)
        for t in range(n + 1):
            ellipse(c, ox + r(ax) + (r(bx) - r(ax)) * t / n, r(ay) + (r(by) - r(ay)) * t / n, max(w * k, 0.6), max(w * k, 0.6), cl)
    for i in range(r(14)):                                                               # cow's tail
        t = i / max(r(14) - 1, 1)
        ellipse(c, ox + r(5 - 5 * t), r(38 + 10 * t), max(0.8 * k, 0.5), max(0.8 * k, 0.5), shade)
    ellipse(c, ox + r(0), r(49), 1.8 * k, 2.2 * k, "h")                                  # its tuft
    seg(8, 28, 5, 44, 2.6, shade); ellipse(c, ox + r(5), r(46), 3 * k, 2.6 * k, shade)  # far arm, huge hand
    for x, d in ((9, -step), (19, step)):                                                # short bowed legs, big feet
        seg(x, 42, x + 1, 50, 3, shade if x == 9 else col)
        ellipse(c, ox + r(x + 2) + d, r(52), 4 * k, 2.2 * k, shade)
    ellipse(c, ox + r(16), r(34), 12 * k, 11 * k, col)                                   # great body
    ellipse(c, ox + r(20), r(38), 7 * k, 6 * k, "v")                                     # belly
    ellipse(c, ox + r(10), r(25), 8 * k, 7 * k, col)                                     # hunched, mossy back
    ellipse(c, ox + r(9), r(31), 6 * k, 5 * k, shade)
    for x, y in ((6, 22), (10, 20), (14, 23), (8, 27), (4, 30)):
        c.px(ox + r(x), r(y), "m"); c.px(ox + r(x) + 1, r(y), "M")                       # moss
    if not king:
        poly(c, [(ox + r(9), r(19)), (ox + r(12), r(11)), (ox + r(15), r(19))], "t")     # a little fir tree on its back
        poly(c, [(ox + r(10), r(15)), (ox + r(12), r(9)), (ox + r(14), r(15))], "t")
        c.px(ox + r(12), r(20), "h")
        poly(c, [(ox + r(6), r(41)), (ox + r(27), r(41)), (ox + r(26), r(46)), (ox + r(7), r(46))], "f")   # hide
    hx, hy = 25, 19                                                                      # head, thrust forward
    ellipse(c, ox + r(hx), r(hy), 6.5 * k, 6 * k, col)
    ellipse(c, ox + r(hx - 5), r(hy + 1), 1.8 * k, 2.6 * k, shade)                       # big ear
    for x in range(r(hx - 6), r(hx + 4)):
        c.px(ox + x, r(hy - 6) + (x % 2), "h")                                           # shaggy hair
    c.rect(ox + r(hx - 7), r(hy - 5), ox + r(hx - 6), r(hy + 4), "h")
    c.row(r(hy - 2), ox + r(hx - 2), ox + r(hx + 5), shade)                              # heavy brow
    poly(c, [(ox + r(hx + 3), r(hy - 1)), (ox + r(hx + 11), r(hy + 6)), (ox + r(hx + 10), r(hy + 9)),
             (ox + r(hx + 3), r(hy + 4))], shade)                                        # long drooping nose
    c.px(ox + r(hx + 8), r(hy + 5), "W")                                                 # a wart
    c.row(r(hy + 4), ox + r(hx - 2), ox + r(hx + 2), "k"); c.px(ox + r(hx + 1), r(hy + 5), "w")   # mouth, a tooth
    for ex in (hx, hx + 3):
        if eye == "open":
            c.px(ox + r(ex), r(hy), "k"); c.px(ox + r(ex), r(hy) - 1, "e")
        else:
            c.px(ox + r(ex), r(hy), "K")                                                 # empty sockets
    seg(22, 28, 27, 44, 2.6, col); ellipse(c, ox + r(28), r(46), 3.2 * k, 2.8 * k, col)  # near arm, huge hand
    c.px(ox + r(26), r(48), "k"); c.px(ox + r(29), r(48), "k"); c.px(ox + r(31), r(47), "k")
    if eye == "holding":
        seg(22, 28, 30, 18, 2.4, col); ellipse(c, ox + r(31), r(15), 3 * k, 2.8 * k, col)   # arm raised, the eye held up
        ellipse(c, ox + r(31), r(12), 2.4 * k, 2.4 * k, "w"); c.px(ox + r(31), r(12), "E"); c.px(ox + r(32), r(12), "k")


TROLL_PAL = {"o": "#10140e", "k": "#1a1e14", "K": "#060806", "g": "#6e7e5a", "G": "#4c5a3c", "v": "#808e6a",
             "h": "#3a3226", "W": "#8a6a5a", "w": "#e8e0d0", "f": "#5a4a36", "m": "#4a7a3a", "M": "#6a9a4a",
             "t": "#2a5a32", "e": "#f0d060", "E": "#f0c040", "b": "#5a3a1a"}


def dovre_troll(c, f):
    """A Dovre troll (Peer Gynt: the Dovre-King's courtiers; Asbjørnsen and Moe): a hunched green-grey troll with a mossy
    back, a long drooping nose, small eyes under a heavy brow, long arms with big hands, and a cow's tail with a tuft,
    carrying a knotted club."""
    troll(c, 0, STEP[f], 0.48)
    for t in range(10):
        c.px(15 + t // 4, 22 - t * 2 // 2, "b")                                          # club
    ellipse(c, 18, 11, 1.8, 1.8, "b")


DOVRE_TROLL_PAL = TROLL_PAL


def troll_brat(c, f):
    """A troll brat (Peer Gynt: the Dovre-King's troll children, who bit and pinched Peer): a small, round troll child
    with a long nose, a grin and a tufted tail, its little hands reaching out to pinch."""
    up = f % 2
    troll(c, 0, 0, 0.27)
    c.px(13, 10 - up, "w"); c.px(14, 11 - up, "w")                                       # pinching


TROLL_BRAT_PAL = TROLL_PAL


def hedal_trolls(c, step):
    """The Hedal Trolls (Asbjørnsen and Moe, "The Boys Who Met the Trolls in the Hedal Woods": three trolls with only
    one eye between them, which they passed from one to another): three huge grey trolls, hunched and mossy, with fir
    trees growing on their backs; the two at the sides with empty sockets, groping, and the one in the middle holding
    the single glowing eye up in his fist."""
    troll(c, 0, -step, 0.85, eye="none", col="q", shade="Q")                             # the two at the sides, behind
    troll(c, 46, step, 0.85, eye="none", col="q", shade="Q")
    troll(c, 22, step, 1.0, eye="holding", col="v", shade="g")                           # the middle one, in front
    for x, y in ((53, 9), (56, 11), (50, 11)):
        c.px(x, y, "E")                                                                  # the eye's glow


HEDAL_PAL = dict(TROLL_PAL, g="#7a8070", G="#5a6050", v="#8e9482", q="#626a5a", Q="#454c3e")


def great_boyg(c, step):
    """The Great Bøyg (Peer Gynt, Act II: the shapeless, slimy thing in the dark that can't be fought, only gone round,
    and says "Go round about"): a towering mound of thick, wet coils of darkness looping over and under one another,
    glistening along their tops, ooze dripping from them, no face at all, and mist swirling round its foot."""
    def tube(pts, w):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            n = int(max(abs(bx - ax), abs(by - ay))) + 1
            for t in range(n + 1):
                ellipse(c, ax + (bx - ax) * t / n, ay + (by - ay) * t / n, w + 0.8, w + 0.8, "K")
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            n = int(max(abs(bx - ax), abs(by - ay))) + 1
            for t in range(n + 1):
                x, y = ax + (bx - ax) * t / n, ay + (by - ay) * t / n
                ellipse(c, x, y, w, w, "k"); c.px(round(x), round(y - w + 1), "s")       # glistening along the top
    sw = step * 1.5
    for k in range(7):                                                                   # loops, from the back to the front
        cx = 12 + k * 7.5 + (sw if k % 2 else -sw)
        top = 10 + abs(3 - k) * 5
        tube([(cx - 7, 50), (cx - 8, top + 10), (cx - 3, top), (cx + 3, top + 2), (cx + 6, top + 12), (cx + 4, 50)],
             4.2 - abs(3 - k) * 0.3)
    tube([(4, 44), (20, 36), (36, 40), (52, 34), (66, 42)], 4.5)                         # one coil across the front
    for x, y in ((14, 46), (30, 46), (44, 44), (58, 47), (24, 22), (40, 18)):
        c.px(x, y, "s"); c.px(x, y + 1, "S"); c.px(x, y + 3 + (x + step) % 2, "S")      # ooze dripping
    for x in range(0, 70, 3):
        y = 52 + (x + step) % 3
        c.px(x, y, "m"); c.px(x + 1, y - 1, "M"); c.px(x + 2, y, "m")                   # mist swirling at its foot
    for x, y in ((6, 30), (64, 26), (2, 40), (68, 38)):
        c.px(x, y, "M"); c.px(x + 1, y + 1, "m")


BOYG_PAL = {"o": "#05060a", "k": "#1e262a", "K": "#0c1012", "s": "#6a8078", "S": "#3e5048", "m": "#6a7478",
            "M": "#4a5458"}


def mountain_king(c, step):
    """The Mountain King (Peer Gynt: the old Dovre-King on his throne, with crown and sceptre): an old, hunched troll
    king with a huge drooping nose and small eyes under a heavy brow, a long white beard, a gold crown, a royal red
    cloak over his mossy back, a sceptre in his huge hand, and his cow's tail with its tuft."""
    poly(c, [(4, 18), (18, 14), (24, 22), (22, 50), (2, 50)], "r")                       # red cloak over his back
    poly(c, [(4, 18), (8, 17), (6, 50), (2, 50)], "R")
    troll(c, 2, step, 1.05, king=True)
    poly(c, [(24, 26), (34, 26), (33, 38), (29, 43), (25, 36)], "W")                     # long white beard
    c.px(29, 30, "V"); c.px(31, 34, "V"); c.px(27, 28, "V")
    for x in range(23, 34, 3):
        c.rect(x, 10, x, 13, "y"); c.px(x, 9, "Y")                                       # gold crown, on his head
    c.row(13, 23, 33, "y"); c.px(28, 12, "j")
    c.rect(7, 22, 7, 56, "y"); ellipse(c, 7, 21, 2, 2, "y"); c.px(7, 21, "j")            # sceptre in his far hand


MOUNTAIN_KING_PAL = dict(TROLL_PAL, r="#8a2a2a", R="#5a1a1a", W="#ece8e0", V="#b8b4ac", y="#e8c040", Y="#fff0a0",
                         j="#e83a3a")


# --- The City of Brass ("The City of Brass", the Nights; Burton, 1885; no jinn) --------------------------------------

def brass_soldier(c, f):
    """A brass soldier (the tale's brass figures, still keeping watch in the silent city): a stiff automaton of polished
    brass with rivets at its joints, a crested helmet with a glowing visor slit, a round shield embossed with a sun, and
    a curved sword."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 21, "B"); c.px(x + d, 19, "Y"); c.row(22, x + d, x + 2 + d, "B")   # jointed legs
    poly(c, [(6, 8), (13, 8), (12, 16), (7, 16)], "y"); c.rect(6, 8, 7, 16, "B"); c.px(11, 9, "Y")   # breastplate
    for x, y in ((8, 10), (11, 12), (8, 14)):
        c.px(x, y, "B")                                                                  # rivets
    c.row(16, 6, 13, "B")
    c.rect(7, 2, 12, 7, "y"); c.rect(7, 2, 7, 7, "B"); c.row(4, 8, 12, "k"); c.px(10, 4, "r"); c.px(12, 4, "r")   # helmet, glowing slit
    for x in range(7, 13):
        c.px(x, 1 - (1 if 9 <= x <= 10 else 0), "Y")                                    # crest
    ellipse(c, 3, 12, 3, 4, "B"); ellipse(c, 3, 12, 2, 3, "y"); c.px(3, 12, "Y")         # round shield, a sun on it
    c.px(2, 10, "Y"); c.px(4, 14, "Y")
    for x, y in ((15, 13), (16, 12), (16, 11), (16, 10), (17, 9), (17, 8), (17, 7)):
        c.px(x, y, "s")                                                                  # curved sword
    c.px(14, 13, "Y"); c.px(15, 14, "Y")


BRASS_SOLDIER_PAL = {"o": "#2a1a08", "k": "#1a1008", "y": "#d8a840", "Y": "#f8e088", "B": "#8a5a14", "s": "#d8dce4",
                     "r": "#ff7a3a"}


def locust(c, f):
    """A locust (the desert road): a long green-brown locust with big bent hind legs for leaping, feelers, and its
    wings whirring."""
    up = f % 2
    for x in range(2, 11):
        c.px(x, 6, "g"); c.px(x, 7, "G" if x % 2 else "g")                               # segmented body
    ellipse(c, 11, 6, 1.6, 1.4, "g"); c.px(12, 6, "k"); c.px(13, 4, "G"); c.px(12, 3, "G")   # head, eye, feelers
    poly(c, [(4, 6), (9, 1 + up * 2), (11, 5)], "w"); c.px(7, 3 + up, "W")               # whirring wing
    c.px(5, 8, "G"); c.px(4, 9, "G"); c.px(6, 10, "G"); c.px(7, 10, "G")                 # big bent hind leg
    c.px(9, 8, "G"); c.px(10, 9, "G")                                                    # forelegs


LOCUST_PAL = {"o": "#1a1408", "g": "#8a8a3a", "G": "#5a5a2a", "w": "#d8d4b0", "W": "#a8a480", "k": "#1a1408"}


def wall_watcher(c, step):
    """The Watcher on the Wall ("The City of Brass": the vision that beckoned each man who climbed the wall, so that he
    cried "Thou art beautiful!" and threw himself down): a tall, veiled figure of shimmering light standing on the
    city's brass battlement, its veil streaming, both arms held out to beckon, light glittering round it."""
    c.rect(2, 42, 40, 52, "B"); c.row(42, 2, 40, "y")                                    # the brass battlement
    for y in (45, 48, 51):
        for x in range(2 + (y % 2) * 3, 40, 6):
            c.px(x, y, "D")                                                              # its courses
    for x in range(2, 40, 8):
        c.rect(x, 37, x + 4, 41, "B"); c.row(37, x, x + 4, "y")                          # crenellations
    poly(c, [(16, 12), (26, 12), (31, 40), (11, 40)], "w")                               # gown of light
    poly(c, [(16, 12), (19, 12), (15, 40), (11, 40)], "W")
    poly(c, [(15, 6), (27, 6), (34 + step, 30), (24, 14), (18, 14), (8 - step, 30)], "v")   # veil streaming
    ellipse(c, 21, 8, 4, 4.5, "W"); c.px(20, 8, "y"); c.px(23, 8, "y")                   # veiled head, eyes glinting
    for side in (-1, 1):                                                                 # arms held out, beckoning
        for t in range(9):
            c.px(21 + side * (5 + t), 18 - t // 3 - (step if side > 0 else 0), "W")
        c.px(21 + side * 14, 14 - (step if side > 0 else 0), "y")
    for x, y in ((6, 10 + step), (36, 8 - step), (10, 24), (34, 22), (21, 1), (4, 32)):
        c.px(x, y, "y"); c.px(x + 1, y, "W")                                             # glittering


WATCHER_PAL = {"o": "#4a3a20", "w": "#f4ecd8", "W": "#fff8e8", "v": "#e8dcc0", "y": "#f8d860", "B": "#9a6a1a",
               "D": "#6a4a10"}


def queens_guardians(c, step):
    """The Queen's Guardians ("The City of Brass": two automatons, one of steel and one of brass, standing with swords
    on either side of the dead queen's bier): two tall jointed figures, one steel and one brass, crested helmets with
    glowing eye-slits, riveted breastplates, jointed arms and legs, each raising a sword."""
    def guard(x0, body, shade, light, d):
        for lx, dd in ((x0 + 3, -d), (x0 + 9, d)):                                       # jointed legs
            c.rect(lx + dd, 40, lx + 2 + dd, 47, body); c.rect(lx + dd, 47, lx + 2 + dd, 48, shade)
            c.rect(lx + dd, 49, lx + 2 + dd, 54, body); c.row(54, lx - 1 + dd, lx + 3 + dd, shade)
        poly(c, [(x0, 18), (x0 + 14, 18), (x0 + 12, 38), (x0 + 2, 38)], body)           # breastplate
        poly(c, [(x0, 18), (x0 + 3, 18), (x0 + 4, 38), (x0 + 2, 38)], shade)
        c.rect(x0 + 9, 20, x0 + 10, 30, light)
        for y in (22, 28, 34):
            c.px(x0 + 4, y, shade); c.px(x0 + 12, y, shade)                              # rivets
        c.rect(x0 + 1, 38, x0 + 13, 40, shade)                                           # hip-plate
        c.rect(x0 + 3, 6, x0 + 11, 16, body); c.rect(x0 + 3, 6, x0 + 4, 16, shade)       # helmet
        c.row(11, x0 + 5, x0 + 10, "k"); c.px(x0 + 7, 11, "r"); c.px(x0 + 9, 11, "r")   # glowing eye-slit
        for x in range(x0 + 3, x0 + 12):
            c.px(x, 5 - (1 if x0 + 6 <= x <= x0 + 8 else 0), light)                      # crest
        c.rect(x0 - 2, 19, x0, 30, shade); c.px(x0 - 1, 24, light)                       # far arm, jointed
        c.rect(x0 + 14, 18, x0 + 16, 24, body); c.px(x0 + 15, 21, light)                 # near arm, raised
        c.rect(x0 + 15, 14, x0 + 17, 18, body)
        c.rect(x0 + 16, 0, x0 + 17, 14, "W"); c.px(x0 + 16, 0, "w")                      # the sword
        c.rect(x0 + 13, 14, x0 + 20, 15, shade)                                          # its guard
    guard(4, "s", "S", "w", -step)
    guard(26, "y", "B", "Y", step)


GUARDIANS_PAL = {"o": "#1a1408", "k": "#1a1008", "s": "#a8acb4", "S": "#6a6e76", "w": "#e8ecf4", "y": "#d8a840",
                 "B": "#8a5a14", "Y": "#f8e088", "W": "#e8ecf4", "r": "#ff7a3a"}


def brass_horseman(c, step):
    """The Brass Horseman ("The City of Brass": the horseman of brass on a pillar in the desert, spear in hand, who
    points the way when he is turned): a rider and horse all of polished brass, the horse with an arched neck, a mane
    and a flowing tail, the rider in a pointed helmet with a round shield, his long spear levelled with a pennant."""
    def seg(ax, ay, bx, by, w, col):
        n = max(abs(bx - ax), abs(by - ay), 1)
        for t in range(n + 1):
            ellipse(c, ax + (bx - ax) * t / n, ay + (by - ay) * t / n, w, w, col)
    for x, d, hind in ((16, step, True), (40, -step, False)):                            # far legs
        seg(x, 36, x - (2 if hind else 0), 43, 1.8, "B"); seg(x - (2 if hind else 0), 43, x - (1 if hind else 0) + d, 49, 1.1, "B")
        c.rect(x - 2 + d, 50, x + 1 + d, 51, "D")
    for i in range(14):                                                                  # flowing tail
        t = i / 13
        ellipse(c, 10 - 5 * math.sin(t * 1.6), 28 + 14 * t, 1.6, 1.6, "B")
    ellipse(c, 16, 32, 8, 7, "y"); ellipse(c, 28, 33, 12, 6.5, "y"); ellipse(c, 38, 32, 6, 7, "y")   # haunch, barrel, chest
    ellipse(c, 27, 37, 10, 2.4, "B"); ellipse(c, 24, 27, 10, 2, "Y")                     # shadow, gleam
    for x, d, hind in ((20, -step, True), (43, step, False)):                            # near legs
        seg(x, 36, x - (2 if hind else 0), 43, 2, "y"); seg(x - (2 if hind else 0), 43, x - (1 if hind else 0) + d, 49, 1.2, "y")
        c.rect(x - 2 + d, 50, x + 1 + d, 51, "D")
    seg(40, 28, 46, 21, 3.2, "y")                                                        # arched neck
    poly(c, [(44, 18), (52, 21), (56, 26), (53, 28), (47, 25)], "y")                     # head
    c.px(50, 22, "k"); c.px(55, 26, "D"); poly(c, [(45, 18), (46, 15), (48, 18)], "y")   # eye, nostril, ear
    for t in range(9):
        c.px(round(41 + t * 0.6), round(27 - t * 1.0), "D"); c.px(round(40 + t * 0.6), round(27 - t * 1.0), "B")   # mane
    poly(c, [(26, 14), (34, 14), (34, 28), (26, 28)], "y"); c.rect(26, 14, 27, 28, "B")  # rider's body
    c.px(31, 18, "Y"); c.px(31, 22, "Y")
    c.rect(28, 28, 32, 34, "B")                                                          # leg against the horse
    ellipse(c, 30, 9, 3.4, 3.8, "y"); c.px(32, 9, "k")                                   # head
    poly(c, [(26, 8), (34, 8), (30, 1)], "B"); c.px(30, 1, "Y")                          # pointed helmet
    ellipse(c, 25, 21, 4, 5, "B"); ellipse(c, 25, 21, 2.6, 3.6, "y"); c.px(25, 21, "Y")  # round shield
    c.rect(20, 12, 63, 13, "D"); c.row(12, 20, 63, "B")                                  # the spear, levelled high
    poly(c, [(63, 10), (66, 12), (63, 15)], "s")
    poly(c, [(56, 13), (61, 14 + step), (56, 17)], "r")                                  # pennant
    c.rect(34, 13, 36, 17, "y")                                                          # his arm holding it


HORSEMAN_PAL = {"o": "#2a1a08", "k": "#1a1008", "y": "#d8a840", "Y": "#f8e088", "B": "#9a6a1a", "D": "#6a4210",
                "s": "#d8dce4", "r": "#b03a2a"}


# --- The Sea King's Hall (Andersen, "The Little Mermaid", 1837) -------------------------------------------------------

def water_snake(c, f):
    """A water snake (Andersen: the Sea Witch's ugly, fat water-snakes, "her little chickens"): a thick, slimy
    green-brown snake with dark blotches and a slimy sheen, swimming, with yellow eyes and a flickering tongue."""
    pts = []
    for k in range(11):
        pts.append((2 + k * 1.7, 12 + 3 * math.sin(k / 1.6 + f * 0.8), 1.4 + k * 0.12))
    for x, y, r in pts:
        ellipse(c, x, y, r + 0.6, r + 0.6, "G")
    for i, (x, y, r) in enumerate(pts):
        ellipse(c, x, y - 0.3, r, r, "g")
        if i % 3 == 1:
            c.px(round(x), round(y), "G")                                                # blotches
        c.px(round(x), round(y - r), "l")                                                # slimy sheen
    hy = 12 + round(3 * math.sin(10 / 1.6 + f * 0.8))
    ellipse(c, 20, hy, 3, 2.4, "g"); c.px(21, hy - 1, "y"); c.px(23, hy, "G")            # broad head, eye
    if f % 2:
        c.px(23, hy + 1, "r"); c.px(23, hy + 2, "r")                                     # tongue


WATER_SNAKE_PAL = {"o": "#0e140a", "g": "#5a6a3a", "G": "#3a4a2a", "l": "#8a9a5a", "y": "#e8d040", "r": "#c83a3a"}


def silver_fish(c, f):
    """A silver fish (Andersen: the little fish that swim in and out of the Sea King's windows, as birds fly into our
    houses): a shining fish with a forked tail and fins, scales glinting."""
    up = f % 2
    ellipse(c, 6, 5, 4, 2.5, "s"); ellipse(c, 6, 6, 3, 1.2, "S")
    poly(c, [(2, 5), (0, 2 + up), (1, 5), (0, 8 - up)], "S")                             # forked tail
    poly(c, [(5, 3), (7, 1), (8, 3)], "S"); c.px(6, 8, "S")                              # fins
    c.px(9, 4, "k"); c.px(5, 4, "w"); c.px(7, 5, "w"); c.px(4, 6, "w")                    # eye, glints


SILVER_FISH_PAL = {"o": "#2a3a4a", "s": "#c8d8e8", "S": "#8aa0b8", "w": "#ffffff", "k": "#1a2a3a"}


def polyp_wood(c, step):
    """The Polyp Wood (Andersen: the polyps round the Sea Witch's house, half animal and half plant, like hundred-headed
    snakes growing out of the ground, whose slimy arms seize whatever comes near and never let go; in their grip lie
    the white bones of drowned men): a thicket of slimy stalks rising from the sea floor, each crowned with writhing,
    grasping arms with pink tips, one clutching a skull, bones among their roots."""
    ellipse(c, 30, 49, 26, 5, "G"); ellipse(c, 30, 48, 24, 3, "g")                       # the sea floor
    for k in range(7):
        x0 = 6 + k * 8
        top = 14 + (k % 3) * 7
        for y in range(48, top, -1):                                                     # the stalk, swaying
            x = x0 + round(2.5 * math.sin(y / 6.0 + k + step * 0.5))
            c.rect(x, y, x + 2, y, "g"); c.px(x, y, "G")
        cx = x0 + round(2.5 * math.sin(top / 6.0 + k + step * 0.5)) + 1
        for a in range(5):                                                               # its crown of grasping arms
            ang = -math.pi / 2 + (a - 2) * 0.6
            for t in range(6):
                bend = t * 0.15 * (1 if a % 2 else -1)
                px_, py_ = cx + round(t * math.cos(ang + bend)), top + round(t * math.sin(ang + bend))
                c.px(px_, py_, "g" if t < 4 else "p")
        ellipse(c, cx, top + 1, 1.6, 1.6, "G")
    ellipse(c, 42, 20, 3, 2.6, "w"); c.px(41, 20, "k"); c.px(43, 20, "k"); c.row(22, 41, 43, "k")   # a skull in their grip
    c.rect(14, 46, 24, 46, "w"); c.px(13, 45, "w"); c.px(25, 45, "w")                   # bones among the roots
    c.rect(34, 47, 40, 47, "w"); c.px(33, 46, "w"); c.px(41, 48, "w")


POLYP_PAL = {"o": "#0e140a", "g": "#6a8a4a", "G": "#4a6a3a", "p": "#e08a9a", "w": "#e8e4dc", "k": "#2a2a24"}


def witch_snakes(c, step):
    """The Witch's Water Snakes (Andersen: the Sea Witch's great fat water-snakes, her "little chickens"): a knot of
    great fat snakes coiled together, blotched and slimy, two of them rearing up with jaws open and tongues out."""
    for k in range(16):                                                                  # the coiled knot
        a = k / 16 * math.tau + step * 0.1
        x, y = 28 + 16 * math.cos(a), 36 + 7 * math.sin(a)
        ellipse(c, x, y, 5.5, 4.5, "G"); ellipse(c, x, y - 0.6, 4.6, 3.6, "g")
        c.px(round(x), round(y - 3.4), "l")
        if k % 3 == 0:
            c.px(round(x), round(y), "G"); c.px(round(x) + 1, round(y), "G")             # blotches
    for x0, top, side in ((16, 10, -1), (40, 6, 1)):                                     # two rearing up
        for y in range(36, top, -1):
            x = x0 + round(2 * math.sin(y / 3.0 + step + x0))
            c.rect(x, y, x + 3, y, "g"); c.px(x, y, "G"); c.px(x + 3, y, "l")
        hx = x0 + round(2 * math.sin(top / 3.0 + step + x0))
        ellipse(c, hx + 2 + side, top, 4, 3, "g"); c.px(hx + 2 + side * 2, top - 1, "y")
        c.row(top + 2, hx + side * 3, hx + 4 + side * 3, "k")                            # jaws open
        c.px(hx + 2 + side * 5, top + 2, "r"); c.px(hx + 2 + side * 6, top + 3, "r")    # tongue


SNAKES_PAL = dict(WATER_SNAKE_PAL, k="#0e140a")


def sea_witch(c, step):
    """The Sea Witch (Andersen, 1837; not any film): a squat, heavy old witch of the sea floor with grey-green skin and
    a wide mouth, her long hair like sea-weed, a ragged dark robe hung with shells and little bones, a great fat
    water-snake coiled round her shoulders, and a toad sitting on her outstretched hand."""
    person(c, step, cx=20, skin="s", skin_d="S", hair="g", hair_d="G", hair_style="long", garment="gown",
           robe="d", robe_d="D", robe_l="q", belt="w", boots="D", arm_forward=True, eye="y", mouth="k", head_y=12)
    poly(c, [(9, 30), (31, 30), (34, 52), (6, 52)], "d"); poly(c, [(9, 30), (13, 30), (9, 52), (6, 52)], "D")   # squat, heavy
    for x, y in ((12, 40), (26, 36), (18, 46), (28, 48)):
        c.px(x, y, "w"); c.px(x + 1, y, "e")                                             # shells and little bones
    for k in range(7):                                                                   # sea-weed hair
        x = 14 + k * 2
        c.rect(x, 5, x, 22 + (k % 3) * 2, "g" if k % 2 else "G")
    ellipse(c, 20, 12, 4.6, 5, "s"); c.px(16, 13, "S")                                   # face
    c.px(18, 11, "y"); c.px(22, 11, "y"); c.row(15, 17, 23, "k"); c.px(19, 16, "k")      # eyes, wide mouth
    for k in range(13):                                                                  # the fat snake round her shoulders
        a = math.pi * (0.95 + k / 12 * 1.1)
        x, y = 20 + 11 * math.cos(a), 21 + 4 * math.sin(a) + (2 if k > 9 else 0)
        ellipse(c, x, y, 2.2, 2, "n"); c.px(round(x), round(y) - 1, "N")
    ellipse(c, 31, 22, 2.4, 2, "n"); c.px(32, 21, "y")
    ellipse(c, 35, 21, 2.6, 2, "t"); c.px(35, 20, "y"); c.px(37, 20, "y"); c.px(33, 22, "T")   # the toad on her hand


SEA_WITCH_PAL = {"o": "#0a0e10", "k": "#141a1e", "d": "#2a3a3a", "D": "#1a2626", "q": "#3a4e4e", "s": "#8aa098",
                 "S": "#6a8078", "g": "#3a5a2a", "G": "#2a4220", "y": "#e8d040", "w": "#e8e4dc", "e": "#d8a8a0",
                 "n": "#5a6a3a", "N": "#8a9a5a", "t": "#6a7a3a", "T": "#4a5a2a", "m": "#141a1e", "l": "#2a3a3a",
                 "b": "#1a2626"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_frontiers.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("centaur_raider", centaur_raider, CENTAUR_PAL, doc(centaur_raider.__doc__), (28, 30), (13, 29), walk, folder="enemies")
    kit.build_boss("centaur_slinger", centaur_slinger, CENTAUR_PAL, doc(centaur_slinger.__doc__), (28, 30), (13, 29), walk, folder="enemies")
    kit.build_boss("eurytus", eurytus, EURYTUS_PAL, doc(eurytus.__doc__), (56, 70), (26, 68), [0, 1, 0, -1, 0])
    kit.build_boss("rhoetus", rhoetus, CENTAUR_PAL, doc(rhoetus.__doc__), (56, 60), (26, 58), [0, 1, 0, -1, 0])
    kit.build_boss("nessus", nessus, NESSUS_PAL, doc(nessus.__doc__), (56, 60), (26, 58), [0, 1, 0, -1, 0])
    kit.build_boss("dovre_troll", dovre_troll, DOVRE_TROLL_PAL, doc(dovre_troll.__doc__), (26, 28), (12, 27), walk, folder="enemies")
    kit.build_boss("troll_brat", troll_brat, TROLL_BRAT_PAL, doc(troll_brat.__doc__), (16, 16), (8, 15), walk, folder="enemies")
    kit.build_boss("hedal_trolls", hedal_trolls, HEDAL_PAL, doc(hedal_trolls.__doc__), (84, 60), (42, 58), [0, 1, 0, -1, 0])
    kit.build_boss("great_boyg", great_boyg, BOYG_PAL, doc(great_boyg.__doc__), (70, 58), (35, 56), [0, 1, 0, -1, 0])
    kit.build_boss("mountain_king", mountain_king, MOUNTAIN_KING_PAL, doc(mountain_king.__doc__), (48, 60), (22, 58), [0, 1, 0, -1, 0])
    kit.build_boss("brass_soldier", brass_soldier, BRASS_SOLDIER_PAL, doc(brass_soldier.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("locust", locust, LOCUST_PAL, doc(locust.__doc__), (14, 12), (7, 11), walk, folder="enemies")
    kit.build_boss("wall_watcher", wall_watcher, WATCHER_PAL, doc(wall_watcher.__doc__), (42, 54), (21, 52), [0, 1, 0, -1, 0])
    kit.build_boss("queens_guardians", queens_guardians, GUARDIANS_PAL, doc(queens_guardians.__doc__), (48, 56), (24, 54), [0, 1, 0, -1, 0])
    kit.build_boss("brass_horseman", brass_horseman, HORSEMAN_PAL, doc(brass_horseman.__doc__), (68, 54), (32, 52), [0, 1, 0, -1, 0])
    kit.build_boss("water_snake", water_snake, WATER_SNAKE_PAL, doc(water_snake.__doc__), (24, 20), (12, 19), walk, folder="enemies")
    kit.build_boss("silver_fish", silver_fish, SILVER_FISH_PAL, doc(silver_fish.__doc__), (12, 10), (6, 9), walk, folder="enemies")
    kit.build_boss("polyp_wood", polyp_wood, POLYP_PAL, doc(polyp_wood.__doc__), (60, 54), (30, 52), [0, 1, 0, -1, 0])
    kit.build_boss("witch_snakes", witch_snakes, SNAKES_PAL, doc(witch_snakes.__doc__), (56, 46), (28, 44), [0, 1, 0, -1, 0])
    kit.build_boss("sea_witch", sea_witch, SEA_WITCH_PAL, doc(sea_witch.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    print("wrote Wild Frontiers' art")
