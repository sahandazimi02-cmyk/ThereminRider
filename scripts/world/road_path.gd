## Road centre line, sampled every `step` metres. Heading convention matches
## Node3D.rotation.y: forward = (-sin yaw, 0, -cos yaw). Positive curvature
## turns right (yaw decreases). "s" = distance along the road, "lateral" =
## signed offset to the right of the centre line.
class_name RoadPath
extends RefCounted

var step := 1.0
var points := PackedVector3Array()
var yaws := PackedFloat32Array()
var start_yaw := 0.0

var _hint := 0


func _init(step_m: float = 1.0, start_pos: Vector3 = Vector3.ZERO, heading: float = 0.0) -> void:
	step = step_m
	start_yaw = heading
	points.append(start_pos)
	yaws.append(heading)


static func forward_of(heading: float) -> Vector3:
	return Vector3(-sin(heading), 0.0, -cos(heading))


static func right_of(heading: float) -> Vector3:
	return Vector3(cos(heading), 0.0, -sin(heading))


func length() -> float:
	return float(points.size() - 1) * step


func sample_count() -> int:
	return points.size()


func end_yaw() -> float:
	return yaws[yaws.size() - 1]


## Appends `length_m` of road whose curvature (1/radius) goes linearly k0 -> k1.
func append(length_m: float, k0: float, k1: float) -> void:
	var n := maxi(1, roundi(length_m / step))
	var pos := points[points.size() - 1]
	var heading := end_yaw()
	for j in n:
		var k := lerpf(k0, k1, (float(j) + 0.5) / float(n))
		var mid := heading - k * step * 0.5
		pos += forward_of(mid) * step
		heading -= k * step
		points.append(pos)
		yaws.append(heading)


func append_straight(length_m: float) -> void:
	append(length_m, 0.0, 0.0)


## Curve with eased entry/exit. turn_right: true = right. Returns turn in radians.
func append_curve(length_m: float, radius: float, turn_right: bool, ease_m: float) -> float:
	var k := (1.0 if turn_right else -1.0) / maxf(radius, 1.0)
	var e := minf(ease_m, length_m * 0.5)
	var hold := length_m - 2.0 * e
	if e > 0.0:
		append(e, 0.0, k)
	if hold > 0.0:
		append(hold, k, k)
	if e > 0.0:
		append(e, k, 0.0)
	return k * (hold + e)


func _index_f(s: float) -> float:
	return clampf(s / step, 0.0, float(points.size() - 1))


func position_at(s: float) -> Vector3:
	var f := _index_f(s)
	var i := mini(int(f), points.size() - 2)
	if i < 0:
		return points[0]
	return points[i].lerp(points[i + 1], f - float(i))


func yaw_at(s: float) -> float:
	var f := _index_f(s)
	var i := mini(int(f), yaws.size() - 2)
	if i < 0:
		return yaws[0]
	return lerp_angle(yaws[i], yaws[i + 1], f - float(i))


func point_at(s: float, lateral: float) -> Vector3:
	return position_at(s) + right_of(yaw_at(s)) * lateral


## Returns Vector2(s, lateral) for a world position near the road.
func locate(pos: Vector3) -> Vector2:
	var n := points.size()
	if n < 2:
		return Vector2.ZERO
	var i := clampi(_hint, 0, n - 2)
	var flat := Vector3(pos.x, 0.0, pos.z)
	# Walk forward/back to the segment containing pos.
	for _guard in 4096:
		if i < n - 2 and _along(flat, i + 1) >= 0.0:
			i += 1
		elif i > 0 and _along(flat, i) < 0.0:
			i -= 1
		else:
			break
	_hint = i
	var a := points[i]
	var dir := (points[i + 1] - a).normalized()
	var d := flat - Vector3(a.x, 0.0, a.z)
	var along := d.dot(dir)
	var right := Vector3(-dir.z, 0.0, dir.x)
	return Vector2(float(i) * step + along, d.dot(right))


func reset_hint(s: float = 0.0) -> void:
	_hint = clampi(int(s / step), 0, maxi(points.size() - 2, 0))


func _along(flat: Vector3, i: int) -> float:
	var a := points[i]
	var dir := (points[mini(i + 1, points.size() - 1)] - a)
	if i == points.size() - 1:
		dir = a - points[i - 1]
	return (flat - Vector3(a.x, 0.0, a.z)).dot(dir.normalized())
