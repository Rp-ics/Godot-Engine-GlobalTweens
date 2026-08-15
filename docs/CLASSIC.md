# Classic API

The original GlobalTweens toolkit — 112+ helper functions, fully backward
compatible. Call them on the `GlobalTweens` singleton. Most return the Tween
(or the last PropertyTweener) so you can `await ... .finished`.

```gdscript
GlobalTweens.pop_scale($Button, 1.3, 0.2)
GlobalTweens.float_loop($Coin, 8.0, 2.0)          # infinite by default
GlobalTweens.swing($Lantern, 12.0, 0.8)
GlobalTweens.camera_trauma($Camera2D, 0.7)
await GlobalTweens.scene_fade_change(get_tree(), "res://scenes/Game.tscn")
```

Every helper tween is tracked by the safety layer: `stop()` / `stop_all()` /
`reset()` also stop classic animations and restore the node state.

## Index

| Group | Functions |
|---|---|
| Basic visual | blink, fade, show_canvas, hide_canvas, fade_loop, color_flash, color_pulse |
| Scale / pop | pop_scale, zoom_pop, elastic_pop, squash_stretch, wobble |
| Movement / rotation | move_to, rotate_by, bounce, shake, shake_rot |
| Loops | float_loop, float_random, spin, swing, beat_pulse |
| Special FX | spawn_in, explode_and_free, quantum_jump, glitch_flash, phase_shift, energy_pulse, slide_in, slide_out, explode_frames, implode_frames |
| Scene transitions | scene_fade_change, scene_slide_change, scene_zoom_change, scene_glitch_change, scene_pixel_dissolve, scene_crossfade, scene_iris_change, scene_shatter_change, scene_color_splash_change, scene_tv_off_change, scene_page_turn_change |
| Node lifecycle | activate, deactivate, show_node, hide_node |
| UI buttons | button_hover, button_unhover, button_press, button_disable, button_enable |
| UI input | lineedit_attention, lineedit_pop, lineedit_error_feedback, lineedit_typewrite, lineedit_typewrite_placeholder |
| UI scroll | scrollbar_scroll_to |
| UI progress | texture_progress_fluid, texture_progress_pulse |
| UI wipe | wipe_vertical |
| UI radial / chain | radial_menu_open, chain_tweens, parallel_tweens |
| Text | typewriter, text_shake, label_rainbow, label_gradient_pulse |
| Particles / FX | burst_particles, trail |
| Camera | camera_shake, camera_zoom_pulse, camera_trauma, camera_lerp_to, camera_cinematic_zoom, camera_cinematic_zoom_stop, camera_recoil, camera_pan_and_return |
| Tilemap | tilemap_fade_in, tilemap_shake |
| Light | light_flicker, light_pulse |
| Exit + free | exit_fade_and_free, exit_slide_and_free, exit_spin_and_free, exit_pop_and_free |
| Epic / dynamic | epic_ground_slam, epic_energy_charge, dynamic_burst_entry, slam_down |
| General extension | rubber_band, magnetic_snap, heartbeat, heartbeat_stop, shockwave_scale, warp_entry, death_spiral, flicker_alive, flicker_alive_stop, pendulum_chain, depth_pop, cascade_fade_in, impact_freeze, orbit_around, morph_color_sequence, morph_color_sequence_stop |

## Loop conventions (classic)

Classic loop functions keep their original signatures (`infinite: bool`,
`cycles: int`, `loops: int`). For the unified `loops` convention
(-1 = infinite) use the catalog: `GlobalTweens.play(node, "generic.pulse_loop",
{"loops": -1})`.

## Stopping

```gdscript
GlobalTweens.stop($Lantern)        # kills swing + restores rotation
GlobalTweens.stop_all()            # everything, everywhere
GlobalTweens.heartbeat_stop($Icon) # dedicated per-feature stoppers exist too
```