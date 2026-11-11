## Owns the road: centre line, mesh chunks (asphalt, lines, rails, scenery),
## obstacles, and the endless generator. Builds ahead of the bike and frees
## what is far behind.
class_name RoadWorld
extends Node3D

var tuning: RoadTuning
var endless := true
var path: RoadPath
## Course mode: distance of the finish line (-1 in endless).
var finish_s := -1.0
var obstacles: Array[Obstacle] = []
## Roadside signs (ordinary ones now and then, warnings before hazards).
var signs: Array[RoadSigns.Placed] = []
## 0..1 endless difficulty (driven by distance).
var difficulty := 0.0

var _rng := RandomNumberGenerator.new()
## Separate RNG for crash effects so they never change the generated road.
var _fx_rng := RandomNumberGenerator.new()
## Separate RNG for roadside signs so they never change the generated road.
var _sign_rng := RandomNumberGenerator.new()
## Separate RNG for sound variation (moo pitch) so it never changes the road.
var _sfx_rng := RandomNumberGenerator.new()
var _next_sign_s := 0.0
var _chunks: Dictionary = {}  # int -> Node3D
var _next_obstacle_s := 0.0
var _last_lane := 1
var _post_mesh: BoxMesh
var _trunk_mesh: CylinderMesh
var _leaf_meshes: Array[CylinderMesh] = []
var _rock_mesh: SphereMesh


func setup(road_tuning: RoadTuning, is_endless: bool, seed_value: int = 0) -> void:
	tuning = road_tuning
	endless = is_endless
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	_sign_rng.seed = hash(_rng.seed + 7717)
	_sfx_rng.seed = hash(_rng.seed + 4243)
	_next_sign_s = start_s() + 30.0 + _sign_rng.randf_range(0.0, tuning.sign_spacing_min_m * 0.5)
	_make_shared_meshes()
	path = RoadPath.new(tuning.sample_step_m)
	path.append_straight(tuning.start_straight_m)
	if endless:
		# Warm-up: a long straight with only a couple of obstacles on it.
		path.append_straight(tuning.endless_intro_m)
		_next_obstacle_s = tuning.start_straight_m + maxf(tuning.endless_intro_m * 0.4, tuning.obstacle_gap_easy_m * 0.5)
		_extend_endless(tuning.view_ahead_m + tuning.chunk_length_m * 2.0)
	else:
		_build_course()
	_build_start_banner()


# ---------------------------------------------------------------- queries

func lane_center(lane: int) -> float:
	return tuning.lane_width_m * (-0.5 if lane == 0 else 0.5)


func lane_of(lateral: float) -> int:
	return 0 if lateral < 0.0 else 1


## Road curvature at s in rad/m (+ = bends right), averaged over a few metres.
func curvature_at(s: float) -> float:
	var h := 2.0
	return -wrapf(path.yaw_at(s + h) - path.yaw_at(s - h), -PI, PI) / (2.0 * h)


## Lateral distance from the centre line to the rail face.
func rail_offset() -> float:
	return tuning.lane_width_m + tuning.rail_gap_m


func start_s() -> float:
	return tuning.start_straight_m * 0.3


## First obstacle the bike's box overlaps that it hasn't already hit, or null.
func check_hit(s: float, lateral: float, half_len: float, half_wid: float) -> Obstacle:
	for o in obstacles:
		if o.hit or absf(o.s - s) > o.half_along + 4.0:
			continue
		if o.overlaps(s, lateral, half_len, half_wid):
			return o
	return null


func is_clear(s: float, lateral: float, clearance: float) -> bool:
	for o in obstacles:
		if o.hit and o.crashes:
			continue  # knocked out of the way
		if absf(o.s - s) < clearance + o.half_along and absf(o.lateral - lateral) < o.half_lateral + 0.6:
			return false
	return true


## A crash sends cones/barriers flying (they stop blocking the road). push is
## the bike's world velocity at impact. Cars stay put.
func knock(o: Obstacle, push: Vector3) -> void:
	if o.kind != Obstacle.Kind.CONES and o.kind != Obstacle.Kind.BARRIER:
		return
	o.hit = true
	if o.node == null:
		return
	var local_push := o.node.global_basis.inverse() * push
	for piece in o.node.get_children():
		if piece is Node3D:
			var v := local_push * _fx_rng.randf_range(0.5, 1.0) + Vector3(_fx_rng.randf_range(-1.5, 1.5), _fx_rng.randf_range(2.5, 5.0), _fx_rng.randf_range(-1.0, 1.0))
			var spin := Vector3(_fx_rng.randf_range(-12, 12), _fx_rng.randf_range(-6, 6), _fx_rng.randf_range(-12, 12))
			CrashFx.knock_piece(piece, v, spin)


