extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("item_selected", item_selected)

func item_selected(item):
	InterpreterManager.current_language = get_item_text(item).to_lower()
