# Builds data/art/heracles.json from shapes (docs/ART_RULES.md). Run:
#   python3 tools/art/build_heracles.py /tmp/heracles_frames.json
# then copy its "palette", "hand", and "all" (as "frames") into data/art/heracles.json.
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
    # No cloak hanging behind (owner request 10/31/2026): the lion skin shows as
    # the hood and the paws knotted at his throat.
    # Far (left) arm hanging at his side, in the skin's shadow colour since it's
    # further away; a 1-pixel gap from the chest becomes a dark edge.
    rect(7, 14, 8, 20, "S"); px(8, 14, "s"); px(8, 15, "s")   # shoulder catches a little light
    rect(7, 21, 8, 21, "s")                                      # fist
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
    # Front arm held a little out from his side, so his weapon hangs clear of his
    # body (owner request 10/31/2026): upper arm down, forearm angled outward.
    rect(18, 14, 19, 17, "s"); rect(17, 15, 17, 17, "o"); px(19, 14, "S")
    rect(19, 18, 20, 19, "s"); px(19, 19, "S")                  # forearm angling out
    rect(20, 20, 21, 20, "s")                                   # fist
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
    # His weapon is drawn separately (data/art/weapons/, tools/art/build_weapons.py)
    # and placed at his hand ("hand" in the art file); fingers wrap round it.
    px(22, 20, "s")                                             # fingers round the grip

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
json.dump({"palette": palette, "frames": [idle] + frames["walk"], "all": frames, "hand": [22, 20]}, open(sys.argv[1], "w"), indent=1)
