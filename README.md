# Mythriven data branch

This branch holds only the shared leaderboard, `leaderboard.json`. It is
written automatically by the leaderboard service (`leaderboard-api/` on the
`main` branch) whenever a player submits a score that makes the top 100.

Please don't edit it by hand: the service keeps its own copy and overwrites
this file on the next score. The game itself lives on `main`.
