# =============================================================================
#  GlobalTweens — Category: camera
#  Camera drama: zoom kicks, focus pans, cut kicks, slow-motion, orbit drift.
# =============================================================================

class_name GT_Camera
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"zoom_kick": {
			"fn": zoom_kick, "node_type": "Camera2D",
			"desc": "Quick zoom punch-in and back (impact / explosion).",
			"params": "target:float, dur:float",
			"defaults": {"target": 1.15, "dur": 0.35},
			"restore": true,
		},
		"focus": {
			"fn": focus, "node_type": "Camera2D",
			"desc": "Cinematic: pans to a world position while zooming in, then returns.",
			"params": "target:Vector2, zoom:float, dur:float, hold:float",
			"defaults": {"zoom": 1.3, "dur": 0.6, "hold": 1.0},
			"restore": true,
		},
		"cut_kick": {
			"fn": cut_kick, "node_type": "Camera2D",
			"desc": "Directional offset kick (hit-stop style camera nudge).",
			"params": "dir:Vector2, power:float, dur:float",
			"defaults": {"dir": Vector2.LEFT, "power": 16.0, "dur": 0.25},
			"restore": true,
		},
		"slow_motion": {
			"fn": slow_motion, "node_type": "Camera2D",
			"desc": "Dramatic slow-motion zoom: time slows while the camera closes in.",
			"params": "target:float, time_scale:float, dur:float",
			"defaults": {"target": 1.35, "time_scale": 0.35, "dur": 1.2},
			"restore": true,
		},
		"orbit_drift": {
			"fn": orbit_drift, "node_type": "Camera2D",
			"desc": "Drone-like drifting orbit of the camera offset (loop).",
			"params": "radius:float, dur:float, loops:int",
			"defaults": {"radius": 12.0, "dur": 6.0, "loops": -1},
			"restore": true,
		},
		"fov_pulse": {
			"fn": fov_pulse, "node_type": "Camera2D",
			"desc": "Breathing zoom pulse (heartbeat tension, loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.05, "dur": 1.6, "loops": -1},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func zoom_kick(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var target: float = max(1.01, float(o.get("target", 1.15)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var orig: Vector2 = node.zoom
	tween.tween_property(node, "zoom", Vector2.ONE * target, dur * 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "zoom", orig, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func focus(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var target: Vector2 = o.get("target", node.global_position)
	var zoom_target: float = max(1.01, float(o.get("zoom", 1.3)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var hold: float = max(0.0, float(o.get("hold", 1.0)))
	var origin: Vector2 = node.global_position
	var orig_zoom: Vector2 = node.zoom
	tween.tween_property(node, "global_position", target, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(node, "zoom", Vector2.ONE * zoom_target, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	tween.tween_interval(hold)
	tween.set_parallel(true)
	tween.tween_property(node, "global_position", origin, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "zoom", orig_zoom, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	return tween


static func cut_kick(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.LEFT) as Vector2).normalized()
	var power: float = float(o.get("power", 16.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.25))
	var orig: Vector2 = node.offset
	tween.tween_property(node, "offset", orig + dir * power, dur * 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "offset", orig, dur * 0.7).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func slow_motion(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var target: float = max(1.01, float(o.get("target", 1.35)))
	var time_scale: float = clampf(float(o.get("time_scale", 0.35)), 0.05, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var orig: Vector2 = node.zoom
	tween.tween_callback(func():
		Engine.time_scale = time_scale
	)
	tween.tween_property(node, "zoom", Vector2.ONE * target, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "zoom", orig, dur * 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		Engine.time_scale = 1.0
	)
	return tween


static func orbit_drift(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var radius: float = float(o.get("radius", 12.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 6.0))
	var orig: Vector2 = node.offset
	tween.tween_property(node, "offset", orig + Vector2(radius, 0.0), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "offset", orig + Vector2(0.0, radius), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "offset", orig - Vector2(radius, 0.0), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "offset", orig - Vector2(0.0, radius), dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func fov_pulse(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = max(1.005, float(o.get("factor", 1.05)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.6))
	var orig: Vector2 = node.zoom
	tween.tween_property(node, "zoom", orig * factor, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "zoom", orig, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween