## The bicycle: speed from pedalling, heading from steering, and a lean
## (balance) simulation. The game calls step() every physics tick.
##
## Balance model (inverted pendulum + steering):
##   lean_acc = gravity_scale * g/h * (sin(lean) - cos(lean) * lat_accel / g)
##              - k(v) * (lean - lean_eq) - damping * lean_rate + wobble
## lat_accel = v * yaw_rate comes from steering, so steering *toward* the
## lean pushes the bike back up (like a real bike). k(v) is self-stability:
## zero below wobble_speed, full at stable_speed. Stop pedalling -> you slow
## down -> self-stability fades, steering loses authority -> you fall.
class_name Bike
extends Node3D

signal crashed(reason: String)

enum State { FOOT_DOWN, RIDING, FALLING, DOWN }

const G := 9.81
const FOOT_DOWN_UPRIGHT_RATE := 2.5
const STATE_NAMES := ["FOOT DOWN", "RIDING", "FALLING", "DOWN"]

var tuning: BikeTuning
## x = self-stability multiplier, y = gravity multiplier (menu assist level).
var assist_scale := Vector2.ONE

var state: State = State.FOOT_DOWN
var speed := 0.0
var yaw := 0.0
var lean := 0.0
var lean_rate := 0.0
var steer_angle := 0.0
var yaw_rate := 0.0
var lat_accel := 0.0
var lean_eq := 0.0
var stability_k := 0.0
var target_speed := 0.0
var last_crash_reason := ""

var model: BikeModel

var _stall_t := 0.0
var _fall_side := 1.0
var _noise_t := 0.0
var _noise_phase := Vector3.ZERO
var _wheel_spin := 0.0
var _crank := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	if tuning == null:
		tuning = BikeTuning.load_default()
	model = BikeModel.new()
	model.name = "Model"
	add_child(model)
	_rng.randomize()
	_noise_phase = Vector3(_rng.randf() * TAU, _rng.randf() * TAU, _rng.randf() * TAU)


func respawn(pos: Vector3, heading: float) -> void:
	position = pos
	yaw = heading
	rotation = Vector3(0.0, yaw, 0.0)
	state = State.FOOT_DOWN
	speed = 0.0
	lean = 0.0
	lean_rate = 0.0
	steer_angle = 0.0
	yaw_rate = 0.0
	lat_accel = 0.0
	_stall_t = 0.0
	_update_model()


func is_upright() -> bool:
	return state == State.FOOT_DOWN or state == State.RIDING


func forward() -> Vector3:
	return Vector3(-sin(yaw), 0.0, -cos(yaw))


func right() -> Vector3:
	return Vector3(cos(yaw), 0.0, -sin(yaw))


func state_name() -> String:
	return STATE_NAMES[int(state)]


