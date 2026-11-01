# The Deep Below's art (Pack 6, docs/PACK_6_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts (the Eddas, Snorri, the Nibelungenlied, Ovid, Herodotus); Mycendra is the game's own.
# Run: python3 build_deep.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


# --- Nidavellir (Voluspa 37; Reginsmal; Skaldskaparmal 35, 39) --------------------------------------------------------

def dwarf_smith(c, f):
    """A dwarf smith of Nidavellir (Voluspa 10-16; Skaldskaparmal 35): short and broad, a long beard, a leather apron,
    a smith's hammer."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 17, x + 1 + d, 20, "B")
    c.rect(5, 9, 14, 17, "a"); c.rect(6, 11, 13, 17, "A")
    ellipse(c, 9, 6, 3.5, 3, "s"); c.px(8, 5, "k"); c.px(10, 5, "k")
    poly(c, [(6, 7), (12, 7), (11, 14), (7, 14)], "h")                                    # the beard
    c.rect(5, 2, 13, 4, "c")
    c.rect(15, 6, 16, 14, "B"); c.rect(14, 4, 18, 6, "i")                                  # hammer


DWARF_PAL = {"o": "#120c08", "a": "#6a4a2a", "A": "#4a3018", "s": "#d8a880", "k": "#1a1008", "h": "#b07030",
             "c": "#3a3a48", "B": "#3a2818", "i": "#9aa0a8"}


def dwarf_hammerer(c, f):
    """A dwarf hammer-bearer (Skaldskaparmal 35): a heavy dwarf in mail with a great two-handed hammer."""
    s = STEP[f]
    for x, d in ((8, -s), (14, s)):
        c.rect(x + d, 20, x + 2 + d, 24, "B")
    c.rect(5, 10, 18, 20, "m"); c.row(14, 5, 18, "M"); c.row(17, 5, 18, "M")
    ellipse(c, 11, 6, 4, 3.5, "s"); c.px(10, 5, "k"); c.px(13, 5, "k")
    poly(c, [(7, 7), (15, 7), (14, 16), (8, 16)], "h")
    c.rect(6, 1, 16, 4, "i")
    c.rect(20, 3, 21, 20, "B"); c.rect(18, 0, 24, 4, "i")


HAMMER_PAL = dict(DWARF_PAL, m="#7a7e88", M="#5a5e68", h="#c8c0b0")


def gullinbursti(c, step):
    """Gullinbursti (Skaldskaparmal 35): the boar with golden bristles that Brokkr and Sindri forged for Freyr; it runs
    over air and sea faster than any horse, and its bristles light up the darkest night."""
    ellipse(c, 28, 28, 18, 10, "g")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(14 + k * 9 + d, 34, 17 + k * 9 + d, 46, "G")
    poly(c, [(44, 22), (56, 26), (56, 33), (44, 34)], "g"); c.rect(54, 28, 57, 31, "G"); c.px(49, 25, "k")
    poly(c, [(52, 31), (55, 36), (53, 31)], "w")                                            # tusk
    for x in range(14, 46, 2):
        c.px(x, 17 + abs(x - 30) // 6, "y"); c.px(x, 16 + abs(x - 30) // 6, "w")           # golden bristles
    c.px(9, 27, "g"); c.px(8, 26, "g")


BOAR_PAL = {"o": "#2a1a04", "g": "#d8a030", "G": "#a87420", "y": "#ffe070", "w": "#fff8d8", "k": "#1a0e04",
            "l": "#fff0a0", "L": "#f8d860"}


def brokkr(c, step):
    """Brokkr (Skaldskaparmal 35): the dwarf who worked the bellows for his brother Sindri and would not stop though the
    fly stung him; he carried the treasures to the gods. A dwarf in a leather apron with a pair of bellows."""
    for k, d in enumerate((-step, step)):
        c.rect(14 + k * 8 + d, 40, 17 + k * 8 + d, 46, "B")
    c.rect(10, 20, 31, 40, "a"); c.rect(13, 24, 28, 40, "A")
    ellipse(c, 20, 13, 7, 6, "s"); c.px(17, 12, "k"); c.px(23, 12, "k")
    poly(c, [(14, 15), (26, 15), (24, 32), (16, 32)], "h")
    c.rect(12, 5, 28, 9, "c")
    poly(c, [(32, 26), (40, 22), (42, 32), (34, 34)], "b"); c.rect(41, 26, 46, 28, "i")        # the bellows


BROKKR_PAL = dict(DWARF_PAL, b="#7a5430")


def andvari(c, step):
    """Andvari (Reginsmal): the dwarf who lived as a pike in the waterfall Andvarafors guarding his gold; robbed, he
    cursed his ring Andvaranaut. A small grey dwarf clutching a gold ring, a pike's fins on his back."""
    for k, d in enumerate((-step, step)):
        c.rect(14 + k * 8 + d, 40, 17 + k * 8 + d, 46, "B")
    c.rect(11, 20, 30, 40, "u"); c.rect(13, 24, 28, 40, "U")
    for k in range(5):
        c.px(30 + k, 22 + k * 2, "f"); c.px(31 + k, 22 + k * 2, "f")                           # pike fins
    ellipse(c, 20, 13, 7, 6, "s"); c.px(17, 12, "k"); c.px(23, 12, "k")
    poly(c, [(14, 15), (26, 15), (23, 30), (17, 30)], "h")
    c.rect(12, 5, 28, 9, "c")
    for a in range(12):
        c.px(8 + round(3 * math.cos(a / 12 * 6.28)), 30 + round(3 * math.sin(a / 12 * 6.28)), "y")   # the ring
    for k in range(8):
        c.px(4 + k * 4, 46, "y")                                                                  # gold at his feet


ANDVARI_PAL = dict(DWARF_PAL, u="#4a5a6a", U="#3a4858", f="#6a8a7a", y="#f0c840", h="#9a9a9a", s="#c8b8a8")


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
    """Alviss (Alvissmal): the "all-wise" dwarf, pale-nosed and dwelling under stone, who came to claim Thor's daughter;
    Thor kept him answering questions until the sun rose and turned him to stone."""
    def draw(c, step):
        skin, robe, beard = ("g", "G", "g") if stone else ("p", "v", "w")
        for k, d in enumerate((-step, step)):
            c.rect(14 + k * 8 + d, 40, 17 + k * 8 + d, 46, "G" if stone else "k")
        c.rect(11, 20, 30, 40, robe)
        ellipse(c, 20, 13, 7, 6, skin); c.px(17, 12, "k"); c.px(23, 12, "k")
        c.rect(19, 13, 21, 16, "w" if not stone else "G")                                  # the pale nose
        poly(c, [(14, 15), (26, 15), (24, 34), (16, 34)], beard)
        c.rect(12, 4, 28, 8, "G" if stone else "c")
        if stone:
            for x, y in ((14, 24), (25, 30), (18, 36), (22, 10)):
                c.px(x, y, "k"); c.px(x + 1, y + 1, "k")                                    # cracks
    return draw


ALVISS_PAL = {"o": "#08080c", "k": "#14121a", "p": "#d8d0d8", "v": "#3a3450", "w": "#f0f0f4", "c": "#2a2438",
              "g": "#8a8a88", "G": "#6a6a68"}


def fjalar_and_galar(c, step):
    """Fjalar and Galar (Skaldskaparmal 1): the two dwarf brothers who killed Kvasir and brewed the mead of poetry from
    his blood mixed with honey in two vats and a kettle. Two dwarves side by side, one with a ladle."""
    for bx, robe in ((4, "r"), (26, "u")):
        for k, d in enumerate((-step, step)):
            c.rect(bx + 4 + k * 6 + d, 38, bx + 6 + k * 6 + d, 44, "k")
        c.rect(bx + 1, 20, bx + 17, 38, robe)
        ellipse(c, bx + 9, 13, 6, 5, "s"); c.px(bx + 7, 12, "k"); c.px(bx + 11, 12, "k")
        poly(c, [(bx + 4, 15), (bx + 14, 15), (bx + 12, 30), (bx + 6, 30)], "h")
        c.rect(bx + 2, 5, bx + 16, 8, "c")
    c.rect(44, 18, 45, 34, "b"); ellipse(c, 44, 36, 3, 2, "y")                              # the ladle of mead


