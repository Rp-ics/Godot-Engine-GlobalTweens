# =============================================================================
#  GlobalTweens — Category: boss
#  Boss drama: intro slam, enrage, telegraphs, roars, auras, deaths.
#  Camera affects autoplay via rest — all tween-driven.
# =============================================================================

class_name GT_Boss
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"intro_slam": {
			"fn": intro_slam, "node_type": "Node2D",
			"desc": "Boss entrance: drops from above, screen-shake impact, ring shockwave.",
			"params": "height:float, shake:float, dur:float",
			"defaults": {"height": 320.0, "shake": 12.0, "dur": 0.55},
			"restore": true,
		},
		"stagger": {
			"fn": stagger, "node_type": "Node2D",
			"desc": "Staggered by a hit: heavy wobble, blue flash, small backstep.",
			"params": "dur:float",
			"defaults": {"dur": 0.6},
			"restore": true,
		},
		"enrage": {
			"fn": enrage, "node_type": "Node2D",
			"desc": "Enrage: red pulsing aura with body-vibration (loop until stopped).",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 1.0, "loops": -1},
			"restore": true,
		},
		"telegraph": {
			"fn": telegraph, "node_type": "Node2D",
			"desc": "Telegraph an attack: slow orange glow charge, then a burst flash.",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 0.9, "loops": 1},
			"restore": true,
		},
		"weakpoint": {
			"fn": weakpoint, "node_type": "Node2D",
			"desc": "Weak point revealed: yellow pulsing highlight (loop).",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 0.5, "loops": -1},
			"restore": true,
		},
		"roar": {
			"fn": roar, "node_type": "Node2D",
			"desc": "Roar: scale surge, white flash and a violent shake, then settle.",
			"params": "dur:float",
			"defaults": {"dur": 0.7},
			"restore": true,
		},
		"aura_pulse": {
			"fn": aura_pulse, "node_type": "Node2D",
			"desc": "Threatening aura: continuous pulsing with periodic ring shockwaves.",
			"params": "dur:float, ring_interval:float, loops:int",
			"defaults": {"dur": 0.7, "ring_interval": 0.7, "loops": -1},
			"restore": true,
		},
		"rush": {
			"fn": rush, "node_type": "Node2D",
			"desc": "Charge attack: dashes to a target position and dashes back.",
			"params": "target:Vector2, dur:float",
			"defaults": {"dur": 0.8},
			"restore": true,
		},
		"enter": {
			"fn": enter, "node_type": "Node2D",
			"desc": "Warp-in entrance: stretches from a horizontal line, elite arrival.",
			"params": "factor:float, dur:float",
			"defaults": {"factor": 3.0, "dur": 0.5},
			"restore": true,
		},
		"death": {
			"fn": death, "node_type": "Node2D",
			"desc": "Boss death: hitstop, white flash, ring waves, collapse and free.",
			"params": "dur:float, free_after:bool",
			"defaults": {"dur": 1.0},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func intro_slam(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 320.0))
	var shake: float = float(o.get("shake", 12.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.55))
	var dest: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	node.position = dest - Vector2.UP * height
	tween.tween_property(node, "position", dest, dur * 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 4.0, dur * 0.02).set_trans(Tween.TRANS_LINEAR)
	var rng := RandomNumberGenerator.new()
	for i in 5:
		tween.tween_property(node, "position", dest + Vector2(rng.randf_range(-shake, shake), rng.randf_range(-shake * 0.3, shake * 0.3)), dur * 0.04).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "position", dest, dur * 0.05).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 1.45, orig_scale.y * 0.55), dur * 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig_scale, dur * 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		GT_Flash.ring(node.get_parent() if node.get_parent() else node, {"size": 40.0, "dur": 0.4, "color": Color(1.0, 0.8, 0.4)})
	)
	return tween


