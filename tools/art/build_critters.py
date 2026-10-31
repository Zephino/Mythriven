# Critters (docs/WORLD_PLAN.md: 2; owner request 10/31/2026): the real animals of each land.
#   small ground animals, birds and insects: only for looks (data/art/critters/<level id>.json; frames named
#     "<animal>" (moving: 2 frames), birds also "<bird>_fly" (2 frames))
#   large animals: they can be hurt (data/art/enemies/<id>.json, a standing frame and 4 walking frames, like monsters)
# All drawn facing right, standing on their bottom edge. Run: python3 build_critters.py from tools/art/.
import json, os
from hero_kit import Canvas, ellipse, poly

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art")


def rows(c, outline=True):
    return c.outline() if outline else ["".join(r) for r in c.g]


# --- Small ground animals (2 frames: a hop or a step) --------------------------------------------------------------

def hare(fur, belly, k):
    c = Canvas(12, 9)
    up = 1 if k else 0
    ellipse(c, 5, 5 - up, 3.6, 2.3, fur); ellipse(c, 9, 3 - up, 1.8, 1.6, fur)
    c.rect(9, 0 - up, 9, 2 - up, fur); c.rect(8, 0 - up, 8, 1 - up, fur)          # long ears
    c.px(10, 3 - up, "k"); c.px(1, 4 - up, belly)                                  # eye, white tail
    if k:
        c.rect(2, 6, 3, 7, fur); c.rect(7, 7, 8, 8, fur)
    else:
        c.rect(3, 7, 4, 8, fur); c.rect(6, 7, 7, 8, fur)
    return rows(c)


def lizard(skin, dark, k):
    c = Canvas(14, 5)
    for x in range(1, 12):
        c.px(x, 2, skin)
    c.rect(3, 1, 8, 3, skin); c.rect(10, 1, 12, 2, skin); c.px(11, 1, "k")
    c.px(0, 3, dark)
    legs = (2, 8) if k else (4, 6)
    for x in legs:
        c.px(x, 4, dark)
    c.px(5, 2, dark); c.px(7, 1, dark)
    return rows(c)


def tortoise(shell, skin, k):
    c = Canvas(12, 7)
    ellipse(c, 5.5, 3, 4.5, 2.6, shell); c.px(4, 2, skin); c.px(6, 3, skin)
    c.rect(10, 3 + (1 if k else 0), 11, 4 + (1 if k else 0), skin); c.px(11, 3, "k")
    c.rect(2, 5, 3, 6, skin); c.rect(7, 5, 8, 6, skin)
    return rows(c)


def squirrel(fur, tail, k):
    c = Canvas(12, 10)
    up = 1 if k else 0
    ellipse(c, 6, 6 - up, 2.6, 2.2, fur); ellipse(c, 8.5, 4 - up, 1.6, 1.5, fur)
    c.px(9, 2 - up, fur); c.px(9, 4 - up, "k")
    for y in range(1, 8):                                                           # a bushy tail curled up
        c.rect(1, y - up, 3 if 2 < y < 6 else 2, y - up, tail)
    c.rect(5, 8, 5, 9, fur); c.rect(7, 8 - up, 7, 9 - up, fur)
    return rows(c)


def fox(fur, white, k):
    c = Canvas(16, 9)
    ellipse(c, 7, 4, 4.5, 2.2, fur); ellipse(c, 12.5, 3, 2, 1.7, fur)
    c.px(14, 3, fur); c.px(15, 4, "k"); c.px(12, 1, fur); c.px(13, 1, fur); c.px(12, 2, "k")
    c.px(13, 4, white)
    for x in range(0, 4):                                                           # brush with a white tip
        c.rect(x, 3 + (x == 0), x, 4, fur)
    c.px(0, 4, white)
    legs = ((4, 7), (9, 10)) if k else ((5, 6), (8, 9))
    for a, b in legs:
        c.rect(a, 6, a, 8, fur); c.rect(b, 6, b, 8, "k")
    return rows(c)


def jerboa(fur, k):
    c = Canvas(10, 9)
    up = 2 if k else 0
    ellipse(c, 5, 5 - up, 2, 1.8, fur); c.px(7, 4 - up, fur); c.px(7, 3 - up, "k")
    c.rect(6, 1 - up, 6, 3 - up, fur)
    for x in range(0, 4):
        c.px(x, 6 - up, fur)
    c.px(0, 5 - up, "k")
    c.rect(5, 7 - up, 5, 8 - up if not k else 6, fur)
    return rows(c)


def hedgehog(spines, face, k):
    c = Canvas(11, 7)
    ellipse(c, 5, 3.5, 4.2, 2.6, spines)
    for x in range(2, 9, 2):
        c.px(x, 1, face)
    c.rect(9, 3, 10, 4, face); c.px(10, 3, "k")
    c.px(3 if k else 4, 6, "k"); c.px(7 if k else 6, 6, "k")
    return rows(c)


def frog(skin, belly, k):
    c = Canvas(9, 6 if not k else 7)
    base = 2 if not k else 1
    ellipse(c, 4, base + 2, 3.4, 1.8, skin); c.px(5, base, skin); c.px(6, base, skin); c.px(6, base, "k")
    c.row(base + 3, 2, 5, belly)
    if k:
        c.rect(0, base + 4, 1, base + 5, skin)
    else:
        c.rect(1, base + 3, 2, base + 3, skin)
    return rows(c)


# --- Birds (sitting: a peck; flying: wings up and down) ------------------------------------------------------------

def bird_sit(body, wing, beak, k, big=False):
    c = Canvas(10 if big else 8, 7 if big else 6)
    w, h = c.w, c.h
    ellipse(c, w / 2 - 0.5, h / 2, w * 0.33, h * 0.32, body)
    c.rect(1, int(h / 2), int(w / 2), int(h / 2), wing)
    head = (w - 3, 1 + (1 if k else 0))
    c.rect(head[0], head[1], head[0] + 1, head[1] + 1, body); c.px(head[0] + 1, head[1], "k")
    c.px(head[0] + 2, head[1] + 1, beak)
    c.px(0, int(h / 2) - 1, wing)
    c.px(int(w / 2) - 1, h - 1, beak); c.px(int(w / 2) + 1, h - 1, beak)
    return rows(c)


