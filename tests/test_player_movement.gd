extends GutTest
## Phase 2: 8-direction movement, diagonal speed, facing, and players-as-list.

const DEADZONE := 0.2


func test_no_input_means_no_movement() -> void:
	assert_eq(PlayerInput.shape_move(Vector2.ZERO, DEADZONE, true), Vector2.ZERO)
	assert_eq(PlayerInput.shape_move(Vector2(0.1, 0.1), DEADZONE, true), Vector2.ZERO)


func test_diagonal_is_not_faster_than_straight() -> void:
	var straight: Vector2 = PlayerInput.shape_move(Vector2(1, 0), DEADZONE, true)
	var diagonal: Vector2 = PlayerInput.shape_move(Vector2(1, 1), DEADZONE, true)
	assert_almost_eq(straight.length(), 1.0, 0.0001)
	assert_almost_eq(diagonal.length(), 1.0, 0.0001)
	assert_almost_eq(PlayerInput.shape_move(Vector2(1, 1), DEADZONE, false).length(), 1.0, 0.0001)


func test_snaps_to_nearest_of_8_directions() -> void:
	var almost_right: Vector2 = PlayerInput.shape_move(Vector2(1.0, 0.3), DEADZONE, true)
	assert_almost_eq(almost_right.x, 1.0, 0.0001)
	assert_almost_eq(almost_right.y, 0.0, 0.0001)
	var near_diagonal: Vector2 = PlayerInput.shape_move(Vector2(0.9, -0.7), DEADZONE, true)
	assert_almost_eq(near_diagonal.angle(), -PI / 4.0, 0.0001)


func test_facing_keeps_last_direction_when_stopped() -> void:
	var player: Player = autofree(Player.new())
	player.move_speed = 100.0
	player.step(Vector2.UP, 0.5)
	assert_eq(player.position, Vector2(0, -50))
	player.step(Vector2.ZERO, 0.5)
	assert_eq(player.facing, Vector2.UP)
	assert_eq(player.velocity, Vector2.ZERO)
	assert_eq(player.position, Vector2(0, -50))


func test_players_are_a_list() -> void:
	var parent: Node = add_child_autofree(Node.new())
	var before: int = GameAuthority.players.size()
	var first: Player = GameAuthority.spawn_player(parent, Vector2.ZERO, PlayerInput.new(), true)
	var second: Player = GameAuthority.spawn_player(parent, Vector2(10, 0), PlayerInput.new(), false)
	assert_eq(GameAuthority.players.size(), before + 2)
	assert_ne(first.player_id, second.player_id)
	GameAuthority.remove_player(first)
	GameAuthority.remove_player(second)
	assert_eq(GameAuthority.players.size(), before)
