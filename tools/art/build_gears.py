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
    """A buccaneer of Libertalia (the General History of the Pyrates): a sailor in a striped shirt and head-scarf with a
    cutlass."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 21, "k")
    for y in range(8, 17):
        c.row(y, 5, 13, "w" if y % 2 else "u")
    ellipse(c, 9, 5, 3, 3, "s"); c.rect(6, 1, 12, 3, "r"); c.px(13, 2, "r")
    c.rect(15, 6, 15, 14, "i"); c.rect(14, 14, 16, 15, "y")


BUCCANEER_PAL = {"o": "#0e0a08", "k": "#2a2420", "w": "#ece4d4", "u": "#3a5a8a", "s": "#c8946a", "r": "#b02a2a",
                 "i": "#c8ccd4", "y": "#d8b040"}


def musketeer(c, f):
    """A pirate musketeer of Libertalia: a sailor in a long coat and tricorne hat with a long musket."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 21, "k")
    poly(c, [(5, 8), (13, 8), (15, 18), (3, 18)], "c")
    ellipse(c, 9, 5, 3, 3, "s"); poly(c, [(4, 2), (14, 2), (12, 4), (6, 4)], "k")
    c.rect(14, 4, 15, 18, "b"); c.rect(14, 2, 15, 4, "i")


MUSKETEER_PAL = {"o": "#0e0a08", "k": "#1e1a18", "c": "#6a2a2a", "s": "#c8946a", "b": "#5a3a1a", "i": "#8a8e96"}


def gull(c, f):
    """A gull over the bay of Libertalia."""
    up = f % 2
    poly(c, [(9, 7), (1, 3 if up else 9), (5, 8)], "w"); poly(c, [(11, 7), (19, 3 if up else 9), (15, 8)], "w")
    c.px(1, 3 if up else 9, "k"); c.px(19, 3 if up else 9, "k")
    ellipse(c, 10, 8, 3, 2, "w"); c.px(13, 7, "y")


GULL_PAL = {"o": "#4a5058", "w": "#ecf0f0", "k": "#2a2a2a", "y": "#e0b030"}


def sea_serpent(c, step):
    """The great sea serpent (Pontoppidan, 1752-53): a vast serpent with a horse-like head and a mane, rising from the
    sea in great coils, each coil like a hump above the waves."""
    for k in range(4):
        x = 4 + k * 13
        for t in range(10):
            ellipse(c, x + t, 36 - round(10 * math.sin(t / 9 * math.pi)) + step, 3, 3, "g" if t % 3 else "G")
    poly(c, [(56, 18), (66, 22), (66, 28), (56, 30)], "g"); c.px(61, 21, "r")
    for k in range(6):
        c.px(55 - k, 16 + k, "m"); c.px(54 - k, 17 + k, "m")                                    # the mane
    for x in range(0, 70, 4):
        c.px(x, 46, "w"); c.px(x + 1, 45, "b")                                                    # the waves


SERPENT_PAL = {"o": "#08140e", "g": "#3a6a5a", "G": "#2a4a40", "r": "#e83a2a", "m": "#8a3a2a", "w": "#e8f0f4",
               "b": "#3a6a9a"}


def misson(c, step):
    """Captain Misson (the General History of the Pyrates, 1724): the gentleman-captain who founded Libertalia, in a fine
    blue coat and tricorne, a sword at his side and a spyglass in hand."""
    figure(c, step, "u", "s", "k")
    c.rect(16, 18, 26, 30, "w"); c.rect(20, 18, 22, 30, "y")
    poly(c, [(11, 3), (31, 3), (28, 6), (14, 6)], "k")
    c.rect(32, 20, 37, 22, "y")
    c.rect(6, 30, 7, 46, "i"); c.rect(5, 30, 8, 31, "y")


MISSON_PAL = {"o": "#0a0a10", "k": "#1a1a22", "u": "#2a3a7a", "w": "#ece4d4", "s": "#d8b090", "y": "#d8b040",
              "i": "#c8ccd4"}


def kraken(c, step):
    """The Kraken (Pontoppidan, 1752-53): a sea-beast so vast that its back, rising out of the sea, was taken for a
    cluster of small islands; its arms could pull down the greatest ship."""
    ellipse(c, 40, 38, 30, 14, "r"); ellipse(c, 40, 34, 22, 8, "R")
    c.px(32, 30, "y"); c.px(48, 30, "y")
    for k in range(6):
        ax = 6 + k * 13
        for t in range(16):
            x = ax + round(4 * math.sin(t / 3 + k + step * 0.6))
            c.rect(x, 40 - t * 2, x + 2, 42 - t * 2, "r" if t % 3 else "p")
    for x in range(0, 82, 4):
        c.px(x, 54, "w"); c.px(x + 1, 53, "b")


KRAKEN_PAL = {"o": "#120608", "r": "#8a3a4a", "R": "#6a2a3a", "p": "#c87a8a", "y": "#f0d040", "w": "#e8f0f4",
              "b": "#3a6a9a"}


# --- The Hollow Hills (Paracelsus 1566; British fairy-hill folklore; Baum, Ozma of Oz, 1907) --------------------------

