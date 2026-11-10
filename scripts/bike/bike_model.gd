## Low-poly bicycle + rider built from primitives. Forward is -Z, right is +X,
## origin is on the ground midway between the wheels. Bike drives the pose
## through update_pose(); this script owns no gameplay logic.
class_name BikeModel
extends Node3D

# Visual geometry (metres, bike-local). Not gameplay tunables.
const WHEEL_R := 0.34
const HALF_WB := 0.525
const BB := Vector3(0.0, 0.29, 0.10)
const SEAT := Vector3(0.0, 0.93, 0.30)
const HEAD_TOP := Vector3(0.0, 0.88, -0.40)
const HEAD_BOT := Vector3(0.0, 0.70, -0.45)
const STEER_PIVOT := Vector3(0.0, 0.0, -0.45)
const BAR := Vector3(0.0, 0.99, -0.34)
const BAR_HALF := 0.24
const CRANK_R := 0.17
const PEDAL_X := 0.13
const HIP := Vector3(0.0, 1.00, 0.28)
const HIP_X := 0.09
const SHOULDER := Vector3(0.0, 1.40, 0.0)
const SHOULDER_X := 0.18
const HEAD := Vector3(0.0, 1.58, -0.08)
const THIGH := 0.47
const SHIN := 0.46
## First-person eye point (bike-local, before lean).
const EYE := Vector3(0.0, 1.62, -0.12)
# Thrown-rider ragdoll-lite (visual only).
const RIDER_PIVOT := Vector3(0.0, 1.0, 0.24)
const RIDER_REST_H := 0.13
const RIDER_GROUND_FRICTION := 5.0

var lean_pivot: Node3D
var steer_node: Node3D
var rear_wheel: Node3D
var front_wheel: Node3D
var crank_node: Node3D
var head_group: Node3D
## Every rider mesh lives under this node so the rider can fly off the bike.
var rider: Node3D
var thrown := false

var _legs: Array = []  # [thigh, shin, foot] per side
var _arms: Array[MeshInstance3D] = []
var _pedals: Array[MeshInstance3D] = []
var _r_pos := Vector3.ZERO
var _r_vel := Vector3.ZERO
var _r_basis := Basis.IDENTITY
var _r_ang := Vector3.ZERO
var _ground_y := 0.0


func _ready() -> void:
	_build()


