# Trees, bushes and rocks for each level (docs/WORLD_PLAN.md: 1; owner request 10/31/2026): the real plants and stone
# of each land, every tree in three sizes, then weathered like the rest of the world (tools/art/weathering.py).
# Run: python3 build_flora.py from tools/art/. Writes data/art/flora/<level id>.json: frames named
# "<kind>_<size>" (trees: small, medium, large), "bush_<kind>", "boulder_<n>", "stone_<n>", "pebbles_<n>", each
# standing on its bottom edge, with "items" saying what each one is and how big its solid base is.
import json, math, os, random
from hero_kit import Canvas, ellipse, poly
from weathering import weather

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "flora")
SIZES = {"small": 0.7, "medium": 1.0, "large": 1.35}
# Solid trunk radius (px) by size; the canopy above is only drawn, never solid.
TRUNK_R = {"small": 4, "medium": 5, "large": 7}


def leafy(c, rnd, cx, cy, rx, ry, dark, mid, light, lumps=6):
    """A canopy of leaves: a dark mass, lit lumps toward the top left, speckled leaves."""
    ellipse(c, cx, cy + 1, rx, ry, dark)
    for _ in range(lumps):
        a = rnd.uniform(math.pi * 0.9, math.pi * 2.1)
        d = rnd.uniform(0.2, 0.6)
        ellipse(c, cx + math.cos(a) * rx * d, cy + math.sin(a) * ry * d - 1, rx * 0.45, ry * 0.42, mid)
    for _ in range(int(rx * ry * 0.12)):
        x = cx + rnd.uniform(-rx, rx * 0.5); y = cy + rnd.uniform(-ry, ry * 0.3)
        if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 < 0.8:
            c.px(int(x), int(y), light)
    for _ in range(int(rx * ry * 0.08)):
        x = cx + rnd.uniform(-rx, rx); y = cy + rnd.uniform(-ry * 0.2, ry)
        if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 < 0.9:
            c.px(int(x), int(y), dark)


def trunk(c, x, y0, y1, w, bark, bark_d, lean=0.0):
    for y in range(y0, y1 + 1):
        dx = round((y1 - y) * lean)
        c.rect(x + dx, y, x + dx + w - 1, y, bark)
        c.px(x + dx + w - 1, y, bark_d)