## Puts every obstacle back (for a restart): knocked ones are rebuilt and
## potholes can be hit again.
func reset_obstacles() -> void:
	for o in obstacles:
		if (o.hit and o.crashes or o.is_mover()) and o.node != null:
			o.node.queue_free()
			o.node = null
		o.hit = false
		if o.is_mover():
			o.reset_motion()


## Moves oncoming cars and cows. Oncoming cars start driving once the bike is
## within their trigger distance; cows start walking once the bike is lead_s
## seconds away. Call every physics tick while riding (not in the countdown).
func update_movers(dt: float, bike_s: float, bike_speed: float) -> void:
	for o in obstacles:
		if not o.is_mover() or o.stopped:
			continue
		match o.kind:
			Obstacle.Kind.ONCOMING:
				if not o.active and o.s - bike_s <= o.trigger_m:
					o.active = true
				if o.active:
					o.s -= o.speed * dt
			Obstacle.Kind.COW:
				if not o.active and o.s > bike_s and (o.s - bike_s) / maxf(bike_speed, 1.0) <= o.lead_s:
					o.active = true
					o.moo(tuning, _sfx_rng)
				if o.active:
					o.lateral = move_toward(o.lateral, o.end_lateral, o.speed * dt)
					if is_equal_approx(o.lateral, o.end_lateral):
						o.stopped = true
				o.play_cow(o.active and not o.stopped, tuning.cow_anim_speed)
		_place_node(o)


## The bike crashed: oncoming cars still ahead of it brake to a stop (so they
## don't run into the rider after the get-up), and whatever it hit stops.
func on_bike_crash(bike_s: float, hit: Obstacle) -> void:
	for o in obstacles:
		if o.kind == Obstacle.Kind.ONCOMING and o.active and o.s > bike_s - 1.0:
			o.stopped = true
	if hit != null and hit.is_mover():
		hit.stopped = true
		hit.play_cow(false, tuning.cow_anim_speed)


## Updates generation/streaming for a bike at distance s.
func update_around(s: float) -> void:
	if endless:
		var x := clampf((s - tuning.start_straight_m - tuning.endless_intro_m) / tuning.difficulty_ramp_m, 0.0, 1.0)
		difficulty = pow(x, tuning.difficulty_curve)
		if path.length() < s + tuning.view_ahead_m + tuning.chunk_length_m * 2.0:
			_extend_endless(s + tuning.view_ahead_m + tuning.chunk_length_m * 3.0)
	_stream_chunks(s)
	_stream_obstacles(s)
	_stream_signs(s)


# ---------------------------------------------------------------- generation

func _extend_endless(to_s: float) -> void:
	while path.length() < to_s:
		var straight := _rng.randf_range(tuning.straight_min_m, tuning.straight_max_m) * lerpf(1.0, 0.6, difficulty)
		path.append_straight(straight)
		var radius_base := lerpf(tuning.curve_radius_easy_m, tuning.curve_radius_hard_m, difficulty)
		var radius := maxf(radius_base * _rng.randf_range(0.85, 1.3), tuning.curve_radius_hard_m)
		var drift := path.end_yaw() - path.start_yaw
		var max_drift := deg_to_rad(tuning.max_heading_drift_deg)
		# Positive drift = turned left; turning right brings it back.
		var turn_right := _rng.randf() < 0.5
		if absf(drift) > max_drift * 0.4:
			turn_right = drift > 0.0
		var side := 1.0 if turn_right else -1.0
		var k := 1.0 / radius
		var allowed_len := (max_drift + side * drift) / k
		var length := minf(_rng.randf_range(tuning.curve_len_min_m, tuning.curve_len_max_m), allowed_len + tuning.curve_ease_m)
		if length > tuning.curve_ease_m * 2.0:
			path.append_curve(length, radius, turn_right, tuning.curve_ease_m)
	_spawn_endless_obstacles(path.length() - 10.0)
	# Future hazards are all at or after _next_obstacle_s, so their warning
	# signs can't land in the stretch that gets ordinary signs now.
	_spawn_random_signs(minf(path.length() - 100.0, _next_obstacle_s - tuning.hazard_sign_lead_m - tuning.sign_hazard_clear_m))


