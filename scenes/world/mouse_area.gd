extends Area2D

@onready var debug_view: Sprite2D = $MouseAreaCollision/DebugView

# Compteur pour gérer le chevauchement de plusieurs zones
var _overlapping_panels_count: int = 0

func _ready() -> void:
	debug_view.hide()
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _on_area_entered(area: Area2D) -> void:
	if _is_target_area(area):
		_overlapping_panels_count += 1
		_update_mouse_manager()

func _on_area_exited(area: Area2D) -> void:
	if _is_target_area(area):
		_overlapping_panels_count = max(0, _overlapping_panels_count - 1)
		_update_mouse_manager()

func _is_target_area(area: Area2D) -> bool:
	return area.is_in_group("panel_manager_area") or area.is_in_group("code_manager_area")

func _update_mouse_manager() -> void:
	# Tant qu'on est dans au moins 1 zone, ça reste à 'true'
	MouseManager.is_mouse_inside_panel_manager = (_overlapping_panels_count > 0)
