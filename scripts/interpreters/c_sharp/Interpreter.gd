# CSharpInterpreter.gd (À utiliser comme script classique attaché à un nœud enfant d'une Unit)
extends Node

var is_running := false
var dynamic_script_instance: Object = null
var current_unit_target: Unit = null

@export var decision_delay := 1.5

func execute_code(code: String, current_unit: Unit) -> Dictionary:
	# On arrête l'ancienne boucle de CE paysan uniquement
	stop_execution()
	current_unit_target = current_unit
	
	# Utilisation de ton validateur (qui lui peut rester un Autoload/Singleton)
	var validation = CSharp_Validator.clean_and_validate(code)
	if not validation["is_valid"]:
		current_unit.log_to_editor(validation["error"], "error")
		return {"is_valid": false, "error": validation["error"], "clean_code": ""}
		
	var gdscript_code = transpile_to_gdscript(validation["clean_code"])
	
	var script = GDScript.new()
	script.set_source_code(gdscript_code)
	var error = script.reload()
	
	if error != OK:
		var compilation_error = "Erreur de transpilation interne (Code %d)." % error
		current_unit.log_to_editor(compilation_error, "error")
		return {"is_valid": false, "error": compilation_error, "clean_code": ""}
		
	dynamic_script_instance = script.new()
	start_decision_loop()
	
	current_unit.log_to_editor("Code C# compilé et appliqué avec succès !", "success")
	return {"is_valid": true, "error": "", "clean_code": validation["clean_code"]}

func stop_execution():
	is_running = false
	dynamic_script_instance = null

func start_decision_loop():
	is_running = true
	# La boucle s'exécute de manière autonome dans cette instance d'interpréteur
	while is_running and is_instance_valid(current_unit_target) and dynamic_script_instance != null:
		dynamic_script_instance.run(current_unit_target)
		await get_tree().create_timer(decision_delay).timeout

# --- Garde tes fonctions de transpilation inchangées en dessous ---
func transpile_to_gdscript(cs_code: String) -> String:
	# ... ton code de transpilation ...
	var gd_lines = []
	gd_lines.append("extends RefCounted\n")
	var lines = cs_code.split("\n")
	var indent_level = 0
	for line in lines:
		var clean_line = line.strip_edges()
		if clean_line == "" or clean_line.begins_with("namespace ") or "class " in clean_line:
			continue
		if "void Run(" in clean_line or "void Run()" in clean_line:
			gd_lines.append("func run(unit: Node):")
			indent_level = 1
			continue
		if clean_line == "{":
			continue
		if clean_line == "}":
			indent_level = max(0, indent_level - 1)
			continue
		var tabs = ""
		for i in range(indent_level):
			tabs += "\t"
		if clean_line.begins_with("if"):
			var start_parenthesis = clean_line.find("(")
			var end_parenthesis = clean_line.rfind(")")
			if start_parenthesis != -1 and end_parenthesis != -1:
				var condition = clean_line.substr(start_parenthesis + 1, (end_parenthesis - start_parenthesis) - 1)
				var gd_condition = transpile_line_content(condition)
				gd_lines.append(tabs + "if " + gd_condition + ":")
				indent_level += 1
			continue
		if clean_line.begins_with("else"):
			gd_lines.append(tabs + "else:")
			indent_level += 1
			continue
		var clean_instruction = clean_line.replace(";", "")
		var gd_instruction = transpile_line_content(clean_instruction)
		gd_lines.append(tabs + gd_instruction)
	return "\n".join(gd_lines)

func transpile_line_content(line: String) -> String:
	# ... ton code de transpile_line_content ...
	var result = line
	var types_to_replace = ["string ", "int ", "float ", "bool ", "double "]
	for type_cs in types_to_replace:
		if result.begins_with(type_cs):
			result = "var " + result.substr(type_cs.length())
			break
	var regex_gather = RegEx.new()
	regex_gather.compile("unit\\.Gather\\((.*?)\\)")
	result = regex_gather.sub(result, "unit.gather_closest_resource($1)", true)
	var regex_capacity = RegEx.new()
	regex_capacity.compile("unit\\.SetMaxCapacity\\((.*?)\\)")
	result = regex_capacity.sub(result, "unit.set_max_capacity($1)", true)
	result = result.replace("unit.Deposit()", "unit.deposit_at_closest_inn()")
	result = result.replace("unit.GetCarriedResources()", "unit.get_carried_resources()")
	result = result.replace("unit.GetMaxCapacity()", "unit.get_max_capacity()")
	result = result.replace("unit.IsEnemyNearby()", "unit.is_enemy_nearby()")
	result = result.replace("unit.AttackNearestEnemy()", "unit.attack_nearest_enemy()")
	return result
