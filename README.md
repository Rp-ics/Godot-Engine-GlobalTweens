# GlobalTweens  
**Universal Tween Toolkit for Godot 4.x**  
*One line. Infinite motion. Develop without overthinking.*

A massive collection of **69+ ready-to-use tween animations** for your Godot 4 projects.  
Bring your UI, characters, cameras, and effects to life with one-line calls — no more messing with raw tweens.
---
Version 2 is finaly here → https://github.com/Rp-ics/Godot-Engine-GlobalTweens/tree/v2
Version 2.0 is something extraordinary. Give a try, make your animation easy and fluid vith GlobalTweens V2.0
---

## 🆕 What's New in v1.5

- 🛡️ **Anti-spam protection** on 11 functions — rapid clicks won't break animations
- 🔁 **Loop control** — every loop now has `infinite` (bool) + `cycles` (int) parameters
- ✨ **New text effects** — `label_rainbow()`, `label_gradient_pulse()` (6 color palettes)
- 🎬 **New scene transitions** — `scene_zoom_change()`, `scene_glitch_change()`, `scene_pixel_dissolve()`, `scene_crossfade()`
- 🐾 **Infinite trail** — `trail()` now supports `length=0` for endless motion streaks
- 📝 **LineEdit typewriter** — `lineedit_typewrite()` and `lineedit_typewrite_placeholder()`
- 🔄 **`fade_loop()`** — ping-pong fade with loop control
- 🐛 **6 bug fixes** — `fade()` alpha jump gone, `scene_slide_change()` crash fixed, empty Tween warnings squashed

---

## Features

- 🎮 **69+ animation functions** covering UI, movement, special effects, text, particles, camera, and more
- 🚀 **AutoLoad singleton** — call any tween from anywhere in your project
- 🛡️ **Anti-spam** — functions auto-kill old tweens before starting new ones
- 🔁 **Loop control** — `infinite`/`cycles` on all repeating functions
- ⏩ **Chain & parallel tween utilities** for complex sequences
- 🧩 **Sprite explosion/implosion** effects (4×4 fragment grid)
- 🎬 **6 scene transitions** — fade, slide, zoom, glitch, pixel dissolve, crossfade
- 💡 **Light, tilemap, and progress bar tweens**
- 📜 **Typewriter text, text shake, rainbow & gradient labels**
- 📝 **LineEdit animations** — typewriter, placeholder typewriter, attention flash
- ⚡ **Camera shake & zoom pulse**
- ⏳ **Awaitable** — most functions return a `Tween` or `PropertyTweener` so you can `await` them
- 🧪 **MIT licensed** — free for any use, modify and distribute

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
GlobalTweens.label_rainbow($Title, 0.1, 0.8)
GlobalTweens.scene_glitch_change(get_tree(), "res://Game.tscn")
```

### Option 2: Local instance (if you don't want a global)

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

# Squash and stretch the ship along the Y axis (anti-spam safe!)
GlobalTweens.squash_stretch($Ship, "y", 1.4)

# Teleport an object with a quantum shrink/grow
GlobalTweens.quantum_jump($Enemy, Vector2(800, 300))

# Explode loot and free it afterwards
GlobalTweens.explode_and_free($Loot)

# Make a coin float up and down forever
GlobalTweens.float_loop($Coin, 8.0, 2.0, "y", true)

# Float exactly 3 times then stop
GlobalTweens.float_loop($Coin, 8.0, 2.0, "y", false, 3)

# Swing a lantern back and forth
GlobalTweens.swing($Lantern, 12.0, 0.5)

# Spin a rotor indefinitely at 180°/s
GlobalTweens.spin($Rotor, 180.0)

# Ping-pong fade forever
GlobalTweens.fade_loop($Sprite, 0.0, 0.4, true)

# Rainbow text on a label
GlobalTweens.label_rainbow($Title, 0.1, 0.8)

# Fire gradient pulse on a label
GlobalTweens.label_gradient_pulse($Subtitle, "fire", 1.0, true)

# Typewriter into a LineEdit
GlobalTweens.lineedit_typewrite($SearchInput, "Hello, World!", 0.04)

# Camera shake on impact
GlobalTweens.camera_shake($Camera2D, 15.0, 0.4)

# Torch light flicker
GlobalTweens.light_flicker($TorchLight, 0.3, 1.0, 0.08)

# Glitch transition to a new scene
await GlobalTweens.scene_glitch_change(get_tree(), "res://scenes/Boss.tscn", 30.0, 0.3)

# Pixel dissolve transition
await GlobalTweens.scene_pixel_dissolve(get_tree(), "res://scenes/Level2.tscn", 16, 0.6)
```

---

## Awaiting Tweens

Most functions return either a `Tween` or the last `PropertyTweener`, so you can easily wait for them to finish:

```gdscript
await GlobalTweens.pop_scale($Button, 1.3, 0.2).finished
await GlobalTweens.fade($Panel, 1.0, 0.0, 0.4).finished
await GlobalTweens.spawn_in($Enemy, 0.3).finished
await GlobalTweens.scene_zoom_change(get_tree(), "res://Game.tscn")
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
| `fade(node, from, to, dur)` | Tweens modulate alpha from current alpha to `to` |
| `fade_loop(node, to, dur, infinite, cycles)` | Ping-pong fade with loop control |
| `show_canvas(node, dur)` | Fades in to full opacity |
| `hide_canvas(node, dur)` | Fades out to full transparency |
| `color_flash(node, color, dur)` | Flashes a color then returns to original |
| `color_pulse(node, color, dur)` | Slower `color_flash` for ambient highlights |

### Scale / Pop
| Function | Description |
|----------|-------------|
| `pop_scale(node, factor, dur)` | Quick scale up and back (anti-spam) |
| `zoom_pop(node, factor, dur)` | Like `pop_scale` with higher overshoot |
| `elastic_pop(node, factor, dur)` | Springy, elastic scale pop |
| `squash_stretch(node, axis, factor, dur)` | Squashes one axis, stretches the other (anti-spam) |
| `wobble(node, factor, dur, times)` | Repeated squash & stretch (anti-spam) |

### Movement / Rotation
| Function | Description |
|----------|-------------|
| `move_to(node, target, dur)` | Moves to a target position |
| `rotate_by(node, degrees, dur, loops)` | Rotates relative to current rotation (anti-spam, loop control) |
| `bounce(node, height, dur)` | Single bounce up and back |
| `shake(node, intensity, dur)` | Procedural position shake |
| `shake_rot(node, intensity, dur)` | Procedural rotation shake |

### Loops (fire and forget)
| Function | Description |
|----------|-------------|
| `float_loop(node, amp, speed, axis, infinite, cycles)` | Oscillates position up/down or left/right (anti-spam) |
| `float_random(node, amplitude, dur)` | Wanders randomly within an area |
| `spin(node, speed, infinite, cycles)` | Spins continuously (anti-spam) |
| `swing(node, degrees, dur, infinite, cycles)` | Swings rotation left/right (anti-spam) |
| `beat_pulse(node, bpm, factor, repeats)` | Pulsing scale in sync with BPM |

### Special FX
| Function | Description |
|----------|-------------|
| `spawn_in(node, dur)` | Scale from zero + fade in |
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
| `scene_fade_change(tree, path, dur)` | Fade out → change scene → fade in |
| `scene_slide_change(tree, path, dir, dur)` | Old scene slides out, new slides in |
| `scene_zoom_change(tree, path, zoom, dur)` | Zoom out → change → zoom in |
| `scene_glitch_change(tree, path, intensity, dur)` | Jitter + white flash → change |
| `scene_pixel_dissolve(tree, path, block, dur)` | Random block dissolve |
| `scene_crossfade(tree, path, dur)` | Optimized fade to black |

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
| `lineedit_attention(line, color, dur)` | Flashes a LineEdit with a color (anti-spam) |
| `lineedit_pop(line, color, dur)` | Softer color pop for positive feedback |
| `lineedit_error_feedback(line, color, dur)` | Alias for error flash |
| `lineedit_typewrite(line, text, delay, clear)` | Types text into a LineEdit |
| `lineedit_typewrite_placeholder(line, text, delay, clear)` | Types into placeholder text |

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
| `radial_menu_open(buttons, radius, dur, open, origin, stagger)` | Spreads buttons radially from a custom origin |
| `chain_tweens(targets, props, values, durs)` | Runs tweens in lock-step arrays |
| `parallel_tweens(node, tweens_data)` | Multiple property tweens in parallel |

### Text
| Function | Description |
|----------|-------------|
| `typewriter(label, text, delay)` | Types out text character by character |
| `text_shake(label, intensity, duration, infinite)` | Horizontal position shake (anti-spam, loop control) |
| `label_rainbow(label, speed, sat, val, infinite, cycles)` | Cycles through HSV rainbow colors |
| `label_gradient_pulse(label, type, dur, infinite, cycles)` | Pulses through color palettes: warm, cool, fire, aurora, sunset, ocean |

### Particles / FX
| Function | Description |
|----------|-------------|
| `burst_particles(node, count, speed, dur, color)` | Simple ColorRect particle burst |
| `trail(node, length, interval, fade_dur)` | Ghost trail effect (length=0 for infinite, anti-spam) |

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

Feel free to open issues or PRs on the [GitHub repository](https://github.com/Rp-ics/Godot-Engine-GlobalTweens). Suggestions for new tweens or improvements are welcome!

---

**One line. Infinite motion. Develop without overthinking. 🎬✨**
---

```print("Let's make it easy")```
