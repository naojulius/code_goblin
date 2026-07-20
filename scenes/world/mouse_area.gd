extends Area2D
@onready var debug_view: Sprite2D = $MouseAreaCollision/DebugView

func _ready() -> void:
	debug_view.hide()
	connect("area_entered", _on_ara_entered)
	connect("area_exited", _on_ara_exited)
	

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _on_ara_entered(area: Area2D):
	if area.is_in_group("panel_manager_area"):
		MouseManager.is_mouse_inside_panel_manager = true
	
func _on_ara_exited(area: Area2D):
	if area.is_in_group("panel_manager_area"):
		MouseManager.is_mouse_inside_panel_manager = false
