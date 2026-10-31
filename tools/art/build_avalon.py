# Avalon's Shadow's art (Pack 2, docs/PACK_2_PLAN.md; docs/ART_RULES.md): enemies (black knight, enchanted hound, afanc,
# will-o'-wisp, and the Hounds of Annwn for Arawn's summon), the bosses (the Green Knight, whole and headless; Mordred;
# Twrch Trwyth) and the gods Rhiannon and Arawn. Run: python3 build_avalon.py from tools/art/.
import math
import hero_kit as kit
from hero_kit import ellipse, poly

STEP = [0, -1, 0, 1, 0]
BOB = [0, -1, -2, -1, 0]


def horse(c, x0, y0, coat, coat_d, step, length=22):
    """A horse facing right from (x0, y0) (its back): a long level body, four legs stepping, an arched neck rising to a
    long head held forward, mane and tail."""
    ellipse(c, x0 + length // 2, y0 + 4, length // 2 + 1, 4, coat)
    ellipse(c, x0 + length // 2, y0 + 6, length // 2 - 1, 2.5, coat_d)                # belly shadow
    for k, d in enumerate((-step, step, step, -step)):
        x = x0 + 2 + k * (length - 4) // 3 + d
        c.rect(x, y0 + 7, x + 1, y0 + 16, coat_d if k % 2 == 0 else coat)
        c.rect(x, y0 + 16, x + 2, y0 + 16, "k")                                      # hooves
    nx = x0 + length - 3
    poly(c, [(nx - 2, y0 + 3), (nx + 2, y0 - 7), (nx + 6, y0 - 6), (nx + 3, y0 + 4)], coat)   # arched neck
    poly(c, [(nx + 2, y0 - 8), (nx + 11, y0 - 5), (nx + 11, y0 - 2), (nx + 4, y0 - 3)], coat)  # long head
    c.px(nx + 5, y0 - 6, "k"); c.px(nx + 11, y0 - 3, "k")
    c.rect(nx + 1, y0 - 9, nx + 2, y0 - 7, coat_d)                                   # ear
    for k in range(4):
        c.px(nx - 1 + k, y0 - 4 - k * 1, coat_d)                                     # mane
    c.rect(x0 - 2, y0 + 2, x0, y0 + 11, coat_d)                                      # tail


def rider(c, x, y, armour, armour_d, cloak=None):
    """An armoured rider sitting a horse: helm, body, a leg down the horse's side, a lance or arm forward."""
    if cloak:
        poly(c, [(x - 3, y + 1), (x + 1, y + 1), (x - 1, y + 12), (x - 5, y + 11)], cloak)
    c.rect(x - 1, y, x + 4, y + 9, armour); c.rect(x - 1, y, x, y + 9, armour_d)
    c.rect(x, y - 6, x + 4, y - 1, armour); c.rect(x + 2, y - 4, x + 4, y - 4, "k")   # great helm, eye slit
    c.rect(x + 1, y + 9, x + 3, y + 14, armour_d)


# --- Black knight (Malory) ---------------------------------------------------------------------------------------

def black_knight(c, f):
    horse(c, 4, 19, "h", "H", STEP[f])
    rider(c, 14, 12, "a", "A")
    for x in range(18, 34):                                                         # couched lance
        c.px(x, 15, "w")
    c.px(34, 15, "i")


KNIGHT_PAL = {"o": "#140c08", "k": "#0a0604", "h": "#2a2622", "H": "#1a1614", "a": "#3a3a42", "A": "#24242a",
              "w": "#7a5a3a", "i": "#c8ccd4"}


# --- Hounds -------------------------------------------------------------------------------------------------------

def hound(c, f, coat, coat_d, ear=None):
    s = STEP[f]
    ellipse(c, 10, 9, 7, 3.5, coat)
    for k, d in enumerate((-s, s, s, -s)):
        x = 5 + k * 3 + d
        c.rect(x, 11, x + 1, 16, coat_d if k % 2 == 0 else coat)
    poly(c, [(15, 7), (19, 4), (22, 6), (18, 10)], coat)                            # head and long muzzle
    c.px(19, 5, "k"); c.px(22, 7, "k")
    poly(c, [(16, 5), (14, 4), (16, 7)], ear or coat_d)                             # ear laid back
    c.rect(1, 7, 3, 8, coat_d)                                                      # tail


HOUND_PAL = {"o": "#140c08", "k": "#0a0604", "g": "#7a7068", "G": "#5a524c"}
ANNWN_PAL = {"o": "#2a1c18", "k": "#140c08", "g": "#f2f0ea", "G": "#cfcac0", "r": "#c02a2a"}


# --- Afanc (Welsh lake beast) and will-o'-wisp ------------------------------------------------------------------

def afanc(c, f):
    s = STEP[f]
    ellipse(c, 13, 11, 10, 5, "d")
    ellipse(c, 13, 13, 8, 3, "D")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(5 + k * 5 + d, 15, 6 + k * 5 + d, 18, "D")
    poly(c, [(21, 8), (28, 9), (28, 13), (21, 14)], "d"); c.row(12, 23, 28, "k")   # broad flat head and jaws
    c.px(23, 9, "y")
    for x in range(6, 20, 3):
        c.px(x, 7, "q")                                                             # ridged back
    poly(c, [(3, 10), (0, 7), (0, 13)], "D")                                        # flat tail


AFANC_PAL = {"o": "#10140c", "k": "#080a06", "d": "#3e5a3a", "D": "#2a3e28", "q": "#6a8a5a", "y": "#e8d040"}


def wisp(c, f):
    b = BOB[f]
    ellipse(c, 6, 7 + b, 5, 5, "l")
    ellipse(c, 6, 7 + b, 3, 3, "w")
    c.px(6, 7 + b, "W")
    c.px(6, 13 + b, "l"); c.px(5, 14 + b, "l")


WISP_PAL = {"o": "#2a3a20", "k": "#101808", "l": "#a8e870", "w": "#e8ffd0", "W": "#ffffff"}


# --- The Green Knight (Sir Gawain and the Green Knight) ----------------------------------------------------------

def green_knight(headless):
    def draw(c, step):
        horse(c, 6, 36, "h", "H", step, length=30)
        x, y = 20, 24
        poly(c, [(x - 4, y), (x + 8, y), (x + 9, y + 14), (x - 5, y + 14)], "g")     # green surcoat
        c.row(y + 7, x - 4, x + 8, "u")                                              # gold-trimmed belt
        c.rect(x - 2, y - 2, x + 6, y, "G")
        if headless:
            c.rect(x, y - 3, x + 4, y - 2, "r")                                     # the stump of his neck
            c.rect(x + 7, y + 2, x + 9, y + 12, "g")                                 # his arm held out
            ellipse(c, x + 9, y + 16, 4.5, 4.5, "g"); c.px(x + 11, y + 15, "k")      # his head, held by the hair
            poly(c, [(x + 6, y + 18), (x + 12, y + 18), (x + 10, y + 24), (x + 7, y + 23)], "G")   # its beard
            c.rect(x + 7, y + 11, x + 11, y + 12, "G")
        else:
            ellipse(c, x + 2, y - 6, 4, 4.5, "g"); c.px(x + 4, y - 7, "k")
            poly(c, [(x - 1, y - 4), (x + 5, y - 4), (x + 3, y + 3), (x, y + 2)], "G")   # great green beard
            c.rect(x - 1, y - 11, x + 5, y - 9, "G")
        for k in range(18):                                                         # the great axe
            c.px(x + 10 + k // 3, y + 4 - k, "w")
        poly(c, [(x + 14, y - 14), (x + 21, y - 18), (x + 22, y - 9), (x + 16, y - 8)], "i")
        c.px(x + 14, y - 13, "u")
    return draw


GREEN_PAL = {"o": "#10180c", "k": "#081006", "g": "#6ab04a", "G": "#3e7a2c", "h": "#2e5a28", "H": "#1e4018",
             "r": "#8a2020", "w": "#7a5a3a",
             "i": "#9ad09a", "u": "#e0c040"}


# --- Mordred (Malory) ----------------------------------------------------------------------------------------------

def mordred(c, step):
    for k, d in enumerate((-step, step)):
        c.rect(16 + k * 6 + d, 38, 19 + k * 6 + d, 52, "A" if k == 0 else "a")
    poly(c, [(13, 20), (29, 20), (30, 40), (12, 40)], "a"); poly(c, [(13, 20), (16, 20), (15, 40), (12, 40)], "A")
    poly(c, [(10, 20), (13, 20), (11, 46), (6, 44)], "r")                           # dark red cloak
    c.rect(15, 8, 27, 19, "a"); c.rect(15, 8, 16, 19, "A"); c.rect(21, 12, 27, 13, "k")   # closed helm
    c.rect(18, 5, 24, 7, "r")
    c.rect(29, 24, 32, 28, "a")
    for k in range(18):                                                             # sword held forward
        c.px(32 + k // 2, 26 - k, "i")
    c.rect(30, 26, 34, 27, "u")


MORDRED_PAL = {"o": "#100c10", "k": "#08060a", "a": "#2e2c34", "A": "#1c1a20", "r": "#6a1a20", "i": "#c8ccd4",
               "u": "#b88a3a"}


# --- Twrch Trwyth (Culhwch and Olwen) ---------------------------------------------------------------------------

def twrch(c, step):
    ellipse(c, 30, 26, 22, 12, "b")
    ellipse(c, 30, 30, 18, 8, "B")
    for k in range(10):                                                             # bristles along the back
        c.rect(12 + k * 4, 13 - (k % 2), 12 + k * 4, 16, "k")
    for k, d in enumerate((-step, step, step, -step)):
        x = 14 + k * 10 + d
        c.rect(x, 34, x + 3, 44, "B" if k % 2 == 0 else "b")
    poly(c, [(48, 18), (62, 22), (63, 32), (50, 34)], "b")                          # head
    c.rect(60, 25, 63, 29, "B"); c.px(62, 26, "k")                                   # snout
    poly(c, [(58, 30), (64, 27), (62, 31)], "w"); poly(c, [(56, 31), (61, 33), (57, 33)], "w")   # tusks
    c.px(54, 22, "r")
    c.rect(50, 14, 52, 16, "u"); c.rect(53, 13, 55, 15, "i"); c.rect(47, 15, 49, 17, "u")   # comb, razor, shears


def young_boar(c, f):
    """One of Twrch Trwyth's young pigs (Culhwch and Olwen): a bristly young boar."""
    s = STEP[f]
    ellipse(c, 10, 9, 8, 4.5, "b"); ellipse(c, 10, 11, 6, 2.5, "B")
    for k in range(5):
        c.px(5 + k * 3, 4, "k")
    for k, d in enumerate((-s, s, s, -s)):
        c.rect(4 + k * 4 + d, 13, 5 + k * 4 + d, 16, "B")
    poly(c, [(16, 6), (21, 8), (21, 12), (16, 12)], "b"); c.px(20, 10, "k"); c.px(21, 12, "w"); c.px(18, 8, "r")


TWRCH_PAL = {"o": "#140c08", "k": "#0a0604", "b": "#4a3a30", "B": "#30261e", "w": "#ece4d0", "r": "#d03020",
             "u": "#e0c050", "i": "#c8ccd4"}


# --- Rhiannon and Arawn (the Mabinogi, First Branch) ---------------------------------------------------------------

GOD_SIZE, GOD_ANCHOR = (48, 62), (22, 60)
STANCE = (18, 23)
GOD_WALK = [STANCE, (16, 25), STANCE, (20, 21), STANCE]
SEATED = {"style": "celtic", "hip": 40, "lap": "b", "shin": "b", "foot": "n", "keep": range(32, 38)}

RHIANNON_DOC = ("Rhiannon, god (docs/PACK_2_PLAN.md: Avalon's Shadow). The First Branch of the Mabinogi: she rides past "
                "the mound of Arberth on a great pale-white horse in a garment of shining gold; no rider can catch her "
                "until Pwyll calls to her to stop; her birds sing so sweetly the dead wake and the living sleep (the "
                "Second Branch). A lady in shining gold silk. Built by tools/art/build_avalon.py.")
ARAWN_DOC = ("Arawn, god (docs/PACK_2_PLAN.md: Avalon's Shadow). The First Branch of the Mabinogi: king of Annwn, the "
             "Otherworld, met hunting with his hounds, shining white with red ears, in hunting dress of grey wool. A "
             "grey-clad hunter king with a crown and a hunting horn. Built by tools/art/build_avalon.py.")
RHIANNON_PAL = {"o": "#24160e", "k": "#140c08", "s": "#ecc8a8", "S": "#bc9878", "h": "#7a3a1a", "H": "#5a2410",
                "b": "#e0c050", "B": "#b09030", "u": "#fff0a0", "n": "#6a4a2a"}
ARAWN_PAL = {"o": "#14100c", "k": "#0a0806", "s": "#dcb090", "S": "#ac8060", "h": "#2a2420", "b": "#7a7a80",
             "B": "#5a5a60", "u": "#d8b048", "w": "#e8e4dc", "n": "#3a2a20"}


def robe(c, main, fold):
    for y in range(20, 57):
        x0, x1 = (16, 27) if y < 44 else (15 - (y - 44) // 6, 28 + (y - 44) // 6)
        c.row(y, x0, x1, main)
        if y > 34:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, fold)
    c.rect(16, 20, 17, 43, fold)


def feet(c, legs):
    for x0 in legs:
        c.rect(x0, 57, x0 + 4, 58, "s"); c.row(58, x0, x0 + 4, "n")


def face(c):
    c.rect(18, 9, 25, 17, "s"); c.rect(18, 9, 19, 17, "S")
    c.px(23, 12, "k"); c.row(16, 21, 23, "S")


def rhiannon(c, legs):
    c.rect(14, 8, 18, 26, "h"); c.rect(14, 8, 15, 26, "H")                           # long red-brown hair
    robe(c, "b", "B")
    face(c)
    c.rect(17, 7, 25, 8, "h")
    for y in range(22, 50, 4):                                                      # the shine of her gold silk
        c.px(22, y, "u")
    c.rect(26, 21, 28, 28, "s")
    feet(c, legs)


def arawn(c, legs):
    robe(c, "b", "B")
    face(c)
    c.rect(17, 6, 25, 9, "h"); poly(c, [(18, 15), (25, 15), (23, 21), (20, 21)], "h")   # dark hair and beard
    c.row(5, 18, 24, "u"); c.px(19, 4, "u"); c.px(22, 4, "u")                        # a king's circlet
    c.rect(26, 21, 28, 28, "s")
    poly(c, [(28, 27), (34, 24), (35, 27), (29, 30)], "w"); c.px(35, 25, "u")        # hunting horn
    feet(c, legs)


if __name__ == "__main__":
    def doc(text):
        return text + " Built by tools/art/build_avalon.py."
    kit.build_boss("black_knight", black_knight, KNIGHT_PAL, doc("Black knight (docs/PACK_2_PLAN.md: Avalon's Shadow). "
                   "Malory, Le Morte d'Arthur: the knights in black armour who hold fords and fields against all comers. "
                   "A black-armoured knight on a dark horse, lance couched."), (36, 36), (16, 35), [0, 1, 2, 3, 4], folder="enemies")
    kit.build_boss("enchanted_hound", lambda c, f: hound(c, f, "g", "G"), HOUND_PAL, doc("Enchanted hound (docs/PACK_2_PLAN.md: "
                   "Avalon's Shadow). The hunting hounds of the Welsh tales (Pwyll, Prince of Dyfed). A lean grey hound."),
                   (24, 18), (11, 17), [0, 1, 2, 3, 4], folder="enemies")
    kit.build_boss("hound_of_annwn", lambda c, f: hound(c, f, "g", "G", "r"), ANNWN_PAL, doc("Hound of Annwn (Arawn's "
                   "summon). The First Branch of the Mabinogi: shining white hounds with red ears."), (24, 18), (11, 17),
                   [0, 1, 2, 3, 4], folder="enemies")
    kit.build_boss("afanc", afanc, AFANC_PAL, doc("Afanc (docs/PACK_2_PLAN.md: Avalon's Shadow). The lake monster of Welsh "
                   "tradition, dragged from its lake by oxen in the old tales: a broad, dark, scaly beast with a flat head "
                   "and ridged back."), (30, 20), (14, 19), [0, 1, 2, 3, 4], folder="enemies")
    kit.build_boss("will_o_wisp", wisp, WISP_PAL, doc("Will-o'-the-wisp (docs/PACK_2_PLAN.md: Avalon's Shadow). The "
                   "wandering marsh light of British folklore that leads travellers astray: a pale green-white glow."),
                   (12, 16), (6, 15), [0, 1, 2, 3, 4], folder="enemies")
    kit.build_boss("green_knight", green_knight(False), GREEN_PAL, doc("The Green Knight, boss (docs/PACK_2_PLAN.md: "
                   "Avalon's Shadow). Sir Gawain and the Green Knight: a giant of a knight, green all over, his horse "
                   "green, a great green beard, a huge axe in his hand."), (64, 60), (26, 58), [0, 1, 0, -1, 0])
    kit.build_boss("green_knight_headless", green_knight(True), GREEN_PAL, doc("The Green Knight after the beheading: he "
                   "picks up his own head by the hair and rides on (Sir Gawain and the Green Knight)."), (64, 60), (26, 58),
                   [0, 1, 0, -1, 0])
    kit.build_boss("mordred", mordred, MORDRED_PAL, doc("Mordred, boss (docs/PACK_2_PLAN.md: Avalon's Shadow). Malory, Le "
                   "Morte d'Arthur: Arthur's son and betrayer, who seized the kingdom and fell at Camlann. A knight in "
                   "black plate under a dark red cloak, sword drawn."), (44, 56), (20, 54), [0, 1, 0, -1, 0])
    kit.build_boss("twrch_trwyth", twrch, TWRCH_PAL, doc("Twrch Trwyth, boss (docs/PACK_2_PLAN.md: Avalon's Shadow). "
                   "Culhwch and Olwen: a king turned into a monstrous boar, hunted across Ireland and Wales by Arthur, "
                   "with a comb, a razor and shears between his ears."), (66, 48), (34, 46), [0, 1, 0, -1, 0])
    kit.build_boss("young_boar", young_boar, TWRCH_PAL, doc("Young boar (docs/PACK_2_PLAN.md: Avalon's Shadow). "
                   "Culhwch and Olwen: the seven young pigs that ran with Twrch Trwyth, Grugyn Silver-bristle among them."),
                   (24, 18), (11, 17), [0, 1, 2, 3, 4], folder="enemies")
    kit.build_boss("rhiannon", rhiannon, RHIANNON_PAL, RHIANNON_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    kit.build_boss("arawn", arawn, ARAWN_PAL, ARAWN_DOC, GOD_SIZE, GOD_ANCHOR, GOD_WALK, folder="gods", seated=SEATED)
    print("wrote Avalon's Shadow's art")
