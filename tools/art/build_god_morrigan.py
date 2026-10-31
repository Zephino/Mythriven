# The Morrígan, god (docs/ART_RULES.md: Gods). Run: python3 build_god_morrigan.py from tools/art/.
# Writes data/art/gods/morrigan.json.
import hero_kit as kit
from hero_kit import ellipse, poly

DOC = ("The Morrígan, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_morrigan.py; rules in "
       "docs/ART_RULES.md. From the Táin Bó Cúailnge (she comes to the Brown Bull as a bird, and to Cú Chulainn in many "
       "shapes) and Táin Bó Regamna (a red-haired woman in a red cloak); Cath Maige Tuired (she foretells the battle). "
       "Shown as the woman in the red cloak, with red hair, a dark dress, a grey spear, and a hooded crow, her bird "
       "shape, on her shoulder.")

SIZE, ANCHOR = (50, 62), (22, 60)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f0d0b8", "S": "#c4a08a",                 # pale skin
    "h": "#b8402a", "H": "#80281c",                 # red hair
    "r": "#a82a2a", "R": "#701818",                 # red cloak
    "d": "#2e2a3a", "D": "#1e1a28",                 # dark dress
    "c": "#3a3a40", "C": "#8a8a90", "y": "#d8a040",  # hooded crow: black, grey body, beak
    "w": "#9aa0a8", "W": "#6a4a2a",                 # grey spear head, shaft
    "b": "#3a2a1c",                                 # shoes
}


def draw(c, legs):
    back, front = legs
    # Red cloak hanging behind her to the ground
    poly(c, [(14, 17), (20, 17), (20, 56), (8, 58), (10, 30)], "r")
    for y in range(22, 58, 3):
        c.px(12, y, "R"); c.px(16, y + 1, "R")
    # Far arm
    c.rect(13, 21, 15, 34, "S")
    # Long red hair down her back
    c.row(4, 18, 24, "h"); c.rect(15, 5, 26, 8, "h"); c.rect(13, 8, 19, 26, "h")
    c.rect(13, 8, 14, 26, "H"); c.px(12, 20, "h"); c.px(12, 24, "h")
    # Face: forehead, eye, red brows (Táin Bó Regamna), nose
    c.rect(19, 9, 26, 16, "s"); c.rect(19, 9, 20, 16, "S")
    c.row(10, 22, 25, "h"); c.px(24, 11, "k"); c.px(27, 12, "s"); c.px(27, 13, "s"); c.row(15, 22, 24, "S")
    c.rect(20, 17, 24, 18, "s")
    # The hooded crow on her far shoulder: black head and wings, grey body, a dark beak
    ellipse(c, 15, 15, 2.6, 2.2, "c"); c.px(15, 14, "k"); c.px(14, 14, "C")
    poly(c, [(17, 14), (20, 15), (17, 16)], "y")
    ellipse(c, 14, 19, 3.5, 2.6, "C"); poly(c, [(10, 18), (16, 18), (12, 23), (9, 22)], "c")
    # Dark dress to the ankle, a red cloak's edge over her shoulders, a brooch
    for y in range(20, 56):
        x0, x1 = (16, 27) if y < 42 else (15 - (y - 42) // 7, 28 + (y - 42) // 7)
        c.row(y, x0, x1, "d")
        if y > 34:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "D")
    c.rect(16, 20, 18, 55, "r"); c.rect(16, 20, 16, 55, "R")
    c.row(20, 19, 26, "r"); c.px(20, 21, "w")
    c.row(31, 17, 27, "D")
    # Near arm holding a grey spear upright
    c.rect(26, 21, 28, 27, "s"); c.rect(25, 22, 25, 27, "o")
    c.rect(28, 27, 32, 29, "s"); c.row(29, 28, 32, "S")
    c.rect(34, 8, 35, 56, "W")
    poly(c, [(33, 8), (36, 8), (35, 1), (34, 1)], "w"); c.px(34, 0, "w")
    c.rect(32, 26, 36, 30, "s"); c.row(30, 32, 36, "S")
    # Shoes
    for x0 in (back, front):
        c.rect(x0, 56, x0 + 4, 58, "b")


if __name__ == "__main__":
    kit.build_boss("morrigan", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods",
                  seated={"style": "celtic", "hip": 40, "lap": "d", "shin": "d", "foot": "b", "keep": range(32, 38)})
    print("wrote data/art/gods/morrigan.json")
