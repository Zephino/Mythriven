# Scáthach, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_scathach.py from tools/art/ (after
# build_scathach.py and build_weapons.py). Writes data/art/bosses/scathach.json.
# The boss is the Hero players unlock by defeating her (data/art/scathach.json) holding her spear, at twice the size.
import hero_kit as kit

DOC = ("Scáthach, boss (GAME_DESIGN.md: The Misty Isles bosses; art 10/31/2026). Built by "
       "tools/art/build_boss_scathach.py from her Hero art (data/art/scathach.json, sources there) holding her spear "
       "(data/art/weapons/scathach_spear.json), drawn twice as big: the warrior-teacher you must defeat.")

if __name__ == "__main__":
    art = kit.build_hero_boss("scathach", "scathach_spear", DOC)
    print("wrote data/art/bosses/scathach.json", art["size"])
