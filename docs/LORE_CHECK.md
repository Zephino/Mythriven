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

## Pack 4 (added as each realm is built)

### Muspelheim

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| boss | gifr_and_geri | Gífr and Geri | Fjolsvinnsmal 13-18 (the two hounds who sleep by turns) | no |
| boss | vidofnir | Víðófnir | Fjolsvinnsmal 18-26 (the shining cock on the tree) | no |
| boss | sinmara | Sinmara | Fjolsvinnsmal 26-30 (Sinmara keeps Laevateinn in a chest with nine locks) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| gifr_and_geri_entrance | boss entrance | gifr_and_geri | One of us always watches. Always. | Fjolsvinnsmal 13-18 (the hounds sleep by turns) | no |
| vidofnir_entrance | boss entrance | vidofnir | Look at me, and see nothing else. | Fjolsvinnsmal 18-26 (the gleaming cock) | no |
| sinmara_entrance | boss entrance | sinmara | Nine locks on the chest, and every key is mine. | Fjolsvinnsmal 26-30 (Laevateinn in a chest with nine locks) | no |
| sinmara_freyja | boss meets god (with freyja) | sinmara | Goddess, your gold will melt like everything else here. | Original line written for Mythriven | no |

### Niflheim

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| boss | hraesvelgr | Hræsvelgr | Vafthrudnismal 37; Gylfaginning 18 (the winds come from his wings) | no |
| boss | garmr | Garmr | Voluspa 44 (Garm bays loudly before Gnipahellir) | no |
| boss | nidhoggr | Níðhöggr | Grimnismal 32-35; Voluspa 39 (Nidhoggr gnaws the roots of the tree) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| hraesvelgr_entrance | boss entrance | hraesvelgr | Every wind in the world comes from my wings. | Vafthrudnismal 37 | no |
| garmr_entrance | boss entrance | garmr | Hear me bay; the fetter is wearing thin. | Voluspa 44 (Garm bays; the fetter breaks) | no |
| nidhoggr_entrance | boss entrance | nidhoggr | I gnaw the roots of the world. You are a smaller meal. | Grimnismal 35 (Nidhoggr gnaws the roots) | no |
| nidhoggr_odin | boss meets god (with odin) | nidhoggr | All-Father, your tree is rotting from below, and I am why. | Grimnismal 35 (the ash suffers more than men know) | no |

