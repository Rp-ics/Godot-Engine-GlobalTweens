# =============================================================================
#  GlobalTweens — Category: generic
#  All-purpose loops: pulse, wiggle, breathe, rock, flicker, fade, move,
#  stretch, color cycle and blob squash-stretch. Default loops = infinite
#  (restore keeps them safe when stopped).
# =============================================================================

class_name GT_Generic
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"pulse_loop": {
			"fn": pulse_loop, "node_type": "Node2D",
			"desc": "Scale pulses between min_scale and max_scale (loop).",
			"params": "min_scale:float, max_scale:float, dur:float, loops:int",
			"defaults": {"min_scale": 0.9, "max_scale": 1.1, "dur": 0.8, "loops": -1},
			"restore": true,
		},
		"wiggle_loop": {
			"fn": wiggle_loop, "node_type": "Node2D",
			"desc": "Rotation wobbles left and right (loop).",
			"params": "angle:float, dur:float, loops:int",
			"defaults": {"angle": 6.0, "dur": 0.5, "loops": -1},
			"restore": true,
		},
		"breathe_loop": {
			"fn": breathe_loop, "node_type": "Node2D",
			"desc": "Subtle scale + alpha breathing (loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.06, "dur": 2.0, "loops": -1},
			"restore": true,
		},
		"rock": {
			"fn": rock, "node_type": "Node2D",
			"desc": "Slow pendulum rock (loop).",
			"params": "angle:float, dur:float, loops:int",
			"defaults": {"angle": 10.0, "dur": 2.4, "loops": -1},
			"restore": true,
		},
		"flicker": {
			"fn": flicker, "node_type": "CanvasItem",
			"desc": "Random alpha flicker (old lamps, damaged enemies, ghosts).",
			"params": "steps:int, min_alpha:float, dur:float, loops:int",
			"defaults": {"steps": 12, "min_alpha": 0.3, "dur": 1.2, "loops": -1},
			"restore": true,
		},
		"fade_in_out": {
			"fn": fade_in_out, "node_type": "CanvasItem",
			"desc": "Fades to min_alpha, holds, returns to full (loop).",
			"params": "min_alpha:float, dur:float, hold:float, loops:int",
			"defaults": {"min_alpha": 0.05, "dur": 0.6, "hold": 0.4, "loops": -1},
			"restore": true,
		},
		"move_loop": {
			"fn": move_loop, "node_type": "Node2D",
			"desc": "Glides between the origin and dir * dist (loop).",
			"params": "dir:Vector2, dist:float, dur:float, loops:int",
			"defaults": {"dir": Vector2.UP, "dist": 20.0, "dur": 1.2, "loops": -1},
			"restore": true,
		},
		"stretch_loop": {
			"fn": stretch_loop, "node_type": "Node2D",
			"desc": "Alternating horizontal/vertical stretch (loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.2, "dur": 1.0, "loops": -1},
			"restore": true,
		},
		"color_cycle": {
			"fn": color_cycle, "node_type": "CanvasItem",
			"desc": "Modulate cycles through the palette (loop).",
			"params": "palette:Array[Color], dur:float, loops:int",
			"defaults": {
				"palette": [Color(1.0, 0.9, 0.7), Color(1.0, 0.7, 0.9), Color(0.7, 0.9, 1.0)],
				"dur": 1.5, "loops": -1,
			},
			"restore": true,
		},
		"blob": {
			"fn": blob, "node_type": "Node2D",
			"desc": "Bouncy squash-stretch like a slime (loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.25, "dur": 0.9, "loops": -1},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func pulse_loop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var min_scale: float = clampf(float(o.get("min_scale", 0.9)), 0.05, 5.0)
	var max_scale: float = max(0.1, float(o.get("max_scale", 1.1)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", orig * max_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig * min_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func wiggle_loop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 6.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var orig: float = node.rotation_degrees
	var half := dur * 0.5
	tween.tween_property(node, "rotation_degrees", orig + angle, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig - angle, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func breathe_loop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.06)), 1.005, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 2.0))
	var orig_scale: Vector2 = node.scale
	var orig_alpha: float = node.modulate.a
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig_scale * factor, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha * 0.85, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func rock(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 10.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 2.4))
	var orig: float = node.rotation_degrees
	var half := dur * 0.5
	tween.tween_property(node, "rotation_degrees", orig + angle, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func flicker(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var steps: int = max(4, int(o.get("steps", 12)))
	var min_alpha: float = clampf(float(o.get("min_alpha", 0.3)), 0.0, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var orig_alpha: float = node.modulate.a
	var rng := RandomNumberGenerator.new()
	var step: float = dur / float(steps)
	for i in range(steps):
		var a: float = orig_alpha if i % 2 == 0 else orig_alpha * rng.randf_range(min_alpha, 0.8)
		tween.tween_property(node, "modulate:a", a, step * rng.randf_range(0.4, 1.0))
	tween.tween_property(node, "modulate:a", orig_alpha, step)
	return tween


static func fade_in_out(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var min_alpha: float = clampf(float(o.get("min_alpha", 0.05)), 0.0, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var hold: float = max(0.0, float(o.get("hold", 0.4)))
	tween.tween_property(node, "modulate:a", min_alpha, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(hold)
	tween.tween_property(node, "modulate:a", 1.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func move_loop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.UP) as Vector2).normalized()
	var dist: float = float(o.get("dist", 20.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var origin: Vector2 = node.position
	tween.tween_property(node, "position", origin + dir * dist, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func stretch_loop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.2)), 1.01, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var orig: Vector2 = node.scale
	var half := dur * 0.5
	tween.tween_property(node, "scale", Vector2(orig.x * factor, orig.y / factor), half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", Vector2(orig.x / factor, orig.y * factor), half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func color_cycle(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var palette: Array = o.get("palette", [Color(1.0, 0.9, 0.7), Color(1.0, 0.7, 0.9), Color(0.7, 0.9, 1.0)])
	if palette.is_empty():
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.5))
	for c in palette:
		tween.tween_property(node, "modulate", c, dur / float(palette.size()))
	return tween


static func blob(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.25)), 1.05, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", Vector2(orig.x * factor, orig.y / factor), dur * 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween