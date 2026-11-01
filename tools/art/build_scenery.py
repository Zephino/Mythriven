# Scenery (docs/ART_RULES.md: Scenery): the decorations scattered over each level's ground (levels.json
# "decorations"). Visual only, no collision. Run: python3 build_scenery.py from tools/art/.
# Writes data/art/scenery/<decoration id>.json, drawn with the middle of its base on the decoration's spot.
import json, math, os, random
from build_weapons import Pic, finish
from weathering import weather

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "m": "#ece7da", "M": "#c8c0ae", "n": "#a8a090",                      # marble
    "t": "#6a5034", "T": "#4a3622", "v": "#8a9a6a", "V": "#5a6a40", "w": "#b0bc90",   # olive
    "p": "#2e4a32", "P": "#1e3222", "q": "#466a48", "s": "#eef2f6",      # pine, snow
    "g": "#8a8c90", "G": "#64666a", "h": "#a8aab0", "r": "#a83a2c",      # grey stone, red paint
    "b": "#6a5440", "B": "#4a3a2a", "u": "#5a7a3a",                      # timber, turf
    "e": "#d8c4a0", "E": "#b8a07a", "F": "#9a8460", "y": "#f0c040", "z": "#2a1e14",   # sandstone, gold, dark doorway
    "c": "#6a8a40", "C": "#4a6a28", "a": "#a8b860",                      # papyrus
    "i": "#9a9a94", "I": "#76766e", "j": "#b8b8b0", "l": "#5a7a3a",      # Irish stone, lichen
    "d": "#b08858", "D": "#8a6a40",                                    # sun-dried mud brick
    "R": "#8a3a2a",                                                    # red lacquer
    "x": "#3a5a2a", "X": "#2a4420", "f": "#f0d030", "F2": "#c8a020",
}


def blob(p, cx, cy, rx, ry, col, rnd=None, rough=0.0):
    for y in range(p.h):
        for x in range(p.w):
            d = math.hypot((x - cx) / rx, (y - cy) / ry)
            if d <= 1.0 + (rnd.uniform(-rough, rough) if rnd else 0):
                p.px(x, y, col)


def olive_tree():
    """An olive tree: a gnarled, twisting trunk under a broad crown of silver-green leaves."""
    rnd = random.Random(1)
    p = Pic(24, 26, (12, 25))
    for y in range(14, 26):
        x = 11 + round(math.sin(y * 0.6) * 1.5)
        p.rect(x, y, x + 2, y, "t"); p.px(x, y, "T")
    p.rect(9, 24, 15, 25, "T"); p.px(14, 16, "t"); p.px(15, 15, "t")
    blob(p, 12, 8, 11, 7, "V", rnd, 0.15)
    blob(p, 11, 7, 9, 5.5, "v", rnd, 0.2)
    for _ in range(14):
        p.px(rnd.randrange(4, 20), rnd.randrange(2, 12), "w")
    return p


def broken_column():
    """A broken marble column: fluted shaft, snapped at the top, on its base."""
    p = Pic(12, 26, (6, 25))
    p.rect(1, 23, 10, 25, "M"); p.rect(0, 25, 11, 25, "n")
    for y in range(4, 23):
        p.rect(2, y, 9, y, "m")
        for x in (3, 5, 7):
            p.px(x, y, "M")
        p.px(9, y, "n")
    for x, top in ((2, 5), (3, 3), (4, 4), (5, 2), (6, 4), (7, 3), (8, 6), (9, 5)):
        for y in range(4, top):
            p.px(x, y, ".")
        for y in range(top, 4):
            p.px(x, y, "m")
    return p


def marble_ruin():
    """Marble ruins: a fallen column drum and squared blocks lying in the grass."""
    p = Pic(30, 14, (15, 13))
    p.rect(1, 6, 10, 13, "m"); p.rect(1, 6, 10, 6, "M"); p.rect(10, 6, 10, 13, "n")
    p.rect(12, 9, 19, 13, "M"); p.rect(12, 9, 19, 9, "m"); p.rect(19, 9, 19, 13, "n")
    blob(p, 25, 9.5, 4.5, 4, "m")                              # column drum, end on
    for r in (2.5, 1.2):
        for a in range(0, 360, 20):
            p.px(round(25 + math.cos(math.radians(a)) * r), round(9.5 + math.sin(math.radians(a)) * r), "M")
    p.px(4, 9, "n"); p.px(7, 11, "n"); p.px(15, 11, "n")
    return p


