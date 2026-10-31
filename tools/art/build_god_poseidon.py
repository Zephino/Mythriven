# Poseidon, god (docs/ART_RULES.md: Gods). Run: python3 build_god_poseidon.py from tools/art/.
# Writes data/art/gods/poseidon.json.
import hero_kit as kit
from hero_kit import poly

DOC = ("Poseidon, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_poseidon.py; rules in "
       "docs/ART_RULES.md. From Homer (Iliad 13: the earth-shaker, dark-haired, striking with his trident; Odyssey) and "
       "Hesiod's Theogony, as Greek vase paintings and statues (the Artemision bronze) show him: a powerful bearded man "
       "with long dark hair bound by a fillet, a himation of sea-blue wrapped round his hips and over one shoulder, his "
       "chest bare, the three-pronged trident in his hand.")

SIZE, ANCHOR = (52, 64), (22, 62)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "s": "#e2a676", "S": "#b0724a",                 # Mediterranean skin
    "h": "#2a2a3a", "H": "#46465a",                 # dark hair and beard (Homer: dark-haired)
    "g": "#d8b048",                                 # gold fillet
    "m": "#2a6a8a", "M": "#1a4a62",                 # sea-blue himation
    "w": "#9aa8b0", "W": "#5e6a72",                 # bronze-grey trident
    "n": "#6a4a2a",                                 # sandals
}


def draw(c, legs):
    back, front = legs
    # Long dark hair down his back, a gold fillet round it
    c.row(4, 17, 23, "h"); c.rect(15, 5, 25, 8, "h"); c.rect(13, 8, 18, 22, "h")
    c.rect(13, 8, 14, 22, "H"); c.row(6, 15, 25, "g")
    # Face: a heavy brow, eye, strong nose
    c.rect(19, 9, 26, 15, "s"); c.rect(19, 9, 20, 15, "S")
    c.row(10, 22, 26, "H"); c.px(24, 11, "k"); c.px(27, 12, "s"); c.px(27, 13, "s")
    # Far arm
    c.rect(12, 22, 14, 35, "S"); c.rect(12, 36, 14, 38, "s")
    # Bare, powerful chest
    c.rect(15, 20, 27, 33, "s"); c.rect(15, 20, 16, 33, "S")
    c.row(25, 19, 21, "S"); c.row(25, 23, 25, "S"); c.px(22, 28, "S"); c.px(22, 30, "S")
    # Full dark beard (two rows under the eye, then over the chest)
    poly(c, [(19, 14), (27, 14), (27, 18), (24, 22), (20, 20)], "h")
    c.row(17, 21, 26, "H")
    # Sea-blue himation over his far shoulder and wrapped round his hips to the shins
    for y in range(20, 34):
        reach = 15 + int((y - 20) * 0.45)
        c.row(y, 15, min(reach + 2, 27), "m")
        c.px(min(reach + 2, 27), y, "M")
    for y in range(34, 54):
        x0, x1 = (15, 27) if y < 46 else (14, 28)
        c.row(y, x0, x1, "m")
        for x in range(x0 + 1, x1, 3):
            c.px(x, y, "M")
    c.rect(15, 20, 16, 53, "M"); c.row(34, 15, 27, "M")
    # Near arm gripping the trident upright
    c.rect(26, 21, 28, 27, "s"); c.rect(25, 22, 25, 27, "o")
    c.rect(28, 27, 33, 29, "s"); c.row(29, 28, 33, "S")
    c.rect(35, 6, 36, 58, "W"); c.rect(36, 6, 36, 58, "w")
    c.row(9, 31, 40, "w"); c.row(10, 31, 40, "W")
    for x in (31, 35, 39):                                      # the three prongs, barbed
        c.rect(x, 1, x + 1, 9, "w"); c.px(x, 0, "w"); c.px(x + 2, 2, "W")
    c.rect(33, 26, 37, 30, "s"); c.row(30, 33, 37, "S")
    # Legs and sandals
    for x0 in (back, front):
        c.rect(x0, 54, x0 + 3, 58, "s"); c.rect(x0, 54, x0, 58, "S")
        c.rect(x0, 59, x0 + 4, 60, "n")


if __name__ == "__main__":
    kit.build_boss("poseidon", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods",
                  seated={"style": "greek", "hip": 38, "lap": "m", "shin": "s", "foot": "n", "keep": range(30, 42)})
    print("wrote data/art/gods/poseidon.json")
