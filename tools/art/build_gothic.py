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


# --- Ossory (Gerald of Wales c. 1188; Marie de France, Bisclavret; the Lai de Melion; the Beast of Gevaudan 1764-67) --

def werewolf(c, f):
    """A werewolf of Ossory (Gerald of Wales, Topographia Hibernica II.19): a man and a woman of Ossory forced to take
    the shape of wolves; a hulking grey wolf-shape that walks upright, with a man's hands."""
    s = STEP[f]
    for x, d in ((8, -s), (14, s)):
        c.rect(x + d, 20, x + 2 + d, 27, "G")
    ellipse(c, 12, 15, 7, 7, "g")
    poly(c, [(8, 6), (17, 6), (20, 10), (6, 10)], "g"); poly(c, [(15, 8), (22, 9), (21, 12), (16, 11)], "g")
    c.px(9, 4, "g"); c.px(15, 4, "g"); c.px(17, 8, "y"); c.row(11, 19, 21, "w")
    c.rect(3, 12, 5, 19, "G"); c.rect(19, 12, 21, 19, "G"); c.px(3, 20, "s"); c.px(21, 20, "s")


WEREWOLF_PAL = {"o": "#141210", "g": "#6a645a", "G": "#4a463e", "y": "#e8c040", "w": "#ece6d8", "s": "#c8a888"}


def raven(c, f):
    """A raven over the Irish forest: a big black raven, wings spread."""
    up = f % 2
    poly(c, [(9, 7), (1, 3 if up else 10), (5, 9)], "k"); poly(c, [(11, 7), (19, 3 if up else 10), (15, 9)], "k")
    ellipse(c, 10, 8, 3, 3, "b"); poly(c, [(12, 6), (15, 7), (12, 8)], "K"); c.px(11, 7, "w")
    poly(c, [(8, 10), (12, 10), (10, 14)], "k")


RAVEN_PAL = {"o": "#2a2a34", "k": "#141418", "b": "#1e1e26", "K": "#3a3a44", "w": "#c8c8d0"}


