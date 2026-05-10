# =============================================================================
#  GlobalTweens.gd
#  Universal Tween Toolkit for Godot 4.x
#  Author: Rpx
#  License: MIT - Free to use, modify, and distribute
# =============================================================================
#
#  SETUP (AutoLoad Singleton - recommended)
#  ----------------------------------------------------------------------------
#  Project Settings -> AutoLoad -> Add GlobalTweens.gd -> Enable as Singleton
#
#  Then call from anywhere:
#      GlobalTweens.spawn_in($Enemy)
#      GlobalTweens.blink($Player, 4)
#      GlobalTweens.color_flash($Health, Color.RED)
#      GlobalTweens.squash_stretch($Ship, "y", 1.4)
#      GlobalTweens.glitch_flash($Portal)
#      GlobalTweens.quantum_jump($Enemy, Vector2(800, 300))
#      GlobalTweens.explode_and_free($Loot)
#      GlobalTweens.float_loop($Coin, 8.0, 2.0)
#      GlobalTweens.swing($Lantern, 12.0, 0.8)
#      GlobalTweens.zoom_pop($Button, 1.3, 0.2)
#      GlobalTweens.spin($Rotor, 180.0)
#      GlobalTweens.scene_fade_change(get_tree(), "res://scenes/Game.tscn")
#
#  SETUP (Local instance - if you prefer not using a singleton)
#  ----------------------------------------------------------------------------
#      func _ready():
#          var gt = GlobalTweens.new()
#          add_child(gt)
#          gt.spawn_in($Enemy)
#          gt.blink($Player, 4)
#
#  AWAITING TWEENS
#  ----------------------------------------------------------------------------
#  Most functions return the Tween or the last PropertyTweener so you can await:
#
#      await GlobalTweens.pop_scale($Button, 1.3, 0.2).finished
#      await GlobalTweens.fade($Panel, 1.0, 0.0, 0.4).finished
#      await GlobalTweens.spawn_in($Enemy, 0.3).finished
#
#  EASING QUICK REFERENCE
#  ----------------------------------------------------------------------------
#  Trans:  TRANS_LINEAR, TRANS_SINE, TRANS_BACK, TRANS_ELASTIC,
#          TRANS_BOUNCE, TRANS_QUAD, TRANS_CUBIC, TRANS_EXPO, TRANS_SPRING
#  Ease:   EASE_IN, EASE_OUT, EASE_IN_OUT, EASE_OUT_IN
#
#  FUNCTION INDEX
#  ----------------------------------------------------------------------------
#  Basic Visual
#      blink, fade, show_canvas, hide_canvas, color_flash, color_pulse
#
#  Scale / Pop
#      pop_scale, zoom_pop, elastic_pop, squash_stretch, wobble
#
#  Movement / Rotation
#      move_to, rotate_by, bounce, shake, shake_rot
#
#  Loops (fire and forget, run until node is freed)
#      float_loop, float_random, spin, swing, beat_pulse
#
#  Special FX
#      spawn_in, explode_and_free, quantum_jump
#      glitch_flash, phase_shift, energy_pulse, slide_in, slide_out
#      explode_frames, implode_frames
#
#  Scene Transitions
#      scene_fade_change, scene_slide_change
#
#  Node Lifecycle
#      activate, deactivate, show_node, hide_node
#
#  UI - Buttons
#      button_hover, button_unhover, button_press, button_disable, button_enable
#
#  UI - Input
#      lineedit_attention, lineedit_pop, lineedit_error_feedback
#
#  UI - Scroll
#      scrollbar_scroll_to
#
#  UI - Progress
#      texture_progress_fluid, texture_progress_pulse
#
#  UI - Wipe / Reveal
#      wipe_vertical
#
#  UI - Radial / Chain
#      radial_menu_open, chain_tweens, parallel_tweens
#
#  Text
#      typewriter, text_shake
#
#  Particles / FX
#      burst_particles, trail
#
#  Camera
#      camera_shake, camera_zoom_pulse
#
#  Tilemap
#      tilemap_fade_in, tilemap_shake
#
#  Light
#      light_flicker, light_pulse
#
# =============================================================================

extends Node

var rng = RandomNumberGenerator.new()


# =============================================================================
#  INTERNAL HELPERS
# =============================================================================

func _is_valid(n) -> bool:
	return is_instance_valid(n)

# Creates a new tween bound to the target node with a sensible default easing.
# All public functions call this instead of create_tween() directly so the
# default easing is consistent across the entire toolkit.
func _new_tween(target: Node) -> Tween:
	if not _is_valid(target):
		return null
	return target.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# =============================================================================
