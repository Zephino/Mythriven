# The Wild Green's art (Pack 7, docs/PACK_7_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (the Eddas, Herder, Goethe, the Scottish ballads, Ovid, Apollodorus, Hesiod, Pausanias).
# Run: python3 build_wild.py from tools/art/.
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


# --- Alfheim (Grimnismal 5; Volundarkvida; Gylfaginning 17; "Wid faerstice"; Herder 1778; Goethe 1782) ----------------

def light_elf(c, f):
    """A light elf (Gylfaginning 17: "fairer to look upon than the sun"): a slender shining figure in pale gold."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "g")
    poly(c, [(6, 8), (13, 8), (15, 19), (4, 19)], "w")
    ellipse(c, 9, 5, 3, 3, "s"); c.px(8, 5, "b"); c.px(10, 5, "b")
    c.rect(6, 1, 12, 3, "y"); c.px(5, 5, "s"); c.px(13, 5, "s")
    c.px(15, 9, "y"); c.px(16, 8, "y")


LIGHT_ELF_PAL = {"o": "#4a3a10", "w": "#f4ecc8", "g": "#c8b878", "s": "#f8e8d8", "b": "#3a6aa0", "y": "#f0d050"}


def elf_knight(c, f):
    """An elf-knight (the ballad of Lady Isabel and the Elf-Knight): a knight in green with a silver horn at his side."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    c.rect(5, 8, 14, 18, "v"); c.row(12, 5, 14, "V")
    ellipse(c, 9, 5, 3, 3, "s"); c.rect(6, 1, 12, 3, "h")
    c.rect(15, 0, 15, 17, "i"); c.rect(3, 13, 5, 15, "i")


ELF_KNIGHT_PAL = {"o": "#0a1008", "k": "#1a2414", "v": "#3a7a3a", "V": "#2a5a2a", "s": "#f0dcc8", "h": "#d8c060",
                  "i": "#c8ccd4"}


def elf_maiden(c, f):
    """An elf-maiden, one of the Erlking's daughters (Goethe: "my daughters shall dance with you at night"): a pale
    dancing girl in a misty white dress."""
    s = STEP[f]
    poly(c, [(5, 6), (9, 6), (12, 14 + s), (2, 14 - s)], "w")
    ellipse(c, 7, 3, 2.5, 2.5, "s"); c.rect(5, 0, 9, 1, "y")
    c.px(1, 6 + s, "w"); c.px(13, 6 - s, "w")


MAIDEN_PAL = {"o": "#2a3040", "w": "#e8eef8", "s": "#f8ecdc", "y": "#e8d870"}


def erlking_daughter(c, step):
    """The Erlking's daughter (Herder, 1778): she holds out her hand to Sir Oluf and asks him to dance; when he refuses,
    she strikes him over the heart. A tall pale elf-woman in shimmering white, a garland in her golden hair."""
    figure(c, step, "w", "s", "y")
    c.rect(16, 18, 26, 22, "W")
    for x in range(14, 28, 3):
        c.px(x, 2, "f")
    c.rect(29, 22, 33, 26, "s")


DAUGHTER_PAL = {"o": "#2a3040", "k": "#c8ccd8", "w": "#eef2fa", "W": "#c8d0e8", "s": "#f8ecdc", "y": "#f0d860",
                "f": "#a8e080"}


