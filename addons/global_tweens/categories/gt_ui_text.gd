# =============================================================================
#  GlobalTweens — Category: text
#  Label juice: pop, shake, wave, glitch, scramble, reveal, rise...
# =============================================================================

class_name GT_Text
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"pop": {
			"fn": pop, "node_type": "Label",
			"desc": "Snappy pop-in: scale from zero with fade (menu titles, announcements).",
			"params": "dur:float",
			"defaults": {"dur": 0.35},
			"restore": true,
		},
		"shake": {
			"fn": shake, "node_type": "Label",
			"desc": "Horizontal shake burst (wrong answer, damage feedback).",
			"params": "intensity:float, dur:float",
			"defaults": {"intensity": 4.0, "dur": 0.3},
			"restore": true,
		},
		"bounce": {
			"fn": bounce, "node_type": "Label",
			"desc": "Drops in with a bounce and fade (dialog punch-ins).",
			"params": "height:float, dur:float",
			"defaults": {"height": 40.0, "dur": 0.5},
			"restore": true,
		},
		"wave": {
			"fn": wave, "node_type": "Label",
			"desc": "Underwater wave: gentle vertical sine bob (loop).",
			"params": "amp:float, dur:float, loops:int",
			"defaults": {"amp": 6.0, "dur": 0.8, "loops": -1},
			"restore": true,
		},
		"glitch": {
			"fn": glitch, "node_type": "Label",
			"desc": "Hacker glitch: random jitter + alpha flicker + x-stretch pops (loop).",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 0.4, "loops": -1},
			"restore": true,
		},
		"scramble": {
			"fn": scramble, "node_type": "Label",
			"desc": "Character scramble: random chars converge into the real text.",
			"params": "steps:int, step_dur:float",
			"defaults": {"steps": 10, "step_dur": 0.05},
			"restore": false,
		},
		"reveal": {
			"fn": reveal, "node_type": "Label",
			"desc": "Reveal wipe: slides in from the left while fading (clean UI reveal).",
			"params": "dist:float, dur:float",
			"defaults": {"dist": 50.0, "dur": 0.4},
			"restore": true,
		},
		"rise": {
			"fn": rise, "node_type": "Label",
			"desc": "Floats up and fades out (combat text, floating hints).",
			"params": "dist:float, dur:float",
			"defaults": {"dist": 40.0, "dur": 0.9},
			"restore": false,
		},
		"emphasis": {
			"fn": emphasis, "node_type": "Label",
			"desc": "Pulsing emphasis on an important word (loop).",
			"params": "factor:float, dur:float, loops:int",
			"defaults": {"factor": 1.12, "dur": 0.7, "loops": -1},
			"restore": true,
		},
		"sway": {
			"fn": sway, "node_type": "Label",
			"desc": "Gentle rotation sway back and forth (loop).",
			"params": "angle:float, dur:float, loops:int",
			"defaults": {"angle": 3.0, "dur": 1.2, "loops": -1},
			"restore": true,
		},
		"breathe": {
			"fn": breathe, "node_type": "Label",
			"desc": "Alpha breathing: fades softly between transparent and solid (loop).",
			"params": "min_alpha:float, dur:float, loops:int",
			"defaults": {"min_alpha": 0.55, "dur": 1.0, "loops": -1},
			"restore": true,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func pop(node, o: Dictionary) -> Tween:
	GT_Factory.center_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var orig_alpha: float = node.modulate.a
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.6)
	return tween


static func shake(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var intensity: float = float(o.get("intensity", 4.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var origin: Vector2 = node.position
	var rng := RandomNumberGenerator.new()
	for i in 5:
		tween.tween_property(node, "position", origin + Vector2(rng.randf_range(-intensity, intensity), 0.0), dur / 6.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin, dur / 6.0).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	return tween


static func bounce(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 40.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var origin: Vector2 = node.position
	var orig_alpha: float = node.modulate.a
	node.position = origin - Vector2.UP * height
	node.modulate.a = 0.0
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", origin, dur).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return tween


static func wave(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var amp: float = float(o.get("amp", 6.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.8))
	var origin: Vector2 = node.position
	tween.tween_property(node, "position", origin - Vector2.UP * amp, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", origin, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func glitch(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var origin: Vector2 = node.position
	var orig_alpha: float = node.modulate.a
	var orig_scale: Vector2 = node.scale
	var rng := RandomNumberGenerator.new()
	for i in 8:
		var jx: float = rng.randf_range(-3.0, 3.0)
		var alpha: float = orig_alpha * (1.0 if rng.randf() > 0.35 else 0.15)
		tween.tween_property(node, "position", origin + Vector2(jx, 0.0), dur * 0.07).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(node, "modulate:a", alpha, dur * 0.04).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "position", origin, dur * 0.06).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.05)
	tween.tween_property(node, "scale", Vector2(orig_scale.x * 1.08, orig_scale.y), dur * 0.03).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "scale", orig_scale, dur * 0.04).set_trans(Tween.TRANS_LINEAR)
	return tween


static func scramble(node, o: Dictionary) -> Tween:
	if node == null or not is_instance_valid(node):
		return null
	var steps: int = max(2, int(o.get("steps", 10)))
	var step_dur: float = max(0.01, float(o.get("step_dur", 0.05)))
	var text: String = node.text
	var tween_host: Tween = node.create_tween()
	const CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#@$%&"
	for i in range(steps):
		tween_host.tween_callback(func():
			if not is_instance_valid(node):
				return
			var progress := float(i) / steps
			var visible: int = int(text.length() * progress)
			var out := ""
			for c in range(text.length()):
				if c < visible:
					out += text[c]
				else:
					out += CHARS[randi() % CHARS.length()]
			node.text = out
		)
		tween_host.tween_interval(step_dur)
	tween_host.tween_callback(func():
		if is_instance_valid(node):
			node.text = text
	)
	return tween_host


static func reveal(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 50.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var origin: Vector2 = node.position
	var orig_alpha: float = node.modulate.a
	node.position = origin - Vector2.RIGHT * dist
	node.modulate.a = 0.0
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.7)
	return tween


static func rise(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 40.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.9))
	var origin: Vector2 = node.position
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin - Vector2.UP * dist, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


static func emphasis(node, o: Dictionary) -> Tween:
	GT_Factory.center_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var factor: float = clampf(float(o.get("factor", 1.12)), 1.02, 2.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.7))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", orig * factor, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", orig, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func sway(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var angle: float = float(o.get("angle", 3.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.2))
	var orig: float = node.rotation_degrees
	tween.tween_property(node, "rotation_degrees", orig + angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", orig - angle, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func breathe(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var min_alpha: float = clampf(float(o.get("min_alpha", 0.55)), 0.0, 1.0)
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 1.0))
	var orig_alpha: float = node.modulate.a
	tween.tween_property(node, "modulate:a", min_alpha, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween