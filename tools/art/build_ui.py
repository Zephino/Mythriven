# Menu art (docs/ART_RULES.md: Menus): the frames every panel and button is drawn with, and the icons for passives
# and level-up cards. Run: python3 build_ui.py from tools/art/.
# Writes data/art/ui/frames.json (12 x 12 frames stretched by their 4 px edges: a nine-slice) and
# data/art/ui/icons.json (16 x 16 icons named by passive id).
import json, math, os
from build_weapons import Pic

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "art", "ui")

FRAME_PALETTE = {
    "o": "#140c08", "s": "#2a2430", "S": "#221c28", "t": "#3a3242",           # dark stone
    "g": "#c89a3c", "G": "#8a6420", "y": "#f0cc58",                           # bronze trim
    "h": "#4a3e54", "H": "#5a4c66", "p": "#1a1420", "w": "#fff0b0", "d": "#55505a",
}


def frame(fill, edge, light, dark, inner):
    """A 12 x 12 frame: a dark outline, a two-tone bronze (or grey) border lit at the top left, and the fill."""
    p = Pic(12, 12, (0, 0))
    p.rect(0, 0, 11, 11, "o")
    p.rect(1, 1, 10, 10, edge)
    p.rect(1, 1, 10, 1, light); p.rect(1, 1, 1, 10, light)
    p.rect(1, 10, 10, 10, dark); p.rect(10, 1, 10, 10, dark)
    p.rect(2, 2, 9, 9, "o")
    p.rect(3, 3, 8, 8, fill)
    p.rect(3, 3, 8, 3, inner)
    for x, y in ((0, 0), (11, 0), (0, 11), (11, 11)):
        p.px(x, y, ".")
    return ["".join(r) for r in p.g]


FRAMES = {
    "panel": frame("s", "g", "y", "G", "t"),
    "button": frame("t", "G", "g", "o", "h"),
    "button_hover": frame("h", "g", "y", "G", "H"),
    "button_pressed": frame("p", "G", "o", "g", "S"),
    "button_focus": frame("h", "y", "w", "g", "H"),
    "button_disabled": frame("S", "d", "d", "o", "S"),
}

# The four menu styles (owner decision 10/31/2026), each matching its backdrop: a stone, wood or sandstone border
# lit at the top left, an inner trim, corner studs, and a dark fill so the cream text reads.
STYLE_PALETTE = {
    # greek: marble and gold
    "A": "#efe6d4", "B": "#fffaf0", "C": "#a89e8c", "D": "#d8a838", "E": "#2c2430", "F": "#3e3448", "I": "#4e4258",
    # norse: wood and iron
    "J": "#7a5232", "K": "#9a6c44", "L": "#4a3020", "M": "#9aa0a8", "N": "#2a2218", "P": "#3a2e22", "Q": "#4a3c2c",
    # egyptian: sandstone and lapis
    "R": "#d8b47e", "T": "#f0d4a0", "U": "#a8844e", "V": "#2a5aa0", "X": "#1e2236", "Y": "#2a3048", "Z": "#3a4260",
    # celtic: mossy stone
    "a": "#8a8a84", "b": "#a8a8a0", "c": "#5e5e58", "e": "#5a7a3a", "f": "#1e2620", "i": "#2a342c", "j": "#38463a",
    "k": "#f0cc58",
}


def styled(edge, light, dark, trim, stud, fill, hover, hollow=False, dim=False):
    """A 12 x 12 frame in one style: outline, a border lit at the top left, a thin trim inside it, a stud at each
    corner of the trim, and the fill. `dim`: greyed (disabled)."""
    p = Pic(12, 12, (0, 0))
    p.rect(0, 0, 11, 11, "o")
    p.rect(1, 1, 10, 10, edge)
    p.rect(1, 1, 10, 1, light); p.rect(1, 1, 1, 10, light)
    p.rect(1, 10, 10, 10, dark); p.rect(10, 1, 10, 10, dark)
    p.rect(2, 2, 9, 9, trim)
    p.rect(3, 3, 8, 8, hover if hover else fill)
    for x, y in ((2, 2), (9, 2), (2, 9), (9, 9)):
        p.px(x, y, stud)
    for x, y in ((0, 0), (11, 0), (0, 11), (11, 11)):
        p.px(x, y, ".")
    rows = ["".join(r) for r in p.g]
    if dim:
        rows = [r.replace(edge, "d").replace(light, "d").replace(trim, "S").replace(stud, "S") for r in rows]
    return rows


