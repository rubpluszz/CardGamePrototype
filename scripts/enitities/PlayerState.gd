class_name PlayerState
extends RefCounted

var health: int = 20
var max_health: int = 20

var mana: int = 0
var max_mana: int = 0

var hand: Array = []
var deck: Array = []
var battlefield: Array = []

func take_damage(amount: int) -> void:
	health = max(0, health - amount)

func heal(amount: int) -> void:
	health = min(max_health, health + amount)
