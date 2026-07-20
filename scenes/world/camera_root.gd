extends Node2D

const CAMERA_MIN_ZOOM: float = 1.5
const CAMERA_MAX_ZOOM: float = 2.0
const CAMERA_ZOOM_SPEED: float = 2.0
const CAMERA_ZOOM_STEP: float = 0.15

@onready var camera: Camera2D = $Camera

@export_group("Déplacements Clavier")
@export var move_speed: float = 400.0

@export_group("Déplacements Souris (Bords d'Écran)")
@export var edge_scrolling: bool = true
@export var edge_threshold: float = 15.0

# Variable cible pour le zoom lissé (Défini à 0.5 par défaut)
var _target_zoom: float = 2.0

func _ready() -> void:
		
	place_camera()

func place_camera():
	var inn = get_tree().get_first_node_in_group("inns")
	if inn:
		global_position = inn.global_position
	
func _process(delta: float) -> void:
	# 1. Lissage du zoom
	if camera:
		camera.zoom = camera.zoom.lerp(Vector2(_target_zoom, _target_zoom), CAMERA_ZOOM_SPEED * delta)

	# 2. Déplacement clavier et souris
	var velocity := Vector2.ZERO

	if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		velocity.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		velocity.y += 1
	if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		velocity.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		velocity.x += 1

	if edge_scrolling and not Engine.is_editor_hint():
		var mouse_pos := get_viewport().get_mouse_position()
		var viewport_size := get_viewport().get_visible_rect().size

		if mouse_pos.x <= edge_threshold:
			velocity.x -= 1
		elif mouse_pos.x >= viewport_size.x - edge_threshold:
			velocity.x += 1

		if mouse_pos.y <= edge_threshold:
			velocity.y -= 1
		elif mouse_pos.y >= viewport_size.y - edge_threshold:
			velocity.y += 1

	# 3. Application du mouvement sans restriction
	if velocity != Vector2.ZERO:
		velocity = velocity.normalized()
		var zoom_factor := 1.0 / camera.zoom.x
		global_position += velocity * move_speed * zoom_factor * delta

func _input(event: InputEvent) -> void:
	# --- Molette de la souris ---
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_target_zoom = min(_target_zoom + CAMERA_ZOOM_STEP, CAMERA_MAX_ZOOM)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_target_zoom = max(_target_zoom - CAMERA_ZOOM_STEP, CAMERA_MIN_ZOOM)
