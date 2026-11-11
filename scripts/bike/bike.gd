## The bicycle: speed from pedalling, heading from steering, and a lean
## (balance) simulation. The game calls step() every physics tick.
##
## On top of the physics, a fake steering assist (0.3.0, for the theremin): the
## bike follows part of the road's curve and its heading eases back toward the
## road, so steering moves you across the road instead of spinning you round.
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
## 0 = random wobble each run. Tests set a fixed seed so runs repeat exactly.
var noise_seed := 0
## Set by the game every tick before step(): the road's heading and curvature
## (rad/m, + = bends right) under the bike. Drives the fake steering assist.
## Without a road (unit tests) the assist is off.
var has_road := false
var road_yaw := 0.0
var road_curvature := 0.0

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
## True when the last fall came from hitting something (rail/obstacle), so the
## game plays the big crash effects. False for plain balance/stall falls.
var impact := false

## Editable in the Godot editor: open this scene to change the bike, the rider
## and the first-person camera.
const MODEL_SCENE := preload("res://scenes/bike/bike_model.tscn")

var model: BikeModel

var _stall_t := 0.0
var _fall_side := 1.0
var _noise_t := 0.0
var _noise_phase := Vector3.ZERO
var _wheel_spin := 0.0
var _crank := 0.0
var _rng := RandomNumberGenerator.new()
# Crash motion (visual + slide): slide direction, spin on the ground, bounce.
var _slide_dir := Vector3.FORWARD
var _spin := 0.0
var _hop_y := 0.0
var _hop_v := 0.0
# Seconds of pothole shakiness left (see hit_pothole) and its jitter clock.
var _pothole_t := 0.0
var _jitter_t := 0.0


func _ready() -> void:
	if tuning == null:
		tuning = BikeTuning.load_default()
	model = MODEL_SCENE.instantiate() as BikeModel
	model.name = "Model"
	model.use_handlebar_model = GameSession.handlebar_model
	add_child(model)
	if noise_seed != 0:
		_rng.seed = noise_seed
	else:
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
	impact = false
	_spin = 0.0
	_hop_y = 0.0
	_hop_v = 0.0
	_pothole_t = 0.0
	if model != null:
		model.reset_rider()
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
		target_speed = minf(cadence * t.speed_per_rpm, t.max_speed_kmh / 3.6)
		if target_speed > speed:
			speed += minf(t.pedal_response * (target_speed - speed), t.max_accel) * dt
		else:
			var decel := t.coast_decel + t.coast_drag * speed * speed
			if cadence < 1.0:
				decel += t.stop_brake
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
	yaw -= (yaw_rate + _assist_yaw_rate()) * dt
	if is_upright():
		position += forward() * speed * dt
	else:
		position += _slide_dir * speed * dt
		yaw += _spin * dt
		_spin *= exp(-2.2 * dt)
	if _hop_y > 0.0 or _hop_v > 0.0:
		_hop_v -= G * dt
		_hop_y += _hop_v * dt
		if _hop_y <= 0.0:
			_hop_y = 0.0
			_hop_v = -_hop_v * 0.3 if _hop_v < -1.0 else 0.0

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

	if _pothole_t > 0.0:
		_pothole_t = maxf(0.0, _pothole_t - dt) if state == State.RIDING else 0.0
		_jitter_t += dt
	_wheel_spin = fmod(_wheel_spin + speed / t.wheel_radius_m * dt, TAU)
	if is_upright():
		_crank = fmod(_crank + cadence / 60.0 * TAU * dt, TAU)
	_update_model()


func _step_balance(dt: float) -> void:
	var t := tuning
	var gs := t.gravity_scale * assist_scale.y
	stability_k = (t.self_stability * smoothstep(t.wobble_speed, t.stable_speed, speed) + t.lean_assist) * assist_scale.x
	var shaky := pothole_shake()
	stability_k *= 1.0 - t.pothole_stability_loss * shaky
	lean_eq = atan2(lat_accel, G)
	var pend := gs * (G / t.com_height_m) * (sin(lean) - cos(lean) * lat_accel / G)
	var wobble := (t.wobble_noise * (1.0 - smoothstep(0.0, t.wobble_speed, speed)) + t.speed_wobble) * _noise(dt)
	wobble += t.pothole_jitter * shaky * _jitter()
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