func _spawn_endless_obstacles(to_s: float) -> void:
	while _next_obstacle_s < to_s:
		var lane := _last_lane
		if _rng.randf() < 0.7:
			lane = 1 - _last_lane
		_last_lane = lane
		var kind := _pick_kind()
		var lat := lane_center(lane)
		if kind == Obstacle.Kind.POTHOLE:
			lat += _rng.randf_range(-0.4, 0.4)
		var o := Obstacle.make(kind, _next_obstacle_s, lat, tuning.lane_width_m)
		_setup_hazard(o)
		if kind == Obstacle.Kind.ONCOMING:
			# The car appears trigger_m ahead and drives back down its stretch.
			o.shift(o.trigger_m)
		_place_spaced(o)
		_add_hazard_sign(o)
		# Harder: sometimes a pothole in the other lane just after it. Ride past
		# the obstacle in the free lane, then swap back at once. Always at least
		# swap_gap_m of clear road between the two, never side by side.
		if difficulty > tuning.paired_pothole_from and kind != Obstacle.Kind.POTHOLE and not o.is_mover() 				and _rng.randf() < tuning.paired_pothole_chance * difficulty:
			var p := Obstacle.make(Obstacle.Kind.POTHOLE, 0.0, lane_center(1 - lane), tuning.lane_width_m)
			p.shift(o.s + o.half_along + tuning.swap_gap_m + p.half_along + _rng.randf_range(0.0, tuning.paired_pothole_spread_m) - p.s)
			_place_spaced(p)
			_add_hazard_sign(p)
		var gap := lerpf(tuning.obstacle_gap_easy_m, tuning.obstacle_gap_hard_m, difficulty)
		gap *= 1.0 + _rng.randf_range(-tuning.obstacle_gap_jitter, tuning.obstacle_gap_jitter)
		_next_obstacle_s = o.s + maxf(gap, 8.0)


## Car pack vehicle for cars, speed for oncoming cars, side and timing for cows.
func _setup_hazard(o: Obstacle) -> void:
	match o.kind:
		Obstacle.Kind.CAR:
			o.set_vehicle(VehiclePack.pick(_rng, tuning.truck_chance), tuning)
		Obstacle.Kind.ONCOMING:
			o.set_vehicle(VehiclePack.pick(_rng, tuning.truck_chance), tuning)
			var v := lerpf(tuning.oncoming_speed_easy_mps, tuning.oncoming_speed_hard_mps, difficulty)
			o.setup_oncoming(v, tuning.oncoming_trigger_m)
		Obstacle.Kind.COW:
			var side := -1.0 if _rng.randf() < 0.5 else 1.0
			var lead := _rng.randf_range(tuning.cow_lead_min_s, maxf(tuning.cow_lead_min_s, tuning.cow_lead_max_s))
			o.setup_cow(tuning, rail_offset(), side, lead)


## Clear road needed between two hazards: same_lane_gap_m if both only block
## the same single lane, otherwise swap_gap_m (you have to change lanes between
## them, and a cow can be in either lane).
func needed_gap(a: Obstacle, b: Obstacle) -> float:
	return tuning.same_lane_gap_m if a.lanes() == b.lanes() and a.lanes() != 3 else tuning.swap_gap_m


## Clear road between the reserved stretches of two hazards (negative = they
## overlap). An oncoming car reserves its whole drive (Obstacle.zone_*).
static func clear_gap(a: Obstacle, b: Obstacle) -> float:
	return absf(a.zone_center() - b.zone_center()) - a.zone_half() - b.zone_half()


## Adds o to the road, first pushing it further along until it has enough
## clear road to every hazard already placed (see needed_gap). Returns o.
func _place_spaced(o: Obstacle) -> Obstacle:
	var moved := true
	while moved:
		moved = false
		for other in obstacles:
			var need := needed_gap(o, other)
			if clear_gap(o, other) < need - 0.001:
				var want := other.zone_center() + other.zone_half() + need + o.zone_half()
				o.shift(want - o.zone_center())
				moved = true
	obstacles.append(o)
	return o


