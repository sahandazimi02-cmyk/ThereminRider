## Title screen: pick a mode, assist level and camera; shows live input status
## so you can see Max/OSC is connected before riding.
extends Control

var _assist_btn: Button
var _camera_btn: Button
var _status: Label
var _best: Label


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Palette.color("sky_top").darkened(0.45)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := UiKit.centered()
	add_child(center)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	center.add_child(col)

	col.add_child(UiKit.label("THEREMIN RIDER", 72, HORIZONTAL_ALIGNMENT_CENTER))
	col.add_child(UiKit.label("Player 1 steers and balances with the theremin.  Player 2 pedals.", 22, HORIZONTAL_ALIGNMENT_CENTER))
	col.add_child(_spacer(10))

	var endless := UiKit.button("Endless ride", _on_endless)
	col.add_child(endless)
	col.add_child(UiKit.button("Course", _on_course))
	col.add_child(UiKit.button("Input check", _on_input_check))
	_assist_btn = UiKit.button("", _on_assist)
	col.add_child(_assist_btn)
	_camera_btn = UiKit.button("", _on_camera)
	col.add_child(_camera_btn)
	col.add_child(UiKit.button("Quit", _on_quit))
	for c in col.get_children():
		if c is Button:
			(c as Button).size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	col.add_child(_spacer(10))
	_best = UiKit.label("", 20, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_best)
	_status = UiKit.label("", 18, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_status)

	_refresh_buttons()
	endless.grab_focus()


func _process(_delta: float) -> void:
	var steer := RiderInput.source_name(RiderInput.steer_source)
	var pedal := RiderInput.source_name(RiderInput.pedal_source)
	_status.text = "%s\nSteer: %s (%+.2f)    Pedal: %s (%d RPM)    Input mode: %s (F2)" % [
			OscReceiver.status_text, steer, RiderInput.steer, pedal,
			int(RiderInput.cadence_rpm), RiderInput.mode_name()]
	var course_best := UiKit.format_time(GameSession.best_course_s) if GameSession.best_course_s > 0.0 else "--"
	_best.text = "Best endless streak %d m     Best course %s" % [int(GameSession.best_endless_m), course_best]


func _spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _refresh_buttons() -> void:
	_assist_btn.text = "Balance assist: %s" % GameSession.assist_name()
	_camera_btn.text = "Camera: %s" % ("1st person" if GameSession.first_person else "3rd person")


func _on_endless() -> void:
	GameSession.mode = GameSession.Mode.ENDLESS
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_course() -> void:
	GameSession.mode = GameSession.Mode.COURSE
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_input_check() -> void:
	get_tree().change_scene_to_file("res://scenes/input_check.tscn")


func _on_assist() -> void:
	GameSession.assist = ((int(GameSession.assist) + 1) % 3) as GameSession.Assist
	GameSession.save()
	_refresh_buttons()


func _on_camera() -> void:
	GameSession.first_person = not GameSession.first_person
	GameSession.save()
	_refresh_buttons()


func _on_quit() -> void:
	get_tree().quit()
