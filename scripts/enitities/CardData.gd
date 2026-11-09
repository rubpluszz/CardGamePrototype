class_name CardData
extends Resource

@export var id: String
@export var title: String
@export_multiline var description: String

@export var mana_cost: int = 1

@export var attack: int = 0
@export var health: int = 0

@export_enum("Minion", "Spell", "Weapon")
var card_type: String = "Minion"

@export var artwork: Texture2D