func _pick_kind() -> Obstacle.Kind:
	var w := [tuning.weight_cones, tuning.weight_barrier, tuning.weight_car, tuning.weight_pothole,
			tuning.weight_oncoming if difficulty >= tuning.oncoming_from else 0.0,
			tuning.weight_cow if difficulty >= tuning.cow_from else 0.0]
	var total := 0.0
	for v: float in w:
		total += v
	if total <= 0.0:
		return Obstacle.Kind.CONES
	var r := _rng.randf() * total
	for i in w.size():
		r -= w[i]
		if r <= 0.0:
			return i as Obstacle.Kind
	return Obstacle.Kind.CONES


# ---------------------------------------------------------------- signs

## Warning sign hazard_sign_lead_m before a hazard (roadwork for cones and
## barriers, pothole, cow; none for cars). Skipped when a sign of the same kind
## already stands within hazard_sign_repeat_m: it covers this one too.
func _add_hazard_sign(o: Obstacle) -> void:
	var sign_name := RoadSigns.hazard_sign_for(o.kind)
	if sign_name == "" or not RoadSigns.has(sign_name):
		return
	var at := maxf(o.start_s - tuning.hazard_sign_lead_m, start_s() + 10.0)
	if at >= o.start_s - 2.0:
		return
	for sg in signs:
		if sg.hazard and sg.sign_name == sign_name and absf(sg.s - at) < tuning.hazard_sign_repeat_m:
			return
	# An ordinary sign not built yet makes way for the warning.
	var i := signs.size() - 1
	while i >= 0:
		var other := signs[i]
		if not other.hazard and other.node == null and absf(other.s - at) < tuning.sign_hazard_clear_m:
			signs.remove_at(i)
		i -= 1
	# Right side of the road if there's room, else the left, else a bit earlier.
	for _try in 3:
		for right: bool in [true, false]:
			if _sign_side_free(at, right):
				_add_sign(at, sign_name, right, true)
				return
		at -= tuning.sign_min_gap_m
		if at <= start_s() + 10.0:
			return


## Ordinary signs every sign_spacing_min_m..max_m up to `to_s`, on the right,
## kept clear of warning signs. Signs with a right arrow only before a right
## bend.
func _spawn_random_signs(to_s: float) -> void:
	while _next_sign_s < to_s:
		var at := _next_sign_s
		if _sign_near_hazard(at) or not _sign_side_free(at, true):
			_next_sign_s += tuning.sign_min_gap_m
			continue
		var bend := 0.0
		for d: float in [30.0, 50.0, 70.0, 90.0]:
			bend += curvature_at(at + d) * 0.25
		var sign_name := RoadSigns.pick_random(_sign_rng, bend)
		if sign_name != "":
			_add_sign(at, sign_name, true, false)
		var lo := tuning.sign_spacing_min_m
		_next_sign_s = at + _sign_rng.randf_range(lo, maxf(lo, tuning.sign_spacing_max_m))


func _add_sign(at: float, sign_name: String, right: bool, hazard: bool) -> void:
	var sg := RoadSigns.Placed.new()
	sg.s = at
	sg.sign_name = sign_name
	sg.hazard = hazard
	sg.height = tuning.hazard_sign_height_m if hazard else tuning.sign_height_m
	# Post placed so the whole sign stays sign_rail_clearance_m outside the rail.
	var span := RoadSigns.span_of(sign_name, sg.height)
	var edge := rail_offset() + tuning.sign_rail_clearance_m
	sg.lateral = edge - span.x if right else -edge - span.y
	signs.append(sg)


func _sign_side_free(at: float, right: bool) -> bool:
	for sg in signs:
		if (sg.lateral > 0.0) == right and absf(sg.s - at) < tuning.sign_min_gap_m:
			return false
	return true


func _sign_near_hazard(at: float) -> bool:
	for sg in signs:
		if sg.hazard and absf(sg.s - at) < tuning.sign_hazard_clear_m:
			return true
	return false


