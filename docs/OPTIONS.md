# Options

Every catalog animation accepts a unified options dictionary. Per-category
defaults are merged under your values (yours win), and every value is
validated before it reaches a Tween.

```gdscript
GlobalTweens.play($Node, "hit.knockback", {
	"dir": Vector2.LEFT,   # Vector2
	"power": 120.0,        # float
	"dur": 0.25,           # float: seconds, must be finite and > 0
	"delay": 0.1,          # float: seconds before starting (>= 0)
	"loops": 2,            # int: -1/0 = infinite, 1 = once, N = N times
	"trans": Tween.TRANS_CUBIC,   # int 0..11 (validated)
	"ease": Tween.EASE_OUT,       # int 0..3 (validated)
	"keep_end_state": true,       # bool: don't restore the start state
	"spam_mode": "kill_same",     # "kill_same" | "kill_all" | "queue"
})
```

## Common keys

| Key | Type | Default | Meaning |
|---|---|---|---|
| `dur` | float | per animation | Duration in seconds. Rejected if NaN/INF/<= 0. |
| `loops` | int | 1 | `-1` or `0` = infinite; `1` = once; `N` = N times. |
| `delay` | float | 0.0 | Delay before the tween starts. |
| `trans` | int | `TRANS_SINE` | Any `Tween.TRANS_*` (0..11). |
| `ease` | int | `EASE_IN_OUT` | Any `Tween.EASE_*` (0..3). |
| `keep_end_state` | bool | false | If true, the snapshot is NOT restored: the animation's end state is kept. Required for gameplay animations like `hit.push`. |
| `spam_mode` | String | `"kill_same"` | `kill_same`: re-playing the same animation restarts it. `kill_all`: any new animation kills everything else on the node. `queue`: animations queue up. |

## Per-animation keys

Every animation exposes its own keys — see [ANIMATIONS.md](ANIMATIONS.md).
They never collide with the common keys above.

## Examples

```gdscript
# Infinite float with a custom easing
GlobalTweens.play($Coin, "generic.move_loop", {
	"dir": Vector2.UP, "dist": 12.0, "dur": 0.8,
	"loops": -1, "trans": Tween.TRANS_SINE, "ease": Tween.EASE_IN_OUT,
})

# Persistent gameplay knockback (no restore at the end)
GlobalTweens.play($Enemy, "hit.push", {
	"dir": Vector2.LEFT, "dist": 64.0, "dur": 0.2,
	"keep_end_state": true,
})

# Fire three hits without fighting over the same animation
GlobalTweens.play($Boss, "hit.flash", {"spam_mode": "queue", "dur": 0.1})
```