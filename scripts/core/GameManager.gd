extends Node

signal time_of_day_changed(new_time: int)

@onready var turn_manager: TurnManager = $TurnManager

signal turn_started(turn_number: int, player_index: int)

signal mana_changed(player_index: int, current: int, maximum: int)

signal hand_changed(player_index: int, cards: Array)
signal deck_changed(player_index: int, cards_left: int)
signal board_changed(player_index: int, board_rows: Array)
var game_state: GameState

@export var player_1_deck: Array[CardData] = []
@export var player_2_deck: Array[CardData] = []

@export_range(3, 5, 1) var player_1_starting_hand: int = 3
@export_range(3, 5, 1) var player_2_starting_hand: int = 3

@export_range(3, 5, 1) var player_1_hand_limit: int = 3
@export_range(3, 5, 1) var player_2_hand_limit: int = 3

func _ready() -> void:
	turn_manager.time_of_day_changed.connect(_on_time_of_day_changed)
	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.mana_changed.connect(_on_mana_changed)
	turn_manager.board_changed.connect(_on_board_changed)
	turn_manager.hand_changed.connect(_on_hand_changed)
	turn_manager.deck_changed.connect(_on_deck_changed)
	start_new_game()


func start_new_game() -> void:
	game_state = GameState.new()

	var player_1 = PlayerState.new()
	var player_2 = PlayerState.new()

	game_state.players = [player_1, player_2]

	game_state.start_game()
	if player_1_deck.is_empty():
		player_1_deck = create_test_deck()

	if player_2_deck.is_empty():
		player_2_deck = create_test_deck()
	turn_manager.start_game(
	game_state,
	[player_1_deck, player_2_deck],
	[
		player_1_starting_hand,
		player_2_starting_hand
	],
	[
		player_1_hand_limit,
		player_2_hand_limit
	]
)

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

func _on_hand_changed(player_index: int, cards: Array) -> void:
	hand_changed.emit(player_index, cards)


func _on_deck_changed(player_index: int, cards_left: int) -> void:
	deck_changed.emit(player_index, cards_left)

func create_test_deck() -> Array[CardData]:
	var deck: Array[CardData] = []

	var test_card = load("res://data/cards/test_card.tres")

	if test_card == null:
		push_error("Test card not found!")
		return deck

	for i in range(50):
		deck.append(test_card)

	return deck

func _on_board_changed(
	player_index: int,
	board_rows: Array
) -> void:
	board_changed.emit(player_index, board_rows)


func play_card_from_hand(
	hand_index: int,
	row_index: int,
	slot_index: int
) -> bool:
	return turn_manager.play_card_from_hand(
		hand_index,
		row_index,
		slot_index
	)
