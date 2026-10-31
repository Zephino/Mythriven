# The Land of Legends' art (Pack 3, docs/PACK_3_PLAN.md; docs/ART_RULES.md): enemies (oni, tengu-kin, earth spider,
# restless warrior), the bosses (Tsuchigumo, Benkei, Shuten-doji), the Heroes Benkei and Minamoto no Yoshitsune, and
# the sika deer. Japanese historical legend: the Gikeiki, the Tale of the Heike, the Tsuchigumo Soshi and the Oeyama
# tale. No kami are drawn (Shinto is a living religion). Run build_weapons.py first, then python3 build_legends.py.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def oni(c, f):
    """An oni of Shuten-doji's band (the Oeyama tale): a big horned ogre with red skin, a tiger-skin loincloth and an
    iron club."""
    s = STEP[f]
    for x, d in ((8, -s), (14, s)):
        c.rect(x + d, 20, x + 2 + d, 27, "r")
        c.row(28, x - 1 + d, x + 3 + d, "k")
    ellipse(c, 12, 15, 7, 6, "r")
    c.rect(6, 18, 18, 21, "y")
    for x in (7, 10, 13, 16):
        c.px(x, 19, "k")                                                                 # tiger stripes
    ellipse(c, 12, 6, 4.5, 4.5, "r")
    c.px(10, 5, "w"); c.px(14, 5, "w"); c.row(9, 10, 14, "w")
    c.px(9, 1, "h"); c.px(15, 1, "h"); c.px(9, 2, "h"); c.px(15, 2, "h")                  # horns
    c.rect(8, 2, 16, 3, "k")                                                              # wild black hair
    c.rect(18, 12, 20, 15, "r")
    for k in range(12):
        c.px(21, 16 - k, "i")                                                             # iron club
    c.rect(20, 3, 22, 7, "i"); c.px(21, 2, "I")


ONI_PAL = {"o": "#140806", "k": "#0a0404", "r": "#b83a2a", "y": "#e0b040", "w": "#f0ece0", "h": "#e8dcc0",
           "i": "#6a6e76", "I": "#9aa2ac"}


def tengu(c, f):
    """Tengu-kin (the Gikeiki: the tengu of Mount Kurama who taught the boy Yoshitsune swordsmanship): a crow-beaked,
    black-winged mountain goblin in a monk's dark robe."""
    flap = [0, -2, -4, -2, 0][f]
    poly(c, [(8, 8), (5, 2 + flap), (11, 8)], "b"); poly(c, [(13, 8), (18, 2 + flap), (15, 9)], "B")
    poly(c, [(8, 8), (15, 8), (16, 18), (7, 18)], "r")
    ellipse(c, 11, 5, 3, 3, "s")
    poly(c, [(13, 4), (17, 5), (13, 6)], "y"); c.px(11, 4, "k")                          # crow's beak
    c.rect(9, 1, 13, 2, "k")
    c.rect(8, 18, 9, 21, "k"); c.rect(13, 18, 14, 21, "k")


TENGU_PAL = {"o": "#0a0a0c", "k": "#060608", "b": "#24222a", "B": "#3a3844", "r": "#3a3a52", "s": "#d8b898",
             "y": "#e0b040"}


def earth_spider(c, f):
    """An earth spider (the Tsuchigumo Soshi): a small dark mountain spider, hairy legs splayed."""
    s = STEP[f]
    ellipse(c, 9, 8, 5, 3.5, "b"); ellipse(c, 14, 8, 3, 2.5, "B")
    for k in range(4):
        y = 6 + k
        c.px(4 - (k + s) % 2, y - 2, "b"); c.px(3, y, "b")
        c.px(16 + (k + s) % 2, y - 2, "b"); c.px(18, y, "b")
    c.px(15, 7, "r"); c.px(16, 8, "r")


SPIDER_PAL = {"o": "#08060a", "b": "#3a3028", "B": "#24201a", "r": "#e04020"}