## steer_in -1..1, cadence in crank RPM.
func step(dt: float, steer_in: float, cadence_rpm: float) -> void:
	var t := tuning
	var cadence := minf(cadence_rpm, t.max_cadence_rpm)

	# --- speed ---
	if is_upright():
		target_speed = cadence * t.speed_per_rpm
		if target_speed > speed:
			speed += minf(t.pedal_response * (target_speed - speed), t.max_accel) * dt
		else:
			var decel := t.coast_decel + t.coast_drag * speed * speed
			speed = maxf(target_speed, speed - decel * dt)
			speed = maxf(speed, 0.0)
	else:
		target_speed = 0.0
		speed = move_toward(speed, 0.0, t.ground_friction * dt)

	# --- steering & heading ---
	var steer_target := 0.0
	if is_upright():
		var max_deg := lerpf(t.max_steer_deg_slow, t.max_steer_deg_fast, smoothstep(0.0, t.fast_speed, speed))
		var u := clampf(steer_in, -1.0, 1.0)
		u = signf(u) * pow(absf(u), t.steer_expo)
		steer_target = deg_to_rad(max_deg) * u
		if state == State.FOOT_DOWN:
			steer_target *= t.foot_down_steer_factor
	steer_angle = move_toward(steer_angle, steer_target, deg_to_rad(t.steer_rate_deg_s) * dt)
	yaw_rate = speed * tan(steer_angle) / t.wheelbase_m if is_upright() else 0.0
	lat_accel = speed * yaw_rate
	yaw -= yaw_rate * dt
	position += forward() * speed * dt

	# --- lean ---
	match state:
		State.FOOT_DOWN:
			lean = move_toward(lean, 0.0, FOOT_DOWN_UPRIGHT_RATE * dt)
			lean_rate = 0.0
			lean_eq = 0.0
			stability_k = 0.0
			if speed >= t.launch_speed:
				state = State.RIDING
				_stall_t = 0.0
		State.RIDING:
			_step_balance(dt)
		State.FALLING:
			lean_rate += _fall_side * t.fall_tip_accel * dt
			lean += lean_rate * dt
			var rest := deg_to_rad(t.fallen_rest_deg)
			if absf(lean) >= rest:
				lean = _fall_side * rest
				lean_rate = 0.0
				state = State.DOWN
		State.DOWN:
			pass

	_wheel_spin = fmod(_wheel_spin + speed / t.wheel_radius_m * dt, TAU)
	if is_upright():
		_crank = fmod(_crank + cadence / 60.0 * TAU * dt, TAU)
	_update_model()


func _step_balance(dt: float) -> void:
	var t := tuning
	var gs := t.gravity_scale * assist_scale.y
	stability_k = t.self_stability * assist_scale.x * smoothstep(t.wobble_speed, t.stable_speed, speed)
	lean_eq = atan2(lat_accel, G)
	var pend := gs * (G / t.com_height_m) * (sin(lean) - cos(lean) * lat_accel / G)
	var wobble := t.wobble_noise * (1.0 - smoothstep(0.0, t.wobble_speed, speed)) * _noise(dt)
	var acc := pend - stability_k * (lean - lean_eq) - t.lean_damping * lean_rate + wobble
	lean_rate += acc * dt
	lean += lean_rate * dt

	if absf(lean) > deg_to_rad(t.fall_angle_deg):
		_start_fall("lost balance", signf(lean))
		return
	if speed < t.stall_speed:
		_stall_t += dt
		if _stall_t >= t.stall_fall_s:
			_start_fall("stopped pedalling", signf(lean) if absf(lean) > 0.001 else _random_side())
	else:
		_stall_t = 0.0


## Called by the game for rail/obstacle hits. side: +1 fall right, -1 left, 0 = auto.
func crash(reason: String, side: float = 0.0) -> void:
	if not is_upright():
		return
	speed *= tuning.impact_speed_keep
	if side == 0.0:
		side = signf(lean) if absf(lean) > 0.02 else _random_side()
	_start_fall(reason, side)


func hit_pothole() -> void:
	if state != State.RIDING:
		return
	lean_rate += _random_side() * tuning.pothole_kick
	speed *= tuning.pothole_speed_keep


func _start_fall(reason: String, side: float) -> void:
	state = State.FALLING
	_fall_side = side if side != 0.0 else 1.0
	if lean_rate * _fall_side < 0.0:
		lean_rate = 0.0
	last_crash_reason = reason
	crashed.emit(reason)


func _random_side() -> float:
	return 1.0 if _rng.randf() < 0.5 else -1.0


func _noise(dt: float) -> float:
	_noise_t += dt
	return sin(1.3 * _noise_t + _noise_phase.x) * 0.6 \
			+ sin(2.9 * _noise_t + _noise_phase.y) * 0.3 \
			+ sin(5.3 * _noise_t + _noise_phase.z) * 0.1


func _update_model() -> void:
	rotation = Vector3(0.0, yaw, 0.0)
	if model != null:
		model.update_pose(lean, steer_angle, _wheel_spin, _crank)
