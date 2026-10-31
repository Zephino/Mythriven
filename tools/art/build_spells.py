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


SPELLS = {"fire": fireball, "ice": ice_shard, "lightning": bolt, "wind": gust, "holy": light, "dark": shadow,
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
    print("wrote", len(SPELLS), "spell pictures")
