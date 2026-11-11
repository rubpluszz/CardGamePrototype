class_name PlayerState
extends RefCounted

var health: int = 20
var max_health: int = 20

var max_mana: int = 10
var current_mana: int = 1
var mana_per_turn: int = 1

var turns_started: int = 0

var hand: Array = []
var deck: Array = []
var battlefield: Array = []

func take_damage(amount: int) -> void:
	health = max(0, health - amount)

func heal(amount: int) -> void:
	health = min(max_health, health + amount)
