# The Aegean Shore's enemies (docs/ART_RULES.md: Enemies). Run: python3 build_enemies_aegean.py from tools/art/.
# Writes data/art/enemies/<enemy id>.json. Each enemy is drawn facing right with a standing frame and 4 moving
# frames (legs stepping, wings beating, or a ghost's bobbing), from the sources in data/enemies.json.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

OUT = "enemies"


def legs2(c, x0, y0, length, step, col, shade, foot, gap=3, w=2):
    """Two legs from (x0, y0) down `length` pixels, stepping by `step` (the near leg forward, the far back)."""
    for k, d in enumerate((-step, step)):
        x = x0 + k * gap + d
        c.rect(x, y0, x + w - 1, y0 + length - 1, shade if k == 0 else col)
        c.rect(x, y0 + length, x + w, y0 + length, foot)


STEP = [0, -1, 0, 1, 0]          # leg step per frame (standing, then 4 walking)
BOB = [0, -1, -2, -1, 0]         # a floating body's rise per frame
FLAP = [0, 1, 2, 1, 0]           # wing beat per frame


# --- Shades of the dead (Homer, Odyssey 11) ---------------------------------------------------------------------

SHADE_DOC = ("{name} (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). From Homer, Odyssey 11: the shades of "
             "the dead, thin and bodiless, that flit and gibber round Odysseus. A pale, wispy hooded figure with dark "
             "hollows for eyes, trailing off into mist instead of legs. Built by tools/art/build_enemies_aegean.py.")


def shade(c, f, size, arms=False, palette=("w", "W", "m")):
    w, h = size
    light, dark, mist = palette
    b = BOB[f]
    cx = w // 2
    ellipse(c, cx, 5 + b, 4, 4.5, light)                       # hooded head
    poly(c, [(cx - 4, 6 + b), (cx + 4, 6 + b), (cx + 5, h - 6 + b), (cx - 5, h - 5 + b)], light)
    for k in range(3):                                        # the trailing wisps
        x = cx - 3 + k * 3 + (f % 2)
        c.rect(x, h - 6 + b, x + 1, h - 3 + b + (k % 2), mist)
    c.rect(cx - 5, 6 + b, cx - 4, h - 6 + b, dark)
    c.rect(cx, 4 + b, cx + 1, 5 + b, "k"); c.px(cx + 3, 4 + b, "k"); c.px(cx + 3, 5 + b, "k")   # dark hollows
    c.row(8 + b, cx + 1, cx + 3, dark)                         # a gaping mouth
    if arms:
        c.rect(cx + 4, 9 + b - f % 2, cx + 7, 10 + b - f % 2, light); c.rect(cx - 7, 10 + b, cx - 4, 11 + b, dark)


SHADE_PAL = {"o": "#2a2a3a", "k": "#141020", "w": "#c8d4e0", "W": "#8a98b0", "m": "#a0b0c8"}
ENCIRCLER_PAL = {"o": "#2a2a3a", "k": "#141020", "w": "#b4a8cc", "W": "#7a6e98", "m": "#9a90b8"}


# --- Harpies (Apollonius, Argonautica 2) and Sirens (Odyssey 12; Greek vase painting) ---------------------------

def bird_woman(c, f, size, wing_span, hair, body, body_s, extra=None):
    """A bird's body and wings with a woman's head, as Greek vases paint harpies and sirens."""
    w, h = size
    b = -FLAP[f] // 2
    flap = FLAP[f]
    cx = w // 2 - 1
    # wings: raised and lowered across the frames
    for side, col in ((-1, body_s), (1, body)):
        tip = (cx + side * wing_span, 3 + flap * 2 + b)
        poly(c, [(cx - 1, 8 + b), (cx + 2, 8 + b), tip], col)
        poly(c, [(cx, 9 + b), tip, (tip[0] - side, tip[1] + 3)], col)
    ellipse(c, cx, 11 + b, 3.5, 3.5, body)                       # feathered body
    c.rect(cx - 2, 12 + b, cx - 1, 14 + b, body_s)
    c.rect(cx - 3, 13 + b, cx - 2, 15 + b, body_s)               # tail
    c.px(cx, 15 + b, "y"); c.px(cx + 2, 15 + b, "y"); c.px(cx, 16 + b, "y"); c.px(cx + 3, 16 + b, "y")   # talons
    ellipse(c, cx + 1, 5 + b, 2.5, 2.8, "s")                     # a woman's face
    c.rect(cx - 2, 2 + b, cx + 1, 6 + b, hair); c.row(2 + b, cx - 1, cx + 3, hair)
    c.px(cx + 2, 5 + b, "k")
    if extra:
        extra(c, cx, b)


