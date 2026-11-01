# The Wild Green's art (Pack 7, docs/PACK_7_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (the Eddas, Herder, Goethe, the Scottish ballads, Ovid, Apollodorus, Hesiod, Pausanias).
# Run: python3 build_wild.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly
from figure_kit import person
from build_frontiers import centaur as pelion_centaur

STEP = [0, -1, 0, 1, 0]


def figure(c, step, robe, skin, hair, legs="k", x0=14, top=18, bottom=50):
    """A standing figure in a long robe (shared by the boss figures)."""
    for k, d in enumerate((-step, step)):
        c.rect(x0 + 2 + k * 6 + d, bottom - 2, x0 + 4 + k * 6 + d, bottom + 4, legs)
    poly(c, [(x0, top), (x0 + 14, top), (x0 + 17, bottom), (x0 - 3, bottom)], robe)
    c.rect(x0 + 2, top - 12, x0 + 11, top - 2, skin)
    c.rect(x0, top - 15, x0 + 13, top - 11, hair)
    c.px(x0 + 4, top - 8, "o"); c.px(x0 + 9, top - 8, "o")


# --- Alfheim (Grimnismal 5; Volundarkvida; Gylfaginning 17; "Wid faerstice"; Herder 1778; Goethe 1782) ----------------

def light_elf(c, f):
    """A light elf (Gylfaginning 17: "fairer to look upon than the sun"): a slender shining elf with pointed ears and
    golden hair, in pale gold, with a bow for elf-shot."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 21, "g"); c.rect(x + d, 22, x + 2 + d, 22, "G")
    poly(c, [(6, 9), (13, 9), (15, 18), (4, 18)], "w"); poly(c, [(6, 9), (8, 9), (7, 18), (4, 18)], "W")
    c.row(13, 6, 13, "y")                                                                 # girdle
    ellipse(c, 9, 5, 3, 3.4, "s")
    poly(c, [(6, 5), (3, 2), (6, 7)], "s"); poly(c, [(12, 5), (15, 2), (12, 7)], "s")    # pointed ears
    ellipse(c, 9, 2, 3.4, 2, "y"); c.rect(5, 2, 6, 9, "y"); c.rect(12, 2, 13, 9, "y")   # golden hair
    c.px(8, 5, "b"); c.px(10, 5, "b")
    for k in range(9):                                                                   # the bow
        c.px(16 + (1 if 2 <= k <= 6 else 0), 6 + k, "G")
    c.rect(15, 6, 15, 14, "W")
    for x, y in ((2, 0), (17, 3), (0, 12)):
        c.px(x, y, "y")                                                                  # its shining


LIGHT_ELF_PAL = {"o": "#4a3a10", "w": "#f4ecc8", "W": "#d8ccA0", "g": "#c8b878", "G": "#8a7a40", "s": "#f8e8d8",
                 "b": "#3a6aa0", "y": "#f0d050"}


def elf_knight(c, f):
    """An elf-knight (the ballad of Lady Isabel and the Elf-Knight): a slim knight in green mail with pointed ears, a
    silver helm and sword, and a silver horn at his side."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 21, "V"); c.rect(x + d, 22, x + 2 + d, 22, "k")
    poly(c, [(5, 9), (14, 9), (15, 17), (4, 17)], "v")
    for y in (11, 13, 15):
        c.row(y, 5, 14, "V")                                                             # green mail
    ellipse(c, 9, 5, 3, 3.2, "s")
    poly(c, [(6, 5), (3, 3), (6, 7)], "s"); poly(c, [(12, 5), (15, 3), (12, 7)], "s")    # pointed ears
    ellipse(c, 9, 2, 3.4, 2.2, "i"); c.rect(9, 2, 9, 6, "I")                             # silver helm, nose-guard
    c.px(8, 5, "k"); c.px(10, 5, "k")
    c.rect(16, 1, 16, 16, "i"); c.rect(15, 13, 17, 13, "y")                              # sword
    poly(c, [(3, 12), (1, 15), (4, 16)], "i")                                            # horn at his side


