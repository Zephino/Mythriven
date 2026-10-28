# Cursor ↔ Claude Code workflow

## Modes
- **Reviewer:** Claude follows existing `CLAUDE.md` reviewer-only restrictions.
- **Developer:** Only when the owner explicitly requests Claude to implement code on a dedicated feature branch. Update `CLAUDE.md` to allow this mode before using Claude as a developer; existing reviewer-only instructions otherwise still apply.

## Local handoff
1. `git status` and confirm current task/branch.
2. Save all work safely: commit and push on a feature branch (never blindly discard or stash unknown work).
3. Update `docs/AI_STATUS.md` on that branch and push.
4. Next agent fetches, checks out the correct branch, reads design/rules/status, and resumes.
5. Only one agent edits a given local worktree at a time. Separate git worktrees for parallel local tasks.

## Cloud handoff
1. Push the feature branch to GitHub.
2. In Claude Code web, connect GitHub and choose the Mythriven repo.
3. Ask Claude to inspect the branch, `AGENTS.md`, `CLAUDE.md`, and `docs/AI_STATUS.md` before working.
4. Cloud sessions may use isolated branches; have Claude create a PR against the intended base and check the diff before merging.
5. On return to Cursor: fetch, review PR, merge only after approval and checks, then pull.

## Safety
- No concurrent edits to scenes, resources, scripts or project settings on one branch.
- Inspect conflicts manually, especially `.tscn`, `.tres`, `project.godot`.
- Run available Godot headless import/parse checks if Godot is installed; separately test gameplay and visuals locally.
- Don't overwrite `docs/HANDOFF.md`: it contains historical design context, not live agent status.
- Keep AI usage quotas and chats separate; no automatic quota-triggered switching is assumed.