func _build() -> void:
	lean_pivot = Node3D.new()
	lean_pivot.name = "LeanPivot"
	add_child(lean_pivot)

	var r_axle := Vector3(0.0, WHEEL_R, HALF_WB)
	var f_axle := Vector3(0.0, WHEEL_R, -HALF_WB)

	# Frame
	MeshKit.tube_between(lean_pivot, BB, SEAT, 0.022, "bike_frame")
	MeshKit.tube_between(lean_pivot, BB, HEAD_BOT, 0.026, "bike_frame")
	MeshKit.tube_between(lean_pivot, SEAT + Vector3(0, -0.06, 0), HEAD_TOP + Vector3(0, -0.02, 0), 0.022, "bike_frame")
	for x: float in [-0.05, 0.05]:
		MeshKit.tube_between(lean_pivot, BB + Vector3(x, 0, 0), r_axle + Vector3(x, 0, 0), 0.014, "bike_frame")
		MeshKit.tube_between(lean_pivot, SEAT + Vector3(x, -0.08, 0), r_axle + Vector3(x, 0, 0), 0.012, "bike_frame")
	MeshKit.tube_between(lean_pivot, SEAT, SEAT + Vector3(0, 0.05, 0.01), 0.014, "bike_metal")
	MeshKit.box(lean_pivot, Vector3(0.13, 0.05, 0.27), SEAT + Vector3(0, 0.07, 0.0), "bike_dark")

	rear_wheel = _wheel(lean_pivot, r_axle)

	# Crank
	crank_node = Node3D.new()
	crank_node.position = BB
	lean_pivot.add_child(crank_node)
	MeshKit.ring_x(crank_node, 0.10, 0.015, Vector3(0.06, 0, 0), "bike_metal")
	for _i in 2:
		_pedals.append(MeshKit.box(lean_pivot, Vector3(0.10, 0.025, 0.07), Vector3.ZERO, "bike_dark"))

	# Steering assembly
	steer_node = Node3D.new()
	steer_node.name = "Steer"
	steer_node.position = STEER_PIVOT
	lean_pivot.add_child(steer_node)
	var off := -STEER_PIVOT
	MeshKit.tube_between(steer_node, HEAD_BOT + off, HEAD_TOP + off, 0.03, "bike_frame")
	for x: float in [-0.05, 0.05]:
		MeshKit.tube_between(steer_node, HEAD_BOT + off + Vector3(x, 0, 0), f_axle + off + Vector3(x, 0, 0), 0.014, "bike_metal")
	MeshKit.tube_between(steer_node, HEAD_TOP + off, BAR + off, 0.018, "bike_metal")
	MeshKit.tube_between(steer_node, BAR + off + Vector3(-BAR_HALF, 0, 0), BAR + off + Vector3(BAR_HALF, 0, 0), 0.016, "bike_metal")
	for x: float in [-BAR_HALF, BAR_HALF]:
		MeshKit.tube_between(steer_node, BAR + off + Vector3(x * 0.8, 0, 0), BAR + off + Vector3(x * 1.1, 0, 0), 0.022, "bike_dark")
	front_wheel = _wheel(steer_node, f_axle + off)

	# Rider (its own node, identity transform under the lean pivot, so rider
	# coordinates are the same as lean-pivot coordinates until it's thrown).
	rider = Node3D.new()
	rider.name = "Rider"
	lean_pivot.add_child(rider)
	var hip_c := HIP
	var sh_c := SHOULDER
	var torso := MeshKit.tube(rider, 0.14, "rider_shirt", 8)
	MeshKit.place_tube(torso, hip_c, sh_c)
	MeshKit.box(rider, Vector3(0.30, 0.16, 0.24), hip_c + Vector3(0, 0.02, 0), "rider_pants")
	head_group = Node3D.new()
	head_group.position = HEAD
	rider.add_child(head_group)
	MeshKit.sphere(head_group, 0.105, Vector3.ZERO, "rider_skin")
	MeshKit.sphere(head_group, 0.12, Vector3(0, 0.04, 0.01), "helmet").scale = Vector3(1.0, 0.75, 1.15)
	MeshKit.tube_between(rider, sh_c, HEAD + Vector3(0, -0.08, 0.02), 0.05, "rider_skin")
	for side: float in [-1.0, 1.0]:
		_arms.append(MeshKit.tube(rider, 0.045, "rider_shirt"))
		var thigh := MeshKit.tube(rider, 0.065, "rider_pants")
		var shin := MeshKit.tube(rider, 0.05, "rider_pants")
		var foot := MeshKit.box(rider, Vector3(0.09, 0.07, 0.22), Vector3.ZERO, "bike_dark")
		_legs.append([thigh, shin, foot])

	update_pose(0.0, 0.0, 0.0, 0.0)


func _wheel(parent: Node3D, axle: Vector3) -> Node3D:
	var w := Node3D.new()
	w.position = axle
	parent.add_child(w)
	MeshKit.ring_x(w, WHEEL_R, 0.035, Vector3.ZERO, "tire")
	MeshKit.ring_x(w, WHEEL_R - 0.04, 0.012, Vector3.ZERO, "bike_metal")
	for i in 4:
		var a := PI * float(i) / 4.0
		var d := Vector3(0.0, cos(a), sin(a)) * (WHEEL_R - 0.04)
		MeshKit.tube_between(w, -d, d, 0.005, "bike_metal")
	MeshKit.tube_between(w, Vector3(-0.05, 0, 0), Vector3(0.05, 0, 0), 0.025, "bike_dark")
	return w


## lean (+ = right), steer (+ = right, radians), wheel_spin and crank angle (radians).
func update_pose(lean: float, steer: float, wheel_spin: float, crank: float) -> void:
	if lean_pivot == null:
		return
	lean_pivot.rotation = Vector3(0.0, 0.0, -lean)
	steer_node.rotation = Vector3(0.0, -steer, 0.0)
	rear_wheel.rotation = Vector3(-wheel_spin, 0.0, 0.0)
	front_wheel.rotation = Vector3(-wheel_spin, 0.0, 0.0)
	crank_node.rotation = Vector3(-crank, 0.0, 0.0)

	var steer_xf := steer_node.transform
	for i in 2:
		var side := -1.0 if i == 0 else 1.0
		var theta := crank + (0.0 if side > 0.0 else PI)
		var pedal := BB + Vector3(side * PEDAL_X, CRANK_R * cos(theta), -CRANK_R * sin(theta))
		_pedals[i].position = pedal
		if thrown:
			continue  # limbs keep their last pose while the rider flies
		var hip := HIP + Vector3(side * HIP_X, 0.0, 0.0)
		var knee := _knee(hip, pedal)
		var leg: Array = _legs[i]
		MeshKit.place_tube(leg[0], hip, knee)
		MeshKit.place_tube(leg[1], knee, pedal)
		(leg[2] as Node3D).position = pedal + Vector3(0.0, 0.03, 0.02)
		var grip_local := BAR - STEER_PIVOT + Vector3(side * BAR_HALF * 0.95, 0.0, 0.0)
		var grip := steer_xf * grip_local
		MeshKit.place_tube(_arms[i], SHOULDER + Vector3(side * SHOULDER_X, 0.0, 0.0), grip)


