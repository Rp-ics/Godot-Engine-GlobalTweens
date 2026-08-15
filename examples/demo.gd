# =============================================================================
#  GlobalTweens — Interaction Demo / Playground
#  Left: category buttons. Center: one button per catalog animation.
#  Right: the "stage" with demo actors. Bottom: global controls.
#  Every animation is played through GlobalTweens.play() with its defaults.
# =============================================================================

extends Node2D

const TARGETS := {
	"ui_buttons": "demo_button",
	"ui_generic": "demo_button",
	"ui_text": "demo_label",
	"fog": "fog_layer",
	"camera": "camera",
	"flash": "hero",
	"fx": "hero",
}

var stage: Dictionary = {}
var ui_root: CanvasLayer
var category_list: VBoxContainer
var anim_list: VBoxContainer
var status_label: Label
var current_category := ""
var selected_button: Button


func _ready() -> void:
	_build_stage()
	_build_ui()


# ---------------------------------------------------------------------------
#  Stage (world actors)
# ---------------------------------------------------------------------------

func _make_square(size: Vector2, color: Color) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-size.x / 2, -size.y / 2),
		Vector2(size.x / 2, -size.y / 2),
		Vector2(size.x / 2, size.y / 2),
		Vector2(-size.x / 2, size.y / 2),
	])
	poly.color = color
	return poly


func _make_label(text: String, size: int = 14, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _build_stage() -> void:
	var camera := Camera2D.new()
	camera.position = Vector2(640, 360)
	camera.zoom = Vector2.ONE
	add_child(camera)

	var hero := _make_square(Vector2(64, 64), Color(0.55, 0.35, 0.85))
	hero.position = Vector2(440, 340)
	add_child(hero)
	hero.add_child(_make_label("HERO", 12, Color(1, 1, 1, 0.9)))
	(hero.get_child(0) as Label).position = Vector2(-14, -40)

	var slime := _make_square(Vector2(44, 52), Color(0.3, 0.8, 0.35))
	slime.position = Vector2(590, 350)
	add_child(slime)
	slime.add_child(_make_label("SLIME", 11, Color(1, 1, 1, 0.9)))
	(slime.get_child(0) as Label).position = Vector2(-18, -36)

	var boss := _make_square(Vector2(96, 96), Color(0.85, 0.25, 0.2))
	boss.position = Vector2(790, 320)
	add_child(boss)
	boss.add_child(_make_label("BOSS", 14, Color(1, 1, 1, 0.9)))
	(boss.get_child(0) as Label).position = Vector2(-18, -50)

	var fog_layer := _make_square(Vector2(460, 46), Color(0.8, 0.85, 0.95, 0.35))
	fog_layer.position = Vector2(620, 180)
	add_child(fog_layer)

	var demo_label := _make_label("Demo Text", 28, Color(1.0, 0.85, 0.4))
	demo_label.position = Vector2(700, 130)
	add_child(demo_label)

	var demo_button := Button.new()
	demo_button.text = "Demo Button"
	demo_button.custom_minimum_size = Vector2(190, 58)
	demo_button.position = Vector2(30, 200)
	demo_button.pivot_offset = demo_button.size * 0.5
	demo_button.focus_mode = Control.FOCUS_NONE
	add_child(demo_button)

	var progress := ProgressBar.new()
	progress.value = 70
	progress.min_value = 0
	progress.max_value = 100
	progress.size = Vector2(220, 26)
	progress.position = Vector2(460, 570)
	add_child(progress)

	stage = {
		"hero": hero,
		"slime": slime,
		"boss": boss,
		"fog_layer": fog_layer,
		"demo_label": demo_label,
		"demo_button": demo_button,
		"progress": progress,
		"camera": camera,
	}


# ---------------------------------------------------------------------------
#  UI
# ---------------------------------------------------------------------------

func _build_ui() -> void:
	ui_root = CanvasLayer.new()
	ui_root.layer = 10
	add_child(ui_root)

	# Left panel: categories
	var cat_panel := PanelContainer.new()
	cat_panel.position = Vector2(10, 10)
	cat_panel.size = Vector2(190, 360)
	cat_panel.add_theme_stylebox_override("panel", _panel_style())
	ui_root.add_child(cat_panel)

	var cat_scroll := ScrollContainer.new()
	cat_scroll.custom_minimum_size = Vector2(170, 340)
	cat_panel.add_child(cat_scroll)
	category_list = VBoxContainer.new()
	category_list.add_theme_constant_override("separation", 4)
	cat_scroll.add_child(category_list)

	# Center: animations of the selected category
	var anim_panel := PanelContainer.new()
	anim_panel.position = Vector2(210, 10)
	anim_panel.size = Vector2(300, 460)
	anim_panel.add_theme_stylebox_override("panel", _panel_style())
	ui_root.add_child(anim_panel)

	var anim_scroll := ScrollContainer.new()
	anim_scroll.custom_minimum_size = Vector2(280, 440)
	anim_panel.add_child(anim_scroll)
	anim_list = VBoxContainer.new()
	anim_list.add_theme_constant_override("separation", 4)
	anim_scroll.add_child(anim_list)

	# Status
	status_label = _make_label("Select a category on the left.", 13, Color(0.9, 0.9, 0.9))
	status_label.position = Vector2(10, 530)
	ui_root.add_child(status_label)

	# Global controls
	var stop_all_btn := Button.new()
	stop_all_btn.text = "STOP ALL"
	stop_all_btn.position = Vector2(210, 480)
	stop_all_btn.size = Vector2(100, 34)
	stop_all_btn.focus_mode = Control.FOCUS_NONE
	stop_all_btn.pressed.connect(func():
		GlobalTweens.stop_all()
		status_label.text = "Stopped everything."
	)
	ui_root.add_child(stop_all_btn)

	var reset_btn := Button.new()
	reset_btn.text = "RESET"
	reset_btn.position = Vector2(320, 480)
	reset_btn.size = Vector2(80, 34)
	reset_btn.focus_mode = Control.FOCUS_NONE
	reset_btn.pressed.connect(func():
		for key in ["hero", "slime", "boss", "fog_layer", "demo_label", "demo_button", "camera"]:
			GlobalTweens.reset(stage[key])
		status_label.text = "Reset all test nodes."
	)
	ui_root.add_child(reset_btn)

	var spam_btn := Button.new()
	spam_btn.text = "SPAM TEST"
	spam_btn.position = Vector2(410, 480)
	spam_btn.size = Vector2(100, 34)
	spam_btn.focus_mode = Control.FOCUS_NONE
	spam_btn.pressed.connect(func():
		var names := GlobalTweens.catalog_names("hit")
		for i in 20:
			GlobalTweens.play(stage["hero"], names[i % names.size()])
		status_label.text = "Spammed 20 hit animations on HERO."
	)
	ui_root.add_child(spam_btn)

	_refresh_categories()
	_select_category(GlobalTweens.catalog_categories()[0])


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.1, 0.13, 0.92)
	style.border_color = Color(0.3, 0.32, 0.38)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style


func _refresh_categories() -> void:
	for child in category_list.get_children():
		child.queue_free()
	for category in GlobalTweens.catalog_categories():
		var btn := Button.new()
		btn.text = category
		btn.focus_mode = Control.FOCUS_NONE
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(160, 30)
		btn.pressed.connect(_select_category.bind(category))
		category_list.add_child(btn)
		if category == current_category:
			selected_button = btn
			btn.button_pressed = true


func _select_category(category: String) -> void:
	current_category = category
	if selected_button != null:
		selected_button.button_pressed = false
	for child in category_list.get_children():
		if (child as Button).text == category:
			selected_button = child
			(child as Button).button_pressed = true

	for child in anim_list.get_children():
		child.queue_free()

	for id in GlobalTweens.catalog_names(category):
		var btn := Button.new()
		btn.text = id.get_slice(".", 1)
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(260, 28)
		btn.pressed.connect(_play_animation.bind(id))
		anim_list.add_child(btn)

	status_label.text = "Category: %s — click an animation to play it." % category


func _play_animation(id: String) -> void:
	var target_name: String = TARGETS.get(current_category, "hero")
	var target: Node = stage[target_name]
	var opts := {}
	if id == "camera.focus":
		opts["target"] = stage["hero"].global_position
		opts["hold"] = 0.7
	elif id == "hit.damage_popup":
		opts["text"] = str(randi_range(3, 48))
	elif id == "hit.crit":
		opts["text"] = str(randi_range(20, 99))
	elif id == "ui_generic.progress_flash":
		target = stage["progress"]
	elif id == "ui_generic.slider_fill":
		target = stage["progress"]
		opts["value"] = 100.0
	var tween := GlobalTweens.play(target, id, opts)
	if tween != null:
		status_label.text = "Played '%s' on %s" % [id, target_name]
	else:
		status_label.text = "Play failed: '%s' (is the node type compatible?)" % id