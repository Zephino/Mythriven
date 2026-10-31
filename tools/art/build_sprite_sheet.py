# Sprite sheets of every picture in the game (owner request 10/31/2026), for the owner to look over and fix by hand.
# Reads every art file in data/art/ and draws each picture at 3x, named underneath, grouped by kind. Writes one sheet
# per kind to docs/art/sprites/<kind>.png and everything together to docs/art/sprite_sheet.png.
# Characters (Heroes, companions, enemies, bosses, gods, summons) show every frame: standing, the walking frames and,
# for gods, seated on their throne. Everything else shows the first frame of each picture.
# The sheets are generated: change the art in tools/art/build_*.py (or the data/art files), then run this again.
# Run: python3 build_sprite_sheet.py from tools/art/ (needs Pillow).
#
# Also writes one sheet per pack, docs/art/sprite_sheet_pack2.png (and pack3, pack4, pack5), with only the pictures that
# pack added (owner request 10/31/2026), so it's easy to see what's new; the bonus levels go on sprite_sheet_bonus.png.
# A picture belongs to the pack whose versions first added its art file (from git; the version ranges are in PACKS); the
# passive icons, which share one file, go by the pack of the secret that unlocks them.
import json, os, re, subprocess
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


# Sheet name -> (first version, last version, heading).
PACKS = {"pack2": ("00.02.53", "00.02.69", "Pack 2"), "pack3": ("00.02.70", "00.02.75", "Pack 3"),
         "pack4": ("00.02.77", "00.02.81", "Pack 4"), "bonus": ("00.02.82", "00.02.84", "Bonus levels"),
         "pack5": ("00.02.85", "99.99.99", "Pack 5")}


def first_version(path):
    """The version (XX.XX.XX) of the commit that first added `path`, or "" when git can't tell."""
    try:
        out = subprocess.run(["git", "log", "--diff-filter=A", "--format=%s", "--", path], cwd=ROOT,
                             capture_output=True, text=True, check=True).stdout.strip().splitlines()
    except (OSError, subprocess.CalledProcessError):
        return ""
    if not out:
        # Not committed yet: it is being added in the version being built now.
        return open(os.path.join(ROOT, "VERSION")).read().strip()
    found = re.search(r"v(\d\d\.\d\d\.\d\d)", out[-1])
    return found.group(1) if found else ""


def pack_of_version(version):
    for pack, (low, high, _title) in PACKS.items():
        if version and low <= version <= high:
            return pack
    return ""


def icon_packs():
    """Passive icon -> pack, by the secret that unlocks the passive."""
    secrets = {s["id"]: s for s in json.load(open(os.path.join(ROOT, "data", "secrets.json"))) if isinstance(s, dict)}
    by_secret = {}
    for pack, ids in (("pack2", ["the_pomegranate", "the_whetstone", "the_green_girdle", "the_plant_of_youth"]),
                      ("pack3", ["the_ski_chase", "the_seventh_labour", "seared_necks", "poisoned_sake"]),
                      ("pack4", ["laevateinn", "the_gnawed_root", "the_golden_key", "sindbads_escape"]),
                      ("bonus", ["the_nine_crows", "the_last_thread"]),
                      ("pack5", ["the_last_horn", "lauras_charm", "out_of_the_undergrowth", "the_empty_bower"])):
        for sid in ids:
            by_secret[sid] = pack
    out = {}
    for passive in json.load(open(os.path.join(ROOT, "data", "passives.json"))):
        secret = str((passive.get("unlock") or {}).get("secret", ""))
        if secret in by_secret and secret in secrets:
            out[passive["id"]] = by_secret[secret]
    return out


def pack_sheets():
    """One sheet per pack of the pictures it added."""
    icons = icon_packs()
    per_pack = {pack: [] for pack in PACKS}
    for kind, folder, title, every in KINDS:
        directory = os.path.join(ART, folder)
        groups = {pack: [] for pack in PACKS}
        for file in sorted(os.listdir(directory)):
            if not file.endswith(".json"):
                continue
            path = os.path.join(directory, file)
            if kind == "ui" and file == "icons.json":
                for label, image in tiles_for(path, "", False):
                    name = label.strip().replace("idle", "").strip()
                    if name in icons:
                        groups[icons[name]].append((name, image))
                continue
            pack = pack_of_version(first_version(os.path.relpath(path, ROOT)))
            if pack:
                groups[pack] += tiles_for(path, file[:-5], every)
        for pack, tiles in groups.items():
            if tiles:
                per_pack[pack].append(lay_out(title, tiles))
    for pack, sheets in per_pack.items():
        if not sheets:
            continue
        head = Image.new("RGB", (SHEET_W, 60), BG)
        ImageDraw.Draw(head).text((PAD, 14), "%s: new pictures" % PACKS[pack][2], fill=HEAD, font=TITLE)
        whole = Image.new("RGB", (SHEET_W, 60 + sum(s.height for s in sheets)), BG)
        whole.paste(head, (0, 0))
        y = 60
        for s in sheets:
            whole.paste(s, (0, y))
            y += s.height
        name = "sprite_sheet_%s.png" % pack
        whole.save(os.path.join(OUT, name))
        print("wrote docs/art/%s (%dx%d)" % (name, whole.width, whole.height))


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
    pack_sheets()
