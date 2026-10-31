# Sprite sheets of every picture in the game (owner request 10/31/2026), for the owner to look over and fix by hand.
# Reads every art file in data/art/ and draws each picture at 3x, named underneath, grouped by kind. Writes one sheet
# per kind to docs/art/sprites/<kind>.png and everything together to docs/art/sprite_sheet.png.
# Characters (Heroes, companions, enemies, bosses, gods, summons) show every frame: standing, the walking frames and,
# for gods, seated on their throne. Everything else shows the first frame of each picture.
# The sheets are generated: change the art in tools/art/build_*.py (or the data/art files), then run this again.
# Run: python3 build_sprite_sheet.py from tools/art/ (needs Pillow).
import json, os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
ART = os.path.join(ROOT, "data", "art")
OUT = os.path.join(ROOT, "docs", "art")
SCALE = 3
PAD = 10
SHEET_W = 2400
BG = (44, 46, 54)
CELL_BG = (70, 72, 82)
TEXT = (235, 232, 222)
HEAD = (240, 200, 110)

# (kind, folder under data/art, title, show every frame)
KINDS = [
    ("heroes", "", "Heroes", True),
    ("companions", "companions", "Companions", True),
    ("enemies", "enemies", "Enemies", True),
    ("bosses", "bosses", "Bosses", True),
    ("gods", "gods", "Gods (standing, walking, seated, throne)", True),
    ("summons", "summons", "God summons", True),
    ("weapons", "weapons", "Weapons", False),
    ("projectiles", "projectiles", "Projectiles", False),
    ("pickups", "pickups", "Pickups", False),
    ("scenery", "scenery", "Scenery", False),
    ("flora", "flora", "Trees and bushes (by level)", False),
    ("critters", "critters", "Critters and animals (by level)", False),
    ("ground", "ground", "Ground tiles (by level)", False),
    ("mountain", "mountain", "Mountain parts (by level)", False),
    ("shrines", "shrines", "Shrine parts", False),
    ("dungeon", "dungeon", "Dungeon and cave parts", False),
    ("ui", "ui", "Menu frames and icons", False),
    ("menu", "menu", "Menu backdrops", False),
]

try:
    FONT = ImageFont.load_default(size=14)
    TITLE = ImageFont.load_default(size=26)
except TypeError:
    FONT = TITLE = ImageFont.load_default()


def colour(value):
    if isinstance(value, str) and value.startswith("#") and len(value) >= 7:
        return tuple(int(value[i:i + 2], 16) for i in (1, 3, 5)) + ((int(value[7:9], 16),) if len(value) >= 9 else (255,))
    return None


def picture(rows, palette):
    """One frame (a list of rows of palette letters) as an image, at SCALE."""
    rows = [str(r) for r in rows]
    if not rows:
        return None
    w, h = max(len(r) for r in rows), len(rows)
    image = Image.new("RGBA", (w, h), CELL_BG + (255,))
    for y, row in enumerate(rows):
        for x, letter in enumerate(row):
            c = palette.get(letter)
            if c is not None and c[3] > 0:
                image.putpixel((x, y), c)
    return image.resize((w * SCALE, h * SCALE), Image.NEAREST)


def is_frame(value):
    return isinstance(value, list) and value and all(isinstance(r, str) for r in value)


def tiles_for(path, label, every_frame):
    """(label, image) for each picture in one art file."""
    data = json.load(open(path))
    palette = {k: colour(v) for k, v in data.get("palette", {}).items()}
    out = []
    for name, frames in (data.get("frames") or {}).items():
        if is_frame(frames):                       # a single frame stored without the list round it
            frames = [frames]
        if not isinstance(frames, list):
            continue
        chosen = frames if every_frame else frames[:1]
        for k, frame in enumerate(chosen):
            if not is_frame(frame):
                continue
            image = picture(frame, palette)
            if image is None:
                continue
            tag = label if name == "idle" and k == 0 else "%s %s%s" % (label, name, " %d" % (k + 1) if len(chosen) > 1 else "")
            out.append((tag, image))
    return out


def text_width(draw, text, font):
    box = draw.textbbox((0, 0), text, font=font)
    return box[2] - box[0]


def shorten(draw, text, width):
    while text and text_width(draw, text, FONT) > width:
        text = text[:-2] + "…" if not text.endswith("…") else text[:-2] + "…"
    return text


def lay_out(title, tiles):
    """Packs tiles in rows under a title; returns the sheet image."""
    scratch = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    cells = []
    for label, image in tiles:
        w = max(image.width, min(text_width(scratch, label, FONT), 220)) + PAD
        cells.append((label, image, w, image.height + 22))
    rows, row, x = [], [], PAD
    for cell in cells:
        if row and x + cell[2] > SHEET_W - PAD:
            rows.append(row)
            row, x = [], PAD
        row.append(cell)
        x += cell[2]
    if row:
        rows.append(row)
    height = 50 + sum(max(c[3] for c in r) + PAD for r in rows) + PAD
    sheet = Image.new("RGB", (SHEET_W, height), BG)
    draw = ImageDraw.Draw(sheet)
    draw.text((PAD, 12), "%s  (%d)" % (title, len(tiles)), fill=HEAD, font=TITLE)
    y = 50
    for r in rows:
        x = PAD
        tallest = max(c[3] for c in r)
        for label, image, w, h in r:
            top = y + (tallest - h)
            sheet.paste(image, (x, top), image)
            draw.text((x, top + image.height + 3), shorten(draw, label, w - 4), fill=TEXT, font=FONT)
            x += w
        y += tallest + PAD
    return sheet


if __name__ == "__main__":
    os.makedirs(os.path.join(OUT, "sprites"), exist_ok=True)
    sheets = []
    total = 0
    for kind, folder, title, every in KINDS:
        directory = os.path.join(ART, folder)
        tiles = []
        for file in sorted(os.listdir(directory)):
            if file.endswith(".json"):
                tiles += tiles_for(os.path.join(directory, file), file[:-5], every)
        if not tiles:
            continue
        sheet = lay_out(title, tiles)
        sheet.save(os.path.join(OUT, "sprites", kind + ".png"))
        sheets.append(sheet)
        total += len(tiles)
        print("%-12s %4d pictures" % (kind, len(tiles)))
    whole = Image.new("RGB", (SHEET_W, sum(s.height for s in sheets)), BG)
    y = 0
    for s in sheets:
        whole.paste(s, (0, y))
        y += s.height
    whole.save(os.path.join(OUT, "sprite_sheet.png"))
    print("wrote docs/art/sprite_sheet.png and %d sheets in docs/art/sprites/ (%d pictures, %dx%d)" % (len(sheets), total, whole.width, whole.height))
