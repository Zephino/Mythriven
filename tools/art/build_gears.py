# Gears and Plunder's art (Pack 9, docs/PACK_9_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Homer, Apollodorus, Apollonius; Rossetti 1862; the General History of the Pyrates 1724; Pontoppidan 1752;
# Paracelsus; Baum's Ozma of Oz 1907, the book), never later versions.
# Run: python3 build_gears.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly, Canvas
from figure_kit import person
from build_gothic import empusa as gothic_beast, wolf as wolf_body, WOLF_WALK

STEP = [0, -1, 0, 1, 0]


def figure(c, step, robe, skin, hair, legs="k", x0=14, top=18, bottom=50):
    """A standing figure in a long robe or coat (shared by the boss figures)."""
    for k, d in enumerate((-step, step)):
        c.rect(x0 + 2 + k * 6 + d, bottom - 2, x0 + 4 + k * 6 + d, bottom + 4, legs)
    poly(c, [(x0, top), (x0 + 14, top), (x0 + 17, bottom), (x0 - 3, bottom)], robe)
    c.rect(x0 + 2, top - 12, x0 + 11, top - 2, skin)
    c.rect(x0, top - 15, x0 + 13, top - 11, hair)
    c.px(x0 + 4, top - 8, "o"); c.px(x0 + 9, top - 8, "o")


# --- Lemnos (Iliad 1.590-594, 18.373-420; Odyssey 7.91-94; Apollodorus 1.9.23, 1.9.26; Argonautica 4.1638-1688) ---

