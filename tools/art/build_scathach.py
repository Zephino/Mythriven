# Scáthach (docs/ART_RULES.md). Run: python3 tools/art/build_scathach.py
# Writes data/art/scathach.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("Scáthach (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_scathach.py on the shared body in "
       "tools/art/hero_kit.py; rules in docs/ART_RULES.md. From Tochmarc Emire (she trains Cú Chulainn in arms at her "
       "fortress, Dún Scáith, the fortress of shadows) and Aided Óenfir Aífe. The tales do not describe her looks, so her "
       "dress follows early Irish clothing in the same tales (as Cú Chulainn's): a léine (tunic) to the knees, a brat "
       "(mantle) over the shoulders held by a ring brooch, a belt, and shoes, in the dark, shadowy colours of her "
       "fortress; long dark hair. Fair skin. Not based on any modern version (GAME_DESIGN.md: avoid the Fate/Grand Order "
       "design). Her spear is drawn separately (data/art/weapons/) at her hand.")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f0c8a8", "S": "#c49478",                 # fair skin, as Cú Chulainn
    "h": "#2a1c18", "H": "#4a3830",                 # long black hair, brown highlight
    "g": "#7a3a28", "G": "#54261a",                 # madder-brown léine (stands out on grass)
    "m": "#3c3c48", "M": "#24242c",                 # shadow-black brat (mantle)
    "i": "#d0d4dc",                                 # silver ring brooch
    "b": "#5c3a1c",                                 # leather belt and shoes
}


def shoes(c, x0):
    c.px(x0 + 1, 29, "b")
    c.row(30, x0, x0 + 2, "b"); c.row(31, x0, x0 + 3, "b")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    # Long black hair: one mass over the head, falling down her back past the shoulders, with a highlight band
    c.row(3, 11, 15, "h"); c.row(4, 10, 16, "h"); c.rect(9, 5, 16, 6, "h")
    c.rect(9, 7, 11, 12, "h"); c.rect(8, 9, 9, 15, "h"); c.px(10, 13, "h")
    c.row(4, 12, 14, "H"); c.px(11, 5, "H"); c.rect(10, 7, 10, 11, "H"); c.rect(9, 12, 9, 14, "H")
    # Face: forehead, eye, nose, chin
    c.rect(12, 7, 16, 12, "s"); c.px(12, 8, "S"); c.px(12, 9, "S")
    c.px(15, 9, "k"); c.px(17, 9, "s"); c.row(12, 12, 13, "S")
    c.row(13, 12, 15, "s")
    # Léine to the knees with folds
    for y in range(14, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "g")
        if y > 20:
            for x in range(x0 + 1, x1, 3):
                c.px(x, y, "G")
    c.row(25, 9, 18, "G")
    # Brat over the shoulders, its lower edge sloping, held by a silver ring brooch
    c.rect(10, 14, 17, 16, "m"); c.row(17, 10, 14, "m"); c.row(18, 10, 11, "m")
    c.rect(10, 14, 11, 18, "M"); c.row(16, 15, 17, "M")
    c.row(14, 14, 15, "i"); c.px(14, 15, "i")
    c.row(20, 10, 17, "b")
    kit.weapon_arm(c)
    kit.legs(c, back_leg, front_leg, shoes)


if __name__ == "__main__":
    kit.build("scathach", draw, PALETTE, DOC)
    print("wrote data/art/scathach.json")
