extends Control

func _ready() -> void:
	if not $title:
		push_error("$title not found")
		return
	if not $subt:
		push_error("$subt not found")
		return

	GlobalTweens.typewriter($title, "Welcome to GlobalTweens DEMO")
	GlobalTweens.label_rainbow($title, 0.1, 0.8)
	GlobalTweens.typewriter($subt, "Yep Title & Sub-title are tweens effect", 0.06)


func _on_sprite_tw_mouse_entered() -> void:
	GlobalTweens.button_hover($SpriteTW)

func _on_sprite_tw_mouse_exited() -> void:
	GlobalTweens.button_unhover($SpriteTW)


func _on_btn_tw_mouse_entered() -> void:
	GlobalTweens.button_hover($BtnTW)

func _on_btn_tw_mouse_exited() -> void:
	GlobalTweens.button_unhover($BtnTW)


func _on_sprite_tw_pressed() -> void:
	GlobalTweens.button_press($SpriteTW)
	GlobalTweens.scene_fade_change(get_tree(), "res://demo.tscn")
	

func _on_btn_tw_pressed() -> void:
	GlobalTweens.button_press($BtnTW)
	GlobalTweens.scene_slide_change(get_tree(), "res://demo.tscn")
