# Mazandaran's art (Pack 3, docs/PACK_3_PLAN.md; docs/ART_RULES.md): enemies (div, sorcerer, wild lion, dragon-kin), the
# bosses (the Dragon of the Third Labour; the Witch of the Fourth Labour, disguised and revealed; the White Div), the
# Simurgh, the Hero Rostam and his horse Rakhsh. Drawn from Ferdowsi's Shahnameh (the Seven Labours of Rostam) and the
# old Persian manuscript paintings of it. No Persian gods are drawn (a living religion). Run: python3 build_mazandaran.py
import math
import hero_kit as kit
from hero_kit import ellipse, poly
from build_avalon import horse

STEP = [0, -1, 0, 1, 0]


def div(c, f):
    """A div of Mazandaran, as the old manuscript paintings show them: a horned, spotted demon with a tail, gold
    bands on its arms, a club."""
    s = STEP[f]
    for x, d in ((8, -s), (14, s)):
        c.rect(x + d, 20, x + 2 + d, 27, "d")
        c.row(28, x - 1 + d, x + 3 + d, "k")
    ellipse(c, 12, 15, 7, 6, "d")
    for x, y in ((8, 12), (14, 16), (11, 18), (16, 12), (9, 17)):
        c.px(x, y, "D")                                                                  # spots
    c.rect(6, 19, 18, 21, "r")                                                           # a short red kilt
    ellipse(c, 12, 6, 4.5, 4.5, "d")
    c.px(10, 5, "y"); c.px(14, 5, "y"); c.row(9, 10, 14, "w")
    for x, side in ((8, -1), (16, 1)):
        c.px(x, 2, "h"); c.px(x + side, 1, "h"); c.px(x + side * 2, 0, "h")               # horns
    c.rect(18, 12, 20, 15, "d"); c.row(13, 18, 20, "u")                                  # arm, gold band
    for k in range(10):
        c.px(21, 15 - k, "b")                                                            # club
    c.rect(20, 3, 22, 6, "b")
    c.rect(2, 18, 5, 19, "d"); c.px(1, 17, "d")                                          # tail


DIV_PAL = {"o": "#140c0a", "k": "#0a0604", "d": "#6a7a5a", "D": "#3e4a34", "r": "#a83a2a", "y": "#f0d040",
           "w": "#f0ece0", "h": "#e8dcc0", "u": "#e0b040", "b": "#5a3e26"}


def sorcerer(c, f):
    """A sorcerer of Mazandaran (the Shahnameh: the sorcery of the divs' land): a robed figure with a long staff."""
    s = STEP[f]
    poly(c, [(7, 8), (13, 8), (15, 24), (5, 24)], "p")
    poly(c, [(7, 8), (9, 8), (8, 24), (5, 24)], "P")
    c.rect(8, 2, 12, 7, "s"); c.px(11, 4, "k"); c.rect(7, 0, 13, 2, "P")
    c.rect(8, 6, 12, 9, "h")                                                             # beard
    for k in range(22):
        c.px(16, 24 - k + s * 0, "b")
    c.rect(15, 0, 17, 2, "g"); c.px(16, 1, "w")                                          # glowing staff-head
    c.row(25, 6 + s, 9 + s, "k"); c.row(25, 11 - s, 14 - s, "k")


SORC_PAL = {"o": "#100a14", "k": "#08060a", "p": "#4a2a5a", "P": "#2e1a3a", "s": "#c89a78", "h": "#2a2420",
            "b": "#5a4028", "g": "#60f0a0", "w": "#e0fff0"}


def lion(c, f):
    """A wild lion (the Shahnameh, first labour: the lion that attacked while Rostam slept, killed by Rakhsh)."""
    s = STEP[f]
    ellipse(c, 12, 10, 9, 4, "l")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 13, 6 + k * 4 + d, 17, "L" if k % 2 else "l")
    ellipse(c, 21, 7, 4.5, 5, "m")                                                       # mane
    poly(c, [(21, 6), (26, 7), (26, 10), (21, 10)], "l"); c.px(23, 7, "k"); c.px(26, 9, "k")
    c.rect(1, 8, 3, 9, "l"); c.px(0, 7, "m")


