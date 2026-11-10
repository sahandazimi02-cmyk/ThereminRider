## Input check screen: shows exactly what Godot receives from Max (OSC) and from
## the controller, so both players can test their side before riding.
extends Control

var _gauges: HudGauges
var _info: Label


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Palette.color("sky_top").darkened(0.55)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := UiKit.label("INPUT CHECK", 48, HORIZONTAL_ALIGNMENT_CENTER)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -400
	title.offset_right = 400
	title.offset_top = 24
	add_child(title)

	_info = UiKit.label("", 22)
	_info.position = Vector2(60, 110)
	add_child(_info)

	_gauges = HudGauges.new()
	_gauges.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gauges.offset_bottom = -90
	add_child(_gauges)

	var back := UiKit.button("Back", _on_back)
	back.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	back.offset_left = -180
	back.offset_right = 180
	back.offset_top = -80
	back.offset_bottom = -24
	# No keyboard/pad focus: A must stay free for pedal taps. Esc / Start goes back.
	back.focus_mode = Control.FOCUS_NONE
	back.text = "Back (Esc / Start)"
	add_child(back)


func _process(_delta: float) -> void:
	var t := RiderInput.tuning
	_gauges.steer = RiderInput.steer
	_gauges.steer_ok = RiderInput.hand_present
	_gauges.lean_deg = 0.0
	_info.text = """%s   (%.0f packets/s, %d total)
Last OSC message: %s %s

THEREMIN (OSC %s):  %s   value %+.3f   hand %s
STATIONARY BIKE (OSC %s / %s):  %s   %.0f RPM
CONTROLLER:  left stick %+.2f   A-tap cadence %.0f RPM

USING NOW  ->  steer %s %+.2f    pedal %s %.0f RPM
CONTROLS:  %s (F2 to change)
%s

Expected from Max:  %s f (-1..1)   %s i (0/1)   %s f (RPM)   or %s per stroke""" % [
			OscReceiver.status_text, OscReceiver.packets_per_s, OscReceiver.packets_total,
			OscReceiver.last_address, str(OscReceiver.last_args),
			t.addr_steer, "LIVE" if OscReceiver.steer_fresh() else "no signal", OscReceiver.steer,
			"IN RANGE" if OscReceiver.hand_present() else "NOT DETECTED",
			t.addr_cadence, t.addr_pedal_stroke,
			"LIVE" if (OscReceiver.cadence_fresh() or OscReceiver.strokes_fresh()) else "no signal", RiderInput.osc_cadence,
			RiderInput.pad_steer, RiderInput.pad_cadence,
			RiderInput.source_name(RiderInput.steer_source), RiderInput.steer,
			RiderInput.source_name(RiderInput.pedal_source), RiderInput.cadence_rpm,
			RiderInput.profile_name(), UiKit.input_profile_hint(),
			t.addr_steer, t.addr_steer_present, t.addr_cadence, t.addr_pedal_stroke]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause", false):
		_on_back()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
