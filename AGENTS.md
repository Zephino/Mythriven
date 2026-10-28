# Mythriven — shared AI coding rules

Applies to Cursor, local Claude Code, and Claude Code cloud. Read `GAME_DESIGN.md`, `docs/BUILD_PLAN.md`, `docs/PROGRESS.md`, `docs/DECISIONS.md`, `docs/HANDOFF.md`, and `docs/AI_WORKFLOW.md` before work.

- The owner approves game-design changes. Build only the current Pack 1 phase; do not invent lore, names, or features.
- Existing design, cultural, performance, and persistence rules take priority over coding convenience.
- Use a dedicated `agent/<tool>/<task>` branch per task. Never force-push or commit directly to main.
- Inspect git status and current branch before modifying files. Preserve unrelated changes.
- Do not edit the same working tree concurrently with another agent.
- Validate changes using the project's actual available tests. Never claim visual or gameplay testing from headless checks.
- Before handoff, update `docs/AI_STATUS.md` with branch, commit, task, changes, tests, blockers, and next action.
- Do not commit secrets, credentials, or generated Godot caches.
- Open a pull request for review; never auto-merge.