ELF_KNIGHT_PAL = {"o": "#0a1008", "k": "#1a2414", "v": "#3a7a3a", "V": "#2a5a2a", "s": "#f0dcc8", "h": "#d8c060",
                  "i": "#c8ccd4", "I": "#8a8e96", "y": "#d8c060"}


def elf_maiden(c, f):
    """An elf-maiden, one of the Erlking's daughters (Goethe: "my daughters shall dance with you at night"): a pale
    dancing girl, her misty white dress and golden hair swirling."""
    s = STEP[f]
    poly(c, [(6, 7), (9, 7), (13 + s, 14), (1 - s, 14)], "w")                             # swirling dress
    c.px(3 - s, 13, "W"); c.px(7, 13, "W"); c.px(11 + s, 13, "W")
    ellipse(c, 7, 4, 2.4, 2.6, "s"); c.px(6, 4, "b"); c.px(8, 4, "b")
    ellipse(c, 7, 2, 2.8, 1.6, "y"); c.px(4 - s, 3, "y"); c.px(3 - s, 4, "y"); c.px(10 - s, 3, "y")   # hair swinging
    c.px(3, 7 - s, "s"); c.px(2, 6 - s, "s"); c.px(11, 7 + s, "s"); c.px(12, 6 + s, "s")  # arms raised in the dance


MAIDEN_PAL = {"o": "#2a3040", "w": "#e8eef8", "W": "#c0c8d8", "s": "#f8ecdc", "y": "#e8d870", "b": "#3a6aa0"}


def erlking_daughter(c, step):
    """The Erlking's daughter (Herder, 1778): she holds out her hand to Sir Oluf and asks him to dance; when he refuses,
    she strikes him over the heart. A tall pale elf-woman with long golden hair and a garland of leaves, in a
    shimmering white gown with a green girdle, holding out her hand."""
    person(c, step, hair="y", hair_d="Y", hair_style="long", garment="gown", robe="w", robe_d="W", robe_l="L",
           belt="g", ears=True, eye="e", arm_forward=True, boots="W")
    for x in range(15, 26, 2):
        c.px(x, 4, "f"); c.px(x + 1, 3, "g")                                             # garland of leaves
    for x, y in ((9, 30), (31, 40), (12, 46), (28, 24)):
        c.px(x, y, "L")                                                                  # shimmer


DAUGHTER_PAL = {"o": "#2a3040", "k": "#1a1a24", "e": "#4a7ab0", "m": "#d88a8a", "w": "#eef2fa", "W": "#c0c8e0",
                "L": "#ffffff", "s": "#f8ecdc", "S": "#d8c4b4", "y": "#f0d860", "Y": "#c8a840", "f": "#a8e080",
                "g": "#5a9a4a"}


def volundr(c, step):
    """Volundr (Volundarkvida): the smith, "prince of elves", lamed by King Nidud, who forged himself wings and flew
    away laughing. A strong young smith with brown hair and a short beard, a leather apron over his tunic, great
    feathered wings spread behind him, his hammer in his hand."""
    for side in (-1, 1):                                                                 # the forged wings
        for k in range(10):
            x = 20 + side * (6 + k * 2)
            y0 = 10 + k // 2 + step
            c.rect(min(x, x + side), y0, max(x, x + side), 34 - k, "f" if k % 2 else "F")
            c.px(x, y0, "i")                                                             # a metal rivet on each feather
    person(c, step, hair="h", hair_d="H", hair_style="short", beard="H", garment="tunic", robe="t", robe_d="T",
           legs="T", boots="b", belt="b", arm_forward=True)
    poly(c, [(16, 22), (24, 22), (25, 38), (15, 38)], "a"); c.row(22, 16, 24, "A")       # leather apron
    c.rect(33, 13, 34, 24, "w"); c.rect(31, 11, 36, 14, "i")                             # his hammer


VOLUNDR_PAL = {"o": "#120c08", "k": "#1a1008", "m": "#a85a4a", "a": "#6a4a2a", "A": "#4a3018", "s": "#e0b890",
               "S": "#b88a68", "h": "#8a5a2a", "H": "#5a3a1a", "t": "#3a5a6a", "T": "#2a4250", "f": "#e8e4dc",
               "F": "#b8b4ac", "b": "#3a2818", "i": "#9aa0a8", "w": "#5a3a1a"}


