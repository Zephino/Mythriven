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


SCENERY = {f.__name__: f for f in (olive_tree, broken_column, marble_ruin, pine_tree, runestone, longhouse_ruin, obelisk,
                                   tomb_entrance, nile_reeds, standing_stone, stone_circle, gorse, grave_stele, lekythos, giant_steps, castle_ruin,
                                   ziggurat_ruin, boundary_stone, log_hut_ruin, div_palace_ruin, well_sweep, bamboo_clump,
                                   castle_wall_ruin)}

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