def style_set(name, edge, light, dark, trim, stud, fill, fill_hover, fill_pressed):
    return {
        name + "_panel": styled(edge, light, dark, trim, stud, fill, None),
        name + "_button": styled(edge, light, dark, dark, stud, fill_hover, None),
        name + "_button_hover": styled(light, light, edge, trim, stud, fill_pressed, None),
        name + "_button_pressed": styled(dark, dark, light, dark, dark, fill, None),
        name + "_button_focus": styled(trim, "w", trim, trim, "w", fill_pressed, None),
        name + "_button_disabled": styled(edge, light, dark, dark, stud, "S", None, dim=True),
    }


STYLES = {}
STYLES.update(style_set("greek", "A", "B", "C", "D", "D", "E", "F", "I"))
STYLES.update(style_set("norse", "J", "K", "L", "M", "M", "N", "P", "Q"))
STYLES.update(style_set("egyptian", "R", "T", "U", "V", "k", "X", "Y", "Z"))
STYLES.update(style_set("celtic", "a", "b", "c", "e", "e", "f", "i", "j"))

ICON_PALETTE = {
    "o": "#24160e", "k": "#140c08", "w": "#ffffff",
    "b": "#6a4422", "B": "#4a2e16", "g": "#c89a3c", "G": "#8a6420", "y": "#f0cc58",
    "e": "#e8e0d0", "E": "#b8b0a0", "u": "#5a9ad8", "U": "#2a5a9a", "s": "#c8ccd4", "S": "#8a8e96",
    "r": "#e8c040", "R": "#b08a20", "l": "#4a8a30", "c": "#6a6a78", "C": "#44444e", "m": "#a8d8ff", "f": "#e2a676",
    "F": "#b0724a", "q": "#d8e8f0", "p": "#b02a3a", "P": "#701a26", "h": "#f0d8c8", "v": "#3a7a3a",
}


def icon():
    return Pic(16, 16, (8, 8))


def belt():
    """Belt of Strength: a broad leather belt with a bronze buckle."""
    p = icon()
    p.rect(0, 6, 15, 10, "b"); p.rect(0, 10, 15, 10, "B"); p.rect(0, 6, 15, 6, "F")
    p.rect(5, 4, 10, 12, "g"); p.rect(7, 6, 8, 10, "B"); p.rect(5, 4, 10, 4, "y"); p.rect(5, 12, 10, 12, "G")
    return p


def sandals():
    """Winged Sandals (the winged sandals Hermes lends Perseus): a sandal with a white wing at the heel."""
    p = icon()
    p.rect(3, 11, 14, 12, "b"); p.rect(3, 13, 14, 13, "B")
    for x in (5, 8, 11):
        p.rect(x, 8, x, 10, "b")
    p.rect(5, 8, 11, 8, "b")
    for k in range(6):
        p.rect(1 + k // 2, 3 + k, 6 - k // 2, 3 + k, "e")
    p.rect(1, 3, 6, 3, "w"); p.px(2, 5, "E"); p.px(3, 7, "E")
    return p


def hourglass():
    """Hourglass: sand running through, in a wooden frame."""
    p = icon()
    p.rect(3, 1, 12, 2, "b"); p.rect(3, 13, 12, 14, "b")
    for y in range(3, 13):
        w = abs(y - 7.5)
        p.rect(round(8 - w * 0.75) - 1, y, round(7 + w * 0.75) + 1, y, "q")
    for y in range(9, 13):
        w = abs(y - 7.5) * 0.75
        p.rect(round(8 - w), y, round(7 + w), y, "r")
    p.rect(7, 4, 8, 5, "r"); p.px(8, 7, "r"); p.px(7, 8, "r")
    return p


def eye():
    """Seer's Eye: a wide eye with a bright blue iris."""
    p = icon()
    for x in range(1, 15):
        h = round(math.sin(math.pi * (x - 0.5) / 14.5) * 4.2)
        p.rect(x, 8 - h, x, 8 + h, "e")
    for y in range(5, 12):
        for x in range(5, 11):
            d = math.hypot(x - 7.5, y - 8)
            if d <= 3.0:
                p.px(x, y, "U" if d > 2.0 else "u")
    p.rect(7, 7, 8, 9, "k"); p.px(6, 6, "w")
    return p


def lodestone():
    """Lodestone: a dark magnetic stone drawing in specks of gold."""
    p = icon()
    for y in range(4, 13):
        for x in range(3, 13):
            if math.hypot(x - 7.5, (y - 8.5) * 1.2) <= 4.6:
                p.px(x, y, "c")
    p.rect(5, 6, 7, 6, "S"); p.px(10, 11, "C"); p.px(9, 11, "C")
    for x, y in ((1, 2), (14, 3), (1, 13), (14, 14), (8, 1)):
        p.px(x, y, "y")
    return p


def aegis():
    """Bronze Aegis: a round bronze shield with a boss."""
    p = icon()
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5)
            if d <= 7.0:
                p.px(x, y, "G" if d > 5.8 or 3.2 < d <= 3.9 else "g")
    p.rect(7, 7, 8, 8, "y"); p.px(5, 4, "y"); p.px(4, 5, "y")
    return p


