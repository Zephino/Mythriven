# Mountain parts (docs/WORLD_PLAN.md: 5; owner request 10/31/2026), one set per level in its own rock, weathered like
# the rest of the world: the tops of raised ground (16 x 16 tiles), cliff faces below their edges (16 x 20), handholds
# cut into a cliff, a rolled rope ladder and a hung one, rope-bridge planks (whole and broken) and posts, and a cave
# mouth. Run: python3 build_mountain_parts.py from tools/art/. Writes data/art/mountain/<level id>.json.
import json, os, random
from hero_kit import Canvas, ellipse, poly
from weathering import weather

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "mountain")

ROCK = {   # top, top shade, face light, face, face dark, accent (snow, moss)
    "aegean_shore": ("#b8b09a", "#a29a84", "#c8c0aa", "#a49c88", "#7a7262", None),
    "midgards_edge": ("#dfe6ee", "#c4ccd8", "#9a9ca4", "#76787e", "#55565c", "#eef2f6"),
    "the_two_lands": ("#d8b47e", "#c49e68", "#d4b07a", "#b08c5c", "#86683e", None),
    "the_misty_isles": ("#6e8a52", "#5a7442", "#9a9a94", "#76766e", "#55554e", "#7a8a5a"),
    "jotunheim": ("#dfe6ee", "#c4ccd8", "#8a8c94", "#68696f", "#4a4b50", "#eef2f6"),
    "the_crossroads": ("#6a7a5a", "#56664a", "#8a868a", "#6a666a", "#4c4a4e", "#8a4ad0"),
    "the_realm_of_the_ten_suns": ("#a8784a", "#8a6038", "#9a7a5a", "#7a5a3a", "#5a4028", "#c8501a"),
    "cloud_cuckoo_land": ("#eef2f8", "#d8e0ec", "#c09a6a", "#a07a4a", "#7a5a34", "#f8fafe"),
    "ys": ("#7a8484", "#5a6464", "#6a7a7a", "#4a5a5a", "#344444", "#3a8a7a"),
    "erebus": ("#3a3842", "#2e2c36", "#4e4a56", "#3a3644", "#24222a", None),
    "karnstein": ("#4a4852", "#3e3c46", "#5e5a66", "#4a4652", "#2e2c34", None),
    "ossory": ("#5a5c56", "#4a4c46", "#6a6c64", "#54564e", "#3a3c36", None),
    "the_brocken": ("#6a6a72", "#5a5a62", "#7a7a82", "#64646c", "#46464e", "#e8eaee"),
    "nidavellir": ("#4a4246", "#3e383c", "#5e5458", "#4a4246", "#2e282a", None),
    "svartalfheim": ("#2e2e38", "#24242e", "#3e3e4a", "#30303c", "#1a1a22", None),
    "mycendra": ("#3a3240", "#2e2834", "#4a4050", "#3a3242", "#241e28", None),
    "the_myrmidon_hive": ("#c8a870", "#b0905a", "#d8b880", "#c0a068", "#8a6a40", None),
    "alfheim": ("#8a9a7a", "#7a8a6a", "#9aaa8a", "#8a9a7a", "#5a6a4a", "#f4f6ee"),
    "elfame": ("#7a9a6a", "#6a8a5a", "#8aaa7a", "#7a9a6a", "#4a6a3a", None),
    "arcadia": ("#9a947e", "#8a846e", "#aaa48e", "#949080", "#6a6450", "#f4f2ec"),
    "lerna": ("#6a7262", "#5a6252", "#7a8272", "#646c5c", "#424a3a", None),
    "ghorvast": ("#5a5048", "#4a423c", "#6a5e54", "#544a42", "#342e2a", None),
    "knossos": ("#b0a48c", "#a0947c", "#c0b49c", "#a89c84", "#7a6e58", None),
    "utgard": ("#7a7e88", "#6a6e78", "#8a8e98", "#747882", "#4e525a", "#f0f2f6"),
    "logres": ("#7a7e72", "#6a6e62", "#8a8e82", "#74786c", "#4e5248", None),
    "lemnos": ("#5a524c", "#4a4440", "#6a625a", "#544c46", "#342e2a", None),
    "the_goblin_market": ("#6a6a5a", "#5a5a4a", "#7a7a6a", "#646454", "#44443a", None),
    "libertalia": ("#c8b088", "#b09870", "#d8c098", "#c0a880", "#8a7050", None),
    "the_hollow_hills": ("#4a4440", "#3e3834", "#5a524c", "#46403c", "#2e2a26", None),
    "hyperborea": ("#dce4ee", "#c8d0dc", "#a8b0bc", "#8a929e", "#6a727e", "#f6f8fc"),
    "the_empyrean": ("#2a3052", "#1e2444", "#3a4070", "#2a3058", "#141a34", "#e8eeff"),
    "the_glass_mountain": ("#dce8f2", "#c8d8e8", "#a8bccc", "#8ca0b2", "#6a7e90", "#f6faff"),
    "demos_oneiron": ("#4a4060", "#3e3452", "#5a5070", "#463c5a", "#2a2438", None),
    "niflheim": ("#e4eaf2", "#c8d0dc", "#7a7e88", "#5e6068", "#42444a", "#f2f6fa"),
    "muspelheim": ("#3a3234", "#2a2426", "#4a3a36", "#3a2c28", "#241c1a", "#c8501a"),
    "the_land_of_legends": ("#567a3e", "#42642e", "#8a8680", "#6a6660", "#4c4a46", "#6a8a48"),
    "the_slavic_wilds": ("#5a8040", "#466a32", "#8a8a84", "#6a6a64", "#4c4c48", "#6a9048"),
    "mazandaran": ("#5e7a4a", "#4a6438", "#8a8680", "#6a6660", "#4c4a46", "#6a8a4a"),
    "pohjola": ("#e4eaf2", "#c8d0dc", "#7a7e88", "#5e6068", "#42444a", "#f2f6fa"),
    "the_land_between_the_rivers": ("#c8a878", "#b0905e", "#a88a5e", "#8a6c44", "#64503a", "#d8bc8a"),
    "avalons_shadow": ("#5e7a4a", "#4a6438", "#8a8a84", "#6a6a64", "#4c4c48", "#6a8a4a"),
    "the_underworld": ("#5a5862", "#4a4852", "#6e6a76", "#54505c", "#38343e", None),
}
EXTRA = {"o": "#140c08", "k": "#0c0806", "r": "#b89a6a", "R": "#8a6a3a", "w": "#7a5a34", "W": "#5a3e22", "i": "#6a6e76"}


