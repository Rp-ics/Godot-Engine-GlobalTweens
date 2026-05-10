# GlobalTweens  
**Universal Tween Toolkit for Godot 4.x**  
*by Rpx – MIT License*

A massive collection of ready-to-use tween animations for your Godot 4 projects.  
Bring your UI, characters, cameras, and effects to life with one-line calls – no more messing with raw tweens.

---

## Features

- 🎮 **60+ animation functions** covering UI, movement, special effects, text, particles, camera, and more
- 🚀 **AutoLoad singleton** – call any tween from anywhere in your project
- 🔁 **Looping helpers** (float, spin, swing, beat pulse) that run until the node is freed
- ⏩ **Chain & parallel tween utilities** for complex sequences
- 🧩 **Sprite explosion/implosion** effects (4×4 fragment grid)
- 🎬 **Scene transitions** with fade or slide
- 💡 **Light, tilemap, and progress bar tweens**
- 📜 **Typewriter text & text shake**
- ⚡ **Camera shake & zoom pulse**
- ⏳ **Awaitable** – most functions return a `Tween` or `PropertyTweener` so you can `await` them
- 🧪 **MIT licensed** – free for any use, modify and distribute

---

## Installation

### Option 1: AutoLoad Singleton (recommended)

1. Copy `GlobalTweens.gd` into your project (e.g., `res://addons/global_tweens/`).
2. Go to **Project Settings → AutoLoad**.
3. Add `GlobalTweens.gd` as a singleton (name `GlobalTweens`).
4. Enable the singleton.

Now you can call any function from anywhere:
```gdscript
GlobalTweens.spawn_in($Enemy)
GlobalTweens.blink($Player, 4)
GlobalTweens.elastic_pop($Button, 1.5, 0.3)
```

### Option 2: Local instance (if you don’t want a global)

```gdscript
func _ready():
    var gt = GlobalTweens.new()
    add_child(gt)
    gt.spawn_in($Enemy)
    gt.color_flash($Health, Color.RED)
```

**Note:** Looping functions (`float_loop`, `spin`, `light_flicker` etc.) require the node to stay alive, so either attach the instance to a persistent node or rely on the singleton.

---

## Quick Examples

```gdscript
# Spawn an enemy – scale from zero and fade in
GlobalTweens.spawn_in($Enemy)

# Blink the player 4 times quickly
GlobalTweens.blink($Player, 4, 0.1)

# Flash a red warning on the health bar
GlobalTweens.color_flash($Health, Color.RED)

# Squash and stretch the ship along the Y axis
GlobalTweens.squash_stretch($Ship, "y", 1.4)

# Teleport an object with a quantum shrink/grow
GlobalTweens.quantum_jump($Enemy, Vector2(800, 300))

# Explode loot and free it afterwards
GlobalTweens.explode_and_free($Loot)

# Make a coin float up and down forever
GlobalTweens.float_loop($Coin, 8.0, 2.0)

# Swing a lantern back and forth
GlobalTweens.swing($Lantern, 12.0, 0.8)

# Zoom‑pop a button when it appears
GlobalTweens.zoom_pop($Button, 1.3, 0.2)

# Spin a rotor indefinitely at 180°/s
GlobalTweens.spin($Rotor, 180.0)

# Fade to black and change scene
await GlobalTweens.scene_fade_change(get_tree(), "res://scenes/Game.tscn")
```

---

## Awaiting Tweens

Most functions return either a `Tween` or the last `PropertyTweener`, so you can easily wait for them to finish:

```gdscript
await GlobalTweens.pop_scale($Button, 1.3, 0.2).finished
await GlobalTweens.fade($Panel, 1.0, 0.0, 0.4).finished
await GlobalTweens.spawn_in($Enemy, 0.3).finished
```

---

## Easing Quick Reference

All tweens use **`TRANS_SINE`** and **`EASE_IN_OUT`** by default unless overridden.  
You can modify any tween returned by the toolkit with the standard Godot `set_trans()` and `set_ease()` methods.

**Transition types:**  
`TRANS_LINEAR`, `TRANS_SINE`, `TRANS_BACK`, `TRANS_ELASTIC`,  
`TRANS_BOUNCE`, `TRANS_QUAD`, `TRANS_CUBIC`, `TRANS_EXPO`, `TRANS_SPRING`

**Ease types:**  
`EASE_IN`, `EASE_OUT`, `EASE_IN_OUT`, `EASE_OUT_IN`

---

## Function Catalog

### Basic Visual
| Function | Description |
|----------|-------------|
| `blink(node, times, speed)` | Blinks alpha between 0.2 and 1.0 |
| `fade(node, from, to, dur)` | Tweens modulate alpha |
| `show_canvas(node, dur)` | Fades in to full opacity |
| `hide_canvas(node, dur)` | Fades out to full transparency |
| `color_flash(node, color, dur)` | Flashes a color then returns to original |
| `color_pulse(node, color, dur)` | Slower `color_flash` for ambient highlights |

### Scale / Pop
| Function | Description |
|----------|-------------|
| `pop_scale(node, factor, dur)` | Quick scale up and back (button feedback) |
| `zoom_pop(node, factor, dur)` | Like `pop_scale` with higher overshoot (UI popup) |
| `elastic_pop(node, factor, dur)` | Springy, elastic scale pop |
| `squash_stretch(node, axis, factor, dur)` | Squashes along one axis, stretches the other |
| `wobble(node, factor, dur, times)` | Repeated squash & stretch |

