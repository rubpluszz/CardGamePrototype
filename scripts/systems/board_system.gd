
class_name BoardSystem
extends RefCounted


# Перевіряє, чи можна розмістити істоту
func can_place_minion(
	player: PlayerState,
	row_index: int,
	slot_index: int
) -> bool:

	if row_index < 0 or row_index >= player.board_rows.size():
		return false

	if slot_index < 0 or slot_index >= player.board_rows[row_index].size():
		return false

	# Комірка повинна бути вільною
	if player.board_rows[row_index][slot_index] != null:
		return false

	return true


# Розміщує істоту на полі
func place_minion(
	player: PlayerState,
	card: CardData,
	row_index: int,
	slot_index: int
) -> bool:

	if card == null:
		return false

	if card.card_type != "Minion":
		return false

	if not can_place_minion(player, row_index, slot_index):
		return false

	player.board_rows[row_index][slot_index] = card

	return true
