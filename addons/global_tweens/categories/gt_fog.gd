# =============================================================================
#  GlobalTweens — Category: fog
#  Atmospheric fog layers: drift, scroll, thicken, dissipate, pulse, swirl,
#  rise and billow. Works on any Node2D fog sprite/layer.
# =============================================================================

class_name GT_Fog
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"drift": {
			"fn": drift, "node_type": "Node2D",
			"desc": "Slow horizontal to-and-fro drifting (loop).",
			"params": "dist:float, dur:float, loops:int",
			"defaults": {"dist": 60.0, "dur": 8.0, "loops": -1},
			"restore": true,
		},
		"scroll": {
			"fn": scroll, "node_type": "Node2D",
			"desc": "One-way linear scroll (directional, keeps its final position).",
			"params": "dir:Vector2, dist:float, dur:float",
			"defaults": {"dir": Vector2.RIGHT, "dist": 120.0, "dur": 6.0},
			"restore": false,
		},
		"thicken": {
			"fn": thicken, "node_type": "Node2D",
			"desc": "Fog rolls in: alpha rises and the layer grows slightly (kept).",
			"params": "alpha:float, dur:float",
			"defaults": {"alpha": 0.9, "dur": 2.0},
			"restore": false,
		},
		"dissipate": {
			"fn": dissipate, "node_type": "Node2D",
			"desc": "Fog clears: fades away while drifting up and growing (kept).",
			"params": "dur:float",
			"defaults": {"dur": 2.5},
			"restore": false,
		},
		"pulse": {
			"fn": pulse, "node_type": "Node2D",
			"desc": "Fog breathing: alpha pulses between two values (loop).",
			"params": "min_alpha:float, max_alpha:float, dur:float, loops:int",
			"defaults": {"min_alpha": 0.25, "max_alpha": 0.6, "dur": 3.0, "loops": -1},
			"restore": true,
		},
		"swirl": {
			"fn": swirl, "node_type": "Node2D",
			"desc": "Slow circular drift with continuous rotation (loop).",
			"params": "radius:float, dur:float, loops:int",
			"defaults": {"radius": 20.0, "dur": 10.0, "loops": -1},
			"restore": true,
		},
		"rise": {
			"fn": rise, "node_type": "Node2D",
			"desc": "Fog rising: slowly floats upward then resets (loop).",
			"params": "dist:float, dur:float, loops:int",
			"defaults": {"dist": 40.0, "dur": 6.0, "loops": -1},
			"restore": true,
		},
		"billow": {
			"fn": billow, "node_type": "Node2D",
			"desc": "Billowing: scale breathes out while alpha pulses (loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.15, "dur": 4.0, "loops": -1},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func drift(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 60.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 8.0))
	var origin: Vector2 = node.position
	tween.tween_property(node, "position", origin + Vector2.RIGHT * dist, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2.RIGHT * dist, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func scroll(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.RIGHT) as Vector2).normalized()
	var dist: float = float(o.get("dist", 120.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 6.0))
	tween.tween_property(node, "position", node.position + dir * dist, dur).set_trans(Tween.TRANS_LINEAR)
	return tween


static func thicken(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var alpha: float = clampf(float(o.get("alpha", 0.9)), 0.0, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 2.0))
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "modulate:a", alpha, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale * 1.12, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func dissipate(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 2.5))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig_scale * 1.2, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2.UP * 24.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func pulse(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var min_alpha: float = clampf(float(o.get("min_alpha", 0.25)), 0.0, 1.0)
	var max_alpha: float = clampf(float(o.get("max_alpha", 0.6)), 0.0, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 3.0))
	tween.tween_property(node, "modulate:a", max_alpha, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", min_alpha, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func swirl(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var radius: float = float(o.get("radius", 20.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 10.0))
	var origin: Vector2 = node.position
	var orig_rot: float = node.rotation_degrees
	var rng := RandomNumberGenerator.new()
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + Vector2(radius, 0.0), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin + Vector2(0.0, radius), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2(radius, 0.0), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin - Vector2(0.0, radius), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot + 360.0, dur).set_trans(Tween.TRANS_LINEAR)
	return tween


static func rise(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 40.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 6.0))
	var origin: Vector2 = node.position
	tween.tween_property(node, "position", origin - Vector2.UP * dist, dur * 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin, dur * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func billow(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.15)), 1.02, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 4.0))
	var orig_scale: Vector2 = node.scale
	var orig_alpha: float = node.modulate.a
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig_scale * factor, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha * 0.7, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween