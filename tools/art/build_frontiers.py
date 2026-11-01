# Wild Frontiers' art (Pack 13, docs/PACK_13_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (Ovid; Apollodorus; Ibsen's Peer Gynt, 1867; Asbjørnsen and Moe; "The City of Brass" in the Nights, Burton
# 1885, without its jinn; Andersen's "The Little Mermaid", 1837), never later versions.
# Run: python3 build_frontiers.py from tools/art/.
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


def centaur(c, step, k=1.0, held=None):
    """A centaur (shared): a horse's body with a man's chest, arms and head where the horse's neck would be."""
    def r(v):
        return int(round(v * k))
    for i, d in enumerate((-step, step, step, -step)):
        c.rect(r(6 + i * 7) + d, r(30), r(8 + i * 7) + d, r(42), "h")
    ellipse(c, r(20), r(28), 16 * k, 6 * k, "b")
    for i in range(r(8)):
        c.px(r(4) - i // 2, r(26) + i, "H")
    poly(c, [(r(29), r(11)), (r(39), r(11)), (r(37), r(26)), (r(31), r(26))], "s")
    c.row(r(18), r(31), r(37), "S"); c.px(r(34), r(14), "S")
    c.rect(r(27), r(12), r(29), r(22), "s")
    c.rect(r(32), r(1), r(37), r(9), "s"); c.rect(r(31), r(0), r(38), r(2), "H")
    c.rect(r(32), r(7), r(37), r(11), "H")
    c.px(r(33), r(4), "o"); c.px(r(36), r(4), "o")
    c.rect(r(39), r(12), r(42), r(14), "s")
    if held:
        held(c, r)


# --- Mount Pelion (Ovid, Met. 9.98-133, 12.210-535; Apollodorus 2.5.4, 2.7.6) ---------------------------------------

def centaur_raider(c, f):
    """A centaur raider (Ovid, Met. 12: the wild centaurs of Pelion): a small galloping centaur with a club."""
    centaur(c, STEP[f], 0.5, lambda c, r: c.rect(r(42), r(4), r(44), r(16), "w"))


def centaur_slinger(c, f):
    """A centaur slinger (Ovid, Met. 12: centaurs hurling rocks): a small centaur with a stone raised to throw."""
    centaur(c, STEP[f], 0.5, lambda c, r: ellipse(c, r(42), r(9), 1.5, 1.5, "g"))


CENTAUR_PAL = {"S": "#a8744a", "o": "#120e0a", "h": "#5a3a1e", "b": "#8a6040", "H": "#3a2412", "s": "#c8946a", "w": "#6a4a2a",
               "g": "#9a9a92", "r": "#8a1a3a", "y": "#e8c040", "f": "#f08a2a"}


def eurytus(c, step):
    """Eurytus (Ovid, Met. 12.219-240: "wildest of the wild centaurs", drunk at the wedding): a big red-faced centaur
    with a great embossed wine-bowl held up in both hands, wine slopping over."""
    def bowl(c, r):
        ellipse(c, r(40), r(4), 6, 3, "y"); c.rect(r(36), r(3), r(44), r(4), "r")
    centaur(c, step, 1.0, bowl)


def rhoetus(c, step):
    """Rhoetus (Ovid, Met. 12.271-290: he snatched a burning brand from the altar): a centaur swinging a blazing log."""
    def brand(c, r):
        c.rect(r(42), r(0), r(44), r(14), "w")
        ellipse(c, r(43), r(0), 3, 3, "f"); c.px(r(43), r(0), "y")
    centaur(c, step, 1.0, brand)


def nessus(c, step):
    """Nessus (Ovid, Met. 9.98-133: the ferryman centaur of the river Evenus): a dark, powerful centaur, his flank
    stained with his venomed blood, an arrow standing in his back."""
    def arrow(c, r):
        c.rect(r(22), r(14), r(23), r(24), "w"); c.px(r(22), r(13), "g"); c.px(r(23), r(13), "g")
        for x, y in ((18, 28), (22, 30), (26, 27)):
            c.px(r(x), r(y), "r")
    centaur(c, step, 1.0, arrow)


NESSUS_PAL = dict(CENTAUR_PAL, h="#2a1e14", b="#4a3626", H="#1a120a", s="#a8785a", S="#7a5a3a", r="#5a8a2a")


# --- Dovrefjell (Ibsen, Peer Gynt, 1867; Asbjørnsen and Moe, 1841-44) -----------------------------------------------

def dovre_troll(c, f):
    """A Dovre troll (Peer Gynt: the Dovre-King's courtiers): a lumpy green-grey troll with a long nose and a cow's
    tail."""
    s = STEP[f]
    for x, d in ((6, -s), (12, s)):
        c.rect(x + d, 18, x + 2 + d, 22, "k")
    ellipse(c, 10, 13, 6, 6, "g")
    ellipse(c, 10, 5, 4, 4, "g"); c.rect(13, 5, 15, 7, "G")
    c.px(9, 4, "k"); c.px(12, 4, "k")
    for i in range(5):
        c.px(4 - i // 2, 15 + i, "G")
    c.px(2, 20, "k")


DOVRE_TROLL_PAL = {"o": "#10140e", "k": "#1a1e14", "g": "#6a7a5a", "G": "#4a5a3a"}


def troll_brat(c, f):
    """A troll brat (Peer Gynt: the Dovre-King's troll children): a small, big-headed troll child, pinching."""
    up = f % 2
    ellipse(c, 6, 7 - up, 4, 3.5, "g"); c.rect(9, 7 - up, 10, 8 - up, "G")
    c.px(5, 6 - up, "k"); c.px(8, 6 - up, "k")
    c.rect(4, 10, 8, 12, "G")


TROLL_BRAT_PAL = DOVRE_TROLL_PAL


def hedal_trolls(c, step):
    """The Hedal Trolls (Asbjørnsen and Moe: three trolls with one eye between them): three huge, grey, eyeless trolls
    shoulder to shoulder, groping with their hands."""
    for k, d in enumerate((-step, step, -step, step, -step, step)):
        c.rect(6 + k * 8 + d, 44, 9 + k * 8 + d, 54, "G")
    for k, x in enumerate((12, 28, 44)):
        ellipse(c, x, 32, 9, 13, "g" if k % 2 == 0 else "G")
        ellipse(c, x, 14, 6, 6, "g")
        c.rect(x + 3, 15, x + 6, 17, "G")
        c.row(12, x - 3, x + 2, "k")
    c.rect(0, 24, 3, 36, "g"); c.rect(53, 24, 56, 36, "g")


HEDAL_PAL = {"o": "#10120e", "k": "#2a2e24", "g": "#7a8070", "G": "#5a6050"}


def great_boyg(c, step):
    """The Great Bøyg (Peer Gynt, Act II: the shapeless thing in the dark that says "Go round about"): a vast, slimy,
    coiling darkness with no face at all."""
    for k in range(9):
        a = k / 9 * math.tau + step * 0.1
        ellipse(c, 30 + round(16 * math.cos(a)), 30 + round(12 * math.sin(a)), 9, 8, "k" if k % 2 else "K")
    ellipse(c, 30, 30, 14, 11, "K")
    for x, y in ((22, 22), (36, 26), (28, 36), (40, 34)):
        c.px(x, y, "s")


BOYG_PAL = {"o": "#05060a", "k": "#14181c", "K": "#20262a", "s": "#5a6a5a"}


def mountain_king(c, step):
    """The Mountain King (Peer Gynt: the old Dovre-King): an old troll king, huge-nosed, white-bearded, crowned, his
    cow's tail hanging below a royal cloak."""
    figure(c, step, "r", "g", "w")
    poly(c, [(16, 15), (27, 15), (24, 30), (19, 30)], "w")
    c.rect(24, 10, 28, 12, "G")
    for x in range(14, 28, 4):
        c.rect(x, 0, x + 1, 3, "y")
    c.row(3, 14, 28, "y")
    for i in range(8):
        c.px(10 - i // 2, 44 + i, "G")


MOUNTAIN_KING_PAL = {"o": "#10140e", "k": "#1a1e14", "r": "#6a2a2a", "g": "#7a8a6a", "G": "#5a6a4a", "w": "#e8e4dc",
                     "y": "#e8c040"}


# --- The City of Brass ("The City of Brass", the Nights; Burton, 1885; no jinn) --------------------------------------

def brass_soldier(c, f):
    """A brass soldier (the tale's brass figures): a stiff automaton of polished brass with a round shield."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 22, "B")
    c.rect(6, 8, 13, 17, "y"); c.row(12, 6, 13, "B")
    c.rect(7, 2, 12, 7, "y"); c.rect(8, 4, 11, 4, "k")
    ellipse(c, 4, 12, 3, 4, "B"); c.px(4, 12, "y")
    c.rect(15, 4, 15, 18, "s")


BRASS_SOLDIER_PAL = {"o": "#2a1a08", "k": "#1a1008", "y": "#d8a840", "B": "#9a6a1a", "s": "#c8ccd4"}


def locust(c, f):
    """A locust (the desert road): a long green-brown grasshopper with whirring wings."""
    up = f % 2
    c.rect(2, 6, 11, 7, "g"); c.px(12, 6, "k")
    poly(c, [(4, 6), (10, 2 + up), (11, 5)], "w")
    c.px(4, 9, "G"); c.px(7, 9, "G"); c.px(3, 10, "G")


LOCUST_PAL = {"o": "#1a1408", "g": "#8a8a3a", "G": "#5a5a2a", "w": "#d8d4b0", "k": "#1a1408"}


def wall_watcher(c, step):
    """The Watcher on the Wall ("The City of Brass": the vision that beckoned each man who climbed the wall): a tall,
    veiled figure of shimmering light standing on a brass battlement, one hand raised to beckon."""
    c.rect(4, 42, 38, 52, "B"); c.row(42, 4, 38, "y")
    for x in range(4, 38, 8):
        c.rect(x, 38, x + 4, 42, "B")
    poly(c, [(15, 10), (27, 10), (31, 40), (11, 40)], "w")
    ellipse(c, 21, 7, 5, 5, "W")
    c.rect(28, 4 - step, 30, 14, "W")
    for x, y in ((14, 20), (26, 26), (18, 34)):
        c.px(x, y, "y")


WATCHER_PAL = {"o": "#4a3a20", "w": "#f4ecd8", "W": "#fff8e8", "y": "#e8c040", "B": "#9a6a1a"}


def queens_guardians(c, step):
    """The Queen's Guardians ("The City of Brass": two automatons with swords beside the dead queen's bier): two
    figures, one of steel and one of brass, each with a raised sword."""
    for k, (body, dark) in enumerate((("s", "S"), ("y", "B"))):
        x0 = 4 + k * 22
        for i, d in enumerate((-step, step)):
            c.rect(x0 + 3 + i * 6 + d, 44, x0 + 5 + i * 6 + d, 54, dark)
        c.rect(x0, 18, x0 + 14, 44, body); c.row(30, x0, x0 + 14, dark)
        c.rect(x0 + 3, 6, x0 + 11, 16, body); c.rect(x0 + 4, 10, x0 + 10, 10, "k")
        c.rect(x0 + 16, 2, x0 + 17, 30, "W"); c.rect(x0 + 14, 28, x0 + 19, 29, dark)


GUARDIANS_PAL = {"o": "#1a1408", "k": "#1a1008", "s": "#a8acb4", "S": "#6a6e76", "y": "#d8a840", "B": "#9a6a1a",
                 "W": "#e8ecf4"}


def brass_horseman(c, step):
    """The Brass Horseman ("The City of Brass": the horseman of brass on a pillar, spear in hand, who points the way):
    a rider and horse all of brass, the spear levelled."""
    for i, d in enumerate((-step, step, step, -step)):
        c.rect(14 + i * 8 + d, 36, 16 + i * 8 + d, 50, "B")
    ellipse(c, 28, 32, 16, 7, "y")
    poly(c, [(40, 30), (48, 18), (54, 22), (46, 34)], "y"); c.px(51, 21, "k")
    c.rect(24, 12, 32, 28, "y"); c.rect(25, 4, 31, 11, "y"); c.rect(24, 2, 32, 4, "B")
    c.px(27, 7, "k"); c.px(30, 7, "k")
    c.rect(18, 16, 60, 17, "B"); poly(c, [(60, 14), (64, 16), (60, 19)], "s")
    for i in range(6):
        c.px(12 - i, 30 + i, "B")


HORSEMAN_PAL = {"o": "#2a1a08", "k": "#1a1008", "y": "#d8a840", "B": "#9a6a1a", "s": "#c8ccd4"}


# --- The Sea King's Hall (Andersen, "The Little Mermaid", 1837) -------------------------------------------------------

def water_snake(c, f):
    """A water snake (Andersen: the Sea Witch's fat water-snakes, "her little chickens"): a thick, slimy green-brown
    snake, swimming."""
    for k in range(9):
        ellipse(c, 2 + k * 2, 12 + round(3 * math.sin(k / 1.6 + f * 0.8)), 2.5, 2, "g" if k % 2 else "G")
    ellipse(c, 19, 12 + round(3 * math.sin(8 / 1.6 + f * 0.8)), 3, 2.5, "g"); c.px(20, 11 + round(3 * math.sin(8 / 1.6 + f * 0.8)), "y")


WATER_SNAKE_PAL = {"o": "#0e140a", "g": "#5a6a3a", "G": "#3a4a2a", "y": "#e8d040"}


def silver_fish(c, f):
    """A silver fish (Andersen: the little fish that swim in and out of the Sea King's windows)."""
    up = f % 2
    ellipse(c, 6, 5, 4, 2.5, "s"); poly(c, [(2, 5), (0, 2 + up), (0, 8 - up)], "S")
    c.px(8, 4, "k"); c.row(6, 4, 8, "w")


SILVER_FISH_PAL = {"o": "#2a3a4a", "s": "#c8d8e8", "S": "#8aa0b8", "w": "#ffffff", "k": "#1a2a3a"}


def polyp_wood(c, step):
    """The Polyp Wood (Andersen: the polyps round the Sea Witch's house, half animal and half plant, like
    hundred-headed snakes, holding the white bones of drowned men): a thicket of slimy, writhing green arms rising from
    the sea floor."""
    ellipse(c, 30, 48, 24, 6, "G")
    for k in range(7):
        x0 = 8 + k * 7
        for y in range(48, 10 + (k % 3) * 6, -1):
            x = x0 + round(3 * math.sin(y / 5.0 + k + step * 0.5))
            c.rect(x, y, x + 2, y, "g" if (y + k) % 4 else "G")
        c.px(x0 + round(3 * math.sin(11 / 5.0 + k)), 10 + (k % 3) * 6, "p")
    c.rect(20, 44, 30, 45, "w"); c.px(19, 43, "w"); c.px(31, 43, "w")


POLYP_PAL = {"o": "#0e140a", "g": "#6a8a4a", "G": "#4a6a3a", "p": "#c87a8a", "w": "#e8e4dc"}


def witch_snakes(c, step):
    """The Witch's Water Snakes (Andersen: the Sea Witch's "little chickens"): a knot of great fat water-snakes,
    coiled and rearing."""
    for k in range(14):
        a = k / 14 * math.tau
        ellipse(c, 28 + round(16 * math.cos(a)), 34 + round(9 * math.sin(a)), 5, 4, "g" if k % 2 else "G")
    for x, h in ((18, 14), (36, 8)):
        for y in range(34, h, -1):
            c.rect(x + round(2 * math.sin(y / 3.0 + step)), y, x + 3 + round(2 * math.sin(y / 3.0 + step)), y, "g")
        ellipse(c, x + 2, h, 4, 3, "G"); c.px(x + 3, h - 1, "y")


SNAKES_PAL = WATER_SNAKE_PAL


def sea_witch(c, step):
    """The Sea Witch (Andersen, 1837; not any film): a squat old witch on the sea floor, her hair like sea-weed, a fat
    water-snake round her shoulders and a toad on her hand."""
    figure(c, step, "d", "s", "g")
    c.rect(10, 4, 14, 26, "g"); c.rect(29, 4, 33, 26, "g")
    for k in range(10):
        c.px(12 + k * 2, 20 + round(2 * math.sin(k)), "G")
    ellipse(c, 34, 32, 3, 2, "t"); c.px(35, 31, "y")
    c.px(18, 10, "y"); c.px(23, 10, "y")


SEA_WITCH_PAL = {"o": "#0a0e10", "k": "#141a1e", "d": "#2a3a3a", "s": "#8aa098", "g": "#3a5a2a", "G": "#5a6a3a",
                 "t": "#6a7a3a", "y": "#e8d040"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_frontiers.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("centaur_raider", centaur_raider, CENTAUR_PAL, doc(centaur_raider.__doc__), (24, 24), (12, 23), walk, folder="enemies")
    kit.build_boss("centaur_slinger", centaur_slinger, CENTAUR_PAL, doc(centaur_slinger.__doc__), (24, 24), (12, 23), walk, folder="enemies")
    kit.build_boss("eurytus", eurytus, CENTAUR_PAL, doc(eurytus.__doc__), (48, 46), (22, 44), [0, 1, 0, -1, 0])
    kit.build_boss("rhoetus", rhoetus, CENTAUR_PAL, doc(rhoetus.__doc__), (48, 46), (22, 44), [0, 1, 0, -1, 0])
    kit.build_boss("nessus", nessus, NESSUS_PAL, doc(nessus.__doc__), (48, 46), (22, 44), [0, 1, 0, -1, 0])
    kit.build_boss("dovre_troll", dovre_troll, DOVRE_TROLL_PAL, doc(dovre_troll.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("troll_brat", troll_brat, TROLL_BRAT_PAL, doc(troll_brat.__doc__), (13, 13), (6, 12), walk, folder="enemies")
    kit.build_boss("hedal_trolls", hedal_trolls, HEDAL_PAL, doc(hedal_trolls.__doc__), (58, 58), (28, 56), [0, 1, 0, -1, 0])
    kit.build_boss("great_boyg", great_boyg, BOYG_PAL, doc(great_boyg.__doc__), (60, 52), (30, 50), [0, 1, 0, -1, 0])
    kit.build_boss("mountain_king", mountain_king, MOUNTAIN_KING_PAL, doc(mountain_king.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("brass_soldier", brass_soldier, BRASS_SOLDIER_PAL, doc(brass_soldier.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("locust", locust, LOCUST_PAL, doc(locust.__doc__), (14, 12), (7, 11), walk, folder="enemies")
    kit.build_boss("wall_watcher", wall_watcher, WATCHER_PAL, doc(wall_watcher.__doc__), (42, 54), (21, 52), [0, 1, 0, -1, 0])
    kit.build_boss("queens_guardians", queens_guardians, GUARDIANS_PAL, doc(queens_guardians.__doc__), (48, 56), (24, 54), [0, 1, 0, -1, 0])
    kit.build_boss("brass_horseman", brass_horseman, HORSEMAN_PAL, doc(brass_horseman.__doc__), (66, 52), (32, 50), [0, 1, 0, -1, 0])
    kit.build_boss("water_snake", water_snake, WATER_SNAKE_PAL, doc(water_snake.__doc__), (24, 20), (12, 19), walk, folder="enemies")
    kit.build_boss("silver_fish", silver_fish, SILVER_FISH_PAL, doc(silver_fish.__doc__), (12, 10), (6, 9), walk, folder="enemies")
    kit.build_boss("polyp_wood", polyp_wood, POLYP_PAL, doc(polyp_wood.__doc__), (60, 54), (30, 52), [0, 1, 0, -1, 0])
    kit.build_boss("witch_snakes", witch_snakes, SNAKES_PAL, doc(witch_snakes.__doc__), (56, 46), (28, 44), [0, 1, 0, -1, 0])
    kit.build_boss("sea_witch", sea_witch, SEA_WITCH_PAL, doc(sea_witch.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    print("wrote Wild Frontiers' art")
