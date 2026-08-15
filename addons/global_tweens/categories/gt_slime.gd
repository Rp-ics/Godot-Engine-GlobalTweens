# =============================================================================
#  GlobalTweens — Category: slime
#  Gooey, dripping, squishy life: idle wobble, drips, hops, shivers...
# =============================================================================

class_name GT_Slime
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"idle": {
			"fn": idle, "node_type": "Node2D",
			"desc": "Breathing idle: gentle squash/stretch cycle (loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.08, "dur": 1.2, "loops": -1},
			"restore": true,
		},
		"drip": {
			"fn": drip, "node_type": "Node2D",
			"desc": "A blob dripping: slow stretch down, a wobble, and snap back up.",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.3, "dur": 0.9},
			"restore": true,
		},
		"hop": {
			"fn": hop, "node_type": "Node2D",
			"desc": "Classic slime hop: squash, jump, squash on landing (loopable).",
			"params": "height:float, dur:float, loops:int",
			"defaults": {"height": 34.0, "dur": 0.9, "loops": 1},
			"restore": true,
		},
		"grow": {
			"fn": grow, "node_type": "Node2D",
			"desc": "Slowly grows to a bigger size (stays grown).",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.6, "dur": 1.2},
			"restore": false,
		},
		"shiver": {
			"fn": shiver, "node_type": "Node2D",
			"desc": "High-frequency nervous jitter (cold slime / scared slime).",
			"params": "intensity:float, dur:float, loops:int",
			"defaults": {"intensity": 0.05, "dur": 0.12, "loops": -1},
			"restore": true,
		},
		"squish_floor": {
			"fn": squish_floor, "node_type": "Node2D",
			"desc": "Spread flat against the floor, hold, then pop back up.",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.6, "dur": 0.8},
			"restore": true,
		},
		"blob_wobble": {
			"fn": blob_wobble, "node_type": "Node2D",
			"desc": "Random jelly-like wobbles in random directions (loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.2, "dur": 1.4, "loops": -1},
			"restore": true,
		},
		"goo_smear": {
			"fn": goo_smear, "node_type": "Node2D",
			"desc": "Smears flat+wide while fading slightly, then recovers (goo being squashed).",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.4, "dur": 0.5},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func idle(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.08)), 1.01, 2.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", Vector2(orig.x / factor, orig.y * factor), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func drip(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.3)), 1.01, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", Vector2(orig.x / factor, orig.y * factor), dur * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig, dur * 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(dur * 0.2)
	return tween


static func hop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 34.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var origin: Vector2 = node.position
	var orig: Vector2 = node.scale
	# anticipation squash
	tween.tween_property(node, "scale", Vector2(orig.x * 1.35, orig.y * 0.65), dur * 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# jump (stretch up)
	tween.set_parallel(true)
	tween.tween_property(node, "position:y", origin.y - height, dur * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(orig.x * 0.8, orig.y * 1.25), dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	# fall
	tween.tween_property(node, "position:y", origin.y, dur * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# landing squash
	tween.tween_property(node, "scale", Vector2(orig.x * 1.5, orig.y * 0.5), dur * 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig, dur * 0.18).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func grow(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.6)), 1.01, 5.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", orig * factor, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(dur * 0.15)
	tween.tween_property(node, "scale", orig * factor * 1.05, dur * 0.2).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig * factor, dur * 0.15).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN)
	return tween


static func shiver(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var intensity: float = clampf(float(o.get("intensity", 0.05)), 0.005, 0.5)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.12))
	var orig: Vector2 = node.scale
	var rng := RandomNumberGenerator.new()
	for i in 6:
		var dir: float = 1.0 if i % 2 == 0 else -1.0
		tween.tween_property(node, "scale", Vector2(orig.x * (1.0 + dir * intensity), orig.y * (1.0 - dir * intensity)), dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween


static func squish_floor(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.6)), 1.05, 5.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var orig: Vector2 = node.scale
	var flat: Vector2 = Vector2(orig.x * factor, orig.y / factor)
	tween.tween_property(node, "position:y", node.position.y + 6.0, dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", flat, dur * 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", flat, dur * 0.25)
	tween.tween_property(node, "position:y", node.position.y, dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig, dur * 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	return tween


static func blob_wobble(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.2)), 1.01, 2.5)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.4))
	var orig: Vector2 = node.scale
	var rng := RandomNumberGenerator.new()
	for i in 8:
		var fx: float = rng.randf_range(1.0, factor)
		var fy: float = rng.randf_range(1.0, factor) * (1.0 if rng.randf() < 0.5 else -1.0)
		tween.tween_property(node, "scale", Vector2(orig.x * fx, orig.y / fy), dur * 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(node, "scale", orig, dur * 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func goo_smear(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.4)), 1.01, 4.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var orig: Vector2 = node.scale
	var orig_alpha: float = node.modulate.a
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2(orig.x * factor, orig.y / factor), dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha * 0.7, dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.6)
	return tween