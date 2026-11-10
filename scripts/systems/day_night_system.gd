class_name DayNightSystem
extends RefCounted

const TURNS_PER_PHASE: int = 4


func should_change_time(turn_number: int) -> bool:
	return (
		turn_number > 1
		and (turn_number - 1) % TURNS_PER_PHASE == 0
	)


func get_next_time(current_time: int) -> int:
	if current_time == GameState.TimeOfDay.DAY:
		return GameState.TimeOfDay.NIGHT

	return GameState.TimeOfDay.DAY
