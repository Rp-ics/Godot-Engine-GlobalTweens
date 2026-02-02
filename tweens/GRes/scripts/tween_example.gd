extends Node2D

var t := 0.1

func _ready() -> void:
	$Camera2D.position = $CamP1.position

func _on_reset_timeout() -> void:
	get_tree().reload_current_scene()

func _on_next_pressed() -> void: 
	var tw = create_tween()
	tw.tween_property($Camera2D, 'position', $CamP2.position, 0.2)

func _on_prev_pressed() -> void:
	var tw = create_tween()
	tw.tween_property($Camera2D, 'position', $CamP1.position, 0.2)
	
# === CHECKBUTTON === #
func _on_check_button_toggled(toggled_on: bool) -> void:
	GlobalTweens.button_press($CheckButton)

func _on_check_button_mouse_entered() -> void:
	GlobalTweens.button_hover($CheckButton)

func _on_check_button_mouse_exited() -> void:
	GlobalTweens.button_unhover($CheckButton)
# ========================================= #
# === SCROLL === #
func _on_v_scroll_bar_value_changed(value: float) -> void:
	t = value
	GlobalTweens.button_press($VScrollBar, t)
	$VScrollBar/info_count.text = str(value)
	
# ========================================= #
# === BUTTON === #
func _on_ena_mouse_entered() -> void:
	GlobalTweens.button_hover($ena)

func _on_ena_mouse_exited() -> void:
	GlobalTweens.button_unhover($ena)

func _on_dis_mouse_entered() -> void:
	GlobalTweens.button_hover($dis)

func _on_dis_mouse_exited() -> void:
	GlobalTweens.button_unhover($dis)

func _on_ena_pressed() -> void:
	GlobalTweens.button_disable($ena)
	GlobalTweens.button_enable($dis)
	GlobalTweens.button_press($ena)

func _on_dis_pressed() -> void:
	GlobalTweens.button_disable($dis)
	GlobalTweens.button_enable($ena)
	GlobalTweens.button_press($dis)
# ========================================= #
# === SCROLLBAR TWEEN FX === #
func _on_h_scroll_bar_fx_1_mouse_entered() -> void:
	GlobalTweens.scrollbar_scroll_to($HScrollBarFX1, 100, 0.6)
	
func _on_h_scroll_bar_fx_1_mouse_exited() -> void:
	GlobalTweens.scrollbar_scroll_to($HScrollBarFX1, 0, 0.6)
	
func _on_h_scroll_bar_fx_1_value_changed(value: float) -> void:
	$HScrollBarFX1/count.text = str(value)
# ========================================= #
# === LINE EDIT === #
func _on_line_edit_fx_1_text_changed(new_text: String) -> void:
	GlobalTweens.lineedit_attention($LineEditFX1, Color.SKY_BLUE, 0.6)
	
func _on_line_edit_fx_2_text_changed(new_text: String) -> void:
	GlobalTweens.lineedit_pop($LineEditFX2)
	
func _on_line_edit_fx_3_text_changed(new_text: String) -> void:
	GlobalTweens.lineedit_error_feedback($LineEditFX3)
# ========================================= #
func _on_bounce_pressed() -> void:
	GlobalTweens.button_press($imgs/Bounce)
	GlobalTweens.bounce($imgs/i1)

func _on_btn_2_pressed() -> void:
	GlobalTweens.blink($imgs/i2)

func _on_btn_3_pressed() -> void:
	GlobalTweens.color_flash($imgs/i3)

func _on_btn_4_pressed() -> void:
	GlobalTweens.color_pulse($imgs/i4)

func _on_btn_5_pressed() -> void:
	GlobalTweens.elastic_pop($imgs/i5)

func _on_btn_6_pressed() -> void:
	GlobalTweens.energy_pulse($imgs/i6)

func _on_btn_7_pressed() -> void:
	GlobalTweens.explode_and_free($imgs/i7)
	$imgs/reset.start()

func _on_btn_8_pressed() -> void:
	GlobalTweens.fade($imgs/i8, 1.0, 0.0, 0.5)
	$imgs/reset.start()

func _on_btn_9_pressed() -> void:
	GlobalTweens.fade($imgs/i9, 0.0, 1.0, 0.5)
	$imgs/reset.start()

func _on_btn_10_pressed() -> void:
	GlobalTweens.glitch_flash($imgs/i10)

func _on_btn_11_pressed() -> void:
	GlobalTweens.move_to($imgs/i11, $Marker2D.position)
	$imgs/reset.start()

func _on_btn_12_pressed() -> void:
	GlobalTweens.pop_scale($imgs/i12)

func _on_btn_13_pressed() -> void:
	GlobalTweens.quantum_jump($imgs/i13, $Marker2D.position)
	$imgs/reset.start()

func _on_btn_14_pressed() -> void:
	GlobalTweens.random_tween($imgs/i14)
	$imgs/reset.start()
	
func _on_btn_15_pressed() -> void:
	GlobalTweens.rotate($imgs/i15)

func _on_btn_16_pressed() -> void:
	GlobalTweens.shake($imgs/i16)

func _on_btn_17_pressed() -> void:
	GlobalTweens.shake_rot($imgs/i17)

func _on_btn_18_pressed() -> void:
	GlobalTweens.show_node($imgs/i18)

func _on_btn_19_pressed() -> void:
	GlobalTweens.slide_in($imgs/i19, $p1.position)

func _on_btn_20_pressed() -> void:
	GlobalTweens.slide_out($imgs/i20, $p2.position)

func _on_btn_21_pressed() -> void:
	GlobalTweens.spawn_in($imgs/i21)


func _on_btn_22_pressed() -> void:
	GlobalTweens.spin($imgs/i22)


func _on_btn_23_pressed() -> void:
	GlobalTweens.squash_stretch($imgs/i23)


func _on_btn_24_pressed() -> void:
	GlobalTweens.swing($imgs/i24)


func _on_btn_25_pressed() -> void:
	GlobalTweens.wobble($imgs/i25)


func _on_btn_26_pressed() -> void:
	GlobalTweens.explode_frames($imgs/i26)


func _on_btn_27_pressed() -> void:
	GlobalTweens.implode_frames($imgs/i27)


func _on_btn_28_pressed() -> void:
	GlobalTweens.float_random($imgs/i28)
