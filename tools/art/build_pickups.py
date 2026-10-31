# Pickup pictures (docs/ART_RULES.md: Pickups). Run: python3 build_pickups.py from tools/art/.
# XP gems, gold coins and ambrosia are drawn in light greys so the game tints them (config xp.orb_colors,
# pickups.gold_color, pickups.ambrosia_color); chests are in full colour. Written to data/art/pickups/<name>.json.
import json, math, os
from build_weapons import Pic, finish

# Light-grey shades for the tinted pickups, full colours for the chests and the golden apple.
PALETTE = {
    "o": "#24160e",
    "1": "#ffffff", "2": "#d8d8d8", "3": "#a8a8a8", "4": "#787878",
    "w": "#8a5a2c", "W": "#5e3a1a", "m": "#b0b4bc", "M": "#6c7078", "g": "#f0c040", "G": "#b08020", "k": "#140c08",
    "r": "#e8c040", "R": "#b08a20", "l": "#4a8a30",
}


def gem():
    """An XP gem: a cut crystal, lit from the top left (tinted by its tier)."""
    p = Pic(7, 9, (3, 4))
    for y in range(9):
        half = min(y, 8 - y) if y <= 3 else (8 - y) * 3 / 5
        half = min(half, 3)
        for x in range(7):
            d = x - 3
            if abs(d) <= half:
                p.px(x, y, ("1" if d <= 0 else "2") if y < 4 else ("3" if d <= 0 else "4"))
    p.px(2, 2, "1"); p.px(3, 1, "1")
    return p


def coin():
    """A gold coin with a struck face (tinted gold)."""
    p = Pic(7, 7, (3, 3))
    for y in range(7):
        for x in range(7):
            d = math.hypot(x - 3, y - 3)
            if d <= 3.2:
                p.px(x, y, "3" if d > 2.3 else "2")
    p.px(2, 2, "1"); p.px(3, 2, "1"); p.col(3, 3, 4, "4")
    return p


def ambrosia():
    """Ambrosia, the food of the gods (Odyssey 5.93): a little two-handled cup brimming over (tinted)."""
    p = Pic(9, 8, (4, 4))
    p.rect(1, 1, 7, 1, "1"); p.rect(0, 2, 8, 2, "2")
    p.rect(1, 3, 7, 3, "3"); p.rect(2, 4, 6, 4, "3"); p.rect(3, 5, 5, 5, "4")
    p.px(4, 6, "4"); p.rect(2, 7, 6, 7, "3")
    p.px(0, 1, "3"); p.px(8, 1, "3")
    p.px(3, 0, "1"); p.px(5, 0, "1")
    return p


def chest(big):
    """A wooden chest bound with iron (a big one, from bosses and points of interest, is bound with gold)."""
    w, h = (17, 13) if big else (13, 10)
    band, dark = ("g", "G") if big else ("m", "M")
    p = Pic(w, h, (w // 2, h - 1))
    lid = h // 3
    p.rect(1, 0, w - 2, 0, "w"); p.rect(0, 1, w - 1, lid, "w"); p.rect(0, lid + 1, w - 1, h - 1, "W")
    p.rect(0, lid + 1, w - 1, lid + 1, dark)
    for x in (2, w - 3):
        p.col(x, 0, h - 1, band)
    p.rect(0, h - 1, w - 1, h - 1, dark)
    c = w // 2
    p.rect(c - 1, lid, c + 1, lid + 2, band); p.px(c, lid + 2, "k")
    for x in range(3, w - 3, 2):
        p.px(x, 1, "W" if x % 4 == 1 else "w")
    return p


def golden_apple():
    """A golden apple (Atalanta's race: Pseudo-Apollodorus, Bibliotheca 3.9.2; Ovid, Metamorphoses 10)."""
    p = Pic(8, 9, (4, 5))
    for y in range(2, 9):
        for x in range(8):
            if math.hypot((x - 3.5) * 1.05, y - 5.2) <= 3.5 and not (y == 2 and x in (3, 4)):
                p.px(x, y, "R" if x > 4 or y > 7 else "r")
    p.px(2, 4, "1"); p.px(4, 0, "W"); p.px(4, 1, "W"); p.px(5, 1, "l"); p.px(6, 0, "l")
    return p


PICKUPS = {"xp_gem": gem, "gold_coin": coin, "ambrosia": ambrosia, "chest": lambda: chest(False),
           "chest_big": lambda: chest(True), "golden_apple": golden_apple}
DOCS = {"chest": chest.__doc__, "chest_big": chest.__doc__}

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "pickups")
    os.makedirs(out_dir, exist_ok=True)
    for name, make in PICKUPS.items():
        art = finish(make(), 0.0)
        doc = " ".join((DOCS.get(name) or make.__doc__ or "").split())
        data = {"_doc": "Pickup picture (docs/ART_RULES.md: Pickups), built by tools/art/build_pickups.py. %s" % doc,
                "size": art["size"], "palette": PALETTE, "frames": {"idle": [art["rows"]]}}
        with open(os.path.join(out_dir, name + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote", len(PICKUPS), "pickup pictures")
