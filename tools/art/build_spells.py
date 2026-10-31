# Spell pictures (docs/ART_RULES.md: Spells): what each element's shot looks like in flight. Every spell or
# infused shot without its own picture flies as its element's (data/art/projectiles/element_<element>.json):
# drawn pointing up; the game turns it to face its flight, or spins it (scripts/combat/projectiles.gd).
# Run: python3 build_spells.py from tools/art/.
import json, math, os
from build_weapons import Pic, finish

PALETTE = {
    "o": "#24160e",
    "q": "#c83018", "f": "#ff9030", "F": "#ffe070", "W": "#fffbe0",        # fire
    "i": "#d8f0ff", "I": "#88b8d8", "j": "#4a88b8",                        # ice
    "y": "#fff6a0", "Y": "#ffd040", "l": "#a8c8ff",                        # lightning
    "w": "#e8f4f0", "v": "#a8d0c8",                                        # wind
    "h": "#fffbe0", "H": "#ffe070", "u": "#f0c040",                        # holy light
    "d": "#4a3060", "D": "#2a1840", "p": "#9a6ac8",                        # dark
    "b": "#7ac0e8", "B": "#3a80c0", "c": "#d8f0ff",                        # water
    "e": "#9a7a50", "E": "#6a5034", "g": "#b89a6a",                        # earth
}


def fireball():
    """Ember: a ball of fire, its flames streaming back from the way it flies."""
    p = Pic(9, 15, (4, 7))
    for y in range(15):
        t = y / 14
        half = 3.6 * (1 - t) ** 0.6 if y > 3 else [2.0, 3.0, 3.6, 3.8][y]
        for x in range(9):
            d = abs(x - 4)
            if d <= half:
                col = "q" if d > half - 1.2 else ("f" if d > half - 2.4 or y > 8 else "F")
                if y in (2, 3, 4) and d < 1.5:
                    col = "W"
                p.px(x, y, col)
    return p


def ice_shard():
    """Frost: a long, pointed shard of ice with a bright edge."""
    p = Pic(7, 15, (3, 7))
    for y in range(15):
        half = min(y / 3, 2.4) if y < 8 else max(2.4 - (y - 8) / 3, 0.6)
        for x in range(7):
            if abs(x - 3) <= half:
                p.px(x, y, "I" if x > 3 else "i")
    p.px(3, 0, "c"); p.col(2, 3, 10, "c")
    p.col(4, 4, 11, "j")
    return p


def bolt():
    """Lightning (Runo Song's third verse, and Spark's strikes): a short jagged bolt."""
    p = Pic(8, 16, (4, 8))
    pts = [(4, 0), (2, 5), (5, 7), (3, 11), (5, 15)]
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = max(abs(bx - ax), abs(by - ay))
        for k in range(n + 1):
            x = round(ax + (bx - ax) * k / n); y = round(ay + (by - ay) * k / n)
            p.px(x, y, "y"); p.px(x + 1, y, "Y"); p.px(x - 1, y, "l")
    return p


def gust():
    """Breeze: a gust of wind, curling lines in a ring (it spins as it flies)."""
    p = Pic(17, 17, (8, 8))
    for k in range(3):
        for a in range(0, 200, 8):
            r = 3 + k * 2.4 + a / 120
            ang = math.radians(a + k * 120)
            p.px(round(8 + math.cos(ang) * r), round(8 + math.sin(ang) * r), "w" if a < 150 else "v")
    return p


def light():
    """Glimmer: a bright mote of holy light with four rays."""
    p = Pic(11, 11, (5, 5))
    for y in range(11):
        for x in range(11):
            d = math.hypot(x - 5, y - 5)
            if d <= 2.4:
                p.px(x, y, "h" if d < 1.3 else "H")
    for k in range(1, 6):
        for x, y in ((5, 5 - k), (5, 5 + k), (5 - k, 5), (5 + k, 5)):
            p.px(x, y, "H" if k < 4 else "u")
    return p


def shadow():
    """Dark: a swirling orb of shadow with a violet edge."""
    p = Pic(11, 11, (5, 5))
    for y in range(11):
        for x in range(11):
            d = math.hypot(x - 5, y - 5)
            if d <= 4.4:
                a = math.atan2(y - 5, x - 5)
                p.px(x, y, "p" if d > 3.4 and math.sin(a * 3) > 0 else ("D" if d < 2 else "d"))
    return p


def droplet():
    """Water: a drop of water, its point leading."""
    p = Pic(7, 11, (3, 6))
    for y in range(11):
        half = y / 2.2 if y < 6 else math.sqrt(max(0.0, 9 - (y - 7) ** 2))
        for x in range(7):
            if abs(x - 3) <= min(half, 3):
                p.px(x, y, "B" if x > 3 else "b")
    p.px(2, 6, "c"); p.px(2, 7, "c")
    return p


def stone():
    """Earth: a rough lump of stone (it tumbles as it flies)."""
    p = Pic(9, 9, (4, 4))
    for y in range(9):
        for x in range(9):
            if math.hypot(x - 4, (y - 4) * 1.15) <= 3.6 + ((x * 7 + y * 3) % 3) * 0.3:
                p.px(x, y, "e")
    p.px(3, 3, "g"); p.px(4, 3, "g"); p.px(5, 6, "E"); p.px(6, 5, "E")
    return p


