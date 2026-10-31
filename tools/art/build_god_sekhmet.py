# Sekhmet, god (docs/ART_RULES.md: Gods). Run: python3 build_god_sekhmet.py from tools/art/.
# Writes data/art/gods/sekhmet.json.
import hero_kit as kit
from hero_kit import ellipse, poly

DOC = ("Sekhmet, god (GAME_DESIGN.md: Gods; art 10/31/2026). Built by tools/art/build_god_sekhmet.py; rules in "
       "docs/ART_RULES.md. From the Book of the Heavenly Cow (the Destruction of Mankind: Ra's Eye sent as Sekhmet, the "
       "Powerful One) and her many statues (for example the rows of Sekhmet statues from the temple of Mut, Karnak): a "
       "woman with the head of a lioness, a striped wig, the sun disk with a rearing cobra (uraeus) on her head, a "
       "broad collar, a close red linen dress ('Lady of the Red Linen'), an ankh in one hand and a papyrus sceptre in "
       "the other.")

SIZE, ANCHOR = (50, 68), (22, 66)
STANCE = (17, 23)
WALK = [STANCE, (15, 25), STANCE, (19, 21), STANCE]

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "a": "#d8a050", "A": "#a87430",                 # lioness head
    "s": "#b8683e", "S": "#884624",                 # red-brown skin (Egyptian painting)
    "h": "#2a2a48", "H": "#4a4a78",                 # striped wig
    "u": "#f0c040", "U": "#c08020", "e": "#e85020",  # sun disk, cobra
    "b": "#3a6aa8", "r": "#b8402c", "g": "#e0b040",  # collar beads, gold
    "d": "#b0302a", "D": "#80201c",                 # red linen dress
    "p": "#5a9a4a", "P": "#3a6a30",                 # papyrus sceptre
    "y": "#f0d060",                                 # eye
}


def draw(c, legs):
    back, front = legs
    d = 6                                            # room above for the sun disk
    # Sun disk and cobra above her head
    ellipse(c, 20.5, 4.5, 4.5, 4.5, "u"); ellipse(c, 19.5, 3.5, 2, 2, "U")
    c.rect(25, 3, 26, 9, "e"); c.px(26, 2, "e"); c.px(27, 3, "e")
    # Striped wig falling behind to the shoulders
    poly(c, [(14, 9 + d - 1), (22, 7 + d - 1), (22, 21 + d), (14, 21 + d)], "h")
    for y in range(9 + d, 22 + d, 2):
        c.row(y, 14, 21, "H")
    # Lioness head: rounded skull, short muzzle, mane ruff, yellow eye
    ellipse(c, 23, 12 + d, 5, 5, "a")
    poly(c, [(25, 11 + d), (31, 13 + d), (31, 16 + d), (25, 18 + d)], "a")
    c.row(16 + d, 26, 30, "A"); c.rect(30, 13 + d, 31, 14 + d, "k")
    c.px(25, 11 + d, "y"); c.px(26, 11 + d, "k")
    c.px(20, 7 + d, "a"); c.px(21, 6 + d, "a"); c.px(22, 7 + d, "A")          # ear
    c.rect(19, 17 + d, 24, 19 + d, "A")
    # Broad collar
    c.row(20 + d, 16, 27, "b"); c.row(21 + d, 15, 28, "g"); c.row(22 + d, 15, 28, "r"); c.row(23 + d, 16, 27, "b")
    # Far arm, holding the papyrus sceptre
    c.rect(12, 23 + d, 14, 36 + d, "S")
    c.rect(11, 14 + d, 11, 54 + d, "p"); poly(c, [(8, 10 + d), (14, 10 + d), (11, 15 + d)], "p"); c.row(10 + d, 8, 14, "P")
    c.rect(10, 35 + d, 14, 37 + d, "s")
    # Close red linen dress from the chest to the ankle
    for y in range(24 + d, 57 + d):
        x0, x1 = (16, 27) if y < 44 + d else (15, 28)
        c.row(y, x0, x1, "d")
        if y > 36 + d and y % 2 == 0:
            c.px(x0 + 3, y, "D"); c.px(x1 - 3, y, "D")
    c.rect(16, 24 + d, 17, 56 + d, "D")
    # Near arm, an ankh in her hand
    c.rect(26, 24 + d, 28, 30 + d, "s"); c.rect(25, 25 + d, 25, 30 + d, "o")
    c.row(26 + d, 26, 28, "g")
    c.rect(28, 30 + d, 32, 32 + d, "s"); c.row(32 + d, 28, 32, "S")
    c.rect(32, 29 + d, 34, 33 + d, "s")
    c.rect(36, 30 + d, 36, 37 + d, "g"); c.row(30 + d, 34, 38, "g"); ellipse(c, 36, 27 + d, 1.8, 2.5, "g"); c.px(36, 27 + d, ".")
    # Feet
    for x0 in (back, front):
        c.rect(x0, 57 + d, x0 + 4, 59 + d, "s"); c.row(59 + d, x0, x0 + 4, "S")


if __name__ == "__main__":
    kit.build_boss("sekhmet", draw, PALETTE, DOC, SIZE, ANCHOR, WALK, folder="gods",
                  seated={"style": "egyptian", "hip": 48, "lap": "d", "shin": "d", "foot": "s", "keep": range(8, 15)})
    print("wrote data/art/gods/sekhmet.json")
