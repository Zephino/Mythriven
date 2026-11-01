# Gears and Plunder's art (Pack 9, docs/PACK_9_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Homer, Apollodorus, Apollonius; Rossetti 1862; the General History of the Pyrates 1724; Pontoppidan 1752;
# Paracelsus; Baum's Ozma of Oz 1907, the book), never later versions.
# Run: python3 build_gears.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

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
    """A bronze automaton of Hephaestus' forge (Iliad 18: his self-moving works): a jointed bronze man, rivets showing."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "B")
    c.rect(5, 8, 14, 18, "z"); c.row(12, 5, 14, "B"); c.px(7, 10, "y"); c.px(12, 10, "y"); c.px(7, 15, "y"); c.px(12, 15, "y")
    c.rect(6, 1, 12, 7, "z"); c.rect(7, 3, 11, 4, "k"); c.px(8, 3, "r"); c.px(10, 3, "r")
    c.rect(3, 9, 4, 16, "B"); c.rect(15, 9, 16, 16, "B")


AUTOMATON_PAL = {"o": "#1a0e04", "z": "#c08a3a", "B": "#8a5a24", "y": "#f0d070", "k": "#2a1a0a", "r": "#f05a2a"}


def golden_handmaiden(c, f):
    """A golden handmaiden (Iliad 18.417-420: "made of gold, like living girls; they have understanding, speech and
    strength"): a maiden of gold in a long gown."""
    s = STEP[f]
    poly(c, [(6, 8), (13, 8), (15, 21), (4, 21)], "y"); c.rect(6, 8, 13, 10, "Y")
    ellipse(c, 9, 5, 3, 3, "y"); c.rect(6, 1, 12, 3, "Y"); c.px(8, 5, "k"); c.px(10, 5, "k")
    c.px(15, 10 + s, "w"); c.px(16, 9 + s, "w")


HANDMAIDEN_PAL = {"o": "#3a2a04", "y": "#e8c040", "Y": "#b08a20", "k": "#4a3410", "w": "#fff4b0"}


def aeetes_bulls(c, step):
    """The Bulls of Aeetes (Apollodorus 1.9.23): two bronze-footed bulls Hephaestus made, which breathed fire; Jason had
    to yoke them and plough with them. Two bronze bulls under a yoke, flame at their mouths."""
    for row, (dy, col) in enumerate(((0, "z"), (14, "Z"))):
        ellipse(c, 26, 22 + dy, 16, 7, col)
        for k, d in enumerate((-step, step, step, -step)):
            c.rect(14 + k * 8 + d, 26 + dy, 16 + k * 8 + d, 34 + dy, "B")
        poly(c, [(40, 17 + dy), (50, 19 + dy), (50, 25 + dy), (40, 27 + dy)], col); c.px(45, 19 + dy, "r")
        c.px(42, 15 + dy, "w"); c.px(47, 15 + dy, "w")
        for k in range(4):
            c.px(51 + k, 21 + dy + (k + step) % 2, "y"); c.px(52 + k, 22 + dy, "r")                 # fire
    c.rect(36, 12, 38, 40, "b")                                                                       # the yoke


BULLS_PAL = {"o": "#1a0e04", "z": "#c08a3a", "Z": "#a8763a", "B": "#6a4a1a", "r": "#f05a2a", "y": "#ffd040",
             "w": "#e8dcc0", "b": "#5a3a1a"}


def gold_silver_hound(gold):
    """The gold and silver hounds of Alcinous (Odyssey 7.91-94): dogs Hephaestus made with cunning skill to guard the
    house of great-hearted Alcinous, immortal and ageless all their days."""
    def draw(c, step):
        main, dark = ("y", "Y") if gold else ("s", "S")
        ellipse(c, 24, 26, 15, 7, main)
        for k, d in enumerate((-step, step, step, -step)):
            c.rect(12 + k * 8 + d, 30, 14 + k * 8 + d, 42, dark)
        poly(c, [(36, 16), (48, 18), (48, 24), (36, 26)], main); c.px(42, 18, "k")
        c.px(37, 13, main); c.px(38, 12, main); c.row(24, 44, 48, "k")
        for k in range(8):
            c.px(8 - k // 2, 24 - k // 3, dark)
    return draw


HOUNDS_PAL = {"o": "#1a1408", "y": "#e8c040", "Y": "#b08a20", "s": "#d8dce4", "S": "#a0a6b0", "k": "#2a2010"}


def talos(hot):
    """Talos (Argonautica 4.1638-1688; Apollodorus 1.9.26): the bronze giant who guarded Crete, running round it three
    times a day and hurling rocks at ships; one vein ran from his neck to his ankle, stopped by a bronze nail."""
    def draw(c, step):
        main, dark = ("r", "R") if hot else ("z", "Z")
        for k, d in enumerate((-step, step)):
            c.rect(16 + k * 12 + d, 48, 21 + k * 12 + d, 64, dark)
        c.rect(30 + step, 62, 32 + step, 63, "y")                                                     # the nail
        c.rect(12, 22, 40, 48, main); c.row(32, 12, 40, dark); c.row(40, 12, 40, dark)
        c.rect(5, 24, 11, 44, dark); c.rect(41, 24, 47, 44, dark)
        c.rect(18, 6, 34, 21, main); c.rect(20, 11, 32, 13, "k"); c.px(23, 12, "y"); c.px(29, 12, "y")
        for k in range(26):
            c.px(26, 21 + k * 2 if 21 + k * 2 < 62 else 61, "v")                                       # the one vein
    return draw


TALOS_PAL = {"o": "#1a0a04", "z": "#c08a3a", "Z": "#8a5a24", "r": "#f06a2a", "R": "#c83a10", "y": "#ffe070",
             "k": "#2a1408", "v": "#a83a2a"}


# --- The Goblin Market (Christina Rossetti, Goblin Market, 1862) -------------------------------------------------------

def goblin_man(c, f):
    """A goblin merchant-man (Rossetti: "one had a cat's face, one whisked a tail"): a small cat-faced goblin in a brown
    coat, a basket of fruit on his arm."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 16, x + 1 + d, 20, "k")
    c.rect(5, 8, 13, 16, "b")
    ellipse(c, 9, 5, 3.5, 3, "c"); c.px(6, 2, "c"); c.px(12, 2, "c"); c.px(8, 5, "y"); c.px(10, 5, "y")
    ellipse(c, 15, 13, 3, 2, "B"); c.px(14, 11, "r"); c.px(16, 11, "p"); c.px(15, 10, "y")


GOBLIN_PAL = {"o": "#120a06", "k": "#2a1a10", "b": "#6a4a2a", "B": "#8a6a3a", "c": "#8a7a5a", "y": "#e8d040",
              "r": "#c82a2a", "p": "#7a2a8a"}


def rat_goblin(c, f):
    """A rat-paced goblin (Rossetti: "one tramped at a rat's pace"): a small grey goblin scurrying like a rat."""
    s = STEP[f]
    ellipse(c, 8, 8, 5, 3, "g"); poly(c, [(12, 6), (15, 8), (12, 10)], "g"); c.px(13, 7, "r")
    for k, d in enumerate((-s, s, s, -s)):
        c.px(5 + k * 2 + d, 11, "G")
    for k in range(5):
        c.px(3 - k, 8 + k // 2, "p")


RAT_PAL = {"o": "#120c0a", "g": "#7a7068", "G": "#4a4440", "r": "#e8203a", "p": "#c89a8a"}


def ratel_goblin(c, step):
    """The Ratel Goblin (Rossetti: "one like a ratel tumbled hurry skurry"): a squat goblin like a honey badger, black
    below and grey-white along its back, tumbling head over heels."""
    ellipse(c, 24, 28, 18, 11, "k"); ellipse(c, 24, 22, 16, 6, "w")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 7 + d, 34, 14 + k * 7 + d, 42, "k")
    ellipse(c, 40, 26, 6, 5, "k"); c.px(42, 24, "y"); c.rect(44, 27, 46, 28, "w")
    for k in range(6):
        c.px(8 + k, 36 + (k + step) % 2, "y")                                                       # dust as it tumbles


RATEL_PAL = {"o": "#0a0806", "k": "#1e1a18", "w": "#d8d4cc", "y": "#e8c040"}


def snail_goblin(c, step):
    """The Snail Goblin (Rossetti: "one crawled like a snail"): a fat goblin crawling under a great spiral shell, its
    trail glistening behind it."""
    for x in range(0, 44, 3):
        c.px(x, 46, "s")                                                                              # the slime trail
    poly(c, [(4, 40), (44, 40), (48, 46), (2, 46)], "b")
    for r in range(14, 2, -3):
        ellipse(c, 24, 26, r, r, "h" if r % 2 else "H")
    c.rect(40, 30, 46, 40, "b"); ellipse(c, 44, 30, 4, 4, "b"); c.px(45, 29, "k")
    c.px(46, 24, "b"); c.px(47, 22, "b"); c.px(43, 24, "b"); c.px(43, 22, "b")


SNAIL_PAL = {"o": "#120c08", "b": "#8a7a5a", "h": "#a8703a", "H": "#7a4a24", "k": "#1a1008", "s": "#a8d8a0"}


def goblin_merchants(c, step):
    """The Goblin Merchant-Men (Rossetti: "Come buy our orchard fruits, come buy, come buy"): a crowd of little goblin
    merchants with laden trays and baskets of fruit, crying their wares."""
    for k, (x, face) in enumerate(((8, "c"), (24, "g"), (40, "c"))):
        dy = (step if k % 2 else -step)
        for d in (-1, 1):
            c.rect(x + d * 2, 44 + dy, x + d * 2 + 1, 50, "k")
        c.rect(x - 5, 30 + dy, x + 5, 44 + dy, "b")
        ellipse(c, x, 26 + dy, 4, 4, face); c.px(x - 1, 25 + dy, "y"); c.px(x + 2, 25 + dy, "y")
        c.px(x - 3, 22 + dy, face); c.px(x + 3, 22 + dy, face)
    poly(c, [(2, 18), (48, 18), (44, 24), (6, 24)], "B")                                              # a laden tray
    for x, col in ((8, "r"), (14, "p"), (20, "y"), (26, "r"), (32, "o2"), (38, "p"), (44, "y")):
        ellipse(c, x, 16, 2.5, 2.5, col if col != "o2" else "q")


MERCHANTS_PAL = dict(GOBLIN_PAL, g="#7a8a5a", q="#e88a2a")


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_gears.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("bronze_automaton", bronze_automaton, AUTOMATON_PAL, doc(bronze_automaton.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("golden_handmaiden", golden_handmaiden, HANDMAIDEN_PAL, doc(golden_handmaiden.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("aeetes_bulls", aeetes_bulls, BULLS_PAL, doc(aeetes_bulls.__doc__), (58, 52), (28, 50), [0, 1, 0, -1, 0])
    kit.build_boss("gold_silver_hounds_gold", gold_silver_hound(True), HOUNDS_PAL, doc(gold_silver_hound.__doc__ + " The gold hound."), (52, 46), (24, 44), [0, 1, 0, -1, 0])
    kit.build_boss("gold_silver_hounds_silver", gold_silver_hound(False), HOUNDS_PAL, doc(gold_silver_hound.__doc__ + " The silver hound."), (52, 46), (24, 44), [0, 1, 0, -1, 0])
    kit.build_boss("talos", talos(False), TALOS_PAL, doc(talos.__doc__), (54, 68), (26, 66), [0, 1, 0, -1, 0])
    kit.build_boss("talos_hot", talos(True), TALOS_PAL, doc(talos.__doc__ + " Here, red-hot."), (54, 68), (26, 66), [0, 1, 0, -1, 0])
    kit.build_boss("goblin_man", goblin_man, GOBLIN_PAL, doc(goblin_man.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("rat_goblin", rat_goblin, RAT_PAL, doc(rat_goblin.__doc__), (18, 14), (9, 13), walk, folder="enemies")
    kit.build_boss("ratel_goblin", ratel_goblin, RATEL_PAL, doc(ratel_goblin.__doc__), (50, 46), (24, 44), [0, 1, 0, -1, 0])
    kit.build_boss("snail_goblin", snail_goblin, SNAIL_PAL, doc(snail_goblin.__doc__), (50, 50), (24, 48), [0, 1, 0, -1, 0])
    kit.build_boss("goblin_merchants", goblin_merchants, MERCHANTS_PAL, doc(goblin_merchants.__doc__), (50, 54), (24, 52), [0, 1, 0, -1, 0])
    print("wrote Gears and Plunder's art")