def pine_tree():
    """A tall pine: tiers of dark needles, snow lying on their tops, on a short trunk."""
    p = Pic(20, 32, (10, 31))
    p.rect(9, 27, 11, 31, "T")
    for tier, (top, bottom, half) in enumerate(((1, 10, 4), (7, 18, 7), (14, 27, 9))):
        for y in range(top, bottom + 1):
            w = round(half * (y - top) / (bottom - top)) + 1
            p.rect(10 - w, y, 10 + w - 1, y, "p" if y < bottom - 1 else "P")
            p.px(10 - w, y, "P")
        for x in range(10 - half // 2, 10 + half // 2):
            p.px(x, top + 2 + abs(x - 10) // 2, "s")
    p.px(10, 0, "q")
    return p


def runestone():
    """A runestone: an upright slab with a carved serpent band painted red (as Viking-age runestones were painted)."""
    p = Pic(12, 22, (6, 21))
    for y in range(1, 22):
        w = 4 if y > 3 else [2, 3, 4][y - 1]
        p.rect(6 - w, y, 5 + w, y, "g")
    p.rect(9, 3, 9, 21, "G"); p.rect(2, 4, 2, 18, "h")
    for y in range(4, 19):                                     # carved band down the face
        p.px(4 if y % 6 < 3 else 7, y, "r")
    p.rect(4, 4, 7, 4, "r"); p.rect(4, 18, 7, 18, "r")
    p.rect(1, 21, 10, 21, "G")
    return p


def longhouse_ruin():
    """A ruined longhouse: a low turf-covered wall and broken timber posts."""
    p = Pic(34, 18, (17, 17))
    p.rect(1, 11, 32, 17, "b"); p.rect(1, 11, 32, 12, "u"); p.rect(1, 17, 32, 17, "B")
    for x in range(3, 32, 4):
        p.px(x, 14, "B")
    for x, top in ((5, 3), (14, 6), (24, 2), (30, 7)):
        p.rect(x, top, x + 1, 11, "b"); p.px(x + 1, top, "B")
    p.rect(5, 3, 14, 3, "B")                                   # a beam still resting on two posts
    p.px(20, 10, "u"); p.px(21, 10, "u")
    return p


def obelisk():
    """An obelisk: a tall tapering sandstone shaft, its pyramidion capped with gold, carved marks down its face."""
    p = Pic(10, 32, (5, 31))
    for y in range(4, 30):
        w = 2 + round((y - 4) / 12)
        p.rect(5 - w, y, 4 + w, y, "e"); p.px(4 + w, y, "E")
    for y in range(0, 4):
        p.rect(5 - (y // 2 + 1), y, 4 + (y // 2 + 1), y, "y")
    for y in range(7, 27, 3):
        p.px(4, y, "F"); p.px(5, y + 1, "F")
    p.rect(1, 30, 8, 31, "E")
    return p


def tomb_entrance():
    """A rock-cut tomb entrance: a dark doorway with a lintel, cut into a rough sandstone cliff face."""
    rnd = random.Random(3)
    p = Pic(28, 20, (14, 19))
    top = 3
    for x in range(28):
        top = max(1, min(6, top + rnd.choice((-1, 0, 0, 1))))
        p.rect(x, top, x, 19, "e")
        p.px(x, top, "E")
    for y in (9, 14):
        for x in range(0, 28, 5):
            p.px(x + (y % 3), y, "F")
    p.rect(9, 6, 18, 8, "E"); p.rect(9, 6, 18, 6, "e")                  # lintel
    p.rect(10, 9, 17, 19, "z"); p.rect(10, 9, 10, 19, "F"); p.rect(17, 9, 17, 19, "F")
    return p


def nile_reeds():
    """Papyrus by the Nile: a clump of tall stems topped with feathery heads."""
    p = Pic(16, 18, (8, 17))
    for k, (x, top) in enumerate(((3, 5), (6, 2), (8, 4), (10, 1), (13, 6))):
        for y in range(top + 2, 18):
            p.px(x + (1 if y < top + 5 and k % 2 else 0), y, "c" if y < 15 else "C")
        p.rect(x - 1, top, x + 1, top + 1, "a"); p.px(x, top - 1, "a")
    p.rect(2, 16, 13, 17, "C")
    return p


def standing_stone():
    """A standing stone: a tall weathered menhir with lichen on it."""
    p = Pic(10, 22, (5, 21))
    for y in range(1, 22):
        w = 2 + min(y, 6) // 2
        p.rect(5 - w, y, 4 + w, y, "i")
        p.px(4 + w, y, "I")
    p.px(3, 7, "l"); p.px(4, 8, "l"); p.px(6, 14, "l"); p.px(2, 15, "j"); p.px(2, 10, "j")
    p.rect(1, 21, 8, 21, "I")
    return p


def stone_circle():
    """A stone circle: a ring of small standing stones seen from the side, the far ones smaller."""
    p = Pic(36, 22, (18, 21))
    for k in range(9):
        ang = math.tau * (k + 0.5) / 9
        x = round(18 + math.cos(ang) * 15); y = round(13 + math.sin(ang) * 6)
        h = 6 if math.sin(ang) > 0 else 4
        p.rect(x, y - h, x + 1, y, "i"); p.px(x + 1, y - h + 1, "I"); p.px(x, y, "I")
    return p


def gorse():
    """Gorse: a spiny dark-green bush covered in yellow flowers."""
    rnd = random.Random(7)
    p = Pic(16, 12, (8, 11))
    blob(p, 8, 7, 7.5, 4.5, "X", rnd, 0.15)
    blob(p, 8, 6, 6, 3.5, "x", rnd, 0.2)
    for _ in range(12):
        p.px(rnd.randrange(2, 14), rnd.randrange(2, 10), "f")
    return p


def giant_steps():
    """Giant-sized ruins (Jotunheim): three huge cut stone steps, cracked and half buried in snow."""
    p = Pic(34, 18, (17, 17))
    for k, (x0, y0) in enumerate(((1, 10), (8, 5), (17, 0))):
        p.rect(x0, y0, 33, 17, "g" if k % 2 else "h"); p.rect(x0, y0, 33, y0, "h")
        p.rect(x0, y0, x0, 17, "G")
    p.px(20, 8, "G"); p.px(21, 9, "G"); p.px(12, 12, "G")
    p.rect(1, 16, 33, 17, "s"); p.rect(4, 15, 10, 15, "s"); p.rect(24, 15, 30, 15, "s")
    return p


def castle_ruin():
    """A ruined castle wall (Avalon's Shadow): grey stone courses, a broken top, an arrow slit, ivy creeping up."""
    p = Pic(32, 24, (16, 23))
    for x in range(0, 32):
        top = 4 + (x * 7 % 5) + (6 if 12 < x < 20 else 0)
        for y in range(top, 24):
            p.px(x, y, "i" if (x // 4 + y // 3) % 2 else "I")
        p.px(x, top, "j")
    for y in range(4, 24, 3):
        for x in range(0, 32, 4):
            p.px(x + (y // 3) % 2 * 2, y, "I")
    p.rect(6, 10, 7, 15, "z")                                     # arrow slit
    for y in range(12, 24):
        p.px(26 + (y % 3), y, "l"); p.px(27 + (y % 2), y, "x")    # ivy
    return p


def ziggurat_ruin():
    """A ruined ziggurat (the Land Between the Rivers): stepped terraces of sun-dried mud brick, worn and slumped,
    with the stair climbing the front, as at Ur."""
    p = Pic(36, 24, (18, 23))
    for k, (x0, x1, y0) in enumerate(((0, 35, 14), (5, 30, 7), (10, 25, 1))):
        for y in range(y0, 24 if k == 0 else y0 + 7):
            for x in range(x0 + (1 if y == y0 else 0), x1 + 1 - (1 if y == y0 else 0)):
                p.px(x, y, "d" if (x // 3 + y // 2) % 2 else "D")
        p.rect(x0, y0, x1, y0, "e")
    for y in range(4, 24):
        p.rect(16, y, 19, y, "E" if y % 2 else "F")                # the front stair
    p.rect(30, 3, 33, 6, "D"); p.px(2, 12, "D"); p.px(34, 10, "D")  # fallen brick
    return p


def boundary_stone():
    """A boundary stone, kudurru (Kassite Babylonia): a rounded dark stone carved with the emblems of the gods in
    rows, the star, the moon and the sun disc at the top (emblems only, never writing)."""
    p = Pic(12, 20, (6, 19))
    for y in range(2, 20):
        half = 4 if y > 4 else 2 + (y - 1)
        p.rect(6 - half, y, 6 + half - 1, y, "g" if y % 5 else "G")
    p.rect(2, 2, 9, 2, "h"); p.rect(4, 1, 7, 1, "h")
    p.px(3, 4, "y"); p.px(6, 4, "y"); p.px(8, 4, "y")              # star, crescent, sun disc
    p.px(5, 3, "y"); p.px(7, 5, "y")
    for y in (8, 13):
        p.rect(3, y, 8, y, "G")                                     # bands of carved emblems
        p.px(4, y + 2, "h"); p.px(7, y + 2, "h")
    return p


def log_hut_ruin():
    """A ruined log hut (Pohjola): the corner of a farmstead of round pine logs, notched at the corners, the roof fallen
    in and drifted with snow."""
    p = Pic(30, 22, (15, 21))
    for k in range(6):
        y = 8 + k * 2
        p.rect(1, y, 28 - (k % 2) * 3, y + 1, "b" if k % 2 else "B")
        p.px(0, y, "t"); p.px(29 - (k % 2) * 3, y, "t")                    # notched log ends
    p.rect(1, 20, 28, 21, "B")
    for x in range(4, 22):
        p.px(x, 7 - (x - 4) // 4, "B")                                     # the fallen roof beam
    p.rect(10, 12, 14, 19, "z")                                          # doorway
    p.rect(2, 6, 12, 7, "s"); p.rect(16, 19, 28, 19, "s"); p.rect(20, 7, 26, 7, "s")   # snow
    return p


def div_palace_ruin():
    """A ruined palace of the divs (Mazandaran): a broken arched gateway of cut stone, its arch fallen, a carved band
    of rosettes along the top."""
    p = Pic(34, 26, (17, 25))
    for x0 in (2, 24):
        p.rect(x0, 6, x0 + 7, 25, "g"); p.rect(x0, 6, x0, 25, "G")
    for k in range(6):
        p.px(9 + k, 6 + k // 2, "g"); p.px(24 - k, 6 + k // 2, "h")      # the broken arch springing
    p.rect(1, 4, 32, 5, "h")
    for x in range(4, 30, 5):
        p.px(x, 4, "y")                                                 # rosettes
    p.rect(13, 22, 20, 25, "g"); p.px(15, 21, "G")                     # fallen stones
    return p


def well_sweep():
    """A village well with a sweep (the Slavic Wilds): a log well-frame and a long counterweighted pole on a forked
    post, as in the old wooden villages."""
    p = Pic(24, 28, (12, 27))
    p.rect(2, 20, 10, 27, "b"); p.rect(2, 20, 10, 20, "t"); p.rect(2, 24, 10, 24, "B")   # the log well-frame
    p.rect(17, 10, 18, 27, "B"); p.px(16, 9, "B"); p.px(19, 9, "B")                     # the forked post
    for k in range(18):
        p.px(4 + k, 18 - k * 15 // 18, "b")                                              # the long sweep pole
    p.rect(20, 2, 22, 4, "g")                                                            # counterweight stone
    for y in range(17, 21):
        p.px(5, y, "t")                                                                  # the rope
    p.rect(4, 20, 6, 21, "B")
    return p


def bamboo_clump():
    """A clump of bamboo (the Land of Legends): tall green jointed canes with narrow leaves at the top."""
    p = Pic(16, 32, (8, 31))
    for k, (x, top) in enumerate(((3, 4), (7, 0), (11, 3), (13, 8))):
        p.rect(x, top, x + 1, 31, "c" if k % 2 else "C")
        for y in range(top + 4, 31, 6):
            p.rect(x, y, x + 1, y, "a")                                  # the joints
        for d in (-1, 1):
            p.px(x + d * 2, top + 1, "c"); p.px(x + d * 3, top, "c"); p.px(x + d, top + 2, "C")
    return p


def castle_wall_ruin():
    """A ruined castle wall base (the Land of Legends): the sloping dry-stone foundation of a fallen castle, its
    timber keep long gone, grass on top."""
    p = Pic(34, 22, (17, 21))
    for y in range(6, 22):
        inset = (21 - y) // 3
        for x in range(inset, 34 - inset):
            p.px(x, y, "g" if (x // 3 + y // 2) % 2 else "G")
    for x in range(2, 32, 3):
        p.px(x, 5 + (x % 2), "u")                                         # grass on top
    p.rect(3, 5, 30, 5, "u")
    return p


def smoking_vent():
    """A smoking vent (Muspelheim): a cracked mound of black rock glowing at its mouth, a wisp of smoke above."""
    p = Pic(18, 20, (9, 19))
    for y in range(10, 20):
        half = 3 + (y - 10) * 0.6
        p.rect(round(9 - half), y, round(9 + half), y, "G" if y % 3 else "g")
    p.rect(7, 10, 11, 11, "r"); p.rect(8, 9, 10, 9, "y")                              # the glowing mouth
    for k in range(8):
        p.px(9 + round(1.5 * math.sin(k)), 8 - k, "h")                                  # smoke
    return p


def obsidian_spire():
    """An obsidian spire (Muspelheim): a tall shard of black volcanic glass with a sharp gleam."""
    p = Pic(14, 30, (7, 29))
    for y in range(2, 30):
        half = (y - 2) * 5 // 28 + 1
        p.rect(7 - half, y, 7 + half, y, "z")
    for y in range(6, 26, 3):
        p.px(6, y, "h")                                                                 # gleam
    p.rect(3, 28, 11, 29, "G")
    return p


def ice_shard():
    """An ice shard (Niflheim): a tall, jagged spike of blue-white ice."""
    p = Pic(14, 26, (7, 25))
    for y in range(1, 26):
        half = (y - 1) * 5 // 25 + 1
        p.rect(7 - half, y, 7 + half - (y % 4 == 0), y, "h" if y % 5 else "j")
    for y in range(4, 22, 4):
        p.px(6, y, "s")
    return p


def frozen_root():
    """A frozen root (Niflheim): a huge gnarled root of the world-tree breaking through the ice, gnawed, rimed with
    frost (Grimnismal 32-35)."""
    p = Pic(34, 16, (17, 15))
    for x in range(0, 34):
        y = 8 + round(3 * math.sin(x / 5.0))
        p.rect(x, y, x, min(y + 4, 15), "b" if x % 4 else "B")
        if x % 6 == 0:
            p.px(x, y - 1, "s")
    p.rect(12, 9, 14, 11, "z")                                          # a gnawed hollow
    return p


def drowned_arch():
    """A drowned arch of Ys: a broken stone archway of the sunken city, green with weed, a barnacled keystone."""
    p = Pic(30, 26, (15, 25))
    for x0 in (2, 22):
        p.rect(x0, 8, x0 + 5, 25, "i"); p.rect(x0, 8, x0, 25, "I")
    for k in range(10):
        a = math.pi * k / 9
        p.rect(round(15 - 10 * math.cos(a)) - 1, round(10 - 7 * math.sin(a)), round(15 - 10 * math.cos(a)) + 1,
               round(10 - 7 * math.sin(a)) + 1, "i")
    for y in range(12, 25, 3):
        p.px(3 + (y % 2), y, "l"); p.px(26 - (y % 2), y, "l")                        # weed
    p.rect(14, 2, 16, 4, "j")
    return p


def sea_gate():
    """A sea gate of Ys: the great wooden gates in the dyke, bound with iron, standing open to the sea."""
    p = Pic(32, 28, (16, 27))
    p.rect(0, 4, 5, 27, "i"); p.rect(26, 4, 31, 27, "i"); p.rect(0, 2, 31, 5, "I")
    p.rect(6, 6, 11, 26, "b"); p.rect(20, 6, 25, 26, "b")                            # the gates swung open
    for y in (10, 18):
        p.rect(6, y, 11, y, "G"); p.rect(20, y, 25, y, "G")
    p.rect(12, 20, 19, 27, "j")
    return p


def birds_wall():
    """A wall of the birds' city (Aristophanes, The Birds: the great wall of Cloud-Cuckoo-Land, built of baked brick by
    the birds themselves): a stretch of brick wall with a crenellated top."""
    p = Pic(34, 20, (17, 19))
    for y in range(4, 20):
        for x in range(34):
            p.px(x, y, "d" if ((x + (y // 3) % 2 * 2) // 4 + y // 3) % 2 else "D")
    for x in range(0, 34, 6):
        p.rect(x, 1, x + 3, 3, "d")
    return p


def nest_tower():
    """A nest tower of the birds' city (The Birds): a slim brick tower with a great nest of twigs on top."""
    p = Pic(18, 32, (9, 31))
    p.rect(5, 10, 12, 31, "d"); p.rect(5, 10, 6, 31, "D")
    for y in range(12, 31, 3):
        p.rect(7, y, 11, y, "D")
    for k in range(18):
        p.px(k, 7 + (k % 3) - 1, "t"); p.px(k, 8 + (k * 7 % 3), "T")                   # the nest
    p.rect(6, 4, 11, 6, "y")                                                          # eggs
    return p


def pagoda_ruin():
    """A ruined pagoda (the Realm of the Ten Suns): a scorched tower of stacked tiers with upturned eaves, the top tiers
    fallen."""
    p = Pic(24, 34, (12, 33))
    for k, (half, y0) in enumerate(((10, 24), (8, 15), (6, 7))):
        p.rect(12 - half + 2, y0 + 2, 12 + half - 2, y0 + 9, "r" if k % 2 else "R")
        p.rect(12 - half, y0, 12 + half, y0 + 1, "z")                                  # eaves
        p.px(12 - half - 1, y0 - 1, "z"); p.px(12 + half + 1, y0 - 1, "z")             # upturned tips
        p.rect(11, y0 + 4, 13, y0 + 8, "z")                                            # doorway / window
    p.rect(5, 3, 8, 6, "G"); p.px(16, 5, "G")                                          # fallen top tiers
    return p


def grave_stele():
    """A Greek grave stele (the Underworld): a tall marble slab with a palmette crown, worn and leaning a little."""
    p = Pic(12, 26, (6, 25))
    p.rect(2, 8, 9, 25, "M"); p.rect(3, 8, 8, 24, "m"); p.rect(9, 8, 9, 25, "n")
    for x, y in ((5, 2), (4, 3), (6, 3), (3, 4), (5, 4), (7, 4), (2, 5), (4, 5), (6, 5), (8, 5), (2, 6), (9, 6)):
        p.px(x, y, "m")
    p.rect(2, 7, 9, 7, "M")
    p.rect(4, 12, 7, 18, "n")                                   # the carved panel, worn smooth
    p.rect(1, 25, 10, 25, "n")
    return p


def lekythos():
    """A white-ground lekythos (the Underworld): the tall oil flask the Greeks set on graves, with a dark band."""
    p = Pic(10, 20, (5, 19))
    blob(p, 5, 12, 3.6, 6.5, "m")
    p.rect(4, 3, 6, 6, "m"); p.rect(3, 2, 7, 2, "M"); p.px(7, 5, "M"); p.px(8, 6, "M"); p.px(8, 7, "M")
    p.rect(2, 9, 8, 9, "z"); p.rect(2, 16, 8, 16, "z")
    p.rect(3, 18, 7, 19, "M")
    return p


def barrow_mound():
    """A barrow (Erebus; the old grave mounds the Wild Hunt rides over in the folklore Grimm gathered): a low grassy
    burial mound with a dark stone doorway."""
    p = Pic(34, 18, (17, 17))
    for y in range(4, 18):
        half = int(16 * math.sqrt(max(0.0, 1 - ((17 - y) / 14.0 - 1) ** 2))) if y < 17 else 16
        half = min(16, int(16 * (y - 3) / 10)) if y < 13 else 16
        p.rect(17 - half, y, 16 + half, y, "u" if y < 8 else "x")
    p.rect(14, 11, 19, 17, "g"); p.rect(15, 12, 18, 17, "z")
    return p


def stone_tomb():
    """A stone tomb in the ruined chapel's yard (Karnstein; Le Fanu, Carmilla: the tombs of the Karnsteins): a plain
    stone chest-tomb, moss on its lid, cracked at one corner."""
    p = Pic(26, 16, (13, 15))
    p.rect(2, 6, 23, 15, "g"); p.rect(2, 6, 23, 7, "h"); p.rect(1, 4, 24, 6, "h"); p.rect(1, 4, 24, 4, "i")
    p.rect(4, 9, 21, 13, "G")
    for x in (3, 7, 12, 18): p.px(x, 4, "l"); p.px(x + 1, 5, "l")
    p.px(22, 8, "k"); p.px(21, 9, "k"); p.px(22, 10, "k")
    return p


def fallen_log():
    """A fallen oak trunk in the forest of Ossory, mossy, with a broken end."""
    p = Pic(32, 10, (16, 9))
    p.rect(1, 3, 30, 8, "b"); p.rect(1, 3, 30, 4, "u"); p.rect(1, 8, 30, 8, "B")
    p.rect(28, 2, 31, 9, "e"); p.px(29, 5, "E"); p.px(30, 6, "E")
    for x in (5, 11, 18, 24): p.px(x, 2, "l"); p.px(x + 1, 3, "l")
    return p


def granite_tor():
    """A granite tor on the Brocken (the summit's rock piles, named the Witches' Altar and the Devil's Pulpit in the
    old guidebooks): rounded granite blocks stacked on one another."""
    p = Pic(28, 24, (14, 23))
    blob(p, 14, 18, 13, 6, "G"); blob(p, 13, 17, 11, 5, "g")
    blob(p, 12, 10, 8, 5, "G"); blob(p, 11, 9, 7, 4, "g")
    blob(p, 15, 4, 5, 3.5, "G"); blob(p, 14, 3, 4, 3, "h")
    for x, y in ((6, 16), (18, 12), (20, 19)): p.px(x, y, "l")
    return p


def walpurgis_fire():
    """A Walpurgis Night fire (Faust I: the fires on the Brocken): a heap of logs with flames leaping up."""
    p = Pic(18, 22, (9, 21))
    p.rect(2, 18, 15, 20, "b"); p.rect(4, 16, 13, 17, "B")
    for k, h in enumerate((8, 13, 16, 12, 9)):
        p.rect(4 + k * 2, 17 - h, 5 + k * 2, 16, "r" if k % 2 else "y")
    p.rect(7, 8, 10, 15, "f")
    return p


def anvil():
    """A dwarf's anvil in the forge-halls of Nidavellir (Skaldskaparmal 35), on its stump, a hammer resting on it."""
    p = Pic(20, 16, (10, 15))
    p.rect(6, 9, 13, 15, "b"); p.rect(6, 9, 7, 15, "B")
    p.rect(3, 4, 16, 7, "G"); p.rect(1, 4, 3, 5, "G"); p.rect(5, 7, 14, 8, "g"); p.rect(3, 4, 16, 4, "h")
    p.rect(9, 1, 10, 3, "b"); p.rect(7, 0, 12, 1, "g")
    return p


def forge_hearth():
    """A forge hearth in Nidavellir: a stone hearth with glowing coals and a hood over it."""
    p = Pic(26, 26, (13, 25))
    p.rect(3, 14, 22, 25, "g"); p.rect(3, 14, 22, 15, "h"); p.rect(6, 16, 19, 22, "z")
    for x in range(7, 19, 2): p.px(x, 21, "r"); p.px(x + 1, 20, "y")
    p.rect(5, 2, 20, 6, "G"); p.rect(9, 0, 16, 2, "G"); p.rect(7, 6, 18, 13, "G"); p.rect(9, 7, 16, 13, "z")
    return p


def stalagmite():
    """Stalagmites in the caverns of Svartalfheim: a cluster of pale dripstone spires."""
    p = Pic(18, 26, (9, 25))
    for x0, h in ((3, 14), (8, 24), (13, 17)):
        for y in range(26 - h, 26):
            w = max(1, (y - (26 - h)) // 5)
            p.rect(x0 - w // 2, y, x0 + w // 2 + 1, y, "j" if (y + x0) % 5 else "I")
    return p


def hoard_heap():
    """A heap of the Nibelung hoard (the Nibelungenlied: more gold and gems than a hundred carts could carry)."""
    p = Pic(24, 12, (12, 11))
    for y in range(3, 12):
        half = min(11, (y - 2) * 2)
        p.rect(12 - half, y, 11 + half, y, "y" if (y % 2) else "F")
    for x, y in ((8, 6), (14, 4), (17, 9), (5, 10)): p.px(x, y, "r")
    p.px(12, 5, "m")
    return p


def giant_mushroom():
    """A giant mushroom of Mycendra (the game's own): a tall pale stalk under a broad violet cap."""
    p = Pic(26, 30, (13, 29))
    p.rect(11, 12, 15, 29, "m"); p.rect(11, 12, 12, 29, "M")
    blob(p, 13, 9, 12, 6, "R"); blob(p, 12, 8, 10, 4.5, "r")
    for x in (6, 11, 17): p.px(x, 7, "m")
    p.rect(2, 13, 24, 13, "R")
    return p


def glow_caps():
    """A cluster of small glowing mushrooms (Mycendra, the game's own)."""
    p = Pic(16, 10, (8, 9))
    for x, h in ((2, 4), (6, 7), (10, 5), (13, 3)):
        p.rect(x, 9 - h, x, 9, "m"); p.rect(x - 1, 8 - h, x + 1, 8 - h, "a"); p.px(x, 7 - h, "a")
    return p


def anthill():
    """An ant-hill of the Myrmidon Hive (Ovid, Metamorphoses 7: the ants' hill under Aeacus' oak): a great mound of
    sand with dark tunnel mouths."""
    p = Pic(30, 18, (15, 17))
    blob(p, 15, 14, 14, 8, "E"); blob(p, 14, 13, 11, 6, "e")
    for x, y in ((9, 12), (17, 9), (21, 14)): p.rect(x, y, x + 1, y + 1, "z")
    return p


def elf_mill():
    """An elf-mill stone (Scandinavian folklore: boulders with cup-shaped hollows where offerings were left for the
    elves): a low mossy boulder pitted with small round cups."""
    p = Pic(24, 14, (12, 13))
    blob(p, 12, 9, 11, 5, "G"); blob(p, 11, 8, 9, 4, "g")
    for x, y in ((6, 7), (10, 6), (14, 8), (17, 6), (9, 10)): p.px(x, y, "G"); p.px(x + 1, y, "I")
    for x in (3, 19): p.px(x, 6, "l"); p.px(x + 1, 7, "l")
    return p


def fairy_knowe():
    """A fairy knowe (Scottish folklore: the green hill the fairy folk live under, as in Thomas the Rhymer): a round
    grassy hill with a ring of white mushrooms at its foot."""
    p = Pic(32, 18, (16, 17))
    blob(p, 16, 16, 15, 10, "x"); blob(p, 15, 15, 12, 8, "u")
    for k in range(8):
        x = 3 + k * 4
        p.px(x, 16, "m"); p.px(x, 15, "M")
    return p


def sheepfold():
    """A shepherd's sheepfold in the Arcadian hills (Pausanias 8: a land of herdsmen): a low ring of dry-stone wall."""
    p = Pic(32, 16, (16, 15))
    for a in range(60):
        t = a / 60 * 2 * math.pi
        x, y = round(16 + 14 * math.cos(t)), round(9 + 6 * math.sin(t))
        if not (0.2 < t < 0.7):
            p.rect(x, y, x + 1, y + 1, "g" if a % 3 else "G")
    return p


def dragons_teeth():
    """Dragon's teeth in a furrow (Apollodorus 3.4.1: Cadmus sowed the teeth of the dragon he killed, and armed men
    sprang up): white fangs sticking up out of a ploughed strip of earth."""
    p = Pic(28, 12, (14, 11))
    p.rect(1, 8, 26, 11, "b"); p.rect(1, 8, 26, 8, "B")
    for x, h in ((4, 5), (9, 7), (14, 4), (19, 6), (23, 5)):
        for y in range(8 - h, 8):
            p.rect(x, y, x + max(0, (y - (8 - h)) // 3), y, "m")
    return p


def palisade():
    """A stretch of Ghorvast's palisade (the game's own): sharpened stakes lashed together."""
    p = Pic(32, 22, (16, 21))
    for x in range(1, 31, 4):
        p.rect(x, 5, x + 2, 21, "b"); p.rect(x, 5, x, 21, "B")
        p.px(x + 1, 3, "b"); p.rect(x, 4, x + 2, 4, "b")
    p.rect(0, 12, 31, 12, "B"); p.rect(0, 17, 31, 17, "B")
    return p


def minoan_column():
    """A column of the palace of Knossos: red, wider at the top than the bottom, with a black cushion capital."""
    p = Pic(14, 30, (7, 29))
    for y in range(6, 28):
        w = 3 + (28 - y) // 8
        p.rect(7 - w, y, 6 + w, y, "R" if y % 7 else "r")
    p.rect(2, 2, 11, 5, "z"); p.rect(1, 0, 12, 1, "z"); p.rect(3, 28, 10, 29, "M")
    return p


def labyrinth_wall():
    """A stretch of the Labyrinth's wall (Ovid, Metamorphoses 8: Daedalus' building of winding passages): a dressed
    stone wall turning a corner."""
    p = Pic(30, 20, (15, 19))
    p.rect(0, 6, 29, 19, "M"); p.rect(20, 0, 29, 19, "M")
    for y in range(6, 20, 4):
        for x in range(0 if y % 8 else 3, 30, 6):
            p.rect(x, y, x, y + 3, "n")
        p.rect(0, y, 29, y, "n")
    p.rect(0, 6, 19, 6, "m"); p.rect(20, 0, 29, 0, "m")
    return p


SCENERY = {f.__name__: f for f in (olive_tree, broken_column, marble_ruin, pine_tree, runestone, longhouse_ruin, obelisk,
                                   tomb_entrance, nile_reeds, standing_stone, stone_circle, gorse, grave_stele, lekythos, giant_steps, castle_ruin,
                                   ziggurat_ruin, boundary_stone, log_hut_ruin, div_palace_ruin, well_sweep, bamboo_clump,
                                   castle_wall_ruin, smoking_vent, obsidian_spire, ice_shard,
                                   frozen_root, drowned_arch, sea_gate, birds_wall,
                                   nest_tower, pagoda_ruin, barrow_mound, stone_tomb, fallen_log, granite_tor, walpurgis_fire, anvil, forge_hearth, stalagmite, hoard_heap, giant_mushroom, glow_caps, anthill, elf_mill, fairy_knowe, sheepfold, dragons_teeth, palisade, minoan_column, labyrinth_wall)}

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "scenery")
    os.makedirs(out_dir, exist_ok=True)
    palette = {k: v for k, v in PALETTE.items() if len(k) == 1}
    for name, make in SCENERY.items():
        art = finish(make(), 0.0)
        # Weathered like the shrines (owner request 10/31/2026); gorse flowers and snow keep their brightness.
        pal, frames = weather(palette, {"idle": [art["rows"]]}, name, keep={"f", "s"})
        data = {"_doc": "Scenery picture (docs/ART_RULES.md: Scenery), built by tools/art/build_scenery.py, weathered by "
                        "tools/art/weathering.py. " + " ".join(make.__doc__.split()), "size": art["size"],
                "anchor": [art["grip"][0], art["size"][1] - 1], "palette": pal, "frames": frames}
        with open(os.path.join(out_dir, name + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote", len(SCENERY), "scenery pictures")
