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

## Pack 2 (added 10/31/2026; owner: "add it to lore I need to do still")

The same check for everything Pack 2 added. Heroes, gods and bosses first; then the new secrets and banter lines, which are original text written for Mythriven and need your OK before release.

### Heroes

| Id | Name | Tradition | Care tier | Source in data | Verified |
| --- | --- | --- | --- | --- | --- |
| orpheus | Orpheus | Greek | A | Ovid, Metamorphoses 10.1-85 and 11.1-66; Virgil, Georgics 4.453-527; Apollonius of Rhodes, Argonautica 4.891-911 (he drowns out the Sirens) | no |
| beowulf | Beowulf | Geatish (Old English poem) | A | Beowulf (the Old English poem): lines 379-381 (the hand-grip of thirty men), 740-836 (Grendel), 1557-1569 (the giant-made sword) | no |
| gilgamesh | Gilgamesh | Mesopotamian (Epic of Gilgamesh) | A | Epic of Gilgamesh (Standard Babylonian): Tablet I (two-thirds god, one-third man; Enkidu made from clay), Tablets II-V (the axes; Humbaba), Tablet VI (the Bull of Heaven) | no |

### Gods

| Id | Name | Tradition | Care tier | Source in data | Verified |
| --- | --- | --- | --- | --- | --- |
| hecate | Hecate | greek | A | Hesiod, Theogony 411-452; Homeric Hymn to Demeter 24-25, 52-61 (Hecate with her torch) | no |
| persephone | Persephone | greek | A | Homeric Hymn to Demeter (the pomegranate seed; her return with the spring) | no |
| odin | Odin | norse | A | Gylfaginning 15 (his eye for Mimir's well); Havamal 138-141 (hanged on the tree, a sacrifice to himself); Grimnismal 20 (Huginn and Muninn); Gungnir (Skaldskaparmal 35) | no |
| freyja | Freyja | norse | A | Thrymskvida 3 and 13 (her falcon cloak; Brisingamen); Grimnismal 14 and Gylfaginning 24 (she takes half the slain) | no |
| rhiannon | Rhiannon | welsh | A | The Mabinogi, First Branch (no rider can catch her until Pwyll asks her to stop) and Second Branch (the Birds of Rhiannon) | no |
| arawn | Arawn | welsh | A | The Mabinogi, First Branch (Arawn, king of Annwn, and his white, red-eared hounds) | no |
| enki | Enki | mesopotamian | A | The Adda seal (streams flowing from his shoulders); Atrahasis and Gilgamesh XI (he warns of the Flood); Enki and the World Order | no |
| shamash | Shamash | mesopotamian | A | Epic of Gilgamesh, Tablet V (he raises thirteen winds against Humbaba); the Shamash tablet | no |

### Bosses

| Id | Name | Tradition | Care tier | Source in data | Verified |
| --- | --- | --- | --- | --- | --- |
| cerberus | Cerberus | greek | A | Hesiod, Theogony 311 and 769-774; Apollodorus, Library 2.5.12 (three dogs' heads, a serpent's tail; Heracles' twelfth labour) | no |
| thanatos | Thanatos | greek | A | Hesiod, Theogony 211-212 and 758-766; Euripides, Alcestis (Heracles wrestles Death for Alcestis) | no |
| typhon | Typhon | greek | A | Hesiod, Theogony 820-868 (a hundred snake heads with fiery eyes); Apollodorus, Library 1.6.3 (vipers' coils below the thighs, winged) | no |
| hrungnir | Hrungnir | norse | A | Snorri Sturluson, Skaldskaparmal 17 (heart and head of stone, a stone shield, a whetstone; broken by Thor's hammer) | no |
| thrym | Thrym | norse | A | Thrymskvida, Poetic Edda (Thrym steals Thor's hammer and hides it under the earth) | no |
| ymir | Ymir | norse | A | Snorri Sturluson, Gylfaginning 5-6 (the first giant, formed from the rime) | no |
| green_knight | The Green Knight | welsh | A | Sir Gawain and the Green Knight (the beheading game: he picks up his own head and rides away) | no |
| mordred | Mordred | welsh | A | Malory, Le Morte d'Arthur, books 20-21 (Mordred's host; Camlann) | no |
| twrch_trwyth | Twrch Trwyth | welsh | A | Culhwch and Olwen (the comb, razor and shears between his ears; his young pigs) | no |
| humbaba | Humbaba | mesopotamian | A | Epic of Gilgamesh, Tablets II-V (the seven radiances; Shamash's thirteen winds hold him) | no |
| bull_of_heaven | The Bull of Heaven | mesopotamian | A | Epic of Gilgamesh, Tablet VI (its snorts open pits in the earth) | no |
| tiamat | Tiamat | mesopotamian | A | Enuma Elish, Tablets I-V (her eleven monsters; the salt waters) | no |

### Secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| the_lulled_hound | The Lulled Hound | At the singer's music, even the three-headed watchdog forgot to bite. | Ovid, Metamorphoses 10.1-77; Virgil, Georgics 4.483 (Cerberus stands spellbound by Orpheus' song) | no |
| the_pomegranate | The Pomegranate | The torch-bearer went down beside the queen of the dead; find them both below. | Homeric Hymn to Demeter (Hecate goes with Persephone; the pomegranate seed) | no |
| the_brides_veil | The Bride's Veil | A giant's wedding, a veiled bride, and a weapon won back three times. | Thrymskvida (Thor, veiled as the bride, wins back his hammer at Thrym's wedding) | no |
| the_whetstone | The Whetstone | Stone breaks best under the thunderer's blow; let the storm strike last. | Snorri, Skaldskaparmal 17 (Thor kills Hrungnir; a piece of the whetstone lodges in his head) | no |
| the_green_girdle | The Green Girdle | When the headless knight returns the blow, take no more than a nick. | Sir Gawain and the Green Knight (the green girdle that keeps its wearer from death; Gawain is only nicked) | no |
| camlann | Camlann | Father and son meet on the last field; let the king be the one who stands. | Malory, Le Morte d'Arthur, book 21 (Arthur and Mordred at Camlann) | no |
| the_plant_of_youth | The Plant of Youth | A serpent stole the plant that makes the old young. Take a hundred serpents in return. | Epic of Gilgamesh, Tablet XI (a serpent steals the plant of youth) | no |
| the_thirteen_winds | The Thirteen Winds | The king of Uruk did not go into the cedars alone: the sun sent his winds. | Epic of Gilgamesh, Tablet V (Shamash raises thirteen winds against Humbaba) | no |

### Banter lines (`data/banter.json`, all original, one sentence each)

| Id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| hecate_found | found | hecate | Three roads meet here, and I stand at all of them. | Original line written for Mythriven | no |
| hecate_bound | bound | hecate | My torch will light your way through the dark. | Original line written for Mythriven | no |
| hecate_summon | summon | hecate | Every road leads to me! | Original line written for Mythriven | no |
| hecate_patron | patron | hecate | A child of Hellas at my crossroads; take whichever road you like. | Original line written for Mythriven | no |
| persephone_found | found | persephone | Even down here, something can grow. | Original line written for Mythriven | no |
| persephone_bound | bound | persephone | Spring follows me wherever I go; let it follow you. | Original line written for Mythriven | no |
| persephone_summon | summon | persephone | Bloom, even in the dark! | Original line written for Mythriven | no |
| persephone_patron | patron | persephone | The heroes of Hellas are welcome in my house, and free to leave it. | Original line written for Mythriven | no |
| odin_found | found | odin | I gave an eye for wisdom; what will you give? | Original line written for Mythriven | no |
| odin_bound | bound | odin | A fair bargain; my ravens will watch over you. | Original line written for Mythriven | no |
| odin_summon | summon | odin | Gungnir never misses! | Original line written for Mythriven | no |
| odin_patron | patron | odin | The All-Father knows a warrior of the north when he sees one. | Original line written for Mythriven | no |
| freyja_found | found | freyja | Show me your courage, and my falcon cloak is yours. | Original line written for Mythriven | no |
| freyja_bound | bound | freyja | Fly with me, then. | Original line written for Mythriven | no |
| freyja_summon | summon | freyja | Wings of the falcon! | Original line written for Mythriven | no |
| freyja_patron | patron | freyja | Half the fallen are mine to choose, and you are not among them yet. | Original line written for Mythriven | no |
| rhiannon_found | found | rhiannon | You will never catch me by running; you only have to ask. | Original line written for Mythriven | no |
| rhiannon_bound | bound | rhiannon | You asked, so I will stay. | Original line written for Mythriven | no |
| rhiannon_summon | summon | rhiannon | Sing, my birds, and let them sleep. | Original line written for Mythriven | no |
| arawn_found | found | arawn | Who hunts in my woods? Prove yourself against me. | Original line written for Mythriven | no |
| arawn_bound | bound | arawn | Ride with me, and Annwn rides with you. | Original line written for Mythriven | no |
| arawn_summon | summon | arawn | Hunt, my hounds! | Original line written for Mythriven | no |
| enki_found | found | enki | Sit a while by the sweet waters, and be wise. | Original line written for Mythriven | no |
| enki_bound | bound | enki | My waters will run beside you. | Original line written for Mythriven | no |
| enki_summon | summon | enki | Rise, waters of the Abzu! | Original line written for Mythriven | no |
| enki_patron | patron | enki | Child of the two rivers, my waters know your city. | Original line written for Mythriven | no |
| shamash_found | found | shamash | The sun sees all you do; walk justly. | Original line written for Mythriven | no |
| shamash_bound | bound | shamash | I will light your road. | Original line written for Mythriven | no |
| shamash_summon | summon | shamash | Thirteen winds, hold them fast! | Original line written for Mythriven | no |
| shamash_patron | patron | shamash | Child of the two rivers, the sun walks with you. | Original line written for Mythriven | no |
| orpheus_binds | hero bind | orpheus | Sing with me. | Original line written for Mythriven | no |
| beowulf_binds | hero bind | beowulf | Your strength and mine, then, against the giants. | Original line written for Mythriven | no |
| gilgamesh_binds | hero bind | gilgamesh | Stand beside me, as Enkidu did. | Original line written for Mythriven | no |
| persephone_orpheus | bound (as orpheus) | persephone | You sang for Eurydice, and even the queen of the dead wept; take my help. | Ovid, Metamorphoses 10.40-48 (Orpheus' song moves the rulers of the dead) | no |
| shamash_gilgamesh | bound (as gilgamesh) | shamash | I raised thirteen winds for you once; I will raise them again. | Epic of Gilgamesh, Tablet V (Shamash's winds against Humbaba) | no |
| cerberus_entrance | boss entrance | cerberus | Three heads, and not one of them lets anyone leave. | Hesiod, Theogony 769-773 (the hound lets all in and none out) | no |
| cerberus_heracles | boss entrance (as heracles) | cerberus | You dragged me up into the light once; not again. | Apollodorus, Library 2.5.12 (Heracles carries Cerberus up from Hades) | no |
| cerberus_orpheus | boss entrance (as orpheus) | cerberus | Not you again, singer; all three of my heads are listening. | Ovid, Metamorphoses 10; Virgil, Georgics 4.483 (Cerberus spellbound by Orpheus) | no |
| thanatos_entrance | boss entrance | thanatos | I come for every mortal in the end; today I come for you. | Hesiod, Theogony 758-766 (Death, hated even by the gods) | no |
| thanatos_heracles | boss entrance (as heracles) | thanatos | You wrestled me for Alcestis once; I have not forgotten. | Euripides, Alcestis (Heracles wrestles Death at her tomb) | no |
| typhon_entrance | boss entrance | typhon | Even the gods fled when I rose. | Apollodorus, Library 1.6.3 (the gods flee to Egypt before Typhon) | no |
| hrungnir_entrance | boss entrance | hrungnir | My heart is stone and my head is stone; which will you break? | Snorri, Skaldskaparmal 17 (Hrungnir's stone heart and head) | no |
| thrym_entrance | boss entrance | thrym | Bring me Freyja, or I keep whatever I take. | Thrymskvida (Thrym hides Thor's hammer and demands Freyja) | no |
| ymir_entrance | boss entrance | ymir | From my flesh they made the world; I have come to take it back. | Snorri, Gylfaginning 8 (the world made from Ymir's body) | no |
| green_knight_entrance | boss entrance | green_knight | Strike your blow, and then stand still for mine. | Sir Gawain and the Green Knight (the beheading game) | no |
| mordred_entrance | boss entrance | mordred | The king is far away, and the kingdom is mine. | Malory, Le Morte d'Arthur, book 21 (Mordred seizes the realm) | no |
| twrch_trwyth_entrance | boss entrance | twrch_trwyth | I was a king once; now I am the hunt that no one survives. | Culhwch and Olwen (a king turned into a boar for his sins) | no |
| humbaba_entrance | boss entrance | humbaba | These are my cedars. Turn back while you still can. | Epic of Gilgamesh, Tablets II-V (Humbaba, guardian of the Cedar Forest) | no |
| bull_of_heaven_entrance | boss entrance | bull_of_heaven | The earth splits open at my breath. | Epic of Gilgamesh, Tablet VI (pits open at the Bull's snort) | no |
| tiamat_entrance | boss entrance | tiamat | I am the salt sea; everything that lives came out of me. | Enuma Elish, Tablet I (Tiamat, mother of all) | no |
| thrym_freyja | boss meets god (with freyja) | thrym | Freyja! At last you have come to be my bride. | Thrymskvida (Thrym demands Freyja as his bride) | no |
| humbaba_shamash | boss meets god (with shamash) | humbaba | Sun, you sent your winds against me once; not this time. | Epic of Gilgamesh, Tablet V | no |
| thanatos_persephone | boss meets god (with persephone) | thanatos | My queen, step aside; this one is mine to take. | Original line written for Mythriven (Thanatos serves the house of Hades) | no |
| tiamat_enki | boss meets god (with enki) | tiamat | Ea, you killed my Apsu; now I take back all the waters. | Enuma Elish, Tablet I (Ea slays Apsu, and Tiamat rises in anger) | no |
| odin_ymir | boss meets god (with odin) | ymir | Son of Borr, you and your brothers made the world from my body; did you think I would forget? | Snorri, Gylfaginning 7-8 (Odin and his brothers slay Ymir) | no |
| torch_in_the_dark_resonance | resonance (torch_in_the_dark) | hecate | Hold my torch, daughter of Demeter; we will light the dark together. | Homeric Hymn to Demeter 52-61, 438-440 (Hecate with torches meets Demeter and becomes Persephone's companion) | no |
| chosen_slain_resonance | resonance (chosen_slain) | freyja | Half for me, half for you, All-Father; choose well. | Grimnismal 14 (Freyja chooses half the slain each day, Odin the other half) | no |
| flood_and_sun_resonance | resonance (flood_and_sun) | enki | Let the waters rise, and let the sun shine on whatever is left. | Epic of Gilgamesh, Tablet XI (Ea warns Utnapishtim; Shamash sets the hour of the Flood) | no |
| thryms_wedding_resonance | resonance (thryms_wedding) | thor | Lay the hammer in the bride's lap, and watch the wedding end! | Thrymskvida (Thor, dressed as Freyja, takes back his hammer when it is laid in the bride's lap) | no |

Also written for Pack 2 and worth checking: the boss lines shown as banners (`BOSS_MORDRED_ARTHUR`, `BOSS_MORDRED_CAMLANN`, `BOSS_HUMBABA_GILGAMESH`, `BOSS_GREEN_KNIGHT_RISES`) and the myth text for every new monster, god and boss in `localization/text.csv` (`ENEMY_*_MYTH`, `GOD_*_MYTH`, `HERO_*_LEGEND`).


## Not checked here

- Enemy fodder, events, and Words of Legend lines: listed sources are in their data files; check them the same way before release.
- Art and audio: when they arrive, research period clothing, weapons, and symbols from museum sources (GAME_DESIGN.md: Art).
