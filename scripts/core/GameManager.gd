extends Node

var game_state: GameState

func _ready() -> void:
	start_new_game()

func start_new_game() -> void:
	game_state = GameState.new()

	var player_1 = PlayerState.new()
	var player_2 = PlayerState.new()

	game_state.players = [player_1, player_2]
	game_state.start_game()

	print("Game started!")
