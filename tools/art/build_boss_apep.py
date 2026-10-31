# Apep, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_apep.py from tools/art/.
# Writes data/art/bosses/apep.json.
import math
import hero_kit as kit
from hero_kit import poly

DOC = ("Apep, boss (GAME_DESIGN.md: The Two Lands bosses; art 10/31/2026). Built by tools/art/build_boss_apep.py; "
       "rules in docs/ART_RULES.md. From the Book of Gates and the Amduat (the vast serpent of chaos who attacks the "
       "sun's boat each night in the underworld) and the Book of Overthrowing Apep (Bremner-Rhind Papyrus), as tomb "
       "paintings show him: a huge coiled serpent, darker than the night, reared up with his jaws open. The biggest "
       "boss of the Two Lands.")

SIZE, ANCHOR = (84, 72), (40, 68)
WALK = [0.0, 1.0, 0.0, -1.0, 0.0]   # the sway of his coils for each frame

PALETTE = {
    "o": "#24160e", "k": "#140c08",
    "p": "#4a3060", "P": "#2e1c40", "q": "#6a4a88",  # scales: purple-black, shadow, a sheen along the back
    "v": "#c8b070", "V": "#9a844a",                 # pale belly scales
    "r": "#8a1a1a", "w": "#f0ead8", "e": "#ff4030",  # mouth, fangs, red eye
}

# His body from the tail tip to the neck: (x, y, radius). A coil along the ground curling back over itself, then the
# neck rising up and forward to the head.
PATH = [(3, 59, 1.2), (12, 62, 3.0), (24, 64, 5.0), (38, 63, 6.5), (50, 59, 7.0), (57, 51, 7.0), (53, 42, 6.5),
        (43, 39, 6.0), (34, 43, 6.0), (33, 33, 5.6), (40, 24, 5.2), (50, 18, 5.0), (58, 15, 4.8)]


def body(c, sway):
    pts = []
    for (ax, ay, ar), (bx, by, br) in zip(PATH, PATH[1:]):
        for i in range(10):
            t = i / 10
            pts.append([ax + (bx - ax) * t, ay + (by - ay) * t, ar + (br - ar) * t])
    pts.append(list(PATH[-1]))
    for k, p in enumerate(pts):                      # his coils sway as he moves
        p[1] += math.sin(k / len(pts) * math.pi * 3) * sway * 1.2
    n = len(pts)
    normals = []
    for k in range(n):
        ax, ay = pts[max(k - 1, 0)][:2]; bx, by = pts[min(k + 1, n - 1)][:2]
        tx, ty = bx - ax, by - ay
        L = math.hypot(tx, ty) or 1
        nx, ny = -ty / L, tx / L
        if ny < 0 or (abs(ny) < 0.2 and nx < 0):
            nx, ny = -nx, -ny                        # the belly side faces down (or forward, where he rears up)
        normals.append((nx, ny))
    for y in range(c.h):
        for x in range(c.w):
            front = -1
            for k, (px_, py_, r) in enumerate(pts):
                if math.hypot(x - px_, y - py_) <= r:
                    front = k
            if front < 0:
                continue
            near = min(range(max(front - 14, 0), min(front + 15, n)),
                       key=lambda j: math.hypot(x - pts[j][0], y - pts[j][1]) / pts[j][2])
            px_, py_, r = pts[near]
            if math.hypot(x - px_, y - py_) > r:
                near = front; px_, py_, r = pts[near]
            nx, ny = normals[near]
            side = ((x - px_) * nx + (y - py_) * ny) / max(r, 1)
            col = "v" if side > 0.55 else ("q" if side < -0.6 else "p")
            if 0.4 < side <= 0.55:
                col = "V"
            if col == "p" and near % 9 in (0, 1):
                col = "P"                                # dark bands across his back
            c.px(x, y, col)
    # A dark edge where a coil passes over another
    for k, (x, y, r) in enumerate(pts):
        for j in range(0, max(k - 20, 0)):
            ox, oy, orr = pts[j]
            if math.hypot(x - ox, y - oy) < r + orr - 1:
                for a in range(0, 360, 6):
                    ex = round(x + math.cos(math.radians(a)) * (r + 0.6)); ey = round(y + math.sin(math.radians(a)) * (r + 0.6))
                    inside_later = any(math.hypot(ex - pts[m][0], ey - pts[m][1]) <= pts[m][2] for m in range(k - 3, min(k + 4, n)))
                    if not inside_later and math.hypot(ex - ox, ey - oy) <= orr and 0 <= ex < c.w and 0 <= ey < c.h:
                        c.px(ex, ey, "o")
                break


def head(c):
    """Reared up, jaws open: a heavy wedge-shaped skull, a red eye, fangs."""
    poly(c, [(54, 8), (64, 6), (72, 9), (76, 12), (66, 14), (56, 17)], "p")            # skull and upper jaw
    poly(c, [(58, 18), (66, 17), (76, 22), (74, 24), (60, 23)], "v")                   # lower jaw, pale
    poly(c, [(60, 15), (76, 12), (76, 21), (64, 18)], "r")                             # open mouth
    c.px(73, 13, "w"); c.px(73, 14, "w"); c.px(68, 14, "w"); c.px(68, 15, "w")          # fangs
    c.px(72, 20, "w"); c.px(67, 18, "w")
    c.row(7, 58, 70, "q"); c.px(76, 11, "k")
    c.rect(63, 9, 64, 10, "e"); c.px(64, 10, "k")                                       # red eye
    c.row(11, 61, 66, "P")                                                             # the ridge over the eye


def draw(c, sway):
    body(c, sway)
    head(c)


if __name__ == "__main__":
    kit.build_boss("apep", draw, PALETTE, DOC, SIZE, ANCHOR, WALK)
    print("wrote data/art/bosses/apep.json")
