class_name GameState
extends RefCounted

var current_turn: int = 0
var active_player: int = 0
var is_game_over: bool = false

var players: Array = []

func start_game() -> void:
	current_turn = 1
	active_player = 0
	is_game_over = false

func switch_player() -> void:
	active_player = 1 - active_player
	current_turn += 1
