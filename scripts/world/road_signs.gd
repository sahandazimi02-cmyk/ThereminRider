## Roadside signs from the user's sign exports in res://Assets/:
##   "Roaad signs used random.glb": ordinary signs placed now and then.
##   "Roaad signs hazards.glb": the warning signs "roadwork", "pothole", "cow",
##   placed a little before those hazards.
## Each GLB holds the signs as loose meshes scattered around the Blender scene.
## Every mesh's own origin is the foot of its post and the sign face looks
## +Z, so a sign is rebuilt at the origin, scaled to RoadTuning.sign_height_m
## (hazard_sign_height_m for warnings)
## and needs no turning to face a rider coming down the road (-Z).
class_name RoadSigns
extends RefCounted

const RANDOM_SOURCE := "res://Assets/Roaad signs used random.glb"
const HAZARD_SOURCE := "res://Assets/Roaad signs hazards.glb"

## Warning signs in the hazard file (node names).
const HAZARD_SIGNS := ["roadwork", "pothole", "cow"]
## Random-file signs that are copies of the hazard warnings ("ROAD WORK AHEAD",
## the digging worker): never used at random, so they only ever mean a hazard.
const NOT_RANDOM := ["Cube_071", "Cube_079"]
## Chevron and big arrow: the usual sign before a right bend, never elsewhere.
const CURVE_SIGNS := ["Cube_055", "Cube_077"]
## Detour and one-way also point right: only before a right bend too, so no
## sign ever points the wrong way. (Left bends get no arrow: the signs are
## right-pointing only, and a mirrored copy renders dark.)
const RIGHT_ONLY := ["Cube_067", "Cube_089"]
## Road counts as bending when its curvature is above this (rad/m, ~500 m radius).
const BEND_K := 0.002

## One placed sign, in road coordinates.
class Placed:
	var s := 0.0
	## Signed offset of the post from the centre line (+ = right).
	var lateral := 0.0
	var sign_name := ""
	var hazard := false
	## Post foot to sign top (m).
	var height := 3.0
	var node: Node3D = null

## name -> { "mesh": Mesh, "aabb": AABB }
static var _signs: Dictionary = {}
static var _random_names: Array[String] = []
static var _loaded := false


static func has(sign_name: String) -> bool:
	_load()
	return _signs.has(sign_name)


## Warning sign for a hazard kind, or "" (cars have none).
static func hazard_sign_for(kind: Obstacle.Kind) -> String:
	match kind:
		Obstacle.Kind.CONES, Obstacle.Kind.BARRIER:
			return "roadwork"
		Obstacle.Kind.POTHOLE:
			return "pothole"
		Obstacle.Kind.COW:
			return "cow"
	return ""


## Random sign for a spot where the road ahead bends by `bend` (rad/m,
## + = right), or "" if none loaded.
static func pick_random(rng: RandomNumberGenerator, bend: float) -> String:
	_load()
	var right_bend := bend > BEND_K
	if right_bend and rng.randf() < 0.6:
		var curve: Array[String] = []
		for n: String in CURVE_SIGNS:
			if _random_names.has(n):
				curve.append(n)
		if not curve.is_empty():
			return curve[rng.randi() % curve.size()]
	var options: Array[String] = []
	for n in _random_names:
		if (n in CURVE_SIGNS or n in RIGHT_ONLY) and not right_bend:
			continue
		options.append(n)
	if options.is_empty():
		return ""
	return options[rng.randi() % options.size()]


## True for signs with an arrow pointing right (only placed before right bends).
static func points_right(sign_name: String) -> bool:
	return sign_name in CURVE_SIGNS or sign_name in RIGHT_ONLY


## Scale that makes a sign sign_height_m tall.
static func scale_of(sign_name: String, height_m: float) -> float:
	_load()
	if not _signs.has(sign_name):
		return 1.0
	var box: AABB = _signs[sign_name]["aabb"]
	return height_m / maxf(box.end.y, 0.01)


## Sideways extent of the scaled sign around its post (x = left edge, y = right
## edge, both relative to the post).
static func span_of(sign_name: String, height_m: float) -> Vector2:
	_load()
	if not _signs.has(sign_name):
		return Vector2(-0.5, 0.5)
	var box: AABB = _signs[sign_name]["aabb"]
	var k := scale_of(sign_name, height_m)
	return Vector2(box.position.x * k, box.end.x * k)


## The sign under a new Node3D: post foot at the origin, face towards +Z.
static func build(sign_name: String, height_m: float) -> Node3D:
	_load()
	var root := Node3D.new()
	root.name = "Sign_" + sign_name
	if not _signs.has(sign_name):
		return root
	var mi := MeshInstance3D.new()
	mi.mesh = _signs[sign_name]["mesh"]
	var k := scale_of(sign_name, height_m)
	mi.scale = Vector3.ONE * k
	root.add_child(mi)
	return root


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_read(HAZARD_SOURCE, false)
	_read(RANDOM_SOURCE, true)


static func _read(path: String, random: bool) -> void:
	if not ResourceLoader.exists(path):
		push_warning("RoadSigns: %s missing, no signs from it" % path)
		return
	var scene := load(path) as PackedScene
	if scene == null:
		return
	var root := scene.instantiate()
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null:
			continue
		var n := String(mi.name)
		# The hazard file also has the ordinary signs; only its warnings are used.
		if (random and n in NOT_RANDOM) or (not random and n not in HAZARD_SIGNS):
			continue
		if random:
			_random_names.append(n)
		_signs[n] = {"mesh": mi.mesh, "aabb": mi.mesh.get_aabb()}
	root.free()
