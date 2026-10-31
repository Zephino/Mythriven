# Dungeon parts for the Ancient Ruins (docs/ART_RULES.md: Dungeons; owner request 10/31/2026): an old, crumbling
# underground ruin, different from the gods' shrines. Cracked and mossy flagstones, broken walls of dark stone, a
# snapped pillar, a stone dais for the treasure, a wall torch, and things lying about (rubble, bones, a broken urn,
# cobwebs), plus small debris scattered on the corridor floors and the ruined stairway that leads down into it from
# the world. Same shape as the shrine sets (floor tiles 16 x 16, every other part standing on its bottom edge), so the
# dungeon generator (scripts/gods/shrine_dungeon.gd) builds with it the same way.
# Run: python3 build_dungeon_parts.py from tools/art/. Writes data/art/dungeon/ruins.json.
import json, os, random
from hero_kit import Canvas, ellipse, poly
from build_shrine_parts import part, flame, FIRE, TILE

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "dungeon")

PAL = dict(FIRE, **{
    "o": "#140c08", "k": "#0a0606",
    "a": "#5a5560", "A": "#46424c", "B": "#36323c", "C": "#2a2630", "h": "#6e6874",      # dark stone
    "m": "#4a5a32", "M": "#36442a",                                                       # moss
    "e": "#e8e0cc", "E": "#b8ae98",                                                       # bone
    "u": "#9a5a38", "U": "#6a3a22",                                                       # clay urn
    "w": "#c8c8d0",                                                                       # cobweb
    "t": "#6a4422", "T": "#4a2e16", "i": "#8a8e96",                                       # wood, iron
    "g": "#f0c040", "G": "#b08020",                                                       # gold glint
})


def flagstones(seed, moss=False):
    """Old flagstones, worn and cracked; some with moss in the joints."""
    rnd = random.Random(seed)

    def draw(c):
        c.rect(0, 0, 15, 15, "A")
        for y0, x_cuts in ((0, (0, 9)), (8, (0, 5, 12))):
            for x in range(16):
                c.px(x, y0, "C")
            for x in x_cuts:
                for y in range(y0, y0 + 8):
                    c.px(x, y, "C")
        for _ in range(6):
            c.px(rnd.randrange(16), rnd.randrange(16), rnd.choice("aB"))
        x, y = rnd.randrange(2, 14), rnd.randrange(2, 14)
        for _ in range(5):
            c.px(x, y, "C"); x += rnd.choice((-1, 0, 1)); y += 1
        if moss:
            for _ in range(7):
                x = rnd.randrange(16)
                c.px(x, 8, "m"); c.px(x, 7, "M")
            c.px(9, rnd.randrange(1, 7), "m")
    return part(TILE, TILE, draw, outline=False)


def wall(c):
    """A wall of big dark stone blocks, its top broken off unevenly."""
    rnd = random.Random(4)
    top = [rnd.choice((0, 0, 1, 2, 3)) for _ in range(16)]
    for x in range(16):
        c.rect(x, top[x], x, 23, "a")
        c.px(x, top[x], "h")
    for y in (8, 16):
        c.row(y, 0, 15, "C")
    for x, y0 in ((5, 1), (12, 9), (3, 17)):
        c.rect(x, y0, x, y0 + 6, "C")
    c.rect(0, 20, 15, 23, "B")
    c.px(8, 12, "m"); c.px(9, 12, "M"); c.px(2, 4, "B"); c.px(13, 5, "B")


def pillar(c):
    """A snapped stone pillar, its top jagged, its base cracked."""
    c.rect(2, 8, 9, 29, "a"); c.rect(8, 8, 9, 29, "B"); c.rect(2, 8, 3, 29, "h")
    for x, t in ((2, 9), (3, 6), (4, 5), (5, 7), (6, 4), (7, 6), (8, 8), (9, 7)):
        c.rect(x, t, x, 8, "a")
    c.rect(1, 28, 10, 31, "A"); c.row(31, 1, 10, "B")
    c.rect(5, 14, 5, 19, "C"); c.px(6, 20, "C"); c.px(4, 24, "m"); c.px(5, 24, "m")


def dais(c):
    """A low stone dais where the treasure rests."""
    c.rect(0, 6, 21, 13, "A"); c.rect(1, 3, 20, 6, "a"); c.row(3, 1, 20, "h"); c.row(13, 0, 21, "B")
    c.row(6, 0, 21, "C"); c.rect(6, 8, 6, 12, "C"); c.rect(15, 8, 15, 12, "C")


def torch(c):
    """A torch in an iron bracket, burning."""
    c.rect(5, 12, 6, 23, "t"); c.px(6, 12, "T"); c.rect(3, 14, 8, 15, "i"); c.rect(4, 22, 7, 23, "i")
    c.rect(4, 10, 7, 12, "T")
    flame(c, 5, 10, 9)


def rubble(c):
    """A heap of fallen stones."""
    for cx, cy, rx, ry, col in ((6, 12, 6, 4, "A"), (12, 13, 4, 3, "a"), (4, 10, 3, 2.5, "a"), (9, 8, 3, 2.5, "h")):
        ellipse(c, cx, cy, rx, ry, col)
    c.px(6, 12, "C"); c.px(11, 14, "C"); c.px(3, 13, "B")


