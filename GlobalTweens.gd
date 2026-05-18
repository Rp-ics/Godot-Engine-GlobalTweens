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
static var _beat_call_ids := {} 
static var _beat_next_id := 0
static var _pop_tweens := {}

static var _float_tweens := {}
static var _spin_active := {}
static var _swing_tweens := {}

static var _label_rainbow_active := {}
static var _label_gradient_tweens := {}

# Dictionary to track active squash-stretch tweens per node (anti-spam).
static var _squash_tweens := {}

# Dictionary to track active wobble tweens per node (anti-spam).
static var _wobble_tweens := {}

# Dictionary to track active rotate tweens per node (anti-spam).
static var _rotate_tweens := {}

# Dictionary to track active text_shake tweens per label (anti-spam).
static var _text_shake_tweens := {}

# Dictionary to track active LineEdit flash tweens (anti-spam).
static var _lineedit_flash_tweens := {}
static var _lineedit_original_colors := {}   # stores original modulate per LineEdit

# === SCENE CHANGER === #
static var _transition_active := false  # prevents overlapping scene transitions

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

# Tweens modulate alpha from the **current** alpha to `to`.
# (The `from` argument is kept for backward compatibility but no longer forces a jump.)
func fade(node: CanvasItem, from: float, to: float, dur: float = 0.4) -> PropertyTweener:
	if not _is_valid(node):
		return null
	# No forced modulate – start tween from whatever alpha the node already has
	return _new_tween(node).tween_property(node, "modulate:a", to, dur)
	
func hide_canvas(node: CanvasItem, dur: float = 0.3) -> PropertyTweener:
	return fade(node, node.modulate.a, 0.0, dur)    # "from" is ignored but kept for API compatibility

func show_canvas(node: CanvasItem, dur: float = 0.3) -> PropertyTweener:
	return fade(node, node.modulate.a, 1.0, dur)

