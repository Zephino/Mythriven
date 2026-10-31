# Mythriven — Game Design (v3)

Oct 25, 2026 · @Ray

## Overview

Mythriven is a top-down 2D pixel-art roguelike survivor for PC and mobile, built in Godot 4, where legendary **Heroes** from the world's mythologies make a last stand against an endless tide of chaos, and **Gods** awakened in ruined shrines lend their power as summons. Every run ends in defeat; gold and everything else earned for use outside a level carry over. Up to 4 players can play online co-op with a 6-digit code.

The hook: **gods you earn mid-run by passing their trials, summon on your own timing, and combine across pantheons into Divine Resonances**, plus Heroes whose abilities come straight from their legends (Heracles' labors, Cú Chulainn's salmon leap), an elemental combat system, and a level for each mythic region with bosses from its own myths.

Nothing in this design comes from Final Fantasy. All content draws on public-domain mythology and legend, presented with our own art, writing, and characterization.

**For Cursor:** this file is the source of truth. Read it before every task. Build one phase at a time (see Build phases). Never remove working features when adding new ones. If something here is unclear, ask instead of guessing. Every feature is tagged **\[Launch\]**, **\[Post-launch\]**, or **\[Future\]**; only build \[Launch\] items unless told otherwise.

**Design pillars**

1. **Simple to play, deep to build.** Movement plus two god buttons. Depth comes from Hero, weapons, elements, and god combinations.
2. **Gods are the star.** Earning them through trials, timing their summons, and pairing them into Resonances is what players remember.
3. **Legends feel like their myths.** Each Hero's signature ability comes from a famous deed or trait in their story.
4. **Choices have tradeoffs.** Elemental weaknesses, resistances, and reactions mean the biggest number isn't always the best pick.
5. **Movement is skill.** Smart targeting handles aiming; the player's job is dodging telegraphed danger and positioning.
6. **Every run ends, and every run counts.** Milestones, gold, and discoveries make each run feel like progress.
7. **Runs smoothly on phones.** Hundreds of enemies at 60 FPS on a mid-range phone.
8. **Respectful and original.** Myths are public domain, but cultures and modern adaptations are not ours to take carelessly (see Cultural care and IP).

## Cultural care and IP rules

Ancient myths and legends are public domain, so names like Heracles or Thor are free to use; the risks are (1) offending living religious communities and (2) copying a modern company's version of a myth. Your reference database already flags 112 of 277 gods and 57 of 152 heroes as belonging to living traditions; this design turns those flags into three tiers. This is a design recommendation, **not legal or cultural clearance**.

**Tier A: use** \[Launch\]. Traditions no longer widely practiced as organized religion, or legendary/literary heroes. Depict with dignity: no mocking gods, no sexualized depictions, gods are never cannon-fodder enemies.

| Use as | Traditions |
| --- | --- |
| Gods (summons) | Greek, Norse, Egyptian, Celtic, Mesopotamian, Slavic, Canaanite, Hittite/Hurrian |
| Heroes (playable) | Greek, Norse/Germanic, Irish/Celtic, Welsh/Arthurian, Mesopotamian, Persian epic (Shahnameh), Finnish (Kalevala), Japanese historical legend (e.g. Tomoe Gozen, Yoshitsune, Benkei, Raikō), Chinese literary/legendary heroes (e.g. Hua Mulan, Hou Yi), Korean founding legend |

Note: Norse, Celtic, Slavic, Greek, and Egyptian religions have small modern revival communities. Tier A doesn't mean careless; it means respectful use is widely accepted.

**Gods and heroes as bosses** \[new in v3.1\]. Some bosses are Tier A gods or heroes, chosen by these rules:

- **Adversaries in their own myths:** figures their stories cast as rivals, tricksters, or chaos (Kronos, Loki, Set, Balor, Mordred). They act in the game much as they do in their myths.
- **Trials and duels:** heroes famous for testing others fight you to measure your worth (Achilles, Scáthach). Defeating them unlocks them as playable Heroes.
- **Framing:** bosses are echoes pulled out of their stories by the Unweaving, not the gods' "true" selves, so a god can be honored in the Compendium while their mythic conflict plays out in a fight.
- **No benevolent major deities as villains** (Zeus, Odin, Ra, Isis, Athena, etc.).
- **Nuance in lore text:** Set was also revered in Egypt and defended Ra's sun-boat against Apep; Loki is both helper and enemy of the gods. Their Compendium entries say so, and their fights are framed as their mythic rivalries, never as pure evil.
- A god who is a boss in a level is never in that level's shrine pool, so a god is never your summon and your enemy in the same run.

**Naming and lore sourcing rules** \[new in v3.3, applies to everything\]

Every name for a character, god, creature, place, realm, item, or ability is chosen in this order. Invention is the last resort, used only when no public source exists.

1. **Public-domain names first.** Use names from ancient mythology, folklore, legend, and old literature whose copyright has expired. As a working test: in the US, works published in 1930 or earlier are public domain as of 2026; most other countries require the author to have died more than 70 years ago. Ancient myths, medieval texts, and traditional folklore always qualify.
2. **Pull the lore from the same public source.** Traits, abilities, appearance, and story beats come from what the old sources say. Record the source in the entry's `lore_source` field.
3. **Use the old source, never a modern adaptation.** Atlantis comes from Plato, not Disney; Nidavellir from the Eddas, not Marvel; Carmilla from Le Fanu's 1872 novella, not a film; Laputa from Swift, not Studio Ghibli. Modern adaptations' designs, added characters, and changes are off limits.
4. **Never use terms invented by modern franchises,** even if they sound generic: Feywild, drow, beholder, mind flayer, Dragonborn, Lich King, Noble Phantasm, Servant, and anything from Final Fantasy.
5. **Invent only as a last resort.** When no public-domain name or lore fits something the game needs, invent it, mark the entry `invented: true`, and run a trademark and store search on the name before release.
6. **Cultural tiers still apply.** A public-domain name from a Tier C tradition is still not used.
7. **Public domain isn't trademark-free.** A public-domain name can still be someone's registered game title or brand, so search any name used as a title, logo, or product name.

**Invented names currently in the design** (as of v3.3; replace any of them if public lore turns up): the game title Mythriven; the setting terms the Unweaving, the Unwoven, the Crossroads, and the Hall of Legends; the Crossroads finale boss the Unweaver (public-domain alternative: Khaos, the primordial void of Greek myth); and three fantasy realms with no suitable public source, listed in Fantasy realms. Game-system words (Resonance, Blessing, Omens, Guard gauge) are ordinary vocabulary, not names, and don't count.

**Tier B: only after cultural review** \[Post-launch at the earliest\]. Actively worshipped in places today, or tied to living descendant communities. Include only with input from people of that culture.

- Chinese folk/Daoist deities and deified heroes (Guan Yu/Guandi, Nezha, Erlang Shen, Mazu); Sun Wukong (mainly literary, but worshipped at some temples).
- Japanese Shinto kami (Amaterasu, Susanoo, Raijin, Fujin, Hachiman).
- Aztec, Maya, and Inca gods and the Popol Vuh Hero Twins.
- Filipino and West African epic heroes (Lam-ang, Aliguyon, Sundiata, Fakoli), which remain part of living oral traditions.

**Tier C: do not use as playable Heroes or summons.** Figures sacred in major living religions, where use as a game power-up is very likely to cause real offense (Hindu groups, for example, have publicly objected to deities appearing in games).

- Hindu deities and Hindu epic heroes (Ramayana, Mahabharata).
- Yoruba orishas; Hawaiian and Māori atua and heroes (including Māui); Diné holy people.
- Figures from Hebrew Bible, Christian, Islamic, Sikh, and Buddhist traditions.

**Accuracy:** the database's own notes say rows are starting points and some source links cover a whole tradition, not the individual figure. Before writing any Hero or god's lore, check it against a primary source or a reliable reference, and record the source in the data file.

**Modern adaptations: don't copy** designs, characterizations, names they invented, or signature looks from:

- Marvel (Thor, Loki, Odin designs), Disney (Hercules, Mulan, Moana), Percy Jackson.
- God of War, Hades and Hades II, Smite, Age of Mythology, Assassin's Creed Odyssey/Valhalla.
- Fate/Grand Order (its summoned-legend designs such as Cú Chulainn, Gilgamesh, Arthur; its terms "Servant" and "Noble Phantasm"), Persona and Shin Megami Tensei (demon/persona designs).
- Dungeons & Dragons' five-headed Tiamat.

