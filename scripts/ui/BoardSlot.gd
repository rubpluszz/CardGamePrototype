
class_name BoardSlot
extends PanelContainer

signal slot_clicked(row_index: int, slot_index: int)

@export_range(0, 2, 1) var row_index: int = 0
@export_range(0, 3, 1) var slot_index: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	print("[SLOT READY] ", get_path(),
		" | Row: ", row_index,
		" | Slot: ", slot_index)


func _on_mouse_entered() -> void:
	print("[HOVER ENTER] ", get_path(),
		" | Row: ", row_index,
		" | Slot: ", slot_index)

	# Тимчасова візуальна перевірка.
	modulate = Color(1.3, 1.3, 0.7)


func _on_mouse_exited() -> void:
	print("[HOVER EXIT] ", get_path())

	modulate = Color.WHITE


func _gui_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			print("[MOUSE CLICK EVENT] ",
				"Pressed: ", event.pressed,
				" | Slot: ", get_path(),
				" | Mouse position: ", get_global_mouse_position(),
				" | Inside rect: ",
				get_global_rect().has_point(get_global_mouse_position()))

			if event.pressed:
				print("[SLOT CLICKED] Row: ",
					row_index, " / Slot: ", slot_index)

				slot_clicked.emit(row_index, slot_index)

			accept_event()
