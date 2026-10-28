# MYTHRIVEN

**Every legend has a breaking point.**

*A mythology-inspired, top-down roguelike survivor where legendary heroes make their last stand against an endless tide of chaos.*

[![Web build](https://github.com/Zephino/Mythriven/actions/workflows/web.yml/badge.svg)](https://github.com/Zephino/Mythriven/actions/workflows/web.yml)
![Godot](https://img.shields.io/badge/Engine-Godot%204-blue)
![Development](https://img.shields.io/badge/Status-Early%20Development-orange)
![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-lightgrey)

**[Web development build](https://zephino.github.io/Mythriven/)** · **[Game design](GAME_DESIGN.md)** · **[Report an issue](https://github.com/Zephino/Mythriven/issues)**

> **Work in progress:** Mythriven is an early prototype, not a finished or released game. The web link is a debug/development build and depends on GitHub Pages being enabled and successfully deployed. Features described as *planned* below are not necessarily playable yet.

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

Mythriven is being built in **Godot 4**, using **GDScript**. The current repository contains an early single-player combat prototype.

| Area | Status |
| --- | --- |
| Keyboard/gamepad/touch movement | Implemented in prototype |
| Procedural terrain and endless chunk system | Implemented in prototype |
| Enemy spawning, pooled enemies, and combat | Implemented in prototype |
| Automatic weapons, damage effects, and targeting | Implemented in prototype |
| Experience pickups, leveling, HUD, and death screen | Implemented in prototype |
| Playable hero roster and legend abilities | Planned |
| God shrines, trials, blessings, and summons | Planned |
| Divine Resonance and elemental reactions | Planned |
| Regional bosses and additional mythic worlds | Planned |
| Permanent progression and unlocks | Planned |
| Online co-op for up to four players | Planned |

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
- **Targets:** PC and mobile; a web debug build is provided through GitHub Actions
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

## Roadmap

**Current focus:** Polish the core combat loop until surviving, dodging, and leveling up feels great.

**Next:** Elemental combat, selectable heroes, mythic enemies, divine shrines, God summons, and Divine Resonance.

**Later:** Multi-phase bosses, region-specific content, permanent progression, UI/art/audio polish, mobile optimization, and co-op.

See [the detailed 20-phase plan](GAME_DESIGN.md#build-phases) for the intended development order.

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
