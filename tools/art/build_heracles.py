# Heracles (docs/ART_RULES.md). Run: python3 tools/art/build_heracles.py
# Writes data/art/heracles.json. The shared body (arms, hand, legs, walk,
# outline) comes from hero_kit.py; this draws what's his own.
import hero_kit as kit

DOC = ("Heracles (GAME_DESIGN.md: Heroes; owner-approved art style, 10/31/2026). Built by tools/art/build_heracles.py "
       "on the shared body in tools/art/hero_kit.py; rules in docs/ART_RULES.md. Iconography from Greek vase painting "
       "and Pseudo-Apollodorus (Bibliotheca 2.5.1): the Nemean lion's skin worn as a hood (its head over his), its paws "
       "knotted at the throat (no cloak behind him, owner request); a beard; a short chiton; sandals. His weapon is drawn "
       "separately (data/art/weapons/) at his hand.")

PALETTE = {
    "o": "#24160e", "l": "#d6a040", "L": "#a06a24", "m": "#6e4216", "w": "#f6efe0", "k": "#140c08",
    "s": "#e2a676", "S": "#b0724a", "h": "#3e2414", "H": "#2a180c",
    "r": "#a83a2c", "R": "#7a2620", "b": "#5c3a1c", "y": "#d8b048",
}


def sandals(c, x0):
    c.row(28, x0, x0 + 2, "b"); c.px(x0 + 1, 29, "b")
    c.row(31, x0, x0 + 3, "b")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    # Lion head hood: ear, the lion's eye, brow and snout over his forehead, teeth at the tip
    c.row(1, 10, 11, "m")
    c.row(2, 9, 15, "l"); c.px(10, 2, "L")
    c.row(3, 9, 16, "l")
    c.row(4, 9, 17, "l"); c.px(15, 3, "k")
    c.row(5, 9, 18, "L")
    c.row(6, 9, 18, "L"); c.px(9, 5, "m"); c.px(9, 6, "m")
    c.px(17, 7, "w"); c.px(18, 7, "w")
    c.row(7, 10, 16, "L")
    # Face in profile: eye, nose
    c.rect(11, 8, 16, 10, "s"); c.rect(11, 8, 12, 10, "S")
    c.px(15, 9, "k"); c.px(17, 9, "s")
    # Short beard
    c.rect(12, 11, 16, 12, "h"); c.px(12, 11, "H"); c.px(12, 12, "H"); c.px(16, 11, "s")
    # Neck and the lion's paws knotted at the throat
    c.row(13, 11, 16, "s"); c.px(12, 13, "l"); c.px(13, 13, "l"); c.px(14, 13, "L"); c.px(15, 13, "l")
    # Bare, muscled chest with chest and stomach lines
    c.rect(10, 14, 17, 19, "s"); c.rect(10, 14, 11, 19, "S")
    c.row(16, 12, 13, "S"); c.row(16, 15, 16, "S"); c.px(14, 17, "S"); c.px(14, 18, "S")
    kit.weapon_arm(c)
    # Belt with a bronze buckle
    c.row(20, 10, 17, "b"); c.px(14, 20, "y")
    # Dark red chiton to the knees, flaring a little, with folds
    for y in range(21, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "r")
        for x in range(x0 + 1, x1, 3):
            c.px(x, y, "R")
    c.row(25, 9, 18, "R")
    kit.legs(c, back_leg, front_leg, sandals)


if __name__ == "__main__":
    kit.build("heracles", draw, PALETTE, DOC)
    print("wrote data/art/heracles.json")
