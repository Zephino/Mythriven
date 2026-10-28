# Changelog

One entry per change request, newest first (see `.cursor/rules/changelog.mdc`). The version here always matches `VERSION`. Work from before this changelog existed (versions 00.01.00–00.01.05: Phases 1–6 and the web link) is logged in `docs/PROGRESS.md`.

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
