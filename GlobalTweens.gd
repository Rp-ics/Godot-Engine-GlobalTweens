# =========================================================
#  GlobalTweens.gd
#  Universal Tween Toolkit for Godot 4.x
#  Author: Rpx
#  License: MIT — Free to use, modify, and distribute
# =========================================================
#  FEATURES
#  ────────────────────────────────────────────────
#   • blink, fade, show, hide
#   • shake, shake_rot, move_to, bounce, rotate
#   • activate / deactivate
#   • pop_scale, zoom_pop, elastic_pop
#   • color_flash, color_pulse
#   • spawn_in, explode_and_free, squash_stretch, wobble
#   • slide_in, slide_out, quantum_jump
#   • phase_shift, energy_pulse, glitch_flash
#   • float_loop, swing, spin, random_tween
# =========================================================
#
#  USAGE (as AutoLoad Singleton)
#  ────────────────────────────────────────────────
#  Add `GlobalTweens.gd` to your project autoloads:
#     Project Settings → AutoLoad → + → GlobalTweens.gd → Enable Singleton
#
#  Then call directly from anywhere:
#
#     GlobalTweens.spawn_in($Enemy)
#     GlobalTweens.blink($Player, 4)
#     GlobalTweens.color_flash($UI_Health, Color.RED)
#     GlobalTweens.squash_stretch($Ship, "y", 1.4)
#     GlobalTweens.glitch_flash($Portal)
#     GlobalTweens.quantum_jump($Enemy, Vector2(800, 300))
#     GlobalTweens.explode_and_free($Loot)
#     GlobalTweens.float_loop($Asteroid, amplitude=40, speed=3.0, axis="y")
#     GlobalTweens.swing($Ship, degrees=15, dur=0.5)
#     GlobalTweens.zoom_pop($Button, 1.5, 0.3)
#     GlobalTweens.spin($Rotor, speed=180)
#     GlobalTweens.random_tween($Icon, pos_range=20, rot_range=30, scale_range=0.2)
#
# =========================================================
#
#  USAGE (as Class Instance)
#  ────────────────────────────────────────────────
#  If you don’t want it global, just instantiate:
#
#     func _ready():
#         var tweens = GlobalTweens.new()
#         add_child(tweens)
#
#         tweens.spawn_in($Enemy)
#         tweens.blink($Player, 4)
#         tweens.color_flash($UI_Health, Color.RED)
#         tweens.squash_stretch($Ship, "y", 1.4)
#
#         # Sequential example
#         var seq = GlobalTweens.new()
#         add_child(seq)
#         seq.fade($Sprite, 1.0, 0.0, 0.5)
#         await get_tree().create_timer(0.5).timeout
#         seq.fade($Sprite, 0.0, 1.0, 0.5)
#
# =========================================================
#  NOTES
#  ────────────────────────────────────────────────
#   • All functions accept `wait: bool` → await tween end
#   • Loops (`float_loop`, `spin`, `swing`, `bounce_loop`) are async and independent
#   • Each tween returns its Tween object (for chaining or debug)
#   • Safety checks prevent invalid node usage
#   • Easing/transition parameters can be strings:
#         trans = "sine", "back", "elastic", "quad", etc.
#         ease  = "in", "out", "in_out"
#
# =========================================================
#  EXAMPLES
#  ────────────────────────────────────────────────
#     # Pop and wait
#     await GlobalTweens.pop_scale($Button, 1.3, 0.2, true)
#
#     # Floating asteroid
#     GlobalTweens.float_loop($Asteroid, amplitude=40, speed=3.0, axis="y")
#
#     # Bounce with custom transition
#     GlobalTweens.bounce($Icon, 25.0, 0.4, false, "elastic", "out")
#
#     # Fade out + free
#     GlobalTweens.explode_and_free($Enemy)
#
#     # Spin rotor continuously
#     GlobalTweens.spin($Rotor, 180)
#
#     # Random movement / wobble
#     GlobalTweens.random_tween($Icon, 20, 30, 0.2)
#
#     # Elastic pop on a button
#     GlobalTweens.elastic_pop($Button, 1.5, 0.4)
# =========================================================

extends Node
@onready var rng = RandomNumberGenerator.new()

# =========================================================
#  UTILS
# =========================================================
func _is_valid(n: Node) -> bool:
	return is_instance_valid(n)
	#var valid = is_instance_valid(n)
	#if valid:
		#push_warning("Node instance %s is not valid, skipping tween" % n)
	#return valid
	
func _new_tween(target: Node) -> Tween:
	if not _is_valid(target): return null
	return target.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# =========================================================
#  BASIC VISUAL
# =========================================================
func blink(node: CanvasItem, times: int = 3, speed: float = 0.1):
	if not _is_valid(node): return
	var t = _new_tween(node)
	for i in range(times):
		t.tween_property(node, "modulate:a", 0.2, speed)
		t.tween_property(node, "modulate:a", 1.0, speed)

func fade(node: CanvasItem, from: float, to: float, dur: float = 0.4):
	if not _is_valid(node): return
	node.modulate.a = from
	return _new_tween(node).tween_property(node, "modulate:a", to, dur)

func hide(node: CanvasItem, dur: float = 0.3): return fade(node, node.modulate.a, 0.0, dur)
func show(node: CanvasItem, dur: float = 0.3): return fade(node, node.modulate.a, 1.0, dur)

func color_flash(node: CanvasItem, color: Color = Color(1, 0, 0), dur: float = 0.15):
	if not _is_valid(node): return
	var t = _new_tween(node)
	var original = node.modulate
	t.tween_property(node, "modulate", color, dur / 2)
	t.tween_property(node, "modulate", original, dur / 2)


# =========================================================
#  SCALE / POP / STRETCH
# =========================================================
func pop_scale(node: Node2D, factor: float = 1.3, dur: float = 0.15):
	if not _is_valid(node): return
	var t = _new_tween(node)
	var s = node.scale
	t.tween_property(node, "scale", s * factor, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", s, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func squash_stretch(node: Node2D, axis: String = "y", factor: float = 1.3, dur: float = 0.15):
	if not _is_valid(node): return
	var t = _new_tween(node)
	var s = node.scale
	var stretch = Vector2(1, 1)
	if axis == "y":
		stretch = Vector2(1.0 / factor, factor)
	else:
		stretch = Vector2(factor, 1.0 / factor)
	t.tween_property(node, "scale", s * stretch, dur)
	t.tween_property(node, "scale", s, dur)


# =========================================================
#  MOVEMENT / ROTATION
# =========================================================
func shake(node: Node2D, intensity: float = 10.0, dur: float = 0.3):
	if not _is_valid(node): return
	var original = node.position
	var timer := Timer.new()
	timer.wait_time = 0.02
	timer.one_shot = false
	node.add_child(timer)
	timer.timeout.connect(func ():
		node.position = original + Vector2(
			rng.randf_range(-intensity, intensity),
			rng.randf_range(-intensity, intensity)
		)
	)
	timer.start()
	await get_tree().create_timer(dur).timeout
	timer.stop()
	node.position = original
	timer.queue_free()

func move_to(node: Node2D, target: Vector2, dur: float = 0.4):
	if not _is_valid(node): return
	_new_tween(node).tween_property(node, "position", target, dur)

func rotate(node: Node2D, degrees: float = 360.0, dur: float = 1.0):
	if not _is_valid(node): return
	var target = node.rotation_degrees + degrees
	return _new_tween(node).tween_property(node, "rotation_degrees", target, dur)

func bounce(node: Node2D, height: float = 20.0, dur: float = 0.3):
	if not _is_valid(node): return
	var y = node.position.y
	var t = _new_tween(node)
	t.tween_property(node, "position:y", y - height, dur / 2)
	t.tween_property(node, "position:y", y, dur / 2)


# =========================================================
#  ACTIVATE / DEACTIVATE -> Buttons, Collisions ...
# =========================================================
func activate(node: Node):
	if not _is_valid(node): 
		return
	
	# Enable CollisionShape2D if present
	if node.has_node("CollisionShape2D"):
		var shape = node.get_node("CollisionShape2D")
		if shape and shape is CollisionShape2D:
			shape.disabled = false
	
	# If it is a Control or Button, reactivate it
	if node.has_method("set_disabled"):
		node.set_disabled(false)
		
	# Visual “pop” effect for feedback
	pop_scale(node, 1.1, 0.15)


func deactivate(node: Node):
	if not _is_valid(node): 
		return
	
	# Disable CollisionShape2D if present
	if node.has_node("CollisionShape2D"):
		var shape = node.get_node("CollisionShape2D")
		if shape and shape is CollisionShape2D:
			shape.disabled = true
	
	# If it is a Control or Button, disable it.
	if node.has_method("set_disabled"):
		node.call_deferred("set_disabled", true)
	
	# Visual fade effect for feedback
	fade(node, node.modulate.a, 0.3, 0.2)


# =========================================================
#  SHOW / HIDE -> Visibility + optional soft tween
# =========================================================
func show_node(node: Node, smooth: bool = true, duration: float = 0.2):
	if not _is_valid(node):
		return
	
	if node.has_method("show"):
		node.show()
	
	# effetto fade-in dolce
	if smooth and node is CanvasItem:
		node.modulate.a = 0.0
		fade(node, 0.0, 1.0, duration)
	else:
		if node is CanvasItem:
			node.modulate.a = 1.0


func hide_node(node: Node, smooth: bool = true, duration: float = 0.2):
	if not _is_valid(node):
		return
	
	if smooth and node is CanvasItem:
		var tween := create_tween()
		# imposta il valore iniziale manualmente
		node.modulate.a = node.modulate.a  
		# ora tweena verso 0
		tween.tween_property(node, "modulate:a", 0.0, duration)
		tween.tween_callback(func ():
			if is_instance_valid(node) and node.has_method("hide"):
				node.hide()
		)
	else:
		if node.has_method("hide"):
			node.hide()


# =========================================================
#  SPECIAL FX
# =========================================================
func spawn_in(node: Node2D, dur: float = 0.3):
	if not _is_valid(node): return
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	var t = _new_tween(node)
	t.parallel().tween_property(node, "scale", Vector2.ONE, dur)
	t.parallel().tween_property(node, "modulate:a", 1.0, dur)

func explode_and_free(node: Node2D, dur: float = 0.4):
	if not _is_valid(node): return
	var t = _new_tween(node)
	t.parallel().tween_property(node, "scale", node.scale * 1.5, dur)
	t.parallel().tween_property(node, "modulate:a", 0.0, dur)
	t.finished.connect(func (): if _is_valid(node): node.queue_free())

func energy_pulse(node: CanvasItem, color: Color = Color(0.5, 1, 1), dur: float = 0.3):
	if not _is_valid(node): return
	var orig = node.modulate
	var t = _new_tween(node)
	t.tween_property(node, "modulate", color, dur / 2)
	t.tween_property(node, "modulate", orig, dur / 2)

func glitch_flash(node: Node2D, intensity: float = 5.0, dur: float = 0.2):
	if not _is_valid(node): return
	var orig_pos = node.position
	for i in range(int(dur / 0.02)):
		node.position = orig_pos + Vector2(
			rng.randf_range(-intensity, intensity),
			rng.randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(0.02).timeout
	node.position = orig_pos

func quantum_jump(node: Node2D, new_pos: Vector2, dur: float = 0.3):
	if not _is_valid(node): return
	var t = _new_tween(node)
	t.tween_property(node, "scale", Vector2.ZERO, dur / 2)
	t.tween_callback(func ():
		node.position = new_pos
	)
	t.tween_property(node, "scale", Vector2.ONE, dur / 2)

func phase_shift(node: CanvasItem, times: int = 3, speed: float = 0.08):
	if not _is_valid(node): return
	var t = _new_tween(node)
	for i in range(times):
		t.tween_property(node, "modulate:a", 0.0, speed)
		t.tween_property(node, "modulate:a", 1.0, speed)

func slide_in(node: Node2D, from_dir: Vector2, dist: float = 200.0, dur: float = 0.4):
	if not _is_valid(node): return
	var start_pos = node.position + from_dir.normalized() * dist
	node.position = start_pos
	move_to(node, start_pos - from_dir.normalized() * dist, dur)

func slide_out(node: Node2D, to_dir: Vector2, dist: float = 200.0, dur: float = 0.4):
	if not _is_valid(node): return
	move_to(node, node.position + to_dir.normalized() * dist, dur)


# =========================================================
#  EXTRA TWEENS / FX
# =========================================================

# Continuous float-type vertical oscillation
func float_y(node: Node2D, amplitude: float = 10.0, period: float = 1.0):
	if not _is_valid(node): return
	var orig_y = node.position.y
	var tween = _new_tween(node)
	tween.tween_property(node, "position:y", orig_y - amplitude, period / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops()  # infinite loop
	tween.tween_property(node, "position:y", orig_y + amplitude, period / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops()

# Zoom with overshoot
func zoom_pop(node: Node2D, factor: float = 1.5, dur: float = 0.3):
	if not _is_valid(node): return
	var t = _new_tween(node)
	var s = node.scale
	t.tween_property(node, "scale", s * factor, dur / 2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", s, dur / 2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

# SWING TODO
func _swing_loop(node: Node2D, orig: float, degrees: float, dur: float):
	if not _is_valid(node): return
	var t = _new_tween(node)
	t.tween_property(node, "rotation_degrees", orig + degrees, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "rotation_degrees", orig - degrees, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.finished.connect(func(): _swing_loop(node, orig, degrees, dur))  # richiamo ricorsivo sicuro

func swing(node: Node2D, degrees: float = 15.0, dur: float = 0.5):
	if not _is_valid(node): return
	var orig = node.rotation_degrees
	_swing_loop(node, orig, degrees, dur)


# Shake with rotation
func shake_rot(node: Node2D, intensity: float = 10.0, dur: float = 0.3):
	if not _is_valid(node): return
	var orig = node.rotation_degrees
	for i in range(int(dur / 0.02)):
		node.rotation_degrees = orig + rng.randf_range(-intensity, intensity)
		await get_tree().create_timer(0.02).timeout
	node.rotation_degrees = orig

# Wobble scale on X e Y
func wobble(node: Node2D, factor: float = 1.2, dur: float = 0.2, times: int = 3):
	if not _is_valid(node): return
	var t = _new_tween(node)
	var orig = node.scale
	for i in range(times):
		t.tween_property(node, "scale", orig * Vector2(factor, 1.0 / factor), dur)
		t.tween_property(node, "scale", orig * Vector2(1.0 / factor, factor), dur)
	t.tween_property(node, "scale", orig, dur)

# Random tween on position, rotation, and scale
func random_tween(node: Node2D, pos_range: float = 20.0, rot_range: float = 30.0, scale_range: float = 0.2, dur: float = 0.3):
	if not _is_valid(node): return
	var t = _new_tween(node)
	t.tween_property(node, "position:x", node.position.x + rng.randf_range(-pos_range, pos_range), dur)
	t.tween_property(node, "position:y", node.position.y + rng.randf_range(-pos_range, pos_range), dur)
	t.tween_property(node, "rotation_degrees", node.rotation_degrees + rng.randf_range(-rot_range, rot_range), dur)
	t.tween_property(node, "scale", node.scale * (1.0 + rng.randf_range(-scale_range, scale_range)), dur)

# Color pulse
func color_pulse(node: CanvasItem, color: Color = Color(1, 1, 0), dur: float = 0.4):
	if not _is_valid(node): return
	var t = _new_tween(node)
	var orig = node.modulate
	t.tween_property(node, "modulate", color, dur / 2)
	t.tween_property(node, "modulate", orig, dur / 2)

# Elastic pop
func elastic_pop(node: Node2D, factor: float = 1.5, dur: float = 0.4):
	if not _is_valid(node): return
	var t = _new_tween(node)
	var s = node.scale
	t.tween_property(node, "scale", s * factor, dur / 2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", s, dur / 2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)

# Spin
func spin(node: Node2D, speed: float = 180.0):  # degrees per second
	if not _is_valid(node): return
	while _is_valid(node):
		node.rotation_degrees += speed * get_process_delta_time()
		await get_tree().process_frame


func scene_fade_change(tree: SceneTree, scene_path: String, dur: float = 0.4):
	var canvas := CanvasLayer.new()
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.size = tree.root.size
	rect.modulate.a = 0.0
	canvas.add_child(rect)
	tree.root.add_child(canvas)

	var t = rect.create_tween()
	t.tween_property(rect, "modulate:a", 1.0, dur)
	await t.finished

	tree.change_scene_to_file(scene_path)

	var t2 = rect.create_tween()
	t2.tween_property(rect, "modulate:a", 0.0, dur)
	await t2.finished
	canvas.queue_free()

#USAGE: await GlobalTweens.scene_fade_change(get_tree(), "res://scenes/Game.tscn")
# ================================================================================== #

func scene_slide_change(tree: SceneTree, scene_path: String, dir: Vector2 = Vector2.LEFT, dur: float = 0.4):
	var old_scene = tree.current_scene
	var viewport_size = tree.root.size

	var new_scene = load(scene_path).instantiate()
	tree.root.add_child(new_scene)

	new_scene.position = dir * viewport_size
	var t = new_scene.create_tween()
	t.parallel().tween_property(new_scene, "position", Vector2.ZERO, dur)
	t.parallel().tween_property(old_scene, "position", -dir * viewport_size, dur)

	await t.finished
	old_scene.queue_free()
	tree.current_scene = new_scene

# === BUTTON HOWE === #
func button_hover(btn: Control, scale: float = 1.1, dur: float = 0.12):
	if not _is_valid(btn): return
	var t = _new_tween(btn)
	t.tween_property(btn, "scale", Vector2.ONE * scale, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# === BUTTON UNHOVER === #
func button_unhover(btn: Control, dur: float = 0.1):
	if not _is_valid(btn): return
	_new_tween(btn).tween_property(btn, "scale", Vector2.ONE, dur)

# === BUTTON PRESS === #
func button_press(btn: Control, dur: float = 0.08):
	if not _is_valid(btn): return
	var t = _new_tween(btn)
	t.tween_property(btn, "scale", Vector2.ONE * 0.9, dur)
	t.tween_property(btn, "scale", Vector2.ONE, dur)


# === INTELLIGENT DISABLE === #
func button_disable(btn: Control, dur: float = 0.2):
	if not _is_valid(btn): return
	btn.disabled = true
	var t = _new_tween(btn)
	t.parallel().tween_property(btn, "modulate:a", 0.4, dur)
	t.parallel().tween_property(btn, "scale", Vector2.ONE * 0.95, dur)

# === INTELLIGENT ENBLE === #
func button_enable(btn: Control, dur: float = 0.2):
	if not _is_valid(btn): return
	btn.disabled = false
	btn.modulate.a = 0.4
	btn.scale = Vector2.ONE * 0.95
	var t = _new_tween(btn)
	t.parallel().tween_property(btn, "modulate:a", 1.0, dur)
	t.parallel().tween_property(btn, "scale", Vector2.ONE, dur)

# ============================================================ #
# === SCROLLBAR: SCROLL TO=== #
func scrollbar_scroll_to(scroll: ScrollBar, value: float, dur: float = 0.3):
	if not _is_valid(scroll): return
	var t = _new_tween(scroll)
	t.tween_property(scroll, "value", clamp(value, scroll.min_value, scroll.max_value), dur)

# USAGE: GlobalTweens.scrollbar_scroll_to($ScrollBar, 50)

# === SCROLL PULSE (DEPRECATED) === #
func scrollbar_thumb_pulse(scroll: ScrollBar, color: Color = Color(1,1,0), dur: float = 0.3):
	if not _is_valid(scroll): return
	var style = scroll.get("custom_styles/scrollbar")
	if not style: return
	var orig_color = style.get_color("fg_color")
	var t = _new_tween(scroll)
	t.tween_property(style, "fg_color", color, dur/2)
	t.tween_property(style, "fg_color", orig_color, dur/2)


# === SCROLL SHAKE (DEPRECATED) === #
func scrollbar_shake(scroll: ScrollBar, intensity: float = 5.0, dur: float = 0.2):
	if not _is_valid(scroll): return
	var orig_value = scroll.value
	var steps = int(dur / 0.02)
	for i in range(steps):
		scroll.value = orig_value + rng.randf_range(-intensity, intensity)
		await get_tree().create_timer(0.02).timeout
	scroll.value = orig_value


# === SCROLL HIGHLIGHT (DEPRECATED) === #
func scrollbar_highlight(scroll: ScrollBar, color: Color = Color(1,1,1,0.7), dur: float = 0.2):
	if not _is_valid(scroll): return
	var style = scroll.get("custom_styles/scrollbar")
	if not style: return
	var orig_color = style.get_color("fg_color")
	var t = _new_tween(scroll)
	t.tween_property(style, "fg_color", color, dur/2)
	t.tween_property(style, "fg_color", orig_color, dur/2)

# ===================================================== #
# === INPUT === #
func lineedit_attention(line: LineEdit, color: Color = Color(1,0,0), dur: float = 0.15):
	if not _is_valid(line): return
	var orig_modulate = line.modulate
	var t = _new_tween(line)
	t.tween_property(line, "modulate", color, dur / 2)
	t.tween_property(line, "modulate", orig_modulate, dur / 2)


func lineedit_pop(line: LineEdit, color: Color = Color(1,1,0), dur: float = 0.2):
	if not _is_valid(line): return
	var orig_color = line.modulate
	var t = _new_tween(line)
	t.tween_property(line, "modulate", color, dur/2)
	t.tween_property(line, "modulate", orig_color, dur/2)

# DEPRECATED
func lineedit_highlight(line: LineEdit, color: Color = Color(1,1,0,0.3), dur: float = 0.3):
	if not _is_valid(line): return
	var style = line.get("custom_styles/normal")
	if not style: return
	var orig_color = style.get_color("bg_color")
	var t = _new_tween(line)
	t.tween_property(style, "bg_color", color, dur/2)
	t.tween_property(style, "bg_color", orig_color, dur/2)


func lineedit_error_feedback(line: LineEdit, color: Color = Color(1,0,0), dur: float = 0.2):
	if not _is_valid(line): return

	var orig_modulate = line.modulate
	var t = GlobalTweens._new_tween(line)  # riutilizza _new_tween dal tuo file
	t.tween_property(line, "modulate", color, dur / 2)
	t.tween_property(line, "modulate", orig_modulate, dur / 2)

# === NEW EXPLODE === #
# =========================================================
# Explode particles
# =========================================================
func explode_frames(node: Sprite2D, dur: float = 0.5, particle_scale: float = 0.3, spread: float = 50.0, shader: ShaderMaterial = null):
	if not _is_valid(node): return
	var tex = node.texture
	if not tex: return
	var size = tex.get_size()
	var parent = node.get_parent()
	if not parent: return

	var cols = 4
	var rows = 4
	var w = size.x / cols
	var h = size.y / rows

	for x in range(cols):
		for y in range(rows):
			var frag = Sprite2D.new()
			frag.texture = tex
			frag.region_enabled = true
			frag.region_rect = Rect2(x * w, y * h, w, h)
			frag.position = node.global_position + Vector2(w/2, h/2)
			if shader:
				frag.material = shader.duplicate()
			parent.add_child(frag)

			var target_pos = frag.position + Vector2(
				rng.randf_range(-spread, spread),
				rng.randf_range(-spread, spread)
			)

			var t = _new_tween(frag)
			t.parallel().tween_property(frag, "position", target_pos, dur)
			t.parallel().tween_property(frag, "scale", Vector2.ONE * particle_scale, dur)
			t.parallel().tween_property(frag, "modulate:a", 0.0, dur)
			t.finished.connect(func(): if _is_valid(frag): frag.queue_free())

	node.queue_free()


# =========================================================
# Implode particles (da sparso a nodo)
# =========================================================
func implode_frames(node: Sprite2D, dur: float = 0.5, particle_scale: float = 0.3, spread: float = 50.0, shader: ShaderMaterial = null):
	if not _is_valid(node): return
	var tex = node.texture
	if not tex: return
	var size = tex.get_size()
	var parent = node.get_parent()
	if not parent: return

	var cols = 4
	var rows = 4
	var w = size.x / cols
	var h = size.y / rows

	for x in range(cols):
		for y in range(rows):
			var frag = Sprite2D.new()
			frag.texture = tex
			frag.region_enabled = true
			frag.region_rect = Rect2(x * w, y * h, w, h)
			# start sparso
			frag.position = node.global_position + Vector2(
				rng.randf_range(-spread, spread),
				rng.randf_range(-spread, spread)
			)
			frag.scale = Vector2.ONE * particle_scale
			if shader:
				frag.material = shader.duplicate()
			parent.add_child(frag)

			var t = _new_tween(frag)
			t.parallel().tween_property(frag, "position", node.global_position + Vector2(w/2, h/2), dur)
			t.parallel().tween_property(frag, "scale", Vector2.ONE, dur)
			t.parallel().tween_property(frag, "modulate:a", 1.0, dur)
			t.finished.connect(func(): if _is_valid(frag): frag.queue_free())

	# nascondi il nodo originale per la durata dell’animazione
	node.hide()
	await get_tree().create_timer(dur).timeout
	node.show()

# === FLOAT === #
# Funzione helper privata
func _float_random_loop(node: Node2D, orig_pos: Vector2, amplitude: Vector2, dur: float) -> void:
	if not _is_valid(node):
		return

	var target = orig_pos + Vector2(
		rng.randf_range(-amplitude.x, amplitude.x),
		rng.randf_range(-amplitude.y, amplitude.y)
	)

	var t = _new_tween(node)
	t.tween_property(node, "position", target, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.finished.connect(func(): _float_random_loop(node, orig_pos, amplitude, dur))

# Funzione pubblica da chiamare
func float_random(node: Node2D, amplitude: Vector2 = Vector2(10,10), dur: float = 1.0) -> void:
	if not _is_valid(node):
		return
	_float_random_loop(node, node.position, amplitude, dur)
