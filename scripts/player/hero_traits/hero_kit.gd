class_name HeroKit
extends Node2D
## Base for a Hero's Legend Trait and passive (GAME_DESIGN.md: Heroes). One
## script per Hero lives in this folder; adding a Hero needs only an entry in
## heroes.json, a kit script here, and art. Kits are children of the Player.

const KITS: Dictionary = {
	"twelve_labors": "res://scripts/player/hero_traits/twelve_labors.gd",
	"salmon_leap": "res://scripts/player/hero_traits/salmon_leap.gd",
	"song_of_power": "res://scripts/player/hero_traits/song_of_power.gd",
	"cavalry_charge": "res://scripts/player/hero_traits/cavalry_charge.gd",
	"the_heel": "res://scripts/player/hero_traits/the_heel.gd",
}

var player: Player
var hero: Dictionary = {}


## Makes the kit for a Hero's Legend Trait (a plain kit if the trait is unknown).
static func create(trait_id: String) -> HeroKit:
	var path: String = str(KITS.get(trait_id, ""))
	if path == "":
		return HeroKit.new()
	return load(path).new()


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	player = owner_player
	hero = hero_data


func trait_data() -> Dictionary:
	return hero.get("trait", {})


func passive_data() -> Dictionary:
	return hero.get("passive", {})


## Extra attack speed right now (e.g. +0.3 = 30% more attacks).
func attack_speed_bonus() -> float:
	return 0.0


## Damage multiplier for one of this Hero's weapons.
func damage_mult(_weapon: WeaponInstance) -> float:
	return 1.0


## Move speed multiplier right now (e.g. during a charge).
func speed_mult() -> float:
	return 1.0


## True while the kit moves the player itself (e.g. mid-leap).
func controls_movement() -> bool:
	return false


## True while enemies can't hurt the player (e.g. mid-leap).
func is_untargetable() -> bool:
	return false


## Changes damage the player is about to take (after Armor).
func incoming_damage(amount: float) -> float:
	return amount


## Like incoming_damage, but knowing where the hit came from (Vector2.INF when unknown).
func incoming_damage_at(amount: float, _from: Vector2) -> float:
	return incoming_damage(amount)


## A short line for the HUD (e.g. the current Labor), or "".
func hud_text() -> String:
	return ""


## Finds the shared effect layer to draw rings and arcs.
func effect_layer() -> EffectLayer:
	return get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
