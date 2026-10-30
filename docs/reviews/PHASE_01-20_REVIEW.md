# Review — Pack 1, Phases 1–20

Reviewer: Claude Code (cloud) · Date: 10/29/2026 · Version reviewed: 00.01.33 (commit 616b002)

## How this review was done

- No phase had been reviewed or tagged yet, so this covers all 20 phases against the **Done when** lists in `docs/BUILD_PLAN.md` and the matching sections of `GAME_DESIGN.md`.
- **Automated tests:** 234 Godot tests (GUT) and 40 Worker tests, all passing. Almost every Done-when item has its own test (named below).
- **Rules checked:** every script is under 300 lines; no on-screen text is typed into the code (it all comes from `localization/text.csv`); enemies, damage numbers, orbs, and effects use pools; the release content gate is in place; the game runs and is checked by CI on every push.
- **Played by the owner (10/29/2026):** co-op between a PC and a phone ("a lot of fun"), and the game on phones ("it works").
- **Not measured by Claude:** frame rate (60 FPS) and memory. The cloud computer has no screen or graphics card, so those Done-when items rest on the owner's own play on PC and phone, where no slowdowns were reported.

## Verdict

**Approved with fixes.** Phases 1–18 and 20 are done. Phase 19 (Polish) is done except three parts the owner has chosen to do later: art, audio, and the lore sign-off. None of the fixes below blocks playing or testing. They are bookkeeping, plus one item to decide.

| Phase | Verdict | Evidence / notes |
| --- | --- | --- |
| 1 Project setup | Approved | `test_missing_field_names_file_and_field`, `test_release_refuses_tier_b_and_unverified`, `test_same_seed_gives_same_sequence_for_every_stream`; F1 debug menu with FPS; pseudo-localization toggle in the debug menu. The only warnings on startup are the intended "loaded for testing" lore warnings (see Notes). |
| 2 Player movement | Approved | `test_diagonal_is_not_faster_than_straight`, `test_players_are_a_list`. The joystick became whole-screen by owner decision (00.01.24): `test_whole_screen_joystick_starts_anywhere_but_on_a_button`. |
| 3 Endless map | Approved | `test_same_seed_gives_same_ground`, `test_same_seed_gives_same_decorations`, `test_world_to_chunk_respects_origin_shift`. 60 FPS and flat memory: owner play. |
| 4 Enemies core | Approved | `test_pool_never_exceeds_cap_and_reuses_slots`, `test_overlapping_enemies_are_pushed_apart`, `test_contact_damage_once_per_interval_without_iframes`, `test_standing_still_surrounded_kills_the_player`. 500 enemies at 60 FPS: owner play. |
| 5 Weapons and targeting | Approved | `test_club_hits_enemy_behind_while_running_away`, `test_full_order_of_operations`, `test_damage_numbers_pool_does_not_grow`. |
| 6 XP and level-ups | Approved | `test_pickup_chain_climbs_caps_and_resets`, `test_pickup_chain_rate_limit`, `test_maxed_items_are_never_offered_and_maxed_builds_get_gold_and_heal`, `test_smart_auto_collect_heals_when_low`, `test_run_log_has_time_cause_and_build`. |
| 7 Fun checkpoint | Approved | The owner says it's fun (10/29/2026). Tuning notes are in `docs/PROGRESS.md`. |
| 8 Elements | Approved | One test per status and reaction (`test_conduct_chains_…`, `test_steam_burst_melts_ice`, `test_shatter_…`), `test_reaction_budget_caps_reactions_per_second`, `test_players_only_get_statuses_from_30_minutes_at_half_duration`. |
| 9 Heroes | Approved | `test_heroes_play_differently`, `test_expertise_only_for_expert_categories_not_the_start_weapon`, `test_expert_badge_on_level_up_cards`, `test_labors_progress_and_reward`. |
| 10 Aegean waves, elites, chests | Approved | `test_a_run_plays_through_every_age`, `test_a_ready_weapon_evolves_at_the_next_chest_and_joins_the_codex`, elite modifier tests. The Aegean enemies were changed to Greek creatures by owner decision (`test_the_aegean_shore_only_spawns_greek_creatures`). |
| 11 Gods | Approved | `test_all_eight_launch_gods_load_with_a_trigger_and_summon`, `test_each_trial_can_be_won_and_failed`, `test_both_god_buttons_work_independently`. |
| 12 Resonance and infusions | Approved | `test_resonance_needs_a_compatible_pair_and_both_meters_full`, `test_infused_weapon_names_build_automatically`. |
| 13 Aegean bosses | Approved | `test_every_attack_pattern_is_telegraphed_before_it_hurts`, `test_defeating_achilles_unlocks_him_and_saves_at_once`, `test_bosses_spawn_on_time_even_if_the_last_is_alive`. The Aegean Shore works as a complete vertical slice. |
| 14 World discoveries | Approved | `test_the_same_seed_always_places_the_same_pois`, `test_trader_purchases_reduce_run_gold_and_prices_rise_each_age`. |
| 15 Meta and saving | Approved with fixes | `test_force_closing_never_loses_an_unlock`, `test_quitting_before_and_after_5_00_banks_the_right_gold`, `test_the_death_recap_shows_a_relevant_tip_…`. **Missing:** the Steam Cloud backup (fix 1). |
| 16 Midgard's Edge | Approved | `test_every_level_plays_through_its_bosses`, `test_the_blizzard_pushes_and_veils_then_pauses_in_a_boss_arena`, Fenrir/Loki/Surtr tests. |
| 17 The Two Lands | Approved | Ammit/Set/Apep tests, quicksand test, hazard pause test (shared). |
| 18 The Misty Isles | Approved | Scáthach/Ferdiad/Balor tests, fairy rings test. |
| 19 Polish | Approved for what's built | Settings, tips, safe areas, and exports are done and tested (`test_polish.gd`). Phone test passed (owner). **Waiting on the owner, by choice:** art, audio, lore sign-off. |
| 20 Co-op and cloud saves | Approved | `test_coop.gd` (14 tests), `test_online.gd`. The Worker tests and a real PC + phone game by the owner both pass. Cloudflare replaced Epic Online Services (owner decision, 00.01.25). Public Games and joining a game in progress (00.01.32) come from the post-launch "quick-play" idea, and the owner asked for them. |