def coin():
    """Fortune (Tyche): a spinning gold coin with a bright rim."""
    p = Pic(9, 9, (4, 4))
    for y in range(9):
        for x in range(9):
            d = math.hypot(x - 4, y - 4)
            if d <= 3.8:
                p.px(x, y, "u" if d > 2.8 else "H")
    p.px(3, 3, "h"); p.px(4, 2, "h"); p.rect(4, 3, 4, 5, "u")
    return p


# Evolved spells (owner request 10/31/2026: they should look distinct): each is its element's shot grown bigger and
# brighter, written as data/art/projectiles/<weapon id>.json and named by that weapon's projectile_art.
def inferno():
    """Inferno (Ember evolved): a great white-hot fireball, its long flames streaming behind."""
    p = Pic(15, 25, (7, 9))
    for y in range(25):
        t = y / 24
        half = 6.4 * (1 - t) ** 0.55 if y > 5 else [3.0, 4.4, 5.4, 6.0, 6.4, 6.6][y]
        for x in range(15):
            d = abs(x - 7) + (0.8 * math.sin(y * 1.3) if y > 8 else 0)
            if d <= half:
                col = "q" if d > half - 1.4 else ("f" if d > half - 3.0 or y > 14 else "F")
                if 2 <= y <= 8 and d < 2.6:
                    col = "W"
                p.px(x, y, col)
    return p


def absolute_zero():
    """Absolute Zero (Frost evolved): a six-armed snowflake of ice (it spins as it flies)."""
    p = Pic(17, 17, (8, 8))
    for k in range(6):
        a = math.radians(k * 60 + 90)
        for s in range(1, 8):
            x = 8 + math.cos(a) * s; y = 8 + math.sin(a) * s
            p.px(round(x), round(y), "i" if s < 6 else "c")
            if s in (4, 6):
                for side in (-1, 1):
                    b = a + side * math.radians(55)
                    p.px(round(x + math.cos(b) * 1.6), round(y + math.sin(b) * 1.6), "I")
    for y in range(6, 11):
        for x in range(6, 11):
            if math.hypot(x - 8, y - 8) <= 1.8:
                p.px(x, y, "j" if (x + y) % 2 else "c")
    return p


def cyclone():
    """Cyclone (Breeze evolved): a great whirl of wind, five curling bands round a bright eye."""
    p = Pic(25, 25, (12, 12))
    for k in range(5):
        for a in range(0, 260, 5):
            r = 2.5 + k * 1.6 + a / 60
            ang = math.radians(a + k * 72)
            p.px(round(12 + math.cos(ang) * r), round(12 + math.sin(ang) * r), "w" if a < 190 else "v")
    p.rect(11, 11, 13, 13, "w")
    return p


def judgment():
    """Judgment (Glimmer evolved): a blazing star of holy light, eight rays round a white heart."""
    p = Pic(19, 19, (9, 9))
    for y in range(19):
        for x in range(19):
            d = math.hypot(x - 9, y - 9)
            if d <= 3.6:
                p.px(x, y, "h" if d < 2.0 else "H")
    for k in range(1, 10):
        for dx, dy in ((0, -1), (0, 1), (-1, 0), (1, 0)):
            p.px(9 + dx * k, 9 + dy * k, "h" if k < 5 else ("H" if k < 8 else "u"))
        if k < 7:
            for dx, dy in ((1, 1), (1, -1), (-1, 1), (-1, -1)):
                p.px(9 + dx * k, 9 + dy * k, "H" if k < 5 else "u")
    return p


EVOLVED = {"inferno": inferno, "absolute_zero": absolute_zero, "cyclone": cyclone, "judgment": judgment}

SPELLS = {"fortune": coin, "fire": fireball, "ice": ice_shard, "lightning": bolt, "wind": gust, "holy": light, "dark": shadow,
          "water": droplet, "earth": stone}

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "projectiles")
    for element, make in SPELLS.items():
        art = finish(make(), 0.0)
        doc = " ".join((make.__doc__ or "").split())
        data = {"_doc": "Spell picture for the %s element (docs/ART_RULES.md: Spells), built by tools/art/build_spells.py. %s"
                        % (element, doc), "size": art["size"], "palette": PALETTE, "frames": {"idle": [art["rows"]]}}
        with open(os.path.join(out_dir, "element_" + element + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    for weapon_id, make in EVOLVED.items():
        art = finish(make(), 0.0)
        doc = " ".join((make.__doc__ or "").split())
        data = {"_doc": "Evolved spell picture (docs/ART_RULES.md: Spells), built by tools/art/build_spells.py. %s" % doc,
                "size": art["size"], "palette": PALETTE, "frames": {"idle": [art["rows"]]}}
        with open(os.path.join(out_dir, weapon_id + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote", len(SPELLS), "spell pictures and", len(EVOLVED), "evolved ones")
