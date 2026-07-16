extends Panel

@onready var wood_label: Label = $HBoxContainer/WoodLabel
@onready var gold_label: Label = $HBoxContainer/GoldLabel
@onready var stone_label: Label = $HBoxContainer/StoneLabel
@onready var population_label: Label = $HBoxContainer/PopulationLabel


func _process(_delta: float) -> void:
	wood_label.text = str("Wood: ", ResourceManager.wood)
	gold_label.text = str("Gold: ", ResourceManager.gold)
	stone_label.text = str("Stone: ", ResourceManager.stone)
	population_label.text = str("Population: ", ResourceManager.population)
	
	
