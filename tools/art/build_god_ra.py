# Ra, god (docs/ART_RULES.md: Gods). Run: python3 build_god_ra.py from tools/art/.
# Writes data/art/gods/ra.json.
import hero_kit as kit
from hero_kit import ellipse, poly

DOC = ("Ra, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_ra.py; rules in docs/ART_RULES.md. "
       "From the Book of the Heavenly Cow and the Amduat (the sun god who sails through the underworld each night), as "
       "Egyptian tomb paintings and papyri show Ra-Horakhty: a man with the head of a falcon, the sun disk circled by a "
       "rearing cobra on his head, a striped wig, a broad collar, a pleated kilt with a gold belt, the was-sceptre and "
       "an ankh.")

SIZE, ANCHOR = (50, 68), (22, 66)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "f": "#6a7a8a", "F": "#3e4a58", "l": "#e8e0c8",  # falcon head: slate feathers, pale cheek
    "s": "#b8683e", "S": "#884624",                 # red-brown skin (Egyptian painting)
    "h": "#2a2a48", "H": "#4a4a78",                 # striped wig
    "u": "#f0b030", "U": "#c07818", "e": "#e85020",  # sun disk, cobra
    "b": "#3a6aa8", "r": "#b8402c", "g": "#e0b040", "G": "#a07a20",  # collar, gold
    "w": "#ece4d0", "W": "#bcb29c",                 # linen kilt
    "y": "#f0d060",
}


def draw(c, legs):
    back, front = legs
    d = 6
    # The sun disk, the cobra rearing at its front
    ellipse(c, 20.5, 5, 5.5, 5, "u"); ellipse(c, 19, 3.5, 2.5, 2, "U")
    c.rect(26, 4, 27, 10, "e"); c.px(27, 3, "e"); c.px(28, 4, "e")
    # Striped wig falling behind to the shoulders
    poly(c, [(14, 9 + d - 1), (22, 7 + d - 1), (22, 21 + d), (14, 21 + d)], "h")
    for y in range(9 + d, 22 + d, 2):
        c.row(y, 14, 21, "H")
    # Falcon head: round crown, a hooked beak, the dark 'tear' mark under the eye
    ellipse(c, 23, 12 + d, 5, 4.5, "f")
    poly(c, [(26, 10 + d), (31, 12 + d), (30, 15 + d), (28, 15 + d), (26, 14 + d)], "g")   # beak
    c.px(30, 15 + d, "G"); c.px(29, 15 + d, "G")
    c.rect(21, 14 + d, 25, 17 + d, "l"); c.px(24, 14 + d, "F"); c.px(24, 15 + d, "F"); c.px(23, 16 + d, "F")
    c.px(25, 11 + d, "y"); c.px(26, 11 + d, "k")
    c.rect(20, 17 + d, 24, 19 + d, "f")
    # Broad collar, bare chest
    c.row(20 + d, 16, 27, "b"); c.row(21 + d, 15, 28, "g"); c.row(22 + d, 15, 28, "r"); c.row(23 + d, 16, 27, "b")
    c.rect(12, 23 + d, 14, 36 + d, "S"); c.rect(12, 37 + d, 14, 38 + d, "s")
    c.rect(16, 24 + d, 27, 35 + d, "s"); c.rect(16, 24 + d, 17, 35 + d, "S")
    c.row(27 + d, 19, 21, "S"); c.row(27 + d, 23, 25, "S")
    # Gold belt and pleated kilt
    c.row(36 + d, 15, 28, "g"); c.px(22, 36 + d, "G")
    for y in range(37 + d, 47 + d):
        c.row(y, 15, 28, "w")
        for x in range(16, 28, 2):
            c.px(x, y, "W")
    poly(c, [(22, 37 + d), (26, 37 + d), (27, 46 + d), (23, 46 + d)], "g")
    # Near arm with the was-sceptre
    c.rect(26, 24 + d, 28, 30 + d, "s"); c.rect(25, 25 + d, 25, 30 + d, "o"); c.row(27 + d, 26, 28, "g")
    c.rect(28, 30 + d, 33, 32 + d, "s"); c.row(32 + d, 28, 33, "S")
    c.rect(35, 10 + d, 36, 58 + d, "G"); c.rect(36, 10 + d, 36, 58 + d, "g")
    poly(c, [(34, 7 + d), (37, 7 + d), (41, 10 + d), (40, 11 + d), (37, 10 + d), (34, 10 + d)], "g")
    c.px(34, 59 + d, "G"); c.px(37, 59 + d, "G")
    c.rect(33, 29 + d, 37, 33 + d, "s"); c.row(33 + d, 33, 37, "S")
    # Legs and sandals
    for x0 in (back, front):
        c.rect(x0, 47 + d, x0 + 3, 57 + d, "s"); c.rect(x0, 47 + d, x0, 57 + d, "S")
        c.rect(x0, 58 + d, x0 + 4, 59 + d, "G")


if __name__ == "__main__":
    kit.build_boss("ra", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods",
                  seated={"style": "egyptian", "hip": 50, "lap": "w", "shin": "s", "foot": "G", "keep": range(33, 42)})
    print("wrote data/art/gods/ra.json")
