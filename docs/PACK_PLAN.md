# Pack Plan — Packs 2, 3, and 4

Written 10/29/2026 at the owner's request, after Pack 1 was reviewed (`docs/reviews/PHASE_01-20_REVIEW.md`). This is a **plan, not approval to build**. Each pack starts only when the owner says so, and only after the pack before it is working, tested, and fun (`GAME_DESIGN.md`: Pack roadmap).

Everything named here (levels, gods, bosses, enemy families, hazards, Heroes) comes from `GAME_DESIGN.md` (Regional levels, Gods added with Acts II–III, Acts II–IV bosses, Post-launch Heroes, Fantasy realms). Nothing is invented. Where the design leaves a gap, it's listed under **Owner decisions** instead of being filled in.

## How every pack is built

Each pack has the same shape, which keeps it manageable:

1. **Groundwork phase:** the systems the pack's four levels share (new shrine types, new hazards for the hazard library, the Act unlock).
2. **One phase per level:** tileset (placeholder art is fine), hazard, enemy families (3–4 new at most), wave table, 3 bosses, and local gods, the same as Phases 16–18.
3. **Wrap-up phase:** the pack's Heroes and Resonances, balance, a full playthrough, and a review with Claude.

Rules carried over from Pack 1:
- All text goes in `localization/text.csv`, all numbers in data files, and every new Hero, god, and boss gets `lore_source` and `lore_verified: false` until the owner signs off.
- **Reuse first:** levels from the same culture share about half their enemies, decorations, and music. Every boss is the shared pattern library plus one signature script. Every hazard is a mix of the hazard library.
- Co-op keeps working: every new system that changes the world gets a `CoopMirror` (or events), and the two-device test is part of each wrap-up.
- **Unlock flow:** clearing all four 20:00 bosses in an Act opens the next Act. The level select map grows with each pack.

---

## Pack 2 — Deeper Myths (Act II)

**Levels, gods, and bosses** (all from `GAME_DESIGN.md`)