# Looping / ping‑pong fade of the alpha channel.
# - `to` is the alpha value the node reaches at the end of each “forward” fade.
# - If `infinite` is true the loop runs forever (ignore `cycles`).
# - Otherwise `cycles` defines how many complete fade‑in/fade‑out cycles to perform.
#   Example: cycles=3 → fade to, back, to, back, to, back → 6 transitions total.
# Returns the Tween that drives the whole sequence (you can await tween.finished if not infinite).
func fade_loop(node: CanvasItem, to: float, dur: float = 0.4, infinite: bool = false, cycles: int = 1) -> Tween:
	if not _is_valid(node):
		return null

	var start_alpha: float = node.modulate.a
	var tween: Tween = _new_tween(node)

	if infinite:
		# Ping‑pong forever: from start_alpha -> to -> start_alpha ...
		tween.tween_property(node, "modulate:a", to, dur)
		tween.tween_property(node, "modulate:a", start_alpha, dur)
		tween.set_loops(0)   # 0 = infinite loops
	elif cycles > 1:
		# Repeat the forward/backward pair 'cycles' times
		tween.tween_property(node, "modulate:a", to, dur)
		tween.tween_property(node, "modulate:a", start_alpha, dur)
		tween.set_loops(cycles)
	else:
		# Single fade to `to`
		tween.tween_property(node, "modulate:a", to, dur)

	return tween

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
# Aggiungi questa variabile statica in cima al file
func pop_scale(node: Node2D, factor: float = 1.3, dur: float = 0.15) -> Tween:
	if not _is_valid(node):
		return null
	
	# Uccidi il vecchio Tween prima di partire
	if _pop_tweens.has(node) and is_instance_valid(_pop_tweens[node]):
		_pop_tweens[node].kill()
	
	var s = node.scale
	var t = _new_tween(node)
	_pop_tweens[node] = t  # registra il nuovo
	
	t.tween_property(node, "scale", s * factor, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", s, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Pulizia a fine animazione
	t.finished.connect(func():
		if _pop_tweens.get(node) == t:
			_pop_tweens.erase(node)
	)
	
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
# The node always returns to the *original* scale it had when the first call was made,
# even if you spam the function.
func squash_stretch(node: Node2D, axis: String = "y", factor: float = 1.3, dur: float = 0.15) -> Tween:
	if not _is_valid(node):
		return null

	# If there's already an active squash-stretch tween for this node, kill it.
	if _squash_tweens.has(node) and is_instance_valid(_squash_tweens[node]):
		_squash_tweens[node].kill()

	# Determine the original scale we must always return to.
	# If no tween is stored, use the current scale as the original.
	var original_scale: Vector2
	if _squash_tweens.has(node):
		# Retrieve stored original scale (we'll store it later, but we need to keep it across calls)
		# Actually we can't store the scale inside the dict value easily without extra data.
		# Let's store a small dictionary { "tween": tween, "original": scale }.
		pass
	# Better: store a dictionary with the original scale and the tween.

	# store { "tween": Tween, "original": Vector2 }
	var entry = _squash_tweens.get(node, {})
	var original: Vector2 = entry.get("original", node.scale)

	# If there was no entry (first call), save the current scale as the official original.
	if not _squash_tweens.has(node):
		original = node.scale

	# Build the stretch vector (volume-preserving)
	var stretch_vec = Vector2(1.0 / factor, factor) if axis == "y" else Vector2(factor, 1.0 / factor)

	# Create the tween
	var tween = _new_tween(node)

	# Save the new tween and the original scale
	_squash_tweens[node] = { "tween": tween, "original": original }

	# Stretch to original * stretch_vec
	tween.tween_property(node, "scale", original * stretch_vec, dur)
	# Return to the exact original scale
	tween.tween_property(node, "scale", original, dur)

	# Cleanup after the tween finishes
	tween.finished.connect(func():
		if _squash_tweens.get(node, {}).get("tween") == tween:
			_squash_tweens.erase(node)
	)

	return tween

# Repeatedly squashes and stretches the node. Great for idle animations.
# The node always returns to the *original* scale it had when the first call was made,
# even if you spam the function.
func wobble(node: Node2D, factor: float = 1.2, dur: float = 0.2, times: int = 3) -> Tween:
	if not _is_valid(node):
		return null

	# Kill any previous wobble tween on this node
	if _wobble_tweens.has(node) and is_instance_valid(_wobble_tweens[node].get("tween")):
		_wobble_tweens[node]["tween"].kill()

	# Determine the original scale we must always return to
	var entry = _wobble_tweens.get(node, {})
	var original: Vector2 = entry.get("original", node.scale)

	# First call: save the current scale as the official original
	if not _wobble_tweens.has(node):
		original = node.scale

	# Build the two alternating stretch states
	var stretch_a = original * Vector2(factor, 1.0 / factor)
	var stretch_b = original * Vector2(1.0 / factor, factor)

	# Create the tween
	var tween = _new_tween(node)

	# Save the new tween and the original scale
	_wobble_tweens[node] = { "tween": tween, "original": original }

	# Animate: alternate between stretch_a and stretch_b for 'times' cycles
	for i in range(times):
		tween.tween_property(node, "scale", stretch_a, dur)
		tween.tween_property(node, "scale", stretch_b, dur)

	# Always return to the exact original scale
	tween.tween_property(node, "scale", original, dur)

	# Cleanup after the tween finishes
	tween.finished.connect(func():
		if _wobble_tweens.get(node, {}).get("tween") == tween:
			_wobble_tweens.erase(node)
	)

	return tween

# =============================================================================
#  MOVEMENT / ROTATION
# =============================================================================

# Moves the node to a target position over `dur` seconds.
func move_to(node: Node2D, target: Vector2, dur: float = 0.4) -> PropertyTweener:
	if not _is_valid(node):
		return null
	return _new_tween(node).tween_property(node, "position", target, dur)


# Rotates the node by `degrees` relative to its current rotation.
# - degrees: how many degrees to add to the current rotation each cycle.
# - dur: duration of one full rotation cycle in seconds.
# - loops: 0 = default (single rotation, no loop).
#          positive N = repeat N times.
#          -1 = infinite loop.
#
# If called again while a previous rotate is active, the old one is killed
# and the new one starts from the *current* rotation (no jump).
func rotate_by(node: Node2D, degrees: float = 360.0, dur: float = 1.0, loops: int = 0) -> Tween:
	if not _is_valid(node):
		return null

	# Kill any previous rotate tween on this node
	if _rotate_tweens.has(node) and is_instance_valid(_rotate_tweens[node]):
		_rotate_tweens[node].kill()

	# Current rotation is our starting point
	var start_rot: float = node.rotation_degrees
	var target_rot: float = start_rot + degrees

	var tween: Tween = _new_tween(node)
	_rotate_tweens[node] = tween

	# Single step: animate from current rotation to start_rot + degrees
	tween.tween_property(node, "rotation_degrees", target_rot, dur)

	if loops == -1:
		# Infinite loop
		tween.set_loops(0)   # 0 means infinite in Godot
	elif loops > 1:
		# Repeat the tween 'loops' times
		# (set_loops counts total executions, so 1 is already the first one)
		tween.set_loops(loops)

	# Cleanup after the tween finishes (only if not infinite)
	if loops != -1:
		tween.finished.connect(func():
			if _rotate_tweens.get(node) == tween:
				_rotate_tweens.erase(node)
		)
	else:
		# For infinite loops, we still want to clean up when the node is freed or a new call arrives.
		# We can't easily hook into "a new call killed this tween", but the new call already calls kill(),
		# and on kill the Tween stops. The entry will be overwritten by the new call anyway.
		# Just remove the entry when the node exits the tree (optional safety).
		if _is_valid(node):
			node.tree_exiting.connect(func():
				_rotate_tweens.erase(node)
			, CONNECT_ONE_SHOT)

	return tween
	
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

# Oscillates the node up and down (or left/right).
# - amplitude: pixels to move from origin.
# - speed: full cycles per second.
# - axis: "x" or "y".
# - infinite: true = loop forever, false = run for 'cycles' repetitions.
# - cycles: number of full back-and-forth cycles (only used when infinite=false).
func float_loop(node: Node2D, amplitude: float = 10.0, speed: float = 1.0, axis: String = "y", infinite: bool = true, cycles: int = 1) -> void:
	if not _is_valid(node):
		return

	# Kill any previous float tween on this node
	if _float_tweens.has(node) and is_instance_valid(_float_tweens[node]):
		_float_tweens[node].kill()

	var period = 1.0 / speed
	var origin = node.position

	if infinite:
		_float_loop_internal(node, origin, amplitude, period, axis, -1)   # -1 = infinite
	else:
		_float_loop_internal(node, origin, amplitude, period, axis, cycles)


func _float_loop_internal(node: Node2D, origin: Vector2, amplitude: float, period: float, axis: String, remaining: int) -> void:
	if not _is_valid(node):
		_float_tweens.erase(node)
		return

	if remaining == 0:
		# Finished all cycles – return to origin
		var t_final = _new_tween(node)
		t_final.tween_property(node, "position", origin, period * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_float_tweens[node] = t_final
		t_final.finished.connect(func(): _float_tweens.erase(node))
		return

	if remaining > 0:
		remaining -= 1

	var target = origin + (Vector2.DOWN if axis == "y" else Vector2.RIGHT) * amplitude
	var t = _new_tween(node)
	_float_tweens[node] = t
	t.tween_property(node, "position", target, period * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "position", origin, period * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	t.finished.connect(func(): _float_loop_internal(node, origin, amplitude, period, axis, remaining), CONNECT_ONE_SHOT)
	

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
# - infinite: true = spin forever, false = spin for 'cycles' full 360° rotations.
# - cycles: number of full rotations (only used when infinite=false).
# Calling this again while spinning will restart with the new settings.
func spin(node: Node2D, speed: float = 180.0, infinite: bool = true, cycles: int = 1) -> void:
	if not _is_valid(node):
		return

	# Signal the old spin loop to stop (if any)
	_spin_active[node] = false

	if not infinite and cycles <= 0:
		return

	var my_id = rng.randi()   # unique ID for this spin session
	_spin_active[node] = my_id

	var total_degrees = 0.0
	var target_degrees = cycles * 360.0 if not infinite else INF

	while _is_valid(node) and _spin_active.get(node) == my_id:
		var delta = speed * get_process_delta_time()
		node.rotation_degrees += delta
		total_degrees += abs(delta)

		if not infinite and total_degrees >= target_degrees:
			break

		await get_tree().process_frame

	# Cleanup
	if _spin_active.get(node) == my_id:
		_spin_active.erase(node)


# Swings the node left and right around its origin rotation. Good for pendulums or hanging objects.
# - degrees: max swing angle from origin.
# - dur: duration of one full swing (left to right and back).
# - infinite: true = swing forever, false = swing for 'cycles' full swings.
# - cycles: number of full back-and-forth swings (only used when infinite=false).
func swing(node: Node2D, degrees: float = 15.0, dur: float = 0.5, infinite: bool = true, cycles: int = 1) -> void:
	if not _is_valid(node):
		return

	# Kill any previous swing tween on this node
	if _swing_tweens.has(node) and is_instance_valid(_swing_tweens[node]):
		_swing_tweens[node].kill()

	var origin = node.rotation_degrees

	if infinite:
		_swing_internal(node, origin, degrees, dur, -1)
	else:
		_swing_internal(node, origin, degrees, dur, cycles)


func _swing_internal(node: Node2D, origin: float, degrees: float, dur: float, remaining: int) -> void:
	if not _is_valid(node):
		_swing_tweens.erase(node)
		return

	if remaining == 0:
		# Finished – return to origin rotation
		var t_final = _new_tween(node)
		t_final.tween_property(node, "rotation_degrees", origin, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_swing_tweens[node] = t_final
		t_final.finished.connect(func(): _swing_tweens.erase(node))
		return

	if remaining > 0:
		remaining -= 1

	var t = _new_tween(node)
	_swing_tweens[node] = t
	t.tween_property(node, "rotation_degrees", origin + degrees, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "rotation_degrees", origin - degrees, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	t.finished.connect(func(): _swing_internal(node, origin, degrees, dur, remaining), CONNECT_ONE_SHOT)


# Pulses the node scale in sync with a BPM. Great for music-driven UI or rhythm games.
func beat_pulse(node: Node2D, bpm: float = 120.0, factor: float = 1.2, repeats: int = 0) -> void:
	if not _is_valid(node):
		return

	# Generate a new ID for this call
	_beat_next_id += 1
	var my_id = _beat_next_id
	_beat_call_ids[node] = my_id

	var interval = 60.0 / bpm
	var count = 0
	var max_repeats = repeats   # 0 = loop

	# The loop continues only if:
	# - the node is valid
	# - the ID of this call is still active
	# - the number of iterations has not been reached
	while _is_valid(node) and _beat_call_ids.get(node) == my_id and (max_repeats == 0 or count < max_repeats):
		pop_scale(node, factor, interval * 0.1)
		await get_tree().create_timer(interval).timeout
		count += 1

	# Cleanup: Remove the ID only if it still belongs to us
	if _beat_call_ids.get(node) == my_id:
		_beat_call_ids.erase(node)


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
	if not old_scene:
		push_error("scene_slide_change: no current scene to slide out")
		return

	# Load the new scene resource
	var new_scene_resource = load(scene_path)
	if not new_scene_resource:
		push_error("scene_slide_change: could not load scene at path: " + scene_path)
		return

	# Convert viewport_size (Vector2i) to Vector2 for float multiplication
	var viewport_size: Vector2 = Vector2(tree.root.size)

	var new_scene = new_scene_resource.instantiate()
	tree.root.add_child(new_scene)
	new_scene.position = -dir.normalized() * viewport_size

	var t = new_scene.create_tween().set_parallel(true)
	t.tween_property(new_scene, "position", Vector2.ZERO, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(old_scene, "position", dir.normalized() * viewport_size, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	await t.finished
	old_scene.queue_free()
	tree.current_scene = new_scene
	

# Zooms the current scene out, changes scene, then zooms the new scene in.
# - zoom_target: how far to zoom out (0.0 = fully shrunk, 1.0 = normal).
func scene_zoom_change(tree: SceneTree, scene_path: String, zoom_target: float = 0.0, dur: float = 0.4) -> void:
	if _transition_active:
		return
	_transition_active = true

	var old_scene = tree.current_scene
	if not old_scene:
		tree.change_scene_to_file(scene_path)
		_transition_active = false
		return

	# Zoom out the old scene
	var t1 = old_scene.create_tween()
	t1.tween_property(old_scene, "scale", Vector2.ONE * zoom_target, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await t1.finished

	# Change scene
	tree.change_scene_to_file(scene_path)
	await tree.process_frame

	var new_scene = tree.current_scene
	if new_scene:
		new_scene.scale = Vector2.ONE * zoom_target
		var t2 = new_scene.create_tween()
		t2.tween_property(new_scene, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await t2.finished

	_transition_active = false
	
# Glitch transition: rapid position jitter + color flashes on the old scene,
# then cuts to the new scene with a settling animation.
func scene_glitch_change(tree: SceneTree, scene_path: String, intensity: float = 20.0, dur: float = 0.3) -> void:
	if _transition_active:
		return
	_transition_active = true

	# Flash a white overlay briefly
	var canvas = CanvasLayer.new()
	var rect = ColorRect.new()
	rect.color = Color.WHITE
	rect.size = tree.root.size
	rect.modulate.a = 0.0
	canvas.add_child(rect)
	tree.root.add_child(canvas)

	var old_scene = tree.current_scene
	var origin = old_scene.position if old_scene else Vector2.ZERO

	# Glitch the old scene (position jitter + white flash)
	var steps = int(dur / 0.02)
	for i in range(steps):
		if not _is_valid(old_scene):
			break

		# Random position jitter
		if i % 2 == 0:
			old_scene.position = origin + Vector2(
				rng.randf_range(-intensity, intensity),
				rng.randf_range(-intensity, intensity)
			)

		# Flicker white overlay
		rect.modulate.a = rng.randf_range(0.0, 0.8)

		await tree.create_timer(0.02).timeout

	# Restore position
	if _is_valid(old_scene):
		old_scene.position = origin

	# Flash to white
	var t_flash = rect.create_tween()
	t_flash.tween_property(rect, "modulate:a", 1.0, 0.05)
	await t_flash.finished

	# Change scene
	tree.change_scene_to_file(scene_path)
	await tree.process_frame

	# Fade out the white overlay on the new scene
	var t2 = rect.create_tween()
	t2.tween_property(rect, "modulate:a", 0.0, dur * 0.5)
	await t2.finished

	canvas.queue_free()
	_transition_active = false

# Pixel dissolve transition: the old scene dissolves into blocks that fade away,
# then the new scene assembles from blocks.
# - block_size: size of each dissolving block in pixels.
func scene_pixel_dissolve(tree: SceneTree, scene_path: String, block_size: int = 16, dur: float = 0.5) -> void:
	if _transition_active:
		return
	_transition_active = true

	var viewport_size = tree.root.size
	var cols = ceil(viewport_size.x / block_size)
	var rows = ceil(viewport_size.y / block_size)
	var total_blocks = int(cols * rows)
	var block_order = range(total_blocks)
	block_order.shuffle()

	var canvas = CanvasLayer.new()
	tree.root.add_child(canvas)

	var blocks: Array[ColorRect] = []

	# Create blocks covering the screen
	for i in total_blocks:
		var block = ColorRect.new()
		block.color = Color.BLACK
		block.size = Vector2(block_size, block_size)
		var x = (i % cols) * block_size
		var y = int(i / cols) * block_size
		block.position = Vector2(x, y)
		block.modulate.a = 0.0
		canvas.add_child(block)
		blocks.append(block)

	# Dissolve in (blocks appear in random order)
	var delay_per_block = dur / total_blocks
	for idx in block_order:
		if not _is_valid(canvas):
			break
		blocks[idx].modulate.a = 1.0
		await tree.create_timer(delay_per_block).timeout

	# Change scene
	tree.change_scene_to_file(scene_path)
	await tree.process_frame

	# Dissolve out (blocks disappear in random order)
	block_order.shuffle()
	for idx in block_order:
		if not _is_valid(canvas):
			break
		blocks[idx].modulate.a = 0.0
		await tree.create_timer(delay_per_block * 0.5).timeout

	canvas.queue_free()
	_transition_active = false

# Crossfade transition: old scene fades out while new scene fades in simultaneously.
# Requires both scenes to be in the tree temporarily (uses a CanvasLayer overlay).
func scene_crossfade(tree: SceneTree, scene_path: String, dur: float = 0.4) -> void:
	if _transition_active:
		return
	_transition_active = true

	# Cover with black overlay
	var canvas = CanvasLayer.new()
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.size = tree.root.size
	rect.modulate.a = 0.0
	canvas.add_child(rect)
	tree.root.add_child(canvas)

	# Fade to black
	var t1 = rect.create_tween()
	t1.tween_property(rect, "modulate:a", 1.0, dur * 0.5)
	await t1.finished

	# Change scene
	tree.change_scene_to_file(scene_path)
	await tree.process_frame

	# Fade from black
	var t2 = rect.create_tween()
	t2.tween_property(rect, "modulate:a", 0.0, dur * 0.5)
	await t2.finished

	canvas.queue_free()
	_transition_active = false

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
# Anti-spam protected: calling again instantly restores original color then starts new flash.
func lineedit_attention(line: LineEdit, color: Color = Color.RED, dur: float = 0.15) -> Tween:
	if not _is_valid(line):
		return null

	# Store the original modulate if we don't have it yet
	if not _lineedit_original_colors.has(line):
		_lineedit_original_colors[line] = line.modulate

	var original = _lineedit_original_colors[line]

	# Kill previous tween AND instantly restore original color
	if _lineedit_flash_tweens.has(line) and is_instance_valid(_lineedit_flash_tweens[line]):
		_lineedit_flash_tweens[line].kill()
		line.modulate = original   # 🔥 Forza subito il ritorno al colore originale

	var t = _new_tween(line)
	if not t:
		return null

	_lineedit_flash_tweens[line] = t

	t.tween_property(line, "modulate", color, dur * 0.5)
	t.tween_property(line, "modulate", original, dur * 0.5)

	t.finished.connect(func():
		if _lineedit_flash_tweens.get(line) == t:
			_lineedit_flash_tweens.erase(line)
			if _is_valid(line):
				line.modulate = original
	)

	return t


# Softer color pop. Use for positive feedback (e.g. autocomplete accepted).
func lineedit_pop(line: LineEdit, color: Color = Color.YELLOW, dur: float = 0.2) -> Tween:
	return lineedit_attention(line, color, dur)


# Alias for lineedit_attention. Kept for API clarity when slot is "error" context.
func lineedit_error_feedback(line: LineEdit, color: Color = Color.RED, dur: float = 0.2) -> Tween:
	return lineedit_attention(line, color, dur)

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
# Returns the Tween for awaiting.
func wipe_vertical(node: Control, open: bool = true, duration: float = 0.3) -> Tween:
	if not _is_valid(node):
		return null

	node.clip_contents = true
	var full_size = node.size
	var tween = _new_tween(node)
	if not tween:
		return null

	if open:
		if node.has_method("show"):
			node.show()
		node.modulate.a = 1.0
		node.size = Vector2(full_size.x, 0)
		tween.tween_property(node, "size", full_size, duration)
	else:
		tween.tween_property(node, "size", Vector2(full_size.x, 0), duration)
		tween.finished.connect(func():
			if _is_valid(node) and node.has_method("hide"):
				node.hide()
		, CONNECT_ONE_SHOT)

	return tween

# =============================================================================
#  UI - RADIAL / CHAIN UTILITIES
# =============================================================================

# Animates an array of buttons outward in a radial pattern from a custom origin.
# - buttons: array of nodes to animate.
# - radius: distance from origin when open.
# - duration: animation duration per button.
# - open: true = expand outward, false = collapse to origin.
# - origin: center point of the radial menu (default: Vector2.ZERO).
# - stagger: delay between each button (default: 0.04).
func radial_menu_open(buttons: Array, radius: float = 100.0, duration: float = 0.3, open: bool = true, origin: Vector2 = Vector2.ZERO, stagger: float = 0.04) -> void:
	for i in range(buttons.size()):
		var btn = buttons[i]
		if not _is_valid(btn):
			continue
		var angle = (i * TAU) / buttons.size()
		var target = origin + Vector2(cos(angle), sin(angle)) * radius if open else origin
		_new_tween(btn).tween_property(btn, "position", target, duration).set_delay(i * stagger).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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

# =============================================================================
#  UI - INPUT TYPEWRITER
# =============================================================================

# Types out text character by character into a LineEdit, like a typewriter effect.
# - clear_first: if true, clears the field before typing (default).
#                if false, appends to existing text.
func lineedit_typewrite(line: LineEdit, text: String, delay: float = 0.05, clear_first: bool = true) -> void:
	if not _is_valid(line):
		return
	
	if clear_first:
		line.text = ""
	
	for i in range(text.length()):
		if not _is_valid(line):
			return
		line.text += text[i]
		# Move cursor to the end while typing
		line.caret_column = line.text.length()
		await get_tree().create_timer(delay).timeout


# Types out text character by character into the placeholder text of a LineEdit.
# - clear_first: if true, clears the placeholder before typing (default).
func lineedit_typewrite_placeholder(line: LineEdit, text: String, delay: float = 0.05, clear_first: bool = true) -> void:
	if not _is_valid(line):
		return
	
	if clear_first:
		line.placeholder_text = ""
	
	for i in range(text.length()):
		if not _is_valid(line):
			return
		line.placeholder_text += text[i]
		await get_tree().create_timer(delay).timeout

# Horizontal position shake for labels. Good for "wrong answer" or damage feedback.
# - intensity: max horizontal displacement in pixels.
# - duration: length of one full shake burst (only used when infinite=false).
# - infinite: true = shake forever, false = single burst.
func text_shake(label: Label, intensity: float = 2.0, duration: float = 0.2, infinite: bool = false) -> Tween:
	if not _is_valid(label):
		return null

	# Kill any previous text_shake tween on this label
	if _text_shake_tweens.has(label) and is_instance_valid(_text_shake_tweens[label]):
		_text_shake_tweens[label].kill()

	var origin = label.position
	var t = _new_tween(label)
	_text_shake_tweens[label] = t

	if infinite:
		# Infinite shake: keep adding random horizontal jitters forever
		# Use a signal loop rather than set_loops because we need random positions each cycle
		_shake_step(label, origin, intensity, duration / 4.0, -1, t)
	else:
		# Single burst: 4 random steps + return to origin
		var steps = 4
		for i in range(steps):
			t.tween_property(label, "position", origin + Vector2(rng.randf_range(-intensity, intensity), 0), duration / steps)
		t.tween_property(label, "position", origin, duration / steps)
		t.finished.connect(func():
			if _text_shake_tweens.get(label) == t:
				_text_shake_tweens.erase(label)
		)

	return t


# Helper: performs one shake step. If remaining != 0, schedules the next step.
func _shake_step(label: Label, origin: Vector2, intensity: float, step_dur: float, remaining: int, master_tween: Tween) -> void:
	if not _is_valid(label):
		_text_shake_tweens.erase(label)
		return

	# Check if this specific shake session is still the active one
	if _text_shake_tweens.get(label) != master_tween:
		return

	if remaining == 0:
		# Finished – return to origin and clean up
		var t_final = _new_tween(label)
		_text_shake_tweens[label] = t_final
		t_final.tween_property(label, "position", origin, step_dur)
		t_final.finished.connect(func():
			if _text_shake_tweens.get(label) == t_final:
				_text_shake_tweens.erase(label)
		)
		return

	var target = origin + Vector2(rng.randf_range(-intensity, intensity), 0)
	var t_step = _new_tween(label)
	t_step.tween_property(label, "position", target, step_dur)

	var next_remaining = remaining - 1 if remaining > 0 else -1   # -1 stays -1 (infinite)

	t_step.finished.connect(func():
		_shake_step(label, origin, intensity, step_dur, next_remaining, master_tween)
	, CONNECT_ONE_SHOT)

# Cycles the label through rainbow colors.
# - speed: how fast the hue shifts (higher = faster).
# - saturation: color saturation (0.0 to 1.0).
# - value: color brightness (0.0 to 1.0).
# - infinite: true = rainbow forever, false = run for 'cycles' full hue rotations.
# - cycles: number of full hue cycles (only used when infinite=false).
func label_rainbow(label: Label, speed: float = 1.0, saturation: float = 0.8, value: float = 0.9, infinite: bool = true, cycles: int = 1) -> void:
	if not _is_valid(label):
		return

	# Stop any previous rainbow on this label
	_label_rainbow_active[label] = false

	var my_id = rng.randi()
	_label_rainbow_active[label] = my_id

	var hue = 0.0
	var total_hue_shift = 0.0
	var target_hue_shift = cycles * 1.0 if not infinite else INF

	while _is_valid(label) and _label_rainbow_active.get(label) == my_id:
		hue += speed * get_process_delta_time()
		total_hue_shift += speed * get_process_delta_time()

		if not infinite and total_hue_shift >= target_hue_shift:
			# Return to white (or original)
			label.modulate = Color.WHITE
			break

		label.modulate = Color.from_hsv(fmod(hue, 1.0), saturation, value)
		await get_tree().process_frame

	# Cleanup
	if _label_rainbow_active.get(label) == my_id:
		_label_rainbow_active.erase(label)

# Pulses the label's modulate color through a gradient sequence.
# - gradient_type: "warm", "cool", "fire", "aurora", "sunset", "ocean".
# - dur: duration of one full color cycle.
# - infinite: true = pulse forever, false = stop after 'cycles' cycles.
# - cycles: number of cycles (only used when infinite=false).
func label_gradient_pulse(label: Label, gradient_type: String = "warm", dur: float = 1.0, infinite: bool = true, cycles: int = 1) -> Tween:
	if not _is_valid(label):
		push_warning("label_gradient_pulse: invalid node")
		return null

	# Kill previous
	if _label_gradient_tweens.has(label) and is_instance_valid(_label_gradient_tweens[label]):
		_label_gradient_tweens[label].kill()

	# Define gradient color arrays
	var gradients = {
		"warm":   [Color.RED, Color.ORANGE, Color.YELLOW, Color.ORANGE],
		"cool":   [Color.CYAN, Color.BLUE, Color.PURPLE, Color.BLUE],
		"fire":   [Color.YELLOW, Color.ORANGE, Color.RED, Color.ORANGE],
		"aurora": [Color.GREEN, Color.CYAN, Color.PURPLE, Color.CYAN],
		"sunset": [Color.ORANGE, Color.DEEP_PINK, Color.PURPLE, Color.DEEP_PINK],
		"ocean":  [Color.AQUA, Color.TEAL, Color.NAVY_BLUE, Color.TEAL],
	}

	var colors = gradients.get(gradient_type, gradients["warm"])
	
	# Guard against empty color array
	if colors.is_empty():
		push_error("label_gradient_pulse: no colors found for gradient_type: " + gradient_type)
		return null

	var step_dur = dur / float(colors.size())
	var tween = _new_tween(label)   # ✅ FIX: "node" → "label"
	if not tween:
		push_error("label_gradient_pulse: could not create tween")
		return null

	_label_gradient_tweens[label] = tween

	# Build the color sequence
	for color in colors:
		tween.tween_property(label, "modulate", color, step_dur)

	# Restore original at the end
	var original = label.modulate
	tween.tween_property(label, "modulate", original, step_dur)

	if infinite:
		tween.set_loops(0)
	else:
		tween.set_loops(cycles)
		tween.finished.connect(func():
			if _label_gradient_tweens.get(label) == tween:
				_label_gradient_tweens.erase(label)
				if _is_valid(label):
					label.modulate = original
		)

	return tween

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

# Dictionary to track active trail loops per node (anti-spam).
static var _trail_active := {}

# Leaves fading ghost copies of the node at regular intervals to create a motion trail.
# The node must have a parent. Trail clones are duplicated and fade automatically.
# - length: number of trail clones to create. 0 = infinite (runs until node is freed or a new trail is started).
# - interval: seconds between each clone spawn.
# - fade_duration: how long each clone takes to fade out and self-destruct.
func trail(node: Node2D, length: int = 5, interval: float = 0.1, fade_duration: float = 0.3) -> void:
	if not _is_valid(node):
		return

	var parent = node.get_parent()
	if not parent:
		return

	# Signal any previous trail on this node to stop
	_trail_active[node] = false

	var my_id = rng.randi()
	_trail_active[node] = my_id

	var count = 0

	while _is_valid(node) and _trail_active.get(node) == my_id:
		# If length > 0 and we've spawned enough clones, stop
		if length > 0 and count >= length:
			break

		await get_tree().create_timer(interval).timeout

		# Check again after the await (node might have been freed or trail stopped)
		if not _is_valid(node) or _trail_active.get(node) != my_id:
			break

		var clone = node.duplicate()
		clone.modulate.a = 0.7
		parent.add_child(clone)

		# Fade out and free the clone
		var t = _new_tween(clone)
		t.tween_property(clone, "modulate:a", 0.0, fade_duration)
		t.finished.connect(func():
			if _is_valid(clone):
				clone.queue_free()
		)

		count += 1

	# Cleanup
	if _trail_active.get(node) == my_id:
		_trail_active.erase(node)

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



# =============================================================================
#  EXIT TWEENS (fade / slide / spin / pop out → free)
# =============================================================================

# Fades out the node and then frees it.
func exit_fade_and_free(node: CanvasItem, dur: float = 0.3) -> Tween:
	if not _is_valid(node):
		return null
	var tween = _new_tween(node)
	tween.tween_property(node, "modulate:a", 0.0, dur)
	tween.finished.connect(func(): 
		if _is_valid(node): node.queue_free()
	)
	return tween

# Slides the node off-screen in a given direction and then frees it.
func exit_slide_and_free(node: Node2D, direction: Vector2, distance: float = 300.0, dur: float = 0.4) -> Tween:
	if not _is_valid(node):
		return null
	var target = node.position + direction.normalized() * distance
	var tween = _new_tween(node)
	tween.tween_property(node, "position", target, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, dur)
	tween.finished.connect(func(): 
		if _is_valid(node): node.queue_free()
	)
	return tween

# Spins the node while shrinking and fading it, then frees it. Spectacular exit.
func exit_spin_and_free(node: Node2D, rotations: float = 2.0, dur: float = 0.4) -> Tween:
	if not _is_valid(node):
		return null
	var tween = _new_tween(node)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + rotations * 360.0, dur)
	tween.parallel().tween_property(node, "scale", Vector2.ZERO, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, dur)
	tween.finished.connect(func(): 
		if _is_valid(node): node.queue_free()
	)
	return tween

# Pops the node (quick scale up then implode) and frees it. Bubble-burst effect.
func exit_pop_and_free(node: Node2D, dur: float = 0.3) -> Tween:
	if not _is_valid(node):
		return null
	var original_scale = node.scale
	var tween = _new_tween(node)
	tween.tween_property(node, "scale", original_scale * 1.2, dur * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ZERO, dur * 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, dur)
	tween.finished.connect(func(): 
		if _is_valid(node): node.queue_free()
	)
	return tween

# =============================================================================
#  EPIC / DYNAMIC TWEENS
# =============================================================================

# Ground-slam effect: node flies to target with bounce and then shakes.
# Optionally shakes the camera as well.
func epic_ground_slam(node: Node2D, target_position: Vector2, dur: float = 0.5, shake_intensity: float = 10.0, camera: Camera2D = null) -> Tween:
	if not _is_valid(node):
		return null
	var tween = _new_tween(node)
	tween.tween_property(node, "position", target_position, dur).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		shake(node, shake_intensity, 0.2)
		if camera:
			camera_shake(camera, shake_intensity * 0.5, 0.2)
	)
	return tween

# Energy charge: node inflates and glows, then returns to normal.
# Great for power-ups or epic moments.
func epic_energy_charge(node: CanvasItem, scale_factor: float = 1.3, glow_color: Color = Color.YELLOW, dur: float = 0.6) -> Tween:
	if not _is_valid(node):
		return null
	var original_scale = node.scale if node is Node2D else Vector2.ONE
	var original_modulate = node.modulate
	var tween = _new_tween(node)
	tween.parallel().tween_property(node, "scale", original_scale * scale_factor, dur * 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", glow_color, dur * 0.5)
	tween.tween_property(node, "scale", original_scale, dur * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate", original_modulate, dur * 0.5)
	return tween

# Dynamic burst entry: node arrives from a direction with overshoot and a color flash.
# Perfect for UI or enemy spawn with impact.
func dynamic_burst_entry(node: Node2D, from_direction: Vector2, distance: float = 300.0, dur: float = 0.4, burst_color: Color = Color.WHITE) -> Tween:
	if not _is_valid(node):
		return null
	var destination = node.position
	node.position = destination + from_direction.normalized() * distance
	node.modulate = burst_color
	var tween = _new_tween(node)
	tween.tween_property(node, "position", destination, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", Color.WHITE, dur)
	return tween
