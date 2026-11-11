@tool
## Low-poly bicycle + rider built from primitives. Forward is -Z, right is +X,
## origin is on the ground midway between the wheels. Bike drives the pose
## through update_pose(); this script owns no gameplay logic.
##
## Lives in res://scenes/bike/bike_model.tscn. Open that scene to edit the
## model: every point below is an Inspector field and the model rebuilds live
## in the editor. The FirstPersonCamera child node IS the first-person view:
## move/rotate it in the viewport, set its FOV, and tick "Preview" to see what
## the rider sees. (The meshes are generated, so they don't show up in the
## Scene dock and aren't saved into the .tscn.)
class_name BikeModel
extends Node3D

@export_group("Bike")
@export_range(0.2, 0.5, 0.005) var wheel_radius: float = 0.34:
	set(v):
		wheel_radius = v
		_changed()
## Half the distance between the axles.
@export_range(0.3, 0.8, 0.005) var half_wheelbase: float = 0.525:
	set(v):
		half_wheelbase = v
		_changed()
## Crank axle.
@export var bottom_bracket := Vector3(0.0, 0.29, 0.10):
	set(v):
		bottom_bracket = v
		_changed()
@export_range(0.1, 0.25, 0.005) var crank_radius: float = 0.17:
	set(v):
		crank_radius = v
		_changed()
@export var seat := Vector3(0.0, 0.93, 0.30):
	set(v):
		seat = v
		_changed()
@export var head_tube_top := Vector3(0.0, 0.88, -0.40):
	set(v):
		head_tube_top = v
		_changed()
## Bottom of the head tube. The steering turns around a vertical axis through it.
@export var head_tube_bottom := Vector3(0.0, 0.70, -0.45):
	set(v):
		head_tube_bottom = v
		_changed()
## Centre of the handlebar (top of the stem).
@export var handlebar := Vector3(0.0, 1.03, -0.36):
	set(v):
		handlebar = v
		_changed()
## Centre to bar end.
@export_range(0.1, 0.45, 0.005) var handlebar_half_width: float = 0.27:
	set(v):
		handlebar_half_width = v
		_changed()
## How far the bar ends sweep back towards the rider.
@export_range(-0.1, 0.25, 0.005) var handlebar_sweep: float = 0.07:
	set(v):
		handlebar_sweep = v
		_changed()
## How far the bar ends rise above the bar centre.
@export_range(-0.1, 0.15, 0.005) var handlebar_rise: float = 0.03:
	set(v):
		handlebar_rise = v
		_changed()

@export_group("Handlebar model")
## Use the handlebar GLB (`Assets/steering.glb`) instead of the generated bar.
## The game sets this from the main menu ("Handlebar: Model / Classic").
@export var use_handlebar_model := true:
	set(v):
		use_handlebar_model = v
		_changed()
@export var handlebar_model: PackedScene = preload("res://Assets/steering.glb"):
	set(v):
		handlebar_model = v
		_changed()
## Turn the GLB about the vertical axis so its bar runs left-right and its
## grips point back at the rider (the GLB's own orientation, not a tunable).
@export_range(-180.0, 180.0, 0.1) var model_yaw_deg: float = 87.6:
	set(v):
		model_yaw_deg = v
		_changed()
## Distance between the two grip centres (m). Sets the model's scale.
@export_range(0.3, 0.8, 0.005) var model_grip_width: float = 0.44:
	set(v):
		model_grip_width = v
		_changed()
## Moves the model from its mount point: the bottom of its stem (just above
## its dashboard) sits on `head_tube_top` + this. The hands always hold the
## model's grips, wherever they end up.
@export var model_offset := Vector3(0.0, -0.18, 0.0):
	set(v):
		model_offset = v
		_changed()
## Tip the whole bar forward (+) or back (-) around its mount point, degrees.
@export_range(-60.0, 60.0, 0.5) var model_tilt_deg: float = 0.0:
	set(v):
		model_tilt_deg = v
		_changed()
## The GLB's tall vertical stem (between `model_stem_band` heights, in the
## GLB's own units) is shortened to this fraction of its length.
@export_range(0.0, 1.0, 0.01) var model_stem_keep: float = 0.05:
	set(v):
		model_stem_keep = v
		_changed()
@export var model_stem_band := Vector2(-0.24, 0.22):
	set(v):
		model_stem_band = v
		_changed()