BIRD_PAL = {"o": "#24160e", "k": "#140c08", "s": "#e2b48a", "y": "#d8b048"}


# --- Satyrs (Euripides, Cyclops; Hesiod fr. 10a) ------------------------------------------------------------------

def satyr(c, f):
    """A satyr as Greek vases paint them: a snub-nosed bearded man with a horse's ears and tail; here the goat legs
    of later art are left out, the vase-painting horse tail kept."""
    s = STEP[f]
    legs2(c, 6, 14, 6, s, "s", "S", "k", gap=3)
    c.rect(4, 9, 10, 14, "s"); c.rect(4, 9, 5, 14, "S")         # body
    c.rect(1, 9, 3, 11, "h"); c.px(0, 12, "h"); c.px(1, 12, "h") # horse tail
    ellipse(c, 8, 5, 3, 3, "s"); c.px(10, 5, "k"); c.px(11, 6, "s")
    c.rect(5, 2, 7, 4, "h"); c.px(5, 1, "s"); c.px(6, 0, "s")    # hair and a horse's pointed ear
    c.rect(7, 8, 10, 9, "h")                                     # beard
    c.rect(10, 10, 12, 11, "s")                                  # arm reaching
    c.rect(4, 12, 10, 12, "g")                                   # a wine-dark band


SATYR_PAL = {"o": "#24160e", "k": "#140c08", "s": "#c88a5a", "S": "#9a6440", "h": "#4a2c18", "g": "#7a2a5a"}


# --- Spartoi, the sown men (Apollodorus 1.9.23, 3.4.1) -------------------------------------------------------------

def spartoi(c, f):
    """The Sown Men, armed warriors sprung from the dragon's teeth: a bronze helmet with a crest, a bronze
    breastplate, a round shield and a spear, their legs still rising out of a mound of earth."""
    s = STEP[f]
    poly(c, [(2, 30), (24, 30), (21, 24), (5, 24)], "e"); c.row(24, 6, 20, "E")    # the earth they rise from
    for k in range(4):
        c.px(5 + k * 5, 26 + (k % 2), "E")
    legs2(c, 10, 18, 7 + s, 0, "s", "S", "E", gap=4)
    c.rect(8, 9, 16, 18, "g"); c.rect(8, 9, 9, 18, "G"); c.row(13, 11, 15, "G")   # breastplate
    c.rect(9, 2, 16, 8, "g"); c.rect(9, 2, 10, 8, "G"); c.rect(14, 5, 16, 7, "s"); c.px(15, 5, "k")  # helmet, face
    c.rect(8, 0, 14, 1, "r"); c.px(7, 1, "r"); c.px(7, 2, "r")   # red crest
    ellipse(c, 6, 13, 4.5, 5, "g"); ellipse(c, 6, 13, 2.5, 3, "G"); c.px(6, 13, "u")   # shield
    c.rect(17, 10, 19, 12, "s")
    c.col_ = None
    for y in range(0, 26):
        c.px(20, y, "c")
    c.rect(19, 0, 21, 2, "i")                                     # spear


SPARTOI_PAL = {"o": "#24160e", "k": "#140c08", "s": "#c88a5a", "S": "#9a6440", "g": "#b88a3a", "G": "#7a5a20",
               "u": "#f0cc58", "r": "#a83a2c", "c": "#7a5030", "i": "#c8ccd4", "e": "#7a5a3a", "E": "#54402a"}


