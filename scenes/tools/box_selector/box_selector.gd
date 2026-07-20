extends Node2D

var tween : Tween = null

func _ready() -> void:
	add_to_group("box_selectors")
	#animate_box_selector()
	hide_box_selector()

func show_box_selector():
	for selector in get_tree().get_nodes_in_group("box_selectors"):
		selector.hide_box_selector()
		
	if not visible:
		show()

func hide_box_selector():
	if visible:
		hide()

func animate_box_selector():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_loops()
	
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
