# Building parts for the gods' shrines (docs/ART_RULES.md: Shrines; owner request 10/31/2026): floor tiles, walls,
# columns, an altar, a fire bowl and decorations, one set per people, in data/art/shrines/<pantheon>.json (one frame
# per part). The game lays them out at random round each shrine's altar (scripts/gods/shrine_layout.gd). Every part
# is drawn standing on its bottom edge. Run: python3 build_shrine_parts.py from tools/art/.
import json, math, os
from hero_kit import Canvas, ellipse, poly
from weathering import weather

TILE = 16
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "shrines")


def part(w, h, draw, outline=True):
    c = Canvas(w, h)
    draw(c)
    return c.outline() if outline else ["".join(r) for r in c.g]


def flame(c, x, y, h):
    for col, k in (("q", 1.0), ("f", 0.66), ("F", 0.33)):
        hh = h * k
        for yy in range(int(y - hh), y + 1):
            t = min((y - yy) / max(hh, 1), 1.0)
            half = 2.6 * k * (1 - t) ** 0.8 + 0.3
            for xx in range(int(x - half) - 1, int(x + half) + 2):
                if abs(xx - x) <= half:
                    c.px(xx, yy, col)


def brazier(c, w, h, bowl, bowl_s, stand):
    """A fire bowl on a stand, burning."""
    cx = w // 2
    c.rect(cx - 1, h - 9, cx, h - 1, stand); c.rect(cx - 3, h - 2, cx + 2, h - 1, stand)
    poly(c, [(cx - 5, h - 13), (cx + 4, h - 13), (cx + 2, h - 9), (cx - 3, h - 9)], bowl); c.row(h - 10, cx - 3, cx + 2, bowl_s)
    flame(c, cx, h - 14, 9)


FIRE = {"q": "#c83018", "f": "#ff9030", "F": "#ffe070"}


# --- Greek: a marble temple ---------------------------------------------------------------------------------------

def greek():
    pal = dict(FIRE, **{"o": "#24160e", "m": "#ece6d8", "M": "#b8b0a0", "n": "#d4ccbc", "g": "#c8a048",
                        "r": "#a83a2c", "c": "#b87848", "C": "#7a4a28", "b": "#8a7a68"})
    floor = [part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "n"), c.row(15, 0, 15, "M"), c.rect(15, 0, 15, 15, "M"),
                                       c.px(4, 5, "m"), c.px(10, 11, "m")), outline=False),
             part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "m"), c.row(7, 0, 15, "M"), c.row(15, 0, 15, "M"),
                                       c.rect(7, 0, 7, 7, "M"), c.rect(15, 8, 15, 15, "M")), outline=False)]

    def wall(c):
        c.rect(0, 4, 15, 23, "m"); c.rect(0, 0, 15, 3, "n"); c.row(3, 0, 15, "M")            # a coping on top
        for y in (9, 15, 21):
            c.row(y, 0, 15, "M")
        c.px(7, 9, "M"); c.rect(3, 10, 3, 15, "M"); c.rect(11, 16, 11, 21, "M")
        c.rect(0, 1, 15, 1, "g")                                                              # a gold-painted band

    def column(c):
        c.rect(1, 0, 10, 3, "n"); c.row(3, 1, 10, "M"); c.rect(0, 0, 11, 0, "m")             # capital
        c.rect(2, 4, 9, 29, "m")
        for x in (3, 5, 7):
            c.rect(x, 4, x, 29, "M")                                                          # fluting
        c.rect(1, 29, 10, 31, "n"); c.row(31, 1, 10, "M")                                    # base

    def altar(c):
        c.rect(1, 6, 18, 15, "m"); c.rect(0, 3, 19, 6, "n"); c.row(6, 0, 19, "M"); c.row(15, 1, 18, "M")
        c.rect(3, 9, 16, 10, "g"); c.px(9, 2, "r"); c.px(10, 2, "r"); c.px(9, 1, "f")          # a garland band, embers

    def amphora(c):
        ellipse(c, 6, 11, 4.5, 5.5, "c"); c.rect(4, 2, 7, 5, "c"); c.row(1, 3, 8, "C")
        c.rect(1, 4, 2, 9, "C"); c.rect(10, 4, 11, 9, "C"); c.row(11, 2, 10, "C")
        c.rect(5, 16, 6, 17, "C")

    return pal, {"floor": floor, "wall": [part(TILE, 24, wall)], "column": [part(12, 32, column)],
                 "altar": [part(20, 16, altar)], "brazier": [part(12, 24, lambda c: brazier(c, 12, 24, "g", "C", "b"))],
                 "decor": [part(13, 18, amphora)]}


# --- Norse: a timber hall -------------------------------------------------------------------------------------------

