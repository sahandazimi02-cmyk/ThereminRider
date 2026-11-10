## Third-person chase camera and first-person helmet camera in one. After a
## fall both modes switch to a crash camera that pulls back and orbits the
## crash. Camera shake comes from add_trauma().
class_name BikeCamera
extends Camera3D

var bike: Bike
var tuning: RoadTuning
var first_person := false:
	set(v):
		first_person = v
		_update_head()
		_snap = true

var _snap := true
var _chase_pos := Vector3.ZERO
var _chase_yaw := 0.0
var _roll := 0.0
var _trauma := 0.0
var _crash_view := false
var _crash_yaw := 0.0
var _crash_pos := Vector3.ZERO
var _shake_phase := Vector4(0.0, 1.7, 3.1, 4.6)


func _ready() -> void:
	near = 0.05
	far = 900.0


func snap() -> void:
	_snap = true


## Adds camera shake (0..1, stacks up to 1).
func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func is_crash_view() -> bool:
	return _crash_view


func _process(delta: float) -> void:
	if bike == null or tuning == null:
		return
	var crashed := not bike.is_upright()
	if crashed != _crash_view:
		_crash_view = crashed
		if crashed:
			_crash_yaw = bike.yaw if first_person else _chase_yaw
			_crash_pos = global_position
		else:
			_snap = true
		_update_head()
	# Follow the lean while riding; level out once the bike is on the ground.
	var target_roll := bike.lean if bike.is_upright() else 0.0
	_roll = target_roll if _snap else lerpf(_roll, target_roll, 1.0 - exp(-tuning.chase_follow_rate * 2.0 * delta))
	if _crash_view:
		_crash(delta)
	elif first_person:
		_first_person()
	else:
		_chase(delta)
	if not _crash_view:
		fov += tuning.speed_fov_boost_deg * clampf(bike.speed / tuning.speed_fov_full_mps, 0.0, 1.0)
	_shake(delta)
	_snap = false


func _update_head() -> void:
	if bike != null and bike.model != null:
		bike.model.set_head_visible(_crash_view or not first_person)


func _first_person() -> void:
	# Placement and FOV come from the FirstPersonCamera node in
	# scenes/bike/bike_model.tscn, so they're edited in the Godot editor.
	fov = bike.model.first_person_fov()
	var view := bike.model.first_person_transform(_roll * tuning.fp_roll_factor)
	global_transform = Transform3D(Basis(Vector3.UP, bike.yaw) * view.basis, bike.global_transform * view.origin)


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


## Pull back behind the crash, slowly orbit, keep bike and rider in view.
func _crash(delta: float) -> void:
	fov = lerpf(fov, tuning.chase_fov_deg, 1.0 - exp(-3.0 * delta))
	var rider_pos := bike.model.rider_focus()
	var focus := (bike.global_position + rider_pos) * 0.5 + Vector3.UP * 0.4
	# Back off further when the rider lands far from the bike, so both stay in shot.
	var spread := Vector2(rider_pos.x - bike.global_position.x, rider_pos.z - bike.global_position.z).length()
	var dist := tuning.crash_cam_distance_m + spread * 0.9
	_crash_yaw += deg_to_rad(tuning.crash_cam_orbit_deg_s) * delta
	var back := Vector3(sin(_crash_yaw), 0.0, cos(_crash_yaw))
	var target := focus + back * dist + Vector3.UP * (tuning.crash_cam_height_m + spread * 0.35)
	_crash_pos = _crash_pos.lerp(target, 1.0 - exp(-2.5 * delta))
	global_position = _crash_pos
	# Aim a bit above the crash so bike and rider sit below the HUD messages.
	var aim := focus + Vector3.UP * (1.2 + spread * 0.15)
	if not _crash_pos.is_equal_approx(aim):
		look_at(aim, Vector3.UP)
	# Keep the chase camera ready to pick up from here after the get-up.
	_chase_yaw = _crash_yaw


func _shake(delta: float) -> void:
	if _trauma <= 0.0:
		return
	var s := _trauma * _trauma
	var t := Time.get_ticks_msec() / 1000.0
	var off := Vector3(sin(t * 41.0 + _shake_phase.x), sin(t * 37.0 + _shake_phase.y), sin(t * 29.0 + _shake_phase.z))
	global_position += global_basis * off * s * tuning.shake_offset_m
	rotate_object_local(Vector3.BACK, sin(t * 33.0 + _shake_phase.w) * s * deg_to_rad(tuning.shake_roll_deg))
	_trauma = maxf(_trauma - tuning.shake_decay * delta, 0.0)
