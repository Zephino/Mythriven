# Odysseus (docs/ART_RULES.md). Run: python3 tools/art/build_odysseus.py
# Writes data/art/odysseus.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("Odysseus (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_odysseus.py on the shared body in "
       "tools/art/hero_kit.py; rules in docs/ART_RULES.md. The pilos, the pointed felt cap of a sailor and traveller, is "
       "how Greek vase painting and sculpture mark Odysseus; a dark beard (Odyssey 16.176). From Odyssey 19.225-232, "
       "the clothes he wore to Troy: a purple woollen cloak fastened with a gold brooch, and a shining tunic, shown here "
       "as a purple tunic to the knees with a gold brooch at the shoulder. A belt and sandals. Mediterranean skin. His "
       "great bow (Odyssey 21) is drawn separately (data/art/weapons/) at his hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#e2a676", "S": "#b0724a",                 # Mediterranean skin, as the other Greek Heroes
    "h": "#3a2414", "H": "#22140a",                 # dark hair and beard
    "p": "#9a7a4e", "P": "#6a5030",                 # felt pilos cap
    "r": "#6a2c5a", "R": "#4a1c3e",                 # purple tunic
    "y": "#d8b048",                                 # gold brooch and buckle
    "b": "#5c3a1c",                                 # belt and sandals
}


def sandals(c, x0):
    c.row(28, x0, x0 + 2, "b"); c.px(x0 + 1, 29, "b")
    c.row(31, x0, x0 + 3, "b")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    # The pilos: a pointed felt cap with a rim
    c.px(13, 0, "p"); c.row(1, 12, 14, "p"); c.row(2, 12, 15, "p"); c.row(3, 11, 15, "p"); c.row(4, 11, 16, "p")
    c.row(5, 10, 16, "p"); c.row(6, 10, 17, "P")
    c.rect(11, 1, 12, 5, "P"); c.px(12, 1, "p")
    # Dark hair under the cap at the back
    c.rect(9, 7, 11, 10, "h"); c.rect(9, 7, 9, 10, "H")
    # Face: forehead, eye, nose
    c.rect(12, 7, 16, 10, "s"); c.px(12, 8, "S"); c.px(12, 9, "S")
    c.px(15, 9, "k"); c.px(17, 9, "s")
    # Dark beard
    c.rect(11, 11, 16, 12, "h"); c.px(11, 11, "H"); c.px(11, 12, "H"); c.px(16, 11, "s")
    c.row(13, 11, 16, "s")
    # Purple tunic to the knees with folds, a gold brooch at the shoulder
    for y in range(14, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "r")
        if y > 20:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "R")
    c.rect(10, 14, 11, 19, "R"); c.px(14, 16, "R"); c.px(14, 17, "R")
    c.row(25, 9, 18, "R")
    c.px(16, 14, "y")
    c.row(20, 10, 17, "b"); c.px(14, 20, "y")
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, sandals)


if __name__ == "__main__":
    kit.build("odysseus", draw, PALETTE, DOC)
    print("wrote data/art/odysseus.json")
