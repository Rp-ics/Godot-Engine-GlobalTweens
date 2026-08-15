# =============================================================================
#  GlobalTweens — Category: squish
#  Squash & stretch goodness: squeeze, stretch, jelly, thud, flatten...
# =============================================================================

class_name GT_Squish
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"squeeze": {
			"fn": squeeze, "node_type": "Node2D",
			"desc": "Squash the node along an axis, hold, then spring back (volume preserved).",
			"params": "axis:String (x|y), factor:float, dur:float",
			"defaults": {"axis": "y", "factor": 1.3, "dur": 0.35},
			"restore": true,
		},
		"stretch": {
			"fn": stretch, "node_type": "Node2D",
			"desc": "Stretch the node along an axis, hold, then spring back.",
			"params": "axis:String (x|y), factor:float, dur:float",
			"defaults": {"axis": "y", "factor": 1.25, "dur": 0.4},
			"restore": true,
		},
		"jelly": {
			"fn": jelly, "node_type": "Node2D",
			"desc": "Gelatin wobble: several alternating squashes with decreasing energy.",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.25, "dur": 0.7},
			"restore": true,
		},
		"thud": {
			"fn": thud, "node_type": "Node2D",
			"desc": "Heavy impact response: deep squash, bounce and recover.",
			"params": "dur:float, bounce:float",
			"defaults": {"dur": 0.45, "bounce": 6.0},
			"restore": true,
		},
		"flatten": {
			"fn": flatten, "node_type": "Node2D",
			"desc": "Fully flatten the node (like a pancake or a hit by a crusher).",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.6, "dur": 0.6},
			"restore": true,
		},
		"bounce_squash": {
			"fn": bounce_squash, "node_type": "Node2D",
			"desc": "Squash-land, small hop, land again: trampoline bounce.",
			"params": "height:float, dur:float",
			"defaults": {"height": 24.0, "dur": 0.6},
			"restore": true,
		},
		"snap": {
			"fn": snap, "node_type": "Node2D",
			"desc": "Quick spring snap to full size from a slightly squashed state.",
			"params": "dur:float",
			"defaults": {"dur": 0.3},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func _axis_vec(o: Dictionary, orig: Vector2, factor: float) -> Vector2:
	if str(o.get("axis", "y")) == "x":
		return Vector2(orig.x * factor, orig.y / factor)
	return Vector2(orig.x / factor, orig.y * factor)


static func squeeze(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.3)), 1.01, 5.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var orig: Vector2 = node.scale
	var target := _axis_vec(o, orig, factor)
	tween.tween_property(node, "scale", target, dur * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", target, dur * 0.25)
	tween.tween_property(node, "scale", orig, dur * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


static func stretch(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.25)), 1.01, 5.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var orig: Vector2 = node.scale
	var target := _axis_vec(o, orig, factor)
	tween.tween_property(node, "scale", target, dur * 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", target, dur * 0.2)
	tween.tween_property(node, "scale", orig, dur * 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func jelly(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.25)), 1.01, 5.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	var orig: Vector2 = node.scale
	var step: float = dur / 6.0
	for i in 3:
		var amp: float = factor * (1.0 - i * 0.28)
		tween.tween_property(node, "scale", Vector2(orig.x * amp, orig.y / amp), step).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(node, "scale", Vector2(orig.x / amp, orig.y * amp), step).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig, step).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


static func thud(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var bounce: float = float(o.get("bounce", 6.0))
	var origin: Vector2 = node.position
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", Vector2(orig.x * 1.5, orig.y * 0.55), dur * 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig, dur * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", origin - Vector2.UP * bounce, dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", origin, dur * 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return tween


static func flatten(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.6)), 1.05, 8.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", Vector2(orig.x * factor, orig.y / factor), dur * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig, dur * 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func bounce_squash(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 24.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var origin: Vector2 = node.position
	var orig: Vector2 = node.scale
	# land (start squashed by previous fall: quick squash)
	tween.tween_property(node, "scale", Vector2(orig.x * 1.3, orig.y * 0.7), dur * 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# hop up
	tween.tween_property(node, "position:y", origin.y - height, dur * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig, dur * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# fall & land
	tween.tween_property(node, "position:y", origin.y, dur * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", Vector2(orig.x * 1.45, orig.y * 0.6), dur * 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig, dur * 0.22).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func snap(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", orig * 0.75, dur * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig, dur * 0.7).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween