# Changelog

One entry per change request, newest first (see `.cursor/rules/changelog.mdc`). The version here always matches `VERSION`. Work from before this changelog existed (versions 00.01.00–00.01.05: Phases 1–6 and the web link) is logged in `docs/PROGRESS.md`.

## Version 00.01.10
Date: 10/28/2026
Time: 4:29 PM

### Changes
- README: added "What you can play right now" (current weapons, passives, level-ups, Ambrosia), a controls table for PC, gamepad, and phones (including the debug menu), a phase-by-phase status table for all 20 phases showing Phase 7 as current, and a table linking the project documents. Kept the existing look, play link, and license section.
- Bumped the version to 00.01.10.

### Reason
The owner asked for a better README on GitHub and a reminder of all the phases.

## Version 00.01.09
Date: 10/28/2026
Time: 4:06 PM

### Changes
- Phones and tablets now show everything 1.5× bigger than PC (menus, HUD, buttons, text, joystick, and the game world), on top of the normal screen scaling. Setting: `ui.handheld_scale` in `data/config.json`.
- New healing item, **Ambrosia** (from the design's special pickups): each kill has a 2% chance to drop one; it heals 30 HP and flies to you like an XP orb, but only when you're hurt. Debug menu: "Drop an Ambrosia".
- Eased the placeholder difficulty: placeholder chasers now deal 3 contact damage (was 5), swarm enemies 2 (was 3), and enemies spawn 1.5 per second (was 2).
- New automated test for Ambrosia; bumped the version to 00.01.09.

### Reason
The owner wanted bigger windows on mobile and found it very hard to get past level 1–2 without any way to heal.

## Version 00.01.08
Date: 10/28/2026
Time: 2:03 PM

### Changes
- The game now has a fixed design size (1152×648) and scales everything (menus, HUD, buttons, text, the joystick, and the game world) to fit the screen, keeping the full width or height visible and showing a little more on wider or taller screens.
- New `SafeArea` helper so the touch joystick and the debug menu stay clear of phone notches after scaling.
- Bumped the version to 00.01.08.

### Reason
The owner found the windows too small on mobile: the game was drawn at the phone's full pixel resolution with nothing scaled up.

## Version 00.01.07
Date: 10/28/2026
Time: 8:02 AM

### Changes
- Added `LICENSE`: the same proprietary "All Rights Reserved" copyright as WaveDefence (Copyright (c) 2026 Zephino), pointing to the Zephino/Mythriven repo, with a note that third-party add-ons keep their own licenses.
- Added the license line and the `LICENSE` file to `START_HERE.md`.
- Re-ran the web build now that the repository is public.
- Bumped the version to 00.01.07.

### Reason
The owner made the repository public so the game can have a free GitHub Pages link, and asked to use the same copyright as WaveDefence.

## Version 00.01.06
Date: 10/28/2026
Time: 2:29 AM

### Changes
- Added the changelog rule as `.cursor/rules/changelog.mdc` (always applies).
- Created this `CHANGELOG.md`.
- Added an automated test that checks the newest changelog entry matches `VERSION`.
- Bumped the version to 00.01.06 in `VERSION` and `project.godot`.
- Fixed two bugs found by the first real Godot run on GitHub: the touch joystick class was renamed from `VirtualJoystick` to `TouchJoystick` (Godot 4.7 added a built-in class with that name), and `RunState` no longer declares `level` twice (the level's data is now `level_data`).

### Reason
The owner asked for every change request to be recorded with its version, date, time, what changed, and why. The bug fixes were needed because the GitHub web build couldn't compile the game, which stopped the playable link from being published.
