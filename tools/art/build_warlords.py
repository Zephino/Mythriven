# Warlords' art (Pack 8, docs/PACK_8_PLAN.md; docs/ART_RULES.md), one realm at a time. Ghorvast is the game's own;
# the rest is drawn only from the old texts (Apollodorus, Plutarch, Ovid, Snorri, Geoffrey of Monmouth, Malory).
# Run: python3 build_warlords.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def figure(c, step, robe, skin, hair, legs="k", x0=14, top=18, bottom=50):
    """A standing figure in a long robe or tunic (shared by the boss figures)."""
    for k, d in enumerate((-step, step)):
        c.rect(x0 + 2 + k * 6 + d, bottom - 2, x0 + 4 + k * 6 + d, bottom + 4, legs)
    poly(c, [(x0, top), (x0 + 14, top), (x0 + 17, bottom), (x0 - 3, bottom)], robe)
    c.rect(x0 + 2, top - 12, x0 + 11, top - 2, skin)
    c.rect(x0, top - 15, x0 + 13, top - 11, hair)
    c.px(x0 + 4, top - 8, "o"); c.px(x0 + 9, top - 8, "o")


# --- Ghorvast (the game's own invented orc stronghold) ----------------------------------------------------------------

def orc(kind):
    """An orc of Ghorvast (the game's own; the word is old English "orcneas"): a broad grey-skinned warrior with small
    tusks in crude leather and iron."""
    def draw(c, f):
        s = STEP[f]
        big = kind == "brute"
        w = 3 if big else 0
        for x, d in ((7, -s), (12 + w, s)):
            c.rect(x + d, 18 + w, x + 1 + d, 23 + w, "k")
        c.rect(5, 8, 15 + w, 18 + w, "l"); c.row(13, 5, 15 + w, "L")
        ellipse(c, 10 + w // 2, 5, 3.5 + w / 2, 3, "g"); c.px(9, 4, "r"); c.px(12 + w // 2, 4, "r")
        c.px(9, 7, "w"); c.px(12 + w // 2, 7, "w")                                           # tusks
        if kind == "archer":
            for k in range(9):
                c.px(18 + round(math.sin(k / 8 * math.pi) * 2), 5 + k * 2 // 2 + k, "b")
            c.rect(17, 5, 17, 18, "W")
        elif kind == "brute":
            c.rect(21, 2, 22, 20, "b"); c.rect(19, 0, 25, 4, "i")
        else:
            c.rect(17, 4, 18, 16, "i"); c.rect(16, 15, 19, 16, "b")
    return draw


ORC_PAL = {"o": "#0e0c08", "k": "#1e1a14", "l": "#5a4430", "L": "#3e2e20", "g": "#7a8070", "r": "#e8b030",
           "w": "#ece4d0", "b": "#5a3a1a", "i": "#8a8e96", "W": "#c8c4bc"}


def carrion_crow(c, f):
    """A carrion crow over the walls of Ghorvast."""
    up = f % 2
    poly(c, [(9, 7), (1, 2 if up else 10), (5, 9)], "k"); poly(c, [(11, 7), (19, 2 if up else 10), (15, 9)], "k")
    ellipse(c, 10, 8, 3, 3, "K"); poly(c, [(12, 6), (16, 8), (12, 9)], "b"); c.px(11, 7, "w")


CROW_PAL = {"o": "#2a2a30", "k": "#121216", "K": "#1e1e24", "b": "#2a2a2a", "w": "#c8c8d0"}


def war_drummer(c, step):
    """The War Drummer (the game's own): a huge orc beating a great war drum slung before him."""
    figure(c, step, "l", "g", "k", x0=14, top=18, bottom=50)
    c.px(18, 15, "w"); c.px(23, 15, "w")
    ellipse(c, 21, 34, 12, 8, "d"); ellipse(c, 21, 31, 12, 4, "D")                          # the drum
    for x in range(10, 33, 4):
        c.rect(x, 33, x, 40, "b")
    c.rect(6, 22 - step * 3, 8, 30, "b"); c.rect(34, 22 + step * 3, 36, 30, "b")              # the sticks


DRUM_PAL = dict(ORC_PAL, d="#8a5a34", D="#d8c8a8")


def pit_champion(c, step):
    """The Pit Champion (the game's own): a scarred orc fighter, bare-chested, with an iron collar and two axes."""
    figure(c, step, "L", "g", "k", x0=14, top=18, bottom=50)
    c.rect(14, 18, 28, 28, "g"); c.row(22, 15, 27, "s"); c.row(25, 16, 24, "s")              # bare chest, scars
    c.rect(16, 16, 26, 17, "i"); c.px(18, 15, "w"); c.px(23, 15, "w")
    for side in (-1, 1):
        x = 21 + side * 14
        c.rect(x, 18, x, 36, "b"); poly(c, [(x, 18), (x + side * 6, 16), (x + side * 6, 24), (x, 22)], "i")


CHAMP_PAL = dict(ORC_PAL, s="#b05a4a")


def warlord(c, step):
    """The Warlord (the game's own): a great orc in black iron armour with a horned helm and a heavy cleaver."""
    figure(c, step, "a", "g", "a", x0=14, top=18, bottom=50)
    c.rect(14, 18, 28, 32, "A"); c.row(24, 14, 28, "a")
    c.rect(13, 2, 28, 7, "a")
    poly(c, [(13, 4), (8, -2), (14, 2)], "w"); poly(c, [(28, 4), (33, -2), (27, 2)], "w")     # horns
    c.px(18, 10, "r"); c.px(23, 10, "r"); c.px(18, 15, "w"); c.px(23, 15, "w")
    c.rect(34, 14, 35, 40, "b"); poly(c, [(35, 14), (42, 14), (42, 26), (35, 24)], "i")


WARLORD_PAL = dict(ORC_PAL, a="#2a2a30", A="#3a3a44")


# --- Knossos (Apollodorus 2.5.7, 3.1.3-4, Epitome 1.7-9; Plutarch, Theseus 15-19; Odyssey 11.568) ---------------------

def cretan_guard(c, f):
    """A guard of Minos' palace (Plutarch, Theseus 19: Minos' general Taurus and his men): a Cretan soldier with a tall
    figure-of-eight shield and a spear, long dark hair."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "s")
    c.rect(6, 9, 13, 18, "w"); c.rect(6, 15, 13, 18, "r")
    ellipse(c, 9, 5, 3, 3, "s"); c.rect(6, 1, 12, 3, "h"); c.rect(5, 3, 6, 10, "h")
    ellipse(c, 3, 9, 3, 3, "d"); ellipse(c, 3, 15, 3, 3, "d")                                  # figure-of-eight shield
    c.rect(16, 0, 16, 20, "b")


GUARD_PAL = {"o": "#120c08", "s": "#c88a5a", "w": "#ece4d0", "r": "#b03a2a", "h": "#1a1410", "d": "#c8a878",
             "b": "#6a4a2a"}


def young_bull(c, f):
    """A young Cretan bull (the bulls of the bull-leaping games): a lean dappled bull with long horns."""
    s = STEP[f]
    ellipse(c, 10, 9, 7, 3.5, "w"); c.px(7, 8, "b"); c.px(11, 10, "b"); c.px(13, 8, "b")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(4 + k * 4 + d, 11, 4 + k * 4 + d, 15, "W")
    poly(c, [(15, 6), (20, 8), (20, 11), (15, 11)], "w"); c.px(18, 8, "k")
    c.px(16, 4, "h"); c.px(15, 3, "h"); c.px(19, 4, "h"); c.px(20, 3, "h")


YOUNG_BULL_PAL = {"o": "#120a06", "w": "#e8dcc8", "W": "#b8a890", "b": "#4a3020", "k": "#100808", "h": "#f0e8d8"}


def cretan_bull(c, step):
    """The Cretan Bull (Apollodorus 2.5.7): the white bull Poseidon sent from the sea, which Minos would not sacrifice;
    Poseidon maddened it, and it ravaged Crete until Heracles caught it."""
    ellipse(c, 28, 28, 22, 12, "w"); ellipse(c, 26, 24, 16, 6, "W")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 10 + d, 36, 16 + k * 10 + d, 50, "W")
    poly(c, [(46, 18), (60, 22), (60, 32), (46, 34)], "w"); c.px(52, 22, "r")
    c.rect(56, 28, 60, 31, "p")
    for k in range(7):
        c.px(48 - k // 2, 17 - k, "h"); c.px(55 + k // 2, 17 - k, "h")                         # horns
    c.rect(6, 22, 8, 32, "W")


CRETAN_BULL_PAL = {"o": "#1a0e08", "w": "#f4f0e8", "W": "#c8c0b0", "r": "#e83a2a", "p": "#d8a8a0", "h": "#e8d8b0"}


def minos(c, step):
    """Minos (Odyssey 11.568: "Minos, the glorious son of Zeus, a golden sceptre in his hand, giving judgement to the
    dead"): a bearded king in a long robe with a golden sceptre."""
    figure(c, step, "r", "s", "h")
    c.rect(16, 18, 26, 26, "R"); c.rect(16, 13, 25, 16, "h")
    c.rect(14, 1, 27, 3, "y"); c.px(15, 0, "y"); c.px(21, 0, "y"); c.px(26, 0, "y")
    c.rect(32, 6, 32, 48, "y"); ellipse(c, 32, 5, 2, 2, "y")


MINOS_PAL = {"o": "#120808", "k": "#1a1010", "r": "#2a3a7a", "R": "#1a2a5a", "s": "#c88a5a", "h": "#2a1a10",
             "y": "#e8c040"}


def asterion(c, step):
    """Asterion, the Minotaur (Apollodorus 3.1.4: "he had the face of a bull, but the rest of him was human"): a huge
    man with a bull's head and horns, naked to the waist, in the Labyrinth's dark."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 10 + d, 44, 20 + k * 10 + d, 56, "s")
    c.rect(14, 20, 36, 34, "s"); c.rect(14, 34, 36, 44, "l")
    c.rect(8, 22, 13, 38, "s"); c.rect(37, 22, 42, 38, "s")
    ellipse(c, 25, 12, 8, 8, "b"); c.rect(21, 14, 29, 19, "B"); c.px(22, 10, "r"); c.px(28, 10, "r")
    for k in range(8):
        c.px(17 - k, 8 - k // 2, "h"); c.px(33 + k, 8 - k // 2, "h")                          # horns


ASTERION_PAL = {"o": "#0e0806", "s": "#a86a44", "l": "#5a3a24", "b": "#3a2418", "B": "#5a3a28", "r": "#e83a2a",
                "h": "#e8dcc0"}


# --- Utgard (Snorri, Gylfaginning 44-47) ------------------------------------------------------------------------------

def utgard_thrall(c, f):
    """A thrall of Utgard's hall (Gylfaginning 46: the great hall full of giants on benches): a big rough giant's
    servant in furs, carrying a cudgel."""
    s = STEP[f]
    for x, d in ((7, -s), (12, s)):
        c.rect(x + d, 19, x + 2 + d, 24, "k")
    c.rect(5, 8, 15, 19, "f"); c.row(13, 5, 15, "F")
    ellipse(c, 10, 5, 3.5, 3, "s"); c.rect(7, 1, 13, 3, "h"); c.rect(8, 7, 12, 9, "h")
    c.rect(17, 3, 18, 17, "b")


THRALL_PAL = {"o": "#100c08", "k": "#2a2018", "f": "#8a7458", "F": "#6a5640", "s": "#c8a888", "h": "#8a6a40",
              "b": "#5a3a1a"}


def utgard_phantom(c, f):
    """A phantom of Utgard (Gylfaginning 47: all of it was illusion): a pale, half-there shape that bursts at a blow."""
    s = STEP[f]
    poly(c, [(6, 4), (10, 4), (12, 13 + s), (4, 13 - s)], "w")
    c.px(7, 6, "k"); c.px(9, 6, "k")
    for x in range(4, 13, 2):
        c.px(x, 14 + (x + f) % 2, "W")


PHANTOM_PAL = {"o": "#4a5468", "w": "#d8dcec", "W": "#a8b0c8", "k": "#2a3040"}


def utgarda_loki(copy):
    """Utgarda-Loki (Gylfaginning 44-47): the king of the giants of Utgard, so tall that Thor had to bend his head back
    to see over him, master of illusions."""
    def draw(c, step):
        figure(c, step, "g" if not copy else "G", "s", "h", x0=14, top=20, bottom=52)
        c.rect(16, 20, 26, 30, "G" if not copy else "g")
        c.rect(14, 2, 27, 4, "y"); c.px(15, 1, "y"); c.px(21, 1, "y"); c.px(26, 1, "y")
        poly(c, [(16, 15), (25, 15), (24, 26), (17, 26)], "h")                                   # long beard
        if copy:
            for y in range(0, 58, 3):
                for x in range(4, 40, 4):
                    if (x + y) % 3 == 0 and y < len(c.g) and x < len(c.g[y]) and c.g[y][x] in ("g", "G", "h"):
                        c.px(x, y, "m")
    return draw


UTGARD_PAL = {"o": "#0a0c14", "k": "#2a2a34", "g": "#4a5a7a", "G": "#3a4a6a", "s": "#c8b8a8", "h": "#a8a0a0",
              "y": "#c8c8d0", "m": "#c8d0f0"}


def logi(c, step):
    """Logi (Gylfaginning 46-47): "Wildfire", who ate the meat, the bones and the trough itself in the eating contest
    against Loki. A tall figure made of leaping flame."""
    for y in range(4, 58):
        w = 3 + int(9 * math.sin(min(y, 50) / 50 * math.pi)) + ((y + step * 2) % 4 == 0)
        c.rect(21 - w, y, 21 + w, y, "r" if y > 40 else ("y" if (y + step) % 5 else "w"))
    for k in range(5):
        c.px(14 + k * 3, 2 - (k + step) % 2, "y")
    c.px(18, 14, "k"); c.px(24, 14, "k"); c.rect(18, 20, 24, 21, "k")


LOGI_PAL = {"o": "#4a1004", "r": "#c83a10", "y": "#f0a020", "w": "#fff0a0", "k": "#5a1a04"}


def hugi(c, step):
    """Hugi (Gylfaginning 46-47): the young man who outran Thjalfi three times; he was Utgarda-Loki's thought. A slim
    pale runner, caught mid-stride, hair streaming."""
    for k, d in enumerate((-step * 3, step * 3)):
        c.rect(17 + k * 5 + d, 42, 19 + k * 5 + d, 54, "s")
    c.rect(15, 20, 26, 42, "w"); c.rect(15, 32, 26, 34, "W")
    c.rect(17, 8, 25, 18, "s"); c.px(19, 12, "k"); c.px(23, 12, "k")
    for k in range(10):
        c.px(15 - k, 8 + k // 3, "h"); c.px(15 - k, 9 + k // 3, "h")                               # hair streaming back
    for k in range(4):
        c.row(26 + k * 4, 2, 10 - k * 2, "W")                                                       # speed lines


HUGI_PAL = {"o": "#2a3040", "s": "#e8dcd0", "w": "#e8eef8", "W": "#a8b8d8", "k": "#1a2030", "h": "#d8d0b0"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_warlords.py."
    walk = [0, 1, 2, 3, 4]
    for kind in ("warrior", "archer", "brute"):
        size = (28, 28) if kind == "brute" else (22, 24)
        kit.build_boss("orc_" + kind, orc(kind), ORC_PAL, doc(orc.__doc__ + " An orc %s." % kind), size,
                       (size[0] // 2, size[1] - 1), walk, folder="enemies")
    kit.build_boss("carrion_crow", carrion_crow, CROW_PAL, doc(carrion_crow.__doc__), (20, 14), (10, 13), walk, folder="enemies")
    kit.build_boss("war_drummer", war_drummer, DRUM_PAL, doc(war_drummer.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    kit.build_boss("pit_champion", pit_champion, CHAMP_PAL, doc(pit_champion.__doc__), (44, 56), (21, 54), [0, 1, 0, -1, 0])
    kit.build_boss("warlord", warlord, WARLORD_PAL, doc(warlord.__doc__), (46, 58), (21, 56), [0, 1, 0, -1, 0])
    kit.build_boss("cretan_guard", cretan_guard, GUARD_PAL, doc(cretan_guard.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("young_bull", young_bull, YOUNG_BULL_PAL, doc(young_bull.__doc__), (22, 16), (10, 15), walk, folder="enemies")
    kit.build_boss("cretan_bull", cretan_bull, CRETAN_BULL_PAL, doc(cretan_bull.__doc__), (64, 52), (30, 50), [0, 1, 0, -1, 0])
    kit.build_boss("minos", minos, MINOS_PAL, doc(minos.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("asterion", asterion, ASTERION_PAL, doc(asterion.__doc__), (50, 60), (25, 58), [0, 1, 0, -1, 0])
    kit.build_boss("utgard_thrall", utgard_thrall, THRALL_PAL, doc(utgard_thrall.__doc__), (22, 26), (11, 25), walk, folder="enemies")
    kit.build_boss("utgard_phantom", utgard_phantom, PHANTOM_PAL, doc(utgard_phantom.__doc__), (16, 18), (8, 17), walk, folder="enemies")
    kit.build_boss("utgard_illusion", utgarda_loki(True), UTGARD_PAL, doc(utgarda_loki.__doc__ + " Here, one of his illusions."),
                   (42, 60), (21, 58), [0, 1, 0, -1, 0], folder="enemies")
    kit.build_boss("logi", logi, LOGI_PAL, doc(logi.__doc__), (42, 60), (21, 58), [0, 1, 0, 1, 0])
    kit.build_boss("hugi", hugi, HUGI_PAL, doc(hugi.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("utgarda_loki", utgarda_loki(False), UTGARD_PAL, doc(utgarda_loki.__doc__), (42, 60), (21, 58), [0, 1, 0, -1, 0])
    print("wrote the Warlords' art")
