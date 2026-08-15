# =============================================================================
#  GlobalTweens — GT_Catalog
#  The animation registry powering GlobalTweens.play(node, "category.name",
#  opts). Each category registers its animations once; the dispatcher then
#  handles validation, snapshots, anti-spam and restore automatically.
#
#  Animation def format:
#    "name": {
#        "fn": builder,            # static func(node, opts: Dictionary) -> Tween
#        "node_type": "Node2D",    # expected node class ("" = any)
#        "desc": "...",            # short description (used by docs)
#        "params": "dir:Vector2, power:float",
#        "defaults": {...},        # merged under user opts
#        "restore": bool,          # true = restore snapshot on finish
#        "spam_mode": String,      # "kill_same" | "kill_all" | "queue"
#    }
# =============================================================================

class_name GT_Catalog
extends RefCounted

## id ("category.name") -> def Dictionary
static var catalog := {}


static func register(category: String, defs: Dictionary) -> void:
	for name in defs:
		var d: Dictionary = defs[name]
		d["category"] = category
		d["name"] = name
		catalog[category + "." + name] = d


static func count() -> int:
	return catalog.size()


static func categories() -> Array:
	var set := {}
	for id in catalog.keys():
		set[id.split(".")[0]] = true
	var out := set.keys()
	out.sort()
	return out


static func names(category: String = "") -> Array:
	var out := []
	for id in catalog.keys():
		if category == "" or id.begins_with(category + "."):
			out.append(id)
	out.sort()
	return out


## Main dispatcher. Called by GlobalTweens.play().
## Returns the Tween (await-able) or null on invalid input.
static func play(node: Variant, id: String, opts: Dictionary = {}) -> Tween:
	if not GT_Safe.node_ok(node):
		return null
	var def: Dictionary = catalog.get(id, {})
	if def.is_empty():
		push_warning("GT_Catalog.play: unknown animation '%s'. Available (%d): %s" % [
			id, catalog.size(), ", ".join(names())
		])
		return null
	var node_type: String = def.get("node_type", "")
	if node_type != "" and not ClassDB.is_parent_class(node.get_class(), node_type):
		push_warning("GT_Catalog.play: '%s' expects a '%s' but got '%s' on %s." % [
			id, node_type, node.get_class(), str(node)
		])
		return null

	# Pause flag from a previous stop() is cleared: this call re-activates.
	GT_Safe.resume(node)

	# Anti-spam (before snapshotting: the killed animation restores itself).
	var spam: String = opts.get("spam_mode", def.get("spam_mode", "kill_same"))
	if spam == "kill_all":
		GT_Safe.kill(node)
	elif spam == "kill_same":
		GT_Safe.kill_kind(node, id)

	# Snapshot the CURRENT visual state before the builder mutates anything.
	GT_Safe.save_state(node)

	# Merge category defaults under the user opts.
	var merged: Dictionary = def.get("defaults", {}).duplicate()
	for k in opts:
		merged[k] = opts[k]

	var callable: Callable = def.get("fn")
	var tween: Tween = callable.call(node, merged)
	if tween == null:
		return null

	GT_Safe.track_kind(node, id, tween)

	# Restore-on-finish (skipped for kept end states and restore:false).
	var keep_end: bool = bool(opts.get("keep_end_state", false))
	var do_restore: bool = bool(opts.get("restore", def.get("restore", true)))
	if do_restore and not keep_end:
		tween.finished.connect(func():
			if keep_end:
				return
			if is_instance_valid(node):
				GT_Safe.restore(node)
		)
	return tween