FJALAR_PAL = {"o": "#0c0806", "k": "#1a1410", "r": "#6a2a2a", "u": "#2a4a6a", "s": "#d8a880", "h": "#9a6a3a",
              "c": "#3a3a48", "b": "#6a4a2a", "y": "#e8a840"}


def alberich(c, step):
    """Alberich (the Nibelungenlied, 3rd adventure): the strong dwarf who guarded the Nibelung hoard and owned the
    cloak of invisibility (the Tarnkappe) until Siegfried won it from him. A crowned dwarf with a long beard and a
    whip, the grey cloak over his shoulders."""
    for k, d in enumerate((-step, step)):
        c.rect(14 + k * 8 + d, 40, 17 + k * 8 + d, 46, "k")
    poly(c, [(8, 18), (32, 18), (36, 42), (4, 42)], "g")                                  # the Tarnkappe
    c.rect(12, 20, 28, 40, "r")
    ellipse(c, 20, 13, 7, 6, "s"); c.px(17, 12, "k"); c.px(23, 12, "k")
    poly(c, [(14, 15), (26, 15), (23, 36), (17, 36)], "w")
    c.rect(13, 4, 27, 7, "y"); c.px(14, 3, "y"); c.px(20, 2, "y"); c.px(26, 3, "y")      # crown
    for k in range(10):
        c.px(36 + k // 2, 20 + k * 2, "b")                                                  # his whip of gold knots
    c.px(38, 30, "y"); c.px(39, 36, "y")


ALBERICH_PAL = {"o": "#0a0808", "k": "#1a1410", "g": "#6a6e78", "r": "#5a2a4a", "s": "#d8b090", "w": "#e8e4dc",
                "y": "#f0c840", "b": "#6a4a2a"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_deep.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("dwarf_smith", dwarf_smith, DWARF_PAL, doc(dwarf_smith.__doc__), (20, 22), (10, 21), walk, folder="enemies")
    kit.build_boss("dwarf_hammerer", dwarf_hammerer, HAMMER_PAL, doc(dwarf_hammerer.__doc__), (26, 26), (12, 25), walk, folder="enemies")
    kit.build_boss("gullinbursti", gullinbursti, BOAR_PAL, doc(gullinbursti.__doc__), (60, 50), (28, 48), [0, 1, 0, -1, 0])
    kit.build_boss("brokkr", brokkr, BROKKR_PAL, doc(brokkr.__doc__), (48, 48), (20, 46), [0, 1, 0, -1, 0])
    kit.build_boss("andvari", andvari, ANDVARI_PAL, doc(andvari.__doc__), (44, 48), (20, 46), [0, 1, 0, -1, 0])
    kit.build_boss("svartalf", svartalf, SVART_PAL, doc(svartalf.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("nibelung", nibelung, NIB_PAL, doc(nibelung.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    kit.build_boss("alviss", alviss(False), ALVISS_PAL, doc(alviss.__doc__), (40, 48), (20, 46), [0, 1, 0, -1, 0])
    kit.build_boss("alviss_stone", alviss(True), ALVISS_PAL, doc(alviss.__doc__ + " Here, turned to stone."), (40, 48),
                   (20, 46), [0, 0, 0, 0, 0])
    kit.build_boss("fjalar_and_galar", fjalar_and_galar, FJALAR_PAL, doc(fjalar_and_galar.__doc__), (50, 46), (24, 44), [0, 1, 0, -1, 0])
    kit.build_boss("alberich", alberich, ALBERICH_PAL, doc(alberich.__doc__), (44, 48), (20, 46), [0, 1, 0, -1, 0])
    print("wrote the Deep Below's art")
