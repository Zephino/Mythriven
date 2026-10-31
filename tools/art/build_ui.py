# Menu art (docs/ART_RULES.md: Menus): the frames every panel and button is drawn with, and the icons for passives
# and level-up cards. Run: python3 build_ui.py from tools/art/.
# Writes data/art/ui/frames.json (12 x 12 frames stretched by their 4 px edges: a nine-slice) and
# data/art/ui/icons.json (16 x 16 icons named by passive id).
import json, math, os
from build_weapons import Pic

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "ui")

FRAME_PALETTE = {
    "o": "#140c08", "s": "#2a2430", "S": "#221c28", "t": "#3a3242",           # dark stone
    "g": "#c89a3c", "G": "#8a6420", "y": "#f0cc58",                           # bronze trim
    "h": "#4a3e54", "H": "#5a4c66", "p": "#1a1420", "w": "#fff0b0", "d": "#55505a",
}


def frame(fill, edge, light, dark, inner):
    """A 12 x 12 frame: a dark outline, a two-tone bronze (or grey) border lit at the top left, and the fill."""
    p = Pic(12, 12, (0, 0))
    p.rect(0, 0, 11, 11, "o")
    p.rect(1, 1, 10, 10, edge)
    p.rect(1, 1, 10, 1, light); p.rect(1, 1, 1, 10, light)
    p.rect(1, 10, 10, 10, dark); p.rect(10, 1, 10, 10, dark)
    p.rect(2, 2, 9, 9, "o")
    p.rect(3, 3, 8, 8, fill)
    p.rect(3, 3, 8, 3, inner)
    for x, y in ((0, 0), (11, 0), (0, 11), (11, 11)):
        p.px(x, y, ".")
    return ["".join(r) for r in p.g]


FRAMES = {
    "panel": frame("s", "g", "y", "G", "t"),
    "button": frame("t", "G", "g", "o", "h"),
    "button_hover": frame("h", "g", "y", "G", "H"),
    "button_pressed": frame("p", "G", "o", "g", "S"),
    "button_focus": frame("h", "y", "w", "g", "H"),
    "button_disabled": frame("S", "d", "d", "o", "S"),
}

ICON_PALETTE = {
    "o": "#24160e", "k": "#140c08", "w": "#ffffff",
    "b": "#6a4422", "B": "#4a2e16", "g": "#c89a3c", "G": "#8a6420", "y": "#f0cc58",
    "e": "#e8e0d0", "E": "#b8b0a0", "u": "#5a9ad8", "U": "#2a5a9a", "s": "#c8ccd4", "S": "#8a8e96",
    "r": "#e8c040", "R": "#b08a20", "l": "#4a8a30", "c": "#6a6a78", "C": "#44444e", "m": "#a8d8ff", "f": "#e2a676",
    "F": "#b0724a", "q": "#d8e8f0",
}


def icon():
    return Pic(16, 16, (8, 8))


def belt():
    """Belt of Strength: a broad leather belt with a bronze buckle."""
    p = icon()
    p.rect(0, 6, 15, 10, "b"); p.rect(0, 10, 15, 10, "B"); p.rect(0, 6, 15, 6, "F")
    p.rect(5, 4, 10, 12, "g"); p.rect(7, 6, 8, 10, "B"); p.rect(5, 4, 10, 4, "y"); p.rect(5, 12, 10, 12, "G")
    return p


def sandals():
    """Winged Sandals (the winged sandals Hermes lends Perseus): a sandal with a white wing at the heel."""
    p = icon()
    p.rect(3, 11, 14, 12, "b"); p.rect(3, 13, 14, 13, "B")
    for x in (5, 8, 11):
        p.rect(x, 8, x, 10, "b")
    p.rect(5, 8, 11, 8, "b")
    for k in range(6):
        p.rect(1 + k // 2, 3 + k, 6 - k // 2, 3 + k, "e")
    p.rect(1, 3, 6, 3, "w"); p.px(2, 5, "E"); p.px(3, 7, "E")
    return p


def hourglass():
    """Hourglass: sand running through, in a wooden frame."""
    p = icon()
    p.rect(3, 1, 12, 2, "b"); p.rect(3, 13, 12, 14, "b")
    for y in range(3, 13):
        w = abs(y - 7.5)
        p.rect(round(8 - w * 0.75) - 1, y, round(7 + w * 0.75) + 1, y, "q")
    for y in range(9, 13):
        w = abs(y - 7.5) * 0.75
        p.rect(round(8 - w), y, round(7 + w), y, "r")
    p.rect(7, 4, 8, 5, "r"); p.px(8, 7, "r"); p.px(7, 8, "r")
    return p


def eye():
    """Seer's Eye: a wide eye with a bright blue iris."""
    p = icon()
    for x in range(1, 15):
        h = round(math.sin(math.pi * (x - 0.5) / 14.5) * 4.2)
        p.rect(x, 8 - h, x, 8 + h, "e")
    for y in range(5, 12):
        for x in range(5, 11):
            d = math.hypot(x - 7.5, y - 8)
            if d <= 3.0:
                p.px(x, y, "U" if d > 2.0 else "u")
    p.rect(7, 7, 8, 9, "k"); p.px(6, 6, "w")
    return p


def lodestone():
    """Lodestone: a dark magnetic stone drawing in specks of gold."""
    p = icon()
    for y in range(4, 13):
        for x in range(3, 13):
            if math.hypot(x - 7.5, (y - 8.5) * 1.2) <= 4.6:
                p.px(x, y, "c")
    p.rect(5, 6, 7, 6, "S"); p.px(10, 11, "C"); p.px(9, 11, "C")
    for x, y in ((1, 2), (14, 3), (1, 13), (14, 14), (8, 1)):
        p.px(x, y, "y")
    return p


def aegis():
    """Bronze Aegis: a round bronze shield with a boss."""
    p = icon()
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5)
            if d <= 7.0:
                p.px(x, y, "G" if d > 5.8 or 3.2 < d <= 3.9 else "g")
    p.rect(7, 7, 8, 8, "y"); p.px(5, 4, "y"); p.px(4, 5, "y")
    return p


