# The bonus levels' art (docs/BONUS_LEVELS_PLAN.md; docs/ART_RULES.md). The Realm of the Ten Suns: enemies (bone demon,
# fox spirit, fire beast), the bosses (Nian; Baigujing, the White Bone Demon, in her true form and three disguises; the
# Ten Suns) and the Hero Hou Yi. From the Huainanzi, the Shanhaijing, Journey to the West and New Year folklore. Sun
# Wukong is not drawn (Tier B). Run build_weapons.py first, then python3 build_bonus.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


def bone_demon(c, f):
    """A bone demon (Journey to the West: the White Bone Demon's kind): a small rattling skeleton spirit."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 14, x + d, 19, "w")
        c.px(x - 1 + d, 19, "w")
    c.rect(9, 7, 9, 14, "w")
    for y in (8, 10, 12):
        c.row(y, 6, 12, "W")                                                            # ribs
    ellipse(c, 9, 4, 3, 3, "w"); c.px(8, 4, "k"); c.px(10, 4, "k"); c.row(6, 8, 10, "k")
    c.rect(4, 8, 5, 12, "w"); c.rect(13, 8, 14, 12, "w")


BONE_PAL = {"o": "#1a1418", "k": "#100a10", "w": "#ece6d8", "W": "#b8b0a0"}


def fox_spirit(c, f):
    """A fox spirit (Chinese tales; the Shanhaijing's nine-tailed fox): a red fox with several tails, foxfire at their
    tips."""
    s = STEP[f]
    ellipse(c, 11, 10, 7, 3.5, "r")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 12, 5 + k * 4 + d, 16, "R" if k % 2 else "r")
    poly(c, [(16, 6), (22, 8), (22, 11), (16, 11)], "r"); c.px(18, 7, "k"); c.px(22, 10, "k")
    c.px(17, 4, "r"); c.px(18, 5, "r"); c.row(10, 18, 21, "w")
    for k in range(3):                                                                   # several tails, foxfire tips
        for t in range(6):
            c.px(4 - t // 2, 9 - k * 2 - t // 3, "r")
        c.px(1, 6 - k * 2, "b")


FOX_PAL = {"o": "#1a0a04", "k": "#0a0402", "r": "#d86a2a", "R": "#a84a1a", "w": "#f0ece0", "b": "#60c0ff"}


def fire_beast(c, f):
    """A fire beast of the burning land under the ten suns: a heavy horned beast with a burning mane."""
    s = STEP[f]
    ellipse(c, 13, 12, 9, 5, "b")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(6 + k * 5 + d, 16, 7 + k * 5 + d, 21, "B")
    poly(c, [(20, 8), (26, 10), (26, 14), (20, 15)], "b"); c.px(23, 10, "y")
    c.px(21, 6, "h"); c.px(22, 5, "h"); c.px(24, 6, "h")
    for x in range(8, 21, 2):
        c.px(x, 6 + (x % 3), "f"); c.px(x, 5 + (x % 3), "y")                               # burning mane along its back


BEAST_PAL = {"o": "#140604", "b": "#6a2a1a", "B": "#4a1a10", "y": "#ffe060", "h": "#e8dcc0", "f": "#f07a20"}


def nian(c, step):
    """Nian (Chinese New Year folklore): the beast that comes at the year's turn, horned and maned, driven off by noise,
    firecrackers and the colour red."""
    ellipse(c, 30, 30, 20, 11, "b")
    for k, d in enumerate((-step, step, step, -step)):
        x = 14 + k * 10 + d
        c.rect(x, 38, x + 3, 50, "B")
        c.row(50, x - 1, x + 4, "k")
    ellipse(c, 50, 22, 9, 8, "b")
    for k in range(10):                                                                  # a great mane
        c.px(42 + k % 3, 12 + k * 2, "m"); c.px(43 + k % 3, 13 + k * 2, "m")
    poly(c, [(46, 14), (40, 4), (48, 12)], "h"); poly(c, [(54, 14), (60, 4), (55, 13)], "h")   # horns
    c.px(48, 20, "y"); c.px(53, 20, "y"); c.rect(46, 26, 56, 28, "k"); c.row(27, 47, 55, "w")
    c.rect(8, 26, 12, 30, "m")


NIAN_PAL = {"o": "#100804", "k": "#080402", "b": "#3a6a5a", "B": "#24483c", "m": "#c8a040", "h": "#e8dcc0",
            "y": "#ffd040", "w": "#f0ece0"}


def baigujing(form):
    """Baigujing, the White Bone Demon (Journey to the West, chapter 27): a demon of white bones who tricks the pilgrims
    three times, as a village girl, an old woman and an old man, before her true shape is shown."""
    def draw(c, step):
        for k, d in enumerate((-step, step)):
            c.rect(16 + k * 5 + d, 50, 18 + k * 5 + d, 54, "k")
        if form == "true":
            c.rect(19, 18, 21, 48, "w")
            for y in range(20, 40, 4):
                c.row(y, 13, 27, "W")                                                    # ribs
            ellipse(c, 20, 10, 7, 7, "w"); c.px(17, 9, "k"); c.px(23, 9, "k"); c.rect(18, 13, 22, 14, "k")
            for k in range(6):
                c.px(10 + k, 6 - k // 2, "w"); c.px(30 - k, 6 - k // 2, "w")              # bone horns
            poly(c, [(12, 20), (28, 20), (32, 50), (8, 50)], "v")
            c.rect(14, 22, 26, 46, "w")
            for y in range(24, 44, 4):
                c.row(y, 14, 26, "W")
            return
        robe = {"girl": "p", "old_woman": "g", "old_man": "n"}[form]
        poly(c, [(14, 20), (28, 20), (31, 50), (11, 50)], robe)
        c.rect(16, 8, 25, 18, "s"); c.px(22, 12, "k"); c.px(19, 12, "k")
        if form == "girl":
            c.rect(15, 4, 26, 8, "h"); c.rect(14, 7, 16, 24, "h"); c.rect(29, 24, 33, 30, "b")   # a basket of food
        elif form == "old_woman":
            c.rect(15, 4, 26, 8, "G"); c.rect(14, 7, 16, 16, "G")
            for k in range(30):
                c.px(31, 50 - k, "b")                                                    # a walking stick
        else:
            c.rect(15, 4, 26, 8, "G"); poly(c, [(17, 15), (25, 15), (23, 26), (19, 26)], "G")   # white beard
            for k in range(30):
                c.px(31, 50 - k, "b")
    return draw


BAIGU_PAL = {"o": "#100c10", "k": "#080608", "w": "#ece6d8", "W": "#b8b0a0", "v": "#4a3a5a", "p": "#d84a6a",
             "g": "#7a6a5a", "n": "#3a4a6a", "s": "#ecd0b0", "h": "#1a1410", "G": "#d8d4cc", "b": "#8a6a3a"}


def ten_suns(c, step):
    """The Ten Suns (the Huainanzi): in the time of Yao all ten suns rose together and scorched the earth, until Yi
    shot down nine. In each sun lived a crow (Shanhaijing). A cluster of blazing suns, a black crow in the brightest."""
    spots = [(36, 30, 12), (16, 18, 7), (56, 18, 7), (14, 42, 6), (58, 42, 6), (26, 8, 5), (46, 8, 5), (24, 52, 5),
             (48, 52, 5), (36, 6, 4)]
    for x, y, r in spots:
        ellipse(c, x, y + (step if r < 8 else 0), r + 2, r + 2, "y")
        ellipse(c, x, y + (step if r < 8 else 0), r, r, "u")
        ellipse(c, x, y + (step if r < 8 else 0), max(r - 3, 1), max(r - 3, 1), "w")
    poly(c, [(32, 28), (40, 28), (42, 32), (30, 32)], "k"); c.px(41, 29, "y")            # the crow in the sun
    poly(c, [(33, 30), (28, 25), (34, 29)], "k")


SUNS_PAL = {"o": "#4a1a04", "y": "#f07a20", "u": "#ffc840", "w": "#fff8d0", "k": "#141010"}


HOU_YI_DOC = ("Hou Yi (docs/BONUS_LEVELS_PLAN.md: the Realm of the Ten Suns' Hero). Built by tools/art/build_bonus.py on the "
              "shared body in tools/art/hero_kit.py. The Huainanzi: the archer Yi who shot down nine of the ten suns. An "
              "archer of ancient China in a red tunic over dark trousers, his hair in a topknot under a cap.")
HOU_YI_PAL = {"o": "#1e140c", "k": "#0e0a06", "s": "#e0b890", "S": "#b08868", "h": "#1a1410", "r": "#b02a2a",
              "R": "#7a1a1a", "a": "#2e2e3a", "u": "#d8b048", "n": "#3a2a20"}


def hou_yi(c, back_leg, front_leg):
    kit.far_arm(c)
    c.rect(11, 2, 15, 4, "a"); c.rect(12, 0, 14, 2, "h")                                # cap and topknot
    c.rect(11, 5, 16, 11, "s"); c.px(11, 6, "S"); c.px(15, 7, "k")
    c.rect(10, 4, 11, 10, "h"); c.rect(12, 10, 16, 12, "h")                             # short beard
    for y in range(13, 24):
        c.row(y, 9, 18, "r")
    c.rect(9, 13, 10, 23, "R"); c.row(19, 9, 18, "u")
    for y in range(14, 22):
        c.px(8 - (y % 2), y, "u")                                                        # quiver strap
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, lambda c, x0: (c.rect(x0, 26, x0 + 2, 30, "a"), c.row(31, x0, x0 + 3, "n")))


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_bonus.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("bone_demon", bone_demon, BONE_PAL, doc(bone_demon.__doc__), (18, 20), (9, 19), walk, folder="enemies")
    kit.build_boss("fox_spirit", fox_spirit, FOX_PAL, doc(fox_spirit.__doc__), (24, 18), (11, 17), walk, folder="enemies")
    kit.build_boss("fire_beast", fire_beast, BEAST_PAL, doc(fire_beast.__doc__), (28, 22), (13, 21), walk, folder="enemies")
    kit.build_boss("nian", nian, NIAN_PAL, doc(nian.__doc__), (62, 52), (30, 50), [0, 1, 0, -1, 0])
    kit.build_boss("baigujing", baigujing("true"), BAIGU_PAL, doc(baigujing.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    for form in ("girl", "old_woman", "old_man"):
        kit.build_boss("baigujing_" + form, baigujing(form), BAIGU_PAL, doc(baigujing.__doc__ + " Here, disguised."),
                       (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("ten_suns", ten_suns, SUNS_PAL, doc(ten_suns.__doc__), (72, 60), (36, 58), [0, 1, 0, -1, 0])
    kit.build("hou_yi", hou_yi, HOU_YI_PAL, HOU_YI_DOC, recolor=["r", "R"])
    print("wrote the Realm of the Ten Suns' art")
