# GlobalTweens
Universal Tween Toolkit for Godot 4.x | a lightweight, async, and highly flexible tween library for your game projects.

GlobalTweens simplifies node animations by providing ready-to-use functions like:
- **blink, fade, show, hide**
- **shake, move_to, bounce, rotate**
- **pop_scale, color_flash, squash_stretch**
- **spawn_in, explode_and_free, quantum_jump, glitch_flash**
- **slide_in, slide_out, phase_shift, energy_pulse**
- **float_loop, move_loop, bounce_loop, tween_loop**

### Features
- **Async & Independent**: Each tween runs independently; you can optionally `await` completion.
- **Looping & Fire-and-Forget**: Continuous animations are easy to start and stop.
- **Customizable Transitions/Easing**: Pass strings like `"sine"`, `"back"`, `"elastic"`, `"quad"` with `"in"`, `"out"`, `"in_out"`.
- **Safe & Robust**: Automatically checks for valid nodes before tweening.
- **AutoLoad or Class Instance**: Use globally or instantiate per scene.

### Installation
1. Copy `GlobalTweens.gd` to your project.
2. Optional: Add as AutoLoad singleton for global access.
3. Start using the functions on any Node2D/CanvasItem.

### Example
```gdscript
# AutoLoad usage
GlobalTweens.spawn_in($Enemy)
await GlobalTweens.blink($Player, 4)
GlobalTweens.color_flash($UI_Health, Color.RED)

# As instance
var tweens = GlobalTweens.new()
add_child(tweens)
tweens.squash_stretch($Ship, "y", 1.4)
