# Ammit, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_ammit.py from tools/art/.
# Writes data/art/bosses/ammit.json.
import hero_kit as kit
from hero_kit import ellipse, poly

DOC = ("Ammit, boss (GAME_DESIGN.md: The Two Lands bosses; art 10/31/2026). Built by tools/art/build_boss_ammit.py; "
       "rules in docs/ART_RULES.md. From the Book of the Dead, spell 125 (the weighing of the heart), as painted in the "
       "Papyrus of Ani (British Museum EA 10470): the Devourer of the Dead, with the head of a crocodile, the forepart "
       "of a lion, and the hindquarters of a hippopotamus, waiting by the scales; her lion's mane painted in stripes. "
       "On four legs, jaws open.")

SIZE, ANCHOR = (80, 54), (36, 52)
WALK = [(0, 0), (2, -2), (0, 0), (-2, 2), (0, 0)]   # front pair, back pair

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "g": "#5a8a4a", "G": "#3a5e30", "v": "#c8c890",  # crocodile head: green scales, pale jaw
    "w": "#f0ead8", "r": "#8a2a20", "y": "#e8c040",  # teeth, mouth, eye
    "l": "#d4a458", "L": "#a87a38",                  # lion forepart
    "m": "#3a5a8a", "M": "#d8b048",                  # striped mane: blue and gold (Papyrus of Ani)
    "p": "#9a6e60", "P": "#6e4a40",                  # hippopotamus hindquarters
}


def lion_leg(c, x, col, shade):
    poly(c, [(x - 1, 31), (x + 5, 31), (x + 4, 40), (x + 4, 47), (x, 47), (x, 40)], col)
    c.rect(x, 47, x + 5, 48, shade); c.px(x + 5, 47, shade)


def hippo_leg(c, x, col, shade, edge=False):
    """A short, thick hippopotamus leg with a broad foot; `edge` gives it a dark line against the leg behind."""
    c.rect(x, 34, x + 5, 46, col); c.rect(x, 34, x, 46, shade)
    c.rect(x - 1, 47, x + 6, 48, shade)
    if edge:
        c.rect(x - 1, 38, x - 1, 46, "o")


def draw(c, legs):
    front, back = legs
    # Far legs (behind, in shadow)
    hippo_leg(c, 11 - back, "P", "P")
    lion_leg(c, 44 + front, "L", "L")
    # Hippopotamus hindquarters: a heavy, rounded rump and a short tail
    ellipse(c, 21, 28, 13, 10, "p")
    poly(c, [(8, 26), (5, 30), (6, 31), (9, 29)], "p")
    for x in range(8, 34):
        for y in range(17, 40):
            if c.g[y][x] == "p" and (y + 1 >= c.h or c.g[y + 1][x] == "." or c.g[y + 2][x] == "."):
                c.px(x, y, "P")
    # Lion forepart: a lean body and chest
    poly(c, [(28, 20), (46, 16), (55, 20), (56, 30), (50, 34), (32, 34), (28, 30)], "l")
    c.row(33, 33, 49, "L"); c.row(32, 36, 47, "L")
    for y in range(20, 34):                                             # tufts where lion fur meets hippo hide
        c.px(28 - (y % 3), y, "l" if y % 2 else "L")
    # The mane over her shoulders and neck, in stripes
    poly(c, [(47, 13), (56, 11), (59, 17), (57, 29), (52, 29), (47, 21)], "m")
    for y in range(11, 30, 3):
        for x in range(46, 61):
            if c.g[y][x] == "m":
                c.px(x, y, "M")
    # Near legs
    hippo_leg(c, 21 + back, "p", "P", edge=True)
    lion_leg(c, 50 - front, "l", "L")
    # Crocodile head: a long flat snout, jaws open with teeth, a yellow eye
    poly(c, [(55, 10), (63, 9), (66, 13), (64, 17), (56, 18)], "g")       # skull
    c.px(60, 8, "g"); c.px(61, 8, "g"); c.px(62, 9, "G")                  # the bump over the eye
    poly(c, [(62, 11), (75, 13), (75, 16), (63, 17)], "g")                # upper jaw
    poly(c, [(60, 19), (74, 21), (73, 24), (60, 23)], "v")                # lower jaw, pale
    poly(c, [(63, 17), (75, 16), (74, 21), (61, 19)], "r")                # open mouth
    for x in range(64, 75, 2):
        c.px(x, 17, "w"); c.px(x + 1, 20, "w")                             # teeth
    c.row(11, 63, 74, "G"); c.px(74, 13, "k")                             # ridged snout, nostril
    for x in range(56, 64, 2):
        c.px(x, 13 + (x % 4) // 2, "G")                                    # scales
    c.px(61, 11, "y"); c.px(62, 11, "k")


if __name__ == "__main__":
    kit.build_boss("ammit", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/ammit.json")
