
extends Control

@onready var game_manager = $GameManager

@onready var end_turn_button: Button = $UI/EndTurnButton
@onready var day_icon: Label = $Battlefield/CenterArea/DayNightIndicator/Icon
@onready var time_label: Label = $Battlefield/CenterArea/DayNightIndicator/TimeLabel
@onready var turn_indicator: Label = $Battlefield/CenterArea/TurnIndicator
@onready var mana_label: Label = $Battlefield/PlayerArea/ManaLabel

@export var card_view_scene: PackedScene

@onready var hand_cards: HBoxContainer = $UI/PlayerBottomArea/HandArea/HandCards
@onready var deck_count: Label = $UI/PlayerBottomArea/DeckPile/DeckCount

var selected_hand_index: int = -1

var board_slots: Array[BoardSlot] = []

@onready var ui_layer: Control = $UI
var last_debug_slot: BoardSlot = null
var last_hovered_control: Control = null

func _ready() -> void:
	end_turn_button.pressed.connect(game_manager.end_turn)

	game_manager.time_of_day_changed.connect(update_time_indicator)
	game_manager.turn_started.connect(update_turn_indicator)
	game_manager.mana_changed.connect(update_mana_indicator)
	game_manager.hand_changed.connect(update_hand)
	game_manager.deck_changed.connect(update_deck_count)
	game_manager.board_changed.connect(update_board)
	# UI-контейнер не повинен перекривати ігрове поле.
	ui_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	end_turn_button.pressed.connect(game_manager.end_turn)

	# Решта твого коду без змін..
	_connect_board_slots()

	# Початкове оновлення інтерфейсу
	var state = game_manager.game_state
	var active_player = state.players[state.active_player]

	update_turn_indicator(
		state.current_turn,
		state.active_player
	)

	update_mana_indicator(
		state.active_player,
		active_player.current_mana,
		active_player.max_mana
	)

	update_hand(state.active_player, active_player.hand)

	update_deck_count(
		state.active_player,
		active_player.draw_pile.size()
	)

	update_time_indicator(state.time_of_day)

	# Початкове відображення поля першого гравця
	update_board(0, state.players[0].board_rows)
	await get_tree().process_frame

	print("========== SLOT POSITIONS AFTER LAYOUT ==========")

	for slot in board_slots:
		print(
			slot.name,
			" | Row: ", slot.row_index,
			" | Slot: ", slot.slot_index,
			" | Position: ", slot.global_position,
			" | Size: ", slot.size
			)

		print("=================================================")



func _connect_board_slots() -> void:
	board_slots.clear()

	var slot_configs: Array[Dictionary] = [
		{"path": "Battlefield/PlayerArea/Row1/CardSlot", "row": 0, "slot": 0},
		{"path": "Battlefield/PlayerArea/Row1/CardSlot2", "row": 0, "slot": 1},
		{"path": "Battlefield/PlayerArea/Row1/CardSlot3", "row": 0, "slot": 2},
		{"path": "Battlefield/PlayerArea/Row1/CardSlot4", "row": 0, "slot": 3},

		{"path": "Battlefield/PlayerArea/Row2/CardSlot", "row": 1, "slot": 0},
		{"path": "Battlefield/PlayerArea/Row2/CardSlot2", "row": 1, "slot": 1},
		{"path": "Battlefield/PlayerArea/Row2/CardSlot3", "row": 1, "slot": 2},

		{"path": "Battlefield/PlayerArea/Row3/CardSlot", "row": 2, "slot": 0},
		{"path": "Battlefield/PlayerArea/Row3/CardSlot2", "row": 2, "slot": 1}
	]

	for config in slot_configs:
		var path: String = config["path"]
		var slot := get_node_or_null(path) as BoardSlot

		if slot == null:
			push_error("BoardSlot not found: " + path)
			continue

		# Примусово встановлюємо координати.
		slot.row_index = int(config["row"])
		slot.slot_index = int(config["slot"])

		board_slots.append(slot)

		if not slot.slot_clicked.is_connected(_on_board_slot_clicked):
			slot.slot_clicked.connect(_on_board_slot_clicked)

		print(
			"SLOT ASSIGNED: ", path,
			" | Row: ", slot.row_index,
			" | Slot: ", slot.slot_index
		)