def roots(c, cx, y, w, col):
    c.rect(cx - w // 2 - 1, y, cx + w // 2 + 1, y, col)


# --- Trees: each draws on a canvas `s` times its medium size --------------------------------------------------------

def olive(c, rnd, s):
    w, h = c.w, c.h; cx = w // 2
    t = max(2, int(3 * s))
    for k in range(int(14 * s)):                                   # a gnarled, twisting trunk
        y = h - 1 - k
        x = cx - t // 2 + round(math.sin(k * 0.5) * 1.5 * s)
        c.rect(x, y, x + t - 1, y, "t"); c.px(x, y, "T")
    roots(c, cx, h - 1, t + 2, "T")
    leafy(c, rnd, cx, h * 0.38, w * 0.46, h * 0.3, "V", "v", "w", 8)


def cypress(c, rnd, s):
    w, h = c.w, c.h; cx = w // 2
    trunk(c, cx - 1, h - int(5 * s), h - 1, 2, "t", "T")
    for y in range(1, h - int(4 * s)):                              # a tall dark flame of foliage
        t = (y - 1) / (h - 5 * s)
        half = max(1, round((w * 0.42) * math.sin(math.pi * min(t * 1.1, 1.0)) ** 0.7))
        c.rect(cx - half, y, cx + half - 1, y, "P")
        if half > 1:
            c.rect(cx - half, y, cx - 1, y, "p")
    for _ in range(int(20 * s)):
        y = rnd.randrange(2, h - int(5 * s)); c.px(cx + rnd.randrange(-2, 1), y, "q")


def umbrella_pine(c, rnd, s):
    w, h = c.w, c.h; cx = w // 2
    trunk(c, cx - 1, int(h * 0.38), h - 1, max(2, int(2 * s)), "t", "T", lean=0.08)
    leafy(c, rnd, cx + 2, h * 0.24, w * 0.48, h * 0.18, "P", "p", "q", 7)      # a flat, spreading crown


def broadleaf(c, rnd, s, dark="V", mid="v", light="w", berries=None):
    w, h = c.w, c.h; cx = w // 2
    t = max(2, int(3 * s))
    trunk(c, cx - t // 2, int(h * 0.5), h - 1, t, "t", "T")
    c.px(cx - t // 2 - 1, int(h * 0.62), "t"); c.px(cx + t // 2 + 1, int(h * 0.58), "t")   # branches
    roots(c, cx, h - 1, t + 2, "T")
    leafy(c, rnd, cx, h * 0.36, w * 0.48, h * 0.33, dark, mid, light, 9)
    if berries:
        for _ in range(int(9 * s)):
            c.px(cx + rnd.randrange(-int(w * 0.35), int(w * 0.3)), int(h * 0.36) + rnd.randrange(-int(h * 0.2), int(h * 0.2)),
                 berries)


def spruce(c, rnd, s):
    w, h = c.w, c.h; cx = w // 2
    trunk(c, cx - 1, h - int(5 * s), h - 1, 2, "t", "T")
    tiers = 4
    for k in range(tiers):                                          # stacked tiers of drooping branches
        top = int(1 + k * (h - 6 * s) / (tiers + 0.6)); bottom = int(top + (h - 6 * s) / tiers * 1.5)
        for y in range(top, min(bottom, h - int(4 * s))):
            half = round((w * 0.48) * (y - top) / max(bottom - top, 1) * (0.55 + 0.45 * k / tiers)) + 1
            c.rect(cx - half, y, cx + half - 1, y, "P")
            c.rect(cx - half, y, cx - max(half // 3, 1), y, "p")
        c.rect(cx - 2, top + 1, cx, top + 1, "s")                   # snow on each tier
    c.px(cx, 0, "p")


def birch(c, rnd, s):
    w, h = c.w, c.h; cx = w // 2
    for y in range(int(h * 0.3), h):                                # a slim white trunk with dark marks
        c.rect(cx - 1, y, cx, y, "e")
        if rnd.random() < 0.25:
            c.px(cx - 1 + rnd.randrange(2), y, "k")
    leafy(c, rnd, cx, h * 0.3, w * 0.38, h * 0.27, "M", "m", "y", 6)


def palm(c, rnd, s, dates=True):
    w, h = c.w, c.h; cx = w // 2
    top = int(h * 0.25)
    for y in range(top, h):                                         # a ringed, leaning trunk
        x = cx + round((h - y) * 0.08)
        c.rect(x - 1, y, x, y, "t" if y % 3 else "T")
    hx = cx + round((h - top) * 0.08)
    for k in range(7):                                              # fronds arching out
        a = math.pi * (1.05 + k * 0.15)
        for d in range(int(w * 0.45)):
            x = hx + math.cos(a) * d; y = top + math.sin(a) * d * 0.55 + (d / (w * 0.45)) ** 2 * 6 * s
            c.px(int(x), int(y), "p" if d % 3 else "P"); c.px(int(x), int(y) + 1, "P")
    if dates:
        c.rect(hx - 2, top + 2, hx + 1, top + 4, "u")


def acacia(c, rnd, s):
    w, h = c.w, c.h; cx = w // 2
    for k in range(2):                                              # a forked trunk
        lean = -0.25 if k == 0 else 0.3
        for y in range(int(h * 0.3), h):
            c.px(cx + round((h - y) * lean * 0.5), y, "t")
    c.rect(cx - 1, int(h * 0.7), cx, h - 1, "t")
    leafy(c, rnd, cx, h * 0.24, w * 0.5, h * 0.12, "V", "v", "w", 6)          # a flat-topped crown


def dead_tree(c, rnd, s):
    """A dead tree: a bare grey trunk forking into crooked leafless branches."""
    w, h = c.w, c.h; cx = w // 2
    t = max(2, int(3 * s))
    trunk(c, cx - t // 2, int(h * 0.35), h - 1, t, "A", "B")
    roots(c, cx, h - 1, t + 2, "B")
    for side in (-1, 1):
        for k in range(2):
            x, y = cx + side, int(h * (0.38 + 0.12 * k))
            for _ in range(int(h * 0.3)):
                c.px(x, y, "A" if rnd.random() < 0.7 else "B")
                x += side if rnd.random() < 0.7 else 0
                y -= 1 if rnd.random() < 0.8 else 0
                if not (0 <= x < w and 0 <= y < h):
                    break


def bush(c, rnd, dark, mid, light, flower=None):
    w, h = c.w, c.h
    leafy(c, rnd, w / 2, h * 0.58, w * 0.46, h * 0.4, dark, mid, light, 5)
    if flower:
        for _ in range(int(w * h * 0.06)):
            x = rnd.randrange(2, w - 2); y = rnd.randrange(2, h - 2)
            if ((x - w / 2) / (w * 0.42)) ** 2 + ((y - h * 0.58) / (h * 0.36)) ** 2 < 1:
                c.px(x, y, flower)


def papyrus(c, rnd):
    w, h = c.w, c.h
    for k in range(5):
        x = 2 + k * (w - 4) // 4
        top = rnd.randrange(1, 5)
        c.rect(x, top + 2, x, h - 1, "m")
        c.rect(x - 1, top, x + 1, top + 1, "y"); c.px(x, top - 1, "y")


def fern(c, rnd):
    w, h = c.w, c.h
    for k in range(5):
        a = math.pi * (1.1 + k * 0.2)
        for d in range(int(w * 0.5)):
            c.px(int(w / 2 + math.cos(a) * d), int(h - 1 + math.sin(a) * d * 0.8), "m" if d % 2 else "M")


def boulder(c, rnd, light, mid, dark, moss=None):
    w, h = c.w, c.h
    pts = []
    for k in range(9):
        a = math.pi * 2 * k / 9
        r = rnd.uniform(0.8, 1.0)
        pts.append((w / 2 + math.cos(a) * (w / 2 - 1) * r, h * 0.55 + math.sin(a) * (h * 0.45 - 1) * r))
    poly(c, pts, mid)
    ellipse(c, w * 0.42, h * 0.42, w * 0.25, h * 0.2, light)
    for x in range(w):
        for y in range(int(h * 0.75), h):
            if c.g[y][x] != ".":
                c.g[y][x] = dark
    for _ in range(3):
        x, y = rnd.randrange(w // 4, 3 * w // 4), rnd.randrange(h // 3, 2 * h // 3)
        for k in range(3):
            c.px(x + k, y + k // 2, dark)
    if moss:
        for _ in range(int(w * 0.6)):
            x = rnd.randrange(w); y = rnd.randrange(h // 4, h // 2)
            if c.g[y][x] != ".":
                c.px(x, y, moss)


def slab(c, rnd, light, mid, dark, moss=None):
    """A flat slab of rock, its top lit."""
    w, h = c.w, c.h
    poly(c, [(1, h * 0.45), (w * 0.3, h * 0.2), (w - 2, h * 0.3), (w - 1, h - 1), (0, h - 1)], mid)
    poly(c, [(2, h * 0.45), (w * 0.3, h * 0.25), (w - 3, h * 0.33), (w - 4, h * 0.5), (3, h * 0.55)], light)
    c.row(h - 1, 0, w - 1, dark); c.row(h - 2, 1, w - 2, dark)
    if moss:
        for _ in range(w // 3):
            c.px(rnd.randrange(2, w - 2), int(h * 0.4), moss)


def jagged(c, rnd, light, mid, dark, moss=None):
    """A tall, jagged rock with sharp edges."""
    w, h = c.w, c.h
    poly(c, [(0, h - 1), (w * 0.2, h * 0.3), (w * 0.45, 0), (w * 0.6, h * 0.25), (w * 0.8, h * 0.15), (w - 1, h - 1)], mid)
    poly(c, [(w * 0.25, h * 0.35), (w * 0.45, 2), (w * 0.5, h * 0.6), (w * 0.3, h * 0.75)], light)
    for y in range(int(h * 0.8), h):
        for x in range(w):
            if c.g[y][x] != ".":
                c.g[y][x] = dark
    if moss:
        c.px(int(w * 0.6), int(h * 0.5), moss); c.px(int(w * 0.65), int(h * 0.55), moss)


def split_rock(c, rnd, light, mid, dark, moss=None):
    """A rounded rock split down the middle."""
    boulder(c, rnd, light, mid, dark, moss)
    w, h = c.w, c.h
    x = w // 2
    for y in range(2, h - 1):
        x += rnd.choice((-1, 0, 0, 1))
        if c.g[y][x] != ".":
            c.g[y][x] = "k"


def mound(c, rnd, light, mid, dark, ripples):
    """A sand dune or snow drift: a long low mound, its crest catching the light, the lee side in shadow, with wind
    ripples (sand) or a smooth crust (snow)."""
    w, h = c.w, c.h
    crest = [h * 0.35 + math.sin(x / w * math.pi * 1.3 + 0.4) * h * 0.18 for x in range(w)]
    for x in range(w):
        edge = abs(x - w / 2) / (w / 2)
        top = int(crest[x] + edge ** 2 * h * 0.45)
        for y in range(top, h):
            c.px(x, y, light if y < top + 2 else (mid if x < w * 0.55 else dark))
    if ripples:
        for k in range(3):
            for x in range(int(w * 0.15), int(w * 0.85)):
                y = int(h * (0.6 + k * 0.12) + math.sin(x * 0.5 + k) * 0.8)
                if c.g[y][x] != "." and (x + k) % 3:
                    c.px(x, y, dark)


def stone(c, rnd, light, mid, dark):
    w, h = c.w, c.h
    ellipse(c, w / 2, h / 2 + 0.5, w / 2 - 0.5, h / 2 - 0.5, mid)
    c.px(int(w / 2) - 1, int(h / 2) - 1, light); c.row(h - 1, 2, w - 3, dark)


def pebbles(c, rnd, light, mid, dark):
    for _ in range(5):
        x, y = rnd.randrange(1, c.w - 2), rnd.randrange(1, c.h - 2)
        c.rect(x, y, x + 1, y, mid); c.px(x, y + 1, dark); c.px(x, y, light)


PALETTE = {
    "o": "#140c08", "k": "#2a2420",
    "t": "#6a4c32", "T": "#463020",                                   # bark
    "v": "#7a8c5a", "V": "#55663c", "w": "#a4b07c",                   # olive / grey-green leaves
    "p": "#3e6040", "P": "#28442e", "q": "#588a5a",                   # dark conifer / cypress
    "m": "#5e8a3c", "M": "#3e6428", "y": "#8cb45a",                   # fresh green
    "e": "#e8e4dc",                                                    # birch bark
    "s": "#eef2f6",                                                    # snow
    "u": "#c86a2a",                                                    # dates, rowan berries
    "r": "#c8a0c8", "R": "#e8d8e8", "h": "#f0f0e0",                   # heather, blossom
    "f": "#f0d030",                                                    # gorse flowers
    "a": "#c8c0ac", "A": "#a49c88", "B": "#7a7262",                   # pale limestone
    "g": "#9a9ca4", "G": "#76787e", "H": "#55565c",                   # granite
    "d": "#d4b07a", "D": "#b08c5c", "E": "#86683e",                   # sandstone
    "l": "#7a8a5a",                                                    # lichen, moss
    "j": "#f0d8a4", "J": "#e2c48c",                                   # dune sand, lit and plain
    "z": "#dfe6ee", "Z": "#b8c4d4",                                   # snow drift, plain and lee shadow
    "x": "#3c4438", "X": "#2a3028", "C": "#56604c",                   # black poplar (the Underworld)
    "i": "#7a8a6a", "I": "#5a6a4e", "L": "#98a888",                   # willow
    "n": "#5e5a64", "N": "#44404a", "O": "#2e2c34",                   # basalt
    "c": "#b02a3a",                                                    # pomegranates
}

# Each level: trees {kind: (draw, medium width, medium height)}, bushes {kind: (draw args)}, its rock colours.
LEVELS = {
    "aegean_shore": {
        "trees": {"olive": (olive, 26, 30), "cypress": (cypress, 12, 38), "aleppo_pine": (umbrella_pine, 30, 34),
                  "holm_oak": (lambda c, r, s: broadleaf(c, r, s, "P", "p", "q"), 28, 32)},
        "bushes": {"myrtle": ("V", "v", "w", "h"), "rosemary": ("P", "p", "q", "#"), "oleander": ("M", "m", "y", "R")},
        "rock": ("a", "A", "B", None)},
    "midgards_edge": {
        "trees": {"spruce": (spruce, 22, 40), "scots_pine": (umbrella_pine, 24, 40), "birch": (birch, 18, 34)},
        "bushes": {"juniper": ("P", "p", "q", None), "bilberry": ("M", "m", "y", "B"), "fern": ("fern",)},
        "rock": ("g", "G", "H", "l"), "mound": ("s", "z", "Z", False)},
    "the_two_lands": {
        "trees": {"date_palm": (palm, 26, 38), "doum_palm": (lambda c, r, s: palm(c, r, s, False), 24, 34),
                  "acacia": (acacia, 32, 28), "sycamore_fig": (broadleaf, 30, 32)},
        "bushes": {"tamarisk": ("V", "v", "w", "r"), "papyrus": ("papyrus",), "desert_scrub": ("V", "v", "D", None)},
        "rock": ("d", "D", "E", None), "mound": ("j", "J", "D", True)},
    "the_misty_isles": {
        "trees": {"oak": (broadleaf, 30, 34), "ash": (lambda c, r, s: broadleaf(c, r, s, "M", "m", "y"), 26, 36),
                  "rowan": (lambda c, r, s: broadleaf(c, r, s, "M", "m", "y", "u"), 22, 30),
                  "yew": (lambda c, r, s: broadleaf(c, r, s, "P", "P", "p"), 26, 28),
                  "hawthorn": (lambda c, r, s: broadleaf(c, r, s, "M", "m", "y", "h"), 22, 26)},
        "bushes": {"gorse": ("P", "p", "q", "f"), "heather": ("r", "r", "R", "R"), "bramble": ("M", "P", "m", "B")},
        "rock": ("g", "G", "H", "l")},
    # Pack 2 (docs/PACK_2_PLAN.md). Black poplars and willows grow in Persephone's grove (Odyssey 10.509–510); cypress,
    # the tree of mourning; dead trees. Asphodel (Odyssey 11) and the pomegranate (Homeric Hymn to Demeter).
    # Jotunheim: the mountain forests of the north, thinner and wind-bitten, with dead trees; snow drifts.
    "jotunheim": {
        "trees": {"spruce": (spruce, 22, 40), "scots_pine": (umbrella_pine, 24, 40), "dead_tree": (dead_tree, 24, 32)},
        "bushes": {"juniper": ("P", "p", "q", None), "fern": ("fern",)},
        "rock": ("g", "G", "H", "l"), "mound": ("s", "z", "Z", False)},
    # Avalon's Shadow: the enchanted forest (oak, yew, hawthorn, ash); brambles and fern.
    "avalons_shadow": {
        "trees": {"oak": (broadleaf, 30, 34), "ash": (lambda c, r, s: broadleaf(c, r, s, "M", "m", "y"), 26, 36),
                  "yew": (lambda c, r, s: broadleaf(c, r, s, "P", "P", "p"), 26, 28),
                  "hawthorn": (lambda c, r, s: broadleaf(c, r, s, "M", "m", "y", "h"), 22, 26)},
        "bushes": {"bramble": ("M", "P", "m", "B"), "fern": ("fern",)},
        "rock": ("g", "G", "H", "l")},
    # The Land of Legends: Japanese cedar (sugi), black pine and maple on the mountain paths; bamboo stands as scenery.
    "the_land_of_legends": {
        "trees": {"japanese_cedar": (spruce, 22, 42), "black_pine": (umbrella_pine, 28, 34),
                  "maple": (lambda c, r, s: broadleaf(c, r, s, "M", "m", "y", "c"), 24, 28)},
        "bushes": {"azalea": ("M", "m", "y", "R"), "fern": ("fern",)},
        "rock": ("g", "G", "H", "l")},
    # The Slavic Wilds: the birch forest, with spruce and willows by the rivers; bilberries and fern.
    "the_slavic_wilds": {
        "trees": {"birch": (birch, 18, 34), "spruce": (spruce, 22, 40),
                  "willow": (lambda c, r, s: broadleaf(c, r, s, "I", "i", "L"), 30, 30)},
        "bushes": {"bilberry": ("M", "m", "y", "B"), "fern": ("fern",)},
        "rock": ("g", "G", "H", "l")},
    # Mazandaran: the Hyrcanian mountain forest of the Caspian shore (oak, hornbeam, plane trees), box and fern.
    "mazandaran": {
        "trees": {"oak": (broadleaf, 30, 34), "hornbeam": (lambda c, r, s: broadleaf(c, r, s, "M", "m", "y"), 24, 32),
                  "plane_tree": (lambda c, r, s: broadleaf(c, r, s, "P", "p", "q"), 32, 38)},
        "bushes": {"box": ("P", "p", "q", None), "fern": ("fern",)},
        "rock": ("g", "G", "H", "l")},
    # Pohjola: the dark northern forest of spruce and pine, and the birch of the Kalevala (runo 44: the kantele of birch).
    "pohjola": {
        "trees": {"spruce": (spruce, 22, 40), "scots_pine": (umbrella_pine, 24, 40), "birch": (birch, 18, 34)},
        "bushes": {"juniper": ("P", "p", "q", None), "bilberry": ("M", "m", "y", "B")},
        "rock": ("g", "G", "H", "l"), "mound": ("s", "z", "Z", False)},
    # The Land Between the Rivers: the cedars of the Cedar Forest (Gilgamesh, Tablet V), date palms and Euphrates
    # poplars by the water, tamarisk (Gilgamesh and the Huluppu tree); reed beds of the marshes.
    "the_land_between_the_rivers": {
        "trees": {"cedar": (umbrella_pine, 30, 38), "date_palm": (palm, 26, 38),
                  "euphrates_poplar": (lambda c, r, s: broadleaf(c, r, s, "I", "i", "L"), 22, 34)},
        "bushes": {"tamarisk": ("V", "v", "w", "r"), "reeds": ("papyrus",)},
        "rock": ("d", "D", "E", None), "mound": ("j", "J", "D", True)},
    "the_underworld": {
        "trees": {"black_poplar": (lambda c, r, s: broadleaf(c, r, s, "X", "x", "C"), 22, 40),
                  "willow": (lambda c, r, s: broadleaf(c, r, s, "I", "i", "L"), 30, 30),
                  "cypress": (cypress, 12, 38), "dead_tree": (dead_tree, 24, 32)},
        "bushes": {"asphodel": ("I", "i", "L", "h"), "pomegranate": ("P", "p", "q", "c")},
        "rock": ("n", "N", "O", None)},
}


def build_level(level_id, spec):
    rnd = random.Random(level_id)
    frames, items = {}, {}
    for kind, (draw, mw, mh) in spec["trees"].items():
        for size, s in SIZES.items():
            for v in range(2):                                    # two of each, so no two look alike
                c = Canvas(max(6, round(mw * s)), max(8, round(mh * s)))
                draw(c, random.Random("%s/%s/%s/%d" % (level_id, kind, size, v)), s)
                name = "%s_%s_%d" % (kind, size, v)
                frames[name] = [c.outline()]
                items[name] = {"kind": "tree", "tree": kind, "size": size, "solid_r": TRUNK_R[size]}
    for kind, args in spec["bushes"].items():
        for v in range(2):
            r = random.Random("%s/%s/%d" % (level_id, kind, v))
            c = Canvas(14 + v * 4, 10 + v * 2)
            if args[0] == "papyrus":
                c = Canvas(14, 18); papyrus(c, r)
            elif args[0] == "fern":
                c = Canvas(16, 10); fern(c, r)
            else:
                bush(c, r, args[0], args[1], args[2], args[3] if args[3] not in (None, "#") else None)
            name = "bush_%s_%d" % (kind, v)
            frames[name] = [c.outline()]
            items[name] = {"kind": "bush", "solid_r": 0}
    light, mid, dark, moss = spec["rock"]
    # Rocks in several styles (rounded, flat slab, tall and jagged, split), each in three sizes (owner request
    # 10/31/2026); they also gather in clusters in the world (scripts/world/flora.gd).
    styles = {"round": (boulder, 22, 18), "slab": (slab, 28, 14), "jagged": (jagged, 16, 24), "split": (split_rock, 22, 18)}
    for style, (draw, mw, mh) in styles.items():
        for size, s in SIZES.items():
            w, h = max(8, round(mw * s)), max(7, round(mh * s))
            c = Canvas(w, h); draw(c, random.Random("%s/%s/%s" % (level_id, style, size)), light, mid, dark, moss)
            name = "boulder_%s_%s" % (style, size)
            frames[name] = [c.outline()]
            items[name] = {"kind": "boulder", "size": size, "solid_r": max(3, int(w * 0.38))}
    for v, (w, h) in enumerate([(8, 6), (10, 7), (7, 5)]):
        c = Canvas(w, h); stone(c, rnd, light, mid, dark)
        frames["stone_%d" % v] = [c.outline()]
        items["stone_%d" % v] = {"kind": "stone", "slow_r": int(w * 0.6)}
    for v in range(2):
        c = Canvas(10, 6); pebbles(c, random.Random("%s/pebbles/%d" % (level_id, v)), light, mid, dark)
        frames["pebbles_%d" % v] = [["".join(r) for r in c.g]]
        items["pebbles_%d" % v] = {"kind": "pebbles"}
    # Sand dunes (desert) and snow drifts (the north): big low mounds you walk over, slowly (owner request 10/31/2026).
    if "mound" in spec:
        light2, mid2, dark2, ripples = spec["mound"]
        for size, s in SIZES.items():
            c = Canvas(round(64 * s), round(22 * s))
            mound(c, random.Random("%s/mound/%s" % (level_id, size)), light2, mid2, dark2, ripples)
            name = "mound_%s" % size
            frames[name] = [["".join(r) for r in c.g]]
            items[name] = {"kind": "mound", "size": size, "slow_r": round(26 * s)}
    pal, frames = weather(PALETTE, frames, level_id, keep={"s", "f", "u", "h", "R", "k", "c"})
    return pal, frames, items


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for level_id, spec in LEVELS.items():
        pal, frames, items = build_level(level_id, spec)
        data = {"_doc": "Trees, bushes and rocks of %s (docs/WORLD_PLAN.md: 1), built by tools/art/build_flora.py and "
                        "weathered. items: kind (tree, bush, boulder, stone, pebbles), solid_r (the solid base in px; 0 = "
                        "walk over), slow_r (stones that slow you)." % level_id,
                "palette": pal, "frames": frames, "items": items}
        with open(os.path.join(OUT, level_id + ".json"), "w") as f:
            json.dump(data, f, indent=1)
        print("wrote", level_id, len(frames), "pictures")