def volundr(c, step):
    """Volundr (Volundarkvida): the smith, "prince of elves", lamed by King Nidud, who forged himself wings and flew
    away laughing. A smith in a leather apron with great feathered wings, a hammer at his belt."""
    for side in (-1, 1):
        for k in range(9):
            x = 21 + side * (8 + k * 2)
            c.rect(min(x, x + side), 10 + k + step, max(x, x + side), 30 - k // 2, "f" if k % 2 else "F")
    figure(c, step, "a", "s", "h", x0=14, top=20, bottom=48)
    c.rect(17, 30, 25, 32, "b"); c.rect(26, 28, 28, 36, "i")


VOLUNDR_PAL = {"o": "#120c08", "k": "#2a1c10", "a": "#6a4a2a", "s": "#e0b890", "h": "#8a5a2a", "f": "#e8e4dc",
               "F": "#b8b4ac", "b": "#3a2818", "i": "#9aa0a8"}


def erlking(c, step):
    """The Erlking (Goethe, 1782): "the Erlking with crown and train", who woos the child riding through the night with
    his father. A tall grey figure, crowned, with a long trailing cloak and a misty beard."""
    poly(c, [(10, 18), (32, 18), (40, 56), (2, 56)], "g")
    poly(c, [(14, 18), (28, 18), (31, 50), (11, 50)], "G")
    c.rect(16, 4, 26, 16, "s"); c.px(19, 9, "e"); c.px(23, 9, "e")
    poly(c, [(15, 12), (27, 12), (24, 30), (18, 30)], "w")
    c.rect(15, 1, 27, 4, "y"); c.px(16, 0, "y"); c.px(21, 0, "y"); c.px(26, 0, "y")
    for k in range(6):
        c.px(34 + k, 22 - k, "s")                                                         # his beckoning hand


ERLKING_PAL = {"o": "#0a0c14", "g": "#4a5468", "G": "#5a6478", "s": "#d8dce4", "e": "#1a2030", "w": "#c8ccd4",
               "y": "#d8c060"}


# --- Elfame (Thomas the Rhymer, Child 37; Tam Lin, Child 39; Lady Isabel and the Elf-Knight, Child 4) -----------------

def fae_rider(c, f):
    """A rider of the fairy rade (Tam Lin: the fairies ride out at Halloween, on black, brown and milk-white steeds): a
    small fairy rider in green on a white horse."""
    s = STEP[f]
    ellipse(c, 11, 11, 7, 3.5, "w")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 13, 5 + k * 4 + d, 18, "W")
    poly(c, [(16, 7), (21, 9), (21, 11), (16, 11)], "w"); c.px(18, 8, "k")
    c.rect(9, 3, 13, 9, "v"); ellipse(c, 11, 2, 2, 2, "s"); c.rect(9, 0, 13, 0, "y")
    for k in range(4):
        c.px(3 - k // 2, 10 + k, "W")


RIDER_PAL = {"o": "#1a2018", "w": "#f0f0ea", "W": "#c8c8c0", "k": "#1a1a1a", "v": "#3a8a3a", "s": "#f0dcc8",
             "y": "#e8c840"}


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
            ellipse(c, 28, 30, 18, 12, "b")
            for k, d in enumerate((-step, step, step, -step)):
                c.rect(14 + k * 9 + d, 38, 18 + k * 9 + d, 48, "B")
            ellipse(c, 44, 22, 8, 7, "b"); c.px(47, 20, "k"); c.px(40, 15, "b"); c.px(47, 15, "b")
            return
        ellipse(c, 28, 30, 10, 18, "r")                                                   # a bar of burning iron
        c.rect(24, 12, 32, 48, "R"); c.rect(26, 16, 30, 44, "y")
        for k in range(6):
            c.px(22 + k * 3, 8 - (k + step) % 3, "y")
    return draw


TAMLIN_PAL = {"o": "#120808", "a": "#4a6a3a", "A": "#3a5a2a", "y": "#ffe060", "r": "#e8501a", "R": "#c83a10",
              "b": "#5a3a24", "B": "#3a2414", "k": "#100a08"}


def the_elf_knight(c, step):
    """The Elf-Knight (Child 4): he blew his horn, and Lady Isabel heard it and followed him; he meant to drown her as
    he had drowned seven king's daughters, but she lulled him to sleep and killed him with his own dagger. A knight in
    green with a long silver horn."""
    figure(c, step, "v", "s", "y")
    c.rect(16, 20, 26, 30, "V")
    for k in range(10):
        c.px(30 + k // 2, 18 + k, "i"); c.px(31 + k // 2, 18 + k, "I")                     # the horn
    c.rect(34, 27, 38, 30, "i")


ELF_KNIGHT_BOSS_PAL = dict(ELF_KNIGHT_PAL, i="#d8dce4", I="#a8acb4", y="#d8c060", V="#2a5a2a")


def queen_of_elfame(c, step):
    """The Queen of Elfame (Thomas the Rhymer): "her skirt was of the grass-green silk, her mantle of the velvet fine;
    at every tett of her horse's mane hung fifty silver bells and nine". A queen in grass-green with a silver crown and
    a branch of fruit."""
    figure(c, step, "v", "s", "h")
    c.rect(16, 18, 26, 26, "V")
    for x in range(12, 32, 3):
        c.px(x, 40, "i"); c.px(x + 1, 44, "i")                                             # silver bells
    c.rect(14, 1, 27, 3, "i"); c.px(15, 0, "i"); c.px(21, 0, "i"); c.px(26, 0, "i")
    c.rect(30, 22, 31, 34, "b"); c.px(32, 24, "r"); c.px(29, 28, "r"); c.px(32, 30, "r")


QUEEN_ELF_PAL = {"o": "#0a120a", "k": "#1a2a1a", "v": "#3a9a3a", "V": "#2a7a2a", "s": "#f4e0d0", "h": "#c87a3a",
                 "i": "#e0e4ec", "b": "#5a3a1a", "r": "#d02a3a"}


# --- Arcadia (Ovid, Metamorphoses 1.163-243; Apollodorus 2.5.3-6; Pausanias 8) ---------------------------------------

def centaur(c, f):
    """A centaur of Pholoe (Apollodorus 2.5.4: the centaurs who smelled Pholus' wine and attacked Heracles with rocks and
    pine trees): a horse's body and a man's chest, carrying a pine branch."""
    s = STEP[f]
    ellipse(c, 12, 16, 8, 4, "b")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(6 + k * 4 + d, 18, 6 + k * 4 + d, 24, "B")
    c.rect(17, 6, 21, 15, "s"); ellipse(c, 19, 4, 2.5, 2.5, "s"); c.rect(17, 1, 21, 2, "h"); c.px(20, 4, "k")
    c.rect(22, 0, 23, 14, "t"); c.px(21, 1, "p"); c.px(24, 2, "p"); c.px(21, 4, "p"); c.px(24, 5, "p")
    for k in range(4):
        c.px(3 - k // 2, 15 + k, "B")


CENTAUR_PAL = {"o": "#120c08", "b": "#8a5a34", "B": "#6a4024", "s": "#d8a880", "h": "#3a2414", "k": "#1a0e08",
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
    for shape in ("adder", "bear", "iron"):
        kit.build_boss("tam_lin_" + shape, tam_lin(shape), TAMLIN_PAL, doc(tam_lin.__doc__ + " Here, as %s." % shape),
                       (60, 52), (28, 50), [0, 1, 0, -1, 0])
    kit.build_boss("the_elf_knight", the_elf_knight, ELF_KNIGHT_BOSS_PAL, doc(the_elf_knight.__doc__), (42, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("queen_of_elfame", queen_of_elfame, QUEEN_ELF_PAL, doc(queen_of_elfame.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("centaur", centaur, CENTAUR_PAL, doc(centaur.__doc__), (26, 26), (12, 25), walk, folder="enemies")
    kit.build_boss("stymphalian_diver", stymphalian_diver, DIVER_PAL, doc(stymphalian_diver.__doc__), (20, 14), (10, 13), walk, folder="enemies")
    kit.build_boss("ceryneian_hind", ceryneian_hind, HIND_PAL, doc(ceryneian_hind.__doc__), (48, 48), (24, 46), [0, 1, 0, -1, 0])
    kit.build_boss("erymanthian_boar", erymanthian_boar, ERY_PAL, doc(erymanthian_boar.__doc__), (64, 50), (30, 48), [0, 1, 0, -1, 0])
    kit.build_boss("lycaon", lycaon(False), LYCAON_PAL, doc(lycaon.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("lycaon_wolf", lycaon(True), LYCAON_PAL, doc(lycaon.__doc__ + " Here, as the wolf."), (54, 50), (25, 48), [0, 1, 0, -1, 0])
    print("wrote the Wild Green's art")