def bird_fly(body, wing, beak, k, big=False):
    c = Canvas(12 if big else 10, 7)
    w = c.w
    ellipse(c, w / 2, 3.5, w * 0.25, 1.4, body)
    c.px(w - 2, 3, body); c.px(w - 1, 3, beak); c.px(w - 3, 2, "k")
    for d in range(1, w // 2 - 1):
        y = 3 - d // 2 if k else 4 + d // 2
        c.px(w // 2 - d // 2, max(0, min(6, y)), wing); c.px(w // 2 + d // 3, max(0, min(6, y)), wing)
    return rows(c)


# --- Insects -----------------------------------------------------------------------------------------------------

def butterfly(a, b, k):
    c = Canvas(7, 6)
    c.rect(3, 1, 3, 4, "k")
    if k:
        c.rect(0, 0, 2, 2, a); c.rect(4, 0, 6, 2, a); c.rect(1, 3, 2, 4, b); c.rect(4, 3, 5, 4, b)
    else:
        c.rect(1, 1, 2, 2, a); c.rect(4, 1, 5, 2, a); c.px(2, 3, b); c.px(4, 3, b)
    return rows(c, outline=False)


def dragonfly(body, wing, k):
    c = Canvas(9, 5)
    c.rect(0, 2, 7, 2, body); c.px(8, 2, "k")
    for x in (4, 6):
        c.px(x, 0 if k else 1, wing); c.px(x, 4 if k else 3, wing)
    return rows(c, outline=False)


def firefly(k):
    c = Canvas(3, 3)
    c.px(1, 1, "L")
    if k:
        c.px(0, 1, "l"); c.px(2, 1, "l"); c.px(1, 0, "l"); c.px(1, 2, "l")
    return rows(c, outline=False)


def cicada(body, k):
    c = Canvas(6, 4)
    c.rect(0, 1, 4, 2, body); c.px(5, 1, "k"); c.rect(1, 0 if k else 3, 3, 0 if k else 3, "W")
    return rows(c, outline=False)


# --- Large animals (enemy format: idle + 4 walking frames) ---------------------------------------------------------

def quadruped(coat, belly, dark, horns, w, h, step, tail_col=None):
    """A grazing animal in profile: body, neck and head forward, four legs moving in step, horns or antlers."""
    c = Canvas(w, h)
    body_y = h * 0.5
    ellipse(c, w * 0.42, body_y, w * 0.3, h * 0.17, coat)
    c.rect(int(w * 0.2), int(body_y + 1), int(w * 0.62), int(body_y + h * 0.12), belly)
    neck = [(w * 0.62, body_y - 1), (w * 0.72, h * 0.22), (w * 0.78, h * 0.22), (w * 0.72, body_y + 1)]
    poly(c, neck, coat)
    ellipse(c, w * 0.8, h * 0.24, w * 0.09, h * 0.08, coat); c.px(int(w * 0.89), int(h * 0.27), dark)
    c.px(int(w * 0.8), int(h * 0.21), "k")
    if horns == "curved":                                                           # a wild goat's or ibex's horns
        for k in range(5):
            c.px(int(w * 0.76) - k // 2, int(h * 0.15) - k, dark)
    elif horns == "antlers":
        for k in range(6):
            c.px(int(w * 0.78) - k // 3, int(h * 0.15) - k, dark)
        for x, y in ((-2, -3), (1, -4), (-3, -5), (2, -2)):
            c.px(int(w * 0.78) + x, int(h * 0.15) + y, dark)
    elif horns == "palmate":                                                        # an elk's broad antlers
        c.rect(int(w * 0.7), int(h * 0.04), int(w * 0.86), int(h * 0.08), dark)
        c.px(int(w * 0.7), int(h * 0.02), dark); c.px(int(w * 0.86), int(h * 0.02), dark)
    elif horns == "ringed":                                                         # a gazelle's ringed horns
        for k in range(5):
            c.px(int(w * 0.77) - k // 3, int(h * 0.16) - k, dark if k % 2 else belly)
    c.px(int(w * 0.75), int(h * 0.15), coat)                                        # ear
    c.px(int(w * 0.11), int(body_y - 1), tail_col or dark)
    legs = [w * 0.2, w * 0.3, w * 0.55, w * 0.64]
    swing = [(0, 1, 0, -1), (1, 0, -1, 0), (0, -1, 0, 1), (-1, 0, 1, 0)][step % 4]
    for x, s in zip(legs, swing):
        top = int(body_y + h * 0.12)
        for y in range(top, h - 1):
            c.px(int(x) + (s if y > top + 2 else 0), y, coat if y < h - 2 else dark)
        c.px(int(x) + s, h - 1, dark)
    return rows(c)


SMALL_PAL = {"o": "#24160e", "k": "#140c08", "W": "#d8e8e0", "L": "#f8ff90", "l": "#c8e060"}

LEVELS = {
    "aegean_shore": {
        "ground": {"hare": (hare, "#9a7650", "#e8e0d0"), "wall_lizard": (lizard, "#7a8a4a", "#4a5a2a"),
                   "tortoise": (tortoise, "#8a6a3a", "#b0905a")},
        "birds": {"sparrow": ("#8a6a4a", "#5a4430", "#c8a040", False), "gull": ("#e8ecec", "#9aa4ac", "#e0b030", True)},
        "insects": {"swallowtail": (butterfly, "#f0d860", "#3a3020"), "cicada": (cicada, "#6a6a3a")},
        "large": {"wild_goat": ("#8a6a4a", "#c8b090", "#3a2a1a", "curved", 26, 22),
                  "roe_deer": ("#a8724a", "#d8b890", "#4a3020", "antlers", 26, 24)}},
    "midgards_edge": {
        "ground": {"red_squirrel": (squirrel, "#b05a2a", "#c86a30"), "mountain_hare": (hare, "#e8e8ec", "#ffffff"),
                   "red_fox": (fox, "#c8642a", "#f0ece4")},
        "birds": {"raven": ("#24222a", "#3a3844", "#24222a", True), "ptarmigan": ("#f0f0f0", "#d0d4dc", "#3a3a3a", False)},
        "insects": {},
        "large": {"reindeer": ("#8a7a6a", "#e0dcd4", "#4a3e32", "antlers", 28, 26),
                  "elk": ("#5a4232", "#7a5e48", "#2a2018", "palmate", 32, 30)}},
    "jotunheim": {
        "ground": {"red_squirrel": (squirrel, "#b05a2a", "#c86a30"), "mountain_hare": (hare, "#e8e8ec", "#ffffff"),
                   "red_fox": (fox, "#c8642a", "#f0ece4")},
        "birds": {"raven": ("#24222a", "#3a3844", "#24222a", True), "ptarmigan": ("#f0f0f0", "#d0d4dc", "#3a3a3a", False)},
        "insects": {},
        "large": {"reindeer": ("#8a7a6a", "#e0dcd4", "#4a3e32", "antlers", 28, 26),
                  "elk": ("#5a4232", "#7a5e48", "#2a2018", "palmate", 32, 30)}},
    "the_two_lands": {
        "ground": {"jerboa": (lambda col, _b, k: jerboa(col, k), "#d4b080", None), "desert_lizard": (lizard, "#c8a870", "#8a6a40")},
        "birds": {"sacred_ibis": ("#f0f0ec", "#24222a", "#24222a", True), "sparrow": ("#a88a5a", "#6a5434", "#c8a040", False)},
        "insects": {"butterfly": (butterfly, "#f0a040", "#3a2a1a"), "dragonfly": (dragonfly, "#3a7ab0", "#c8e8f8")},
        "large": {"gazelle": ("#c89a5a", "#f0e4cc", "#4a3020", "ringed", 26, 24),
                  "nubian_ibex": ("#a8865a", "#d8c4a0", "#3a2a1a", "curved", 26, 24)}},
    "the_misty_isles": {
        "ground": {"hedgehog": (hedgehog, "#6a5a48", "#c8a888"), "hare": (hare, "#8a6a48", "#e8e0d0"),
                   "common_frog": (frog, "#6a8a3a", "#c8c08a")},
        "birds": {"wren": ("#7a5a3a", "#5a4028", "#3a2a1a", False), "robin": ("#7a6a4a", "#5a4a30", "#2a2018", False)},
        "insects": {"butterfly": (butterfly, "#e8f0f8", "#6a6a8a"), "firefly": (lambda *a: firefly(a[-1]),)},
        "large": {"red_deer": ("#8a4a2a", "#c89a70", "#3a2018", "antlers", 30, 28)}},
    "avalons_shadow": {
        "ground": {"hedgehog": (hedgehog, "#6a5a48", "#c8a888"), "hare": (hare, "#8a6a48", "#e8e0d0"),
                   "common_frog": (frog, "#6a8a3a", "#c8c08a")},
        "birds": {"wren": ("#7a5a3a", "#5a4028", "#3a2a1a", False), "robin": ("#7a6a4a", "#5a4a30", "#2a2018", False)},
        "insects": {"butterfly": (butterfly, "#e8f0f8", "#6a6a8a"), "firefly": (lambda *a: firefly(a[-1]),)},
        "large": {"red_deer": ("#8a4a2a", "#c89a70", "#3a2018", "antlers", 30, 28)}},
    "pohjola": {
        "ground": {"red_squirrel": (squirrel, "#b05a2a", "#c86a30"), "mountain_hare": (hare, "#e8e8ec", "#ffffff"),
                   "red_fox": (fox, "#c8642a", "#f0ece4")},
        "birds": {"raven": ("#24222a", "#3a3844", "#24222a", True), "ptarmigan": ("#f0f0f0", "#d0d4dc", "#3a3a3a", False)},
        "insects": {},
        "large": {"reindeer": ("#8a7a6a", "#e0dcd4", "#4a3e32", "antlers", 28, 26),
                  "elk": ("#5a4232", "#7a5e48", "#2a2018", "palmate", 32, 30)}},
    # The Land Between the Rivers: herons and ibises in the reed marshes; onagers (the wild asses of the Assyrian hunt
    # reliefs) and wild boar in the thickets.
    "the_land_between_the_rivers": {
        "ground": {"desert_lizard": (lizard, "#c8a870", "#8a6a40"), "frog": (frog, "#6a8a3a", "#c8c08a")},
        "birds": {"grey_heron": ("#a8acb4", "#6a6e78", "#d8b040", True), "sacred_ibis": ("#f0f0ec", "#24222a", "#24222a", True)},
        "insects": {"dragonfly": (dragonfly, "#3a7ab0", "#c8e8f8")},
        "large": {"onager": ("#b0906a", "#e8dcc4", "#4a3a2a", None, 28, 24),
                  "wild_boar": ("#4a3a30", "#6a5646", "#1e1610", None, 26, 18)}},
    # Pack 2 (docs/PACK_2_PLAN.md). Bats (the souls gibber like bats, Odyssey 24.6–9); the owl (Ascalaphus, turned into
    # one below the earth, Ovid, Metamorphoses 5.539–550); the black cattle of Hades (Apollodorus, Library 2.5.10).
    "the_underworld": {
        "ground": {"grey_lizard": (lizard, "#7a7680", "#4a4650")},
        "birds": {"bat": ("#3a3440", "#24202a", "#24202a", True), "owl": ("#8a7a68", "#5a4a3a", "#d8b040", False)},
        "insects": {"moth": (butterfly, "#c8c4b8", "#4a4650")},
        "large": {"black_cattle": ("#2a2628", "#4a4446", "#141012", "curved", 30, 24)}},
}


if __name__ == "__main__":
    os.makedirs(os.path.join(ROOT, "critters"), exist_ok=True)
    for level_id, spec in LEVELS.items():
        colours, frames, info = {}, {}, {}
        letters = iter("abcdefghijmnpqrstuvxyzABCDEFGHIJKMNOPQRSTUVXYZ0123456789")

        def letter(col):
            if col not in colours:
                colours[col] = next(letters)
            return colours[col]

        for name, (draw, a, b) in spec["ground"].items():
            frames[name] = [draw(letter(a), letter(b) if b else "k", k) for k in (0, 1)]
            info[name] = {"kind": "ground"}
        for name, (body, wing, beak, big) in spec["birds"].items():
            frames[name] = [bird_sit(letter(body), letter(wing), letter(beak), k, big) for k in (0, 1)]
            frames[name + "_fly"] = [bird_fly(letter(body), letter(wing), letter(beak), k, big) for k in (0, 1)]
            info[name] = {"kind": "bird"}
        for name, args in spec["insects"].items():
            draw = args[0]
            cols = [letter(x) for x in args[1:]]
            frames[name] = [draw(*cols, k) for k in (0, 1)]
            info[name] = {"kind": "firefly" if name == "firefly" else "insect"}
        pal = dict(SMALL_PAL); pal.update({v: k for k, v in colours.items()})
        with open(os.path.join(ROOT, "critters", level_id + ".json"), "w") as f:
            json.dump({"_doc": "Critters of %s (docs/WORLD_PLAN.md: 2), built by tools/art/build_critters.py: only for looks; "
                               "they can't be hurt. Two frames each (a step, a peck, a wing beat); birds also fly." % level_id,
                       "palette": pal, "frames": frames, "critters": info}, f, indent=1)
        for animal, (coat, belly, dark, horns, w, h) in spec["large"].items():
            lp = {"o": "#24160e", "k": "#140c08", "c": coat, "b": belly, "d": dark}
            walk = [quadruped("c", "b", "d", horns, w, h, s) for s in range(4)]
            with open(os.path.join(ROOT, "enemies", animal + ".json"), "w") as f:
                json.dump({"_doc": "A %s (docs/WORLD_PLAN.md: 2): a wild animal that runs from you and can be hurt; built "
                                   "by tools/art/build_critters.py." % animal.replace("_", " "),
                           "size": [w, h], "anchor": [w // 2, h - 1], "palette": lp,
                           "frames": {"idle": [walk[0]], "walk": walk}}, f, indent=1)
        print("wrote", level_id, len(frames), "critter frames and", len(spec["large"]), "large animals")
