# Achilles, boss (docs/ART_RULES.md: Bosses). Run: python3 build_boss_achilles.py from tools/art/ (after
# build_achilles.py and build_weapons.py). Writes data/art/bosses/achilles.json.
# The boss is the Hero players already know (data/art/achilles.json) holding his spear, at twice the size, so he's
# recognised at once and stands out as a boss.
import hero_kit as kit

DOC = ("Achilles, boss (GAME_DESIGN.md: The Aegean Shore bosses; art 10/31/2026). Built by "
       "tools/art/build_boss_achilles.py from his Hero art (data/art/achilles.json, sources there) holding his spear "
       "(data/art/weapons/spear_and_shield.json), drawn twice as big: the rival Hero you duel.")

if __name__ == "__main__":
    art = kit.build_hero_boss("achilles", "spear_and_shield", DOC)
    print("wrote data/art/bosses/achilles.json", art["size"])
