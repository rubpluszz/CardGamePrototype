extends Button

@onready var mana_cost_label: Label = $MarginContainer/VBoxContainer/ManaCost
@onready var title_label: Label = $MarginContainer/VBoxContainer/Title
@onready var artwork: TextureRect = $MarginContainer/VBoxContainer/Artwork
@onready var description_label: Label = $MarginContainer/VBoxContainer/Description
@onready var stats_label: Label = $MarginContainer/VBoxContainer/Stats


func set_card(card_data: CardData, current_mana: int) -> void:
	mana_cost_label.text = str(card_data.mana_cost)
	title_label.text = card_data.title
	description_label.text = card_data.description

	artwork.texture = card_data.artwork

	stats_label.text = "%d / %d" % [
		card_data.attack,
		card_data.health
	]

	# Візуально показуємо, чи вистачає мани.
	disabled = current_mana < card_data.mana_cost
