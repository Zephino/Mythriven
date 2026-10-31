# Menu backdrops and the logo (owner decisions 10/31/2026, docs/DECISIONS.md "Menus"): still pixel-art scenes, one
# chosen at random each time the game loads (never the same twice in a row), each with its matching frame style:
#   greek_dusk      a marble temple on a cliff over the wine-dark sea at dusk          (greek: marble and gold)
#   norse_fjord     a longhouse by a fjord under the northern lights                   (norse: wood and iron)
#   egypt_sunset    a temple gateway and obelisk by the Nile at sunset                 (egyptian: sandstone and lapis)
#   misty_stones    a stone circle on green hills in moonlit mist                      (celtic: mossy stone)
#   heroes_road     a road over the hills at dawn to a stone shrine (heroes walk it)   (celtic)
#   heroes_camp     a campfire at night below a lit temple on a hill (heroes gather)   (greek)
# The heroes themselves are drawn by the game over the scene ("mode" walk or camp). The shrine stands on the left;
# the title's buttons sit in the middle. 480 x 270, weathered, written as palette rows like every other picture.
# Run: python3 build_menu_art.py from tools/art/. Writes data/art/menu/<scene>.json and data/art/menu/logo.json.
import json, math, os, random
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "menu")
W, H = 480, 270
KEYS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&*+-=?@^_~<>:;,|/()[]{}"
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def hexc(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def sky(img, stops, top=0, bottom=H, bands=12):
    """A sky in bands, dithered where they meet (pixel-art gradients)."""
    px = img.load()
    for y in range(top, bottom):
        t = (y - top) / max(bottom - top - 1, 1)
        for k in range(len(stops) - 1):
            if stops[k][0] <= t <= stops[k + 1][0]:
                u = (t - stops[k][0]) / max(stops[k + 1][0] - stops[k][0], 1e-6)
                a, b = hexc(stops[k][1]), hexc(stops[k + 1][1])
                break
        level = u * bands
        lo = int(level)
        frac = level - lo
        for x in range(W):
            step = lo + (1 if frac * 16 > BAYER[y % 4][x % 4] else 0)
            px[x, y] = lerp(a, b, min(step / bands, 1.0)) + (255,)


def disc(d, cx, cy, r, col, glow=None, glow_r=0):
    """A sun or moon: a bright disc in two thin halo rings, pixel-art style (soft glows don't survive the palette)."""
    if glow:
        d.ellipse([cx - r - 5, cy - r - 5, cx + r + 5, cy + r + 5], fill=hexc(glow) + (70,))
        d.ellipse([cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2], fill=hexc(glow) + (150,))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=hexc(col) + (255,))


def ridge(d, rnd, base, rough, col, x0=0, x1=W, step=6, peak=None):
    """A mountain or hill line from x0 to x1 (random walk), filled below."""
    pts = [(x0, H)]
    y = base
    for x in range(x0, x1 + step, step):
        y += rnd.uniform(-rough, rough)
        if peak:
            y = y * 0.7 + (base - peak[1] * math.exp(-((x - peak[0]) / peak[2]) ** 2)) * 0.3
        pts.append((x, y))
    pts.append((x1, H))
    d.polygon(pts, fill=hexc(col) + (255,))
    return pts


def stars(d, rnd, n, top, bottom, col="#f0f0ff"):
    for _ in range(n):
        x, y = rnd.randrange(W), rnd.randrange(top, bottom)
        d.point((x, y), fill=hexc(col) + (rnd.randrange(120, 255),))


