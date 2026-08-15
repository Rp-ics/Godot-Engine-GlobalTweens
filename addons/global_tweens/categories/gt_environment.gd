# =============================================================================
#  GlobalTweens — Category: environment
#  Living worlds: wind, grass, water, clouds, leaves, torches, tornadoes...
# =============================================================================

class_name GT_Env
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"wind_sway": {
			"fn": wind_sway, "node_type": "Node2D",
			"desc": "Blowing wind: rotation sway with a slow rhythm (loop).",
			"params": "angle:float, dur:float, loops:int",
			"defaults": {"angle": 10.0, "dur": 1.6, "loops": -1},
			"restore": true,
		},
		"grass_sway": {
			"fn": grass_sway, "node_type": "Node2D",
			"desc": "Grass blade sway: rotation + slight x-scale squash (loop).",
			"params": "angle:float, dur:float, loops:int",
			"defaults": {"angle": 7.0, "dur": 0.9, "loops": -1},
			"restore": true,
		},
		"ripple": {
			"fn": ripple, "node_type": "Node2D",
			"desc": "Water ripple: expanding fading rings from the node position.",
			"params": "count:int, interval:float, size:float, dur:float",
			"defaults": {"count": 3, "interval": 0.4, "size": 16.0, "dur": 0.7},
			"restore": false,
		},
		"cloud_drift": {
			"fn": cloud_drift, "node_type": "Node2D",
			"desc": "Cloud drift: slow horizontal to-and-fro (loop).",
			"params": "dist:float, dur:float, loops:int",
			"defaults": {"dist": 40.0, "dur": 6.0, "loops": -1},
			"restore": true,
		},
		"leaf_fall": {
			"fn": leaf_fall, "node_type": "Node2D",
			"desc": "Falling leaf: descends while swaying side-to-side with rotation (loop).",
			"params": "dist:float, dur:float, sway:float, loops:int",
			"defaults": {"dist": 60.0, "dur": 2.2, "sway": 14.0, "loops": -1},
			"restore": true,
		},
		"torch": {
			"fn": torch, "node_type": "PointLight2D",
			"desc": "Torch/candle flicker: random energy flickers (loop).",
			"params": "min_energy:float, max_energy:float, dur:float, loops:int",
			"defaults": {"min_energy": 0.55, "max_energy": 1.0, "dur": 0.12, "loops": -1},
			"restore": true,
		},
		"tree_sway": {
			"fn": tree_sway, "node_type": "Node2D",
			"desc": "Big tree sway: slow, heavy rotation and a small x lean (loop).",
			"params": "angle:float, dur:float, loops:int",
			"defaults": {"angle": 4.0, "dur": 3.0, "loops": -1},
			"restore": true,
		},
		"flower_bob": {
			"fn": flower_bob, "node_type": "Node2D",
			"desc": "Flower breathing: gentle bob up/down with a tiny scale pulse (loop).",
			"params": "amp:float, dur:float, loops:int",
			"defaults": {"amp": 4.0, "dur": 1.4, "loops": -1},
			"restore": true,
		},
		"wave": {
			"fn": wave, "node_type": "Node2D",
			"desc": "Lava/water surface wave: horizontal sine translation (loop).",
			"params": "amp:float, dur:float, loops:int",
			"defaults": {"amp": 18.0, "dur": 1.2, "loops": -1},
			"restore": true,
		},
		"tornado": {
			"fn": tornado, "node_type": "Node2D",
			"desc": "Tornado spin: accelerating rotation with a wobbly x-lean (loop).",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 1.0, "loops": -1},
			"restore": true,
		},
		"meteor": {
			"fn": meteor, "node_type": "Node2D",
			"desc": "Meteor fall: streaks diagonally, stretches, fades, then frees itself.",
			"params": "dir:Vector2, dist:float, dur:float",
			"defaults": {"dir": Vector2(1, 1), "dist": 240.0, "dur": 0.9},
			"restore": false,
		},
		"vine_grow": {
			"fn": vine_grow, "node_type": "Node2D",
			"desc": "Vine/plant growing from the ground: scale y grows slowly, then sways.",
			"params": "dur:float",
			"defaults": {"dur": 1.2},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func wind_sway(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 10.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.6))
	var orig: float = node.rotation_degrees
	tween.tween_property(node, "rotation_degrees", orig + angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig - angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func grass_sway(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 7.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var orig: float = node.rotation_degrees
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "rotation_degrees", orig + angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 1.06, orig_scale.y * 0.96), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig - angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func ripple(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var count: int = max(1, int(o.get("count", 3)))
	var interval: float = max(0.05, float(o.get("interval", 0.4)))
	var size: float = float(o.get("size", 16.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	var host := parent.create_tween()
	for i in range(count):
		host.tween_interval(interval)
		host.tween_callback(func():
			if not is_instance_valid(node) or not is_instance_valid(parent):
				return
			var rect := GT_Factory.spawn_rect(parent, Vector2(size, size), Color(0.6, 0.9, 1.0, 0.5))
			rect.global_position = node.global_position
			rect.pivot_offset = rect.size * 0.5
			var t := rect.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.set_parallel(true)
			t.tween_property(rect, "scale", Vector2(3.0, 3.0), dur)
			t.tween_property(rect, "modulate:a", 0.0, dur)
			t.set_parallel(false)
			t.tween_callback(func():
				if is_instance_valid(rect):
					rect.queue_free()
			)
		)
	return host


static func cloud_drift(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 40.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 6.0))
	var origin: Vector2 = node.position
	tween.tween_property(node, "position", origin + Vector2.RIGHT * dist, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2.RIGHT * dist, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func leaf_fall(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 60.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 2.2))
	var sway: float = float(o.get("sway", 14.0))
	var origin: Vector2 = node.position
	var orig_rot: float = node.rotation_degrees
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + Vector2(sway, dist), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2(sway, -dist), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot + 40.0, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot - 40.0, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func torch(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var min_energy: float = clampf(float(o.get("min_energy", 0.55)), 0.0, 1.0)
	var max_energy: float = clampf(float(o.get("max_energy", 1.0)), 0.0, 3.0)
	var dur: float = max(0.02, float(o.get("dur", 0.12)))
	var orig: float = node.energy
	var rng := RandomNumberGenerator.new()
	for i in 8:
		tween.tween_property(node, "energy", rng.randf_range(min_energy, max_energy), dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "energy", orig, dur)
	return tween


static func tree_sway(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 4.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 3.0))
	var orig: float = node.rotation_degrees
	var origin: Vector2 = node.position
	tween.set_parallel(true)
	tween.tween_property(node, "rotation_degrees", orig + angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig - angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin + Vector2(2.0, 0.0), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2(2.0, 0.0), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func flower_bob(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var amp: float = float(o.get("amp", 4.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.4))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin - Vector2.UP * amp, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale * 1.04, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func wave(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var amp: float = float(o.get("amp", 18.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var origin: Vector2 = node.position
	tween.tween_property(node, "position", origin + Vector2.RIGHT * amp, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2.RIGHT * amp, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func tornado(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var orig: float = node.rotation_degrees
	var origin: Vector2 = node.position
	var rng := RandomNumberGenerator.new()
	tween.set_parallel(true)
	tween.tween_property(node, "rotation_degrees", orig + 720.0, dur).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "position", origin + Vector2(rng.randf_range(-6.0, 6.0), 0.0), dur * 0.1).set_trans(Tween.TRANS_LINEAR)
	return tween


static func meteor(node, o: Dictionary) -> Tween:
	if node.get_parent() == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2(1, 1)) as Vector2).normalized()
	var dist: float = float(o.get("dist", 240.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	var tween: Tween = node.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + dir * dist, dur)
	tween.tween_property(node, "scale", orig_scale * Vector2(1.2, 0.7), dur * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.5).set_delay(dur * 0.5)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if is_instance_valid(node):
			node.queue_free()
	)
	return tween


static func vine_grow(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var orig_scale: Vector2 = node.scale
	var orig_alpha: float = node.modulate.a
	node.scale = Vector2(orig_scale.x, 0.01)
	node.modulate.a = 0.0
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.3)
	tween.tween_property(node, "scale", orig_scale, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 5.0, dur * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees, dur * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween