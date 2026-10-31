# Builds the held-weapon pictures in data/art/weapons/ (docs/ART_RULES.md: Weapons).
# Each weapon is drawn from shapes around its grip at (0, 0) (y grows downward,
# facing right, as held hanging at the Hero's side), then outlined. The Hero's
# art marks where the hand is ("hand"); the game puts the weapon's grip there.
# Run: python3 tools/art/build_weapons.py
import json, os

PALETTE = {
    "o": "#24160e",
    "c": "#9a6232", "C": "#553012",   # wood, light / shadow
    "e": "#d8dce0", "E": "#8a9098",   # blade metal (bronze-polished / iron), light / shadow
    "g": "#c89a3c", "G": "#8a6420",   # bronze or gold fittings
    "b": "#5c3a1c",                   # leather grip, strings, cords
    "i": "#9aa0a8", "I": "#5c6068",   # iron head (hammer, axe)
    "u": "#d8b048",                   # bright gold (Excalibur)
    "w": "#efe6d2",                   # bowstring
}


def build(shapes, lean=0.0, raised=False):
    """shapes: list of (x0, y0, x1, y1, letter) rectangles relative to the grip.
    lean tilts the weapon so it isn't stiffly upright: each pixel moves sideways
    by lean pixels per pixel below the grip (positive: a hanging blade or club
    head swings forward; negative: an upright spear or bow tips forward).
    raised turns a weapon drawn hanging (blade or head down) the other way up,
    held ready: blade or head up."""
    pts = {}
    for x0, y0, x1, y1, c in shapes:
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                yy = -y if raised else y
                pts[(x + round(yy * lean), yy)] = c
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    left, top = min(xs) - 1, min(ys) - 1
    w, h = max(xs) - left + 2, max(ys) - top + 2
    g = [["." for _ in range(w)] for _ in range(h)]
    for (x, y), c in pts.items():
        g[y - top][x - left] = c
    filled = [r[:] for r in g]
    for y in range(h):
        for x in range(w):
            if filled[y][x] == "." and any(0 <= x + dx < w and 0 <= y + dy < h and filled[y + dy][x + dx] != "."
                                           for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                g[y][x] = "o"
    return {"size": [w, h], "grip": [-left, -top], "rows": ["".join(r) for r in g]}


R = lambda x0, y0, x1, y1, c: (x0, y0, x1, y1, c)
CLUB = [R(0, -2, 0, 3, "c"), R(0, 4, 1, 5, "c"), R(1, 4, 1, 5, "C"), R(0, 6, 2, 7, "c"), R(2, 6, 2, 7, "C"),
        R(0, 8, 3, 11, "c"), R(3, 8, 3, 11, "C"), R(1, 12, 2, 12, "c"), R(1, 7, 1, 7, "C"), R(2, 10, 2, 10, "C")]
XIPHOS = [R(0, -2, 0, -2, "g"), R(0, -1, 0, 0, "b"), R(-1, 1, 1, 1, "g"), R(0, 2, 1, 7, "e"), R(1, 2, 1, 7, "E"),
          R(0, 8, 0, 9, "e")]
EXCALIBUR = [R(0, -3, 0, -3, "u"), R(0, -2, 0, 0, "b"), R(-2, 1, 2, 1, "u"), R(0, 2, 1, 10, "e"), R(1, 2, 1, 10, "E"),
             R(0, 11, 0, 12, "e")]
HAMMER = [R(0, -2, 0, 8, "c"), R(-1, 9, 2, 12, "i"), R(2, 9, 2, 12, "I"), R(-1, 12, 2, 12, "I")]
AXE = [R(0, -1, 0, 7, "c"), R(1, 4, 3, 7, "i"), R(3, 4, 3, 7, "e"), R(1, 7, 3, 7, "I")]
JAVELIN = [R(0, -14, 0, 10, "c"), R(0, -17, 0, -15, "g")]
SPEAR = [R(0, -16, 0, 12, "c"), R(0, -12, 0, -12, "C"), R(-1, -19, 1, -17, "e"), R(1, -19, 1, -17, "E"), R(0, -21, 0, -20, "e"),
         R(0, 13, 0, 13, "g")]
GAE_BOLG = SPEAR + [R(-2, -17, -2, -17, "e"), R(2, -17, 2, -17, "E"), R(-1, -16, -1, -16, "E"), R(1, -16, 1, -16, "E")]
BOW = [R(2, -11, 2, -9, "c"), R(3, -8, 3, -3, "c"), R(3, -2, 3, 2, "b"), R(3, 3, 3, 8, "c"), R(2, 9, 2, 11, "c"),
       R(1, -10, 1, 10, "w")]
DISCUS = [R(1, -1, 4, 2, "g"), R(2, -2, 3, 3, "g"), R(4, -1, 4, 2, "e"), R(2, 3, 3, 3, "e"), R(3, 0, 3, 1, "G")]
SLING = [R(0, -1, 0, 5, "b"), R(1, 6, 1, 7, "b"), R(0, 8, 1, 8, "b"), R(-1, 7, -1, 7, "b"), R(0, 7, 0, 7, "I")]

# (shapes, lean, raised). Held ready, not dragged (owner request 10/31/2026):
# swords, clubs, hammers and axes are raised, blade or head up and tipped
# forward; spears, javelins and bows stand upright, tipped forward a little;
# the sling hangs from the hand.
WEAPONS = {
    "great_club": (CLUB, -0.45, True), "bronze_sword": (XIPHOS, -0.45, True), "sword_and_bow": (XIPHOS, -0.45, True),
    "excalibur": (EXCALIBUR, -0.45, True), "war_hammer": (HAMMER, -0.45, True), "throwing_axe": (AXE, -0.45, True),
    "javelin": (JAVELIN, -0.12, False), "spear_and_shield": (SPEAR, -0.12, False), "gae_bolg": (GAE_BOLG, -0.12, False),
    "scathach_spear": (SPEAR, -0.12, False), "longbow": (BOW, -0.1, False), "great_bow": (BOW, -0.1, False),
    "huntress_bow": (BOW, -0.1, False), "bladed_discus": (DISCUS, 0.0, False), "sling_of_lugh": (SLING, 0.2, False),
}

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data", "art", "weapons")
    for weapon_id, (shapes, lean, raised) in WEAPONS.items():
        art = build(shapes, lean, raised)
        data = {"_doc": "Held weapon (docs/ART_RULES.md: Weapons), built by tools/art/build_weapons.py. grip is the pixel held in the Hero's hand.",
                "size": art["size"], "grip": art["grip"], "palette": PALETTE, "frames": {"idle": [art["rows"]]}}
        with open(os.path.join(out_dir, weapon_id + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote", len(WEAPONS), "weapons")
