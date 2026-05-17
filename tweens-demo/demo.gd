extends Node2D

var quantim := 0
var can_follow := false

func _process(delta: float) -> void:
	if can_follow:
		$Icon1.position = get_global_mouse_position()
		if Input.is_action_just_pressed("stop"): # left, right mouse
			_on_reset_pressed()

func _on_exit_pressed() -> void:
	await GlobalTweens.scene_slide_change(get_tree(), "res://menu.tscn", Vector2.LEFT, 0.5)
	
func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()

func _on_beat_pulse_pressed() -> void:
	GlobalTweens.beat_pulse($Icon1, 120, 1.2, 5)

func _on_beat_pulse_loop_pressed() -> void:
	GlobalTweens.beat_pulse($Icon1)

func _on_blink_pressed() -> void:
	GlobalTweens.blink($Icon1)
	
func _on_bounce_pressed() -> void:
	GlobalTweens.bounce($Icon1)

func _on_color_flash_pressed() -> void:
	GlobalTweens.color_flash($Icon1)

func _on_color_pulse_pressed() -> void:
	GlobalTweens.color_pulse($Icon1)

func _on_elastic_pop_pressed() -> void:
	GlobalTweens.elastic_pop($Icon1)

func _on_glitch_flash_pressed() -> void:
	GlobalTweens.glitch_flash($Icon1)

func _on_energy_pulse_pressed() -> void:
	GlobalTweens.energy_pulse($Icon1)

func _on_explode_and_free_pressed() -> void:
	GlobalTweens.explode_and_free($Icon1)

func _on_explode_frames_pressed() -> void:
	GlobalTweens.explode_frames($Icon1)

func _on_fade_in_pressed() -> void:
	GlobalTweens.fade($Icon1, 0.0, 1.0)

func _on_fade_out_pressed() -> void:
	GlobalTweens.fade($Icon1, 1.0, 0.0)

func _on_fade_out_2_pressed() -> void:
	GlobalTweens.fade($Icon1, 1.0, 0.5)

func _on_fade_out_3_pressed() -> void:
	GlobalTweens.fade_loop($Icon1, 0.0, 0.4, true)

func _on_fade_out_4_pressed() -> void:
	GlobalTweens.fade_loop($Icon1, 0.0, 0.4, false, 5)

func _on_float_pressed() -> void:
	GlobalTweens.float_random($Icon1)

func _on_phase_shift_pressed() -> void:
	GlobalTweens.phase_shift($Icon1)

func _on_pop_scale_pressed() -> void:
	GlobalTweens.pop_scale($Icon1)

func _on_zoom_pop_pressed() -> void:
	GlobalTweens.zoom_pop($Icon1)

func _on_squash_stretch_pressed() -> void:
	GlobalTweens.squash_stretch($Icon1)

func _on_wobble_pressed() -> void:
	GlobalTweens.wobble($Icon1)

func _on_move_to_pressed() -> void:
	GlobalTweens.move_to($Icon1, $PosA.position, 0.5)

func _on_shake_pressed() -> void:
	GlobalTweens.shake($Icon1)

func _on_slide_in_pressed() -> void:
	GlobalTweens.slide_in($Icon1, $PosA.position)

func _on_slide_out_pressed() -> void:
	GlobalTweens.slide_out($Icon1, $PosA.position)

func _on_rotate_by_pressed() -> void:
	GlobalTweens.rotate_by($Icon1)

func _on_shake_rot_pressed() -> void:
	GlobalTweens.shake_rot($Icon1)

func _on_float_loop_pressed() -> void:
	GlobalTweens.float_loop($Icon1)

func _on_spin_pressed() -> void:
	GlobalTweens.spin($Icon1)

func _on_swing_pressed() -> void:
	GlobalTweens.swing($Icon1)

func _on_spawn_in_pressed() -> void:
	GlobalTweens.spawn_in($Icon1)

func _on_quantum_jump_pressed() -> void:
	if quantim == 0:
		quantim = 1
		GlobalTweens.quantum_jump($Icon1, $PosA.position)
	elif quantim == 1:
		quantim = 0
		GlobalTweens.quantum_jump($Icon1, $PosB.position)

func _on_activate_pressed() -> void:
	GlobalTweens.activate($Icon1)

func _on_deactivate_pressed() -> void:
	GlobalTweens.deactivate($Icon1)

func _on_show_node_pressed() -> void:
	GlobalTweens.show_node($Icon1)

func _on_hide_node_pressed() -> void:
	GlobalTweens.hide_node($Icon1)

func _on_explode_frames_2_pressed() -> void:
	GlobalTweens.explode_frames($Icon1)

func _on_implode_frames_pressed() -> void:
	GlobalTweens.implode_frames($Icon1)

func _on_burst_particles_pressed() -> void:
	GlobalTweens.burst_particles($Icon1)

func _on_trail_pressed() -> void:
	GlobalTweens.trail($Icon1)
	can_follow = true

func _on_trail_2_pressed() -> void:
	GlobalTweens.trail($Icon1, 0)
	can_follow = true
