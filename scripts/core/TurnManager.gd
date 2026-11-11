class_name TurnManager
extends Node

signal turn_started(turn_number: int, player_index: int)
signal turn_ended(turn_number: int, player_index: int)

signal time_of_day_changed(new_time: int)

signal mana_changed(player_index: int, current: int, maximum: int)

var mana_system: ManaSystem = ManaSystem.new()

var game_state: GameState

var day_night_system: DayNightSystem = DayNightSystem.new()


func start_game(state: GameState) -> void:
	game_state = state
	game_state.current_turn = 1
	game_state.active_player = 0
	game_state.time_of_day = GameState.TimeOfDay.DAY

	for player in game_state.players:
		mana_system.initialize_player(player)

	_start_active_turn()

func _start_active_turn() -> void:
	var player = game_state.players[game_state.active_player]

	# Перший глобальний хід — початкова мана вже встановлена.
	if game_state.current_turn > 1:
		mana_system.start_turn(player)

	mana_changed.emit(
		game_state.active_player,
		player.current_mana,
		player.max_mana
	)

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

	_start_active_turn()

func spend_current_player_mana(cost: int) -> bool:
	if game_state == null or game_state.is_game_over:
		return false

	var player = game_state.players[game_state.active_player]

	if not mana_system.spend_mana(player, cost):
		return false

	mana_changed.emit(
		game_state.active_player,
		player.current_mana,
		player.max_mana
	)

	return true