def nome(c, f):
    """A Nome (Baum, Ozma of Oz): one of the little rock-coloured people of the underground kingdom, round and
    knobbly, with a pick."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 16, x + 1 + d, 20, "G")
    ellipse(c, 9, 11, 5, 5, "g"); ellipse(c, 9, 5, 3.5, 3, "g"); c.px(8, 5, "k"); c.px(10, 5, "k")
    c.px(6, 9, "G"); c.px(12, 13, "G")
    c.rect(15, 4, 15, 15, "b"); c.rect(13, 3, 17, 4, "i")


NOME_PAL = {"o": "#0e0c0a", "g": "#8a7a68", "G": "#5a4e42", "k": "#1a1410", "b": "#6a4a2a", "i": "#9aa0a8"}


def gnome(c, f):
    """A gnome (Paracelsus, Liber de Nymphis, 1566: the spirits of earth, who pass through rock and stone as we pass
    through air): a small bearded earth-spirit in a pointed hood, glowing faintly."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 20, "k")
    poly(c, [(5, 9), (13, 9), (14, 17), (4, 17)], "v")
    ellipse(c, 9, 7, 3, 2.5, "s"); poly(c, [(6, 9), (12, 9), (9, 14)], "w")
    poly(c, [(5, 5), (9, -1), (13, 5)], "r")
    c.px(15, 9 + s, "y"); c.px(16, 8 + s, "y")


GNOME_PAL = {"o": "#0e0a08", "k": "#2a1e14", "v": "#5a6a3a", "s": "#d8a888", "w": "#e8e4dc", "r": "#a83a2a",
             "y": "#c8f080"}


def kaliko(c, step):
    """Kaliko (Baum, Ozma of Oz): the Nome King's chief steward, a Nome in a fine robe with a great ring of keys, who
    knows every tunnel of the kingdom."""
    figure(c, step, "p", "g", "G", legs="G")
    c.rect(16, 18, 26, 26, "P")
    for a in range(10):
        c.px(30 + round(3 * math.cos(a / 10 * 6.28)), 32 + round(3 * math.sin(a / 10 * 6.28)), "y")
    c.px(32, 36, "y"); c.px(33, 37, "y")


KALIKO_PAL = {"o": "#0e0a08", "k": "#1e1814", "p": "#6a3a7a", "P": "#4a2a5a", "g": "#8a7a68", "G": "#5a4e42",
              "y": "#e8c040"}


def hammer_giant(c, step):
    """The Giant with the Hammer (Baum, Ozma of Oz, ch. 13): a huge man of cast iron who stands beside the narrow road
    to the Nome King's kingdom and pounds it with his iron hammer without ever stopping."""
    for k in range(2):
        c.rect(14 + k * 16, 50, 21 + k * 16, 70, "I")
    c.rect(10, 22, 44, 50, "i"); c.row(30, 10, 44, "I"); c.row(40, 10, 44, "I")
    for x in (14, 22, 32, 40):
        c.px(x, 26, "y"); c.px(x, 46, "y")                                                          # rivets
    c.rect(18, 4, 36, 21, "i"); c.rect(21, 10, 33, 12, "k"); c.px(24, 11, "r"); c.px(30, 11, "r")
    c.rect(4, 24, 9, 44, "I"); c.rect(45, 24 - step * 6, 50, 44, "I")
    c.rect(47, 2 - step * 6, 48, 24 - step * 6, "b"); c.rect(41, -2 - step * 6, 54, 6 - step * 6, "I")       # the hammer


HAMMER_GIANT_PAL = {"o": "#0a0a0c", "i": "#5a5e66", "I": "#3a3e46", "y": "#9aa0a8", "k": "#14161a", "r": "#e83a2a",
                    "b": "#4a3a2a"}


def nome_king(c, step):
    """The Nome King (Baum, Ozma of Oz): Roquat, a round, fat little king of the Nomes with a long white beard and a
    jolly-looking face that hid a cruel heart, in a robe of rich colours and a jewelled crown, who turned his visitors
    into ornaments."""
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 8 + d, 46, 18 + k * 8 + d, 54, "G")
    ellipse(c, 21, 34, 14, 13, "r"); ellipse(c, 21, 36, 10, 9, "R")
    for x, y in ((12, 30), (30, 30), (16, 42), (26, 42)):
        c.px(x, y, "j")
    ellipse(c, 21, 14, 7, 7, "g"); c.px(18, 13, "k"); c.px(24, 13, "k")
    poly(c, [(15, 16), (27, 16), (24, 30), (18, 30)], "w")
    c.rect(14, 4, 28, 7, "y"); c.px(15, 3, "y"); c.px(21, 2, "j"); c.px(27, 3, "y")


NOME_KING_PAL = {"o": "#0e0a08", "r": "#8a2a6a", "R": "#a83a8a", "j": "#4ae0c8", "g": "#a89078", "G": "#5a4e42",
                 "k": "#1a1410", "w": "#f0ece4", "y": "#e8c040"}


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
    kit.build_boss("buccaneer", buccaneer, BUCCANEER_PAL, doc(buccaneer.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("musketeer", musketeer, MUSKETEER_PAL, doc(musketeer.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("gull", gull, GULL_PAL, doc(gull.__doc__), (20, 12), (10, 11), walk, folder="enemies")
    kit.build_boss("sea_serpent", sea_serpent, SERPENT_PAL, doc(sea_serpent.__doc__), (70, 50), (34, 48), [0, 1, 0, -1, 0])
    kit.build_boss("misson", misson, MISSON_PAL, doc(misson.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("kraken", kraken, KRAKEN_PAL, doc(kraken.__doc__), (82, 58), (40, 56), [0, 1, 0, -1, 0])
    kit.build_boss("nome", nome, NOME_PAL, doc(nome.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("gnome", gnome, GNOME_PAL, doc(gnome.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("kaliko", kaliko, KALIKO_PAL, doc(kaliko.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("hammer_giant", hammer_giant, HAMMER_GIANT_PAL, doc(hammer_giant.__doc__), (58, 74), (27, 72), [0, 1, 0, 1, 0])
    kit.build_boss("nome_king", nome_king, NOME_KING_PAL, doc(nome_king.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    print("wrote Gears and Plunder's art")
