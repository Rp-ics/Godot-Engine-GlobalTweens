extends Button



func _ready() -> void:
	self.pivot_offset = Vector2(self.size.x / 2, self.size.y / 2)

func _on_mouse_entered() -> void:
	GlobalTweens.button_hover($".")

func _on_mouse_exited() -> void:
	GlobalTweens.button_unhover($".")


func _on_pressed() -> void:
	GlobalTweens.button_press($".")