# --- Khalkotauroi, the bronze bulls (Argonautica 3) -------------------------------------------------------------

def bronze_bull(c, f):
    """The bronze-footed, fire-breathing bulls of Aeëtes that Jason yoked: a bronze bull, flame at its nostrils."""
    s = STEP[f]
    for k, x in enumerate((4, 7, 13, 16)):
        d = s if k % 2 == 0 else -s
        c.rect(x + d, 11, x + 1 + d, 15, "G" if k in (0, 2) else "g"); c.rect(x + d, 15, x + 2 + d, 15, "k")
    ellipse(c, 10, 9, 8, 4, "g"); c.row(6, 4, 15, "u")            # body, light on the back
    c.rect(1, 7, 2, 9, "G")                                       # tail
    ellipse(c, 18, 7, 3, 3, "g"); c.px(18, 6, "k")                # head
    c.px(17, 3, "w"); c.px(16, 2, "w"); c.px(20, 3, "w"); c.px(21, 2, "w")    # horns
    c.rect(21, 8, 22, 9, "G")
    flicker = f % 2
    c.px(23, 8, "r"); c.px(24, 8 + flicker, "f"); c.px(25, 7, "f"); c.px(24, 9, "F")   # fire from its nostrils


BULL_PAL = {"o": "#24160e", "k": "#140c08", "g": "#c08a3a", "G": "#8a5e20", "u": "#f0c860", "w": "#efe6d2",
            "r": "#c83a20", "f": "#ff9030", "F": "#ffe070"}


# --- Elites: the Minotaur, a Cyclops, a Gorgon ----------------------------------------------------------------------

def minotaur(c, f):
    """The Minotaur (Apollodorus 3.1.4): a man's body with a bull's head, as Greek vases paint him; a short loincloth."""
    s = STEP[f]
    legs2(c, 14, 30, 12, s, "s", "S", "k", gap=6, w=4)
    c.rect(11, 27, 25, 31, "r"); c.row(31, 11, 25, "R")           # loincloth
    c.rect(10, 13, 26, 27, "s"); c.rect(10, 13, 13, 27, "S")      # a massive chest
    c.row(19, 15, 18, "S"); c.row(19, 20, 23, "S"); c.px(19, 23, "S")
    c.rect(6, 14, 9, 27, "S"); c.rect(27, 14, 30, 24, "s"); c.rect(29, 24, 32, 27, "s")   # arms
    ellipse(c, 21, 7, 6, 5.5, "b"); poly(c, [(23, 6), (31, 8), (31, 12), (24, 13)], "b")  # bull's head
    c.rect(29, 10, 31, 12, "B"); c.px(30, 9, "k")                  # muzzle, nostril
    c.px(24, 6, "y"); c.px(25, 6, "k")
    poly(c, [(17, 3), (12, 0), (14, 4)], "w"); poly(c, [(23, 3), (27, 0), (25, 4)], "w")  # horns
    c.rect(15, 11, 18, 13, "b")


MINO_PAL = {"o": "#24160e", "k": "#140c08", "s": "#b8784a", "S": "#8a5432", "b": "#5a3a24", "B": "#3a2416",
            "w": "#e8dcc0", "y": "#e8c040", "r": "#8a2a20", "R": "#5a1a14"}


