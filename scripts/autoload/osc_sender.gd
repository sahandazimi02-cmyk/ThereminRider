## Autoload "OscSender": sends the game's cycling speed back to Max over UDP/OSC
## so the video playback speed can follow it. See docs/OSC_PROTOCOL.md.
extends Node

var tuning: InputTuning
var speed_kmh := 0.0
var enabled := false
var status_text := "Not started."

var _udp: PacketPeerUDP
var _accum := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	tuning = InputTuning.load_default()
	enabled = tuning.osc_out_enabled
	if not enabled:
		status_text = "Speed output off."
		return
	_udp = PacketPeerUDP.new()
	var err := _udp.set_dest_address(tuning.osc_out_host, tuning.osc_out_port)
	if err != OK:
		status_text = "Bad OSC output address %s:%d" % [tuning.osc_out_host, tuning.osc_out_port]
		push_warning(status_text)
		_udp = null
		return
	status_text = "Sending speed to UDP %s:%d" % [tuning.osc_out_host, tuning.osc_out_port]


func _process(delta: float) -> void:
	if _udp == null:
		return
	_accum += delta
	var period := 1.0 / tuning.osc_out_rate_hz
	if _accum < period:
		return
	_accum = fmod(_accum, period)
	_udp.put_packet(encode_float(tuning.addr_speed_out, speed_kmh))


static func encode_float(address: String, value: float) -> PackedByteArray:
	var out := PackedByteArray()
	out.append_array(_pad(address.to_ascii_buffer()))
	out.append_array(_pad(",f".to_ascii_buffer()))
	var b := PackedByteArray()
	b.resize(4)
	b.encode_float(0, value)
	# OSC is big-endian; encode_float is little-endian.
	b.reverse()
	out.append_array(b)
	return out


static func _pad(bytes: PackedByteArray) -> PackedByteArray:
	bytes.append(0)
	while bytes.size() % 4 != 0:
		bytes.append(0)
	return bytes
