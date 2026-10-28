# MYTHRIVEN

**Every legend has a breaking point.**

*A mythology-inspired, top-down roguelike survivor where legendary heroes make their last stand against an endless tide of chaos.*

[![Web build](https://github.com/Zephino/Mythriven/actions/workflows/web.yml/badge.svg)](https://github.com/Zephino/Mythriven/actions/workflows/web.yml)
![Godot](https://img.shields.io/badge/Engine-Godot%204-blue)
![Development](https://img.shields.io/badge/Status-Early%20Development-orange)
![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-lightgrey)

## 🎮 Play Mythriven Online

### **[▶ PLAY MYTHRIVEN — OPEN THE GAME](https://zephino.github.io/Mythriven/)**

**Direct game link:** https://zephino.github.io/Mythriven/

*Browser-based development build — no installation needed. Works when the latest GitHub Pages deployment is available.*

[![Play Mythriven](https://img.shields.io/badge/PLAY-MYTHRIVEN-brightgreen?style=for-the-badge)](https://zephino.github.io/Mythriven/)

**[Game design](GAME_DESIGN.md)** · **[Report an issue](https://github.com/Zephino/Mythriven/issues)**

> **Work in progress:** Mythriven is an early prototype, not a finished or released game. The web link is a debug/development build and depends on GitHub Pages being enabled and successfully deployed. Features described as *planned* below are not necessarily playable yet.

## What you can play right now

The current build covers **Phases 1–6** of the plan, plus early Phase 7 tuning:

- **The Aegean Shore**, an endless procedurally generated map with olive groves and marble ruins (placeholder art).
- **Heracles' Great Club** as your starting weapon. It aims itself at the nearest enemy, and every fourth slam sends out a quake.
- **Two more weapons** to find on level-up: the **Throwing Axe** and the **Bladed Discus**. Every weapon has 8 levels.
- **Nine passives** from mythic objects (Belt of Strength, Winged Sandals, Hourglass, Seer's Eye, Lodestone, Bronze Aegis, Ferryman's Coin, Golden Apple, Votive Bell), each with 5 levels.
- **XP orbs and level-ups**: choose 1 of 3 cards (4 with high Luck), save a level-up for later, or let Auto-collect take Gold/Heal when your build is maxed.
- **Ambrosia**, a rare healing drop that restores 30 HP.
- **A swarm that never stops.** Enemies never stack and there are no invulnerability frames, so standing still in a crowd is fatal.

Enemies are simple placeholder circles until the real mythic creatures arrive (Phase 10), and all numbers are early placeholders.

### Controls

| Action | PC | Gamepad | Phone / tablet |
| --- | --- | --- | --- |
| Move (8 directions) | WASD or arrow keys | Left stick or D-pad | Touch and drag on the left half of the screen |
| Open a saved level-up | Tab | Y / Triangle | Tap the level badge (top of the screen) |
| Debug menu (test build) | F1 | — | Tap with three fingers |

Weapons fire on their own. The debug menu has test tools such as god mode, spawning enemies, gaining a level, dropping a healing item, and an FPS counter.

## The world is unraveling

Every myth is a thread in the world's tapestry. Now something called **the Unweaving** is tearing those threads apart.

Legendary heroes are drawn from their stories into **the Crossroads**, where ancient ruins, forgotten monsters, and divine shrines collide. Fight an ever-growing horde, discover the powers of the gods, and survive as long as you can.

**Every run ends. Every run counts.**

## Gameplay

- **Survive the horde.** Move, dodge, and build an increasingly powerful arsenal of automatically attacking weapons.
- **Choose your build.** Collect experience, level up weapons and passives, and discover new combinations.
- **Explore an endless world.** Travel through a procedurally generated landscape that keeps unfolding as you move.
- **Meet heroes from legend.** The planned roster draws on mythological and legendary figures from different cultures, each with a signature fighting style.
- **Earn divine allies.** Planned shrine encounters and trials let you bind gods who provide blessings and powerful summons.
- **Combine divine powers.** Planned **Divine Resonance** rewards specific god pairings with unique effects.
- **Fight mythic threats.** Planned regional bosses, elemental interactions, and challenging attack patterns raise the stakes.
- **Grow between runs.** Planned unlocks, discoveries, and offerings make defeat part of your long-term progression.

## Development status

Mythriven is being built in **Godot 4**, using **GDScript**, one phase at a time from a 20-phase plan.

| Phase | What it adds | Status |
| --- | --- | --- |
| 1. Project setup | Godot project, data loading with clear errors, translations, seeded randomness, debug menu | ✅ Built |
| 2. Player movement | 8-direction movement on keyboard, gamepad, and touch; smooth camera | ✅ Built |
| 3. Endless map | Endless chunked ground with seeded decorations | ✅ Built |
| 4. Enemies core | Up to 500 pooled enemies, no stacking, contact damage, death screen | ✅ Built |
| 5. Weapons and targeting | Great Club, smart targeting, damage formula, damage numbers | ✅ Built |
| 6. XP and level-ups | XP orbs, level-up cards, passives, more weapons, run log | ✅ Built |
| 7. Fun checkpoint | Play and tune until moving and fighting feel great | 🔄 **Now** |
| 8. Elements | 8 elements, statuses, weaknesses, reactions | Planned |
| 9. Heroes | Hero select: Heracles, Cú Chulainn, Väinämöinen, Tomoe Gozen | Planned |
| 10. Aegean waves | Real Aegean enemies, Ages, elites, chests, evolutions | Planned |
| 11. Gods | Shrines, trials, binding, two god buttons, summons | Planned |
| 12. Resonance | Divine Resonances between god pairs, weapon infusions | Planned |
| 13. Aegean bosses | Medusa, Achilles, Kronos; the Aegean Shore becomes a complete slice | Planned |
| 14. World discoveries | Points of interest, compass, Wandering Trader, world events | Planned |
| 15. Meta and saving | Saving, gold, Hall of Legends, unlocks, collections, Swift Mode | Planned |
| 16–18. More regions | Midgard's Edge, The Two Lands, The Misty Isles | Planned |
| 19. Polish | Art, audio, accessibility, mobile, performance, lore checks | Planned |
| 20. Co-op | Online co-op for up to 4 players and cross-platform cloud saves | Planned |

The design targets four launch regions—**Aegean Shore, Midgard's Edge, The Two Lands, and The Misty Isles**—with mythology-inspired heroes, gods, and bosses. Content, timing, and scope may change as development continues.

The full feature plan, design constraints, and implementation phases are documented in **[GAME_DESIGN.md](GAME_DESIGN.md)**.

## Try the development build

### In your browser

Visit **[Mythriven on GitHub Pages](https://zephino.github.io/Mythriven/)** if the latest build is deployed. This is a **debug preview**, not a release build.

### Run locally

1. Install **[Godot 4.7.2](https://godotengine.org/download/)** (the version used by the repository's web-build workflow).
2. Clone the repository:
   ```bash
   git clone https://github.com/Zephino/Mythriven.git
   cd Mythriven
   ```
3. Open Godot, choose **Import**, and select `project.godot`.
4. Open the project and press **F5** to run it.

**Prototype movement:** WASD / arrow keys, gamepad left stick / D-pad, or the touch joystick on supported devices. Additional summon and Resonance controls are part of the planned systems.

## Technology

- **Engine:** Godot 4 / GDScript
- **Visual direction:** Original, colorful 16-bit-inspired pixel art
- **Design:** Data-driven configuration and content in JSON
- **Performance approach:** Object pooling, spatial hashing, and efficient enemy rendering
- **Targets:** PC and mobile; a web debug build is rebuilt and published automatically on every update to `main`
- **Testing:** Automated tests use the [GUT](https://github.com/bitwes/Gut) add-on

To run the automated tests locally with the matching Godot version:

```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json
```

## Project layout

```text
Mythriven/
├── GAME_DESIGN.md      # Design source of truth and roadmap
├── project.godot        # Godot project settings
├── scenes/              # Game scenes
├── scripts/             # Game logic and systems
├── data/                # JSON content and balance settings
├── assets/              # Visual and audio assets
├── localization/        # Translations and text resources
├── tests/               # Automated tests
├── addons/              # Godot add-ons
└── .github/workflows/   # Web build and deployment
```

## Project documents

| Document | What's in it |
| --- | --- |
| [GAME_DESIGN.md](GAME_DESIGN.md) | The full game design, the source of truth |
| [docs/BUILD_PLAN.md](docs/BUILD_PLAN.md) | Each phase's checklist and "done when" tests |
| [docs/PROGRESS.md](docs/PROGRESS.md) | Log of every task finished |
| [CHANGELOG.md](CHANGELOG.md) | Every version: what changed and why |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Choices the design didn't cover, and their approval status |
| [START_HERE.md](START_HERE.md) | How the project is organised and run |

## Mythology and creative direction

Mythriven draws inspiration from historical mythology, folklore, and legend. Its gameplay, visual designs, dialogue, and worldbuilding aim to be original interpretations—not copies of modern adaptations. The project aims to portray its source traditions with care, especially where beliefs are still practiced today.

Mythriven is an independent game and is **not affiliated with, endorsed by, or sponsored by any other game publisher or religious organization**.

## Feedback

Suggestions and bug reports are welcome through [GitHub Issues](https://github.com/Zephino/Mythriven/issues). Please check for an existing issue before opening a duplicate.

## License and credits

**© 2026 Zephino. All rights reserved.**

This repository is **source-available, not open-source**. Viewing the code publicly does **not** grant permission to copy, modify, redistribute, or commercially use the game or its assets. See [LICENSE](LICENSE) for terms and contact information.

Third-party components retain their own licenses. See [CREDITS.md](CREDITS.md) for acknowledgments and license details.

---

*Built with Godot. Inspired by legends. Made to test how long a hero can stand.*
