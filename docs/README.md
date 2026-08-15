# GlobalTweens

Universal Tween Toolkit for Godot 4.x — **264 animations** in one plugin:
~153 curated **catalog** animations (with automatic safety + anti-spam) plus the
original **112+ classic helper** functions, all backward compatible.

![Demo](examples/demo_scene.tscn)

## Features

- **Catalog mode** — `GlobalTweens.play(node, "category.name", opts)`:
  16 categories (hit, jump, death, squish, slime, player, boss, ui_buttons,
  ui_text, ui_generic, environment, fog, flash, camera, fx, generic).
- **Classic mode** — the original toolkit: `pop_scale`, `shake`, `float_loop`,
  `beat_pulse`, `scene_fade_change`, `camera_trauma`, `explode_frames`, ... all
  112+ functions unchanged.
- **Safety layer** (`GT_Safe`): every animation snapshots the node state
  before running and restores it when finished, stopped or killed. A node can
  **never** be left permanently distorted, even after spamming animations.
- **Anti-spam**: one active animation per kind per node; new plays kill old
  ones and restore their start state.
- **Unified options**: `dur`, `loops`, `delay`, `trans`, `ease` work the same
  way across every animation.
- **Interactive demo scene** included — press any button, see the animation.

## Installation

1. Copy the `addons/global_tweens/` folder into your project.
2. Enable the plugin: `Project > Project Settings > Plugins > enable GlobalTweens`.
   (This registers the `GlobalTweens` autoload singleton automatically.)
3. Done. The global `GlobalTweens` singleton is available everywhere.

## Quick start

```gdscript
# Catalog mode (recommended)
GlobalTweens.play($Enemy, "hit.knockback", {"dir": Vector2.LEFT, "power": 120.0})
GlobalTweens.play($Player, "player.dash", {"dur": 0.25})
GlobalTweens.play($TitleLabel, "ui_text.emphasis", {"scale": 1.3})
GlobalTweens.play($Camera2D, "camera.zoom_kick", {"target": 1.2})

# Await a tween
await GlobalTweens.play($Enemy, "jump.arc", {"height": 80.0}).finished

# Classic helpers (fully backward compatible)
GlobalTweens.pop_scale($Button, 1.3, 0.2)
GlobalTweens.float_loop($Coin, 8.0, 2.0)
GlobalTweens.color_flash($Player, Color.RED)
await GlobalTweens.scene_fade_change(get_tree(), "res://scenes/Game.tscn")
```

## Stopping animations

```gdscript
GlobalTweens.stop($Enemy)        # kill all tweens on the node + restore state
GlobalTweens.stop_all()          # stop everything in the project
GlobalTweens.reset($Enemy)       # stop + clear pause (fresh start)
GlobalTweens.is_animating($Enemy) # true while the node has running animations
```

## Error handling

Calls with null/freed nodes never crash — they are skipped. Choose the
behaviour in code:

```gdscript
GlobalTweens.error_mode = "crash"   # default: loud errors (development)
GlobalTweens.error_mode = "warn"    # warnings, non-fatal
GlobalTweens.error_mode = "ignore"  # skip silently (production)
```

## Documentation

| File | Contents |
|---|---|
| [docs/ANIMATIONS.md](docs/ANIMATIONS.md) | Full catalog list: 153 animations with parameters |
| [docs/OPTIONS.md](docs/OPTIONS.md) | The unified options dictionary explained |
| [docs/SAFETY.md](docs/SAFETY.md) | Snapshot/restore, anti-spam and pause semantics |
| [docs/CLASSIC.md](docs/CLASSIC.md) | The classic helper API (index and usage) |

## License

MIT — free to use, modify, and distribute.