def norse():
    pal = dict(FIRE, **{"o": "#1e140c", "w": "#8a5a32", "W": "#5e3c1e", "d": "#3e2612", "s": "#8a8a90", "S": "#5a5a62",
                        "u": "#c8a048", "r": "#a82a2a", "b": "#2a4a7a", "i": "#9aa0a8"})
    floor = [part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "W"), [c.row(y, 0, 15, "d") for y in (3, 7, 11, 15)],
                                       c.px(5, 1, "w"), c.px(12, 9, "w")), outline=False),
             part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "W"), [c.row(y, 0, 15, "d") for y in (3, 7, 11, 15)],
                                       c.px(2, 5, "d"), c.px(9, 13, "w")), outline=False)]

    def wall(c):
        c.rect(0, 2, 15, 23, "w")
        for x in (0, 4, 8, 12):
            c.rect(x, 2, x, 23, "d")                                                          # upright planks
        poly(c, [(0, 2), (8, -2), (15, 2)], "W"); c.row(2, 0, 15, "d")                        # a turf-capped top
        c.px(6, 12, "W"); c.px(10, 17, "W")

    def column(c):
        c.rect(2, 0, 9, 31, "w"); c.rect(2, 0, 3, 31, "d")
        for y in range(4, 28, 5):
            c.px(5, y, "d"); c.px(6, y + 1, "d"); c.px(7, y + 2, "d")                         # carved interlace
        c.rect(1, 0, 10, 2, "W"); c.px(5, -1 + 1, "u"); c.px(6, 0, "u")

    def altar(c):
        c.rect(1, 4, 18, 15, "s"); c.rect(1, 4, 3, 15, "S"); c.row(4, 1, 18, "S")             # a stone hörgr
        for x, y in [(6, 8), (12, 11), (15, 6)]:
            c.px(x, y, "S")
        c.rect(7, 1, 12, 3, "i"); c.px(9, 0, "f"); c.px(10, 0, "q")

    def shield(c):
        ellipse(c, 6.5, 8.5, 6, 6, "r"); ellipse(c, 6.5, 8.5, 2, 2, "i")
        for a in range(4):
            ang = a * math.pi / 2
            for k in range(3, 6):
                c.px(round(6.5 + math.cos(ang) * k), round(8.5 + math.sin(ang) * k), "b")
        c.rect(6, 15, 7, 16, "d")

    return pal, {"floor": floor, "wall": [part(TILE, 24, wall)], "column": [part(12, 32, column)],
                 "altar": [part(20, 16, altar)], "brazier": [part(12, 24, lambda c: brazier(c, 12, 24, "i", "S", "d"))],
                 "decor": [part(14, 18, shield)]}


# --- Egyptian: a sandstone temple ---------------------------------------------------------------------------------

def egyptian():
    pal = dict(FIRE, **{"o": "#2a1c10", "s": "#e0c890", "S": "#b89a60", "t": "#c8ac70", "b": "#3a6aa8", "r": "#b8402c",
                        "g": "#5a9a4a", "u": "#e0b040", "k": "#3a2a1a"})
    floor = [part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "t"), c.row(15, 0, 15, "S"), c.rect(15, 0, 15, 15, "S"),
                                       c.px(6, 6, "s")), outline=False),
             part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "s"), c.row(15, 0, 15, "S"), c.rect(15, 0, 15, 15, "S"),
                                       c.px(3, 10, "t"), c.px(11, 4, "t")), outline=False)]

    def wall(c):
        c.rect(0, 3, 15, 23, "s"); c.rect(0, 0, 15, 2, "t"); c.row(2, 0, 15, "S")             # cornice
        c.row(1, 0, 15, "b")
        for y in (11, 19):
            c.row(y, 0, 15, "S")
        for x, y, col in [(3, 6, "k"), (4, 7, "k"), (9, 5, "b"), (10, 5, "b"), (12, 7, "r"), (6, 14, "k"), (11, 15, "b")]:
            c.px(x, y, col)                                                                   # painted hieroglyphs

    def column(c):
        poly(c, [(0, 0), (11, 0), (9, 5), (2, 5)], "g"); c.row(5, 2, 9, "u")                 # a papyrus capital
        for x in (2, 5, 8):
            c.rect(x, 1, x, 4, "u")
        c.rect(2, 6, 9, 30, "s"); c.rect(2, 6, 3, 30, "S")
        for y in (10, 18, 26):
            c.row(y, 2, 9, "b")
        c.rect(1, 30, 10, 31, "S")

    def altar(c):
        c.rect(1, 4, 18, 15, "s"); c.rect(1, 4, 2, 15, "S"); c.rect(0, 2, 19, 4, "t"); c.row(4, 0, 19, "S")
        c.row(9, 3, 16, "b"); c.px(8, 1, "g"); c.px(10, 1, "g"); c.px(9, 0, "r")              # lotus offering

    def obelisk(c):
        poly(c, [(3, 2), (6, 0), (9, 2), (8, 22), (4, 22)], "s"); c.rect(4, 2, 5, 22, "S")
        poly(c, [(4, 2), (6, 0), (8, 2)], "u")                                                # a gilded tip
        for y in range(5, 20, 3):
            c.px(6, y, "k"); c.px(7, y + 1, "b")
        c.rect(2, 22, 10, 23, "S")

    return pal, {"floor": floor, "wall": [part(TILE, 24, wall)], "column": [part(12, 32, column)],
                 "altar": [part(20, 16, altar)], "brazier": [part(12, 24, lambda c: brazier(c, 12, 24, "u", "S", "k"))],
                 "decor": [part(13, 24, obelisk)]}


