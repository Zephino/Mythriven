class_name ZmeyGorynychBoss
extends BossController
## Zmey Gorynych, 10:00 (docs/PACK_3_PLAN.md: the Slavic Wilds). Signature, three heads: while any head is on, blows
## land on the heads, not the body; each head falls after head_hp of harm. A head cut off with an ordinary blow grows
## back after regrow_s (and heals him), but one finished with Fire or Holy is seared and never grows back. With every
## head off, his body takes full damage. Source: the byliny (Dobrynya Nikitich and the Serpent).

## Per head: "hp" left (0 when off), "regrow" seconds until it grows back (-1 when on or seared), "seared".
var heads: Array = []
var _element: String = ""
## True once any head has grown back (the Seared Necks secret: defeat him without one ever regrowing).
var regrew: bool = false


func secret_earned() -> String:
	return "seared_necks" if not regrew else ""


func _sig() -> Dictionary:
	return data.get("signature", {})


func _ensure() -> void:
	if heads.is_empty():
		for _k: int in int(_sig().get("heads", 3)):
			heads.append({"hp": float(_sig().get("head_hp", 420.0)), "regrow": -1.0, "seared": false})


func heads_on() -> int:
	_ensure()
	var on: int = 0
	for head: Dictionary in heads:
		if float(head["hp"]) > 0.0:
			on += 1
	return on


func on_element_hit(element: String) -> void:
	_element = element


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	_ensure()
	for head: Dictionary in heads:
		if float(head["hp"]) <= 0.0:
			continue
		head["hp"] = float(head["hp"]) - amount
		if float(head["hp"]) <= 0.0:
			_cut(head)
		return 0.0
	return amount


func _cut(head: Dictionary) -> void:
	head["hp"] = 0.0
	var seared: bool = (_sig().get("sear_elements", ["fire", "holy"]) as Array).has(_element)
	head["seared"] = seared
	head["regrow"] = -1.0 if seared else float(_sig().get("regrow_s", 6.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_ZMEY_SEARED") if seared else tr("BOSS_ZMEY_HEAD_FALLS"))


func signature(delta: float) -> void:
	_ensure()
	for head: Dictionary in heads:
		if float(head["regrow"]) < 0.0:
			continue
		head["regrow"] = float(head["regrow"]) - delta
		if float(head["regrow"]) <= 0.0:
			head["regrow"] = -1.0
			head["hp"] = float(_sig().get("head_hp", 420.0))
			regrew = true
			if is_alive():
				var enemies: EnemyManager = GameAuthority.enemies
				enemies.hp[slot] = minf(enemies.hp[slot] + float(_sig().get("regrow_heal", 150.0)), enemies.max_hp[slot])
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null:
				banner.show_text(tr("BOSS_ZMEY_REGROWS"))


## A mark over each head: green while on, a red stump while regrowing, black where it was seared.
func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	_ensure()
	var at: Vector2 = position_now() - global_position + Vector2(0, -GameAuthority.enemies.radius[slot] - 30.0)
	for k: int in heads.size():
		var head: Dictionary = heads[k]
		var spot: Vector2 = at + Vector2((k - (heads.size() - 1) * 0.5) * 12.0, 0)
		var colour := Color(0.3, 0.8, 0.3) if float(head["hp"]) > 0.0 else (Color(0.1, 0.1, 0.1) if bool(head["seared"]) else Color(0.8, 0.2, 0.2))
		draw_circle(spot, 4.0, colour)
