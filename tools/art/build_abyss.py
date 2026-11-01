# The Abyss's art (Pack 11, docs/PACK_11_PLAN.md; docs/ART_RULES.md), one realm at a time. Ashkarrow is the game's own
# invented city (nothing from any religion); the rest is drawn only from the old texts (the Historia Brittonum, "Lludd
# and Llefelys", Plato's Timaeus and Critias, the Eddas), never later versions.
# Run: python3 build_abyss.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def figure(c, step, robe, skin, hair, legs="k", x0=14, top=18, bottom=50):
    """A standing figure in a long robe (shared by the boss figures)."""
    for k, d in enumerate((-step, step)):
        c.rect(x0 + 2 + k * 6 + d, bottom - 2, x0 + 4 + k * 6 + d, bottom + 4, legs)
    poly(c, [(x0, top), (x0 + 14, top), (x0 + 17, bottom), (x0 - 3, bottom)], robe)
    c.rect(x0 + 2, top - 12, x0 + 11, top - 2, skin)
    c.rect(x0, top - 15, x0 + 13, top - 11, hair)
    c.px(x0 + 4, top - 8, "o"); c.px(x0 + 9, top - 8, "o")


# --- Ashkarrow (invented for Mythriven) ----------------------------------------------------------------------------

def ash_fiend(c, f):
    """An ash fiend (Mythriven's own): a grey, hunched figure of packed ash, embers glowing through its cracks."""
    s = STEP[f]
    for x, d in ((6, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "a")
    ellipse(c, 9, 12, 5, 6, "g")
    ellipse(c, 11, 5, 3.5, 3, "g")
    c.px(10, 5, "e"); c.px(13, 5, "e")
    for x, y in ((7, 10), (10, 14), (12, 11), (8, 15)):
        c.px(x, y, "e")
    c.rect(3, 10, 4, 15, "a"); c.rect(15, 9, 16, 14, "a")


ASH_FIEND_PAL = {"o": "#120c0a", "g": "#5a5250", "a": "#3e3634", "e": "#f07a2a"}


def cinder_imp(c, f):
    """A cinder imp (Mythriven's own): a little spark of Ashkarrow with arms and legs, flickering."""
    up = f % 2
    ellipse(c, 6, 6, 3, 3, "r"); ellipse(c, 6, 6 - up, 1.5, 1.5, "y")
    c.px(4, 5, "k"); c.px(8, 5, "k")
    c.px(2, 6 + up, "r"); c.px(10, 6 - up, "r"); c.px(5, 10, "r"); c.px(7, 10, "r")
    c.px(6, 1 + up, "y")


CINDER_IMP_PAL = {"o": "#2a0e06", "r": "#e8502a", "y": "#ffd060", "k": "#1a0a06"}


def chain_warden(c, step):
    """The Chain Warden (Mythriven's own): the gatekeeper of Ashkarrow, a broad grey figure wound about with red-hot
    chains, a loop of chain hanging from his fist."""
    figure(c, step, "g", "a", "a", legs="a")
    for y in range(20, 48, 5):
        c.row(y, 13, 30, "r"); c.px(15, y + 1, "R"); c.px(25, y + 1, "R")
    c.px(18, 10, "e"); c.px(23, 10, "e")
    for k in range(8):
        c.px(33 + (k % 2), 22 + k * 3, "r"); c.px(34 + (k % 2), 23 + k * 3, "R")


WARDEN_PAL = {"o": "#120c0a", "k": "#1e1816", "g": "#4a4240", "a": "#363030", "r": "#e8602a", "R": "#a83a1a",
              "e": "#ffb040"}


def ash_colossus(c, step):
    """The Ash Colossus (Mythriven's own): a giant heaped up out of hot grey ash, embers showing in its seams."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 18 + d, 40, 23 + k * 18 + d, 52, "a")
    ellipse(c, 30, 30, 18, 14, "g")
    ellipse(c, 30, 12, 9, 8, "g")
    c.rect(6, 22, 12, 40, "a"); c.rect(48, 22, 54, 40, "a")
    c.px(26, 11, "e"); c.px(34, 11, "e"); c.row(16, 27, 33, "e")
    for x, y in ((20, 26), (24, 34), (34, 28), (38, 36), (29, 40), (16, 32), (44, 30)):
        c.px(x, y, "e"); c.px(x + 1, y + 1, "E")


COLOSSUS_PAL = {"o": "#120c0a", "g": "#6a6260", "a": "#4a4240", "e": "#f07a2a", "E": "#ffc060"}


def lord_of_ashkarrow(c, step):
    """The Lord of Ashkarrow (Mythriven's own): the master of the city of ash, tall in a charcoal robe, crowned with
    cinders."""
    figure(c, step, "k", "g", "k", legs="K")
    c.rect(12, 22, 32, 24, "r"); c.rect(20, 24, 23, 48, "r")
    for x in range(15, 29, 3):
        c.rect(x, 0, x + 1, 3, "e"); c.px(x, 0, "y")
    c.px(18, 10, "y"); c.px(23, 10, "y")
    c.rect(34, 10, 35, 48, "K"); ellipse(c, 34, 8, 3, 3, "e")


LORD_PAL = {"o": "#0e0a0a", "k": "#2a2426", "K": "#1a1416", "g": "#6a6260", "r": "#a8321a", "e": "#f07a2a",
            "y": "#ffd060"}


# --- Dinas Emrys (Historia Brittonum 40-42; "Lludd and Llefelys") -------------------------------------------------

def coraniad(c, f):
    """A Coraniad ("Lludd and Llefelys": the people who heard every word the wind touched): a pale, thin figure in a grey
    cloak with great, pricked ears."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    poly(c, [(6, 8), (13, 8), (15, 19), (4, 19)], "c")
    c.rect(7, 2, 12, 7, "s")
    poly(c, [(7, 3), (3, 0), (6, 6)], "s"); poly(c, [(12, 3), (16, 0), (13, 6)], "s")
    c.px(8, 4, "k"); c.px(11, 4, "k")


CORANIAD_PAL = {"o": "#14141e", "k": "#1e1e28", "c": "#7a7a9a", "s": "#d8d0d0"}


def wyrmling(c, f):
    """A wyrmling (Historia Brittonum 42: the dragons are called "worms"): a little white dragon on beating wings."""
    up = f % 2
    poly(c, [(6, 6), (1, 1 if up else 5), (5, 8)], "W"); poly(c, [(9, 6), (14, 1 if up else 5), (10, 8)], "W")
    ellipse(c, 7, 8, 3, 2, "w"); ellipse(c, 11, 6, 2, 1.5, "w"); c.px(12, 5, "r")
    c.px(3, 9, "w"); c.px(2, 10, "W")


WYRMLING_PAL = {"o": "#3a3a48", "w": "#f0f0ec", "W": "#c8ccd8", "r": "#c83a2a"}


def coraniaid(c, step):
    """The Coraniaid ("Lludd and Llefelys"): a tall grey-cloaked figure of the people who heard every word the wind
    touched, with long, listening ears and a hand cupped to one of them."""
    figure(c, step, "c", "s", "C")
    poly(c, [(16, 6), (9, 0), (15, 11)], "s"); poly(c, [(26, 6), (33, 0), (27, 11)], "s")
    c.rect(28, 8, 31, 12, "s"); c.rect(29, 12, 30, 22, "c")
    c.px(18, 10, "k"); c.px(23, 10, "k")


CORANIAID_PAL = dict(CORANIAD_PAL, C="#5a5a7a")


def feast_magician(c, step):
    """The Magician of the Feast ("Lludd and Llefelys": the mighty man of magic who played the court to sleep and carried
    off the feast): a big man in a dark cloak with a harp under one arm and a hamper on his back."""
    figure(c, step, "m", "s", "h")
    c.rect(4, 14, 12, 30, "b"); c.row(18, 4, 12, "B")
    poly(c, [(30, 18), (38, 16), (38, 36), (32, 36)], "y")
    for k in range(4):
        c.rect(32 + k * 1, 19 + k, 32 + k * 1, 35, "w")
    c.px(18, 10, "k"); c.px(23, 10, "k"); c.row(14, 18, 23, "h")


MAGICIAN_PAL = {"o": "#120e0a", "k": "#1e1814", "m": "#3a2a4a", "s": "#d8b090", "h": "#4a3a2a", "b": "#8a6a3a",
                "B": "#6a4e2a", "y": "#c8a040", "w": "#f0ece4"}


def white_dragon(c, step):
    """The White Dragon (Historia Brittonum 42; "Lludd and Llefelys"): a great white dragon, wings raised, with pale blue
    eyes and frost at its jaws."""
    poly(c, [(26, 20), (4, 2 - step), (20, 28)], "W"); poly(c, [(34, 20), (56, 2 + step), (40, 28)], "W")
    ellipse(c, 30, 32, 16, 9, "w")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(18 + k * 8 + d, 38, 20 + k * 8 + d, 48, "W")
    poly(c, [(42, 26), (52, 16), (60, 20), (52, 26)], "w"); c.px(54, 19, "b")
    c.row(24, 56, 62, "i"); c.px(61, 23, "i")
    for k in range(12):
        c.px(14 - k, 34 + k // 3, "w"); c.px(14 - k, 35 + k // 3, "W")


WHITE_DRAGON_PAL = {"o": "#2a2a38", "w": "#f0f0ec", "W": "#c8ccd8", "b": "#4a8ad0", "i": "#c8e8ff"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_abyss.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("ash_fiend", ash_fiend, ASH_FIEND_PAL, doc(ash_fiend.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("cinder_imp", cinder_imp, CINDER_IMP_PAL, doc(cinder_imp.__doc__), (13, 12), (6, 11), walk, folder="enemies")
    kit.build_boss("chain_warden", chain_warden, WARDEN_PAL, doc(chain_warden.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("ash_colossus", ash_colossus, COLOSSUS_PAL, doc(ash_colossus.__doc__), (60, 56), (30, 54), [0, 1, 0, -1, 0])
    kit.build_boss("lord_of_ashkarrow", lord_of_ashkarrow, LORD_PAL, doc(lord_of_ashkarrow.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("coraniad", coraniad, CORANIAD_PAL, doc(coraniad.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("wyrmling", wyrmling, WYRMLING_PAL, doc(wyrmling.__doc__), (16, 12), (8, 11), walk, folder="enemies")
    kit.build_boss("coraniaid", coraniaid, CORANIAID_PAL, doc(coraniaid.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("feast_magician", feast_magician, MAGICIAN_PAL, doc(feast_magician.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("white_dragon", white_dragon, WHITE_DRAGON_PAL, doc(white_dragon.__doc__), (64, 52), (30, 50), [0, 1, 0, -1, 0])
    print("wrote the Abyss's art")
