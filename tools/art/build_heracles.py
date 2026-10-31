# Builds data/art/heracles.json from shapes (docs/ART_RULES.md). Run:
#   python3 tools/art/build_heracles.py /tmp/heracles_frames.json
# then copy its "palette" and "all" (as "frames") into data/art/heracles.json.
import json, sys
W, H = 24, 34
g = []
def px(x, y, c):
    if 0 <= x < W and 0 <= y < H: g[y][x] = c
def rect(x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1): px(x, y, c)
def row(y, x0, x1, c): rect(x0, y, x1, y, c)

def draw(back_leg, front_leg):
  global g
  g = [["." for _ in range(W)] for _ in range(H)]
  _draw(back_leg, front_leg)
  return outline()


def _draw(back_leg, front_leg):
    # Lion-skin cloak down his back: draped off the back shoulder, widening to
    # a ragged furry edge, with the lion's hind paw hanging at the bottom.
    for y in range(8, 27):
        width = 2 if y < 14 else (3 if y < 21 else 4)
        x0 = 9 - width
        row(y, x0, 8, "L")
        px(x0, y, "m")                      # dark fur along the outer edge
        if y % 3 == 0:
            px(x0 + 1, y, "l")              # lighter tufts of fur
    for x in (5, 7):
        px(x, 27, "L"); px(x, 28, "m")      # ragged hem
    rect(5, 29, 6, 29, "l"); px(5, 30, "w"); px(6, 30, "w")   # the hind paw and its claws
    # Lion head hood
    row(1, 10, 11, "m")                       # ear
    row(2, 9, 15, "l"); px(10, 2, "L")
    row(3, 9, 16, "l")
    row(4, 9, 17, "l"); px(15, 3, "k")        # lion's eye
    row(5, 9, 18, "L")                        # brow and snout over his forehead
    row(6, 9, 18, "L"); px(9, 5, "m"); px(9, 6, "m")
    px(17, 7, "w"); px(18, 7, "w")            # lion's teeth at the tip of the snout
    row(7, 10, 16, "L")
    # Face in profile
    rect(11, 8, 16, 10, "s"); rect(11, 8, 12, 10, "S")
    px(15, 9, "k"); px(17, 9, "s")            # eye, nose
    # Short beard
    rect(12, 11, 16, 12, "h"); px(12, 11, "H"); px(12, 12, "H"); px(16, 11, "s")
    # Neck and the lion's paws knotted at the throat
    row(13, 11, 16, "s"); px(12, 13, "l"); px(13, 13, "l"); px(14, 13, "L"); px(15, 13, "l")
    # Bare, muscled chest
    rect(10, 14, 17, 19, "s"); rect(10, 14, 11, 19, "S")
    row(16, 12, 13, "S"); row(16, 15, 16, "S"); px(14, 17, "S"); px(14, 18, "S")   # chest and stomach lines
    # Front arm, hand gripping the club
    rect(18, 14, 19, 19, "s"); rect(17, 15, 17, 19, "o"); px(19, 14, "S"); rect(18, 20, 19, 20, "s")
    # Belt with a bronze buckle
    row(20, 10, 17, "b"); px(14, 20, "y")
    # Dark red chiton to the knees, flaring a little, with folds
    for y in range(21, 26):
        x0, x1 = (10, 17) if y < 24 else (9, 18)
        row(y, x0, x1, "r")
        for x in range(x0 + 1, x1, 3): px(x, y, "R")
    row(25, 9, 18, "R")
    # Legs with laced sandals
    for x0 in (back_leg, front_leg):
        rect(x0, 26, x0 + 2, 31, "s"); px(x0, 26, "S"); px(x0, 27, "S")
        row(28, x0, x0 + 2, "b"); px(x0 + 1, 29, "b")
        row(31, x0, x0 + 3, "b")
    # Club: a thin handle showing below the hand, widening into a heavy rounded
    # head that rests by his feet; knots are dark marks on the wood.
    for y, x0, x1 in [(18,21,21),(19,21,21),(20,21,21),(21,21,21),(22,21,22),(23,21,22),(24,21,23),(25,21,23),
                      (26,21,24),(27,21,24),(28,21,24),(29,21,24),(30,22,23)]:
        row(y, x0, x1, "c")
        if x1 > x0: px(x1, y, "C")
    rect(20, 20, 20, 20, "s")                                   # fingers round the handle
    for (x, y) in [(22,25),(23,28),(22,29)]: px(x, y, "C")     # knots

# Dark outline around everything
def outline():
    fill = [r[:] for r in g]
    for y in range(H):
        for x in range(W):
            if fill[y][x] == ".":
                for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < W and 0 <= ny < H and fill[ny][nx] != ".":
                        g[y][x] = "o"; break
    return ["".join(r) for r in g]

idle = draw(11, 15)
frames = {"idle": [idle], "walk": [draw(10, 16), idle, draw(12, 14), idle]}
palette = {
 "o": "#24160e", "l": "#d6a040", "L": "#a06a24", "m": "#6e4216", "w": "#f6efe0", "k": "#140c08",
 "s": "#e2a676", "S": "#b0724a", "h": "#3e2414", "H": "#2a180c",
 "r": "#a83a2c", "R": "#7a2620", "b": "#5c3a1c", "y": "#d8b048", "c": "#9a6232", "C": "#553012"
}
json.dump({"palette": palette, "frames": [idle] + frames["walk"], "all": frames}, open(sys.argv[1], "w"), indent=1)