| Phase | Level | Hazard (hazard library) | Enemy families | Local gods | Bosses (10 / 20 / 30 min) |
| --- | --- | --- | --- | --- | --- |
| 22 | **The Underworld** (Greek) | Rivers of the dead slow and drain (slow ground); chasms collapse, telegraphed (collapsing ground) | Shades, Furies-kin flyers, skeletal hoplites, Stymphalian birds | Hecate, Persephone | Cerberus · Thanatos · Typhon |
| 23 | **Jotunheim** (Norse) | Rockslides from cliffs (strikes) | Frost Thursar, Trolls, giant wolves, ice wisps | Odin, Freyja | Hrungnir · Thrym · Ymir |
| 24 | **Avalon's Shadow** (Welsh / Arthurian) | Enchanted brambles grow and block paths (**new** hazard script) | Black knights, enchanted hounds, Afanc, will-o'-wisps | Rhiannon, Arawn | The Green Knight · Mordred · Twrch Trwyth |
| 25 | **The Land Between the Rivers** (Mesopotamian) | Floods sweep across in bands (sweeping bands) | Scorpion-men, Ugallu storm-demons, dust demons, river serpents | Enki, Shamash | Humbaba · The Bull of Heaven · Tiamat (original design, not D&D's) |

**Phase 21 — Pack 2 groundwork**
- Act II unlock (all four Act I 20:00 bosses) and the level select map's second row.
- New shrine bindings: Odin's **Sacrifice** (bind by giving up 30% Max HP), and Rhiannon's chase that only binds when you **stand still**.
- New hazard scripts: collapsing ground, growing brambles. Slow-and-drain ground (slow ground plus a damage tick).
- Boss toolkit additions: bosses with separate parts (Cerberus' three heads, Humbaba's 7 shield layers), a "steal a weapon for 20 s" mechanic (Thrym), and arena rotation (Typhon).
- Mordred's special lines for King Arthur and Thanatos' lines for Heracles (banter data).

**Phase 26 — Pack 2 wrap-up**
- New Resonances, preferring pairs with a mythic link (the design names Odin + Freyja and Shamash + Enki); numbers designed then.
- Pack 2 Heroes from the post-launch list (see owner decision 1).
- Full 30-minute run on each level, co-op test on two devices, balance pass, review with Claude.

**Done when**
- [ ] All four levels play a full 30-minute run with all 3 bosses, and hazards pause in boss arenas.
- [ ] All 8 new gods can be found, bound (including Sacrifice and stand-still binding), and summoned.
- [ ] Clearing Act I's four 20:00 bosses opens Act II and saves at once.
- [ ] Co-op works on every new level (bosses, hazards, and new shrines show the same on both devices).

**Owner decisions for Pack 2**
1. Which post-launch Heroes come with Pack 2? Suggested from the design's list by culture: Orpheus or Perseus (Greek, Underworld), Sigurd or Brynhild (Norse, Jotunheim), Gilgamesh (Mesopotamian, Rivers). Pick some, all, or none.
2. Add the post-launch reactions **Toxic Flare** (Fire + Poison) and **Eclipse** (Holy + Dark) with this pack? (Hecate and Thanatos make Dark common here.)
3. The alternate boss per slot (Typhon, Hydra, Jörmungandr, Ymir) is post-launch: Typhon and Ymir are already 30:00 bosses here. Keep them as fixed bosses (as the Act II table says)?

---

## Pack 3 — Distant Legends (Act III)

| Phase | Level | Hazard | Enemy families | Local gods | Bosses (10 / 20 / 30 min) |
| --- | --- | --- | --- | --- | --- |
| 28 | **Pohjola** (Finnish, Kalevala) | Polar night: darkness pulses, shrinking vision (darkness / vision shrink) | Hiisi forest-spirits, frost-wolves, swamp beasts | Ukko\*, Ilmatar\* | The Elk of Hiisi · Iku-Turso · Louhi |
| 29 | **Mazandaran** (Persian, Shahnameh) | Sorcerous darkness clouds (darkness) | Divs, sorcerers, wild lions, dragons-kin | Simurgh\*\* (special summon, not a god) | The Dragon of Rostam's Third Labor · The Witch of the Fourth Labor · The White Div |
| 30 | **The Slavic Wilds** (Slavic) | Will-o'-wisp lights lure enemies and briefly confuse controls (**new** hazard script) | Leshy-kin, Rusalki (water casters), wolves, firebirds-kin | Perun, Mokosh | Zmey Gorynych · Baba Yaga · Koschei the Deathless |
| 31 | **The Land of Legends** (Japanese historical legend) | Falling cherry-blossom storms reduce vision (vision shrink) | Oni, tengu-kin, earth spiders, restless warriors | none\*\*\* (shrines from all pantheons) | Tsuchigumo · Benkei (unlocks Benkei) · Shuten-dōji |

\* Not in the reference database: verify before use. \*\* No Persian gods: Zoroastrianism is a living religion. \*\*\* Shinto kami are Tier B.

**Phase 27 — Pack 3 groundwork**
- Act III unlock and the level select map's third row.
- The **Simurgh** mechanic: no shrine; elites drop feathers, collect 3, burn one to call her.
- Levels with no local gods draw 100% of shrines from any unlocked pantheon (Land of Legends).
- New hazard script: wisp lights that lure enemies and briefly confuse controls (with an accessibility setting to soften the confusion).
- Boss toolkit additions: a hidden weak point on the map (Koschei's egg), decoys (the Witch of the Fourth Labor), heads that regrow unless finished with Fire or Holy (Zmey), "must be slowed first" (Elk of Hiisi), a narrow-bridge arena (Benkei), and darkness that reveals only near light (the Dragon).

**Phase 32 — Pack 3 wrap-up**
- Benkei as a playable Hero (boss unlock, like Achilles and Scáthach).
- New Resonances (the design names Perun + Mokosh and Ukko + Poseidon).
- Pack 3 Heroes from the post-launch list (owner decision 1).
- Full runs, two-device co-op test, balance, review with Claude.

**Done when**
- [ ] All four levels play a full 30-minute run with all 3 bosses.
- [ ] The Simurgh can be called with feathers; Land of Legends shrines come from every pantheon.
- [ ] Defeating Benkei unlocks him and saves at once.
- [ ] Co-op works on every new level.

**Owner decisions for Pack 3**
1. Which post-launch Heroes come with Pack 3? Suggested from the design's list: Rostam, Gordafarid, or Arash the Archer (Persian epic, Mazandaran), and Minamoto no Yoshitsune (Japanese legend). Benkei comes from his boss fight.
2. Ukko and Ilmatar aren't in the reference database. Find sources and approve them, or swap Pohjola's gods?
3. The "confused controls" hazard can frustrate on phones. Keep it, or make it lighter (lights only lure enemies)?

---

## Pack 4 — Elemental Planes (fantasy realms)

The Pack roadmap makes Pack 4 the **Elemental Planes**. (The Act IV extras, the Realm of the Ten Suns and the Crossroads finale, are listed separately as "Extra" and come later. See owner decision 1.)

| Phase | Realm | Realm type | Public-domain source | Boss in the design | Bosses still needed |
| --- | --- | --- | --- | --- | --- |
| 35 | **Muspelheim** | Fire realm of salamanders | Norse Eddas; salamanders from Paracelsus | Sinmara, the fire-giantess | 2 |
| 36 | **Niflheim** | Ice realm | Norse Eddas | Níðhöggr, the dragon gnawing at the world-tree's roots | 2 |
| 37 | **Ys** | Sunken water city of undines | Breton legend; undines from Paracelsus | Dahut, the princess who opened the sea gates | 2 |
| 38 | **Cloud-Cuckoo-Land** | Sky realm of sylphs | Aristophanes' *The Birds*; sylphs from Paracelsus | The Roc (*One Thousand and One Nights*) | 2 |

Realms use the same structure as myth levels (endless map, hazard, enemy families, 3 bosses) and draw shrine gods from **every** unlocked pantheon. They have no local gods.

**Phase 33 — Pack 4 design (owner and Claude, no code)**
The design says each fantasy realm "still needs two more bosses designed per level, from the same public-domain lore." It also gives these realms no hazards or enemy families yet. Before any building:
- 8 more bosses (2 per realm), each from that realm's own public-domain source.
- One hazard per realm, picked from the hazard library where possible.
- 3–4 enemy families per realm from the race names the design already lists (salamanders, undines, sylphs, plus Norse realm creatures from the Eddas).
- Add them to `GAME_DESIGN.md` with owner approval, then build.

**Phase 34 — Pack 4 groundwork**
- How realms unlock and appear on the level select map (realms can mix with myth packs in any order).
- "All pantheons" shrines in every realm (reuses the Land of Legends rule).
- Element-themed level effects, if the approved hazards need them.

**Phase 39 — Pack 4 wrap-up**
- Full runs, two-device co-op test, balance, review with Claude.

**Done when**
- [ ] The Phase 33 design is approved in `GAME_DESIGN.md`.
- [ ] All four realms play a full 30-minute run with all 3 bosses.
- [ ] Shrines in realms offer gods from every unlocked pantheon.
- [ ] Co-op works in every realm.

**Owner decisions for Pack 4**
1. The roadmap says Pack 4 is the Elemental Planes, but Act IV (the Realm of the Ten Suns, which unlocks Hou Yi, and the Crossroads finale with the Unweaver) is fully designed already. Build the **Elemental Planes** as Pack 4 (roadmap order), or do the **Act IV extras** first?
2. Approve Claude drafting the 8 missing realm bosses, hazards, and enemy families from the named public-domain sources, for your review? (Nothing is built until you approve.)
3. Ys and Cloud-Cuckoo-Land have famous modern versions. Confirm we design only from the old texts (as the design's notes say).

---

## Rough size

| Pack | Phases | New gods | New bosses | New Heroes |
| --- | --- | --- | --- | --- |
| 2 | 21–26 (6) | 8 | 12 | owner's pick |
| 3 | 27–32 (6) | 4 plus the Simurgh | 12 | Benkei, plus owner's pick |
| 4 | 33–39 (7) | none (all pantheons) | 12 (8 still to design) | none planned |

**Before Pack 2 starts:** the owner says Pack 1 is done (review decision 1). Choosing an art direction first would also help, so new tilesets aren't drawn twice.
