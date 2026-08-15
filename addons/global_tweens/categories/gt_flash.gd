# =============================================================================
#  GlobalTweens — Category: flash
#  Screen and node flashes: white/red/green overlays, rings, afterimages,
#  lightning strobes. All self-cleaning (overlays free themselves).
# =============================================================================

class_name GT_Flash
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"screen_white": {
			"fn": screen_white, "node_type": "Node",
			"desc": "Full-screen white flash (photo flash / spawn impact).",
			"params": "dur:float",
			"defaults": {"dur": 0.3},
			"restore": false,
		},
		"screen_red": {
			"fn": screen_red, "node_type": "Node",
			"desc": "Full-screen red flash (player damage).",
			"params": "dur:float",
			"defaults": {"dur": 0.35},
			"restore": false,
		},
		"screen_green": {
			"fn": screen_green, "node_type": "Node",
			"desc": "Full-screen green flash (pickup / heal).",
			"params": "dur:float",
			"defaults": {"dur": 0.3},
			"restore": false,
		},
		"screen_fade_black": {
			"fn": screen_fade_black, "node_type": "Node",
			"desc": "Screen dips to black and back (faint / cutscene beat).",
			"params": "dur:float, hold:float",
			"defaults": {"dur": 0.3, "hold": 0.15},
			"restore": false,
		},
		"node_flash": {
			"fn": node_flash, "node_type": "CanvasItem",
			"desc": "Flash just the node (white) and return to its color.",
			"params": "color:Color, dur:float",
			"defaults": {"dur": 0.18},
			"restore": true,
		},
		"ring": {
			"fn": ring, "node_type": "Node2D",
			"desc": "Expanding ring shockwave at the node position.",
			"params": "size:float, dur:float, color:Color",
			"defaults": {"size": 30.0, "dur": 0.45},
			"restore": false,
		},
		"afterimage": {
			"fn": afterimage, "node_type": "Node2D",
			"desc": "Leaves one fading ghost copy of the node.",
			"params": "fade:float, alpha:float",
			"defaults": {"fade": 0.4, "alpha": 0.7},
			"restore": false,
		},
		"lightning": {
			"fn": lightning, "node_type": "Node",
			"desc": "Random lightning strobe on the whole screen.",
			"params": "count:int, dur:float",
			"defaults": {"count": 6, "dur": 0.6},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func _screen_overlay(o: Dictionary, color: Color) -> Tween:
	var root: Window = GT_Factory.tree().root
	var layer := CanvasLayer.new()
	layer.layer = 128
	root.add_child(layer)
	var rect := ColorRect.new()
	rect.color = color
	rect.size = root.size
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var tween := rect.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(rect, "modulate:a", 1.0, dur * 0.5)
	tween.tween_property(rect, "modulate:a", 0.0, dur * 0.5)
	tween.tween_callback(func():
		if is_instance_valid(layer):
			layer.queue_free()
	)
	return tween


static func screen_white(node, o: Dictionary) -> Tween:
	return _screen_overlay(o, Color.WHITE)


static func screen_red(node, o: Dictionary) -> Tween:
	return _screen_overlay(o, Color(0.85, 0.1, 0.1))


static func screen_green(node, o: Dictionary) -> Tween:
	return _screen_overlay(o, Color(0.2, 0.9, 0.3))


static func screen_fade_black(node, o: Dictionary) -> Tween:
	var root: Window = GT_Factory.tree().root
	var layer := CanvasLayer.new()
	layer.layer = 128
	root.add_child(layer)
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.size = root.size
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var hold: float = max(0.0, float(o.get("hold", 0.15)))
	var tween := rect.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(rect, "modulate:a", 1.0, dur)
	tween.tween_interval(hold)
	tween.tween_property(rect, "modulate:a", 0.0, dur)
	tween.tween_callback(func():
		if is_instance_valid(layer):
			layer.queue_free()
	)
	return tween


static func node_flash(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.18))
	var color: Color = o.get("color", Color.WHITE)
	var orig: Color = node.modulate
	tween.tween_property(node, "modulate", color, dur * 0.5)
	tween.tween_property(node, "modulate", orig, dur * 0.5)
	return tween


static func ring(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var size: float = float(o.get("size", 30.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var color: Color = o.get("color", Color.WHITE)
	var rect := GT_Factory.spawn_rect(parent, Vector2(size, size), color)
	rect.global_position = node.global_position
	rect.pivot_offset = rect.size * 0.5
	var tween := rect.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(rect, "scale", Vector2(2.6, 2.6), dur)
	tween.tween_property(rect, "modulate:a", 0.0, dur)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if is_instance_valid(rect):
			rect.queue_free()
	)
	return tween


static func afterimage(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var fade: float = max(0.05, float(o.get("fade", 0.4)))
	var alpha: float = clampf(float(o.get("alpha", 0.7)), 0.0, 1.0)
	var ghost: CanvasItem = node.duplicate()
	ghost.modulate = Color(1, 1, 1, alpha)
	if ghost is Node2D:
		ghost.z_index = (node as Node2D).z_index - 1
	parent.add_child(ghost)
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, fade)
	tween.tween_callback(func():
		if is_instance_valid(ghost):
			ghost.queue_free()
	)
	return tween


static func lightning(node, o: Dictionary) -> Tween:
	var root: Window = GT_Factory.tree().root
	var layer := CanvasLayer.new()
	layer.layer = 128
	root.add_child(layer)
	var rect := ColorRect.new()
	rect.color = Color.WHITE
	rect.size = root.size
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	var count: int = max(2, int(o.get("count", 6)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var rng := RandomNumberGenerator.new()
	var tween := rect.create_tween().set_trans(Tween.TRANS_LINEAR)
	var step_dur: float = dur / (count * 2)
	for i in range(count):
		tween.tween_property(rect, "modulate:a", 1.0, step_dur * rng.randf_range(0.3, 1.0))
		tween.tween_property(rect, "modulate:a", 0.0, step_dur * rng.randf_range(0.3, 1.0))
	tween.tween_property(rect, "modulate:a", 0.0, step_dur)
	tween.tween_callback(func():
		if is_instance_valid(layer):
			layer.queue_free()
	)
	return tween