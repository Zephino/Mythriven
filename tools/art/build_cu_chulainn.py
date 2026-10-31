# Cú Chulainn (docs/ART_RULES.md). Run: python3 tools/art/build_cu_chulainn.py
# Writes data/art/cu_chulainn.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("Cú Chulainn (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_cu_chulainn.py on the shared "
       "body in tools/art/hero_kit.py; rules in docs/ART_RULES.md. From the Táin Bó Cúailnge (Book of Leinster "
       "description of him): hair of three colours, dark at the roots, blood-red in the middle, gold at the tips; "
       "young and beardless; a crimson mantle fastened with a brooch over a white tunic with red embroidery. Not "
       "based on any modern version (GAME_DESIGN.md: avoid the Fate/Grand Order design). His weapon, the Gáe Bolg, "
       "is drawn separately (data/art/weapons/) at his hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f0c49a", "S": "#c48e66",                 # fair skin
    "h": "#3a2414", "q": "#b02a20", "u": "#e8c04a",  # hair: dark roots, blood-red middle, gold tips
    "r": "#d8c8a0", "R": "#a8966e",                 # linen tunic (léine)
    "m": "#8a2042", "M": "#5a1430",                 # crimson mantle
    "y": "#d8b048", "b": "#5c3a1c",                 # gold brooch / leather belt and shoes
}


def shoes(c, x0):
    c.px(x0 + 1, 29, "b")                            # ankle tie
    c.row(30, x0, x0 + 2, "b"); c.row(31, x0, x0 + 3, "b")


# Head centre, and the spike tips of his hair (swept up and back).
HEAD = (13.5, 7.5)
SPIKES = [(17, 1), (13, 0), (9, 0), (5, 2), (3, 6), (4, 10)]


def _inside(p, a, b, c):
    def side(p1, p2, p3):
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])
    d1, d2, d3 = side(p, a, b), side(p, b, c), side(p, c, a)
    return not ((d1 < 0 or d2 < 0 or d3 < 0) and (d1 > 0 or d2 > 0 or d3 > 0))


def hair(c):
    """A solid mass of hair with a spiky edge, coloured outward from the scalp in
    the Táin's three colours: dark at the roots, blood-red, gold at the tips."""
    import math
    cx, cy = HEAD
    for y in range(0, 13):
        for x in range(2, 19):
            d = math.hypot(x - cx, y - cy)
            # The skull (covered in hair), plus a wedge for each spike.
            inside = d <= 4.6 and (x <= 12 or y <= 4)
            for i, tip in enumerate(SPIKES):
                angle = math.atan2(tip[1] - cy, tip[0] - cx)
                base1 = (cx + 3.6 * math.cos(angle - 0.75), cy + 3.6 * math.sin(angle - 0.75))
                base2 = (cx + 3.6 * math.cos(angle + 0.75), cy + 3.6 * math.sin(angle + 0.75))
                inside = inside or _inside((x, y), tip, base1, base2)
            if inside:
                c.px(x, y, "h" if d < 4.8 else ("q" if d < 6.6 else "u"))


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    hair(c)
    # Young, beardless face in profile
    c.rect(11, 5, 16, 10, "s"); c.rect(11, 5, 11, 10, "S")
    c.px(15, 7, "k"); c.px(17, 7, "s")               # eye, nose
    c.px(15, 9, "S")                                 # mouth
    # Neck
    c.rect(12, 11, 15, 12, "s"); c.px(12, 11, "S"); c.px(12, 12, "S")
    # Cream tunic with a red-embroidered neckline
    c.rect(10, 14, 17, 19, "r"); c.rect(10, 14, 11, 19, "R")
    c.row(15, 12, 15, "q"); c.rect(16, 15, 16, 19, "q")   # red embroidery at the neck and down the front edge
    kit.weapon_arm(c)
    # Crimson mantle over both shoulders, its back draping down, a gold brooch at the chest
    c.row(12, 10, 17, "m")
    c.row(13, 8, 19, "m"); c.row(14, 8, 19, "M")
    c.rect(8, 15, 9, 17, "m"); c.px(8, 17, "M")
    c.px(14, 13, "y")
    # Leather belt
    c.row(20, 10, 17, "b"); c.px(14, 20, "y")
    # Tunic to the knees with folds and a red-embroidered hem
    for y in range(21, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "r")
        for x in range(x0 + 1, x1, 3):
            c.px(x, y, "R")
    c.row(24, 9, 18, "q"); c.row(25, 9, 18, "q")          # a deep embroidered hem
    kit.legs(c, back_leg, front_leg, shoes)


if __name__ == "__main__":
    kit.build("cu_chulainn", draw, PALETTE, DOC)
    print("wrote data/art/cu_chulainn.json")
