# King Arthur (docs/ART_RULES.md). Run: python3 tools/art/build_king_arthur.py
# Writes data/art/king_arthur.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("King Arthur (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_king_arthur.py on the shared body in "
       "tools/art/hero_kit.py; rules in docs/ART_RULES.md. From Malory, Le Morte d'Arthur (book 1 ch. 25: Excalibur and its "
       "scabbard, worn here at his side) and Geoffrey of Monmouth (Historia Regum Britanniae 9.4: armed in a coat of mail), "
       "with the crown and short beard of the medieval Nine Worthies pictures. A gold crown, a coat of mail under a blue "
       "surcoat with a gold crown on the chest (the three crowns on blue given to Arthur in medieval rolls of arms, shown as "
       "one at this size), mail on arms and legs, leather boots. Fair skin of Britain. Excalibur is drawn separately "
       "(data/art/weapons/) at his hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f0c8a8", "S": "#c49478",                 # fair skin of Britain
    "h": "#6a4426", "H": "#4a2e18",                 # brown hair and beard
    "u": "#e8c050", "U": "#a88028",                 # gold crown and fittings
    "i": "#a8acb4", "I": "#6c727c",                 # mail
    "d": "#2c4c8c", "D": "#1c3264",                 # blue surcoat
    "b": "#5c3a1c", "B": "#3c2410",                 # leather belt, scabbard, boots
}


def mail(c, x0, y0, x1, y1):
    """Skin in this box becomes mail: rows of rings, light and dark rows in turn (a dotted checker reads as noise)."""
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if c.g[y][x] in ("s", "S"):
                c.px(x, y, "I" if y % 2 == 0 or c.g[y][x] == "S" else "i")


def boots(c, x0):
    mail(c, x0, 26, x0 + 2, 28)
    c.rect(x0, 29, x0 + 2, 30, "b"); c.px(x0, 29, "B")
    c.row(31, x0, x0 + 3, "B")


def draw(c, back_leg, front_leg):
    # The scabbard (Malory 1.25) hanging from the belt on his far hip, angled back, with gold fittings
    for y in range(21, 29):
        x = 8 - (y - 21) // 2
        c.px(x, y, "b"); c.px(x - 1, y, "B")
    c.row(21, 7, 9, "u"); c.px(4, 28, "u"); c.px(5, 28, "u")
    kit.far_arm(c)
    mail(c, 7, 14, 8, 20)
    # Brown hair, gold crown with three points
    c.row(3, 11, 15, "h"); c.row(4, 10, 16, "h")
    c.px(10, 3, "u"); c.px(13, 2, "u"); c.px(16, 3, "u"); c.px(13, 3, "u")
    c.row(4, 10, 16, "u"); c.row(5, 10, 16, "u"); c.px(10, 5, "U"); c.px(11, 5, "U")
    c.px(12, 4, "U"); c.px(15, 4, "U")
    c.rect(9, 6, 11, 11, "h"); c.rect(9, 6, 9, 11, "H")
    # Face: forehead, eye, nose; short beard
    c.rect(12, 6, 16, 10, "s"); c.px(12, 7, "S"); c.px(12, 8, "S")
    c.px(15, 8, "k"); c.px(17, 8, "s")
    c.rect(12, 11, 16, 12, "h"); c.px(12, 11, "H"); c.px(12, 12, "H"); c.px(16, 11, "s"); c.px(15, 11, "S")
    # Mail at the neck, then the blue surcoat to the knees
    c.row(13, 11, 16, "i"); c.px(12, 13, "I"); c.px(14, 13, "I")
    for y in range(14, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "d")
        c.px(x0, y, "D")
    c.rect(11, 14, 11, 19, "D")
    for y in range(21, 26):
        c.px(14, y, "D")                                 # the split at the front
    c.row(25, 9, 18, "D")
    # A gold crown on the chest
    c.px(12, 15, "u"); c.px(14, 15, "u"); c.px(16, 15, "u"); c.row(16, 12, 16, "u")
    # Belt with a gold buckle
    c.row(20, 10, 17, "b"); c.px(14, 20, "u")
    kit.weapon_arm(c)
    mail(c, 18, 14, 20, 18)
    kit.legs(c, back_leg, front_leg, boots)


if __name__ == "__main__":
    kit.build("king_arthur", draw, PALETTE, DOC)
    print("wrote data/art/king_arthur.json")
