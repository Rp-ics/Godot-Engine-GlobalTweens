# =============================================================================
#  GlobalTweens — Category: player
#  Player feel: idle bob, run bob, dash, land, wall slide, air tricks...
# =============================================================================

class_name GT_Player
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"idle_bob": {
			"fn": idle_bob, "node_type": "Node2D",
			"desc": "Gentle breathing bob up/down with a slight rotation sway (loop).",
			"params": "amp:float, dur:float, loops:int",
			"defaults": {"amp": 5.0, "dur": 1.0, "loops": -1},
			"restore": true,
		},
		"run_bob": {
			"fn": run_bob, "node_type": "Node2D",
			"desc": "Fast run bounce with forward lean (loop).",
			"params": "amp:float, dur:float, tilt:float, loops:int",
			"defaults": {"amp": 3.5, "dur": 0.3, "tilt": 4.0, "loops": -1},
			"restore": true,
		},
		"dash": {
			"fn": dash, "node_type": "Node2D",
			"desc": "Dash burst: horizontal stretch forward, flash, then recover.",
			"params": "dir:Vector2, factor:float, dur:float",
			"defaults": {"dir": Vector2.RIGHT, "factor": 1.6, "dur": 0.35},
			"restore": true,
		},
		"dash_trail": {
			"fn": dash_trail, "node_type": "Node2D",
			"desc": "Spawns fading ghost copies behind the node (motion trail burst).",
			"params": "count:int, interval:float, fade:float",
			"defaults": {"count": 5, "interval": 0.06, "fade": 0.3},
			"restore": false,
		},
		"land": {
			"fn": land, "node_type": "Node2D",
			"desc": "Player landing: deep squash, dust puff and settle.",
			"params": "power:float, dur:float",
			"defaults": {"power": 1.45, "dur": 0.3},
			"restore": true,
		},
		"wall_slide": {
			"fn": wall_slide, "node_type": "Node2D",
			"desc": "Wall-slide squash with a grinding jitter (loop).",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 0.9, "loops": -1},
			"restore": true,
		},
		"jump_crouch": {
			"fn": jump_crouch, "node_type": "Node2D",
			"desc": "Anticipation crouch, then spring release upward (jump start).",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 1.35, "dur": 0.45},
			"restore": true,
		},
		"air_flip": {
			"fn": air_flip, "node_type": "Node2D",
			"desc": "Mid-air 360 flip with a slight stretch.",
			"params": "dur:float",
			"defaults": {"dur": 0.5},
			"restore": true,
		},
		"hurt": {
			"fn": hurt, "node_type": "Node2D",
			"desc": "Player hurt: red flash, knockback, shake, invincible flicker.",
			"params": "dir:Vector2, power:float, dur:float",
			"defaults": {"dir": Vector2.LEFT, "power": 40.0, "dur": 0.5},
			"restore": true,
		},
		"revive": {
			"fn": revive, "node_type": "CanvasItem",
			"desc": "Respawn: fade in from nothing with a scale pop and white flash.",
			"params": "dur:float",
			"defaults": {"dur": 0.5},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func idle_bob(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var amp: float = float(o.get("amp", 5.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var origin: Vector2 = node.position
	var orig_rot: float = node.rotation_degrees
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin - Vector2.UP * amp, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot + 1.5, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot - 1.5, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func run_bob(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var amp: float = float(o.get("amp", 3.5))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var tilt: float = float(o.get("tilt", 4.0))
	var origin: Vector2 = node.position
	var orig_rot: float = node.rotation_degrees
	tween.set_parallel(true)
	tween.tween_property(node, "position:y", origin.y - amp, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", origin.y, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "rotation_degrees", orig_rot + tilt, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot - tilt, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func dash(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.RIGHT) as Vector2).normalized()
	var factor: float = clampf(float(o.get("factor", 1.6)), 1.05, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var orig_scale: Vector2 = node.scale
	var stretch: Vector2 = Vector2(orig_scale.x * factor, orig_scale.y / factor) if abs(dir.x) > abs(dir.y) else Vector2(orig_scale.x / factor, orig_scale.y * factor)
	tween.set_parallel(true)
	tween.tween_property(node, "scale", stretch, dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", Color.WHITE, dur * 0.2)
	tween.set_parallel(false)
	tween.tween_property(node, "scale", orig_scale, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func dash_trail(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var count: int = max(1, int(o.get("count", 5)))
	var interval: float = max(0.02, float(o.get("interval", 0.06)))
	var fade: float = max(0.05, float(o.get("fade", 0.3)))
	var host := parent.create_tween()
	for i in range(count):
		host.tween_interval(interval)
		host.tween_callback(func():
			if not is_instance_valid(node) or not is_instance_valid(parent):
				return
			var ghost: CanvasItem = node.duplicate()
			ghost.modulate = Color(1, 1, 1, 0.7)
			parent.add_child(ghost)
			var t: Tween = ghost.create_tween()
			t.tween_property(ghost, "modulate:a", 0.0, fade)
			t.tween_callback(func():
				if is_instance_valid(ghost):
					ghost.queue_free()
			)
		)
	return host


static func land(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var power: float = clampf(float(o.get("power", 1.45)), 1.05, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var orig_scale: Vector2 = node.scale
	tween.tween_property(node, "scale", Vector2(orig_scale.x * power, orig_scale.y / power), dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig_scale, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		GT_Jump.coyote_dust(node.get_parent() if node.get_parent() else node, {"count": 3})
	)
	return tween


static func wall_slide(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var orig_scale: Vector2 = node.scale
	var origin: Vector2 = node.position
	var rng := RandomNumberGenerator.new()
	var jitter: Array = []
	for i in 6:
		jitter.append(Vector2(rng.randf_range(-2.0, 2.0), 0.0))
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 1.12, orig_scale.y * 0.9), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for i in 6:
		tween.tween_property(node, "position", origin + jitter[i], dur / 12.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func jump_crouch(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.35)), 1.05, 3.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var orig_scale: Vector2 = node.scale
	var origin: Vector2 = node.position
	tween.tween_property(node, "scale", Vector2(orig_scale.x * factor, orig_scale.y / factor), dur * 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_interval(dur * 0.1)
	tween.tween_property(node, "position:y", origin.y - 12.0, dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.35).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func air_flip(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var orig_scale: Vector2 = node.scale
	var origin: Vector2 = node.position
	tween.set_parallel(true)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 360.0, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position:y", origin.y - 30.0, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", origin.y, dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 1.15, orig_scale.y * 0.85), dur * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func hurt(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.LEFT) as Vector2).normalized()
	var power: float = float(o.get("power", 40.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var origin: Vector2 = node.position
	var orig: Color = node.modulate
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + dir * power, dur * 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", Color.RED, dur * 0.15)
	tween.tween_property(node, "modulate", orig, dur * 0.3)
	tween.set_parallel(false)
	tween.tween_property(node, "position", origin, dur * 0.7).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	# invincibility flicker
	for i in 4:
		tween.tween_property(node, "modulate:a", 0.25, dur * 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(node, "modulate:a", orig.a, dur * 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func revive(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var orig_scale: Vector2 = node.scale if node is Node2D else Vector2.ONE
	var orig: Color = node.modulate
	node.modulate = Color(1, 1, 1, 0)
	if node is Node2D:
		node.scale = orig_scale * 0.3
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", orig, dur * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if node is Node2D:
		tween.tween_property(node, "scale", orig_scale, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(node, "modulate", Color.WHITE, dur * 0.1).set_delay(dur * 0.5)
	tween.tween_property(node, "modulate", orig, dur * 0.2)
	return tween