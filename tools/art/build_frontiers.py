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


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_frontiers.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("centaur_raider", centaur_raider, CENTAUR_PAL, doc(centaur_raider.__doc__), (24, 24), (12, 23), walk, folder="enemies")
    kit.build_boss("centaur_slinger", centaur_slinger, CENTAUR_PAL, doc(centaur_slinger.__doc__), (24, 24), (12, 23), walk, folder="enemies")
    kit.build_boss("eurytus", eurytus, CENTAUR_PAL, doc(eurytus.__doc__), (48, 46), (22, 44), [0, 1, 0, -1, 0])
    kit.build_boss("rhoetus", rhoetus, CENTAUR_PAL, doc(rhoetus.__doc__), (48, 46), (22, 44), [0, 1, 0, -1, 0])
    kit.build_boss("nessus", nessus, NESSUS_PAL, doc(nessus.__doc__), (48, 46), (22, 44), [0, 1, 0, -1, 0])
    print("wrote Wild Frontiers' art")
