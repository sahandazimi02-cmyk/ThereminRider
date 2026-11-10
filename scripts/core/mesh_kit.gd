@tool
## Small helpers for building low-poly props out of primitive meshes.
class_name MeshKit
extends RefCounted

const LOW_SEGMENTS := 8


static func box(parent: Node3D, size: Vector3, pos: Vector3, color_id: String) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _add(parent, mesh, pos, color_id)


static func sphere(parent: Node3D, radius: float, pos: Vector3, color_id: String) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = LOW_SEGMENTS
	mesh.rings = 4
	return _add(parent, mesh, pos, color_id)


## Upright cylinder (or cone if top_radius is 0), base centred on pos.
static func cylinder(parent: Node3D, bottom_radius: float, top_radius: float, height: float,
		pos: Vector3, color_id: String, segments: int = LOW_SEGMENTS) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = bottom_radius
	mesh.top_radius = top_radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	return _add(parent, mesh, pos + Vector3(0.0, height * 0.5, 0.0), color_id)


## Unit-height cylinder that place_tube() stretches between two points.
static func tube(parent: Node3D, radius: float, color_id: String, segments: int = 6) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 1.0
	mesh.radial_segments = segments
	mesh.rings = 1
	return _add(parent, mesh, Vector3.ZERO, color_id)


static func tube_between(parent: Node3D, a: Vector3, b: Vector3, radius: float,
		color_id: String) -> MeshInstance3D:
	var t := tube(parent, radius, color_id)
	place_tube(t, a, b)
	return t


## Points a unit cylinder from a to b (in the parent's space).
static func place_tube(node: Node3D, a: Vector3, b: Vector3) -> void:
	var d := b - a
	var length := d.length()
	if length < 0.0001:
		node.visible = false
		return
	node.visible = true
	var y := d / length
	var ref := Vector3.FORWARD if absf(y.dot(Vector3.FORWARD)) < 0.99 else Vector3.RIGHT
	var x := ref.cross(y).normalized()
	var z := x.cross(y).normalized()
	node.transform = Transform3D(Basis(x, y * length, z), (a + b) * 0.5)


## Wheel-like ring whose axle is the X axis.
static func ring_x(parent: Node3D, radius: float, thickness: float, pos: Vector3,
		color_id: String) -> MeshInstance3D:
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - thickness
	mesh.outer_radius = radius
	mesh.rings = 20
	mesh.ring_segments = 6
	var mi := _add(parent, mesh, pos, color_id)
	mi.rotation = Vector3(0.0, 0.0, PI * 0.5)
	return mi


static func _add(parent: Node3D, mesh: Mesh, pos: Vector3, color_id: String) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = Palette.mat(color_id)
	mi.position = pos
	parent.add_child(mi)
	return mi
