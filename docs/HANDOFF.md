# Handoff — the design conversation so far

This file carries over the context from the owner's design conversation with Claude (in the Claude chat app), so a Claude Code session can continue without it. Every decision is already in `GAME_DESIGN.md`; this file adds **how we got there, what was rejected, and what's still open**.

Last updated: 2026-10-26, design version v3.11.

## Who does what

- **Owner:** makes all design decisions. Not a professional programmer; explain things simply.
- **Cursor:** writes the game code, following `.cursor/rules/`.
- **Claude (Code tab):** reviewer. Keeps Cursor on task and checks its work against the design (see `CLAUDE.md`). Doesn't write game code.
- **Claude (Chat):** where the design was created. The owner may still bring design discussions there.

## How the design evolved (so you don't repeat rejected ideas)

1. Started as a Vampire Survivors–style game "like my tower defense game" (which uses Godot) with Final Fantasy–style summons.
2. Owner decided to sell it, so all Final Fantasy names and content were removed; then **dropped Final Fantasy as an inspiration entirely** in favor of world mythology. Never reintroduce FF elements or terms.
3. Mythology version: Heroes from the owner's database are playable characters; gods are summons. Cultural tiers (A/B/C) decide which traditions can be used.
4. Owner asked for a level per mythic region, then **at least 12 levels**, then added **fantasy realms** (40 of them). Total: 54 levels in 13 packs of 4 plus 2 extras. **Only Pack 1 is being built**; more packs only after Pack 1 works.
5. Owner set the **naming rule**: only public-domain names and lore; invent only as a last resort.
6. Owner named the game **Mythriven**.

## Rules the owner set personally (be careful with these)

- Packs of 4 levels; build Pack 1 first.
- Only names and lore that are public domain; never modern adaptations or franchise terms.
- Anything earned in a level that's used outside a level persists, saved the moment it's earned.
- Quitting a run: none of that run's gold before 5:00, 10% after. If the co-op host quits, other players keep 10% even before 5:00.
- Enemies never stack; no invulnerability after being hit (being swarmed kills you).
- Each weapon has its own speeds; Heroes have expertise in weapon types they don't start with.
- No hard stat caps; every level-up offers something useful; Auto-collect gold/heal when maxed.
- Bosses spawn on time even if the previous boss is alive.
- God summons are enhanced by the player's stats.
- Elemental statuses only affect players from 30:00.
- Level-ups and chests pause the timer; in co-op, players pick one at a time in turns.
- Rising-pitch pickup sounds must cap out.

## Ideas the owner declined or hasn't chosen (don't add without asking)

- Difficulty rating per level (later packs starting harder): suggested, not chosen.
- A public-domain Hero for each fantasy realm pack (e.g. Thomas the Rhymer, Sinbad, Peer Gynt): suggested, not chosen.
- A generic permanent stat shop: rejected (progression should unlock options, not raw power).
- Free-to-play with ads or energy timers: advised against; not decided.

## Open questions waiting for the owner

1. **How the game will be sold** (one-time purchase with packs as paid DLC or free updates, or something else). Needed before a Steam page.
2. **Crashes:** a crash or force-close currently counts as quitting (gold penalty). Alternative offered: let players resume an interrupted run.
3. **Status timing exception:** boss signature mechanics (Medusa's gaze, Tsuchigumo's webs) and terrain (quicksand) currently work before 30:00 even though elemental statuses don't. Owner hasn't confirmed this.
4. **Finale boss name:** the Unweaver is invented; Khaos (Greek primordial void) was offered as a public-domain alternative.
5. **Trademark searches** still needed for Mythriven, every realm name, and the three invented realms (Mycendra, Ghorvast, Ashkarrow).

## Work still to design before it's built

- Odysseus (secret Hero) needs a full design by Phase 15.
- Each fantasy realm has only one boss so far; two more per realm are needed before any realm pack is built.
- Ukko and Ilmatar (Pack 3) aren't in the reference database; verify their lore before use.

## Where the design document lives

The master copy is a Claude Doc in the owner's Claude chat, with tabs for the design, a review and changelog (every version from v1 to v3.11 with reasons), and archived v1 and v2. `GAME_DESIGN.md` in this folder is an export of the design tab. When the design changes, export a fresh copy rather than editing by hand, unless the owner says otherwise.
