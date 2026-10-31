# Pack 3 plan: Distant Legends

Status: **approved by the owner** (10/31/2026: "yes, as suggested" to all five questions). Pohjola built and released
10/31/2026 (00.02.70); Mazandaran (00.02.72); the Slavic Wilds (00.02.73); the Land of Legends (00.02.74). **All four Pack 3 levels
and its three Heroes are built.** Still open: Pack 3 secrets and Resonances (to design with the owner). The owner asked to start Pack 3 once Pack 2 was finished ("When your done
start pack 3"). Like Pack 2, this plan comes first; building starts when the owner answers the questions at the end.

Everything named here comes from `GAME_DESIGN.md` (Act III levels, Gods added with Acts II–III, Acts II–IV bosses,
Post-launch Heroes) and `docs/PACK_PLAN.md`. Where the design had a gap or a name without a source, a sourced choice is
**suggested** and marked so, for the owner to approve. Nothing is quoted from translations later than 1930; all lines
are written fresh.

## How it is built (same as Pack 2)

- One level at a time, each shown to the owner before the next: Pohjola, Mazandaran, the Slavic Wilds, the Land of
  Legends.
- Each level: its ground, trees and animals, a hazard, four monster families with a wave table, three bosses (10:00,
  20:00, 30:00), its local gods (or the Simurgh), and its Hero if it has one; then its achievements, two secrets and
  banter lines, as Pack 2 had.
- Every Hero, god and boss gets `lore_source` and `lore_verified: false` and goes on `docs/LORE_CHECK.md`.
- **Unlock (suggestion, like Pack 2's sister levels):** each level opens by beating the 30:00 boss of a Pack 2 level
  with a link to it:

  | Pack 3 level | Opened by | Why |
  | --- | --- | --- |
  | Pohjola | Ymir (Jotunheim) | Both the frozen far north |
  | Mazandaran | Tiamat (the Land Between the Rivers) | Neighbouring lands of the old Near East |
  | The Slavic Wilds | Twrch Trwyth (Avalon's Shadow) | Enchanted forests and their beasts |
  | The Land of Legends | Typhon (the Underworld) | The last and farthest step |

- **Difficulty (suggestion):** Pack 3 is harder again. Against Pack 1 at the same minute: enemy HP +40%, spawns +25%,
  damage +20% (Pack 2 is +20% / +15% / +10%).

---

## Level 9: Pohjola (Finnish, the Kalevala): **done and released 10/31/2026 (00.02.70)**

**Look:** dark northern pine and spruce, frozen lakes, snow, the northern lights overhead.
*Source: the Kalevala (Lönnrot, 1849), runos 1, 13–14, 19, 32–33, 42–47.*

**Hazard: polar night.** The dark pulses in and the view shrinks to a ring of light round each Hero, then lifts.
(A new "darkness" hazard; Mazandaran's sorcerous clouds reuse it.)

**Monster families**
| Family | What it does | Source |
| --- | --- | --- |
| Hiisi forest-spirits | Goblin-like spirits of the wild woods, in packs | Kalevala 13–14 (Hiisi, who made the elk) |
| Pohjola's wolves | Fast packs | Kalevala 32–33 (Louhi's wolves and bears sent against the herd) |
| Vipers of the snake field | Swarms that strike from the snow. **Suggested** in place of "swamp beasts", which had no source | Kalevala 19 (Ilmarinen must plough Pohjola's field of vipers) |
| Frost (Pakkanen) wisps | **Suggested** casters that throw frost | Kalevala 30 (Pakkanen, the Frost, sent by Louhi) |

**Bosses (from the design)**
| Time | Boss | Mechanic | Source |
| --- | --- | --- | --- |
| 10:00 | **The Elk of Hiisi** | Sprints you can't catch: it must be slowed (Chill, Wind, stuns) before it takes damage | Kalevala 13–14 (Lemminkäinen's hunt) |
| 20:00 | **Iku-Turso** | Rises from frozen lakes; the ice breaks into open water | Kalevala 42 (Turso rises against the ship; Väinämöinen lifts him by the ears) |
| 30:00 | **Louhi** | Steals the sun and moon (a darkness phase); in phase 3 becomes a giant eagle | Kalevala 43 (the eagle), 47 (she hides the sun and moon) |

**Local gods (from the design; the design asked for sources)**
| God | Element | Shrine | Summon | Source (suggested) |
| --- | --- | --- | --- | --- |
| Ukko | Lightning | Trial: Duel | **Thunder Axe:** strikes on the densest crowds | The Kalevala (the chief god, called on throughout); Mikael Agricola's list of Finnish gods (1551) |
| Ilmatar | Wind | Peaceful | **World Egg:** a shell that blocks every shot for 4 s | Kalevala 1 (the air-maiden; the teal's eggs on her knee become the world) |

**Hero:** none new. Väinämöinen is already the Finnish Hero; banter can link him to Louhi, Ukko and Ilmatar (his mother
in runo 1).

---

## Level 10: Mazandaran (Persian, the Shahnameh): **done and released 10/31/2026 (00.02.72)**

**Look:** mountain forests, caves, the ruined palaces of the divs.
*Source: Ferdowsi, the Shahnameh: the Seven Labours of Rostam (Haft Khan).*
**Care:** no Persian gods are used (Zoroastrianism is a living religion). Mazandaran's shrines draw gods from the other
pantheons, and its own summon is the **Simurgh**, the great bird who protects Rostam's family, as the design says.

**Hazard: sorcerous darkness.** Clouds of the divs' darkness drift over the field (the darkness hazard, in patches).

**Monster families**
| Family | What it does | Source |
| --- | --- | --- |
| Divs | Demons of Mazandaran: brutes | Shahnameh, the Seven Labours |
| Sorcerers | Casters | Shahnameh (the sorcery of Mazandaran) |
| Wild lions | Fast, hard-hitting chasers | Shahnameh, first labour (Rakhsh kills the lion) |
| Dragon-kin | Fire-breathing flyers | Shahnameh, third labour (the dragon) |

**Bosses (from the design)**
| Time | Boss | Mechanic | Source |
| --- | --- | --- | --- |
| 10:00 | **The Dragon of the Third Labour** | Hides in darkness; seen only in light (the Simurgh or Holy) | Third labour |
| 20:00 | **The Witch of the Fourth Labour** | Disguised as a harmless traveller among decoys | Fourth labour |
| 30:00 | **The White Div** | A cave arena; the ground cracks into pits; huge boulders | Seventh labour |

**The Simurgh (from the design):** no shrine. Elites drop feathers; with 3 collected, burn one to call her, as Zal was
given her feathers. **Healing Wings:** a full heal and a wind that clears enemy shots.

**Hero (suggestion): Rostam**, with his horse **Rakhsh** as a companion (the design's Legend Trait idea), a heavy mace
and bow. Unlock: defeat the White Div (his seventh labour).

---

## Level 11: The Slavic Wilds (Slavic): **done and released 10/31/2026 (00.02.73)**

**Look:** birch forests, rivers, wooden villages, swamps.
*Sources: Afanasyev's Russian Fairy Tales (1855–1863); the byliny (Dobrynya and the Serpent); the Russian Primary
Chronicle (for Perun and Mokosh).*

**Hazard: wandering lights.** Will-o'-wisp lights drift about and lure monsters to them; in the design they also
briefly confuse your controls (see question 4).

**Monster families**
| Family | What it does | Source |
| --- | --- | --- |
| Leshy-kin | Forest spirits that lead you astray | Afanasyev (the leshy) |
| Rusalki | Water casters by rivers and swamps | Slavic folklore (the rusalka) |
| Wolves | Packs | Afanasyev (the grey wolf) |
| Firebird-kin | Burning flyers | Afanasyev, "Tsarevich Ivan, the Firebird and the Grey Wolf" |

**Bosses (from the design)**
| Time | Boss | Mechanic | Source |
| --- | --- | --- | --- |
| 10:00 | **Zmey Gorynych** | Three heads; a cut-off head regrows unless finished with Fire or Holy | The byliny (Dobrynya Nikitich and the Serpent) |
| 20:00 | **Baba Yaga** | Flies in her mortar; her hut on chicken legs stomps round the arena | Afanasyev ("Vasilisa the Beautiful") |
| 30:00 | **Koschei the Deathless** | Can't die until his needle is found: a glowing egg appears on the map; break it | Afanasyev ("The Death of Koschei the Deathless") |

**Local gods (from the design)**
| God | Element | Shrine | Summon | Source |
| --- | --- | --- | --- | --- |
| Perun | Lightning | Trial: Duel | **Thunder Against the Serpent:** a huge strike on the strongest enemy; double against dragons and serpents | Russian Primary Chronicle (Vladimir's gods, 980) |
| Mokosh | Earth | Peaceful | **Spindle of Fate:** threads bind enemies; Luck doubled for 10 s | Russian Primary Chronicle (980) |

Little is known of Perun and Mokosh beyond their names and a few lines; their game text stays light, as with Cernunnos.

**Hero:** none on the design's list for Slavic legend (the design's playable traditions don't include it yet).

---

## Level 12: The Land of Legends (Japanese historical legend): **done and released 10/31/2026 (00.02.74)**

**Look:** the outer paths of mountain shrines, bamboo groves, castle ruins.
*Sources: the Gikeiki (Yoshitsune and Benkei); the Tsuchigumo Sōshi scroll and the Ōeyama tale (Minamoto no Raikō).*
**Care:** no kami are used (Shinto is a living religion, Tier B). Shrines here draw gods from every pantheon. Shrine
buildings stay "outer paths", never the sacred inner places, as the design's look says.

**Hazard: blossom storms.** Falling cherry blossom thickens and the view shrinks (the darkness hazard's vision ring, in
pink).

**Monster families**
| Family | What it does | Source |
| --- | --- | --- |
| Oni | Brutes with iron clubs | The Ōeyama tale (Shuten-dōji's band) |
| Tengu-kin | Fast mountain flyers | The Gikeiki (the tengu of Mount Kurama who taught Yoshitsune) |
| Earth spiders | Swarms that web | The Tsuchigumo Sōshi |
| Restless warriors | Armoured chasers and archers | The war tales of the Genpei era |

**Bosses (from the design)**
| Time | Boss | Mechanic | Source |
| --- | --- | --- | --- |
| 10:00 | **Tsuchigumo** | Webs root Heroes; Fire burns the webs | Tsuchigumo Sōshi (Raikō and the earth spider) |
| 20:00 | **Benkei** | Fights on a narrow bridge; a very tough "standing death" last phase. Defeat unlocks him | The Gikeiki (the Gojō Bridge duel); his standing death at Koromogawa |
| 30:00 | **Shuten-dōji** | Drunken, unpredictable patterns; calls oni bands; Water hits slow him (made drunk, as in the tale) | The Ōeyama tale |

**Heroes (from the design):**
- **Benkei**, unlocked by defeating him (as the design says). Naginata; Legend Trait: stands his ground, stronger while
  surrounded.
- **Minamoto no Yoshitsune (suggestion)**. Sword; Legend Trait: extreme agility (a double dodge). Unlock (suggestion):
  survive 30:00 in the Land of Legends.

---

## Also in Pack 3
- **Resonances (suggestion):** Perun + Mokosh (the design's example), Ukko + Ilmatar (both of the Kalevala), and Ukko +
  Poseidon (the design's elemental example). The Simurgh is not a god, so she has no pair.
- **Achievements and secrets:** a boss achievement for each new boss; two secrets per level, designed with the owner,
  as in Pack 2.
- **Banter:** where the myths meet, e.g. Väinämöinen and Louhi, Rostam and the White Div, Benkei and Yoshitsune,
  Tomoe Gozen in the Land of Legends (she fought in the same war).
- **Lore check:** everything new goes on `docs/LORE_CHECK.md`.

## Questions for the owner
1. **Plan:** does the plan look right? Build in this order, one level at a time?
2. **Unlocks and difficulty:** open each level from a Pack 2 30:00 boss as in the table, and make Pack 3 harder
   (+40% HP, +25% spawns, +20% damage)?
3. **Heroes:** Rostam (unlock: beat the White Div), Benkei (unlock: beat him), and Yoshitsune (unlock: survive 30:00
   in the Land of Legends)? Or a different choice from the design's list (Gordafarid, Arash the Archer)?
4. **The wandering lights:** keep the design's "briefly confuse your controls" in the Slavic Wilds, or only let the
   lights lure monsters? (Reversed controls can be very frustrating on phones.)
5. **Gods and monsters:** use the suggested sources for Ukko and Ilmatar, and the two suggested Pohjola monsters
   (vipers of the snake field, frost wisps) in place of the unsourced "swamp beasts"?