def top(seed):
    rnd = random.Random(seed)
    c = Canvas(16, 16)
    c.rect(0, 0, 15, 15, "t")
    for _ in range(12):
        c.px(rnd.randrange(16), rnd.randrange(16), "T")
    for _ in range(3):
        x, y = rnd.randrange(14), rnd.randrange(14)
        c.px(x, y, "l"); c.px(x + 1, y, "l")
    return ["".join(r) for r in c.g]


def face(seed, accent):
    rnd = random.Random(seed)
    c = Canvas(16, 20)
    c.rect(0, 0, 15, 19, "f")
    c.rect(0, 0, 15, 1, "L")                                   # the lit lip
    for x in range(0, 16, rnd.choice((4, 5))):                 # vertical cracks and strata
        for y in range(2, 20):
            if rnd.random() < 0.7:
                c.px(x + (y // 6) % 2, y, "D")
    for y in (7, 13):
        for x in range(16):
            if rnd.random() < 0.6:
                c.px(x, y, "D")
    c.rect(0, 17, 15, 19, "D")                                 # shadow at the foot
    if accent:
        for x in range(16):
            if rnd.random() < 0.5:
                c.px(x, 0, "a"); c.px(x, 1 if rnd.random() < 0.3 else 0, "a")
    return ["".join(r) for r in c.g]


def handholds(c):
    """Cracks and holds cut into the rock: a way up for anyone."""
    for y in range(2, 19, 4):
        x = 5 + (y // 4) % 2 * 4
        c.rect(x, y, x + 2, y, "k"); c.px(x + 1, y - 1, "D")


def ladder_rolled(c):
    """A rope ladder rolled up at the top of the cliff: it needs a rope to hang."""
    ellipse(c, 8, 3, 5, 2.5, "r"); ellipse(c, 8, 3, 2.5, 1.2, "R")
    c.rect(3, 6, 13, 6, "R")
    for x in (4, 12):
        c.rect(x, 0, x, 1, "w")


def ladder_hung(c):
    """A rope ladder hanging down the cliff."""
    for x in (4, 11):
        c.rect(x, 0, x, 23, "r")
    for y in range(2, 24, 4):
        c.rect(4, y, 11, y, "w")
    c.rect(3, 0, 4, 1, "W"); c.rect(11, 0, 12, 1, "W")


def plank(c, broken=False):
    """A rope bridge's planks between two ropes (broken: a gap where planks fell)."""
    for x in range(16):
        if broken and 5 <= x <= 11:
            continue
        c.rect(x, 3, x, 12, "w" if x % 3 else "W")
    c.rect(0, 2, 15, 2, "r"); c.rect(0, 13, 15, 13, "r")
    if broken:
        c.px(5, 13, "."); c.px(6, 13, "."); c.px(10, 2, "."); c.rect(6, 14, 7, 15, "r")


def post(c):
    c.rect(2, 2, 5, 15, "w"); c.rect(2, 2, 2, 15, "W"); c.rect(1, 0, 6, 2, "W")
    c.rect(5, 6, 7, 7, "r")


def cave_mouth(c):
    """A cave mouth in the rock: a dark arch with a little light at its lip."""
    W, H = c.w, c.h
    ellipse(c, W / 2, H * 0.6, W / 2 - 1, H * 0.55, "f")
    ellipse(c, W / 2, H * 0.72, W / 2 - 6, H * 0.5, "k")
    c.rect(0, H - 2, W - 1, H - 1, "D")
    for x in range(6, W - 6, 3):
        c.px(x, int(H * 0.25), "D")
    c.rect(int(W / 2) - 4, H - 4, int(W / 2) + 3, H - 3, "D")


def part(w, h, draw, outline=True):
    c = Canvas(w, h)
    draw(c)
    return c.outline() if outline else ["".join(r) for r in c.g]


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for level_id, (t, T, L, f, D, accent) in ROCK.items():
        pal = dict(EXTRA, t=t, T=T, L=L, f=f, D=D, l=T, a=accent or L)
        frames = {
            "top": [top(level_id + str(k)) for k in range(3)],
            "face": [face(level_id + str(k), accent) for k in range(3)],
            "handholds": [part(16, 20, handholds, outline=False)],
            "ladder_rolled": [part(16, 8, ladder_rolled)],
            "ladder": [part(16, 24, ladder_hung)],
            "plank": [part(16, 16, plank, outline=False)],
            "plank_broken": [part(16, 16, lambda c: plank(c, True), outline=False)],
            "post": [part(8, 16, post)],
            "cave": [part(36, 30, cave_mouth)],
        }
        pal, frames = weather(pal, frames, "mountain/" + level_id, keep={"k", "r", "R", "w", "W", "a"})
        with open(os.path.join(OUT, level_id + ".json"), "w") as fh:
            json.dump({"_doc": "Mountain parts for %s (docs/WORLD_PLAN.md: 5), built by tools/art/build_mountain_parts.py "
                                "and weathered: raised ground tops, cliff faces, handholds, rope ladders (rolled and hung), "
                                "rope-bridge planks (whole and broken) and posts, a cave mouth." % level_id,
                       "palette": pal, "frames": frames}, fh, indent=1)
        print("wrote", level_id)