def obol():
    """Ferryman's Coin (the obol paid to Charon): a silver coin with an owl's eyes struck on it."""
    p = icon()
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5)
            if d <= 6.5:
                p.px(x, y, "S" if d > 5.4 else "s")
    p.rect(5, 6, 6, 7, "S"); p.rect(9, 6, 10, 7, "S"); p.px(5, 6, "k"); p.px(10, 6, "k")
    p.rect(7, 9, 8, 10, "S"); p.px(5, 4, "w")
    return p


def apple():
    """Golden Apple: a golden apple with a leaf."""
    p = icon()
    for y in range(4, 16):
        for x in range(16):
            if math.hypot((x - 7.5) * 1.05, y - 9.5) <= 5.8 and not (y == 4 and x in (7, 8)):
                p.px(x, y, "R" if x > 9 or y > 13 else "r")
    p.px(5, 7, "w"); p.px(5, 8, "y"); p.rect(7, 1, 8, 4, "B"); p.rect(9, 1, 11, 2, "l")
    return p


def bell():
    """Votive Bell: a small bronze temple bell."""
    p = icon()
    for y in range(3, 13):
        w = 2 + (y - 3) * 0.45
        p.rect(round(7.5 - w), y, round(7.5 + w), y, "g")
    p.rect(1, 12, 14, 12, "G"); p.rect(7, 1, 8, 2, "G"); p.rect(7, 13, 8, 14, "G")
    p.rect(5, 4, 5, 10, "y")
    return p


def mirror_shield():
    """Mirrored Shield (Perseus' polished shield): a round shield polished bright, with a gleam."""
    p = icon()
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5)
            if d <= 7.0:
                p.px(x, y, "G" if d > 5.8 else "q")
    for k in range(5):
        p.px(4 + k, 9 - k, "w"); p.px(6 + k, 11 - k, "m")
    return p


def hand():
    """Tyr's Oath (Tyr's hand pledged in Fenrir's jaws): an open right hand, raised."""
    p = icon()
    p.rect(3, 8, 11, 13, "f"); p.rect(4, 14, 10, 15, "F")
    for x, top in ((3, 3), (6, 1), (9, 2)):
        p.rect(x, top, x + 1, 8, "f"); p.px(x + 1, top, "F")
    p.rect(12, 7, 13, 10, "f"); p.px(13, 11, "f")
    p.rect(3, 12, 11, 13, "F")
    return p


def crit():
    """Critical strike (the Crit Chance card): a blade's point striking a bright spark."""
    p = icon()
    for k in range(9):
        p.px(1 + k, 14 - k, "s"); p.px(2 + k, 14 - k, "S")
    p.rect(1, 13, 2, 14, "b")
    for x, y in ((12, 3), (11, 2), (13, 4), (12, 1), (12, 5), (10, 3), (14, 3), (11, 4), (13, 2)):
        p.px(x, y, "y")
    p.px(12, 3, "w")
    return p


