# Gothic Night's art (Pack 5, docs/PACK_5_PLAN.md; docs/ART_RULES.md), one realm at a time. Drawn only from the old
# texts and folklore (Hesiod, Aristophanes, Pausanias, the Anglo-Saxon Chronicle, Le Fanu, Polidori, Varney, Gerald of
# Wales, Marie de France, Goethe), never later versions.
# Run: python3 build_gothic.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]


# --- Erebus (Hesiod; Aristophanes, The Frogs; Pausanias 10.28.7; the Anglo-Saxon Chronicle 1127) ----------------------

def ker(c, f):
    """A Ker (Hesiod, Theogony 211-217; the Shield of Heracles 248-257): a dark-winged death spirit of the battlefield
    in a blood-stained cloak, with long claws."""
    s = STEP[f]
    poly(c, [(9, 6), (1, 2 + s), (4, 12)], "w"); poly(c, [(11, 6), (19, 2 + s), (16, 12)], "w")
    poly(c, [(7, 6), (13, 6), (14, 18), (6, 18)], "d")
    c.rect(7, 12, 13, 13, "r")                                                          # blood on the cloak
    ellipse(c, 10, 4, 2.5, 2.5, "p"); c.px(9, 4, "y"); c.px(11, 4, "y")
    c.px(5, 16, "p"); c.px(15, 16, "p")


KER_PAL = {"o": "#0a0608", "d": "#2a2028", "w": "#3a3040", "r": "#7a1a1a", "p": "#b8b0a8", "y": "#e85a3a"}


def hunt_hound(c, f):
    """A hound of the Wild Hunt (the Anglo-Saxon Chronicle for 1127: "the hounds were all black and wide-eyed and
    ugly"): a lean black hound with burning eyes."""
    s = STEP[f]
    ellipse(c, 11, 9, 7, 3, "k")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 4 + d, 11, 5 + k * 4 + d, 15, "K")
    poly(c, [(16, 5), (22, 7), (22, 10), (16, 10)], "k"); c.px(18, 6, "y"); c.px(19, 6, "y")
    c.px(17, 3, "k"); c.px(17, 4, "k"); c.row(9, 0, 4, "K")


HOUND_PAL = {"o": "#2a2830", "k": "#141218", "K": "#0a080c", "y": "#f0c040"}


def empusa(shape):
    """Empusa (Aristophanes, The Frogs 285-295): the shape-shifting spectre of the dark road, "now a bull, now a mule,
    now a lovely woman, now a dog", one leg of bronze."""
    def draw(c, step):
        if shape == "woman":
            for k, d in enumerate((-step, step)):
                c.rect(16 + k * 6 + d, 46, 18 + k * 6 + d, 54, "b" if k else "s")       # one leg of bronze
            poly(c, [(14, 18), (28, 18), (32, 48), (10, 48)], "v")
            c.rect(16, 6, 25, 16, "s"); c.px(19, 10, "y"); c.px(23, 10, "y")
            c.rect(14, 3, 27, 7, "h"); c.rect(13, 6, 15, 26, "h"); c.rect(26, 6, 28, 26, "h")
            c.rect(30, 22, 33, 26, "y")                                                 # a glowing hand
            return
        if shape == "bull":
            ellipse(c, 22, 30, 16, 10, "k")
            for k, d in enumerate((-step, step, step, -step)):
                c.rect(10 + k * 8 + d, 38, 13 + k * 8 + d, 52, "b" if k == 3 else "K")
            ellipse(c, 36, 24, 7, 7, "k"); c.px(38, 22, "y")
            poly(c, [(34, 18), (30, 10), (36, 17)], "h"); poly(c, [(40, 18), (44, 10), (40, 17)], "h")
            return
        ellipse(c, 20, 34, 13, 6, "k")                                                  # the dog
        for k, d in enumerate((-step, step, step, -step)):
            c.rect(10 + k * 6 + d, 38, 11 + k * 6 + d, 50, "b" if k == 3 else "K")
        poly(c, [(30, 26), (40, 28), (40, 33), (30, 33)], "k"); c.px(34, 28, "y"); c.px(31, 23, "k"); c.px(31, 24, "k")
        c.row(33, 4, 8, "K")
    return draw


