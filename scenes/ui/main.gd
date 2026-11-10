extends Control

@onready var game_manager = $GameManager

@onready var end_turn_button: Button = $UI/EndTurnButton

@onready var day_icon: Label = \
	$Battlefield/CenterArea/DayNightIndicator/Icon

@onready var time_label: Label = \
	$Battlefield/CenterArea/DayNightIndicator/TimeLabel


func _ready() -> void:

	end_turn_button.pressed.connect(
		game_manager.end_turn
	)

	game_manager.time_of_day_changed.connect(
		update_time_indicator
	)

	# Встановлюємо початковий стан
	update_time_indicator(
		game_manager.game_state.time_of_day
	)


func update_time_indicator(new_time: int) -> void:

	if new_time == GameState.TimeOfDay.DAY:
		day_icon.text = "☀️"
		time_label.text = "DAY"

	else:
		day_icon.text = "🌙"
		time_label.text = "NIGHT"
