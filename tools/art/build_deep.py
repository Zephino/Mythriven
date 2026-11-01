# The Deep Below's art (Pack 6, docs/PACK_6_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (the Eddas, Snorri, the Nibelungenlied, Ovid, Herodotus); Mycendra is the game's own.
# Run: python3 build_deep.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


# --- Nidavellir (Voluspa 37; Reginsmal; Skaldskaparmal 35, 39) --------------------------------------------------------

def dwarf_body(c, step, ox=0, tunic="t", tunic_d="T", skin="s", skin_d="S", hair="h", hair_d="H", boots="B",
               belt="b", hat=None, hat_col="c", hat_d="C", beard_long=34, braid_rings=True):
    """The shared dwarf body for the dwarf bosses: short, broad and strong, a big head with a big nose, bushy brows and
    deep-set eyes, a long flowing beard over the chest, a belted tunic, big hands and heavy boots. `hat`: "hood" (a
    pointed hood), "helm" (an iron cap with a nose-guard), "crown", or None (bare, with a fringe of hair)."""
    X = lambda x: x + ox
    for k, d in enumerate((-step, step)):                                                # short legs, heavy boots
        c.rect(X(14 + k * 8) + d, 37, X(18 + k * 8) + d, 42, tunic_d)
        c.rect(X(13 + k * 8) + d, 42, X(19 + k * 8) + d, 46, boots); c.row(42, X(13 + k * 8) + d, X(19 + k * 8) + d, "k")
    poly(c, [(X(9), 20), (X(31), 20), (X(33), 30), (X(30), 38), (X(10), 38), (X(7), 30)], tunic)   # broad body
    poly(c, [(X(9), 20), (X(13), 20), (X(12), 38), (X(10), 38), (X(7), 30)], tunic_d)
    c.row(33, X(9), X(31), belt); c.rect(X(19), 32, X(21), 34, "y")                       # belt and buckle
    poly(c, [(X(7), 21), (X(10), 21), (X(9), 32), (X(5), 32)], tunic_d)                   # the far arm
    ellipse(c, X(6), 34, 2.5, 2.5, skin_d)                                               # big fist
    ellipse(c, X(20), 12, 7.5, 7.5, skin)                                                # the head
    c.px(X(12), 12, skin_d); c.px(X(12), 13, skin_d); c.px(X(28), 12, skin_d)            # ears
    poly(c, [(X(13), 15), (X(27), 15), (X(28), 22), (X(25), beard_long - 6), (X(20), beard_long),
             (X(15), beard_long - 6), (X(12), 22)], hair)                                # the beard, over the chest
    for x in (X(15), X(18), X(22), X(25)):
        for y in range(18, beard_long - 4, 2):
            if c.g[y][x] == hair:
                c.px(x, y, hair_d)                                                       # strands
    if braid_rings:
        c.px(X(17), beard_long - 6, "y"); c.px(X(23), beard_long - 6, "y")               # rings in the braids
    c.rect(X(15), 15, X(25), 16, hair_d)                                                 # moustache
    ellipse(c, X(21), 13, 2, 2.2, skin_d); c.px(X(21), 12, skin)                         # the big nose
    c.row(9, X(15), X(18), hair); c.row(9, X(22), X(25), hair)                           # bushy brows
    c.px(X(17), 11, "k"); c.px(X(23), 11, "k"); c.px(X(16), 11, skin_d); c.px(X(24), 11, skin_d)   # deep-set eyes
    if hat == "hood":
        poly(c, [(X(11), 9), (X(20), 0), (X(26), 1), (X(29), 9), (X(28), 12), (X(12), 12)], hat_col)
        poly(c, [(X(20), 0), (X(14), -1), (X(11), 3), (X(16), 4)], hat_col)              # the hood's point, falling back
        c.row(9, X(12), X(28), hat_d)
        c.row(9, X(15), X(18), hair); c.row(9, X(22), X(25), hair)
    elif hat == "helm":
        ellipse(c, X(20), 6, 8.5, 5, hat_col); c.rect(X(11), 6, X(29), 8, hat_col)
        c.row(8, X(11), X(29), hat_d); c.rect(X(20), 8, X(21), 12, hat_d)                # rim and nose-guard
        c.px(X(17), 3, "w")
    elif hat == "crown":
        c.rect(X(13), 3, X(27), 6, "y")
        for x in (X(13), X(17), X(20), X(23), X(27)):
            c.px(x, 2, "y")
        c.px(X(20), 4, "r"); c.px(X(16), 5, "Y"); c.px(X(24), 5, "Y")
    else:
        c.rect(X(13), 5, X(27), 6, hair); c.px(X(13), 7, hair); c.px(X(27), 7, hair)    # a fringe of hair round a bald crown
    poly(c, [(X(29), 21), (X(33), 21), (X(35), 30), (X(32), 30)], tunic_d)               # the near arm, reaching forward
    ellipse(c, X(34), 31, 2.5, 2.5, skin)                                                # big hand


