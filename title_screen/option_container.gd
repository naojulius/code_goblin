extends HBoxContainer

signal color_changed(new_data: Dictionary, option_node)

@onready var label: Label = $Label
@onready var option_button: OptionButton = $OptionButton
@onready var color_rect: ColorRect = $ColorPanel/ColorRect


# Stocke l'ID de la couleur courante pour pouvoir annuler si doublon
var current_color_id: int = -1

var colors: Array[Dictionary] = [
	{"id": 0, "color_name": "RED", "hex_code": "E63946"},
	{"id": 1, "color_name": "ORANGE", "hex_code": "F4A261"},
	{"id": 2, "color_name": "YELLOW", "hex_code": "E9C46A"},
	{"id": 3, "color_name": "GREEN", "hex_code": "2A9D8F"},
	{"id": 4, "color_name": "BLUE", "hex_code": "4068A1"},
	{"id": 5, "color_name": "PURPLE", "hex_code": "7209B7"},
	{"id": 6, "color_name": "PINK", "hex_code": "F72585"},
	{"id": 7, "color_name": "BROWN", "hex_code": "8D5B4C"},
	{"id": 8, "color_name": "GRAY", "hex_code": "ADB5BD"}
]

func _ready() -> void:
	option_button.clear()
	
	for i in range(colors.size()):
		var color_data = colors[i]
		option_button.add_item(color_data["color_name"], i)
		option_button.set_item_metadata(i, color_data)

	option_button.item_selected.connect(_on_color_selected)

func _on_color_selected(index: int) -> void:
	var selected_data: Dictionary = option_button.get_item_metadata(index)
	# On informe le parent du choix demandé
	color_changed.emit(selected_data, self)

func get_random_color() -> Dictionary:
	return colors.pick_random()

## Appelé uniquement quand la couleur est validée (ou à l'init)
func set_option_data(data: Dictionary, _owner: String) -> void:
	current_color_id = data["id"]
	option_button.select(data["id"])
	color_rect.color = Color.html(data["hex_code"])
	
	if _owner.to_lower().begins_with("you"):
		GameManager.my_unit_color = Color(str("#", data["hex_code"]))

## Remet le menu déroulant sur la dernière couleur valide si le choix est rejeté
func revert_selection() -> void:
	if current_color_id != -1:
		option_button.select(current_color_id)