## How metallic the model looks (multiplies its metallic map). The GLB's
## full chrome mirrors the sky and grass, so the bar looks blue-green.
@export_range(0.0, 1.0, 0.01) var model_shine: float = 0.5:
	set(v):
		model_shine = v
		_changed()
## Multiplies the model's colour map. Its map is light grey (it only looks
## black in a dark viewer), so darken it here for the black bar in daylight.
@export var model_tint := Color(0.22, 0.22, 0.22):
	set(v):
		model_tint = v
		_changed()
## Hide the model's triangles that are entirely below this height (bike
## space), so its long steerer tube doesn't poke through the front tyre.
@export_range(0.0, 1.5, 0.005) var model_cut_below: float = 0.70:
	set(v):
		model_cut_below = v
		_changed()

@export_group("Rider")
@export var show_rider := true:
	set(v):
		show_rider = v
		_changed()
## Centre of the hips (sits on the seat).
@export var hip := Vector3(0.0, 1.00, 0.28):
	set(v):
		hip = v
		_changed()
@export_range(0.03, 0.2, 0.005) var hip_half_width: float = 0.09:
	set(v):
		hip_half_width = v
		_changed()
## Centre between the shoulders.
@export var shoulder := Vector3(0.0, 1.38, 0.10):
	set(v):
		shoulder = v
		_changed()
@export_range(0.08, 0.3, 0.005) var shoulder_half_width: float = 0.19:
	set(v):
		shoulder_half_width = v
		_changed()
## Centre of the head (hidden in first person).
@export var head := Vector3(0.0, 1.56, 0.06):
	set(v):
		head = v
		_changed()
@export_range(0.15, 0.5, 0.005) var upper_arm_length: float = 0.31:
	set(v):
		upper_arm_length = v
		_changed()
@export_range(0.15, 0.5, 0.005) var forearm_length: float = 0.30:
	set(v):
		forearm_length = v
		_changed()
## Which way the elbows bend: x = outwards, y = up, z = backwards.
@export var elbow_direction := Vector3(1.0, -0.3, 0.6):
	set(v):
		elbow_direction = v
		_changed()
@export_range(0.2, 0.7, 0.005) var thigh_length: float = 0.47:
	set(v):
		thigh_length = v
		_changed()
@export_range(0.2, 0.7, 0.005) var shin_length: float = 0.46:
	set(v):
		shin_length = v
		_changed()

@export_group("First person")
## The camera the first-person view copies (position, rotation and FOV).
@export var first_person_camera: Camera3D
## Editor only: hide the head and neck, as the game does in first person, so
## the camera's Preview looks like the game.
@export var preview_first_person := false:
	set(v):
		preview_first_person = v
		_changed()

# Fixed visual details (metres, bike-local). Not gameplay tunables.
const PEDAL_X := 0.13
const HAND_R := 0.045
## Fallback eye point if the scene has no FirstPersonCamera.
const DEFAULT_EYE := Vector3(0.0, 1.56, 0.02)
const DEFAULT_FP_PITCH_DEG := -20.0
const DEFAULT_FP_FOV := 80.0
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

## The handlebar GLB mesh while `use_handlebar_model` is on (else null).
var handlebar_mesh: MeshInstance3D
## Grip centres [left, right] of the handlebar GLB, bike space, steering straight.
var _model_grips: Array[Vector3] = []
var _neck: MeshInstance3D
var _legs: Array = []  # [thigh, shin, foot] per side
var _arms: Array = []  # [upper arm, forearm, hand] per side
var _pedals: Array[MeshInstance3D] = []
var _head_visible := true
var _pose := Vector4.ZERO  # last update_pose() args, re-applied after a rebuild
var _r_pos := Vector3.ZERO
var _r_vel := Vector3.ZERO
var _r_basis := Basis.IDENTITY
var _r_ang := Vector3.ZERO
var _ground_y := 0.0


func _ready() -> void:
	if first_person_camera == null:
		first_person_camera = get_node_or_null("FirstPersonCamera") as Camera3D
	if not Engine.is_editor_hint() and first_person_camera != null:
		# Only a marker in the game; the game's BikeCamera does the rendering.
		first_person_camera.current = false
	_build()


func _changed() -> void:
	if is_node_ready():
		_build()


