class_name DeckSystem
extends RefCounted


func setup_player(
	player: PlayerState,
	cards: Array[CardData],
	initial_hand: int,
	hand_limit: int
) -> bool:

	if cards.size() != 50:
		push_error(
            "Deck must contain exactly 50 cards. Current: %d"
			% cards.size()
		)
		return false

	player.draw_pile = cards.duplicate()
	player.draw_pile.shuffle()

	player.hand.clear()
	player.discard_pile.clear()

	player.starting_hand_size = clampi(initial_hand, 3, 5)
	player.max_hand_size = maxi(hand_limit, player.starting_hand_size)

	player.turns_started = 0

	draw_cards(player, player.starting_hand_size)

	return true


func draw_cards(player: PlayerState, amount: int) -> int:
	var drawn: int = 0

	while drawn < amount:
		if player.draw_pile.is_empty():
			break

		if player.hand.size() >= player.max_hand_size:
			break

		var card: CardData = player.draw_pile.pop_back()
		player.hand.append(card)
		drawn += 1

	return drawn


func draw_to_hand_limit(player: PlayerState) -> int:
	var cards_needed: int = (player.max_hand_size - player.hand.size())

	if cards_needed <= 0:
		return 0

	return draw_cards(player, cards_needed)


func increase_hand_limit(player: PlayerState, amount: int) -> void:
	if amount <= 0:
		return

	player.max_hand_size += amount
