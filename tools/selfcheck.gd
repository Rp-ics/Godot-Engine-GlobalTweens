# =============================================================================
#  GlobalTweens self-check (headless)
#  Run with:  godot --headless --path . res://tools/selfcheck.tscn
#  Plays EVERY catalog animation on a dummy node, then spot-checks the
#  classic helpers. Exits 0 on success, 1 on failure.
# =============================================================================

extends Node

var errors: Array = []
var total_played := 0
var holder: Node2D


func _ready() -> void:
	await get_tree().process_frame

	print("=== GlobalTweens self-check ===")
	print("Catalog count: %d" % GlobalTweens.catalog_count())
	print("Categories: %s" % str(GlobalTweens.catalog_categories()))

	holder = Node2D.new()
	add_child(holder)

	await _run_catalog()
	await _run_classic()

	print("=== RESULT: %d animations played, %d errors ===" % [total_played, errors.size()])
	for e in errors:
		push_error(e)
	get_tree().quit(1 if not errors.is_empty() else 0)


func _dummy(category: String) -> Node:
	match category:
		"ui_text":
			var label := Label.new()
			label.text = "Hello"
			return label
		"ui_buttons", "ui_generic":
			var btn := Button.new()
			btn.text = "Button"
			return btn
		"camera":
			return Camera2D.new()
		"environment":
			return PointLight2D.new()
		_:
			return Node2D.new()


func _run_catalog() -> void:
	for category in GlobalTweens.catalog_categories():
		for id in GlobalTweens.catalog_names(category):
			var node := _dummy(category)
			if id == "ui_generic.slider_fill":
				node = TextureProgressBar.new()
			holder.add_child(node)
			var opts := {}
			if id == "camera.focus":
				opts["target"] = Vector2(100, 100)
				opts["hold"] = 0.01
			elif id == "hit.damage_popup" or id == "hit.crit":
				opts["text"] = "7"
			elif id == "ui_text.scramble":
				opts["text"] = "42"
			var tween := GlobalTweens.play(node, id, opts)
			total_played += 1
			await get_tree().process_frame
			await get_tree().create_timer(0.03).timeout
			if is_instance_valid(node):
				GlobalTweens.stop(node)
				node.queue_free()
			# re-verify anti-spam on a kept node for a couple of loops
			if category == "generic" and id == "generic.pulse_loop":
				var again := _dummy(category)
				holder.add_child(again)
				GlobalTweens.play(again, id, {"loops": -1})
				await get_tree().process_frame
				GlobalTweens.stop(again)
				again.queue_free()


func _run_classic() -> void:
	var hero := Node2D.new()
	holder.add_child(hero)
	var label := Label.new()
	label.text = "Test"
	holder.add_child(label)
	var btn := Button.new()
	btn.text = "Btn"
	holder.add_child(btn)
	var cam := Camera2D.new()
	holder.add_child(cam)

	# one-shot helpers
	GlobalTweens.pop_scale(hero, 1.3, 0.1)
	GlobalTweens.color_flash(hero, Color.RED, 0.1)
	GlobalTweens.squash_stretch(hero, "y", 1.3, 0.1)
	GlobalTweens.wobble(hero, 1.2, 0.1, 3)
	GlobalTweens.move_to(hero, Vector2(50, 50), 0.1)
	GlobalTweens.rotate_by(hero, 90.0, 0.2)
	GlobalTweens.bounce(hero, 20.0, 0.2)
	GlobalTweens.spawn_in(hero, 0.2)
	GlobalTweens.slide_in(hero, Vector2.LEFT, 100.0, 0.2)
	GlobalTweens.slide_out(hero, Vector2.RIGHT, 100.0, 0.2)
	GlobalTweens.glitch_flash(hero, 5.0, 0.05)
	GlobalTweens.phase_shift(hero, 2, 0.05)
	GlobalTweens.energy_pulse(hero, Color.CYAN, 0.1)
	GlobalTweens.burst_particles(hero, 4, 60.0, 0.2)
	GlobalTweens.rubber_band(hero, 1.3, 1.1, 0.2)
	GlobalTweens.magnetic_snap(hero, Vector2(100, 100), 10.0, 0.2)
	GlobalTweens.warp_entry(hero, 2.0, 0.2)
	GlobalTweens.shockwave_scale(hero, 2.0, 0.2)
	GlobalTweens.depth_pop(hero, null, 1.15, 10.0, 0.2)
	GlobalTweens.texture_progress_pulse(TextureProgressBar.new(), Color.YELLOW, 0.1)
	GlobalTweens.button_hover(btn, 1.1, 0.1)
	GlobalTweens.button_unhover(btn, 0.1)
	GlobalTweens.button_press(btn, 0.05)
	GlobalTweens.button_disable(btn, 0.1)
	GlobalTweens.button_enable(btn, 0.1)
	GlobalTweens.text_shake(label, 3.0, 0.1)
	GlobalTweens.label_gradient_pulse(label, "warm", 0.3, false, 1)
	GlobalTweens.camera_zoom_pulse(cam, 1.2, 0.1)
	GlobalTweens.camera_recoil(cam, Vector2.UP, 8.0, 0.1)
	GlobalTweens.camera_lerp_to(cam, Vector2(200, 200), 0.1)
	GlobalTweens.cascade_fade_in([label, btn], 0.1, 0.05)
	GlobalTweens.radial_menu_open([btn], 50.0, 0.1, true, Vector2.ZERO, 0.01)
	GlobalTweens.chain_tweens([hero], ["position"], [Vector2(30, 30)], [0.1])
	GlobalTweens.parallel_tweens(hero, [["scale", Vector2(2, 2), 0.1], ["rotation", 0.5, 0.1]])
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout

	# infinite loops: start then stop
	GlobalTweens.float_loop(hero, 5.0, 1.0, "y")
	GlobalTweens.swing(hero, 10.0, 0.3)
	GlobalTweens.spin(hero, 90.0)
	GlobalTweens.beat_pulse(hero, 120.0, 1.2)
	GlobalTweens.label_rainbow(label, 1.0)
	GlobalTweens.flicker_alive(hero, 0.4, 1.0)
	GlobalTweens.heartbeat(hero, 72.0, 1.2)
	GlobalTweens.morph_color_sequence(hero, [Color.RED, Color.BLUE], 0.2)
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	GlobalTweens.stop_all()
	await get_tree().process_frame
	if GlobalTweens.is_animating(hero):
		errors.append("is_animating(hero) still true after stop_all()")

	# --- Freed / null node guards (error_mode) ------------------------------
	GlobalTweens.error_mode = "ignore"
	var freed := Node2D.new()
	holder.add_child(freed)
	freed.queue_free()
	await get_tree().process_frame
	GlobalTweens.stop(freed)
	GlobalTweens.reset(freed)
	GlobalTweens.play(freed, "generic.fade_in")
	GlobalTweens.play(null, "generic.fade_in")
	if GlobalTweens.is_animating(freed):
		errors.append("is_animating(freed) should be false after free")
	GlobalTweens.error_mode = "crash"

	holder.queue_free()