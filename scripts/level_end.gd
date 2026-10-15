extends Area2D

@export_file("*.tscn") var next_level: String

func _on_body_entered(_body: Node2D) -> void:
	call_deferred("load_next_level")
	
func load_next_level():
	if next_level:
		return get_tree().change_scene_to_file(next_level)
		
	push_error("next_level not found")