func _build_course() -> void:
	# CourseData's first straight includes the start straight already built.
	var first := true
	for seg: Array in CourseData.SEGMENTS:
		var kind: String = seg[0]
		var length: float = seg[1]
		if first:
			length = maxf(0.0, length - tuning.start_straight_m)
			first = false
		if kind == "S":
			path.append_straight(length)
		else:
			path.append_curve(length, seg[2], kind == "R", tuning.curve_ease_m)
	finish_s = path.length()
	path.append_straight(CourseData.RUNOFF_M)
	for entry: Array in CourseData.OBSTACLES:
		var lat := lane_center(int(entry[1]))
		if entry.size() > 3:
			lat += float(entry[3])
		var o := Obstacle.make(Obstacle.kind_from_name(entry[2]), entry[0], lat, tuning.lane_width_m)
		_setup_hazard(o)
		obstacles.append(o)
		_add_hazard_sign(o)
	_spawn_random_signs(finish_s - 20.0)
	_build_finish_gate()


# ---------------------------------------------------------------- streaming

func _stream_chunks(s: float) -> void:
	var cl := tuning.chunk_length_m
	var first := maxi(0, int(floor((s - tuning.keep_behind_m) / cl)))
	var last := int(floor((s + tuning.view_ahead_m) / cl))
	var max_chunk := int(ceil(path.length() / cl)) - 1
	last = mini(last, max_chunk)
	for c in range(first, last + 1):
		if not _chunks.has(c):
			var node := _build_chunk(c)
			add_child(node)
			_chunks[c] = node
	for c: int in _chunks.keys():
		if c < first or c > last + 1:
			(_chunks[c] as Node3D).queue_free()
			_chunks.erase(c)


## Drops every built road chunk; they're rebuilt on the next update_around().
## For hazards added by hand after the road was built (screenshots), so the
## rail picks up cow openings.
func rebuild_chunks() -> void:
	for c: int in _chunks.keys():
		(_chunks[c] as Node3D).queue_free()
	_chunks.clear()


func _stream_obstacles(s: float) -> void:
	var keep := tuning.keep_behind_m
	var i := 0
	while i < obstacles.size():
		var o := obstacles[i]
		if o.s < s - keep:
			if o.node != null:
				o.node.queue_free()
			if endless:
				obstacles.remove_at(i)
				continue
			o.node = null
		elif o.node == null and not (o.hit and o.crashes) and o.s < s + tuning.view_ahead_m and o.s >= s - keep \
				and not (o.kind == Obstacle.Kind.ONCOMING and not o.active):
			# (An oncoming car only shows up once it starts driving.)
			o.node = o.build_node(tuning, _rng)
			add_child(o.node)
			_place_node(o)
		i += 1


func _stream_signs(s: float) -> void:
	var keep := tuning.keep_behind_m
	var i := 0
	while i < signs.size():
		var sg := signs[i]
		if sg.s < s - keep:
			if sg.node != null:
				sg.node.queue_free()
				sg.node = null
			if endless:
				signs.remove_at(i)
				continue
		elif sg.node == null and sg.s < s + tuning.view_ahead_m:
			sg.node = RoadSigns.build(sg.sign_name, sg.height)
			add_child(sg.node)
			sg.node.transform = Transform3D(Basis(Vector3.UP, path.yaw_at(sg.s)), path.point_at(sg.s, sg.lateral))
		i += 1


func _place_node(o: Obstacle) -> void:
	if o.node == null:
		return
	var yaw := path.yaw_at(o.s)
	o.node.transform = Transform3D(Basis(Vector3.UP, yaw), path.point_at(o.s, o.lateral))


# ---------------------------------------------------------------- meshes

func _make_shared_meshes() -> void:
	_post_mesh = BoxMesh.new()
	_post_mesh.size = Vector3(0.12, tuning.rail_height_m, 0.12)
	_post_mesh.material = Palette.mat("rail_post")
	_trunk_mesh = CylinderMesh.new()
	_trunk_mesh.top_radius = 0.12
	_trunk_mesh.bottom_radius = 0.18
	_trunk_mesh.height = 1.6
	_trunk_mesh.radial_segments = 6
	_trunk_mesh.rings = 1
	_trunk_mesh.material = Palette.mat("trunk")
	for id: String in ["leaves_a", "leaves_b"]:
		var leaf := CylinderMesh.new()
		leaf.top_radius = 0.0
		leaf.bottom_radius = 1.4
		leaf.height = 3.6
		leaf.radial_segments = 7
		leaf.rings = 1
		leaf.material = Palette.mat(id)
		_leaf_meshes.append(leaf)
	_rock_mesh = SphereMesh.new()
	_rock_mesh.radius = 0.6
	_rock_mesh.height = 0.8
	_rock_mesh.radial_segments = 6
	_rock_mesh.rings = 3
	_rock_mesh.material = Palette.mat("rock")


