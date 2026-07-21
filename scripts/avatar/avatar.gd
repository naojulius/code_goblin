extends Panel

func _ready() -> void:
	var player = get_node_or_null("AnimationPlayer")
	if player and not player.is_playing():
		player.play("init")
		
