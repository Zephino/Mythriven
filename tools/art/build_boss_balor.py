# Balor, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_balor.py from tools/art/.
# Writes data/art/bosses/balor.json.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

DOC = ("Balor, boss (GAME_DESIGN.md: The Misty Isles bosses; art 10/31/2026). Built by tools/art/build_boss_balor.py; "
       "rules in docs/ART_RULES.md. From Cath Maige Tuired (The Second Battle of Mag Tuired): the old Fomorian king with "
       "the destroying eye, which was never opened except on the battlefield, when four men lifted its lid with a "
       "polished handle passed through it, and any host that looked on it was overcome, until Lugh's sling-stone drove "
       "the eye out through his head. A huge, grim old giant: one great eye under a heavy lid, the handle through the "
       "lid, the eye glowing; long dark hair and beard; a dark mantle, a studded leather war-belt and kilt. As big as "
       "Kronos and Surtr.")

SIZE, ANCHOR = (70, 78), (30, 76)
STANCE = (24, 33)
WALK = [STANCE, (22, 35), STANCE, (26, 31), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#c4b0a0", "S": "#907a6a",                 # an old giant's grey-pale skin
    "h": "#2e2a2a", "H": "#4a4444",                 # long dark hair and beard
    "L": "#a08878",                                 # the heavy eyelid
    "e": "#ff5020", "E": "#ffd060",                 # the destroying eye, glowing
    "i": "#b8bcc4", "I": "#6c7078",                 # the polished handle
    "m": "#2e4a3a", "M": "#1e3226",                 # dark green mantle
    "b": "#5a3a20", "B": "#3a2412",                 # leather kilt and belt, boots
    "g": "#c89a3c",                                 # bronze studs
}


def draw(c, legs):
    back, front = legs
    # Mantle hanging behind him from his shoulders
    poly(c, [(18, 22), (24, 21), (24, 62), (12, 64), (14, 40)], "m")
    for y in range(26, 64, 1):
        c.px(16 + (y % 5 == 0), y, "M")
    # Far arm
    c.rect(19, 27, 22, 50, "S"); c.rect(19, 51, 22, 54, "s")
    # Long dark hair down his back
    poly(c, [(22, 5), (28, 2), (36, 2), (41, 7), (30, 9), (26, 26), (19, 26), (20, 10)], "h")
    c.rect(21, 10, 23, 25, "H"); c.rect(26, 22, 28, 27, "h")
    # Head: a heavy brow, the great eye under its lid, a big nose
    c.rect(27, 7, 41, 21, "s"); c.rect(27, 7, 29, 21, "S")
    c.row(7, 28, 40, "h")
    ellipse(c, 35.5, 12.5, 3.6, 2.4, "e")                       # the eye
    c.rect(34, 12, 37, 13, "E"); c.px(35, 12, "k"); c.px(36, 12, "k")
    poly(c, [(31, 9), (40, 9), (40, 11), (31, 11)], "L")        # the heavy lid, half raised
    c.row(15, 32, 39, "S"); c.row(8, 30, 40, "S")             # under the eye, the brow
    # The polished handle passed through the lid, jutting forward
    c.rect(38, 9, 46, 10, "i"); c.row(10, 38, 46, "I"); c.rect(46, 7, 47, 12, "i"); c.px(47, 12, "I")
    c.rect(42, 15, 43, 18, "s"); c.px(43, 18, "S")              # nose
    # Massive body: a leather war-belt studded with bronze, a kilt to the knees
    c.rect(23, 26, 43, 46, "s"); c.rect(23, 26, 26, 46, "S")
    poly(c, [(28, 19), (41, 19), (40, 30), (35, 36), (30, 30)], "h")
    for y in (23, 27, 31):
        c.row(y, 31, 38, "H")
    c.row(38, 30, 34, "S"); c.row(38, 37, 41, "S"); c.px(35, 41, "S")
    c.row(19, 37, 41, "S")                                     # the line of his mouth above the beard
    c.rect(22, 46, 44, 48, "B")
    for x in range(24, 44, 3):
        c.px(x, 47, "g")
    for y in range(49, 62):
        x0, x1 = (22, 44) if y < 57 else (21, 45)
        c.row(y, x0, x1, "b")
        for x in range(x0 + 2, x1, 4):
            c.px(x, y, "B")
    c.rect(22, 49, 24, 61, "B")
    # Near arm, reaching forward with an open hand
    c.rect(42, 27, 45, 37, "s"); c.rect(41, 28, 41, 37, "o")
    c.rect(45, 36, 52, 39, "s"); c.row(39, 45, 52, "S")
    c.rect(52, 34, 56, 40, "s"); c.px(57, 34, "s"); c.px(57, 36, "s"); c.px(57, 38, "s"); c.row(40, 52, 56, "S")
    # Legs and boots
    for x0 in (back, front):
        c.rect(x0, 62, x0 + 6, 70, "s"); c.rect(x0, 62, x0 + 1, 70, "S")
        c.rect(x0, 70, x0 + 7, 74, "B"); c.row(70, x0, x0 + 6, "b")


if __name__ == "__main__":
    kit.build_boss("balor", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/balor.json")
