## Autoload "RiderInput": the one place the game reads controls from.
## Merges theremin/bike OSC (from Max) with the controller/keyboard fallback.
##   steer        -1..1  (-1 full left, +1 full right)
##   cadence_rpm  crank RPM from the pedal player
## Which device drives which channel comes from the control profile
## (GameSession.input_profile, picked in the main menu or with F2):
##   CONTROLLER           steer = stick / keys     pedal = A / Space taps
##   THEREMIN_BIKE        steer = theremin (OSC)   pedal = stationary bike (OSC)
##   THEREMIN_CONTROLLER  steer = theremin (OSC)   pedal = A / Space taps
## A channel set to OSC never falls back to the pad: no Max signal = NONE.
extends Node

enum Source { PAD, OSC, NONE }

var tuning: InputTuning

var steer := 0.0
var cadence_rpm := 0.0
var steer_source: Source = Source.PAD
var pedal_source: Source = Source.PAD
## False when the theremin is the steering source but the hand is out of range.
var hand_present := true

## Tests set these to drive the bike without hardware.
var override_enabled := false
var override_steer := 0.0
var override_cadence := 0.0

var pad_steer := 0.0
var pad_cadence := 0.0
var osc_steer := 0.0
var osc_cadence := 0.0

var _pad_strokes := StrokeCadence.new()
var _osc_strokes := StrokeCadence.new()
var _cadence_raw := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	tuning = InputTuning.load_default()
	_pad_strokes.configure(tuning)
	_osc_strokes.configure(tuning)
	_ensure_actions()
	OscReceiver.pedal_stroke.connect(_on_osc_stroke)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pedal", false):
		_pad_strokes.add_stroke(_now())
	elif event.is_action_pressed("cycle_input_mode", false):
		GameSession.cycle_input_profile()


func _process(delta: float) -> void:
	var now := _now()
	pad_steer = Input.get_axis("steer_left", "steer_right")
	pad_cadence = _pad_strokes.rpm(now)

	# --- steering ---
	var use_osc_steer := steer_uses_theremin()
	var target := pad_steer
	hand_present = true
	if use_osc_steer:
		steer_source = Source.OSC if OscReceiver.steer_fresh() else Source.NONE
		hand_present = steer_source == Source.OSC and OscReceiver.hand_present()
		var raw := OscReceiver.steer * tuning.osc_steer_gain
		if tuning.osc_steer_invert:
			raw = -raw
		raw = clampf(raw, -1.0, 1.0)
		if absf(raw) < tuning.osc_steer_deadzone:
			raw = 0.0
		else:
			raw = signf(raw) * inverse_lerp(tuning.osc_steer_deadzone, 1.0, absf(raw))
		osc_steer = _smooth(osc_steer, raw, tuning.osc_steer_smoothing_s, delta)
		if hand_present:
			target = osc_steer
		else:
			target = _smooth(steer, 0.0, tuning.steer_absent_return_s, delta)
	else:
		steer_source = Source.PAD

	# --- pedalling ---
	var osc_value := 0.0
	var osc_live := OscReceiver.cadence_fresh() or OscReceiver.strokes_fresh()
	if OscReceiver.cadence_fresh():
		osc_value = OscReceiver.cadence_rpm * tuning.osc_cadence_gain
	elif OscReceiver.strokes_fresh():
		osc_value = _osc_strokes.rpm(now) * tuning.osc_cadence_gain
	osc_cadence = osc_value
	var use_osc_pedal := pedal_uses_bike()
	var cadence_target := pad_cadence
	if use_osc_pedal:
		pedal_source = Source.OSC if osc_live else Source.NONE
		cadence_target = osc_value
	else:
		pedal_source = Source.PAD

	if override_enabled:
		target = override_steer
		cadence_target = override_cadence
		hand_present = true

	steer = clampf(target, -1.0, 1.0)
	_cadence_raw = maxf(0.0, cadence_target)
	cadence_rpm = _smooth(cadence_rpm, _cadence_raw, tuning.cadence_smoothing_s, delta)
	if _cadence_raw <= 0.0 and cadence_rpm < 1.0:
		cadence_rpm = 0.0


func profile_name() -> String:
	return GameSession.input_profile_name()


## True when the active profile steers with the theremin (OSC).
func steer_uses_theremin() -> bool:
	return GameSession.input_profile != GameSession.InputProfile.CONTROLLER


## True when the active profile pedals with the stationary bike (OSC).
func pedal_uses_bike() -> bool:
	return GameSession.input_profile == GameSession.InputProfile.THEREMIN_BIKE


static func source_name(s: Source) -> String:
	match s:
		Source.OSC:
			return "OSC"
		Source.PAD:
			return "PAD"
	return "NONE"


func _on_osc_stroke() -> void:
	_osc_strokes.add_stroke(_now())


func _now() -> float:
	return Time.get_ticks_usec() / 1_000_000.0


func _smooth(current: float, target: float, time_s: float, delta: float) -> float:
	if time_s <= 0.0:
		return target
	return lerpf(current, target, 1.0 - exp(-delta / time_s))


## Default bindings. Added only if the action isn't already in Project Settings,
## so you can rebind them in the editor's Input Map.
func _ensure_actions() -> void:
	_action("steer_left", 0.15, [_key(KEY_A), _key(KEY_LEFT), _axis(JOY_AXIS_LEFT_X, -1.0)])
	_action("steer_right", 0.15, [_key(KEY_D), _key(KEY_RIGHT), _axis(JOY_AXIS_LEFT_X, 1.0)])
	_action("pedal", 0.5, [_key(KEY_SPACE), _key(KEY_W), _key(KEY_UP), _button(JOY_BUTTON_A)])
	_action("toggle_camera", 0.5, [_key(KEY_C), _button(JOY_BUTTON_Y)])
	_action("pause", 0.5, [_key(KEY_ESCAPE), _button(JOY_BUTTON_START)])
	_action("debug_reset", 0.5, [_key(KEY_R), _button(JOY_BUTTON_BACK)])
	_action("toggle_debug", 0.5, [_key(KEY_F1)])
	_action("cycle_input_mode", 0.5, [_key(KEY_F2)])


func _action(action_name: StringName, deadzone: float, events: Array[InputEvent]) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name, deadzone)
	for e in events:
		InputMap.action_add_event(action_name, e)


func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return e


func _button(b: JoyButton) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = b
	return e


func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = axis
	e.axis_value = value
	return e
