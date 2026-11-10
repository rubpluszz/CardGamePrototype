class_name GameState
extends RefCounted

enum TimeOfDay {
	DAY,
	NIGHT
}

var current_turn: int = 1
var active_player: int = 0
var is_game_over: bool = false

var time_of_day: TimeOfDay = TimeOfDay.DAY

var players: Array = []

func start_game() -> void:
	current_turn = 1
	active_player = 0
	is_game_over = false
	time_of_day = TimeOfDay.DAY