# --- Celtic: a stone enclosure ------------------------------------------------------------------------------------

def celtic():
    pal = dict(FIRE, **{"o": "#1a1a14", "g": "#6a8a4a", "G": "#4a6a34", "s": "#8a8a80", "S": "#5e5e56", "m": "#5a7a3a",
                        "u": "#c8a848", "w": "#7a5a3a"})
    floor = [part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "g"), c.px(3, 4, "G"), c.px(11, 9, "G"), c.px(6, 13, "G")),
                  outline=False),
             part(TILE, TILE, lambda c: (c.rect(0, 0, 15, 15, "g"), c.rect(2, 3, 7, 7, "s"), c.rect(9, 9, 14, 13, "s"),
                                       c.row(7, 2, 7, "S"), c.row(13, 9, 14, "S")), outline=False)]

    def wall(c):
        for k, (x0, x1, top) in enumerate([(0, 6, 6), (5, 11, 3), (10, 15, 7)]):              # a drystone wall
            c.rect(x0, top, x1, 23, "s"); c.row(top, x0, x1, "S" if k % 2 else "s")
        for y in (11, 17):
            c.row(y, 0, 15, "S")
        c.px(3, 14, "S"); c.px(9, 20, "S"); c.px(12, 9, "m"); c.px(2, 8, "m")                # moss

    def column(c):
        poly(c, [(2, 3), (5, 0), (9, 2), (10, 31), (1, 31)], "s"); c.rect(1, 3, 3, 31, "S")   # a standing stone
        for a in range(0, 360, 30):
            r = 1 + a / 120
            c.px(round(6 + math.cos(math.radians(a)) * r), round(12 + math.sin(math.radians(a)) * r), "S")   # spiral
        c.px(7, 22, "m"); c.px(8, 23, "m")

    def altar(c):
        c.rect(0, 6, 19, 15, "s"); c.rect(0, 6, 2, 15, "S"); c.row(6, 0, 19, "S")             # a slab on stones
        c.rect(2, 10, 4, 15, "S"); c.rect(15, 10, 17, 15, "S")
        c.rect(7, 3, 12, 5, "u"); c.px(9, 2, "u")                                             # a bronze offering bowl

    def cauldron(c):
        ellipse(c, 6.5, 10, 6, 5, "S"); c.row(5, 1, 12, "s"); c.rect(0, 4, 13, 5, "s")
        c.rect(2, 14, 3, 16, "S"); c.rect(9, 14, 10, 16, "S")
        c.px(5, 3, "w"); c.px(7, 2, "w")                                                      # steam

    return pal, {"floor": floor, "wall": [part(TILE, 24, wall)], "column": [part(12, 32, column)],
                 "altar": [part(20, 16, altar)], "brazier": [part(12, 24, lambda c: brazier(c, 12, 24, "S", "s", "S"))],
                 "decor": [part(14, 17, cauldron)]}


DOCS = {
    "greek": "A Greek marble temple: slab floors, a wall with a gold-painted band, fluted Doric columns, a marble altar "
             "with a garland band, a bronze fire bowl, an amphora.",
    "norse": "A Norse timber hall: plank floors, walls of upright planks with a turf cap, carved posts, a stone hörgr "
             "(altar) as the sagas name it, an iron fire bowl, a painted round shield.",
    "egyptian": "An Egyptian sandstone temple: stone floors, walls with a blue cornice and painted signs, papyrus "
                "columns, an altar with a lotus offering, a gilded fire bowl, a small obelisk with a gilded tip.",
    "celtic": "A Celtic stone enclosure: grass and flagstones, a drystone wall, standing stones carved with spirals "
              "(as at Newgrange), a slab altar with a bronze bowl, a fire bowl, a bronze cauldron.",
}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, make in (("greek", greek), ("norse", norse), ("egyptian", egyptian), ("celtic", celtic)):
        pal, frames = make()
        pal, frames = weather(pal, frames, name, keep=FIRE)
        data = {"_doc": "Shrine parts, " + DOCS[name] + " Built by tools/art/build_shrine_parts.py; each frame is one "
                        "part, drawn standing on its bottom edge; floor tiles are 16 × 16.",
                "palette": pal, "frames": frames}
        with open(os.path.join(OUT, name + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote 4 shrine part sets")