LION_PAL = {"o": "#140c06", "k": "#080402", "l": "#c8984a", "L": "#a07836", "m": "#7a4a20"}


def dragon_kin(c, f):
    """Dragon-kin (the Shahnameh's dragons): a small winged, fire-breathing dragon, scaled in dark green and red."""
    flap = [0, -3, -5, -3, 0][f]
    ellipse(c, 11, 11, 7, 3.5, "g")
    poly(c, [(8, 9), (4, 2 + flap), (14, 9)], "r")                                      # wing
    poly(c, [(17, 9), (22, 8), (22, 11), (17, 12)], "g"); c.px(20, 9, "y")
    c.px(23, 10, "f"); c.px(24, 9, "f"); c.px(24, 11, "F")                              # a lick of fire
    c.rect(1, 11, 4, 12, "G"); c.px(0, 13, "G")


DRAKE_PAL = {"o": "#0a0c08", "g": "#3a6a3a", "G": "#244a26", "r": "#8a2a2a", "y": "#f0d040", "f": "#f0a020",
             "F": "#e04010"}


# --- Bosses --------------------------------------------------------------------------------------------------------

def dragon(c, step):
    """The Dragon of the Third Labour: a huge dragon that came out of the dark three times while Rostam slept, until
    Rakhsh woke him and they killed it together. Long and serpentine, scaled, horned, breathing fire."""
    for k in range(9):                                                                   # the long body
        ellipse(c, 10 + k * 6, 34 + round(4 * math.sin(k / 1.5 + step * 0.4)), 6, 5, "g" if k % 2 else "G")
    for k in range(4):
        c.rect(14 + k * 12 + step, 38, 16 + k * 12 + step, 46, "G")
        c.row(46, 13 + k * 12 + step, 18 + k * 12 + step, "y")                            # claws
    poly(c, [(54, 20), (66, 22), (68, 30), (56, 34)], "g")                               # head
    c.rect(62, 28, 68, 31, "G"); c.row(29, 62, 68, "w")
    c.px(60, 24, "y")
    poly(c, [(56, 20), (52, 12), (58, 18)], "h"); poly(c, [(60, 20), (60, 11), (63, 19)], "h")
    for k in range(6):
        c.px(30 + k * 5, 27 - (k % 2), "r")                                              # crest
    poly(c, [(69, 28), (72, 25), (72, 33)], "f")


DRAGON_PAL = {"o": "#08100a", "g": "#2e5a34", "G": "#1e3e24", "y": "#e8c040", "w": "#f0ece0", "h": "#d8d0b0",
              "r": "#a83020", "f": "#f08020"}


def witch(disguised):
    """The Witch of the Fourth Labour: she came to Rostam's feast as a lovely young woman; when he spoke the name of
    God her face turned black and she showed herself a hideous old sorceress, and he cut her in two."""
    def draw(c, step):
        for k, d in enumerate((-step, step)):
            c.rect(16 + k * 5 + d, 50, 18 + k * 5 + d, 54, "k")
        if disguised:
            poly(c, [(14, 20), (28, 20), (32, 52), (10, 52)], "p")                       # a rich red gown
            c.row(30, 12, 30, "u"); c.row(44, 11, 31, "u")
            c.rect(16, 8, 25, 18, "s"); c.px(22, 12, "k"); c.px(19, 12, "k")
            c.rect(15, 4, 26, 8, "h"); c.rect(14, 7, 16, 28, "h")                         # long dark hair
            c.row(16, 19, 22, "r")
            c.rect(28, 24, 30, 30, "s"); c.rect(30, 20, 34, 28, "b"); c.rect(33, 14, 34, 20, "b")   # a lute
        else:
            poly(c, [(14, 20), (28, 20), (32, 52), (10, 52)], "P")                       # rags, black
            c.rect(16, 8, 25, 18, "S"); c.px(22, 12, "y"); c.px(19, 12, "y")              # blackened face
            c.rect(15, 4, 26, 8, "g"); c.rect(13, 7, 16, 32, "g")                         # wild grey hair
            c.row(16, 18, 23, "k"); c.px(20, 16, "w")
            for k in range(4):
                c.px(30 + k, 24 - k, "S")                                                # clawed hand raised
    return draw


