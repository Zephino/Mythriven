# Lore check (Phase 19)

**Status: needs owner review.** Nothing here is marked verified yet. The design (GAME_DESIGN.md, Phase 19) asks for every launch Hero, god, and boss to be checked against its sources before `lore_verified` is set to `true`. Only the owner can approve that.

How to use this list:

1. For each row, read the listed source (or a trusted museum or university summary of it).
2. Check that the name and spelling, tradition, epithets, and the story behind the Legend Trait, passive, summon, or signature attack match the source and are respectful (GAME_DESIGN.md naming and cultural rules).
3. Tell Claude or Cursor which rows are approved. Only then is `lore_verified` flipped to `true` in the data file.

Care tier A means extra care: a living religion, a national hero, or a figure with strong cultural meaning today.

## Heroes (`data/heroes.json`)

| Id | Name | Tradition | Care tier | Source in data | Verified |
| --- | --- | --- | --- | --- | --- |
| heracles | Heracles | Greek | A | Pseudo-Apollodorus, Bibliotheca (The Library), Book 2: Heracles and the Twelve Labors | no |
| cu_chulainn | Cú Chulainn | Irish | A | Táin Bó Cúailnge (the Ulster Cycle), including the salmon leap and the warp-spasm | no |
| vainamoinen | Väinämöinen | Finnish (Kalevala) | A | Kalevala (Elias Lönnrot, 1835/1849): Väinämöinen, the eternal singer | no |
| tomoe_gozen | Tomoe Gozen | Japanese legend | A | The Tale of the Heike (Heike monogatari), Kakuichi text, Book 9: Tomoe Gozen | no |
| achilles | Achilles | Greek | A | Homer, Iliad (book 18 for the shield Hephaestus forged); Statius, Achilleid (made nearly invulnerable, save the heel). Unlocked by defeating him on the Aegean Shore. | no |
| king_arthur | King Arthur | Welsh/Arthurian | A | Thomas Malory, Le Morte d'Arthur (1485), book 1 ch. 25 (Excalibur and its scabbard: whoever wears it loses no blood); Geoffrey of Monmouth, Historia Regum Britanniae | no |
| atalanta | Atalanta | Greek | A | Apollodorus, Library 3.9.2; Ovid, Metamorphoses 10.560–707 (the footrace and the golden apples) | no |
| odysseus | Odysseus | Greek | A | Homer, Odyssey (book 21: the contest of the bow; books 13–22: his return disguised as a beggar; book 9: the ruse of 'Nobody') | no |
| scathach | Scáthach | Irish | A | Tochmarc Emire (The Wooing of Emer); Aided Óenfir Aífe. Unlocked by defeating her on the Misty Isles. | no |

## Gods (`data/gods.json`)

| Id | Name | Tradition | Care tier | Source in data | Verified |
| --- | --- | --- | --- | --- | --- |
| tyche | Tyche | greek | A | Hesiod, Theogony; Pindar, Olympian Ode 12 | no |
| cernunnos | Cernunnos | celtic | A | Gundestrup cauldron; Pillar of the Boatmen (Paris) inscription. Known mainly from a few ancient images: keep lore light. | no |
| thor | Thor | norse | A | Prose Edda (Gylfaginning, Skáldskaparmál); Poetic Edda (Þrymskviða) | no |
| skadi | Skadi | norse | A | Prose Edda (Skáldskaparmál); Poetic Edda (Grímnismál, Lokasenna) | no |
| sekhmet | Sekhmet | egyptian | A | Book of the Heavenly Cow (the Destruction of Mankind) | no |
| poseidon | Poseidon | greek | A | Homer, Iliad and Odyssey; Hesiod, Theogony | no |
| ra | Ra | egyptian | A | Book of the Heavenly Cow; the Amduat | no |
| morrigan | The Morrígan | celtic | A | Táin Bó Cúailnge; Cath Maige Tuired | no |

## Bosses (`data/bosses.json`)

| Id | Name | Tradition | Care tier | Source in data | Verified |
| --- | --- | --- | --- | --- | --- |
| medusa | Medusa | greek | A | Hesiod, Theogony 270-281; Pseudo-Apollodorus, Bibliotheca 2.4.2-3; Ovid, Metamorphoses 4 | no |
| achilles | Achilles | greek | A | Homer, Iliad; Statius, Achilleid 1.269 (the dip in the Styx); the heel: Hyginus, Fabulae 107 | no |
| kronos | Kronos | greek | A | Hesiod, Theogony 137-210, 453-506 (Kronos the Titan, who swallowed his children) | no |
| fenrir | Fenrir | norse | A | Snorri Sturluson, Prose Edda, Gylfaginning 34 (the binding with Gleipnir) and 51 (Ragnarök) | no |
| loki | Loki | norse | A | Poetic Edda, Lokasenna; Snorri Sturluson, Prose Edda, Gylfaginning 33 (shape-shifter) and 49–50 | no |
| surtr | Surtr | norse | A | Poetic Edda, Völuspá 52–53; Snorri Sturluson, Prose Edda, Gylfaginning 4 and 51 (Surtr's flaming sword at Ragnarök) | no |
| ammit | Ammit | egyptian | A | The Book of the Dead, spell 125: the weighing of the heart, with Ammit waiting by the scales | no |
| set | Set | egyptian | A | The Contendings of Horus and Set; Plutarch, On Isis and Osiris (Set as lord of the desert and storms) | no |
| apep | Apep | egyptian | A | The Book of Overthrowing Apep (Bremner-Rhind Papyrus); the Book of Gates (Apep attacks the sun's boat each night) | no |
| scathach | Scáthach | irish | A | Tochmarc Emire (The Wooing of Emer): Scáthach trains Cú Chulainn in arms on the Isle of Shadows | no |
| ferdiad | Ferdiad | irish | A | Táin Bó Cúailnge: the combat of Ferdiad and Cú Chulainn at the ford | no |
| balor | Balor of the Evil Eye | irish | A | Cath Maige Tuired (The Second Battle of Mag Tuired): Balor's destructive eye, struck by Lugh's sling-stone | no |

Bosses have `care_tier` and `lore_verified` like Heroes and gods (owner approved, 00.01.24), so a release build refuses any boss not yet verified.

## Not checked here

- Enemy fodder, events, and Words of Legend lines: listed sources are in their data files; check them the same way before release.
- Art and audio: when they arrive, research period clothing, weapons, and symbols from museum sources (GAME_DESIGN.md: Art).
