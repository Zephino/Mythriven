# Set, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_set.py from tools/art/.
# Writes data/art/bosses/set.json.
import hero_kit as kit
from hero_kit import poly

DOC = ("Set, boss (GAME_DESIGN.md: The Two Lands bosses; art 10/31/2026). Built by tools/art/build_boss_set.py; "
       "rules in docs/ART_RULES.md. As Egyptian temple reliefs and papyri show him (for example at Karnak and Abydos): a "
       "man's body with the head of the 'Set animal', with its long curved snout and tall flat-topped ears, a striped "
       "wig, a broad beaded collar, a pleated linen kilt (shendyt) to the knee with a gold belt, and the was-sceptre, a "
       "staff topped with the Set animal's head and forked at the foot. Lord of the desert and storms (The Contendings "
       "of Horus and Set; Plutarch, On Isis and Osiris, which also gives him red colouring). Skin in the red-brown that "
       "Egyptian painting gives men.")

SIZE, ANCHOR = (46, 60), (22, 58)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#b8683e", "S": "#884624",                 # red-brown skin, as Egyptian painting shows men
    "a": "#8a3a26", "A": "#5e2416",                 # the Set animal's head, reddish
    "h": "#2a2a48", "H": "#4a4a78",                 # striped wig
    "b": "#3a6aa8", "r": "#b8402c", "u": "#e0b040", "U": "#a07a20",  # collar beads, gold
    "w": "#ece4d0", "W": "#bcb29c",                 # linen kilt
    "n": "#6a4a2a",                                 # sandals
    "y": "#f0d060",                                 # eye
}


def sceptre(c, x):
    """The was-sceptre: a straight gold staff, the Set animal's head on top, forked at the foot."""
    c.rect(x, 12, x + 1, 54, "U"); c.rect(x + 1, 12, x + 1, 54, "u")
    poly(c, [(x - 1, 9), (x + 2, 9), (x + 6, 12), (x + 5, 13), (x + 2, 12), (x - 1, 12)], "u")   # the head
    c.rect(x, 6, x, 9, "u"); c.rect(x + 2, 7, x + 2, 9, "u")                                       # its ears
    c.px(x + 3, 10, "k")
    c.px(x - 1, 55, "U"); c.px(x + 2, 55, "U"); c.px(x - 1, 56, "U"); c.px(x + 2, 56, "U")         # the fork


def draw(c, legs):
    back, front = legs
    # Far arm in shadow
    c.rect(12, 21, 13, 33, "S"); c.rect(12, 34, 13, 35, "s")
    # The striped wig falling behind his head to the shoulders
    poly(c, [(13, 9), (21, 7), (21, 21), (13, 21)], "h")
    for y in range(9, 22, 2):
        c.row(y, 13, 20, "H")
    # The Set animal's head: tall flat-topped ears, a long curved snout, a yellow eye
    c.rect(17, 1, 18, 8, "a"); c.rect(20, 0, 21, 8, "a"); c.row(0, 17, 18, "A"); c.row(0, 20, 21, "A")
    c.rect(17, 7, 25, 15, "a"); c.rect(17, 7, 18, 15, "A")
    poly(c, [(24, 10), (30, 11), (33, 14), (32, 16), (28, 14), (24, 15)], "a")
    c.px(32, 15, "A"); c.px(33, 15, "A"); c.row(14, 25, 30, "A")
    c.px(22, 10, "y"); c.px(23, 10, "k")
    c.rect(19, 16, 23, 18, "a")                                   # throat
    # Broad collar of beads: rows of blue, red and gold
    c.row(19, 15, 26, "b"); c.row(20, 14, 27, "u"); c.row(21, 14, 27, "r"); c.row(22, 15, 26, "b")
    # Bare chest and stomach
    c.rect(16, 23, 26, 33, "s"); c.rect(16, 23, 17, 33, "S")
    c.row(26, 19, 21, "S"); c.row(26, 23, 25, "S"); c.px(22, 29, "S"); c.px(22, 31, "S")
    # Gold belt and the pleated linen kilt to the knee, a gold front panel
    c.row(34, 15, 27, "u"); c.px(21, 34, "U")
    for y in range(35, 45):
        x0, x1 = (15, 27) if y < 41 else (14, 28)
        c.row(y, x0, x1, "w")
        for x in range(x0 + 1, x1, 2):
            c.px(x, y, "W")
    poly(c, [(22, 35), (26, 35), (27, 44), (23, 44)], "u"); c.rect(23, 36, 23, 43, "U")
    # Near arm, holding the was-sceptre upright
    c.rect(25, 21, 27, 27, "s"); c.rect(24, 22, 24, 27, "o")
    c.rect(27, 27, 31, 28, "s"); c.px(27, 28, "S")
    sceptre(c, 33)
    c.rect(31, 25, 34, 29, "s"); c.row(27, 31, 34, "S")          # fist round the staff
    c.row(24, 26, 27, "u")                                       # an armband
    # Legs and sandals
    for x0 in (back, front):
        c.rect(x0, 45, x0 + 3, 54, "s"); c.rect(x0, 45, x0, 54, "S")
        c.rect(x0, 55, x0 + 4, 56, "n")


if __name__ == "__main__":
    kit.build_boss("set", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/set.json")
