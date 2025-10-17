# =========================================================
#  GlobalTweens.gd
#  Universal Tween Toolkit for Godot 4.x
#  Author: Rpx
#  License: MIT — Free to use, modify, and distribute
# =========================================================
#  FEATURES
#  ────────────────────────────────────────────────
#   • blink, fade, show, hide
#   • shake, move_to, bounce, rotate
#   • activate / deactivate
#   • pop_scale, color_flash, spawn_in
#   • explode_and_free, squash_stretch
#   • slide_in, slide_out, quantum_jump
#   • phase_shift, energy_pulse, glitch_flash
#   • float_loop, move_loop, bounce_loop, tween_loop
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
#   • All loops are async and independent
#   • All easing/transition parameters can be strings:
#         trans = "sine", "back", "elastic", "quad", etc.
#         ease  = "in", "out", "in_out"
#   • Each tween returns its Tween object (for chaining or debug)
#   • Safety checks prevent invalid node usage
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
# =========================================================

extends Node
#@tool
# GlobalTweens.gd
# A single, global utility for creating tweens and async looped animations.
# - All tween functions accept `wait: bool = false` and return the Tween they create (or null).
# - Loop animations are asynchronous and independent: they re-create tweens each cycle
#   and stop automatically if the node becomes invalid.
# - Transition and ease arguments accept human-friendly strings (e.g. "sine", "back")
#   or numeric Tween constants. Strings are mapped to Tween constants internally.

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# -------------------------------
# Utility helpers
# -------------------------------

func _is_valid(node: Object) -> bool:
	return is_instance_valid(node)

func _parse_transition(trans) -> int:
	# Accept either numeric constant or a descriptive string.
	if typeof(trans) == TYPE_INT:
		return trans
	if trans == null:
		return Tween.TRANS_SINE
	var s := String(trans).to_lower()
	var table := {
		"sine": Tween.TRANS_SINE,
		"linear": Tween.TRANS_LINEAR,
		"quad": Tween.TRANS_QUAD,
		"cubic": Tween.TRANS_CUBIC,
		"quart": Tween.TRANS_QUART,
		"quint": Tween.TRANS_QUINT,
		"expo": Tween.TRANS_EXPO,
		"circ": Tween.TRANS_CIRC,
		"elastic": Tween.TRANS_ELASTIC,
		"back": Tween.TRANS_BACK,
		"bounce": Tween.TRANS_BOUNCE
	}
	return table.get(s, Tween.TRANS_SINE)

func _parse_ease(ease) -> int:
	if typeof(ease) == TYPE_INT:
		return ease
	if ease == null:
		return Tween.EASE_IN_OUT
	var s := String(ease).to_lower()
	var table := {
		"in": Tween.EASE_IN,
		"out": Tween.EASE_OUT,
		"in_out": Tween.EASE_IN_OUT,
		"inout": Tween.EASE_IN_OUT,
		"in_and_out": Tween.EASE_IN_OUT,
		"in_andout": Tween.EASE_IN_OUT,
	}
	return table.get(s, Tween.EASE_IN_OUT)

func _new_tween(target: Node, trans = null, ease = null) -> Tween:
	# Create a neutral tween attached to the target node and set its transition/ease.
	if not _is_valid(target):
		return null
	var t: Tween = target.create_tween()
	t.set_trans(_parse_transition(trans))
	t.set_ease(_parse_ease(ease))
	return t

func _handle_wait(tween: Tween, wait: bool) -> void:
	# Centralized await handling. If tween is null and wait requested, return immediately.
	if tween == null:
		return
	if wait:
		await tween.finished

# -------------------------------
# Basic visual effects
# -------------------------------

func blink(node: CanvasItem, times: int = 3, speed: float = 0.1, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var t := _new_tween(node, trans, ease)
	for i in range(times):
		t.tween_property(node, "modulate:a", 0.2, speed)
		t.tween_property(node, "modulate:a", 1.0, speed)
	_handle_wait(t, wait)
	return t

func fade(node: CanvasItem, from_val: float, to_val: float, dur: float = 0.4, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	node.modulate.a = from_val
	var t := _new_tween(node, trans, ease)
	t.tween_property(node, "modulate:a", to_val, dur)
	_handle_wait(t, wait)
	return t

func hide(node: CanvasItem, dur: float = 0.3, wait: bool = false, trans = null, ease = null) -> Tween:
	return fade(node, node.modulate.a, 0.0, dur, wait, trans, ease)

func show(node: CanvasItem, dur: float = 0.3, wait: bool = false, trans = null, ease = null) -> Tween:
	return fade(node, node.modulate.a, 1.0, dur, wait, trans, ease)

func color_flash(node: CanvasItem, color: Color = Color(1, 0, 0), dur: float = 0.15, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var original := node.modulate
	var t := _new_tween(node, trans, ease)
	t.tween_property(node, "modulate", color, dur / 2)
	t.tween_property(node, "modulate", original, dur / 2)
	_handle_wait(t, wait)
	return t

# -------------------------------
# Scale / pop / stretch
# -------------------------------

func pop_scale(node: Node2D, factor: float = 1.3, dur: float = 0.15, wait: bool = false, trans = "back", ease = "out") -> Tween:
	if not _is_valid(node):
		return null
	var t := _new_tween(node, trans, ease)
	var s := node.scale
	# pop out then back, parallel for smoothness
	t.parallel().tween_property(node, "scale", s * factor, dur)
	t.parallel().tween_property(node, "scale", s, dur)
	_handle_wait(t, wait)
	return t

func squash_stretch(node: Node2D, axis: String = "y", factor: float = 1.3, dur: float = 0.15, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var t := _new_tween(node, trans, ease)
	var s := node.scale
	var stretch := Vector2.ONE
	if axis == "y":
		stretch = Vector2(1.0 / factor, factor)
	else:
		stretch = Vector2(factor, 1.0 / factor)
	t.tween_property(node, "scale", s * stretch, dur)
	t.tween_property(node, "scale", s, dur)
	_handle_wait(t, wait)
	return t

# -------------------------------
# Movement / rotation
# -------------------------------

func shake(node: Node2D, intensity: float = 10.0, dur: float = 0.3, wait: bool = false) -> Tween:
	# Shake uses a short-lived Timer to jitter the node; it's not a Tween but we return a faux Tween via a Timer
	if not _is_valid(node):
		return null
	var original := node.position
	var timer := Timer.new()
	timer.wait_time = 0.02
	timer.one_shot = false
	node.add_child(timer)
	timer.timeout.connect(func ():
		if not _is_valid(node):
			timer.stop()
			return
		node.position = original + Vector2(
			rng.randf_range(-intensity, intensity),
			rng.randf_range(-intensity, intensity)
		)
	)
	timer.start()
	# Stop after dur
	await get_tree().create_timer(dur).timeout
	if _is_valid(timer):
		timer.stop()
		timer.queue_free()
	if _is_valid(node):
		node.position = original
	# There's no Tween to return; return null
	return null

func move_to(node: Node2D, target: Vector2, dur: float = 0.4, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var t := _new_tween(node, trans, ease)
	t.tween_property(node, "position", target, dur)
	_handle_wait(t, wait)
	return t

func rotate(node: Node2D, degrees: float = 360.0, dur: float = 1.0, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var target := node.rotation_degrees + degrees
	var t := _new_tween(node, trans, ease)
	t.tween_property(node, "rotation_degrees", target, dur)
	_handle_wait(t, wait)
	return t

func bounce(node: Node2D, height: float = 20.0, dur: float = 0.3, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var y := node.position.y
	var t := _new_tween(node, trans, ease)
	t.tween_property(node, "position:y", y - height, dur / 2)
	t.tween_property(node, "position:y", y, dur / 2)
	_handle_wait(t, wait)
	return t

# -------------------------------
# Activate / deactivate helpers
# -------------------------------

func activate(node: Node, wait: bool = false) -> Tween:
	if not _is_valid(node):
		return null
	# enable collision if present
	if node.has_node("CollisionShape2D"):
		var shape := node.get_node("CollisionShape2D")
		if shape and shape is CollisionShape2D:
			shape.disabled = false
	# enable controls
	if node.has_method("set_disabled"):
		node.set_disabled(false)
	# visual feedback
	return pop_scale(node, 1.1, 0.15, wait)

func deactivate(node: Node, wait: bool = false) -> Tween:
	if not _is_valid(node):
		return null
	if node.has_node("CollisionShape2D"):
		var shape := node.get_node("CollisionShape2D")
		if shape and shape is CollisionShape2D:
			shape.disabled = true
	if node.has_method("set_disabled"):
		node.call_deferred("set_disabled", true)
	return fade(node, node.modulate.a, 0.3, 0.2, wait)

# -------------------------------
# Show/Hide convenience (safe)
# -------------------------------

func show_node(node: Node, smooth: bool = true, duration: float = 0.2, wait: bool = false) -> Tween:
	if not _is_valid(node):
		return null
	if node.has_method("show"):
		node.show()
	if smooth and node is CanvasItem:
		node.modulate.a = 0.0
		return fade(node, 0.0, 1.0, duration, wait)
	else:
		if node is CanvasItem:
			node.modulate.a = 1.0
		return null

func hide_node(node: Node, smooth: bool = true, duration: float = 0.2, wait: bool = false) -> Tween:
	if not _is_valid(node):
		return null
	if smooth and node is CanvasItem:
		var t := _new_tween(node)
		node.modulate.a = node.modulate.a
		t.tween_property(node, "modulate:a", 0.0, duration)
		t.tween_callback(func ():
			if is_instance_valid(node) and node.has_method("hide"):
				node.hide()
		)
		_handle_wait(t, wait)
		return t
	else:
		if node.has_method("hide"):
			node.hide()
		return null

# -------------------------------
# Special FX
# -------------------------------

func spawn_in(node: Node2D, dur: float = 0.3, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	var t := _new_tween(node, trans, ease)
	t.parallel().tween_property(node, "scale", Vector2.ONE, dur)
	t.parallel().tween_property(node, "modulate:a", 1.0, dur)
	_handle_wait(t, wait)
	return t

func explode_and_free(node: Node2D, dur: float = 0.4, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var t := _new_tween(node, trans, ease)
	t.parallel().tween_property(node, "scale", node.scale * 1.5, dur)
	t.parallel().tween_property(node, "modulate:a", 0.0, dur)
	t.finished.connect(func ():
		if _is_valid(node):
			node.queue_free()
	)
	_handle_wait(t, wait)
	return t

func energy_pulse(node: CanvasItem, color: Color = Color(0.5, 1, 1), dur: float = 0.3, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var orig := node.modulate
	var t := _new_tween(node, trans, ease)
	t.tween_property(node, "modulate", color, dur / 2)
	t.tween_property(node, "modulate", orig, dur / 2)
	_handle_wait(t, wait)
	return t

func glitch_flash(node: Node2D, intensity: float = 5.0, dur: float = 0.2, wait: bool = false) -> Tween:
	if not _is_valid(node):
		return null
	var orig_pos := node.position
	var cycles := int(dur / 0.02)
	for i in range(cycles):
		node.position = orig_pos + Vector2(
			rng.randf_range(-intensity, intensity),
			rng.randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(0.02).timeout
	if _is_valid(node):
		node.position = orig_pos
	return null

func quantum_jump(node: Node2D, new_pos: Vector2, dur: float = 0.3, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var t := _new_tween(node, trans, ease)
	t.tween_property(node, "scale", Vector2.ZERO, dur / 2)
	t.tween_callback(func ():
		if _is_valid(node):
			node.position = new_pos
	)
	t.tween_property(node, "scale", Vector2.ONE, dur / 2)
	_handle_wait(t, wait)
	return t

func phase_shift(node: CanvasItem, times: int = 3, speed: float = 0.08, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var t := _new_tween(node, trans, ease)
	for i in range(times):
		t.tween_property(node, "modulate:a", 0.0, speed)
		t.tween_property(node, "modulate:a", 1.0, speed)
	_handle_wait(t, wait)
	return t

func slide_in(node: Node2D, from_dir: Vector2, dist: float = 200.0, dur: float = 0.4, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var start_pos := node.position + from_dir.normalized() * dist
	node.position = start_pos
	return move_to(node, start_pos - from_dir.normalized() * dist, dur, wait, trans, ease)

func slide_out(node: Node2D, to_dir: Vector2, dist: float = 200.0, dur: float = 0.4, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	return move_to(node, node.position + to_dir.normalized() * dist, dur, wait, trans, ease)

# -------------------------------
# Looping animations (async, independent)
# -------------------------------

func tween_loop(node: Object, property_path: String, values: Array, duration: float = 1.0, loop: bool = true, wait: bool = false, trans = null, ease = null) -> Tween:
	# Plays a sequence of values in loop. values: [v1, v2, v3...]
	if not _is_valid(node):
		return null
	var last_tween: Tween = null
	while loop and _is_valid(node):
		for v in values:
			if not _is_valid(node):
				break
			last_tween = _new_tween(node, trans, ease)
			last_tween.tween_property(node, property_path, v, duration)
			await last_tween.finished
		# continue looping
	# if wait is requested, block until loop ends (node freed or loop set false)
	if wait:
		# wait until node invalid
		while _is_valid(node):
			await get_tree().process_frame
	return last_tween

func float_loop(node: Node2D, amplitude: float = 20.0, speed: float = 2.0, axis: String = "y", loop: bool = true, wait: bool = false, trans = null, ease = null) -> Tween:
	# Smooth hovering effect using sine-like tween cycles (to/from)
	if not _is_valid(node):
		return null
	var original := node.position
	var last_t: Tween = null
	while loop and _is_valid(node):
		var offset := Vector2.ZERO
		if axis == "y":
			offset = Vector2(0, -amplitude)
		else:
			offset = Vector2(-amplitude, 0)
		# move out
		last_t = _new_tween(node, trans, ease)
		last_t.tween_property(node, "position", original + offset, speed)
		await last_t.finished
		# move back
		last_t = _new_tween(node, trans, ease)
		last_t.tween_property(node, "position", original, speed)
		await last_t.finished
	# if wait requested, block until node freed
	if wait:
		while _is_valid(node):
			await get_tree().process_frame
	return last_t

func move_loop(node: Node2D, offset: Vector2, duration: float = 1.0, loop: bool = true, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var original := node.position
	var last_t: Tween = null
	while loop and _is_valid(node):
		last_t = _new_tween(node, trans, ease)
		last_t.tween_property(node, "position", original + offset, duration)
		await last_t.finished
		last_t = _new_tween(node, trans, ease)
		last_t.tween_property(node, "position", original, duration)
		await last_t.finished
	if wait:
		while _is_valid(node):
			await get_tree().process_frame
	return last_t

func bounce_loop(node: Node2D, height: float = 20.0, dur: float = 0.6, loop: bool = true, wait: bool = false, trans = null, ease = null) -> Tween:
	if not _is_valid(node):
		return null
	var original_y := node.position.y
	var last_t: Tween = null
	while loop and _is_valid(node):
		# up
		last_t = _new_tween(node, trans, ease)
		last_t.tween_property(node, "position:y", original_y - height, dur / 2)
		await last_t.finished
		# down
		last_t = _new_tween(node, trans, ease)
		last_t.tween_property(node, "position:y", original_y, dur / 2)
		await last_t.finished
	if wait:
		while _is_valid(node):
			await get_tree().process_frame
	return last_t

# -------------------------------
# END of file
# -------------------------------
