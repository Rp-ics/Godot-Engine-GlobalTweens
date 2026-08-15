# =============================================================================
#  GlobalTweens — Category: buttons
#  UI button juice: hover, press, ripple, shiny sweep, focus, notifications.
#  Controls are scaled around their center (pivot is handled automatically).
# =============================================================================

class_name GT_Buttons
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"hover": {
			"fn": hover, "node_type": "Control",
			"desc": "Scale up on hover (stays scaled while hovered — pair with unhover).",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.08, "dur": 0.14},
			"restore": false,
		},
		"unhover": {
			"fn": unhover, "node_type": "Control",
			"desc": "Return to normal scale (mouse exit).",
			"params": "dur:float",
			"defaults": {"dur": 0.12},
			"restore": false,
		},
		"press": {
			"fn": press, "node_type": "Control",
			"desc": "Quick squish down and back on click.",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 0.9, "dur": 0.09},
			"restore": true,
		},
		"pop_in": {
			"fn": pop_in, "node_type": "Control",
			"desc": "Appear with an elastic pop from zero scale + fade in.",
			"params": "dur:float",
			"defaults": {"dur": 0.35},
			"restore": true,
		},
		"wiggle": {
			"fn": wiggle, "node_type": "Control",
			"desc": "Playful rotation wiggle (suggest: NEW / don't click me).",
			"params": "angle:float, dur:float",
			"defaults": {"angle": 5.0, "dur": 0.5},
			"restore": true,
		},
		"notify_bounce": {
			"fn": notify_bounce, "node_type": "Control",
			"desc": "Attention bounce: hops up with a golden flash (new feature badge).",
			"params": "height:float, dur:float",
			"defaults": {"height": 12.0, "dur": 0.5},
			"restore": true,
		},
		"click_zoom": {
			"fn": click_zoom, "node_type": "Control",
			"desc": "Satisfying click: quick zoom in, then spring back.",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.15, "dur": 0.25},
			"restore": true,
		},
		"focus_pulse": {
			"fn": focus_pulse, "node_type": "Control",
			"desc": "Keyboard focus highlight: yellow pulse (loop).",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 0.8, "loops": -1},
			"restore": true,
		},
		"ripple": {
			"fn": ripple, "node_type": "Control",
			"desc": "Material-style ripple: expanding ring from the button center.",
			"params": "size:float, dur:float",
			"defaults": {"size": 24.0, "dur": 0.45},
			"restore": false,
		},
		"shiny_sweep": {
			"fn": shiny_sweep, "node_type": "Control",
			"desc": "Shiny highlight sweeps across the button (purchase/loot feeling).",
			"params": "dur:float",
			"defaults": {"dur": 0.6},
			"restore": false,
		},
		"disable_fade": {
			"fn": disable_fade, "node_type": "Control",
			"desc": "Visually disable: fade to grey alpha and shrink (stays disabled).",
			"params": "dur:float",
			"defaults": {"dur": 0.2},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func _pivot(node) -> void:
	GT_Factory.center_pivot(node)


static func hover(node, o: Dictionary) -> Tween:
	_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.08)), 1.01, 2.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.14))
	tween.tween_property(node, "scale", node.scale * factor, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


static func unhover(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.12))
	tween.tween_property(node, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func press(node, o: Dictionary) -> Tween:
	_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 0.9)), 0.4, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.09))
	tween.tween_property(node, "scale", Vector2.ONE * factor, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", Vector2.ONE, dur * 1.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


static func pop_in(node, o: Dictionary) -> Tween:
	_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var orig_alpha: float = node.modulate.a
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.7)
	return tween


static func wiggle(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 5.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var orig: float = node.rotation_degrees
	for i in 3:
		var sign: float = 1.0 if i % 2 == 0 else -1.0
		tween.tween_property(node, "rotation_degrees", orig + angle * sign, dur * 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig, dur * 0.15).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func notify_bounce(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 12.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var origin: Vector2 = node.position
	var orig_color: Color = node.modulate
	tween.set_parallel(true)
	tween.tween_property(node, "position:y", origin.y - height, dur * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", origin.y, dur * 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", Color(1.0, 0.9, 0.4), dur * 0.2)
	tween.tween_property(node, "modulate", orig_color, dur * 0.5)
	return tween


static func click_zoom(node, o: Dictionary) -> Tween:
	_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.15)), 1.02, 2.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.25))
	tween.tween_property(node, "scale", Vector2.ONE * factor, dur * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, dur * 0.65).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func focus_pulse(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var orig_color: Color = node.modulate
	tween.tween_property(node, "modulate", Color(1.0, 0.9, 0.4), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", orig_color, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", Vector2.ONE * 1.03, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func ripple(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var size: float = float(o.get("size", 24.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var rect := GT_Factory.spawn_rect(parent, Vector2(size, size), Color(1, 1, 1, 0.5))
	rect.global_position = node.global_position + node.size * 0.5
	rect.pivot_offset = rect.size * 0.5
	var tween := rect.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(rect, "scale", Vector2(4.5, 4.5), dur)
	tween.tween_property(rect, "modulate:a", 0.0, dur)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if is_instance_valid(rect):
			rect.queue_free()
	)
	return tween


static func shiny_sweep(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var strip := GT_Factory.spawn_rect(parent, Vector2(34.0, node.size.y), Color(1, 1, 1, 0.55))
	strip.global_position = node.global_position - Vector2(60.0, 0.0)
	var tween := strip.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(strip, "position:x", node.global_position.x + node.size.x + 60.0, dur)
	tween.tween_property(strip, "modulate:a", 0.0, dur * 0.5).set_delay(dur * 0.5)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if is_instance_valid(strip):
			strip.queue_free()
	)
	return tween


static func disable_fade(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.2))
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", Color(0.6, 0.6, 0.6, 0.45), dur)
	tween.tween_property(node, "scale", Vector2.ONE * 0.96, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	return tween