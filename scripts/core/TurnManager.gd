class_name TurnManager
extends Node

signal turn_started(turn_number: int, player_index: int)
signal turn_ended(turn_number: int, player_index: int)

signal time_of_day_changed(new_time: int)

var game_state: GameState

var day_night_system: DayNightSystem = DayNightSystem.new()


func start_game(state: GameState) -> void:
	game_state = state

	game_state.current_turn = 1
	game_state.active_player = 0
	game_state.time_of_day = GameState.TimeOfDay.DAY

	turn_started.emit(
		game_state.current_turn,
		game_state.active_player
	)


func end_turn() -> void:
	if game_state == null:
		return

	if game_state.is_game_over:
		return

	turn_ended.emit(
		game_state.current_turn,
		game_state.active_player
	)

	# Перемикаємо активного гравця
	game_state.active_player = 1 - game_state.active_player

	# Переходимо до наступного ходу
	game_state.current_turn += 1

	# Перевіряємо зміну часу доби
	if day_night_system.should_change_time(
		game_state.current_turn
	):
		game_state.time_of_day = day_night_system.get_next_time(
			game_state.time_of_day
		)

		time_of_day_changed.emit(game_state.time_of_day)

	turn_started.emit(
		game_state.current_turn,
		game_state.active_player
	)
