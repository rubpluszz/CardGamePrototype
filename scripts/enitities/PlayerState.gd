class_name PlayerState
extends RefCounted

var health: int = 20
var max_health: int = 20

var max_mana: int = 10
var current_mana: int = 1
var mana_per_turn: int = 1

var turns_started: int = 0

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

var starting_hand_size: int = 3
var max_hand_size: int = 5

# Ряди бойового поля: 4, 3 та 2 слоти.
var board_rows: Array = [
	[null, null, null, null],
	[null, null, null],
	[null, null]
]

func take_damage(amount: int) -> void:
	health = max(0, health - amount)

func heal(amount: int) -> void:
	health = min(max_health, health + amount)
