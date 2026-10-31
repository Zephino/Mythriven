# Cave parts (docs/WORLD_PLAN.md: 5; owner request 10/31/2026): the inside of the treasure cave on top of a mountain,
# for the dungeon generator (scripts/gods/shrine_dungeon.gd), weathered like the rest of the world: dirt floors with
# pebbles, rough rock walls, stalagmites, a rock ledge for the treasure, glowing crystals for light, and things lying
# about (a still pool, bones, small stalagmites, cave mushrooms). Same shape as the other dungeon sets.
# Run: python3 build_cave_parts.py from tools/art/. Writes data/art/dungeon/cave.json.
import json, os, random
from hero_kit import Canvas, ellipse, poly
from build_shrine_parts import part, TILE
from weathering import weather

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "dungeon")

PAL = {
    "o": "#140c08", "k": "#0a0606",
    "d": "#5a4a3a", "D": "#46382a", "E": "#36291e", "p": "#7a6a56",          # dirt floor, pebbles
    "a": "#6a6470", "A": "#55505a", "B": "#3e3a44", "h": "#7e7884",          # rock
    "c": "#8ad8f0", "C": "#4aa0c8", "W": "#e8fbff",                          # crystals
    "q": "#3a6a8a", "Q": "#5a8aaa",                                          # pool
    "e": "#e8e0cc", "m": "#c8a87a", "M": "#8a5a3a",                          # bone, mushrooms
}


def dirt(seed):
    rnd = random.Random(seed)

    def draw(c):
        c.rect(0, 0, 15, 15, "d")
        for _ in range(14):
            c.px(rnd.randrange(16), rnd.randrange(16), rnd.choice("DE"))
        for _ in range(3):
            x, y = rnd.randrange(15), rnd.randrange(15)
            c.px(x, y, "p"); c.px(x + 1, y, "D")
    return part(TILE, TILE, draw, outline=False)


def wall(c):
    """Rough rock, bulging and cracked."""
    rnd = random.Random(9)
    for x in range(16):
        top = rnd.choice((0, 1, 1, 2, 3))
        c.rect(x, top, x, 23, "a")
        c.px(x, top, "h")
    for _ in range(18):
        c.px(rnd.randrange(16), rnd.randrange(4, 22), rnd.choice("AB"))
    c.rect(0, 20, 15, 23, "B")


def stalagmite(c):
    """A tall stalagmite rising from the floor."""
    poly(c, [(1, 31), (4, 10), (6, 0), (8, 9), (11, 31)], "a")
    poly(c, [(3, 31), (5, 12), (6, 3), (6, 31)], "h")
    c.rect(1, 29, 10, 31, "A")


def ledge(c):
    """A low ledge of rock where the treasure rests."""
    c.rect(0, 5, 21, 13, "A"); c.rect(1, 2, 20, 5, "a"); c.row(2, 1, 20, "h"); c.row(13, 0, 21, "B")
    c.px(6, 9, "B"); c.px(15, 8, "B")


def crystals(c):
    """A cluster of glowing crystals (the cave's light)."""
    for x, h, col in ((3, 14, "C"), (6, 20, "c"), (8, 16, "C"), (10, 11, "c")):
        poly(c, [(x - 1, 23), (x, 23 - h), (x + 1, 23)], col)
        c.px(x, 23 - h + 2, "W")
    c.rect(1, 22, 11, 23, "A")


def pool(c):
    """A still pool of dark water."""
    ellipse(c, 9, 6, 8.5, 4.5, "B"); ellipse(c, 9, 6, 7, 3.4, "q"); c.rect(5, 4, 8, 4, "Q")


def bones(c):
    ellipse(c, 4, 4, 3, 2.6, "e"); c.px(3, 4, "k"); c.px(5, 4, "k")
    for k in range(6):
        c.px(8 + k, 6 - k // 2, "e")


def little_stalagmites(c):
    for x, h in ((2, 7), (5, 11), (9, 6)):
        poly(c, [(x - 2, 12), (x, 12 - h), (x + 2, 12)], "a")
        c.px(x, 13 - h, "h")


def mushrooms(c):
    for x, y in ((2, 6), (6, 4), (10, 7)):
        c.rect(x, y + 1, x, y + 3, "e"); ellipse(c, x, y, 2, 1.2, "m"); c.px(x, y - 1, "M")


def debris(seed):
    rnd = random.Random(seed)

    def draw(c):
        for _ in range(4):
            x, y = rnd.randrange(1, 8), rnd.randrange(1, 5)
            c.rect(x, y, x + 1, y, "p")
    return part(9, 6, draw)


if __name__ == "__main__":
    frames = {
        "floor": [dirt(1), dirt(2), dirt(3)],
        "wall": [part(TILE, 24, wall)],
        "column": [part(12, 32, stalagmite)],
        "altar": [part(22, 14, ledge)],
        "brazier": [part(12, 24, crystals)],
        "decor": [part(18, 12, pool), part(14, 8, bones), part(12, 13, little_stalagmites), part(13, 11, mushrooms)],
        "debris": [debris(k) for k in range(6)],
    }
    pal, frames = weather(PAL, frames, "cave", keep={"c", "C", "W"})
    with open(os.path.join(OUT, "cave.json"), "w") as f:
        json.dump({"_doc": "Cave parts for the treasure caves on mountain tops (docs/WORLD_PLAN.md: 5), built by "
                           "tools/art/build_cave_parts.py and weathered: dirt floors, rough rock walls, stalagmites, a rock "
                           "ledge, glowing crystals, a still pool, bones, small stalagmites, cave mushrooms, floor debris.",
                   "palette": pal, "frames": frames}, f, indent=1)
    print("wrote cave parts")
