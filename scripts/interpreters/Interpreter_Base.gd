# Interpreter_Base.gd
extends Node
class_name Interpreter_Base

var is_running := false
var dynamic_script_instance: Object = null
var current_unit_target: CharacterBody2D = null

@export var decision_delay := 1.5

func execute_code(_code: String, _current_unit: CharacterBody2D) -> Dictionary:
	# À surcharger par les interpréteurs spécifiques
	return {"is_valid": false, "error": "Interpréteur non configuré."}

func stop_execution() -> void:
	is_running = false
	dynamic_script_instance = null

func start_decision_loop() -> void:
	is_running = true
	while is_running and is_instance_valid(current_unit_target) and dynamic_script_instance != null:
		dynamic_script_instance.run(current_unit_target)
		await get_tree().create_timer(decision_delay).timeout
