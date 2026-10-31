# The enemies of Midgard's Edge, the Two Lands and the Misty Isles, plus the placeholders and the god's trial
# avatar (docs/ART_RULES.md: Enemies). Run: python3 build_enemies_rest.py from tools/art/ (after
# build_boss_loki.py, whose picture Loki's illusions copy). Writes data/art/enemies/<enemy id>.json.
import json, math, os
import hero_kit as kit
from hero_kit import ellipse, poly
from build_enemies_aegean import legs2, STEP, BOB, FLAP, build

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art")
TAG = " Built by tools/art/build_enemies_rest.py."


def line(c, a, b, col):
    (ax, ay), (bx, by) = a, b
    n = max(abs(bx - ax), abs(by - ay), 1)
    for i in range(n + 1):
        c.px(round(ax + (bx - ax) * i / n), round(ay + (by - ay) * i / n), col)


def flame(c, x, y, h, w, f):
    for col, k in (("q", 1.0), ("f", 0.68), ("F", 0.36)):
        hh = h * k
        for yy in range(int(y - hh), y + 1):
            t = min((y - yy) / max(hh, 1), 1.0)
            half = w * k * (1 - t) ** 0.8 + 0.3
            cx = x + math.sin(t * 4 + f) * 0.9
            for xx in range(int(cx - half) - 1, int(cx + half) + 2):
                if abs(xx - cx) <= half:
                    c.px(xx, yy, col)


# --- Midgard's Edge (Norse) -------------------------------------------------------------------------------------

def draugr(c, f, big=False):
    """A draugr, the walking dead of the sagas (Grettis saga 32-35: Glámr, huge and 'blue as hel'): a swollen,
    dark-blue corpse in a rotted tunic, its eyes glowing, arms reaching; the brute carries a rusted sword."""
    k = 1.5 if big else 1.0
    s = STEP[f]
    def S(v):
        return round(v * k)
    legs2(c, S(5), S(15), S(6), s, "d", "D", "k", gap=S(3), w=S(2))
    c.rect(S(3), S(8), S(10), S(15), "t"); c.rect(S(3), S(8), S(4), S(15), "T")      # rotted tunic
    for x in range(S(3), S(11), 2):
        c.px(x, S(15), "T")
    c.rect(S(10), S(8), S(14), S(9) + 1, "d")                                          # arm reaching
    ellipse(c, S(7), S(4), S(3.5), S(3.8), "d"); c.rect(S(4), S(1), S(7), S(3), "h")    # head, lank hair
    c.px(S(9), S(4), "e"); c.px(S(9) + 1, S(4), "e")                                   # glowing eyes
    c.row(S(6), S(7), S(9), "D")
    if big:
        line(c, (S(14), S(9)), (S(16), 0), "r"); line(c, (S(14) + 1, S(9)), (S(16) + 1, 0), "R")
        c.rect(S(13), S(9), S(15), S(10), "k")


DRAUGR_PAL = {"o": "#1a1820", "k": "#141018", "d": "#4a5a7a", "D": "#2e3a54", "t": "#5a5244", "T": "#3a342a",
              "h": "#2a2a2e", "e": "#a8f0ff", "r": "#8a6a5a", "R": "#5a4038"}


def frost_giant(c, f, caster=False):
    """A frost giant, a hrímþurs (Gylfaginning 5-8: the giants born of Ymir, of the rime-cold of Niflheim): pale
    icy-blue skin, a beard and hair of icicles, furs; the caster holds up a shard of ice."""
    s = STEP[f]
    legs2(c, 6, 18, 8, s, "s", "S", "k", gap=4, w=3)
    c.rect(4, 10, 14, 18, "f"); c.rect(4, 10, 5, 18, "F"); c.row(18, 4, 14, "w")       # furs
    ellipse(c, 10, 5, 4, 4.5, "s"); c.px(12, 4, "k"); c.px(13, 5, "s")
    for x in range(6, 13, 2):                                                          # icicle beard and hair
        c.rect(x, 7, x, 10 + (x % 3), "i"); c.px(x, 1, "i"); c.px(x, 0, "I")
    c.rect(6, 1, 12, 2, "I")
    c.rect(13, 11, 16, 12, "s")
    if caster:
        poly(c, [(16, 2 + f % 2), (19, 6), (17, 11), (15, 7)], "i"); c.px(17, 6, "w")
        c.rect(15, 11, 17, 13, "s")