def cloud(d, rnd, cx, cy, w, col, alpha=150):
    """A long wisp of cloud: thin streaks, lit on top."""
    for k in range(5):
        x = cx + rnd.uniform(-w / 2, w / 2); y = cy + rnd.uniform(-5, 5); length = rnd.uniform(w * 0.3, w * 0.6)
        d.rectangle([x - length / 2, y, x + length / 2, y + 2], fill=hexc(col) + (alpha,))
        d.rectangle([x - length / 3, y - 1, x + length / 3, y], fill=hexc(col) + (alpha // 2,))


def speckle(img, rnd, box, cols, n):
    px = img.load()
    for _ in range(n):
        x, y = rnd.randrange(box[0], box[2]), rnd.randrange(box[1], box[3])
        if 0 <= x < W and 0 <= y < H and px[x, y][3] > 0:
            px[x, y] = hexc(rnd.choice(cols)) + (255,)


def olive(d, x, y, s, dark, mid, light, trunk):
    d.line([(x, y), (x - 1, y - 8 * s), (x + 1, y - 12 * s)], fill=hexc(trunk) + (255,), width=max(1, int(2 * s)))
    d.ellipse([x - 9 * s, y - 22 * s, x + 9 * s, y - 9 * s], fill=hexc(dark) + (255,))
    d.ellipse([x - 7 * s, y - 22 * s, x + 5 * s, y - 13 * s], fill=hexc(mid) + (255,))
    d.ellipse([x - 5 * s, y - 21 * s, x, y - 17 * s], fill=hexc(light) + (255,))


def cypress(d, x, y, s, dark, mid):
    d.polygon([(x, y - 34 * s), (x + 4 * s, y - 14 * s), (x + 3 * s, y), (x - 3 * s, y), (x - 4 * s, y - 14 * s)], fill=hexc(dark) + (255,))
    d.polygon([(x, y - 32 * s), (x - 3 * s, y - 14 * s), (x - 2 * s, y - 2), (x, y - 2)], fill=hexc(mid) + (255,))


def pine(d, x, y, s, dark, mid, snow=None):
    d.rectangle([x - 1, y - 5 * s, x + 1, y], fill=hexc("#3a2a1a") + (255,))
    for k in range(4):
        top = y - (30 - k * 7) * s; w = (5 + k * 3) * s
        d.polygon([(x, top), (x + w, top + 10 * s), (x - w, top + 10 * s)], fill=hexc(dark) + (255,))
        d.polygon([(x, top), (x - w, top + 10 * s), (x - w * 0.3, top + 10 * s)], fill=hexc(mid) + (255,))
        if snow:
            d.line([(x - w * 0.6, top + 7 * s), (x, top + 2 * s)], fill=hexc(snow) + (255,))


def palm(d, x, y, s, trunk, frond, frond_d):
    for k in range(int(30 * s)):
        d.point((x + int(k * 0.15), y - k), fill=hexc(trunk) + (255,)); d.point((x + 1 + int(k * 0.15), y - k), fill=hexc(trunk) + (255,))
    tx, ty = x + int(30 * s * 0.15), y - 30 * s
    for a in range(6):
        ang = math.pi * (1.0 + a * 0.2)
        pts = [(tx + math.cos(ang) * d2 * s, ty + math.sin(ang) * d2 * s * 0.4 + (d2 / 14) ** 2 * 4 * s) for d2 in range(0, 15)]
        d.line(pts, fill=hexc(frond if a % 2 else frond_d) + (255,), width=2)


def greek_temple(d, x, y, s, marble, shade, dark, roof, glow=None):
    """A Doric temple: steps, six columns, an entablature and a pediment."""
    w = 90 * s
    for k in range(3):
        d.rectangle([x - k * 2, y - k * 3, x + w + k * 2, y - k * 3 + 3], fill=hexc(shade if k else dark) + (255,))
    top = y - 9 - 34 * s
    if glow:
        d.rectangle([x + 6, top + 8, x + w - 6, y - 9], fill=hexc(glow) + (255,))
    for c in range(6):
        cx = x + 6 + c * (w - 12) / 5
        d.rectangle([cx - 3 * s, top + 8, cx + 3 * s, y - 9], fill=hexc(marble) + (255,))
        d.line([(cx + 2 * s, top + 8), (cx + 2 * s, y - 9)], fill=hexc(shade) + (255,))
    d.rectangle([x - 2, top, x + w + 2, top + 8], fill=hexc(marble) + (255,))
    d.line([(x - 2, top + 8), (x + w + 2, top + 8)], fill=hexc(shade) + (255,))
    d.polygon([(x - 4, top), (x + w / 2, top - 16 * s), (x + w + 4, top)], fill=hexc(roof) + (255,))
    d.polygon([(x + 4, top - 2), (x + w / 2, top - 13 * s), (x + w - 4, top - 2)], fill=hexc(marble) + (255,))


def longhouse(d, x, y, wood, wood_d, turf, glow):
    d.rectangle([x, y - 22, x + 96, y], fill=hexc(wood) + (255,))
    for k in range(x, x + 96, 6):
        d.line([(k, y - 22), (k, y)], fill=hexc(wood_d) + (255,))
    d.polygon([(x - 8, y - 20), (x + 48, y - 48), (x + 104, y - 20)], fill=hexc(turf) + (255,))
    d.line([(x - 8, y - 20), (x + 48, y - 48), (x + 104, y - 20)], fill=hexc(wood_d) + (255,), width=2)
    d.line([(x + 44, y - 50), (x + 40, y - 56)], fill=hexc(wood_d) + (255,), width=2)       # carved gable ends
    d.line([(x + 52, y - 50), (x + 56, y - 56)], fill=hexc(wood_d) + (255,), width=2)
    d.rectangle([x + 40, y - 16, x + 54, y], fill=hexc(glow) + (255,))


def pylon(d, x, y, stone, shade, dark, lapis):
    """An Egyptian temple gateway: two sloping towers with a cornice, a gate between, banners."""
    for tx in (x, x + 70):
        d.polygon([(tx, y), (tx + 4, y - 60), (tx + 40, y - 60), (tx + 44, y)], fill=hexc(stone) + (255,))
        d.polygon([(tx + 30, y), (tx + 36, y - 60), (tx + 40, y - 60), (tx + 44, y)], fill=hexc(shade) + (255,))
        d.rectangle([tx + 2, y - 64, tx + 42, y - 60], fill=hexc(lapis) + (255,))
        for k in range(3):
            d.line([(tx + 10 + k * 9, y - 52), (tx + 10 + k * 9, y - 40)], fill=hexc(dark) + (255,))
    d.rectangle([x + 44, y - 40, x + 70, y], fill=hexc(stone) + (255,))
    d.rectangle([x + 50, y - 34, x + 64, y], fill=hexc(dark) + (255,))
    d.rectangle([x + 44, y - 44, x + 70, y - 40], fill=hexc(lapis) + (255,))


def obelisk(d, x, y, h, stone, shade, gold):
    d.polygon([(x - 4, y), (x - 3, y - h), (x + 3, y - h), (x + 4, y)], fill=hexc(stone) + (255,))
    d.polygon([(x + 1, y), (x + 1, y - h), (x + 3, y - h), (x + 4, y)], fill=hexc(shade) + (255,))
    d.polygon([(x - 3, y - h), (x, y - h - 6), (x + 3, y - h)], fill=hexc(gold) + (255,))


def standing_stone(d, x, y, w, h, stone, shade, moss=None):
    d.polygon([(x - w / 2, y), (x - w / 2 + 1, y - h + 3), (x, y - h), (x + w / 2 - 1, y - h + 2), (x + w / 2, y)], fill=hexc(stone) + (255,))
    d.polygon([(x + 1, y - h + 1), (x + w / 2 - 1, y - h + 2), (x + w / 2, y), (x + 2, y)], fill=hexc(shade) + (255,))
    if moss:
        d.line([(x - w / 2 + 1, y - 4), (x - 1, y - 6)], fill=hexc(moss) + (255,))


def mist(img, y, h, col, alpha):
    over = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(over)
    rnd = random.Random(y)
    for x in range(-40, W + 40, 30):
        d.ellipse([x, y - h / 2 + rnd.uniform(-3, 3), x + 70, y + h / 2], fill=hexc(col) + (alpha,))
    img.alpha_composite(over)


# --- The scenes -----------------------------------------------------------------------------------------------------

def greek_dusk():
    rnd = random.Random(1)
    img = Image.new("RGBA", (W, H)); d = ImageDraw.Draw(img, "RGBA")
    sky(img, [(0, "#2a1e48"), (0.35, "#6a3a6a"), (0.62, "#d8705a"), (0.8, "#f0b070"), (1, "#f8d898")], 0, 175)
    disc(d, 360, 150, 16, "#ffe0a0", "#ffb070", 40)
    for cx, cy, w in ((90, 60, 120), (300, 40, 160), (420, 90, 90)):
        cloud(d, rnd, cx, cy, w, "#f0a080", 110)
    d.rectangle([0, 165, W, H], fill=hexc("#3a2a5a") + (255,))                      # the wine-dark sea
    for y in range(168, 215, 3):
        for x in range(rnd.randrange(4), W, rnd.randrange(14, 24)):
            d.line([(x, y), (x + rnd.randrange(3, 9), y)], fill=hexc("#5a3e6a") + (255,))
    for y in range(166, 215, 2):                                                    # the sun's path on the water
        w = 4 + (y - 166) * 0.6
        d.line([(360 - w, y), (360 + w, y)], fill=hexc("#f0a070" if y % 4 else "#ffd090") + (200,))
    ridge(d, rnd, 205, 2, "#5a4a3a", 0, W)                                           # the shore
    d.polygon([(0, 140), (60, 128), (150, 132), (210, 150), (240, 175), (230, H), (0, H)], fill=hexc("#6a5844") + (255,))  # the cliff
    d.polygon([(0, 140), (60, 128), (150, 132), (210, 150), (215, 156), (150, 140), (60, 136), (0, 148)], fill=hexc("#8a7458") + (255,))
    speckle(img, rnd, (0, 130, 240, H), ["#5a4a38", "#7a664c"], 700)
    greek_temple(d, 30, 132, 1.0, "#f0e2cc", "#c8b49a", "#8a7a68", "#b8604a", "#d89a6a")
    for x, s in ((150, 1.0), (176, 0.8), (12, 0.9)):
        olive(d, x, 150 if x > 140 else 160, s, "#4a5a3a", "#6a7a4a", "#8a9a6a", "#4a3624")
    for x in (198, 214):
        cypress(d, x, 160, 1.1, "#2a3a2a", "#3e5038")
    d.polygon([(110, 175), (300, 205), (480, 215), (480, 270), (0, 270), (0, 190)], fill=hexc("#7a6248") + (255,))   # the road
    speckle(img, rnd, (0, 190, W, H), ["#6a5440", "#8a7058"], 900)
    return img, {"style": "greek", "mode": "walk", "shrine_x": 75, "ground_y": 200, "walk_from_x": 200}


def norse_fjord():
    rnd = random.Random(2)
    img = Image.new("RGBA", (W, H)); d = ImageDraw.Draw(img, "RGBA")
    sky(img, [(0, "#0a0e22"), (0.5, "#16224a"), (1, "#2a3a6a")], 0, 160)
    stars(d, rnd, 160, 0, 150)
    over = Image.new("RGBA", (W, H), (0, 0, 0, 0)); od = ImageDraw.Draw(over)        # the northern lights
    for band in range(3):
        base = 40 + band * 18
        for x in range(0, W, 2):
            y = base + math.sin(x / 40 + band) * 14 + math.sin(x / 13) * 4
            od.line([(x, y), (x, y + 24 - band * 4)], fill=hexc("#5ae8a0" if band != 1 else "#4ac0d8") + (50 - band * 10,))
    img.alpha_composite(over)
    ridge_far = ridge(d, rnd, 120, 4, "#2a3048", 0, W, peak=(330, 40, 60))
    ridge_near = ridge(d, rnd, 140, 3, "#3e4864", 0, W, peak=(140, 30, 50))
    for pts, col in ((ridge_far, "#c8d4e8"), (ridge_near, "#dfe6ee")):            # snow along the ridges
        for (x, y) in pts[1:-1]:
            if y < 132:
                d.line([(x - 3, y + 1), (x + 3, y + 1)], fill=hexc(col) + (255,), width=2)
    d.rectangle([0, 160, W, 205], fill=hexc("#1a2a4a") + (255,))                      # the fjord
    for y in range(162, 205, 3):
        for x in range(rnd.randrange(5), W, rnd.randrange(16, 30)):
            d.line([(x, y), (x + rnd.randrange(3, 8), y)], fill=hexc("#3a5a7a") + (255,))
    ridge(d, rnd, 200, 2, "#d8e0ea", 0, W)                                           # snow on the shore
    speckle(img, rnd, (0, 195, W, H), ["#c4ccd8", "#eef2f6"], 900)
    longhouse(d, 22, 200, "#5a3e28", "#3a2618", "#4a5a3a", "#f0a040")
    for x, s in ((140, 1.1), (160, 0.9), (8, 0.8), (440, 1.2), (462, 1.0), (420, 0.8)):
        pine(d, x, 205, s, "#1e3424", "#2e4a34", "#e8eef6")
    return img, {"style": "norse", "mode": "walk", "shrine_x": 70, "ground_y": 212, "walk_from_x": 200}


def egypt_sunset():
    rnd = random.Random(3)
    img = Image.new("RGBA", (W, H)); d = ImageDraw.Draw(img, "RGBA")
    sky(img, [(0, "#4a1e2a"), (0.4, "#b8402c"), (0.75, "#f08a3a"), (1, "#f8d070")], 0, 170)
    disc(d, 380, 140, 22, "#fff0b0", "#ffb050", 50)
    d.polygon([(250, 170), (300, 120), (350, 170)], fill=hexc("#a8603a") + (255,))   # pyramids in the haze
    d.polygon([(300, 120), (350, 170), (320, 170)], fill=hexc("#8a4a2e") + (255,))
    d.polygon([(330, 170), (365, 136), (400, 170)], fill=hexc("#b06a40") + (255,))
    d.rectangle([0, 168, W, 196], fill=hexc("#3a5a7a") + (255,))                      # the Nile
    for y in range(170, 196, 3):
        for x in range(rnd.randrange(5), W, rnd.randrange(14, 26)):
            d.line([(x, y), (x + rnd.randrange(3, 9), y)], fill=hexc("#f0a060" if abs(x - 380) < 40 else "#5a7a9a") + (255,))
    d.rectangle([0, 192, W, H], fill=hexc("#c89a5a") + (255,))                       # sand
    speckle(img, rnd, (0, 192, W, H), ["#b88a4a", "#d8b070"], 1200)
    for x in range(0, W, 7):                                                         # reeds along the bank
        h = rnd.randrange(6, 14)
        d.line([(x, 194), (x + 1, 194 - h)], fill=hexc("#4a6a2a") + (255,))
    pylon(d, 10, 196, "#d8b47e", "#b08c5c", "#5a4028", "#2a5aa0")
    obelisk(d, 140, 196, 64, "#d8b47e", "#b08c5c", "#f0c040")
    for x, s in ((170, 1.0), (196, 1.2), (430, 1.1), (455, 0.9)):
        palm(d, x, 200, s, "#6a4a2a", "#5a7a3a", "#3e5a28")
    return img, {"style": "egyptian", "mode": "walk", "shrine_x": 64, "ground_y": 214, "walk_from_x": 210}


def misty_stones():
    rnd = random.Random(4)
    img = Image.new("RGBA", (W, H)); d = ImageDraw.Draw(img, "RGBA")
    sky(img, [(0, "#0e1424"), (0.6, "#24304a"), (1, "#4a5a6a")], 0, 170)
    stars(d, rnd, 90, 0, 120, "#d8e0f0")
    disc(d, 380, 60, 14, "#f0f0e0", "#a8b8c8", 36)
    ridge(d, rnd, 150, 3, "#2a3a34", 0, W, peak=(300, 20, 90))
    mist(img, 158, 12, "#a8b4b8", 34)
    ridge(d, rnd, 175, 2, "#3a5a3a", 0, W, peak=(80, 18, 70))
    mist(img, 182, 10, "#b8c4c4", 30)
    d.rectangle([0, 196, W, H], fill=hexc("#4a6a3a") + (255,))
    ridge(d, rnd, 196, 1.5, "#4a6a3a", 0, W)
    speckle(img, rnd, (0, 190, W, H), ["#3e5a30", "#5a7a46", "#7a8a5a"], 1200)
    for k in range(7):                                                               # the stone circle on its hill
        a = math.pi * 2 * k / 7
        x = 80 + math.cos(a) * 52; y = 168 + math.sin(a) * 10
        standing_stone(d, x, y, 9, 18 + (6 if math.sin(a) > 0 else 0), "#8a8a84", "#5e5e58", "#5a7a3a")
    for x in (170, 186, 444):
        d.ellipse([x - 8, 192, x + 8, 200], fill=hexc("#5a6a2a") + (255,))           # gorse
        for _ in range(5):
            d.point((x + rnd.randrange(-6, 6), 194 + rnd.randrange(4)), fill=hexc("#f0d030") + (255,))
    mist(img, 205, 12, "#c8d0d0", 28)
    return img, {"style": "celtic", "mode": "walk", "shrine_x": 80, "ground_y": 214, "walk_from_x": 210}


def heroes_road():
    rnd = random.Random(5)
    img = Image.new("RGBA", (W, H)); d = ImageDraw.Draw(img, "RGBA")
    sky(img, [(0, "#2a3a6a"), (0.5, "#8a8ab0"), (0.8, "#f0c0a0"), (1, "#f8e0b0")], 0, 170)
    disc(d, 140, 150, 12, "#fff4c8", "#f8d0a0", 30)
    cloud(d, rnd, 330, 60, 170, "#f0d0c8", 90); cloud(d, rnd, 80, 80, 120, "#e8c8c0", 80)
    ridge(d, rnd, 140, 4, "#5a6080", 0, W, peak=(380, 40, 80))
    ridge(d, rnd, 165, 2, "#5a7a4a", 0, W, peak=(70, 40, 50))                         # the shrine's hill
    ridge(d, rnd, 195, 1.5, "#6a8a4a", 0, W)
    speckle(img, rnd, (0, 150, W, H), ["#5a7a40", "#7a9a56"], 1300)
    # A stone shrine on the hilltop: two posts, a lintel and a doorway (like the Celtic shrines in the game).
    for x in (52, 86):
        standing_stone(d, x, 132, 12, 30, "#9a9a94", "#6e6e68", "#5a7a3a")
    d.rectangle([46, 98, 94, 106], fill=hexc("#8a8a84") + (255,))
    d.rectangle([60, 108, 78, 132], fill=hexc("#1a1a24") + (255,))
    d.polygon([(70, 132), (150, 190), (330, 230), (480, 240), (480, 270), (300, 270), (120, 205), (62, 134)], fill=hexc("#a08a68") + (255,))  # the road
    speckle(img, rnd, (60, 130, W, H), ["#8a7458", "#b09a78"], 600)
    for x, s in ((200, 1.0), (230, 0.8), (420, 1.2)):
        olive(d, x, 196, s, "#3e5a30", "#5a7a40", "#7a9a5a", "#4a3624")
    return img, {"style": "celtic", "mode": "walk", "shrine_x": 70, "ground_y": 220, "walk_from_x": 220, "path": True}


def heroes_camp():
    rnd = random.Random(6)
    img = Image.new("RGBA", (W, H)); d = ImageDraw.Draw(img, "RGBA")
    sky(img, [(0, "#080a18"), (0.7, "#141c34"), (1, "#24304a")], 0, 180)
    stars(d, rnd, 220, 0, 160)
    disc(d, 410, 50, 10, "#f0f0e0", "#8090b0", 24)
    ridge(d, rnd, 150, 3, "#1a2034", 0, W)
    ridge(d, rnd, 165, 2, "#222a3e", 0, W, peak=(80, 45, 55))
    greek_temple(d, 40, 122, 0.8, "#b8b4c8", "#8a8698", "#5a586a", "#6a4a5a", "#e8a050")   # lit from within
    ridge(d, rnd, 200, 1.5, "#2a3a2e", 0, W)
    speckle(img, rnd, (0, 196, W, H), ["#24342a", "#34463a"], 900)
    over = Image.new("RGBA", (W, H), (0, 0, 0, 0)); od = ImageDraw.Draw(over)        # firelight on the ground
    for r in range(70, 0, -6):
        od.ellipse([150 - r * 1.6, 222 - r * 0.5, 150 + r * 1.6, 222 + r * 0.5], fill=hexc("#f0a040") + (int(26 * (1 - r / 70)),))
    img.alpha_composite(over)
    for k in range(4):                                                               # the fire's logs and stones
        a = math.pi * 2 * k / 4 + 0.4
        d.line([(150 - math.cos(a) * 8, 222 - math.sin(a) * 3), (150 + math.cos(a) * 8, 222 + math.sin(a) * 3)], fill=hexc("#4a2e1a") + (255,), width=2)
    for k in range(8):
        a = math.pi * 2 * k / 8
        d.ellipse([150 + math.cos(a) * 12 - 2, 222 + math.sin(a) * 4 - 1, 150 + math.cos(a) * 12 + 2, 222 + math.sin(a) * 4 + 1], fill=hexc("#6a6a70") + (255,))
    for x, s in ((260, 1.1), (450, 1.0), (10, 0.9)):
        pine(d, x, 205, s, "#14221a", "#1e3024")
    return img, {"style": "greek", "mode": "camp", "shrine_x": 76, "ground_y": 222, "fire": [150, 222]}


# --- The logo -----------------------------------------------------------------------------------------------------

GLYPHS = {
    "M": ["X.....X", "XX...XX", "X.X.X.X", "X..X..X", "X.....X", "X.....X", "X.....X", "X.....X", "X.....X"],
    "Y": ["X.....X", "X.....X", ".X...X.", "..X.X..", "...X...", "...X...", "...X...", "...X...", "...X..."],
    "T": ["XXXXXXX", "...X...", "...X...", "...X...", "...X...", "...X...", "...X...", "...X...", "...X..."],
    "H": ["X.....X", "X.....X", "X.....X", "X.....X", "XXXXXXX", "X.....X", "X.....X", "X.....X", "X.....X"],
    "R": ["XXXXXX.", "X.....X", "X.....X", "X.....X", "XXXXXX.", "X...X..", "X....X.", "X.....X", "X.....X"],
    "I": ["XXXXX", "..X..", "..X..", "..X..", "..X..", "..X..", "..X..", "..X..", "XXXXX"],
    "V": ["X.....X", "X.....X", "X.....X", "X.....X", ".X...X.", ".X...X.", "..X.X..", "..X.X..", "...X..."],
    "E": ["XXXXXXX", "X......", "X......", "X......", "XXXXXX.", "X......", "X......", "X......", "XXXXXXX"],
    "N": ["X.....X", "XX....X", "X.X...X", "X..X..X", "X...X.X", "X....XX", "X.....X", "X.....X", "X.....X"],
}


def logo():
    """MYTHRIVEN in carved gold letters (thick strokes, lit from the top, a dark bevel and outline) over a laurel."""
    text = "MYTHRIVEN"
    s = 2
    width = sum((len(GLYPHS[c][0]) + 2) * s for c in text) + 8
    height = 9 * s + 16
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    px = img.load()
    x0 = 4
    gold = [hexc("#fff0a8"), hexc("#f0cc58"), hexc("#d8a838"), hexc("#a87818")]
    for c in text:
        g = GLYPHS[c]
        for gy, row in enumerate(g):
            for gx, ch in enumerate(row):
                if ch != "X":
                    continue
                for dy in range(s):
                    for dx in range(s + 1):              # strokes a little thicker than the grid
                        x, y = x0 + gx * s + dx, 6 + gy * s + dy
                        band = min(3, (gy * s + dy) * 4 // (9 * s))
                        px[x, y] = gold[band] + (255,)
        x0 += (len(g[0]) + 2) * s
    # A dark bevel below and right, and an outline round it all.
    base = img.copy()
    bp = base.load()
    for y in range(height):
        for x in range(width):
            if bp[x, y][3] == 0 and (x > 0 and y > 0 and bp[x - 1, y - 1][3] > 0):
                px[x, y] = hexc("#6a4410") + (255,)
    out = img.copy(); op = out.load(); ip = img.load()
    for y in range(height):
        for x in range(width):
            if ip[x, y][3] == 0 and any(0 <= x + dx < width and 0 <= y + dy < height and ip[x + dx, y + dy][3] > 0
                                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                op[x, y] = hexc("#24160e") + (255,)
    # A thin laurel line under the name.
    d = ImageDraw.Draw(out)
    mid = width // 2
    d.line([(mid - 50, height - 5), (mid + 50, height - 5)], fill=hexc("#a87818") + (255,))
    for k in range(0, 46, 6):
        for sgn in (-1, 1):
            d.point((mid + sgn * (4 + k), height - 6), fill=hexc("#6a8a3a") + (255,))
            d.point((mid + sgn * (6 + k), height - 4), fill=hexc("#6a8a3a") + (255,))
    return out


def to_rows(img):
    """Gathers the picture's colours into a palette (as few as needed) and writes it as rows of letters."""
    rgba = img.convert("RGBA")
    alpha = [rgba.getpixel((x, y))[3] > 0 for y in range(rgba.height) for x in range(rgba.width)]
    q = rgba.convert("RGB").quantize(colors=len(KEYS), method=Image.Quantize.MEDIANCUT)
    pal = q.getpalette()
    used = sorted(set(q.getdata()))
    keymap = {idx: KEYS[k] for k, idx in enumerate(used)}
    palette = {keymap[i]: "#%02x%02x%02x" % tuple(pal[i * 3:i * 3 + 3]) for i in used}
    data = list(q.getdata())
    rows = []
    for y in range(rgba.height):
        rows.append("".join(keymap[data[y * rgba.width + x]] if alpha[y * rgba.width + x] else "."
                            for x in range(rgba.width)))
    return palette, rows


SCENES = {"greek_dusk": greek_dusk, "norse_fjord": norse_fjord, "egypt_sunset": egypt_sunset,
          "misty_stones": misty_stones, "heroes_road": heroes_road, "heroes_camp": heroes_camp}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, make in SCENES.items():
        img, meta = make()
        palette, rows = to_rows(img)
        doc = "Menu backdrop %s (docs/DECISIONS.md: Menus), built by tools/art/build_menu_art.py." % name
        with open(os.path.join(OUT, name + ".json"), "w") as f:
            json.dump(dict({"_doc": doc, "size": [W, H], "anchor": [0, 0], "palette": palette, "frames": {"idle": [rows]}},
                           **{"scene": meta}), f)
        img.save(os.path.join(os.environ.get("PREVIEW_DIR", "/tmp"), name + ".png"))
        print("wrote", name, len(palette), "colours")
    l = logo()
    palette, rows = to_rows(l)
    with open(os.path.join(OUT, "logo.json"), "w") as f:
        json.dump({"_doc": "The MYTHRIVEN logo: carved gold letters over a laurel line, built by tools/art/build_menu_art.py.",
                   "size": [l.width, l.height], "anchor": [0, 0], "palette": palette, "frames": {"idle": [rows]}}, f)
    l.save(os.path.join(os.environ.get("PREVIEW_DIR", "/tmp"), "logo.png"))
    print("wrote logo")