func _build() -> void:
	# Look the old one up by name too: after an editor script reload the
	# variable is reset but the generated node is still there.
	var old := get_node_or_null("LeanPivot")
	if old != null:
		remove_child(old)
		old.free()
	thrown = false
	_legs.clear()
	_arms.clear()
	_pedals.clear()

	lean_pivot = Node3D.new()
	lean_pivot.name = "LeanPivot"
	add_child(lean_pivot)

	var r_axle := Vector3(0.0, wheel_radius, half_wheelbase)
	var f_axle := Vector3(0.0, wheel_radius, -half_wheelbase)
	var bb := bottom_bracket

	# Frame
	MeshKit.tube_between(lean_pivot, bb, seat, 0.022, "bike_frame")
	MeshKit.tube_between(lean_pivot, bb, head_tube_bottom, 0.026, "bike_frame")
	MeshKit.tube_between(lean_pivot, seat + Vector3(0, -0.06, 0), head_tube_top + Vector3(0, -0.02, 0), 0.022, "bike_frame")
	for x: float in [-0.05, 0.05]:
		MeshKit.tube_between(lean_pivot, bb + Vector3(x, 0, 0), r_axle + Vector3(x, 0, 0), 0.014, "bike_frame")
		MeshKit.tube_between(lean_pivot, seat + Vector3(x, -0.08, 0), r_axle + Vector3(x, 0, 0), 0.012, "bike_frame")
	MeshKit.tube_between(lean_pivot, seat, seat + Vector3(0, 0.05, 0.01), 0.014, "bike_metal")
	MeshKit.box(lean_pivot, Vector3(0.13, 0.05, 0.27), seat + Vector3(0, 0.07, 0.0), "bike_dark")

	rear_wheel = _wheel(lean_pivot, r_axle)

	# Crank
	crank_node = Node3D.new()
	crank_node.position = bb
	lean_pivot.add_child(crank_node)
	MeshKit.ring_x(crank_node, 0.10, 0.015, Vector3(0.06, 0, 0), "bike_metal")
	for _i in 2:
		_pedals.append(MeshKit.box(lean_pivot, Vector3(0.10, 0.025, 0.07), Vector3.ZERO, "bike_dark"))

	# Steering assembly: head tube, fork, stem, swept-back bar, grips, front wheel.
	steer_node = Node3D.new()
	steer_node.name = "Steer"
	steer_node.position = _steer_pivot()
	lean_pivot.add_child(steer_node)
	var off := -_steer_pivot()
	MeshKit.tube_between(steer_node, head_tube_bottom + off, head_tube_top + off, 0.03, "bike_frame")
	for x: float in [-0.05, 0.05]:
		MeshKit.tube_between(steer_node, head_tube_bottom + off + Vector3(x, 0, 0), f_axle + off + Vector3(x, 0, 0), 0.014, "bike_metal")
	handlebar_mesh = null
	_model_grips.clear()
	if use_handlebar_model and handlebar_model != null:
		_build_handlebar_model(off)
	if handlebar_mesh == null:
		# Classic generated stem, swept-back bar and grips.
		MeshKit.tube_between(steer_node, head_tube_top + off, handlebar + off, 0.018, "bike_metal")
		MeshKit.box(steer_node, Vector3(0.05, 0.04, 0.05), handlebar + off, "bike_dark")
		for side: float in [-1.0, 1.0]:
			var bend := _bar_bend(side) + off
			var end := _bar_end(side) + off
			MeshKit.tube_between(steer_node, handlebar + off, bend, 0.016, "bike_metal")
			MeshKit.tube_between(steer_node, bend, end, 0.016, "bike_metal")
			MeshKit.tube_between(steer_node, bend.lerp(end, 0.35), end + (end - bend).normalized() * 0.015, 0.022, "bike_dark")
	front_wheel = _wheel(steer_node, f_axle + off)

	# Rider (its own node, identity transform under the lean pivot, so rider
	# coordinates are the same as lean-pivot coordinates until it's thrown).
	rider = Node3D.new()
	rider.name = "Rider"
	rider.visible = show_rider
	lean_pivot.add_child(rider)
	var torso := MeshKit.tube(rider, 0.14, "rider_shirt", 8)
	MeshKit.place_tube(torso, hip, shoulder)
	MeshKit.box(rider, Vector3(0.30, 0.16, 0.24), hip + Vector3(0, 0.02, 0), "rider_pants")
	# Shoulder caps so the upper arms join the torso cleanly.
	for side: float in [-1.0, 1.0]:
		MeshKit.sphere(rider, 0.06, _shoulder(side), "rider_shirt")
	head_group = Node3D.new()
	head_group.position = head
	rider.add_child(head_group)
	MeshKit.sphere(head_group, 0.105, Vector3.ZERO, "rider_skin")
	MeshKit.sphere(head_group, 0.12, Vector3(0, 0.04, 0.01), "helmet").scale = Vector3(1.0, 0.75, 1.15)
	_neck = MeshKit.tube_between(rider, shoulder, head + Vector3(0, -0.08, 0.02), 0.05, "rider_skin")
	for side: float in [-1.0, 1.0]:
		var upper := MeshKit.tube(rider, 0.048, "rider_shirt")
		var fore := MeshKit.tube(rider, 0.04, "rider_skin")
		var hand := MeshKit.sphere(rider, HAND_R, Vector3.ZERO, "rider_glove")
		hand.scale = Vector3(1.0, 0.85, 1.35)
		_arms.append([upper, fore, hand])
		var thigh := MeshKit.tube(rider, 0.065, "rider_pants")
		var shin := MeshKit.tube(rider, 0.05, "rider_pants")
		var foot := MeshKit.box(rider, Vector3(0.09, 0.07, 0.22), Vector3.ZERO, "bike_dark")
		_legs.append([thigh, shin, foot])

	_apply_head_visible()
	update_pose(_pose.x, _pose.y, _pose.z, _pose.w)


func _wheel(parent: Node3D, axle: Vector3) -> Node3D:
	var w := Node3D.new()
	w.position = axle
	parent.add_child(w)
	MeshKit.ring_x(w, wheel_radius, 0.035, Vector3.ZERO, "tire")
	MeshKit.ring_x(w, wheel_radius - 0.04, 0.012, Vector3.ZERO, "bike_metal")
	for i in 4:
		var a := PI * float(i) / 4.0
		var d := Vector3(0.0, cos(a), sin(a)) * (wheel_radius - 0.04)
		MeshKit.tube_between(w, -d, d, 0.005, "bike_metal")
	MeshKit.tube_between(w, Vector3(-0.05, 0, 0), Vector3(0.05, 0, 0), 0.025, "bike_dark")
	return w


## lean (+ = right), steer (+ = right, radians), wheel_spin and crank angle (radians).
func update_pose(lean: float, steer: float, wheel_spin: float, crank: float) -> void:
	_pose = Vector4(lean, steer, wheel_spin, crank)
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
		var pedal := bottom_bracket + Vector3(side * PEDAL_X, crank_radius * cos(theta), -crank_radius * sin(theta))
		_pedals[i].position = pedal
		if thrown:
			continue  # limbs keep their last pose while the rider flies
		var hip_p := hip + Vector3(side * hip_half_width, 0.0, 0.0)
		var knee := _ik(hip_p, pedal, thigh_length, shin_length, Vector3.FORWARD)
		var leg: Array = _legs[i]
		MeshKit.place_tube(leg[0], hip_p, knee)
		MeshKit.place_tube(leg[1], knee, pedal)
		(leg[2] as Node3D).position = pedal + Vector3(0.0, 0.03, 0.02)

		var grip := steer_xf * (_grip(side) - _steer_pivot())
		var sh := _shoulder(side)
		var pole := Vector3(elbow_direction.x * side, elbow_direction.y, elbow_direction.z)
		var elbow := _ik(sh, grip, upper_arm_length, forearm_length, pole)
		var arm: Array = _arms[i]
		MeshKit.place_tube(arm[0], sh, elbow)
		MeshKit.place_tube(arm[1], elbow, grip)
		var hand := arm[2] as Node3D
		hand.position = grip + Vector3(0.0, 0.012, 0.0)
		hand.basis = steer_xf.basis * Basis.from_scale(Vector3(1.0, 0.85, 1.35))


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
	if not thrown or Engine.is_editor_hint():
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
	_head_visible = v
	_apply_head_visible()


func _apply_head_visible() -> void:
	var v := _head_visible and not (Engine.is_editor_hint() and preview_first_person)
	if head_group != null:
		head_group.visible = v
	if _neck != null:
		_neck.visible = v


