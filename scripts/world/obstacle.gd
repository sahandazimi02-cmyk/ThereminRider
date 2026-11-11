## One obstacle on the road, in road coordinates (s along, lateral across).
## ONCOMING cars and COWs move (RoadWorld.update_movers); everything else
## stays put.
class_name Obstacle
extends RefCounted

enum Kind { CONES, BARRIER, CAR, POTHOLE, ONCOMING, COW }

const KIND_NAMES := ["cones", "barrier", "car", "pothole", "oncoming", "cow"]

const COW_SCENE := "res://Assets/cow/source/Cow.glb"
const COW_WALK_ANIM := "walking"
const COW_IDLE_ANIM := "iddle"  # (sic) the name in the GLB
const COW_MOO_SOUND := "res://Assets/audio/moo.wav"
## Cow model proportions (width / length), so the hit box matches the model.
const COW_WIDTH_RATIO := 0.28
## Extra yaw so the cow model's head points the way it walks (the model faces -Z:
## its front legs and neck bones are at -Z).
const COW_FACING := PI

var kind: Kind = Kind.CONES
var s := 0.0
var lateral := 0.0
var half_along := 0.3
var half_lateral := 0.3
## false = rideable hazard (pothole wobbles you instead of crashing you).
var crashes := true
var hit := false
var node: Node3D = null
## Car pack vehicle (VehiclePack index) for CAR / ONCOMING, -1 = none.
var variant := -1

# ---- moving hazards
## Where it was placed (restart puts it back here).
var start_s := 0.0
var start_lateral := 0.0
## ONCOMING: driving speed (m/s). COW: walking speed across the road.
var speed := 0.0
## ONCOMING: starts driving when the bike is this close. Its reserved stretch
## of road reaches this far back from start_s.
var trigger_m := 0.0
## COW: starts walking when the bike is this many seconds away.
var lead_s := 0.0
## COW: walks from start_lateral to end_lateral.
var end_lateral := 0.0
var active := false
## Stopped for good (hit, or braked for a crash).
var stopped := false
var anim: AnimationPlayer = null
## COW: 3D moo player on the cow node (null until the node is built).
var moo_player: AudioStreamPlayer3D = null


static func make(k: Kind, s_m: float, lateral_m: float, lane_width: float) -> Obstacle:
	var o := Obstacle.new()
	o.kind = k
	o.s = s_m
	o.lateral = lateral_m
	match k:
		Kind.CONES:
			o.half_along = 0.25
			o.half_lateral = lane_width * 0.38
		Kind.BARRIER:
			o.half_along = 0.2
			o.half_lateral = lane_width * 0.42
		Kind.CAR:
			o.half_along = 2.1
			o.half_lateral = 0.85
		Kind.POTHOLE:
			o.half_along = 0.75
			o.half_lateral = 0.68
			o.crashes = false
	o.start_s = s_m
	o.start_lateral = lateral_m
	return o


## CAR / ONCOMING: use car pack vehicle `index` and size the hit box to it.
func set_vehicle(index: int, tuning: RoadTuning) -> void:
	variant = index
	var size := VehiclePack.size_of(index, tuning)
	half_lateral = size.x * 0.5 * tuning.vehicle_hit_width
	half_along = size.y * 0.5


## ONCOMING: drives towards the bike once it's within trigger metres.
func setup_oncoming(drive_speed: float, trigger: float) -> void:
	speed = drive_speed
	trigger_m = trigger


## COW: waits beside the road on `side` (-1 left, +1 right) and walks across.
func setup_cow(tuning: RoadTuning, rail_offset: float, side: float, lead: float) -> void:
	half_lateral = tuning.cow_length_m * 0.5 * 0.9
	half_along = tuning.cow_length_m * COW_WIDTH_RATIO * 0.5
	start_lateral = side * (rail_offset + tuning.cow_side_m)
	end_lateral = -start_lateral
	lateral = start_lateral
	speed = tuning.cow_speed_mps
	lead_s = lead


func is_mover() -> bool:
	return kind == Kind.ONCOMING or kind == Kind.COW


## Puts a moving hazard back where it started (restart).
func reset_motion() -> void:
	s = start_s
	lateral = start_lateral
	active = false
	stopped = false


## Name for crash messages ("hit the ...").
func display_name() -> String:
	match kind:
		Kind.CAR:
			return "truck" if VehiclePack.is_long(variant) else "car"
		Kind.ONCOMING:
			return "oncoming truck" if VehiclePack.is_long(variant) else "oncoming car"
	return kind_name()


