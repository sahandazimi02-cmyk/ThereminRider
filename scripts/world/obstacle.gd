## One obstacle on the road, in road coordinates (s along, lateral across).
class_name Obstacle
extends RefCounted

enum Kind { CONES, BARRIER, CAR, POTHOLE }

const KIND_NAMES := ["cones", "barrier", "car", "pothole"]

var kind: Kind = Kind.CONES
var s := 0.0
var lateral := 0.0
var half_along := 0.3
var half_lateral := 0.3
## false = rideable hazard (pothole wobbles you instead of crashing you).
var crashes := true
var hit := false
var node: Node3D = null


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
	return o


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
func build_node(lane_width: float, rng: RandomNumberGenerator) -> Node3D:
	var root := Node3D.new()
	root.name = "Obstacle_" + kind_name()
	match kind:
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
		Kind.CAR:
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