def warrior(c, f):
    """A restless warrior (the war tales of the Genpei era): the ghost of a fallen samurai in lacquered armour, pale,
    still fighting."""
    s = STEP[f]
    for x, d in ((7, -s), (12, s)):
        c.rect(x + d, 19, x + 2 + d, 25, "a")
    c.rect(6, 9, 15, 19, "a")
    for y in range(10, 19, 2):
        c.row(y, 6, 15, "A")                                                              # lacing rows
    c.rect(7, 2, 14, 8, "p"); c.px(12, 5, "k")
    c.rect(6, 0, 15, 3, "A"); c.px(5, 1, "u"); c.px(16, 1, "u")                          # helmet with crests
    for k in range(12):
        c.px(17, 18 - k, "e")
    c.rect(16, 18, 18, 18, "u")


WARRIOR_PAL = {"o": "#0a0c14", "k": "#06060a", "a": "#4a5a7a", "A": "#2e3a54", "p": "#c8d4e0", "u": "#d8b048",
               "e": "#e4e8ec"}


def tsuchigumo(c, step):
    """Tsuchigumo (the Tsuchigumo Soshi: Minamoto no Raiko and the earth spider): a monstrous spider of the
    mountain cave, huge, with striped legs and burning eyes, webs trailing."""
    ellipse(c, 34, 30, 16, 12, "b")
    ellipse(c, 34, 20, 9, 7, "B")
    for side in (-1, 1):
        for k in range(4):
            x0, y0 = 34 + side * 10, 24 + k * 4
            pts = [(x0, y0), (x0 + side * (14 + k), y0 - 10 + k * 2 + step * side), (x0 + side * (22 + k), y0 + 14)]
            for (ax, ay), (bx, by) in zip(pts, pts[1:]):
                for t in range(11):
                    c.px(round(ax + (bx - ax) * t / 10), round(ay + (by - ay) * t / 10), "b" if t % 3 else "y")
    for x, y in ((30, 18), (38, 18), (32, 16), (36, 16)):
        c.px(x, y, "r")
    for k in range(6):
        c.row(26 + k * 3, 24, 44, "B")


SPIDER_BOSS_PAL = {"o": "#08060a", "b": "#3a3028", "B": "#24201a", "y": "#c8a050", "r": "#f04020"}


def shuten(c, step):
    """Shuten-doji (the Oeyama tale): the oni king of Mount Oe, huge and red, fond of sake, in a rich robe, his great
    sake cup in hand; Raiko's men made him drunk with poisoned sake to kill him."""
    lurch = [0, 1, 0, -1, 0][step % 5] if step >= 0 else 0
    for k, d in enumerate((-step, step)):
        c.rect(18 + k * 12 + d, 56, 23 + k * 12 + d, 70, "r")
        c.row(71, 17 + k * 12 + d, 24 + k * 12 + d, "k")
    poly(c, [(12 + lurch, 26), (44 + lurch, 26), (48, 58), (8, 58)], "p")                # rich robe
    for y in range(30, 58, 6):
        c.row(y, 12, 44, "u")
    c.rect(18 + lurch, 8, 38 + lurch, 26, "r")
    c.px(24 + lurch, 15, "w"); c.px(32 + lurch, 15, "w"); c.rect(24 + lurch, 20, 32 + lurch, 22, "k")
    c.rect(16 + lurch, 4, 40 + lurch, 9, "h")                                            # wild red-black hair
    c.px(22 + lurch, 1, "w"); c.px(22 + lurch, 2, "w"); c.px(34 + lurch, 1, "w"); c.px(34 + lurch, 2, "w")   # horns
    c.rect(44, 30, 48, 38, "r")
    ellipse(c, 50, 30, 6, 2.5, "c"); c.row(29, 46, 54, "s")                              # the great red sake cup


SHUTEN_PAL = {"o": "#140606", "k": "#0a0404", "r": "#c83a2a", "p": "#2a3a6a", "u": "#d8b048", "w": "#f0ece0",
              "h": "#3a1410", "c": "#a82a2a", "s": "#f0e8c8"}


# --- Benkei and Yoshitsune (the Gikeiki) -------------------------------------------------------------------------

BENKEI_DOC = ("Benkei (docs/PACK_3_PLAN.md: the Land of Legends; boss and Hero). Built by tools/art/build_legends.py on "
              "the shared body in tools/art/hero_kit.py. From the Gikeiki and the old picture scrolls: the giant warrior "
              "monk in a white hood (the cowl of the mountain monks), dark robes over armour, his naginata.")
