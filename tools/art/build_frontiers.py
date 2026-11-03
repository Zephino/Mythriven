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


def eurytus(c, step):
    """Eurytus (Ovid, Met. 12.219-240: "wildest of the wild centaurs", drunk at the wedding): a big red-faced centaur
    with a great embossed wine-bowl held up in both hands, wine slopping over."""
    def bowl(c, r):
        ellipse(c, r(42), r(6), 6, 3, "y"); c.rect(r(37), r(4), r(47), r(5), "r"); c.row(r(7), r(38), r(46), "Y")
        for x in (38, 41, 44):
            c.px(x, 7, "Y")                                                              # embossing
    centaur(c, step, 1.0, bowl)
    c.px(47, 8, "r"); c.px(48, 10, "r"); c.px(37, 7, "r"); c.px(47, 12, "r")             # wine slopping over


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
    kit.build_boss("centaur_raider", centaur_raider, CENTAUR_PAL, doc(centaur_raider.__doc__), (28, 30), (13, 29), walk, folder="enemies")
    kit.build_boss("centaur_slinger", centaur_slinger, CENTAUR_PAL, doc(centaur_slinger.__doc__), (28, 30), (13, 29), walk, folder="enemies")
    kit.build_boss("eurytus", eurytus, EURYTUS_PAL, doc(eurytus.__doc__), (56, 60), (26, 58), [0, 1, 0, -1, 0])
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
    kit.build_boss("brass_horseman", brass_horseman, HORSEMAN_PAL, doc(brass_horseman.__doc__), (66, 52), (32, 50), [0, 1, 0, -1, 0])
    kit.build_boss("water_snake", water_snake, WATER_SNAKE_PAL, doc(water_snake.__doc__), (24, 20), (12, 19), walk, folder="enemies")
    kit.build_boss("silver_fish", silver_fish, SILVER_FISH_PAL, doc(silver_fish.__doc__), (12, 10), (6, 9), walk, folder="enemies")
    kit.build_boss("polyp_wood", polyp_wood, POLYP_PAL, doc(polyp_wood.__doc__), (60, 54), (30, 52), [0, 1, 0, -1, 0])
    kit.build_boss("witch_snakes", witch_snakes, SNAKES_PAL, doc(witch_snakes.__doc__), (56, 46), (28, 44), [0, 1, 0, -1, 0])
    kit.build_boss("sea_witch", sea_witch, SEA_WITCH_PAL, doc(sea_witch.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    print("wrote Wild Frontiers' art")
