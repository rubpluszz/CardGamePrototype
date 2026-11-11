class_name ManaSystem
extends RefCounted


func initialize_player(player: PlayerState) -> void:
	player.current_mana = 1


func start_turn(player: PlayerState) -> void:
	player.current_mana = min(
		player.current_mana + player.mana_per_turn,
		player.max_mana
	)


func can_afford(player: PlayerState, cost: int) -> bool:
	return cost >= 0 and player.current_mana >= cost


func spend_mana(player: PlayerState, cost: int) -> bool:
	if not can_afford(player, cost):
		return false

	player.current_mana -= cost
	return true
