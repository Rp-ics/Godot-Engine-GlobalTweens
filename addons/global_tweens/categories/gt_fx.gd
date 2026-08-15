# =============================================================================
#  GlobalTweens — Category: fx
#  Gameplay effects: ring waves, sparkles, dust, confetti, heal glow,
#  magic swirls, poison bubbles, electric jitter, vignette, XP orbs.
#  All spawned particles are self-freed.
# =============================================================================

class_name GT_FX
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"ring_wave": {
			"fn": ring_wave, "node_type": "Node2D",
			"desc": "Staggered expanding shockwave rings at the node position.",
			"params": "rings:int, size:float, dur:float, color:Color",
			"defaults": {"rings": 3, "size": 26.0, "dur": 0.6},
			"restore": false,
		},
		"sparkle": {
			"fn": sparkle, "node_type": "Node2D",
			"desc": "Twinkling sparkle particles around the node (grow + fade).",
			"params": "count:int, radius:float, dur:float",
			"defaults": {"count": 7, "radius": 36.0, "dur": 0.9},
			"restore": false,
		},
		"dust": {
			"fn": dust, "node_type": "Node2D",
			"desc": "Small puffs of dust spreading from the node (landing, footsteps).",
			"params": "count:int, dur:float",
			"defaults": {"count": 6, "dur": 0.7},
			"restore": false,
		},
		"confetti": {
			"fn": confetti, "node_type": "Node2D",
			"desc": "Colorful confetti burst raining from the node position.",
			"params": "count:int, spread:float, dur:float",
			"defaults": {"count": 24, "spread": 120.0, "dur": 1.4},
			"restore": false,
		},
		"heal_glow": {
			"fn": heal_glow, "node_type": "Node2D",
			"desc": "Green heal flash on the node plus an expanding soft glow.",
			"params": "dur:float",
			"defaults": {"dur": 0.8},
			"restore": true,
		},
		"magic_swirl": {
			"fn": magic_swirl, "node_type": "Node2D",
			"desc": "Orbs orbiting the node in a spinning circle, then fading out.",
			"params": "count:int, radius:float, dur:float, color:Color",
			"defaults": {"count": 6, "radius": 40.0, "dur": 1.2},
			"restore": false,
		},
		"poison_bubble": {
			"fn": poison_bubble, "node_type": "Node2D",
			"desc": "Green bubbles wobbling up from the node (poison pool / swamp).",
			"params": "count:int, dur:float",
			"defaults": {"count": 5, "dur": 1.4},
			"restore": false,
		},
		"electric": {
			"fn": electric, "node_type": "Node2D",
			"desc": "Electric jitter: rapid random position jumps with blue flashes.",
			"params": "steps:int, dur:float",
			"defaults": {"steps": 10, "dur": 0.4},
			"restore": true,
		},
		"vignette": {
			"fn": vignette, "node_type": "Node",
			"desc": "Screen darkens into a vignette, holds, then fades back.",
			"params": "alpha:float, dur:float, hold:float",
			"defaults": {"alpha": 0.45, "dur": 0.8, "hold": 0.3},
			"restore": false,
		},
		"xp_gain": {
			"fn": xp_gain, "node_type": "Node2D",
			"desc": "Orbs fly into the node from random directions + '+XP' popup.",
			"params": "count:int, dur:float",
			"defaults": {"count": 5, "dur": 0.9},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func ring_wave(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var rings: int = max(1, int(o.get("rings", 3)))
	var size: float = float(o.get("size", 26.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var color: Color = o.get("color", Color(0.5, 0.9, 1.0))
	var host: Tween = node.create_tween().set_parallel(true)
	host.tween_interval(dur)
	for i in range(rings):
		var rect := GT_Factory.spawn_rect(node, Vector2(size, size), color)
		rect.global_position = node.global_position
		rect.pivot_offset = rect.size * 0.5
		var t := rect.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_interval(i * dur * 0.25)
		t.set_parallel(true)
		t.tween_property(rect, "scale", Vector2(2.4, 2.4), dur)
		t.tween_property(rect, "modulate:a", 0.0, dur)
		t.finished.connect(rect.queue_free)
	host.set_parallel(false)
	host.tween_interval(0.01)
	return host


static func sparkle(node, o: Dictionary) -> Tween:
	var count: int = max(2, int(o.get("count", 7)))
	var radius: float = float(o.get("radius", 36.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var host: Tween = node.create_tween()
	host.tween_interval(dur)
	for i in range(count):
		var rect := GT_Factory.spawn_rect(node, Vector2(5, 5), Color(1.0, 1.0, 0.8))
		var dir := Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		rect.global_position = node.global_position + dir * randf_range(10.0, radius)
		var t := rect.create_tween()
		t.set_parallel(true)
		t.tween_property(rect, "scale", Vector2(1.7, 1.7), dur * 0.6)
		t.tween_property(rect, "modulate:a", 0.0, dur)
		t.finished.connect(rect.queue_free)
	return host


static func dust(node, o: Dictionary) -> Tween:
	var count: int = max(2, int(o.get("count", 6)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	for i in range(count):
		var rect := GT_Factory.spawn_rect(node, Vector2(8, 6), Color(0.75, 0.7, 0.65, 0.8))
		rect.global_position = node.global_position + Vector2(randf_range(-10.0, 10.0), randf_range(-4.0, 0.0))
		var t := rect.create_tween()
		var vel: Vector2 = Vector2(randf_range(-0.5, 0.5), randf_range(-0.2, 0.1)) * 40.0
		t.set_parallel(true)
		t.tween_property(rect, "global_position", rect.global_position + vel, dur)
		t.tween_property(rect, "modulate:a", 0.0, dur)
		t.finished.connect(rect.queue_free)
	var host: Tween = node.create_tween()
	host.tween_interval(dur)
	return host


static func confetti(node, o: Dictionary) -> Tween:
	var count: int = max(3, int(o.get("count", 24)))
	var spread: float = float(o.get("spread", 120.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.4))
	var palette: Array = [
		Color(1.0, 0.4, 0.5), Color(1.0, 0.8, 0.2),
		Color(0.3, 0.9, 0.6), Color(0.4, 0.6, 1.0),
	]
	for i in range(count):
		var rect := GT_Factory.spawn_rect(node, Vector2(7, 5), palette[i % palette.size()])
		var vel: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-0.4, -1.2)).normalized() * randf_range(60.0, spread)
		rect.rotation = randf_range(0.0, TAU)
		var t := rect.create_tween()
		t.set_parallel(true)
		t.tween_property(rect, "global_position", rect.global_position + vel, dur)
		t.tween_property(rect, "rotation", rect.rotation + randf_range(TAU, TAU * 3.0), dur)
		t.tween_property(rect, "modulate:a", 0.0, dur)
		t.finished.connect(rect.queue_free)
	var host: Tween = node.create_tween()
	host.tween_interval(dur)
	return host


static func heal_glow(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var orig: Color = node.modulate
	var glow := GT_Factory.spawn_rect(node, Vector2(60, 60), Color(0.4, 1.0, 0.5, 0.5))
	glow.global_position = node.global_position
	glow.pivot_offset = glow.size * 0.5
	var gt := glow.create_tween().set_parallel(true)
	gt.tween_property(glow, "scale", Vector2(2.2, 2.2), dur)
	gt.tween_property(glow, "modulate:a", 0.0, dur)
	gt.finished.connect(glow.queue_free)
	tween.tween_property(node, "modulate", Color(0.6, 1.0, 0.65), dur * 0.3)
	tween.tween_property(node, "modulate", orig, dur * 0.7)
	return tween


static func magic_swirl(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var orb_count: int = max(2, int(o.get("count", 6)))
	var radius: float = float(o.get("radius", 40.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var color: Color = o.get("color", Color(0.6, 0.8, 1.0))
	var holder := Node2D.new()
	parent.add_child(holder)
	holder.global_position = node.global_position
	for i in range(orb_count):
		var orb := GT_Factory.spawn_rect(holder, Vector2(8, 8), color)
		var angle: float = TAU * i / float(orb_count)
		orb.position = Vector2(cos(angle), sin(angle)) * radius
	var tween := holder.create_tween()
	tween.set_parallel(true)
	tween.tween_property(holder, "rotation", TAU, dur).set_trans(Tween.TRANS_LINEAR)
	for i in range(orb_count):
		tween.tween_property(holder.get_child(i), "modulate:a", 0.0, dur * 0.4).set_delay(dur * 0.6)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if is_instance_valid(holder):
			holder.queue_free()
	)
	return tween


static func poison_bubble(node, o: Dictionary) -> Tween:
	var count: int = max(2, int(o.get("count", 5)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.4))
	for i in range(count):
		var bubble := GT_Factory.spawn_rect(node, Vector2(7, 7), Color(0.35, 0.9, 0.35, 0.9))
		bubble.global_position = node.global_position + Vector2(randf_range(-12.0, 12.0), 0.0)
		var t := bubble.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(bubble, "global_position", bubble.global_position - Vector2.UP * randf_range(30.0, 60.0), dur * 0.8)
		t.tween_property(bubble, "global_position", bubble.global_position - Vector2.UP * randf_range(0.0, 6.0), dur * 0.2)
		t.tween_property(bubble, "modulate:a", 0.0, dur * 0.6)
		t.tween_callback(bubble.queue_free)
	var host: Tween = node.create_tween()
	host.tween_interval(dur)
	return host


static func electric(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var steps: int = max(4, int(o.get("steps", 10)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var orig_pos: Vector2 = node.position
	var orig_color: Color = node.modulate
	var step: float = dur / float(steps)
	var rng := RandomNumberGenerator.new()
	for i in range(steps):
		var jitter: Vector2 = orig_pos + Vector2(rng.randf_range(-8.0, 8.0), rng.randf_range(-8.0, 8.0))
		tween.tween_property(node, "position", jitter, step * 0.8)
		tween.tween_property(node, "modulate", Color(0.7, 0.85, 1.0) if i % 2 == 0 else orig_color, step * 0.8)
	tween.tween_property(node, "position", orig_pos, step)
	tween.tween_property(node, "modulate", orig_color, step)
	return tween


static func vignette(node, o: Dictionary) -> Tween:
	var root: Window = GT_Factory.tree().root
	var layer := CanvasLayer.new()
	layer.layer = 64
	root.add_child(layer)
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.size = root.size
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	var max_alpha: float = clampf(float(o.get("alpha", 0.45)), 0.0, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var hold: float = max(0.0, float(o.get("hold", 0.3)))
	var tween := rect.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(rect, "modulate:a", max_alpha, dur)
	tween.tween_interval(hold)
	tween.tween_property(rect, "modulate:a", 0.0, dur)
	tween.tween_callback(func():
		if is_instance_valid(layer):
			layer.queue_free()
	)
	return tween


static func xp_gain(node, o: Dictionary) -> Tween:
	var orb_count: int = max(2, int(o.get("count", 5)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var color: Color = Color(0.6, 1.0, 0.3)
	for i in range(orb_count):
		var orb := GT_Factory.spawn_rect(node, Vector2(9, 9), color)
		orb.global_position = node.global_position + Vector2(randf_range(-90.0, 90.0), randf_range(-60.0, -20.0))
		var t := orb.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		t.tween_property(orb, "global_position", node.global_position, dur)
		t.tween_property(orb, "scale", Vector2(0.4, 0.4), dur * 0.8).set_delay(dur * 0.2)
		t.tween_callback(orb.queue_free)
	GT_Text.pop(node, {"text": "+XP", "color": color, "dur": 0.8})
	var host: Tween = node.create_tween()
	host.tween_interval(dur)
	return host