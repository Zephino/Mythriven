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
    """The Great Puffball (Mycendra, the game's own): a puffball as big as an ox, its pale skin cracked into patches,
    split open at the top with spores puffing out."""
    ellipse(c, 28, 49, 14, 3, "s")                                                       # the soil it sits on
    c.rect(22, 44, 34, 48, "k")                                                          # its stub
    ellipse(c, 28, 30, 24, 18 - step, "p")
    ellipse(c, 23, 25, 15, 10, "P")                                                      # the light side
    ellipse(c, 34, 38, 16, 8, "q")                                                       # the shadowed underside
    for y in range(14, 47, 6):                                                           # cracked into patches
        for x in range(6, 52, 7):
            ox = 3 if (y // 6) % 2 else 0
            if c.g[y][x + ox] in "pPq":
                c.px(x + ox, y, "k"); c.px(x + ox + 1, y, "k"); c.px(x + ox + 3, y + 3, "k")
    poly(c, [(22, 12), (34, 12), (31, 16), (25, 16)], "k")                               # the split at the top
    for k, (dx, dy, r) in enumerate(((0, 9, 2.5), (-4, 6, 2), (4, 5, 2.2), (-7, 2, 1.6), (1, 2, 2.4), (7, 1, 1.5),
                                     (-2, -1 + 1, 1.2), (10, 6, 1), (-10, 7, 1))):
        ellipse(c, 28 + dx, dy - step, r, r * 0.8, "g" if k % 2 else "G")               # a dusty cloud of spores


GREATPUFF_PAL = {"o": "#2a2410", "p": "#d8cc98", "P": "#ece4c0", "q": "#b8a878", "k": "#8a7a50", "g": "#a89a6a",
                 "G": "#c8bc90", "s": "#4a3a24"}


def mycelium(c, step):
    """The Mycelium (Mycendra, the game's own): a heaving mound of pale fungus threads, tendrils creeping out over the
    ground, with a knot of mushrooms at its heart."""
    for k in range(10):                                                                  # tendrils reaching out
        a = math.pi + k / 9 * math.pi
        x, y = 30.0, 42.0
        for t in range(18):
            x += math.cos(a) * 1.6; y += 0.15 + math.sin(t * 0.6 + k) * 0.3
            c.px(round(x), min(51, round(y + 6)), "W")
            if t == 10:
                c.px(round(x + math.cos(a + 0.6) * 2), min(51, round(y + 5)), "W")
    for cx, cy, rx, ry in ((18, 38, 12, 8), (40, 38, 13, 8), (30, 32, 15, 10), (24, 26, 9, 6), (36, 27, 8, 6)):
        ellipse(c, cx, cy + (step if cx < 30 else -step) * 0.5, rx, ry, "w")             # heaving lumps
    for k in range(40):                                                                  # threads woven over it
        a = k * 0.9
        x0 = 30 + math.cos(a) * 14; y0 = 34 + math.sin(a) * 8
        for t in range(6):
            x, y = round(x0 + t * math.cos(a + 1.3)), round(y0 + t * math.sin(a + 1.3) * 0.6)
            if 0 <= y < c.h and 0 <= x < c.w and c.g[y][x] == "w":
                c.px(x, y, "W")
    for x, h, r in ((22, 10, 4), (28, 15, 5), (34, 12, 4), (39, 8, 3), (25, 6, 2.5)):   # the knot of mushrooms
        c.rect(x, 30 - h, x + 1, 30, "s")
        ellipse(c, x + 0.5, 30 - h, r, r * 0.6, "b"); c.row(30 - h + 1, round(x - r + 1), round(x + r), "B")
        c.px(round(x - r / 2), 30 - h - 1, "l")


MYCELIUM_PAL = {"o": "#2a2620", "w": "#e8e4d4", "W": "#b8b2a0", "s": "#e0d4b8", "b": "#8a5a3a", "B": "#5a3a24",
                "l": "#c8946a"}


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
    """A Myrmidon (Ovid, Metamorphoses 7: the ants of Aegina turned into men for King Aeacus): a hoplite in bronze with
    an ant's feelers rising from his helmet, a red cloak, a spear, and a round shield with an ant on it."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 21, "s"); c.rect(x + d, 21, x + 2 + d, 22, "k")
    poly(c, [(5, 8), (12, 8), (15, 17), (3, 17)], "r")                                   # cloak behind
    c.rect(6, 8, 13, 16, "b"); c.row(12, 6, 13, "B"); c.px(9, 10, "B")                   # bronze cuirass
    c.rect(6, 15, 13, 17, "R")                                                           # kilt
    ellipse(c, 9, 4, 3.5, 3.5, "b"); c.rect(7, 5, 8, 7, "s"); c.px(8, 5, "k")            # helmet, face
    c.px(10, 1, "k"); c.px(11, 0, "k"); c.px(8, 1, "k"); c.px(7, 0, "k")                 # an ant's feelers
    c.rect(16, 0, 16, 20, "w"); c.px(16, 0, "i")                                         # spear
    ellipse(c, 4, 12, 3.5, 4.5, "b"); ellipse(c, 4, 12, 2.5, 3.5, "B")                   # round shield
    c.px(3, 11, "k"); c.px(4, 12, "k"); c.px(5, 13, "k"); c.px(2, 12, "k"); c.px(6, 12, "k")   # the ant on it


MYRM_PAL = {"o": "#0a0604", "k": "#1a0e0a", "r": "#8a2a1a", "R": "#5a1a10", "b": "#c08a3a", "B": "#8a5a1e",
            "s": "#c8946a", "y": "#e0b040", "w": "#6a4a2a", "i": "#c8ccd4"}


def ant_body(c, x0, y0, k, step, col, dark, light, eye="k"):
    """An ant in side view, facing left, scaled by k: head with jaws and a big eye, elbowed feelers, a narrow thorax, a
    small waist node, a big shining abdomen, and six bent legs (three on the far side in shadow)."""
    X = lambda v: round(x0 + v * k)
    Y = lambda v: round(y0 + v * k)
    def leg(xa, out, d, colr):
        knee = (X(xa + out * 5 + d), Y(4))
        foot = (X(xa + out * 7 + d * 1.5), Y(10))
        for t in range(6):
            c.px(round(X(xa) + (knee[0] - X(xa)) * t / 5), round(Y(1) + (knee[1] - Y(1)) * t / 5), colr)
        for t in range(7):
            c.px(round(knee[0] + (foot[0] - knee[0]) * t / 6), round(knee[1] + (foot[1] - knee[1]) * t / 6), colr)
    for i, (xa, out) in enumerate(((9, -1), (13, 0), (16, 1))):                          # far legs, in shadow
        leg(xa + 1, out, step if i % 2 else -step, dark)
    ellipse(c, X(33), Y(-1), 11 * k, 8 * k, col)                                         # the abdomen
    ellipse(c, X(31), Y(-4), 7 * k, 3.5 * k, light)                                      # its shine
    for bx in (27, 32, 37):
        for t in range(-6, 6):
            yy = Y(-1 + t)
            xx = X(bx) + round(abs(t) * 0.3 * k)
            if 0 <= yy < c.h and c.g[yy][xx] in (col, light):
                c.px(xx, yy, dark)                                                       # its bands
    ellipse(c, X(20.5), Y(0), 2.2 * k, 2.2 * k, col)                                     # the waist node
    ellipse(c, X(13), Y(-1), 6 * k, 3.4 * k, col); c.px(X(12), Y(-3), light)             # the thorax
    ellipse(c, X(4), Y(-2), 4.5 * k, 4 * k, col)                                         # the head
    ellipse(c, X(4), Y(-3), 1.4 * k, 1.4 * k, eye)                                       # big eye
    c.px(X(-1), Y(1), dark); c.px(X(-2), Y(0), dark); c.px(X(-1), Y(2), dark)            # jaws
    for t in range(5):                                                                   # elbowed feelers
        c.px(X(4 - t * 0.4), Y(-6 - t), dark)
    for t in range(6):
        c.px(X(2 - t), Y(-10 + t * 0.2), dark)
    for i, (xa, out) in enumerate(((9, -1), (13, 0), (16, 1))):                          # near legs
        leg(xa, out, -step if i % 2 else step, dark)


def ant(colour, wings=False, load=False):
    """A small ant of the hive in side view: head with jaws and an eye, elbowed feelers, a narrow thorax, a waist node,
    a banded shining abdomen, and bent legs that step."""
    def draw(c, f):
        s = STEP[f]
        if wings:
            up = f % 2
            poly(c, [(8, 6), (12, 0 if up else 2), (16, 1 if up else 3), (10, 6)], "W")
        for k, (x, d) in enumerate(((6, s), (8, -s), (10, s))):                             # bent legs
            kx = x - 2 + k * 2
            c.px(x, 9, "k"); c.px(kx + d, 10, "k"); c.px(kx + d - (1 if k == 0 else 0) + (1 if k == 2 else 0), 11, "k")
            c.px(kx + d - (1 if k == 0 else 0) + (1 if k == 2 else 0), 12, "k")
        ellipse(c, 15, 7, 4, 3, colour); c.px(14, 5, "l"); c.px(15, 5, "l")              # abdomen, its shine
        c.rect(16, 5, 16, 9, "k")                                                        # its band
        c.px(11, 8, colour)                                                              # waist node
        ellipse(c, 8, 7, 2.6, 1.6, colour)                                               # thorax
        ellipse(c, 3, 7, 2.4, 2.2, colour); c.px(2, 6, "k")                             # head, eye
        c.px(0, 8, "k"); c.px(0, 9, "k")                                                 # jaws
        c.px(4, 4, "k"); c.px(4, 3, "k"); c.px(3, 2, "k"); c.px(2, 2, "k"); c.px(1, 2, "k")   # elbowed feeler
        if wings:
            poly(c, [(7, 6), (10, 0 if up else 2), (13, 1 if up else 3), (9, 6)], "w")
        if load:
            ellipse(c, 3, 2, 2.5, 1.8, "y"); c.px(2, 1, "Y")                             # the gold it carries
    return draw


ANT_PAL = {"o": "#120804", "a": "#8a4a1a", "d": "#c88a2a", "k": "#2a1408", "l": "#f0c070", "w": "#e8e4d8",
           "W": "#c8c4b8", "y": "#f0c840", "Y": "#fff0a0"}


def great_gold_ant(c, step):
    """The Gold-Digging Ant (Herodotus 3.102: ants smaller than dogs but bigger than foxes, which throw up gold-bearing
    sand as they burrow): a huge tawny ant with gold dust on its jaws."""
    ant_body(c, 6, 28, 1.25, step, "d", "k", "l")
    for x, y in ((2, 30), (4, 31), (1, 32), (3, 33), (6, 32)):
        c.px(x, y, "y")                                                                  # gold dust on its jaws
    for x in range(0, 60, 5):
        c.px(x, 43, "y")                                                                 # gold-bearing sand


GREATANT_PAL = {"o": "#120804", "d": "#c88a2a", "k": "#2a1408", "l": "#f0c070", "y": "#f0d040"}


def myrmex(c, step):
    """Myrmex (Servius on Virgil, Aeneid 4.402): an Attic girl, a favourite of Athena, who claimed she had invented the
    plough the goddess made, and was turned into an ant. A girl in a pale peplos, her dark hair bound up, an ant's
    feelers rising from her head and her arms turning dark and shining, pushing a wooden plough."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 6 + d, 46, 18 + k * 6 + d, 52, "s"); c.rect(15 + k * 6 + d, 52, 19 + k * 6 + d, 54, "k")
    poly(c, [(14, 18), (26, 18), (30, 47), (10, 47)], "p")                               # the peplos
    for x in (14, 18, 22, 26):
        c.rect(x, 26, x, 46, "P")                                                        # its folds
    c.row(25, 13, 27, "b")                                                               # girdle
    c.rect(16, 6, 24, 15, "s"); c.px(17, 10, "S")                                        # face
    c.px(19, 10, "k"); c.px(23, 10, "k"); c.row(13, 20, 22, "r")                         # eyes, mouth
    c.rect(15, 3, 25, 6, "h"); c.rect(15, 6, 16, 12, "h"); ellipse(c, 14, 6, 3, 3, "h")  # hair bound up
    for t in range(6):
        c.px(18 - t // 2, 2 - t, "a"); c.px(22 + t // 2, 2 - t, "a")                     # an ant's feelers
    c.px(15, -3 + 4, "a")
    poly(c, [(26, 19), (30, 19), (34, 30), (31, 31)], "a"); c.px(29, 21, "A")            # dark shining arm
    poly(c, [(13, 19), (11, 30), (14, 31), (16, 21)], "a")
    c.rect(32, 30, 35, 33, "a")                                                          # hand on the plough
    c.rect(33, 28, 34, 46, "w"); poly(c, [(33, 46), (44, 52), (44, 54), (32, 54)], "w")  # the wooden plough
    poly(c, [(40, 51), (45, 54), (40, 54)], "i")                                         # its share


MYRMEX_PAL = {"o": "#0e0806", "k": "#1e140e", "p": "#e8dcc0", "P": "#c8b894", "s": "#d8a880", "S": "#b0805a",
              "h": "#2a1a10", "r": "#a84a3a", "b": "#a87a3a", "a": "#2a1a14", "A": "#6a5040", "w": "#7a5430",
              "i": "#9aa0a8"}


def ant_queen(c, step):
    """The Queen of the Gold-Digging Ants (the design's; Herodotus 3.102): a vast winged queen ant, her swollen body
    ringed with gold, a crown on her head."""
    poly(c, [(28, 20), (40, 2 - step), (56, 0 - step), (46, 12), (32, 22)], "w")         # far wing
    ant_body(c, 4, 30, 1.0, step, "d", "k", "l")
    ellipse(c, 50, 28, 20, 14, "D")                                                      # the vast swollen abdomen
    ellipse(c, 46, 22, 12, 5, "l")
    for x in range(36, 70, 5):
        for y in range(14, 43):
            if c.g[y][x] in "Dl":
                c.px(x, y, "y")                                                          # rings of gold
    poly(c, [(26, 22), (34, 4 + step), (48, 6 + step), (38, 16), (30, 24)], "W")         # near wing
    for t in range(10):
        c.px(30 + t, 20 - t, "v"); c.px(34 + t, 16 - t // 2, "v")                        # veins in it
    c.rect(4, 22, 12, 24, "y"); c.px(4, 21, "y"); c.px(8, 20, "y"); c.px(12, 21, "y"); c.px(8, 23, "r")  # crown on her head


QUEEN_PAL = {"o": "#120804", "d": "#a86a2a", "D": "#c88a3a", "k": "#2a1408", "l": "#f0c070", "y": "#f0c840",
             "w": "#d8d4c8", "W": "#ece8dc", "v": "#b8b4a8", "r": "#c83030"}


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
