class_name TurnManager
extends Node

signal turn_started(turn_number: int, player_index: int)
signal turn_ended(turn_number: int, player_index: int)

signal time_of_day_changed(new_time: int)

signal mana_changed(player_index: int, current: int, maximum: int)

signal hand_changed(player_index: int, cards: Array)
signal deck_changed(player_index: int, cards_left: int)

signal board_changed(player_index: int, board_rows: Array)

var deck_system: DeckSystem = DeckSystem.new()

var mana_system: ManaSystem = ManaSystem.new()

var game_state: GameState

var day_night_system: DayNightSystem = DayNightSystem.new()

var board_system: BoardSystem = BoardSystem.new()

func start_game(
	state: GameState,
	decks: Array,
	starting_hands: Array,
	hand_limits: Array
) -> void:

	game_state = state

	game_state.current_turn = 1
	game_state.active_player = 0
	game_state.time_of_day = GameState.TimeOfDay.DAY

	for i in range(game_state.players.size()):
		var player: PlayerState = game_state.players[i]

		mana_system.initialize_player(player)

		var success = deck_system.setup_player(
			player,
			decks[i],
			starting_hands[i],
			hand_limits[i]
		)

		if not success:
			push_error("Failed to initialize player deck: %d" % i)
			return

	_start_active_turn()


func _start_active_turn() -> void:
	var player: PlayerState = game_state.players[
		game_state.active_player
	]

	# Перший особистий хід уже має початкову ману
	# та початкову руку.
	if player.turns_started > 0:
		mana_system.start_turn(player)

		# ДІАГНОСТИКА: стан руки перед добором
		print("========== DRAW DEBUG ==========")
		print("Player: ", game_state.active_player)
		print("Hand before draw: ", player.hand.size())
		print("Hand limit: ", player.max_hand_size)

		# Добираємо карти до індивідуального ліміту
		deck_system.draw_to_hand_limit(player)

		# ДІАГНОСТИКА: стан руки після добору
		print("Hand after draw: ", player.hand.size())
		print("Cards left in deck: ", player.draw_pile.size())
		print("================================")

	player.turns_started += 1

	mana_changed.emit(
		game_state.active_player,
		player.current_mana,
		player.max_mana
	)

	hand_changed.emit(
		game_state.active_player,
		player.hand
	)

	deck_changed.emit(
		game_state.active_player,
		player.draw_pile.size()
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


func play_card_from_hand(
	hand_index: int,
	row_index: int,
	slot_index: int
) -> bool:

	if game_state == null or game_state.is_game_over:
		return false

	var player: PlayerState = game_state.players[
		game_state.active_player
	]

	# Перевіряємо індекс карти в руці
	if hand_index < 0 or hand_index >= player.hand.size():
		return false

	var card: CardData = player.hand[hand_index]

	# Поки дозволяємо викладати тільки істот
	if card.card_type != "Minion":
		return false

	# Перевіряємо вільну комірку
	if not board_system.can_place_minion(
		player,
		row_index,
		slot_index
	):
		return false

	# Перевіряємо, чи вистачає мани
	if not mana_system.can_afford(player, card.mana_cost):
		return false

	# Списуємо ману
	if not mana_system.spend_mana(player, card.mana_cost):
		return false

	# Розміщуємо карту на полі
	if not board_system.place_minion(
		player,
		card,
		row_index,
		slot_index
	):
		# Захист на випадок невдалого розміщення
		player.current_mana += card.mana_cost
		return false

	# Видаляємо карту з руки
	player.hand.remove_at(hand_index)

	# Повідомляємо інтерфейс про зміни
	mana_changed.emit(
		game_state.active_player,
		player.current_mana,
		player.max_mana
	)

	hand_changed.emit(
		game_state.active_player,
		player.hand
	)

	board_changed.emit(
		game_state.active_player,
		player.board_rows
	)

	return true
