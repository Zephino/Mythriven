# Gothic Night's art (Pack 5, docs/PACK_5_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts and folklore (Hesiod, Aristophanes, Pausanias, the Anglo-Saxon Chronicle, Le Fanu, Polidori, Varney, Gerald of
# Wales, Marie de France, Goethe), never later versions.
# Run: python3 build_gothic.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


# --- Erebus (Hesiod; Aristophanes, The Frogs; Pausanias 10.28.7; the Anglo-Saxon Chronicle 1127) ----------------------

def ker(c, f):
    """A Ker (Hesiod, Theogony 211-217; the Shield of Heracles 248-257): a dark-winged death spirit of the battlefield
    in a blood-stained cloak, with long claws."""
    s = STEP[f]
    poly(c, [(9, 6), (1, 2 + s), (4, 12)], "w"); poly(c, [(11, 6), (19, 2 + s), (16, 12)], "w")
    poly(c, [(7, 6), (13, 6), (14, 18), (6, 18)], "d")
    c.rect(7, 12, 13, 13, "r")                                                          # blood on the cloak
    ellipse(c, 10, 4, 2.5, 2.5, "p"); c.px(9, 4, "y"); c.px(11, 4, "y")
    c.px(5, 16, "p"); c.px(15, 16, "p")


KER_PAL = {"o": "#0a0608", "d": "#2a2028", "w": "#3a3040", "r": "#7a1a1a", "p": "#b8b0a8", "y": "#e85a3a"}


def hunt_hound(c, f):
    """A hound of the Wild Hunt (the Anglo-Saxon Chronicle for 1127: "the hounds were all black and wide-eyed and
    ugly"): a lean black hound with burning eyes."""
    s = STEP[f]
    ellipse(c, 11, 9, 7, 3, "k")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 11, 5 + k * 4 + d, 15, "K")
    poly(c, [(16, 5), (22, 7), (22, 10), (16, 10)], "k"); c.px(18, 6, "y"); c.px(19, 6, "y")
    c.px(17, 3, "k"); c.px(17, 4, "k"); c.row(9, 0, 4, "K")


HOUND_PAL = {"o": "#2a2830", "k": "#141218", "K": "#0a080c", "y": "#f0c040"}


def rim(c, body, light):
    """Edge-light: every pixel of the given colours with empty space just above or in front becomes the light colour,
    so a dark shape still reads against dark ground."""
    w, h = c.w, c.h
    hits = []
    for y in range(1, h):
        for x in range(w - 1):
            if c.g[y][x] in body and (c.g[y - 1][x] == "." or c.g[y][x + 1] == "."):
                hits.append((x, y))
    for x, y in hits:
        c.px(x, y, light)


def hoofed_leg(c, x, y0, y1, col, shade, hoof, bend=0, paw=False):
    """A slim jointed leg from inside the body (y0) to the ground (y1): a muscled upper leg tapering to the knee or hock,
    a thin lower leg, and a hoof (or a paw)."""
    knee = y0 + (y1 - y0) * 5 // 9
    poly(c, [(x - 2, y0), (x + 3, y0), (x + 2 + bend, knee), (x + bend, knee)], col)    # upper leg, tapering
    c.px(x + bend, knee, shade); c.px(x + 1 + bend, knee + 1, col)                       # the joint
    c.rect(x + bend, knee + 1, x + 1 + bend, y1 - 2, col)                                # the thin lower leg
    c.px(x + bend, knee + 2, shade)
    if paw:
        c.rect(x + bend, y1 - 1, x + 2 + bend, y1, shade)
    else:
        c.rect(x - 1 + bend, y1 - 2, x + 2 + bend, y1, hoof)


def horse_hind_leg(c, x, col, shade):
    """A horse's hind leg: the thigh under the rump, the gaskin slanting back to the hock, then the cannon straight
    down to the hoof."""
    poly(c, [(x - 4, 30), (x + 4, 30), (x + 3, 40), (x - 1, 46), (x - 4, 44), (x - 3, 38)], col)   # thigh and gaskin
    c.rect(x - 3, 44, x - 1, 46, col); c.px(x - 3, 45, shade)                             # the hock
    c.rect(x - 2, 46, x - 1, 56, col); c.px(x - 2, 50, shade)                             # the cannon
    c.rect(x - 3, 56, x, 58, shade)                                                      # the hoof


def horn(c, pts, col, rim_col):
    """A hunting horn along a curve: thin at the mouthpiece, widening to the bell."""
    n = len(pts)
    for i, (x, y) in enumerate(pts):
        r = 0.6 + 2.6 * (i / (n - 1)) ** 2
        ellipse(c, x, y, r, r, col)
    bx, by = pts[-1]
    c.px(bx, by, rim_col); c.px(bx + 1, by, rim_col)


