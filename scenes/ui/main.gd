extends Control

@onready var game_manager = $GameManager

@onready var end_turn_button: Button = $UI/EndTurnButton

@onready var day_icon: Label = $Battlefield/CenterArea/DayNightIndicator/Icon

@onready var time_label: Label = $Battlefield/CenterArea/DayNightIndicator/TimeLabel

@onready var turn_indicator: Label = $Battlefield/CenterArea/TurnIndicator

@onready var mana_label: Label = $Battlefield/PlayerArea/ManaLabel

func _ready() -> void:
	end_turn_button.pressed.connect(game_manager.end_turn)

	game_manager.time_of_day_changed.connect(update_time_indicator)
	game_manager.turn_started.connect(update_turn_indicator)
	game_manager.mana_changed.connect(update_mana_indicator)

	# Початкове оновлення індикаторів
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

	update_time_indicator(state.time_of_day)

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