def pomegranate():
    """Pomegranate Seed (Persephone's pomegranate): a split pomegranate, its red seeds showing."""
    p = icon()
    for y in range(3, 15):
        for x in range(16):
            d = math.hypot(x - 7.5, (y - 9) * 1.1)
            if d <= 6.0:
                p.px(x, y, "P" if d > 4.6 else "h")
    for x, y in ((6, 8), (8, 8), (7, 10), (9, 10), (5, 10), (6, 12), (8, 12), (7, 7)):
        p.px(x, y, "p")
    p.rect(6, 1, 9, 2, "P"); p.px(5, 1, "P"); p.px(10, 1, "P")          # the crown
    return p


def whetstone():
    """Whetstone Shard (Hrungnir's whetstone, Skaldskaparmal 17): a grey shard of whetstone with a lightning spark."""
    p = icon()
    for k in range(10):
        p.rect(3 + k // 2, 13 - k, 7 + k // 2, 13 - k, "c" if k % 3 else "C")
    for x, y in ((12, 2), (11, 4), (13, 4), (12, 6), (11, 7)):
        p.px(x, y, "y")
    p.px(12, 4, "w")
    return p


def girdle():
    """The Green Girdle (Sir Gawain and the Green Knight): a green silk girdle tied in a knot, gold at its ends."""
    p = icon()
    p.rect(1, 6, 14, 8, "l"); p.rect(1, 8, 14, 8, "v")
    p.rect(6, 5, 9, 9, "v"); p.rect(7, 6, 8, 8, "l")
    for k in range(5):
        p.px(6 - k // 2, 10 + k, "l"); p.px(9 + k // 2, 10 + k, "v")
    p.px(4, 14, "y"); p.px(11, 14, "y")
    return p


def plant():
    """Plant of Youth (Epic of Gilgamesh, Tablet XI): a thorny sprig drawn up from the deep, with green leaves."""
    p = icon()
    p.rect(7, 4, 8, 15, "v")
    for y, side in ((5, -1), (7, 1), (9, -1), (11, 1)):
        for k in range(4):
            p.px(7 + side * (k + 1) + (1 if side > 0 else 0), y - k // 2, "l")
    for y in range(6, 14, 3):
        p.px(6, y, "w"); p.px(9, y + 1, "w")                            # thorns
    p.rect(6, 1, 9, 3, "l")
    return p


def skis():
    """Elk-Hunter's Skis (Kalevala 13-14, Lemminkainen's chase): a pair of long wooden skis, tips curled up."""
    p = icon()
    for k, y in enumerate((6, 10)):
        p.rect(1, y, 13, y + 1, "b" if k else "B"); p.px(14, y - 1, "b"); p.px(15, y - 2, "b")
    p.rect(6, 5, 8, 12, "e")
    return p


def div_blood():
    """White Div's Blood (the Shahnameh, seventh labour): a pale drop that restored the blinded king's sight."""
    p = icon()
    for y in range(2, 15):
        w = 0 if y < 5 else min(5, (y - 4))
        if y > 10:
            w = max(0, 5 - (y - 10))
        p.rect(7 - w, y, 8 + w, y, "q")
    p.px(6, 9, "w"); p.px(6, 10, "w")
    return p


def feather():
    """Firebird's Feather (the Russian tales): a feather that shines like fire."""
    p = icon()
    for k in range(12):
        p.px(3 + k, 14 - k, "R")
        for d in (1, 2):
            p.px(3 + k - d, 14 - k - d + 1, "r" if k % 2 else "y")
    return p


def sake():
    """Oeyama Sake (the Oeyama tale): a red lacquered sake cup."""
    p = icon()
    for y in range(6, 12):
        w = 6 - (y - 6)
        p.rect(7 - w, y, 8 + w, y, "p")
    p.rect(2, 6, 13, 6, "y"); p.rect(4, 7, 11, 7, "q")
    p.rect(6, 12, 9, 13, "P")
    return p


def flame_blade():
    """Laevateinn Shard (Fjolsvinnsmal): a shard of a blade of flame."""
    p = icon()
    for k in range(11):
        p.px(3 + k, 13 - k, "r"); p.px(4 + k, 13 - k, "y")
    p.rect(2, 13, 4, 14, "b")
    return p


def dew():
    """Dew of the Ash (Gylfaginning 16): a drop of honeydew falling from a green ash leaf."""
    p = icon()
    p.rect(3, 2, 12, 4, "l"); p.rect(6, 1, 9, 5, "l")
    for y in range(7, 15):
        w = min(3, (y - 6) // 2 + 1) if y < 12 else 3 - (y - 12)
        p.rect(7 - w, y, 8 + w, y, "y")
    return p


def golden_key():
    """The Golden Key (the legend of Ys): the golden key of the sea gates."""
    p = icon()
    for y in range(2, 8):
        for x in range(3, 9):
            if 1.5 <= math.hypot(x - 5.5, y - 4.5) <= 2.8:
                p.px(x, y, "r")
    p.rect(7, 7, 8, 14, "r"); p.rect(9, 11, 11, 11, "r"); p.rect(9, 13, 10, 13, "r")
    return p


def roc_feather():
    """Roc's Feather (the Thousand and One Nights): a huge brown feather."""
    p = icon()
    for k in range(12):
        p.px(3 + k, 14 - k, "B")
        for d in (1, 2, 3):
            p.px(3 + k - d, 14 - k - d + 1, "b")
    return p


def crow_feather():
    """Sun-crow Feather (the Huainanzi; the Chuci commentary): a black feather of a crow from the sun, gold-tipped."""
    p = icon()
    for k in range(12):
        p.px(3 + k, 14 - k, "k" if k < 9 else "r")
        for d in (1, 2):
            p.px(3 + k - d, 14 - k - d + 1, "C" if k < 9 else "y")
    return p


def loose_thread():
    """Loose Thread (the Unweaver, the game's own): a loose thread unravelling from a spool."""
    p = icon()
    p.rect(2, 4, 7, 12, "b"); p.rect(1, 3, 8, 3, "B"); p.rect(1, 13, 8, 13, "B")
    p.rect(3, 5, 6, 11, "p")
    for x in range(7, 15):
        p.px(x, 8 + round(2 * math.sin(x * 1.1)), "p")
    return p


def hunters_horn():
    """Hunter's Horn (the Wild Hunt: the horns heard all night, the Anglo-Saxon Chronicle 1127): a curved hunting horn."""
    p = icon()
    for k in range(11):
        w = 1 + k // 4
        y = 11 - round(4 * math.sin(k / 10 * math.pi))
        p.rect(2 + k, y - w // 2, 2 + k, y + w // 2, "y" if k % 4 else "G")
    p.rect(12, 5, 14, 12, "g")
    return p


def pedlar_charm():
    """Pedlar's Charm (Carmilla, ch. 5: the hunchbacked pedlar's charms against the oupire): a little rolled paper
    charm on a cord."""
    p = icon()
    for k in range(6):
        p.px(4 + k, 2 + k // 2, "B")
    p.rect(7, 5, 11, 13, "e"); p.rect(7, 5, 11, 5, "E"); p.rect(7, 13, 11, 13, "E")
    p.rect(8, 8, 10, 9, "p")
    return p


def wolf_tooth():
    """Wolf's Tooth (the Beast of Gevaudan): a long white fang."""
    p = icon()
    for y in range(2, 15):
        w = max(0, 3 - (y - 2) // 4)
        p.rect(8 - w, y, 8 + w // 2, y, "e")
    p.rect(5, 2, 10, 3, "E")
    return p


def iron_claw():
    """Iron Claw (Black Annis): three long curved iron claws."""
    p = icon()
    for k in range(3):
        for t in range(10):
            p.px(3 + k * 4 + t // 4, 3 + t, "s" if t < 7 else "S")
    return p


def draupnir_ring():
    """Draupnir (Skaldskaparmal 35): the gold ring from which eight more of the same weight drip every ninth night."""
    p = icon()
    for a in range(40):
        t = a / 40 * 2 * math.pi
        p.px(round(8 + 5 * math.cos(t)), round(7 + 5 * math.sin(t)), "y")
        p.px(round(8 + 4 * math.cos(t)), round(7 + 4 * math.sin(t)), "g")
    for x in (5, 8, 11): p.px(x, 14, "y")
    return p


def tarnkappe_thread():
    """Tarnkappe Thread (the Nibelungenlied): a wisp of the grey cloak of invisibility, half there."""
    p = icon()
    for y in range(2, 15):
        for x in range(4, 13):
            if (x + y) % 2 and abs(x - 8 - round(2 * math.sin(y / 2))) < 4:
                p.px(x, y, "S" if y % 3 else "s")
    return p


def glow_cap():
    """Glow-cap (Mycendra, the game's own): a small mushroom glowing pale green."""
    p = icon()
    p.rect(7, 8, 9, 14, "e"); p.rect(3, 4, 13, 7, "l"); p.rect(5, 2, 11, 3, "l"); p.px(5, 5, "w"); p.px(10, 4, "w")
    return p


def ant_strength():
    """Ant's Strength (Herodotus' gold-digging ants): an ant carrying a lump of gold bigger than itself."""
    p = icon()
    for x, r in ((4, 2), (8, 1.5), (12, 2.5)):
        for y in range(16):
            for xx in range(16):
                if math.hypot(xx - x, y - 11) <= r: p.px(xx, y, "B")
    for k in range(3): p.px(6 + k * 2, 14, "k"); p.px(6 + k * 2, 8 + 0, "k")
    p.rect(6, 2, 12, 7, "y")
    return p


def elf_arrow():
    """Elf-arrow (the charm "Wid faerstice": the elves' arrows): a small flint arrowhead, as the old "elf-shot" stones."""
    p = icon()
    for y in range(2, 13):
        w = (y - 2) // 2
        p.rect(8 - w, y, 8 + w, y, "S" if y % 3 else "s")
    p.rect(7, 13, 9, 15, "b")
    return p


def rhymers_tongue():
    """Rhymer's Tongue (Thomas the Rhymer: given a tongue that cannot lie): a harp of Elfland, small and green-gold."""
    p = icon()
    for k in range(10):
        p.px(3 + k // 3, 13 - k, "r"); p.px(4 + k, 3 + k // 4, "r")
    for x in range(5, 13, 2):
        p.rect(x, 5 + (x - 5) // 4, x, 12, "y")
    p.rect(3, 13, 13, 14, "l")
    return p


def thunderstone():
    """Thunderstone (Ovid: Zeus' thunderbolt on Lycaon's house): a dark stone crackling with a jagged bolt."""
    p = icon()
    for y in range(4, 15):
        for x in range(2, 14):
            if math.hypot(x - 8, (y - 10) * 1.3) <= 5.5:
                p.px(x, y, "C")
    for x, y in ((9, 1), (8, 3), (10, 4), (8, 6), (9, 8)):
        p.px(x, y, "y"); p.px(x, y + 1, "y")
    return p


def iolaus_brand():
    """Iolaus' Brand (Apollodorus 2.5.2: the brands that seared the Hydra's necks): a burning torch."""
    p = icon()
    for k in range(9):
        p.px(4 + k, 14 - k, "b"); p.px(5 + k, 14 - k, "B")
    for x, y in ((12, 2), (13, 3), (11, 3), (12, 4), (14, 1)):
        p.px(x, y, "y")
    p.rect(11, 4, 13, 6, "r")
    return p


def torn_banner():
    """Torn Banner (Ghorvast, the game's own): a ragged red war banner on a broken pole."""
    p = icon()
    p.rect(4, 2, 5, 15, "b")
    for y in range(2, 10):
        p.rect(6, y, 6 + 7 - abs(y - 5) - (y % 3), y, "p")
    return p


def ariadne_thread():
    """Ariadne's Thread (Plutarch, Theseus 19): a ball of red thread, the end trailing away."""
    p = icon()
    for y in range(3, 12):
        for x in range(2, 11):
            if math.hypot(x - 6, y - 7) <= 4.2:
                p.px(x, y, "p" if (x + y) % 3 else "P")
    for k in range(6):
        p.px(10 + k, 11 + round(math.sin(k) * 1.5), "p")
    return p


def drinking_horn():
    """Drinking Horn (Gylfaginning 46-47: the horn whose end was in the sea): a curved horn with a silver rim."""
    p = icon()
    for k in range(12):
        w = 1 + k // 4
        p.rect(2 + k, 12 - k // 2 - w // 2, 2 + k, 12 - k // 2 + w // 2, "E" if k % 3 else "e")
    p.rect(13, 4, 14, 9, "s")
    return p


def scabbard_strap():
    """Scabbard Strap (Malory: the scabbard of Excalibur): a red jewelled scabbard on its strap."""
    p = icon()
    for k in range(11):
        p.px(3 + k, 13 - k, "p"); p.px(4 + k, 13 - k, "P")
    p.px(6, 10, "y"); p.px(9, 7, "u"); p.px(12, 4, "y")
    p.rect(13, 1, 15, 3, "b")
    return p


ICONS = {"crit": crit, "belt_of_strength": belt, "winged_sandals": sandals, "hourglass": hourglass, "seers_eye": eye,
         "lodestone": lodestone, "bronze_aegis": aegis, "ferrymans_coin": obol, "golden_apple": apple,
         "votive_bell": bell, "mirrored_shield": mirror_shield, "tyrs_oath": hand,
         "pomegranate_seed": pomegranate, "whetstone_shard": whetstone, "green_girdle": girdle, "plant_of_youth": plant,
         "elk_skis": skis, "white_div_blood": div_blood, "firebird_feather": feather, "oeyama_sake": sake,
         "laevateinn_shard": flame_blade, "yggdrasil_dew": dew, "golden_key": golden_key, "roc_feather": roc_feather,
         "sun_crow_feather": crow_feather, "loose_thread": loose_thread,
         "hunters_horn": hunters_horn, "mountebanks_charm": pedlar_charm, "wolf_tooth": wolf_tooth, "iron_claw": iron_claw,
         "draupnir": draupnir_ring, "tarnkappe_thread": tarnkappe_thread, "glow_cap": glow_cap, "ant_strength": ant_strength,
         "elf_arrow": elf_arrow, "rhymers_tongue": rhymers_tongue, "thunderstone": thunderstone, "iolaus_brand": iolaus_brand,
         "torn_banner": torn_banner, "ariadne_thread": ariadne_thread, "drinking_horn": drinking_horn, "scabbard_strap": scabbard_strap}


def outlined(p):
    g = [r[:] for r in p.g]
    for y in range(16):
        for x in range(16):
            if p.g[y][x] == "." and any(0 <= x + dx < 16 and 0 <= y + dy < 16 and p.g[y + dy][x + dx] not in (".",)
                                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                g[y][x] = "o"
    return ["".join(r) for r in g]


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "frames.json"), "w") as f:
        json.dump({"_doc": "Menu frames (docs/ART_RULES.md: Menus), built by tools/art/build_ui.py: dark stone with a bronze "
                           "trim (no prefix), and the four menu styles that match the menu backdrops (greek_: marble and gold, norse_: wood and "
                           "iron, egyptian_: sandstone and lapis, celtic_: mossy stone), stretched by their 4 px edges "
                           "(nine-slice) for every panel and button.",
                   "size": [12, 12], "margin": 4, "palette": dict(FRAME_PALETTE, **STYLE_PALETTE),
                   "frames": {k: [v] for k, v in dict(FRAMES, **STYLES).items()}},
                  f, indent=1)
    docs = " ".join("%s: %s" % (k, " ".join(v.__doc__.split())) for k, v in ICONS.items())
    with open(os.path.join(OUT, "icons.json"), "w") as f:
        json.dump({"_doc": "Passive icons (docs/ART_RULES.md: Menus), built by tools/art/build_ui.py. " + docs,
                   "size": [16, 16], "palette": ICON_PALETTE, "frames": {k: [outlined(v())] for k, v in ICONS.items()}},
                  f, indent=1)
    print("wrote", len(FRAMES), "frames and", len(ICONS), "icons")