def bisclavret(man):
    """Bisclavret (Marie de France, 12th c.): a Breton baron who becomes a wolf in the woods three days a week; when his
    wife hides his clothes he must stay a wolf, until the king gives them back. As a great gentle grey wolf, and as the
    baron once more."""
    def draw(c, step):
        if man:
            for k, d in enumerate((-step, step)):
                c.rect(15 + k * 6 + d, 44, 17 + k * 6 + d, 54, "B")
            poly(c, [(13, 18), (27, 18), (29, 46), (11, 46)], "r")
            c.row(30, 12, 28, "y")
            c.rect(15, 6, 25, 16, "s"); c.px(18, 10, "k"); c.px(22, 10, "k")
            c.rect(14, 3, 26, 7, "h"); c.rect(16, 14, 24, 17, "h")
            c.rect(8, 20, 11, 36, "r"); c.rect(29, 20, 32, 36, "r")
            return
        ellipse(c, 24, 30, 16, 8, "g")
        for k, d in enumerate((-step, step, step, -step)):
            c.rect(11 + k * 8 + d, 34, 13 + k * 8 + d, 48, "G")
        poly(c, [(36, 20), (48, 22), (48, 28), (36, 30)], "g"); c.px(41, 22, "y")
        c.px(37, 17, "g"); c.px(38, 16, "g"); c.px(40, 18, "g"); c.row(28, 44, 48, "k")
        for k in range(8):
            c.px(8 - k // 2, 28 + k // 3, "G")
    return draw


BISCLAVRET_PAL = {"o": "#141210", "g": "#8a8a90", "G": "#64646a", "y": "#e8d040", "k": "#1a1414", "r": "#3a5a8a",
                  "B": "#3a2a1a", "s": "#e0b890", "h": "#6a4a2a"}


def melion(c, step):
    """Melion (the Lai de Melion, 13th c.): a knight of Arthur's turned into a wolf by a ring with a white and a red
    stone, left so by his faithless wife, who led a pack of wolves through Ireland. A big dark wolf, a gold ring still
    on its foreleg."""
    ellipse(c, 26, 28, 18, 9, "g")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 9 + d, 33, 15 + k * 9 + d, 48, "G")
    c.rect(39, 40, 42, 41, "y"); c.px(40, 39, "w"); c.px(41, 39, "r")                     # the ring and its two stones
    poly(c, [(40, 16), (54, 18), (54, 25), (40, 27)], "g"); c.px(46, 19, "y")
    c.px(41, 12, "g"); c.px(42, 11, "g"); c.px(44, 13, "g"); c.row(24, 50, 54, "k")
    for k in range(10):
        c.px(8 - k // 2, 26 + k // 3, "G")


MELION_PAL = {"o": "#0e0c0a", "g": "#4a4440", "G": "#34302c", "y": "#e8c040", "w": "#f0f0f0", "r": "#c83030",
              "k": "#1a1010"}


def gevaudan(c, step):
    """The Beast of Gevaudan (French newspapers of 1764-67): a huge wolf-like beast, bigger than a calf, reddish, with a
    black stripe down its back, a wide chest, a long tail and great teeth."""
    ellipse(c, 30, 30, 22, 11, "r")
    for x in range(14, 48):
        c.px(x, 20 + abs(x - 30) // 8, "k")                                              # the black stripe
    ellipse(c, 44, 34, 8, 8, "R")                                                         # the wide chest
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(12 + k * 11 + d, 38, 16 + k * 11 + d, 54, "R")
    poly(c, [(48, 18), (66, 22), (66, 32), (48, 32)], "r"); c.px(55, 22, "y")
    c.rect(58, 29, 66, 32, "k")
    for x in range(58, 66, 2):
        c.px(x, 29, "w")
    c.px(50, 14, "r"); c.px(51, 13, "r"); c.px(53, 15, "r")
    for k in range(14):
        c.px(8 - k // 2, 28 + k // 2, "r")                                               # the long tail


GEVAUDAN_PAL = {"o": "#120804", "r": "#8a4a2a", "R": "#6a3418", "k": "#1a0e08", "y": "#f0c040", "w": "#f0ece0"}


# --- The Brocken (Goethe, Faust I 1808: Walpurgis Night; Praetorius 1668; Silberschlag 1780; Black Annis) ------------

def witch(c, f):
    """A witch of Walpurgis Night (Goethe, Faust I; Praetorius, Blockes-Berges Verrichtung, 1668): an old woman riding
    a broomstick up the Brocken."""
    s = STEP[f]
    c.row(15 + s, 0, 20, "b"); c.rect(0, 13 + s, 3, 17 + s, "y")                          # the broom
    poly(c, [(7, 6 + s), (14, 6 + s), (15, 15 + s), (6, 15 + s)], "k")
    ellipse(c, 11, 4 + s, 2.5, 2.5, "g"); c.px(12, 4 + s, "y")
    poly(c, [(8, 2 + s), (11, -4 + s), (14, 2 + s)], "k"); c.row(2 + s, 7, 15, "k")        # pointed hat


WITCH_PAL = {"o": "#0e0a10", "k": "#24182a", "g": "#9aaa7a", "y": "#d8b040", "b": "#6a4a2a"}


def black_goat(c, f):
    """A black goat of the witches' ride (Praetorius; Faust: they ride up on goats): a shaggy black goat, horns curled
    back."""
    s = STEP[f]
    ellipse(c, 10, 9, 7, 4, "k")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(4 + k * 4 + d, 12, 4 + k * 4 + d, 16, "K")
    poly(c, [(15, 4), (20, 6), (20, 9), (15, 9)], "k"); c.px(17, 6, "y")
    c.px(15, 2, "h"); c.px(14, 1, "h"); c.px(13, 2, "h"); c.px(19, 10, "k"); c.px(19, 11, "k")


GOAT_PAL = {"o": "#2a2830", "k": "#1a181e", "K": "#100e14", "y": "#e8c040", "h": "#a89c88"}


def brocken_spectre(c, step):
    """The Brocken Spectre (Johann Silberschlag, 1780): the giant shadow a climber casts on the mist below the summit,
    huge and dim, a ring of coloured light round its head."""
    for k, d in enumerate((-step, step)):
        c.rect(18 + k * 12 + d, 50, 22 + k * 12 + d, 66, "s")
    poly(c, [(16, 18), (40, 18), (44, 52), (12, 52)], "s")
    ellipse(c, 28, 10, 7, 8, "s")
    c.rect(6, 20, 12, 44, "s"); c.rect(44, 20, 50, 44, "s")
    for y in range(4, 66, 3):
        for x in range(4, 54, 5):
            if (x + y) % 2 and c.g[y][x] == "s":
                c.px(x, y, "m")                                                          # the mist through it


SPECTRE_PAL = {"o": "#3a3e4a", "s": "#4a505e", "m": "#9aa2b4"}


def baubo(c, step):
    """Baubo (Goethe, Faust I, Walpurgis Night: "Old Baubo comes alone; she rides a farrow sow"): an old witch riding a
    great sow up the mountain."""
    ellipse(c, 28, 38, 18, 9, "p")
    for k, d in enumerate((-step, step, step, -step)):
        c.rect(14 + k * 9 + d, 44, 17 + k * 9 + d, 54, "P")
    ellipse(c, 46, 36, 6, 6, "p"); c.rect(50, 36, 54, 39, "P"); c.px(52, 37, "k"); c.px(45, 33, "k")
    poly(c, [(42, 30), (44, 26), (46, 30)], "p"); c.px(10, 34, "p"); c.px(9, 33, "p")
    poly(c, [(20, 14), (32, 14), (34, 32), (18, 32)], "k")                                  # the old witch
    ellipse(c, 26, 10, 4, 4, "g"); c.px(28, 10, "y")
    poly(c, [(21, 8), (26, 0), (31, 8)], "k"); c.row(8, 20, 32, "k")
    c.rect(32, 20, 36, 22, "g")


BAUBO_PAL = {"o": "#120c10", "p": "#c8907a", "P": "#a06a58", "k": "#2a1e2a", "g": "#9aaa7a", "y": "#d8b040"}


def black_annis(c, step):
    """Black Annis (Leicestershire folklore): a hag with a blue face and long iron claws, who dug her bower in the Dane
    Hills with her claws."""
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 6 + d, 46, 18 + k * 6 + d, 54, "k")
    poly(c, [(12, 18), (30, 18), (34, 48), (8, 48)], "k")
    c.rect(16, 6, 26, 16, "b"); c.px(19, 10, "y"); c.px(23, 10, "y"); c.row(14, 18, 24, "K")
    c.rect(14, 3, 28, 7, "h"); c.rect(13, 6, 15, 26, "h"); c.rect(27, 6, 29, 26, "h")       # wild grey hair
    c.rect(4, 22, 9, 30, "b"); c.rect(33, 22, 38, 30, "b")
    for k in range(4):
        c.rect(2 + k * 2, 31, 2 + k * 2, 37, "i"); c.rect(32 + k * 2, 31, 32 + k * 2, 37, "i")   # iron claws


ANNIS_PAL = {"o": "#08080c", "k": "#1e1a20", "K": "#0e0c10", "b": "#3a5ab0", "y": "#f0e040", "h": "#a8a8a8",
             "i": "#8a9098"}


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
    kit.build_boss("werewolf", werewolf, WEREWOLF_PAL, doc(werewolf.__doc__), (24, 28), (12, 27), walk, folder="enemies")
    kit.build_boss("raven", raven, RAVEN_PAL, doc(raven.__doc__), (20, 16), (10, 15), walk, folder="enemies")
    kit.build_boss("bisclavret", bisclavret(False), BISCLAVRET_PAL, doc(bisclavret.__doc__), (52, 50), (24, 48), [0, 1, 0, -1, 0])
    kit.build_boss("bisclavret_man", bisclavret(True), BISCLAVRET_PAL, doc(bisclavret.__doc__ + " Here, a man again."),
                   (40, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("melion", melion, MELION_PAL, doc(melion.__doc__), (58, 50), (28, 48), [0, 1, 0, -1, 0])
    kit.build_boss("gevaudan", gevaudan, GEVAUDAN_PAL, doc(gevaudan.__doc__), (70, 56), (34, 54), [0, 1, 0, -1, 0])
    kit.build_boss("witch", witch, WITCH_PAL, doc(witch.__doc__), (22, 20), (11, 19), walk, folder="enemies")
    kit.build_boss("black_goat", black_goat, GOAT_PAL, doc(black_goat.__doc__), (22, 18), (11, 17), walk, folder="enemies")
    kit.build_boss("brocken_spectre", brocken_spectre, SPECTRE_PAL, doc(brocken_spectre.__doc__), (56, 68), (28, 66), [0, 1, 0, -1, 0])
    kit.build_boss("baubo", baubo, BAUBO_PAL, doc(baubo.__doc__), (58, 56), (28, 54), [0, 1, 0, -1, 0])
    kit.build_boss("black_annis", black_annis, ANNIS_PAL, doc(black_annis.__doc__), (42, 56), (21, 54), [0, 1, 0, -1, 0])
    print("wrote Gothic Night's art")
