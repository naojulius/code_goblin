# Paysant_Python_Interpreter.gd
extends Python_Interpreter_Base
class_name Paysant_Python_Interpreter

func _setup_validator() -> void:
	validator = Paysant_Python_Validator.new()
	add_child(validator)