def obol():
    """Ferryman's Coin (the obol paid to Charon): a silver coin with an owl's eyes struck on it."""
    p = icon()
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5)
            if d <= 6.5:
                p.px(x, y, "S" if d > 5.4 else "s")
    p.rect(5, 6, 6, 7, "S"); p.rect(9, 6, 10, 7, "S"); p.px(5, 6, "k"); p.px(10, 6, "k")
    p.rect(7, 9, 8, 10, "S"); p.px(5, 4, "w")
    return p


def apple():
    """Golden Apple: a golden apple with a leaf."""
    p = icon()
    for y in range(4, 16):
        for x in range(16):
            if math.hypot((x - 7.5) * 1.05, y - 9.5) <= 5.8 and not (y == 4 and x in (7, 8)):
                p.px(x, y, "R" if x > 9 or y > 13 else "r")
    p.px(5, 7, "w"); p.px(5, 8, "y"); p.rect(7, 1, 8, 4, "B"); p.rect(9, 1, 11, 2, "l")
    return p


def bell():
    """Votive Bell: a small bronze temple bell."""
    p = icon()
    for y in range(3, 13):
        w = 2 + (y - 3) * 0.45
        p.rect(round(7.5 - w), y, round(7.5 + w), y, "g")
    p.rect(1, 12, 14, 12, "G"); p.rect(7, 1, 8, 2, "G"); p.rect(7, 13, 8, 14, "G")
    p.rect(5, 4, 5, 10, "y")
    return p


def mirror_shield():
    """Mirrored Shield (Perseus' polished shield): a round shield polished bright, with a gleam."""
    p = icon()
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5)
            if d <= 7.0:
                p.px(x, y, "G" if d > 5.8 else "q")
    for k in range(5):
        p.px(4 + k, 9 - k, "w"); p.px(6 + k, 11 - k, "m")
    return p


def hand():
    """Tyr's Oath (Tyr's hand pledged in Fenrir's jaws): an open right hand, raised."""
    p = icon()
    p.rect(3, 8, 11, 13, "f"); p.rect(4, 14, 10, 15, "F")
    for x, top in ((3, 3), (6, 1), (9, 2)):
        p.rect(x, top, x + 1, 8, "f"); p.px(x + 1, top, "F")
    p.rect(12, 7, 13, 10, "f"); p.px(13, 11, "f")
    p.rect(3, 12, 11, 13, "F")
    return p


def crit():
    """Critical strike (the Crit Chance card): a blade's point striking a bright spark."""
    p = icon()
    for k in range(9):
        p.px(1 + k, 14 - k, "s"); p.px(2 + k, 14 - k, "S")
    p.rect(1, 13, 2, 14, "b")
    for x, y in ((12, 3), (11, 2), (13, 4), (12, 1), (12, 5), (10, 3), (14, 3), (11, 4), (13, 2)):
        p.px(x, y, "y")
    p.px(12, 3, "w")
    return p


ICONS = {"crit": crit, "belt_of_strength": belt, "winged_sandals": sandals, "hourglass": hourglass, "seers_eye": eye,
         "lodestone": lodestone, "bronze_aegis": aegis, "ferrymans_coin": obol, "golden_apple": apple,
         "votive_bell": bell, "mirrored_shield": mirror_shield, "tyrs_oath": hand}


def outlined(p):
    g = [r[:] for r in p.g]
    for y in range(16):
        for x in range(16):
            if p.g[y][x] == "." and any(0 <= x + dx < 16 and 0 <= y + dy < 16 and p.g[y + dy][x + dx] not in (".",)
                                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                g[y][x] = "o"
    return ["".join(r) for r in g]


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "frames.json"), "w") as f:
        json.dump({"_doc": "Menu frames (docs/ART_RULES.md: Menus), built by tools/art/build_ui.py: dark stone with a bronze "
                           "trim, stretched by their 4 px edges (nine-slice) for every panel and button.",
                   "size": [12, 12], "margin": 4, "palette": FRAME_PALETTE, "frames": {k: [v] for k, v in FRAMES.items()}},
                  f, indent=1)
    docs = " ".join("%s: %s" % (k, " ".join(v.__doc__.split())) for k, v in ICONS.items())
    with open(os.path.join(OUT, "icons.json"), "w") as f:
        json.dump({"_doc": "Passive icons (docs/ART_RULES.md: Menus), built by tools/art/build_ui.py. " + docs,
                   "size": [16, 16], "palette": ICON_PALETTE, "frames": {k: [outlined(v())] for k, v in ICONS.items()}},
                  f, indent=1)
    print("wrote", len(FRAMES), "frames and", len(ICONS), "icons")
