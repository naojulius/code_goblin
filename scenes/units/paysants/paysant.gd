# Paysant.gd
extends Unit
class_name Paysant
const STRING_NAME: String = "Paysant"
@export var base_speed := 40.0
@export var max_resource_capacity := 10

var _resources_carried := 0
var _resource_carried_name := ""

# Surcharge de la méthode d'initialisation pour attribuer le bon interpréteur
func _initialize_interpreter() -> void:
	interpreter = InterpreterManager.get_interpreter(STRING_NAME)
	add_child(interpreter)
	
	match InterpreterManager.current_language:
		"c#":
			code_layer.text_edit.text = PaysantDefaultCode.DEFAULT_CSHARP_CODE
		"python":
			code_layer.text_edit.text = PaysantDefaultCode.DEFAULT_PYTHON_CODE
			
	code_layer.file_button.text = str(STRING_NAME, InterpreterManager.file_extension)
	code_layer.text_edit.syntax_highlighter = InterpreterManager.get_highlighter()
	code_layer.update_lines()
# --- API appelée par l'interpréteur C# ---

func set_max_capacity(new_capacity: int) -> void:
	update_stats_from_capacity(new_capacity)

func get_max_capacity() -> int:
	return max_resource_capacity

# --- Système interne de poids ---

func update_stats_from_capacity(chosen_capacity: int) -> void:
	max_resource_capacity = chosen_capacity
	
	if chosen_capacity <= 0 or chosen_capacity > 10:
		speed = 0.0
		log_to_editor("Surcharge ou capacité invalide (%d) ! Le paysan est immobile." % chosen_capacity, "warning")
	else:
		speed = base_speed - chosen_capacity

# --- Capteurs & Actions ---

func get_carried_resources() -> int:
	return _resources_carried

func is_enemy_nearby() -> bool:
	var closest_enemy = find_closest_in_group("enemies")
	if closest_enemy != null:
		var distance = global_position.distance_to(closest_enemy.global_position)
		if distance <= 150.0:
			return true
	return false

func gather_closest_resource(resource_group: String) -> void:
	if speed <= 0.0:
		log_to_editor("Impossible de se déplacer : surcharge ou capacité nulle !", "error")
		return

	var group_name = resource_group.to_lower()
	var closest_resource = find_closest_in_group(group_name)
	_resource_carried_name = group_name
	
	if not is_instance_valid(current_target_node):
		current_target_node = null
	
	if closest_resource != null:
		current_target_node = closest_resource
		
		if is_arrived_at_node(closest_resource):
			_resources_carried = max_resource_capacity
			closest_resource.gather(_resources_carried)
			if closest_resource and closest_resource.has_method("add_label"):
				closest_resource.add_label(str("- ", _resources_carried), closest_resource.global_position)
				
			log_to_editor("Arrivé ! Récolte de %s terminée. Sac : %d/%d" % [group_name, _resources_carried, max_resource_capacity], "success")
			
			if navigation_agent:
				navigation_agent.set_target_position(global_position)
		else:
			move_to_target(closest_resource.global_position)
	else:
		if navigation_agent:
			navigation_agent.set_target_position(global_position)
		log_to_editor("Aucune ressource du groupe '%s' trouvée !" % group_name, "error")

func deposit_at_closest_inn() -> void:
	if speed <= 0.0:
		log_to_editor("Impossible de se déplacer : surcharge ou capacité nulle !", "error")
		return

	var closest_inn = find_closest_in_group("inns")
	if closest_inn != null:
		current_target_node = closest_inn
		
		if is_arrived_at_node(closest_inn):
			_update_resource()
			_resources_carried = 0
			current_target_node = null 
			
			if navigation_agent:
				navigation_agent.set_target_position(global_position)
				
			log_to_editor("Arrivé à l'auberge ! Ressources déposées.", "success")
		else:
			move_to_target(closest_inn.global_position)
	else:
		log_to_editor("Aucune auberge trouvée !", "error")

func attack_nearest_enemy() -> void:
	if speed <= 0.0:
		return
	var closest_enemy = find_closest_in_group("enemies")
	if closest_enemy != null:
		current_target_node = closest_enemy
		move_to_target(closest_enemy.global_position)
	else:
		log_to_editor("Aucun ennemi trouvé.", "info")

func _update_resource() -> void:
	match _resource_carried_name:
		"wood":
			ResourceManager.wood += _resources_carried
			add_label(str(_resource_carried_name, "+ ", _resources_carried), current_target_node)
		"stone":
			ResourceManager.stone += _resources_carried
			add_label(str(_resource_carried_name, "+ ", _resources_carried), current_target_node)

func add_label(text: String, target: Variant) -> void:
	if target and target.has_method("add_label"):
		target.add_label(text, target.global_position)
