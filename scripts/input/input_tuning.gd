## OSC + controller input settings. Saved as res://data/input_tuning.tres.
class_name InputTuning
extends Resource

const PATH := "res://data/input_tuning.tres"

@export_group("OSC network")
## UDP port Max's [udpsend] targets.
@export_range(1024, 65535, 1) var osc_port: int = 9100
## "*" = listen on every network card (Max on another computer works).
## "127.0.0.1" = this PC only.
@export var osc_bind_address: String = "*"
## A channel counts as connected if a message arrived within this time.
@export_range(0.1, 5.0, 0.05) var osc_timeout_s: float = 0.75

@export_group("OSC addresses")
## Float -1..1: -1 full left, 0 straight, +1 full right.
@export var addr_steer: String = "/bike/steer"
## Int/float 0 or 1: is the steering hand in the theremin's range?
@export var addr_steer_present: String = "/bike/steer/present"
## Float: crank RPM from the stationary bike.
@export var addr_cadence: String = "/bike/cadence"
## Any message = one pedal stroke (alternative to sending RPM).
@export var addr_pedal_stroke: String = "/bike/pedal"

@export_group("Theremin steering (OSC)")
@export var osc_steer_invert: bool = false
## Multiplies the incoming value before clamping to -1..1.
@export_range(0.2, 3.0, 0.01) var osc_steer_gain: float = 1.0
## Values this close to 0 count as straight.
@export_range(0.0, 0.3, 0.005) var osc_steer_deadzone: float = 0.06
## Extra smoothing in Godot on top of Max's [slide] (seconds).
@export_range(0.0, 0.5, 0.005) var osc_steer_smoothing_s: float = 0.15
## When the hand leaves the theremin, steering eases to straight this fast.
@export_range(0.05, 2.0, 0.01) var steer_absent_return_s: float = 0.35

@export_group("Pedalling")
## A pedal stroke is half a crank turn (two strokes per revolution).
@export_range(1.0, 4.0, 1.0) var strokes_per_rev: float = 2.0
## How many recent strokes are averaged into the cadence.
@export_range(1, 10, 1) var stroke_average_count: int = 4
## No stroke for this long = cadence 0.
@export_range(0.3, 4.0, 0.05) var stroke_timeout_s: float = 1.2
## Smoothing on the final cadence value (seconds).
@export_range(0.0, 2.0, 0.01) var cadence_smoothing_s: float = 0.25
## OSC cadence values are multiplied by this (handy if a sensor reads 2x).
@export_range(0.1, 4.0, 0.01) var osc_cadence_gain: float = 1.0


static func load_default() -> InputTuning:
	if ResourceLoader.exists(PATH):
		var res := load(PATH) as InputTuning
		if res != null:
			return res
	return InputTuning.new()