WITCH_PAL = {"o": "#100a0c", "k": "#08060a", "p": "#a82a3a", "P": "#1c181c", "u": "#e0b040", "s": "#e8c8a8",
             "S": "#2a2026", "h": "#24181a", "g": "#9a9a98", "r": "#c84050", "b": "#8a5a2a", "y": "#e0d040",
             "w": "#e0dcd0"}


def white_div(c, step):
    """The White Div (the seventh labour): the great demon of Mazandaran in his cave, white as snow, huge as a
    mountain, with horns and a boulder in his hands. Rostam tore out his heart and liver to cure the blinded king."""
    for k, d in enumerate((-step, step)):
        c.rect(18 + k * 14 + d, 58, 25 + k * 14 + d, 74, "w" if k else "W")
        c.row(75, 17 + k * 14 + d, 26 + k * 14 + d, "k")
    ellipse(c, 30, 44, 18, 16, "w")
    for x, y in ((22, 40), (36, 48), (28, 54), (40, 38), (18, 50)):
        ellipse(c, x, y, 2, 1.5, "D")                                                    # spots
    c.rect(14, 54, 46, 58, "r")
    ellipse(c, 30, 20, 10, 10, "w")
    c.px(26, 18, "y"); c.px(34, 18, "y"); c.rect(25, 24, 35, 27, "k"); c.row(25, 26, 34, "W")
    for side in (-1, 1):
        for k in range(6):
            c.px(30 + side * (8 + k), 12 - k + (k // 3), "h")                            # great horns
    for side, x in ((-1, 8), (1, 48)):
        c.rect(x, 34, x + 5, 50, "W")
        c.row(38, x, x + 5, "u")
    ellipse(c, 30, 4, 9, 4, "s")                                                         # the boulder held overhead
    c.rect(10, 2, 13, 34, "W"); c.rect(47, 2, 50, 34, "W")


WHITE_PAL = {"o": "#14141a", "k": "#08080c", "w": "#eceef2", "W": "#c8ccd4", "D": "#8a8e98", "r": "#6a2a2a",
             "y": "#e04020", "h": "#d8cca8", "u": "#e0b040", "s": "#8a8478"}


def simurgh(c, f):
    """The Simurgh (the Shahnameh): the great mythic bird who raised Zal and gave him her feathers to burn when in
    need; she healed Rudaba and Rostam. A vast bird with a long, sweeping tail of many colours, as in the paintings."""
    flap = [0, -3, -6, -3, 0][f]
    ellipse(c, 18, 14, 6, 4, "g")
    poly(c, [(16, 12), (4, 2 + flap), (8, 12)], "b")
    poly(c, [(20, 12), (30, 3 + flap), (26, 13)], "B")
    poly(c, [(23, 10), (28, 8), (27, 12)], "g"); c.px(26, 9, "k"); c.px(29, 10, "u")
    c.px(24, 7, "r"); c.px(25, 6, "r")                                                   # crest
    for k in range(4):                                                                   # the sweeping tail
        poly(c, [(13, 15), (0 + k, 20 + k * 2), (4 + k, 22 + k * 2)], ("r", "u", "b", "B")[k])


SIMURGH_PAL = {"o": "#140c08", "k": "#080402", "g": "#3aa08a", "b": "#2a6ab0", "B": "#6a3a9a", "r": "#c83a3a",
               "u": "#e0b040"}


# --- Rostam and Rakhsh (the Shahnameh) -------------------------------------------------------------------------------

ROSTAM_DOC = ("Rostam (docs/PACK_3_PLAN.md: Mazandaran's Hero; art 10/31/2026). Built by tools/art/build_mazandaran.py on "
              "the shared body in tools/art/hero_kit.py. From the Shahnameh and the old manuscript paintings: the "
              "champion of Iran in his tiger-skin war-coat (babr-e bayan), a helmet, a long black beard; he carries his "
              "ox-headed mace.")
ROSTAM_PAL = {"o": "#1e140c", "k": "#0e0a06", "s": "#c89870", "S": "#9a7050", "h": "#1a1410", "H": "#3a2e24",
              "b": "#c8903a", "B": "#9a6a24", "d": "#3a2a18", "i": "#9aa2ac", "I": "#6a727c", "u": "#d8b048",
              "n": "#5a3a20"}


def rostam(c, back_leg, front_leg):
    kit.far_arm(c)
    c.rect(10, 2, 16, 6, "i"); c.rect(10, 2, 10, 7, "I"); c.px(13, 1, "u")             # helmet
    c.rect(11, 6, 16, 11, "s"); c.px(11, 7, "S"); c.px(15, 8, "k"); c.px(17, 8, "s")
    c.rect(11, 10, 16, 15, "h")                                                           # long black beard
    for y in (11, 13):
        c.row(y, 12, 16, "H")
    for y in range(14, 26):                                                               # the tiger-skin war-coat
        c.row(y, 9, 18, "b")
    for x, y in ((10, 16), (13, 15), (16, 17), (11, 20), (15, 21), (12, 24), (17, 23)):
        c.px(x, y, "d"); c.px(x + 1, y, "d")                                              # its stripes
    c.rect(9, 14, 10, 25, "B")
    c.row(20, 9, 18, "u")
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, lambda c, x0: (c.rect(x0, 28, x0 + 2, 30, "n"), c.row(31, x0, x0 + 3, "n")))


RAKHSH_DOC = ("Rakhsh, Rostam's horse (docs/PACK_3_PLAN.md: Rostam's Legend Trait). The Shahnameh: his coat was like "
              "rose petals scattered on saffron; he killed the lion of the first labour and woke Rostam against the "
              "dragon of the third. A red-gold dappled war-horse. Built by tools/art/build_mazandaran.py.")
RAKHSH_PAL = {"o": "#140c06", "k": "#080402", "h": "#c87a3a", "H": "#9a5226", "r": "#e0a050"}


def rakhsh(c, f):
    horse(c, 2, 12, "h", "H", STEP[f], length=22)
    for x, y in ((6, 15), (12, 14), (18, 16), (9, 18), (15, 18)):
        c.px(x, y, "r")                                                                   # dappled like rose petals


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_mazandaran.py."
    walk = [0, 1, 2, 3, 4]
    for name, draw, pal, size, anchor in (("div", div, DIV_PAL, (24, 30), (12, 28)),
                                          ("sorcerer", sorcerer, SORC_PAL, (20, 26), (10, 25)),
                                          ("wild_lion", lion, LION_PAL, (28, 18), (13, 17)),
                                          ("dragon_kin", dragon_kin, DRAKE_PAL, (26, 16), (12, 15))):
        kit.build_boss(name, draw, pal, doc(draw.__doc__), size, anchor, walk, folder="enemies")
    kit.build_boss("dragon_third_labour", dragon, DRAGON_PAL, doc(dragon.__doc__), (74, 50), (36, 48), [0, 1, 0, -1, 0])
    kit.build_boss("witch_fourth_labour", witch(False), WITCH_PAL, doc(witch.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("witch_fourth_labour_disguised", witch(True), WITCH_PAL, doc(witch.__doc__ + " Here, disguised."), (40, 56), (20, 54),
                   [0, 1, 0, -1, 0])
    kit.build_boss("white_div", white_div, WHITE_PAL, doc(white_div.__doc__), (62, 78), (30, 76), [0, 1, 0, -1, 0])
    kit.build_boss("simurgh", simurgh, SIMURGH_PAL, doc(simurgh.__doc__), (32, 30), (16, 28), walk, folder="summons")
    kit.build("rostam", rostam, ROSTAM_PAL, ROSTAM_DOC, recolor=["b", "B"])
    kit.build_boss("rakhsh", rakhsh, RAKHSH_PAL, RAKHSH_DOC, (36, 32), (16, 30), walk, folder="companions")
    print("wrote Mazandaran's art")
