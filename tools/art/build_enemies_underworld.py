# The Underworld's enemies (Pack 2, docs/PACK_2_PLAN.md; docs/ART_RULES.md: Enemies). Run:
# python3 build_enemies_underworld.py from tools/art/. Writes data/art/enemies/<enemy id>.json, each drawn facing right
# with a standing frame and 4 moving frames (legs stepping or wings beating), from the sources in data/enemies.json.
# The shades are already drawn by build_enemies_aegean.py.
import hero_kit as kit
from hero_kit import ellipse, poly

OUT = "enemies"
STEP = [0, -1, 0, 1, 0]          # leg step per frame (standing, then 4 walking)
FLAP = [0, 1, 2, 1, 0]           # wing beat per frame


def legs2(c, x0, y0, length, step, col, shade, foot, gap=3, w=2):
    for k, d in enumerate((-step, step)):
        x = x0 + k * gap + d
        c.rect(x, y0, x + w - 1, y0 + length - 1, shade if k == 0 else col)
        c.rect(x, y0 + length, x + w, y0 + length, foot)


# --- Furies-kin: the Erinyes (Aeschylus, Eumenides; Greek vase painting) ----------------------------------------

def erinys(c, f, size, span):
    """A winged huntress as Greek vases paint the Erinyes: a short dark chiton and hunting boots, dark wings, snakes
    twined in her hair, a snake held out like a whip. Nameless: none of the three named Furies."""
    w, h = size
    b = -FLAP[f] // 2
    flap = FLAP[f]
    cx = w // 2 - 1
    for side, col in ((-1, "W"), (1, "w")):                     # dark wings beating
        tip = (cx + side * span, 2 + flap * 2 + b)
        poly(c, [(cx - 1, 8 + b), (cx + 2, 8 + b), tip], col)
        poly(c, [(cx, 10 + b), tip, (tip[0] - side, tip[1] + 4)], col)
    c.rect(cx - 2, 8 + b, cx + 2, 15 + b, "d"); c.rect(cx - 2, 8 + b, cx - 1, 15 + b, "D")   # short chiton
    c.rect(cx - 1, 16 + b, cx, h - 3 + b, "s"); c.rect(cx + 1, 16 + b, cx + 2, h - 4 + b, "s")
    c.rect(cx - 1, h - 3 + b, cx + 1, h - 2 + b, "D"); c.rect(cx + 1, h - 4 + b, cx + 3, h - 3 + b, "D")   # boots
    ellipse(c, cx + 1, 5 + b, 2.6, 2.8, "s")                   # face
    c.px(cx + 2, 5 + b, "k")
    c.rect(cx - 2, 2 + b, cx, 6 + b, "h"); c.row(2 + b, cx - 1, cx + 3, "h")
    for x, y in ((cx - 3, 3), (cx - 2, 1), (cx + 3, 2), (cx - 3, 6)):   # snakes in her hair
        c.px(x, y + b, "g"); c.px(x - 1 if x < cx else x + 1, y - 1 + b, "g")
    for k in range(5):                                          # a snake held out ahead of her
        c.px(cx + 3 + k, 10 + b + (k % 2), "g")
    c.px(cx + 8, 9 + b, "G")


ERINYS_PAL = {"o": "#140c10", "k": "#0c0608", "s": "#d8b49a", "h": "#1c1418", "d": "#3a2a3a", "D": "#24182a",
              "w": "#3c3444", "W": "#28222e", "g": "#5a8a3a", "G": "#8ab04a"}


# --- Skeletal hoplites (the armed dead of Odyssey 11; Greek hoplite armour) -------------------------------------

def hoplite(c, f, big):
    """A dead hoplite: bare bones under a bronze Corinthian helmet with a horsehair crest, a round bronze shield
    (aspis) on his arm and a spear. `big` carries a larger shield and stands taller."""
    s = STEP[f]
    lift = 2 if big else 0
    legs2(c, 9, 18 + lift, 8, s, "b", "B", "k", gap=4, w=1)        # thin bone legs
    c.rect(10, 10 + lift, 14, 17 + lift, "B")                      # ribcage
    for y in range(11 + lift, 17 + lift, 2):
        c.row(y, 10, 14, "b")
    c.rect(12, 9 + lift, 12, 18 + lift, "b")                       # spine
    c.rect(9, 2 + lift, 15, 8 + lift, "u"); c.rect(9, 2 + lift, 10, 8 + lift, "U")   # Corinthian helmet
    c.rect(13, 5 + lift, 15, 6 + lift, "k")                        # the T-shaped face opening, dark inside
    c.rect(14, 4 + lift, 14, 8 + lift, "k")
    c.rect(9, 0 + lift, 14, 1 + lift, "r"); c.px(8, 1 + lift, "r"); c.px(8, 2 + lift, "r")   # crest
    r = 6.0 if big else 5.0
    ellipse(c, 8, 14 + lift, r, r + 0.5, "u"); ellipse(c, 8, 14 + lift, r - 2, r - 1.5, "U")   # aspis
    c.px(8, 14 + lift, "y"); c.px(7, 13 + lift, "y"); c.px(9, 15 + lift, "y")                # its emblem
    c.rect(15, 11 + lift, 17, 12 + lift, "b")                      # bone arm
    for y in range(0, 28):
        c.px(18, y, "c")
    c.rect(17, 0, 19, 2, "i")                                      # spear


