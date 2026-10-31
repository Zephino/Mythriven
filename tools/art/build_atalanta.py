# Atalanta (docs/ART_RULES.md). Run: python3 tools/art/build_atalanta.py
# Writes data/art/atalanta.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("Atalanta (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_atalanta.py on the shared body in "
       "tools/art/hero_kit.py; rules in docs/ART_RULES.md. From Ovid, Metamorphoses 8.318-323 (at the Calydonian hunt: "
       "her robe fastened at the throat by a polished brooch, her hair plain, gathered in a single knot, an ivory quiver "
       "hanging from her shoulder, shown only as arrows above it) and Apollodorus, Library 3.9.2 (raised in the wild, a huntress). A belted huntress's "
       "chiton to the knees, as Greek vase paintings show hunters, and laced hunting boots. Mediterranean skin. Her bow "
       "is drawn separately (data/art/weapons/) at her hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#e2a676", "S": "#b0724a",                 # Mediterranean skin, as Heracles and Achilles
    "h": "#4a2c18", "H": "#2e1a0c",                 # dark brown hair
    "t": "#2f6f6a", "T": "#1f4a48",                 # deep teal huntress's chiton (stands out on grass)
    "f": "#c84a34", "F": "#8a2e20",                 # arrow fletching
    "c": "#d8b078", "C": "#a87c48",                 # arrow shafts (light wood, apart from her hair)
    "y": "#d8b048",                                 # gold brooch
    "b": "#6a4422", "B": "#4a2e16",                 # leather belt and boots
}


def boots(c, x0):
    """Laced hunting boots up the shin."""
    c.rect(x0, 28, x0 + 2, 30, "b"); c.px(x0, 28, "B"); c.px(x0 + 1, 29, "B")
    c.row(31, x0, x0 + 3, "B")


def quiver(c):
    """Her quiver (Ovid) is on her back, out of sight from the side: only the arrows show, sticking up behind her
    shoulder (owner request 10/31/2026: a whole quiver beside her looked like a rocket)."""
    c.rect(5, 6, 5, 12, "c"); c.rect(6, 5, 6, 12, "C")
    c.px(5, 4, "f"); c.px(5, 5, "F"); c.px(6, 3, "f"); c.px(6, 4, "F"); c.px(4, 5, "f"); c.px(7, 4, "f")


def draw(c, back_leg, front_leg):
    quiver(c)
    kit.far_arm(c)
    # Dark hair, plain, gathered in a single knot at the back of the head
    c.row(3, 11, 15, "h"); c.row(4, 10, 16, "h"); c.rect(10, 5, 16, 6, "h")
    c.rect(10, 7, 11, 10, "h")
    c.rect(8, 5, 9, 7, "h"); c.px(8, 5, "H"); c.px(8, 7, "H")         # the knot
    c.rect(10, 5, 10, 10, "H"); c.row(6, 13, 16, "H")
    # Face: forehead, eye, nose, mouth, chin
    c.rect(12, 7, 16, 12, "s"); c.px(12, 8, "S"); c.px(12, 9, "S")
    c.px(15, 9, "k"); c.px(17, 9, "s")
    c.row(12, 12, 13, "S")
    # Neck, and the brooch fastening her robe at the throat
    c.row(13, 12, 15, "s")
    # Chiton to the knees, belted, with folds
    for y in range(14, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "t")
        if y > 20:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "T")
    c.rect(10, 14, 11, 19, "T"); c.px(14, 16, "T"); c.px(14, 17, "T")
    c.px(15, 14, "y")
    c.row(25, 9, 18, "T")
    c.row(20, 10, 17, "b")
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, boots)


if __name__ == "__main__":
    kit.build("atalanta", draw, PALETTE, DOC)
    print("wrote data/art/atalanta.json")
