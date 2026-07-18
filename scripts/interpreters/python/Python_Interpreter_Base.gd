# Python_Interpreter_Base.gd
extends Interpreter_Base
class_name Python_Interpreter_Base

var validator: Python_Validator_Base = null

func _ready() -> void: _setup_validator()
func _setup_validator() -> void: pass

func execute_code(code: String, current_unit: CharacterBody2D) -> Dictionary:
	stop_execution()
	current_unit_target = current_unit
	
	var validation = validator.clean_and_validate(code)
	if not validation["is_valid"]: return validation
		
	var gdscript_code = transpile_to_gdscript(validation["clean_code"])
	var script = GDScript.new()
	script.set_source_code(gdscript_code)
	if script.reload() != OK:
		return {"is_valid": false, "error": "Erreur interne de compilation Python."}
		
	dynamic_script_instance = script.new()
	start_decision_loop()
	return {"is_valid": true, "error": ""}

func transpile_to_gdscript(py_code: String) -> String:
	var gd_lines = ["extends RefCounted\n"]
	
	for line in py_code.split("\n"):
		var indent = ""
		for i in range(line.length()):
			if line[i] == "\t" or line[i] == " ": indent += line[i]
			else: break
				
		var clean = line.strip_edges()
		if clean == "": continue
		if clean.begins_with("def run(unit):") or clean.begins_with("def run(unit) :"):
			gd_lines.append("func run(unit: Node):")
			continue
			
		gd_lines.append(indent + transpile_line_content(clean))
	return "\n".join(gd_lines)

func transpile_line_content(line: String) -> String:
	var result = line.replace("True", "true").replace("False", "false").replace("None", "null")
	
	# Détection et ajout de 'var' pour les variables locales Python
	if "=" in result and not result.strip_edges().begins_with("unit."):
		var parts = result.split("=")
		var left_side = parts[0].strip_edges()
		if not result.strip_edges().begins_with("if") and not result.strip_edges().begins_with("elif") and not "==" in left_side:
			if not left_side.begins_with("var "):
				result = "var " + result
	
	# --- CORRECTION : Mapping complet de l'API (Toutes les casses) ---
	
	# 1. Gestion de Deposit
	result = result.replace("unit.Deposit()", "unit.deposit_at_closest_inn()")
	result = result.replace("unit.deposit()", "unit.deposit_at_closest_inn()")
	
	# 2. Gestion de get_carried_resources (les 3 écritures possibles par le joueur)
	result = result.replace("unit.GetCarriedResources()", "unit.get_carried_resources()")
	result = result.replace("unit.getCarriedResources()", "unit.get_carried_resources()") # <-- Manquait ici !
	result = result.replace("unit.get_carried_resources()", "unit.get_carried_resources()")
	
	# 3. Gestion de get_max_capacity
	result = result.replace("unit.GetMaxCapacity()", "unit.get_max_capacity()")
	result = result.replace("unit.getMaxCapacity()", "unit.get_max_capacity()") # <-- Manquait ici !
	result = result.replace("unit.get_max_capacity()", "unit.get_max_capacity()")
	
	# 4. Gestion de is_enemy_nearby
	result = result.replace("unit.IsEnemyNearby()", "unit.is_enemy_nearby()")
	result = result.replace("unit.isEnemyNearby()", "unit.is_enemy_nearby()")
	result = result.replace("unit.is_enemy_nearby()", "unit.is_enemy_nearby()")
	
	# 5. Gestion des fonctions à arguments (RegEx)
	var reg_gather = RegEx.new(); reg_gather.compile("unit\\.[gG]ather\\((.*?)\\)")
	result = reg_gather.sub(result, "unit.gather_closest_resource($1)", true)
	
	var reg_cap = RegEx.new(); reg_cap.compile("unit\\.[sS]etMaxCapacity\\((.*?)\\)")
	result = reg_cap.sub(result, "unit.set_max_capacity($1)", true)
	
	return result