Mythological names and story details are fine; the specific modern visual designs, invented characters (e.g. Kratos as God of War depicts him, Zagreus' characterization), and franchise terms are not.

**Final Fantasy:** nothing from it is used. The v2 terms (Spirits, Pact Stones, Wardens, the Gloam) are replaced by the mythology framing below.

**Our terms**

| Concept | Term |
| --- | --- |
| Playable characters | Heroes |
| Summons | Gods |
| Summon shrines | Shrines (look varies by pantheon: Greek temple, Norse runestone, Egyptian obelisk, Celtic stone circle) |
| Gold spent on gods | Offerings |
| Enemies | the Unwoven |
| Hub menu | Hall of Legends |
| Currency | Gold |

**Title: Mythriven** (decided). An invented word ("myth" + "riven," meaning torn apart), which fits the Unweaving. A quick web search in October 2026 found no game or product with this exact name, but that isn't clearance: before making the Steam page, run trademark searches (USPTO, EUIPO, UK IPO) and search Steam, the App Store, and Google Play.

**Assets:** only assets we make, commission, or buy with a commercial license; keep `CREDITS.md`. Before release, have names, art, and the cultural-tier list reviewed by an IP lawyer and, for any Tier B content, cultural consultants.

## World and tone

All the world's myths are threads in one great tapestry, and something is pulling them apart; where the threads fray, legends from every culture spill into one endless borderland, which is why Heroes and gods of different pantheons fight side by side, and why the stand always ends. \[Launch: used in menus, god dialogue, bestiary text. No story mode.\]

**The Unweaving.** Many mythologies imagine fate as something woven. Our original setting takes that image literally: every myth is a thread, and a primordial chaos is unraveling them. Its herald is Apep, the chaos serpent of Egyptian myth who tries to swallow the sun each night, here grown vast enough to threaten every story at once.

**The Crossroads.** Where myths fray, they bleed together into the Crossroads: an endless land where Greek columns stand beside Norse runestones, Egyptian obelisks, and Celtic stone circles. The procedural world is this place.

**Heroes** are pulled from their legends at the height of their deeds to make a **Last Stand** (one run). None can win. Each falls eventually, but the gold they leave behind becomes **offerings** that strengthen the gods for the next Hero.

**Gods** are weakened and sleeping in shrines across the Crossroads. Echoing countless myths in which gods test mortals, some lend their power to anyone who asks; others demand a trial first. Each god speaks one short line when found, bound, and summoned. Gods appear in their own culture's style but rendered in our art, dignified and powerful.

**The Unwoven** are the enemies: creatures and the restless dead torn from their myths (shades, draugr, harpies, kelpies) and twisted by chaos. Their element shows in their color.

**Mythic monsters** are the bosses: great beings of chaos from many traditions (fire giants, frost giants, the chaos serpent).

**The night deepens.** A run moves through **Ages**: Dusk (0–10 min), Night (10–20), Deep Night (20–30), and the Unraveling (30+), when the world itself comes apart and the stand ends.

**Hall of Legends** (menu hub): a place outside time where fallen Heroes rest and offerings are made.

**Tone:** heroic, colorful, and a little melancholy, in a 16-bit pixel style that's our own. Each pantheon gets a recognizable palette and architecture so players feel the cultures meeting, never a copy of any other game's art.

## Regional levels

### Pack roadmap \[decided\]

**Build only Pack 1 first.** No other pack is started until Pack 1 is fully working, tested, and fun. After that, packs are added one at a time. All 54 levels below are approved for the future; their details are in this section and in Fantasy realms.

| Pack | Name | Levels | Status |
| --- | --- | --- | --- |
| 1 | Legends of the West | 1 The Aegean Shore · 2 Midgard's Edge · 3 The Two Lands · 4 The Misty Isles | **Build now** (Aegean Shore first as the vertical slice) |
| 2 | Deeper Myths | 5 The Underworld · 6 Jotunheim · 7 Avalon's Shadow · 8 Land Between the Rivers | Later |
| 3 | Distant Legends | 9 Pohjola · 10 Mazandaran · 11 The Slavic Wilds · 12 The Land of Legends | Later |
| 4 | Elemental Planes | 13 Muspelheim · 14 Niflheim · 15 Ys · 16 Cloud-Cuckoo-Land | Later |
| 5 | Gothic Night | 17 Erebus · 18 Karnstein · 19 Ossory · 20 The Brocken | Later |
| 6 | The Deep Below | 21 Nidavellir · 22 Svartalfheim · 23 Mycendra · 24 The Myrmidon Hive | Later |
| 7 | The Wild Green | 25 Alfheim · 26 Elfame · 27 Arcadia · 28 Lerna | Later |
| 8 | Warlords | 29 Ghorvast · 30 Knossos · 31 Utgard · 32 Logres | Later |
| 9 | Gears and Plunder | 33 Lemnos · 34 The Goblin Market · 35 Libertalia · 36 The Hollow Hills | Later |
| 10 | The Heavens | 37 Hyperborea · 38 The Empyrean · 39 The Glass Mountain · 40 Demos Oneiron | Later |
| 11 | The Abyss | 41 Ashkarrow · 42 Dinas Emrys · 43 Atlantis · 44 Ginnungagap | Later |
| 12 | Otherworlds | 45 Tír na nÓg · 46 Hy-Brasil · 47 The Shadow's Court · 48 The Knockers' Deep | Later |
| 13 | Wild Frontiers | 49 Mount Pelion · 50 Dovrefjell · 51 The City of Brass · 52 The Sea King's Hall | Later |
| Extra | Bonus and finale | 53 Realm of the Ten Suns · 54 The Crossroads (finale) | Later |

Pack names are working labels. The Act tables below are the same levels: Act I = Pack 1, Act II = Pack 2, Act III = Pack 3, Act IV = the extras. Fantasy realm packs still need two more bosses designed per level, from the same public-domain lore, before they're built.

The game has **14 regional levels plus a finale**, grouped into Acts that match Packs 1–3 plus the extras in the Pack roadmap. Each level is an endless procedural map with the same 30-minute run arc, but its own look, music, environmental hazard, enemy families, local gods, and three bosses from that region's myths. Any Hero can play any level. All regions are Tier A (see Cultural care and IP).

**Act I — Launch**

| # | Level | Region | Look | Hazard | Enemy families | Local gods |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | **The Aegean Shore** | Greek | Olive groves, marble ruins, wine-dark sea | Thunderstorm strikes | Shades, Harpies, Sirens (casters), Satyr skirmishers, Spartoi (brutes), bronze bulls (bombers) | Tyche, Poseidon |
| 2 | **Midgard's Edge** | Norse | Pine forest, runestones, longhouse ruins, snow | Blizzard push and low vision; frozen ponds | Draugr, Frost Thursar, Muspel Sparks, Trolls | Thor, Skadi |
| 3 | **The Two Lands** | Egyptian | Desert, Nile reeds, obelisks, tombs | Sandstorms; quicksand | Shabti Guardians, scarab swarms, restless mummies, sand serpents | Sekhmet, Ra |
| 4 | **The Misty Isles** | Irish | Green hills, stone circles, bogs | Mist banks hide enemies; fairy rings teleport | Kelpies, Fomorian casters, Sluagh, Redcaps | Cernunnos, the Morrígan |

**Act II — First major update**

| # | Level | Region | Look | Hazard | Enemy families | Local gods |
| --- | --- | --- | --- | --- | --- | --- |
| 5 | **The Underworld** | Greek | Asphodel fields, river Styx, Tartarus chasms | Rivers of the dead slow and drain; chasms collapse (telegraphed) | Shades, Furies-kin flyers, skeletal hoplites, Stymphalian birds | Hecate, Persephone |
| 6 | **Jotunheim** | Norse | Mountain passes, giant-sized ruins, glaciers | Rockslides from cliffs | Frost Thursar, Trolls, giant wolves, ice wisps | Odin, Freyja |
| 7 | **Avalon's Shadow** | Welsh / Arthurian | Ruined castles, enchanted forest, misty lake | Enchanted brambles grow and block paths | Black knights, enchanted hounds, Afanc (lake beasts), will-o'-wisps | Rhiannon, Arawn |
| 8 | **The Land Between the Rivers** | Mesopotamian | Ziggurats, cedar forest, flood plains | Floods sweep across in bands | Scorpion-men, Ugallu storm-demons, dust demons, river serpents | Enki, Shamash |

**Act III — Second major update**

| # | Level | Region | Look | Hazard | Enemy families | Local gods |
| --- | --- | --- | --- | --- | --- | --- |
| 9 | **Pohjola** | Finnish (Kalevala) | Dark northern pine, frozen lakes, northern lights | Polar night: darkness pulses, shrinking vision | Hiisi forest-spirits, frost-wolves, swamp beasts | Ukko, Ilmatar\* |
| 10 | **Mazandaran** | Persian (Shahnameh) | Mountain forests, caves, palaces of the divs | Sorcerous darkness clouds | Divs (demons), sorcerers, wild lions, dragons-kin | Simurgh\*\* |
| 11 | **The Slavic Wilds** | Slavic | Birch forests, rivers, wooden villages, swamps | Wandering will-o'-wisp lights lure enemies and confuse controls briefly | Leshy-kin, Rusalki (water casters), wolves, firebirds-kin | Perun, Mokosh |
| 12 | **The Land of Legends** | Japanese historical legend | Mountain shrines' outer paths, bamboo, castle ruins | Falling cherry-blossom storms reduce vision | Oni, tengu-kin, earth spiders, restless warriors | none\*\*\* |

**Act IV — Final update**

| # | Level | Region | Look | Hazard | Enemy families | Local gods |
| --- | --- | --- | --- | --- | --- | --- |
| 13 | **The Realm of the Ten Suns** | Chinese legend | Scorched terraced hills, rivers, pagodas | Extreme heat bands (stand in shade) | Bone demons, fox spirits, fire beasts | none\*\*\* |
| 14 | **The Crossroads** (finale) | All | Every region's terrain blended and fraying | Rotates every Age between all hazards | All families | All pantheons |

\* Ukko and Ilmatar aren't in your reference database; verify their lore before use. \*\* No Persian gods are used: Zoroastrianism is a living religion. The Simurgh, the great mythic bird who protects Rostam's family in the Shahnameh, is a special non-god summon. \*\*\* Shinto kami and Chinese folk deities are Tier B, so these levels draw shrines from all pantheons.

**Unlock flow**

- Act I: the Aegean Shore is open at the start; beating a level's 20:00 boss unlocks the next level in the Act.
- Clearing all four 20:00 bosses in an Act unlocks the next Act; within an Act after the first level, levels can be played in any order.
- The Crossroads unlocks after defeating the 30:00 boss in at least 8 levels. Its final boss is the Unweaver, an original being (our IP).
- Shrines: 50% local pantheon, 50% any unlocked pantheon (100% any pantheon in levels without local gods).
- Hazards pause during boss arenas.
- Level select: a map of the Crossroads showing each region, best time, bosses defeated, and local gods.

**Content reuse rules** (how 14 levels stay buildable)

- Levels from the same culture (Greek ×2, Norse ×2, Celtic/Arthurian ×2) share about half their enemy families, decoration set, and musical themes, with palette and remix changes.
- **Hazard library:** about 8 reusable hazard scripts (strikes, push wind, vision shrink, slow ground, teleport rings, collapsing ground, sweeping bands, darkness). Each level is a data combination of these.
- **Boss toolkit:** every boss is the shared pattern library plus one signature-mechanic script and a data file.
- 3–4 new enemy families per level at most; elites (Minotaur, Cyclops, Troll, etc.) are shared across levels.
- Everything level-specific lives in `levels.json` and that level's wave table.

## Fantasy realms (other regions)

Beyond the 14 myth levels, the Unweaving also tears open fantasy realms: elves, dwarves, vampires, elemental planes, and more. There are 40 realms in 10 packs of 4 (Packs 4–13 in the Pack roadmap), available for future packs and mixable with myth packs in any order. Following the naming rules, every realm and boss name comes from public-domain folklore, myth, or old literature; only three realms with no suitable source use invented names. Realm levels use the same structure as myth levels (endless map, hazard, enemy families, 3 bosses) and draw shrine gods from every unlocked pantheon. \[Post-launch packs\]

| Pack | Realm | Realm type | Public-domain source | Boss idea from the same lore |
| --- | --- | --- | --- | --- |
| Elemental Planes | **Muspelheim** | Fire realm of salamanders | Norse Eddas; salamanders from Paracelsus (16th c.) | Sinmara, the fire-giantess |
| Elemental Planes | **Niflheim** | Ice realm | Norse Eddas | Níðhöggr, the dragon gnawing at the world-tree's roots |
| Elemental Planes | **Ys** | Sunken water city of undines | Breton legend; undines from Paracelsus | Dahut, the princess who opened the sea gates |
| Elemental Planes | **Cloud-Cuckoo-Land** | Sky realm of sylphs | Aristophanes' *The Birds*; sylphs from Paracelsus | The Roc (*One Thousand and One Nights*) |
| Gothic Night | **Erebus** | Realm of the restless dead | Greek myth | The Wild Hunt (European folklore) |
| Gothic Night | **Karnstein** | Vampire domain | Le Fanu's *Carmilla* (1872) | Carmilla |
| Gothic Night | **Ossory** | Werewolf forests | The werewolves of Ossory (Gerald of Wales, 12th c.); Marie de France's *Bisclavret* | The Beast of Gévaudan (French legend) |
| Gothic Night | **The Brocken** | Witches' mountain | German Walpurgis Night folklore | Black Annis (English folklore hag) |
| The Deep Below | **Nidavellir** | Dwarven forge-halls | Norse Eddas | Andvari and his cursed ring |
| The Deep Below | **Svartalfheim** | Realm of the svartálfar (dark elves) | Norse Eddas | Alberich, dwarf-king of the *Nibelungenlied* |
| The Deep Below | **Mycendra** (invented) | Fungal city | No public-domain source found | Invented |
| The Deep Below | **The Myrmidon Hive** | Insect-warrior city | Greek myth (Zeus turned the ants of Aegina into the Myrmidons) | Queen of the gold-digging ants (Herodotus) |
| The Wild Green | **Alfheim** | Elven realm | Norse Eddas | The Erlking (Danish folklore; Goethe's 1782 poem) |
| The Wild Green | **Elfame** | The Fae Court | Scottish ballads (*Thomas the Rhymer*, *Tam Lin*) | The Queen of Elfame |
| The Wild Green | **Arcadia** | Beastfolk wilds | Greek myth | Lycaon, the king turned wolf |
| The Wild Green | **Lerna** | Serpent-marsh of the Spartoi (warriors grown from dragon's teeth) | Greek myth | The Lernaean Hydra |
| Warlords | **Ghorvast** (invented) | Orc stronghold | "Orc" itself is public (Old English *orcneas*, Latin *Orcus*), but no city lore exists | Invented |
| Warlords | **Knossos** | Labyrinth city | Greek myth | Asterion, the Minotaur |
| Warlords | **Utgard** | Giants' fortress | Norse Eddas | Útgarða-Loki and his rigged contests |
| Warlords | **Logres** | Human kingdom | Arthurian legend | Vortigern, the usurper king |
| Gears and Plunder | **Lemnos** | Clockwork forge-island of automatons | Greek myth (Hephaestus's forge) | Talos, the bronze giant (*Argonautica*) |
| Gears and Plunder | **The Goblin Market** | Goblin bazaar-city | Christina Rossetti's *Goblin Market* (1862) | The Goblin Merchant-Men |
| Gears and Plunder | **Libertalia** | Pirate haven | Legend from *A General History of the Pyrates* (1724) | The Kraken (Norwegian folklore) |
| Gears and Plunder | **The Hollow Hills** | Gnomes' earth realm | British fairy-hill folklore; gnomes from Paracelsus | The Nome King (L. Frank Baum's 1907 *Ozma of Oz*; book version only) |
| The Heavens | **Hyperborea** | Radiant land beyond the north wind | Greek myth | The griffin matriarch (Herodotus's gold-guarding griffins) |
| The Heavens | **The Empyrean** | Star realm | Ptolemaic cosmology; Dante | Orion the hunter |
| The Heavens | **The Glass Mountain** | Crystal realm | European folktale | The Snow Queen (Andersen, 1844; not Disney's version) |
| The Heavens | **Demos Oneiron** | Land of dreams | Homer's *Odyssey* | Phobetor, bringer of nightmares (Ovid) |
| The Abyss | **Ashkarrow** (invented) | Demon city | Public demon lore is religious (Tier C), so invented | Invented |
| The Abyss | **Dinas Emrys** | Dragon realm | Welsh legend of Vortigern's tower and the dragons beneath it | The White Dragon |
| The Abyss | **Atlantis** | Lost ancient city | Plato's *Timaeus* and *Critias* | Atlas, first king of Atlantis (Plato's, not the Titan) |
| The Abyss | **Ginnungagap** | The void | Norse Eddas | Invented herald of the void, or Khaos if used here instead of the finale |
| Otherworlds (new) | **Tír na nÓg** | Fairy land of eternal youth | Irish legend | Finvarra, king of the Connacht fairies (Irish folklore) |
| Otherworlds (new) | **Hy-Brasil** | Phantom spirit isle that appears once every seven years | Irish legend | The Flying Dutchman (ghost-ship legend) |
| Otherworlds (new) | **The Shadow's Court** | Realm of living shadows | Hans Christian Andersen's *The Shadow* (1847) | The Shadow, who became its master's master |
| Otherworlds (new) | **The Knockers' Deep** | Haunted earth mines | Cornish mine folklore (knockers) | The Spriggan, a treasure-guarding giant (Cornish folklore) |
| Wild Frontiers (new) | **Mount Pelion** | Centaur plains and slopes | Greek myth (home of the centaurs) | Nessus, the centaur Heracles defeated |
| Wild Frontiers (new) | **Dovrefjell** | Troll kingdom of mountains and stone bridges | Norwegian folklore; Ibsen's *Peer Gynt* (1867) | The Mountain King of the Dovre trolls |
| Wild Frontiers (new) | **The City of Brass** | Desert kingdom | *One Thousand and One Nights* | The brass horseman guardian |
| Wild Frontiers (new) | **The Sea King's Hall** | Merfolk palace beneath the waves | Andersen's *The Little Mermaid* (1837) | The Sea Witch (Andersen's, not Disney's) |

**Race and creature names** (all public unless noted): elves, svartálfar (dark elves), dwarves, fae, gnomes, undines, sylphs, salamanders, goblins, orcs, trolls, giants, vampires, werewolves, witches, Myrmidons, Spartoi, Hyperboreans, griffins, automatons, centaurs, merfolk, spriggans, knockers. The Hyperboreans replace the earlier "angelic" idea, avoiding religious angels entirely.

**Notes**

- Some realms echo myth levels (Utgard and Jotunheim, Knossos and the Aegean Shore). Keep packs that share a culture apart, or give the realm a clearly different angle (Utgard's illusions versus Jotunheim's mountains).
- Atlantis, Libertalia, Nidavellir, and the Snow Queen all have famous modern adaptations (Disney, Uncharted, Marvel, Frozen). Design only from the old texts.
- The Red Dragon of Dinas Emrys is the Welsh national symbol, so the realm's boss is the White Dragon. Similarly, the City of Brass tale includes jinn, which come from Islamic belief (Tier C), so that level uses only its brass automatons and desert ruins.
- The earlier invented realm names (Calwyrren, Vesperault, and others) are replaced by these public-domain names, except the three marked invented.

## Tech stack and performance rules

Engine: **Godot 4 (latest stable 4.x), GDScript.** Export targets: Windows, macOS, Linux, Android, iOS. Landscape only on phones; resizable window on PC. Target 60 FPS with 500+ enemies on a mid-range phone.

**Rules for Cursor**

- Create enemies, projectiles, pickups, and effects in code from pooled objects. Keep `.tscn` scene files simple; when a step needs the Godot editor, give exact click-by-click instructions.
- **Object pooling** for enemies, projectiles, XP orbs, gold, damage numbers, status VFX, and ground hazards. Never `queue_free()` and re-instantiate during play.
- No per-enemy physics bodies. Move enemies in a manager script; check collisions with a **spatial hash grid** (cell \~64 px). Smart targeting queries the same grid.
- Draw large enemy counts efficiently (`MultiMeshInstance2D` or batched sprites).
- **Statuses are data, not nodes:** each pooled enemy stores status timers/stacks in arrays. Tick statuses at 5 Hz.
- **Effect budgets** (in `config.json`): max 40 ground hazards, 30 reactions per second, 20 regular-enemy projectiles, 8 identical sounds at once. When full, recycle the oldest.
- **All tuning numbers live in data files**, never hard-coded.
- **Multiplayer-ready from day one:** players are always a list. Game events (spawns, damage, drops, deaths, god binding) go through one `GameAuthority` script so they can later run only on the host.
- **Deterministic randomness:** separate seeded `RandomNumberGenerator`s for world generation, spawns, and loot.
- **Release content gate:** every Hero, god, and boss entry carries `care_tier` and `lore_verified` *(bosses added 10/29/2026, owner approved)*. Release builds refuse to load any entry that isn't `care_tier: "A"` with `lore_verified: true` (dev builds load everything, with a warning). This makes the cultural rules enforceable, not just a note.
- **Debug menu** \[Launch, dev builds only\]: F1 / three-finger tap. Spawn any enemy, boss, POI, or god; grant any weapon or level; set timer; show FPS, enemy count, spatial-hash overlay; god mode (the testing kind).
- Static typing in GDScript; keep scripts under \~300 lines.

**Folder structure**

```
res://
  data/        # JSON: config, heroes, weapons, passives, elements, gods, resonances,
               #       enemies, elite_modifiers, bosses, waves, pois, events, omens, achievements
  scenes/      # main.tscn, menus, hud
  scripts/
    core/      # game_authority, run_state, save_system, pools, spatial_hash, rng, content_gate, debug_menu
    world/     # chunk_manager, region_manager (POIs), camera, ages
    player/    # player, input, targeting, hero_traits/
    combat/    # weapons/, fire_patterns/, statuses, reactions, infusions, damage
    enemies/   # enemy_manager, spawner, behaviors/, elites
    bosses/    # boss_base, patterns/, telegraphs, guard_gauge
    gods/      # god_manager, shrines, trials/, triggers, summons/, resonance, patronage
    meta/      # unlocks, bestiary, codex, achievements, omens
    ui/        # hud, level_up, menus, compass
    net/       # lobby_service, sync
  assets/      # sprites, audio, fonts
reference/     # the mythology database files (design reference only, not shipped)
```

### Translation-ready text \[Launch, from Phase 1\]

Every word a player sees goes through Godot's translation system from the first line of code, so adding languages later means translating a file, not hunting through code. The game launches in English only.

- **No hard-coded text.** All player-facing text (menus, HUD, level-up cards, tips, banter, lore, achievements) uses translation keys through Godot's `tr()` function, e.g. `tr("UI_LEVEL_UP_TITLE")`.
- **Translation tables:** `res://localization/` holds the text tables (CSV or PO files) with one column per language; English is the source.
- **Data files store keys, not text.** In JSON, use `name_key` and `desc_key` (e.g. `"name_key": "HERO_CU_CHULAINN_NAME"`) instead of literal names and descriptions.
- **Room for longer text.** UI layouts allow text up to \~40% longer than English (German and Russian often run longer). Use containers that grow and wrap rather than fixed-width boxes.
- **Fonts with wide character coverage,** with fallback fonts for languages like Japanese, Chinese, Korean, and Cyrillic, so adding them later is a font setting, not a redesign.
- **Numbers, times, and plurals** are formatted through helper functions, never by gluing text together ("1 kill" vs "2 kills" differs by language).
- **Pseudo-localization test** in the debug menu: swaps every string for a longer, accented version ("\[Ŀéṽéŀ Ûƥ!!!\]") to catch any hard-coded or clipped text.
- **Names in other languages:** myth names have established forms in many languages (Heracles, Herakles, Hercules); translators use the standard public-domain form for their language, and the naming rules still apply.
- **Likely first languages** after launch: Spanish, Brazilian Portuguese, German, French, Russian, Japanese, Simplified Chinese, Korean.

## Core loop and run arc

A run is one Last Stand: pick a Hero, fight through four Ages of rising danger, earn gods, and fall; then make offerings with the gold you banked. Typical runs last 10–35 minutes. There is no win condition.

**In the Hall of Legends (menu)**

1. Pick a Hero.
2. Optionally pick Omens (challenge modifiers) and host/join co-op.
3. Begin the Last Stand.

**During the run**

1. Move. Weapons fire automatically using smart targeting.
2. Kill the Unwoven, collect XP orbs and gold.
3. Level up and choose 1 of 3 upgrades.
4. Find shrines; bind gods who accept you freely or pass their trials.
5. Summon gods with their buttons; trigger Resonance when a matched pair is ready.
6. Explore points of interest for risk/reward.
7. Survive milestones and mythic monster bosses as the Ages advance.

**After defeat**

1. Results: time, kills, level, gods bound, Resonances used, milestones, gold banked, new records and unlocks.
2. Keep the gold and everything earned for use outside a level (unlocks, discoveries, collections). Things used only inside the run are lost.
3. Spend gold in the Hall of Legends (offerings to gods, Hero unlocks, weapon unlocks).

**Run arc: the Ages** \[Launch\]

| Age | Time | Look | New threats | Milestone |
| --- | --- | --- | --- | --- |
| Dusk | 0–10 min | Warm golden light | Shades, draugr, swarms; first elite at 5:00 | Boss 1 at 10:00 |
| Night | 10–20 min | Blue moonlight, drifting embers | Ranged casters, armored brutes, elite modifiers | Boss 2 at 20:00 |
| Deep Night | 20–30 min | Loose glowing threads drift at screen edges | Encirclers, splitting elites, world events more often | Boss 3 at 30:00 |
| The Unraveling | 30:00+ | The world frays into void | A ring you can't leave closes in every 30 s | Ends the run |

**Milestone rewards:** defeating each Age's boss grants a **Boon** (choose 1 of 3 rare run-wide effects, e.g. "+1 projectile on all weapons") plus a gold bonus (+50 / +100 / +200). Age transitions play a banner and change music. Color shifts use a `CanvasModulate` tween.

**The Unraveling:** after 30:00, a ring centered on the player appears while the world outside frays into threads. The ring is a wall: players can't leave it. Every 30 s it closes in by a tenth of its starting size (a short, visible squeeze, with a countdown on screen), until it closes onto the players and the run ends, even in the debug god mode. The run ends through a visible, fair threat instead of inflated enemy HP. *(Changed 10/31/2026, owner decision: was a ring shrinking 10% a minute with rising damage outside it.)*

**Records:** the HUD timer shows the player's personal best for this Hero as a marker; passing it plays a short flourish.

**Swift Mode** \[Launch\]. A faster, higher-reward version of any level whose 30:00 boss you've beaten, unlocked per level and toggled on the level select screen.

| Change | Normal | Swift Mode |
| --- | --- | --- |
| Run arc | Bosses at 10 / 20 / 30 min | Bosses at 7 / 14 / 21 min; the Unraveling starts at 21:00 |
| Enemy move speed | ×1.0 | ×1.5 |
| Spawn rate | ×1.0 | ×1.5 |
| Player move and projectile speed | ×1.0 | ×1.25 |
| XP gain | ×1.0 | ×1.25 |
| Gold | ×1.0 | ×1.5 |

- Built from multipliers in `config.json` plus one timeline scale (`arc_time_scale: 0.7`) applied to the level's wave table, so no new content is needed. It doesn't speed up the engine's clock, which keeps physics and performance stable.
- Swift records, achievements, and personal bests are tracked separately.
- Stacks with Omens for players who want the hardest challenge.
- Co-op: the host chooses Swift Mode in the lobby.
- The quit rule uses the scaled time: quitting keeps 10% from 3:30 onward (5:00 × 0.7).

## Controls and smart targeting

Movement is the main input; weapons aim themselves at nearby threats so players can run and dodge freely, and two god buttons are the only other required actions. \[Launch\]

| Action | PC | Mobile | Gamepad |
| --- | --- | --- | --- |
| Move (8 directions) | WASD or arrow keys, or hold the left mouse button and drag (the same floating joystick as touch) *(mouse added 10/31/2026, owner request)* | Floating virtual joystick (left half of screen) | Left stick / D-pad |
| Summon god 1 | Q | Button 1, bottom-right | LB / L1 |
| Summon god 2 | E | Button 2, bottom-right | RB / R1 |
| Resonance | R, or Q+E together | Resonance button (appears only when ready) | LB+RB together |
| Manual aim (optional) | Hold mouse button and point | Optional right-side aim stick (setting) | Right stick |
| Open banked level-up | Tab | Tap the level badge | Y / Triangle |
| Pause | Esc | Pause icon, top-right | Start |

**Targeting by weapon type** (each weapon's data names its type)

| Type | Behavior | Examples |
| --- | --- | --- |
| `targeted` | Fires at the nearest enemy in range; prefers an elite or boss if it's within 1.5× the nearest enemy's distance. | Gáe Bolg, spells, bows |
| `melee` | Strikes toward the nearest enemy within melee range; if none, the facing direction. | Heracles' club, Excalibur |
| `orbit` / `aura` | No aiming. | Orbiting shields, auras |
| `random` | Random point or enemy in range. | Lightning strikes |
| `directional` | Movement/facing direction, on purpose. | Cú Chulainn's Salmon Leap |
| `range_switch` | Melee when an enemy is within 2 tiles, otherwise ranged. | Tomoe Gozen's sword and bow |

- **Facing** (last movement direction) still drives directional attacks and sprite flipping.
- Retarget every 0.1 s using the spatial hash.
- **Manual aim (optional):** while held, `targeted`, `melee`, and `range_switch` weapons fire toward the aim point. Never required.
- Mobile: joystick appears only when touched; god buttons are large (≥ 72 px) with meters drawn as rings around the god's portrait; HUD respects safe-area margins.
- Godot Input Map actions: `move_up`, `move_down`, `move_left`, `move_right`, `summon_1`, `summon_2`, `resonance`, `aim`, `level_badge`, `pause`.

## Core mechanics \[v3.10, decided\]

The exact rules for damage, collisions, weapons, level-ups, bosses, summons, statuses, and pauses. All numbers live in `config.json` and can be tuned.

### Damage formula

Every hit is calculated in this order:

1. Start with the weapon's base damage (plus Hero expertise, if any).
2. Multiply by (1 + Might).
3. Critical hit: base 5% chance, ×2 damage (Crit stats and the Samurai raise both).
4. Multiply by ×1.5 if the target is weak to the element, or ×0.5 if it resists.
5. Subtract the target's Armor (Hex and Sundered reduce it).
6. Minimum 1 damage.

Damage over time (Burn, Poison) skips Armor. Damage to the player works the same way: enemy damage minus the player's Armor, minimum 1.

### Collisions and getting hit

- **Enemies never stack.** Every enemy has a body radius and pushes neighbors apart (resolved at 30 Hz through the spatial hash, checking up to 8 neighbors each). Crowds pack into a ring around the player instead of piling onto one spot. Bigger enemies and bosses push smaller ones aside.
- **Contact damage:** each enemy touching the player deals its damage once every 0.5 s (its own timer).
- **No invulnerability after being hit.** If enemies rush and surround you and you don't kill them or escape, you die. The danger of being swarmed is the point.
- **Enemies don't block movement.** You can walk through a crowd, but every enemy you touch deals its contact damage unless a shield stops it. *(Added 10/29/2026, owner approved.)*
- Dodges from Hero traits (Tomoe's charge, Cú Chulainn's leap) still work as designed.

### Weapon speeds and Hero expertise

- **Every weapon has its own rhythm** in its data: attack interval, how often it can hit the same enemy (for auras and orbits), projectile speed, and pierce. No two weapons share a feel.
- **Weapon categories:** Blade, Spear/Polearm, Bow, Blunt, Thrown, Spell. A weapon can belong to two (Tomoe's Sword and Bow is Blade and Bow).
- **Expertise:** each Hero has 1–2 categories they're expert in but **don't start with**. When they pick or find a weapon of that category, it gets +25% attack speed and +15% damage, and an extra projectile or pierce at level 8. Level-up cards show an "Expert" badge.

| Hero | Signature weapon (category) | Expertise |
| --- | --- | --- |
| Heracles | Great Club (Blunt) | Bow (his famous bow), Thrown |
| Cú Chulainn | Gáe Bolg (Spear) | Thrown (his sling feats), Blade |
| Väinämöinen | Runo Song (Spell) | All Spells |
| Tomoe Gozen | Sword and Bow (Blade, Bow) | Spear/Polearm (the naginata) |
| King Arthur | Excalibur (Blade) | Spear/Polearm (his spear in Welsh tradition) |
| Atalanta | Huntress's Bow (Bow) | Spear/Polearm (hunting spears), Thrown |
| Achilles | Spear and shield (Spear) | Blade, Thrown (javelins) |
| Scáthach | Spear (Spear) | Thrown, Blade |
| Odysseus | Great bow (Bow) | Blade, Thrown |

**Four general weapons added** so every category can be found in a run (launch weapons: 18):

| Weapon | Category | Type | Evolution (+ passive) |
| --- | --- | --- | --- |
| Javelin | Spear/Polearm | targeted, piercing | Rain of Javelins (+ Seer's Eye) |
| Longbow | Bow | targeted, long range | Volley (+ Hourglass) |
| Bronze Sword | Blade | melee arc | Hero's Blade (+ Belt of Strength) |
| War Hammer | Blunt | melee, knockback | Quake Hammer (+ Bronze Aegis) |

### Level-up choices

- Each level offers 3 cards (4 with high Luck). Cards can be **items** (new weapons or passives, or upgrades), **stats** (+Might, +Max HP, +Move Speed, +Area, −Cooldown, +Armor, +Luck, +Crit, +Pickup Radius), or **skills** (upgrades to the Hero's Legend Trait, e.g. Salmon Leap recharges 1 s faster). Every level offers something that helps.
- **No hard stat caps.** Stats keep growing every level. Stats that would break the game use soft curves instead: cooldown = base ÷ (1 + cooldown bonus), so it keeps improving but never reaches zero; Move Speed bonus beyond +100% and Area bonus beyond +150% count at half value.
- Cards slightly favor items already owned, and if a weapon can complete an evolution recipe, at least one card helps toward it.
- **When everything is maxed,** cards become Gold (+25, more in later Ages) and Heal (+30% HP).
- **Auto-collect setting:** Off / Gold / Heal / Smart (heal if below 50% HP, otherwise gold). When on, maxed level-ups resolve instantly with no pause. It can be changed in Settings, the pause menu, or on the level-up screen.

### Boss timing

Bosses always spawn on time. If the previous boss is still alive, both fight at once: the arena grows to hold both, fodder stays at 25%, and each boss drops its own rewards. No enrage timer and no pausing. The Unraveling begins at 33:00 or when the 30:00 boss falls, whichever comes first.

### God summons and your stats

Summons are enhanced by the player's stats: damage × (1 + Might), area × (1 + Area), and crits and status durations apply. Cooldown doesn't affect god meters (Votive Bell and god-level bonuses do). A god's Blessing may include a small drawback (e.g. Poseidon's −10% Move Speed), but every god is a net benefit.

### Status effects on the player

- **Before 30:00:** enemies and bosses never apply elemental statuses (Burn, Chill, Shock, Soaked, Poison, Hex) to players.
- **From 30:00 (the Unraveling):** they can, at reduced strength: half duration, Chill never becomes a full Freeze, and 2 s immunity after each status ends.
- **Not statuses:** boss signature mechanics (Medusa's petrifying gaze, Tsuchigumo's webs) and terrain (quicksand, the ford, frozen ponds) work at any time, because they're the fights' and levels' core ideas.

### Crowd control on elites and bosses

- **Elites:** each repeated Freeze, root, or stun within 10 s lasts half as long (100% → 50% → 25%), then they're immune for 5 s.
- **Bosses:** can only be slowed (Chill), and are stunned only by a Guard Break.

### Pauses and turns

- **Solo:** the run timer stops during level-ups, chest reveals, and the pause menu.
- **Co-op:** XP is shared, so everyone levels up at the same moment. The game fully pauses and the timer stops. Players choose **one at a time** in turn order, and the first picker rotates each level-up. Only the player whose turn it is can choose; everyone else sees "Waiting for \[name\]" and can't select anything. Each turn lasts up to 20 s, then picks automatically (following that player's Auto-collect setting when maxed).
- **Co-op chests:** the opener's chest reveal pauses the game for everyone (3 s at most).
- **Banked level-ups** are solo only; co-op uses turns.

## Heroes

Heroes are legendary figures from Tier A traditions in your database, and each plays differently through a **signature weapon** from their legend, an automatic **Legend Trait** based on a famous deed, a **passive**, a **Divine Link** to the god system, and a **patron pantheon**. No Hero adds buttons. Launch with 4 starting Heroes, 2 unlocked with gold or achievements, and 2 unlocked by defeating them as bosses (Achilles, Scáthach); the rest come post-launch.

**Base stats (all Heroes):** Max HP, Move Speed, Might (damage %), Area (%), Cooldown (%), Armor, Pickup Radius, Luck, Crit Chance.

| Hero | Tradition | HP | Speed | Armor | Role | Availability |
| --- | --- | --- | --- | --- | --- | --- |
| Heracles | Greek | 150 | 90 | 2 | Bruiser | \[Launch\] starting |
| Cú Chulainn | Irish | 110 | 105 | 1 | Mobile spear striker | \[Launch\] starting |
| Väinämöinen | Finnish (Kalevala) | 100 | 95 | 0 | Elemental song-mage | \[Launch\] starting |
| Tomoe Gozen | Japanese legend | 95 | 115 | 0 | Agile sword-and-bow skirmisher | \[Launch\] starting |
| King Arthur | Welsh/Arthurian | 130 | 95 | 2 | Holy defender | \[Launch\] unlock: 1,000 gold |
| Atalanta | Greek | 90 | 125 | 0 | Swift archer | \[Launch\] unlock: survive 20:00 with any Hero |

### Heracles (Greek)

- **Great Club** (`melee`, Physical): heavy ground-slam arc toward the nearest enemy; every 4th slam sends out a small quake.
- **Legend Trait: Twelve Labors.** During a run, Labors appear one at a time as small HUD goals (e.g. "Slay an elite within 20 s," "Defeat 150 beasts," "Hold a Ruins circle without taking damage"). Each completed Labor grants a permanent run bonus; up to 12. Gives every Heracles run its own mini-objectives.
- **Passive: Lion's Hide** (the Nemean lion's pelt): +2 Armor; the first hit every 8 s is halved.
- **Divine Link:** each summon empowers his next 3 slams into full shockwaves.
- **Patron:** Greek.

### Cú Chulainn (Irish)

- **Gáe Bolg** (`targeted`, Physical): piercing spear thrust along a line; enemies killed burst into barbs that hit those nearby.
- **How weapons attack follows what they are** (owner rule, 10/31/2026): spears jab and javelins are thrown and fly to enemies (owner decision, 10/31/2026: spears were thrown for a short while, then put back to jabbing); bows stay in the Hero's hand and shoot arrows; swords and clubs are swung from the Hero's hand; hammers come down from overhead and smash the ground in front of the Hero, hitting everything around the spot with a shockwave; axes and discs are thrown and spin. Every attack starts from the Hero.
- **Legend Trait: Salmon Leap** (his famous hero-feat). Every 8 s he automatically leaps 3 tiles in his movement direction (straight up if standing still), untargetable for 0.8 s, landing with a shockwave (radius 2 tiles, knockback). A shadow shows where he'll land.
- **Passive: Battle Frenzy** (his warp-spasm): below 30% HP, +30% attack speed and +15% Area.
- **Divine Link:** landing shockwaves apply the element of each bound god.
- **Patron:** Celtic.

### Väinämöinen (Finnish, Kalevala)

- **Runo Song** (`targeted`, cycles Fire → Ice → Lightning): the old singer's magic songs, cast as bolts; each cast uses the next element.
- **Legend Trait: Song of Power.** Every elemental reaction he causes adds a Verse stack (+3% spell damage, max 10, each lasts 6 s). Mixing elements is how he scales.
- **Passive: Eternal Sage:** statuses he applies last 30% longer. Trade-off: low HP.
- **Divine Link:** bound gods' elements join his song cycle; his reactions deal +25% damage.
- **Patron:** Finnish. No Finnish god at launch, so instead he gets +8% meter charge with every god.

### Tomoe Gozen (Japanese legend)

- **Sword and Bow** (`range_switch`, Physical): sword slashes when enemies are within 2 tiles, arrows when they're farther. Reflects her legendary skill with both.
- **Legend Trait: Cavalry Charge.** Moving continuously builds Momentum every 0.5 s (max 10): +4% attack speed and +2% Move Speed per stack. Standing still 1 s loses half. At 10 stacks, every 5 s she charges: 1.5 s of trampling enemies she passes through and dodging the next hit.
- **Passive:** +10% Crit Chance.
- **Divine Link:** at full Momentum, god meters fill 25% faster.
- **Patron:** Japanese. Shinto gods are Tier B, so at launch she gets +8% meter charge with every god.

### King Arthur (Welsh/Arthurian)

- **Excalibur** (`melee`, Physical): wide arcs toward the nearest enemy; every 3rd swing deals Holy damage.
- **Legend Trait: Shield Wall.** Stand still for 0.4 s and he raises his shield toward the nearest threat: blocks projectiles in a 120° arc and halves contact damage. Moving drops it.
- **Passive: The Scabbard** (in legend, its wearer lost no blood): immune to damage-over-time; regenerates 1% HP per second while his shield is raised.
- **Divine Link:** each summon grants a shield worth 20% Max HP for 5 s.
- **Patron:** Celtic.

### Atalanta (Greek)

- **Huntress's Bow** (`targeted`, Physical): long-range piercing arrows.
- **Legend Trait: The Race** (she would marry only the man who outran her). Every 25 s a golden marker appears 1.5 screens away; reaching it within 6 s grants an XP burst and +30% Move Speed for 8 s. A golden apple sometimes rolls off to the side: grabbing it doubles the reward but costs time, a nod to how she lost her famous race.
- **Passive:** +15% Move Speed; +1 pierce on bows.
- **Divine Link:** while hasted from The Race, summons charge 30% faster.
- **Patron:** Greek.

### Post-launch Heroes \[Post-launch, Tier A\]

| Hero | Tradition | Signature weapon | Legend Trait idea |
| --- | --- | --- | --- |
| Perseus | Greek | Harpe sword + mirrored shield | Shield reflects projectiles; rare petrifying gaze burst |
| Odysseus | Greek | Great bow | Cunning: standing still lays traps; disguises draw enemies away |
| Orpheus | Greek | Lyre | Song charms nearby enemies to fight each other briefly; buffs allies |
| Achilles | Greek | Spear and shield | \[Launch: unlocked by defeating him on the Aegean Shore\] Nearly invulnerable from the front, vulnerable from behind (the heel) |
| Gilgamesh | Mesopotamian | Axe | Enkidu fights beside him as a companion |
| Beowulf | Norse/Germanic | Bare hands, giant sword | Grip combo: grabs and throws elites |
| Sigurd | Norse/Germanic | Gram | Dragonslayer: bonus damage to bosses |
| Brynhild | Norse/Germanic | Valkyrie spear | Chooses the fallen: revives allies faster in co-op |
| Völundr | Norse/Germanic | Smith's hammer | Forges turrets when standing still |
| Scáthach | Irish | Spear | \[Launch: unlocked by defeating her in the Misty Isles\] Trains: each weapon level-up also boosts another weapon |
| Fionn mac Cumhaill | Irish | Sword Mac an Luin | Thumb of Knowledge: reveals weaknesses instantly |
| Rostam | Persian epic | Heavy mace and bow | Rides with Rakhsh, a horse companion |
| Gordafarid | Persian epic | Sword and bow | Defender: stronger when protecting allies |
| Arash the Archer | Persian epic | Legendary bow | One enormous screen-crossing arrow |
| Hou Yi | Chinese legend | Great bow | \[Unlocked by defeating the Ten Suns\] Shoots down suns: bonus vs flyers and bosses |
| Hua Mulan | Chinese legend | Sword and bow | Disguise: enemies ignore her for a moment after each dodge (no Disney design) |
| Benkei | Japanese legend | Naginata | \[Unlocked by defeating him in the Land of Legends\] Stands his ground: grows stronger while surrounded |
| Minamoto no Yoshitsune | Japanese legend | Sword | Extreme agility: double-jump dodge |
| Jumong | Korean legend | Bow | Peerless archery: every 5th arrow never misses |

Tier B Heroes from your database (Sun Wukong, Nezha, Erlang Shen, Guan Yu, the Popol Vuh Twins, Lam-ang, Sundiata, and others) wait for cultural review. Tier C Heroes are not used (see Cultural care and IP).

Adding a Hero must only require an entry in `data/heroes.json`, a trait script in `scripts/player/hero_traits/`, and art.

## Elements, statuses, and reactions

Eight elements plus Physical, each with exactly one status effect, a few simple reactions, and enemies with at most one weakness and one resistance, so the system stays readable in fast combat. \[Launch, unchanged from v2\]

**Elements and statuses**

| Element | Color | Status | Effect |
| --- | --- | --- | --- |
| Fire | Orange-red | **Burn** | 3 s damage over time |
| Ice | Pale blue | **Chill → Freeze** | −30% speed per stack; 3 stacks = Frozen 1.5 s (bosses: Chill only) |
| Lightning | Yellow | **Shock** | Next hit taken deals +20% |
| Water | Deep blue | **Soaked** | 4 s; sets up reactions |
| Earth | Green-brown | **Poison** | Stacking damage over time (max 5 stacks) |
| Wind | Pale green | **Gust** | Knockback; spreads statuses |
| Holy | Gold-white | **Smite** | Breaks enemy shields; bonus vs Dark/undead |
| Dark | Violet | **Hex** | −40% enemy Armor and −20% enemy damage for 4 s |
| Physical | White | none | Unaffected by elemental resistances |

**Weakness and resistance**

- Weak: ×1.5 damage, shown as larger yellow damage numbers with "!".
- Resist: ×0.5 damage, shown as small gray numbers. Normal enemies are never fully immune.
- Each enemy has 0–1 weakness and 0–1 resistance; enemy color matches its element.
- Elites and bosses show weakness/resistance icons on their health bar (icons, not only color).
- **Armor:** flat damage reduction per hit on brutes, elites, and bosses. Hex and Thermal Shock reduce it.

**Reactions** \[Launch: 4\]

| Reaction | Trigger | Effect |
| --- | --- | --- |
| **Conduct** | Lightning hits a Soaked enemy | Lightning chains to every Soaked enemy within 4 tiles |
| **Steam Burst** | Fire hits a Frozen or Chilled enemy | Removes Freeze; small steam explosion |
| **Shatter** | Physical hit on a Frozen enemy | +100% damage; Freeze ends |
| **Spread** | Wind hits an enemy with Burn, Poison, or Soaked | Copies that status to up to 4 nearby enemies |

**Counterplay:** Fire on a Soaked enemy only removes Soaked; Ice on a Burning enemy removes Burn. \[Post-launch: Toxic Flare (Fire + Poison), Eclipse (Holy + Dark).\]

**Spell tier names** \[Launch\]

Elemental spell weapons rename as they level: levels 1–3 = Tier I, 4–6 = Tier II, 7–8 = Tier III, evolution = Tier IV. Plain escalating words; nothing borrowed from any game's spell naming.

| Element | Tier I | Tier II | Tier III | Tier IV (evolution) |
| --- | --- | --- | --- | --- |
| Fire | Ember | Flame | Blaze | Inferno |
| Ice | Frost | Ice Lance | Glacier | Absolute Zero |
| Lightning | Spark | Bolt | Thunder | Tempest |
| Water | Splash | Torrent | Riptide | Deluge |
| Earth | Stone | Quake | Landslide | Worldbreaker |
| Wind | Breeze | Gust | Gale | Cyclone |
| Holy | Glimmer | Radiance | Sanctify | Judgment |
| Dark | Shade | Umbra | Eclipse | Oblivion |

The level-up card shows the tier change ("Flame → **Blaze**") with a distinct sound.

## Weapons, passives, evolutions, and divine infusions

Heroes hold up to **6 weapons and 6 passives** per run; weapons level 1–8, then change along two clear axes: a matching **passive** decides the weapon's evolved *form*, and a bound **god** decides its *element* (divine infusion). Both can apply to the same weapon.

**Weapons** \[Launch: 18, including Javelin, Longbow, Bronze Sword, and War Hammer from Core mechanics\]

- Each Hero starts with their signature weapon. Any Hero can pick up any general weapon from level-up cards; signature weapons can be picked by other Heroes once unlocked.
- Weapon data: id, name, element, targeting type, fire pattern (forward, spread, orbit, aura, random strike, bounce, pierce, boomerang, arc), stats per level 1–8, tier names (spells), evolution pairing, infusion hooks (on-hit, on-kill, projectile, area).
- Fire patterns are reusable scripts; a new weapon is mostly a data entry.

| Weapon | Element | Type | Source |
| --- | --- | --- | --- |
| Great Club, Gáe Bolg, Runo Song, Sword and Bow, Excalibur, Huntress's Bow | (see Heroes) | (see Heroes) | Signature |
| Ember (Fire spell) | Fire | targeted | Starting pool |
| Frost (Ice spell) | Ice | targeted, spread | Starting pool |
| Spark (Lightning spell) | Lightning | random strike | Starting pool |
| Throwing Axe | Physical | arc, high damage | Starting pool |
| Breeze (Wind spell) | Wind | forward wave, knockback | Unlock: 300 gold |
| Glimmer (Holy spell) | Holy | orbit | Unlock: 400 gold |
| Shade (Dark spell) | Dark | aura, drains HP | Unlock: 500 gold |
| Bladed Discus | Physical | boomerang | Unlock: achievement |

**Passives** \[Launch: 9, levels 1–5\], named for mythic objects in general terms: Belt of Strength (+Might), Winged Sandals (+Move Speed), Hourglass (−Cooldown), Seer's Eye (+Area), Lodestone (+Pickup Radius), Bronze Aegis (+Armor), Ferryman's Coin (+Luck), Golden Apple (+Max HP), Votive Bell (+god meter charge).

### 1. Standard evolutions \[Launch\]

Weapon at level 8 + its paired passive owned → the next chest (from elites, bosses, or treasure POIs) evolves it.

| Weapon | + Passive | Evolves into |
| --- | --- | --- |
| Great Club | Bronze Aegis | Labor-Breaker: every slam quakes |
| Gáe Bolg | Winged Sandals | Thirty Barbs: the spear bursts into a spray of barbs |
| Runo Song | Seer's Eye | Song of Creation: casts all three elements at once |
| Sword and Bow | Hourglass | Thousand-Arrow Ride: arrows fire during every charge |
| Excalibur | Golden Apple | Light of Avalon: arcs heal on hit |
| Huntress's Bow | Ferryman's Coin | Calydonian Hunt: arrows split on kill |
| Ember | Belt of Strength | Inferno |
| Frost | Hourglass | Absolute Zero |
| Spark | Ferryman's Coin | Tempest |
| Breeze | Winged Sandals | Cyclone |
| Glimmer | Golden Apple | Judgment |
| Shade | Lodestone | Oblivion |
| Throwing Axe | Seer's Eye | Cleaver Storm |
| Bladed Discus | Votive Bell | Sun Disc |

**Signature bonus:** when a Hero uses their own signature evolution, it gets one extra effect (e.g. Thirty Barbs used by Cú Chulainn also fires on each Salmon Leap landing).

### 2. Divine infusions \[Launch\]

Weapon at level 8 (evolved or not) + a bound god of a different element → the next chest offers to **infuse** it with that god's element. With two eligible gods, the player chooses. One infusion per weapon. If the weapon already has the god's element, it becomes **Empowered** instead (+50% status chance and duration).

Infusions use **8 templates (Ra's and the Morrígan's are described in Gods)** applied by rule, not hand-made weapons:

| God | Infusion | Effect added | Name prefix |
| --- | --- | --- | --- |
| Sekhmet | Fire | Hits Burn; kills cause a small explosion | Sunfire |
| Skadi | Ice | Hits Chill; kills split into 3 ice shards | Winter |
| Thor | Lightning | Hits Shock; 20% chance to chain to 2 enemies | Thunder |
| Cernunnos | Earth | Hits Poison; kills leave a thorn patch (budgeted) | Greenwood |
| Poseidon | Water | Hits Soak; +knockback splash | Tidal |
| Tyche | Fortune | Kills have 10% chance to drop gold; +crit damage | Fortune's |

Names build automatically (prefix + weapon name), with optional overrides for signature weapons. Examples: Gáe Bolg + Thor = **Thunder Gáe Bolg** (lightning chains along the thrust); Excalibur + Sekhmet = **Sunfire Excalibur**; Thirty Barbs + Skadi = **Winter Barbs**.

### 3. Union evolutions \[Post-launch\]

Two specific max-level weapons merge into one, freeing a slot (e.g. Ember + Breeze = Firestorm). Add 2–4 once the base set is balanced.

### Clarity and balance

- Chests show the recipe that triggered: weapon icon + passive icon (+ god icon) = result. The pause menu's **Codex** lists discovered recipes; undiscovered ones show as silhouettes with a hint.
- Launch content math: 14 weapons × 1 evolution + 8 infusion templates = 22 designed pieces producing \~100 combinations.
- Per-level damage budgets live in `config.json`; evolutions are \~2× level 8; infusions add utility worth \~15–25%, not raw multipliers.
- Hand-tune only signature weapons' infusions. Use the debug menu to compare any combo against a fixed test wave.

## Gods (summons)

Gods from Tier A pantheons are the heart of the game: each has a personality drawn from their myths, a combat role, a passive Blessing, its own charge condition, and a summon fired with its own button. A Hero binds up to **2 gods** per run; gods are lost at the end of the run, but each god's permanent level (raised with gold offerings) carries over. \[Launch: 8 gods, 2 from each launch region\]

**The six launch gods**

| God | Pantheon | Element | Personality (from myth) and look | Role | Rarity | Shrine |
| --- | --- | --- | --- | --- | --- | --- |
| Tyche | Greek | Fortune | Capricious, playful goddess of luck; turning wheel and cornucopia | Economy / luck | Common | Peaceful |
| Cernunnos | Celtic | Earth | Ancient, silent antlered lord of beasts and forests | Sustain / zones | Common | Peaceful |
| Thor | Norse | Lightning | Boisterous, fearless protector who loves a fight; hammer that returns to his hand | Chain damage | Uncommon | Trial: Duel |
| Skadi | Norse | Ice | Proud, solitary huntress of winter mountains, on skis with a bow | Control / defense | Uncommon | Trial: Chase |
| Sekhmet | Egyptian | Fire | Fierce lioness of war and healing whose rage once nearly consumed the world | Damage | Uncommon | Trial: Endurance |
| Poseidon | Greek | Water | Stormy, proud lord of seas and earthquakes with a trident | Area / horde clear | Rare | Trial: Duel |

Design each god's look from myth descriptions and museum-era art traditions, never from Marvel, God of War, Hades, Smite, or similar (see Cultural care and IP). Cernunnos is known mainly from a few ancient images, so keep his lore light and avoid inventing "facts."

**Blessing, trigger, and summon** (level 1 values; scaled by permanent level)

| God | Blessing (passive while bound) | Meter fills by | Summon |
| --- | --- | --- | --- |
| Tyche | +30% gold, +Luck; −10% Max HP (trade-off) | Pick up 150 gold or XP orbs | **Wheel of Fortune:** pulls every pickup on screen; kills in the next 5 s drop double |
| Cernunnos | Regenerate 1% HP/s; melee hits Poison | Take 100 damage | **Heart of the Greenwood:** heal to full, invulnerable 5 s, roots bind nearby enemies while spectral stags charge through them |
| Thor | +15% Lightning damage; every 10th projectile chains lightning | 150 attacks made | **Hammer's Return:** a thrown hammer arcs across the screen and returns, calling lightning on everything it passes |
| Skadi | +20% Max HP; enemies that touch you are Chilled | Every 45 s | **Winter's Hunt:** freezes all non-boss enemies 4 s while ice arrows rain down; bosses Chilled |
| Sekhmet | +15% Might; Fire weapons always Burn | 300 enemies hit | **Breath of the Desert:** scorching wind sweeps the screen, Burning everything for 4 s |
| Poseidon | +25% Area; −10% Move Speed (trade-off); hits Soak | 500 kills | **Earthshaker:** a tidal wave crosses the screen, then the ground quakes, Soaking and stunning |

Each god is also a **divine infusion** source (see Weapons) and has a **Divine Link** with each Hero (see Heroes).

### Finding gods

- A **shrine** appears every \~3 minutes (tunable), 1.5–2 screens from the player, with an edge-of-screen arrow. Its look matches the god's pantheon. It vanishes after 90 s if ignored.
- Which god: random by rarity, never one already bound this run. Rare gods can't appear before 8:00.
- **Hidden shrines** also appear as world POIs (see World) and favor uncommon/rare gods.
- When found, the god speaks one short line written for our game (e.g. Thor: "Show me your strength, little hero.").
- **Shrine dungeons** *(owner decisions, 10/31/2026)*: the shrine in the world is an entrance built from its people's architecture. Standing in its doorway takes the party inside (in co-op every standing player must be at the doorway together, or it can't start). While the party is inside, **the run outside pauses**: the clock, enemies, spawns, hazards and bosses all stop. The dungeon is built at random (sometimes a twisting maze, sometimes wide halls with loops, different sizes). **Monsters of the level spawn in its corridors** (no elites or bosses), and walls stop them too, **until someone reaches the god's throne room**: then the rest are banished and none come in with the god. Nothing spawns outside meanwhile; the enemies outside wait where they were. *(Changed 10/31/2026, owner decision: was no monsters inside at all.)* At its far end is the god's throne room, where the god sits on their throne or walks about inside it. Standing at the altar binds a peaceful god; a trial god's trial then starts outside at the shrine. Either way the party is **warped back out** to where they went in; walking back out of the entrance also leaves.
- **Ruins dungeons** *(owner decision, 10/31/2026)*: the Ancient Ruins work the same way as shrine dungeons (gather at the stairway, the run outside pauses, a random maze, the level's monsters in its corridors, walls stop everyone, no monsters in the end room), but they're built from their own set of parts (an old, crumbling underground ruin rather than a temple) and the end room is a treasure vault. Touching the chest on its dais warps the party out and offers the Ruins' gift.

### Shrine types

- **Peaceful:** stand at the shrine for 2 s to bind.
- **Trial: Duel.** A glowing ring (radius \~1 screen) forms; the god fights as a mini-boss with 2 attack patterns, scaled to the current time. Regular spawns drop to 30%. Leave the ring or exceed 60 s = fail; the shrine vanishes.
- **Trial: Endurance.** Survive 40 s inside the ring while the god unleashes hazards; the god can't be damaged. (Sekhmet's rage must be weathered, as in her myth.)
- **Trial: Chase.** The god flees around the area; touch them 3 times within 40 s while they leave decoys. (Skadi the huntress becomes the hunted.)
- Trials reuse boss pattern scripts at smaller scale.

### Binding and summoning

- Two god slots. Binding a third asks which to release (or decline).
- Each god has its **own button and meter** (a ring around its portrait). Players choose which to fire and when; holding a full meter is allowed.
- Summons last 2–6 s and use pooled effects within the effect budgets.
- **Auto-summon** setting (accessibility): fires a god when its meter is full and ≥ 30 enemies are on screen or a boss is present.

### Offerings: permanent god levels \[Launch\]

In the Hall of Legends, gold offered to any god bound at least once raises its level from 1 to 10. The level applies whenever that god is found again. Levels alternate small stat gains with **new options**:

| Level | Gold | Unlocks |
| --- | --- | --- |
| 2 | 75 | Blessing +10% |
| 3 | 150 | Meter fills 10% faster |
| 4 | 250 | Blessing +10% |
| 5 | 400 | **Summon upgrade:** a new effect (e.g. Winter's Hunt ends by shattering frozen enemies) |
| 6 | 550 | Blessing +10% |
| 7 | 750 | **Resonance Harmony** with this god is 50% stronger |
| 8 | 1,000 | Blessing +10% |
| 9 | 1,300 | Meter fills 10% more |
| 10 | 1,600 | **Ascended form:** alternate summon visual + one bonus effect; golden aura cosmetic |

Total per god: 6,075 gold. Tune against \~300–600 gold per run.

**Post-launch gods** (Tier A): Sol (Holy), Anubis or Hel (Dark), Odin, Athena, Zeus, Hephaestus, Brigid, Perun, Ishtar/Inanna, Thoth, Freyja. Wind gap: Stribog (Slavic) or Shu (Egyptian).

### Two more launch gods \[new in v3.1\]

With one level per region, each launch pantheon needs two local gods, so Ra and the Morrígan join the launch roster (8 gods total). They also fill the Holy and Dark gaps.

| God | Pantheon | Element | Personality and look | Role | Rarity | Shrine |
| --- | --- | --- | --- | --- | --- | --- |
| Ra | Egyptian | Holy | Radiant, regal sun-king; falcon head crowned with the sun disc | Holy damage / shield breaking | Uncommon | Peaceful (the sun shines on all) |
| The Morrígan | Celtic | Dark | Fateful battle-goddess who appears as a crow and foretells who will fall | Execution / crits | Rare | Trial: Chase (she shifts into crows and scatters) |

| God | Blessing | Meter fills by | Summon |
| --- | --- | --- | --- |
| Ra | +15% Holy damage; Holy hits break enemy shields instantly | Every 40 s (the sun's daily journey) | **Sun Barque:** a blazing sun crosses the screen, dealing Holy damage and Smiting everything it passes |
| The Morrígan | +10% Crit Chance; kills on Hexed enemies heal 1 HP | Every 60 s; twice as fast below 50% HP | **Crow Storm:** crows harry every enemy, applying Hex, and mark the 5 strongest as fated (+100% damage taken for 6 s) |

Both are infusion sources: Ra adds Holy ("Solar" prefix: hits Smite, kills flash light), the Morrígan adds Dark ("Raven" prefix: hits Hex, kills release a crow that seeks another enemy).

**New launch Resonance: Eye of Ra** (Ra + Sekhmet). In Egyptian myth, Sekhmet was sent as the Eye of Ra. Harmony: Holy and Fire hits each apply the other's status. Resonance: a sun-lioness charges across the screen, Burning and Smiting everything, and every boss Guard gauge gains 50%. Best against: bosses and shielded elites. This brings launch Resonances to 5.

### Gods added with Acts II–III

Each new level brings its local gods, for 21 gods by Act III. Full Blessing/trigger/summon numbers are designed when each Act is built; these are the identities and hooks.

| God | Pantheon | Act / level | Element | Role | Shrine | Summon idea |
| --- | --- | --- | --- | --- | --- | --- |
| Hecate | Greek | II / Underworld | Dark | Control | Peaceful | **Three Ways:** opens three crossroads portals that fling enemies away |
| Persephone | Greek | II / Underworld | Earth | Sustain | Trial: Endurance | **Return of Spring:** heals and blooms flowers that root enemies |
| Odin | Norse | II / Jotunheim | Wind | Crits / foresight | **Sacrifice:** bind by giving up 30% Max HP (echoing his self-sacrifice for wisdom) | **Gungnir:** a spear that never misses strikes the strongest enemies; ravens reveal weaknesses |
| Freyja | Norse | II / Jotunheim | Holy | Survival | Trial: Chase | **Falcon Cloak:** invulnerable flight across the screen; fallen enemies briefly rise to fight for you |
| Rhiannon | Welsh | II / Avalon's Shadow | Wind | Speed | Trial: Chase (her horse can't be caught by running, only by asking: stand still to bind) | **Birds of Rhiannon:** their song puts every enemy to sleep for 3 s |
| Arawn | Welsh | II / Avalon's Shadow | Dark | Summoner | Trial: Duel | **Hounds of Annwn:** white, red-eared hounds hunt down enemies |
| Enki | Mesopotamian | II / Rivers | Water | Healing / control | Peaceful | **Waters of the Abzu:** freshwater flood heals players and Soaks enemies |
| Shamash | Mesopotamian | II / Rivers | Holy | Justice / anti-boss | Peaceful | **Thirteen Winds:** winds pin every enemy in place (as he helped Gilgamesh against Humbaba) |
| Ukko\* | Finnish | III / Pohjola | Lightning | Burst | Trial: Duel | **Thunder Axe:** storms of strikes centered on the densest groups |
| Ilmatar\* | Finnish | III / Pohjola | Wind | Defense | Peaceful | **World Egg:** a protective shell that blocks all projectiles for 4 s |
| Simurgh\*\* | Persian | III / Mazandaran | Holy | Healing | Special: no shrine; collect 3 feathers dropped by elites, then burn one to call her (as in the Shahnameh) | **Healing Wings:** full heal and a wind that clears projectiles |
| Perun | Slavic | III / Slavic Wilds | Lightning | Anti-boss | Trial: Duel | **Thunder Against the Serpent:** huge strike on the strongest enemy; double damage to dragons and serpents |
| Mokosh | Slavic | III / Slavic Wilds | Earth | Fate / luck | Peaceful | **Spindle of Fate:** threads bind enemies; Luck doubled for 10 s |

\* Not in your reference database: verify before use. \*\* Mythic bird, not a deity.

**More Resonances** come with each Act, preferring pairs with a mythic link (e.g. Perun + Mokosh, Odin + Freyja, Shamash + Enki) or a strong elemental combo (e.g. Ukko + Poseidon).

## Divine Resonance and Patronage

Two compatible gods create a **Divine Resonance**: an always-on Harmony bonus plus a combined summon when both meters are full, often pairing gods from different pantheons, which is the Crossroads fantasy in one mechanic. **Patronage** separately rewards matching a Hero with gods of their own culture. \[Launch: 5 Resonances including Eye of Ra (see Gods), Patronage\]

**How Resonance activates**

1. Bind a compatible pair. A "Resonance discovered" banner names it the first time (logged in the Compendium).
2. **Harmony** applies immediately while both are bound.
3. When **both meters are full**, the two god buttons pulse together and a **Resonance button** appears between them (mobile), or R / Q+E (PC) / LB+RB (gamepad).
4. Firing Resonance consumes both meters. Firing either god alone still works, so the player chooses: two summons now, or one Resonance.
5. Incompatible pairs simply have no Resonance.

On mobile this adds no permanent button: the Resonance button exists only while usable.

**Launch Resonances** (each solves a different problem)

| Pair | Resonance | Harmony (always on) | Resonance summon | Best against |
| --- | --- | --- | --- | --- |
| Sekhmet + Skadi | **Sun and Snow** | Fire hits on Chilled enemies trigger mini Steam Bursts | Alternating desert-heat and blizzard waves; every enemy hit by both explodes and is Sundered (−50% Armor, 8 s) | Armored elites and bosses |
| Poseidon + Thor | **Storm Over the Sea** | Lightning chains to +1 target | A screen-wide surge Soaks everything for 6 s while lightning repeatedly chains through all Soaked enemies | Huge hordes |
| Cernunnos + Sekhmet | **Burning Greenwood** | Burning enemies leave short fire patches on death (budgeted) | Wild blooms spread across the area for 10 s; enemies crossing them Burn and are Poisoned | Area denial, kiting |
| Skadi + Poseidon | **Frozen Deluge** | Chill lasts 50% longer | A wave freezes everything in its path for 6 s; frozen enemies take Shatter bonus from any physical hit | Escaping, emergencies |

**Rules**

- Each Resonance is a scripted summon built from existing effects (waves, strikes, hazards, statuses) within effect budgets.
- A Resonance must change *what the player does* (stand and fight, kite, escape, burst a boss), not just multiply damage.
- Strength scales with the **lower** of the two gods' levels.
- Väinämöinen bonus: his reactions inside an active Resonance count double for Verse stacks.

**Patronage** \[Launch\]

- Every Hero has a patron pantheon (see Heroes). Gods from that pantheon charge **15% faster** for that Hero, and the summon plays a short extra line acknowledging them (e.g. Thor to a Norse Hero).
- Heroes whose pantheon has no launch god (Väinämöinen, Tomoe Gozen) get +8% charge with every god instead, so no Hero is disadvantaged.
- Patronage is a nudge, not a rule: cross-pantheon builds are often stronger because of Resonance, which creates a real choice.

&#91;Post-launch Resonances: Tyche + Cernunnos "Bountiful Harvest" (kills drop healing and gold), Thor + Sekhmet "Burning Storm", Tyche + Thor "Lucky Strike", Cernunnos + Poseidon "Overgrowth".\]

&#91;Post-launch: **Pantheon Kinship**: two gods of the same pantheon give a small extra Harmony (e.g. two Norse gods: +10% Might).\]

## Enemies, elites, and difficulty

The Unwoven are creatures and restless dead drawn from Tier A myths; most still walk straight at the nearest player, but difficulty rises through new families, behaviors, elite modifiers, and events rather than ever-larger HP pools. Gods are never used as regular enemies. \[Launch\]

**Movement types**

- **Chaser** (most enemies): moves toward the nearest player with light separation.
- **Swarm:** fast, low HP, packs of 10–30.
- **Brute:** slow, high HP, Armor, knockback resistant.
- **Flyer:** ignores players and crosses the screen in a sine-wave line in groups.
- **Caster:** stops at range and fires a slow, telegraphed projectile (0.5 s glow). Rare.
- **Encircler:** spawns as a ring around the player and closes in. Deep Night only.
- **Bomber:** runs at the player and explodes after a 1 s flashing fuse.

**Enemy families** (color = element)

| Family | Myth source | Element | Weak | Resists | Ages | Types |
| --- | --- | --- | --- | --- | --- | --- |
| Shades | Greek restless dead | Dark | Holy | Dark | All | Swarm, flyer |
| Draugr | Norse walking dead | Dark | Holy | — | Dusk, Night | Chaser, brute |
| Muspel Sparks | Norse fire realm | Fire | Water | Fire | Dusk, Deep Night | Chaser, bomber |
| Kelpies and Fomorian casters | Celtic water spirits; Irish sea-giants | Water | Lightning | Fire | Night | Chaser, caster |
| Frost Thursar | Norse frost-giant kin | Ice | Fire | Ice | Night, Deep Night | Chaser, caster |
| Shabti Guardians | Egyptian funerary figures, animated | Earth | Wind | Physical | Night, Deep Night | Brute (Armor) |
| Harpies | Greek storm-winged spirits | Wind | Lightning | Earth | All | Flyer, swarm |
| Spartoi | Greek "Sown Men" sprung from dragon's teeth (Apollodorus 3.4.1; Argonautica 3) | Earth | Wind | — | Night, Deep Night | Brute |
| Khalkotauroi (bronze bulls) | Aeëtes' fire-breathing bulls (Argonautica 3) | Fire | Water | Fire | Deep Night | Bomber |

*(Spartoi and Khalkotauroi added 10/29/2026, owner approved: they give the Aegean Shore its own brutes and bombers instead of borrowing Draugr and Muspel Sparks. Lore still to be checked.)*

A pure Fire build melts Draugr and Thursar but struggles against Muspel Sparks and Kelpies, so builds have to adapt.

Enemy data: id, family, tradition, sprite, HP, speed, contact damage, Armor, element, weakness, resistance, movement type, XP value, gold chance, knockback resistance, Ages.

**Spawning**

- Spawn in a ring just outside each player's visible screen.
- Enemies farther than 2 screens from every player are moved to the spawn ring ahead (not deleted).
- Hard cap on live enemies (500, tunable per platform).

**Elites** \[Launch\]

Elites appear at 5:00, 15:00, 25:00 and randomly afterward, as larger mythic creatures (Minotaur, Cyclops, Gorgon-kin, Troll) with 1 modifier (2 in Deep Night), shown as an icon over the health bar. Each drops a chest.

| Modifier | Effect | Counter |
| --- | --- | --- |
| Hasted | +50% speed | Ice (Chill), Frozen Deluge |
| Armored | High Armor | Dark (Hex), Sun and Snow, Earth |
| Splitting | Splits into 3 smaller copies on death (Hydra-style) | Area weapons |
| Warded | Shield blocks the first 30% HP | Holy breaks it instantly |
| Elemental Aura | Damages nearby players with its element | Keep distance |
| Summoner | Spawns minions every 5 s | Burst it down |

**Difficulty growth** (data in `waves.json`)

- Each minute changes **composition** (new families and types) and **density** (spawns per second).
- HP grows gently: about ×1.0 at 0:00 to ×3.0 at 30:00, never faster.
- New threats per Age, more elite modifiers, more frequent world events.
- After 30:00, the Unraveling ends the run. No further HP inflation.
- **Readability caps:** max 20 regular-enemy projectiles; all regular-enemy attacks telegraph ≥ 0.5 s.
- **Co-op scaling:** +60% enemy HP and +50% spawns per extra player.

## Bosses

Each regional level has three bosses at 10, 20, and 30 minutes, drawn from that region's myths: monsters, antagonist gods, and rival heroes (see the cultural rules on gods and heroes as bosses). Fights are short bullet-hell duels: multi-phase, telegraphed, elemental, and always dodgeable because the horde is cleared and held back. Elites fill the gaps. \[Launch: 12 bosses across 4 levels\]

**Fairness rules** (every boss and god trial)

- **Clean slate:** when a boss spawns, every regular enemy on screen bursts into XP orbs.
- **Arena:** a ring forms (radius \~1.2 screens). During the fight, only weak fodder spawns, at 25% rate, never casters or bombers.
- **Telegraphs:** every damaging attack shows a ground marker or wind-up for 0.6–1.5 s. Orange = area attack, red flash = about to fire.
- **Readable bullets:** enemy projectiles have a dark outline, draw above player effects, and leave gaps ≥ 1.5× the player's hurtbox.
- **Small hurtbox:** the player's projectile hurtbox is \~40% of the sprite; contact damage uses the full sprite.
- **Effect opacity** setting dims player effects (30–100%).

**Classic boss ideas, real-time**

- **Cast bars:** big attacks show their name and a cast bar ("Flames of Muspelheim — 2.0 s").
- **Guard gauge:** damage fills it; weakness hits fill it ×2. When full, **Guard Break**: boss stunned 4 s, takes +50% damage, current cast cancelled; then the gauge refills slower.
- **Weakness/resistance** icons on the boss health bar.
- **Phases** at HP thresholds with short transitions.

**Pattern library** (reusable, also used by god trials): radial burst, spiral, aimed fan, line sweep, ground circles, charge with trail, falling strikes with shadows, summon adds, safe-zone.

### Regional boss roster \[Act I: 12 bosses; about 40 across all four Acts\]

Each level's bosses escalate from a mythic monster (10:00), to a rival hero or trickster (20:00), to a great chaos figure (30:00). Every boss has one **signature mechanic** taken from its myth, built from the shared pattern library. Phases: 3 for every boss (thresholds roughly 100–60%, 60–25%, 25–0%).

**The Aegean Shore (Greek)**

| Time | Boss | Type | Element (weak / resist) | Signature mechanic | Phases |
| --- | --- | --- | --- | --- | --- |
| 10:00 | Medusa | Monster | Earth (Wind / Earth) | **Gaze:** she charges a stare with a visible cone; anyone moving *toward* her when it fires is petrified (rooted 1.5 s). Move away or sideways. | Serpent-hair volleys → gaze every 8 s → gaze + stone-statue obstacles that block projectiles |
| 20:00 | Achilles | Rival hero (duel) | Physical (Holy / Physical) | **The heel:** takes −80% damage from the front; hits from behind deal ×2. Circle him. | Spear rushes → shield-charge combos → rage: faster rushes, leaves dust trails |
| 30:00 | Kronos | Titan (antagonist god) | Dark (Holy / Dark) | **Devouring Time:** creates slow-time zones and, once per phase, rewinds his projectiles back along their paths. | Scythe sweeps → time zones → devours: pulls the player toward him while bullets spiral out |

Defeating Achilles unlocks him as a playable Hero.

**Midgard's Edge (Norse)**

| Time | Boss | Type | Element (weak / resist) | Signature mechanic | Phases |
| --- | --- | --- | --- | --- | --- |
| 10:00 | Fenrir | Monster (giant wolf) | Ice (Fire / Ice) | **Breaking the chains:** starts chained to a ring of posts; each phase he snaps chains and his reach grows. | Lunges within chain reach → bites and howls that summon wolves → free: full-arena charges |
| 20:00 | Loki | Trickster god | Fire (Water / Fire) | **Shapeshifting illusions:** splits into copies; only the real Loki casts a shadow. Fakes burst into fire when hit. | Fire-dagger fans → 3 illusions → swaps places with the player and fakes a shrine |
| 30:00 | Surtr | Fire giant | Fire (Water, Ice / Fire) | **Ragnarök:** the arena edge burns inward over the fight. | Flaming-sword slams → charges with fire trails and cast "Flames of Muspelheim" → burning-sword sweeps with safe gaps |

**The Two Lands (Egyptian)**

| Time | Boss | Type | Element (weak / resist) | Signature mechanic | Phases |
| --- | --- | --- | --- | --- | --- |
| 10:00 | Ammit | Monster (devourer) | Dark (Holy / Dark) | **The scales:** a giant scale appears; damage taken by the player tips it. If it tips fully, Ammit lunges with a huge devour attack. Avoiding hits keeps it balanced. | Charges → scale active → faster charges with sand bursts |
| 20:00 | Set | Storm rival (antagonist god) | Wind (Lightning / Wind) | **Desert storm:** sandstorm shrinks vision to a small circle while Set strikes from its edge. | Spear and storm-bolt patterns → sandstorm → red-desert cyclones that pull |
| 30:00 | Apep | Chaos serpent | Dark (Holy / Dark) | **Swallowing the light:** swallows one of the player's bound gods and turns its summon against them; hit the god's glowing orb inside Apep 10 times to free it. | Coils sweep the arena and dark-orb spirals → swallow → combined patterns; the Unraveling begins after |

**The Misty Isles (Celtic / Arthurian)**

| Time | Boss | Type | Element (weak / resist) | Signature mechanic | Phases |
| --- | --- | --- | --- | --- | --- |
| 10:00 | Scáthach | Rival hero (training duel) | Physical (Dark / Physical) | **The lesson:** she announces each technique by name before using it, and repeats it faster each time. Learn the pattern, beat the teacher. | Spear forms → leaping strikes → all forms in sequence |
| 20:00 | Ferdiad | Rival hero (duel at the ford) | Earth (Wind / Earth) | **The ford:** the fight happens across a shallow river strip that slows anyone standing in it; his horn-skin armor blocks frontal hits until you Guard Break him. Special lines if the player is Cú Chulainn, his foster-brother. | Sword and shield → stone-skin stance → desperate all-out assault |
| 30:00 | Balor of the Evil Eye | Fomorian giant | Fire (Water / Fire) | **The Eye:** when his eye opens, a sweeping death-beam crosses the arena; stand behind stone circles to break line of sight. Hitting the open eye fills his Guard gauge ×3 (as Lugh's sling-stone struck it in myth). | Fomorian minions and fire breath → the Eye → Eye opens twice as often |

Defeating Scáthach unlocks her as a playable Hero.

Mordred moves to Avalon's Shadow (Act II), where his special lines for King Arthur fit best.

**Acts II–IV bosses** (same 3-phase structure; one signature mechanic each from its myth)

| Level | Time | Boss | Type | Element (weak / resist) | Signature mechanic |
| --- | --- | --- | --- | --- | --- |
| The Underworld | 10:00 | Cerberus | Monster | Fire (Water / Fire) | Three heads act separately (fire, bite, howl); destroy heads one at a time |
| The Underworld | 20:00 | Thanatos | Antagonist (death personified) | Dark (Holy / Dark) | Marks a player for death with a countdown; hit him enough to cancel it (Heracles wrestled him in myth: special lines) |
| The Underworld | 30:00 | Typhon | Father of monsters | Wind (Lightning / Wind) | Hundred serpent heads fire volleys from all sides; storms rotate the arena |
| Jotunheim | 10:00 | Hrungnir | Stone giant | Earth (Lightning / Earth) | Stone heart and shield: armored until hit by Lightning |
| Jotunheim | 20:00 | Thrym | Frost giant king | Ice (Fire / Ice) | Steals a random weapon of the player's for 20 s (as he stole Thor's hammer); recover it from his hoard |
| Jotunheim | 30:00 | Ymir | Primordial frost giant | Ice (Fire / Ice) | Three frost shapes, only the real one casts a shadow; "Endless Winter" freezes the floor except safe circles |
| Avalon's Shadow | 10:00 | The Green Knight | Rival knight | Earth (Fire / Earth) | The beheading game: when "defeated" he picks up his head and returns stronger, once |
| Avalon's Shadow | 20:00 | Mordred | Rival knight | Dark (Holy / Dark) | Betrayer's host: −50% damage while his knights live; special lines for King Arthur |
| Avalon's Shadow | 30:00 | Twrch Trwyth | Monstrous boar (Welsh) | Earth (Wind / Earth) | Charges across the whole map with piglet packs; between his ears hang treasures that drop when hit |
| Land Between the Rivers | 10:00 | Humbaba | Forest guardian monster | Earth (Wind / Earth) | Seven radiances: 7 shield layers stripped one by one (Shamash's winds help: Wind damage ×2) |
| Land Between the Rivers | 20:00 | The Bull of Heaven | Monster | Lightning (Earth / Lightning) | Each stomp opens cracks that stay as hazards |
| Land Between the Rivers | 30:00 | Tiamat | Primordial chaos | Water (Lightning / Water) | Spawns her brood of monsters; flood waves; **original design** (not D&D's five-headed dragon) |
| Pohjola | 10:00 | The Elk of Hiisi | Monster | Wind (Fire / Wind) | Uncatchable sprints: must be slowed before it can be damaged |
| Pohjola | 20:00 | Iku-Turso | Sea monster | Water (Lightning / Water) | Rises from frozen lakes; ice breaks into open water hazards |
| Pohjola | 30:00 | Louhi | Sorceress-queen | Ice (Fire / Ice) | Becomes a giant eagle in phase 3 (as in the Kalevala); steals the sun (darkness phase) |
| Mazandaran | 10:00 | The Dragon of Rostam's Third Labor | Monster | Fire (Water / Fire) | Hides in darkness; only visible when your light (Simurgh or Holy) reveals it |
| Mazandaran | 20:00 | The Witch of the Fourth Labor | Sorceress | Dark (Holy / Dark) | Disguised as a harmless traveler among NPC-like decoys |
| Mazandaran | 30:00 | The White Div | Great demon | Ice (Fire / Ice) | Cave arena; ground cracks into pits; huge boulder throws |
| The Slavic Wilds | 10:00 | Zmey Gorynych | Three-headed dragon | Fire (Water / Fire) | Cut-off heads regrow unless finished with Fire or Holy |
| The Slavic Wilds | 20:00 | Baba Yaga | Witch | Dark (Holy / Dark) | Flies in her mortar; her hut on chicken legs stomps around the arena |
| The Slavic Wilds | 30:00 | Koschei the Deathless | Undying sorcerer | Dark (Holy / Dark) | Immortal until his hidden needle is found: a glowing egg appears on the map; destroy it to make him mortal |
| The Land of Legends | 10:00 | Tsuchigumo | Giant earth spider | Earth (Fire / Earth) | Webs root players; burn webs with Fire |
| The Land of Legends | 20:00 | Benkei | Rival hero (Gojō Bridge duel) | Physical (Lightning / Physical) | Fights on a narrow bridge; extremely tanky "standing death" final phase. Defeat unlocks Benkei. |
| The Land of Legends | 30:00 | Shuten-dōji | Oni king | Fire (Water / Fire) | Drunken unpredictable patterns; summons oni bands; as in legend, weakened by drink: Water hits slow him |
| Ten Suns | 10:00 | Nian | Beast of folklore | Fire (Water / Fire) | Frightened by noise and red: thunderstrikes and Fire stun it briefly |
| Ten Suns | 20:00 | Baigujing (White Bone Demon) | Shapeshifting demon (Journey to the West) | Dark (Holy / Dark) | Takes three disguises in turn; attacking the wrong target heals her |
| Ten Suns | 30:00 | The Ten Suns | Celestial calamity | Fire (Water / Fire) | Ten suns blaze overhead; shoot down nine, but if the last sun falls, the world goes dark (lose vision). Defeat unlocks Hou Yi. |
| The Crossroads | 10 / 20:00 | Random bosses from any region | — | — | Remixed |
| The Crossroads | 30:00 | The Unweaver | Original chaos being | Dark (Holy / Dark) | Steals patterns from every boss you've beaten; swallows and unweaves gods like Apep, but both at once |

**Hero unlocks from bosses:** Achilles (Aegean), Scáthach (Misty Isles), Benkei (Land of Legends), Hou Yi (Ten Suns). These four replace their post-launch entries in Heroes.

**Lore check:** Journey to the West is a classic novel and Baigujing a literary figure, so she's Tier A; Sun Wukong himself stays Tier B. The Ten Suns are from Hou Yi's legend, not worship. Verify all of these against sources before writing lore text.

**Boss rewards:** big chest (evolution/infusion eligible), Boon choice, gold bonus, bestiary entry.

**Co-op:** boss HP ×(1 + 0.75 per extra player); patterns target players in turn.

## Endless world and discoveries

Each regional level generates endlessly from chunks around the player, and a second seeded layer of **regions** places optional points of interest (POIs) that offer risk-versus-reward detours without turning the game into an open-world RPG.

### Chunks (terrain) \[Launch\]

- **Chunks:** 32×32 tiles (16 px tiles = 512×512 px). Keep a 5×5 grid loaded around each player; unload the rest.
- **Ground:** a `TileMapLayer` painted with `FastNoiseLite` so grass, dirt, stone, and flowers blend naturally.
- **Decorations:** mixed-culture ruins (broken columns, runestones, obelisk fragments, standing stones, trees, bones) placed by an RNG seeded with `run_seed + chunk_x + chunk_y`. Visual only, no collision.
- **Biomes:** each regional level has its own tileset and decoration set (see Regional levels).
- **Camera:** smooth follow with slight look-ahead.
- **Far distances:** past \~50,000 px from the origin, shift the world back toward 0,0.
- **Co-op tether:** players can't move more than \~1.5 screens apart.

### Regions and POIs \[Launch\]

- A **region** is 4×4 chunks (2,048 px). For each region, an RNG seeded with `run_seed + region_x + region_y` decides: 35% chance of one POI, its type (weighted by Age and distance from start), and its position (away from region edges).
- Max one POI per region; state is stored only when it changes (`region_key → "cleared"` / `"looted"`).
- Same seed in co-op = same POIs for everyone; the host owns POI state.
- **Onboarding:** the starting region always has Ruins within 1 screen.
- **Compass:** edge-of-screen icons for POIs within 4 screens; "?" until within 2 screens.
- Performance: a few static sprites plus spawner calls; at most \~3 POIs in loaded chunks.

| POI | What happens | Risk | Reward | Scope |
| --- | --- | --- | --- | --- |
| Hidden Shrine | An extra shrine, often uncommon/rare gods | Usually a trial | A god | \[Launch\] |
| Ancient Ruins | A crumbling stairway down into a dungeon: fight through its monsters to the treasure vault and open the chest *(owner decision 10/31/2026; was: stand in the circle 10 s while spawns spike ×3)* | Getting surrounded in the corridors | Choose: weapon/passive level, heal, or gold | \[Launch\] |
| Dragon's Hoard | Guarded treasure; kill 50 enemies within its radius to break the seal | Time spent fighting in place | Chest (evolution-eligible) + gold | \[Launch\] |
| Monster's Lair | 3 elites with guards (a labyrinth-like ring of walls) | Very dangerous | Big chest + gold | \[Launch\] |
| Wandering Trader | Sells items for your **run gold** | Spending gold you'd otherwise bank | Rerolls, heals, weapon levels, meter fills | \[Launch\] |
| Disguised Traveler | A stranger offers a bargain: power with a lasting drawback (in many myths, gods walk the world in disguise) | Permanent run debuff | Strong buff | \[Post-launch\] |
| Elemental Rift | Zone empowering one element; survive 30 s inside | Rift enemies | 2-minute element blessing | \[Post-launch\] |
| Sealed Gate | Secret boss | Very high | Rare cosmetic + big gold | \[Future\] |

### World events \[Launch: 2\]

Timed events announced with a banner, scheduled in `waves.json`:

- **Chaos Surge** (60 s): double spawns, double XP.
- **Divine Storm** (45 s): god meters charge 2×; telegraphed lightning strikes hit random spots (hurting players and enemies).
- &#91;Post-launch: Blood Moon (elites everywhere), Starfall (meteors drop chests).\]

## XP, leveling, pickups, and the trader

Enemies drop XP orbs for leveling within the run and sometimes gold, the only permanent currency; level-ups offer 1 of 3 upgrades, and gold can be spent mid-run at the Wandering Trader at the cost of banking less. \[Launch\]

- **XP orbs:** small (1), medium (5), large (25) by enemy type. Above 300 orbs on the ground, merge distant ones.
- **XP curve:** level 2 needs 5 XP; each level after needs a fixed amount more plus a small percentage, so new choices keep coming for the whole 35 minutes and a full build arrives late in the run (numbers in `config.json`). *(Changed 10/29/2026, owner approved: was "\~10% more each level", which reached level 30 by 3:00 and maxed builds by 10:00 in playtests.)*
- **Level-up (solo):** pause and show 3 random cards: new weapon, weapon level, new passive, or passive level. Never offer maxed items. High Luck can add a 4th card. Spell cards show their tier change.
- **Banked level-ups:** close the screen without picking to save the choice for later (level badge). Solo only; co-op uses turn-based picks.
- **Gold drops:** 5% from normal enemies, guaranteed from elites and bosses, piles from chests and POIs, milestone bonuses.
- **Pickup radius:** items inside it fly to the player.
- **Special pickups:** Lodestone Shard (pulls everything on screen), Ambrosia (heal 30 HP), Thunderstone (damages all on screen), Chest (upgrade, evolution, or infusion plus gold).

**Wandering Trader** (POI)

| Item | Price (run gold) | Effect |
| --- | --- | --- |
| Reroll token | 25 | Reroll one level-up's cards |
| Traveler's bread | 50 | Heal to full |
| Whetstone | 75 | +1 level to a chosen weapon |
| Incense | 40 | Fill one god's meter |
| Banish token | 60 | Remove one item from future level-ups this run |

Prices rise ×1.5 per Age. Gold spent here isn't banked, which creates a real choice between surviving longer and saving for offerings.

## Death, permanent progression, and saving

Every run ends in defeat and only things used inside the run are lost, but between runs gold and achievements unlock new **options** (Heroes, weapons, god levels, challenges, cosmetics) rather than generic stat boosts. Gold is the only currency. No loot boxes.

**Death and scoring** \[Launch\]

- At 0 HP the Hero falls (solo) or is downed (co-op).
- Score = time survived. Results also show kills, level, gods bound, Resonances used, Labors completed (Heracles), milestones, gold banked.
- Records: best time per Hero, per Omen set, and overall.

**What carries over**

| Kept permanently (used outside levels) | Lost when the run ends (used only inside) |
| --- | --- |
| Gold (100% on defeat; 10% if you quit at 5:00 or later, none before) | Weapons, passives, and their levels |
| God offering levels | Bound gods (their levels persist) |
| Gods ever bound (unlocks their offerings and Compendium page) | Run gold spent at the Wandering Trader |
| Heroes unlocked (incl. boss and secret unlocks like Achilles and Odysseus) | Boons, buffs, and Omens' in-run effects |
| Weapons and passives added to the level-up pool (e.g. Sling of Lugh, Mirrored Shield) | Heracles' Labors progress |
| Levels and packs unlocked | POI progress and the map itself |
| Secrets found and Oracle hints received | XP and character level |
| Bestiary entries and revealed weaknesses |  |
| Codex recipes discovered |  |
| Banter lines found (Words of Legend) |  |
| Resonances discovered |  |
| Achievements, records, mastery progress |  |
| Cosmetics and Omens unlocked |  |

**Persistence rule** \[v3.7\]. Anything earned during a level that is used **outside** a level (in the Hall of Legends, menus, Hero select, level select, or collections) is kept permanently. Anything used only **inside** a run is lost when the run ends.

- **Saved the moment it's earned,** not only at the end of the run. A crash, a closed app, or a dropped connection never loses an unlock.
- **Quitting a run co**sts gold: quitting before 5:00 keeps none of the gold collected that run; quitting at 5:00 or later keeps 10% (rounded down). Dying keeps 100%. This stops players from quitting early to farm gold safely. Unlocks and discoveries earned before quitting are still kept, since they were saved when earned. Rates live in config.json (quit\_gold\_pct: 0.10, quit\_min\_seconds: 300). On mobile, switching apps or taking a call pauses the run instead of quitting. In co-op, only the player who quits takes the penalty; if the host quits, the run ends for everyone and the other players keep 10% of their run gold, even before 5:00 (the host follows the normal quit rule). This prevents a host and friends from using a host-quit to farm gold. A crash or force-close is treated as a quit, since the game can't tell them apart from deliberate exits.
- **Co-op:** each player keeps their own copy of anything persistent they earned, including gold (every pickup is credited to every player) and trial rewards.
- **New features must say which side they're on.** Every new item or reward in the data files carries `persists: true` or `persists: false`, and the save system stores everything marked `true` when it's earned.

**Gold sinks** \[Launch\]

- Offerings to gods (see Gods).
- Hero unlocks (e.g. King Arthur 1,000 gold).
- Weapon unlocks: add weapons to the level-up pool (300–500 gold each).
- No generic "+5% damage" shop.

**Collections** \[Launch\]

- **Bestiary:** each creature gets an entry on first kill; weakness and resistance revealed after 25 kills, its myth summary (with source) after 100.
- **Pantheon Compendium:** every god and Resonance discovered, grouped by pantheon, with level, lines, trial records, and a short, sourced summary of the god's real myths. A respectful way to teach the cultures behind the game.
- **Hall of Heroes:** each Hero's legend in brief, with source.
- **Codex:** evolution and infusion recipes discovered.
- **Achievements** (\~30 at launch): unlock content, e.g. "Survive 20:00" unlocks Atalanta; "Trigger 4 different Resonances" unlocks Bladed Discus; "Complete all Twelve Labors" unlocks a Heracles cosmetic.

**Omens (challenge modifiers)** \[Launch: 4; unlocked after first reaching 10:00\]

| Omen | Effect | Gold bonus |
| --- | --- | --- |
| Omen of Haste | Enemies +25% speed | +25% |
| Omen of Frailty | −30% Max HP | +30% |
| Omen of the Horde | +50% spawns | +40% |
| Omen of Silent Gods | God meters charge 50% slower | +35% |

Omens stack. Records are tracked per Omen set.

**Hero mastery** \[Launch: cosmetic only; Post-launch: talents\]. Playing a Hero earns mastery 1–5, unlocking alternate color palettes. Post-launch, mastery can unlock talent *sidegrades*, never pure stat gains.

**Save file** \[Launch\]

- JSON at `user://save.json` with `save_version` (v3); migrate old versions on load. Contains: `gold`, `gods` (level + bound-ever per id), `heroes_unlocked`, `weapons_unlocked`, `bestiary` (kills per enemy id), `codex`, `achievements`, `omens_unlocked`, `records`, `mastery`, `cosmetics`, `settings`.
- Save immediately whenever something persistent is earned, and after every run and purchase. Write to a temp file, then rename, and keep one backup.

**Cloud saves across PC and phone** \[Launch\]

Progress follows the player between PC and phone. The game always works offline and syncs when a connection is available.

- **Why not just Steam Cloud, iCloud, or Google Play saves:** each only syncs within its own platform, so a Steam save can't reach a phone. They're still used as a local backup on each platform.
- **Cross-platform sync:** through the owner's **Cloudflare Worker** (as for co-op lobbies). The player turns on cloud save in Settings and gets a private 12-character sync code; typing it on another device links them. No account or personal data; the save is stored under a scrambled form of the code. Sign-in with Google, Apple, or Steam can be added later in place of the code. *(Changed 10/29/2026, owner approved: was Epic Online Services accounts and storage.)*
- **Sign in with Google** *(added 10/31/2026, owner request)*: in Settings → Account and cloud save, the player signs in with Google on each device (PC, phone, or web), and their progress follows them. The server keeps only Google's id (hashed). The game never asks Google for the player's real name; players signed in with Google choose a **username** (Settings → Account and cloud save; it only shows while signed in), saved with their progress so it follows them through cloud saves, and shown to other players in co-op and as the leaderboard name. Google's email goes only to the player's own device, to show which account is signed in *(username: owner request 10/31/2026)*. **Settings** sync too: the device that changed them last wins. Signing in fills in the account's sync code automatically; a device that already had cloud saves brings its save to a new account. The private code stays as the option for players without a Google account. Apple and Steam sign-in can be added later the same way.
- **One device at a time** *(added 10/31/2026, owner decision)*: an account (or sync code) can only be played on one device at a time, and never twice in the same co-op game. A device claims it before a run or a co-op game and lets go back on the title screen; a closed game lets go within about 90 s. If another device takes over while one was offline, the first device's run ends with a message. Without a connection, play is allowed.
- **When it syncs:** on launch, after every run, after every purchase in the Hall of Legends, and when something persistent is earned (batched, at most once every 30 s).
- **Conflicts** (both devices changed while offline) are merged automatically, because most progress only grows:
  - Unlocks, discoveries, secrets, bestiary entries, codex, banter, achievements: **combine both** (union).
  - God offering levels, mastery, records, best times: **keep the higher** value.
  - Gold: keep the value from the **most recently played** device, and show the player a one-line notice. (Gold is the only value that can go down, so it can't simply be combined.)
- **Save format ready from day one:** the save file has a `save_version`, a `device_id`, a `last_modified` timestamp per section, and a sync counter, so cloud sync can be added without changing the format.
- **Purchases are separate from progress:** progress syncs everywhere, but packs bought in one store (e.g. Steam) don't automatically unlock in another (e.g. the App Store). Whether that's allowed depends on each store's rules; check them before launch.
- **Co-op** doesn't affect cloud saves: each player's progress lives in their own account.

## Discovery and feel \[new in v3.6, Launch\]

Four features that make every run feel rewarding, even the ones that end badly: a suspenseful chest reveal, a death recap that teaches, secrets to discover, and short lines between Heroes, gods, and bosses whose myths connect.

### 1. Chest reveal

Opening a chest is a short, exciting moment in our own style, themed to the level's pantheon.

1. **The seal.** The chest is closed by a seal in the level's pantheon style: a Greek meander ring, Norse runic band, Egyptian scarab clasp, or Celtic knot. (Seals are decorative patterns, never fake writing in a real script.)
2. **The build-up (about 1.5 s).** The seal spins and cracks while light leaks out and a rising note plays. The light's color previews the reward: **bronze** = 1 upgrade, **silver** = 2, **gold** = 3 upgrades or an evolution/infusion. Luck raises the odds of silver and gold.
3. **The reveal.** Rewards rise one at a time with a short sound each.
4. **Evolutions get a special reveal:** the weapon icon and passive icon (and god icon, for infusions) fly together and fuse into the new weapon. This shows the player exactly how the recipe works, and a "New recipe discovered" banner adds it to the Codex.

Rules: the whole reveal takes no more than 3 s and can be skipped with a tap or key after 0.5 s. A **Fast chests** setting shortens it for players who prefer speed. Solo play pauses during the reveal; in co-op it pauses the game for everyone. Effects use pooled UI particles.

### 2. Death recap

The results screen turns each defeat into something learned.

- **What felled you:** the enemy, boss, or hazard that dealt the final blow, with its element, plus what dealt you the most damage in the last 10 seconds.
- **Your build:** weapons (levels, evolutions, infusions), passives, gods and their levels, Resonances used, and your top damage weapon as a percentage of total damage.
- **Progress:** time survived, milestones reached, kills, gold banked, and your personal best for this Hero and level.
- **One tip,** chosen by rules from the run log. Examples: died mostly to Kelpies without any Lightning → "Kelpies are weak to Lightning"; died to Medusa's gaze → "Moving away from Medusa as her gaze fires keeps you from being petrified"; never bound a god → "A shrine appears about every 3 minutes; look for the arrow at the screen's edge." A weakness revealed by a tip is also marked in the bestiary. The same tip never shows twice in a row.
- **Quick buttons:** Retry (same Hero and level) and Change Hero.
- **Co-op:** each player sees their own recap plus a team summary.

Tips live in `tips.json`: condition, text, priority. The recap reads the run log saved at the end of every run.

### 3. Secret unlocks

Hidden rewards for unusual feats. Each secret follows the lore of the place it's found, so players can reason their way to it.

**Rules:** secrets are discovered by playing, never by grinding; each is fair and achievable in a normal run; they appear as "???" in Achievements until found. After every 5 runs, **the Oracle** (in the Hall of Legends, after the Oracle of Delphi) offers one cryptic hint about an undiscovered secret.

**Pack 1 secrets** (8 at launch)

| Secret | Condition | Reward | Lore link |
| --- | --- | --- | --- |
| The Beggar King | Survive 10:00 without picking up any gold | **Odysseus** joins as a secret Hero | Odysseus returned home disguised as a beggar |
| The Mirrored Shield | Defeat Medusa without ever being petrified | **Mirrored Shield** passive (reflects some projectiles) | Perseus beat Medusa using a reflective shield |
| Tyr's Oath | Defeat Fenrir while below 30% HP | **Tyr's Oath** passive (more damage at low HP) | Tyr sacrificed his hand to bind Fenrir |
| The Sun's Return | Let Apep swallow Ra, then free him | Golden sun aura cosmetic and a unique Ra line | Ra's nightly escape from Apep |
| Lugh's Sling | Strike Balor's open eye 5 times in one fight | **Sling of Lugh** weapon added to the pool | Lugh killed Balor with a sling-stone to the eye |
| The Twelve Labors | Complete all 12 Labors in one run as Heracles | Golden lion-pelt cosmetic | Heracles' labors |
| Fortune's Favor | Finish a run with Tyche bound and exactly 777 gold banked | Fortune's wheel cosmetic | Tyche, goddess of luck |
| The Ford | As Cú Chulainn, defeat Ferdiad without leaving the river strip | Unique ending lines and a cosmetic | Their famous duel at the ford |

Secrets live in `secrets.json`: condition, reward, hint text, `lore_source`. Odysseus becomes a launch Hero (secret) using his design from the Heroes post-launch list.

### 4. Hero and god banter

Short lines, one sentence each, when characters whose myths connect meet in a run. They appear as a portrait and a text bubble in a corner for 3 s, never pause the game, and can be turned off in Settings. Every line found is collected on a **Words of Legend** page in the Pantheon Compendium.

**When lines play:** when a Hero binds a god; at a boss's entrance; the first time two gods form a Resonance; and occasionally (10% of summons) when summoning.

**Pack 1 connections**

| Who | Connection in myth |
| --- | --- |
| Cú Chulainn and the Morrígan | She offered him her love; he refused, and she hindered him in battle. A crow settled on his shoulder at his death. |
| Cú Chulainn and Scáthach (boss) | She trained him in arms on the Isle of Shadows. |
| Cú Chulainn and Ferdiad (boss) | Foster-brothers forced to fight at the ford. |
| King Arthur and Mordred (boss) | Arthur's final battle at Camlann. |
| Heracles and Poseidon | Heracles rescued Hesione from Poseidon's sea monster at Troy. |
| Heracles and Kronos (boss) | Kronos is Heracles' grandfather, overthrown by Zeus. |
| Thor and Loki (boss) | Companion on many journeys, and his enemy at the end. |
| Skadi and Loki (boss) | Loki made her laugh as part of her compensation; later she hung the venomous serpent over the bound Loki. |
| Ra and Sekhmet | Sekhmet was the Eye of Ra. |
| Ra and Set (boss) / Ra and Apep (boss) | Set defended Ra's sun-boat against Apep; Apep tries to swallow the sun each night. |

**Writing rules:** lines are written by us, inspired by the myth, and follow the naming and lore rules. Don't quote modern translations of old texts (translations can be copyrighted); quote only translations published in 1930 or earlier, or write original lines. Each line records its `lore_source`. Lines live in `banter.json`: speakers, trigger, text, source. Heroes with no connection to anyone in a pack (e.g. Väinämöinen, Tomoe Gozen in Pack 1) get general lines for binding any god.

### Where these go in the build

- Chest reveal: Phase 10 (chests and evolutions).
- Run log: Phase 6 (save a basic log from the first runs; it helps balancing too).
- Banter: Phase 11 (god binding and summons) and Phase 13 (boss entrances).
- Death recap, secrets, the Oracle, and Odysseus: Phase 15 (meta and saving).

## Online co-op (6-digit codes)

Up to 4 Heroes share one Last Stand through a 6-digit code; the host's game is the authority, rewards are never contested, and everyone makes their own build choices. Built only after single-player is fun and stable. \[Launch target, built last; can ship in an update if it threatens release.\]

**Joining flow**

1. Host taps **Host Game**; the game creates a lobby and shows a 6-digit numeric code.
2. Friends tap **Join Game** and type the code.
3. In the lobby, each player picks a Hero (duplicates allowed). The host's Omens apply to everyone.
4. If the host leaves, the run ends for everyone (no host migration at launch).
5. Friends can join with the code at any time, even during a run (see Joining in progress below).

**Public games** *(added 10/29/2026, owner request)*

- A separate **Public Games** button (the friend-code Co-op stays as it is). It lists open public games (level, players, in the lobby or in a run) and has **Host a public game**, which puts that game on the list. Only games with the same game version and a free place are listed; friend-code games are never listed.
- **Joining in progress:** any co-op game, public or friend code, can be joined during a run *(friend games added 10/29/2026, owner request)*. The newcomer's Hero appears beside the host's Hero with its signature weapon and shares the team's XP and level; the host sends their game a snapshot of the world so far. A newcomer takes the place of a player who left (that player's Shade makes way).
- **Catch-up chest:** a newcomer gets one chest's worth of upgrades (no gold) for every 5 minutes already played, up to 6, in one chest reveal *(added 10/29/2026, owner request; numbers to tune in config.json)*.
- A public game's host may start alone; the same lobby, fairness, and sync rules apply.
- **Invite friends mid-run** *(added 10/31/2026, owner request)*: in a solo run, the pause menu has **Invite friends** (shows a code) and **Open to public**. The run becomes a co-op game hosted by that player without stopping, and others join it in progress. The host can switch between public and friends-only (code) at any time from the pause menu.

**Online service:** the owner's Cloudflare Worker (free plan): a Durable Object per lobby relays messages over WebSockets, so co-op works on the web, PC, and phones; behind a `LobbyService` interface so another service (Epic Online Services, Steam lobbies via GodotSteam, Nakama) can be swapped in. *(Changed 10/29/2026, owner approved: was Epic Online Services, which needs a developer account and has no web support.)*

**Fairness rules**

| Topic | Rule |
| --- | --- |
| Gods | **Personal.** Each player has their own 2 slots, buttons, meters, Patronage, and permanent god levels. |
| Peaceful shrines | Each player who touches the shrine while active binds their own copy of the god. |
| God trials | The trial doesn't start until every standing player is inside the ring (if not everyone arrives within 30 s, it's called off and can be started again). Everyone who took part earns the god on success, including players downed during it. Each chooses individually whether to bind it or release a current god. *(Changed 10/30/2026, owner decision: was "inside the ring at the start or within the first 10 s".)* |
| XP | One shared XP bar; everyone levels at the same time. |
| Level-up choices | **Individual:** each player gets their own 3 cards, chosen on their turn. |
| Level-up pause | Full pause and the timer stops. Players pick one at a time in rotating turn order, up to 20 s each (see Core mechanics). |
| Pause menu | Overlay only; the game keeps running. |
| Gold | **Every gold pickup is credited in full to every player.** Trader purchases spend only the buyer's run gold. |
| Chests | Open for the player who touched them; evolution/infusion checks use that player's build. |
| Revives | A downed player bleeds out over 20 s. An ally standing beside them for 3 s revives them at 30% HP. **2 revives** per player per run; revive time grows (3 s, then 5 s). |
| After the last revive | The player becomes a **Wandering Shade**: a ghost that collects XP orbs and gold for the team and gives allies nearby +10% god charge. Can't die or deal damage. |
| Run end | When every player is downed or a Shade. |
| Resonance | Only between a player's own two gods. \[Post-launch idea: cross-player Resonance.\] |
| Heracles' Labors | Personal to each Heracles player; allies' kills don't count. |
| Scaling | +60% enemy HP and +50% spawns per extra player; boss HP ×(1 + 0.75 per extra player). |

**Sync rules (host-authoritative)**

- Clients send movement input, manual aim, and button presses \~20 times/second.
- The host simulates everything: spawns, damage, statuses, reactions, drops, POIs, shrines, trials, Labors, deaths.
- Host sends player positions \~20/s and **events** for everything else ("enemy 214 of type X spawned at (x, y)", "enemy 214 died", "burn on 214"). Clients move enemies locally with occasional corrections. Never send every enemy's position every frame.
- Interpolate other players' movement.
- Shared seed: everyone generates the same map and POIs locally.

**Testing order:** two windows on one PC → two devices on the same Wi-Fi → online through codes.

## Screens, HUD, art, audio, and accessibility

Placeholder shapes and no sound until the game is fun; then original 16-bit-style pixel art with a distinct palette per pantheon, and original or licensed audio, with readability and accessibility treated as core features.

**Screens**

| Screen | Contents |
| --- | --- |
| Title | Play, Co-op, Public Games, Hall of Legends, Settings, Quit (every platform; in a browser it says the tab can be closed) *(changed 10/29/2026, owner request; Public Games added 10/29/2026, owner request)* |
| Hall of Legends (hub menu) | Hero select, Offerings (god levels), Unlocks, Bestiary, Pantheon Compendium, Hall of Heroes, Codex, Achievements, Omens |
| Hero select | Heroes with tradition, stats, Legend Trait, passive, Divine Link, patron pantheon, signature weapon; locked Heroes show how to unlock |
| Co-op | Host (shows code) / Join (code entry) / lobby with players and their Heroes |
| Public Games | List of open public games (join, even during a run) / Host a public game / the same lobby *(added 10/29/2026, owner request)* |
| In-game HUD | XP bar; timer with personal-best marker; kills; gold; Age banner; weapon and passive icons; 2 god buttons with meter rings; Resonance button when ready; POI compass; HP bar over the Hero; Heracles' current Labor (when playing him) |
| Level-up | 3 cards: icon, name, level or tier change, description, element icon |
| Chest | Recipe display (weapon + passive/god = result) and reward |
| Trial / Boss | Ring, health bar with weakness/resistance icons, Guard gauge, cast bar |
| Pause | Resume, build summary, Codex, Settings, Quit run |
| Results | Time, kills, level, gods, Resonances, Labors, milestones, gold banked, new unlocks |
| Offerings | Every god ever bound, its level, next unlock, gold cost |
| Settings | Accessibility (below), volume, controls; Fullscreen; on the web version Install app and Update app *(added 10/31/2026, owner request)* |

**Art:** original 16-bit-style pixel art, 16×16 or 32×32 sprites, nearest-neighbor filtering, integer scaling. Placeholders first (circles for enemies colored by element, squares for Heroes). Each pantheon gets its own palette and architecture (e.g. Greek marble and bronze, Norse wood and iron, Egyptian sandstone and lapis, Celtic stone and green-gold). Gods need large distinctive sprites and portraits. Research period clothing, weapons, and symbols from historical and museum sources for each Hero and god, and avoid stereotypes.

**Game feel:** hit flash, small knockback, damage numbers (weak = big yellow "!", resist = small gray), screen shake on summons and Guard Breaks, a brief freeze-frame on Resonance.

**Audio:** music per Age and per boss with instrumentation that hints at each culture without parodying it; distinct sounds for weakness hits, reactions, tier-ups, meter-full, and Resonance-ready. Each god has a short motif. Max 8 identical sounds at once.

**Rising-pitch pickups (capped)** \[Launch\]. XP orbs collected in quick succession climb a musical scale, then hold at a top note.

- Each orb picked up within **0.4 s** of the last plays the next note up a pentatonic scale, which always sounds pleasant at any speed.
- **Cap: 12 steps.** After the 12th note, further orbs keep playing that top note until the chain ends. No endless climb into shrill sounds.
- The chain resets to the bottom note after **0.6 s** without a pickup.
- **Rate limit:** at most 20 pickup sounds per second. When a Lodestone Shard pulls in hundreds of orbs at once, the sound plays as a quick capped run up to the top note instead of hundreds of overlapping plays.
- Gold has its own coin sound with the same chain, cap, and rate limit, so XP and gold are easy to tell apart by ear.
- All values live in `config.json` (`pickup_chain_window_s`, `pickup_chain_max_steps`, `pickup_chain_reset_s`, `pickup_sounds_per_s`).

**Accessibility settings** \[Launch\]

- Player effect opacity (30–100%).
- Screen shake and flash intensity (off / low / full).
- Element icons on damage numbers and enemies, plus colorblind palettes.
- Auto-summon gods on/off.
- Joystick size and position; button size. Position: the joystick works anywhere on the screen except on buttons (the default), or only on the left or right side; with right, the god buttons move to the bottom-left. *(Added 10/29/2026, owner approved.)*
- All settings, including Auto-summon and Auto-collect, are saved and kept between runs, and all of them are on the Settings screen. *(Added 10/29/2026, owner approved.)*
- Damage numbers on/off.
- Text size.

**Onboarding** \[Launch\]: the first run shows short contextual tips (first level-up, first shrine, first weakness hit, first full meter, first Resonance). Each shows once and can be disabled.

## Data files, JSON schemas, and the reference database

All content and tuning lives in JSON under `res://data/`, validated at startup (clear errors naming the file and field). Your mythology database is a **design reference**, not game data: it lives in `reference/`, isn't shipped, and Heroes and gods are copied from it into game JSON only after design and lore checks.

**Using the reference database**

- Files: `Mythology_Heroes_Warriors.csv` (152 heroes, 24 traditions), `Mythology_Gods_Deities.csv` (277 gods, 17 traditions), plus the same data as `.xlsx`, `.sqlite` (tables `heroes`, `gods`), and an offline HTML catalog.
- Its `Cultural Care` column maps to our tiers: "May belong to a living religion" / "Living / sacred tradition" rows default to Tier B or C; the rest default to Tier A, then are checked against the Cultural care and IP section (e.g. Japanese historical heroes are Tier A, Shinto kami Tier B).
- Its "Suggested In-Game Attack (Invented)" column is a brainstorm, not myth; use it as a starting idea.
- Its `Source URL` is sometimes a tradition overview; record a figure-specific source in `lore_source` before setting `lore_verified: true`.
- &#91;Later, optional\] Cursor can write a one-time import script that reads the SQLite file and generates **draft** entries (name, tradition, care tier, source) for `heroes.json` / `gods.json`, which are then designed by hand. Not part of the game build.

| File | Holds |
| --- | --- |
| `config.json` | XP curve, enemy cap, effect budgets, shrine interval, Age times, Unraveling rate, co-op scaling, chunk/region size, DPS budgets |
| `heroes.json` | Heroes: tradition, care tier, lore source, stats, signature weapon, Legend Trait, passive, Divine Link, patron pantheon, unlock rule |
| `weapons.json` | Weapons: element, targeting, fire pattern, stats per level, tier names, evolution pairing, infusion hooks, unlock rule |
| `passives.json` | Passives: stat changes per level 1–5 |
| `elements.json` | Elements, colors, statuses, reactions, infusion templates |
| `gods.json` | Gods: pantheon, care tier, lore source, element, rarity, shrine/trial type, trigger, Blessing and summon per level, level unlocks, offering costs, lines |
| `resonances.json` | Pairs, Harmony, Resonance summon |
| `enemies.json` | Enemies: family, tradition, stats, Armor, element, weak/resist, movement, drops, Ages |
| `elite_modifiers.json` | Elite modifiers |
| `bosses.json` | Bosses: tradition, element, phases, patterns, casts, Guard gauge |
| `waves.json` | Per-minute spawn tables, elites, bosses, Ages, events |
| `pois.json`, `events.json`, `omens.json`, `achievements.json` | As named |

**New in v3.1: `levels.json`** holds one entry per regional level: tileset, decorations, music, hazard, enemy families per Age, local gods, shrine weighting, the three bosses, and the unlock rule. `waves.json` becomes one wave table per level (`waves/aegean.json`, etc.).

```json
{
  "id": "midgards_edge",
  "name": "Midgard's Edge",
  "region": "norse",
  "act": 1,
  "care_tier": "A",
  "tileset": "norse_forest",
  "decorations": ["pine", "runestone", "longhouse_ruin", "snowdrift"],
  "music": { "dusk": "midgard_dusk", "night": "midgard_night", "deep_night": "midgard_deep", "boss": "midgard_boss" },
  "hazard": { "type": "blizzard", "interval_s": 90, "duration_s": 15, "push_speed": 40, "vision_mult": 0.7 },
  "waves": "waves/midgards_edge.json",
  "local_gods": ["thor", "skadi"],
  "local_shrine_chance": 0.5,
  "excluded_gods": ["loki"],
  "bosses": { "10": "fenrir", "20": "loki", "30": "surtr" },
  "unlock": { "type": "defeat_boss", "level": "aegean_shore", "minute": 20 },
  "unlocks_hero_on_defeat": null
}
```

**Hero**

```json
{
  "id": "cu_chulainn",
  "name": "Cú Chulainn",
  "tradition": "irish",
  "patron_pantheon": "celtic",
  "care_tier": "A",
  "lore_source": "Táin Bó Cúailnge (translation used: ...)",
  "lore_verified": false,
  "stats": { "max_hp": 110, "move_speed": 105, "armor": 1, "might": 0, "area": 0, "cooldown": 0, "pickup_radius": 40, "luck": 0, "crit": 5 },
  "signature_weapon": "gae_bolg",
  "trait": { "id": "salmon_leap", "interval_s": 8, "distance_tiles": 3, "untargetable_s": 0.8, "landing_radius_tiles": 2 },
  "passive": { "id": "battle_frenzy", "hp_below": 0.3, "attack_speed_pct": 30, "area_pct": 15 },
  "divine_link": { "id": "landing_applies_god_elements" },
  "unlock": { "type": "starting" }
}
```

**God**

```json
{
  "id": "thor",
  "name": "Thor",
  "pantheon": "norse",
  "care_tier": "A",
  "lore_source": "Prose Edda (translation used: ...)",
  "lore_verified": false,
  "element": "lightning",
  "role": "chain_damage",
  "rarity": "uncommon",
  "shrine": { "type": "trial_duel", "patterns": ["hammer_throw", "ground_circles"] },
  "trigger": { "type": "attacks_made", "amount": 150 },
  "blessing": { "lightning_damage_pct": 15, "chain_every_n_projectiles": 10 },
  "summon": { "effect": "hammers_return", "damage": 60, "duration_s": 3 },
  "level_unlocks": { "3": "meter_10", "5": "summon_upgrade", "7": "harmony_plus", "9": "meter_10", "10": "ascended" },
  "offering_cost": [75, 150, 250, 400, 550, 750, 1000, 1300, 1600],
  "lines": { "found": "...", "bound": "...", "summon": "...", "patron": "..." }
}
```

**Weapon**

```json
{
  "id": "ember",
  "element": "fire",
  "targeting": "targeted",
  "pattern": "forward",
  "tier_names": ["Ember", "Flame", "Blaze", "Inferno"],
  "levels": [ { "damage": 10, "cooldown": 1.2, "count": 1, "speed": 300, "area": 1.0, "pierce": 0, "status_chance": 0.3 } ],
  "evolution": { "passive": "belt_of_strength", "into": "inferno" },
  "infusion_hooks": ["on_hit", "on_kill"],
  "unlock": { "type": "starting" }
}
```

**Resonance**

```json
{
  "id": "storm_over_the_sea",
  "gods": ["poseidon", "thor"],
  "harmony": { "chain_bonus_targets": 1 },
  "summon": { "effect": "surge_chain", "soak_s": 6, "chain_interval_s": 0.5, "damage": 30 },
  "scales_with": "lower_god_level"
}
```

**Enemy and boss**

```json
{
  "id": "kelpie",
  "family": "kelpies",
  "tradition": "celtic",
  "hp": 30, "speed": 60, "contact_damage": 8, "armor": 0,
  "element": "water", "weak": "lightning", "resist": "fire",
  "movement": "chaser", "xp": 5, "gold_chance": 0.05, "knockback_resist": 0.2,
  "ages": ["night"]
}
```

```json
{
  "id": "surtr",
  "tradition": "norse",
  "element": "fire", "weak": ["water", "ice"], "resist": "fire",
  "hp": 20000, "armor": 5,
  "guard_gauge": { "max": 1000, "break_s": 4, "damage_taken_mult": 1.5 },
  "phases": [
    { "hp_above": 0.6, "patterns": ["sword_slam", "radial_burst"] },
    { "hp_above": 0.25, "patterns": ["charge_trail"], "casts": [{ "name": "Flames of Muspelheim", "cast_s": 2.0, "pattern": "falling_strikes", "count": 12 }] },
    { "hp_above": 0.0, "patterns": ["arena_shrink", "sword_sweep"] }
  ]
}
```

## Scope: launch, post-launch, future

Launch is a complete, polished single-player game with 4 regional levels, 8 Heroes, 8 gods, 12 bosses, and the god system fully realized; co-op is the last launch item and can slip to an update.

| Area | Launch essentials | Post-launch additions | Future ideas |
| --- | --- | --- | --- |
| Levels | Pack 1 only: Aegean Shore, Midgard's Edge, Two Lands, Misty Isles (each with tileset, hazard, music, wave table) | Packs 2–13 and the extras (see Pack roadmap), added one pack at a time after Pack 1 works | Tier B regions after cultural review |
| Heroes | Heracles, Cú Chulainn, Väinämöinen, Tomoe Gozen + King Arthur, Atalanta + Achilles, Scáthach (boss unlocks) | \~17 more Tier A Heroes; mastery talents | Tier B Heroes after review |
| Gods | Tyche, Poseidon, Thor, Skadi, Sekhmet, Ra, Cernunnos, the Morrígan; 3 trial types; offerings 1–10 | More gods per pantheon; Wind gods | Tier B pantheons after review |
| Resonance | 5 pairs (incl. Eye of Ra) + Harmony; Patronage | 4+ more pairs; Pantheon Kinship | Cross-player Resonance |
| Elements | 8 elements, 8 statuses, 4 reactions, spell tiers | Toxic Flare, Eclipse |  |
| Weapons | 14 weapons, 14 evolutions, 8 infusion templates, codex | Union evolutions; Water and Earth spells |  |
| Enemies | \~15 mythic families across 4 levels, 7 movement types, 6 elite modifiers | Families for new regions |  |
| Bosses | 12 (3 per level) incl. antagonist gods and rival heroes; arena rule, Guard gauge, cast bars | Alternate boss per slot (Typhon, Hydra, Jörmungandr, Ymir) | Secret bosses |
| World | Chunks, regions, 5 POI types, 2 events, 4 level hazards | Disguised Traveler, Elemental Rift | Walkable Hall of Legends |
| Run arc | 4 Ages, Boons, the Unraveling, personal-best marker | More Boons | Daily seeded runs |
| Meta | Level select map, per-level records, gold sinks, bestiary, Compendium, Hall of Heroes, codex, achievements, 4 Omens | More Omens and cosmetics | Endless Unraveling mode |
| Co-op | 4 players, codes, fairness rules (last launch item) | Host migration, quick-play | Cross-play friends lists |
| Polish | Accessibility, onboarding, debug menu, release content gate | Rebinding UI | Localization |

**Scope warning:** four regional levels roughly quadruple art, music, enemy, and boss work compared with v3. Build the Aegean Shore completely first as a vertical slice. Decision: only Pack 1 is built first. More packs are added one at a time, and only after Pack 1 is working, tested, and fun.

## Build phases

Build in 20 phases, one Cursor chat per phase, testing in Godot before moving on; Phase 7 is a deliberate stop to confirm the core is fun before adding the deeper systems.

**Project location** (Windows): `F:\My Documents\Documents\My Programs\Finnished\Cursor\Mythriven`. Open this folder in Cursor and create the Godot project (named Mythriven) inside it. Layout of the root folder:

```
Mythriven\
  GAME_DESIGN.md        # this document, exported as Markdown
  .cursor\rules         # the standing rules below
  reference\            # the mythology database files (never loaded by the game)
  project.godot         # created by Godot in Phase 1
  data\  scenes\  scripts\  assets\  localization\
```

The path contains spaces, which Godot and Cursor handle fine; just keep it in quotes if you ever type it in a terminal command.

1. **Setup:** Godot project, folder structure, Input Map, JSON loader with validation, release content gate, translation tables (all text through tr()), seeded RNG helpers, debug menu shell, empty main scene. Put the mythology database files in `reference/`.
2. **Player:** movement (keyboard, gamepad, mobile joystick), facing, placeholder sprite, camera follow, players-as-list.
3. **Endless map:** chunk manager, noise ground, seeded decorations, origin shift. Read tileset and decorations from `levels.json` from the start, with one level (Aegean Shore).
4. **Enemies core:** pooling, spatial hash, chaser/swarm movement, ring spawning, recycling, contact damage, player HP and death.
5. **Weapons and smart targeting:** one signature weapon (Heracles' Great Club), targeting types, damage, knockback, damage numbers, enemy death.
6. **XP and level-up:** orbs with capped rising-pitch sounds, pickup radius, XP bar, level-up cards, weapon levels 1–8, passives, banked level-ups, a few general weapons.
7. **Fun checkpoint:** play 10-minute runs and tune until moving and killing is fun on its own. Don't continue until it is.
8. **Elements:** elements, statuses (data, 5 Hz), weakness/resistance, Armor, 4 reactions, spell tier names, effect budgets.
9. **Heroes:** `heroes.json`, Hero select, 4 starting Heroes with Legend Traits, passives, and signature weapons (Divine Links in Phase 11).
10. **Aegean waves and elites:** per-level wave table, the Aegean's enemy families, all movement types, Ages and visuals, the thunderstorm hazard, elites with modifiers, chests, standard evolutions, codex.
11. **Gods:** shrines with local-pantheon weighting, peaceful binding, 3 trial types, two buttons and meters, Blessings, summons, Divine Links, Patronage, auto-summon setting.
12. **Resonance and infusions:** 5 Divine Resonances with Harmony and Resonance button; 8 infusion templates and Empowered.
13. **Aegean bosses:** pattern library, arena rule, telegraphs, cast bars, Guard gauge, Medusa, Achilles (and his Hero unlock), Kronos, Boons, the Unraveling. **The Aegean Shore is now a complete vertical slice; playtest it thoroughly.**
14. **World discoveries:** region layer, 5 POI types, compass, Wandering Trader, 2 world events.
15. **Meta and saving:** gold banking, save v3 (with level unlocks, per-level records, and the cloud-sync-ready format), Steam Cloud backup, Swift Mode, Hall of Legends menus, level select map, offerings, unlocks, bestiary, Compendium, Hall of Heroes, achievements, Omens, King Arthur and Atalanta.
16. **Midgard's Edge:** tileset, blizzard hazard, enemy families, wave table, Fenrir, Loki, Surtr.
17. **The Two Lands:** tileset, sandstorm and quicksand, enemy families, wave table, Ammit, Set, Apep (god-swallowing).
18. **The Misty Isles:** tileset, mist and fairy rings, enemy families, wave table, Scáthach (and her unlock), Ferdiad (Cú Chulainn dialogue), Balor. After launch, each Act II–IV level is one phase of the same shape (tileset, hazard, families, wave table, 3 bosses, local gods), built in Act order.
19. **Polish:** art, audio, accessibility, onboarding, mobile UI and safe areas, performance pass on a real mid-range phone, exports. Verify every launch Hero, god, and boss's lore and set `lore_verified`.
20. **Co-op** and cross-platform cloud saves (only once single-player is stable): the online service shared by both (Cloudflare Worker; owner approved 10/29/2026), cloud sync with merge rules, fairness rules, local network test, then online lobby with 6-digit codes, Wandering Shade mode.

**Standing rules** (put these in `.cursor/rules`):

```
Always read GAME_DESIGN.md before starting a task.
Only build features tagged [Launch] unless I say otherwise. Only build Pack 1 levels (Aegean Shore, Midgard's Edge, Two Lands, Misty Isles).
Never use anything from Final Fantasy or other games' designs; follow the Cultural care and IP section.
Only Tier A Heroes and gods may be enabled in release builds.
Never invent names or lore. Use names and details from public-domain sources per the naming rules; if none exists, ask me before inventing, and mark it invented: true.
All player-facing text uses translation keys through tr(); never hard-code text.
Godot 4, GDScript with static typing.
All tuning numbers go in res://data JSON files, never hard-coded.
Players are always a list; game events go through GameAuthority.
Use object pooling and the spatial hash for enemies, projectiles, and effects.
Statuses are data on pooled enemies, ticked at 5 Hz. Respect effect budgets in config.json.
The files in reference/ are design notes, never loaded by the game.
Anything earned in a level that is used outside a level persists and is saved the moment it's earned (persists: true).
Never remove or rewrite working features unless asked.
When a step needs the Godot editor, give exact click-by-click instructions.
End every task by telling me how to test what you built, including debug-menu shortcuts.
```

**Prompt template for each phase:**

```
Read GAME_DESIGN.md. We are on Phase [N]: [name].
Build only what that phase lists, following the matching section(s) of the doc.
Use placeholder shapes for art. Don't change working code from earlier phases
unless you explain why first. Add debug-menu options to test the new features.
When done, tell me how to test it.
```

If something breaks, describe what you see (or paste the error from Godot's Output panel) and ask Cursor to fix only that before continuing.