# ---- spacing: the stretch of road a hazard needs to itself.

## Centre (along s) of the reserved stretch.
func zone_center() -> float:
	return start_s - trigger_m * 0.5 if kind == Kind.ONCOMING else start_s


func zone_half() -> float:
	return half_along + (trigger_m * 0.5 if kind == Kind.ONCOMING else 0.0)


## Lanes it can block: bit 0 = left lane, bit 1 = right lane.
func lanes() -> int:
	if kind == Kind.COW:
		return 3
	return 1 if start_lateral < 0.0 else 2


## Moves the hazard (and its reserved stretch) along the road.
func shift(ds: float) -> void:
	s += ds
	start_s += ds


static func kind_from_name(n: String) -> Kind:
	var i := KIND_NAMES.find(n)
	return (i if i >= 0 else 0) as Kind


func kind_name() -> String:
	return KIND_NAMES[int(kind)]


func overlaps(bike_s: float, bike_lat: float, bike_half_len: float, bike_half_wid: float) -> bool:
	return absf(bike_s - s) < half_along + bike_half_len \
			and absf(bike_lat - lateral) < half_lateral + bike_half_wid


## Builds the visual. Local origin on the road, forward -Z, across X.
## Cones and barriers are built from separate "piece" nodes (direct children)
## so a crash can knock each piece flying.
func build_node(tuning: RoadTuning, rng: RandomNumberGenerator) -> Node3D:
	var root := Node3D.new()
	root.name = "Obstacle_" + kind_name()
	match kind:
		Kind.CAR, Kind.ONCOMING:
			if variant < 0:
				_box_car(root, rng)
			else:
				var v := VehiclePack.build(variant, tuning)
				# Oncoming cars face the bike; parked ones either way.
				if kind == Kind.ONCOMING or rng.randf() < 0.5:
					v.rotation.y = PI
				root.add_child(v)
		Kind.COW:
			_build_cow(root, tuning)
		Kind.CONES:
			var spread := half_lateral
			for i in 3:
				var cone := Node3D.new()
				cone.position = Vector3(lerpf(-spread, spread, float(i) / 2.0), 0.0, 0.0)
				root.add_child(cone)
				MeshKit.box(cone, Vector3(0.36, 0.04, 0.36), Vector3(0, 0.02, 0.0), "cone")
				MeshKit.cylinder(cone, 0.17, 0.03, 0.62, Vector3(0, 0.04, 0.0), "cone")
				MeshKit.cylinder(cone, 0.115, 0.095, 0.08, Vector3(0, 0.32, 0.0), "cone_band")
		Kind.BARRIER:
			var w := half_lateral * 2.0
			for x: float in [-half_lateral * 0.85, half_lateral * 0.85]:
				var leg := Node3D.new()
				leg.position = Vector3(x, 0.0, 0.0)
				root.add_child(leg)
				MeshKit.box(leg, Vector3(0.06, 0.9, 0.06), Vector3(0, 0.45, 0.0), "barrier_white")
				MeshKit.box(leg, Vector3(0.12, 0.05, 0.5), Vector3(0, 0.025, 0.0), "rail_post")
			var board := Node3D.new()
			board.position = Vector3(0.0, 0.72, 0.0)
			root.add_child(board)
			var stripes := 6
			for i in stripes:
				var c := "barrier_red" if i % 2 == 0 else "barrier_white"
				var sw := w / float(stripes)
				MeshKit.box(board, Vector3(sw, 0.28, 0.05), Vector3(-w * 0.5 + sw * (float(i) + 0.5), 0.0, 0.0), c)
		Kind.POTHOLE:
			# Broken-asphalt rim, near-black hole, pitch-black centre and rubble so
			# it reads clearly from a distance. Two offset ovals = irregular edge.
			var stretch := half_along / half_lateral
			var r := half_lateral
			for ring: Array in [[1.22, 0.003, 0.006, "pothole_rim"], [1.0, 0.004, 0.012, "pothole"], [0.6, 0.006, 0.012, "pothole_deep"]]:
				var k: float = ring[0]
				var y: float = ring[1]
				var h: float = ring[2]
				var id: String = ring[3]
				var a := MeshKit.cylinder(root, r * k, r * k, h, Vector3(0, y, 0), id, 9)
				a.scale = Vector3(1.0, 1.0, stretch)
				var b := MeshKit.cylinder(root, r * k * 0.82, r * k * 0.82, h, Vector3(r * 0.22, y, -half_along * 0.25), id, 7)
				b.scale = Vector3(1.0, 1.0, stretch)
				b.rotation.y = 0.6
			for i in 7:
				var ang := TAU * float(i) / 7.0 + rng.randf() * 0.5
				var p := Vector3(cos(ang) * r * 1.15, 0.0, sin(ang) * half_along * 1.15)
				var chunk := MeshKit.box(root, Vector3(0.12, 0.05, 0.09) * rng.randf_range(0.7, 1.4), p + Vector3(0, 0.025, 0), "pothole_rim")
				chunk.rotation.y = rng.randf() * TAU
	return root


## Fallback box car, only if the car pack can't be loaded.
func _box_car(root: Node3D, rng: RandomNumberGenerator) -> void:
	var colors := ["car_a", "car_b", "car_c"]
	var body: String = colors[rng.randi() % colors.size()]
	MeshKit.box(root, Vector3(1.7, 0.7, 4.1), Vector3(0, 0.6, 0), body)
	MeshKit.box(root, Vector3(1.5, 0.55, 2.1), Vector3(0, 1.22, 0.25), body)
	MeshKit.box(root, Vector3(1.52, 0.42, 2.0), Vector3(0, 1.22, 0.25), "car_glass")
	for wx: float in [-0.78, 0.78]:
		for wz: float in [-1.3, 1.3]:
			var wheel := MeshKit.cylinder(root, 0.33, 0.33, 0.24, Vector3.ZERO, "tire", 10)
			wheel.rotation = Vector3(0, 0, PI * 0.5)
			wheel.position = Vector3(wx, 0.33, wz)


## The cow model, turned to face the way it walks (across the road), scaled
## to cow_length_m, idling until it starts walking.
func _build_cow(root: Node3D, tuning: RoadTuning) -> void:
	var scene := load(COW_SCENE) as PackedScene
	if scene == null:
		MeshKit.box(root, Vector3(tuning.cow_length_m, 1.3, half_along * 2.0), Vector3(0, 0.9, 0), "dust")
		return
	var model := scene.instantiate() as Node3D
	var length := 0.0
	for mi: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		length = maxf(length, mi.get_aabb().size.z)
	model.scale = Vector3.ONE * (tuning.cow_length_m / maxf(length, 0.01))
	# Turn the model so it walks across the road (+X = towards the right side;
	# yaw +90 deg turns the model's +Z to +X).
	var pivot := Node3D.new()
	pivot.name = "CowPivot"
	pivot.rotation.y = COW_FACING + (PI * 0.5 if end_lateral > start_lateral else -PI * 0.5)
	pivot.add_child(model)
	root.add_child(pivot)
	anim = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim != null:
		for n: String in [COW_WALK_ANIM, COW_IDLE_ANIM]:
			if anim.has_animation(n):
				anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
		play_cow(active and not stopped, tuning.cow_anim_speed)
	var moo := load(COW_MOO_SOUND) as AudioStream
	if moo != null:
		moo_player = AudioStreamPlayer3D.new()
		moo_player.name = "Moo"
		moo_player.stream = moo
		moo_player.volume_db = tuning.cow_moo_volume_db
		moo_player.unit_size = tuning.cow_moo_unit_m
		moo_player.max_distance = tuning.cow_moo_max_m
		moo_player.position = Vector3(0, 1.2, 0)
		root.add_child(moo_player)


## The cow moos (once per call), pitch picked at random.
func moo(tuning: RoadTuning, rng: RandomNumberGenerator) -> void:
	if moo_player == null or not is_instance_valid(moo_player) or not moo_player.is_inside_tree():
		return
	moo_player.pitch_scale = 1.0 + rng.randf_range(-tuning.cow_moo_pitch_jitter, tuning.cow_moo_pitch_jitter)
	moo_player.play()


## Walk or idle animation for the cow.
func play_cow(walking: bool, anim_speed: float) -> void:
	if anim == null or not is_instance_valid(anim):
		return
	var n := COW_WALK_ANIM if walking else COW_IDLE_ANIM
	if not anim.has_animation(n):
		return
	if anim.current_animation != n:
		anim.play(n, 0.25)
	anim.speed_scale = anim_speed if walking else 1.0
