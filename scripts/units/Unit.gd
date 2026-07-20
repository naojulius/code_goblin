# Unit.gd
class_name Unit
extends CharacterBody2D

const CODE_LAYER = preload("uid://cur7q1g1vtooo")

@export var speed := 30.0
@onready var sensor_area: Area2D = $SensorArea
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var box_selector: Node2D = $BoxSelector


var current_target_node: Node2D = null
@export var interaction_distance := 25.0

var code_layer: Control = null
var commands: Array[PackedScene] = []

# --- SAUVEGARDE DU CODE DU JOUEUR ---
# Cette variable permet à l'éditeur de recharger le code propre à chaque unité
var saved_code: String = ""
var default_code: String = ""

# Déclaré avec le type de la classe de base pour accepter n'importe quel enfant (Paysant, Soldat...)
var interpreter: Interpreter_Base = null

var is_unit_selected: bool = false

func _ready() -> void:
	add_to_group("populations")
	code_layer = CODE_LAYER.instantiate()
	canvas_layer.add_child(code_layer)
	code_layer.current_unit = self
	
	sensor_area.connect("input_event", _on_sensor_area_input_event)
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	# Appel de la méthode d'initialisation (qui sera surchargée par les enfants)
	_initialize_interpreter()
	
func _initialize_interpreter() -> void:
	# Par défaut, une unité générique n'a pas d'interpréteur de code, ou un interpréteur vide.
	pass
	
func apply_code(csharp_code: String) -> void:
	if interpreter:
		interpreter.execute_code(csharp_code, self)

func _physics_process(_delta: float) -> void:
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
		
	if navigation_agent.is_navigation_finished():
		return
	
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
		
func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func move_to_target(movement_target: Vector2) -> void:
	navigation_agent.set_target_position(movement_target)
	
func is_arrived_at_node(node: Node2D) -> bool:
	if node == null:
		return false
	return global_position.distance_to(node.global_position) <= interaction_distance

func find_closest_in_group(group_name: String) -> Node2D:
	var nodes = get_tree().get_nodes_in_group(group_name)
	var closest_node: Node2D = null
	var min_distance = INF
	for node in nodes:
		if node is Node2D:
			var dist = global_position.distance_to(node.global_position)
			if dist < min_distance:
				min_distance = dist
				closest_node = node
	return closest_node

func _on_sensor_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			PanelManager.current_commands.append_array(commands)
			box_selector.show_box_selector()
			is_unit_selected = true
			#code_layer.show_editor()
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MOUSE_LEFT") and is_unit_selected and not MouseManager.is_mouse_inside_panel_manager:
		box_selector.hide_box_selector()
		is_unit_selected = false
		PanelManager.current_commands.clear()
			
func log_to_editor(message: String, type: String = "info") -> void:
	if code_layer and code_layer.has_method("log_message"):
		code_layer.log_message(message, type)
	else:
		print("[%s - %s] %s" % [name, type.to_upper(), message])
