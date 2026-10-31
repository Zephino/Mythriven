# Surtr, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_surtr.py from tools/art/.
# Writes data/art/bosses/surtr.json.
import math
import hero_kit as kit

DOC = ("Surtr, boss (GAME_DESIGN.md: Midgard's Edge bosses; art 10/31/2026). Built by tools/art/build_boss_surtr.py; "
       "rules in docs/ART_RULES.md. From the Poetic Edda, Voluspa 52 (Surtr comes from the south with the bane of "
       "branches, fire; the sun shines from his sword) and Snorri Sturluson's Prose Edda, Gylfaginning 4 (the giant who "
       "guards Muspell, the land of fire, with a flaming sword) and 51 (at Ragnarok fire burns before and behind him, "
       "and light shines from his sword brighter than the sun). A huge fire giant: skin like coal with embers glowing "
       "through the cracks, hair and beard of flame, a soot-dark leather kilt, the blazing sword raised. As big as "
       "Kronos (a giant).")

SIZE, ANCHOR = (72, 78), (32, 76)
STANCE = (25, 34)
WALK = [STANCE, (23, 36), STANCE, (27, 32), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "d": "#4a3c3a", "D": "#2e2422",                 # coal-dark skin
    "e": "#ff7a20",                                 # embers glowing through the cracks
    "q": "#c83018", "f": "#ff9030", "F": "#ffe070",  # flame: dark red, orange, yellow
    "w": "#fffbe0", "u": "#ffd040",                 # the blazing blade: white-hot, gold edge
    "g": "#5a4a3a",                                 # hilt
    "l": "#3a2a20", "L": "#24180e",                 # soot-dark leather kilt
    "i": "#8a8e96",                                 # iron studs
    "y": "#ffe070",                                 # burning eyes
}


def flames(c, x, y, height, width, lean=0.0):
    """A tongue of flame rising from (x, y): dark red outside, orange, a yellow heart."""
    for layer, col, scale in (("q", "q", 1.0), ("f", "f", 0.7), ("F", "F", 0.38)):
        hh = height * scale
        for yy in range(int(y - hh), y + 1):
            h = min((y - yy) / max(hh, 1), 1.0)
            half = width * scale * (1 - h) ** 0.8 + 0.3
            cx = x + lean * (y - yy) + math.sin(h * 4 + x) * 0.8
            for xx in range(int(cx - half) - 1, int(cx + half) + 2):
                if abs(xx - cx) <= half:
                    c.px(xx, yy, col)


def cracks(c, lines):
    for (ax, ay), (bx, by) in lines:
        n = max(abs(bx - ax), abs(by - ay))
        for i in range(n + 1):
            x = round(ax + (bx - ax) * i / n); y = round(ay + (by - ay) * i / n)
            if c.g[y][x] in ("d", "D"):
                c.px(x, y, "e")


def sword(c):
    """His sword, raised and blazing: a white-hot blade with gold edges, flames licking up it."""
    for i in range(34):
        x = 52 + i * 0.35; y = 34 - i
        for k in (-1, 0, 1):
            c.px(round(x) + k, round(y), "u" if k else "w")
    c.rect(48, 34, 57, 35, "g"); c.rect(51, 36, 53, 40, "g")             # crossguard and grip
    for i, (x, y, h) in enumerate([(52, 22, 9), (55, 14, 8), (57, 6, 6)]):
        flames(c, x, y, h, 2.2, lean=0.3)
    for i in range(34):
        x = 52 + i * 0.35; y = 34 - i
        c.px(round(x), round(y), "w")


def draw(c, legs):
    back, front = legs
    # Fire burning behind him (Gylfaginning 51: before and behind him burns fire)
    for x, h in [(8, 16), (13, 22), (18, 14)]:
        flames(c, x, 72, h, 3.5, lean=-0.1)
    # Far arm hanging, coal-dark
    c.rect(17, 28, 20, 50, "D"); c.rect(17, 51, 20, 54, "d")
    # Hair of flame rising from his head
    for x, h in [(23, 13), (27, 17), (31, 16), (35, 14), (39, 10)]:
        flames(c, x, 12, h, 3.2, lean=-0.25)
    # Head: coal-dark brow, burning eyes, a heavy jaw
    c.rect(24, 9, 40, 20, "d"); c.rect(26, 21, 39, 22, "d"); c.rect(24, 9, 27, 20, "D")
    c.px(24, 9, "."); c.px(40, 9, "."); c.px(24, 20, "."); c.px(40, 20, "d")
    c.row(13, 33, 40, "D"); c.rect(35, 14, 37, 15, "y"); c.px(36, 15, "F")
    c.rect(41, 15, 42, 18, "d"); c.px(42, 18, "D")
    # A massive bare chest, coal-dark with embers in the cracks
    c.rect(22, 26, 44, 47, "d"); c.rect(22, 26, 25, 47, "D"); c.rect(21, 28, 21, 50, "o")
    c.row(34, 30, 36, "D"); c.row(34, 38, 42, "D"); c.px(37, 38, "D"); c.px(37, 41, "D")
    # Beard of flame over his chest, rising from his jaw
    for x, y, h in [(30, 32, 10), (34, 33, 12), (38, 32, 10)]:
        flames(c, x, y, h, 3.2)
    cracks(c, [((26, 37), (31, 42)), ((31, 42), (29, 46)), ((40, 38), (43, 44)), ((33, 28), (35, 31)),
               ((25, 12), (27, 16)), ((39, 19), (37, 21))])
    # Leather kilt to the knees with iron studs, a belt
    c.row(47, 22, 44, "L")
    for y in range(48, 63):
        x0, x1 = (21, 45) if y < 58 else (20, 46)
        c.row(y, x0, x1, "l")
        for x in range(x0 + 2, x1, 4):
            c.px(x, y, "L")
    c.rect(21, 48, 23, 62, "L")
    for x in range(24, 45, 4):
        c.px(x, 47, "i")
    # Near arm raised, the fist on the sword's grip
    c.rect(42, 27, 47, 34, "d"); c.rect(41, 28, 41, 34, "o")
    c.rect(46, 34, 50, 40, "d"); c.px(46, 40, "D")
    sword(c)
    c.rect(49, 36, 54, 40, "d"); c.row(38, 49, 54, "D")             # fingers round the grip
    cracks(c, [((43, 29), (46, 33)), ((48, 37), (47, 39))])
    # Legs, coal-dark, embers in the cracks
    for x0 in (back, front):
        c.rect(x0, 63, x0 + 6, 73, "d"); c.rect(x0, 63, x0 + 1, 73, "D")
        c.rect(x0, 72, x0 + 7, 74, "D")
        cracks(c, [((x0 + 3, 64), (x0 + 5, 69))])
    # Fire burning at his feet (before him)
    for x, h in [(46, 10), (51, 7)]:
        flames(c, x, 74, h, 2.6)


if __name__ == "__main__":
    kit.build_boss("surtr", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/surtr.json")
