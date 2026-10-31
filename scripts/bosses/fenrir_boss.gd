class_name FenrirBoss
extends BossController
## Fenrir, 10:00 (GAME_DESIGN.md: Midgard's Edge bosses). Signature, Breaking
## the chains: he starts chained to a ring of posts; each phase he snaps
## chains and his reach grows, until he runs free. Phases: lunges within his
## chains' reach → bites and howls that summon wolves → free: charges across
## the whole arena. Tyr's Oath secret: defeat him while below 30% health
## (Tyr lost his hand binding Fenrir).

## Where the posts stand and how far the chains let him go (-1 = free).
var anchor := Vector2.INF
var reach: float = -1.0


func secret_earned() -> String:
	var player: Player = GameAuthority.local_player()
	var below: float = float((data.get("signature", {}) as Dictionary).get("tyr_hp_fraction", 0.3))
	return "tyrs_oath" if player != null and player.alive and player.hp < player.max_hp * below else ""


func _on_phase_started(index: int) -> void:
	if anchor == Vector2.INF and slot != -1:
		anchor = position_now()
	var reaches: Array = (data.get("signature", {}) as Dictionary).get("reach_px", [90, 170, -1])
	reach = float(reaches[mini(index, reaches.size() - 1)])
	if index > 0:
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_FENRIR_CHAINS" if reach > 0.0 else "BOSS_FENRIR_FREE"))


func _move(delta: float) -> void:
	super._move(delta)
	if reach > 0.0 and anchor != Vector2.INF and is_alive():
		var enemies: EnemyManager = GameAuthority.enemies
		var offset: Vector2 = enemies.positions[slot] - anchor
		if offset.length() > reach:
			enemies.positions[slot] = anchor + offset.normalized() * reach


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if anchor != Vector2.INF:
		anchor -= shift_px


func _draw() -> void:
	super._draw()
	if not is_alive() or anchor == Vector2.INF:
		return
	var sig: Dictionary = data.get("signature", {})
	var posts: int = int(sig.get("posts", 4))
	var chains: int = int((sig.get("chains_per_phase", [4, 2, 0]) as Array)[mini(phase_index, 2)])
	var ring: float = float((sig.get("reach_px", [90]) as Array)[0]) + 20.0
	var at: Vector2 = position_now() - global_position
	var post_color := Color.html(Data.cfg_string("bosses.post_color"))
	for k: int in posts:
		var post: Vector2 = anchor - global_position + Vector2.from_angle(TAU * k / posts) * ring
		# A stout post driven into the ground, and the chain from it to the wolf, link by link (owner request
		# 10/31/2026).
		draw_rect(Rect2(post - Vector2(5, 10), Vector2(10, 14)), post_color.darkened(0.4))
		draw_rect(Rect2(post - Vector2(4, 9), Vector2(8, 12)), post_color)
		draw_rect(Rect2(post - Vector2(5, 11), Vector2(10, 3)), post_color.lightened(0.2))
		if k < chains:
			var links: int = maxi(int(post.distance_to(at) / 7.0), 1)
			var along: Vector2 = (at - post) / links
			for l: int in links:
				var mid: Vector2 = post + along * (l + 0.5)
				draw_set_transform(mid, along.angle() + (PI * 0.5 if l % 2 == 1 else 0.0), Vector2(1.0, 0.55 if l % 2 == 0 else 0.3))
				draw_arc(Vector2.ZERO, 4.0, 0.0, TAU, 10, Color(0.7, 0.72, 0.78, 0.95), 1.5)
				draw_set_transform(Vector2.ZERO)