FROST_PAL = {"o": "#1e2430", "k": "#141820", "s": "#a8c8e0", "S": "#7a98b4", "f": "#c8c0b0", "F": "#9a9282",
             "w": "#f0f4f8", "i": "#d8f0ff", "I": "#88b8d8"}


def spark(c, f, big=False):
    """A spark of Muspell (Gylfaginning 4-5: the burning land whose sparks the gods set in the sky; 51: its sons
    ride out at Ragnarok): a living flame."""
    w, h = (12, 16) if big else (10, 12)
    flame(c, w // 2, h - 2 + BOB[f] // 2, h - 3, 4.2 if big else 3.4, f)
    c.px(w // 2 - 1, h - 6, "k"); c.px(w // 2 + 1, h - 6, "k")


SPARK_PAL = {"o": "#3a1408", "k": "#3a1408", "q": "#c83018", "f": "#ff9030", "F": "#ffe070"}


def troll(c, f, elite=False):
    """A troll of the Norse giants' kind (Alvíssmál: caught by the sunrise they turn to stone; Skáldskaparmál:
    Thor's battles): a hulking, long-nosed, mossy grey-skinned brute with a club; the elite is part stone already."""
    k = 1.45 if elite else 1.0
    def S(v):
        return round(v * k)
    s = STEP[f]
    legs2(c, S(7), S(22), S(7), s, "s", "S", "k", gap=S(5), w=S(3))
    ellipse(c, S(11), S(17), S(8), S(7), "s"); c.rect(S(4), S(13), S(7), S(22), "S")   # a hunched bulk
    c.rect(S(5), S(20), S(17), S(23), "l"); c.row(S(23), S(5), S(17), "L")             # hide loincloth
    ellipse(c, S(14), S(7), S(5), S(5), "s"); c.rect(S(9), S(2), S(15), S(4), "m")      # head, moss
    poly(c, [(S(17), S(6)), (S(23), S(10)), (S(18), S(10))], "s")                       # a great long nose
    c.px(S(16), S(6), "k"); c.row(S(11), S(15), S(18), "S")
    for x, y in [(S(7), S(14)), (S(12), S(19)), (S(15), S(15))]:
        c.px(x, y, "m")
    if elite:
        for x, y in [(S(6), S(16)), (S(9), S(12)), (S(13), S(21)), (S(16), S(9))]:
            c.rect(x, y, x + 2, y + 1, "g"); c.px(x, y, "G")                              # turning to stone
    c.rect(S(17), S(14), S(20), S(16), "s")
    for y in range(0, S(16)):
        x = S(22) - y // 5
        c.rect(x, y, x + (2 if y < S(6) else 0), y, "c")


TROLL_PAL = {"o": "#1e2018", "k": "#141410", "s": "#8a9478", "S": "#626a54", "m": "#5a7a3a", "l": "#6a4a2a",
             "L": "#4a3018", "c": "#6a4a2a", "g": "#9a9a9a", "G": "#6a6a6a"}


def wolf(c, f):
    """A wolf of the Ironwood (Gylfaginning 12: the troll-wife who bears wolves in the Ironwood; 34: Fenrir's kin):
    a lean dark-grey wolf, ears back, running."""
    s = STEP[f]
    for k, x in enumerate((4, 7, 14, 17)):
        d = s if k % 2 == 0 else -s
        c.rect(x + d, 9, x + d, 13, "W" if k in (0, 2) else "w"); c.px(x + d + 1, 13, "W")
    ellipse(c, 11, 8, 7, 3, "w"); c.row(5, 6, 15, "W")
    poly(c, [(4, 7), (0, 10), (1, 11), (5, 9)], "w")                                   # tail
    ellipse(c, 18, 6, 3, 2.5, "w"); poly(c, [(19, 5), (24, 6), (23, 8), (19, 8)], "w")
    poly(c, [(16, 4), (17, 1), (18, 4)], "W"); c.px(19, 5, "y"); c.px(24, 6, "k")


WOLF_PAL = {"o": "#18161a", "k": "#141014", "w": "#6a6a74", "W": "#3e3e48", "y": "#e8c040"}


# --- The Two Lands (Egyptian) -------------------------------------------------------------------------------------

def scarab(c, f):
    """A scarab beetle (Book of the Dead 30B, the heart scarab; Khepri, the scarab who rolls the rising sun): a
    blue-green shining beetle, legs scuttling."""
    for k, x in enumerate((3, 5, 7)):
        d = STEP[f] * (1 if k % 2 else -1)
        c.px(x + d, 8, "k"); c.px(x + d, 9, "k")
    ellipse(c, 5.5, 5, 4.5, 3.5, "b"); c.row(3, 3, 7, "B"); c.px(5, 2, "w")             # shell, gleam
    c.rect(9, 4, 10, 6, "b"); c.px(11, 3, "k"); c.px(11, 7, "k")                        # head, antennae
    c.col_ = None
    for y in range(2, 9):
        c.px(5, y, "B")


SCARAB_PAL = {"o": "#10141a", "k": "#141018", "b": "#2a7a8a", "B": "#1a4a5a", "w": "#a8f0f0"}


def mummy(c, f):
    """A restless dead man (the ghost of Khonsuemheb's story; the Book of the Dead), wrapped in linen bandages,
    arms out, eyes glowing in the dark between the wrappings."""
    s = STEP[f]
    legs2(c, 5, 16, 6, s, "l", "L", "L", gap=3)
    c.rect(4, 7, 11, 16, "l"); c.rect(4, 7, 5, 16, "L")
    for y in range(8, 17, 2):
        c.row(y, 6, 11, "L")                                                           # bandage wraps
    ellipse(c, 8, 4, 3.5, 3.5, "l"); c.row(2, 6, 10, "L"); c.row(5, 6, 10, "L")
    c.px(9, 4, "e"); c.px(10, 4, "e")
    c.rect(11, 8, 15, 9, "l"); c.px(13, 9, "L")
    c.px(3, 15, "l"); c.px(2, 16, "l")                                                 # a trailing strip


MUMMY_PAL = {"o": "#24160e", "k": "#140c08", "l": "#d8ccb0", "L": "#a89a7a", "e": "#a8f0a0"}


def shabti(c, f):
    """A shabti (Book of the Dead, spell 6: the figure that answers 'here I am' and does the field work for the
    dead): a mummy-shaped figure of blue faience, a striped wig, arms crossed holding hoes, a band of writing down
    its front; it shuffles on its square base."""
    b = BOB[f] // 2
    c.rect(4, 26 + b, 15, 29 + b, "B")                                                 # base
    poly(c, [(5, 10 + b), (14, 10 + b), (13, 26 + b), (6, 26 + b)], "b")               # mummy-shaped body
    c.rect(5, 10 + b, 6, 25 + b, "B")
    ellipse(c, 10, 5 + b, 4.5, 5, "h"); c.rect(9, 2 + b, 13, 8 + b, "b")                # wig, face
    for y in range(1, 11, 2):
        c.row(y + b, 5, 8, "H")
    c.px(12, 5 + b, "k"); c.row(7 + b, 11, 13, "B")
    c.rect(6, 13 + b, 13, 14 + b, "s"); c.rect(6, 15 + b, 13, 15 + b, "B")             # crossed arms
    c.px(7, 12 + b, "y"); c.px(12, 12 + b, "y")                                         # hoes in each hand
    c.rect(9, 17 + b, 10, 25 + b, "y")
    for y in range(18, 25, 2):
        c.px(9, y + b, "k"); c.px(10, y + 1 + b, "k")                                   # a band of writing


SHABTI_PAL = {"o": "#10141a", "k": "#141018", "b": "#3a9ab8", "B": "#226a88", "h": "#1e2a48", "H": "#3a4a78",
              "s": "#48b0c8", "y": "#e0c060"}


def cobra(c, f):
    """A serpent of the desert (Book of the Dead, spells 33-35 and 39, against snakes): a sandy cobra reared up,
    hood spread, swaying."""
    sway = BOB[f]
    for i in range(12):
        x = 3 + i; y = 15 - abs(math.sin(i / 3.0 + f * 0.6)) * 2
        c.rect(x, int(y), x, int(y) + 1, "s")
    for y in range(4, 15):
        x = 11 + round(math.sin((y + sway) / 3.0))
        c.rect(x - 1, y, x + 1, y, "s")
    poly(c, [(8, 4 + sway), (15, 4 + sway), (14, 10), (9, 10)], "s"); c.rect(10, 5 + sway, 13, 9, "S")   # hood
    ellipse(c, 12, 2 + sway, 2, 1.6, "s"); c.px(13, 2 + sway, "k"); c.px(14, 3 + sway, "r")


COBRA_PAL = {"o": "#2a1c10", "k": "#140c08", "s": "#c8a060", "S": "#8a6a38", "r": "#c83030"}


# --- The Misty Isles (Irish and Scottish) --------------------------------------------------------------------------

def redcap(c, f):
    """A redcap (Henderson, Folk-Lore of the Northern Counties, 1866): a short, thickset old man with long
    prominent teeth, skinny fingers with talons, large red eyes, grisly grey hair, a red cap dyed in blood, iron
    boots, and a pikestaff in his left hand."""
    s = STEP[f]
    legs2(c, 5, 15, 5, s, "t", "T", "i", gap=3)
    c.rect(4, 15, 11, 16, "i")                                                         # iron boots (feet)
    c.rect(3, 8, 11, 15, "t"); c.rect(3, 8, 4, 15, "T")
    ellipse(c, 8, 5, 3.5, 3.5, "s"); c.rect(4, 3, 6, 7, "h")                            # grey hair
    c.rect(5, 0, 11, 2, "r"); c.px(4, 2, "r"); c.px(12, 1, "R")                         # the red cap
    c.px(10, 4, "e"); c.px(10, 6, "w"); c.px(11, 6, "w"); c.px(10, 7, "w")              # red eye, long teeth
    c.rect(11, 9, 13, 10, "s"); c.px(14, 9, "w"); c.px(14, 11, "w")                     # talons
    for y in range(0, 17):
        c.px(1, y, "c")
    c.rect(0, 0, 2, 1, "i")                                                             # the pikestaff


REDCAP_PAL = {"o": "#24160e", "k": "#140c08", "s": "#c8a88a", "t": "#5a4a3a", "T": "#3a3026", "h": "#9a9a9a",
              "r": "#b81c1c", "R": "#7a1010", "e": "#e83030", "w": "#efe6d2", "i": "#6a6e78", "c": "#7a5030"}


def sluagh(c, f, spread=False):
    """The sluagh, the host of the dead (Carmichael, Carmina Gadelica, vol. 2): spirits flying in dark flocks like
    starlings: a ragged dark winged shape with a pale, hollow face."""
    flap = FLAP[f]
    w = 9 if spread else 6
    cx = 8 if spread else 7
    poly(c, [(cx, 6), (cx - w, 2 + flap), (cx - w + 2, 7 + flap), (cx - 1, 9)], "d")
    poly(c, [(cx, 6), (cx + w, 2 + flap), (cx + w - 2, 7 + flap), (cx + 1, 9)], "D")
    for k in range(3):
        c.px(cx - w + 1 + k * 2, 7 + flap + (k % 2), "d"); c.px(cx + w - 1 - k * 2, 7 + flap + (k % 2), "D")
    ellipse(c, cx, 8, 2.5, 3, "d"); ellipse(c, cx + 1, 5, 2, 2, "p")
    c.px(cx + 1, 5, "k"); c.px(cx + 2, 5, "k")


SLUAGH_PAL = {"o": "#120e16", "k": "#100c14", "d": "#3a3248", "D": "#262032", "p": "#c8c4d8"}


def kelpie(c, f):
    """A kelpie (Gregor, Folk-Lore of the North-East of Scotland; Burns, Address to the Deil), the water-horse of
    rivers and lochs: a grey horse, its mane wet and tangled with water-weed, dripping."""
    s = STEP[f]
    for k, x in enumerate((5, 8, 16, 19)):
        d = s if k % 2 == 0 else -s
        c.rect(x + d, 13, x + 1 + d, 19, "G" if k in (0, 2) else "g"); c.rect(x + d, 19, x + 2 + d, 20, "k")
    ellipse(c, 12, 11, 9, 4.5, "g"); c.row(7, 6, 18, "w")
    poly(c, [(3, 9), (0, 15), (2, 15), (4, 11)], "m")                                   # weedy tail
    poly(c, [(17, 9), (21, 2), (25, 3), (21, 10)], "g")                                 # neck
    poly(c, [(21, 2), (26, 3), (27, 6), (24, 6)], "g"); c.px(26, 5, "k"); c.px(23, 3, "k")
    for y in range(2, 10):
        c.px(19 - (y - 2) // 3, y, "m"); c.px(20 - (y - 2) // 3, y + 1, "M")             # weed-tangled mane
    c.px(15, 16, "b"); c.px(9, 17 - f % 2, "b"); c.px(22, 12, "b")                      # drips


KELPIE_PAL = {"o": "#1a2020", "k": "#141818", "g": "#8a9aa0", "G": "#5e6e74", "w": "#b8c8cc", "m": "#3a6a4a",
              "M": "#2a4a34", "b": "#7ac0e0"}


def fomorian(c, f):
    """A Fomorian (Cath Maige Tuired; Lebor Gabála Érenn), the sea-raiders, later told of as misshapen: hunched,
    green-grey and seaweed-haired, one great eye, casting with a staff of driftwood topped with a sea-shell."""
    s = STEP[f]
    legs2(c, 5, 17, 6, s, "s", "S", "k", gap=3)
    poly(c, [(3, 8), (11, 7), (12, 17), (3, 17)], "t"); c.rect(3, 9, 4, 17, "T")
    ellipse(c, 9, 5, 4, 3.8, "s"); c.rect(4, 1, 8, 9, "m"); c.px(3, 6, "m"); c.px(3, 9, "M")   # seaweed hair
    ellipse(c, 10, 4, 1.6, 1.6, "w"); c.px(11, 4, "k")                                  # one great eye
    c.rect(11, 9, 14, 10, "s")
    for y in range(2, 22):
        c.px(15, y, "c")
    ellipse(c, 15, 1, 2, 1.6, "p"); c.px(14 + f % 2, 0, "b")                            # shell, glinting water


FOMOR_PAL = {"o": "#18201c", "k": "#101410", "s": "#7a9a84", "S": "#54705c", "t": "#3a4a5a", "T": "#26323e",
             "m": "#3a6a3a", "M": "#2a4a2a", "w": "#efe6d2", "c": "#8a7a5a", "p": "#e8c8b8", "b": "#7ac0e0"}


# --- Placeholders and the god's trial avatar ----------------------------------------------------------------------

def blob(c, f, w, h):
    """A plain test creature for the placeholder enemy types (not in any level): a dark rounded blob with eyes."""
    b = BOB[f]
    ellipse(c, w / 2, h / 2 + 1 + b / 2, w / 2 - 1, h / 2 - 1.5, "d"); c.row(h // 2 - 1, 2, w - 3, "D")
    c.px(w // 2, h // 2, "w"); c.px(w // 2 + 2, h // 2, "w")


BLOB_PAL = {"o": "#1a1a20", "d": "#5a6a7a", "D": "#3a4a5a", "w": "#efe6d2"}


def avatar(c, f):
    """A god's avatar in a duel trial, used only for a god without art (every Pack 1 god has art): a figure of
    golden light."""
    s = STEP[f]
    legs2(c, 9, 20, 8, s, "u", "U", "U", gap=4, w=3)
    c.rect(7, 9, 17, 20, "u"); c.rect(7, 9, 8, 20, "U")
    ellipse(c, 12, 5, 4, 4.5, "u"); c.px(14, 5, "w")
    for x, y in [(3, 6), (21, 8), (5, 18), (20, 17), (12, 0)]:
        c.px(x, y, "w")


AVATAR_PAL = {"o": "#4a3a10", "u": "#ffe080", "U": "#d8a838", "w": "#ffffff"}


if __name__ == "__main__":
    build("draugr", (16, 23), (7, 21), draugr, DRAUGR_PAL, "Draugr (GAME_DESIGN.md: Midgard's Edge enemies; art "
          "10/31/2026). " + draugr.__doc__ + TAG)
    build("draugr_brute", (26, 34), (11, 31), lambda c, f: draugr(c, f, True), DRAUGR_PAL, "Draugr brute "
          "(GAME_DESIGN.md: Midgard's Edge enemies; art 10/31/2026). " + draugr.__doc__ + TAG)
    build("frost_thursar", (18, 28), (8, 26), frost_giant, FROST_PAL, "Frost giant (GAME_DESIGN.md: Midgard's "
          "Edge enemies; art 10/31/2026). " + frost_giant.__doc__ + TAG)
    build("frost_thursar_caster", (21, 28), (8, 26), lambda c, f: frost_giant(c, f, True), FROST_PAL, "Frost giant "
          "caster (GAME_DESIGN.md: Midgard's Edge enemies; art 10/31/2026). " + frost_giant.__doc__ + TAG)
    build("muspel_spark", (10, 12), (5, 11), spark, SPARK_PAL, "Muspell spark (GAME_DESIGN.md: Midgard's Edge "
          "enemies; art 10/31/2026). " + spark.__doc__ + TAG)
    build("muspel_spark_bomber", (12, 16), (6, 15), lambda c, f: spark(c, f, True), SPARK_PAL, "Muspell spark, "
          "bomber (GAME_DESIGN.md: Midgard's Edge enemies; art 10/31/2026). " + spark.__doc__ + TAG)
    build("troll", (26, 32), (11, 30), troll, TROLL_PAL, "Troll (GAME_DESIGN.md: Midgard's Edge enemies; art "
          "10/31/2026). " + troll.__doc__ + TAG)
    build("troll_elite", (36, 46), (16, 43), lambda c, f: troll(c, f, True), TROLL_PAL, "Troll, elite "
          "(GAME_DESIGN.md: Midgard's Edge enemies; art 10/31/2026). " + troll.__doc__ + TAG)
    build("wolf", (26, 16), (12, 14), wolf, WOLF_PAL, "Wolf (GAME_DESIGN.md: Midgard's Edge enemies; art "
          "10/31/2026). " + wolf.__doc__ + TAG)
    build("scarab_swarm", (13, 11), (6, 9), scarab, SCARAB_PAL, "Scarab (GAME_DESIGN.md: The Two Lands enemies; "
          "art 10/31/2026). " + scarab.__doc__ + TAG)
    build("mummy", (17, 24), (7, 22), mummy, MUMMY_PAL, "Restless dead (GAME_DESIGN.md: The Two Lands enemies; art "
          "10/31/2026). " + mummy.__doc__ + TAG)
    build("shabti_guardian", (20, 31), (9, 29), shabti, SHABTI_PAL, "Shabti guardian (GAME_DESIGN.md: The Two "
          "Lands enemies; art 10/31/2026). " + shabti.__doc__ + TAG)
    build("sand_serpent", (17, 18), (9, 17), cobra, COBRA_PAL, "Sand serpent (GAME_DESIGN.md: The Two Lands "
          "enemies; art 10/31/2026). " + cobra.__doc__ + TAG)
    build("redcap", (16, 22), (7, 20), redcap, REDCAP_PAL, "Redcap (GAME_DESIGN.md: The Misty Isles enemies; art "
          "10/31/2026). " + redcap.__doc__ + TAG)
    build("sluagh", (15, 13), (7, 12), sluagh, SLUAGH_PAL, "Sluagh (GAME_DESIGN.md: The Misty Isles enemies; art "
          "10/31/2026). " + sluagh.__doc__ + TAG)
    build("sluagh_flyer", (19, 13), (8, 12), lambda c, f: sluagh(c, f, True), SLUAGH_PAL, "Sluagh, flyer "
          "(GAME_DESIGN.md: The Misty Isles enemies; art 10/31/2026). " + sluagh.__doc__ + TAG)
    build("kelpie", (29, 22), (13, 20), kelpie, KELPIE_PAL, "Kelpie (GAME_DESIGN.md: The Misty Isles enemies; art "
          "10/31/2026). " + kelpie.__doc__ + TAG)
    build("fomorian_caster", (19, 24), (7, 22), fomorian, FOMOR_PAL, "Fomorian caster (GAME_DESIGN.md: The Misty "
          "Isles enemies; art 10/31/2026). " + fomorian.__doc__ + TAG)
    build("placeholder_chaser", (16, 16), (8, 15), lambda c, f: blob(c, f, 16, 15), BLOB_PAL, "Placeholder enemy "
          "(tests and development only). " + blob.__doc__ + TAG)
    build("placeholder_swarm", (12, 12), (6, 11), lambda c, f: blob(c, f, 12, 11), BLOB_PAL, "Placeholder enemy "
          "(tests and development only). " + blob.__doc__ + TAG)
    build("trial_avatar", (24, 30), (11, 29), avatar, AVATAR_PAL, "Trial avatar. " + avatar.__doc__ + TAG)
    # Loki's illusions are copies of Loki, meant to fool the player: his boss picture.
    loki = json.load(open(os.path.join(ROOT, "bosses", "loki.json")))
    loki["_doc"] = ("Loki's illusion (GAME_DESIGN.md: Midgard's Edge bosses): a copy of Loki's own picture "
                    "(data/art/bosses/loki.json), so the player can't tell which is real." + TAG)
    with open(os.path.join(ROOT, "enemies", "loki_illusion.json"), "w") as out:
        json.dump(loki, out, indent=1)
    print("wrote data/art/enemies/loki_illusion.json")