EMPUSA_PAL = {"o": "#0e0a10", "k": "#2a2430", "K": "#1a1620", "b": "#b07a3a", "s": "#d8c8b8", "v": "#4a2a4a",
              "h": "#1a1418", "y": "#f05a3a"}


def eurynomos(c, step):
    """Eurynomos (Pausanias 10.28.7, describing Polygnotus' painting): a daemon of the underworld who eats the flesh of
    the dead, leaving only the bones; "his colour is between blue and black, like that of the flies that settle on
    meat; he is showing his teeth, and is seated on the skin of a vulture"."""
    poly(c, [(6, 44), (46, 44), (40, 52), (12, 52)], "f")                               # the vulture's skin
    for k in range(6):
        c.px(8 + k * 7, 46, "F"); c.px(9 + k * 7, 48, "F")
    ellipse(c, 26, 30, 14, 14, "b")
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 18 + d, 38, 19 + k * 18 + d, 46, "B")
    ellipse(c, 26, 14, 9, 8, "b")
    c.px(22, 12, "y"); c.px(30, 12, "y")
    c.rect(20, 17, 32, 19, "k")
    for x in range(21, 32, 2):
        c.px(x, 17, "w"); c.px(x + 1, 19, "w")                                          # the bared teeth
    c.rect(8, 26, 12, 30, "B"); c.rect(40, 26, 44, 30, "B")
    for k in range(3):
        c.px(4 + k * 2, 34, "w")                                                        # a bone in his hand


EURY_PAL = {"o": "#06080e", "b": "#2a3448", "B": "#1a2232", "k": "#0a0a10", "w": "#ece6d8", "y": "#c8f040",
            "f": "#6a5a48", "F": "#4a3e30"}


def wild_hunt(c, step):
    """The Wild Hunt (the Anglo-Saxon Chronicle for 1127: "the huntsmen were black, and big, and loathsome, and their
    hounds all black and wide-eyed and ugly, and they rode on black horses"): a black huntsman with a horn on a black
    horse, a pale ghost-light round them."""
    for x in range(4, 66, 3):
        c.px(x, 54, "g")
    ellipse(c, 32, 34, 20, 9, "k")
    for k, d in enumerate((-step, step, step, -step)):
        x = 16 + k * 10 + d * 2
        c.rect(x, 40, x + 3, 52, "K")
    poly(c, [(48, 24), (60, 20), (62, 28), (50, 32)], "k"); c.px(56, 23, "y")
    for k in range(6):
        c.px(46 - k, 22 + k, "m")                                                       # the mane
    c.rect(26, 10, 34, 28, "K")                                                          # the huntsman
    ellipse(c, 30, 7, 4, 4, "K"); c.px(31, 6, "y")
    poly(c, [(24, 12), (12, 6), (14, 4), (26, 10)], "h")                                  # his horn, raised
    c.rect(4, 32, 12, 34, "k")                                                           # the tail


HUNT_PAL = {"o": "#2a3040", "k": "#141218", "K": "#0a080c", "y": "#f0c040", "m": "#2a2830", "h": "#c8b890",
            "g": "#8a9ab8"}


# --- Karnstein (Le Fanu, Carmilla 1872; Polidori, The Vampyre 1819; Varney the Vampire 1845-47; Calmet 1746) ---------

