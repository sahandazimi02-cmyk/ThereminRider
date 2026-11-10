## Autoload "OscReceiver": listens for OSC from Max on UDP and keeps the latest
## steering / pedalling values. See docs/OSC_PROTOCOL.md for the message list.
extends Node

signal pedal_stroke
signal message(address: String, args: Array)

var tuning: InputTuning
var bound := false
var status_text := "Not started."

var steer := 0.0
var steer_present := true
var cadence_rpm := 0.0
var packets_total := 0
var packets_per_s := 0.0
var last_address := ""
var last_args: Array = []

var _udp: PacketPeerUDP
var _steer_ms := -1
var _present_ms := -1
var _cadence_ms := -1
var _stroke_ms := -1
var _any_ms := -1
var _rate_count := 0
var _rate_t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	tuning = InputTuning.load_default()
	rebind()


func rebind() -> void:
	if _udp != null:
		_udp.close()
	_udp = PacketPeerUDP.new()
	var err := _udp.bind(tuning.osc_port, tuning.osc_bind_address)
	bound = err == OK
	if bound:
		status_text = "Listening on UDP %s:%d" % [tuning.osc_bind_address, tuning.osc_port]
	else:
		status_text = "Could not open UDP port %d (%s). Another program using it?" % [
				tuning.osc_port, error_string(err)]
		_udp = null
		push_warning(status_text)


func _process(delta: float) -> void:
	if _udp != null:
		while _udp.get_available_packet_count() > 0:
			var bytes := _udp.get_packet()
			packets_total += 1
			_rate_count += 1
			for msg: Dictionary in OscParser.parse_packet(bytes):
				handle_message(msg.get("address", ""), msg.get("args", []))
	_rate_t += delta
	if _rate_t >= 0.5:
		packets_per_s = _rate_count / _rate_t
		_rate_count = 0
		_rate_t = 0.0


## Public so tests and the input-check screen can inject messages.
func handle_message(address: String, args: Array) -> void:
	var now := Time.get_ticks_msec()
	_any_ms = now
	last_address = address
	last_args = args
	message.emit(address, args)
	var value := _first_number(args)
	if address == tuning.addr_pedal_stroke:
		_stroke_ms = now
		pedal_stroke.emit()
		return
	if is_nan(value):
		return
	if address == tuning.addr_steer:
		steer = value
		_steer_ms = now
	elif address == tuning.addr_steer_present:
		steer_present = value > 0.5
		_present_ms = now
	elif address == tuning.addr_cadence:
		cadence_rpm = maxf(0.0, value)
		_cadence_ms = now


func steer_fresh() -> bool:
	return _fresh(_steer_ms)


## True when Max says the hand is in range. Starts true, so a patch that never
## sends a presence flag still steers.
func hand_present() -> bool:
	return steer_present


func present_flag_seen() -> bool:
	return _present_ms >= 0


func cadence_fresh() -> bool:
	return _fresh(_cadence_ms)


func strokes_fresh() -> bool:
	return _stroke_ms >= 0 and Time.get_ticks_msec() - _stroke_ms <= tuning.stroke_timeout_s * 1000.0


func any_fresh() -> bool:
	return _fresh(_any_ms)


func _fresh(ms: int) -> bool:
	return ms >= 0 and Time.get_ticks_msec() - ms <= tuning.osc_timeout_s * 1000.0


func _first_number(args: Array) -> float:
	for a: Variant in args:
		if a is float or a is int:
			return float(a)
		if a is bool:
			return 1.0 if a else 0.0
	return NAN