func _build_chunk(c: int) -> Node3D:
	var node := Node3D.new()
	node.name = "Chunk%d" % c
	var per := int(round(tuning.chunk_length_m / path.step))
	var i0 := c * per
	var i1 := mini(i0 + per, path.sample_count() - 1)
	if i1 <= i0:
		return node
	var hw := tuning.lane_width_m
	var rail := rail_offset()
	var shoulder := rail + 1.2

	var road := _surface()
	_strip(road, i0, i1, -hw, hw, 0.0)
	_add_mesh(node, road, "asphalt")

	var verge := _surface()
	_strip(verge, i0, i1, -shoulder, -hw, -0.005)
	_strip(verge, i0, i1, hw, shoulder, -0.005)
	_add_mesh(node, verge, "shoulder")

	var lines := _surface()
	var edge := hw - 0.18
	_strip(lines, i0, i1, -edge - 0.06, -edge + 0.06, 0.006)
	_strip(lines, i0, i1, edge - 0.06, edge + 0.06, 0.006)
	var dash := maxi(1, int(round(3.0 / path.step)))
	var gap := maxi(1, int(round(6.0 / path.step)))
	var j := i0 - (i0 % gap)
	while j < i1:
		var a := maxi(j, i0)
		var b := mini(j + dash, i1)
		if b > a:
			_strip(lines, a, b, -0.06, 0.06, 0.006)
		j += gap
	_add_mesh(node, lines, "line_white")

	# Guard rails, with an opening wherever a cow crosses.
	var gaps := _rail_gaps(i0, i1)
	var rails := _surface()
	var top := tuning.rail_height_m
	for side: float in [-1.0, 1.0]:
		_wall(rails, i0, i1, side * rail, top - 0.3, top, gaps)
	_add_mesh(node, rails, "rail")

	# Posts (none inside an opening, one at each end of it).
	var post_every := maxi(1, int(round(tuning.rail_post_spacing_m / path.step)))
	var post_xf: Array[Transform3D] = []
	var k := i0 - (i0 % post_every)
	while k < i1:
		if k >= i0 and not _in_gap(float(k) * path.step, gaps):
			for side: float in [-1.0, 1.0]:
				var p := path.points[k] + RoadPath.right_of(path.yaws[k]) * (side * (rail + 0.08))
				post_xf.append(Transform3D(Basis(Vector3.UP, path.yaws[k]), p + Vector3.UP * top * 0.5))
		k += post_every
	var s0 := float(i0) * path.step
	var s1 := float(i1) * path.step
	for g: Vector2 in gaps:
		for end_s: float in [g.x, g.y]:
			if end_s < s0 or end_s >= s1:
				continue
			var yaw := path.yaw_at(end_s)
			for side: float in [-1.0, 1.0]:
				var p := path.point_at(end_s, side * (rail + 0.08))
				post_xf.append(Transform3D(Basis(Vector3.UP, yaw), p + Vector3.UP * top * 0.5))
	_multimesh(node, _post_mesh, post_xf)

	_scatter_scenery(node, i0, i1, rail, c)
	return node


func _scatter_scenery(node: Node3D, i0: int, i1: int, rail: float, c: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(c * 7919 + 17)
	var trunks: Array[Transform3D] = []
	var leaves: Array = [[], []]
	var rocks: Array[Transform3D] = []
	var count := int(float(i1 - i0) * path.step / 3.0)
	for _n in count:
		var i := rng.randi_range(i0, i1)
		var side := 1.0 if rng.randf() < 0.5 else -1.0
		var off := rail + rng.randf_range(4.0, 40.0)
		var p := path.points[i] + RoadPath.right_of(path.yaws[i]) * (side * off)
		var sc := rng.randf_range(0.7, 1.5)
		var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * sc)
		if rng.randf() < 0.18:
			rocks.append(Transform3D(b, p))
			continue
		trunks.append(Transform3D(b, p + Vector3.UP * 0.8 * sc))
		(leaves[rng.randi() % 2] as Array).append(Transform3D(b, p + Vector3.UP * (1.6 + 1.8) * sc))
	_multimesh(node, _trunk_mesh, trunks)
	for li in 2:
		var arr: Array[Transform3D] = []
		arr.assign(leaves[li])
		_multimesh(node, _leaf_meshes[li], arr)
	_multimesh(node, _rock_mesh, rocks)


