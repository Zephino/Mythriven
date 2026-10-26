# Prompts to paste into Cursor

Start a **new Cursor chat for each phase** so old conversations don't confuse it.

## Start a phase
```
We are starting Phase [N]: [name] from docs/BUILD_PLAN.md.
Read GAME_DESIGN.md, docs/BUILD_PLAN.md, docs/PROGRESS.md, and docs/DECISIONS.md first.
Build only what Phase [N] lists. Use placeholder shapes for art.
Don't change working code from earlier phases unless you explain why first.
Add debug-menu options to test the new features.
After each task, update docs/PROGRESS.md. When every "Done when" item is complete,
write docs/reports/PHASE_[NN]_REPORT.md from the template, then stop.
```

## Continue a phase (new chat, same phase)
```
Continue Phase [N] from docs/BUILD_PLAN.md. Read docs/PROGRESS.md to see what's done
and what's left, then continue with the next unfinished item.
```

## Fix a bug
```
Bug in Phase [N]: [what you saw, step by step].
Error from Godot's Output panel (if any): [paste it].
Fix only this bug. Don't change anything else. Tell me what caused it and how to test the fix.
Add a line about the fix to docs/PROGRESS.md.
```

## Apply Claude's review
```
Here is the review of the Phase [N] report. Apply every item marked "Fix",
in order. Don't change anything not listed. Update docs/PROGRESS.md,
then update docs/reports/PHASE_[NN]_REPORT.md section 2 and 5.

[paste Claude's fix list]
```

## Check that Cursor is on track (any time)
```
Without changing any code: compare what's built so far with Phase [N] in
docs/BUILD_PLAN.md and the matching sections of GAME_DESIGN.md.
List anything missing, anything built differently, and anything built that
belongs to a later phase.