def bronze_automaton(c, f):
    """A bronze automaton of Hephaestus' forge (Iliad 18: his self-moving works): a jointed bronze man, rivets at every
    joint, a gear turning in his chest, eyes glowing like coals."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 16, x + 1 + d, 18, "z"); c.px(x + d, 19, "y"); c.rect(x + d, 20, x + 1 + d, 22, "B")   # jointed legs
    poly(c, [(5, 8), (14, 8), (13, 15), (6, 15)], "z"); poly(c, [(5, 8), (7, 8), (7, 15), (6, 15)], "B")
    ellipse(c, 9, 11, 2, 2, "B"); c.px(9, 11, "y"); c.px(9, 9, "y"); c.px(11, 11, "y"); c.px(7, 11, "y")   # turning gear
    c.rect(6, 15, 13, 16, "B")
    c.rect(3, 9, 4, 12, "z"); c.px(3, 13, "y"); c.rect(3, 14, 4, 16, "B")             # jointed arms
    c.rect(15, 9, 16, 12, "z"); c.px(16, 13, "y"); c.rect(15, 14, 16, 16, "B")
    c.rect(7, 2, 12, 7, "z"); c.row(2, 7, 12, "y"); c.rect(7, 2, 7, 7, "B")            # head
    c.px(8, 4, "r"); c.px(11, 4, "r"); c.row(6, 8, 11, "B")                            # glowing eyes, mouth-slot
    c.px(9, 1, "y"); c.px(10, 1, "y")


AUTOMATON_PAL = {"o": "#1a0e04", "z": "#c08a3a", "B": "#8a5a24", "y": "#f0d070", "k": "#2a1a0a", "r": "#f05a2a"}


def golden_handmaiden(c, f):
    """A golden handmaiden (Iliad 18.417-420: "made of gold, like living girls; they have understanding, speech and
    strength"): a maiden all of gold, her hair bound up, in a long pleated gown, gleaming."""
    s = STEP[f]
    poly(c, [(6, 9), (13, 9), (15, 22), (4, 22)], "y"); poly(c, [(6, 9), (8, 9), (7, 22), (4, 22)], "Y")   # gown
    for x in (8, 10, 12):
        c.rect(x, 14, x, 21, "Y")                                                          # pleats
    c.row(13, 6, 13, "w")                                                                  # girdle
    c.rect(3, 10, 4, 15, "Y"); c.rect(15, 10, 16, 15, "y")                                 # arms
    ellipse(c, 9, 5, 3, 3.4, "y"); ellipse(c, 9, 2, 3.2, 1.8, "Y"); ellipse(c, 9, 0, 1.5, 1, "Y")   # head, bound hair
    c.px(8, 5, "k"); c.px(11, 5, "k")
    c.px(7, 4, "w"); c.px(12, 11, "w"); c.px(5, 18, "w"); c.px(16, 9, "w")                 # gleam
    c.px(9 - s, 22, "Y"); c.px(11 + s, 22, "Y")


HANDMAIDEN_PAL = {"o": "#3a2a04", "y": "#e8c040", "Y": "#b08a20", "k": "#4a3410", "w": "#fff4b0"}


def aeetes_bulls(c, step):
    """The Bulls of Aeetes (Apollodorus 1.9.23): two bronze-footed bulls Hephaestus made, which breathed fire; Jason had
    to yoke them and plough with them. Two great bronze bulls side by side, heads lowered, riveted, flame pouring from
    their mouths (drawn on the bull body of Empusa)."""
    far = Canvas(56, 56)
    gothic_beast("bull")(far, -step)
    dark = {"k": "m", "K": "M", "b": "M", "B": "M", "h": "M", "H": "M", "l": "m", "y": "y", "g": "f"}
    for y in range(56):
        for x in range(56):
            ch = far.g[y][x]
            if ch != "." and 0 <= x + 12 < c.w and 0 <= y - 6 < c.h:
                c.px(x + 12, y - 6, dark.get(ch, ch))                                      # the far bull, behind
    near = Canvas(56, 56)
    gothic_beast("bull")(near, step)
    for y in range(56):
        for x in range(56):
            if near.g[y][x] != ".":
                c.px(x, y, near.g[y][x])
    for x, y in ((14, 26), (22, 22), (30, 20), (38, 22), (18, 34), (30, 34)):
        c.px(x, y, "y")                                                                    # rivets
    for x0, y0 in ((52, 35), (64, 29)):                                                    # fire pouring from their mouths
        for i in range(9):
            r = 1 + i * 0.4
            ellipse(c, x0 + i * 1.6, y0 + i * 0.5, r, r * 0.8, "f" if i > 3 else "F")
        c.px(x0 + 2, y0, "w")


BULLS_PAL = {"o": "#1a0e04", "k": "#c08a3a", "K": "#8a5a24", "b": "#c08a3a", "B": "#8a5a24", "h": "#e0c070",
             "H": "#a8843a", "l": "#f0c878", "y": "#ffd040", "g": "#f08a2a", "m": "#9a6a2a", "M": "#6a4418",
             "f": "#f05a2a", "F": "#ffd040", "w": "#fff8d0", "s": "#c08a3a", "v": "#c08a3a"}


def gold_silver_hound(gold):
    """The gold and silver hounds of Alcinous (Odyssey 7.91-94): dogs Hephaestus made with cunning skill to guard the
    house of great-hearted Alcinous, immortal and ageless all their days. A great hound of gleaming gold or of silver,
    standing guard, mouth closed (drawn on the wolf body)."""
    return wolf_body()


HOUNDS_GOLD_PAL = {"o": "#2a1a04", "k": "#3a2404", "f": "#e8c040", "F": "#b08a20", "D": "#8a6410", "l": "#fff0a0",
                   "y": "#ffffff", "r": "#8a2020", "w": "#fff8e0"}
HOUNDS_SILVER_PAL = {"o": "#1a1c24", "k": "#20242c", "f": "#d8dce4", "F": "#a0a6b0", "D": "#7a808a", "l": "#ffffff",
                     "y": "#5a8ab8", "r": "#8a2020", "w": "#ffffff"}


def talos(hot):
    """Talos (Argonautica 4.1638-1688; Apollodorus 1.9.26): the bronze giant who guarded Crete, running round it three
    times a day and hurling rocks at ships; one vein ran from his neck to his ankle, stopped by a bronze nail. A huge,
    heavily muscled man of bronze, short curled hair, blank glowing eyes, the vein running down him to the nail in his
    ankle; red-hot when he heats himself."""
    def draw(c, step):
        m, d, l = ("r", "R", "y") if hot else ("z", "Z", "l")
        for k, dd in enumerate((-step, step)):                                             # massive legs
            x = 16 + k * 12 + dd
            poly(c, [(x, 46), (x + 7, 46), (x + 6, 64), (x + 1, 64)], m); c.rect(x, 64, x + 7, 67, d)
            c.rect(x + 2, 50, x + 2, 62, d)
        poly(c, [(12, 22), (42, 22), (38, 40), (16, 40)], m)                               # huge chest
        c.row(29, 18, 36, d); c.rect(27, 24, 27, 40, d); c.row(34, 19, 35, d); c.row(38, 20, 34, d)   # muscles
        poly(c, [(15, 40), (39, 40), (41, 48), (13, 48)], d); c.row(40, 15, 39, l)          # bronze kilt, its rim
        for side in (-1, 1):                                                               # great arms
            x = 27 + side * 17
            poly(c, [(x - 4, 21), (x + 4, 21), (x + side * 2 + 3, 40), (x + side * 2 - 3, 40)], m)
            c.px(x, 27, d); c.px(x, 28, d)
            ellipse(c, x + side * 2, 42, 3.5, 3.5, m)
        c.rect(23, 17, 31, 22, m)                                                          # thick neck
        ellipse(c, 27, 11, 7, 8, m); ellipse(c, 27, 5, 7, 3.5, d)                          # head, curled hair
        for x in range(21, 34, 2):
            c.px(x, 4, l)
        c.rect(23, 11, 25, 11, "w"); c.rect(29, 11, 31, 11, "w")                           # blank glowing eyes
        c.px(27, 13, d); c.row(16, 25, 29, d)
        for y in range(18, 64):
            c.px(26 + (y // 9) % 2, y, "v")                                                # the one vein, neck to ankle
        c.rect(26, 63, 28, 64, "n"); c.px(27, 62, "n")                                     # the bronze nail in his ankle
        for x, y in ((18, 26), (36, 25), (24, 36), (10, 30)):
            c.px(x, y, l)                                                                  # gleam
    return draw


TALOS_PAL = {"o": "#1a0a04", "z": "#c08a3a", "Z": "#8a5a24", "l": "#f0c878", "r": "#f06a2a", "R": "#c83a10",
             "y": "#ffe070", "w": "#fff8d0", "v": "#8a2a10", "n": "#f0e0a0"}


# --- The Goblin Market (Christina Rossetti, Goblin Market, 1862) ------------------------------------------------------

def goblin_face(c, cx, cy, kind):
    """A goblin merchant's animal face (Rossetti: "one had a cat's face, one whisked a tail, one tramped at a rat's
    pace ... one like a wombat prowled obtuse and furry"): cat, rat or wombat."""
    if kind == "cat":
        ellipse(c, cx, cy, 3.5, 3, "c")
        poly(c, [(cx - 3, cy - 2), (cx - 3, cy - 6), (cx - 1, cy - 3)], "c")
        poly(c, [(cx + 3, cy - 2), (cx + 3, cy - 6), (cx + 1, cy - 3)], "c")
        c.px(cx - 1, cy - 1, "y"); c.px(cx + 1, cy - 1, "y"); c.px(cx, cy + 1, "p")
        c.px(cx - 4, cy + 1, "w"); c.px(cx + 4, cy + 1, "w")                               # whiskers
    elif kind == "rat":
        ellipse(c, cx, cy, 3, 2.6, "g")
        poly(c, [(cx + 2, cy - 1), (cx + 6, cy + 1), (cx + 2, cy + 2)], "g"); c.px(cx + 6, cy + 1, "p")   # snout
        ellipse(c, cx - 2, cy - 3, 1.6, 1.6, "p"); ellipse(c, cx + 1, cy - 3, 1.6, 1.6, "p")             # round ears
        c.px(cx + 1, cy - 1, "k")
    else:
        ellipse(c, cx, cy, 4, 3.4, "W")                                                    # wombat: blunt and furry
        c.rect(cx - 1, cy + 1, cx + 2, cy + 2, "k"); c.px(cx - 2, cy - 1, "k"); c.px(cx + 2, cy - 1, "k")
        c.px(cx - 3, cy - 3, "W"); c.px(cx + 3, cy - 3, "W")


def goblin_man(c, f):
    """A goblin merchant-man (Rossetti: "one had a cat's face, one whisked a tail"): a small cat-faced goblin in a
    patched brown coat, his tail whisking, a basket of fruit on his arm."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 16, x + 1 + d, 19, "k"); c.rect(x - 1 + d, 20, x + 1 + d, 20, "k")
    poly(c, [(5, 9), (13, 9), (14, 17), (4, 17)], "b"); c.px(6, 12, "B"); c.px(11, 14, "B")   # patched coat
    for i in range(5):
        c.px(3 - i // 2, 13 - i + s, "c")                                                  # whisking tail
    goblin_face(c, 9, 5, "cat")
    ellipse(c, 15, 13, 3, 2, "B"); c.px(14, 11, "r"); c.px(16, 11, "q"); c.px(15, 12, "y")   # basket of fruit


GOBLIN_PAL = {"o": "#120a06", "k": "#2a1a10", "b": "#6a4a2a", "B": "#8a6a3a", "c": "#8a7a5a", "y": "#e8d040",
              "p": "#d89a8a", "w": "#d8d0c0", "g": "#7a7068", "W": "#6a5a48", "r": "#c82a3a", "q": "#e88a2a",
              "v": "#6a2a8a"}


def rat_goblin(c, f):
    """A rat-paced goblin (Rossetti: "one tramped at a rat's pace"): a small grey goblin scurrying on all fours like a
    rat, a long bare tail behind, a little pack of fruit on its back."""
    s = STEP[f]
    for i in range(6):
        c.px(2 - i // 3, 8 + i // 2, "p")                                                  # long bare tail
    ellipse(c, 8, 8, 5, 3, "g"); c.row(10, 4, 12, "G")
    poly(c, [(12, 6), (16, 8), (12, 10)], "g"); c.px(16, 8, "p"); c.px(13, 7, "r")         # snout, red eye
    ellipse(c, 11, 4, 1.5, 1.5, "p")                                                       # round ear
    ellipse(c, 7, 4, 2.5, 1.8, "b"); c.px(6, 3, "q"); c.px(8, 3, "r")                      # pack of fruit
    for x, d in ((5, s), (8, -s), (11, s)):
        c.px(x + d, 11, "G"); c.px(x + d, 12, "G")


RAT_PAL = {"o": "#120c0a", "g": "#7a7068", "G": "#4a4440", "r": "#e8203a", "p": "#c89a8a", "b": "#6a4a2a",
           "q": "#e88a2a"}


def ratel_goblin(c, step):
    """The Ratel Goblin (Rossetti: "one like a ratel tumbled hurry skurry"): a squat goblin like a honey badger, black
    below with a broad grey-white mantle from its brow to its tail, short strong legs with long claws, small fierce
    eyes."""
    for k, (x, d) in enumerate(((12, -step), (20, step), (32, step), (40, -step))):       # short strong legs, long claws
        poly(c, [(x - 2, 30), (x + 3, 30), (x + 3, 40), (x - 2, 40)], "k")
        for t in range(3):
            c.px(x - 1 + t * 2 + d, 41, "w")
    poly(c, [(6, 28), (12, 20), (36, 18), (44, 22), (46, 32), (40, 36), (10, 36)], "k")    # the squat body
    poly(c, [(8, 26), (14, 19), (38, 17), (44, 22), (40, 23), (14, 25)], "w")             # grey-white mantle along the back
    for x in range(14, 40, 3):
        c.px(x, 22, "W")
    ellipse(c, 46, 28, 5, 4.5, "k")                                                        # head
    poly(c, [(42, 22), (49, 24), (47, 26), (42, 25)], "w")                                 # the mantle over its brow
    c.px(48, 27, "y"); c.px(51, 30, "w"); c.px(50, 31, "w")                                # fierce eye, teeth
    for i in range(4):
        c.px(5 - i, 27 + i // 2, "k")                                                      # short tail


RATEL_PAL = {"o": "#0a0806", "k": "#1e1a18", "w": "#d8d4cc", "W": "#a8a49c", "y": "#e8c040"}


def snail_goblin(c, step):
    """The Snail Goblin (Rossetti: "one crawled like a snail"): a fat goblin crawling under a great spiral shell, with
    a goblin's grinning face and eyes on stalks, its slime trail glistening behind it."""
    for x in range(0, 46, 2):
        c.px(x, 47, "s"); c.px(x + 1, 46, "S")                                             # the slime trail
    poly(c, [(4, 46), (40, 46), (46, 40), (44, 34), (36, 36), (8, 40)], "b")               # the long soft foot
    poly(c, [(36, 40), (46, 40), (44, 44), (38, 44)], "B")
    ellipse(c, 20, 26, 15, 14, "h")                                                        # the great shell
    for i in range(70):                                                                    # its spiral
        a = i * 0.18
        r = 14 - i * 0.19
        if r > 1:
            c.px(round(20 + r * math.cos(a)), round(26 + r * math.sin(a)), "H")
    ellipse(c, 16, 20, 5, 3, "l")                                                          # gloss
    ellipse(c, 41, 34, 5, 5, "b")                                                          # goblin's head
    for sx, top in ((39, 24), (44, 22)):                                                   # eyes on stalks
        c.rect(sx, top, sx, 31, "b"); ellipse(c, sx, top, 1.5, 1.5, "w"); c.px(sx, top, "k")
    c.row(36, 38, 44, "k"); c.px(39, 37, "w"); c.px(43, 37, "w")                           # a sly grin


SNAIL_PAL = {"o": "#120c08", "b": "#8a7a5a", "B": "#6a5a40", "h": "#a8703a", "H": "#6a4024", "l": "#d8a870",
             "k": "#1a1008", "s": "#a8d8a0", "S": "#c8f0c0", "w": "#f0ece0"}


def goblin_merchants(c, step):
    """The Goblin Merchant-Men (Rossetti: "Come buy our orchard fruits, come buy, come buy"): three goblin merchants
    with a cat's face, a rat's and a wombat's, in patched coats and hoods, holding up between them a tray heaped with
    fruit, crying their wares."""
    poly(c, [(2, 16), (48, 16), (46, 19), (4, 19)], "B")                                   # the tray
    for i, (x, col) in enumerate(((5, "r"), (9, "v"), (13, "y"), (17, "q"), (21, "r"), (25, "v"), (29, "y"),
                                  (33, "q"), (37, "r"), (41, "v"), (45, "y"))):
        ellipse(c, x, 13 + (i % 2), 2, 2, col); c.px(x - 1, 12 + (i % 2), "w")              # heaped fruit, shining
    ellipse(c, 15, 10, 2, 2, "q"); ellipse(c, 27, 10, 2, 2, "r"); ellipse(c, 35, 10, 2, 2, "v")
    for k, (x, face) in enumerate(((9, "cat"), (25, "rat"), (41, "wombat"))):
        dy = step if k % 2 else -step
        for lx in (x - 3, x + 2):
            c.rect(lx, 44 + dy, lx + 1, 50, "k"); c.rect(lx - 1, 51, lx + 2, 52, "k")
        poly(c, [(x - 6, 27), (x + 6, 27), (x + 7, 45), (x - 7, 45)], "b")                 # patched coat
        c.px(x - 3, 33, "B"); c.px(x + 2, 38, "B"); c.row(36, x - 6, x + 6, "k")
        c.rect(x - 7, 19, x - 6, 28, "b"); c.rect(x + 6, 19, x + 7, 28, "b")               # arms up to the tray
        goblin_face(c, x, 23 + dy, face)
        poly(c, [(x - 4, 19 + dy), (x, 15 + dy), (x + 4, 19 + dy)], "B") if face != "cat" else None   # hood
    for i in range(6):
        c.px(2 - i // 3, 40 - i + step, "c")                                               # a whisking tail


MERCHANTS_PAL = dict(GOBLIN_PAL)


# --- Libertalia (A General History of the Pyrates, 1724; Pontoppidan, 1752) -------------------------------------------

def buccaneer(c, f):
    """A buccaneer of Libertalia (the General History of the Pyrates): a sailor in a striped shirt, a red sash and a red
    head-scarf knotted behind, knee breeches and bare shins, a gold ring in his ear and a curved cutlass."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 15, x + 2 + d, 18, "n"); c.rect(x + d, 19, x + 1 + d, 21, "s")   # breeches, bare shins
        c.rect(x + d, 22, x + 2 + d, 23, "k")
    for y in range(7, 15):
        c.row(y, 5, 14, "w" if y % 2 else "u")                                           # striped shirt
        c.px(5, y, "W" if y % 2 else "U")
    c.rect(3, 8, 4, 12, "u"); c.px(3, 9, "w"); c.px(3, 11, "w"); c.px(3, 13, "S")       # far arm
    c.row(14, 5, 14, "r"); c.row(15, 5, 14, "R"); c.px(5, 16, "r"); c.px(4, 17, "R")   # red sash
    c.rect(15, 8, 16, 11, "u"); c.px(15, 9, "w"); c.px(16, 12, "s")                      # near arm
    for x, y in ((17, 11), (17, 10), (18, 9), (18, 8), (18, 7), (17, 6)):
        c.px(x, y, "i")                                                                  # curved cutlass
    c.px(19, 8, "I"); c.row(12, 15, 18, "y")
    ellipse(c, 9, 4, 3, 3, "s"); c.px(7, 5, "S")
    c.px(9, 4, "k"); c.px(12, 4, "k"); c.row(6, 9, 12, "S"); c.px(11, 6, "m")          # eyes, stubble
    ellipse(c, 9, 2, 3.6, 2, "r"); c.row(1, 7, 11, "R")                                  # head-scarf
    c.px(5, 3, "r"); c.px(4, 4, "R"); c.px(4, 5, "r")                                    # knotted tails
    c.px(6, 5, "h"); c.px(6, 6, "y")                                                     # hair, earring


BUCCANEER_PAL = {"o": "#0e0a08", "k": "#2a2420", "w": "#ece4d4", "W": "#b8b0a4", "u": "#3a5a8a", "U": "#2a4268",
                 "s": "#c8946a", "S": "#a07450", "r": "#b02a2a", "R": "#7a1a1a", "n": "#2a3448", "h": "#2a1a10",
                 "i": "#d8dce4", "I": "#8a8e96", "y": "#d8b040", "m": "#7a4a3a"}


def musketeer(c, f):
    """A pirate musketeer of Libertalia: a sailor in a long red coat with brass buttons and a powder belt across it, a
    black tricorne trimmed with gold, holding a long musket across his body."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 19, x + 1 + d, 21, "l"); c.rect(x + d, 22, x + 2 + d, 23, "k")
    poly(c, [(5, 7), (13, 7), (15, 19), (3, 19)], "c")                                  # long coat
    poly(c, [(5, 7), (7, 7), (6, 19), (3, 19)], "C")
    c.rect(9, 8, 9, 19, "C")
    for y in range(9, 19, 3):
        c.px(10, y, "y")                                                                 # brass buttons
    for t in range(9):
        c.px(5 + t, 8 + t, "b")                                                          # powder belt
    c.rect(3, 8, 4, 13, "C")
    for t in range(19):                                                                  # the musket, held across him
        x, y = 3 + t * 15 // 18, 18 - t * 17 // 18
        c.px(x, y, "b" if t < 7 else "i")
    c.px(7, 14, "s"); c.px(13, 8, "s")                                                   # hands
    ellipse(c, 9, 4, 3, 3, "s"); c.px(7, 5, "S"); c.px(9, 4, "k"); c.px(12, 4, "k"); c.px(10, 6, "m")
    c.rect(6, 0, 12, 1, "k"); c.row(2, 4, 14, "k"); c.px(4, 1, "k"); c.px(14, 1, "k")   # tricorne
    c.row(2, 5, 13, "y")
    c.px(6, 4, "h"); c.px(6, 5, "h")


MUSKETEER_PAL = {"o": "#0e0a08", "k": "#1e1a18", "c": "#9a2a2a", "C": "#6a1a1a", "s": "#c8946a", "S": "#a07450",
                 "b": "#6a4a2a", "i": "#8a8e96", "y": "#e0b040", "l": "#d8d0bc", "h": "#2a1a10", "m": "#7a4a3a"}


def gull(c, f):
    """A gull over the bay of Libertalia: white, with grey wings tipped black, a yellow bill with a red spot."""
    up = f % 2
    tip = 0 if up else 10
    poly(c, [(8, 6), (11, 6), (6, tip + 1), (3, tip)], "G")                              # far wing
    c.px(3, tip, "k"); c.px(4, tip, "k")
    ellipse(c, 10, 7, 4.5, 2, "w"); c.row(8, 7, 12, "W")                                 # body
    c.px(5, 7, "w"); c.px(4, 6, "W")                                                     # tail
    ellipse(c, 14, 5, 2, 2, "w"); c.px(15, 5, "k")                                       # head, eye
    c.px(16, 6, "y"); c.px(17, 6, "y"); c.px(17, 7, "r")                                 # bill
    poly(c, [(9, 6), (12, 6), (15, tip + 1), (13, tip)], "g")                            # near wing
    c.px(15, tip + 1, "k"); c.px(14, tip, "k")


GULL_PAL = {"o": "#4a5058", "w": "#f4f6f6", "W": "#c8ccd0", "g": "#a8b0b8", "G": "#8a929a", "k": "#1e1e22",
            "y": "#e8c030", "r": "#d83a2a"}


def sea_serpent(c, step):
    """The great sea serpent (Pontoppidan, 1752-53): a vast serpent lying in great coils "like a row of casks", with a
    head like a horse's and a long mane. Its coils hump along the ground behind it as it rears up its neck."""
    def bez(p0, p1, p2, p3, t):
        u = 1 - t
        return (u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1])
    pts = []
    for k in range(60):                                                                  # the coils, humping along
        t = k / 59
        pts.append((2 + 44 * t, 50 - 13 * abs(math.sin(3 * math.pi * t + step * 0.25)), 1.4 + 3.4 * t))
    for k in range(40):                                                                  # the neck, rearing up
        x, y = bez((46, 50), (60, 40), (38, 26), (52, 16), k / 39)
        pts.append((x, y, 4.8 - 0.8 * k / 39))
    for x, y, r in pts:
        ellipse(c, x, y, r, r, "G")
    for x, y, r in pts:
        ellipse(c, x - 0.6, y - 0.8, max(r - 1.3, 0.6), max(r - 1.3, 0.6), "g")
    for i, (x, y, r) in enumerate(pts):
        if r > 2 and i % 2 == 0:
            c.px(round(x + 0.5), round(y + r - 1), "y")                                  # pale belly
        if r > 2 and i % 5 == 0:
            c.px(round(x - 1), round(y - 1), "G")                                        # scales
    for i in range(60, 100, 3):                                                          # the long mane
        x, y, r = pts[i]
        c.px(round(x - r - 1), round(y), "m"); c.px(round(x - r - 2), round(y + 1), "M")
        c.px(round(x - r), round(y - 1), "m")
    ellipse(c, 53, 13, 5, 4.5, "g")                                                      # the horse-like head
    poly(c, [(55, 9), (66, 13), (67, 17), (55, 18)], "g")                                # long muzzle
    c.row(17, 56, 67, "G"); c.row(18, 57, 65, "G")                                       # jaw
    for x in range(58, 67, 2):
        c.px(x, 16, "w")                                                                 # teeth
    c.px(66, 13, "k"); c.px(55, 11, "r"); c.px(56, 11, "r"); c.px(55, 10, "k")          # nostril, red eye
    c.px(50, 8, "m"); c.px(49, 7, "m"); c.px(52, 7, "M")                                 # forelock


SERPENT_PAL = {"o": "#08140e", "g": "#3a7a62", "G": "#24503e", "y": "#c8d8a0", "r": "#e83a2a", "k": "#0a0a0a",
               "m": "#9a3a2a", "M": "#6a2418", "w": "#f0ece0"}


def misson(c, step):
    """Captain Misson (the General History of the Pyrates, 1724): the gentleman-captain who founded Libertalia, in a long
    blue coat with gold buttons and cuffs, a white cravat, white stockings, a black tricorne trimmed with gold, a sword
    at his side and a spyglass in hand."""
    c.rect(9, 30, 10, 31, "y")                                                           # sword hilt, then scabbard
    for t in range(16):
        c.px(9 - t // 3, 32 + t, "k")
    person(c, step, cx=20, hair="h", hair_d="H", hair_style="short", garment="tunic", robe="u", robe_d="U",
           legs="w", boots="k", arm_forward=True)
    poly(c, [(15, 28), (25, 28), (27, 40), (13, 40)], "u")                               # coat skirts
    poly(c, [(15, 28), (17, 28), (16, 40), (13, 40)], "U")
    c.rect(20, 28, 20, 40, "U")
    c.rect(19, 15, 21, 20, "w"); c.px(20, 21, "w")                                       # cravat
    for y in range(22, 39, 3):
        c.px(22, y, "y")                                                                 # gold buttons
    c.rect(31, 21, 33, 23, "y")                                                          # gold cuff
    c.rect(33, 22, 39, 23, "y"); c.px(39, 22, "Y"); c.rect(33, 21, 34, 21, "Y")          # spyglass
    c.rect(15, 2, 25, 4, "k"); c.row(5, 12, 28, "k"); c.px(12, 4, "k"); c.px(28, 4, "k")   # tricorne
    c.row(5, 13, 27, "y")


MISSON_PAL = {"o": "#0a0a10", "k": "#1a1a22", "u": "#2a3a8a", "U": "#1a2660", "w": "#ece4d4", "s": "#d8b090",
              "S": "#b08868", "h": "#3a2a1a", "H": "#24180e", "m": "#9a5a4a", "y": "#d8b040", "Y": "#fff0a0",
              "l": "#ece4d4", "b": "#1a1a22"}


def kraken(c, step):
    """The Kraken (Pontoppidan, 1752-53): a sea-beast so vast that its back was taken for a cluster of small islands,
    its arms like the masts of ships, able to pull down the greatest ship. A giant squid come ashore: a long pointed
    mantle rising upright with fins at its tip, speckled and mottled; great glaring eyes and a hooked beak; thick arms
    spread over the ground, curling at their tips; and two long tentacles raised high, with broad clubbed ends lined
    with suckers."""
    def arm(x0, y0, length, ang, curl, phase, width, col, shade, club=False):
        """A thick arm from (x0, y0) heading at `ang`, swaying, curling at its tip (curl > 0 turns clockwise);
        suckers along its inner side. A tentacle thins along its length, then swells into a club."""
        pts = []
        x, y = float(x0), float(y0)
        n = int(length * 1.4)
        for t in range(n):
            u = t / (n - 1)
            if u > (0.75 if club else 0.6):
                ang += curl * (0.10 if club else 0.16)                                   # the curl at the tip
            ang += math.sin(u * 4 + phase + step * 0.5) * 0.03 * curl                  # mirrored pairs sway alike
            x += math.cos(ang) * 0.9; y += math.sin(ang) * 0.9
            pts.append((x, y, ang))
        side = 1 if curl > 0 else -1

        def rad(t):
            u = t / len(pts)
            if club:
                return width * (0.55 if u < 0.7 else 0.55 + math.sin((u - 0.7) / 0.3 * math.pi) * 0.75)
            return width * (1 - u * 0.8)
        for t, (px, py, _a) in enumerate(pts):
            ellipse(c, px, py, rad(t), rad(t), col)
        for t, (px, py, pa) in enumerate(pts):
            r = rad(t)
            nx, ny = -math.sin(pa) * side, math.cos(pa) * side                          # towards the inside of the curl
            if (t % 4 == 2 or (club and t / len(pts) > 0.7 and t % 2 == 0)) and r > 1.2:
                c.px(round(px + nx * (r - 0.6)), round(py + ny * (r - 0.6)), "p")        # suckers
            if t % 3 == 0:
                c.px(round(px - nx * (r - 0.6)), round(py - ny * (r - 0.6)), shade)      # shading along its back
    sway = math.sin(step * 1.6) * 0.08
    arm(36, 58, 30, -math.pi / 2 - 0.5 + sway, -1, 1.14, 3.6, "r", "R", club=True)      # the two long tentacles
    arm(54, 58, 30, -math.pi / 2 + 0.5 - sway, 1, 1.14, 3.6, "r", "R", club=True)
    for x0, ang, curl, ph in ((38, 2.75, 1, 0.4), (52, 0.39, -1, 0.4)):                 # the arms behind, flat out
        arm(x0, 66, 24, ang, curl, ph, 4.0, "R", "o")
    poly(c, [(45, 2), (60, 22), (58, 34), (45, 30), (32, 34), (30, 22)], "R")            # the fins at the mantle's tip
    poly(c, [(45, 3), (58, 21), (56, 31), (45, 27), (34, 31), (32, 21)], "f")
    poly(c, [(45, 8), (55, 28), (57, 52), (51, 60), (39, 60), (33, 52), (35, 28)], "R")  # the long mantle
    poly(c, [(45, 9), (53, 28), (55, 50), (49, 57), (41, 57), (35, 50), (37, 28)], "r")
    for y in range(14, 56, 2):
        c.px(41 - (y - 14) // 10, y, "l")                                                # light down its back
        c.px(42 - (y - 14) // 10, y + 1, "l")
    for x, y in ((47, 20), (43, 30), (50, 36), (40, 42), (46, 46), (52, 48), (44, 24), (38, 50), (49, 28)):
        c.px(x, y, "R"); c.px(x + 1, y, "R"); c.px(x, y + 1, "R")                        # speckles
    ellipse(c, 45, 63, 11, 6, "R"); ellipse(c, 45, 62, 10, 5, "r")                       # the head
    for ex in (35, 55):                                                                  # the great glaring eyes
        ellipse(c, ex, 61, 4.5, 4, "k"); ellipse(c, ex, 61, 3.5, 3, "y")
        c.rect(ex - 1, 60, ex + 1, 62, "k"); c.px(ex - 1, 59, "w")
        c.row(57, ex - 4, ex + 4, "R")                                                   # heavy brows
    for x0, ang, curl, ph in ((40, 1.95, 1, 0.8), (50, 1.19, -1, 0.8),                  # the arms in front
                              (43, 1.68, 1, 3.1), (47, 1.46, -1, 3.1)):
        arm(x0, 66, 17, ang, curl, ph, 3.8, "a", "R")
    poly(c, [(42, 66), (48, 66), (45, 72)], "k"); c.px(45, 70, "W"); c.px(44, 68, "W")   # the hooked beak


KRAKEN_PAL = {"o": "#120608", "r": "#8a3a4a", "R": "#6a2a3a", "p": "#e8b0b8", "y": "#f0d040", "w": "#e8f0f4",
              "l": "#a85a68", "W": "#f4ecd0", "k": "#1a0a0a", "B": "#4a7a9a", "a": "#a04a5a",
              "f": "#7a3242"}


# --- The Hollow Hills (Paracelsus 1566; British fairy-hill folklore; Baum, Ozma of Oz, 1907) --------------------------

def nome(c, f):
    """A Nome (Baum, Ozma of Oz): one of the little rock-coloured people of the underground kingdom, round and knobbly,
    with a bushy beard, a leather cap and a pick over his shoulder."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 19, x + 1 + d, 22, "G"); c.rect(x + d, 23, x + 2 + d, 23, "k")
    ellipse(c, 9, 15, 5, 4.5, "g"); ellipse(c, 7, 16, 2.5, 3.5, "G")                    # round body
    c.px(11, 13, "G"); c.px(12, 17, "G"); c.px(9, 18, "G")                               # knobbly
    c.row(16, 5, 13, "b"); c.px(10, 16, "y")                                             # belt
    for t in range(13):
        c.px(5 + t * 11 // 12, 19 - t * 16 // 12, "b")                                   # pick handle
    for x, y in ((12, 2), (13, 2), (14, 3), (15, 3), (16, 3), (17, 4), (18, 5), (11, 3), (10, 4)):
        c.px(x, y, "i")                                                                  # pick head
    ellipse(c, 9, 7, 4, 4, "g"); c.px(6, 8, "G")                                         # head
    c.px(8, 6, "k"); c.px(11, 6, "k"); ellipse(c, 11, 8, 1.5, 1.2, "G")                 # eyes, big nose
    poly(c, [(6, 9), (13, 9), (12, 13), (9, 14), (6, 12)], "v"); c.px(8, 11, "V"); c.px(11, 12, "V")   # beard
    c.row(3, 6, 12, "b"); c.row(4, 5, 13, "b")                                           # leather cap
    c.px(14, 12, "g"); c.px(15, 11, "g")                                                 # hand on the pick


NOME_PAL = {"o": "#0e0c0a", "g": "#8a7a68", "G": "#5e5244", "k": "#1a1410", "b": "#6a4a2a", "i": "#a8aeb6",
            "v": "#c8c0b4", "V": "#9a9284", "y": "#d8b040"}


def gnome(c, f):
    """A gnome (Paracelsus, Liber de Nymphis, 1566: the spirits of earth, who pass through rock and stone as we pass
    through air): a small earth-spirit with a long white beard, a tall pointed red hood, a moss-green coat, and a
    lantern glowing in the dark."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 19, x + 1 + d, 21, "V"); c.rect(x + d, 22, x + 2 + d, 23, "k")
    poly(c, [(5, 10), (13, 10), (15, 19), (3, 19)], "v"); poly(c, [(5, 10), (7, 10), (6, 19), (3, 19)], "V")
    c.row(15, 4, 14, "b"); c.px(9, 15, "y")                                              # belt
    c.rect(3, 11, 4, 15, "V"); c.px(3, 16, "s")                                          # far arm
    ellipse(c, 9, 8, 3.2, 2.6, "s"); c.px(8, 7, "k"); c.px(11, 7, "k"); c.px(12, 8, "S")   # face, nose
    poly(c, [(6, 9), (12, 9), (12, 13), (9, 16), (6, 13)], "w"); c.px(8, 12, "W"); c.px(10, 14, "W")   # beard
    poly(c, [(5, 7), (13, 7), (12, 4), (8, 1), (2, -1), (6, 4)], "r")                    # tall pointed hood
    poly(c, [(5, 7), (7, 7), (6, 4), (2, -1)], "R")
    c.rect(13, 11, 15, 12, "v"); c.px(16, 12, "s")                                       # near arm, holding up
    c.px(17, 12, "k"); c.rect(16, 13, 18, 16, "y"); c.px(17, 14, "Y"); c.row(17, 16, 18, "k")   # the lantern
    for x, y in ((15, 14), (19, 14), (17, 18), (19, 16), (15, 16)):
        c.px(x, y, "L")                                                                  # its glow


GNOME_PAL = {"o": "#0e0a08", "k": "#2a1e14", "v": "#5a7a3a", "V": "#3e5a28", "s": "#d8a888", "S": "#b08068",
             "w": "#ece8e0", "W": "#b8b4ac", "r": "#b83a2a", "R": "#842418", "b": "#4a3020", "y": "#f0d060",
             "Y": "#fff8c0", "L": "#c8f080"}


def kaliko(c, step):
    """Kaliko (Baum, Ozma of Oz): the Nome King's chief steward, a rock-coloured Nome with a short grey beard in a rich
    purple robe trimmed with gold, a velvet cap, a gold chain of office, and a great ring of keys, for he knows every
    tunnel of the kingdom."""
    person(c, step, cx=20, skin="g", skin_d="G", hair="p", hair_d="P", hair_style="none", beard="v",
           garment="gown", robe="p", robe_d="P", robe_l="q", belt="y", boots="k", eye="k", head_y=12)
    ellipse(c, 21, 15, 1.6, 1.3, "G")                                                    # big Nome nose
    ellipse(c, 20, 7, 5.5, 3, "p"); c.row(9, 15, 25, "P"); c.px(20, 4, "y")             # velvet cap
    for x in range(14, 27):
        c.px(x, 20 + abs(x - 20) // 3, "y")                                              # chain of office
    c.rect(19, 23, 21, 25, "y"); c.px(20, 24, "j")
    c.row(53, 11, 29, "y")                                                               # gold hem
    for a in range(16):                                                                  # the great ring of keys
        c.px(30 + round(4 * math.cos(a / 16 * 6.28)), 36 + round(4 * math.sin(a / 16 * 6.28)), "y")
    for x, y in ((27, 40), (30, 41), (33, 40)):
        c.rect(x, y, x, y + 4, "Y"); c.px(x + 1, y + 4, "Y"); c.px(x + 1, y + 2, "Y")   # keys


KALIKO_PAL = {"o": "#0e0a08", "k": "#1e1814", "p": "#6a3a8a", "P": "#4a2664", "q": "#8a5aa8", "g": "#8a7a68",
              "G": "#5e5244", "v": "#a8a49c", "y": "#e8c040", "Y": "#c8a030", "j": "#4ae0c8", "m": "#4a3a30",
              "l": "#5e5244", "b": "#1e1814", "s": "#8a7a68", "S": "#5e5244"}


def hammer_giant(c, step):
    """The Giant with the Hammer (Baum, Ozma of Oz, ch. 13): a huge man of cast iron who stands beside the narrow road
    to the Nome King's kingdom and pounds it with his great iron hammer without ever stopping: plated and riveted, eyes
    glowing red in his visor, the hammer swung high and brought down on the road."""
    def limb(x0, y0, x1, y1, r, col):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
        for t in range(n + 1):
            ellipse(c, x0 + (x1 - x0) * t / n, y0 + (y1 - y0) * t / n, r, r, col)
    for x in (16, 32):                                                                   # legs
        c.rect(x, 50, x + 8, 69, "i"); c.rect(x, 50, x + 2, 69, "I")
        c.row(58, x, x + 8, "I"); c.px(x + 4, 58, "y"); c.px(x + 6, 58, "y")             # knee joint
        c.rect(x - 1, 68, x + 10, 71, "I"); c.row(68, x, x + 9, "i")
    c.rect(14, 44, 42, 50, "I"); c.row(45, 15, 41, "i")                                  # hips
    if step:
        hands, head = (40, 12), (42, 0, 56, 9)                                           # hammer raised high
        handle = [(40, 12), (49, 5)]
    else:
        hands, head = (44, 44), (44, 61, 57, 71)                                         # hammer brought down
        handle = [(44, 44), (50, 62)]
    limb(12, 22, hands[0] - 2, hands[1] + 2, 3.5, "I")                                   # far arm
    poly(c, [(10, 20), (46, 20), (42, 46), (14, 46)], "i")                               # plated chest
    poly(c, [(10, 20), (15, 20), (17, 46), (14, 46)], "I")
    for y in (28, 37):
        c.row(y, 13, 43, "I")
        for x in range(16, 42, 5):
            c.px(x, y - 2, "y"); c.px(x, y + 2, "y")                                     # rivets along the seams
    ellipse(c, 12, 22, 5, 4, "I"); ellipse(c, 44, 22, 5, 4, "i")                         # shoulders
    c.rect(20, 6, 36, 19, "i"); c.rect(20, 6, 22, 19, "I"); c.row(6, 20, 36, "y")        # head
    c.rect(23, 11, 34, 12, "k"); c.px(26, 11, "r"); c.px(31, 11, "r"); c.px(27, 11, "R"); c.px(32, 11, "R")
    c.rect(26, 15, 30, 16, "I")                                                          # mouth-grille
    for t in range(14):
        x = handle[0][0] + (handle[1][0] - handle[0][0]) * t / 13
        y = handle[0][1] + (handle[1][1] - handle[0][1]) * t / 13
        c.rect(round(x), round(y), round(x) + 1, round(y) + 1, "b")                      # the haft
    c.rect(*head, "I"); c.rect(head[0] + 1, head[1] + 1, head[2] - 1, head[1] + 3, "i")  # the hammer-head
    limb(44, 22, hands[0], hands[1], 3.8, "i")                                           # near arm
    ellipse(c, hands[0], hands[1], 3, 3, "I")


HAMMER_GIANT_PAL = {"o": "#0a0a0c", "i": "#62666e", "I": "#3e424a", "y": "#9aa0a8", "k": "#14161a", "r": "#ff4a2a",
                    "R": "#a82a1a", "b": "#4a3a2a"}


def nome_king(c, step):
    """The Nome King (Baum, Ozma of Oz): Roquat, a round, fat little king of the Nomes with a long white beard and a
    jolly-looking face that hid a cruel heart, in a robe of rich colours trimmed with ermine and a jewelled crown, a
    sceptre in his hand; he turned his visitors into ornaments."""
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 8 + d, 46, 18 + k * 8 + d, 51, "G"); c.rect(14 + k * 8 + d, 52, 19 + k * 8 + d, 54, "k")
    ellipse(c, 21, 35, 14, 13, "R"); ellipse(c, 23, 34, 12, 12, "r")                     # round robed belly
    for x, y in ((28, 28), (30, 36), (26, 42)):
        c.px(x, y, "q")                                                                  # sheen
    poly(c, [(9, 42), (33, 42), (31, 48), (11, 48)], "w"); c.rect(20, 22, 23, 47, "w")  # ermine trim
    for x, y in ((12, 45), (17, 44), (26, 45), (30, 44), (21, 30), (22, 38), (15, 47), (28, 47)):
        c.px(x, y, "k")                                                                  # ermine tails
    ellipse(c, 7, 33, 3, 4, "R"); ellipse(c, 6, 37, 2, 2, "g")                           # far arm
    c.rect(36, 10, 36, 44, "y"); ellipse(c, 36, 9, 2.4, 2.4, "y"); c.px(36, 9, "j")     # sceptre
    ellipse(c, 34, 32, 3.5, 4, "r"); ellipse(c, 36, 35, 2, 2, "g")                       # near arm, holding it
    poly(c, [(13, 18), (29, 18), (28, 30), (21, 38), (14, 30)], "W")                     # long white beard
    for x, y in ((17, 24), (19, 28), (24, 26), (22, 32), (26, 22)):
        c.px(x, y, "V")
    ellipse(c, 21, 13, 7.5, 7, "g"); c.px(14, 14, "G")                                   # big round head
    c.px(16, 15, "p"); c.px(26, 15, "p"); c.px(17, 16, "p"); c.px(25, 16, "p")           # rosy cheeks
    c.px(18, 12, "k"); c.px(24, 12, "k"); c.row(10, 17, 19, "W"); c.row(10, 23, 25, "W")   # eyes, white brows
    ellipse(c, 21, 14, 1.6, 1.4, "G")                                                    # nose
    c.row(17, 16, 26, "W"); c.row(19, 19, 23, "m"); c.px(18, 18, "m"); c.px(24, 18, "m")   # moustache, jolly grin
    c.rect(13, 3, 29, 7, "y"); c.row(7, 13, 29, "Y")                                     # jewelled crown
    for x in (13, 17, 21, 25, 29):
        c.rect(x, 0, x, 2, "y")
    c.px(17, 5, "j"); c.px(21, 5, "e"); c.px(25, 5, "j"); c.px(21, 0, "e")


NOME_KING_PAL = {"o": "#0e0a08", "r": "#a83a8a", "R": "#7a2a6a", "q": "#c860a8", "j": "#4ae0c8", "e": "#e83a3a",
                 "g": "#a89078", "G": "#7a6450", "k": "#1a1410", "w": "#f4f0e8", "W": "#f0ece4", "V": "#c0bab0",
                 "y": "#e8c040", "Y": "#b08a20", "p": "#d87a7a", "m": "#5a2a20"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_gears.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("bronze_automaton", bronze_automaton, AUTOMATON_PAL, doc(bronze_automaton.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("golden_handmaiden", golden_handmaiden, HANDMAIDEN_PAL, doc(golden_handmaiden.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("aeetes_bulls", aeetes_bulls, BULLS_PAL, doc(aeetes_bulls.__doc__), (82, 56), (34, 54), [0, 1, 0, -1, 0])
    kit.build_boss("gold_silver_hounds", gold_silver_hound(True), HOUNDS_GOLD_PAL, doc(gold_silver_hound.__doc__), (74, 54), (36, 52), WOLF_WALK)
    kit.build_boss("gold_silver_hounds_gold", gold_silver_hound(True), HOUNDS_GOLD_PAL, doc(gold_silver_hound.__doc__ + " The gold hound."), (74, 54), (36, 52), WOLF_WALK)
    kit.build_boss("gold_silver_hounds_silver", gold_silver_hound(False), HOUNDS_SILVER_PAL, doc(gold_silver_hound.__doc__ + " The silver hound."), (74, 54), (36, 52), WOLF_WALK)
    kit.build_boss("talos", talos(False), TALOS_PAL, doc(talos.__doc__), (54, 68), (26, 66), [0, 1, 0, -1, 0])
    kit.build_boss("talos_hot", talos(True), TALOS_PAL, doc(talos.__doc__ + " Here, red-hot."), (54, 68), (26, 66), [0, 1, 0, -1, 0])
    kit.build_boss("goblin_man", goblin_man, GOBLIN_PAL, doc(goblin_man.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("rat_goblin", rat_goblin, RAT_PAL, doc(rat_goblin.__doc__), (18, 14), (9, 13), walk, folder="enemies")
    kit.build_boss("ratel_goblin", ratel_goblin, RATEL_PAL, doc(ratel_goblin.__doc__), (50, 46), (24, 44), [0, 1, 0, -1, 0])
    kit.build_boss("snail_goblin", snail_goblin, SNAIL_PAL, doc(snail_goblin.__doc__), (50, 50), (24, 48), [0, 1, 0, -1, 0])
    kit.build_boss("goblin_merchants", goblin_merchants, MERCHANTS_PAL, doc(goblin_merchants.__doc__), (50, 54), (24, 52), [0, 1, 0, -1, 0])
    kit.build_boss("buccaneer", buccaneer, BUCCANEER_PAL, doc(buccaneer.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("musketeer", musketeer, MUSKETEER_PAL, doc(musketeer.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("gull", gull, GULL_PAL, doc(gull.__doc__), (20, 12), (10, 11), walk, folder="enemies")
    kit.build_boss("sea_serpent", sea_serpent, SERPENT_PAL, doc(sea_serpent.__doc__), (70, 56), (34, 54), [0, 1, 0, -1, 0])
    kit.build_boss("misson", misson, MISSON_PAL, doc(misson.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("kraken", kraken, KRAKEN_PAL, doc(kraken.__doc__), (90, 90), (44, 88), [0, 1, 0, -1, 0])
    kit.build_boss("nome", nome, NOME_PAL, doc(nome.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("gnome", gnome, GNOME_PAL, doc(gnome.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("kaliko", kaliko, KALIKO_PAL, doc(kaliko.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("hammer_giant", hammer_giant, HAMMER_GIANT_PAL, doc(hammer_giant.__doc__), (58, 74), (27, 72), [0, 1, 0, 1, 0])
    kit.build_boss("nome_king", nome_king, NOME_KING_PAL, doc(nome_king.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    print("wrote Gears and Plunder's art")