## Throws the rider off the bike: world velocity (m/s) and world angular
## velocity (rad/s). The rider then tumbles, bounces and slides to a stop.
func throw_rider(velocity: Vector3, angular: Vector3) -> void:
	if thrown or rider == null:
		return
	thrown = true
	_ground_y = global_position.y
	var xf := lean_pivot.global_transform
	_r_pos = xf * RIDER_PIVOT
	_r_basis = xf.basis.orthonormalized()
	_r_vel = velocity
	_r_ang = angular
	rider.top_level = true
	_apply_rider()


func reset_rider() -> void:
	thrown = false
	if rider != null:
		rider.top_level = false
		rider.transform = Transform3D.IDENTITY


## Where the rider is in the world (hip), thrown or not.
func rider_focus() -> Vector3:
	if thrown:
		return _r_pos
	return lean_pivot.global_transform * RIDER_PIVOT


func _physics_process(dt: float) -> void:
	if not thrown:
		return
	_r_vel.y -= 9.81 * dt
	_r_pos += _r_vel * dt
	var w := _r_ang.length()
	if w > 0.001:
		_r_basis = (Basis(_r_ang / w, w * dt) * _r_basis).orthonormalized()
	var floor_y := _ground_y + RIDER_REST_H
	if _r_pos.y <= floor_y:
		_r_pos.y = floor_y
		if _r_vel.y < -1.6:
			# Bounce.
			_r_vel.y = -_r_vel.y * 0.3
			_r_vel.x *= 0.7
			_r_vel.z *= 0.7
			_r_ang *= 0.55
		else:
			# Sliding: friction, stop tumbling, settle flat on the ground.
			_r_vel.y = 0.0
			var flat := Vector3(_r_vel.x, 0.0, _r_vel.z)
			var sp := flat.length()
			if sp > 0.0:
				flat *= maxf(sp - RIDER_GROUND_FRICTION * dt, 0.0) / sp
			_r_vel = flat
			_r_ang *= exp(-8.0 * dt)
			var q := Quaternion(_r_basis).slerp(Quaternion(_lying_basis()), 1.0 - exp(-7.0 * dt))
			_r_basis = Basis(q)
	_apply_rider()


## Flat on the ground, body along whichever way it's pointing, face down or up.
func _lying_basis() -> Basis:
	var along := Vector3(_r_basis.y.x, 0.0, _r_basis.y.z)
	if along.length() < 0.2:
		along = Vector3(-_r_basis.z.x, 0.0, -_r_basis.z.z)
	if along.length() < 0.01:
		along = Vector3.FORWARD
	along = along.normalized()
	var up := Vector3.UP if _r_basis.z.y >= 0.0 else Vector3.DOWN
	return Basis(along.cross(up), along, up).orthonormalized()


func _apply_rider() -> void:
	rider.global_transform = Transform3D(_r_basis, _r_pos) * Transform3D(Basis.IDENTITY, -RIDER_PIVOT)


func set_head_visible(v: bool) -> void:
	if head_group != null:
		head_group.visible = v


## Eye position for the first-person camera, in this node's space (lean applied).
func eye_local() -> Vector3:
	return lean_pivot.transform * EYE


func _knee(hip: Vector3, foot: Vector3) -> Vector3:
	var to_foot := foot - hip
	var d := clampf(to_foot.length(), 0.05, THIGH + SHIN - 0.001)
	var u := to_foot.normalized()
	var fwd := Vector3(0.0, 0.0, -1.0)
	var n := (fwd - u * u.dot(fwd)).normalized()
	var along := (THIGH * THIGH - SHIN * SHIN + d * d) / (2.0 * d)
	var h := sqrt(maxf(THIGH * THIGH - along * along, 0.0))
	return hip + u * along + n * h
