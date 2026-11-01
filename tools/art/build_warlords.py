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
    print("wrote the Warlords' art")