def bones(c):
    """A skull and scattered bones."""
    ellipse(c, 5, 6, 3.5, 3.2, "e"); c.rect(3, 9, 7, 10, "e"); c.px(4, 6, "k"); c.px(6, 6, "k"); c.px(5, 8, "E")
    c.row(10, 3, 7, "E"); c.px(4, 10, "k"); c.px(6, 10, "k")
    for k in range(7):
        c.px(9 + k, 10 - k // 2, "e"); c.px(9 + k, 11 - k // 2, "E")
    c.rect(8, 9, 9, 10, "e"); c.rect(15, 6, 16, 7, "e")


def urn(c):
    """A broken clay urn lying on its side, spilling dust."""
    ellipse(c, 7, 8, 6, 4, "u"); c.rect(1, 6, 2, 9, "U"); c.row(12, 2, 11, "U")
    c.rect(12, 5, 13, 6, "U"); c.px(13, 10, "U"); c.px(12, 11, "u")
    for x in range(13, 17):
        c.px(x, 11, "B")


def cobweb(c):
    """Cobwebs strung in a corner."""
    for k in range(12):
        c.px(k, 0, "w") if k % 2 == 0 else None
        c.px(0, k, "w") if k % 2 == 0 else None
    for k in range(10):
        c.px(k, k, "w")
    for r in (4, 7, 10):
        for k in range(r + 1):
            c.px(k, r - k, "w") if k % 2 == 0 else None


def debris(seed):
    """Small things lying on the floor: pebbles, a bone, a crack."""
    rnd = random.Random(seed)

    def draw(c):
        kind = seed % 3
        if kind == 0:
            for _ in range(3):
                x, y = rnd.randrange(1, 8), rnd.randrange(1, 5)
                c.rect(x, y, x + 1, y + 1, "h")
        elif kind == 1:
            c.row(3, 1, 6, "e"); c.rect(0, 2, 1, 4, "e"); c.rect(6, 2, 7, 4, "e")
        else:
            c.rect(2, 2, 6, 4, "a"); c.px(2, 2, "h"); c.px(6, 4, "B")
    return part(9, 6, draw)


def entrance(c):
    """The way down from the world: a ruined archway of dark stone over steps going down into blackness, with fallen
    blocks about it."""
    W, H = c.w, c.h
    c.rect(4, 10, W - 5, H - 1, "a")                                   # the arch's stones
    c.rect(12, 16, W - 13, H - 1, "k")                                 # the dark way down
    for y in range(14, 17):
        c.row(y, 12 + (16 - y), W - 13 - (16 - y), "k")
    for k, y in enumerate(range(H - 12, H, 3)):                        # steps, lit at their front edge
        c.row(y, 13 + k, W - 14 - k, "B")
        c.row(y + 1, 13 + k, W - 14 - k, "C")
    for x0 in (4, W - 12):                                             # side piers, with broken tops
        for y in range(16, H, 6):
            c.row(y, x0, x0 + 7, "C")
    for x, t in ((4, 12), (5, 9), (6, 10), (7, 8), (8, 11), (W - 9, 7), (W - 8, 10), (W - 7, 9), (W - 6, 12), (W - 5, 11)):
        c.rect(x, t, x, 12, "a")
    c.row(10, 9, W - 10, "h")
    ellipse(c, 2.5, H - 3, 2.5, 2, "A"); ellipse(c, W - 3, H - 2.5, 3, 2.5, "a")
    c.px(10, 20, "m"); c.px(11, 20, "M"); c.px(W - 8, 26, "m")


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    frames = {
        "floor": [flagstones(1), flagstones(2), flagstones(3, moss=True)],
        "wall": [part(TILE, 24, wall)],
        "column": [part(12, 32, pillar)],
        "altar": [part(22, 14, dais)],
        "brazier": [part(12, 24, torch)],
        "decor": [part(17, 16, rubble), part(18, 13, bones), part(18, 14, urn), part(12, 12, cobweb, outline=False)],
        "debris": [debris(k) for k in range(6)],
        "entrance": [part(44, 40, entrance)],
    }
    # The arch's front stones alone (its opening and steps left out), drawn over the Heroes as they walk through.
    front = []
    for y, row in enumerate(frames["entrance"][0]):
        front.append("".join("." if 13 <= x <= 30 and y >= 15 else ch for x, ch in enumerate(row)))
    frames["entrance_front"] = [front]
    data = {"_doc": "Dungeon parts for the Ancient Ruins (owner request 10/31/2026): an old crumbling ruin underground, "
                    "built by tools/art/build_dungeon_parts.py. Cracked and mossy flagstones, broken dark stone walls, a "
                    "snapped pillar, a stone dais for the treasure, a wall torch, rubble, bones, a broken urn, cobwebs, "
                    "floor debris and the ruined stairway down from the world. Floor tiles are 16 x 16; every other part "
                    "stands on its bottom edge.", "palette": PAL, "frames": frames}
    with open(os.path.join(OUT, "ruins.json"), "w") as f:
        json.dump(data, f, indent=1)
    print("wrote dungeon parts:", {k: len(v) for k, v in frames.items()})
