# Thor, god (docs/ART_RULES.md: Gods). Run: python3 build_god_thor.py from tools/art/.
# Writes data/art/gods/thor.json.
import hero_kit as kit
from hero_kit import poly

DOC = ("Thor, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_thor.py; rules in "
       "docs/ART_RULES.md. From Snorri Sturluson's Prose Edda (Gylfaginning 21: his three treasures, the hammer "
       "Mjollnir, the belt of strength Megingjord, and the iron gloves he needs to grip the hammer; Skaldskaparmal 35: "
       "the hammer's handle is rather short) and the sagas' red-bearded Thor. The hammer's shape follows Viking Age "
       "Thor's-hammer pendants. Viking Age dress: a tunic, trousers with leg wraps, leather shoes. The gold crown is the owner's choice "
       "(10/31/2026), not from the sources. Not based on any modern version (GAME_DESIGN.md: never Marvel's Thor: no winged helmet, no red cape).")

SIZE, ANCHOR = (52, 62), (22, 60)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#ecbe98", "S": "#bc8c6a",                 # fair Norse skin
    "h": "#b8482a", "H": "#80301c",                 # red hair and beard
    "t": "#4a5a7a", "T": "#323e58",                 # blue-grey wool tunic
    "y": "#c8a048",                                 # woven border
    "m": "#6a4a2a", "M": "#4a3018", "u": "#d8b048", "U": "#a07a20",  # belt of strength; gold and its shadow
    "i": "#8a8e96", "I": "#5c6068",                 # iron gloves, hammer head
    "w": "#7a5030",                                 # hammer's short wooden handle
    "p": "#5a5048", "P": "#3e3630", "l": "#c8b48a",  # trousers, leg wraps
    "b": "#4a2e16",                                 # shoes
}


def hammer(c):
    """Mjollnir, raised and held clear of his head: a short handle and an iron head flaring at both ends, like the
    Viking Age pendants."""
    c.rect(39, 15, 40, 28, "w")
    poly(c, [(34, 8), (45, 8), (47, 6), (48, 16), (46, 14), (33, 14), (31, 16), (32, 6)], "i")
    c.row(14, 33, 46, "I"); c.rect(32, 6, 32, 16, "I")
    c.row(10, 35, 44, "I"); c.px(39, 12, "u"); c.px(40, 12, "u")      # a knotwork band, a gold boss


def draw(c, legs):
    back, front = legs
    # Far arm
    c.rect(12, 22, 14, 36, "S"); c.rect(12, 37, 14, 39, "I")
    # Red hair falling to his shoulders, a full red beard
    c.row(5, 17, 22, "h"); c.row(6, 15, 24, "h"); c.rect(14, 7, 25, 9, "h"); c.rect(13, 9, 18, 20, "h")
    c.rect(13, 9, 14, 20, "H"); c.row(6, 17, 21, "H")
    # A gold crown on his red hair (owner request 10/31/2026; not in the sources), with a dark line under it so it
    # stands apart from his head, as on King Arthur
    c.rect(15, 3, 24, 5, "u"); c.row(5, 15, 24, "U"); c.row(6, 15, 24, "o")
    for x in (15, 19, 23):
        c.rect(x, 1, x + 1, 2, "u")
    c.px(19, 4, "y"); c.px(20, 4, "y")
    # Face: a heavy brow, a fierce eye, a strong nose
    c.rect(19, 10, 26, 16, "s"); c.rect(19, 10, 20, 16, "S")
    c.row(11, 22, 26, "H"); c.px(24, 12, "k"); c.px(27, 13, "s"); c.px(27, 14, "s")
    # Full beard, two rows over the chest (rules: facial hair under the eye)
    poly(c, [(19, 15), (27, 15), (27, 20), (24, 24), (20, 22)], "h")
    c.row(18, 21, 26, "H"); c.row(21, 21, 24, "H")
    # Blue-grey tunic to the knee with a woven border
    for y in range(20, 43):
        x0, x1 = (15, 27) if y < 38 else (14, 28)
        c.row(y, x0, x1, "t")
        if y > 33:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "T")
    c.rect(15, 20, 16, 37, "T")
    c.row(42, 14, 28, "y")
    poly(c, [(19, 15), (27, 15), (27, 20), (24, 24), (20, 22)], "h")
    c.row(18, 21, 26, "H"); c.row(21, 21, 24, "H")
    # Megingjord, the belt of strength: wide leather with gold fittings
    c.rect(15, 31, 27, 33, "m"); c.row(33, 15, 27, "M")
    for x in (17, 21, 25):
        c.px(x, 32, "u")
    # Near arm raising Mjollnir, the hand in an iron glove
    c.rect(26, 21, 28, 27, "s"); c.rect(25, 22, 25, 27, "o")
    c.rect(28, 27, 36, 29, "s"); c.row(29, 28, 36, "S")
    hammer(c)
    c.rect(37, 25, 42, 30, "i"); c.row(30, 37, 42, "I")          # iron glove round the handle
    # Trousers with leg wraps, shoes
    for x0 in (back, front):
        c.rect(x0, 43, x0 + 3, 55, "p"); c.rect(x0, 43, x0, 55, "P")
        for y in range(47, 56, 2):
            c.row(y, x0, x0 + 3, "l")
        c.rect(x0, 56, x0 + 4, 57, "b")


if __name__ == "__main__":
    kit.build_boss("thor", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods")
    print("wrote data/art/gods/thor.json")
