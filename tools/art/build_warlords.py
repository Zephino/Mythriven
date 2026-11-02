# Warlords' art (Pack 8, docs/PACK_8_PLAN.md; docs/ART_RULES.md), one realm at a time. Ghorvast is the game's own;
# the rest is drawn only from the old texts (Apollodorus, Plutarch, Ovid, Snorri, Geoffrey of Monmouth, Malory).
# Run: python3 build_warlords.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly
from figure_kit import person
from build_gothic import raven as raven_body, empusa as gothic_beast

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
    """An orc of Ghorvast (the game's own; the word is old English "orcneas"): a broad, hunched, grey-green warrior with
    a heavy jaw and tusks, a thick brow and small yellow eyes, in crude leather and iron."""
    def draw(c, f):
        s = STEP[f]
        big = kind == "brute"
        w = 3 if big else 0
        H = 24 + w
        for x, d in ((6, -s), (12 + w, s)):                                              # short bowed legs
            c.rect(x + d, H - 7, x + 2 + d, H - 2, "L"); c.rect(x - 1 + d, H - 2, x + 3 + d, H - 1, "k")
        poly(c, [(4, 9), (16 + w, 9), (17 + w, H - 7), (3, H - 7)], "l")                 # broad hunched body
        c.row(H - 10, 3, 17 + w, "b"); c.px(10 + w // 2, H - 10, "r")                    # belt
        c.rect(4, 11, 5, H - 9, "L")
        ellipse(c, 3, 10, 2.5, 2, "i"); ellipse(c, 17 + w, 10, 2.5, 2, "i")              # iron shoulder plates
        ellipse(c, 10 + w // 2, 6, 4 + w / 2, 3.5, "g")                                  # big head, low between the shoulders
        c.rect(7, 7, 13 + w, 9, "g")                                                     # heavy jaw
        c.row(4, 7, 13 + w, "G")                                                         # thick brow
        c.px(8, 5, "r"); c.px(12 + w, 5, "r")                                            # small yellow eyes
        c.px(8, 8, "w"); c.px(12 + w, 8, "w"); c.px(8, 7, "w"); c.px(12 + w, 7, "w")    # tusks
        c.px(5, 4, "g"); c.px(15 + w, 4, "g")                                            # pointed ears
        if kind == "archer":
            for k in range(13):
                c.px(19 + round(math.sin(k / 12 * math.pi) * 2), 3 + k, "b")             # bow
            c.rect(18, 3, 18, 15, "W"); c.px(17, 9, "g")
        elif kind == "brute":
            c.rect(22, 3, 23, 22, "b"); c.rect(20, 0, 26, 5, "i"); c.row(5, 20, 26, "I")   # great maul
            c.px(21, 12, "g"); c.px(21, 13, "g")
        else:
            c.rect(18, 4, 19, 15, "i"); c.rect(17, 14, 20, 15, "b"); c.px(18, 3, "I")    # cleaver-sword
            c.px(17, 12, "g")
    return draw


ORC_PAL = {"o": "#0e0c08", "k": "#1e1a14", "l": "#5a4430", "L": "#3e2e20", "g": "#7a8a68", "G": "#5a6a4a",
           "r": "#e8b030", "w": "#ece4d0", "b": "#5a3a1a", "i": "#8a8e96", "I": "#5a5e66", "W": "#c8c4bc"}


def carrion_crow(c, f):
    """A carrion crow over the walls of Ghorvast: a black crow flying, wedge tail, heavy beak, wings beating (drawn on
    the raven body)."""
    raven_body(c, f)


CROW_PAL = {"o": "#2a2a30", "k": "#121216", "K": "#22222a", "B": "#3a3a40", "w": "#c8c8d0"}


def orc_head(c, cx, hy, helm=None):
    """Turns the figure's head into an orc's: a heavy jaw, tusks jutting up from the lower lip, a thick brow, small
    glowing eyes, a flat nose and pointed ears. helm: None (a topknot), "horned" (black iron with horns)."""
    ellipse(c, cx, hy + 1, 5.5, 5.5, "g")
    c.rect(cx - 5, hy + 2, cx + 5, hy + 6, "g"); c.row(hy + 6, cx - 4, cx + 4, "G")      # heavy jaw
    c.row(hy - 2, cx - 4, cx + 4, "G"); c.row(hy - 1, cx - 4, cx + 4, "G")               # thick brow
    c.px(cx - 2, hy, "r"); c.px(cx + 2, hy, "r")                                         # small glowing eyes
    c.px(cx - 1, hy + 2, "G"); c.px(cx + 1, hy + 2, "G")                                 # flat nose
    c.row(hy + 4, cx - 2, cx + 2, "k")                                                   # mouth
    c.rect(cx - 3, hy + 2, cx - 3, hy + 4, "w"); c.rect(cx + 3, hy + 2, cx + 3, hy + 4, "w")   # tusks
    poly(c, [(cx - 5, hy), (cx - 9, hy - 3), (cx - 5, hy + 2)], "g")                     # pointed ears
    poly(c, [(cx + 5, hy), (cx + 9, hy - 3), (cx + 5, hy + 2)], "g")
    if helm == "horned":
        ellipse(c, cx, hy - 4, 6.5, 3.5, "a"); c.row(hy - 2, cx - 6, cx + 6, "A")
        poly(c, [(cx - 5, hy - 4), (cx - 10, hy - 11), (cx - 8, hy - 4)], "w")
        poly(c, [(cx + 5, hy - 4), (cx + 10, hy - 11), (cx + 8, hy - 4)], "w")
    else:
        ellipse(c, cx, hy - 5, 4.5, 2, "G"); c.rect(cx - 1, hy - 9, cx + 1, hy - 6, "k")  # shaved head, topknot
        c.px(cx, hy - 10, "k")


def orc_shoulders(c, cx, top, col, shade, spikes=False):
    """Great broad shoulders with iron plates over them."""
    poly(c, [(cx - 12, top + 1), (cx + 12, top + 1), (cx + 9, top + 8), (cx - 9, top + 8)], col)
    ellipse(c, cx - 10, top + 2, 4, 3, "i"); ellipse(c, cx + 10, top + 2, 4, 3, "i")
    c.row(top + 4, cx - 13, cx - 7, "I"); c.row(top + 4, cx + 7, cx + 13, "I")
    if spikes:
        for x in (cx - 12, cx - 9, cx + 9, cx + 12):
            c.px(x, top - 2, "w"); c.px(x, top - 1, "w")


def war_drummer(c, step):
    """The War Drummer (the game's own): a huge orc with a topknot and tusks, in a leather jerkin, beating a great war
    drum slung before him, his sticks rising and falling."""
    person(c, step, cx=21, skin="g", skin_d="G", hair_style="none", garment="tunic", robe="l", robe_d="L",
           legs="L", boots="k", belt="b")
    orc_shoulders(c, 21, 17, "l", "L")
    orc_head(c, 21, 10)
    ellipse(c, 21, 36, 12, 8, "d"); ellipse(c, 21, 32, 12, 4, "D"); ellipse(c, 21, 32, 9, 2.5, "E")   # the drum
    for x in range(10, 33, 4):
        c.rect(x, 34, x, 42, "b")
    c.row(28, 11, 31, "b")                                                               # its strap
    for side, d in ((-1, step), (1, -step)):
        x = 21 + side * 9
        c.rect(x, 22 + d * 3, x + side, 30 + d * 3, "g")                                 # thick arm
        c.rect(x + side * 2, 18 + d * 3, x + side * 3, 26 + d * 3, "b")                  # drumstick
        ellipse(c, x + side * 2, 17 + d * 3, 1.5, 1.5, "D")


DRUM_PAL = dict(ORC_PAL, d="#8a5a34", D="#d8c8a8", E="#c8b898", a="#2a2a30", A="#3a3a44", s="#7a8a68",
                S="#5a6a4a", m="#1e1a14")


def pit_champion(c, step):
    """The Pit Champion (the game's own): a scarred, bare-chested orc fighter with an iron collar, a topknot and tusks,
    a leather kilt, an axe in each hand."""
    person(c, step, cx=22, skin="g", skin_d="G", hair_style="none", garment="tunic", robe="g", robe_d="G",
           legs="L", boots="k", belt="b")
    orc_shoulders(c, 22, 17, "g", "G")
    poly(c, [(16, 31), (28, 31), (30, 40), (14, 40)], "l"); c.rect(16, 33, 16, 39, "L"); c.rect(24, 33, 24, 39, "L")   # kilt
    c.row(22, 17, 26, "G"); c.row(26, 18, 26, "G")                                       # muscles
    c.px(18, 21, "s"); c.px(19, 22, "s"); c.px(20, 23, "s"); c.px(24, 25, "s"); c.px(25, 26, "s")   # scars
    c.rect(17, 16, 27, 17, "i")                                                          # iron collar
    orc_head(c, 22, 10)
    for side in (-1, 1):
        x = 22 + side * 13
        c.rect(x, 18, x, 38, "b")
        poly(c, [(x, 18), (x + side * 6, 15), (x + side * 7, 20), (x + side * 6, 25), (x, 23)], "i")
        c.row(20, min(x, x + side * 6), max(x, x + side * 6), "I")
        ellipse(c, x - side, 30, 2, 2, "g")                                              # fist


CHAMP_PAL = dict(ORC_PAL, s="#b05a4a", a="#2a2a30", A="#3a3a44", m="#1e1a14")


def warlord(c, step):
    """The Warlord (the game's own): a great orc in black iron armour with spiked shoulder-plates, a horned helm, a red
    war-cloak and a heavy cleaver."""
    person(c, step, cx=21, skin="g", skin_d="G", hair_style="none", garment="tunic", robe="a", robe_d="A",
           legs="A", boots="k", belt="b", cloak=("c", "C"))
    orc_shoulders(c, 21, 17, "a", "A", spikes=True)
    for y in (22, 26, 30):
        c.row(y, 15, 27, "A")                                                            # plates of the armour
    c.px(21, 30, "r")
    orc_head(c, 21, 10, helm="horned")
    c.rect(35, 12, 36, 42, "b"); poly(c, [(36, 12), (44, 12), (45, 26), (36, 24)], "i")  # the heavy cleaver
    c.row(13, 37, 43, "I"); ellipse(c, 34, 30, 2, 2, "g")


WARLORD_PAL = dict(ORC_PAL, a="#2a2a30", A="#3a3a44", c="#8a1a1a", C="#5a1010", m="#1e1a14")


# --- Knossos (Apollodorus 2.5.7, 3.1.3-4, Epitome 1.7-9; Plutarch, Theseus 15-19; Odyssey 11.568) ---------------------

def cretan_guard(c, f):
    """A guard of Minos' palace (Plutarch, Theseus 19: Minos' general Taurus and his men): a Cretan soldier with long
    dark hair, a white kilt with a red border, a tall figure-of-eight shield of hide and a spear."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 16, x + 1 + d, 21, "s"); c.rect(x + d, 22, x + 2 + d, 22, "b")
    c.rect(6, 8, 13, 13, "s"); c.px(9, 10, "S")                                          # bare chest
    poly(c, [(6, 13), (13, 13), (14, 17), (5, 17)], "w"); c.row(17, 5, 14, "r")          # kilt, red border
    c.row(13, 6, 13, "y")                                                                # belt
    ellipse(c, 9, 4, 3, 3.2, "s"); c.px(10, 4, "k")
    ellipse(c, 9, 1, 3.4, 1.8, "h"); c.rect(5, 1, 7, 11, "h")                            # long dark hair
    ellipse(c, 3, 8, 3, 3.5, "d"); ellipse(c, 3, 15, 3, 3.5, "d")                        # figure-of-eight shield
    c.px(3, 8, "D"); c.px(3, 15, "D"); c.px(2, 10, "D"); c.px(4, 13, "D")                # dappled hide
    c.rect(16, 0, 16, 20, "b"); c.px(16, 0, "i"); c.px(15, 9, "s")


GUARD_PAL = {"o": "#120c08", "k": "#1a1008", "s": "#c88a5a", "S": "#a06a3e", "w": "#ece4d0", "r": "#b03a2a",
             "h": "#1a1410", "d": "#c8a878", "D": "#6a4a2a", "b": "#6a4a2a", "y": "#e0b040", "i": "#c8ccd4"}


def young_bull(c, f):
    """A young Cretan bull (the bulls of the bull-leaping games): a lean dappled bull with long horns, head lowered."""
    s = STEP[f]
    for k, (x, d) in enumerate(((5, -s), (8, s), (14, s), (17, -s))):                    # slim legs and hooves
        c.rect(x + d, 11, x + d, 14, "W"); c.px(x + d, 15, "k")
    ellipse(c, 10, 9, 7, 3.2, "w"); ellipse(c, 13, 7, 4, 2.5, "w")                       # body, shoulder hump
    for x, y in ((6, 8), (10, 10), (12, 7), (8, 9)):
        c.px(x, y, "b")                                                                  # dapples
    poly(c, [(16, 7), (20, 9), (21, 12), (18, 12), (16, 10)], "w"); c.px(21, 11, "p")    # lowered head, muzzle
    c.px(18, 8, "k")
    c.px(17, 6, "h"); c.px(16, 5, "h"); c.px(16, 4, "h"); c.px(19, 6, "h"); c.px(20, 5, "h"); c.px(21, 4, "h")   # long horns
    c.px(3, 8, "W"); c.px(2, 9, "W"); c.px(2, 10, "b")                                   # tail


YOUNG_BULL_PAL = {"o": "#120a06", "w": "#e8dcc8", "W": "#b8a890", "b": "#4a3020", "k": "#100808", "h": "#f0e8d8",
                  "p": "#c8988a"}


def cretan_bull(c, step):
    """The Cretan Bull (Apollodorus 2.5.7): the white bull Poseidon sent from the sea, which Minos would not sacrifice;
    Poseidon maddened it, and it ravaged Crete until Heracles caught it. A great white bull, head lowered to charge, a
    red maddened eye, sea-spray about it (drawn on the bull body of Empusa)."""
    gothic_beast("bull")(c, step)


CRETAN_BULL_PAL = {"o": "#2a2218", "k": "#f0ece4", "K": "#c0b8a8", "b": "#f0ece4", "B": "#c0b8a8", "h": "#e8d8b0",
                   "H": "#b8a888", "y": "#e83a2a", "l": "#ffffff", "g": "#9ad0f0", "s": "#f0ece4", "v": "#f0ece4"}


def minos(c, step):
    """Minos (Odyssey 11.568: "Minos, the glorious son of Zeus, a golden sceptre in his hand, giving judgement to the
    dead"): a stern king with a dark curling beard and long dark hair, a gold crown, a deep blue robe with a border of
    Cretan spirals, a purple cloak, and a golden sceptre."""
    person(c, step, cx=20, hair="h", hair_d="H", hair_style="shoulder", beard="h", garment="robe", robe="r",
           robe_d="R", belt="y", crown="y", cloak=("p", "P"), arm_forward=True, boots="k")
    for x in range(14, 27, 3):
        c.px(x, 50, "y"); c.px(x + 1, 51, "y")                                           # spiral border at the hem
    for y in range(13, 19, 2):
        c.px(18, y, "H"); c.px(22, y, "H")                                               # curls in the beard
    c.rect(35, 6, 35, 48, "y"); ellipse(c, 35, 5, 2, 2, "y"); c.px(35, 5, "Y")           # the golden sceptre


MINOS_PAL = {"o": "#120808", "k": "#1a1010", "m": "#8a4a3a", "r": "#2a3a7a", "R": "#1a2a5a", "s": "#c88a5a",
             "S": "#a06a3e", "h": "#2a1a10", "H": "#140c06", "y": "#e8c040", "Y": "#fff0a0", "p": "#5a2a5a",
             "P": "#3a1a3a"}


def asterion(c, step):
    """Asterion, the Minotaur (Apollodorus 3.1.4: "he had the face of a bull, but the rest of him was human"): a huge,
    heavily muscled man with a bull's head, long curved horns and red eyes, naked but for a dark kilt, in the
    Labyrinth's dark."""
    for k, d in enumerate((-step, step)):                                                # thick legs, bare feet
        x = 17 + k * 9 + d
        poly(c, [(x, 42), (x + 5, 42), (x + 5, 54), (x, 54)], "s"); c.rect(x, 52, x + 5, 55, "S")
    poly(c, [(13, 22), (37, 22), (33, 38), (17, 38)], "s")                               # massive chest
    c.row(28, 18, 32, "S"); c.rect(25, 24, 25, 37, "S")                                  # chest and belly muscles
    c.row(32, 19, 31, "S"); c.row(35, 20, 30, "S")
    poly(c, [(16, 38), (34, 38), (36, 46), (14, 46)], "l"); c.row(38, 16, 34, "y")       # dark kilt, gold belt
    for side in (-1, 1):                                                                 # great arms
        x = 25 + side * 14
        poly(c, [(x - 3, 21), (x + 3, 21), (x + 3 * side + 1, 36), (x - 2 + side * 2, 36)], "s")
        c.px(x, 26, "S"); c.px(x, 27, "S")
        ellipse(c, x + side * 2, 38, 3, 3, "s")
    ellipse(c, 25, 21, 8, 3, "b")                                                        # thick bull's neck
    ellipse(c, 25, 13, 7, 7, "b")                                                        # the bull's head
    ellipse(c, 25, 18, 4.5, 3.5, "B"); c.px(23, 19, "k"); c.px(27, 19, "k")              # muzzle and nostrils
    c.px(21, 11, "r"); c.px(29, 11, "r")                                                 # red eyes
    c.row(9, 20, 30, "B")                                                                # brow
    poly(c, [(19, 9), (12, 7), (8, 2), (10, 1), (14, 5), (20, 7)], "h")                  # long curved horns
    poly(c, [(31, 9), (38, 7), (42, 2), (40, 1), (36, 5), (30, 7)], "h")
    poly(c, [(17, 11), (14, 12), (17, 14)], "b"); poly(c, [(33, 11), (36, 12), (33, 14)], "b")   # ears


ASTERION_PAL = {"o": "#0e0806", "s": "#a86a44", "S": "#7a4a2a", "l": "#3a2418", "b": "#3a2418", "B": "#5a3a28",
                "r": "#e83a2a", "h": "#e8dcc0", "k": "#0e0806", "y": "#c8a040"}


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


# --- Logres (Geoffrey of Monmouth 6.17-8.2; Malory, Le Morte d'Arthur 1.19-20, 4.14) ----------------------------------

def man_at_arms(c, f):
    """A man-at-arms of Vortigern's Britain (Geoffrey of Monmouth): a soldier in a mail shirt and conical helm with a
    round shield and a spear."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    c.rect(5, 8, 14, 18, "m"); c.row(12, 5, 14, "M"); c.rect(5, 16, 14, 18, "r")
    ellipse(c, 9, 5, 3, 3, "s"); poly(c, [(6, 3), (9, -1), (12, 3)], "M"); c.rect(9, 3, 9, 6, "M")
    ellipse(c, 4, 13, 3, 4, "r"); c.px(4, 13, "y")
    c.rect(16, 0, 16, 20, "b")


MAN_AT_ARMS_PAL = {"o": "#0e0c0a", "k": "#2a2420", "m": "#8a8e96", "M": "#5a5e66", "r": "#7a2a2a", "s": "#d8b090",
                   "y": "#e0b040", "b": "#6a4a2a"}


def questing_beast(c, step):
    """The Questing Beast (Malory 1.19): "the head like a serpent's head, and a body like a leopard, buttocks like a
    lion, and footed like an hart", with a noise in its belly like thirty couple of hounds questing."""
    ellipse(c, 30, 30, 16, 8, "y")
    for x, y in ((20, 27), (26, 31), (32, 27), (38, 31), (24, 34), (34, 34)):
        c.px(x, y, "k"); c.px(x + 1, y, "k")                                                     # leopard spots
    ellipse(c, 16, 30, 7, 8, "l")                                                                # lion's haunches
    for k, d in enumerate((-step, step, step, -step)):
        x = 12 + k * 9 + d * 2
        c.rect(x, 34, x + 1, 46, "y" if k > 1 else "l"); c.rect(x, 46, x + 1, 48, "k")          # hart's feet
    for t in range(14):
        c.rect(44 + t // 2, 26 - t, 46 + t // 2, 28 - t, "g")                                    # serpent neck
    ellipse(c, 52, 11, 5, 3, "g"); c.px(54, 10, "r"); c.row(12, 55, 58, "r")
    for k in range(6):
        c.px(8 - k, 26 + k, "l")


QUESTING_PAL = {"o": "#120a04", "y": "#d8a848", "k": "#2a1a0a", "l": "#b07a3a", "g": "#4a7a4a", "r": "#e83a2a"}


def morgan_le_fay(c, step):
    """Morgan le Fay (Malory 4.14): King Arthur's sister, a great sorceress, who stole Excalibur's scabbard and threw it
    into a lake. A queen in dark green and black, holding the jewelled scabbard."""
    figure(c, step, "v", "s", "h")
    c.rect(16, 18, 26, 26, "V"); c.rect(13, 6, 15, 24, "h"); c.rect(26, 6, 28, 24, "h")
    c.rect(14, 1, 27, 3, "y")
    c.rect(31, 18, 33, 40, "r"); c.px(32, 22, "y"); c.px(32, 28, "w"); c.px(32, 34, "y")            # the scabbard


MORGAN_PAL = {"o": "#0a0a0c", "k": "#14121a", "v": "#1e4a2e", "V": "#14301e", "s": "#ecdcd0", "h": "#1a1418",
              "y": "#e0b840", "r": "#6a1a24", "w": "#d8e8f0"}


def vortigern(c, step):
    """Vortigern (Geoffrey of Monmouth 6.6-8.2): the usurper king of the Britons, who built a tower on Snowdon that
    fell down every night, and was burned in another tower by Aurelius. A crowned king in a red cloak, grim and grey."""
    figure(c, step, "r", "s", "h")
    c.rect(16, 18, 26, 30, "m"); c.row(24, 16, 26, "M")
    c.rect(16, 13, 25, 17, "h")
    c.rect(14, 1, 27, 3, "y"); c.px(15, 0, "y"); c.px(21, 0, "y"); c.px(26, 0, "y")
    c.rect(33, 10, 34, 44, "M"); c.rect(31, 10, 36, 11, "y")


VORTIGERN_PAL = {"o": "#0e0a08", "k": "#1a1410", "r": "#8a2020", "s": "#d8b090", "h": "#7a7470", "m": "#7a7e86",
                 "M": "#5a5e66", "y": "#d8b040"}


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
    kit.build_boss("man_at_arms", man_at_arms, MAN_AT_ARMS_PAL, doc(man_at_arms.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("questing_beast", questing_beast, QUESTING_PAL, doc(questing_beast.__doc__), (62, 52), (30, 50), [0, 1, 0, -1, 0])
    kit.build_boss("morgan_le_fay", morgan_le_fay, MORGAN_PAL, doc(morgan_le_fay.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("vortigern", vortigern, VORTIGERN_PAL, doc(vortigern.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    print("wrote the Warlords' art")
