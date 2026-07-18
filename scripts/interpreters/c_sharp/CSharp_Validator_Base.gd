# CSharp_Validator_Base.gd
extends Node
class_name CSharp_Validator_Base

func clean_and_validate(raw_code: String) -> Dictionary:
	var cleaned_code = remove_comments(raw_code)
	var braces_check = validate_braces_structure(cleaned_code)
	if not braces_check["is_valid"]: return braces_check

	var lines = cleaned_code.split("\n")
	var line_count = 0
	var current_allowed = get_allowed_methods()
	
	for line in lines:
		line_count += 1
		var clean_line = line.strip_edges()
		if clean_line == "" or clean_line == "{" or clean_line == "}": continue
		if clean_line.begins_with("namespace ") or "class " in clean_line or "void Run" in clean_line: continue

		var is_control = clean_line.begins_with("if") or clean_line.begins_with("else") or clean_line.begins_with("while")
		if not is_control and not clean_line.ends_with(";"):
			return {"is_valid": false, "error": "Erreur C# (Ligne %d) : ';' manquant." % line_count}

		if "unit." in clean_line:
			var regex = RegEx.new()
			regex.compile("unit\\.[a-zA-Z0-9_]+")
			for m in regex.search_all(clean_line):
				if not m.get_string() in current_allowed:
					return {"is_valid": false, "error": "Erreur C# (Ligne %d) : '%s' interdit." % [line_count, m.get_string()]}
	return {"is_valid": true, "error": "", "clean_code": cleaned_code}

func get_allowed_methods() -> Array: return []

func remove_comments(code: String) -> String:
	var result = code
	var regex = RegEx.new()
	regex.compile("(?s)/\\*.*?\\*/")
	result = regex.sub(result, "", true)
	var lines = result.split("\n")
	var cleaned = []
	for l in lines:
		var idx = l.find("//")
		cleaned.append(l.left(idx) if idx != -1 else l)
	return "\n".join(cleaned)

func validate_braces_structure(code: String) -> Dictionary:
	var open_braces = 0
	for line in code.split("\n"):
		for c in line:
			if c == "{": open_braces += 1
			elif c == "}":
				open_braces -= 1
				if open_braces < 0: return {"is_valid": false, "error": "Accolade fermante en trop."}
	return {"is_valid": true} if open_braces == 0 else {"is_valid": false, "error": "Accolade non fermée."}
