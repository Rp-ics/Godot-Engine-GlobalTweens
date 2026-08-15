# =============================================================================
#  GlobalTweens — Category: jump
#  Jump arcs, hops, big leaps, flips, landings and air tricks.
# =============================================================================

class_name GT_Jump
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"arc": {
			"fn": arc, "node_type": "Node2D",
			"desc": "Classic jump: crouch squash, rise to apex, fall and land with a squash.",
			"params": "height:float, dur:float",
			"defaults": {"height": 70.0, "dur": 0.6},
			"restore": true,
		},
		"hop": {
			"fn": hop, "node_type": "Node2D",
			"desc": "Small single bounce in place (Mario-style coin hop).",
			"params": "height:float, dur:float",
			"defaults": {"height": 26.0, "dur": 0.35},
			"restore": true,
		},
		"big_leap": {
			"fn": big_leap, "node_type": "Node2D",
			"desc": "Big directional leap with forward lean, landing squash and dust.",
			"params": "dir:Vector2, dist:float, height:float, dur:float",
			"defaults": {"dir": Vector2.RIGHT, "dist": 160.0, "height": 60.0, "dur": 0.7},
			"restore": true,
		},
		"double_flip": {
			"fn": double_flip, "node_type": "Node2D",
			"desc": "Jump up while spinning 720 degrees, landing upright with a squash.",
			"params": "height:float, spins:int, dur:float",
			"defaults": {"height": 90.0, "spins": 2, "dur": 0.8},
			"restore": true,
		},
		"land": {
			"fn": land, "node_type": "Node2D",
			"desc": "Landing reaction: squash, dust puff and a tiny bounce.",
			"params": "power:float, dur:float",
			"defaults": {"power": 1.4, "dur": 0.3},
			"restore": true,
		},
		"ledge_hang": {
			"fn": ledge_hang, "node_type": "Node2D",
			"desc": "Hanging on an edge: a few worried wobbles, then settles.",
			"params": "angle:float, dur:float",
			"defaults": {"angle": 8.0, "dur": 0.7},
			"restore": true,
		},
		"soar": {
			"fn": soar, "node_type": "Node2D",
			"desc": "Gentle smooth rise with a hover hold, then soft landing.",
			"params": "height:float, dur:float",
			"defaults": {"height": 100.0, "dur": 1.0},
			"restore": true,
		},
		"coyote_dust": {
			"fn": coyote_dust, "node_type": "Node2D",
			"desc": "Spawns a small dust puff at the node's feet (jump starts, wall runs).",
			"params": "count:int, dur:float",
			"defaults": {"count": 3, "dur": 0.5},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func _land_squash(tween: Tween, node, orig_scale: Vector2, dur: float) -> void:
	tween.tween_property(node, "scale", orig_scale * Vector2(1.3, 0.7), dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)


static func arc(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 70.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	# crouch anticipation
	tween.tween_property(node, "scale", orig_scale * Vector2(1.15, 0.8), dur * 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# rise
	tween.tween_property(node, "position:y", origin.y - height, dur * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# fall
	tween.tween_property(node, "position:y", origin.y, dur * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# landing squash
	_land_squash(tween, node, orig_scale, dur * 0.3)
	return tween


static func hop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 26.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var y: float = node.position.y
	tween.tween_property(node, "position:y", y - height, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", y, dur * 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return tween


static func big_leap(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.RIGHT) as Vector2).normalized()
	var dist: float = float(o.get("dist", 160.0))
	var height: float = float(o.get("height", 60.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	var origin: Vector2 = node.position
	var target: Vector2 = origin + dir * dist
	var orig_rot: float = node.rotation_degrees
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "position", target - Vector2.UP * height, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot + 14.0 * (1.0 if dir.x >= 0 else -1.0), dur * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(node, "position", target, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "rotation_degrees", orig_rot, dur * 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	_land_squash(tween, node, orig_scale, dur * 0.35)
	tween.tween_callback(func():
		coyote_dust(node, {"count": 3})
	)
	return tween


static func double_flip(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 90.0))
	var spins: int = max(1, int(o.get("spins", 2)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "position:y", origin.y - height, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 360.0 * spins, dur * 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(false)
	tween.tween_property(node, "position:y", origin.y, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_land_squash(tween, node, orig_scale, dur * 0.3)
	return tween


static func land(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var power: float = float(o.get("power", 1.4))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var orig_scale: Vector2 = node.scale
	tween.tween_property(node, "scale", orig_scale * Vector2(power, 2.0 - power), dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		coyote_dust(node, {"count": 2})
	)
	return tween


static func ledge_hang(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 8.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	var orig: float = node.rotation_degrees
	for i in 4:
		var sign: float = 1.0 if i % 2 == 0 else -1.0
		var amp: float = angle * (1.0 - i * 0.18)
		tween.tween_property(node, "rotation_degrees", orig + amp * sign, dur * 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig, dur * 0.2).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func soar(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 100.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var y: float = node.position.y
	var orig_scale: Vector2 = node.scale
	tween.tween_property(node, "position:y", y - height, dur * 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", y - height * 0.85, dur * 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position:y", y, dur * 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_land_squash(tween, node, orig_scale, dur * 0.25)
	return tween


static func coyote_dust(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var count: int = max(1, int(o.get("count", 3)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var host := parent.create_tween().set_parallel(true)
	for i in range(count):
		var rect := GT_Factory.spawn_rect(parent, Vector2(7, 5), Color(0.85, 0.82, 0.78, 0.8))
		rect.global_position = node.global_position + Vector2(randf_range(-10.0, 10.0), 2.0)
		var angle: float = randf_range(PI * 0.75, PI * 1.25)
		var target := rect.global_position + Vector2(cos(angle), sin(angle)) * randf_range(14.0, 26.0)
		host.tween_property(rect, "global_position", target, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		host.tween_property(rect, "modulate:a", 0.0, dur)
		host.tween_callback(func():
			if is_instance_valid(rect):
				rect.queue_free()
		)
	return host