#  BASIC VISUAL
# =============================================================================

# Blinks the node by toggling alpha. Non-blocking.
func blink(node: CanvasItem, times: int = 3, speed: float = 0.1) -> Tween:
	if not _is_valid(node):
		return null
	var t = _new_tween(node)
	for i in range(times):
		t.tween_property(node, "modulate:a", 0.2, speed)
		t.tween_property(node, "modulate:a", 1.0, speed)
	return t

# Tweens modulate alpha from `from` to `to`. Returns the PropertyTweener for awaiting.
func fade(node: CanvasItem, from: float, to: float, dur: float = 0.4) -> PropertyTweener:
	if not _is_valid(node):
		return null
	node.modulate.a = from
	return _new_tween(node).tween_property(node, "modulate:a", to, dur)

# Fades out to full transparency.
func hide_canvas(node: CanvasItem, dur: float = 0.3) -> PropertyTweener:
	return fade(node, node.modulate.a, 0.0, dur)

# Fades in to full opacity.
func show_canvas(node: CanvasItem, dur: float = 0.3) -> PropertyTweener:
	return fade(node, node.modulate.a, 1.0, dur)

# Flashes the node to a given color and returns to the original color.
func color_flash(node: CanvasItem, color: Color = Color.RED, dur: float = 0.15) -> Tween:
	if not _is_valid(node):
		return null
	var original = node.modulate
	var t = _new_tween(node)
	t.tween_property(node, "modulate", color, dur * 0.5)
	t.tween_property(node, "modulate", original, dur * 0.5)
	return t

# Same as color_flash but slightly slower - useful for ambient color highlights.
func color_pulse(node: CanvasItem, color: Color = Color.YELLOW, dur: float = 0.4) -> Tween:
	return color_flash(node, color, dur)


# =============================================================================
#  SCALE / POP
# =============================================================================

