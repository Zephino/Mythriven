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


## Pack 3 (added as each level is built)

### Pohjola

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| god | ukko | Ukko | The Kalevala (Ukko, the chief god of the sky, called on throughout); Mikael Agricola's list of Finnish gods (1551) | no |
| god | ilmatar | Ilmatar | Kalevala 1 (Ilmatar, the maiden of the air; the teal's eggs on her knee become the world) | no |
| boss | elk_of_hiisi | The Elk of Hiisi | Kalevala 13-14 (the elk Hiisi made, that no skier could catch) | no |
| boss | iku_turso | Iku-Turso | Kalevala 42 (Turso rises from the water and is lifted out by his ears) | no |
| boss | louhi | Louhi | Kalevala 43 (she becomes a great eagle with scythe claws), 47 (she hides the sun and the moon) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| ukko_found | found | ukko | Face my thunder, and it will fall for you. | Original line written for Mythriven | no |
| ukko_bound | bound | ukko | The sky's old lord walks with you now. | Original line written for Mythriven | no |
| ukko_summon | summon | ukko | Fall, thunder! | Original line written for Mythriven | no |
| ukko_patron | patron | ukko | A singer of the North; the old sky knows your songs. | Original line written for Mythriven | no |
| ilmatar_found | found | ilmatar | Rest a while; even the sea was calm for me once. | Original line written for Mythriven | no |
| ilmatar_bound | bound | ilmatar | The air itself will shelter you. | Original line written for Mythriven | no |
| ilmatar_summon | summon | ilmatar | Close, shell of the world! | Original line written for Mythriven | no |
| ilmatar_patron | patron | ilmatar | A child of the Kalevala; you are welcome under my sky. | Original line written for Mythriven | no |
| ilmatar_vainamoinen | bound (as vainamoinen) | ilmatar | My son, born old and wise; sing, and I will keep you safe. | Kalevala 1 (Ilmatar is Vainamoinen's mother) | no |
| elk_of_hiisi_entrance | boss entrance | elk_of_hiisi | No skier has ever caught me. Try. | Kalevala 13-14 (the elk no skier could catch) | no |
| iku_turso_entrance | boss entrance | iku_turso | The ice is thin, and I am right beneath it. | Kalevala 42 (Turso rises from the water) | no |
| iku_turso_vainamoinen | boss entrance (as vainamoinen) | iku_turso | You lifted me out by my ears once, old man; never again. | Kalevala 42 (Vainamoinen lifts Turso by his ears) | no |
| louhi_entrance | boss entrance | louhi | The North is mine, and so are its sun and moon. | Kalevala 47 (Louhi hides the sun and the moon) | no |
| louhi_vainamoinen | boss entrance (as vainamoinen) | louhi | Old singer, you stole my Sampo; now pay for it. | Kalevala 42-43 (the theft of the Sampo and Louhi's pursuit) | no |
| louhi_ukko | boss meets god (with ukko) | louhi | Thunder-god, my hidden sun is no business of yours. | Kalevala 47-49 (Ukko strikes fire when the sun and moon are hidden) | no |

### Mazandaran

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| hero | rostam | Rostam | Ferdowsi, the Shahnameh: Rostam and Rakhsh; the Seven Labours (Haft Khan); the ox-headed mace | no |
| special summon | simurgh | The Simurgh | Shahnameh (she raises Zal and gives him feathers to burn in need; she heals Rudaba and Rostam) | no |
| boss | dragon_third_labour | The Dragon of the Third Labour | Shahnameh, third labour (the dragon came out of the dark; Rakhsh woke Rostam) | no |
| boss | witch_fourth_labour | The Witch of the Fourth Labour | Shahnameh, fourth labour (the witch disguised as a young woman) | no |
| boss | white_div | The White Div | Shahnameh, seventh labour (the White Div in his cave) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| rostam_binds | hero bind | rostam | Fight beside me, and we will pass every labour. | Original line written for Mythriven | no |
| dragon_third_labour_entrance | boss entrance | dragon_third_labour | You will not see me until it is too late. | Shahnameh, third labour (the dragon hidden in the dark) | no |
| dragon_third_labour_rostam | boss entrance (as rostam) | dragon_third_labour | Your horse woke you once, rider; he will not save you twice. | Shahnameh, third labour (Rakhsh wakes Rostam) | no |
| witch_fourth_labour_entrance | boss entrance | witch_fourth_labour | Come, traveller, sit and share my feast. | Shahnameh, fourth labour (the witch's feast) | no |
| witch_fourth_labour_rostam | boss entrance (as rostam) | witch_fourth_labour | Sing me your song again, champion, and do not say that name. | Shahnameh, fourth labour (Rostam sings, then names God, and her disguise fails) | no |
| white_div_entrance | boss entrance | white_div | You have come a long way to die in the dark. | Shahnameh, seventh labour (the White Div's cave) | no |
| white_div_rostam | boss entrance (as rostam) | white_div | Rostam. Six labours, and the seventh is me. | Shahnameh, the Seven Labours | no |

### The Slavic Wilds

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| god | perun | Perun | The Russian Primary Chronicle (980: Vladimir sets up Perun's image at Kiev); treaties of 907-971 (oaths sworn by Perun) | no |
| god | mokosh | Mokosh | The Russian Primary Chronicle (980: Mokosh among Vladimir's gods); later folk custom ties her to spinning | no |
| boss | zmey_gorynych | Zmey Gorynych | The byliny (Dobrynya Nikitich and the Serpent: Zmey Gorynych, the many-headed dragon) | no |
| boss | baba_yaga | Baba Yaga | Afanasyev, "Vasilisa the Beautiful" (her mortar, pestle and broom; the hut on hen's legs) | no |
| boss | koschei | Koschei the Deathless | Afanasyev, "The Death of Koschei the Deathless" (his death is a needle in an egg, hidden far away) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| perun_found | found | perun | Stand fast in the storm, and I will strike for you. | Original line written for Mythriven | no |
| perun_bound | bound | perun | My thunder is sworn to you now. | Original line written for Mythriven | no |
| perun_summon | summon | perun | Serpent, hear the thunder! | Original line written for Mythriven | no |
| mokosh_found | found | mokosh | Every thread of fate passes through my hands. | Original line written for Mythriven | no |
| mokosh_bound | bound | mokosh | I will spin you a lucky thread. | Original line written for Mythriven | no |
| mokosh_summon | summon | mokosh | Hold fast, threads! | Original line written for Mythriven | no |
| zmey_gorynych_entrance | boss entrance | zmey_gorynych | Cut off a head, little hero; I have plenty more. | The byliny (the many-headed Zmey Gorynych) | no |
| baba_yaga_entrance | boss entrance | baba_yaga | Fu, fu! I smell a living soul in my forest. | Afanasyev (Baba Yaga smells the Russian smell) | no |
| koschei_entrance | boss entrance | koschei | I cannot die. Look for my death if you dare. | Afanasyev, "The Death of Koschei the Deathless" | no |
| zmey_gorynych_perun | boss meets god (with perun) | zmey_gorynych | Thunder-god, I have three heads for every bolt you throw. | Original line written for Mythriven | no |

### The Land of Legends

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| hero | benkei | Benkei | The Gikeiki (the Gojo Bridge duel; Benkei's standing death at Koromogawa) | no |
| hero | yoshitsune | Minamoto no Yoshitsune | The Tale of the Heike (Dan-no-ura: his leap across eight boats); the Gikeiki (taught by the tengu of Mount Kurama) | no |
| boss | tsuchigumo | Tsuchigumo | The Tsuchigumo Soshi (Raiko and the earth spider) | no |
| boss | benkei | Benkei | The Gikeiki (the duel on the Gojo Bridge; his standing death at Koromogawa) | no |
| boss | shuten_doji | Shuten-dōji | The Oeyama tale (the oni king, made drunk with poisoned sake) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| benkei_binds | hero bind | benkei | Stand beside me; I will not give a step. | Original line written for Mythriven | no |
| yoshitsune_binds | hero bind | yoshitsune | Quick, then; we fight as we move. | Original line written for Mythriven | no |
| tsuchigumo_entrance | boss entrance | tsuchigumo | Come into my cave. Mind the threads. | The Tsuchigumo Soshi (the spider's lair) | no |
| benkei_entrance | boss entrance | benkei | Nine hundred and ninety-nine swords. Yours makes a thousand. | The Gikeiki (Benkei vowed to take a thousand swords) | no |
| benkei_yoshitsune | boss entrance (as yoshitsune) | benkei | The boy from the bridge. This time I will not fall. | The Gikeiki (the Gojo Bridge duel) | no |
| benkei_tomoe_gozen | boss entrance (as tomoe_gozen) | benkei | Lady Tomoe; your lord and mine were cousins, and still they fought. | The Tale of the Heike (Kiso Yoshinaka and Yoshitsune, cousins of the Minamoto, at war in 1184) | no |
| shuten_doji_entrance | boss entrance | shuten_doji | More sake! And then, more heroes! | The Oeyama tale (Shuten-doji's love of sake) | no |

### Pack 3 secrets and Resonances (Oracle hints and lines are original drafts)

| Id | Name | Hint or line | Source | OK? |
| --- | --- | --- | --- | --- |
| the_sampo | The Sampo | The old singer once sailed home with what the North would not give. | Kalevala 42-43 (Vainamoinen takes the Sampo back from Pohjola) | no |
| the_ski_chase | The Ski Chase | No skier could catch it; be the first, and be quick. | Kalevala 13-14 (Lemminkainen chases the elk of Hiisi on skis) | no |
| zals_feathers | Zal's Feathers | She gave her feathers to be burned in need; need her thrice. | Shahnameh (the Simurgh gives Zal her feathers to burn in need) | no |
| the_seventh_labour | The Seventh Labour | Six labours lead to a cave; let the champion end the seventh. | Shahnameh, seventh labour (the White Div's blood restores Kay Kavus's sight) | no |
| seared_necks | Seared Necks | A head cut off grows back; a head burned off does not. | The byliny (Zmey Gorynych's heads) | no |
| the_needle | The Needle | His death is far away; run to it before he knows you've gone. | Afanasyev, "The Death of Koschei the Deathless" | no |
| a_thousand_swords | A Thousand Swords | He wanted one more sword; let the boy from the bridge refuse him again. | The Gikeiki (Benkei's thousand swords; Yoshitsune beats him on the Gojo Bridge) | no |
| poisoned_sake | Poisoned Sake | The oni king loved his drink; let the last thing he tastes be water. | The Oeyama tale (Raiko's men drug Shuten-doji with sake) | no |
| thunder_and_earth_resonance | resonance line | Earth below, thunder above; Mokosh, bind them and I will strike. | A modern reconstruction pairs Perun of the sky with Mokosh of the earth (the Primary Chronicle names both); original line | no |
| airmaidens_prayer_resonance | resonance line | Ukko, highest of gods, come and help me, as you did when I called before. | Kalevala 1 (Ilmatar calls on Ukko for help) | no |
| thunder_on_the_waves_resonance | resonance line | Raise your waves, sea-lord, and I will set the storm on them. | Original line written for Mythriven | no |

## Not checked here

- Enemy fodder, events, and Words of Legend lines: listed sources are in their data files; check them the same way before release.
- Art and audio: when they arrive, research period clothing, weapons, and symbols from museum sources (GAME_DESIGN.md: Art).