BENKEI_PAL = {"o": "#1e140c", "k": "#0e0a06", "s": "#c89870", "S": "#9a7050", "w": "#ece8e0", "W": "#b8b4ac",
              "b": "#2e2e36", "B": "#1e1e24", "i": "#6a727c", "n": "#3a2a20"}


def benkei(c, back_leg, front_leg):
    kit.far_arm(c)
    c.rect(9, 2, 17, 13, "w"); c.rect(9, 2, 10, 13, "W")                                # white monk's hood
    c.rect(12, 6, 16, 11, "s"); c.px(15, 8, "k"); c.px(12, 7, "S")
    c.rect(12, 10, 16, 11, "k")                                                          # heavy brows and stubble
    for y in range(13, 26):
        c.row(y, 8, 19, "b")
    c.rect(8, 13, 9, 25, "B")
    for y in (16, 19, 22):
        c.row(y, 10, 18, "i")                                                            # armour under the robe
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, lambda c, x0: (c.rect(x0, 29, x0 + 2, 30, "w"), c.row(31, x0, x0 + 3, "n")))


YOSHI_DOC = ("Minamoto no Yoshitsune (docs/PACK_3_PLAN.md: the Land of Legends' Hero). Built by tools/art/build_legends.py "
             "on the shared body in tools/art/hero_kit.py. From the Gikeiki and the Tale of the Heike: the young general, "
             "slight and quick, in red-laced armour and a horned helmet, his hair tied back.")
YOSHI_PAL = {"o": "#1e140c", "k": "#0e0a06", "s": "#ecd0b0", "S": "#bc9e80", "h": "#1a1410", "r": "#b02a2a",
             "R": "#7a1a1a", "a": "#3a3a4a", "u": "#d8b048", "n": "#3a2a20"}


def yoshitsune(c, back_leg, front_leg):
    kit.far_arm(c)
    c.rect(10, 3, 16, 6, "a"); c.px(10, 1, "u"); c.px(16, 1, "u"); c.px(11, 2, "u"); c.px(15, 2, "u")   # horned helmet
    c.rect(11, 6, 16, 12, "s"); c.px(11, 7, "S"); c.px(15, 8, "k")
    c.rect(9, 5, 10, 12, "h")
    for y in range(13, 25):
        c.row(y, 9, 18, "r")
    for y in range(14, 25, 2):
        c.row(y, 9, 18, "R")                                                             # red lacing
    c.rect(9, 13, 10, 24, "a")
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, lambda c, x0: (c.rect(x0, 28, x0 + 2, 30, "a"), c.row(31, x0, x0 + 3, "n")))


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_legends.py."
    walk = [0, 1, 2, 3, 4]
    for name, draw, pal, size, anchor in (("oni", oni, ONI_PAL, (24, 30), (12, 28)),
                                          ("tengu", tengu, TENGU_PAL, (22, 22), (11, 21)),
                                          ("earth_spider", earth_spider, SPIDER_PAL, (20, 12), (10, 11)),
                                          ("restless_warrior", warrior, WARRIOR_PAL, (20, 26), (10, 25))):
        kit.build_boss(name, draw, pal, doc(draw.__doc__), size, anchor, walk, folder="enemies")
    kit.build_boss("tsuchigumo", tsuchigumo, SPIDER_BOSS_PAL, doc(tsuchigumo.__doc__), (70, 46), (34, 44), [0, 1, 0, -1, 0])
    kit.build_boss("shuten_doji", shuten, SHUTEN_PAL, doc(shuten.__doc__), (58, 74), (28, 72), [0, 1, 0, -1, 0])
    kit.build("benkei", benkei, BENKEI_PAL, BENKEI_DOC, recolor=["b", "B"])
    kit.build("yoshitsune", yoshitsune, YOSHI_PAL, YOSHI_DOC, recolor=["r", "R"])
    kit.build_hero_boss("benkei", "naginata", "Benkei, boss (docs/PACK_3_PLAN.md: the Land of Legends, 20:00): the Hero's "
                        "art with his naginata, twice as big, on the Gojo Bridge. Built by tools/art/build_legends.py.")
    print("wrote the Land of Legends' art")
