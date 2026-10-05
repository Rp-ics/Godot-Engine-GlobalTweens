# =============================================================================
#  GlobalTweens — Category: audio
#  Audio manipulation: volume fading, pitch bends, BGM ducking, muffling.
# =============================================================================

class_name GT_Audio
extends RefCounted


static func get_defs() -> Dictionary:
	return {
		"fade_volume": {
			"fn": fade_volume, "node_type": "Node",
			"desc": "Smoothly fade audio volume in dB.",
			"params": "target_db:float, dur:float",
			"defaults": {"target_db": -80.0, "dur": 1.0},
			"restore": true,
		},
		"pitch_bend": {
			"fn": pitch_bend, "node_type": "Node",
			"desc": "Pitch scale bend effect.",
			"params": "target_pitch:float, dur:float",
			"defaults": {"target_pitch": 0.5, "dur": 0.5},
			"restore": true,
		},
		"duck": {
			"fn": duck, "node_type": "Node",
			"desc": "Temporarily duck audio volume for sound effect emphasis.",
			"params": "duck_db:float, dur:float, hold:float",
			"defaults": {"duck_db": -12.0, "dur": 0.2, "hold": 0.5},
			"restore": true,
		},
		"pulse": {
			"fn": pulse, "node_type": "Node",
			"desc": "Rhythmic volume pulse loop.",
			"params": "min_db:float, max_db:float, dur:float, loops:int",
			"defaults": {"min_db": -10.0, "max_db": 0.0, "dur": 0.8, "loops": -1},
			"restore": true,
		}
	}


static func fade_volume(node: Node, opts: Dictionary) -> Tween:
	var target_db: float = float(opts.get("target_db", -80.0))
	var dur: float = float(opts.get("dur", 1.0))
	var tween: Tween = GT_Factory.create(node, opts)
	if "volume_db" in node:
		tween.tween_property(node, "volume_db", target_db, dur).set_trans(Tween.TRANS_SINE)
	return tween


static func pitch_bend(node: Node, opts: Dictionary) -> Tween:
	var target_pitch: float = float(opts.get("target_pitch", 0.5))
	var dur: float = float(opts.get("dur", 0.5))
	var tween: Tween = GT_Factory.create(node, opts)
	if "pitch_scale" in node:
		tween.tween_property(node, "pitch_scale", target_pitch, dur).set_trans(Tween.TRANS_SINE)
	return tween


static func duck(node: Node, opts: Dictionary) -> Tween:
	var duck_db: float = float(opts.get("duck_db", -12.0))
	var dur: float = float(opts.get("dur", 0.2))
	var hold: float = float(opts.get("hold", 0.5))
	var tween: Tween = GT_Factory.create(node, opts)
	if "volume_db" in node:
		var orig_db: float = node.get("volume_db")
		tween.tween_property(node, "volume_db", orig_db + duck_db, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_interval(hold)
		tween.tween_property(node, "volume_db", orig_db, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return tween


static func pulse(node: Node, opts: Dictionary) -> Tween:
	var min_db: float = float(opts.get("min_db", -10.0))
	var max_db: float = float(opts.get("max_db", 0.0))
	var dur: float = float(opts.get("dur", 0.8))
	var loops: int = int(opts.get("loops", -1))
	var tween: Tween = GT_Factory.create(node, opts)
	if loops != 1:
		tween.set_loops(loops if loops > 0 else 0)
	if "volume_db" in node:
		tween.tween_property(node, "volume_db", min_db, dur * 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(node, "volume_db", max_db, dur * 0.5).set_trans(Tween.TRANS_SINE)
	return tween
