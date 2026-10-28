# Changelog

One entry per change request, newest first (see `.cursor/rules/changelog.mdc`). The version here always matches `VERSION`. Work from before this changelog existed (versions 00.01.00–00.01.05: Phases 1–6 and the web link) is logged in `docs/PROGRESS.md`.

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
