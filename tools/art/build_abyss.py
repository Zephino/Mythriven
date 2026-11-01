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


# --- Atlantis (Plato, Timaeus 24e-25d; Critias 113b-121c) ----------------------------------------------------------

def atlantean_hoplite(c, f):
    """An Atlantean hoplite (Critias 119a: the heavy-armed soldiers): a soldier in a bronze helmet with a round shield
    and spear."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "k")
    c.rect(6, 8, 13, 17, "t"); c.rect(7, 2, 12, 7, "s")
    c.rect(6, 0, 13, 3, "b"); c.rect(8, 0, 11, 0, "r")
    ellipse(c, 4, 12, 3.5, 4.5, "b"); c.px(4, 12, "B")
    c.rect(16, 0, 16, 20, "w"); c.px(16, 0, "b")


HOPLITE_PAL = {"o": "#120e0a", "k": "#2a1e14", "t": "#c8b890", "s": "#c8946a", "b": "#c8963a", "B": "#8a5a1a",
               "r": "#a83a2a", "w": "#7a5a3a"}


def atlantean_slinger(c, f):
    """An Atlantean slinger (Critias 119b): a light-armed soldier in a short tunic, whirling his sling."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "k")
    c.rect(6, 8, 13, 16, "t"); c.rect(7, 2, 12, 7, "s"); c.rect(7, 1, 12, 2, "h")
    a = f * 1.2
    c.px(14, 5, "s"); c.px(15 + round(2 * math.cos(a)), 3 + round(2 * math.sin(a)), "g")


SLINGER_PAL = {"o": "#120e0a", "k": "#2a1e14", "t": "#3a6a9a", "s": "#c8946a", "h": "#2a1a10", "g": "#8a8a8a"}


def poseidons_bull(c, step):
    """Poseidon's Bull (Critias 119d-e: the bulls that ranged free in Poseidon's temple): a great white bull with
    gilded horns, head lowered to charge."""
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 9 + d, 34, 16 + k * 9 + d, 45, "W"); c.rect(12 + k * 9 + d, 44, 16 + k * 9 + d, 45, "k")
    ellipse(c, 26, 28, 18, 9, "w")
    ellipse(c, 36, 22, 10, 9, "w")
    c.row(36, 12, 42, "W"); c.row(35, 14, 40, "W")
    ellipse(c, 48, 30, 6, 7, "w"); c.rect(46, 34, 52, 37, "p"); c.px(48, 36, "k"); c.px(51, 36, "k")
    poly(c, [(44, 25), (40, 18), (38, 14), (42, 17), (46, 24)], "y")
    poly(c, [(52, 25), (56, 18), (58, 14), (56, 19), (53, 26)], "y")
    c.px(46, 28, "k"); c.px(51, 28, "k")
    for k in range(8):
        c.px(8 - k // 2, 26 + k, "W")
    c.rect(4, 33, 5, 35, "k")


POSEIDON_BULL_PAL = {"o": "#1a1a20", "w": "#f0ece4", "W": "#c8c4bc", "p": "#d8a8a0", "y": "#e8c040", "k": "#1a1a20"}


def gadeirus(c, step):
    """Gadeirus (Critias 114b: Atlas' twin, king of the land toward the Pillars of Heracles): a king in a sea-blue robe
    with a gold diadem and a trident-headed staff."""
    figure(c, step, "b", "s", "h")
    c.row(3, 15, 26, "y"); c.px(20, 2, "y")
    c.rect(13, 24, 29, 25, "y")
    c.rect(33, 4, 34, 48, "w")
    for x in (31, 33, 36):
        c.rect(x, 0, x, 5, "y")
    c.row(5, 31, 36, "y")


GADEIRUS_PAL = {"o": "#0e0a08", "k": "#1e1814", "b": "#2a5a8a", "s": "#c8946a", "h": "#3a2a1a", "y": "#e8c040",
                "w": "#7a5a3a"}


def atlas_king(c, step):
    """Atlas (Critias 114a, 116: the first king of Atlantis, not the Titan): a tall king in deep blue, a cloak of
    gleaming orichalcum red-gold, and a crown."""
    figure(c, step, "b", "s", "h")
    poly(c, [(12, 18), (30, 18), (34, 50), (8, 50)], "r")
    c.rect(15, 18, 27, 50, "b")
    for x in range(15, 28, 3):
        c.rect(x, 1, x + 1, 4, "y")
    c.row(4, 15, 28, "y"); c.row(16, 18, 23, "h")


ATLAS_PAL = {"o": "#0e0a08", "k": "#1e1814", "b": "#1e3a6a", "s": "#c8946a", "h": "#e8e4dc", "y": "#e8c040",
             "r": "#d86a3a"}


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
    kit.build_boss("atlantean_hoplite", atlantean_hoplite, HOPLITE_PAL, doc(atlantean_hoplite.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("atlantean_slinger", atlantean_slinger, SLINGER_PAL, doc(atlantean_slinger.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("poseidons_bull", poseidons_bull, POSEIDON_BULL_PAL, doc(poseidons_bull.__doc__), (58, 48), (28, 46), [0, 1, 0, -1, 0])
    kit.build_boss("gadeirus", gadeirus, GADEIRUS_PAL, doc(gadeirus.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("atlas_king", atlas_king, ATLAS_PAL, doc(atlas_king.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    print("wrote the Abyss's art")
