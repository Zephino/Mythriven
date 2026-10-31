# Achilles, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_achilles.py from tools/art/ (after
# build_achilles.py and build_weapons.py). Writes data/art/bosses/achilles.json.
# The boss is the Hero players already know (data/art/achilles.json) holding his spear, at twice the size, so he's
# recognised at once and stands out as a boss.
import json, os
import hero_kit as kit

SCALE = 2
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art")
DOC = ("Achilles, boss (GAME_DESIGN.md: The Aegean Shore bosses; art 10/31/2026). Built by "
       "tools/art/build_boss_achilles.py from his Hero art (data/art/achilles.json, sources there) holding his spear "
       "(data/art/weapons/spear_and_shield.json), drawn twice as big: the rival Hero you duel.")


def compose(hero, weapon):
    """The Hero's frames with the weapon behind them at the hand (as the game draws a Hero), on one canvas, with the
    weapon's colours given letters the Hero's palette doesn't use. Returns (frames, palette, anchor)."""
    palette = dict(hero["palette"])
    spare = iter(c for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" if c not in palette)
    remap = {}
    for letter, colour in weapon["palette"].items():
        same = next((k for k, v in palette.items() if v == colour), None)
        remap[letter] = same or next(spare)
        palette[remap[letter]] = colour
    wx = hero["hand"][0] - weapon["grip"][0]
    wy = hero["hand"][1] - weapon["grip"][1]
    ww, wh = weapon["size"]
    hw, hh = hero["size"]
    x0, y0 = min(0, wx), min(0, wy)
    x1, y1 = max(hw, wx + ww), max(hh, wy + wh)
    w_rows = weapon["frames"]["idle"][0]

    def one(rows):
        g = [["."] * (x1 - x0) for _ in range(y1 - y0)]
        for y, row in enumerate(w_rows):
            for x, ch in enumerate(row):
                if ch != ".":
                    g[wy + y - y0][wx + x - x0] = remap[ch]
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch != ".":
                    g[y - y0][x - x0] = ch
        return ["".join(r) for r in g]

    frames = {name: [one(rows) for rows in hero["frames"][name]] for name in hero["frames"]}
    return frames, palette, [hero["anchor"][0] - x0, hero["anchor"][1] - y0], [x1 - x0, y1 - y0]


def scale(rows, k):
    return ["".join(ch * k for ch in row) for row in rows for _ in range(k)]


if __name__ == "__main__":
    hero = json.load(open(os.path.join(ROOT, "achilles.json")))
    weapon = json.load(open(os.path.join(ROOT, "weapons", "spear_and_shield.json")))
    frames, palette, anchor, size = compose(hero, weapon)
    art = {"_doc": DOC, "size": [size[0] * SCALE, size[1] * SCALE],
           "anchor": [anchor[0] * SCALE + SCALE // 2, anchor[1] * SCALE + SCALE // 2], "palette": palette,
           "frames": {name: [scale(rows, SCALE) for rows in list_] for name, list_ in frames.items()}}
    os.makedirs(os.path.join(ROOT, "bosses"), exist_ok=True)
    with open(os.path.join(ROOT, "bosses", "achilles.json"), "w") as f:
        json.dump(art, f, indent=1)
    print("wrote data/art/bosses/achilles.json", art["size"])
