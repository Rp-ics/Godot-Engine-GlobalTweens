# =============================================================================
#  GlobalTweens — GT_Factory
#  Shared tween construction with the unified options dictionary. Every
#  animation (catalog + classic helpers) goes through here so behaviour is
#  consistent and every parameter is validated before it reaches a Tween.
#
#  Unified opts keys (all optional):
#    dur       : float  — duration in seconds (sanitized: finite, > 0)
#    loops     : int    — -1 = infinite, 1 = once (default), N = N times
#    delay     : float  — seconds before the tween starts (>= 0)
#    trans     : int    — Tween.TRANS_* (validated 0..11)
#    ease      : int    — Tween.EASE_* (validated 0..3)
#    spam_mode : String — "kill_same" (default) | "kill_all" | "queue"
#    restore   : bool   — restore node snapshot on finish (default true)
#    keep_end_state : bool — keep the animation's end state (no restore)
# =============================================================================

class_name GT_Factory
extends RefCounted


static func tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


static func opt(opts: Dictionary, key: String, default_value: Variant = null) -> Variant:
	return opts.get(key, default_value)


## Converts the unified loops convention into Godot's Tween loops value.
## -1 -> 0 (infinite in Godot). 0/1 -> 1 (once). N -> N times.
static func norm_loops(loops: Variant) -> int:
	if loops is int:
		if loops == -1:
			return 0
		return max(1, loops)
	if loops is float:
		return norm_loops(int(loops))
	push_warning("GT_Factory: invalid 'loops' (%s), using 1 (once)." % str(loops))
	return 1


## Sanitized positive duration. Rejects NaN/INF/<= 0.
static func sanitize_dur(value: Variant, fallback: float = 0.3) -> float:
	if value is float or value is int:
		var f: float = float(value)
		if is_finite(f) and f > 0.0:
			return f
	push_warning("GT_Factory: invalid duration (%s), using %s." % [str(value), str(fallback)])
	return fallback


## Sanitized duration that may be 0 (used for delays).
static func sanitize_non_neg(value: Variant, fallback: float = 0.0) -> float:
	if value is float or value is int:
		var f: float = float(value)
		if is_finite(f) and f >= 0.0:
			return f
	return fallback


## Creates the base tween for a node applying trans/ease/delay/loops.
## Returns null when the node is invalid.
static func build(node: Node, opts: Dictionary) -> Tween:
	if node == null or not is_instance_valid(node):
		push_warning("GT_Factory.build: node is null or already freed.")
		return null
	var tween := node.create_tween()
	var trans: Variant = opt(opts, "trans", Tween.TRANS_SINE)
	var ease: Variant = opt(opts, "ease", Tween.EASE_IN_OUT)
	if trans is int and trans >= 0 and trans <= 11:
		tween.set_trans(trans)
	else:
		push_warning("GT_Factory.build: invalid 'trans' (%s), using TRANS_SINE." % str(trans))
	if ease is int and ease >= 0 and ease <= 3:
		tween.set_ease(ease)
	else:
		push_warning("GT_Factory.build: invalid 'ease' (%s), using EASE_IN_OUT." % str(ease))
	var delay: float = sanitize_non_neg(opt(opts, "delay", 0.0))
	if delay > 0.0:
		tween.set_delay(delay)
	var loops: int = norm_loops(opt(opts, "loops", 1))
	if loops == 0:
		tween.set_loops(0)
	elif loops > 1:
		tween.set_loops(loops)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tween


## Safe property tween: verifies the property exists on the node first.
static func tweenp(tween: Tween, node: Node, prop: String, to: Variant, dur: float) -> void:
	if prop in node:
		tween.tween_property(node, prop, to, dur)
	else:
		push_warning("GT_Factory.tweenp: node '%s' has no property '%s' — skipped." % [node.name, prop])


# ---------------------------------------------------------------------------
#  FX spawn helpers (used by many category animations)
# ---------------------------------------------------------------------------

## Spawns a small ColorRect under `parent` (mouse ignored, anchored to the
## node position later by the caller).
static func spawn_rect(parent: Node, size: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.size = size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


## Spawns a floating Label under `parent`.
static func spawn_label(parent: Node, text: String, color: Color, font_size: int = 16) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


## Connects a tween's finished signal to queue_free the object safely.
static func free_on_finished(tween: Tween, obj: Object) -> void:
	tween.finished.connect(func():
		if is_instance_valid(obj):
			obj.queue_free()
	)


## Centers the pivot of a Control so scale/rotation animations are centered.
static func center_pivot(node: Node) -> void:
	if node is Control and node.size != Vector2.ZERO:
		node.pivot_offset = node.size * 0.5