def cyclops(c, f):
    """A Cyclops (Hesiod, Theogony 139-146: one round eye in the middle of the forehead; Odyssey 9: the shepherd
    giant with a great club of green olive wood): a huge rough giant in a sheepskin, a club in his fist."""
    s = STEP[f]
    legs2(c, 16, 38, 12, s, "s", "S", "k", gap=7, w=5)
    c.rect(12, 30, 30, 38, "f"); c.row(38, 12, 30, "F")           # sheepskin
    for x in range(13, 30, 3):
        c.px(x, 33, "w"); c.px(x + 1, 35, "w")
    c.rect(12, 15, 30, 30, "s"); c.rect(12, 15, 15, 30, "S")
    c.rect(7, 16, 11, 32, "S"); c.rect(7, 32, 11, 35, "s")        # far arm
    ellipse(c, 22, 9, 7.5, 7, "s"); c.rect(15, 3, 25, 6, "h")     # head, wild hair
    ellipse(c, 25, 7, 2.5, 2.5, "w"); c.rect(25, 6, 26, 8, "k")   # the one round eye
    c.row(4, 22, 28, "h"); c.rect(20, 13, 29, 17, "h")            # brow, beard
    c.rect(29, 17, 33, 26, "s")                                   # near arm
    for y in range(0, 30):                                        # the olive-wood club
        x = 36 - y // 6
        c.rect(x, y, x + (3 if y < 10 else 1), y, "c")
    c.rect(32, 24, 36, 28, "s")


CYC_PAL = {"o": "#24160e", "k": "#140c08", "s": "#c89a78", "S": "#9a6e52", "h": "#4a3a2a", "w": "#efe6d2",
           "f": "#d8ccb0", "F": "#a89878", "c": "#7a5030"}


def gorgon(c, f):
    """A Gorgon sister (Hesiod, Theogony 270-283; Apollodorus 2.4.2: serpents for hair, a boar's tusks, bronze hands,
    golden wings), running in the knee-bent stride of archaic Greek art, in a short chiton."""
    s = STEP[f]
    for k, x in enumerate((10, 16)):
        d = s * 2 if k else -s * 2
        c.rect(x + d, 24, x + 2 + d, 33, "s"); c.rect(x + d, 33, x + 3 + d, 34, "k")
    flap = FLAP[f]
    poly(c, [(9, 13), (1, 4 + flap), (2, 14 + flap), (8, 18)], "u"); c.px(2, 6 + flap, "U"); c.px(3, 10 + flap, "U")
    c.rect(9, 12, 20, 25, "r"); c.rect(9, 12, 10, 25, "R")        # chiton
    ellipse(c, 16, 6, 4.5, 4.5, "s"); c.px(18, 5, "k"); c.px(19, 8, "w"); c.px(19, 9, "w")   # face, tusk
    for k, (x, y) in enumerate([(11, 1), (14, 0), (17, 0), (20, 1), (11, 5)]):
        c.rect(x, y, x + 1, y + 2, "g"); c.px(x + (1 if k % 2 else 0), y, "G")   # serpent hair
    c.rect(19, 13, 23, 15, "s"); c.rect(23, 12, 25, 15, "b")      # arm, bronze hand


GORGON_PAL = {"o": "#24160e", "k": "#140c08", "s": "#d8c4a4", "u": "#e8c050", "U": "#a88028", "r": "#3e3452",
              "R": "#28203a", "w": "#f4ecd8", "g": "#6aa04a", "G": "#3e6a2a", "b": "#c08a3a"}


def build(enemy_id, size, anchor, draw, palette, doc):
    kit.build_boss(enemy_id, lambda c, f: draw(c, f), palette, doc, size, anchor, [0, 1, 2, 3, 4], folder=OUT)
    print("wrote data/art/enemies/%s.json" % enemy_id)


