extends "res://Light.gd"

func _on_Area_body_entered(body):
	if !body.is_in_group("Player"):
		return
	status = FLICKERING
