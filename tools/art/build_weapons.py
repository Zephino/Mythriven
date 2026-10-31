# Builds the held-weapon pictures in data/art/weapons/ (docs/ART_RULES.md: Weapons).
# Each weapon is drawn pixel by pixel on its own canvas, upright (blade, head or tip up; a sling hangs), with its grip
# marked, then tipped forward by its lean and outlined. The Hero's art marks the hand ("hand"); the game puts the
# weapon's grip there. Redrawn 10/31/2026 (owner request: more style, so no two weapons look alike).
# Run: python3 build_weapons.py from tools/art/.
import json, math, os

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "c": "#9a6232", "C": "#5e3818", "a": "#c8a070",   # wood: mid, shadow, pale ash
    "e": "#e4e8ec", "E": "#9aa2ac", "s": "#ffffff",   # steel: light, shadow, glint
    "g": "#d0a048", "G": "#8a6420",                   # bronze
    "u": "#f0cc58", "U": "#b08a28",                   # gold
    "b": "#6a4422", "B": "#3e2612",                   # leather
    "i": "#8a9098", "I": "#4e545c",                   # dark iron
    "w": "#efe6d2",                                   # bowstring, bone
    "h": "#3a3440", "H": "#5a4e6a",                   # shadow-dark wood (Scáthach)
    "r": "#7a2a1c", "R": "#4e1a10",                   # dark red (Gáe Bolg's shaft)
    "j": "#3a7ac0", "J": "#c83030",                   # gems
    "l": "#a8e0f0",                                   # Excalibur's bright edge
    "x": "#c8b8a0",                                   # horn
}


