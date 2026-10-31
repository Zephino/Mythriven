# Summon pictures (docs/ART_RULES.md: Summons): what crosses the screen when a god is summoned. Each from its
# source, written in its `_doc`. Run: python3 build_summons.py from tools/art/. Writes data/art/summons/<name>.json
# with an "idle" frame and, for the ones that move, "walk" frames (galloping, wing beats).
import json, math, os
from build_weapons import Pic, finish

PALETTE = {
    "o": "#24160e", "k": "#140c08", "w": "#ffffff",
    "b": "#8a5a30", "B": "#5e3a1a", "c": "#e8d0a8", "a": "#d8c8a0", "A": "#a89870",      # stag
    "i": "#b8bcc8", "I": "#787c88", "h": "#6a4422", "H": "#4a2e16", "y": "#ffe878",      # hammer
    "d": "#2a2430", "D": "#141018", "e": "#5a5068",                                       # crow
    "g": "#f0c040", "G": "#b08020", "s": "#ffe070", "S": "#ff9030", "r": "#c83018", "t": "#3a6a9a",  # barque
}


def stag(stride):
    """Cernunnos' stag (the Gundestrup cauldron shows the antlered figure beside a stag): a red deer stag with
    branching antlers, galloping; `stride` picks the legs."""
    p = Pic(24, 22, (12, 21))
    for y in range(10, 16):                                  # body
        for x in range(5, 19):
            if math.hypot((x - 11.5) / 7.2, (y - 12.8) / 3.3) <= 1.0:
                p.px(x, y, "b" if y < 14 else "B")
    p.rect(4, 11, 5, 12, "c")                                # white rump
    p.rect(17, 7, 19, 12, "b")                               # neck
    p.rect(19, 5, 22, 8, "b"); p.px(23, 7, "B"); p.px(21, 6, "k")   # head, nose, eye
    p.px(19, 4, "b")                                         # ear
    for x, y in ((18, 4), (18, 3), (17, 2), (17, 1), (16, 0), (19, 2), (15, 2), (20, 1), (14, 1)):
        p.px(x, y, "a")                                      # antlers, branching
    p.px(16, 1, "A"); p.px(18, 2, "A")
    legs = [((6, 7), (9, 10), (14, 15), (17, 18)), ((5, 8), (8, 11), (13, 16), (16, 19))][stride]
    for x0, x1 in legs:
        p.px(x0, 16, "B"); p.px(x0, 17, "B")
        for y in range(18, 21):
            p.px(round(x0 + (x1 - x0) * (y - 17) / 4), y, "B")
    return p


def hammer():
    """Mjölnir, Thor's hammer (Skáldskaparmál 35: its handle came out rather short): a broad iron head, a short
    wrapped handle, and sparks of lightning about it."""
    p = Pic(13, 15, (6, 7))
    p.rect(1, 1, 11, 5, "i"); p.rect(1, 4, 11, 5, "I"); p.rect(0, 2, 0, 4, "I"); p.rect(12, 2, 12, 4, "I")
    p.rect(3, 2, 9, 2, "w")
    for x in (4, 6, 8):
        p.px(x, 3, "I")
    for y in range(6, 13):
        p.rect(5, y, 7, y, "h" if y % 2 else "H")
    p.rect(5, 13, 7, 13, "i")
    p.px(2, 0, "y"); p.px(11, 7, "y"); p.px(1, 8, "y")
    return p


def crow(up):
    """The Morrígan's crow (she takes the shape of a crow in the Táin Bó Cúailnge): black, wings up or down."""
    p = Pic(15, 10, (7, 5))
    p.rect(5, 4, 10, 6, "d"); p.rect(10, 3, 12, 5, "d"); p.px(13, 4, "e"); p.px(14, 4, "e"); p.px(11, 3, "w")
    p.rect(2, 5, 4, 5, "D"); p.px(1, 6, "D")                 # tail
    if up:
        for k in range(4):
            p.rect(6 + k, 3 - k, 8 + k // 2, 3 - k, "D")
    else:
        for k in range(4):
            p.rect(6 + k, 7 + k, 8 + k // 2, 7 + k, "D")
    return p


def barque():
    """Ra's sun barque (the Book of the Dead and Amduat show the sun god sailing the sky in a boat): a golden boat
    with upturned ends carrying the blazing sun disc."""
    p = Pic(34, 24, (17, 18))
    for x in range(2, 32):                                   # hull, ends curling up
        t = (x - 17) / 15
        top = 17 + round(-3 * t * t * 1.0) if abs(t) < 0.85 else 14 - round((abs(t) - 0.85) * 20)
        for y in range(max(top, 8), 22 - round(3 * t * t)):
            p.px(x, y, "g" if y < 19 else "G")
    p.rect(4, 17, 30, 17, "s")
    for y in range(4, 16):                                   # sun disc
        for x in range(10, 25):
            d = math.hypot(x - 17, y - 9.5)
            if d <= 6.2:
                p.px(x, y, "S" if d > 4.8 else ("s" if d > 2.5 else "w"))
    p.rect(11, 16, 23, 16, "r")                              # canopy line under the disc
    return p


def make(name, frames):
    arts = [finish(f, 0.0) for f in frames]
    w = max(a["size"][0] for a in arts); h = max(a["size"][1] for a in arts)
    rows = []
    for a in arts:
        pad = [r + "." * (w - len(r)) for r in a["rows"]]
        rows.append(["." * w] * (h - len(pad)) + pad)
    return w, h, rows


SUMMONS = {"stag": ([stag(0)], [stag(0), stag(1)], stag.__doc__),
           "hammer": ([hammer()], [], hammer.__doc__),
           "crow": ([crow(True)], [crow(True), crow(False)], crow.__doc__),
           "sun_barque": ([barque()], [], barque.__doc__)}

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "summons")
    os.makedirs(out_dir, exist_ok=True)
    for name, (idle, walk, doc) in SUMMONS.items():
        w, h, rows = make(name, idle + walk)
        frames = {"idle": [rows[0]]}
        if walk:
            frames["walk"] = rows[1:]
        data = {"_doc": "Summon picture (docs/ART_RULES.md: Summons), built by tools/art/build_summons.py. "
                        + " ".join(doc.split()), "size": [w, h], "anchor": [w // 2, h // 2], "palette": PALETTE,
                "frames": frames}
        with open(os.path.join(out_dir, name + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote", len(SUMMONS), "summon pictures")
