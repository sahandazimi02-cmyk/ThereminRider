## Third-person chase camera and first-person helmet camera in one.
class_name BikeCamera
extends Camera3D

var bike: Bike
var tuning: RoadTuning
var first_person := false:
	set(v):
		first_person = v
		if bike != null and bike.model != null:
			bike.model.set_head_visible(not v)
		_snap = true

var _snap := true
var _chase_pos := Vector3.ZERO
var _chase_yaw := 0.0
var _roll := 0.0


func _ready() -> void:
	near = 0.05
	far = 900.0


func snap() -> void:
	_snap = true


func _process(delta: float) -> void:
	if bike == null or tuning == null:
		return
	# Follow the lean while riding; level out once the bike is on the ground.
	var target_roll := bike.lean if bike.is_upright() else 0.0
	_roll = target_roll if _snap else lerpf(_roll, target_roll, 1.0 - exp(-tuning.chase_follow_rate * 2.0 * delta))
	if first_person:
		_first_person()
	else:
		_chase(delta)
	_snap = false


func _first_person() -> void:
	fov = tuning.fp_fov_deg
	var eye := bike.global_transform * bike.model.eye_local()
	var b := Basis(Vector3.UP, bike.yaw)
	b = b * Basis(Vector3.BACK, -_roll * tuning.fp_roll_factor)
	b = b * Basis(Vector3.RIGHT, deg_to_rad(tuning.fp_pitch_deg))
	global_transform = Transform3D(b, eye)


func _chase(delta: float) -> void:
	fov = tuning.chase_fov_deg
	var w := 1.0 if _snap else 1.0 - exp(-tuning.chase_follow_rate * delta)
	_chase_yaw = lerp_angle(_chase_yaw, bike.yaw, w)
	var fwd := Vector3(-sin(_chase_yaw), 0.0, -cos(_chase_yaw))
	var target := bike.global_position - fwd * tuning.chase_distance_m + Vector3.UP * tuning.chase_height_m
	_chase_pos = _chase_pos.lerp(target, w)
	var look := bike.global_position + Vector3.UP * 1.0 + fwd * tuning.chase_look_ahead_m
	global_position = _chase_pos
	if not _chase_pos.is_equal_approx(look):
		look_at(look, Vector3.UP)
	rotate_object_local(Vector3.BACK, -_roll * tuning.chase_roll_factor)