static func stagger(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var orig_rot: float = node.rotation_degrees
	var orig_color: Color = node.modulate
	var origin: Vector2 = node.position
	tween.tween_property(node, "modulate", Color(0.5, 0.7, 1.0), dur * 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", orig_color, dur * 0.2)
	for i in 3:
		var sign: float = 1.0 if i % 2 == 0 else -1.0
		tween.tween_property(node, "rotation_degrees", orig_rot + 7.0 * sign, dur * 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig_rot, dur * 0.12).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", origin - Vector2.RIGHT * 6.0, dur * 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", origin, dur * 0.25).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func enrage(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var orig_scale: Vector2 = node.scale
	var orig_color: Color = node.modulate
	var origin: Vector2 = node.position
	var rng := RandomNumberGenerator.new()
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", Color(1.0, 0.25, 0.2), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", orig_color, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale * 1.06, dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for i in 4:
		tween.tween_property(node, "position", origin + Vector2(rng.randf_range(-3.0, 3.0), rng.randf_range(-2.0, 2.0)), dur / 8.0).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(false)
	return tween


static func telegraph(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var orig_color: Color = node.modulate
	tween.tween_property(node, "modulate", Color(1.0, 0.65, 0.2), dur * 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", Color.WHITE, dur * 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", orig_color, dur * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		GT_Flash.ring(node.get_parent() if node.get_parent() else node, {"size": 30.0, "dur": 0.35, "color": Color(1.0, 0.65, 0.2)})
	)
	return tween


static func weakpoint(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var orig_color: Color = node.modulate
	tween.tween_property(node, "modulate", Color(1.0, 0.9, 0.3), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", orig_color, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", node.scale * 1.05, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", node.scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func roar(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	var orig_scale: Vector2 = node.scale
	var orig_color: Color = node.modulate
	var origin: Vector2 = node.position
	var rng := RandomNumberGenerator.new()
	tween.tween_property(node, "scale", orig_scale * 1.35, dur * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", Color.WHITE, dur * 0.12)
	tween.tween_property(node, "modulate", orig_color, dur * 0.25)
	for i in 5:
		tween.tween_property(node, "position", origin + Vector2(rng.randf_range(-5.0, 5.0), rng.randf_range(-5.0, 5.0)), dur * 0.04).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "position", origin, dur * 0.06).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	return tween


static func aura_pulse(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	var ring_interval: float = max(0.1, float(o.get("ring_interval", 0.7)))
	var orig_scale: Vector2 = node.scale
	var orig_color: Color = node.modulate
	tween.tween_property(node, "scale", orig_scale * 1.12, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", Color(1.0, 0.6, 0.6, 0.85), dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate", orig_color, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(ring_interval)
	tween.tween_callback(func():
		GT_Flash.ring(node.get_parent() if node.get_parent() else node, {"size": 22.0, "dur": 0.5, "color": Color(1.0, 0.5, 0.4)})
	)
	tween.tween_interval(ring_interval)
	return tween


static func rush(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var target: Vector2 = o.get("target", node.position + Vector2(200, 0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var origin: Vector2 = node.position
	var orig_scale: Vector2 = node.scale
	var dir: Vector2 = (target - origin).normalized()
	var stretch: Vector2 = Vector2(orig_scale.x * 1.5, orig_scale.y * 0.8) if abs(dir.x) > abs(dir.y) else Vector2(orig_scale.x * 0.8, orig_scale.y * 1.5)
	tween.set_parallel(true)
	tween.tween_property(node, "position", target, dur * 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", stretch, dur * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(node, "position", origin, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig_scale, dur * 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func enter(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 3.0)), 1.2, 8.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var orig_scale: Vector2 = node.scale
	var orig_alpha: float = node.modulate.a
	node.scale = Vector2(orig_scale.x * factor, 0.05)
	node.modulate.a = 0.0
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig_scale, dur).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", node.rotation_degrees + 6.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func death(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var orig_scale: Vector2 = node.scale
	var origin: Vector2 = node.position
	var orig_rot: float = node.rotation_degrees
	# hitstop moment (real-time freeze)
	tween.tween_callback(func():
		Engine.time_scale = 0.05
	)
	tween.tween_interval(0.12 * 0.05)
	tween.tween_callback(func():
		Engine.time_scale = 1.0
	)
	# flash white
	tween.tween_property(node, "modulate", Color.WHITE, dur * 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# rings during collapse
	tween.tween_interval(dur * 0.15)
	tween.tween_callback(func():
		GT_Flash.ring(node.get_parent() if node.get_parent() else node, {"size": 30.0, "dur": 0.4, "color": Color.WHITE})
	)
	tween.tween_callback(func():
		GT_Flash.ring(node.get_parent() if node.get_parent() else node, {"size": 50.0, "dur": 0.5, "color": Color(1.0, 0.7, 0.4)})
	)
	# collapse
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 1.25, 0.02), dur * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.4).set_delay(dur * 0.3)
	tween.tween_property(node, "rotation_degrees", orig_rot + 2.0, dur * 0.4)
	tween.tween_property(node, "position", origin + Vector2.DOWN * 6.0, dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	if o.get("free_after", true):
		tween.tween_callback(func():
			if is_instance_valid(node):
				node.queue_free()
		)
	return tween