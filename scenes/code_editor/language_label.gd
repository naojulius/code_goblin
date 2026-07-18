extends Label

func _process(_delta: float) -> void:
	if (text != InterpreterManager.current_language.capitalize()):
		text = str(InterpreterManager.current_language.capitalize())