class Pic:
    def __init__(self, w, h, grip):
        self.w, self.h, self.grip = w, h, grip
        self.g = [["." for _ in range(w)] for _ in range(h)]

    def px(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.g[y][x] = c

    def rect(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.px(x, y, c)

    def col(self, x, y0, y1, c):
        self.rect(x, y0, x, y1, c)


def finish(p, lean):
    """Tips the picture forward by `lean` pixels sideways per pixel above the grip, then outlines it."""
    gx, gy = p.grip
    pts = {}
    for y in range(p.h):
        for x in range(p.w):
            if p.g[y][x] != ".":
                pts[(x + round((gy - y) * lean), y)] = p.g[y][x]
    xs = [q[0] for q in pts]; ys = [q[1] for q in pts]
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
    return {"size": [w, h], "grip": [gx - left, gy - top], "rows": ["".join(r) for r in g]}


# --- Swords --------------------------------------------------------------------------------------------------------

def bronze_sword():
    """A Greek xiphos: a leaf-shaped bronze blade, widest near the tip, a short grip with a disc pommel."""
    p = Pic(9, 20, (4, 16))
    widths = [0, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1]
    for i, w in enumerate(widths):
        y = 1 + i
        p.rect(4 - w, y, 4 + w, y, "g"); p.px(4 + w, y, "G")
    p.col(4, 2, 11, "u")                                         # the bright midrib
    p.px(4, 0, "g")
    p.rect(2, 13, 6, 13, "G"); p.rect(3, 14, 5, 14, "G")         # guard
    p.col(4, 15, 17, "b"); p.px(4, 16, "B")
    p.rect(3, 18, 5, 18, "g"); p.px(5, 18, "G")                  # disc pommel
    return p


def excalibur():
    """Excalibur: a long straight blade with a dark fuller and a bright shining edge, an ornate gold cross-guard
    curling at both ends, a gold-wrapped grip, a jewelled pommel, and a glint near the tip."""
    p = Pic(13, 28, (6, 23))
    p.px(6, 0, "e"); p.rect(5, 1, 7, 1, "e")
    p.rect(5, 2, 7, 19, "e"); p.col(7, 2, 19, "l"); p.col(6, 3, 17, "E")    # blade, bright edge, fuller
    p.px(5, 4, "s"); p.px(4, 4, "s"); p.px(5, 3, "s"); p.px(5, 5, "s")       # the glint
    p.rect(2, 20, 10, 20, "u"); p.rect(3, 21, 9, 21, "U")                   # cross-guard
    p.px(1, 19, "u"); p.px(11, 19, "u"); p.px(1, 18, "U"); p.px(11, 18, "U")   # curled ends
    p.px(6, 20, "j")                                                        # a jewel at its heart
    for y in range(22, 26):
        p.col(6, y, y, "u" if y % 2 else "U")                               # gold-wrapped grip
    p.rect(5, 26, 7, 27, "u"); p.px(6, 26, "J")                             # jewelled pommel
    return p


def tachi():
    """Tomoe Gozen's tachi: a long, gently curved single-edged blade with its bright tempered edge, a round tsuba,
    a grip wrapped in a diamond pattern."""
    p = Pic(12, 26, (3, 21))
    for y in range(1, 18):
        off = round((17 - y) ** 2 / 55)
        x = 3 + off
        p.px(x, y, "e"); p.px(x + 1, y, "l"); p.px(x - 1, y, "E") if y > 2 else None
    p.px(7, 0, "e")
    p.rect(1, 18, 5, 18, "u"); p.rect(2, 19, 4, 19, "U")          # tsuba
    for y in range(20, 25):
        p.px(3, y, "k" if y % 2 else "w")                          # wrapped grip
    p.px(3, 25, "u")
    return p


# --- Clubs, hammers, axes ------------------------------------------------------------------------------------------

def great_club():
    """Heracles' club of wild olive: a thin leather-wrapped grip swelling to a great rounded, knotted head, with the
    stubs of cut branches."""
    p = Pic(13, 25, (6, 21))
    for y in range(0, 24):
        t = (23 - y) / 23
        r = 0.9 + t * t * 3.4
        if y < 4:
            r = min(r, [2.0, 3.2, 3.8, 4.2][y])                    # a rounded top
        for x in range(13):
            if abs(x - 6) <= r:
                p.px(x, y, "c")
        p.px(round(6 + r), y, "C")
    for x, y in [(4, 4), (8, 7), (5, 10), (7, 2), (6, 13)]:
        p.px(x, y, "C"); p.px(x + 1, y, "a")                       # knots
    for x, y, d in [(2, 6, -1), (10, 5, 1), (3, 2, -1)]:
        p.px(x, y, "c"); p.px(x + d, y, "C")                       # stubs of cut branches
    p.rect(6, 19, 7, 23, "b"); p.px(6, 21, "B")                    # leather grip
    return p


def war_hammer():
    """A war hammer: a long banded haft, a heavy square iron head with a beak-spike behind."""
    p = Pic(14, 26, (6, 22))
    p.col(6, 6, 25, "c"); p.col(7, 6, 25, "C")
    for y in (10, 14, 18):
        p.rect(6, y, 7, y, "i")                                    # iron bands
    p.rect(7, 0, 12, 6, "i"); p.col(12, 0, 6, "I"); p.row = None
    p.rect(7, 6, 12, 6, "I"); p.rect(8, 1, 11, 1, "e")
    p.rect(2, 2, 6, 4, "i"); p.px(1, 3, "i"); p.px(0, 3, "I"); p.rect(2, 4, 6, 4, "I")   # the spike
    p.rect(6, 0, 7, 6, "i")
    p.rect(6, 21, 7, 24, "b")
    return p


def throwing_axe():
    """A bearded throwing axe: a short haft, an iron head whose blade sweeps down into a long 'beard'."""
    p = Pic(12, 20, (4, 15))
    p.col(4, 2, 19, "c"); p.col(5, 2, 19, "C")
    p.rect(6, 1, 7, 5, "i")                                        # the eye of the head
    for i, (y0, y1) in enumerate([(0, 6), (0, 8), (1, 10), (2, 11)]):
        p.col(8 + i, y0, y1, "i")
    p.col(11, 2, 11, "e"); p.col(10, 0, 10, "e") if False else None
    p.col(11, 2, 11, "e"); p.px(10, 1, "e")                        # bright cutting edge
    p.rect(8, 6, 9, 8, "I")
    p.rect(3, 1, 4, 3, "I")                                        # the poll behind
    p.rect(4, 14, 5, 17, "b")
    return p


# --- Spears --------------------------------------------------------------------------------------------------------

def javelin():
    """A light javelin: a thin shaft with a leather throwing-loop, a small narrow iron point, no butt-spike."""
    p = Pic(7, 32, (3, 20))
    p.col(3, 6, 31, "a")
    p.rect(3, 1, 3, 5, "i"); p.px(3, 0, "e"); p.px(2, 3, "i"); p.px(4, 3, "I"); p.col(3, 1, 3, "e")
    p.rect(2, 16, 4, 17, "b"); p.px(2, 18, "b"); p.px(4, 18, "B")  # the thong (ankyle)
    return p


def spear_and_shield():
    """Achilles' great spear of Pelian ash (Iliad 16): a long, heavy pale-ash shaft, a broad bronze leaf-shaped head,
    a bronze butt-spike."""
    p = Pic(9, 40, (4, 22))
    p.col(4, 9, 37, "a"); p.col(5, 9, 37, "c")
    for i, w in enumerate([0, 1, 1, 2, 2, 2, 2, 1, 1]):
        p.rect(4 - w, i, 4 + w, i, "g"); p.px(4 + w, i, "G")
    p.col(4, 1, 7, "u")
    p.rect(3, 8, 5, 8, "G")                                        # socket
    p.rect(4, 38, 5, 39, "g"); p.px(4, 39, "G")                    # butt-spike
    return p


def gae_bolg():
    """The Gáe Bolg: a dark red shaft, and a head with rows of barbs pointing back (thirty barbs in the tales) so it
    can't be pulled out."""
    p = Pic(11, 38, (5, 22))
    p.col(5, 13, 37, "r"); p.col(6, 13, 37, "R")
    p.col(5, 0, 12, "w"); p.col(6, 2, 12, "x")
    for y in range(3, 13, 3):                                      # barbs, pointing back down the shaft
        p.px(4, y, "w"); p.px(3, y + 1, "w"); p.px(2, y + 2, "x")
        p.px(7, y, "x"); p.px(8, y + 1, "x"); p.px(9, y + 2, "w")
    p.px(5, 0, "s")
    p.rect(4, 13, 7, 13, "i")
    return p


def scathach_spear():
    """Scáthach's spear: an Irish socketed spear with a long, slender iron head and a raised midrib, bronze rings on
    the socket, and a shaft dark as her Fortress of Shadows."""
    p = Pic(9, 40, (4, 22))
    p.col(4, 12, 38, "h"); p.col(5, 12, 38, "H")
    for i in range(11):
        w = 1 if 1 <= i <= 9 else 0
        p.rect(4 - w, i, 4 + w, i, "e"); p.px(4 + w, i, "E")
    p.col(4, 1, 9, "E"); p.px(4, 0, "s")                           # the midrib
    p.rect(3, 11, 5, 11, "g"); p.rect(3, 13, 5, 13, "g")           # bronze socket rings
    return p


# --- Bows ----------------------------------------------------------------------------------------------------------

def bow(height, curve, wood, shade, tips=None, recurve=False, bands=None):
    p = Pic(10, height + 2, (3, height // 2 + 1))
    mid = height / 2
    for y in range(1, height + 1):
        t = (y - 1 - mid) / mid
        off = curve * (1 - t * t)
        if recurve:
            off -= 1.6 * max(0.0, abs(t) - 0.75) * 4                # the tips curl forward again
        x = round(3 + off)
        p.px(x, y, wood); p.px(x + 1, y, shade)
    for y in range(1, height + 1):
        p.px(2, y, "w")                                            # the string
    gy = height // 2 + 1
    p.rect(round(3 + curve), gy - 1, round(3 + curve) + 1, gy + 1, "b")   # leather grip
    if tips:
        for y in (1, 2, height - 1, height):
            t = (y - 1 - mid) / mid
            p.px(round(3 + curve * (1 - t * t)), y, tips)
    if bands:
        for y in bands:
            t = (y - 1 - mid) / mid
            x = round(3 + curve * (1 - t * t))
            p.px(x, y, "u"); p.px(x + 1, y, "U")
    return p


def longbow():
    """A tall plain longbow of yew: pale sapwood and dark heartwood, a simple deep curve."""
    return bow(32, 4, "a", "C")


def huntress_bow():
    """Atalanta's hunting bow: a short, double-curved (recurved) bow as Greek vases show archers, with horn tips."""
    return bow(22, 3, "c", "C", tips="x", recurve=True)


def great_bow():
    """Odysseus' great bow (Odyssey 21): a big composite bow of horn that no suitor could string, its horn tips
    pale and polished, bound with gold."""
    return bow(30, 4, "x", "c", tips="w", recurve=True, bands=(9, 23))


# --- Others --------------------------------------------------------------------------------------------------------

def bladed_discus():
    """A bladed discus: a bronze disc with a toothed steel rim and a hole at its centre."""
    p = Pic(13, 13, (2, 6))
    for y in range(13):
        for x in range(13):
            d = math.hypot(x - 6, y - 6)
            if d <= 5.6:
                p.px(x, y, "e" if d > 4.4 else ("g" if d > 1.6 else "."))
            if 4.4 < d <= 4.9:
                p.px(x, y, "E")
    for k in range(8):                                             # teeth round the rim
        a = math.tau * k / 8
        p.px(round(6 + math.cos(a) * 6.4), round(6 + math.sin(a) * 6.4), "e")
    p.px(4, 4, "u"); p.px(8, 8, "G")
    return p


def sling_of_lugh():
    """Lugh's sling: two leather cords hanging from his hand, a pouch at the bottom holding the sling-stone."""
    p = Pic(9, 18, (4, 1))
    p.col(4, 0, 12, "b"); p.col(5, 1, 12, "B")
    p.rect(2, 13, 7, 15, "b"); p.rect(3, 16, 6, 16, "B")           # the pouch
    p.rect(4, 13, 5, 14, "i"); p.px(4, 13, "e")                    # the stone
    return p


def runo_song():
    """Väinämöinen's kantele (Kalevala runos 40 and 44): a wing-shaped wooden box zither, five strings over its face
    with wood showing between them, tuning pegs at the wide end, held by its narrow end."""
    p = Pic(12, 18, (2, 1))
    for y in range(0, 16):
        w = min(1 + y // 2, 8)
        p.rect(1, y, 1 + w, y, "c"); p.px(1 + w, y, "C")
    p.rect(1, 15, 9, 16, "C")
    for k, x in enumerate((2, 4, 6, 8)):
        p.col(x, 3 + k * 2, 14, "w")
    for x in (2, 4, 6, 8):
        p.px(x, 15, "u")                                           # tuning pegs
    p.px(2, 1, "C")
    return p


def orpheus_lyre():
    """Orpheus' lyre, the chelys of the Homeric Hymn to Hermes: a tortoise-shell sound box, two curved horn arms rising
    from it to a wooden crossbar, and seven strings (Apollo's gift to Orpheus), held by its sound box."""
    p = Pic(14, 18, (7, 16))
    for y in range(11, 18):                                         # the tortoise-shell sound box
        half = 5 - abs(y - 14) // 1 if y >= 13 else 3 + (y - 11)
        half = max(2, min(half, 5))
        p.rect(7 - half, y, 7 + half, y, "b")
    p.rect(4, 13, 10, 15, "B"); p.px(5, 14, "b"); p.px(9, 14, "b"); p.px(7, 15, "b")   # the shell's plates
    for side in (-1, 1):                                            # two curved horn arms
        for y in range(1, 12):
            x = 7 + side * (2 + (4 - abs(y - 5)) // 2 + (1 if y < 3 else 0))
            p.px(x, y, "x"); p.px(x + side, y, "a") if y in (1, 2) else None
    p.rect(2, 2, 12, 2, "c"); p.rect(2, 3, 12, 3, "C")              # the crossbar
    for x in (4, 5, 6, 7, 8, 9, 10):                                # seven strings
        p.col(x, 4, 12, "w")
    return p


def giant_sword():
    """The giant-made sword from the hall of Grendel's mother (Beowulf 1557-1569): an old sword of giants, too heavy
    for any other man, a broad pale blade with a fuller, a golden hilt."""
    p = Pic(8, 30, (3, 26))
    p.rect(2, 2, 5, 22, "e"); p.rect(2, 2, 2, 22, "E"); p.col(4, 4, 20, "E")       # broad blade, fuller
    p.rect(3, 0, 4, 1, "e")
    p.rect(0, 23, 7, 24, "u"); p.px(0, 24, "U"); p.px(7, 24, "U")                  # golden crossguard
    p.rect(3, 25, 4, 28, "b"); p.rect(2, 29, 5, 29, "u")
    return p


def gilgamesh_axe():
    """Gilgamesh's great axe (Epic of Gilgamesh, Tablets II-III: the axes cast for him and Enkidu, three talents each):
    a long wooden haft bound with leather, a crescent-bladed bronze head with a socket, as on the old Mesopotamian
    bronze axes."""
    p = Pic(14, 30, (5, 25))
    p.col(5, 4, 29, "c"); p.col(6, 4, 29, "C")
    p.rect(5, 22, 6, 27, "b")                                      # leather binding at the grip
    p.rect(4, 3, 7, 8, "g"); p.rect(4, 3, 4, 8, "G")               # the socket
    for i, (y0, y1) in enumerate([(2, 9), (1, 10), (0, 11), (0, 11), (1, 10)]):
        p.col(8 + i, y0, y1, "g")
    p.col(13, 1, 10, "u"); p.px(12, 0, "u"); p.px(12, 11, "u")     # the bright crescent edge
    p.rect(8, 5, 9, 6, "G")
    return p


def rostam_mace():
    """Rostam's ox-headed mace (the gorz-e gavsar of the Shahnameh, the mace made in the shape of an ox's head): a
    heavy iron head shaped like an ox's head with horns, on a stout shaft."""
    p = Pic(12, 28, (5, 24))
    p.col(5, 9, 27, "c"); p.col(6, 9, 27, "C")
    p.rect(5, 21, 6, 26, "b")
    p.rect(2, 2, 9, 9, "i"); p.rect(2, 2, 3, 9, "I")               # the ox's head
    p.px(4, 4, "k"); p.px(7, 4, "k"); p.rect(4, 7, 7, 8, "I")       # eyes, muzzle
    p.px(1, 1, "x"); p.px(0, 0, "x"); p.px(10, 1, "x"); p.px(11, 0, "x")   # horns
    p.rect(4, 10, 7, 10, "g")
    return p


def arrow():
    """An arrow, for every bow: a steel point, a wooden shaft, feathered fletching."""
    p = Pic(5, 18, (2, 9))
    p.px(2, 0, "e"); p.rect(1, 1, 3, 1, "E"); p.px(2, 1, "e")
    p.col(2, 2, 14, "a")
    p.rect(1, 13, 1, 16, "J"); p.rect(3, 13, 3, 16, "J"); p.px(2, 15, "w"); p.px(2, 16, "w")
    return p


def sling_stone():
    """Lugh's sling-stone (the tathlum of Cath Maige Tuired): a round stone."""
    p = Pic(6, 6, (2, 2))
    for y in range(6):
        for x in range(6):
            d = math.hypot(x - 2.5, y - 2.5)
            if d <= 2.4:
                p.px(x, y, "i" if d > 1.2 else "e")
    p.px(3, 3, "I"); p.px(4, 3, "I")
    return p


# What each thrown weapon or shot flies as (data/art/projectiles/; weapons.json projectile_art), drawn upright and
# not tipped, so the game can turn it to face its flight.
PROJECTILES = {
    "javelin": javelin, "throwing_axe": throwing_axe, "bladed_discus": bladed_discus, "arrow": arrow,
    "sling_stone": sling_stone,
}

# (picture, lean). Held ready, not dragged (owner request 10/31/2026): swords, clubs, hammers and axes raised and
# tipped forward; spears, javelins and bows upright, tipped a little; the sling hangs.
WEAPONS = {
    "great_club": (great_club, 0.45), "bronze_sword": (bronze_sword, 0.45), "sword_and_bow": (tachi, 0.35),
    "excalibur": (excalibur, 0.45), "war_hammer": (war_hammer, 0.4), "throwing_axe": (throwing_axe, 0.4),
    "javelin": (javelin, 0.12), "spear_and_shield": (spear_and_shield, 0.12), "gae_bolg": (gae_bolg, 0.12),
    "scathach_spear": (scathach_spear, 0.12), "longbow": (longbow, 0.1), "great_bow": (great_bow, 0.1),
    "huntress_bow": (huntress_bow, 0.1), "bladed_discus": (bladed_discus, 0.0), "sling_of_lugh": (sling_of_lugh, -0.2),
    "runo_song": (runo_song, 0.0), "orpheus_lyre": (orpheus_lyre, 0.0), "giant_sword": (giant_sword, 0.1),
    "gilgamesh_axe": (gilgamesh_axe, 0.4), "rostam_mace": (rostam_mace, 0.4),
}

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "weapons")
    for weapon_id, (make, lean) in WEAPONS.items():
        pic = make()
        art = finish(pic, lean)
        doc = (make.__doc__ or "").strip().replace("\n", " ")
        data = {"_doc": "Held weapon (docs/ART_RULES.md: Weapons), built by tools/art/build_weapons.py. grip is the "
                        "pixel held in the Hero's hand. " + " ".join(doc.split()),
                "size": art["size"], "grip": art["grip"], "palette": PALETTE, "frames": {"idle": [art["rows"]]}}
        with open(os.path.join(out_dir, weapon_id + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote", len(WEAPONS), "weapons")
    proj_dir = os.path.join(out_dir, "..", "projectiles")
    os.makedirs(proj_dir, exist_ok=True)
    for name, make in PROJECTILES.items():
        art = finish(make(), 0.0)
        data = {"_doc": "Flying weapon or shot (docs/ART_RULES.md: Weapons), built by tools/art/build_weapons.py: drawn "
                        "tip up; the game turns it to face its flight (or spins it).",
                "size": art["size"], "palette": PALETTE, "frames": {"idle": [art["rows"]]}}
        with open(os.path.join(proj_dir, name + ".json"), "w") as f:
            json.dump(data, f, indent=1)
    print("wrote", len(PROJECTILES), "projectiles")
