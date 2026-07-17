# CodeValidator.gd (Autoload ou script simple)
extends Node

const ALLOWED_UNIT_METHODS = [
	"unit.Gather",
	"unit.SetMaxCapacity",
	"unit.GetMaxCapacity()",
	"unit.Deposit()",
	"unit.GetCarriedResources()",
	"unit.IsEnemyNearby()",
	"unit.AttackNearestEnemy()"
]

# Analyse complète du snippet C# du joueur
func clean_and_validate(raw_code: String) -> Dictionary:
	# 1. On retire les commentaires pour ne pas fausser l'analyse
	var cleaned_code = remove_comments(raw_code)
	
	# 2. Vérification des accolades globales
	var braces_check = validate_braces_structure(cleaned_code)
	if not braces_check["is_valid"]:
		return braces_check

	# 3. Analyse ligne par ligne (Syntaxe C#)
	var lines = cleaned_code.split("\n")
	var line_count = 0
	var declared_variables = {} # Stocke {"nom_var": "type"}
	
	# Regex pour détecter les variables C# (ex: string maVar = "valeur"; ou int limite = 5;)
	var var_regex = RegEx.new()
	var_regex.compile("^(string|int|float|bool)\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*=\\s*(.*)")

	for line in lines:
		line_count += 1
		var clean_line = line.strip_edges()
		
		# On ignore les lignes vides et les accolades isolées
		if clean_line == "" or clean_line == "{" or clean_line == "}":
			continue
			
		# On ignore la déclaration du namespace, de la classe et de la fonction Run
		if clean_line.begins_with("namespace ") or "class " in clean_line or "void Run()" in clean_line:
			if clean_line.begins_with("namespace ") and not clean_line.ends_with(";"):
				return {"is_valid": false, "error": "Erreur (Ligne %d) : Un namespace C# doit se terminer par ';'" % line_count}
			continue

		# --- RÈGLE 1 : Le Point-virgule obligatoire en C# ---
		# Les lignes d'instructions (hors if, else, accolades) doivent finir par un point-virgule
		if not clean_line.begins_with("if") and not clean_line.begins_with("else") and not clean_line.ends_with(";"):
			return {
				"is_valid": false, 
				"error": "Erreur de syntaxe C# (Ligne %d) : Point-virgule ';' manquant en fin de ligne." % line_count
			}

		# Enlever le point-virgule pour simplifier les analyses suivantes
		var instruction = clean_line.trim_suffix(";")

		# --- RÈGLE 2 : Détection des variables et validation de leur valeur ---
		var var_match = var_regex.search(instruction)
		if var_match:
			var type = var_match.get_string(1)
			var var_name = var_match.get_string(2)
			var value = var_match.get_string(3).strip_edges()
			
			# Validation rapide du type de valeur assignée
			if type == "string" and not (value.begins_with("\"") and value.ends_with("\"")):
				return {"is_valid": false, "error": "Erreur (Ligne %d) : La valeur de '%s' doit être entre guillemets (ex: \"trees\")." % [line_count, var_name]}
			if type == "int" and not value.is_valid_int():
				return {"is_valid": false, "error": "Erreur (Ligne %d) : La valeur de '%s' doit être un nombre entier." % [line_count, var_name]}
			
			declared_variables[var_name] = type
			continue

		# --- RÈGLE 3 : Validation de unit.Gather(...) ---
		if "unit.Gather" in instruction:
			var arg = extract_argument(instruction, "unit.Gather")
			if arg == "":
				return {"is_valid": false, "error": "Erreur (Ligne %d) : 'unit.Gather' attend un argument." % line_count}
			
			# Si l'argument n'est pas du texte brut ("arbre"), c'est une variable. On vérifie si elle existe.
			if not (arg.begins_with("\"") and arg.ends_with("\"")):
				if not declared_variables.has(arg):
					return {"is_valid": false, "error": "Erreur (Ligne %d) : La variable '%s' n'est pas définie." % [line_count, arg]}
				if declared_variables[arg] != "string":
					return {"is_valid": false, "error": "Erreur (Ligne %d) : 'unit.Gather' attend un type 'string', mais '%s' est un '%s'." % [line_count, arg, declared_variables[arg]]}

		# --- RÈGLE 4 : Validation de unit.SetMaxCapacity(...) ---
		if "unit.SetMaxCapacity" in instruction:
			var arg = extract_argument(instruction, "unit.SetMaxCapacity")
			if arg == "":
				return {"is_valid": false, "error": "Erreur (Ligne %d) : 'unit.SetMaxCapacity' attend un nombre." % line_count}
			
			if not arg.is_valid_int():
				# Si ce n'est pas un chiffre brut, est-ce une variable int ?
				if not declared_variables.has(arg) or declared_variables[arg] != "int":
					return {"is_valid": false, "error": "Erreur (Ligne %d) : '%s' doit être un nombre entier ou une variable de type 'int'." % [line_count, arg]}

		# --- RÈGLE 5 : Sécurité générale (Méthodes inconnues ou interdites) ---
		if "unit." in instruction:
			var is_allowed = false
			for method in ALLOWED_UNIT_METHODS:
				if method in instruction:
					is_allowed = true
					break
			if not is_allowed:
				return {"is_valid": false, "error": "Erreur (Ligne %d) : Appel de fonction non autorisé sur 'unit'." % line_count}

	return {"is_valid": true, "error": "", "clean_code": cleaned_code}

# Nettoie les commentaires du code
func remove_comments(code: String) -> String:
	var result = code
	var regex = RegEx.new()
	regex.compile("(?s)/\\*.*?\\*/") # Supprime /* ... */
	result = regex.sub(result, "", true)
	
	var lines = result.split("\n")
	var cleaned_lines = []
	for line in lines:
		var comment_idx = line.find("//")
		if comment_idx != -1:
			cleaned_lines.append(line.left(comment_idx))
		else:
			cleaned_lines.append(line)
	return "\n".join(cleaned_lines)

# Vérifie l'équilibre des accolades
func validate_braces_structure(code: String) -> Dictionary:
	var open_braces = 0
	var line_num = 0
	for line in code.split("\n"):
		line_num += 1
		for _char in line:
			if _char == "{":
				open_braces += 1
			elif _char == "}":
				open_braces -= 1
				if open_braces < 0:
					return {"is_valid": false, "error": "Erreur (Ligne %d) : Accolade fermante '}' sans accolade ouvrante '{' correspondante." % line_num}
	if open_braces != 0:
		return {"is_valid": false, "error": "Erreur de syntaxe globale : Accolade '{' non refermée dans le code."}
	return {"is_valid": true}

# Utilitaire pour extraire le contenu des parenthèses d'une méthode
func extract_argument(line: String, method_name: String) -> String:
	var start = line.find(method_name + "(")
	if start == -1: return ""
	start += method_name.length() + 1
	var end = line.find(")", start)
	if end == -1: return ""
	return line.substr(start, end - start).strip_edges()
