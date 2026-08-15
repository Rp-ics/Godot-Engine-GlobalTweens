# =============================================================================
#  GlobalTweens — Category: death
#  Death animations: dissolve, collapse, puff, shatter, vanish, sink...
#  All free the node at the end (override with free_after=false).
# =============================================================================

class_name GT_Death
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"dissolve": {
			"fn": dissolve, "node_type": "Node2D",
			"desc": "Slow dissolve: fades out, shrinks and sinks while fading.",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 0.6},
			"restore": false,
		},
		"collapse": {
			"fn": collapse, "node_type": "Node2D",
			"desc": "Vertical collapse: squashes flat to the ground while fading.",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 0.4},
			"restore": false,
		},
		"puff": {
			"fn": puff, "node_type": "Node2D",
			"desc": "Quick puff-out: pops up, shrinks and disappears (Mario-like).",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 0.35},
			"restore": false,
		},
		"wilt": {
			"fn": wilt, "node_type": "Node2D",
			"desc": "Dramatic wilt: slowly tips over, sinks and fades. Great for plants/bosses.",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 0.9},
			"restore": false,
		},
		"zap": {
			"fn": zap, "node_type": "Node2D",
			"desc": "Electrocuted: strobing flashes, jitter and a final pop.",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 0.5},
			"restore": false,
		},
		"shatter": {
			"fn": shatter, "node_type": "Node2D",
			"desc": "Shatters into flying colored shards that fade and fall.",
			"params": "count:int, dur:float, free_after:bool",
			"defaults": {"count": 10, "dur": 0.6},
			"restore": false,
		},
		"vanish": {
			"fn": vanish, "node_type": "Node2D",
			"desc": "Glitchy vanish: horizontal stretch collapse with a flash.",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 0.4},
			"restore": false,
		},
		"sink": {
			"fn": sink, "node_type": "Node2D",
			"desc": "Sinks into the ground (like being sucked by quicksand).",
			"params": "depth:float, dur:float, free_after:bool",
			"defaults": {"depth": 60.0, "dur": 0.8},
			"restore": false,
		},
		"float_away": {
			"fn": float_away, "node_type": "Node2D",
			"desc": "Spirit death: gently floats up and fades away.",
			"params": "dist:float, dur:float, free_after:bool",
			"defaults": {"dist": 90.0, "dur": 1.0},
			"restore": false,
		},
		"implode": {
			"fn": implode, "node_type": "Node2D",
			"desc": "Implodes into a point with a white flash (black-hole style).",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 0.45},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func _finish(node, o: Dictionary) -> void:
	pass


static func _hook_free(tween: Tween, node, o: Dictionary) -> void:
	if not o.get("free_after", true):
		return
	tween.finished.connect(func():
		if is_instance_valid(node):
			node.queue_free()
	)


static func dissolve(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig_scale * 0.6, dur * 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "position", origin + Vector2.DOWN * 30.0, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_hook_free(tween, node, o)
	return tween


static func collapse(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 1.2, 0.02), dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.8)
	_hook_free(tween, node, o)
	return tween


static func puff(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig_scale * 1.5, dur * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.7)
	tween.tween_property(node, "position", origin - Vector2.UP * 14.0, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hook_free(tween, node, o)
	tween.tween_callback(func():
		GT_Jump.coyote_dust(node.get_parent() if node.get_parent() else node, {"count": 4})
	)
	return tween


static func wilt(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var origin: Vector2 = node.position
	tween.set_parallel(true)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 88.0, dur * 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "position", origin + Vector2.DOWN * 22.0, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.6).set_delay(dur * 0.4)
	_hook_free(tween, node, o)
	return tween


static func zap(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var origin: Vector2 = node.position
	var orig: Color = node.modulate
	var rng := RandomNumberGenerator.new()
	for i in 4:
		var jitter: Vector2 = Vector2(rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0))
		tween.tween_property(node, "position", origin + jitter, dur * 0.06)
		tween.tween_property(node, "modulate", Color.WHITE if i % 2 == 0 else Color(0.6, 0.9, 1.0), dur * 0.05)
	tween.tween_property(node, "position", origin, dur * 0.05)
	tween.tween_property(node, "modulate", orig, dur * 0.05)
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ZERO, dur * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.4)
	_hook_free(tween, node, o)
	tween.tween_callback(func():
		GT_Hit.spark(node.get_parent() if node.get_parent() else node, {"count": 8, "color": Color(0.5, 0.9, 1.0)})
	)
	return tween


static func shatter(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var count: int = max(4, int(o.get("count", 10)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var host := parent.create_tween().set_parallel(true)
	var rng := RandomNumberGenerator.new()
	for i in range(count):
		var size: Vector2 = Vector2(rng.randf_range(5.0, 14.0), rng.randf_range(5.0, 14.0))
		var rect := GT_Factory.spawn_rect(parent, size, Color(rng.randf_range(0.5, 1.0), rng.randf_range(0.4, 0.9), rng.randf_range(0.5, 1.0)))
		rect.global_position = node.global_position + Vector2(rng.randf_range(-16.0, 16.0), rng.randf_range(-16.0, 16.0))
		var angle: float = rng.randf_range(0.0, TAU)
		var target := rect.global_position + Vector2(cos(angle), sin(angle)) * rng.randf_range(40.0, 120.0)
		host.tween_property(rect, "global_position", target, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		host.tween_property(rect, "rotation", rng.randf_range(-TAU, TAU), dur)
		host.tween_property(rect, "modulate:a", 0.0, dur * 0.8)
		host.tween_callback(func():
			if is_instance_valid(rect):
				rect.queue_free()
		)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return host
	tween.set_parallel(true)
	tween.tween_property(node, "scale", node.scale * 0.1, dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.2)
	_hook_free(tween, node, o)
	return host


static func vanish(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 2.4, 0.05), dur * 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.4).set_delay(dur * 0.3)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 4.0, dur * 0.5)
	_hook_free(tween, node, o)
	return tween


static func sink(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var depth: float = float(o.get("depth", 60.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var origin: Vector2 = node.position
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + Vector2.DOWN * depth, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.9)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 8.0, dur)
	_hook_free(tween, node, o)
	return tween


static func float_away(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 90.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var origin: Vector2 = node.position
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin - Vector2.UP * dist, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 12.0, dur)
	_hook_free(tween, node, o)
	return tween


static func implode(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var orig: Color = node.modulate
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ZERO, dur * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate", Color.WHITE, dur * 0.25)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.5).set_delay(dur * 0.1)
	tween.set_parallel(false)
	tween.tween_property(node, "modulate", orig, 0.01)
	_hook_free(tween, node, o)
	tween.tween_callback(func():
		GT_Flash.ring(node.get_parent() if node.get_parent() else node, {"size": 26.0, "dur": 0.3, "color": Color.WHITE})
	)
	return tween