### Ys

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| boss | morvarch | Morvarc'h | Albert Le Grand; Souvestre (Gradlon's sea-horse gallops over the waves) | no |
| boss | ankou | The Ankou | Anatole Le Braz, La Legende de la mort (the Ankou and his creaking cart) | no |
| boss | dahut | Dahut | Albert Le Grand; the Barzaz Breiz (Dahut opens the sea gates; she becomes a mari-morgan) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| morvarch_entrance | boss entrance | morvarch | The sea is a road, and I run on it. | Le Grand; Souvestre (Morvarc'h gallops over the waves) | no |
| ankou_entrance | boss entrance | ankou | Do you hear the axle creak? It creaks for you. | Le Braz, La Legende de la mort (the Ankou's cart) | no |
| dahut_entrance | boss entrance | dahut | The key was so small, and the sea so big. Let it in. | Le Grand; the Barzaz Breiz (Dahut opens the sea gates) | no |
| dahut_poseidon | boss meets god (with poseidon) | dahut | Lord of the sea, my city is already yours. | Original line written for Mythriven | no |

### Cloud-Cuckoo-Land

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| boss | hoopoe | The Hoopoe | Aristophanes, The Birds (Tereus the hoopoe, king of the birds, calls them together) | no |
| boss | iris | Iris | Aristophanes, The Birds (Iris, the gods' messenger, flies into the birds' sky) | no |
| boss | roc | The Roc | The Thousand and One Nights (the Roc, the bird so vast it hid the sun) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| hoopoe_entrance | boss entrance | hoopoe | Come, all you birds! Here is one who walks on the ground. | Aristophanes, The Birds (the Hoopoe's call to the birds) | no |
| iris_entrance | boss entrance | iris | I carry the gods' word, and I do not stop for walls. | Aristophanes, The Birds (Iris at the walls) | no |
| roc_entrance | boss entrance | roc | You broke the egg. Now look up. | The Thousand and One Nights (the Rocs avenge their egg) | no |
| hoopoe_odysseus | boss entrance (as odysseus) | hoopoe | Another wanderer far from home. Stay, and be a bird with us. | Original line written for Mythriven | no |

### Pack 4 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| past_the_hounds | Past the Hounds | They sleep by turns so that none may pass; pass before the turns run out. | Fjolsvinnsmal 13-18 (the hounds who sleep by turns) | no |
| laevateinn | Lævateinn | Only one weapon can fell the gleaming cock, and it is made of fire. | Fjolsvinnsmal 25-26 (only Laevateinn can kill Vidofnir) | no |
| gnipahellir | Gnipahellir | Silence the hound before the cave hears him thrice. | Voluspa 44 (Garm bays before Gnipahellir) | no |
| the_gnawed_root | The Gnawed Root | What gnaws in the dark at the roots of the world fears the light. | Gylfaginning 16 (the dew that falls from the ash); Grimnismal 35 | no |
| gradlons_escape | Gradlon's Escape | The old king rode out of the flood untouched; ride out of this one the same. | Albert Le Grand; Souvestre (Gradlon escapes the flood on Morvarc'h) | no |
| the_golden_key | The Golden Key | The sea opened the city; let the storm close the story. | Albert Le Grand; the Barzaz Breiz (the golden key of the sea gates) | no |
| iris_at_the_walls | Iris at the Walls | The birds caught the swift messenger at their walls; be quicker than her errand. | Aristophanes, The Birds (Iris caught at the walls) | no |
| sindbads_escape | Sindbad's Escape | Watch the shadows on the ground, and let every stone miss. | The Thousand and One Nights (Sindbad escapes the Rocs' boulders) | no |

## Bonus levels

### The Realm of the Ten Suns

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| hero | hou_yi | Hou Yi | The Huainanzi (c. 139 BC: Yi shoots down nine of the ten suns and slays the monsters plaguing the land) | no |
| boss | nian | Nian | New Year folklore (Nian fears noise, fire and red) | no |
| boss | baigujing | Baigujing | Journey to the West, chapter 27 (three disguises: a village girl, an old woman, an old man) | no |
| boss | ten_suns | The Ten Suns | The Huainanzi (Yi shoots down nine of the ten suns); the Shanhaijing (a crow in each sun) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| hou_yi_binds | hero bind | hou_yi | Lend me your strength, and my arrows will not miss. | Original line written for Mythriven | no |
| nian_entrance | boss entrance | nian | The year turns, and I come down from the mountain. | New Year folklore (Nian comes at the year's end) | no |
| baigujing_entrance | boss entrance | baigujing | Only a poor traveller, nothing to fear. Come closer. | Journey to the West, chapter 27 (her disguises) | no |
| ten_suns_entrance | boss entrance | ten_suns | Ten of us, all at once. Let the world burn. | The Huainanzi (the ten suns rise together) | no |
| ten_suns_hou_yi | boss entrance (as hou_yi) | ten_suns | The archer again. Nine of us remember your arrows. | The Huainanzi (Yi shoots down nine suns) | no |
| ten_suns_ra | boss meets god (with ra) | ten_suns | One sun in the sky is enough, Ra; we are ten. | Original line written for Mythriven | no |

### The Crossroads

| Kind | Id | Name | Source | Verified |
| --- | --- | --- | --- | --- |
| boss | unweaver | The Unweaver | Original, the game's own (no culture to check; the design names it) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| unweaver_entrance | boss entrance | unweaver | Every story ends. I am how. | Original line written for Mythriven | no |
| unweaver_heracles | boss entrance (as heracles) | unweaver | Twelve labours, and still one more. I will unpick them all. | Original line written for Mythriven | no |
| unweaver_apep | boss meets god (with ra) | unweaver | Little sun. The serpent only swallowed you; I will unweave you. | Original line written for Mythriven | no |

### Bonus level secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| firecrackers | Firecrackers | The villagers drove the beast off with noise, fire and red; give it all three, again and again. | Chinese New Year folklore (firecrackers and red drive the Nian away) | no |
| the_nine_crows | The Nine Crows | A crow lived in every sun; when Yi's arrows struck, nine fell from the sky one after another. | Huainanzi (Yi shoots down nine suns); Wang Yi's commentary on the Chuci, Tianwen (the crows in the suns die and their feathers fall) | no |
| the_last_thread | The Last Thread | Cut the last thread before it pulls the rest loose. | Original, the game's own (the Unweaver) | no |
| nothing_to_steal | Nothing to Steal | What is spent can't be stolen: call your gods before the threads come. | Original, the game's own (the Unweaver) | no |

## Pack 5: Gothic Night

### Erebus

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | erebus | Erebus | Hesiod, Theogony 123 (Erebus, the darkness); the Anglo-Saxon Chronicle 1127 (the Wild Hunt) | no |
| enemy | ker | Ker | Hesiod, Theogony 211-217; the Shield of Heracles 248-257 (the Keres, dark death spirits of battle) | no |
| enemy | hunt_hound | Hound of the Hunt | The Anglo-Saxon Chronicle for 1127 (the hunt's black, wide-eyed hounds) | no |
| boss | empusa | Empusa | Aristophanes, The Frogs 285-295 (the shape-shifting spectre on the road through the underworld) | no |
| boss | eurynomos | Eurynomos | Pausanias, Description of Greece 10.28.7 (the daemon in Polygnotus' painting who eats the flesh of the dead) | no |
| boss | wild_hunt | The Wild Hunt | The Anglo-Saxon Chronicle for 1127 (black huntsmen on black horses, with black hounds); Orderic Vitalis, Ecclesiastical History 8.17 (Hellequin's household, 1091) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| empusa_entrance | boss entrance | empusa | Bull or dog or woman? Look again; I've changed. | Aristophanes, The Frogs 285-295 (her shapes) | no |
| eurynomos_entrance | boss entrance | eurynomos | Fresh dead. I'll leave you the bones. | Pausanias 10.28.7 (he leaves only the bones) | no |
| wild_hunt_entrance | boss entrance | wild_hunt | Hear the horns? The Hunt is riding, and you are the quarry. | The Anglo-Saxon Chronicle for 1127 (the horns heard all night) | no |
| empusa_hecate | boss meets god (with hecate) | empusa | Mistress Hecate! Your hound of the roads has found someone. | Original line written for Mythriven (Empusa as Hecate's spectre) | no |

### Karnstein

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | karnstein | Karnstein | Le Fanu, Carmilla (1872): the ruined castle and village of Karnstein in Styria | no |
| enemy | revenant | Revenant | Augustin Calmet, Treatise on the Apparitions of Spirits and on Vampires (1746): the revenants | no |
| enemy | night_bat | Night bat | Le Fanu, Carmilla (1872); Varney the Vampire (1845-47): bats of the night | no |
| enemy | night_bat_flyer | Night bat | Le Fanu, Carmilla (1872); Varney the Vampire (1845-47): bats of the night | no |
| boss | varney | Varney | Rymer and Prest, Varney the Vampire (1845-47): Sir Francis Varney, revived by the light of the moon | no |
| boss | ruthven | Lord Ruthven | John Polidori, The Vampyre (1819): Lord Ruthven, the cold nobleman who feeds on the living | no |
| boss | carmilla | Carmilla | J. Sheridan Le Fanu, Carmilla (1872): Mircalla, Countess Karnstein, and her shape of a monstrous black cat | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| varney_entrance | boss entrance | varney | Strike me down if you like. The moon is up. | Varney the Vampire (the moon revives him) | no |
| ruthven_entrance | boss entrance | ruthven | Remember your oath: speak of me to no one. | Polidori, The Vampyre (Aubrey's oath) | no |
| carmilla_entrance | boss entrance | carmilla | Don't be afraid, darling. You will be mine, and I yours. | Le Fanu, Carmilla, ch. 4 (her words to Laura) | no |
| carmilla_persephone | boss meets god (with persephone) | carmilla | Queen of the dead? I have slept in my tomb a hundred years; it never kept me. | Original line written for Mythriven | no |

### Ossory

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | ossory | Ossory | Gerald of Wales, Topographia Hibernica II.19 (c. 1188: the werewolves of Ossory) | no |
| enemy | werewolf | Werewolf of Ossory | Gerald of Wales, Topographia Hibernica II.19 (c. 1188): the werewolves of Ossory | no |
| enemy | raven | Raven | Irish forest folklore (ravens follow the wolves) | no |
| boss | bisclavret | Bisclavret | Marie de France, Bisclavret (12th c.): the baron who must stay a wolf without his hidden clothes | no |
| boss | melion | Melion | The Lai de Melion (13th c.): the knight left a wolf by his wife, who led a pack of wolves through Ireland | no |
| boss | gevaudan | The Beast of Gévaudan | French newspapers of 1764-67 (the Courrier d'Avignon, the Gazette de France); the Abbe Pourcher's history (1889): the Beast of Gevaudan | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| bisclavret_entrance | boss entrance | bisclavret | Grr... Find what was hidden from me, and I'll be a man again. | Marie de France, Bisclavret (his hidden clothes) | no |
| melion_entrance | boss entrance | melion | The white stone made me a wolf. Now I lead the pack. | The Lai de Melion (the ring's white stone) | no |
| gevaudan_entrance | boss entrance | gevaudan | (A low growl from the undergrowth. Something huge is watching.) | The Beast of Gevaudan (it sprang from cover; a description, not speech) | no |
| melion_king_arthur | boss entrance (as king_arthur) | melion | My king! You came all the way to Ireland for me? | The Lai de Melion (Arthur comes to Ireland and restores him) | no |

### The Brocken

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | the_brocken | The Brocken | Goethe, Faust I (1808), Walpurgis Night; Praetorius, Blockes-Berges Verrichtung (1668) | no |
| enemy | witch | Witch | Goethe, Faust I (1808), Walpurgis Night; Praetorius, Blockes-Berges Verrichtung (1668) | no |
| enemy | black_goat | Black goat | Praetorius (1668); Goethe, Faust I (the witches ride up on goats) | no |
| boss | brocken_spectre | The Brocken Spectre | Johann Silberschlag (1780): the giant shadows with a ring of coloured light seen in the mist from the Brocken | no |
| boss | baubo | Baubo | Goethe, Faust I (1808), Walpurgis Night ("Old Baubo comes alone; she rides a farrow sow") | no |
| boss | black_annis | Black Annis | Leicestershire folklore (John Heyrick's poem, 1797; county histories): Black Annis and her bower in the Dane Hills | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| brocken_spectre_entrance | boss entrance | brocken_spectre | (A giant shape in the mist moves when you move.) | Silberschlag (1780): the shadow on the mist | no |
| baubo_entrance | boss entrance | baubo | Make way! Old Baubo rides alone, and the whole crowd after her! | Goethe, Faust I, Walpurgis Night (the witches' chorus) | no |
| black_annis_entrance | boss entrance | black_annis | I dug my bower with these claws. I'll dig you out of yours. | Leicestershire folklore (her claws dug the cave) | no |
| black_annis_hecate | boss meets god (with hecate) | black_annis | A queen of witches? On my hill there's only one. | Original line written for Mythriven | no |

### Pack 5 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| nothing_to_eat | Nothing to Eat | He grows fat on the fallen; give him nothing to eat. | Pausanias 10.28.7 (Eurynomos eats the flesh of the dead) | no |
| the_last_horn | The Last Horn | The horns blew all night long at Peterborough; end the hunt before dawn. | The Anglo-Saxon Chronicle for 1127 (the hunt's horns heard all night) | no |
| the_moon_blocked | The Moon Blocked | The moon gives him back his life. Stand between them. | Rymer and Prest, Varney the Vampire (the moon revives him) | no |
| lauras_charm | Laura's Charm | The pedlar sold charms against the oupire; be charmed, and never bitten. | Le Fanu, Carmilla, ch. 5 (the pedlar's charms against the oupire) | no |
| the_kings_mercy | The King's Mercy | The king was kind to the gentle wolf; be kind more than once. | Marie de France, Bisclavret (the king gives him back his clothes) | no |
| out_of_the_undergrowth | Out of the Undergrowth | Watch where the undergrowth stirs, and never be there. | French newspapers of 1764-67 (the Beast sprang from cover) | no |
| the_glory | The Glory | It is only your own shadow; walk straight through the mist to meet it. | Silberschlag (1780): the ring of coloured light round the Brocken spectre | no |
| the_empty_bower | The Empty Bower | She hides in her bower to mend. Don't give her the time. | Leicestershire folklore (Black Annis' Bower in the Dane Hills) | no |

## Pack 6: The Deep Below

### Nidavellir

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | nidavellir | Nidavellir | Voluspa 37 (the golden hall of Sindri's kin in Nidavellir) | no |
| enemy | dwarf_smith | Dwarf smith | Voluspa 10-16 (the dwarves); Skaldskaparmal 35 (the dwarf smiths) | no |
| enemy | dwarf_hammerer | Dwarf hammer-bearer | Skaldskaparmal 35 (the dwarves' forge) | no |
| boss | gullinbursti | Gullinbursti | Snorri, Skaldskaparmal 35 (the golden-bristled boar forged by Brokkr and Sindri for Freyr) | no |
| boss | brokkr | Brokkr | Snorri, Skaldskaparmal 35 (Brokkr works the bellows and is stung by a fly; Mjolnir comes out short in the handle) | no |
| boss | andvari | Andvari | The Poetic Edda, Reginsmal (Andvari, his gold and the cursed ring Andvaranaut); Skaldskaparmal 39 | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| gullinbursti_entrance | boss entrance | gullinbursti | (The golden boar's bristles light the hall like day.) | Skaldskaparmal 35 (its bristles light the night) | no |
| brokkr_entrance | boss entrance | brokkr | Keep back! A wager's a wager, and I'm at the bellows. | Skaldskaparmal 35 (Brokkr's wager) | no |
| andvari_entrance | boss entrance | andvari | Take the gold, then. Take the ring. It will be the death of you. | Reginsmal (Andvari's curse) | no |
| brokkr_thor | boss meets god (with thor) | brokkr | Thor! How's the handle on that hammer? A little short, I'd say. | Skaldskaparmal 35 (Mjolnir's short handle) | no |

### Svartalfheim

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | svartalfheim | Svartalfheim | Snorri, Gylfaginning 17 and 34 (the dark elves under the earth; Gleipnir made in Svartalfaheimr) | no |
| enemy | svartalf | Svartalf | Snorri, Gylfaginning 17 (the dark elves live down in the earth, blacker than pitch) | no |
| enemy | nibelung | Nibelung | The Nibelungenlied, 3rd adventure (the warriors of the Nibelungs who guard the hoard) | no |
| boss | alviss | Alvíss | The Poetic Edda, Alvissmal (the dwarf kept talking until sunrise and turned to stone) | no |
| boss | fjalar_and_galar | Fjalar and Galar | Snorri, Skaldskaparmal 1 (the dwarves who brewed the mead of poetry in Odrerir, Bodn and Son) | no |
| boss | alberich | Alberich | The Nibelungenlied (c. 1200), 3rd adventure (Alberich, the Tarnkappe, and Siegfried's victory) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| alviss_entrance | boss entrance | alviss | Ask me anything. I know the names of all things in every world. | Alvissmal (his answers) | no |
| fjalar_and_galar_entrance | boss entrance | fjalar_and_galar | A drink? It's very good mead. Kvasir is in it. | Skaldskaparmal 1 (the mead brewed from Kvasir's blood) | no |
| alberich_entrance | boss entrance | alberich | You can't see me, but I see you. | The Nibelungenlied (the cloak of invisibility) | no |
| alviss_thor | boss meets god (with thor) | alviss | Thor! Ask your questions, then. The night is long. | Alvissmal (Thor questions him until dawn) | no |

### Mycendra

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | mycendra | Mycendra | Invented for Mythriven (GAME_DESIGN.md marks Mycendra invented) | no |
| enemy | cap_walker | Cap walker | Invented for Mythriven (GAME_DESIGN.md: Mycendra has no public-domain source; plain descriptive name) | no |
| enemy | spore_puff | Spore puff | Invented for Mythriven (GAME_DESIGN.md: Mycendra has no public-domain source; plain descriptive name) | no |
| enemy | glow_fly | Glow-fly | Invented for Mythriven (GAME_DESIGN.md: Mycendra has no public-domain source; plain descriptive name) | no |
| boss | great_puffball | The Great Puffball | Invented for Mythriven (GAME_DESIGN.md: Mycendra has no public-domain source; plain descriptive name) | no |
| boss | mycelium | The Mycelium | Invented for Mythriven (GAME_DESIGN.md: Mycendra has no public-domain source; plain descriptive name) | no |
| boss | spore_mother | The Spore Mother | Invented for Mythriven (GAME_DESIGN.md: Mycendra has no public-domain source; plain descriptive name) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| great_puffball_entrance | boss entrance | great_puffball | (It wheezes. Spores puff from its cracks with every breath.) | Original description written for Mythriven | no |
| mycelium_entrance | boss entrance | mycelium | (The ground itself heaves, pale threads reaching for your feet.) | Original description written for Mythriven | no |
| spore_mother_entrance | boss entrance | spore_mother | Grow, my children. Grow, and burst. | Original line written for Mythriven | no |
| spore_mother_persephone | boss meets god (with persephone) | spore_mother | Spring goddess, everything that rots comes back to me. | Original line written for Mythriven | no |

### The Myrmidon Hive

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | the_myrmidon_hive | The Myrmidon Hive | Ovid, Metamorphoses 7.614-660 (Zeus turns the ants of Aegina into the Myrmidons) | no |
| enemy | myrmidon | Myrmidon | Ovid, Metamorphoses 7.614-660 (the ants of Aegina turned into the Myrmidons) | no |
| enemy | gold_digging_ant | Gold-digging ant | Herodotus, Histories 3.102-105 (the gold-digging ants of India) | no |
| enemy | winged_ant | Winged ant | Herodotus 3.102 (the ants of the hive); the swarming flight of ants | no |
| enemy | gold_carrier_ant | Gold-carrier ant | Herodotus, Histories 3.102 (the ants bring up the gold) | no |
| boss | great_gold_ant | The Gold-Digging Ant | Herodotus, Histories 3.102-105 (the ants of India throw up gold sand and chase the thieves) | no |
| boss | myrmex | Myrmex | Servius, commentary on Virgil, Aeneid 4.402 (Myrmex claims Athena's plough and is turned into an ant) | no |
| boss | ant_queen | The Queen of the Gold-Digging Ants | Herodotus, Histories 3.102-105 (the gold-digging ants of India); GAME_DESIGN.md (the queen of the hive) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| great_gold_ant_entrance | boss entrance | great_gold_ant | (It lifts its head from the sand. It can smell gold on you.) | Herodotus 3.105 (the ants find the thieves by smell) | no |
| myrmex_entrance | boss entrance | myrmex | The plough was my idea! Well... it should have been. | Servius on Aeneid 4.402 (her false claim) | no |
| ant_queen_entrance | boss entrance | ant_queen | Bring me the gold, my children. All of it. | Original line written for Mythriven | no |
| myrmex_persephone | boss meets god (with persephone) | myrmex | Daughter of the grain-mother! Every seed the plough sows, we ants gather. | Original line written for Mythriven | no |

### Pack 6 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| the_flys_sting | The Fly's Sting | A fly stung the smith again and again; be the fly. | Snorri, Skaldskaparmal 35 (the fly stings Brokkr at the bellows; Draupnir) | no |
| the_ring_refused | The Ring Refused | Every owner of that ring came to grief. Leave it where it lies. | The Poetic Edda, Reginsmal (Andvari's curse on the ring) | no |
| the_dawn | The Dawn | Keep him talking; the sun is coming up. | The Poetic Edda, Alvissmal (the dwarf turned to stone by daylight) | no |
| the_tarnkappe | The Tarnkappe | Siegfried wrestled the cloak from the dwarf; feel for him in the dark. | The Nibelungenlied, 3rd adventure (Siegfried wins the Tarnkappe) | no |
| clean_air | Clean Air | Every blow makes it burst. Strike and step back. | Invented for Mythriven (Mycendra) | no |
| the_stamping | The Stamping | What she plants, tread down. | Invented for Mythriven (Mycendra) | no |
| the_gold_thief | The Gold Thief | The Indians came for the gold on their swiftest camels. Be swift. | Herodotus, Histories 3.102-105 (the Indians steal the ants' gold) | no |
| the_starved_queen | The Starved Queen | Her workers bring her gold. Let none arrive. | Herodotus, Histories 3.102-105 (the gold-digging ants) | no |

## Pack 7: The Wild Green

### Alfheim

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | alfheim | Alfheim | Grimnismal 5 (Alfheimr, given to Freyr); Gylfaginning 17 (the light elves) | no |
| enemy | light_elf | Light elf | Snorri, Gylfaginning 17 (the light elves, fairer than the sun) | no |
| enemy | elf_knight | Elf-knight | The ballad of Lady Isabel and the Elf-Knight (Child 4) | no |
| enemy | elf_maiden | Elf-maiden | Goethe, Erlkonig (1782): the Erlking's daughters, who dance at night | no |
| boss | erlking_daughter | The Erlking's Daughter | J. G. Herder, "Erlkonigs Tochter" (1778, from the Danish ballad of Sir Oluf); the charm Wid faerstice (elf-shot) | no |
| boss | volundr | Völundr | The Poetic Edda, Volundarkvida (Volundr, prince of elves, forges wings and flies from King Nidud) | no |
| boss | erlking | The Erlking | Goethe, "Erlkonig" (1782); Herder, "Erlkonigs Tochter" (1778) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| erlking_daughter_entrance | boss entrance | erlking_daughter | Welcome! Come, step into the ring and dance with me. | Herder, Erlkonigs Tochter (her invitation to Oluf) | no |
| volundr_entrance | boss entrance | volundr | They lamed me so I could not run. So I made wings. | Volundarkvida | no |
| erlking_entrance | boss entrance | erlking | And if you're not willing, I'll use force. | Goethe, Erlkonig (1782) | no |
| erlking_freyja | boss meets god (with freyja) | erlking | Lady of the Vanir, your brother's realm is mine tonight. | Original line written for Mythriven (Alfheim was given to Freyr, Freyja's brother) | no |

### Elfame

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | elfame | Elfame | The Scottish ballads Thomas the Rhymer (Child 37) and Tam Lin (Child 39) | no |
| enemy | fae_rider | Fairy rider | The ballad Tam Lin (Child 39): the fairy rade at Halloween | no |
| boss | tam_lin | Tam Lin | The ballad Tam Lin (Child 39): Janet holds him fast through his changes and wins him from the fairies | no |
| boss | the_elf_knight | The Elf-Knight | The ballad Lady Isabel and the Elf-Knight (Child 4): his horn draws her away; she lulls him to sleep | no |
| boss | queen_of_elfame | The Queen of Elfame | The ballad Thomas the Rhymer (Child 37); the romance of Thomas of Erceldoune (15th c.): the queen and the fruit of her garden | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| tam_lin_entrance | boss entrance | tam_lin | Hold me fast and fear me not. I'll do you no harm. | Tam Lin (Child 39): his words to Janet | no |
| the_elf_knight_entrance | boss entrance | the_elf_knight | Hear my horn? Come away with me to the greenwood. | Lady Isabel and the Elf-Knight (Child 4) | no |
| queen_of_elfame_entrance | boss entrance | queen_of_elfame | I'm but the queen of fair Elfland, come here to visit you. | Thomas the Rhymer (Child 37): her words to Thomas | no |
| queen_of_elfame_rhiannon | boss meets god (with rhiannon) | queen_of_elfame | Lady of the otherworld! Your horse is slow; mine has fifty silver bells. | Original line written for Mythriven | no |

### Arcadia

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | arcadia | Arcadia | Pausanias, Description of Greece, Book 8 (Arcadia); Ovid, Metamorphoses 1 (Lycaon) | no |
| enemy | centaur | Centaur | Apollodorus, Library 2.5.4 (the centaurs of Pholoe attack Heracles) | no |
| enemy | stymphalian_diver | Stymphalian bird | Apollodorus, Library 2.5.6 (the birds of the Stymphalian lake in Arcadia) | no |
| boss | ceryneian_hind | The Ceryneian Hind | Apollodorus, Library 2.5.3 (the golden-horned hind of Ceryneia, chased by Heracles for a year) | no |
| boss | erymanthian_boar | The Erymanthian Boar | Apollodorus, Library 2.5.4 (Heracles drives the boar of Mount Erymanthus into deep snow and snares it) | no |
| boss | lycaon | Lycaon | Ovid, Metamorphoses 1.163-243 (Lycaon's feast; Zeus' thunderbolt; he becomes a wolf) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| ceryneian_hind_entrance | boss entrance | ceryneian_hind | (A flash of gold antlers between the trees, and it's gone again.) | Apollodorus 2.5.3 (the year-long chase) | no |
| erymanthian_boar_entrance | boss entrance | erymanthian_boar | (It snorts steam into the cold air and lowers its tusks.) | Apollodorus 2.5.4 | no |
| lycaon_entrance | boss entrance | lycaon | Sit, guest, and eat. You won't ask what the meat is. | Ovid, Metamorphoses 1 (Lycaon's feast) | no |
| ceryneian_hind_heracles | boss entrance (as heracles) | ceryneian_hind | (The hind looks at you. It remembers a whole year of running.) | Apollodorus 2.5.3 (the third labour) | no |

### Lerna

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | lerna | Lerna | Hesiod, Theogony 313-318 (the Hydra of Lerna); Pausanias 2.37 (the Lernaean marsh) | no |
| enemy | spartoi | Spartos | Apollodorus, Library 3.4.1 (the armed men sprung from the dragon's teeth) | no |
| boss | karkinos | Karkinos | Apollodorus, Library 2.5.2 (the giant crab that bit Heracles' foot as he fought the Hydra) | no |
| boss | echion | Echion | Apollodorus, Library 3.4.1 (the Spartoi kill each other; Echion is one of the five who survive) | no |
| boss | hydra | The Lernaean Hydra | Hesiod, Theogony 313-318; Apollodorus, Library 2.5.2 (nine heads, the necks seared by Iolaus, the immortal head buried under a rock) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| karkinos_entrance | boss entrance | karkinos | (It raises both claws and scuttles sideways, never turning its back.) | Apollodorus 2.5.2 | no |
| echion_entrance | boss entrance | echion | I rose from a dragon's tooth, and I'm still standing. Who threw that stone? | Apollodorus 3.4.1 | no |
| hydra_entrance | boss entrance | hydra | (Nine heads hiss at once.) | Hesiod, Theogony 313-318 | no |
| hydra_heracles | boss entrance (as heracles) | hydra | (The heads remember the club and the torches. They hiss louder.) | Apollodorus 2.5.2 (the second labour) | no |

### Pack 7 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| the_full_dance | The Full Dance | Sir Oluf would not dance, and died of it. Dance. | Herder, Erlkonigs Tochter (1778): Sir Oluf would not dance | no |
| home_before_dawn | Home Before Dawn | The father rode hard through the night. Ride harder. | Goethe, Erlkonig (1782): the father rides home with the child | no |
| janets_hold | Janet's Hold | Hold him fast and fear him not, whatever shape he takes. | The ballad Tam Lin (Child 39): Janet holds him fast | no |
| true_thomas | True Thomas | Thomas was warned not to touch the fruit. Heed the warning. | The ballad Thomas the Rhymer (Child 37): the fruit of Elfland | no |
| the_years_chase | The Year's Chase | Heracles needed a whole year. You don't have one. | Apollodorus, Library 2.5.3 (Heracles chases the hind for a year) | no |
| zeus_judgement | Zeus' Judgement | Keep the host where the god's anger falls. | Ovid, Metamorphoses 1.163-243 (Zeus' thunderbolt on Lycaon's house) | no |
| the_thrown_stone | The Thrown Stone | Cadmus didn't fight the sown men. He let them fight each other. | Apollodorus, Library 3.4.1 (Cadmus throws a stone among the Spartoi) | no |
| iolaus_brands | Iolaus' Brands | Every head you cut grows two. Every head you burn stays gone. | Apollodorus, Library 2.5.2 (Iolaus sears the Hydra's necks) | no |

## Pack 8: Warlords

### Ghorvast

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | ghorvast | Ghorvast | Invented for Mythriven (GAME_DESIGN.md marks Ghorvast invented) | no |
| enemy | orc_warrior | Orc warrior | Invented for Mythriven (GAME_DESIGN.md: Ghorvast; "orc" from Old English orcneas, Latin Orcus) | no |
| enemy | orc_archer | Orc archer | Invented for Mythriven (GAME_DESIGN.md: Ghorvast; "orc" from Old English orcneas, Latin Orcus) | no |
| enemy | orc_brute | Orc brute | Invented for Mythriven (GAME_DESIGN.md: Ghorvast; "orc" from Old English orcneas, Latin Orcus) | no |
| enemy | carrion_crow | Carrion crow | Carrion crows, ordinary birds round a battlefield | no |
| boss | war_drummer | The War Drummer | Invented for Mythriven (GAME_DESIGN.md: Ghorvast; "orc" from Old English orcneas, Latin Orcus) | no |
| boss | pit_champion | The Pit Champion | Invented for Mythriven (GAME_DESIGN.md: Ghorvast; "orc" from Old English orcneas, Latin Orcus) | no |
| boss | warlord | The Warlord | Invented for Mythriven (GAME_DESIGN.md: Ghorvast; "orc" from Old English orcneas, Latin Orcus) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| war_drummer_entrance | boss entrance | war_drummer | (BOOM. BOOM. BOOM. The whole stronghold answers the drum.) | Original description written for Mythriven | no |
| pit_champion_entrance | boss entrance | pit_champion | Hit me. Go on. Hit me harder. | Original line written for Mythriven | no |
| warlord_entrance | boss entrance | warlord | Under my banner, no one runs. | Original line written for Mythriven | no |
| warlord_odin | boss meets god (with odin) | warlord | A war god? Good. Mine is a war without gods. | Original line written for Mythriven | no |

### Knossos

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | knossos | Knossos | Apollodorus 3.1.4 and Ovid, Metamorphoses 8 (Minos' palace and Daedalus' Labyrinth) | no |
| enemy | cretan_guard | Cretan guard | Plutarch, Life of Theseus 19 (Minos' general Taurus and his men) | no |
| enemy | young_bull | Young bull | The bulls of Crete (Apollodorus 2.5.7; the bull-leaping of Knossos) | no |
| boss | cretan_bull | The Cretan Bull | Apollodorus, Library 2.5.7 (Poseidon's white bull, maddened; Heracles' seventh labour) | no |
| boss | minos | Minos | Homer, Odyssey 11.568 (Minos judges the dead with a golden sceptre); Apollodorus 3.1.3-4 | no |
| boss | asterion | Asterion, the Minotaur | Apollodorus 3.1.4 (Asterius, the Minotaur) and Epitome 1.9 (Theseus beats him to death with his fists); Plutarch, Theseus 19 | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| cretan_bull_entrance | boss entrance | cretan_bull | (It paws the paving stones. Its eyes are white with Poseidon's madness.) | Apollodorus 2.5.7 | no |
| minos_entrance | boss entrance | minos | Stand before me. Every shade I have judged stood where you stand. | Odyssey 11.568 | no |
| asterion_entrance | boss entrance | asterion | (Something huge breathes in the dark of the Labyrinth, and the floor shakes.) | Apollodorus 3.1.4 | no |
| cretan_bull_heracles | boss entrance (as heracles) | cretan_bull | (It knows you. The seventh labour; it has not forgotten the rope.) | Apollodorus 2.5.7 (the seventh labour) | no |

### Utgard

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | utgard | Utgard | Snorri, Gylfaginning 44-47 (Thor's journey to Utgarda-Loki) | no |
| enemy | utgard_thrall | Utgard thrall | Snorri, Gylfaginning 46 (the great hall of Utgard full of giants) | no |
| enemy | utgard_phantom | Phantom of Utgard | Snorri, Gylfaginning 47 (Utgarda-Loki reveals that everything was illusion) | no |
| enemy | utgard_illusion | Illusion of Utgarda-Loki | Snorri, Gylfaginning 44-47 (Utgarda-Loki's illusions) | no |
| boss | logi | Logi | Snorri, Gylfaginning 46-47 (Logi, "wildfire", wins the eating contest against Loki) | no |
| boss | hugi | Hugi | Snorri, Gylfaginning 46-47 (Hugi, "thought", outruns Thjalfi three times) | no |
| boss | utgarda_loki | Útgarða-Loki | Snorri, Gylfaginning 44-47 (the giant king of Utgard and his illusions) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| logi_entrance | boss entrance | logi | Meat, bones, trough... and now you. | Gylfaginning 46 (the eating contest) | no |
| hugi_entrance | boss entrance | hugi | Run, if you like. I'll be there before you. | Gylfaginning 46 (the race) | no |
| utgarda_loki_entrance | boss entrance | utgarda_loki | Welcome to Utgard, little ones. Nothing here is what it seems. | Gylfaginning 47 | no |
| utgarda_loki_thor | boss meets god (with thor) | utgarda_loki | Thor! Did you ever finish that horn? The sea is still lower for it. | Gylfaginning 47 (the horn joined to the sea; the ebb tide) | no |

### Logres

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | logres | Logres | Geoffrey of Monmouth, Historia Regum Britanniae (1136); Malory, Le Morte d'Arthur (1485) | no |
| enemy | man_at_arms | Man-at-arms | Geoffrey of Monmouth, Historia Regum Britanniae 6 (Vortigern's soldiers) | no |
| boss | questing_beast | The Questing Beast | Thomas Malory, Le Morte d'Arthur (1485), 1.19-20 (the Questing Beast, hunted by King Pellinore) | no |
| boss | morgan_le_fay | Morgan le Fay | Thomas Malory, Le Morte d'Arthur (1485), 4.14 (Morgan steals Excalibur's scabbard and throws it into a lake) | no |
| boss | vortigern | Vortigern | Geoffrey of Monmouth, Historia Regum Britanniae (1136) 6.17-8.2 (the tower that fell each night; Vortigern burned in his tower) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| questing_beast_entrance | boss entrance | questing_beast | (From its belly comes a noise like thirty couple of hounds questing.) | Malory 1.19 | no |
| morgan_le_fay_entrance | boss entrance | morgan_le_fay | The scabbard is worth ten of the sword. And it is mine. | Malory 1.25, 4.14 (Merlin on the scabbard) | no |
| vortigern_entrance | boss entrance | vortigern | This time the tower will stand. | Geoffrey of Monmouth 6.17 | no |
| morgan_le_fay_king_arthur | boss entrance (as king_arthur) | morgan_le_fay | Brother! Looking for your scabbard? | Malory 4.14 | no |

### Pack 8 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| the_silent_drum | The Silent Drum | Every beat brings more. Silence the drum quickly. | Invented for Mythriven (Ghorvast) | no |
| the_fallen_banner | The Fallen Banner | Where the banner falls, the warriors falter. | Invented for Mythriven (Ghorvast) | no |
| unjudged | Unjudged | He condemns those who keep away. Stand before him. | Homer, Odyssey 11.568 (Minos judges the dead) | no |
| ariadnes_thread | Ariadne's Thread | Theseus didn't wander the Labyrinth. He went straight to the heart of it. | Plutarch, Theseus 19; Apollodorus, Epitome 1.8-9 (Ariadne's thread) | no |
| faster_than_thought | Faster Than Thought | Nothing outruns thought. Don't race him; stop him. | Snorri, Gylfaginning 46-47 (Hugi is thought) | no |
| seeing_through | Seeing Through | The horn was joined to the sea. See what is really there. | Snorri, Gylfaginning 47 (all of it was illusion) | no |
| the_scabbard_regained | The Scabbard Regained | The scabbard is worth ten of the sword. Win it back. | Malory, Le Morte d'Arthur 1.25, 4.14 (the scabbard worth ten of the sword) | no |
| the_burning_tower | The Burning Tower | Aurelius did not storm the tower. He burned it. | Geoffrey of Monmouth 8.2 (Aurelius burns Vortigern in his tower) | no |

## Pack 9: Gears and Plunder

### Lemnos

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | lemnos | Lemnos | Homer, Iliad 1.590-594 (Hephaestus falls on Lemnos) and 18 (his forge and its self-moving works) | no |
| enemy | bronze_automaton | Bronze automaton | Homer, Iliad 18.373-377 (Hephaestus' self-moving works) | no |
| enemy | golden_handmaiden | Golden handmaiden | Homer, Iliad 18.417-420 (Hephaestus' golden handmaidens) | no |
| boss | aeetes_bulls | The Bulls of Aeëtes | Apollodorus, Library 1.9.23 (the fire-breathing, bronze-footed bulls Hephaestus made, which Jason yoked) | no |
| boss | gold_silver_hounds | The Gold and Silver Hounds | Homer, Odyssey 7.91-94 (the gold and silver dogs Hephaestus made to guard the house of Alcinous) | no |
| boss | talos | Talos | Apollonius, Argonautica 4.1638-1688; Apollodorus, Library 1.9.26 (the bronze giant; the nail in his ankle) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| aeetes_bulls_entrance | boss entrance | aeetes_bulls | (Fire roars from two bronze mouths. The ground smokes under their feet.) | Apollodorus 1.9.23 | no |
| gold_silver_hounds_entrance | boss entrance | gold_silver_hounds | (Two hounds of gold and silver, immortal and ageless, rise from beside the door.) | Odyssey 7.91-94 | no |
| talos_entrance | boss entrance | talos | Three times round the island every day. Nothing lands that I don't see. | Argonautica 4.1638-1688 | no |
| talos_poseidon | boss meets god (with poseidon) | talos | Earth-shaker, your ships do not land here. | Original line written for Mythriven | no |

### The Goblin Market

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | the_goblin_market | The Goblin Market | Christina Rossetti, Goblin Market (1862) | no |
| enemy | goblin_man | Goblin man | Christina Rossetti, Goblin Market (1862): the goblin merchant-men | no |
| enemy | rat_goblin | Rat-paced goblin | Christina Rossetti, Goblin Market (1862): "one tramped at a rat's pace" | no |
| boss | ratel_goblin | The Ratel Goblin | Christina Rossetti, Goblin Market (1862): "one like a ratel tumbled hurry skurry" | no |
| boss | snail_goblin | The Snail Goblin | Christina Rossetti, Goblin Market (1862): "one crawled like a snail" | no |
| boss | goblin_merchants | The Goblin Merchant-Men | Christina Rossetti, Goblin Market (1862): the goblins crowd round Lizzie trying to make her eat | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| ratel_goblin_entrance | boss entrance | ratel_goblin | (It comes tumbling hurry skurry down the glen.) | Rossetti, Goblin Market | no |
| snail_goblin_entrance | boss entrance | snail_goblin | Come buy... come... buy... | Rossetti, Goblin Market (the goblins' cry) | no |
| goblin_merchants_entrance | boss entrance | goblin_merchants | Come buy our orchard fruits, come buy, come buy! | Rossetti, Goblin Market (the goblins' cry) | no |
| goblin_merchants_persephone | boss meets god (with persephone) | goblin_merchants | A lady who knows what fruit can cost! Just one seed, my queen? | Original line written for Mythriven (Persephone's pomegranate) | no |

### Libertalia

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | libertalia | Libertalia | A General History of the Pyrates (1724), "Of Captain Misson" (Libertalia on Madagascar) | no |
| enemy | buccaneer | Buccaneer | A General History of the Pyrates (1724): the crews of Libertalia | no |
| enemy | musketeer | Musketeer | A General History of the Pyrates (1724) | no |
| enemy | gull | Gull | The gulls of the shore | no |
| boss | sea_serpent | The Sea Serpent | Erik Pontoppidan, The Natural History of Norway (1752-53): the great sea serpent | no |
| boss | misson | Captain Misson | A General History of the Pyrates (1724), "Of Captain Misson" (the founder of Libertalia, a figure of the book) | no |
| boss | kraken | The Kraken | Erik Pontoppidan, The Natural History of Norway (1752-53): the Kraken, its arms and its whirlpool | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| sea_serpent_entrance | boss entrance | sea_serpent | (A row of great humps breaks the surface of the bay.) | Pontoppidan (the sea serpent's coils) | no |
| misson_entrance | boss entrance | misson | Welcome to Libertalia, where every man is free. Now surrender. | A General History of the Pyrates (1724) | no |
| kraken_entrance | boss entrance | kraken | (The islands in the bay begin to move.) | Pontoppidan (the Kraken mistaken for islands) | no |
| kraken_poseidon | boss meets god (with poseidon) | kraken | (The sea-beast rolls an eye the size of a cartwheel toward the Earth-shaker.) | Original description written for Mythriven | no |

### The Hollow Hills

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | the_hollow_hills | The Hollow Hills | Paracelsus, Liber de Nymphis (1566: the gnomes); L. Frank Baum, Ozma of Oz (1907: the Nome kingdom) | no |
| enemy | nome | Nome | L. Frank Baum, Ozma of Oz (1907): the Nomes of the underground kingdom | no |
| enemy | gnome | Gnome | Paracelsus, Liber de Nymphis, Sylphis, Pygmaeis et Salamandris (1566): the gnomes | no |
| boss | kaliko | Kaliko | L. Frank Baum, Ozma of Oz (1907): Kaliko, the Nome King's chief steward | no |
| boss | hammer_giant | The Giant with the Hammer | L. Frank Baum, Ozma of Oz (1907), ch. 13: the giant of cast iron who pounds the road to the Nome King's kingdom | no |
| boss | nome_king | The Nome King | L. Frank Baum, Ozma of Oz (1907; the book only): the Nome King, his ornaments, and the Nomes' fear of eggs | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| kaliko_entrance | boss entrance | kaliko | His Majesty is busy. I know every tunnel here, and you don't. | Ozma of Oz (Kaliko, the steward) | no |
| hammer_giant_entrance | boss entrance | hammer_giant | (BANG. BANG. BANG. The hammer never stops.) | Ozma of Oz, ch. 13 | no |
| nome_king_entrance | boss entrance | nome_king | Welcome, welcome! You'll make a lovely ornament. | Ozma of Oz (his game of ornaments) | no |
| nome_king_mokosh | boss meets god (with mokosh) | nome_king | Mother of the damp earth! All that is under it is mine. | Original line written for Mythriven | no |

### Pack 9 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| medeas_ointment | Medea's Ointment | Jason was anointed against the fire. Be quicker than the flames. | Apollodorus 1.9.23 (Medea's ointment kept the bulls' fire from burning Jason) | no |
| the_nail | The Nail | One vein, one nail. Strike when it shows. | Apollodorus 1.9.26 (the nail that stopped Talos' one vein) | no |
| lizzies_errand | Lizzie's Errand | Lizzie did not linger in the glen. Neither should you. | Rossetti, Goblin Market (Lizzie runs home through the glen) | no |
| no_thanks | No Thanks | Lizzie held her mouth shut through all their coaxing. | Rossetti, Goblin Market (Lizzie pays her silver penny but will not eat) | no |
| the_free_sailor | The Free Sailor | Watch the lanes, and stand between them. | A General History of the Pyrates (1724), "Of Captain Misson" | no |
| not_an_island | Not an Island | The sailors who thought it an island were dragged down. Don't wait for the whirlpool. | Pontoppidan (1752-53): the Kraken mistaken for islands; its whirlpool | no |
| between_the_blows | Between the Blows | The hammer keeps a steady beat. Learn it. | Baum, Ozma of Oz (1907), ch. 13 (passing the Giant with the Hammer) | no |
| billinas_eggs | Billina's Eggs | A hen once beat the Nome King. Eggs are your best weapon here. | Baum, Ozma of Oz (1907): Billina the hen's eggs undo the Nomes | no |

## Pack 10: The Heavens

### Hyperborea

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | hyperborea | Hyperborea | Herodotus, Histories 4.13-36 (the Hyperboreans, the Arimaspians and the griffins); Pindar, Pythian 10 | no |
| enemy | arimaspian | Arimaspian | Herodotus, Histories 4.13, 4.27 (the one-eyed Arimaspians) | no |
| enemy | young_griffin | Young griffin | Herodotus, Histories 3.116, 4.13 (the gold-guarding griffins) | no |
| enemy | feather_flurry | Flurry of feathers | Herodotus, Histories 4.7, 4.31 (the air of the north full of feathers: snow) | no |
| boss | arimaspian_chieftain | The Arimaspian Chieftain | Herodotus, Histories 3.116, 4.13, 4.27 (the one-eyed Arimaspians steal the griffins' gold) | no |
| boss | six_month_sleeper | The Six-Month Sleeper | Herodotus, Histories 4.25 (men of the far north who were said to sleep six months of the year) | no |
| boss | griffin_matriarch | The Griffin Matriarch | Herodotus, Histories 3.116, 4.13, 4.27 (the griffins that guard the gold of the north); GAME_DESIGN.md (the griffin matriarch) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| arimaspian_chieftain_entrance | boss entrance | arimaspian_chieftain | One eye is enough to see gold. | Herodotus 4.27 | no |
| six_month_sleeper_entrance | boss entrance | six_month_sleeper | Mmh... is it spring already? | Herodotus 4.25 | no |
| griffin_matriarch_entrance | boss entrance | griffin_matriarch | (A great griffin rises from her nest of gold and screams.) | Herodotus 4.13 | no |
| griffin_matriarch_skadi | boss meets god (with skadi) | griffin_matriarch | (The griffin bows her head to the huntress of the snows, and then attacks anyway.) | Original description written for Mythriven | no |

### The Empyrean

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | the_empyrean | The Empyrean | Aratus, Phaenomena; Ptolemy, Almagest (the sphere of the fixed stars and the constellations) | no |
| enemy | star_hound | Star hound | Aratus, Phaenomena; Hyginus, De Astronomia 2.35-36 (the dogs of Orion among the stars) | no |
| enemy | star_mote | Star mote | Aratus, Phaenomena (the countless lesser stars) | no |
| enemy | comet | Comet | Aristotle, Meteorologica 1.6-7 (the comets, "hairy stars") | no |
| boss | scorpion | The Scorpion | Ovid, Fasti 5.537-544; Hyginus, De Astronomia 2.26 (the scorpion Earth sent against Orion, set in the sky) | no |
| boss | great_bear | The Great Bear | Ovid, Metamorphoses 2.401-530 (Callisto made a bear and set in the stars); Aratus, Phaenomena 26-62 (the Bears that turn round the pole) | no |
| boss | orion | Orion | Apollodorus, Library 1.4.3-5 (Orion the hunter, blinded and healed by the sunrise); Aratus; Hyginus, De Astronomia 2.34 | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| scorpion_entrance | boss entrance | scorpion | (The Scorpion rises over the rim of the sky, and somewhere Orion sets.) | Hyginus 2.26 | no |
| great_bear_entrance | boss entrance | great_bear | (She turns round the pole, as she always has, and never sets.) | Aratus 26-62 | no |
| orion_entrance | boss entrance | orion | Every beast on earth, I said. You'll do. | Ovid, Fasti 5 (Orion's boast) | no |
| orion_skadi | boss meets god (with skadi) | orion | A huntress! Shall we see whose arrow flies true? | Original line written for Mythriven | no |

### The Glass Mountain

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | the_glass_mountain | The Glass Mountain | The Brothers Grimm, KHM 25 and KHM 196 (the glass mountain); Andersen, The Snow Queen (1844) | no |
| enemy | white_bee | White bee | Andersen, The Snow Queen (1844): "the white bees are swarming" (the snowflakes) | no |
| enemy | snowflake_guard | Snowflake guard | Andersen, The Snow Queen (1844), 7th story: her advance guard of living snowflakes | no |
| boss | seven_ravens | The Seven Ravens | The Brothers Grimm, The Seven Ravens (KHM 25): seven brothers turned into ravens, living in the glass mountain | no |
| boss | rinkrank | Old Rinkrank | The Brothers Grimm, Old Rinkrank (KHM 196): the old man in the glass mountain and his ladder | no |
| boss | snow_queen | The Snow Queen | Hans Christian Andersen, The Snow Queen (1844; not any film): her kisses, and the pieces of ice that must make the word Eternity | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| seven_ravens_entrance | boss entrance | seven_ravens | (Seven ravens circle the glass mountain, crying with one voice.) | Grimm, KHM 25 | no |
| rinkrank_entrance | boss entrance | rinkrank | Who's on my mountain? Let down the ladder, let down the ladder! | Grimm, KHM 196 | no |
| snow_queen_entrance | boss entrance | snow_queen | Are you cold? Come here. One kiss, and you'll never feel the cold again. | Andersen, The Snow Queen (her kiss) | no |
| snow_queen_skadi | boss meets god (with skadi) | snow_queen | A goddess of the snows. Then you understand my palace. | Original line written for Mythriven | no |

### Demos Oneiron

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | demos_oneiron | Demos Oneiron | Homer, Odyssey 24.12 (the land of dreams); Ovid, Metamorphoses 11.583-649 (the House of Sleep) | no |
| enemy | dream | Dream | Ovid, Metamorphoses 11.613-615 (the empty dreams about the House of Sleep) | no |
| enemy | nightmare_beast | Nightmare beast | Ovid, Metamorphoses 11.638-640 (the beasts of Phobetor's nightmares) | no |
| boss | phantasos | Phantasos | Ovid, Metamorphoses 11.641-643 (Phantasos, who takes the shapes of earth, rock, water and wood) | no |
| boss | morpheus | Morpheus | Ovid, Metamorphoses 11.633-638 (Morpheus, who imitates the human form better than any) | no |
| boss | phobetor | Phobetor | Ovid, Metamorphoses 11.638-641 (Icelus to the gods, Phobetor to men: beast, bird and serpent) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| phantasos_entrance | boss entrance | phantasos | (The rock in front of you opens its eyes.) | Ovid 11.641-643 | no |
| morpheus_entrance | boss entrance | morpheus | You look familiar. Let me look more so. | Ovid 11.633-638 | no |
| phobetor_entrance | boss entrance | phobetor | Gods call me Icelus. You will call me what you call your worst dream. | Ovid 11.638-641 | no |
| phobetor_hecate | boss meets god (with hecate) | phobetor | Lady of the crossroads at night, we work the same hours. | Original line written for Mythriven | no |

### Pack 10 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| nothing_stolen | Nothing Stolen | The one-eyed thieves take gold with every blow. Give them none. | Herodotus 4.13, 4.27 (the Arimaspians steal the griffins' gold) | no |
| the_unrobbed_nest | The Unrobbed Nest | She swoops from the sky to guard her nest. End it before she can. | Herodotus 3.116, 4.13 (the griffins guard the gold) | no |
| the_bear_sets | The Bear Sets | She has never once set. Make her. | Ovid, Metamorphoses 2.527-530 (the Bear may never bathe in Ocean) | no |
| the_sunrise | The Sunrise | The hunter cannot see. That is the moment. | Apollodorus 1.4.3 (Orion's sight restored by the rising sun) | no |
| seven_brothers | Seven Brothers | Seven brothers, scattered twice. Catch them all. | The Brothers Grimm, The Seven Ravens (KHM 25) | no |
| eternity | Eternity | She promised Kai the whole world if he could make the word. Make it. | Andersen, The Snow Queen (1844): Kai makes the word, and Gerda's tears melt his heart | no |
| your_own_face | Your Own Face | He gives back what you give him. Give him less, and more surely. | Ovid, Metamorphoses 11.633-638 (Morpheus the imitator) | no |
| the_gate_of_horn | The Gate of Horn | Wake before the nightmare finds its worst shape. | Homer, Odyssey 19.560-569 (true dreams come through the gate of horn) | no |

## Pack 11: The Abyss

### Ashkarrow

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | ashkarrow | Ashkarrow | Invented for Mythriven (GAME_DESIGN.md marks Ashkarrow invented) | no |
| enemy | ash_fiend | Ash fiend | Invented for Mythriven (GAME_DESIGN.md: Ashkarrow is invented, as public demon lore is religious) | no |
| enemy | cinder_imp | Cinder imp | Invented for Mythriven (GAME_DESIGN.md: Ashkarrow is invented, as public demon lore is religious) | no |
| boss | chain_warden | The Chain Warden | Invented for Mythriven (GAME_DESIGN.md: Ashkarrow is invented, as public demon lore is religious) | no |
| boss | ash_colossus | The Ash Colossus | Invented for Mythriven (GAME_DESIGN.md: Ashkarrow is invented, as public demon lore is religious) | no |
| boss | lord_of_ashkarrow | The Lord of Ashkarrow | Invented for Mythriven (GAME_DESIGN.md: Ashkarrow is invented, as public demon lore is religious); GAME_DESIGN.md (the realm's lord) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| chain_warden_entrance | boss entrance | chain_warden | No one leaves Ashkarrow. | Original line written for Mythriven | no |
| ash_colossus_entrance | boss entrance | ash_colossus | (The ash heaps up, and up, and stands.) | Original description written for Mythriven | no |
| lord_of_ashkarrow_entrance | boss entrance | lord_of_ashkarrow | Kneel in the ash. Everyone does, in the end. | Original line written for Mythriven | no |
| lord_of_ashkarrow_sekhmet | boss meets god (with sekhmet) | lord_of_ashkarrow | A lioness of the burning sun? My city has room for one more fire. | Original line written for Mythriven | no |

### Dinas Emrys

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | dinas_emrys | Dinas Emrys | Historia Brittonum 40-42; "Lludd and Llefelys" (Red Book of Hergest, c. 1400; Lady Charlotte Guest's translation, 1849) | no |
| enemy | coraniad | Coraniad | "Lludd and Llefelys" (Red Book of Hergest, c. 1400; Lady Charlotte Guest's translation, 1849) (the Coraniaid, the first plague) | no |
| enemy | wyrmling | Wyrmling | Historia Brittonum 42 (the two "worms", dragons, found sleeping in the pool under the tower) | no |
| boss | coraniaid | The Coraniaid | "Lludd and Llefelys" (Red Book of Hergest, c. 1400; Lady Charlotte Guest's translation, 1849) (the Coraniaid hear every word the wind touches; Llefelys destroys them with water steeped with insects) | no |
| boss | feast_magician | The Magician of the Feast | "Lludd and Llefelys" (Red Book of Hergest, c. 1400; Lady Charlotte Guest's translation, 1849) (the third plague: a mighty man of magic who lulls the court asleep with music and carries off the provisions; Lludd keeps awake in a tub of cold water) | no |
| boss | white_dragon | The White Dragon | Historia Brittonum 42 (the white dragon under Vortigern's tower); "Lludd and Llefelys" (Red Book of Hergest, c. 1400; Lady Charlotte Guest's translation, 1849) (the dragons drink the mead, fall asleep and are buried at Dinas Emrys); GAME_DESIGN.md (the White Dragon) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| coraniaid_entrance | boss entrance | coraniaid | We heard you coming. We heard you thinking of coming. | "Lludd and Llefelys" (Red Book of Hergest, c. 1400; Lady Charlotte Guest's translation, 1849) | no |
| feast_magician_entrance | boss entrance | feast_magician | (Somewhere, a harp begins to play. Your eyes grow heavy.) | "Lludd and Llefelys" (Red Book of Hergest, c. 1400; Lady Charlotte Guest's translation, 1849) | no |
| white_dragon_entrance | boss entrance | white_dragon | (A white dragon heaves itself out of the hill, shaking off the dirt of centuries.) | Historia Brittonum 42 | no |
| white_dragon_rhiannon | boss meets god (with rhiannon) | white_dragon | (The dragon sniffs the air: horse and birdsong. It does not like it.) | Original description written for Mythriven | no |

### Atlantis

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | atlantis | Atlantis | Plato, Timaeus 24e-25d; Critias 113b-121c | no |
| enemy | atlantean_hoplite | Atlantean hoplite | Plato, Critias 113b-121c (119a: the heavy-armed soldiers of Atlantis) | no |
| enemy | atlantean_slinger | Atlantean slinger | Plato, Critias 113b-121c (119b: the slingers and stone-throwers of Atlantis) | no |
| boss | poseidons_bull | Poseidon's Bull | Plato, Critias 113b-121c 119d-e (the bulls in Poseidon's temple, hunted by the ten kings without weapons, with staves and nooses) | no |
| boss | gadeirus | Gadeirus | Plato, Critias 113b-121c 113d-114b (Poseidon makes rings of sea and land round Cleito's hill; Gadeirus, Atlas' twin, rules the end of the island toward the Pillars of Heracles) | no |
| boss | atlas_king | Atlas | Plato, Critias 113b-121c 114a (Atlas, first king), 116a-c (the walls coated in brass, tin and orichalcum); Timaeus 25c-d (the island sinks in a single day and night); GAME_DESIGN.md (Atlas, Plato's king, not the Titan) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| poseidons_bull_entrance | boss entrance | poseidons_bull | (The sacred bull paws the temple floor. You have no noose.) | Plato, Critias 113b-121c 119d | no |
| gadeirus_entrance | boss entrance | gadeirus | My brother rules the island. I rule the way to it. | Plato, Critias 113b-121c 114b | no |
| atlas_king_entrance | boss entrance | atlas_king | Brass, tin, orichalcum. Atlantis has never fallen. Not yet. | Plato, Critias 113b-121c 116a-c | no |
| atlas_king_poseidon | boss meets god (with poseidon) | atlas_king | Father? You let the sea take us. | Plato, Critias 113c-114a (Atlas, Poseidon's son) | no |

### Ginnungagap

| Kind | Id | Name | Source in data | Verified |
| --- | --- | --- | --- | --- |
| level | ginnungagap | Ginnungagap | Völuspá 3; Vafþrúðnismál 35; Snorri, Gylfaginning 4-7 | no |
| enemy | venom_rime | Venom rime | Snorri, Gylfaginning 4-7 (5: the venom of the Élivágar rivers hardened like slag, and rime grew over it) | no |
| enemy | rime_drop | Rime drop | Snorri, Gylfaginning 4-7 (5: where the rime met the warm air from Muspelheim, it thawed and dripped, and the drops quickened with life) | no |
| boss | audhumla | Auðumbla | Snorri, Gylfaginning 4-7 (6: the cow Auðumbla, made from the dripping rime; four rivers of milk flowed from her udder, and she licked the salty rime-blocks) | no |
| boss | bergelmir | Bergelmir | Vafþrúðnismál 35 (Bergelmir laid on a lúðr); Snorri, Gylfaginning 4-7 (7: so much blood ran from Ymir's wounds that all the frost giants drowned but Bergelmir, who climbed with his wife on to his lúðr) | no |
| boss | void_herald | The Herald of the Void | Invented for Mythriven (GAME_DESIGN.md: an invented herald of the void, in the Eddas' Ginnungagap); Gylfaginning 4-5 (Niflheim's rime and Muspelheim's fire meeting in the gap) | no |

| Banter id | When | Speaker | Line | Source | OK? |
| --- | --- | --- | --- | --- | --- |
| audhumla_entrance | boss entrance | audhumla | (A vast cow lifts her head from the salt-rime and lows.) | Snorri, Gylfaginning 4-7 (6) | no |
| bergelmir_entrance | boss entrance | bergelmir | All my kin drowned. I did not. Think on that. | Vafþrúðnismál 35 | no |
| void_herald_entrance | boss entrance | void_herald | Before the world, there was the gap. After it, the gap. | Original line written for Mythriven | no |
| void_herald_odin | boss meets god (with odin) | void_herald | Ymir's killer. You built your world from his body, over my emptiness. | Original line written for Mythriven; Gylfaginning 8 (Odin and his brothers make the world from Ymir) | no |

### Pack 11 secrets (Oracle hints are original drafts)

| Id | Name | Hint | Source | OK? |
| --- | --- | --- | --- | --- |
| unchained | Unchained | No one leaves Ashkarrow, he says. Don't let him catch you. | Invented for Mythriven (Ashkarrow) | no |
| the_cold_hearth | The Cold Hearth | Four fires guard the lord of ash. Let all four go out together. | Invented for Mythriven (Ashkarrow) | no |
| wide_awake | Wide Awake | Lludd kept awake in cold water. Do the same. | "Lludd and Llefelys" (Lludd keeps awake in a vessel of cold water) | no |
| the_dragons_sleep | The Dragon's Sleep | Lludd caught the dragons with mead under a silk cloth. Uncover it. | Historia Brittonum 42; "Lludd and Llefelys" (the dragons drink the mead and sleep) | no |
| staves_and_nooses | Staves and Nooses | The kings of Atlantis hunted without iron. | Plato, Critias 119d-e (the bulls hunted with staves and nooses) | no |
| the_three_walls | The Three Walls | Brass, tin, orichalcum. Then again. | Plato, Critias 116a-c (the walls of brass, tin and orichalcum) | no |
| the_hungry_cow | The Hungry Cow | The first cow lives on salt. Take it from her. | Snorri, Gylfaginning 6 (Auðumbla licks the salty rime-blocks) | no |
| where_rime_meets_fire | Where Rime Meets Fire | Bring fire to his rime, and rime to his fire. | Snorri, Gylfaginning 5 (where the rime met the heat, life quickened) | no |

## Not checked here

- Enemy fodder, events, and Words of Legend lines: listed sources are in their data files; check them the same way before release.
- Art and audio: when they arrive, research period clothing, weapons, and symbols from museum sources (GAME_DESIGN.md: Art).
