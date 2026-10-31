# Tomoe Gozen (docs/ART_RULES.md). Run: python3 tools/art/build_tomoe_gozen.py
# Writes data/art/tomoe_gozen.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("Tomoe Gozen (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_tomoe_gozen.py on the shared body in "
       "tools/art/hero_kit.py; rules in docs/ART_RULES.md. From The Tale of the Heike (Kakuichi text, Book 9), which "
       "describes her as beautiful, with fair skin and long hair, a strong archer and a warrior with the sword: long black "
       "hair tied back, and the armour of a Heike-era mounted warrior (lacquered plates laced with coloured cord, square "
       "shoulder guards, a plated skirt), white hakama trousers, shin guards, and sandals. Her weapon, a curved tachi for "
       "Sword and Bow, is drawn separately (data/art/weapons/) at her hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f2d6bc", "S": "#c8a088",                 # fair skin (the Heike: "white skin")
    "h": "#1a1418", "H": "#3e4458",                 # long black hair, highlight (also plate edges)
    "r": "#2c3040", "R": "#1a1c26",                 # dark lacquered armour plates
    "q": "#b42a2a", "y": "#d8b048",                 # red lacing cords, gold fittings
    "p": "#e8e2d4", "P": "#b8b0a0",                 # white hakama
    "i": "#6a6e78", "b": "#3a2a1c",                 # iron shin guards, sandals
}


def greaves(c, x0):
    """White hakama to the shin, iron shin guards, sandals."""
    c.rect(x0, 26, x0 + 2, 27, "p"); c.px(x0, 26, "P"); c.px(x0, 27, "P")
    c.rect(x0, 28, x0 + 2, 30, "i")
    c.row(31, x0, x0 + 3, "b")


def laced(c, x0, y0, x1, y1, every=3):
    """Armour plates joined by rows of red cord stitches (dotted, so they read as
    lacing, not stripes), with a lighter top edge on each row of plates."""
    c.rect(x0, y0, x1, y1, "r")
    for y in range(y0, y1 + 1, every):
        c.row(y, x0, x1, "H")
    for y in range(y0 + 1, y1 + 1, every):
        for x in range(x0, x1 + 1):
            if (x + y) % 2 == 0:
                c.px(x, y, "q")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    c.rect(7, 14, 8, 20, "R")                        # armoured sleeve on the far arm
    # Long black hair tied high at the back, falling down to her waist
    c.rect(7, 5, 9, 18, "h"); c.px(8, 6, "H"); c.px(8, 9, "H"); c.px(8, 12, "H")
    c.rect(8, 19, 9, 20, "h")
    c.row(2, 11, 15, "h"); c.row(3, 10, 16, "h"); c.row(4, 9, 16, "h")
    c.px(12, 3, "H"); c.px(14, 3, "H")
    c.rect(9, 4, 10, 5, "q")                         # the cord tying her hair
    # Fair face in profile, framed by a lock of hair
    c.rect(11, 5, 16, 10, "s"); c.rect(11, 5, 11, 10, "h"); c.rect(12, 5, 12, 10, "S")
    c.px(15, 7, "k"); c.px(17, 8, "s"); c.px(15, 9, "S")   # eye, nose, mouth
    c.rect(12, 11, 15, 12, "s"); c.px(12, 11, "S"); c.px(12, 12, "S")
    # Laced breastplate with a gold fitting
    laced(c, 10, 13, 17, 19)
    c.rect(10, 13, 11, 19, "R"); c.px(14, 13, "y")
    kit.weapon_arm(c)
    c.rect(18, 14, 19, 17, "R"); c.row(18, 19, 20, "R")   # armoured sleeve on the sword arm
    # Square shoulder guards (sode) laced in red: front and back
    laced(c, 17, 13, 20, 16); c.rect(17, 13, 17, 16, "R")
    laced(c, 6, 13, 9, 16)
    # Cord belt
    c.row(20, 10, 17, "q")
    # Plated skirt (kusazuri) to the knees in three panels, laced
    laced(c, 9, 21, 18, 25)
    for x in (12, 15):
        c.rect(x, 21, x, 25, "R")
    kit.legs(c, back_leg, front_leg, greaves)


if __name__ == "__main__":
    kit.build("tomoe_gozen", draw, PALETTE, DOC)
    print("wrote data/art/tomoe_gozen.json")