## First-person view in the parent's (Bike's) space: the FirstPersonCamera
## node's placement. The eye moves with the full lean; the view itself rolls
## by `roll` radians (+ = leaning right), which the camera smooths and scales.
func first_person_transform(roll: float) -> Transform3D:
	var local := Transform3D(Basis(Vector3.RIGHT, deg_to_rad(DEFAULT_FP_PITCH_DEG)), DEFAULT_EYE)
	if first_person_camera != null:
		local = _to_model_space(first_person_camera)
	var pos := transform * (lean_pivot.transform * local.origin)
	var roll_b := Basis(Vector3.BACK, -roll)
	return Transform3D(transform.basis * roll_b * local.basis.orthonormalized(), pos)


func first_person_fov() -> float:
	return first_person_camera.fov if first_person_camera != null else DEFAULT_FP_FOV


## The node's transform relative to this model (works however deep it's nested).
func _to_model_space(n: Node3D) -> Transform3D:
	var xf := n.transform
	var p := n.get_parent()
	while p != null and p != self:
		if p is Node3D:
			xf = (p as Node3D).transform * xf
		p = p.get_parent()
	return xf


func _steer_pivot() -> Vector3:
	return Vector3(0.0, 0.0, head_tube_bottom.z)


func _shoulder(side: float) -> Vector3:
	return shoulder + Vector3(side * shoulder_half_width, 0.0, 0.0)


func _bar_bend(side: float) -> Vector3:
	return handlebar + Vector3(side * handlebar_half_width * 0.45, 0.0, 0.0)


func _bar_end(side: float) -> Vector3:
	return handlebar + Vector3(side * handlebar_half_width, handlebar_rise, handlebar_sweep)


## Where the hand holds the bar (bike space, steering straight).
func _grip(side: float) -> Vector3:
	if _model_grips.size() == 2:
		return _model_grips[0 if side < 0.0 else 1]
	return _bar_bend(side).lerp(_bar_end(side), 0.7)


## Builds the handlebar GLB into one mesh under steer_node (bike space + off):
## turned by model_yaw_deg, its stem shortened, scaled to model_grip_width,
## mounted on the head tube, tilted, and cut below model_cut_below.
## Also finds the grip centres for the hands. Leaves handlebar_mesh null if the
## scene has no mesh.
func _build_handlebar_model(off: Vector3) -> void:
	var src := handlebar_model.instantiate()
	var meshes := src.find_children("*", "MeshInstance3D", true, false)
	if meshes.is_empty():
		src.free()
		return
	var yaw := Basis(Vector3.UP, deg_to_rad(model_yaw_deg))
	var cut := (model_stem_band.y - model_stem_band.x) * (1.0 - model_stem_keep)

	# Pass 1: every surface in the GLB's space, stem shortened, yawed.
	var surfaces: Array[Array] = []  # [arrays, material, normal basis]
	var lo := INF
	var hi := -INF
	for n in meshes:
		var mi := n as MeshInstance3D
		var xf := mi.transform
		var p := mi.get_parent()
		while p != null and p != src:
			if p is Node3D:
				xf = (p as Node3D).transform * xf
			p = p.get_parent()
		for s in mi.mesh.get_surface_count():
			var arrays := mi.mesh.surface_get_arrays(s)
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			for i in verts.size():
				var v := xf * verts[i]
				if v.y > model_stem_band.y:
					v.y -= cut
				elif v.y > model_stem_band.x:
					v.y = model_stem_band.x + (v.y - model_stem_band.x) * model_stem_keep
				v = yaw * v
				verts[i] = v
				lo = minf(lo, v.y)
				hi = maxf(hi, v.y)
			arrays[Mesh.ARRAY_VERTEX] = verts
			var mat := mi.get_active_material(s)
			if mat is BaseMaterial3D:
				mat = mat.duplicate()
				(mat as BaseMaterial3D).metallic *= model_shine
				(mat as BaseMaterial3D).albedo_color *= model_tint
			surfaces.append([arrays, mat, yaw * xf.basis.orthonormalized()])

	# Grips: the top 8 % of the model, split into left and right.
	var band := hi - (hi - lo) * 0.08
	var top: Array[Vector3] = []
	var mid_x := 0.0
	for sf in surfaces:
		for v: Vector3 in (sf[0] as Array)[Mesh.ARRAY_VERTEX]:
			if v.y >= band:
				top.append(v)
				mid_x += v.x
	mid_x /= maxf(top.size(), 1.0)
	var sums := [Vector3.ZERO, Vector3.ZERO]
	var counts := [0, 0]
	for v in top:
		var k := 0 if v.x < mid_x else 1
		sums[k] += v
		counts[k] += 1
	if counts[0] == 0 or counts[1] == 0:
		src.free()
		return
	var g_left: Vector3 = sums[0] / counts[0]
	var g_right: Vector3 = sums[1] / counts[1]
	# Mount point: the stem's centre line at the bottom of the (shortened) stem.
	var stem_sum := Vector3.ZERO
	var stem_n := 0
	var stem_top := model_stem_band.x + (model_stem_band.y - model_stem_band.x) * model_stem_keep
	for sf in surfaces:
		for v: Vector3 in (sf[0] as Array)[Mesh.ARRAY_VERTEX]:
			if v.y >= model_stem_band.x and v.y <= stem_top:
				stem_sum += v
				stem_n += 1
	var mount := Vector3(0.0, model_stem_band.x, 0.0)
	if stem_n > 0:
		mount.z = stem_sum.z / stem_n
	mount.x = (g_left.x + g_right.x) * 0.5  # keep the grips symmetric
	var scale_f := model_grip_width / maxf(g_left.distance_to(g_right), 0.001)
	var tilt := Basis(Vector3.RIGHT, -deg_to_rad(model_tilt_deg))
	var anchor := Vector3(0.0, head_tube_top.y, head_tube_bottom.z) + model_offset
	var place := func(v: Vector3) -> Vector3:
		return anchor + tilt * ((v - mount) * scale_f)
	_model_grips = [place.call(g_left), place.call(g_right)]

	# Pass 2: place, drop triangles entirely below model_cut_below, build the mesh.
	var mesh := ArrayMesh.new()
	for sf in surfaces:
		var arrays: Array = sf[0]
		var turn: Basis = tilt * (sf[2] as Basis)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bike_y := PackedFloat32Array()
		bike_y.resize(verts.size())
		for i in verts.size():
			var v: Vector3 = place.call(verts[i])
			bike_y[i] = v.y
			verts[i] = v + off
		arrays[Mesh.ARRAY_VERTEX] = verts
		var normals = arrays[Mesh.ARRAY_NORMAL]
		if normals is PackedVector3Array:
			var nrm := normals as PackedVector3Array
			for i in nrm.size():
				nrm[i] = (turn * nrm[i]).normalized()
			arrays[Mesh.ARRAY_NORMAL] = nrm
		var tangents = arrays[Mesh.ARRAY_TANGENT]
		if tangents is PackedFloat32Array:
			var tan := tangents as PackedFloat32Array
			for i in range(0, tan.size(), 4):
				var t := (turn * Vector3(tan[i], tan[i + 1], tan[i + 2])).normalized()
				tan[i] = t.x
				tan[i + 1] = t.y
				tan[i + 2] = t.z
			arrays[Mesh.ARRAY_TANGENT] = tan
		var idx = arrays[Mesh.ARRAY_INDEX]
		if idx is PackedInt32Array:
			var kept := PackedInt32Array()
			var ids := idx as PackedInt32Array
			for i in range(0, ids.size(), 3):
				if bike_y[ids[i]] < model_cut_below and bike_y[ids[i + 1]] < model_cut_below and bike_y[ids[i + 2]] < model_cut_below:
					continue
				kept.append(ids[i])
				kept.append(ids[i + 1])
				kept.append(ids[i + 2])
			if kept.is_empty():
				continue
			arrays[Mesh.ARRAY_INDEX] = kept
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		if sf[1] != null:
			mesh.surface_set_material(mesh.get_surface_count() - 1, sf[1])
	src.free()
	if mesh.get_surface_count() == 0:
		_model_grips.clear()
		return
	handlebar_mesh = MeshInstance3D.new()
	handlebar_mesh.name = "HandlebarModel"
	handlebar_mesh.mesh = mesh
	steer_node.add_child(handlebar_mesh)


## Two-bone IK: the middle joint for a limb from root to end, bending towards pole.
static func _ik(root: Vector3, end: Vector3, l1: float, l2: float, pole: Vector3) -> Vector3:
	var to_end := end - root
	var d := clampf(to_end.length(), 0.05, l1 + l2 - 0.001)
	var u := to_end.normalized()
	var n := pole - u * u.dot(pole)
	n = n.normalized() if n.length() > 0.0001 else Vector3.UP
	var along := (l1 * l1 - l2 * l2 + d * d) / (2.0 * d)
	var h := sqrt(maxf(l1 * l1 - along * along, 0.0))
	return root + u * along + n * h