## Fix list

1. **Steam Cloud backup (Phase 15) isn't built.** The design asks for it as a local backup on Steam. There's no Steam version of the game yet, so there's nothing to back up to. Either build it when a Steam export is made, or remove it from Phase 15. Owner decision 2 below.
2. **`docs/BUILD_PLAN.md` still has every Done-when box unticked, and Phase 20 still names Epic Online Services.** If the owner agrees (decision 3), tick the boxes listed above as approved and change Phase 20 to "the owner's Cloudflare Worker".
3. **`docs/PROGRESS.md` header is out of date.** It still says Phase 20 is "built (00.01.25)" and "Last reviewed with Claude: (not yet)". Update it to this review. *(Done with this review.)*

## Decisions for the owner

1. Tag Pack 1 as approved? (The command to run on your computer is: `git tag phase-20-approved && git push origin phase-20-approved`.) Yes / no
2. Leave the Steam Cloud backup until a Steam version exists? Yes / no
3. Update `docs/BUILD_PLAN.md`: tick the approved boxes and change Phase 20's online service to Cloudflare? Yes / no
4. Players who join a public game mid-run start with only their signature weapon. Give them a few free level-up picks to catch up? Yes / no
5. Allow joining mid-run in friend-code games too (today only public games allow it)? Yes / no

## Owner answers (10/30/2026)

1. Pack 1 approved: **yes** (tag `phase-20-approved`).
2. Steam Cloud backup: the owner asked how hard it would be (answered in chat: little code, but it needs the game on Steam first). Still open.
3. Build plan update: the owner didn't follow the question; asked again in plain words. Still open.
4. Catch-up for players who join mid-run: **yes**, as one chest of upgrades per 5 minutes played (built in 00.01.35; numbers to tune).
5. Joining mid-run in friend-code games: **yes** (built in 00.01.35).

## Notes for later

- **Release builds stay locked until the lore sign-off.** All 9 Heroes, 8 gods, and 12 bosses still have `lore_verified: false`, so a **release** export would refuse every one of them and the game would have nothing to play. That's how the content gate is meant to work. The web link and test builds are debug builds, so they're unaffected. Do the lore sign-off (`docs/LORE_CHECK.md`) before any public release.
- **Art and audio are still placeholders.** That's fine until the owner is ready, but every new pack adds more placeholder art to replace later. Choosing an art direction before Pack 2 would save redoing work.
- **Open decisions** in `docs/DECISIONS.md` (numbers 3, 10, 11, tip placement, and the Phase 20 items) are still waiting; none blocks Pack 2 planning.
- **Co-op watch list:** the public-games list depends on the Cloudflare Worker's newest deployment (migration v3). If Public Games ever says it can't get the list, check that deployment first.
- **No problems found** with invented names, cultural rules, or IP in the code reviewed. The names in data come from `GAME_DESIGN.md`, which still has to pass the lore sign-off.
