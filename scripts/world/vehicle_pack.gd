## The low-poly car pack (res://Assets/10-lowpoly-cars/source/cars.fbx).
## The FBX holds all 10 vehicles as loose meshes side by side, so on first use
## this groups the meshes into vehicles (touching boxes = one vehicle), centres
## each one, turns it to face -Z (the road's forward), scales it to
## RoadTuning.vehicle_width_m and stretches the long ones (trucks, bus) to
## truck_length_m. Wheels are only moved when stretching, never squashed.
class_name VehiclePack
extends RefCounted

const SOURCE := "res://Assets/10-lowpoly-cars/source/cars.fbx"
## A vehicle at least this long in the FBX counts as a truck / bus.
const LONG_SOURCE_M := 7.0
## Meshes bigger than this are scenery in the FBX (the ground plane), not a vehicle.
const SCENERY_M := 20.0
## Boxes closer than this belong to the same vehicle.
const JOIN_M := 0.05

## One entry per vehicle: { "meshes": [[Mesh, Transform3D, is_wheel]], "length": float, "width": float, "long": bool }
static var _vehicles: Array = []
static var _loaded := false


static func count() -> int:
	_load()
	return _vehicles.size()


## Picks a vehicle: a truck/bus with chance truck_chance, otherwise a car.
static func pick(rng: RandomNumberGenerator, truck_chance: float) -> int:
	_load()
	if _vehicles.is_empty():
		return -1
	var want_long := rng.randf() < truck_chance
	var options: Array[int] = []
	for i in _vehicles.size():
		if bool(_vehicles[i]["long"]) == want_long:
			options.append(i)
	if options.is_empty():
		return rng.randi() % _vehicles.size()
	return options[rng.randi() % options.size()]


static func is_long(index: int) -> bool:
	_load()
	return index >= 0 and index < _vehicles.size() and bool(_vehicles[index]["long"])


## Size on the road (x = width, y = length) after scaling/stretching.
static func size_of(index: int, tuning: RoadTuning) -> Vector2:
	_load()
	if index < 0 or index >= _vehicles.size():
		return Vector2(1.7, 4.1)
	var v: Dictionary = _vehicles[index]
	var u := tuning.vehicle_width_m / float(v["width"])
	var length := float(v["length"]) * u
	if bool(v["long"]):
		length = maxf(length, tuning.truck_length_m)
	return Vector2(tuning.vehicle_width_m, length)


## Builds the vehicle under a new Node3D: origin on the ground at its centre,
## front towards -Z.
static func build(index: int, tuning: RoadTuning) -> Node3D:
	_load()
	var root := Node3D.new()
	root.name = "Vehicle"
	if index < 0 or index >= _vehicles.size():
		return root
	var v: Dictionary = _vehicles[index]
	var u := tuning.vehicle_width_m / float(v["width"])
	var stretch := size_of(index, tuning).y / (float(v["length"]) * u)
	# Pack space: +X = front. Road space: -Z = front.
	var face := Basis(Vector3.UP, PI * 0.5)
	var squash := Basis.from_scale(Vector3(stretch, 1.0, 1.0))
	for entry: Array in v["meshes"]:
		var mi := MeshInstance3D.new()
		mi.mesh = entry[0]
		var t: Transform3D = entry[1]
		t = Transform3D(Basis.from_scale(Vector3.ONE * u), Vector3.ZERO) * t
		if bool(entry[2]):
			t.origin = squash * t.origin  # wheel: move it, keep it round
		else:
			t = Transform3D(squash, Vector3.ZERO) * t
		mi.transform = Transform3D(face, Vector3.ZERO) * t
		root.add_child(mi)
	return root


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	if not ResourceLoader.exists(SOURCE):
		push_warning("VehiclePack: %s missing, cars fall back to boxes" % SOURCE)
		return
	var scene := load(SOURCE) as PackedScene
	if scene == null:
		return
	var root := scene.instantiate()
	var items: Array = []  # [Mesh, Transform3D, AABB]
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null:
			continue
		var t := _relative(mi, root)
		var box := t * mi.mesh.get_aabb()
		if box.size.x > SCENERY_M or box.size.z > SCENERY_M:
			continue
		items.append([mi.mesh, t, box])
	root.free()
	# Union-find on touching boxes.
	var parent: Array[int] = []
	for i in items.size():
		parent.append(i)
	for i in items.size():
		var a: AABB = (items[i][2] as AABB).grow(JOIN_M)
		for j in range(i + 1, items.size()):
			if a.intersects(items[j][2]):
				var ri := _find(parent, i)
				var rj := _find(parent, j)
				if ri != rj:
					parent[rj] = ri
	var groups := {}
	for i in items.size():
		var r := _find(parent, i)
		if not groups.has(r):
			groups[r] = []
		(groups[r] as Array).append(i)
	var keys := groups.keys()
	keys.sort()
	for r: int in keys:
		var members: Array = groups[r]
		var box: AABB = items[members[0]][2]
		for i: int in members:
			box = box.merge(items[i][2])
		var centre := Vector3(box.get_center().x, box.position.y, box.get_center().z)
		var meshes: Array = []
		for i: int in members:
			var t: Transform3D = items[i][1]
			t.origin -= centre
			var mb: AABB = items[i][2]
			# Wheels: small, round in the side view (X/Y), thin across (Z).
			var wheel := mb.size.y > 0.4 and mb.size.y < 1.4 and absf(mb.size.x - mb.size.y) < mb.size.y * 0.15 and mb.size.z < mb.size.y * 0.6
			meshes.append([items[i][0], t, wheel])
		_vehicles.append({
			"meshes": meshes,
			"length": box.size.x,
			"width": box.size.z,
			"long": box.size.x >= LONG_SOURCE_M,
		})


static func _find(parent: Array[int], i: int) -> int:
	while parent[i] != i:
		parent[i] = parent[parent[i]]
		i = parent[i]
	return i


static func _relative(n: Node, root: Node) -> Transform3D:
	var t := Transform3D()
	var cur := n
	while cur != null and cur != root:
		if cur is Node3D:
			t = (cur as Node3D).transform * t
		cur = cur.get_parent()
	return t
