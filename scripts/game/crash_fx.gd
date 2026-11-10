## One-shot visual effects for crashes: sparks, dust, debris bursts, and the
## Tumbler that knocks obstacle pieces flying. Visual only, no gameplay.
class_name CrashFx
extends RefCounted


## A burst of little cubes flying up and out from pos.
static func burst(parent: Node, pos: Vector3, color_id: String, amount: int, speed: float,
		size: float, lifetime: float = 1.0, glow: bool = false, spread_deg: float = 70.0) -> void:
	var p := CPUParticles3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * size
	p.mesh = mesh
	p.material_override = Palette.glow_mat(color_id) if glow else Palette.mat(color_id)
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = maxi(amount, 1)
	p.lifetime = lifetime
	p.direction = Vector3.UP
	p.spread = spread_deg
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.gravity = Vector3(0.0, -9.8, 0.0)
	p.angular_velocity_min = -540.0
	p.angular_velocity_max = 540.0
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.3
	p.damping_min = 0.5
	p.damping_max = 2.0
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	p.finished.connect(p.queue_free)


## Soft dust puff (bigger, slower, short-lived).
static func dust(parent: Node, pos: Vector3, amount: int = 14) -> void:
	burst(parent, pos, "dust", amount, 2.2, 0.16, 0.8, false, 85.0)


## Sends a piece (a Node3D inside an obstacle) flying. velocity and spin are
## in the piece's parent space.
static func knock_piece(piece: Node3D, velocity: Vector3, spin: Vector3) -> void:
	var t := Tumbler.new()
	t.velocity = velocity
	t.spin = spin
	piece.add_child(t)


## Moves its parent like a thrown object until it settles on the ground (y=0
## in the parent's parent space), then removes itself.
class Tumbler:
	extends Node
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var _rest := 0.0

	func _physics_process(dt: float) -> void:
		var p := get_parent() as Node3D
		if p == null:
			queue_free()
			return
		velocity.y -= 9.81 * dt
		p.position += velocity * dt
		var w := spin.length()
		if w > 0.001:
			p.basis = (Basis(spin / w, w * dt) * p.basis).orthonormalized()
		if p.position.y < 0.0:
			p.position.y = 0.0
			if velocity.y < -1.2:
				velocity.y = -velocity.y * 0.35
				velocity.x *= 0.6
				velocity.z *= 0.6
				spin *= 0.6
			else:
				velocity = Vector3(velocity.x, 0.0, velocity.z) * exp(-6.0 * dt)
				spin *= exp(-6.0 * dt)
				_rest += dt
				if _rest > 1.5:
					queue_free()