func _strip(st: SurfaceTool, i0: int, i1: int, lat_a: float, lat_b: float, y: float) -> void:
	for i in range(i0, i1):
		var a0 := _pt(i, lat_a, y)
		var b0 := _pt(i, lat_b, y)
		var a1 := _pt(i + 1, lat_a, y)
		var b1 := _pt(i + 1, lat_b, y)
		_tri(st, a0, a1, b1)
		_tri(st, a0, b1, b0)


## Openings in the guard rail (both sides) in samples i0..i1: one per cow
## crossing, cow_rail_gap_m long. Each is Vector2(from_s, to_s).
func _rail_gaps(i0: int, i1: int) -> Array[Vector2]:
	var gaps: Array[Vector2] = []
	var half := tuning.cow_rail_gap_m * 0.5
	if half <= 0.0:
		return gaps
	var s0 := float(i0) * path.step
	var s1 := float(i1) * path.step
	for o in obstacles:
		if o.kind == Obstacle.Kind.COW and o.start_s + half >= s0 and o.start_s - half <= s1:
			gaps.append(Vector2(o.start_s - half, o.start_s + half))
	return gaps


static func _in_gap(s: float, gaps: Array[Vector2]) -> bool:
	for g in gaps:
		if s > g.x and s < g.y:
			return true
	return false


## Vertical double-sided ribbon at a fixed lateral offset (guard rail). Skips
## the segments whose middle is inside one of `gaps` (s ranges).
func _wall(st: SurfaceTool, i0: int, i1: int, lat: float, y0: float, y1: float, gaps: Array[Vector2] = []) -> void:
	for i in range(i0, i1):
		if _in_gap((float(i) + 0.5) * path.step, gaps):
			continue
		var a0 := _pt(i, lat, y0)
		var b0 := _pt(i, lat, y1)
		var a1 := _pt(i + 1, lat, y0)
		var b1 := _pt(i + 1, lat, y1)
		_tri(st, a0, a1, b1)
		_tri(st, a0, b1, b0)
		_tri(st, a0, b1, a1)
		_tri(st, a0, b0, b1)


## Flat-shaded triangle builder (smooth group -1 = no normal averaging).
func _surface() -> SurfaceTool:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	return st


func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


func _pt(i: int, lateral: float, y: float) -> Vector3:
	return path.points[i] + RoadPath.right_of(path.yaws[i]) * lateral + Vector3.UP * y


func _add_mesh(node: Node3D, st: SurfaceTool, color_id: String) -> void:
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = Palette.mat(color_id)
	node.add_child(mi)


func _multimesh(node: Node3D, mesh: Mesh, xforms: Array[Transform3D]) -> void:
	if xforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	node.add_child(mmi)


func _build_start_banner() -> void:
	var s := start_s() + 6.0
	_gate(s, "start_banner", false)


func _build_finish_gate() -> void:
	_gate(finish_s, "finish_a", true)


func _gate(s: float, color_id: String, checkered: bool) -> void:
	var g := Node3D.new()
	g.name = "Gate"
	var rail := rail_offset()
	for side: float in [-1.0, 1.0]:
		MeshKit.box(g, Vector3(0.25, 3.6, 0.25), Vector3(side * (rail + 0.4), 1.8, 0.0), "rail_post")
	var width := (rail + 0.4) * 2.0
	if checkered:
		var n := 12
		for i in n:
			for row in 2:
				var id := "finish_a" if (i + row) % 2 == 0 else "finish_b"
				MeshKit.box(g, Vector3(width / n, 0.35, 0.1), Vector3(-width * 0.5 + width / n * (i + 0.5), 3.25 - row * 0.35, 0.0), id)
		for i in n:
			var id2 := "finish_a" if i % 2 == 0 else "finish_b"
			MeshKit.box(g, Vector3(tuning.lane_width_m * 2.0 / n, 0.01, 0.6), Vector3(-tuning.lane_width_m + tuning.lane_width_m * 2.0 / n * (i + 0.5), 0.008, 0.0), id2)
	else:
		MeshKit.box(g, Vector3(width, 0.7, 0.1), Vector3(0.0, 3.1, 0.0), color_id)
	g.transform = Transform3D(Basis(Vector3.UP, path.yaw_at(s)), path.position_at(s))
	add_child(g)
