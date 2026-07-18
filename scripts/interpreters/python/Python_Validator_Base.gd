# Python_Validator_Base.gd
extends Node
class_name Python_Validator_Base

func clean_and_validate(raw_code: String) -> Dictionary:
	var cleaned_code = remove_comments(raw_code)
	var lines = cleaned_code.split("\n")
	var line_count = 0
	var current_allowed = get_allowed_methods()
	var has_run = false

	for line in lines:
		line_count += 1
		var clean_line = line.strip_edges()
		if clean_line == "": continue
		if clean_line.begins_with("def run(unit):") or clean_line.begins_with("def run(unit) :"):
			has_run = true
			continue

		if "unit." in clean_line:
			var regex = RegEx.new()
			regex.compile("unit\\.[a-zA-Z0-9_]+")
			for m in regex.search_all(clean_line):
				if not m.get_string().to_lower() in current_allowed:
					return {"is_valid": false, "error": "Erreur Python (Ligne %d) : '%s' inconnu." % [line_count, m.get_string()]}

	if not has_run: return {"is_valid": false, "error": "Fonction 'def run(unit):' manquante."}
	return {"is_valid": true, "error": "", "clean_code": cleaned_code}

func get_allowed_methods() -> Array: return []

func remove_comments(code: String) -> String:
	var lines = code.split("\n")
	var cleaned = []
	for l in lines:
		var idx = l.find("#")
		cleaned.append(l.left(idx) if idx != -1 else l)
	return "\n".join(cleaned)