def erlking(c, step):
    """The Erlking (Goethe, 1782): "the Erlking with crown and train", who woos the child riding through the night with
    his father. A tall, gaunt old king: silver hair to his shoulders, a long full beard, heavy brows and hollow cheeks,
    a gold crown, broad shoulders under a fur-trimmed mantle, a grey-green robe with a long train trailing in mist,
    one hand reaching out to beckon."""
    poly(c, [(12, 26), (28, 26), (40, 56), (0, 56)], "G")                                # the long train behind him
    for x in range(4, 38, 5):
        c.px(x, 54, "w")                                                                 # mist at its hem
    person(c, step, cx=20, head_y=10, hair="w", hair_d="W", hair_style="shoulder", garment="robe",
           robe="g", robe_d="G", belt="y", crown="y", eye="e", arm_forward=True, boots="G",
           skin="s", skin_d="S")
    poly(c, [(10, 17), (30, 17), (31, 22), (9, 22)], "G")                                # broad shoulders: the mantle
    c.row(17, 11, 29, "W"); c.row(18, 10, 30, "w")                                       # its fur trim
    poly(c, [(15, 13), (25, 13), (25, 20), (23, 27), (20, 31), (17, 27), (15, 20)], "b")  # long full beard
    for x in (17, 20, 23):
        for y in range(15, 28, 2):
            if c.g[y][x] == "b":
                c.px(x, y, "B")
    c.row(13, 17, 23, "B"); c.px(17, 14, "B"); c.px(23, 14, "B")                         # moustache
    c.row(8, 16, 19, "B"); c.row(8, 21, 24, "B")                                         # heavy brows
    c.px(18, 10, "e"); c.px(22, 10, "e"); c.px(18, 9, "S"); c.px(22, 9, "S")             # deep-set eyes
    c.px(16, 11, "S"); c.px(24, 11, "S"); c.px(16, 12, "S"); c.px(24, 12, "S")           # hollow cheeks
    c.px(20, 11, "S"); c.px(20, 12, "S")                                                 # a long nose


ERLKING_PAL = {"b": "#b0b4bc", "B": "#80848e", "o": "#0a0c14", "k": "#1a1e28", "g": "#4a5a58", "G": "#323e3e", "s": "#d8c0ae", "S": "#9a8070",
               "e": "#7ab0d8", "w": "#d8dce4", "W": "#a8aeb8", "y": "#d8c060", "m": "#8a8a98"}


# --- Elfame (Thomas the Rhymer, Child 37; Tam Lin, Child 39; Lady Isabel and the Elf-Knight, Child 4) -----------------

