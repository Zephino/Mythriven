# Mythriven — shared AI coding rules

Applies to Cursor, local Claude Code, and Claude Code cloud. Read `GAME_DESIGN.md`, `docs/BUILD_PLAN.md`, `docs/PROGRESS.md`, `docs/DECISIONS.md`, `docs/HANDOFF.md`, and `docs/AI_WORKFLOW.md` before work.

- The owner approves game-design changes. Build only the current Pack 1 phase; do not invent lore, names, or features.
- Existing design, cultural, performance, and persistence rules take priority over coding convenience.
- **Owner rule (10/29/2026): commit and push straight to `main`.** No feature branches and no pull requests until the owner says otherwise; GitHub keeps only the `main` and `data` branches. Never force-push, and run the tests before every push.
- Inspect git status and current branch before modifying files. Preserve unrelated changes.
- Do not edit the same working tree concurrently with another agent.
- Validate changes using the project's actual available tests. Never claim visual or gameplay testing from headless checks.
- Before handoff, update `docs/AI_STATUS.md` with branch, commit, task, changes, tests, blockers, and next action.
- Do not commit secrets, credentials, or generated Godot caches.
- Push finished, tested work to `main` (owner rule above); never force-push.

## Mandatory Cursor rule parity for Claude Code

Before **every** implementation, review, or refactor task, Claude (local and cloud) MUST:
1. Enumerate every tracked file under `.cursor/rules/` (for example, `git ls-files '.cursor/rules/*'`), read the complete contents of each applicable rule, and apply them to the task. Do not assume `.mdc` frontmatter is automatically processed by Claude.
2. Treat `alwaysApply: true` as unconditional. For `globs` or path-scoped rules, match the files being touched; when scope is ambiguous, read and apply the rule conservatively. For manually attached/agent-requested rules, ask the owner if applicability is unclear.
3. Preserve every Cursor rule's substantive requirements; don't summarize away constraints. If any rule cannot be accessed or conflicts with another, STOP and ask the owner instead of silently proceeding.
4. Recheck applicable rules before submitting the PR, record compliance and any exceptions in `docs/AI_STATUS.md`.
5. Never weaken or edit `.cursor/rules/` merely to complete a task. Only the owner can authorize rule changes.

This is an explicit instruction to Claude, not a guarantee of automatic rule discovery by Claude Code.
