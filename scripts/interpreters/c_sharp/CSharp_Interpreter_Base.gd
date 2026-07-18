# CSharp_Interpreter_Base.gd
extends Interpreter_Base
class_name CSharp_Interpreter_Base

var validator: CSharp_Validator_Base = null

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
		return {"is_valid": false, "error": "Erreur de compilation interne."}
		
	dynamic_script_instance = script.new()
	start_decision_loop()
	return {"is_valid": true, "error": ""}

func transpile_to_gdscript(cs_code: String) -> String:
	var gd_lines = ["extends RefCounted\n"]
	var indent_level = 0
	
	for line in cs_code.split("\n"):
		var clean = line.strip_edges()
		if clean == "" or clean.begins_with("namespace ") or "class " in clean: continue
		if "void Run" in clean:
			gd_lines.append("func run(unit: Node):")
			indent_level = 1
			continue
		if clean == "{": continue
		if clean == "}":
			indent_level = max(0, indent_level - 1)
			continue
			
		var tabs = ""
		for i in range(indent_level): tabs += "\t"
			
		if clean.begins_with("if") or clean.begins_with("else if") or clean.begins_with("while"):
			var prefix = "elif " if clean.begins_with("else if") else ("while " if clean.begins_with("while") else "if ")
			var start = clean.find("(")
			var end = clean.rfind(")")
			if start != -1 and end != -1:
				var cond = clean.substr(start + 1, (end - start) - 1)
				gd_lines.append(tabs + prefix + transpile_line_content(cond) + ":")
				indent_level += 1
			continue
			
		if clean.begins_with("else"):
			gd_lines.append(tabs + "else:")
			indent_level += 1
			continue
			
		gd_lines.append(tabs + transpile_line_content(clean.replace(";", "")))
	return "\n".join(gd_lines)

func transpile_line_content(line: String) -> String:
	var result = line
	for t in ["string ", "int ", "float ", "bool "]:
		if result.begins_with(t): result = "var " + result.substr(t.length()); break
	
	# Gestion des ternaires C# (cond ? vrai : faux) -> (vrai if cond else faux)
	var tern_regex = RegEx.new()
	tern_regex.compile("(=|\\b)\\s*(.*?)\\s*\\?\\s*(.*?)\\s*:\\s*(.*)")
	var match = tern_regex.search(result)
	if match:
		var pref = result.split("?")[0].substr(0, result.find("="))
		result = "%s= %s if %s else %s" % [pref, match.get_string(3).strip_edges(), match.get_string(2).strip_edges(), match.get_string(4).strip_edges()]

	result = result.replace("&&", " and ").replace("||", " or ").replace("!unit.", "not unit.")
	
	# Mapping API RTS
	result = result.replace("unit.Deposit()", "unit.deposit_at_closest_inn()")
	result = result.replace("unit.GetCarriedResources()", "unit.get_carried_resources()")
	result = result.replace("unit.GetMaxCapacity()", "unit.get_max_capacity()")
	result = result.replace("unit.IsEnemyNearby()", "unit.is_enemy_nearby()")
	
	var reg_gather = RegEx.new(); reg_gather.compile("unit\\.Gather\\((.*?)\\)")
	result = reg_gather.sub(result, "unit.gather_closest_resource($1)", true)
	var reg_cap = RegEx.new(); reg_cap.compile("unit\\.SetMaxCapacity\\((.*?)\\)")
	result = reg_cap.sub(result, "unit.set_max_capacity($1)", true)
	
	return result