def fae_rider(c, f):
    """A rider of the fairy rade (Tam Lin: the fairies ride out at Halloween, on black, brown and milk-white steeds): a
    small fairy rider in green on a milk-white horse, its bridle hung with silver bells."""
    s = STEP[f]
    for k, d in enumerate((-s, s, s, -s)):                                               # slim legs
        x = 5 + k * 4 + d
        c.rect(x, 13, x, 18, "W"); c.px(x, 19, "k")
    ellipse(c, 11, 11, 7, 3.2, "w")                                                      # body
    poly(c, [(15, 9), (19, 4), (22, 6), (21, 9), (17, 11)], "w"); c.px(20, 5, "k")       # neck and head
    for k in range(4):
        c.px(16 - k, 6 + k, "y")                                                         # silver bells on the mane
    for k in range(5):
        c.px(3 - k // 2, 10 + k, "W")                                                    # tail
    c.rect(9, 4, 13, 9, "v"); c.rect(10, 9, 11, 12, "V")                                 # rider in green
    ellipse(c, 11, 2, 2, 2, "s"); c.px(9, 2, "y"); c.rect(9, 0, 13, 0, "y")              # face, golden hair
    poly(c, [(9, 4), (5, 6), (6, 9), (9, 7)], "V")                                       # cloak streaming


RIDER_PAL = {"o": "#1a2018", "w": "#f0f0ea", "W": "#c8c8c0", "k": "#1a1a1a", "v": "#3a8a3a", "V": "#2a6a2a",
             "s": "#f0dcc8", "y": "#e8e4c8"}


def tam_lin(shape):
    """Tam Lin (Child 39): the young knight the fairies stole. On Halloween Janet pulled him from his milk-white steed
    and held him fast while they changed him in her arms: to an adder, a bear, a lion, a burning iron; she did not let
    go, and he was hers."""
    def draw(c, step):
        if shape == "adder":
            for k in range(14):
                ellipse(c, 6 + k * 3, 30 + round(5 * math.sin(k / 1.8 + step * 0.5)), 4, 3, "a" if k % 2 else "A")
            ellipse(c, 50, 28, 5, 4, "a"); c.px(52, 27, "y"); c.row(30, 54, 57, "r")
            return
        if shape == "bear":
            # A great brown bear on all fours: a hump over the shoulders, a big round head with small round ears.
            def leg(x, col, shade):
                poly(c, [(x - 3, 32), (x + 4, 32), (x + 4, 44), (x + 3, 48), (x - 3, 48), (x - 3, 42)], col)
                c.rect(x - 3, 47, x + 4, 49, shade)
                for t in range(3):
                    c.px(x - 2 + t * 2, 49, "w")                                         # claws
            leg(14 - step, "B", "D"); leg(38 + step, "B", "D")
            poly(c, [(6, 30), (12, 22), (24, 20), (34, 14), (44, 18), (48, 28), (44, 38), (30, 40), (14, 40),
                     (7, 36)], "b")                                                      # the body, humped at the shoulder
            ellipse(c, 12, 32, 7, 8, "b")
            poly(c, [(16, 37), (40, 37), (36, 40), (20, 40)], "B")
            for x, y in ((20, 24), (28, 20), (36, 18), (14, 28)):
                c.px(x, y, "L"); c.px(x + 1, y, "L")                                     # light on the fur
            ellipse(c, 48, 24, 7, 6.5, "b")                                              # big round head
            ellipse(c, 54, 27, 3.5, 2.8, "L"); c.px(57, 26, "k")                         # muzzle and nose
            ellipse(c, 44, 18, 2.2, 2.2, "b"); ellipse(c, 51, 17, 2.2, 2.2, "b")         # small round ears
            c.px(44, 18, "D"); c.px(51, 17, "D")
            c.px(50, 22, "k"); c.px(51, 22, "y")                                         # small eye
            leg(18 + step, "b", "B"); leg(42 - step, "b", "B")
            c.px(4, 30, "b"); c.px(5, 29, "b")                                           # stub of a tail
            return
        # A bar of red-hot iron, glowing white at its heart, sparks flying and the air shimmering above it.
        for k in range(3):
            for y in range(4, 14):
                c.px(22 + k * 6 + round(math.sin(y * 0.8 + k + step) * 1.2), y, "h")     # heat shimmer
        poly(c, [(20, 14), (36, 14), (38, 18), (38, 46), (36, 50), (20, 50), (18, 46), (18, 18)], "R")
        poly(c, [(21, 16), (35, 16), (36, 46), (34, 48), (22, 48), (20, 46)], "r")
        c.rect(24, 18, 32, 46, "y"); c.rect(26, 20, 30, 44, "w")                         # white-hot heart
        for y in (24, 32, 40):
            c.row(y, 21, 35, "R")                                                        # hammer marks
        for x, y in ((14, 18), (42, 22), (12, 34), (44, 38), (16, 10), (40, 8)):
            c.px(x, y - (step % 2), "y"); c.px(x + 1, y - 1 - (step % 2), "w")           # sparks
    return draw


TAMLIN_PAL = {"o": "#120808", "a": "#4a6a3a", "A": "#3a5a2a", "y": "#ffe060", "r": "#e8501a", "R": "#a82a08",
              "w": "#fff8e0", "h": "#f8c080", "b": "#6a4428", "B": "#4a2e18", "D": "#2e1c0e", "L": "#8a6040",
              "k": "#100a08"}


def the_elf_knight(c, step):
    """The Elf-Knight (Child 4): he blew his horn, and Lady Isabel heard it and followed him; he meant to drown her as
    he had drowned seven king's daughters, but she lulled him to sleep and killed him with his own dagger. A handsome
    fair-haired elf-knight with pointed ears, in green over silver mail, a long silver horn raised to his lips."""
    person(c, step, hair="y", hair_d="Y", hair_style="shoulder", garment="tunic", robe="v", robe_d="V",
           legs="i", boots="k", belt="b", ears=True, eye="e", arm_forward=True, cloak=("V", "D"))
    for y in range(23, 36, 2):
        c.row(y, 16, 24, "I")                                                            # silver mail under the green
    for k, (x, y) in enumerate(((22, 13), (24, 12), (26, 11), (28, 9), (29, 7))):        # the silver horn at his lips
        ellipse(c, x, y, 0.6 + k * 0.35, 0.6 + k * 0.35, "i")
    c.px(29, 6, "I"); c.px(30, 7, "I")
    c.rect(26, 26, 27, 34, "I"); c.px(26, 25, "y")                                       # dagger at his belt


ELF_KNIGHT_BOSS_PAL = {"o": "#0a1008", "k": "#1a2414", "m": "#c88a7a", "v": "#3a7a3a", "V": "#2a5a2a",
                       "D": "#1a3a1a", "s": "#f0dcc8", "S": "#c8b0a0", "y": "#d8c060", "Y": "#a8903a", "e": "#3a8a6a",
                       "i": "#d8dce4", "I": "#a8acb4", "b": "#5a3a1a"}


def queen_of_elfame(c, step):
    """The Queen of Elfame (Thomas the Rhymer): "her skirt was of the grass-green silk, her mantle of the velvet fine;
    at every tett of her horse's mane hung fifty silver bells and nine". A queen with long red-gold hair and a silver
    crown, in grass-green silk with a dark velvet mantle, silver bells at her girdle, an apple of her garden in her
    hand."""
    person(c, step, hair="h", hair_d="H", hair_style="long", garment="gown", robe="v", robe_d="V", robe_l="l",
           belt="i", crown="i", cloak=("u", "U"), eye="e", arm_forward=True, boots="V")
    for x in range(14, 27, 3):
        c.px(x, 29, "i"); c.px(x + 1, 30, "I")                                           # silver bells at her girdle
    ellipse(c, 35, 15, 2, 2, "r"); c.px(35, 13, "b"); c.px(34, 14, "R")                  # the apple


QUEEN_ELF_PAL = {"o": "#0a120a", "k": "#1a2a1a", "m": "#c86a6a", "e": "#3a8a5a", "v": "#3a9a3a", "V": "#2a7a2a",
                 "l": "#7ac87a", "u": "#3a1a4a", "U": "#24102e", "s": "#f4e0d0", "S": "#d0b8a8", "h": "#c87a3a",
                 "H": "#8a4a1a", "i": "#e0e4ec", "I": "#a8acb4", "b": "#5a3a1a", "r": "#d02a3a", "R": "#8a1a20"}


# --- Arcadia (Ovid, Metamorphoses 1.163-243; Apollodorus 2.5.3-6; Pausanias 8) ---------------------------------------

def centaur(c, f):
    """A centaur of Pholoe (Apollodorus 2.5.4: the centaurs who smelled Pholus' wine and attacked Heracles with rocks and
    pine trees): a horse's body with a man's bearded chest, arms and head, a pine branch raised to strike (drawn on the
    Mount Pelion centaur body)."""
    def pine(c, r):
        c.rect(r(42), r(0), r(43), r(16), "t")                                           # the pine branch
        for y in range(r(0), r(10), 2):
            c.px(r(41), y, "p"); c.px(r(44), y + 1, "p")
    pelion_centaur(c, STEP[f], 0.6, pine)


CENTAUR_PAL = {"o": "#120c08", "h": "#5a3a1e", "b": "#8a5a34", "H": "#3a2412", "s": "#d8a880", "S": "#a8744a",
               "t": "#5a3a1a", "p": "#3a6a3a"}


def stymphalian_diver(c, f):
    """A Stymphalian bird (Apollodorus 2.5.6: the man-eating birds of the Stymphalian lake in Arcadia, with bronze
    feathers): a dark bird with bronze wings, diving."""
    up = f % 2
    poly(c, [(9, 7), (1, 2 if up else 10), (5, 9)], "z"); poly(c, [(11, 7), (19, 2 if up else 10), (15, 9)], "z")
    ellipse(c, 10, 8, 3, 3, "k"); poly(c, [(12, 6), (16, 8), (12, 9)], "y"); c.px(11, 7, "r")


DIVER_PAL = {"o": "#1a0e04", "z": "#b07a3a", "k": "#3a2a1a", "y": "#d8a040", "r": "#e83a2a"}


def ceryneian_hind(c, step):
    """The Ceryneian Hind (Apollodorus 2.5.3; Pindar: golden-horned): a swift hind with antlers of gold and hooves of
    bronze, sacred to Artemis."""
    ellipse(c, 24, 26, 15, 7, "b"); ellipse(c, 22, 23, 10, 3, "B")
    for k, d in enumerate((-step, step, step, -step)):
        x = 12 + k * 8 + d * 2
        c.rect(x, 30, x + 1, 44, "b"); c.rect(x, 44, x + 1, 46, "z")                       # bronze hooves
    poly(c, [(36, 18), (44, 20), (44, 24), (36, 26)], "b"); c.px(40, 20, "k")
    for k in range(7):
        c.px(37 - k // 2, 17 - k, "y"); c.px(40 + k // 3, 16 - k, "y")                      # golden antlers
    c.px(34, 12, "y"); c.px(43, 11, "y"); c.rect(8, 22, 10, 24, "w")


HIND_PAL = {"o": "#1a0e04", "b": "#c88a4a", "B": "#a86a34", "k": "#1a0e08", "y": "#f0c840", "z": "#b07a3a",
            "w": "#f0e8d8"}


def erymanthian_boar(c, step):
    """The Erymanthian Boar (Apollodorus 2.5.4): the huge wild boar of Mount Erymanthus, which Heracles drove out of a
    thicket into the deep snow and snared. A massive dark boar, snow on its bristles."""
    ellipse(c, 28, 28, 22, 12, "b")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 10 + d, 36, 16 + k * 10 + d, 48, "B")
    poly(c, [(46, 20), (60, 24), (60, 32), (46, 36)], "b"); c.rect(58, 26, 61, 30, "B"); c.px(51, 24, "k")
    poly(c, [(56, 30), (60, 36), (57, 30)], "w")
    for x in range(10, 46, 2):
        c.px(x, 16 + abs(x - 28) // 5, "B"); c.px(x, 15 + abs(x - 28) // 5, "s" if x % 6 == 0 else "B")


ERY_PAL = {"o": "#0e0806", "b": "#4a3a2e", "B": "#2e241c", "k": "#e83a2a", "w": "#f0ece0", "s": "#f4f8fc"}


def lycaon(wolf):
    """Lycaon (Ovid, Metamorphoses 1.163-243): the savage king of Arcadia who served Zeus human flesh to test him; Zeus
    struck his house with lightning, and as he fled into the fields he became a wolf, still grey, still savage-eyed."""
    def draw(c, step):
        if wolf:
            ellipse(c, 24, 30, 16, 8, "g")
            for k, d in enumerate((-step, step, step, -step)):
                c.rect(11 + k * 8 + d, 34, 13 + k * 8 + d, 48, "G")
            poly(c, [(36, 20), (50, 22), (50, 28), (36, 30)], "g"); c.px(41, 22, "y"); c.row(28, 46, 50, "k")
            c.px(37, 17, "g"); c.px(38, 16, "g"); c.rect(16, 24, 30, 25, "r")             # a torn royal cloak
            for k in range(8):
                c.px(8 - k // 2, 28 + k // 3, "G")
            return
        figure(c, step, "r", "s", "h")
        c.rect(16, 18, 26, 30, "R"); c.px(18, 9, "y"); c.px(23, 9, "y")
        c.rect(14, 1, 27, 3, "y"); c.rect(16, 13, 25, 16, "h")                              # crown and beard
    return draw


LYCAON_PAL = {"o": "#0e0806", "k": "#1a1010", "r": "#7a1a2a", "R": "#5a1020", "s": "#d8a880", "h": "#4a4440",
              "y": "#e8c040", "g": "#6a645e", "G": "#4a4640"}


# --- Lerna (Hesiod, Theogony 313-318; Apollodorus 2.5.2, 3.4.1; Pausanias 2.37) ---------------------------------------

def spartoi(c, f):
    """One of the Spartoi (Apollodorus 3.4.1: armed men who sprang up from the dragon's teeth Cadmus sowed): a warrior
    rising half out of the earth, bronze-helmed, with spear and shield."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "d")
    c.rect(5, 8, 14, 18, "z"); c.row(12, 5, 14, "Z")
    ellipse(c, 9, 5, 3, 3, "s"); c.rect(6, 1, 12, 4, "z"); c.rect(8, 0, 10, 0, "r")
    ellipse(c, 4, 13, 3, 4, "z"); c.px(4, 13, "Z")
    c.rect(16, 0, 16, 20, "b")
    c.row(21, 2, 16, "d"); c.row(22, 3, 15, "D")                                          # the earth he rises from


SPARTOI_PAL = {"o": "#120c06", "z": "#b0803a", "Z": "#8a5a24", "s": "#c8a080", "r": "#c83a2a", "b": "#6a4a2a",
               "d": "#6a5034", "D": "#4a3824"}


def karkinos(c, step):
    """Karkinos (Apollodorus 2.5.2): the giant crab Hera sent from the marsh to bite Heracles' foot as he fought the
    Hydra. A great red-brown crab, claws raised."""
    ellipse(c, 30, 30, 18, 11, "r"); ellipse(c, 30, 28, 14, 7, "R")
    c.px(25, 20, "k"); c.px(35, 20, "k"); c.rect(25, 18, 25, 20, "r"); c.rect(35, 18, 35, 20, "r")
    for side in (-1, 1):
        for k in range(4):
            x = 30 + side * (14 + k * 2)
            c.rect(min(x, x + side * 4), 34 + k * 2 + (step if k % 2 else -step), max(x, x + side * 4), 35 + k * 2, "R")
        cx = 30 + side * 22
        for t in range(9):
            c.rect(30 + side * (12 + t), 26 - t, 30 + side * (12 + t) + 1, 27 - t, "R")      # the arm
        ellipse(c, cx, 16, 6, 5, "r"); poly(c, [(cx, 12), (cx + side * 6, 6), (cx + side * 2, 13)], "R")


KARKINOS_PAL = {"o": "#120604", "r": "#b0442a", "R": "#80301a", "k": "#100808"}


def echion(c, step):
    """Echion (Apollodorus 3.4.1): one of the five Spartoi left standing after the sown men killed each other; he
    married Cadmus' daughter Agave. A bronze-armoured warrior, earth still on his greaves."""
    figure(c, step, "z", "s", "Z", legs="d")
    c.rect(16, 18, 26, 32, "Z"); c.row(24, 16, 26, "z")
    c.rect(14, 1, 27, 6, "z"); c.rect(19, 0, 22, 1, "r")
    ellipse(c, 8, 30, 6, 8, "z"); c.px(8, 30, "Z")
    c.rect(32, 4, 32, 50, "b")


ECHION_PAL = dict(SPARTOI_PAL, k="#1a1008")


def hydra(c, step):
    """The Lernaean Hydra (Hesiod, Theogony 313; Apollodorus 2.5.2): the water-serpent of the Lerna marsh with nine
    heads, the middle one immortal; cut one off and two grow back."""
    ellipse(c, 34, 46, 20, 10, "g"); ellipse(c, 34, 44, 16, 7, "G")
    for k in range(9):
        a = math.pi * (0.15 + 0.7 * k / 8)
        for t in range(18 if k != 4 else 22):
            x = round(34 - math.cos(a) * t * 1.4 + math.sin(t / 3 + k + step * 0.5))
            y = round(42 - math.sin(a) * t * 1.6)
            c.rect(x - 1, y - 1, x + 1, y + 1, "g" if t % 4 else "G")
        L = 18 if k != 4 else 22
        hx, hy = round(34 - math.cos(a) * L * 1.4), round(42 - math.sin(a) * L * 1.6)
        ellipse(c, hx, hy, 3, 2.5, "y" if k == 4 else "g"); c.px(hx + 1, hy - 1, "r")


HYDRA_PAL = {"o": "#08100a", "g": "#3a7a4a", "G": "#2a5a3a", "y": "#d8c050", "r": "#e83a2a"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_wild.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("light_elf", light_elf, LIGHT_ELF_PAL, doc(light_elf.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("elf_knight", elf_knight, ELF_KNIGHT_PAL, doc(elf_knight.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("elf_maiden", elf_maiden, MAIDEN_PAL, doc(elf_maiden.__doc__), (16, 16), (7, 15), walk, folder="enemies")
    kit.build_boss("erlking_daughter", erlking_daughter, DAUGHTER_PAL, doc(erlking_daughter.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("volundr", volundr, VOLUNDR_PAL, doc(volundr.__doc__), (44, 54), (21, 52), [0, 1, 0, -1, 0])
    kit.build_boss("erlking", erlking, ERLKING_PAL, doc(erlking.__doc__), (44, 58), (21, 56), [0, 1, 0, -1, 0])
    kit.build_boss("fae_rider", fae_rider, RIDER_PAL, doc(fae_rider.__doc__), (24, 20), (11, 19), walk, folder="enemies")
    # His plain picture (the banter portrait and the codex) is his first shape.
    kit.build_boss("tam_lin", tam_lin("adder"), TAMLIN_PAL, doc(tam_lin.__doc__), (60, 52), (28, 50), [0, 1, 0, -1, 0])
    for shape in ("adder", "bear", "iron"):
        kit.build_boss("tam_lin_" + shape, tam_lin(shape), TAMLIN_PAL, doc(tam_lin.__doc__ + " Here, as %s." % shape),
                       (60, 52), (28, 50), [0, 1, 0, -1, 0])
    kit.build_boss("the_elf_knight", the_elf_knight, ELF_KNIGHT_BOSS_PAL, doc(the_elf_knight.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("queen_of_elfame", queen_of_elfame, QUEEN_ELF_PAL, doc(queen_of_elfame.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("centaur", centaur, CENTAUR_PAL, doc(centaur.__doc__), (28, 28), (13, 27), walk, folder="enemies")
    kit.build_boss("stymphalian_diver", stymphalian_diver, DIVER_PAL, doc(stymphalian_diver.__doc__), (20, 14), (10, 13), walk, folder="enemies")
    kit.build_boss("ceryneian_hind", ceryneian_hind, HIND_PAL, doc(ceryneian_hind.__doc__), (48, 48), (24, 46), [0, 1, 0, -1, 0])
    kit.build_boss("erymanthian_boar", erymanthian_boar, ERY_PAL, doc(erymanthian_boar.__doc__), (64, 50), (30, 48), [0, 1, 0, -1, 0])
    kit.build_boss("lycaon", lycaon(False), LYCAON_PAL, doc(lycaon.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("lycaon_wolf", lycaon(True), LYCAON_PAL, doc(lycaon.__doc__ + " Here, as the wolf."), (54, 50), (25, 48), [0, 1, 0, -1, 0])
    kit.build_boss("spartoi", spartoi, SPARTOI_PAL, doc(spartoi.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("karkinos", karkinos, KARKINOS_PAL, doc(karkinos.__doc__), (62, 48), (30, 46), [0, 1, 0, -1, 0])
    kit.build_boss("echion", echion, ECHION_PAL, doc(echion.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("hydra", hydra, HYDRA_PAL, doc(hydra.__doc__), (70, 60), (34, 58), [0, 1, 0, -1, 0])
    print("wrote the Wild Green's art")
