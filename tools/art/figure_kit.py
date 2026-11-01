# A shared standing figure for boss-sized people (about 40 x 56 pixels), drawn front-on with a little shading:
# a shaped head with hair, eyes, brows, nose and mouth; a neck and shoulders; arms with hands; a fitted top and a gown,
# robe or tunic with folds; optional cloak, crown, belt and pointed (elf) ears. Each Hero-sized boss script picks the
# colours and parts, then adds what is its own (an item, wings, a train). Used by build_wild.py and later packs.
from hero_kit import ellipse, poly


def person(c, step, cx=20, skin="s", skin_d="S", hair="h", hair_d="H", hair_style="short", beard=None,
           garment="gown", robe="r", robe_d="R", robe_l=None, legs="l", boots="b", belt=None, cloak=None,
           crown=None, ears=False, eye="k", mouth="m", arm_forward=False, head_y=10, bottom=54):
    """Draws a person. hair_style: "long" (to the waist), "shoulder", "short", "bun", "none". garment: "gown" (to the
    feet), "robe" (to the feet, straight), "tunic" (to the knee, with legs and boots). cloak: (colour, shade) hanging
    behind. crown: a colour. arm_forward: the near (right-hand) arm reaches out at chest height."""
    hy = head_y
    if cloak:                                                                        # cloak hanging behind
        poly(c, [(cx - 8, hy + 8), (cx + 8, hy + 8), (cx + 13, bottom - 2), (cx - 13, bottom - 2)], cloak[0])
        poly(c, [(cx - 8, hy + 8), (cx - 5, hy + 8), (cx - 9, bottom - 2), (cx - 13, bottom - 2)], cloak[1])
    if hair_style == "long":                                                         # long hair behind the shoulders
        poly(c, [(cx - 5, hy - 3), (cx + 5, hy - 3), (cx + 7, hy + 18), (cx - 7, hy + 18)], hair_d)
    if garment == "tunic":                                                           # legs and boots under a tunic
        for k, d in enumerate((-step, step)):
            x = cx - 4 + k * 5 + d
            c.rect(x, bottom - 16, x + 2, bottom - 4, legs)
            c.rect(x - 1, bottom - 4, x + 3, bottom, boots)
    else:
        for k, d in enumerate((-step, step)):                                        # feet peeping out
            x = cx - 4 + k * 5 + d
            c.rect(x, bottom - 1, x + 3, bottom, boots)
    top = hy + 7
    waist = hy + 18
    poly(c, [(cx - 7, top), (cx + 7, top), (cx + 5, waist), (cx - 5, waist)], robe)  # fitted top
    poly(c, [(cx - 7, top), (cx - 4, top), (cx - 3, waist), (cx - 5, waist)], robe_d)
    if garment in ("gown", "robe"):
        spread = 10 if garment == "gown" else 7
        poly(c, [(cx - 5, waist), (cx + 5, waist), (cx + spread, bottom - 1), (cx - spread, bottom - 1)], robe)
        poly(c, [(cx - 5, waist), (cx - 3, waist), (cx - spread + 3, bottom - 1), (cx - spread, bottom - 1)], robe_d)
        for fx in (-1, 3):                                                           # folds
            for y in range(waist + 2, bottom - 1):
                c.px(cx + fx + (y - waist) * fx // 12, y, robe_d)
        if robe_l:
            for y in range(waist + 1, bottom - 2, 2):
                c.px(cx + 2 + (y - waist) // 6, y, robe_l)
            c.row(bottom - 1, cx - spread + 1, cx + spread - 1, robe_l)              # light at the hem
    else:
        poly(c, [(cx - 5, waist), (cx + 5, waist), (cx + 7, bottom - 14), (cx - 7, bottom - 14)], robe)
        poly(c, [(cx - 5, waist), (cx - 3, waist), (cx - 5, bottom - 14), (cx - 7, bottom - 14)], robe_d)
    if belt:
        c.row(waist, cx - 5, cx + 5, belt)
    # arms
    poly(c, [(cx - 7, top), (cx - 9, top + 2), (cx - 9, top + 12), (cx - 7, top + 12)], robe_d)   # far arm
    ellipse(c, cx - 8, top + 13, 1.5, 1.5, skin_d)
    if arm_forward:
        poly(c, [(cx + 6, top), (cx + 8, top + 1), (cx + 13, top + 5), (cx + 12, top + 7), (cx + 6, top + 4)], robe)
        ellipse(c, cx + 14, top + 6, 1.5, 1.5, skin)
    else:
        poly(c, [(cx + 7, top), (cx + 9, top + 2), (cx + 9, top + 12), (cx + 7, top + 12)], robe)
        ellipse(c, cx + 8, top + 13, 1.5, 1.5, skin)
    # neck and head
    c.rect(cx - 1, hy + 4, cx + 1, top, skin_d)
    ellipse(c, cx, hy, 4.5, 5.2, skin)
    c.px(cx - 4, hy + 1, skin_d); c.px(cx - 4, hy + 2, skin_d)                       # shaded cheek
    if ears:
        poly(c, [(cx - 4, hy), (cx - 8, hy - 3), (cx - 5, hy + 2)], skin)            # pointed elf ears
        poly(c, [(cx + 4, hy), (cx + 8, hy - 3), (cx + 5, hy + 2)], skin)
    # hair on top
    if hair_style != "none":
        ellipse(c, cx, hy - 3, 5, 3.2, hair)
        c.row(hy - 6, cx - 3, cx + 3, hair)
        c.px(cx - 5, hy - 1, hair); c.px(cx + 5, hy - 1, hair)
        if hair_style in ("long", "shoulder"):
            c.rect(cx - 6, hy - 2, cx - 5, hy + (9 if hair_style == "long" else 6), hair)
            c.rect(cx + 5, hy - 2, cx + 6, hy + (9 if hair_style == "long" else 6), hair)
        if hair_style == "bun":
            ellipse(c, cx, hy - 7, 2.5, 2, hair)
        c.px(cx - 2, hy - 4, hair_d); c.px(cx + 2, hy - 5, hair_d)                   # strands
    if beard:
        poly(c, [(cx - 4, hy + 2), (cx + 4, hy + 2), (cx + 3, hy + 9), (cx, hy + 12), (cx - 3, hy + 9)], beard)
    # face
    c.px(cx - 2, hy, eye); c.px(cx + 2, hy, eye)
    c.px(cx - 2, hy - 1, skin_d); c.px(cx + 2, hy - 1, skin_d)                       # lids
    c.row(hy - 2, cx - 3, cx - 1, hair_d if hair_style != "none" else skin_d)       # brows
    c.row(hy - 2, cx + 1, cx + 3, hair_d if hair_style != "none" else skin_d)
    c.px(cx, hy + 2, skin_d)                                                          # nose
    if not beard:
        c.row(hy + 3, cx - 1, cx + 1, mouth)
    if crown:
        c.row(hy - 5, cx - 4, cx + 4, crown)
        for x in (cx - 4, cx - 2, cx, cx + 2, cx + 4):
            c.px(x, hy - 6 - (1 if x == cx else 0), crown)
