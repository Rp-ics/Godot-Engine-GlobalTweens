# =============================================================================
#  GlobalTweens — Category: ui (generic)
#  Panels, toasts, tooltips, lists, cards, progress bars, icons...
# =============================================================================

class_name GT_UI
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"toast": {
			"fn": toast, "node_type": "Control",
			"desc": "Toast notification: slides up, fades in, holds, slides away.",
			"params": "dist:float, dur:float, hold:float",
			"defaults": {"dist": 30.0, "dur": 0.35, "hold": 1.6},
			"restore": false,
		},
		"tooltip_pop": {
			"fn": tooltip_pop, "node_type": "Control",
			"desc": "Tooltip: quick elastic pop from zero scale + fade (stays visible).",
			"params": "dur:float",
			"defaults": {"dur": 0.22},
			"restore": false,
		},
		"panel_slide": {
			"fn": panel_slide, "node_type": "Control",
			"desc": "Panel slides in from a direction with a fade (menus, settings).",
			"params": "dir:Vector2, dist:float, dur:float",
			"defaults": {"dir": Vector2.DOWN, "dist": 80.0, "dur": 0.4},
			"restore": true,
		},
		"list_stagger": {
			"fn": list_stagger, "node_type": "Control",
			"desc": "Staggered entrance for an ARRAY of nodes (opts: items).",
			"params": "items:Array, stagger:float, dur:float",
			"defaults": {"stagger": 0.07, "dur": 0.3},
			"restore": true,
		},
		"card_flip": {
			"fn": card_flip, "node_type": "Control",
			"desc": "Vertical card flip: collapses to a line, then expands back (fake flip).",
			"params": "dur:float",
			"defaults": {"dur": 0.45},
			"restore": true,
		},
		"icon_bounce": {
			"fn": icon_bounce, "node_type": "Control",
			"desc": "Notification icon bounce: hops repeatedly until stopped (loop).",
			"params": "height:float, dur:float, loops:int",
			"defaults": {"height": 10.0, "dur": 0.5, "loops": -1},
			"restore": true,
		},
		"badge_pulse": {
			"fn": badge_pulse, "node_type": "Control",
			"desc": "Gold badge pulse: scale + yellow glow, attention grabber (loop).",
			"params": "dur:float, loops:int",
			"defaults": {"dur": 0.6, "loops": -1},
			"restore": true,
		},
		"progress_flash": {
			"fn": progress_flash, "node_type": "Control",
			"desc": "Flash a progress bar tint (low-health warning, milestone reached).",
			"params": "color:Color, dur:float",
			"defaults": {"dur": 0.3},
			"restore": true,
		},
		"slider_fill": {
			"fn": slider_fill, "node_type": "Range",
			"desc": "Smoothly animate a Range value to a target (health/xp bars, sliders).",
			"params": "value:float, dur:float",
			"defaults": {"dur": 0.5},
			"restore": false,
		},
		"notification_slide": {
			"fn": notification_slide, "node_type": "Control",
			"desc": "Slide in from the right, hold, slide out (achievements).",
			"params": "dist:float, dur:float, hold:float",
			"defaults": {"dist": 120.0, "dur": 0.3, "hold": 2.0},
			"restore": false,
		},
	}


# ---------------------------------------------------------------------------
#  Builders
# ---------------------------------------------------------------------------

static func toast(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 30.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.35))
	var hold: float = max(0.0, float(o.get("hold", 1.6)))
	var origin: Vector2 = node.position
	var orig_alpha: float = node.modulate.a
	var down: Vector2 = origin + Vector2.DOWN * dist
	node.position = down
	node.modulate.a = 0.0
	tween.tween_property(node, "position", origin, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.5)
	tween.set_parallel(false)
	tween.tween_interval(hold)
	tween.set_parallel(true)
	tween.tween_property(node, "position", down, dur * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.5)
	return tween


static func tooltip_pop(node, o: Dictionary) -> Tween:
	GT_Factory.center_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.22))
	var orig_alpha: float = node.modulate.a
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur)
	return tween


static func panel_slide(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dir: Vector2 = (o.get("dir", Vector2.DOWN) as Vector2).normalized()
	var dist: float = float(o.get("dist", 80.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.4))
	var origin: Vector2 = node.position
	var orig_alpha: float = node.modulate.a
	node.position = origin + dir * dist
	node.modulate.a = 0.0
	tween.set_parallel(true)
	tween.tween_property(node, "position", origin, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.7)
	return tween


static func list_stagger(node, o: Dictionary) -> Tween:
	var items: Array = o.get("items", [])
	if items.is_empty():
		return null
	var stagger: float = max(0.0, float(o.get("stagger", 0.07)))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var tween: Tween = node.create_tween()
	for i in range(items.size()):
		var item = items[i]
		if not is_instance_valid(item) or not item is CanvasItem:
			continue
		tween.tween_interval(stagger)
		tween.tween_callback(func():
			var target = item
			var origin: Vector2 = target.position
			var orig_alpha: float = target.modulate.a
			target.modulate.a = 0.0
			target.position = origin + Vector2.DOWN * 16.0
			var t: Tween = target.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			t.set_parallel(true)
			t.tween_property(target, "position", origin, dur)
			t.tween_property(target, "modulate:a", orig_alpha, dur)
		)
	return tween


static func card_flip(node, o: Dictionary) -> Tween:
	GT_Factory.center_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.45))
	var orig: Vector2 = node.scale
	tween.tween_property(node, "scale", Vector2(orig.x, 0.001), dur * 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", orig, dur * 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(orig.x, orig.y * 1.03), dur * 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig, dur * 0.06)
	return tween


static func icon_bounce(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var height: float = float(o.get("height", 10.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	var origin: Vector2 = node.position
	tween.tween_property(node, "position:y", origin.y - height, dur * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", origin.y, dur * 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(dur * 0.35)
	return tween


static func badge_pulse(node, o: Dictionary) -> Tween:
	GT_Factory.center_pivot(node)
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.6))
	var orig_color: Color = node.modulate
	var orig: Vector2 = node.scale
	tween.set_parallel(true)
	tween.tween_property(node, "scale", orig * 1.25, dur * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", orig, dur * 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", Color(1.0, 0.85, 0.3), dur * 0.4)
	tween.tween_property(node, "modulate", orig_color, dur * 0.6)
	return tween


static func progress_flash(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var color: Color = o.get("color", Color.YELLOW)
	var orig: Color = node.modulate
	tween.tween_property(node, "modulate", color, dur * 0.5)
	tween.tween_property(node, "modulate", orig, dur * 0.5)
	return tween


static func slider_fill(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var target: float = float(o.get("value", node.max_value))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.5))
	tween.tween_property(node, "value", clampf(target, node.min_value, node.max_value), dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return tween


static func notification_slide(node, o: Dictionary) -> Tween:
	var tween := GT_Factory.build(node, o)
	if tween == null:
		return null
	var dist: float = float(o.get("dist", 120.0))
	var dur: float = GT_Factory.sanitize_dur(o.get("dur", 0.3))
	var hold: float = max(0.0, float(o.get("hold", 2.0)))
	var origin: Vector2 = node.position
	var orig_alpha: float = node.modulate.a
	var right: Vector2 = origin + Vector2.RIGHT * dist
	node.position = right
	node.modulate.a = 0.0
	tween.tween_property(node, "position", origin, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(node, "modulate:a", orig_alpha, dur * 0.5)
	tween.set_parallel(false)
	tween.tween_interval(hold)
	tween.set_parallel(true)
	tween.tween_property(node, "position", right, dur * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, dur * 0.5)
	return tween