# GlobalTweens  
**Universal Tween Toolkit for Godot 4.x**  
*One line. Infinite motion. Develop without overthinking.*

A massive collection of **69+ ready-to-use tween animations** for your Godot 4 projects.  
Bring your UI, characters, cameras, and effects to life with one-line calls — no more messing with raw tweens.

---

## 🆕 What's New in v2.0

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