### Movement / Rotation
| Function | Description |
|----------|-------------|
| `move_to(node, target, dur)` | Moves to a target position |
| `rotate_by(node, degrees, dur)` | Rotates relative to current rotation |
| `bounce(node, height, dur)` | Single bounce up and back |
| `shake(node, intensity, dur)` | Procedural position shake (no tween) |
| `shake_rot(node, intensity, dur)` | Procedural rotation shake |

### Loops (fire and forget)
| Function | Description |
|----------|-------------|
| `float_loop(node, amplitude, speed, axis)` | Oscillates position up/down (or left/right) |
| `float_random(node, amplitude, dur)` | Wanders randomly within an area |
| `spin(node, speed)` | Spins continuously |
| `swing(node, degrees, dur)` | Swings rotation left/right (pendulum) |
| `beat_pulse(node, bpm, factor)` | Pulsing scale in sync with BPM |

### Special FX
| Function | Description |
|----------|-------------|
| `spawn_in(node, dur)` | Scale from zero + fade in (classic entry) |
| `explode_and_free(node, dur)` | Scale up + fade out, then `queue_free()` |
| `quantum_jump(node, new_pos, dur)` | Shrink, teleport, grow back |
| `glitch_flash(node, intensity, dur)` | Random position jitter |
| `phase_shift(node, times, speed)` | Alpha flicker (ghost, shield) |
| `energy_pulse(node, color, dur)` | Cyan/teal color flash |
| `slide_in(node, from_dir, dist, dur)` | Slides in from a direction |
| `slide_out(node, to_dir, dist, dur)` | Slides out toward a direction |
| `explode_frames(node, dur, scale, spread, shader)` | 4×4 sprite explosion |
| `implode_frames(node, dur, scale, spread, shader)` | Reverse of explosion |

### Scene Transitions
| Function | Description |
|----------|-------------|
| `scene_fade_change(tree, scene_path, dur)` | Fade out → change scene → fade in |
| `scene_slide_change(tree, scene_path, dir, dur)` | Old scene slides out, new scene slides in |

### UI – Buttons
| Function | Description |
|----------|-------------|
| `button_hover(btn, scale, dur)` | Scale up on mouse enter |
| `button_unhover(btn, dur)` | Return to normal scale |
| `button_press(btn, dur)` | Quick squish on click |
| `button_disable(btn, dur)` | Fade + shrink + disable |
| `button_enable(btn, dur)` | Fade + grow + enable |

### UI – Input
| Function | Description |
|----------|-------------|
| `lineedit_attention(line, color, dur)` | Flashes a LineEdit with a color (error) |
| `lineedit_pop(line, color, dur)` | Softer color pop (success) |
| `lineedit_error_feedback(line, color, dur)` | Alias for error flash |

### UI – Scroll / Progress
| Function | Description |
|----------|-------------|
| `scrollbar_scroll_to(scroll, value, dur)` | Smooth scroll to value |
| `texture_progress_fluid(progress, target, dur)` | Animate progress bar value |
| `texture_progress_pulse(progress, color, dur)` | Flash tint color of progress |

### UI – Wipe / Reveal
| Function | Description |
|----------|-------------|
| `wipe_vertical(node, open, dur)` | Vertical curtain reveal/hide |

### UI – Radial / Chain
| Function | Description |
|----------|-------------|
| `radial_menu_open(buttons, radius, dur, open)` | Spreads buttons radially |
| `chain_tweens(targets, props, values, durs)` | Runs tweens in lock-step arrays |
| `parallel_tweens(node, tweens_data)` | Multiple property tweens in parallel |

### Text
| Function | Description |
|----------|-------------|
| `typewriter(label, text, delay)` | Types out text character by character |
| `text_shake(label, intensity, duration)` | Horizontal position shake on labels |

### Particles / FX
| Function | Description |
|----------|-------------|
| `burst_particles(node, count, speed, dur, color)` | Simple ColorRect particle burst |
| `trail(node, length, interval, fade_dur)` | Ghost trail effect using duplicates |

### Camera
| Function | Description |
|----------|-------------|
| `camera_shake(camera, intensity, duration)` | Procedural camera shake |
| `camera_zoom_pulse(camera, target_zoom, duration)` | Zoom in and out pulse |

### Tilemap
| Function | Description |
|----------|-------------|
| `tilemap_fade_in(tilemap, duration)` | Fades in the entire tilemap |
| `tilemap_shake(tilemap, intensity, duration)` | Shakes tilemap position (earthquake) |

### Light
| Function | Description |
|----------|-------------|
| `light_flicker(light, min, max, speed)` | Random energy flicker (torch, candle) |
| `light_pulse(light, target_energy, duration)` | Single energy pulse |

### Node Lifecycle
| Function | Description |
|----------|-------------|
| `activate(node)` | Enables collision + pops scale |
| `deactivate(node)` | Disables collision + fades alpha |
| `show_node(node, smooth, duration)` | Show with optional fade-in |
| `hide_node(node, smooth, duration)` | Hide with optional fade-out |

---

## Internal Helpers

- `_is_valid(n)` – checks `is_instance_valid`
- `_new_tween(target)` – creates a tween with default **TRANS_SINE / EASE_IN_OUT**

All public functions use `_new_tween` for consistent default easing.

---

## License

MIT – Free to use, modify, and distribute in any project (commercial or personal). No attribution required but always appreciated.

---

## Contributing

Feel free to open issues or PRs on the repository. Suggestions for new tweens or improvements are welcome!

---

**Enjoy crafting juicy animations with zero boilerplate! 🎬✨**