## Called by the game for rail/obstacle hits. side: +1 fall right, -1 left,
## 0 = auto. bounce: world direction the bike gets knocked toward (e.g. off a rail).
func crash(reason: String, side: float = 0.0, bounce: Vector3 = Vector3.ZERO) -> void:
	if not is_upright():
		return
	if side == 0.0:
		side = signf(lean) if absf(lean) > 0.02 else _random_side()
	var t := tuning
	var hit_speed := speed
	var fwd := forward()
	# Rider keeps flying; the bike stops short, bounces and spins.
	if model != null:
		var throw_v := fwd * hit_speed * t.rider_throw_keep + Vector3.UP * t.rider_throw_up * clampf(hit_speed / 6.0, 0.4, 1.2)
		throw_v += bounce * hit_speed * 0.15 + right() * side * 0.8
		var tumble := right() * -t.rider_tumble * clampf(hit_speed / 6.0, 0.4, 1.3) + fwd * side * _rng.randf_range(1.0, 3.0)
		model.throw_rider(throw_v, tumble)
	speed = hit_speed * t.impact_speed_keep
	_slide_dir = (fwd + bounce * 0.9).normalized() if bounce != Vector3.ZERO else fwd
	_spin = deg_to_rad(t.crash_spin_deg_s) * _rng.randf_range(0.6, 1.0) * (1.0 if _rng.randf() < 0.5 else -1.0)
	_hop_v = t.crash_hop * clampf(hit_speed / 6.0, 0.3, 1.2)
	_hop_y = 0.001
	impact = true
	_start_fall(reason, side)


## Fake steering (kinematic, not part of the lean physics): follow some of the
## road's curve and ease the heading back toward the road direction. Returns a
## yaw rate in the same sense as yaw_rate (+ = turning right).
func _assist_yaw_rate() -> float:
	if not has_road or state != State.RIDING:
		return 0.0
	var rel := wrapf(yaw - road_yaw, -PI, PI)  # + = pointing left of the road
	return tuning.road_follow * speed * road_curvature + tuning.heading_assist * rel


## Called by the game while the bike rubs along a guard rail. Instead of a
## crash, the rail turns the bike away (toward away_deg off the road heading),
## slows it and calms the lean. side: +1 = right rail, -1 = left rail.
func scrape_rail(dt: float, side: float, rail_yaw: float, decel: float, away_deg: float, turn_deg_s: float, lean_calm: float) -> void:
	if state != State.RIDING and state != State.FOOT_DOWN:
		return
	speed = maxf(0.0, speed - decel * dt)
	var rel := wrapf(yaw - rail_yaw, -PI, PI)  # + = pointing left
	var want := side * deg_to_rad(away_deg)  # right rail -> point left
	if rel * side < deg_to_rad(away_deg):
		rel = move_toward(rel, want, deg_to_rad(turn_deg_s) * dt)
		yaw = rail_yaw + rel
	# Steering into the rail is pointless; straighten the front wheel a bit.
	if steer_angle * side > 0.0:
		steer_angle = move_toward(steer_angle, 0.0, deg_to_rad(turn_deg_s) * dt)
	lean_rate *= exp(-lean_calm * dt)
	_update_model()


## Riding over a pothole: a sideways kick, some speed lost, a jolt up, and
## for pothole_shaky_s the bike balances itself less and jitters (fading out).
func hit_pothole() -> void:
	if state != State.RIDING:
		return
	var t := tuning
	lean_rate += _random_side() * t.pothole_kick
	speed *= t.pothole_speed_keep
	_pothole_t = t.pothole_shaky_s
	_jitter_t = _rng.randf() * TAU
	if t.pothole_hop > 0.0:
		_hop_v = maxf(_hop_v, t.pothole_hop)
		_hop_y = maxf(_hop_y, 0.001)


## 0..1: how shaky the bike still is from the last pothole (1 = just hit).
func pothole_shake() -> float:
	if _pothole_t <= 0.0 or tuning.pothole_shaky_s <= 0.0:
		return 0.0
	return _pothole_t / tuning.pothole_shaky_s


## Fast two-tone jitter (-1..1) for the post-pothole wobble.
func _jitter() -> float:
	return sin(9.0 * _jitter_t) * 0.6 + sin(15.0 * _jitter_t + 1.3) * 0.4


func _start_fall(reason: String, side: float) -> void:
	state = State.FALLING
	_fall_side = side if side != 0.0 else 1.0
	if not impact:
		# Plain fall: slide on in a straight line, rider topples off sideways.
		_slide_dir = forward()
		var soft := tuning.soft_fall_throw
		if model != null and soft > 0.0:
			var v := forward() * speed * 0.9 + right() * _fall_side * 2.4 * soft + Vector3.UP * 1.6 * soft
			model.throw_rider(v, forward() * _fall_side * 3.5 * soft)
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
		model.position.y = _hop_y
		var twitch := deg_to_rad(tuning.pothole_bar_twitch_deg) * pothole_shake() * sin(13.0 * _jitter_t)
		model.update_pose(lean, steer_angle + twitch, _wheel_spin, _crank)
