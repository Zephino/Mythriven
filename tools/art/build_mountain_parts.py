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