def revenant(c, f):
    """A revenant (Calmet, Treatise on Vampires, 1746: the dead who leave their graves at night): a grey-faced corpse in
    a burial shroud, arms out."""
    s = STEP[f]
    for x, d in ((7, -s), (11, s)):
        c.rect(x + d, 18, x + 1 + d, 22, "g")
    poly(c, [(6, 8), (13, 8), (14, 19), (5, 19)], "w")
    c.rect(3, 9, 6, 10, "g"); c.rect(13, 9, 16, 10, "g")                                # arms out
    ellipse(c, 9, 5, 3, 3, "g"); c.px(8, 5, "r"); c.px(10, 5, "r"); c.row(7, 8, 10, "k")
    c.row(13, 6, 13, "W")


REVENANT_PAL = {"o": "#141214", "w": "#c8c4b8", "W": "#a8a498", "g": "#8a948a", "r": "#c83a3a", "k": "#1a1414"}


def night_bat(c, f):
    """A bat of the night (Carmilla; Varney the Vampire): a small black bat, wings beating."""
    up = f % 2
    poly(c, [(8, 6), (1, 2 if up else 9), (4, 8)], "k"); poly(c, [(10, 6), (17, 2 if up else 9), (14, 8)], "k")
    ellipse(c, 9, 7, 2.5, 3, "b"); c.px(8, 6, "r"); c.px(10, 6, "r"); c.px(8, 4, "b"); c.px(10, 4, "b")


BAT_PAL = {"o": "#2a2028", "k": "#1a141c", "b": "#2e2430", "r": "#e83a3a"}


def varney(c, step):
    """Sir Francis Varney (Rymer and Prest, Varney the Vampire, 1845-47): tall and gaunt, his face white as death, his
    teeth like fangs, in an old-fashioned dark coat; the moon brings him back to life."""
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 6 + d, 44, 17 + k * 6 + d, 54, "k")
    poly(c, [(13, 16), (27, 16), (29, 46), (11, 46)], "c")
    c.rect(18, 16, 22, 30, "w")                                                         # shirt front
    c.rect(15, 4, 25, 14, "s"); c.px(18, 8, "y"); c.px(22, 8, "y"); c.px(19, 12, "w"); c.px(21, 12, "w")
    c.rect(14, 2, 26, 5, "h")
    c.rect(8, 18, 11, 34, "c"); c.rect(29, 18, 32, 34, "c"); c.rect(7, 34, 10, 37, "s"); c.rect(30, 34, 33, 37, "s")


VARNEY_PAL = {"o": "#0a080c", "k": "#141018", "c": "#2a2430", "w": "#e8e4dc", "s": "#e0dcd4", "y": "#c83a2a",
              "h": "#2a2018"}


def ruthven(c, step):
    """Lord Ruthven (Polidori, The Vampyre, 1819): a nobleman with a dead grey eye and a deadly pale face, coldly
    elegant in a dark coat with a red-lined cloak."""
    for k, d in enumerate((-step, step)):
        c.rect(15 + k * 6 + d, 44, 17 + k * 6 + d, 54, "k")
    poly(c, [(10, 16), (30, 16), (34, 48), (6, 48)], "r")                                # the cloak's red lining
    poly(c, [(13, 16), (27, 16), (28, 46), (12, 46)], "c")
    c.rect(18, 16, 22, 24, "w")
    c.rect(15, 5, 25, 14, "s"); c.px(18, 9, "g"); c.px(22, 9, "g"); c.row(12, 18, 22, "S")
    c.rect(14, 2, 26, 6, "h")
    poly(c, [(10, 14), (16, 18), (10, 20)], "c"); poly(c, [(30, 14), (24, 18), (30, 20)], "c")   # high collar


RUTHVEN_PAL = {"o": "#0a080c", "k": "#141018", "c": "#1e1a24", "r": "#7a1420", "w": "#e8e4dc", "s": "#d8d4d0",
               "S": "#a8a4a0", "g": "#9aa0a8", "h": "#3a2a1a"}


