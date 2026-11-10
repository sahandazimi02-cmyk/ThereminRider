## Minimal OSC 1.0 decoder: messages and (nested) bundles.
## Argument types: i f d h s S b T F N I. Returns [{address, args}].
class_name OscParser
extends RefCounted


static func parse_packet(bytes: PackedByteArray) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	_parse_into(bytes, out, 0)
	return out


static func _parse_into(bytes: PackedByteArray, out: Array[Dictionary], depth: int) -> void:
	if bytes.size() < 4 or depth > 8:
		return
	if bytes.size() >= 16 and bytes.slice(0, 8).get_string_from_ascii() == "#bundle":
		var pos := 16  # "#bundle\0" + 8-byte timetag
		while pos + 4 <= bytes.size():
			var size := _read_i32(bytes, pos)
			pos += 4
			if size <= 0 or pos + size > bytes.size():
				return
			_parse_into(bytes.slice(pos, pos + size), out, depth + 1)
			pos += size
		return
	var msg := _parse_message(bytes)
	if not msg.is_empty():
		out.append(msg)


static func _parse_message(bytes: PackedByteArray) -> Dictionary:
	var r := _read_string(bytes, 0)
	var address: String = r[0]
	var pos: int = r[1]
	if address.is_empty() or address[0] != "/":
		return {}
	var args: Array = []
	if pos >= bytes.size():
		return {"address": address, "args": args}
	r = _read_string(bytes, pos)
	var tags: String = r[0]
	pos = r[1]
	if tags.is_empty() or tags[0] != ",":
		return {"address": address, "args": args}
	for i in range(1, tags.length()):
		var tag := tags[i]
		match tag:
			"i":
				if pos + 4 > bytes.size():
					break
				args.append(_read_i32(bytes, pos))
				pos += 4
			"f":
				if pos + 4 > bytes.size():
					break
				args.append(_read_f32(bytes, pos))
				pos += 4
			"d":
				if pos + 8 > bytes.size():
					break
				args.append(_read_f64(bytes, pos))
				pos += 8
			"h":
				if pos + 8 > bytes.size():
					break
				args.append(_read_i64(bytes, pos))
				pos += 8
			"s", "S":
				r = _read_string(bytes, pos)
				args.append(r[0])
				pos = r[1]
			"b":
				if pos + 4 > bytes.size():
					break
				var n := _read_i32(bytes, pos)
				pos += 4 + _pad4(n)
			"T":
				args.append(true)
			"F":
				args.append(false)
			"N", "I":
				args.append(null)
			_:
				break
	return {"address": address, "args": args}


## Returns [string, next_aligned_position].
static func _read_string(bytes: PackedByteArray, pos: int) -> Array:
	var end := pos
	while end < bytes.size() and bytes[end] != 0:
		end += 1
	var s := bytes.slice(pos, end).get_string_from_utf8()
	return [s, pos + _pad4(end - pos + 1)]


static func _pad4(n: int) -> int:
	return (n + 3) & ~3


static func _big_endian(bytes: PackedByteArray, pos: int, n: int) -> StreamPeerBuffer:
	var spb := StreamPeerBuffer.new()
	spb.big_endian = true
	spb.data_array = bytes.slice(pos, pos + n)
	return spb


static func _read_i32(bytes: PackedByteArray, pos: int) -> int:
	return _big_endian(bytes, pos, 4).get_32()


static func _read_i64(bytes: PackedByteArray, pos: int) -> int:
	return _big_endian(bytes, pos, 8).get_64()


static func _read_f32(bytes: PackedByteArray, pos: int) -> float:
	return _big_endian(bytes, pos, 4).get_float()


static func _read_f64(bytes: PackedByteArray, pos: int) -> float:
	return _big_endian(bytes, pos, 8).get_double()


## Builds an OSC message (used by the self test and the input check screen).
static func encode_message(address: String, args: Array) -> PackedByteArray:
	var spb := StreamPeerBuffer.new()
	spb.big_endian = true
	_write_string(spb, address)
	var tags := ","
	for a: Variant in args:
		if a is int:
			tags += "i"
		elif a is float:
			tags += "f"
		elif a is String:
			tags += "s"
	_write_string(spb, tags)
	for a: Variant in args:
		if a is int:
			spb.put_32(a)
		elif a is float:
			spb.put_float(a)
		elif a is String:
			_write_string(spb, a)
	return spb.data_array


static func _write_string(spb: StreamPeerBuffer, s: String) -> void:
	var raw := s.to_utf8_buffer()
	raw.append(0)
	while raw.size() % 4 != 0:
		raw.append(0)
	spb.put_data(raw)
