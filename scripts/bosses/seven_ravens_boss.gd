class_name SevenRavensBoss
extends BossController
## The Seven Ravens, 10:00 (docs/PACK_10_PLAN.md: the Glass Mountain). Signature, scattering: every so often the boss
## scatters into seven ravens and can't be hurt; each raven killed before they gather again hurts it, then they gather
## and it fights on. Source: the Brothers Grimm, "The Seven Ravens" (KHM 25): seven brothers turned into ravens, living
## in the glass mountain.

## Enemy slots of the scattered ravens.
var ravens: Array[int] = []
var scattered_s: float = 0.0
var killed: int = 0
var scatters: int = 0
var _scatter_in: float = 6.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if scattered_s > 0.0 else amount


func ravens_left() -> int:
	var enemies: EnemyManager = GameAuthority.enemies
	var raven_id: String = str(_sig().get("raven", "raven"))
	var left: int = 0
	for i: int in range(ravens.size() - 1, -1, -1):
		var r: int = ravens[i]
		if enemies.active[r] == 0 or str(enemies.type_of(r).get("id", "")) != raven_id:
			ravens.remove_at(i)
			killed += 1
			var hurt: float = enemies.max_hp[slot] * float(_sig().get("hurt_per_raven", 0.03))
			enemies.hp[slot] = maxf(enemies.hp[slot] - hurt, 1.0)
		else:
			left += 1
	return left


func signature(delta: float) -> void:
	if not is_alive():
		return
	var enemies: EnemyManager = GameAuthority.enemies
	if scattered_s > 0.0:
		scattered_s -= delta
		enemies.statuses.stun[slot] = maxf(enemies.statuses.stun[slot], 0.2)
		if ravens_left() == 0 or scattered_s <= 0.0:
			gather()
		return
	_scatter_in -= delta
	if _scatter_in <= 0.0:
		_scatter_in = float(_sig().get("scatter_every_s", 12.0))
		scatter()


func scatter() -> void:
	scatters += 1
	scattered_s = float(_sig().get("scatter_s", 6.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	for k: int in 7:
		var r: int = GameAuthority.spawn_enemy(str(_sig().get("raven", "raven")), position_now() + Vector2.from_angle(TAU * k / 7.0 + rng.randf()) * 40.0)
		if r >= 0:
			ravens.append(r)


## The ravens gather again; any left alive fly back into it.
func gather() -> void:
	scattered_s = 0.0
	GameAuthority.enemies.statuses.stun[slot] = 0.0
	for r: int in ravens:
		if GameAuthority.enemies.active[r] != 0:
			GameAuthority.enemies.remove_quietly(r)
	ravens.clear()


func _draw() -> void:
	if scattered_s <= 0.0:
		super._draw()


## Seven Brothers Freed secret: fourteen ravens brought down.
func secret_earned() -> String:
	return "seven_brothers" if killed >= 14 else ""
