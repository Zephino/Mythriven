# World plan: forests, rocks, critters, hidden groves and mountains

Status: **approved by the owner and built** (10/31/2026; versions 00.02.32 to 00.02.35). The agreed parts are in
`GAME_DESIGN.md` with dated notes. Open questions were settled with Claude's suggestions: rarities as below, the rope is
only for climbing, large animals in every level.

Everything is drawn in the world's weathered style (`tools/art/weathering.py`) and generated at random from the run's
seed, so every co-op player sees the same world.

---

## 1. Trees, rocks and bushes

### Kinds, per level (real plants and stone of each land)

| Level | Trees (block) | Bushes (walk over) | Rocks |
| --- | --- | --- | --- |
| Aegean Shore | olive, cypress, Aleppo pine, holm oak | myrtle, rosemary, oleander | pale limestone |
| Midgard's Edge | spruce, Scots pine, birch | juniper, bilberry, fern | grey granite, mossy |
| The Two Lands | date palm, doum palm, acacia, sycamore fig | tamarisk, papyrus clump, desert scrub | sandstone |
| The Misty Isles | oak, ash, rowan, yew, hawthorn | gorse, heather, bramble | dark granite, lichen |

- **Sizes:** each tree and rock kind comes in small, medium and large (a few drawings each, so no two look alike).
- **Density:** a smooth noise map over the world makes open fields, light woods and thick forest. Thick forest
  always has gaps you can get through; it never walls a Hero in.
- **Kept clear:** the start of a run, boss arenas, shrines, points of interest and their surroundings.

### What blocks what

| Thing | Heroes | Walking monsters | Flying monsters |
| --- | --- | --- | --- |
| Trees | blocked | blocked (slide round) | fly over |
| Big boulders | blocked | blocked (slide round) | fly over |
| Small stones | slowed a little | slowed a little | not slowed |
| Pebbles, bushes | nothing (walk over) | nothing | nothing |

- Heroes and monsters slide along trees and boulders instead of sticking.
- **No hiding in the woods:** when the Hero is sheltered by trees, new monsters spawn on the side that is open to them,
  so forests are cover, not a safe place. (The spawner checks each spawn point can reach the Hero.)
- Shots and weapons pass through trees (only movement is blocked), so fights stay readable.
- Performance: trees and boulders go in the same spatial grid the enemies use, checked only near each mover.

---

## 2. Critters

| Level | Small (can't be hurt, flee from you) | Birds | Insects | Large (can be hurt) |
| --- | --- | --- | --- | --- |
| Aegean Shore | hare, wall lizard, tortoise | sparrows, gulls by the sea | butterflies, cicadas | wild goat, deer |
| Midgard's Edge | red squirrel, mountain hare, fox | ravens, ptarmigan | (few) | reindeer, elk |
| The Two Lands | jerboa, desert lizard | ibis, sparrows | butterflies, dragonflies by the Nile | gazelle, ibex |
| The Misty Isles | hedgehog, hare, frog by the bog | wren, robin | butterflies, fireflies at night | red deer |

- **Small critters, birds and insects** are only for looks: they can't be hurt, do no damage and nothing hits them.
  They wander, and scatter or fly off when a Hero comes near.
- **Large animals** can be hurt. They don't fight back; they run. When killed they're more likely than monsters to
  drop healing (ambrosia) and give less XP.
- **A cap on screen** (a setting, about 12 critters and 2 large animals) so they never cause lag. They're pooled,
  appear just off screen, and leave when far away. None appear during boss fights.

---

## 3. Hidden groves

- Some thick clumps of trees hide a **clearing** inside. From outside they look like ordinary forest, with a small
  hint: a gap that's slightly wider, a different tree, a bird that flies out, or a glint.
- Those trees **let you walk in**. As a Hero enters, the trees round them fade, and the hidden clearing comes into view.
  Walking out, the forest closes over it again.
- **What's inside** (random): a treasure chest (sometimes a big one), or rarely a **hidden shrine** (below).
- **Challenging to reach:** the way in winds through the trees, and the clearing is guarded (an elite or a pack of
  the level's monsters waits inside).

### The hidden shrine: a third god slot

- Binding at the hidden shrine gives the Hero a **third god slot for this run**: a third god button appears, and they
  can hold three gods instead of two. It ends with the run.
- It's rare, and well guarded. Getting it is a goal worth chasing in a run.
- The god there is chosen like any shrine's (it can be an uncommon or rare one). Co-op: each player who binds there
  gets their own third slot.

---

## 4. Mountains, climbing and caves

- Now and then (rarely), a **mountain**: raised ground ringed by **cliff walls** you can't walk through. On top is a
  **cave** with treasure (a big chest and gold; it could also hold a hidden shrine).
- **Ways up:**
  - **Climbing spots** (handholds and cracks in the rock): free, but you climb slowly and can't attack while climbing.
  - **Rope ladder spots:** need a **rope**, used up when you hang the ladder (then the ladder stays for everyone).
  - **Rope bridges** span gaps between peaks; some are broken and need a rope to fix.
- **Rope:** bought from the Wandering Trader with run gold, or sometimes found in chests. Shown on the HUD.
- **Levels:** you climb from the ground to a ledge, and maybe to a higher ledge, then over a bridge to the cave peak.
- **Monsters:** walking monsters can't climb cliffs (they come up the same ways you do, or spawn on top); flyers can
  reach you anywhere.
- **Sprites needed:** cliff faces and edges (corners, straight runs, for each land's rock), raised ground tops, climbing
  handholds, a hanging rope ladder (rolled and hung), rope bridge pieces (posts, planks, ropes, broken), a cave mouth,
  and the cave's inside (it uses the dungeon generator with a cave set: rock walls, dirt floor, stalagmites, a pool).

---

## Order to build (each step shown to the owner before the next)

1. **Trees, rocks and bushes:** drawings (kinds × sizes, per level), density map, blocking and sliding, open-side
   spawning, kept-clear areas. Replaces the old decorations.
2. **Critters:** drawings and wandering, fleeing, the cap; large animals that can be hurt and drop healing.
3. **Hidden groves:** walk-in trees, fading canopy, clearing, guards, chests.
4. **Hidden shrine and the third god slot.**
5. **Mountains:** cliffs, climbing spots, rope ladders and bridges, the rope (Trader and chests), the cave.

Each step also gets: tests, settings in `config.json`, rules in `docs/ART_RULES.md`, a changelog entry, and
screenshots.

## Questions still open

- How rare should hidden groves, hidden shrines and mountains be? (Suggestion: a hidden grove every few screens of
  forest; a hidden shrine at most once a run; a mountain every 3-5 minutes of walking.)
- Should the rope also be used for anything else (for example, climbing out of a pit trap)?
- Large animals: should they appear in every level, or only some?

Then the menu redesign (agreed in `docs/DECISIONS.md`) follows.
