# =============================================================================
#  GlobalTweens — Category: hit
#  Hit reactions: flash, knockback, launch, stun, damage popups, crits,
#  sparks, absorb, hitstop and more. All tween-driven, no await.
# =============================================================================

class_name GT_Hit
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"flash": {
			"fn": flash, "node_type": "CanvasItem",
			"desc": "Flash the node to a color and back (classic hit flash).",
			"params": "color:Color, dur:float",
			"defaults": {"dur": 0.2},
			"restore": true,
		},
		"knockback": {
			"fn": knockback, "node_type": "Node2D",
			"desc": "Push back along a direction with a white flash, then spring back to origin.",
			"params": "dir:Vector2, power:float, dur:float, color:Color",
			"defaults": {"dir": Vector2.RIGHT, "power": 70.0, "dur": 0.28},
			"restore": true,
		},
		"launch": {
			"fn": launch, "node_type": "Node2D",
			"desc": "Launch the node up in an arc with a squash, then land back.",
			"params": "power:float, dur:float",
			"defaults": {"power": 90.0, "dur": 0.5},
			"restore": true,
		},
		"stun_tilt": {
			"fn": stun_tilt, "node_type": "Node2D",
			"desc": "Stunned wobble: tilts left/right a few times, then settles upright.",
			"params": "angle:float, dur:float",
			"defaults": {"angle": 6.0, "dur": 0.5},
			"restore": true,
		},
		"flinch": {
			"fn": flinch, "node_type": "Node2D",
			"desc": "Quick short jerk backwards with a small flash. Subtle hit feedback.",
			"params": "dir:Vector2, dist:float, dur:float",
			"defaults": {"dir": Vector2.LEFT, "dist": 12.0, "dur": 0.18},
			"restore": true,
		},
		"damage_popup": {
			"fn": damage_popup, "node_type": "Node2D",
			"desc": "Spawns a floating damage number that rises and fades.",
			"params": "text:String, color:Color, font_size:int, rise:float, dur:float",
			"defaults": {"text": "12", "color": Color.RED, "font_size": 20, "rise": 50.0, "dur": 0.8},
			"restore": false,
		},
		"crit": {
			"fn": crit, "node_type": "Node2D",
			"desc": "Critical hit: big flash, scale pop and a bigger damage popup.",
			"params": "text:String, dur:float",
			"defaults": {"text": "CRIT! 24", "dur": 0.4},
			"restore": true,
		},
		"spark": {
			"fn": spark, "node_type": "Node2D",
			"desc": "Spawns a radial burst of tiny particles (cheap hit sparks).",
			"params": "count:int, speed:float, dur:float, color:Color",
			"defaults": {"count": 10, "speed": 130.0, "dur": 0.45},
			"restore": false,
		},
		"absorb": {
			"fn": absorb, "node_type": "Node2D",
			"desc": "Shrink + cyan flash, then elastic grow back. Absorb/heal feedback.",
			"params": "dur:float, color:Color",
			"defaults": {"dur": 0.4},
			"restore": true,
		},
		"push": {
			"fn": push, "node_type": "Node2D",
			"desc": "Persistent displacement: push away and STAY there (no auto-return).",
			"params": "dir:Vector2, power:float, dur:float",
			"defaults": {"dir": Vector2.RIGHT, "power": 90.0, "dur": 0.2},
			"restore": false,
		},
		"hitstop": {
			"fn": hitstop, "node_type": "Node",
			"desc": "Hit-stop freeze: slows Engine.time_scale for a beat, then restores.",
			"params": "dur:float, freeze_scale:float",
			"defaults": {"dur": 0.09, "freeze_scale": 0.05},
			"restore": false,
		},
		"graze": {
			"fn": graze, "node_type": "CanvasItem",
			"desc": "Ghostly near-miss flicker: fades and flashes white, then recovers.",
			"params": "dur:float",
			"defaults": {"dur": 0.3},
			"restore": true,
		},
		"shield_break": {
			"fn": shield_break, "node_type": "Node2D",
			"desc": "Shield break: cyan flash, expanding ring, horizontal shatter-squash.",
			"params": "dur:float",
			"defaults": {"dur": 0.45},
			"restore": true,
		},
		"thud": {
			"fn": thud, "node_type": "Node2D",
			"desc": "Heavy blunt hit: hard squash + downward bump + shake, then recover.",
			"params": "dur:float, power:float",
			"defaults": {"dur": 0.35, "power": 8.0},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders (static, tween-driven)
# ---------------------------------------------------------------------------

static func flash(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.2))
	var color: Color = o.get("color", Color.WHITE)
	var orig: Color = node.modulate
	GT_Factory.tweenp(tween, node, "modulate", color, dur * 0.5)
	GT_Factory.tweenp(tween, node, "modulate", orig, dur * 0.5)
	return tween


