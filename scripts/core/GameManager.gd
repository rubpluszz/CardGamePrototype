extends Node

signal time_of_day_changed(new_time: int)

@onready var turn_manager: TurnManager = $TurnManager

signal turn_started(turn_number: int, player_index: int)

signal mana_changed(player_index: int, current: int, maximum: int)

var game_state: GameState


func _ready() -> void:
	turn_manager.time_of_day_changed.connect(_on_time_of_day_changed)
	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.mana_changed.connect(_on_mana_changed)

	start_new_game()


func start_new_game() -> void:
	game_state = GameState.new()

	var player_1 = PlayerState.new()
	var player_2 = PlayerState.new()

	game_state.players = [player_1, player_2]

	game_state.start_game()

	turn_manager.start_game(game_state)

	print("Game started!")


func end_turn() -> void:
	turn_manager.end_turn()


func _on_time_of_day_changed(new_time: int) -> void:
	time_of_day_changed.emit(new_time)

	if new_time == GameState.TimeOfDay.DAY:
		print("Time changed: DAY")
	else:
		print("Time changed: NIGHT")

func _on_turn_started(turn_number: int, player_index: int) -> void:
	turn_started.emit(turn_number, player_index)


func _on_mana_changed(
	player_index: int,
	current: int,
	maximum: int
) -> void:
	mana_changed.emit(player_index, current, maximum)
