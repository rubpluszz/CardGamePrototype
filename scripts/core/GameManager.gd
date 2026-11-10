extends Node

signal time_of_day_changed(new_time: int)

@onready var turn_manager: TurnManager = $TurnManager

var game_state: GameState


func _ready() -> void:
	turn_manager.time_of_day_changed.connect(
		_on_time_of_day_changed
	)

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
