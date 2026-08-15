# =============================================================================
#  GlobalTweens — GT_Safe
#  Safety layer: per-node state snapshots, tween tracking, anti-spam kill,
#  pause flags and automatic cleanup. This is what guarantees a node can
#  NEVER be left permanently distorted, no matter how many animations are
#  spammed, interrupted, or killed mid-way.
#
#  Error handling: every public entry point takes a Variant node and validates
#  it (null / freed / not-a-Node) instead of crashing on typed-parameter
#  binding. Set error_mode to choose the behaviour:
#    "crash"  (default) — push_error, visible in the debugger (development)
#    "warn"             — push_warning, non-fatal (transitional)
#    "ignore"           — skip invalid calls silently (production)
# =============================================================================

class_name GT_Safe
extends RefCounted

## Error handling mode for invalid calls (see class comment).
static var error_mode: String = "crash"

## Properties captured by snapshots (restored on stop()/reset()/finish).
const SNAP_PROPS: PackedStringArray = [
	"position", "scale", "rotation", "rotation_degrees",
	"modulate", "pivot_offset", "size", "offset",
	"zoom", "energy", "value", "visible", "text",
]

## node -> { snap: Dictionary, tweens: {Tween: true}, kinds: {kind: Tween} }
static var _states := {}
## node -> true (any animation-loop must stop when this is set)
static var _paused := {}


# ---------------------------------------------------------------------------
#  Validation & error reporting
# ---------------------------------------------------------------------------

static func _err(msg: String) -> void:
	match error_mode:
		"crash":
			push_error(msg)
		"warn":
			push_warning(msg)
		_:
			pass


## Guards a public entry point. Returns false (and reports per error_mode)
## when the argument is null, already freed, or not a Node.
static func node_ok(node: Variant) -> bool:
	if node == null:
		_err("GlobalTweens: node is null — call skipped.")
		return false
	if not is_instance_valid(node):
		_err("GlobalTweens: node was freed — call skipped.")
		return false
	if not node is Node:
		_err("GlobalTweens: expected a Node, got '%s' — call skipped." % str(node))
		return false
	return true


# ---------------------------------------------------------------------------
#  Entries & lifecycle
# ---------------------------------------------------------------------------

static func _entry(node: Node) -> Dictionary:
	if not _states.has(node):
		var entry := {"snap": {}, "tweens": {}, "kinds": {}}
		_states[node] = entry
		if is_instance_valid(node) and node.is_inside_tree():
			node.tree_exiting.connect(func():
				cleanup(node)
			, CONNECT_ONE_SHOT)
	return _states[node]


## Auto-cleanup when the node leaves the tree (kills tweens, drops state).
static func cleanup(node: Node) -> void:
	kill(node)
	_paused.erase(node)


# ---------------------------------------------------------------------------
#  Snapshots (anti-distortion)
# ---------------------------------------------------------------------------

## Captures the current visual state of a node (overwrites any previous snap).
static func save_state(node: Variant) -> Dictionary:
	if not node_ok(node):
		return {}
	var entry := _entry(node)
	var snap := {}
	for prop in SNAP_PROPS:
		if prop in node:
			snap[prop] = node.get(prop)
	entry["snap"] = snap
	return snap


## Restores the node to the last captured snapshot. No-op if node is gone.
static func restore(node: Variant) -> void:
	if not node_ok(node):
		_states.erase(node)
		return
	var entry: Dictionary = _states.get(node, {})
	if entry.is_empty():
		return
	var snap: Dictionary = entry.get("snap", {})
	for prop in snap:
		if prop in node:
			node.set(prop, snap[prop])


## Kills every tracked tween on the node and drops its state entry.
static func kill(node: Variant) -> void:
	if not node_ok(node):
		return
	var entry: Dictionary = _states.get(node, {})
	if entry.is_empty():
		return
	var tweens: Array = entry.get("tweens", {}).keys()
	for t in tweens:
		if is_instance_valid(t):
			t.kill()
	_states.erase(node)


# ---------------------------------------------------------------------------
#  Tracking
# ---------------------------------------------------------------------------

## Registers a tween so stop()/reset()/kill_all can find it.
static func track_tween(node: Node, tween: Variant) -> void:
	if not is_instance_valid(tween) or not tween is Tween:
		return
	var entry := _entry(node)
	entry["tweens"][tween] = true
	tween.finished.connect(func():
		untrack_tween(node, tween)
	)


static func untrack_tween(node: Node, tween: Variant) -> void:
	if not is_instance_valid(tween) or not tween is Tween:
		return
	var entry: Dictionary = _states.get(node, {})
	if entry.is_empty():
		return
	entry["tweens"].erase(tween)
	for kind in entry["kinds"].keys():
		if entry["kinds"][kind] == tween:
			entry["kinds"].erase(kind)


# ---------------------------------------------------------------------------
#  Anti-spam (one active animation per kind per node)
# ---------------------------------------------------------------------------

## Registers a tween under a "kind" (e.g. the animation id). If a previous
## tween with the same kind is still alive it is killed first.
static func track_kind(node: Node, kind: String, tween: Variant) -> void:
	if not is_instance_valid(tween) or not tween is Tween:
		return
	var entry := _entry(node)
	var prev: Tween = entry["kinds"].get(kind)
	if is_instance_valid(prev):
		prev.kill()
		entry["tweens"].erase(prev)
	entry["kinds"][kind] = tween
	track_tween(node, tween)


## Kills the active tween of the given kind (if any) and optionally restores
## the node to the snapshot that animation started from.
static func kill_kind(node: Variant, kind: String, do_restore: bool = true) -> void:
	if not node_ok(node):
		return
	var entry: Dictionary = _states.get(node, {})
	if entry.is_empty():
		return
	var prev: Tween = entry["kinds"].get(kind)
	if is_instance_valid(prev):
		prev.kill()
		entry["tweens"].erase(prev)
	entry["kinds"].erase(kind)
	if do_restore:
		restore(node)


# ---------------------------------------------------------------------------
#  Public stop / reset
# ---------------------------------------------------------------------------

## Restores the node to its snapshot and kills every tracked tween.
## Any running frame-based loop (spin, heartbeat, rainbow...) also stops,
## because GT_Safe.pause() is set and loop functions check it.
static func stop(node: Variant) -> void:
	if not node_ok(node):
		return
	restore(node)
	kill(node)
	_paused[node] = true


## Stops every tracked node in the project.
static func stop_all() -> void:
	for node in _states.keys().duplicate():
		stop(node)
	_paused.clear()


## Full reset: stop + clear the pause flag so a new animation can start.
static func reset(node: Variant) -> void:
	if not node_ok(node):
		return
	stop(node)
	_paused.erase(node)


# ---------------------------------------------------------------------------
#  Pause flags (used by frame-based loops)
# ---------------------------------------------------------------------------

static func pause(node: Variant) -> void:
	if not node_ok(node):
		return
	_paused[node] = true


static func resume(node: Variant) -> void:
	if not node_ok(node):
		return
	_paused.erase(node)


static func is_paused(node: Variant) -> bool:
	if not node_ok(node):
		return false
	return _paused.has(node)


# ---------------------------------------------------------------------------
#  Queries
# ---------------------------------------------------------------------------

## True when the node still has active tracked tweens.
static func is_animating(node: Variant) -> bool:
	if not node_ok(node):
		return false
	var entry: Dictionary = _states.get(node, {})
	if entry.is_empty():
		return false
	return not entry.get("tweens", {}).is_empty()