def dwarf_smith(c, f):
    """A dwarf smith of Nidavellir (Voluspa 10-16; Skaldskaparmal 35): short and broad, a pointed hood, a big nose and a
    long beard, a leather apron, a smith's hammer."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 18, "a"); c.rect(x - 1 + d, 19, x + 2 + d, 20, "B")
    poly(c, [(5, 10), (14, 10), (15, 17), (4, 17)], "a"); c.rect(7, 12, 12, 17, "A")    # body and apron
    ellipse(c, 9, 6, 3.5, 3.5, "s")
    poly(c, [(6, 7), (12, 7), (11, 13), (9, 14), (7, 13)], "h"); c.px(9, 10, "H")        # beard
    c.px(10, 6, "S"); c.px(8, 5, "k"); c.px(11, 5, "k")                                  # nose, eyes
    poly(c, [(5, 4), (9, 0), (13, 3), (13, 5), (5, 5)], "c")                             # pointed hood
    c.rect(15, 6, 16, 14, "w"); c.rect(14, 3, 18, 6, "i")                                # hammer
    c.px(14, 10, "s")


DWARF_PAL = {"o": "#120c08", "a": "#6a4a2a", "A": "#4a3018", "s": "#d8a880", "S": "#b0805a", "k": "#1a1008",
             "h": "#b07030", "H": "#7a4a1a", "c": "#5a3a3a", "B": "#3a2818", "i": "#9aa0a8", "w": "#6a4a2a"}


def dwarf_hammerer(c, f):
    """A dwarf hammer-bearer (Skaldskaparmal 35): a heavy dwarf in mail and an iron cap with a nose-guard, carrying a
    great two-handed hammer."""
    s = STEP[f]
    for x, d in ((8, -s), (14, s)):
        c.rect(x + d, 20, x + 2 + d, 22, "m"); c.rect(x - 1 + d, 23, x + 3 + d, 24, "B")
    poly(c, [(5, 10), (18, 10), (19, 20), (4, 20)], "m")
    for y in (13, 16, 19):
        c.row(y, 5, 18, "M")                                                             # mail rings
    ellipse(c, 11, 6, 4, 4, "s")
    poly(c, [(7, 7), (15, 7), (14, 15), (11, 17), (8, 15)], "h"); c.px(11, 11, "H"); c.px(9, 9, "H")
    ellipse(c, 6.5 + 4.5, 3, 4.5, 2.5, "i"); c.row(4, 6, 16, "I"); c.rect(11, 4, 11, 7, "I")   # iron cap, nose-guard
    c.px(9, 6, "k"); c.px(13, 6, "k")
    c.rect(20, 3, 21, 20, "w"); c.rect(18, 0, 24, 4, "i"); c.row(4, 18, 24, "I")        # great hammer
    c.px(19, 12, "s"); c.px(19, 13, "s")


HAMMER_PAL = dict(DWARF_PAL, m="#7a7e88", M="#5a5e68", h="#c8c0b0", H="#9a9284", I="#6a7078")


def gullinbursti(c, step):
    """Gullinbursti (Skaldskaparmal 35): the boar with golden bristles that Brokkr and Sindri forged for Freyr; it runs
    over air and sea faster than any horse, and its bristles light up the darkest night. A great golden boar, heavy in
    the shoulders, its crest of bristles glowing."""
    def leg(x, col, shade):
        poly(c, [(x - 2, 34), (x + 3, 34), (x + 2, 42), (x + 1, 46), (x - 1, 46), (x - 1, 42)], col)
        c.rect(x - 2, 46, x + 2, 48, shade); c.px(x, 47, "k")                            # cloven hoof
    leg(16 - step, "G", "D"); leg(46 + step, "G", "D")                                   # far legs
    for i in range(6):
        c.px(6 - i // 2, 24 + i, "G")                                                    # thin tail
    c.px(3, 30, "y"); c.px(3, 31, "y")
    poly(c, [(8, 26), (14, 20), (30, 16), (44, 14), (52, 20), (54, 30), (50, 38), (36, 38), (20, 38), (10, 36)], "g")
    ellipse(c, 14, 30, 7, 7, "g")                                                        # the haunch
    poly(c, [(22, 36), (44, 36), (40, 39), (24, 39)], "G")                               # shadow under the belly
    poly(c, [(48, 18), (58, 24), (64, 28), (64, 33), (56, 34), (50, 32)], "g")           # long head and snout
    c.rect(63, 28, 65, 33, "G"); c.px(64, 30, "k"); c.px(64, 32, "k")                    # the snout's disc, nostrils
    poly(c, [(59, 32), (62, 26), (63, 27), (60, 33)], "w")                               # the tusk curving up
    c.px(55, 23, "k"); c.px(56, 23, "y")                                                 # small eye
    poly(c, [(49, 17), (51, 11), (54, 18)], "G")                                         # ear
    leg(20 + step, "g", "G"); leg(50 - step, "g", "G")                                   # near legs
    for x in range(14, 54):                                                              # the glowing crest of bristles
        top = next((y for y in range(c.h) if c.g[y][x] in "gG"), None)
        if top is None:
            continue
        h = 3 if 26 <= x <= 46 else 2
        for y in range(top - h, top):
            c.px(x, y, "l" if (x + y) % 2 else "y")
        if x % 3 == 0:
            c.px(x, top - h - 1, "w")
    for x, y in ((24, 26), (32, 24), (40, 22), (18, 30)):
        c.px(x, y, "L")                                                                  # gleam on the gold


BOAR_PAL = {"o": "#2a1a04", "g": "#d8a030", "G": "#a87420", "D": "#7a5210", "y": "#ffe070", "w": "#fff8d8",
            "k": "#1a0e04", "l": "#fff0a0", "L": "#f8d860"}


def brokkr(c, step):
    """Brokkr (Skaldskaparmal 35): the dwarf who worked the bellows for his brother Sindri and would not stop though the
    fly stung him; he carried the treasures to the gods. A stocky red-bearded dwarf in a smith's leather apron and a
    pointed hood, his bellows in his hand."""
    dwarf_body(c, step, hat="hood", hat_col="c", hat_d="C")
    poly(c, [(13, 22), (27, 22), (28, 38), (12, 38)], "A")                               # the leather apron
    poly(c, [(13, 15), (27, 15), (28, 22), (25, 28), (20, 34), (15, 28), (12, 22)], "h")
    for x in (15, 18, 22, 25):
        for y in range(18, 30, 2):
            if c.g[y][x] == "h":
                c.px(x, y, "H")
    poly(c, [(34, 24), (42, 20), (45, 30), (36, 34)], "b"); c.rect(44, 25, 47, 27, "i")   # the bellows
    c.row(29, 36, 43, "B")


BROKKR_PAL = {"o": "#120c08", "k": "#1a1008", "t": "#5a3a22", "T": "#3a2414", "s": "#d8a880", "S": "#a87a58",
              "h": "#c0602a", "H": "#8a3e18", "B": "#3a2818", "b": "#7a5430", "c": "#6a2a2a", "C": "#4a1a1a",
              "A": "#6a4a2a", "y": "#e8c040", "i": "#9aa0a8", "w": "#f0ece4"}


def andvari(c, step):
    """Andvari (Reginsmal): the dwarf who lived as a pike in the waterfall Andvarafors guarding his gold; robbed, he
    cursed his ring Andvaranaut. A small old grey dwarf, bald with a fringe of white hair, a long grey beard, a damp
    blue-green tunic, clutching the gold ring; gold at his feet."""
    dwarf_body(c, step, tunic="u", tunic_d="U", hair="h", hair_d="H", hat=None)
    for k in range(5):
        c.px(32 + k, 20 + k * 2, "f"); c.px(33 + k, 20 + k * 2, "f")                     # a pike's fin on his back
    for a in range(16):
        c.px(round(37 + 3 * math.cos(a / 16 * 6.28)), round(31 + 3 * math.sin(a / 16 * 6.28)), "y")   # the ring
    for k in range(9):
        c.px(4 + k * 4, 47, "y"); c.px(5 + k * 4, 47, "Y")                               # gold at his feet


ANDVARI_PAL = {"o": "#0c0c10", "k": "#141418", "u": "#3a5a5a", "U": "#2a4242", "s": "#c8b8a8", "S": "#9a8a7a",
               "h": "#a8a8a8", "H": "#7a7a7a", "B": "#2a2a2a", "b": "#4a3a2a", "f": "#6a8a7a", "y": "#f0c840",
               "Y": "#b08a20", "w": "#f0f0f0"}


# --- Svartalfheim (Gylfaginning 17, 34; Alvissmal; Skaldskaparmal 1; the Nibelungenlied) ------------------------------

def svartalf(c, f):
    """A svartalf, a dark elf (Gylfaginning 17: the dark elves live down in the earth, blacker than pitch): a slender
    pitch-dark figure in a hooded cloak, pale eyes."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    poly(c, [(6, 8), (13, 8), (15, 19), (4, 19)], "c")
    ellipse(c, 9, 5, 3, 3, "k"); c.px(8, 5, "e"); c.px(10, 5, "e")
    poly(c, [(5, 6), (9, 0), (13, 6)], "c"); c.px(15, 10, "e"); c.px(16, 9, "e")


SVART_PAL = {"o": "#04040a", "k": "#0c0c14", "c": "#1e1e2e", "e": "#a8d8f0"}


def nibelung(c, f):
    """A Nibelung warrior (the Nibelungenlied, 3rd adventure: the strong warriors of the Nibelungs' land who guard the
    hoard): a warrior in dark mail with a round shield and a spear."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    c.rect(5, 8, 14, 18, "m"); c.row(12, 5, 14, "M")
    ellipse(c, 9, 5, 3, 3, "s"); c.rect(6, 1, 12, 4, "m"); c.px(9, 4, "M")
    ellipse(c, 4, 13, 3, 4, "r"); c.px(4, 13, "y")
    c.rect(16, 0, 16, 20, "b"); c.px(16, 0, "M")


NIB_PAL = {"o": "#0a0808", "k": "#1a1418", "m": "#4a4a56", "M": "#2e2e38", "s": "#c8a888", "r": "#7a2a2a",
           "y": "#e0b040", "b": "#6a4a2a"}


def alviss(stone):
    """Alviss (Alvissmal): the "all-wise" dwarf, pale about the nose and dwelling under stone, who came to claim Thor's
    daughter; Thor kept him answering questions until the sun rose and turned him to stone. A pale dwarf with a long
    white beard in a deep violet robe and hood; and the same dwarf turned to grey stone, cracked."""
    def draw(c, step):
        if stone:
            dwarf_body(c, 0, tunic="g", tunic_d="G", skin="g", skin_d="G", hair="G", hair_d="d", boots="G", belt="G",
                       hat="hood", hat_col="g", hat_d="G", braid_rings=False)
            for x, y in ((14, 24), (25, 30), (18, 36), (22, 6), (10, 28), (30, 26)):
                c.px(x, y, "d"); c.px(x + 1, y + 1, "d")                                 # cracks
            return
        dwarf_body(c, step, tunic="v", tunic_d="V", skin="p", skin_d="P", hair="w", hair_d="W", hat="hood",
                   hat_col="v", hat_d="V", braid_rings=False)
        ellipse(c, 21, 13, 2, 2.2, "n")                                                  # the pale nose
    return draw


ALVISS_PAL = {"o": "#08080c", "k": "#14121a", "p": "#d8c8c8", "P": "#a89898", "n": "#f4eeee", "v": "#4a3a6a",
              "V": "#2e2448", "w": "#f0f0f4", "W": "#b8b8c4", "B": "#1e1a24", "b": "#2a2438", "y": "#c8c0e0",
              "g": "#8a8a88", "G": "#6a6a68", "d": "#3a3a38"}


def fjalar_and_galar(c, step):
    """Fjalar and Galar (Skaldskaparmal 1): the two dwarf brothers who killed Kvasir and brewed the mead of poetry from
    his blood mixed with honey in two vats and a kettle. Two dwarves side by side: Fjalar red-haired in a red tunic and
    a pointed hood, Galar dark-haired in blue under an iron cap, holding a ladle dripping mead."""
    dwarf_body(c, step, ox=-4, tunic="r", tunic_d="R", hair="h", hair_d="H", hat="hood", hat_col="R", hat_d="C")
    dwarf_body(c, -step, ox=22, tunic="u", tunic_d="U", hair="j", hair_d="J", hat="helm", hat_col="i", hat_d="I")
    c.rect(57, 14, 58, 30, "b"); ellipse(c, 57, 33, 3, 2, "m"); c.px(57, 36, "m"); c.px(58, 38, "m")   # ladle of mead


FJALAR_PAL = {"o": "#0c0806", "k": "#1a1410", "r": "#7a2a2a", "R": "#5a1e1e", "u": "#2a4a6a", "U": "#1e3650",
              "s": "#d8a880", "S": "#a87a58", "h": "#c0602a", "H": "#8a3e18", "j": "#3a2a1e", "J": "#20160e",
              "B": "#2a1e14", "b": "#6a4a2a", "C": "#3a1414", "i": "#9aa0a8", "I": "#6a7078", "y": "#e8c040",
              "m": "#f0b030", "w": "#ffffff"}


def alberich(c, step):
    """Alberich (the Nibelungenlied, 3rd adventure): the strong dwarf who guarded the Nibelung hoard and owned the
    cloak of invisibility (the Tarnkappe) until Siegfried won it from him. A crowned dwarf with a long white beard, the
    grey Tarnkappe over his shoulders, a whip with knots of gold."""
    poly(c, [(6, 19), (34, 19), (38, 44), (2, 44)], "g")                                 # the Tarnkappe behind him
    c.row(30, 4, 36, "G"); c.row(38, 3, 37, "G")
    dwarf_body(c, step, tunic="r", tunic_d="R", hair="w", hair_d="W", hat="crown")
    c.px(9, 20, "y"); c.px(31, 20, "y")                                                  # the cloak's clasps
    for k in range(12):
        c.px(36 + k // 2, 30 + k, "b")                                                   # his whip
    for k in (3, 7, 11):
        c.px(36 + k // 2, 30 + k, "y")                                                   # its knots of gold


ALBERICH_PAL = {"o": "#0a0808", "k": "#1a1410", "g": "#6a6e78", "G": "#50545e", "r": "#5a2a4a", "R": "#401c34",
                "s": "#d8b090", "S": "#a8805e", "w": "#e8e4dc", "W": "#b0aca4", "B": "#2a1e14", "b": "#6a4a2a",
                "y": "#f0c840", "Y": "#b08a20"}


# --- Mycendra (the game's own invented fungal city; GAME_DESIGN.md: Fantasy realms) ------------------------------------

def cap_walker(c, f):
    """A cap walker (Mycendra, the game's own): a squat mushroom-person on two stubby legs under a broad spotted cap."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 20, "S")
    c.rect(6, 10, 13, 17, "s"); c.px(8, 13, "k"); c.px(11, 13, "k")
    ellipse(c, 9.5, 7, 8, 4, "r"); c.row(10, 3, 16, "R")
    for x, y in ((5, 6), (9, 4), (13, 6), (11, 8)):
        c.px(x, y, "w")


CAP_PAL = {"o": "#120a08", "s": "#e0d4b8", "S": "#b8a888", "k": "#2a1a10", "r": "#b0402a", "R": "#80281a",
           "w": "#f0ece0"}


def spore_puff(c, f):
    """A spore puff (Mycendra, the game's own): a small round puffball drifting on the air, trailing spores."""
    s = STEP[f]
    ellipse(c, 7, 6 + s, 5, 5, "p"); ellipse(c, 6, 5 + s, 3, 3, "P")
    c.px(6, 1 + s, "w")
    for k in range(3):
        c.px(2 + k * 4, 12 + (k + f) % 2, "g")


PUFF_PAL = {"o": "#2a2410", "p": "#d8cc98", "P": "#ece4c0", "w": "#f8f4e0", "g": "#a8b848"}


def glow_fly(c, f):
    """A glow-fly (Mycendra, the game's own): a fly lit pale green by the fungus light."""
    up = f % 2
    ellipse(c, 8, 7, 3, 2, "k"); c.px(10, 7, "g"); c.px(5, 7, "y")
    poly(c, [(7, 6), (4, 1 if up else 3), (9, 5)], "w"); poly(c, [(9, 6), (12, 1 if up else 3), (10, 5)], "w")


GLOWFLY_PAL = {"o": "#0e140a", "k": "#1e2a14", "g": "#c8f060", "y": "#a8f048", "w": "#c8e8c0"}


def great_puffball(c, step):
    """The Great Puffball (Mycendra, the game's own): a puffball as big as an ox, its skin cracked, spores leaking."""
    ellipse(c, 28, 30, 24, 20 - step, "p"); ellipse(c, 24, 24, 16, 12, "P")
    for x, y in ((14, 20), (36, 18), (30, 36), (20, 38), (40, 30)):
        c.px(x, y, "k"); c.px(x + 1, y + 1, "k"); c.px(x + 2, y + 1, "k")
    for k in range(6):
        c.px(10 + k * 7, 6 + (k % 3) * 2, "g")
    c.rect(18, 48, 38, 50, "s")


GREATPUFF_PAL = {"o": "#2a2410", "p": "#d8cc98", "P": "#ece4c0", "k": "#8a7a50", "g": "#a8b848", "s": "#6a5a3a"}


def mycelium(c, step):
    """The Mycelium (Mycendra, the game's own): a heaving mass of pale fungus threads with a knot of mushrooms at its
    heart."""
    ellipse(c, 30, 34, 26, 14, "w")
    for k in range(22):
        a = k / 22 * math.tau
        for r in range(10, 28, 2):
            c.px(round(30 + math.cos(a + r * 0.05 + step * 0.1) * r), round(34 + math.sin(a) * r * 0.55), "W")
    for x, h in ((22, 10), (30, 14), (37, 9)):
        c.rect(x, 30 - h, x + 1, 30, "s"); ellipse(c, x + 0.5, 30 - h, 4, 2.5, "b")


MYCELIUM_PAL = {"o": "#2a2620", "w": "#e8e4d4", "W": "#c8c2b0", "s": "#e0d4b8", "b": "#8a5a3a"}


def spore_mother(c, step):
    """The Spore Mother (Mycendra, the game's own): a towering mushroom with a vast frilled cap and a face in its stalk,
    spores raining from its gills."""
    c.rect(22, 22, 36, 60, "s"); c.rect(22, 22, 24, 60, "S")
    c.px(26, 34, "k"); c.px(32, 34, "k"); c.row(40, 27, 31, "k")
    ellipse(c, 29, 18, 26, 12, "v"); c.row(28, 4, 54, "V")
    for x in range(6, 54, 3):
        c.px(x, 29, "V"); c.px(x + 1, 30 + (x // 3 + step) % 2, "g")                        # the frilled gills
    for x, y in ((14, 14), (24, 9), (36, 10), (44, 16), (29, 20)):
        c.rect(x, y, x + 2, y + 1, "w")
    for k in range(6):
        c.px(10 + k * 8, 36 + (k * 5 + step) % 12, "g")


MOTHER_PAL = {"o": "#120a10", "s": "#e0d4b8", "S": "#b8a888", "k": "#2a1a10", "v": "#6a3a7a", "V": "#4a2858",
              "g": "#b8c858", "w": "#e8d8f0"}


# --- The Myrmidon Hive (Ovid, Metamorphoses 7.614-660; Herodotus 3.102-105; Servius on Aeneid 4.402) -------------------

def myrmidon(c, f):
    """A Myrmidon (Ovid, Metamorphoses 7: the ants of Aegina turned into men for King Aeacus): a hoplite in dark
    bronze-red armour with an ant's feelers on his helmet, a spear and round shield."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "k")
    c.rect(5, 8, 14, 18, "r"); c.row(12, 5, 14, "R")
    ellipse(c, 9, 5, 3, 3, "b"); c.rect(6, 1, 12, 4, "b"); c.px(10, 4, "k")
    c.px(7, 0, "k"); c.px(6, -1 if False else 0, "k"); c.px(12, 0, "k")
    ellipse(c, 4, 13, 3, 4, "b"); c.px(4, 13, "y")
    c.rect(16, 0, 16, 20, "w"); c.px(16, 0, "b")


MYRM_PAL = {"o": "#0a0604", "k": "#1a0e0a", "r": "#7a2a1a", "R": "#5a1a10", "b": "#a8743a", "y": "#e0b040",
            "w": "#6a4a2a"}


def ant(colour, wings=False, load=False):
    def draw(c, f):
        s = STEP[f]
        ellipse(c, 4, 8, 3, 2.5, colour); ellipse(c, 9, 8, 2, 2, colour); ellipse(c, 14, 8, 3.5, 3, colour)
        c.px(2, 6, "k"); c.px(1, 5, "k"); c.px(3, 5, "k")
        for k, d in enumerate((-s, s, -s)):
            c.px(7 + k * 2 + d, 11, "k"); c.px(7 + k * 2 - d, 5, "k")
        if wings:
            up = f % 2
            poly(c, [(9, 7), (5, 1 if up else 3), (12, 5)], "w"); poly(c, [(10, 7), (15, 1 if up else 3), (13, 6)], "w")
        if load:
            ellipse(c, 4, 4, 3, 2, "y")                                                     # the gold it carries
    return draw


ANT_PAL = {"o": "#120804", "a": "#8a4a1a", "d": "#c88a2a", "k": "#2a1408", "w": "#e8e4d8", "y": "#f0c840"}


def great_gold_ant(c, step):
    """The Gold-Digging Ant (Herodotus 3.102: ants smaller than dogs but bigger than foxes, which throw up gold-bearing
    sand as they burrow): a huge tawny ant with gold dust on its jaws."""
    ellipse(c, 12, 26, 10, 8, "d"); ellipse(c, 28, 26, 7, 6, "d"); ellipse(c, 46, 26, 13, 10, "d")
    c.px(9, 22, "k"); c.px(14, 22, "k")
    for k in range(6):
        c.px(4 - k, 20 - k, "k"); c.px(8 - k // 2, 19 - k, "k")                          # feelers
    for k, d in enumerate((-step, step, -step)):
        x = 22 + k * 7
        for t in range(10):
            c.px(x - t // 2 + d, 32 + t, "k"); c.px(x - t // 2 - d, 20 - t, "k")
    c.rect(2, 28, 6, 30, "y"); c.px(3, 27, "y")


GREATANT_PAL = {"o": "#120804", "d": "#c88a2a", "k": "#2a1408", "y": "#f0d040"}


def myrmex(c, step):
    """Myrmex (Servius on Virgil, Aeneid 4.402): an Attic girl, a favourite of Athena, who claimed she had invented the
    plough the goddess made, and was turned into an ant. A girl with an ant's feelers and dark shining limbs, pushing
    a plough."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 6 + d, 44, 18 + k * 6 + d, 54, "k")
    poly(c, [(14, 18), (28, 18), (31, 46), (11, 46)], "p")
    c.rect(16, 6, 25, 16, "s"); c.px(19, 10, "k"); c.px(23, 10, "k")
    c.rect(14, 3, 27, 7, "h")
    for k in range(5):
        c.px(17 - k, 2 - k // 2, "k"); c.px(24 + k, 2 - k // 2, "k")                       # feelers
    c.rect(32, 30, 34, 50, "b"); poly(c, [(33, 48), (44, 54), (34, 54)], "i")                # the plough


MYRMEX_PAL = {"o": "#0e0806", "k": "#1e140e", "p": "#b8a070", "s": "#5a3a24", "h": "#2a1a10", "b": "#7a5430",
              "i": "#9aa0a8"}


def ant_queen(c, step):
    """The Queen of the Gold-Digging Ants (the design's; Herodotus 3.102): a vast winged queen ant, her swollen body
    ringed with gold."""
    ellipse(c, 12, 28, 9, 8, "d"); ellipse(c, 26, 28, 7, 6, "d"); ellipse(c, 50, 30, 20, 14, "D")
    for x in range(36, 68, 5):
        c.rect(x, 18, x, 42, "y")                                                            # gold rings
    poly(c, [(24, 24), (10, 4 + step), (34, 20)], "w"); poly(c, [(28, 24), (44, 2 - step), (36, 22)], "w")
    c.px(9, 24, "k"); c.px(14, 24, "k")
    for k in range(6):
        c.px(5 - k, 22 - k, "k"); c.px(9 - k // 2, 21 - k, "k")
    c.rect(6, 18, 18, 20, "y"); c.px(8, 17, "y"); c.px(12, 16, "y"); c.px(16, 17, "y")      # a crown
    for k, d in enumerate((-step, step, -step)):
        x = 18 + k * 6
        for t in range(10):
            c.px(x - t // 2 + d, 34 + t, "k")


QUEEN_PAL = {"o": "#120804", "d": "#a86a2a", "D": "#c88a3a", "k": "#2a1408", "y": "#f0c840", "w": "#e8e4d8"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_deep.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("dwarf_smith", dwarf_smith, DWARF_PAL, doc(dwarf_smith.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("dwarf_hammerer", dwarf_hammerer, HAMMER_PAL, doc(dwarf_hammerer.__doc__), (26, 26), (12, 25), walk, folder="enemies")
    kit.build_boss("gullinbursti", gullinbursti, BOAR_PAL, doc(gullinbursti.__doc__), (68, 50), (32, 48), [0, 1, 0, -1, 0])
    kit.build_boss("brokkr", brokkr, BROKKR_PAL, doc(brokkr.__doc__), (48, 48), (20, 46), [0, 1, 0, -1, 0])
    kit.build_boss("andvari", andvari, ANDVARI_PAL, doc(andvari.__doc__), (44, 48), (20, 46), [0, 1, 0, -1, 0])
    kit.build_boss("svartalf", svartalf, SVART_PAL, doc(svartalf.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("nibelung", nibelung, NIB_PAL, doc(nibelung.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("alviss", alviss(False), ALVISS_PAL, doc(alviss.__doc__), (40, 48), (20, 46), [0, 1, 0, -1, 0])
    kit.build_boss("alviss_stone", alviss(True), ALVISS_PAL, doc(alviss.__doc__ + " Here, turned to stone."), (40, 48),
                   (20, 46), [0, 0, 0, 0, 0])
    kit.build_boss("fjalar_and_galar", fjalar_and_galar, FJALAR_PAL, doc(fjalar_and_galar.__doc__), (64, 48), (31, 46), [0, 1, 0, -1, 0])
    kit.build_boss("alberich", alberich, ALBERICH_PAL, doc(alberich.__doc__), (44, 48), (20, 46), [0, 1, 0, -1, 0])
    kit.build_boss("cap_walker", cap_walker, CAP_PAL, doc(cap_walker.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("spore_puff", spore_puff, PUFF_PAL, doc(spore_puff.__doc__), (14, 16), (7, 15), walk, folder="enemies")
    kit.build_boss("glow_fly", glow_fly, GLOWFLY_PAL, doc(glow_fly.__doc__), (16, 12), (8, 11), walk, folder="enemies")
    kit.build_boss("great_puffball", great_puffball, GREATPUFF_PAL, doc(great_puffball.__doc__), (56, 54), (28, 52), [0, 1, 0, 1, 0])
    kit.build_boss("mycelium", mycelium, MYCELIUM_PAL, doc(mycelium.__doc__), (60, 52), (30, 50), [0, 1, 0, -1, 0])
    kit.build_boss("spore_mother", spore_mother, MOTHER_PAL, doc(spore_mother.__doc__), (58, 64), (29, 62), [0, 1, 0, -1, 0])
    kit.build_boss("myrmidon", myrmidon, MYRM_PAL, doc(myrmidon.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    ant_doc = "A gold-digging ant (Herodotus, Histories 3.102: smaller than a dog, bigger than a fox)."
    kit.build_boss("gold_digging_ant", ant("d"), ANT_PAL, doc(ant_doc), (20, 14), (10, 13), walk, folder="enemies")
    kit.build_boss("winged_ant", ant("a", wings=True), ANT_PAL, doc("A winged ant of the hive on its swarming flight."),
                   (20, 14), (10, 13), walk, folder="enemies")
    kit.build_boss("gold_carrier_ant", ant("d", load=True), ANT_PAL, doc(ant_doc + " This one carries gold to its queen."),
                   (20, 14), (10, 13), walk, folder="enemies")
    kit.build_boss("great_gold_ant", great_gold_ant, GREATANT_PAL, doc(great_gold_ant.__doc__), (62, 44), (30, 42), [0, 1, 0, -1, 0])
    kit.build_boss("myrmex", myrmex, MYRMEX_PAL, doc(myrmex.__doc__), (46, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("ant_queen", ant_queen, QUEEN_PAL, doc(ant_queen.__doc__), (72, 48), (36, 46), [0, 1, 0, -1, 0])
    print("wrote the Deep Below's art")