# Scales up then back to original. Great for button feedback or hit reactions.
func pop_scale(node: Node2D, factor: float = 1.3, dur: float = 0.15) -> Tween:
	if not _is_valid(node):
		return null
	var s = node.scale
	var t = _new_tween(node)
	t.tween_property(node, "scale", s * factor, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", s, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	return t

# Like pop_scale but with an elastic overshoot. Feels springy and alive.
func elastic_pop(node: Node2D, factor: float = 1.5, dur: float = 0.4) -> Tween:
	if not _is_valid(node):
		return null
	var s = node.scale
	var t = _new_tween(node)
	t.tween_property(node, "scale", s * factor, dur * 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", s, dur * 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	return t

# Same as pop_scale with a higher overshoot. Best for UI popups appearing on screen.
func zoom_pop(node: Node2D, factor: float = 1.5, dur: float = 0.3) -> Tween:
	if not _is_valid(node):
		return null
	var s = node.scale
	var t = _new_tween(node)
	t.tween_property(node, "scale", s * factor, dur * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", s, dur * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	return t

# Squashes and stretches the node along one axis. Volume is preserved (inverse on opposite axis).
# axis: "x" or "y"
func squash_stretch(node: Node2D, axis: String = "y", factor: float = 1.3, dur: float = 0.15) -> Tween:
	if not _is_valid(node):
		return null
	var s = node.scale
	var stretch = Vector2(1.0 / factor, factor) if axis == "y" else Vector2(factor, 1.0 / factor)
	var t = _new_tween(node)
	t.tween_property(node, "scale", s * stretch, dur)
	t.tween_property(node, "scale", s, dur)
	return t

# Repeatedly squashes and stretches the node. Great for idle animations.
func wobble(node: Node2D, factor: float = 1.2, dur: float = 0.2, times: int = 3) -> Tween:
	if not _is_valid(node):
		return null
	var s = node.scale
	var t = _new_tween(node)
	for i in range(times):
		t.tween_property(node, "scale", s * Vector2(factor, 1.0 / factor), dur)
		t.tween_property(node, "scale", s * Vector2(1.0 / factor, factor), dur)
	t.tween_property(node, "scale", s, dur)
	return t


# =============================================================================
#  MOVEMENT / ROTATION
# =============================================================================

# Moves the node to a target position over `dur` seconds.
func move_to(node: Node2D, target: Vector2, dur: float = 0.4) -> PropertyTweener:
	if not _is_valid(node):
		return null
	return _new_tween(node).tween_property(node, "position", target, dur)

# Rotates the node by `degrees` relative to its current rotation.
func rotate_by(node: Node2D, degrees: float = 360.0, dur: float = 1.0) -> PropertyTweener:
	if not _is_valid(node):
		return null
	return _new_tween(node).tween_property(node, "rotation_degrees", node.rotation_degrees + degrees, dur)

# Single bounce up and back down.
func bounce(node: Node2D, height: float = 20.0, dur: float = 0.3) -> Tween:
	if not _is_valid(node):
		return null
	var y = node.position.y
	var t = _new_tween(node)
	t.tween_property(node, "position:y", y - height, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "position:y", y, dur * 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return t

# Shakes the node position using a timer. Intensity decays naturally over time.
func shake(node: Node2D, intensity: float = 10.0, dur: float = 0.3) -> void:
	if not _is_valid(node):
		return
	var original = node.position
	var steps = int(dur / 0.02)
	for i in range(steps):
		if not _is_valid(node):
			return
		var decay = 1.0 - (float(i) / steps)
		node.position = original + Vector2(
			rng.randf_range(-intensity, intensity) * decay,
			rng.randf_range(-intensity, intensity) * decay
		)
		await get_tree().create_timer(0.02).timeout
	if _is_valid(node):
		node.position = original

# Same as shake but on rotation_degrees instead of position.
func shake_rot(node: Node2D, intensity: float = 10.0, dur: float = 0.3) -> void:
	if not _is_valid(node):
		return
	var original = node.rotation_degrees
	var steps = int(dur / 0.02)
	for i in range(steps):
		if not _is_valid(node):
			return
		var decay = 1.0 - (float(i) / steps)
		node.rotation_degrees = original + rng.randf_range(-intensity, intensity) * decay
		await get_tree().create_timer(0.02).timeout
	if _is_valid(node):
		node.rotation_degrees = original


# =============================================================================
#  LOOPS (fire and forget - runs until the node is freed)
# =============================================================================

# Oscillates the node up and down indefinitely.
# amplitude: pixels to move from origin. speed: full cycles per second.
# axis: "x" or "y"
func float_loop(node: Node2D, amplitude: float = 10.0, speed: float = 1.0, axis: String = "y") -> void:
	if not _is_valid(node):
		return
	var period = 1.0 / speed
	var origin = node.position
	_float_loop_internal(node, origin, amplitude, period, axis)

func _float_loop_internal(node: Node2D, origin: Vector2, amplitude: float, period: float, axis: String) -> void:
	if not _is_valid(node):
		return
	var target = origin + (Vector2.DOWN if axis == "y" else Vector2.RIGHT) * amplitude
	var t = _new_tween(node)
	t.tween_property(node, "position", target, period * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "position", origin, period * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.finished.connect(func(): _float_loop_internal(node, origin, amplitude, period, axis), CONNECT_ONE_SHOT)

# Wanders the node randomly within an amplitude range. More organic than float_loop.
func float_random(node: Node2D, amplitude: Vector2 = Vector2(10, 10), dur: float = 1.0) -> void:
	if not _is_valid(node):
		return
	_float_random_internal(node, node.position, amplitude, dur)

func _float_random_internal(node: Node2D, origin: Vector2, amplitude: Vector2, dur: float) -> void:
	if not _is_valid(node):
		return
	var target = origin + Vector2(
		rng.randf_range(-amplitude.x, amplitude.x),
		rng.randf_range(-amplitude.y, amplitude.y)
	)
	var t = _new_tween(node)
	t.tween_property(node, "position", target, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.finished.connect(func(): _float_random_internal(node, origin, amplitude, dur), CONNECT_ONE_SHOT)

# Spins the node continuously. speed is degrees per second.
# This runs on process_frame so it's framerate-aware.
func spin(node: Node2D, speed: float = 180.0) -> void:
	if not _is_valid(node):
		return
	while _is_valid(node):
		node.rotation_degrees += speed * get_process_delta_time()
		await get_tree().process_frame

# Swings the node left and right around its origin rotation. Good for pendulums or hanging objects.
func swing(node: Node2D, degrees: float = 15.0, dur: float = 0.5) -> void:
	if not _is_valid(node):
		return
	_swing_internal(node, node.rotation_degrees, degrees, dur)

func _swing_internal(node: Node2D, origin: float, degrees: float, dur: float) -> void:
	if not _is_valid(node):
		return
	var t = _new_tween(node)
	t.tween_property(node, "rotation_degrees", origin + degrees, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "rotation_degrees", origin - degrees, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.finished.connect(func(): _swing_internal(node, origin, degrees, dur), CONNECT_ONE_SHOT)

# Pulses the node scale in sync with a BPM. Great for music-driven UI or rhythm games.
func beat_pulse(node: Node2D, bpm: float = 120.0, factor: float = 1.2) -> void:
	if not _is_valid(node):
		return
	var interval = 60.0 / bpm
	while _is_valid(node):
		pop_scale(node, factor, interval * 0.1)
		await get_tree().create_timer(interval).timeout


# =============================================================================
#  SPECIAL FX
# =============================================================================

# Scales from zero and fades in. The standard "spawn" entry animation.
func spawn_in(node: Node2D, dur: float = 0.3) -> Tween:
	if not _is_valid(node):
		return null
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	var t = _new_tween(node)
	t.parallel().tween_property(node, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(node, "modulate:a", 1.0, dur)
	return t

# Scales up and fades out, then frees the node. Use on enemies, loot, projectiles.
func explode_and_free(node: Node2D, dur: float = 0.4) -> Tween:
	if not _is_valid(node):
		return null
	var t = _new_tween(node)
	t.parallel().tween_property(node, "scale", node.scale * 1.5, dur)
	t.parallel().tween_property(node, "modulate:a", 0.0, dur)
	t.finished.connect(func():
		if _is_valid(node):
			node.queue_free()
	)
	return t

# Teleports the node to a new position with a shrink/grow transition.
# Gives a satisfying "blink" feel to instant movement.
func quantum_jump(node: Node2D, new_pos: Vector2, dur: float = 0.3) -> Tween:
	if not _is_valid(node):
		return null
	var t = _new_tween(node)
	t.tween_property(node, "scale", Vector2.ZERO, dur * 0.5)
	t.tween_callback(func(): node.position = new_pos)
	t.tween_property(node, "scale", Vector2.ONE, dur * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return t

# Rapid position jitter. Simulates a glitch or electric shock visual.
func glitch_flash(node: Node2D, intensity: float = 5.0, dur: float = 0.2) -> void:
	if not _is_valid(node):
		return
	var origin = node.position
	var steps = int(dur / 0.02)
	for i in range(steps):
		if not _is_valid(node):
			return
		node.position = origin + Vector2(
			rng.randf_range(-intensity, intensity),
			rng.randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(0.02).timeout
	if _is_valid(node):
		node.position = origin

# Rapid alpha flicker. Use on ghosts, shields, or anything phasing in/out.
func phase_shift(node: CanvasItem, times: int = 3, speed: float = 0.08) -> Tween:
	if not _is_valid(node):
		return null
	var t = _new_tween(node)
	for i in range(times):
		t.tween_property(node, "modulate:a", 0.0, speed)
		t.tween_property(node, "modulate:a", 1.0, speed)
	return t

# Color flash with a cyan/teal tint. Good for energy hits, pickups, or buffs.
func energy_pulse(node: CanvasItem, color: Color = Color(0.5, 1.0, 1.0), dur: float = 0.3) -> Tween:
	return color_flash(node, color, dur)

# Slides the node in from a direction. from_dir should be a cardinal Vector2 (e.g. Vector2.LEFT).
func slide_in(node: Node2D, from_dir: Vector2, dist: float = 200.0, dur: float = 0.4) -> PropertyTweener:
	if not _is_valid(node):
		return null
	var destination = node.position
	node.position = destination + from_dir.normalized() * dist
	return _new_tween(node).tween_property(node, "position", destination, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Slides the node out toward a direction. Does not free the node automatically.
func slide_out(node: Node2D, to_dir: Vector2, dist: float = 200.0, dur: float = 0.4) -> PropertyTweener:
	if not _is_valid(node):
		return null
	var target = node.position + to_dir.normalized() * dist
	return _new_tween(node).tween_property(node, "position", target, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


# =============================================================================
#  SPRITE EXPLOSION / IMPLOSION
# =============================================================================

# Splits a Sprite2D into a 4x4 grid of fragments that fly outward, then frees the original.
# Optionally applies a ShaderMaterial to each fragment.
func explode_frames(node: Sprite2D, dur: float = 0.5, particle_scale: float = 0.3, spread: float = 50.0, shader: ShaderMaterial = null) -> void:
	if not _is_valid(node):
		return
	var tex = node.texture
	if not tex:
		return
	var parent = node.get_parent()
	if not parent:
		return

	var cols = 4
	var rows = 4
	var size = tex.get_size()
	var w = size.x / cols
	var h = size.y / rows

	for x in range(cols):
		for y in range(rows):
			var frag = Sprite2D.new()
			frag.texture = tex
			frag.region_enabled = true
			frag.region_rect = Rect2(x * w, y * h, w, h)
			frag.global_position = node.global_position + Vector2(x * w - size.x * 0.5 + w * 0.5, y * h - size.y * 0.5 + h * 0.5)
			if shader:
				frag.material = shader.duplicate()
			parent.add_child(frag)

			var target = frag.global_position + Vector2(
				rng.randf_range(-spread, spread),
				rng.randf_range(-spread, spread)
			)
			var t = _new_tween(frag)
			t.parallel().tween_property(frag, "global_position", target, dur)
			t.parallel().tween_property(frag, "scale", Vector2.ONE * particle_scale, dur)
			t.parallel().tween_property(frag, "modulate:a", 0.0, dur)
			t.finished.connect(func():
				if _is_valid(frag):
					frag.queue_free()
			)

	node.queue_free()

# Reverse of explode_frames. Fragments fly in from random positions and assemble into the node.
func implode_frames(node: Sprite2D, dur: float = 0.5, particle_scale: float = 0.3, spread: float = 50.0, shader: ShaderMaterial = null) -> void:
	if not _is_valid(node):
		return
	var tex = node.texture
	if not tex:
		return
	var parent = node.get_parent()
	if not parent:
		return

	var cols = 4
	var rows = 4
	var size = tex.get_size()
	var w = size.x / cols
	var h = size.y / rows

	node.hide()

	for x in range(cols):
		for y in range(rows):
			var frag = Sprite2D.new()
			frag.texture = tex
			frag.region_enabled = true
			frag.region_rect = Rect2(x * w, y * h, w, h)

			var dest = node.global_position + Vector2(x * w - size.x * 0.5 + w * 0.5, y * h - size.y * 0.5 + h * 0.5)
			frag.global_position = dest + Vector2(
				rng.randf_range(-spread, spread),
				rng.randf_range(-spread, spread)
			)
			frag.scale = Vector2.ONE * particle_scale
			frag.modulate.a = 0.0
			if shader:
				frag.material = shader.duplicate()
			parent.add_child(frag)

			var t = _new_tween(frag)
			t.parallel().tween_property(frag, "global_position", dest, dur)
			t.parallel().tween_property(frag, "scale", Vector2.ONE, dur)
			t.parallel().tween_property(frag, "modulate:a", 1.0, dur)
			t.finished.connect(func():
				if _is_valid(frag):
					frag.queue_free()
			)

	await get_tree().create_timer(dur).timeout
	if _is_valid(node):
		node.show()


# =============================================================================
#  SCENE TRANSITIONS
# =============================================================================

# Fades to black, changes scene, then fades back in.
# Usage: await GlobalTweens.scene_fade_change(get_tree(), "res://scenes/Game.tscn")
func scene_fade_change(tree: SceneTree, scene_path: String, dur: float = 0.4) -> void:
	var canvas = CanvasLayer.new()
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.size = tree.root.size
	rect.modulate.a = 0.0
	canvas.add_child(rect)
	tree.root.add_child(canvas)

	var t1 = rect.create_tween()
	t1.tween_property(rect, "modulate:a", 1.0, dur)
	await t1.finished

	tree.change_scene_to_file(scene_path)

	var t2 = rect.create_tween()
	t2.tween_property(rect, "modulate:a", 0.0, dur)
	await t2.finished

	canvas.queue_free()

# Slides the new scene in from a direction while pushing the old scene out.
# dir: the direction the new scene slides FROM (e.g. Vector2.RIGHT = new scene enters from the right).
# Usage: await GlobalTweens.scene_slide_change(get_tree(), "res://scenes/Game.tscn", Vector2.LEFT)
func scene_slide_change(tree: SceneTree, scene_path: String, dir: Vector2 = Vector2.LEFT, dur: float = 0.4) -> void:
	var old_scene = tree.current_scene
	var viewport_size = tree.root.size

	var new_scene = load(scene_path).instantiate()
	tree.root.add_child(new_scene)
	new_scene.position = -dir.normalized() * viewport_size

	var t = new_scene.create_tween().set_parallel(true)
	t.tween_property(new_scene, "position", Vector2.ZERO, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(old_scene, "position", dir.normalized() * viewport_size, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	await t.finished
	old_scene.queue_free()
	tree.current_scene = new_scene


# =============================================================================
#  NODE LIFECYCLE
# =============================================================================

# Enables the node: re-enables CollisionShape2D and sets disabled=false on Controls.
# Plays a subtle pop for visual feedback.
func activate(node: Node) -> void:
	if not _is_valid(node):
		return
	if node.has_node("CollisionShape2D"):
		var shape = node.get_node("CollisionShape2D")
		if _is_valid(shape) and shape is CollisionShape2D:
			shape.disabled = false
	if node.has_method("set_disabled"):
		node.set_disabled(false)
	if node is Node2D:
		pop_scale(node, 1.1, 0.15)

# Disables the node: disables CollisionShape2D and calls set_disabled on Controls.
# Fades alpha down for visual feedback.
func deactivate(node: Node) -> void:
	if not _is_valid(node):
		return
	if node.has_node("CollisionShape2D"):
		var shape = node.get_node("CollisionShape2D")
		if _is_valid(shape) and shape is CollisionShape2D:
			shape.disabled = true
	if node.has_method("set_disabled"):
		node.call_deferred("set_disabled", true)
	if node is CanvasItem:
		fade(node, node.modulate.a, 0.3, 0.2)

# Shows the node with an optional fade-in. Works on any Node with a show() method.
func show_node(node: Node, smooth: bool = true, duration: float = 0.2) -> void:
	if not _is_valid(node):
		return
	if node.has_method("show"):
		node.show()
	if smooth and node is CanvasItem:
		node.modulate.a = 0.0
		fade(node, 0.0, 1.0, duration)
	elif node is CanvasItem:
		node.modulate.a = 1.0

# Hides the node with an optional fade-out. Calls hide() after the tween completes.
func hide_node(node: Node, smooth: bool = true, duration: float = 0.2) -> void:
	if not _is_valid(node):
		return
	if smooth and node is CanvasItem:
		var t = create_tween()
		t.tween_property(node, "modulate:a", 0.0, duration)
		t.tween_callback(func():
			if _is_valid(node) and node.has_method("hide"):
				node.hide()
		)
	else:
		if node.has_method("hide"):
			node.hide()


# =============================================================================
#  UI - BUTTONS
# =============================================================================

# Scale up on mouse enter. Pair with button_unhover on mouse_exited.
func button_hover(btn: Control, scale_factor: float = 1.1, dur: float = 0.12) -> Tween:
	if not _is_valid(btn):
		return null
	var t = _new_tween(btn)
	t.tween_property(btn, "scale", Vector2.ONE * scale_factor, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return t

# Returns to normal scale on mouse exit.
func button_unhover(btn: Control, dur: float = 0.1) -> PropertyTweener:
	if not _is_valid(btn):
		return null
	return _new_tween(btn).tween_property(btn, "scale", Vector2.ONE, dur)

# Quick squish on click. Pair with button.pressed signal.
func button_press(btn: Control, dur: float = 0.08) -> Tween:
	if not _is_valid(btn):
		return null
	var t = _new_tween(btn)
	t.tween_property(btn, "scale", Vector2.ONE * 0.9, dur)
	t.tween_property(btn, "scale", Vector2.ONE, dur)
	return t

# Visually disables a button with a fade and shrink. Also sets disabled = true.
func button_disable(btn: Button, dur: float = 0.2) -> Tween:
	if not _is_valid(btn):
		return null
	btn.disabled = true
	var t = _new_tween(btn)
	t.parallel().tween_property(btn, "modulate:a", 0.4, dur)
	t.parallel().tween_property(btn, "scale", Vector2.ONE * 0.95, dur)
	return t

# Re-enables a button with a fade and grow animation. Also sets disabled = false.
func button_enable(btn: Button, dur: float = 0.2) -> Tween:
	if not _is_valid(btn):
		return null
	btn.disabled = false
	btn.modulate.a = 0.4
	btn.scale = Vector2.ONE * 0.95
	var t = _new_tween(btn)
	t.parallel().tween_property(btn, "modulate:a", 1.0, dur)
	t.parallel().tween_property(btn, "scale", Vector2.ONE, dur)
	return t


# =============================================================================
#  UI - INPUT FIELDS
# =============================================================================

# Flashes the LineEdit with a color. Use on validation errors or required field prompts.
func lineedit_attention(line: LineEdit, color: Color = Color.RED, dur: float = 0.15) -> Tween:
	return color_flash(line, color, dur)

# Softer color pop. Use for positive feedback (e.g. autocomplete accepted).
func lineedit_pop(line: LineEdit, color: Color = Color.YELLOW, dur: float = 0.2) -> Tween:
	return color_flash(line, color, dur)

# Alias for lineedit_attention. Kept for API clarity when slot is "error" context.
func lineedit_error_feedback(line: LineEdit, color: Color = Color.RED, dur: float = 0.2) -> Tween:
	return color_flash(line, color, dur)


# =============================================================================
#  UI - SCROLL
# =============================================================================

# Smoothly animates a scrollbar to a target value. Clamps to valid range.
func scrollbar_scroll_to(scroll: ScrollBar, value: float, dur: float = 0.3) -> PropertyTweener:
	if not _is_valid(scroll):
		return null
	var clamped = clamp(value, scroll.min_value, scroll.max_value)
	return _new_tween(scroll).tween_property(scroll, "value", clamped, dur)


# =============================================================================
#  UI - PROGRESS BARS
# =============================================================================

# Animates a TextureProgressBar value smoothly. Use for health bars, XP bars, loading.
func texture_progress_fluid(progress: TextureProgressBar, target_value: float, duration: float = 0.5) -> PropertyTweener:
	if not _is_valid(progress):
		return null
	return _new_tween(progress).tween_property(progress, "value", target_value, duration)

# Flashes the tint_progress color. Great for low-health warning pulses.
func texture_progress_pulse(progress: TextureProgressBar, color: Color = Color.YELLOW, duration: float = 0.3) -> Tween:
	if not _is_valid(progress):
		return null
	var original = progress.tint_progress
	var t = _new_tween(progress)
	t.tween_property(progress, "tint_progress", color, duration * 0.5)
	t.tween_property(progress, "tint_progress", original, duration * 0.5)
	return t


# =============================================================================
#  UI - WIPE / REVEAL
# =============================================================================

# Reveals or hides a Control node by animating its size.Y (vertical curtain effect).
# open=true reveals the node (height goes from 0 to full). open=false hides it.
func wipe_vertical(node: Control, open: bool = true, duration: float = 0.3) -> PropertyTweener:
	if not _is_valid(node):
		return null
	node.clip_contents = true
	var full_size = node.size
	if open:
		var original_size = full_size
		node.size = Vector2(original_size.x, 0)
		return _new_tween(node).tween_property(node, "size", original_size, duration)
	else:
		return _new_tween(node).tween_property(node, "size", Vector2(full_size.x, 0), duration)


# =============================================================================
#  UI - RADIAL / CHAIN UTILITIES
# =============================================================================

# Animates an array of buttons outward in a radial pattern from their origin.
# Call with open=false to collapse back. Assumes buttons start at position Vector2.ZERO.
func radial_menu_open(buttons: Array, radius: float = 100.0, duration: float = 0.3, open: bool = true) -> void:
	for i in range(buttons.size()):
		var btn = buttons[i]
		if not _is_valid(btn):
			continue
		var angle = (i * TAU) / buttons.size()
		var target = Vector2(cos(angle), sin(angle)) * radius if open else Vector2.ZERO
		_new_tween(btn).tween_property(btn, "position", target, duration).set_delay(i * 0.04).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Runs a tween on each target/property/value/duration tuple in lock-step arrays.
# All arrays must have the same length.
func chain_tweens(targets: Array, properties: Array, values: Array, durations: Array) -> Array:
	var tweens = []
	for i in range(targets.size()):
		if not _is_valid(targets[i]):
			continue
		var t = _new_tween(targets[i])
		t.tween_property(targets[i], properties[i], values[i], durations[i])
		tweens.append(t)
	return tweens

# Runs multiple property tweens in parallel on a single node.
# tweens_data is an Array of [property: String, value, duration: float] arrays.
func parallel_tweens(node: Node, tweens_data: Array) -> Tween:
	if not _is_valid(node):
		return null
	var t = _new_tween(node)
	for data in tweens_data:
		t.parallel().tween_property(node, data[0], data[1], data[2])
	return t


# =============================================================================
#  TEXT
# =============================================================================

# Types out text character by character, like a typewriter or dialogue system.
func typewriter(label: Label, text: String, delay: float = 0.05) -> void:
	if not _is_valid(label):
		return
	label.text = ""
	for i in range(text.length()):
		if not _is_valid(label):
			return
		label.text += text[i]
		await get_tree().create_timer(delay).timeout

# Horizontal position shake for labels. Good for "wrong answer" or damage feedback.
func text_shake(label: Label, intensity: float = 2.0, duration: float = 0.2) -> Tween:
	if not _is_valid(label):
		return null
	var origin = label.position
	var t = _new_tween(label)
	var steps = 4
	for i in range(steps):
		t.tween_property(label, "position", origin + Vector2(rng.randf_range(-intensity, intensity), 0), duration / steps)
	t.tween_property(label, "position", origin, duration / steps)
	return t


# =============================================================================
#  PARTICLES / FX
# =============================================================================

# Spawns ColorRect dots that fly outward in a burst pattern, then fade and self-destruct.
# Good as a cheap particle burst when GPUParticles2D is overkill.
func burst_particles(node: Node2D, count: int = 8, speed: float = 100.0, duration: float = 0.5, color: Color = Color.WHITE) -> void:
	if not _is_valid(node):
		return
	var parent = node.get_parent()
	if not parent:
		return
	for i in range(count):
		var dot = ColorRect.new()
		dot.size = Vector2(4, 4)
		dot.color = color
		dot.global_position = node.global_position
		parent.add_child(dot)

		var angle = (i * TAU) / count
		var target = dot.global_position + Vector2(cos(angle), sin(angle)) * speed

		var t = _new_tween(dot)
		t.parallel().tween_property(dot, "global_position", target, duration)
		t.parallel().tween_property(dot, "modulate:a", 0.0, duration)
		t.finished.connect(dot.queue_free)

# Leaves fading ghost copies of the node at regular intervals to create a motion trail.
# The node must have a parent. Trail clones are duplicated and fade automatically.
func trail(node: Node2D, length: int = 5, interval: float = 0.1, fade_duration: float = 0.3) -> void:
	if not _is_valid(node):
		return
	var parent = node.get_parent()
	if not parent:
		return
	for i in range(length):
		if not _is_valid(node):
			return
		await get_tree().create_timer(interval).timeout
		var clone = node.duplicate()
		clone.modulate.a = 0.7
		parent.add_child(clone)
		fade(clone, 0.7, 0.0, fade_duration)
		await get_tree().create_timer(fade_duration).timeout
		if _is_valid(clone):
			clone.queue_free()


# =============================================================================
#  CAMERA
# =============================================================================

# Camera shake with exponential decay. More natural than a flat random shake.
# Use on Camera2D after an explosion, hit, or impact.
func camera_shake(camera: Camera2D, intensity: float = 10.0, duration: float = 0.3) -> void:
	if not _is_valid(camera):
		return
	var original = camera.offset
	var steps = int(duration / 0.02)
	for i in range(steps):
		if not _is_valid(camera):
			return
		var decay = 1.0 - (float(i) / steps)
		camera.offset = original + Vector2(
			rng.randf_range(-intensity, intensity) * decay,
			rng.randf_range(-intensity, intensity) * decay
		)
		await get_tree().create_timer(0.02).timeout
	if _is_valid(camera):
		camera.offset = original

# Zooms the camera in or out and back. Good for dramatic moments or hit pauses.
func camera_zoom_pulse(camera: Camera2D, target_zoom: float = 1.2, duration: float = 0.3) -> Tween:
	if not _is_valid(camera):
		return null
	var original = camera.zoom
	var t = _new_tween(camera)
	t.tween_property(camera, "zoom", Vector2.ONE * target_zoom, duration * 0.5)
	t.tween_property(camera, "zoom", original, duration * 0.5)
	return t


# =============================================================================
#  TILEMAP
# =============================================================================

# Fades an entire TileMap from transparent to opaque. Use on level load or reveal.
func tilemap_fade_in(tilemap: TileMap, duration: float = 0.5) -> PropertyTweener:
	if not _is_valid(tilemap):
		return null
	tilemap.modulate.a = 0.0
	return _new_tween(tilemap).tween_property(tilemap, "modulate:a", 1.0, duration)

# Shakes the entire TileMap position. Use for earthquake effects.
func tilemap_shake(tilemap: TileMap, intensity: float = 5.0, duration: float = 0.3) -> void:
	if not _is_valid(tilemap):
		return
	var original = tilemap.position
	var steps = int(duration / 0.02)
	for i in range(steps):
		if not _is_valid(tilemap):
			return
		tilemap.position = original + Vector2(
			rng.randf_range(-intensity, intensity),
			rng.randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(0.02).timeout
	if _is_valid(tilemap):
		tilemap.position = original


# =============================================================================
#  LIGHT
# =============================================================================

# Flickers a PointLight2D energy value randomly. Runs indefinitely until the light is freed.
# Use for torches, candles, damaged electronics.
func light_flicker(light: PointLight2D, intensity_min: float = 0.3, intensity_max: float = 1.0, speed: float = 0.1) -> void:
	if not _is_valid(light):
		return
	while _is_valid(light):
		light.energy = rng.randf_range(intensity_min, intensity_max)
		await get_tree().create_timer(speed).timeout

# Pulses the light energy up and back down. Use for muzzle flash, magic hit, or power surge.
func light_pulse(light: PointLight2D, target_energy: float = 2.0, duration: float = 0.5) -> Tween:
	if not _is_valid(light):
		return null
	var original = light.energy
	var t = _new_tween(light)
	t.tween_property(light, "energy", target_energy, duration * 0.5)
	t.tween_property(light, "energy", original, duration * 0.5)
	return t
