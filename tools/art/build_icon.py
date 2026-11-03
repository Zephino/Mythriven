# Builds Mythriven's icon (owner request 11/03/2026: replace the Godot icon): a carved gold M, the title logo's letter
# (build_menu_art.py), in a laurel wreath tied with a red ribbon, on the game's dark purple, drawn at 32 x 32 and
# scaled up without smoothing. Writes icon.png (the project's icon: browser tab, window, desktop) and the web app's
# icons in assets/icons/ (installed app on phones and desktops).
# Run: python3 build_icon.py from tools/art/.
import os, sys, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
from build_menu_art import GLYPHS
def hexc(h): return tuple(int(h[i:i+2],16) for i in (1,3,5))
N=32
img=Image.new('RGBA',(N,N),(0,0,0,0)); px=img.load()
bg=hexc('#1b1622'); bg2=hexc('#2a2034'); rim=hexc('#e8c46a')
# rounded square background
for y in range(N):
    for x in range(N):
        cx, cy = min(x, N-1-x), min(y, N-1-y)
        if cx+cy >= 3 or (cx>=2 and cy>=2):
            if not (cx < 2 and cy < 2 and cx+cy < 3):
                d = math.hypot(x-15.5, y-15.5)
                px[x,y] = (bg2 if d < 11 else bg) + (255,)
# laurel wreath: two arcs of leaves round the letter
leaf=hexc('#6a9a3a'); leafd=hexc('#3e6a24')
for k in range(16):
    a = math.radians(112 + k*9)
    for side in (1,-1):
        ang = a if side == 1 else math.pi - a
        for rad, col in ((12.4, leafd), (11.4, leaf), (10.6, leaf)):
            x = 15.5 + rad*math.cos(ang + side*0.05*(rad-11)); y = 16.2 + rad*math.sin(ang + side*0.05*(rad-11))
            if (k + int(rad)) % 3 != 0 or rad == 11.4:
                px[int(round(x)), int(round(y))] = col + (255,)
for x in (14, 15, 16, 17):
    px[x, 29] = hexc('#c83a3a') + (255,)                 # the ribbon tying the wreath
# the gold M, carved
g = GLYPHS['M']; s = 2
gold=[hexc('#fff0a8'),hexc('#f0cc58'),hexc('#d8a838'),hexc('#a87818')]
w=len(g[0])*s; h=len(g)*s
x0=(N-w)//2; y0=(N-h)//2
pts=set()
for gy,row in enumerate(g):
    for gx,ch in enumerate(row):
        if ch=='X':
            for dy in range(s):
                for dx in range(s):
                    pts.add((x0+gx*s+dx, y0+gy*s+dy))
for (x,y) in pts:                                   # bevel and outline
    for ddx,ddy in ((1,1),):
        if (x+ddx,y+ddy) not in pts: px[x+ddx,y+ddy]=hexc('#6a4410')+(255,)
outline=set()
for (x,y) in pts:
    for ddx,ddy in ((1,0),(-1,0),(0,1),(0,-1),(1,1)):
        q=(x+ddx,y+ddy)
        if q not in pts: outline.add(q)
for (x,y) in outline:
    if px[x,y][:3]!=hexc('#6a4410'): px[x,y]=hexc('#140c08')+(255,)
for (x,y) in pts:
    band=min(3,(y-y0)*4//h)
    px[x,y]=gold[band]+(255,)
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
img.resize((512, 512), Image.NEAREST).save(os.path.join(ROOT, "icon.png"))           # the game's icon (project, PC)
for n in (144, 180, 512):                                                               # the web app's icons
    img.resize((n, n), Image.NEAREST).save(os.path.join(ROOT, "assets", "icons", "icon_%d.png" % n))
print("wrote icon.png and assets/icons/icon_144.png, icon_180.png, icon_512.png")