def carmilla(cat):
    """Carmilla (Le Fanu, 1872): Mircalla, Countess Karnstein, slender and lovely, with long thick brown hair, in a
    pale gown; at night "a sooty-black animal that resembled a monstrous cat"."""
    def draw(c, step):
        if cat:
            ellipse(c, 26, 32, 18, 8, "k")
            for k, d in enumerate((-step, step, step, -step)):
                c.rect(12 + k * 9 + d, 36, 14 + k * 9 + d, 48, "K")
            ellipse(c, 44, 24, 8, 7, "k"); c.px(41, 23, "y"); c.px(47, 23, "y")
            poly(c, [(38, 18), (39, 12), (42, 17)], "k"); poly(c, [(46, 17), (49, 12), (50, 18)], "k")
            for k in range(10):
                c.px(8 - k // 3, 30 - k, "k"); c.px(9 - k // 3, 30 - k, "k")             # the tail, raised
            return
        for k, d in enumerate((-step, step)):
            c.rect(17 + k * 5 + d, 50, 19 + k * 5 + d, 54, "k")
        poly(c, [(15, 18), (27, 18), (32, 52), (10, 52)], "w")
        c.rect(16, 18, 26, 24, "W")
        c.rect(16, 6, 25, 16, "s"); c.px(19, 10, "e"); c.px(23, 10, "e"); c.px(21, 14, "r")
        c.rect(14, 3, 27, 7, "h"); c.rect(13, 6, 15, 28, "h"); c.rect(26, 6, 28, 28, "h")   # long brown hair
    return draw


CARMILLA_PAL = {"o": "#0a080c", "k": "#141016", "K": "#0a080c", "y": "#e8d040", "w": "#ece8f0", "W": "#c8c4d4",
                "s": "#f0dcd0", "e": "#4a3a5a", "r": "#b0202a", "h": "#5a3a22"}


if __name__ == "__main__":
    def doc(text):
        return " ".join(text.split()) + " Built by tools/art/build_gothic.py."
    walk = [0, 1, 2, 3, 4]
    kit.build_boss("ker", ker, KER_PAL, doc(ker.__doc__), (20, 20), (10, 19), walk, folder="enemies")
    kit.build_boss("hunt_hound", hunt_hound, HOUND_PAL, doc(hunt_hound.__doc__), (24, 16), (11, 15), walk, folder="enemies")
    kit.build_boss("empusa", empusa("woman"), EMPUSA_PAL, doc(empusa.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    for shape in ("bull", "dog"):
        kit.build_boss("empusa_" + shape, empusa(shape), EMPUSA_PAL, doc(empusa.__doc__ + " Here, as a %s." % shape),
                       (52, 56), (24, 54), [0, 1, 0, -1, 0])
    kit.build_boss("eurynomos", eurynomos, EURY_PAL, doc(eurynomos.__doc__), (52, 54), (26, 52), [0, 1, 0, -1, 0])
    kit.build_boss("wild_hunt", wild_hunt, HUNT_PAL, doc(wild_hunt.__doc__), (70, 56), (34, 54), [0, 1, 0, -1, 0])
    kit.build_boss("revenant", revenant, REVENANT_PAL, doc(revenant.__doc__), (20, 24), (10, 23), walk, folder="enemies")
    for bat in ("night_bat", "night_bat_flyer"):
        kit.build_boss(bat, night_bat, BAT_PAL, doc(night_bat.__doc__), (18, 12), (9, 11), walk, folder="enemies")
    kit.build_boss("varney", varney, VARNEY_PAL, doc(varney.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("ruthven", ruthven, RUTHVEN_PAL, doc(ruthven.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("carmilla", carmilla(False), CARMILLA_PAL, doc(carmilla.__doc__), (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("carmilla_cat", carmilla(True), CARMILLA_PAL, doc(carmilla.__doc__ + " Here, as the cat."), (56, 50),
                   (26, 48), [0, 1, 0, -1, 0])
    print("wrote Gothic Night's art")