func update_time_indicator(new_time: int) -> void:
	if new_time == GameState.TimeOfDay.DAY:
		day_icon.text = "☀️"
		time_label.text = "DAY"
	else:
		day_icon.text = "🌙"
		time_label.text = "NIGHT"


func update_turn_indicator(
	turn_number: int,
	player_index: int
) -> void:
	turn_indicator.text = "ХІД %d — ГРАВЕЦЬ %d" % [
		turn_number,
		player_index + 1
	]


func update_mana_indicator(
	player_index: int,
	current: int,
	maximum: int
) -> void:
	mana_label.text = "МАНА %d/%d" % [current, maximum]

	if player_index == game_manager.game_state.active_player:
		update_hand(
			player_index,
			game_manager.game_state.players[player_index].hand
		)


func update_hand(player_index: int, cards: Array) -> void:
	# Показуємо тільки руку активного гравця.
	if player_index != game_manager.game_state.active_player:
		return

	for child in hand_cards.get_children():
		child.queue_free()

	if card_view_scene == null:
		push_error("CardView scene is not assigned!")
		return

	var player = game_manager.game_state.players[player_index]

	for i in range(cards.size()):
		var card_data: CardData = cards[i]
		var card_view = card_view_scene.instantiate()

		hand_cards.add_child(card_view)
		card_view.set_card(card_data, player.current_mana)

		# Підключаємо натискання саме до створеної кнопки.
		card_view.pressed.connect(
			_on_hand_card_pressed.bind(i)
		)

		# Візуально позначаємо вибрану карту.
		if i == selected_hand_index:
			card_view.modulate = Color(1.2, 1.2, 0.7)


func _on_hand_card_pressed(hand_index: int) -> void:
	selected_hand_index = hand_index

	print("Selected card: ", hand_index)

	# Оновлюємо підсвічування вибраної карти.
	var player = game_manager.game_state.players[
		game_manager.game_state.active_player
	]

	update_hand(
		game_manager.game_state.active_player,
		player.hand
	)


func _on_board_slot_clicked(
	row_index: int,
	slot_index: int
) -> void:
	print("MAIN RECEIVED SLOT CLICK: ", row_index, " / ", slot_index)

	if selected_hand_index < 0:
		print("Спочатку вибери карту в руці.")
		return

	print("Trying to play card index: ", selected_hand_index)

	var success: bool = game_manager.play_card_from_hand(
		selected_hand_index,
		row_index,
		slot_index
	)

	print("PLAY CARD RESULT: ", success)

	if success:
		selected_hand_index = -1


func update_board(
	player_index: int,
	board_rows: Array
) -> void:
	# PlayerArea поки відображає поле першого гравця.
	if player_index != 0:
		return

	var player: PlayerState = game_manager.game_state.players[player_index]

	var slot_index: int = 0

	for row_index in range(board_rows.size()):
		for column_index in range(board_rows[row_index].size()):
			var slot: BoardSlot = board_slots[slot_index]
			slot_index += 1

			# Видаляємо попереднє відображення карти.
			for child in slot.get_children():
				child.queue_free()

			var card_data: CardData = board_rows[row_index][column_index]

			if card_data == null:
				continue

			var card_view = card_view_scene.instantiate()
			slot.add_child(card_view)

			card_view.set_card(card_data, card_data.mana_cost)

			# Карта на полі не повинна перехоплювати натискання комірки.
			card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_view.set_anchors_and_offsets_preset(
				Control.PRESET_FULL_RECT
			)


func update_deck_count(player_index: int, cards_left: int) -> void:
	if player_index != game_manager.game_state.active_player:
		return

	deck_count.text = str(cards_left)

func _process(_delta: float) -> void:
	var hovered = get_viewport().gui_get_hovered_control()

	if hovered != last_hovered_control:
		last_hovered_control = hovered

		if hovered == null:
			print("[GUI HOVERED] NONE")
		else:
			print(
				"[GUI HOVERED] ",
				hovered.get_path(),
				" | Mouse filter: ",
				hovered.mouse_filter
			)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("[GLOBAL CLICK] ", event.position)