HOPLITE_PAL = {"o": "#140c08", "k": "#0c0604", "b": "#e2dccc", "B": "#a8a090", "u": "#b88a3a", "U": "#7a5a20",
               "y": "#f0cc58", "r": "#3a2a2a", "c": "#6a4a30", "i": "#c8ccd4"}


# --- Stymphalian birds (Pausanias 8.22.4-6; Apollonius, Argonautica 2.1030-1089) -------------------------------

def stymphalian(c, f, size):
    """A man-eating marsh bird the size of a crane, like an ibis but with a stronger, straight beak: bronze-brown with
    bronze-tipped wing feathers, which it sheds like arrows (Apollonius)."""
    w, h = size
    b = -FLAP[f] // 2
    flap = FLAP[f]
    cx = w // 2 - 2
    for side, col in ((-1, "W"), (1, "w")):
        tip = (cx + side * (w // 2 - 1), 2 + flap * 3 + b)
        poly(c, [(cx - 1, 8 + b), (cx + 3, 8 + b), tip], col)
        c.px(tip[0], tip[1], "u"); c.px(tip[0] - side, tip[1] + 1, "u")   # bronze feather tips
    ellipse(c, cx + 1, 10 + b, 4, 3, "w")                             # body
    c.rect(cx - 3, 10 + b, cx - 1, 11 + b, "W")                       # tail
    c.rect(cx + 4, 5 + b, cx + 5, 9 + b, "w")                         # neck
    ellipse(c, cx + 6, 4 + b, 2, 1.8, "w"); c.px(cx + 6, 3 + b, "k")  # head
    c.row(4 + b, cx + 8, cx + 11, "u"); c.px(cx + 11, 5 + b, "U")     # straight bronze beak
    c.rect(cx, 13 + b, cx, h - 2 + b, "U"); c.rect(cx + 2, 13 + b, cx + 2, h - 3 + b, "U")   # long legs


STYMPH_PAL = {"o": "#1c140c", "k": "#0c0806", "w": "#7a5a3a", "W": "#54402a", "u": "#d0a040", "U": "#9a7428"}


def build(enemy_id, size, anchor, draw, palette, doc):
    kit.build_boss(enemy_id, lambda c, f: draw(c, f), palette, doc, size, anchor, [0, 1, 2, 3, 4], folder=OUT)
    print("wrote data/art/enemies/%s.json" % enemy_id)


if __name__ == "__main__":
    erinys_doc = ("Furies-kin (docs/PACK_2_PLAN.md: the Underworld). After the Erinyes of Aeschylus' Eumenides and "
                  "Greek vase painting: winged huntresses in short dark chitons and hunting boots, snakes in their "
                  "hair and hands. Nameless, not the three named Furies. Built by tools/art/build_enemies_underworld.py.")
    build("erinys_swarm", (18, 24), (8, 22), lambda c, f: erinys(c, f, (18, 24), 7), ERINYS_PAL, erinys_doc)
    build("erinys_flyer", (22, 24), (10, 22), lambda c, f: erinys(c, f, (22, 24), 9), ERINYS_PAL, erinys_doc)
    hoplite_doc = ("Skeletal hoplite (docs/PACK_2_PLAN.md: the Underworld). The armed dead of Homer, Odyssey 11 "
                   "(men killed in battle, still in their bloodied armour), drawn as bare bones in Greek hoplite gear: "
                   "a crested Corinthian helmet, a round bronze aspis and a spear. Built by "
                   "tools/art/build_enemies_underworld.py.")
    build("skeletal_hoplite", (22, 30), (12, 28), lambda c, f: hoplite(c, f, False), HOPLITE_PAL, hoplite_doc)
    build("hoplite_shieldwall", (24, 32), (12, 30), lambda c, f: hoplite(c, f, True), HOPLITE_PAL, hoplite_doc)
    bird_doc = ("Stymphalian bird (docs/PACK_2_PLAN.md: the Underworld). Pausanias, Description of Greece 8.22.4-6 "
                "(man-eating birds the size of cranes, like ibises with stronger, straight beaks) and Apollonius, "
                "Argonautica 2.1030-1089 (they shed their feathers like arrows). Built by "
                "tools/art/build_enemies_underworld.py.")
    build("stymphalian_flock", (22, 18), (10, 16), lambda c, f: stymphalian(c, f, (22, 18)), STYMPH_PAL, bird_doc)
    build("stymphalian_archer", (24, 20), (11, 18), lambda c, f: stymphalian(c, f, (24, 20)), STYMPH_PAL, bird_doc)
