## Turns individual pedal strokes (an A-button tap, or a sensor pulse) into
## crank RPM. Tap faster = higher RPM; stop tapping = it decays to 0.
class_name StrokeCadence
extends RefCounted

var strokes_per_rev: float = 2.0
var average_count: int = 4
var timeout_s: float = 1.2

var _times: PackedFloat64Array = PackedFloat64Array()


func configure(tuning: InputTuning) -> void:
	strokes_per_rev = tuning.strokes_per_rev
	average_count = tuning.stroke_average_count
	timeout_s = tuning.stroke_timeout_s


func add_stroke(now_s: float) -> void:
	if not _times.is_empty() and now_s - _times[_times.size() - 1] > timeout_s:
		_times.clear()
	_times.append(now_s)
	while _times.size() > average_count + 1:
		_times.remove_at(0)


func rpm(now_s: float) -> float:
	if _times.size() < 2:
		return 0.0
	var last := _times[_times.size() - 1]
	var since := now_s - last
	if since > timeout_s:
		return 0.0
	var interval := (last - _times[0]) / float(_times.size() - 1)
	# Once the next stroke is overdue, slow the estimate down continuously.
	interval = maxf(interval, since)
	if interval <= 0.0001:
		return 0.0
	return 60.0 / (interval * strokes_per_rev)


func reset() -> void:
	_times.clear()