if __name__ == "__main__":
    build("shade_swarm", (14, 18), (7, 16), lambda c, f: shade(c, f, (14, 18)), SHADE_PAL, SHADE_DOC.format(name="Shade"))
    build("shade_flyer", (18, 20), (9, 18), lambda c, f: shade(c, f, (18, 20), arms=True), SHADE_PAL,
          SHADE_DOC.format(name="Shade (flyer)"))
    build("shade_encircler", (16, 20), (8, 18), lambda c, f: shade(c, f, (16, 20), arms=True), ENCIRCLER_PAL,
          SHADE_DOC.format(name="Shade (encircler, a darker, violet shade)"))
    harpy_doc = ("Harpy (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). From Apollonius of Rhodes, "
                 "Argonautica 2.178-300 (the Harpies who snatch Phineus' food), as Greek vases paint them: a bird's "
                 "body and wings with a woman's head, dark hair, talons. Built by tools/art/build_enemies_aegean.py.")
    build("harpy_swarm", (18, 20), (8, 18), lambda c, f: bird_woman(c, f, (18, 20), 7, "h", "b", "B"),
          dict(BIRD_PAL, h="#2a1c18", b="#6a5a6a", B="#4a3a4a"), harpy_doc)
    build("harpy_flyer", (22, 20), (10, 18), lambda c, f: bird_woman(c, f, (22, 20), 9, "h", "b", "B"),
          dict(BIRD_PAL, h="#2a1c18", b="#7a5a4a", B="#54382e"), harpy_doc)

    def lyre(c, cx, b):
        c.rect(cx + 4, 9 + b, cx + 4, 13 + b, "y"); c.rect(cx + 7, 9 + b, cx + 7, 13 + b, "y")
        c.row(9 + b, cx + 4, cx + 7, "y"); c.rect(cx + 5, 10 + b, cx + 6, 12 + b, "w")
    build("siren_caster", (20, 20), (9, 18), lambda c, f: bird_woman(c, f, (20, 20), 7, "h", "b", "B", lyre),
          dict(BIRD_PAL, h="#a8603a", b="#e8dcc0", B="#b8a888", w="#c8b88a"),
          "Siren (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). Homer (Odyssey 12.39-200) gives the "
          "Sirens no shape; Greek vase painting (the Siren vase, British Museum) shows them as birds with women's "
          "heads, often with a lyre: a pale-feathered bird with a woman's head and red-gold hair, holding a lyre. "
          "Built by tools/art/build_enemies_aegean.py.")
    build("satyr_skirmisher", (14, 22), (8, 20), satyr, SATYR_PAL,
          "Satyr (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). From Euripides' satyr play Cyclops and "
          "Hesiod fr. 10a, as Greek vases paint satyrs: a snub-nosed, bearded man with a horse's ears and tail. "
          "Built by tools/art/build_enemies_aegean.py.")
    build("spartoi_brute", (26, 32), (13, 30), spartoi, SPARTOI_PAL,
          "Spartoi, the Sown Men (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). From Pseudo-Apollodorus, "
          "Bibliotheca 1.9.23 and 3.4.1 and Apollonius: armed warriors who sprang from the dragon's teeth sown in "
          "the earth. A crested bronze helmet, a breastplate, a round shield and a spear, rising out of the earth. "
          "Built by tools/art/build_enemies_aegean.py.")
    build("khalkotauros_bomber", (27, 18), (12, 16), bronze_bull, BULL_PAL,
          "Khalkotauros, a bronze bull (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). From Apollonius "
          "of Rhodes, Argonautica 3.409-421 and 3.1278-1329: the bronze-footed bulls of Aeëtes that breathed fire. "
          "Built by tools/art/build_enemies_aegean.py.")
    build("minotaur", (34, 46), (18, 44), minotaur, MINO_PAL,
          "Minotaur, elite (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). From Apollodorus, Library "
          "3.1.4 and Epitome 1.7-9, as Greek vases paint him: a man's body with a bull's head. Built by "
          "tools/art/build_enemies_aegean.py.")
    build("cyclops", (40, 54), (21, 52), cyclops, CYC_PAL,
          "Cyclops, elite (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). From Hesiod, Theogony 139-146 "
          "(one round eye in the middle of the forehead) and Homer, Odyssey 9 (the shepherd giant and his great "
          "club of olive wood): a huge rough giant in a sheepskin, a club in his fist. Built by "
          "tools/art/build_enemies_aegean.py.")
    build("gorgon_kin", (28, 38), (14, 36), gorgon, GORGON_PAL,
          "Gorgon, elite (GAME_DESIGN.md: The Aegean Shore enemies; art 10/31/2026). Medusa's immortal sisters "
          "(Hesiod, Theogony 270-283; Apollodorus 2.4.2: serpents for hair, a boar's tusks, bronze hands, golden "
          "wings), running in the knee-bent stride of archaic Greek art. Built by tools/art/build_enemies_aegean.py.")
