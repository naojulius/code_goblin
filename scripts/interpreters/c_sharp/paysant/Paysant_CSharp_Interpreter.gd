# Paysant_CSharp_Interpreter.gd
extends CSharp_Interpreter_Base
class_name Paysant_CSharp_Interpreter

func _setup_validator() -> void:
	validator = Paysant_CSharp_Validator.new()
	add_child(validator)
