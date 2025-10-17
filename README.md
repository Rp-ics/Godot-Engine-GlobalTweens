# GlobalTweens

Universal Tween Toolkit for Godot 4.x | A lightweight, async, and highly flexible tween library for your game projects.
GlobalTweens simplifies node animations by providing ready-to-use functions like:

- blink, fade, show, hide

- shake, shake_rot, move_to, bounce, rotate

- pop_scale, zoom_pop, elastic_pop, color_flash, color_pulse, squash_stretch, wobble

- spawn_in, explode_and_free, quantum_jump, glitch_flash

- slide_in, slide_out, phase_shift, energy_pulse

- float_loop, move_loop, bounce_loop, swing, spin, random_tween

---
## Features

- Async & Independent: Each tween runs independently; optionally await completion for sequential control.

- Looping & Fire-and-Forget: Continuous animations (float, swing, spin, bounce) are easy to start and manage.

- Customizable Transitions/Easing: Pass strings like "sine", "back", "elastic", "quad" with "in", "out", "in_out".

- Safe & Robust: Automatically checks for valid nodes before tweening.

- AutoLoad or Class Instance: Use globally or instantiate per scene.

- Return Tween Objects: Every function returns its Tween for chaining or debugging.

## Installation

- Copy GlobalTweens.gd to your project.

- Optional: Add as AutoLoad singleton for global access:
  - Project Settings → AutoLoad → + → GlobalTweens.gd → Enable Singleton

- Start using the functions on any Node2D or CanvasItem.

# Usage Examples

## AutoLoad Singleton

## • Spawn enemy with smooth pop-in
GlobalTweens.spawn_in($Enemy)

## • Blink player 4 times and await completion
await GlobalTweens.blink($Player, 4)

## • Flash UI element red
GlobalTweens.color_flash($UI_Health, Color.RED)

## • Elastic pop on a button
GlobalTweens.elastic_pop($Button, 1.5, 0.4)

## • Floating asteroid
GlobalTweens.float_loop($Asteroid, amplitude=40, speed=3.0, axis="y")

## • Spin rotor continuously
GlobalTweens.spin($Rotor, speed=180)

## • Random movement / wobble

GlobalTweens.random_tween($Icon, pos_range=20, rot_range=30, scale_range=0.2)

## • As Class Instance
Example
    
    func _ready():
      var tweens = GlobalTweens.new()
      add_child(tweens)

      tweens.squash_stretch($Ship, "y", 1.4)
      await tweens.pop_scale($Button, 1.3, 0.2, true)

      # Sequential example
      tweens.fade($Sprite, 1.0, 0.0, 0.5)
      await get_tree().create_timer(0.5).timeout
      tweens.fade($Sprite, 0.0, 1.0, 0.5)

