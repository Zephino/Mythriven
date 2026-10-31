# Orpheus (docs/ART_RULES.md; docs/PACK_2_PLAN.md: new Heroes). Run: python3 tools/art/build_orpheus.py
# Writes data/art/orpheus.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("Orpheus (docs/PACK_2_PLAN.md: the Underworld's Hero; art 10/31/2026). Built by tools/art/build_orpheus.py on the "
       "shared body in tools/art/hero_kit.py; rules in docs/ART_RULES.md. The singer of Thrace whose song moved beasts, "
       "trees and stones and won him passage to the dead (Ovid, Metamorphoses 10-11; Virgil, Georgics 4). As Attic vase "
       "painting shows him playing: a young man with a laurel wreath in his hair, a long pale chiton and a deep blue "
       "mantle, sandals. Mediterranean skin. His lyre is drawn separately (data/art/weapons/) at his hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#e2a676", "S": "#b0724a",                 # Mediterranean skin
    "h": "#5a3418", "H": "#3a200c",                 # brown hair
    "l": "#6a9a3a", "L": "#4a7a28",                 # laurel wreath
    "c": "#e8e2d4", "C": "#b8b0a0",                 # pale chiton
    "m": "#2e4a8a", "M": "#1e3266",                 # deep blue mantle
    "n": "#6a4a2a",                                 # sandal straps
}


def sandals(c, x0):
    c.rect(x0, 28, x0 + 2, 30, "s"); c.px(x0, 29, "n"); c.px(x0 + 1, 30, "n")
    c.row(31, x0, x0 + 3, "n")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    c.row(3, 11, 15, "h"); c.row(4, 10, 16, "h"); c.rect(10, 5, 16, 6, "h"); c.rect(10, 7, 11, 11, "h")
    c.rect(10, 5, 10, 11, "H")
    c.row(5, 10, 16, "l"); c.px(11, 4, "L"); c.px(13, 4, "l"); c.px(15, 4, "L"); c.px(9, 6, "l")   # laurel wreath
    c.rect(12, 7, 16, 12, "s"); c.px(12, 8, "S"); c.px(12, 9, "S")
    c.px(15, 9, "k"); c.px(17, 9, "s")
    c.row(12, 12, 13, "S")
    c.row(13, 12, 15, "s")
    for y in range(14, 27):                                         # long chiton to the ankles
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "c")
        if y > 20:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "C")
    for y in range(14, 24):                                         # the mantle over one shoulder, across the body
        reach = 10 + (y - 14) // 2
        c.row(y, 10, min(reach + 2, 17), "m")
        c.px(min(reach + 2, 17), y, "M")
    c.rect(10, 14, 10, 23, "M")
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, sandals)


if __name__ == "__main__":
    kit.build("orpheus", draw, PALETTE, DOC, recolor=["m", "M"])
    print("wrote data/art/orpheus.json")
