# Safety

GlobalTweens guarantees that a node can **never** be left permanently
distorted, no matter how animations are spammed, interrupted or killed.

## How it works

1. **Snapshot** — before any animation (catalog or classic helper) mutates a
   node, `GT_Safe` records its visual state (`position`, `scale`, `rotation`,
   `modulate`, `pivot_offset`, `size`, `offset`, `zoom`, `energy`, `visible`).
2. **Track** — every tween created by the toolkit is registered per node.
3. **Restore** — when the animation finishes, is stopped, or is killed by
   anti-spam, the node returns to the snapshot.

```gdscript
GlobalTweens.stop($Enemy)      # restore + kill, or:
GlobalTweens.stop_all()        # restore + kill for every tracked node
GlobalTweens.reset($Enemy)     # as above + clear the pause flag
```

## Anti-spam

Each animation is registered under a "kind" (its id). Playing the same
animation again while it runs does not stack: the old tween is killed and the
node restored, then the new tween starts from the restored state. No jumps,
no accumulated deformation. Choose the policy per call with `spam_mode`:

- `kill_same` (default): only the same animation is restarted.
- `kill_all`: the new animation clears everything else on the node.
- `queue`: animations wait in line and play one after another.

## Kept end states

Some animations are *supposed* to leave the node changed (`hit.push`,
`death.*` frees the node, `environment.meteor`, ...). They are declared with
`restore: false` or require `keep_end_state: true`. Restore is skipped for
them. Everything else cleans up after itself.

## Loops and pauses

Infinite loops (`loops: -1`) run until `stop()`/`stop_all()`/`reset()`.
Classic frame-based loops (`spin`, `beat_pulse`, `label_rainbow`,
`light_flicker`, `heartbeat`, `flicker_alive`, `trail`, `camera_trauma`,
`camera_cinematic_zoom`, `morph_color_sequence`) check the pause flag every
frame and stop cleanly on `stop()`, restoring their baseline state.

## Node lifecycle

- When a tracked node leaves the tree, its tweens are killed and its state is
  dropped automatically (no leaks across scene changes).
- Calling `play()` also clears a previous `stop()` pause flag, so the same
  node can be re-animated immediately.
- Passing a **freed or null** node to the control API (`play`, `stop`,
  `stop_all`, `reset`, `is_animating`) is safe: the call is skipped instead
  of crashing with a typed-parameter error.

## Error handling (`error_mode`)

Invalid calls (null/freed nodes, non-Node arguments) are validated before
they reach any typed parameter. The developer decides what happens:

```gdscript
GlobalTweens.error_mode = "crash"   # default: push_error, visible in debugger (dev)
GlobalTweens.error_mode = "warn"    # push_warning, non-fatal
GlobalTweens.error_mode = "ignore"  # skip invalid calls silently (production)
```

- `crash` is for **development & fixing**: every invalid call is loud.
- `ignore` is for **production**: broken tweens are skipped, the game never
  crashes because of a stale node reference.
- The error is reported once per call; the call still returns a safe value
  (`null` for `play()`, `false` for `is_animating()`, nothing otherwise).

Note: animation *builders* (e.g. `GlobalTweens.spin(node, ...)`) still expect
a live node — call them only with valid nodes, and use the guarded control
API (`stop`/`reset`/`play`) in cleanup flows.

## Hitstop caution

`hit.hitstop` and `impact_freeze` temporarily change `Engine.time_scale`.
They are guarded against stacking (once at a time) and always restore it.
Avoid killing them mid-freeze; prefer `stop()` which runs after the tween
had a chance to restore, or simply let them finish (they are short).