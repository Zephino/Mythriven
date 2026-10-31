# Väinämöinen (docs/ART_RULES.md). Run: python3 tools/art/build_vainamoinen.py
# Writes data/art/vainamoinen.json on the shared body in hero_kit.py.
import hero_kit as kit

DOC = ("Väinämöinen (GAME_DESIGN.md: Heroes; art 10/31/2026). Built by tools/art/build_vainamoinen.py on the shared body "
       "in tools/art/hero_kit.py; rules in docs/ART_RULES.md. From the Kalevala (Elias Lönnrot, 1835/1849), where he is "
       "'old and steadfast Väinämöinen', the eternal singer: an old man with long white hair and a long white beard, in a "
       "plain wool coat with a woven belt, and leather boots. He carries his kantele (Kalevala runos 40 and 44: he makes the "
       "first kantele from a great pike's jawbone, then one of birch), drawn separately as the picture for his Runo Song "
       "(data/art/weapons/runo_song.json).")

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#f2d0b4", "S": "#cc9a80",                 # fair skin, a little weathered and ruddy (Finnic north)
    "h": "#ece8e0", "H": "#b8b2a8",                 # white hair and beard
    "r": "#3e5a7a", "R": "#2a405a",                 # dark blue-grey wool coat
    "q": "#a83030", "y": "#d8b048",                 # red woven belt with gold thread
    "b": "#5c3a1c",                                 # leather boots
}


def boots(c, x0):
    c.rect(x0, 29, x0 + 2, 30, "b"); c.row(31, x0, x0 + 3, "b")


def draw(c, back_leg, front_leg):
    kit.far_arm(c)
    # Long white hair: over the crown and falling down his back to the shoulders
    c.row(2, 10, 15, "h")
    c.row(3, 9, 16, "h")
    c.rect(8, 4, 11, 13, "h"); c.rect(8, 9, 9, 13, "H"); c.px(8, 4, "H")
    c.row(4, 12, 16, "h")
    # Weathered face in profile, bushy white brow, eye, nose
    c.rect(12, 5, 16, 9, "s"); c.rect(12, 5, 12, 9, "S")
    c.row(6, 14, 16, "h")                            # bushy brow
    c.px(15, 7, "k"); c.px(17, 8, "s")
    c.px(13, 8, "S")                                 # line of age on the cheek
    # Coat (shoulders and chest under the beard)
    c.rect(10, 13, 17, 19, "r"); c.rect(10, 13, 11, 19, "R")
    kit.weapon_arm(c)
    c.rect(18, 14, 19, 15, "r"); c.px(18, 14, "R")   # coat sleeve over the upper arm
    # Long white beard over his chest, tapering to a point
    c.rect(13, 9, 17, 10, "h"); c.px(17, 9, "s")     # moustache and beard start
    c.rect(12, 11, 16, 14, "h"); c.rect(12, 11, 12, 14, "H")
    c.rect(13, 15, 15, 16, "h"); c.px(13, 16, "H"); c.px(14, 17, "h")
    # Red woven belt with a gold thread pattern
    c.row(20, 10, 17, "q")
    for x in (11, 14, 17):
        c.px(x, 20, "y")
    # Coat skirt to the knees with folds
    for y in range(21, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        c.row(y, x0, x1, "r")
        for x in range(x0 + 1, x1, 3):
            c.px(x, y, "R")
    c.row(25, 9, 18, "R")
    kit.legs(c, back_leg, front_leg, boots)


if __name__ == "__main__":
    kit.build("vainamoinen", draw, PALETTE, DOC)
    print("wrote data/art/vainamoinen.json")