def empusa(shape):
    """Empusa (Aristophanes, The Frogs 285-295): the shape-shifting spectre of the dark road, "now a bull, now a mule,
    now a lovely woman, now a dog", one leg of bronze."""
    def draw(c, step):
        if shape == "woman":
            for k, d in enumerate((-step, step)):
                c.rect(16 + k * 6 + d, 46, 18 + k * 6 + d, 54, "b" if k else "s")       # one leg of bronze
            poly(c, [(14, 18), (28, 18), (32, 48), (10, 48)], "v")
            c.rect(16, 6, 25, 16, "s"); c.px(19, 10, "y"); c.px(23, 10, "y")
            c.rect(14, 3, 27, 7, "h"); c.rect(13, 6, 15, 26, "h"); c.rect(26, 6, 28, 26, "h")
            c.rect(30, 22, 33, 26, "y")                                                 # a glowing hand
            return
        if shape == "bull":
            # A spectral black bull, head lowered to charge; its near foreleg is bronze.
            hoofed_leg(c, 12 - step, 38, 54, "K", "K", "K", bend=-1)                     # far hind leg
            hoofed_leg(c, 37 + step, 38, 54, "K", "K", "K")                               # far foreleg
            poly(c, [(6, 28), (12, 22), (26, 22), (32, 14), (40, 13), (46, 20), (47, 34), (42, 42), (30, 44),
                     (16, 44), (7, 40)], "k")                                            # body: the great shoulder hump
            ellipse(c, 12, 34, 7, 9, "k")                                                # round haunch
            poly(c, [(42, 22), (49, 25), (52, 34), (50, 39), (44, 38), (41, 32)], "k")   # the lowered head
            c.rect(49, 35, 52, 38, "K"); c.px(51, 36, "o")                               # muzzle and nostril
            poly(c, [(44, 24), (41, 19), (42, 15), (44, 14), (44, 18), (46, 23)], "h")  # near horn, curving up and forward
            poly(c, [(47, 24), (49, 19), (52, 16), (53, 17), (50, 21), (49, 25)], "H")  # far horn
            c.px(47, 29, "y"); c.px(48, 29, "y")                                         # burning eye
            for i in range(10):
                c.px(6 - i // 3, 30 + i, "K")                                            # the tail
            c.rect(3, 39, 5, 41, "K")
            hoofed_leg(c, 16 + step, 40, 54, "k", "K", "K", bend=-1)                     # near hind leg
            hoofed_leg(c, 41 - step, 40, 54, "b", "B", "B")                              # near foreleg: bronze
            rim(c, "k", "l")
            for x, y in ((10, 18), (24, 14), (38, 8), (2, 30), (54, 44)):
                c.px(x, y, "g")                                                          # spectral glints
            return
        # The dog: a lean black hound, ears up, one bronze foreleg.
        hoofed_leg(c, 12 - step, 34, 54, "K", "K", "K", bend=-1, paw=True)
        hoofed_leg(c, 34 + step, 34, 54, "K", "K", "K", paw=True)
        poly(c, [(8, 30), (16, 27), (34, 27), (40, 24), (42, 32), (36, 37), (22, 36), (10, 37)], "k")
        poly(c, [(36, 26), (40, 18), (46, 18), (49, 23), (44, 28), (40, 30)], "k")      # neck and head
        poly(c, [(46, 21), (53, 24), (52, 27), (46, 27)], "k"); c.px(52, 24, "o")       # muzzle and nose
        poly(c, [(40, 19), (40, 12), (43, 18)], "k"); poly(c, [(43, 18), (45, 11), (46, 18)], "k")   # pricked ears
        c.px(45, 21, "y"); c.row(26, 47, 51, "y")                                       # burning eye, glowing mouth
        for i in range(8):
            c.px(8 - i, 30 - i // 2, "k")                                                # the tail
        hoofed_leg(c, 16 + step, 35, 54, "k", "K", "K", bend=-1, paw=True)
        hoofed_leg(c, 38 - step, 33, 54, "b", "B", "B", paw=True)                        # bronze foreleg
        rim(c, "k", "l")
        for x, y in ((14, 22), (30, 20), (4, 40)):
            c.px(x, y, "g")
    return draw


EMPUSA_PAL = {"o": "#0e0a10", "k": "#2a2430", "K": "#1a1620", "b": "#c8883a", "B": "#8a5a22", "s": "#d8c8b8",
              "v": "#4a2a4a", "h": "#e0d4c0", "H": "#a89c88", "y": "#f05a3a", "l": "#6a5a7a", "g": "#b89ad8"}


def eurynomos(c, step):
    """Eurynomos (Pausanias 10.28.7, describing Polygnotus' painting): a daemon of the underworld who eats the flesh of
    the dead, leaving only the bones; "his colour is between blue and black, like that of the flies that settle on
    meat; he is showing his teeth, and is seated on the skin of a vulture"."""
    poly(c, [(6, 44), (46, 44), (40, 52), (12, 52)], "f")                               # the vulture's skin
    for k in range(6):
        c.px(8 + k * 7, 46, "F"); c.px(9 + k * 7, 48, "F")
    ellipse(c, 26, 30, 14, 14, "b")
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 18 + d, 38, 19 + k * 18 + d, 46, "B")
    ellipse(c, 26, 14, 9, 8, "b")
    c.px(22, 12, "y"); c.px(30, 12, "y")
    c.rect(20, 17, 32, 19, "k")
    for x in range(21, 32, 2):
        c.px(x, 17, "w"); c.px(x + 1, 19, "w")                                          # the bared teeth
    c.rect(8, 26, 12, 30, "B"); c.rect(40, 26, 44, 30, "B")
    for k in range(3):
        c.px(4 + k * 2, 34, "w")                                                        # a bone in his hand


EURY_PAL = {"o": "#06080e", "b": "#2a3448", "B": "#1a2232", "k": "#0a0a10", "w": "#ece6d8", "y": "#c8f040",
            "f": "#6a5a48", "F": "#4a3e30"}


def wild_hunt(c, step):
    """The Wild Hunt (the Anglo-Saxon Chronicle for 1127: "the huntsmen were black, and big, and loathsome, and their
    hounds all black and wide-eyed and ugly, and they rode on black horses"): a huge black huntsman in a streaming hooded
    cloak, eyes burning, holding up his hunting horn, on a black horse at the gallop."""
    # Far legs of the horse, in shadow
    horse_hind_leg(c, 20 - step * 2, "K", "K")
    hoofed_leg(c, 52 + step * 2, 38, 58, "K", "K", "K", bend=1)
    # The tail: a full tail falling from the top of the rump and streaming back
    pts = [(15, 25), (12, 26), (9, 28), (7, 31), (6, 35), (6, 39), (7, 43), (8, 46)]
    for i, (x, y) in enumerate(pts):
        r = 2.8 - i * 0.2
        ellipse(c, x - step, y, r, r, "k")
    for i, (x, y) in enumerate(pts[2:]):
        c.px(x - step + 1, y, "m")                                                       # a strand of it
    # The horse's body: a deep chest, a long back, the rump rounding over the top of the hind legs
    poly(c, [(15, 26), (20, 23), (44, 24), (54, 22), (58, 30), (56, 40), (46, 42), (28, 42), (20, 40), (15, 34)], "k")
    ellipse(c, 21, 29, 7, 6, "k")                                                        # the quarters
    # The arched neck rising to a long head, held forward
    poly(c, [(50, 24), (58, 12), (64, 10), (66, 14), (60, 26), (56, 32)], "k")
    poly(c, [(62, 10), (72, 18), (73, 22), (69, 23), (60, 16)], "k")
    poly(c, [(61, 8), (62, 3), (64, 8)], "k")                                            # ear
    c.px(66, 13, "y"); c.px(71, 21, "o")                                                 # burning eye, nostril
    for i in range(10):                                                                  # the mane, flying back
        c.px(57 - i, 13 + i, "m"); c.px(56 - i, 15 + i, "m")
    # The huntsman, sitting his horse: a short hooded cape, a dark tunic, the reins in one hand, the horn raised in the other
    poly(c, [(31, 11), (27, 14), (23, 22), (26, 25), (31, 23)], "R")                     # the short cape behind his back
    for y in range(15, 24):
        c.px(27 + (y - 15) // 3, y, "r")                                                 # a fold in it
    poly(c, [(31, 12), (39, 11), (41, 15), (40, 24), (31, 24)], "t")                     # body in a dark tunic
    c.px(39, 16, "T"); c.px(39, 17, "T"); c.px(33, 20, "T")
    c.row(21, 31, 40, "b"); c.px(36, 21, "y")                                            # belt and buckle
    poly(c, [(30, 10), (41, 10), (42, 13), (30, 14)], "R")                               # the cape across his shoulders
    c.px(40, 11, "y")                                                                    # its clasp
    ellipse(c, 36, 6, 4.5, 5, "R")                                                       # the hood
    poly(c, [(33, 2), (30, 5), (32, 7)], "R")                                            # its point, falling back
    poly(c, [(38, 4), (41, 4), (41, 9), (38, 9)], "v")                                   # the dark opening of the hood
    c.px(38, 6, "y"); c.px(40, 6, "y"); c.px(38, 7, "Y"); c.px(40, 7, "Y")              # eyes burning in the hood
    c.px(40, 2, "r"); c.px(41, 3, "r")                                                   # light on the hood's brow
    poly(c, [(39, 14), (45, 9), (47, 10), (41, 17)], "t")                                # the raised arm
    c.rect(46, 7, 48, 10, "b"); c.px(46, 7, "B")                                         # gloved fist
    for i in range(9):                                                                   # the hunting horn held up in his fist
        t = i / 8
        x, y = 47 + t * 7, 8 - t * 7 + t * t * 2
        r = 0.8 + 1.8 * t
        ellipse(c, x, y, r, r, "h")
    c.row(5, 49, 51, "H")                                                                # its band
    c.rect(53, 1, 56, 3, "H")                                                            # the open bell
    poly(c, [(33, 16), (36, 16), (42, 21), (40, 23)], "t")                               # the other arm, forward to the reins
    c.rect(41, 21, 42, 22, "b")                                                          # hand on the reins
    for i in range(15):
        c.px(43 + i, 21 - i // 3, "B")                                                   # the reins, to the horse's mouth
    poly(c, [(31, 23), (38, 23), (41, 27), (35, 29)], "t")                               # thigh over the horse's side
    c.rect(38, 27, 40, 33, "t"); c.px(38, 28, "T")                                       # the lower leg
    c.rect(37, 33, 42, 35, "B"); c.row(36, 36, 42, "y")                                  # boot in the stirrup
    # Near legs of the horse
    horse_hind_leg(c, 24 + step * 2, "k", "K")
    hoofed_leg(c, 48 - step * 2, 40, 58, "k", "K", "K", bend=1)
    rim(c, "kK", "l")
    # A light grey line round the huntsman (not the horse), so he stands out from the dark and from his horse
    edge = []
    for y in range(c.h):
        for x in range(c.w):
            if c.g[y][x] in "RrtTbBvhHyY":
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if not (0 <= nx < c.w and 0 <= ny < c.h) or c.g[ny][nx] not in "RrtTbBvhHyY":
                        edge.append((x, y))
                        break
    for x, y in edge:
        if c.g[y][x] in "RrtT":
            c.px(x, y, "q")
    for x in range(4, 74, 4):
        c.px(x, 59, "g")                                                                 # a pale ghost-light underfoot


HUNT_PAL = {"o": "#2a3040", "R": "#141218", "r": "#3a3848", "v": "#050408", "b": "#4a3422", "B": "#2a1c12", "t": "#363040", "T": "#4a4356",
            "Y": "#b8781a", "q": "#5a5e72", "k": "#1a1820", "K": "#0e0c12", "y": "#f0c040", "m": "#2e2c36", "h": "#c89a50",
            "H": "#6a4420", "l": "#4a4a62", "g": "#8a9ab8"}


# --- Karnstein (Le Fanu, Carmilla 1872; Polidori, The Vampyre 1819; Varney the Vampire 1845-47; Calmet 1746) ---------

def revenant(c, f):
    """A revenant (Calmet, Treatise on Vampires, 1746: the dead who leave their graves at night): a grey-faced corpse in
    a burial shroud, arms out."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "g")
    poly(c, [(6, 8), (13, 8), (14, 19), (5, 19)], "w")
    c.rect(3, 9, 6, 10, "g"); c.rect(13, 9, 16, 10, "g")                                # arms out
    ellipse(c, 9, 5, 3, 3, "g"); c.px(8, 5, "r"); c.px(10, 5, "r"); c.row(7, 8, 10, "k")
    c.row(13, 6, 13, "W")


REVENANT_PAL = {"o": "#141214", "w": "#c8c4b8", "W": "#a8a498", "g": "#8a948a", "r": "#c83a3a", "k": "#1a1414"}


def night_bat(c, f):
    """A bat of the night (Carmilla; Varney the Vampire): a small black bat, wings beating."""
    up = f % 2
    poly(c, [(8, 6), (1, 2 if up else 9), (4, 8)], "k"); poly(c, [(10, 6), (17, 2 if up else 9), (14, 8)], "k")
    ellipse(c, 9, 7, 2.5, 3, "b"); c.px(8, 6, "r"); c.px(10, 6, "r"); c.px(8, 4, "b"); c.px(10, 4, "b")


BAT_PAL = {"o": "#2a2028", "k": "#1a141c", "b": "#2e2430", "r": "#e83a3a"}


def varney(c, step):
    """Sir Francis Varney (Rymer and Prest, Varney the Vampire, 1845-47): tall and gaunt, his face white as death, his
    teeth like fangs, in an old-fashioned dark coat; the moon brings him back to life."""
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 6 + d, 44, 17 + k * 6 + d, 54, "k")
    poly(c, [(13, 16), (27, 16), (29, 46), (11, 46)], "c")
    c.rect(18, 16, 22, 30, "w")                                                         # shirt front
    c.rect(15, 4, 25, 14, "s"); c.px(18, 8, "y"); c.px(22, 8, "y"); c.px(19, 12, "w"); c.px(21, 12, "w")
    c.rect(14, 2, 26, 5, "h")
    c.rect(8, 18, 11, 34, "c"); c.rect(29, 18, 32, 34, "c"); c.rect(7, 34, 10, 37, "s"); c.rect(30, 34, 33, 37, "s")


VARNEY_PAL = {"o": "#0a080c", "k": "#141018", "c": "#2a2430", "w": "#e8e4dc", "s": "#e0dcd4", "y": "#c83a2a",
              "h": "#2a2018"}


def ruthven(c, step):
    """Lord Ruthven (Polidori, The Vampyre, 1819): a nobleman with a dead grey eye and a deadly pale face, coldly
    elegant in a dark coat with a red-lined cloak."""
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 6 + d, 44, 17 + k * 6 + d, 54, "k")
    poly(c, [(10, 16), (30, 16), (34, 48), (6, 48)], "r")                                # the cloak's red lining
    poly(c, [(13, 16), (27, 16), (28, 46), (12, 46)], "c")
    c.rect(18, 16, 22, 24, "w")
    c.rect(15, 5, 25, 14, "s"); c.px(18, 9, "g"); c.px(22, 9, "g"); c.row(12, 18, 22, "S")
    c.rect(14, 2, 26, 6, "h")
    poly(c, [(10, 14), (16, 18), (10, 20)], "c"); poly(c, [(30, 14), (24, 18), (30, 20)], "c")   # high collar


RUTHVEN_PAL = {"o": "#0a080c", "k": "#141018", "c": "#1e1a24", "r": "#7a1420", "w": "#e8e4dc", "s": "#d8d4d0",
               "S": "#a8a4a0", "g": "#9aa0a8", "h": "#3a2a1a"}


def carmilla(cat):
    """Carmilla (Le Fanu, 1872): Mircalla, Countess Karnstein, slender and lovely, with long thick brown hair, in a
    pale gown; at night "a sooty-black animal that resembled a monstrous cat"."""
    def draw(c, step):
        if cat:
            ellipse(c, 26, 32, 18, 8, "k")
            for k, d in enumerate((-step, step, step, -step)):
                c.rect(12 + k * 9 + d, 36, 14 + k * 9 + d, 48, "K")
            ellipse(c, 44, 24, 8, 7, "k"); c.px(41, 23, "y"); c.px(47, 23, "y")
            poly(c, [(38, 18), (39, 12), (42, 17)], "k"); poly(c, [(46, 17), (49, 12), (50, 18)], "k")
            for k in range(10):
                c.px(8 - k // 3, 30 - k, "k"); c.px(9 - k // 3, 30 - k, "k")             # the tail, raised
            return
        for k, d in enumerate((-step, step)):
            c.rect(17 + k * 5 + d, 50, 19 + k * 5 + d, 54, "k")
        poly(c, [(15, 18), (27, 18), (32, 52), (10, 52)], "w")
        c.rect(16, 18, 26, 24, "W")
        c.rect(16, 6, 25, 16, "s"); c.px(19, 10, "e"); c.px(23, 10, "e"); c.px(21, 14, "r")
        c.rect(14, 3, 27, 7, "h"); c.rect(13, 6, 15, 28, "h"); c.rect(26, 6, 28, 28, "h")   # long brown hair
    return draw


CARMILLA_PAL = {"o": "#0a080c", "k": "#141016", "K": "#0a080c", "y": "#e8d040", "w": "#ece8f0", "W": "#c8c4d4",
                "s": "#f0dcd0", "e": "#4a3a5a", "r": "#b0202a", "h": "#5a3a22"}


# --- Ossory (Gerald of Wales c. 1188; Marie de France, Bisclavret; the Lai de Melion; the Beast of Gevaudan 1764-67) --

def werewolf(c, f):
    """A werewolf of Ossory (Gerald of Wales, Topographia Hibernica II.19): a man and a woman of Ossory forced to take
    the shape of wolves. A hulking grey wolf-shape that walks upright on bent wolf's legs, hunched, with long clawed
    arms, a long snout and a tail."""
    s = STEP[f]
    for x, d in ((7, -s), (13, s)):                                                      # bent wolf's legs
        poly(c, [(x, 17), (x + 3, 17), (x + 4, 21), (x + 2, 24), (x + 2, 27), (x, 27), (x, 24), (x + 1, 21)], "G")
        c.rect(x - 1 + 1, 27, x + 3, 27, "K")
    ellipse(c, 11, 15, 6, 6, "g")                                                        # hunched body
    poly(c, [(8, 12), (14, 12), (13, 19), (9, 19)], "l")                                 # paler chest
    poly(c, [(9, 5), (15, 4), (18, 7), (16, 11), (10, 11)], "g")                         # head
    poly(c, [(16, 7), (22, 8), (22, 10), (16, 11)], "g"); c.px(22, 8, "k")               # snout and nose
    c.row(10, 18, 21, "K"); c.px(19, 11, "w"); c.px(21, 11, "w")                         # mouth and fangs
    poly(c, [(10, 5), (10, 0), (13, 4)], "G"); poly(c, [(13, 4), (15, 0), (16, 5)], "g")  # ears
    c.px(16, 7, "y")                                                                     # eye
    poly(c, [(15, 12), (20, 13), (21, 19), (19, 20), (18, 15)], "G")                     # long arm reaching
    c.px(20, 20, "w"); c.px(21, 20, "w"); c.px(19, 21, "w")                              # claws
    poly(c, [(6, 12), (3, 15), (3, 20), (5, 20), (6, 16)], "G"); c.px(3, 21, "w"); c.px(4, 21, "w")
    for i in range(6):
        c.px(5 - i // 2, 20 + i, "G")                                                    # tail


WEREWOLF_PAL = {"o": "#141210", "g": "#7a7266", "G": "#544e46", "K": "#2a2622", "l": "#a8a090", "y": "#e8c040",
                "w": "#ece6d8", "k": "#141010"}


def raven(c, f):
    """A raven over the Irish forest: a big black raven flying, wedge tail, heavy beak, its wings beating with the
    flight feathers spread like fingers."""
    up = f % 2
    poly(c, [(2, 9), (6, 8), (6, 10)], "k")                                              # wedge tail
    ellipse(c, 9, 9, 4, 2.5, "k")                                                        # body
    ellipse(c, 14, 8, 2.5, 2.2, "k"); poly(c, [(15, 7), (19, 8), (15, 9)], "B")         # head, heavy beak
    c.px(14, 7, "w")
    if up:                                                                               # wings raised
        poly(c, [(7, 8), (4, 1), (10, 0), (11, 8)], "K")
        for x in (4, 6, 8, 10):
            c.px(x, 0, "k")
    else:                                                                                # wings spread wide
        poly(c, [(6, 8), (1, 4), (13, 3), (12, 8)], "K")
        for x in (1, 3, 5):
            c.px(x, 3, "k")


RAVEN_PAL = {"o": "#2a2a34", "k": "#141418", "K": "#26262e", "B": "#3a3a44", "w": "#c8c8d0"}


from build_boss_fenrir import front_leg as wolf_front_leg, hind_leg as wolf_hind_leg

WOLF_WALK = [(0, 0), (3, -3), (0, 0), (-3, 3), (0, 0)]


def wolf(snarl=False, ring=False, stripe=False, tuft=False, big_head=False):
    """A great wolf on four legs, drawn on Fenrir's body (tools/art/build_boss_fenrir.py), with its own features:
    a snarl or a closed mouth, a ring on the foreleg (Melion), a black stripe down the back and a tufted tail (the Beast
    of Gevaudan)."""
    def draw(c, legs):
        front, back = legs
        wolf_hind_leg(c, 17 - back, "F", "D")
        wolf_front_leg(c, 44 + front, "F", "D")
        for i in range(16):                                                              # the tail
            t = i / 15
            ellipse(c, 13 - t * 6, 22 + t * 15 - t * t * 3, 3.6 - t * 1.4 + math.sin(t * 3.1) * 0.8, 3.2 - t * 1.0, "f")
        if tuft:
            ellipse(c, 6, 36, 3, 3, "D")
        poly(c, [(13, 23), (19, 19), (31, 19), (42, 14), (49, 14), (54, 20), (55, 27), (51, 32), (44, 31), (34, 28),
                 (25, 29), (16, 30)], "f")
        poly(c, [(44, 15), (51, 8), (58, 8), (60, 16), (56, 25), (50, 20)], "f")
        for x in range(12, 60):                                                          # darker along the back
            for y in range(6, 24):
                if c.g[y][x] == "f" and (c.g[y - 1][x] == "." or c.g[y - 2][x] == "."):
                    c.px(x, y, "D")
        if stripe:
            for x in range(14, 50):                                                      # the black stripe down the back
                for y in range(6, 26):
                    if c.g[y][x] in "fD" and c.g[y - 1][x] == "D":
                        c.px(x, y, "k")
                        break
        poly(c, [(50, 20), (56, 22), (55, 28), (51, 31), (48, 27)], "l")                # pale chest
        poly(c, [(30, 27), (42, 29), (44, 31), (34, 29)], "F")                           # shadow under the belly
        wolf_hind_leg(c, 22 + back, "f", "F")
        wolf_front_leg(c, 49 - front, "f", "F")
        if ring:
            c.rect(49 - front, 40, 53 - front, 41, "g"); c.px(50 - front, 39, "w"); c.px(52 - front, 39, "r")
        hx = 1 if big_head else 0
        ellipse(c, 58, 12, 5 + hx, 4.5 + hx, "f")
        poly(c, [(51, 8), (52, 1), (56, 7)], "F")
        poly(c, [(54, 9), (56, 0), (60, 8)], "f"); poly(c, [(55, 6), (56, 3), (57, 7)], "D")
        poly(c, [(60, 9), (70 + hx, 11), (71 + hx, 14), (68, 17), (60, 18)], "f")
        ellipse(c, 57, 9, 4, 3, "f")
        c.px(57, 7, "D"); c.px(58, 7, "D"); c.px(59, 7, "D")
        c.rect(70 + hx, 11, 71 + hx, 12, "k")
        if snarl:
            c.row(15, 62, 69 + hx, "k")
            for x in range(63, 70 + hx, 2):
                c.px(x, 16, "w")
            c.row(16, 61, 62, "r")
        else:
            c.row(15, 63, 68, "F")                                                       # a closed mouth
        c.px(60, 10, "y"); c.px(61, 10, "y"); c.px(61, 11, "k")
        poly(c, [(55, 14), (61, 17), (59, 20), (55, 19)], "l")
    return draw


def bisclavret_man(c, step):
    """Bisclavret as the Breton baron once more: a tall man with brown hair and a short beard, a blue tunic belted with
    gold, a red cloak over his shoulders, and boots."""
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 7 + d, 42, 18 + k * 7 + d, 50, "t"); c.rect(14 + k * 7 + d, 50, 19 + k * 7 + d, 53, "B")
    poly(c, [(11, 16), (31, 16), (34, 48), (8, 48)], "c"); poly(c, [(11, 16), (8, 48), (12, 48), (14, 20)], "C")   # the cloak
    poly(c, [(14, 17), (28, 17), (30, 43), (12, 43)], "r")                                # the tunic
    for y in range(20, 42, 4):
        c.px(16, y, "R"); c.px(26, y + 2, "R")
    c.row(30, 13, 29, "y"); c.px(21, 30, "Y")                                             # gold belt
    c.rect(29, 19, 32, 33, "r"); c.rect(29, 33, 32, 36, "s")                              # arm and hand
    c.rect(16, 4, 26, 15, "s"); c.px(16, 9, "S")                                          # face
    c.rect(15, 1, 27, 5, "h"); c.rect(15, 5, 16, 11, "h")                                 # hair
    c.rect(17, 12, 26, 16, "h"); c.rect(19, 13, 23, 13, "s")                              # beard and mouth
    c.px(20, 9, "k"); c.px(24, 9, "k"); c.row(8, 19, 21, "H"); c.row(8, 23, 25, "H")     # eyes and brows
    c.px(13, 17, "y"); c.px(29, 17, "y")                                                  # cloak clasps


BISCLAVRET_PAL = {"o": "#1e140c", "k": "#1a1414", "f": "#9a8468", "F": "#6e5c46", "D": "#4a3c2c", "l": "#d8ccb4",
                  "y": "#e8c040", "Y": "#a8801a", "r": "#3a5a8a", "R": "#2a4268", "w": "#f0ead8", "c": "#8a2a2a",
                  "C": "#5a1a1a", "t": "#4a3a2a", "B": "#2a1e12", "s": "#e0b890", "S": "#b88a68", "h": "#6a4a2a",
                  "H": "#3a2a18"}
MELION_PAL = {"o": "#0e0a08", "k": "#0a0806", "f": "#4a4642", "F": "#34312e", "D": "#24221f", "l": "#8a8680",
              "y": "#e8c040", "r": "#c83030", "w": "#f0f0f0", "g": "#e0b830"}
GEVAUDAN_PAL = {"o": "#120804", "k": "#140a06", "f": "#9a5428", "F": "#6e3a1a", "D": "#4a2810", "l": "#c8946a",
                "y": "#f0c040", "r": "#8a1a1a", "w": "#f4f0e4"}


# --- The Brocken (Goethe, Faust I 1808: Walpurgis Night; Praetorius 1668; Silberschlag 1780; Black Annis) ------------

def witch(c, f):
    """A witch of Walpurgis Night (Goethe, Faust I; Praetorius, Blockes-Berges Verrichtung, 1668): an old woman riding
    a broomstick up the Brocken."""
    s = STEP[f]
    c.row(15 + s, 0, 20, "b"); c.rect(0, 13 + s, 3, 17 + s, "y")                          # the broom
    poly(c, [(7, 6 + s), (14, 6 + s), (15, 15 + s), (6, 15 + s)], "k")
    ellipse(c, 11, 4 + s, 2.5, 2.5, "g"); c.px(12, 4 + s, "y")
    poly(c, [(8, 2 + s), (11, -4 + s), (14, 2 + s)], "k"); c.row(2 + s, 7, 15, "k")        # pointed hat


WITCH_PAL = {"o": "#0e0a10", "k": "#24182a", "g": "#9aaa7a", "y": "#d8b040", "b": "#6a4a2a"}


def black_goat(c, f):
    """A black goat of the witches' ride (Praetorius; Faust: they ride up on goats): a shaggy black goat with a beard,
    horns curling back, a yellow eye, and cloven hooves."""
    s = STEP[f]
    for k, d in enumerate((-s, s, s, -s)):                                               # thin legs, cloven hooves
        x = 5 + k * 4 + d
        c.rect(x, 12, x, 16, "K"); c.px(x, 17, "h")
    ellipse(c, 10, 9, 7, 4, "k")
    for x in range(4, 17, 2):
        c.px(x, 13, "k")                                                                 # shaggy fringe
    poly(c, [(15, 5), (19, 6), (21, 9), (18, 10), (15, 9)], "k")                         # head
    poly(c, [(16, 5), (14, 1), (12, 2), (14, 5)], "h")                                   # horn, curling back
    c.px(12, 3, "h"); c.px(18, 7, "y")                                                   # eye
    c.rect(19, 10, 20, 12, "K")                                                          # beard
    c.px(3, 6, "k"); c.px(2, 5, "k")                                                     # tail
    for x, y in ((6, 6), (10, 5), (14, 6), (18, 5)):
        c.px(x, y, "l")                                                                  # light along the back


GOAT_PAL = {"o": "#3a3842", "k": "#1e1c24", "K": "#121016", "y": "#e8c040", "h": "#b8ac94", "l": "#44424e"}


def brocken_spectre(c, step):
    """The Brocken Spectre (Johann Silberschlag, 1780): the giant shadow a climber casts on the mist below the summit,
    huge and dim, with a ring of coloured light (a glory) round its head."""
    for r, col in ((15, "v"), (14, "b"), (13, "g"), (12, "y"), (11, "r")):               # the glory round its head
        for k in range(72):
            a = k / 72 * math.tau
            c.px(round(28 + r * math.cos(a)), round(14 + r * math.sin(a)), col)
    for k, d in enumerate((-step, step)):                                                # long legs, striding
        poly(c, [(20 + k * 10 + d, 46), (25 + k * 10 + d, 46), (24 + k * 10 + d, 66), (20 + k * 10 + d, 66)], "s")
    poly(c, [(19, 22), (37, 22), (40, 48), (16, 48)], "s")                               # the body, spreading into mist
    ellipse(c, 28, 14, 6, 7, "s")                                                        # the head
    poly(c, [(19, 23), (8, 30), (6, 44), (10, 44), (13, 32), (20, 28)], "s")             # arms out from the sides
    poly(c, [(37, 23), (48, 30), (50, 44), (46, 44), (43, 32), (36, 28)], "s")
    for y in range(4, 68):
        for x in range(56):
            if c.g[y][x] == "s" and (x * 7 + y * 3) % 11 == 0:
                c.px(x, y, "m")                                                          # mist drifting through it
            elif c.g[y][x] == "s" and any(0 <= x + dx < 56 and c.g[y][x + dx] == "." for dx in (-1, 1)):
                c.px(x, y, "e")                                                          # its edges dissolving


SPECTRE_PAL = {"o": "#3a3e4a", "s": "#454b5a", "e": "#5a6274", "m": "#8a92a6", "r": "#c86a5a", "y": "#d8c070",
               "g": "#7ab07a", "b": "#6a8ac8", "v": "#8a6ab0"}


def baubo(c, step):
    """Baubo (Goethe, Faust I, Walpurgis Night: "Old Baubo comes alone; she rides a farrow sow"): an old witch riding a
    great sow up the mountain."""
    ellipse(c, 28, 38, 18, 9, "p")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(14 + k * 9 + d, 44, 17 + k * 9 + d, 54, "P")
    ellipse(c, 46, 36, 6, 6, "p"); c.rect(50, 36, 54, 39, "P"); c.px(52, 37, "k"); c.px(45, 33, "k")
    poly(c, [(42, 30), (44, 26), (46, 30)], "p"); c.px(10, 34, "p"); c.px(9, 33, "p")
    poly(c, [(20, 14), (32, 14), (34, 32), (18, 32)], "k")                                  # the old witch
    ellipse(c, 26, 10, 4, 4, "g"); c.px(28, 10, "y")
    poly(c, [(21, 8), (26, 0), (31, 8)], "k"); c.row(8, 20, 32, "k")
    c.rect(32, 20, 36, 22, "g")


BAUBO_PAL = {"o": "#120c10", "p": "#c8907a", "P": "#a06a58", "k": "#2a1e2a", "g": "#9aaa7a", "y": "#d8b040"}


def black_annis(c, step):
    """Black Annis (Leicestershire folklore): a hag with a blue face and long iron claws, who dug her bower in the Dane
    Hills with her claws."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 6 + d, 46, 18 + k * 6 + d, 54, "k")
    poly(c, [(12, 18), (30, 18), (34, 48), (8, 48)], "k")
    c.rect(16, 6, 26, 16, "b"); c.px(19, 10, "y"); c.px(23, 10, "y"); c.row(14, 18, 24, "K")
    c.rect(14, 3, 28, 7, "h"); c.rect(13, 6, 15, 26, "h"); c.rect(27, 6, 29, 26, "h")       # wild grey hair
    c.rect(4, 22, 9, 30, "b"); c.rect(33, 22, 38, 30, "b")
    for k in range(4):
        c.rect(2 + k * 2, 31, 2 + k * 2, 37, "i"); c.rect(32 + k * 2, 31, 32 + k * 2, 37, "i")   # iron claws


ANNIS_PAL = {"o": "#08080c", "k": "#1e1a20", "K": "#0e0c10", "b": "#3a5ab0", "y": "#f0e040", "h": "#a8a8a8",
             "i": "#8a9098"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_gothic.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("ker", ker, KER_PAL, doc(ker.__doc__), (20, 20), (10, 19), walk, folder="enemies")
    kit.build_boss("hunt_hound", hunt_hound, HOUND_PAL, doc(hunt_hound.__doc__), (24, 16), (11, 15), walk, folder="enemies")
    kit.build_boss("empusa", empusa("woman"), EMPUSA_PAL, doc(empusa.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    for shape in ("bull", "dog"):
        kit.build_boss("empusa_" + shape, empusa(shape), EMPUSA_PAL, doc(empusa.__doc__ + " Here, as a %s." % shape),
                       (56, 56), (26, 54), [0, 1, 0, -1, 0])
    kit.build_boss("eurynomos", eurynomos, EURY_PAL, doc(eurynomos.__doc__), (52, 54), (26, 52), [0, 1, 0, -1, 0])
    kit.build_boss("wild_hunt", wild_hunt, HUNT_PAL, doc(wild_hunt.__doc__), (76, 61), (37, 59), [0, 1, 0, -1, 0])
    kit.build_boss("revenant", revenant, REVENANT_PAL, doc(revenant.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    for bat in ("night_bat", "night_bat_flyer"):
        kit.build_boss(bat, night_bat, BAT_PAL, doc(night_bat.__doc__), (18, 12), (9, 11), walk, folder="enemies")
    kit.build_boss("varney", varney, VARNEY_PAL, doc(varney.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("ruthven", ruthven, RUTHVEN_PAL, doc(ruthven.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("carmilla", carmilla(False), CARMILLA_PAL, doc(carmilla.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("carmilla_cat", carmilla(True), CARMILLA_PAL, doc(carmilla.__doc__ + " Here, as the cat."), (56, 50),
                   (26, 48), [0, 1, 0, -1, 0])
    kit.build_boss("werewolf", werewolf, WEREWOLF_PAL, doc(werewolf.__doc__), (24, 28), (12, 27), walk, folder="enemies")
    kit.build_boss("raven", raven, RAVEN_PAL, doc(raven.__doc__), (20, 16), (10, 15), walk, folder="enemies")
    BISCLAVRET_DOC = ("Bisclavret (Marie de France, 12th c.): a Breton baron who becomes a wolf in the woods three days a "
                      "week; when his wife hides his clothes he must stay a wolf, until the king gives them back. A great "
                      "gentle grey-brown wolf, mouth closed (drawn on Fenrir's body).")
    kit.build_boss("bisclavret", wolf(), BISCLAVRET_PAL, doc(BISCLAVRET_DOC), (74, 54), (36, 52), WOLF_WALK)
    kit.build_boss("bisclavret_man", bisclavret_man, BISCLAVRET_PAL, doc(BISCLAVRET_DOC + " Here, a man again: " + bisclavret_man.__doc__),
                   (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("melion", wolf(snarl=True, ring=True), MELION_PAL, doc(
        "Melion (the Lai de Melion, 13th c.): a knight of Arthur's turned into a wolf by a ring with a white and a red "
        "stone, left so by his faithless wife, who led a pack of wolves through Ireland. A big dark wolf, snarling, the "
        "gold ring with its two stones still on his foreleg (drawn on Fenrir's body)."), (74, 54), (36, 52), WOLF_WALK)
    kit.build_boss("gevaudan", wolf(snarl=True, stripe=True, tuft=True, big_head=True), GEVAUDAN_PAL, doc(
        "The Beast of Gevaudan (French newspapers of 1764-67): a huge wolf-like beast, bigger than a calf, reddish, with "
        "a black stripe down its back, a wide pale chest, a big head, a long tufted tail and great teeth (drawn on "
        "Fenrir's body)."), (76, 54), (36, 52), WOLF_WALK)
    kit.build_boss("witch", witch, WITCH_PAL, doc(witch.__doc__), (22, 20), (11, 19), walk, folder="enemies")
    kit.build_boss("black_goat", black_goat, GOAT_PAL, doc(black_goat.__doc__), (22, 18), (11, 17), walk, folder="enemies")
    kit.build_boss("brocken_spectre", brocken_spectre, SPECTRE_PAL, doc(brocken_spectre.__doc__), (56, 68), (28, 66), [0, 1, 0, -1, 0])
    kit.build_boss("baubo", baubo, BAUBO_PAL, doc(baubo.__doc__), (58, 56), (28, 54), [0, 1, 0, -1, 0])
    kit.build_boss("black_annis", black_annis, ANNIS_PAL, doc(black_annis.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    print("wrote Gothic Night's art")