static func knockback(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.28))
	var dir: Vector2 = (o.get("dir", Vector2.RIGHT) as Vector2).normalized()
	var power: float = float(o.get("power", 70.0))
	var color: Color = o.get("color", Color.WHITE)
	var origin: Vector2 = node.position
	var orig_color: Color = node.modulate
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + dir * power, dur * 0.35).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", color, dur * 0.18)
	tween.tween_property(node, "modulate", orig_color, dur * 0.5).set_delay(dur * 0.2)
	tween.set_parallel(false)
	tween.tween_property(node, "position", origin, dur * 0.65).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func launch(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var power: float = float(o.get("power", 90.0))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + Vector2.UP * power, dur * 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale * Vector2(1.15, 0.8), dur * 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(node, "position", origin, dur * 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig_scale, dur * 0.35).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func stun_tilt(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var angle: float = float(o.get("angle", 6.0))
	var orig: float = node.rotation_degrees
	for i in 3:
		var sign: float = 1.0 if i % 2 == 0 else -1.0
		tween.tween_property(node, "rotation_degrees", orig + angle * sign, dur * 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig, dur * 0.2).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func flinch(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.18))
	var dir: Vector2 = (o.get("dir", Vector2.LEFT) as Vector2).normalized()
	var dist: float = float(o.get("dist", 12.0))
	var origin: Vector2 = node.position
	var orig: Color = node.modulate
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin + dir * dist, dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", Color.WHITE, dur * 0.3)
	tween.set_parallel(false)
	tween.tween_property(node, "position", origin, dur * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", orig, dur * 0.3)
	return tween


static func damage_popup(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var text: String = str(o.get("text", "12"))
	var color: Color = o.get("color", Color.RED)
	var font_size: int = int(o.get("font_size", 20))
	var rise: float = float(o.get("rise", 50.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var label := GT_Factory.spawn_label(parent, text, color, font_size)
	label.global_position = node.global_position + Vector2(randf_range(-12.0, 12.0), -8.0)
	var tween := parent.create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - rise, dur).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, dur * 0.6).set_delay(dur * 0.4)
	tween.set_parallel(false)
	tween.tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
	)
	return tween


static func crit(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var color: Color = o.get("color", Color.YELLOW)
	var orig_color: Color = node.modulate
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", color, dur * 0.35)
	tween.tween_property(node, "modulate", orig_color, dur * 0.65)
	tween.tween_property(node, "scale", orig_scale * 1.3, dur * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.65).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_callback(func():
		damage_popup(node, {"text": str(o.get("text", "CRIT! 24")), "color": Color.YELLOW, "font_size": 26})
	)
	return tween


static func spark(node, o: Dictionary) -> Tween:
	var parent: Node = node.get_parent()
	if parent == null:
		return null
	var count: int = max(1, int(o.get("count", 10)))
	var speed: float = float(o.get("speed", 130.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var color: Color = o.get("color", Color(1.0, 0.92, 0.45))
	var host := parent.create_tween().set_parallel(true)
	for i in range(count):
		var rect := GT_Factory.spawn_rect(parent, Vector2(4, 4), color)
		rect.global_position = node.global_position
		var angle: float = randf_range(0.0, TAU)
		var target := rect.global_position + Vector2(cos(angle), sin(angle)) * speed * randf_range(0.5, 1.2)
		host.tween_property(rect, "global_position", target, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		host.tween_property(rect, "modulate:a", 0.0, dur * 0.9)
		host.tween_callback(func():
			if is_instance_valid(rect):
				rect.queue_free()
		)
	return host


static func absorb(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var color: Color = o.get("color", Color(0.5, 1.0, 1.0))
	var orig_color: Color = node.modulate
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig_scale * 0.6, dur * 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate", color, dur * 0.35)
	tween.set_parallel(false)
	tween.tween_property(node, "scale", orig_scale * 1.15, dur * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", orig_color, dur * 0.4)
	return tween


static func push(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.RIGHT) as Vector2).normalized()
	var power: float = float(o.get("power", 90.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.2))
	tween.tween_property(node, "position", node.position + dir * power, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return tween


static var _freezing := false


static func hitstop(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.09))
	var scale: float = clampf(float(o.get("freeze_scale", 0.05)), 0.001, 0.5)
	if _freezing:
		return null
	_freezing = true
	tween.tween_callback(func():
		Engine.time_scale = scale
	)
	# The interval runs in *scaled* time, so dur * scale = real `dur` seconds.
	tween.tween_interval(dur * scale)
	tween.tween_callback(func():
		Engine.time_scale = 1.0
		_freezing = false
	)
	return tween


static func graze(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var orig: Color = node.modulate
	for i in 3:
		tween.tween_property(node, "modulate", Color(1, 1, 1, 0.25), dur * 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(node, "modulate", Color.WHITE, dur * 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", orig, dur * 0.25)
	return tween


static func shield_break(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var orig_color: Color = node.modulate
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", Color(0.4, 1.0, 1.0), dur * 0.25)
	tween.tween_property(node, "modulate", orig_color, dur * 0.75)
	tween.set_parallel(false)
	tween.tween_property(node, "scale", orig_scale * Vector2(1.5, 0.5), dur * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		GT_Flash.ring(node, {"size": 40.0, "dur": 0.35, "color": Color(0.4, 1.0, 1.0)})
	)
	return tween


static func thud(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var power: float = float(o.get("power", 8.0))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig_scale * Vector2(1.35, 0.6), dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", origin + Vector2.DOWN * power, dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_property(node, "position", origin, dur * 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.45).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween
