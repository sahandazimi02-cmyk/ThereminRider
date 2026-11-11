## Headless self test. Run:
##   Godot_console.exe --headless --path . --fixed-fps 60 res://scenes/test/smoke_test.tscn
## Exit code 0 = all checks passed. A "balance bot" rides the bike through the
## real game scene using RiderInput's override, so this also proves the bike is
## balanceable with the current tuning.
extends Node

var failures := 0
var trace := OS.get_environment("RIDER_TRACE") == "1"
var _bot_lane := 1


func _ready() -> void:
	_run.call_deferred()


func _check(cond: bool, what: String) -> void:
	if cond:
		print("  PASS  ", what)
	else:
		failures += 1
		printerr("  FAIL  ", what)


func _run() -> void:
	if OS.get_environment("RIDER_OSC_PROBE") == "1":
		await _osc_probe()
		return
	print("=== Theremin Rider smoke test ===")
	_test_osc()
	await _test_profiles()
	_test_cadence()
	_test_road()
	_test_spacing()
	_test_fall_times()
	_test_pothole()
	await _test_crash_fx()
	await _test_rail()
	await _test_endless()
	await _test_course()
	print("=== %s (%d failure%s) ===" % ["OK" if failures == 0 else "FAILED", failures, "" if failures == 1 else "s"])
	RiderInput.override_enabled = false
	get_tree().quit(1 if failures > 0 else 0)


## RIDER_OSC_PROBE=1: listen on the real UDP port for 4 s and report what
## arrived (run tools/osc_test_sender.py or Max at the same time).
func _osc_probe() -> void:
	print("=== OSC probe: ", OscReceiver.status_text)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 4000:
		await get_tree().process_frame
	print("packets %d  steer %+.3f (fresh %s)  present %s  cadence %.1f (fresh %s)  -> RiderInput steer %s %+.3f, pedal %s %.1f RPM" % [
			OscReceiver.packets_total, OscReceiver.steer, OscReceiver.steer_fresh(), OscReceiver.hand_present(),
			OscReceiver.cadence_rpm, OscReceiver.cadence_fresh(),
			RiderInput.source_name(RiderInput.steer_source), RiderInput.steer,
			RiderInput.source_name(RiderInput.pedal_source), RiderInput.cadence_rpm])
	get_tree().quit(0 if OscReceiver.packets_total > 0 else 1)


func _test_osc() -> void:
	print("[osc]")
	var bytes := OscParser.encode_message("/bike/steer", [0.25])
	var msgs := OscParser.parse_packet(bytes)
	_check(msgs.size() == 1 and msgs[0]["address"] == "/bike/steer" and is_equal_approx(msgs[0]["args"][0], 0.25), "encode/parse float message")
	var bundle := PackedByteArray()
	bundle.append_array("#bundle".to_ascii_buffer())
	bundle.append(0)
	bundle.append_array(PackedByteArray([0, 0, 0, 0, 0, 0, 0, 1]))
	for m: PackedByteArray in [OscParser.encode_message("/bike/cadence", [88.0]), OscParser.encode_message("/bike/steer/present", [1])]:
		var spb := StreamPeerBuffer.new()
		spb.big_endian = true
		spb.put_32(m.size())
		bundle.append_array(spb.data_array)
		bundle.append_array(m)
	msgs = OscParser.parse_packet(bundle)
	_check(msgs.size() == 2 and msgs[1]["args"][0] == 1, "parse bundle with float + int")
	OscReceiver.handle_message("/bike/steer", [-0.5])
	_check(OscReceiver.steer_fresh() and is_equal_approx(OscReceiver.steer, -0.5), "receiver stores /bike/steer")


## Each control profile routes steer / pedal to the right device. Only the
## theremin is "live" here (no cadence), so the bike-pedal channel reads NONE.
func _test_profiles() -> void:
	print("[control profiles]")
	var saved := GameSession.input_profile
	var P := GameSession.InputProfile
	var S := RiderInput.Source
	# profile -> [expected steer source, expected pedal source]
	var expect := {
		P.CONTROLLER: [S.PAD, S.PAD],
		P.THEREMIN_BIKE: [S.OSC, S.NONE],
		P.THEREMIN_CONTROLLER: [S.OSC, S.PAD],
	}
	for profile: int in expect:
		GameSession.input_profile = profile as GameSession.InputProfile  # set directly: never save in tests
		OscReceiver.handle_message("/bike/steer", [-0.5])
		OscReceiver.handle_message("/bike/steer/present", [1])
		await get_tree().process_frame
		await get_tree().process_frame
		var want: Array = expect[profile]
		_check(RiderInput.steer_source == want[0] and RiderInput.pedal_source == want[1],
				"%s: steer %s, pedal %s" % [GameSession.input_profile_name(),
				RiderInput.source_name(RiderInput.steer_source), RiderInput.source_name(RiderInput.pedal_source)])
	GameSession.input_profile = saved


func _test_cadence() -> void:
	print("[cadence]")
	var sc := StrokeCadence.new()
	sc.configure(RiderInput.tuning)
	for i in 6:
		sc.add_stroke(10.0 + i / 3.0)
	var rpm := sc.rpm(10.0 + 5.0 / 3.0 + 0.1)
	_check(absf(rpm - 90.0) < 3.0, "3 taps/s = ~90 RPM (got %.1f)" % rpm)
	_check(sc.rpm(30.0) == 0.0, "no taps = 0 RPM")


func _test_road() -> void:
	print("[road]")
	var t := RoadTuning.load_default()
	var w := RoadWorld.new()
	w.setup(t, true, 1234)
	add_child(w)
	w.update_around(0.0)
	var worst := 0.0
	w.path.reset_hint(0.0)
	for s in range(5, 400, 7):
		var lat := sin(float(s)) * 2.0
		var loc := w.path.locate(w.path.point_at(float(s), lat))
		worst = maxf(worst, absf(loc.x - s) + absf(loc.y - lat))
	_check(worst < 0.15, "locate() inverts point_at() (worst error %.3f m)" % worst)
	var mi: MeshInstance3D = null
	for c in w.get_children():
		if c.name.begins_with("Chunk"):
			mi = c.get_child(0) as MeshInstance3D
			break
	var up_ok := false
	if mi != null:
		var normals: PackedVector3Array = mi.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
		up_ok = normals.size() > 0 and normals[0].y > 0.9
	_check(up_ok, "road surface faces up (winding)")
	_check(w.obstacles.size() > 2, "endless spawned obstacles (%d)" % w.obstacles.size())
	var drift := 0.0
	for y in w.path.yaws:
		drift = maxf(drift, absf(y - w.path.start_yaw))
	_check(rad_to_deg(drift) <= t.max_heading_drift_deg + 1.0, "heading drift bounded (%.1f deg)" % rad_to_deg(drift))
	w.queue_free()


## 0.7.0: hazards in opposite lanes always leave swap_gap_m of clear road
## between them (no forced potholes), at every difficulty and in the course.
func _test_spacing() -> void:
	print("[hazard spacing]")
	var t := RoadTuning.load_default()
	var w := RoadWorld.new()
	w.setup(t, true, 4321)
	add_child(w)
	var worst_swap := INF
	var worst_same := INF
	var paired := 0
	var seen := {}
	var end_s := t.start_straight_m + t.endless_intro_m + t.difficulty_ramp_m + 2000.0
	var s := 0.0
	while s < end_s:
		w.update_around(s)
		for i in w.obstacles.size():
			var a := w.obstacles[i]
			for j in range(i + 1, w.obstacles.size()):
				var b := w.obstacles[j]
				var gap := RoadWorld.clear_gap(a, b)
				if w.lane_of(a.lateral) != w.lane_of(b.lateral):
					worst_swap = minf(worst_swap, gap)
					var key := "%d:%d" % [a.get_instance_id(), b.get_instance_id()]
					if not seen.has(key) and gap < t.swap_gap_m + t.paired_pothole_spread_m + 1.0 							and (a.kind == Obstacle.Kind.POTHOLE) != (b.kind == Obstacle.Kind.POTHOLE):
						seen[key] = true
						paired += 1
				else:
					worst_same = minf(worst_same, gap)
		s += 40.0
	print("    endless to %.0f m: tightest lane swap %.1f m, tightest same lane %.1f m, close obstacle/pothole swaps %d" % [end_s, worst_swap, worst_same, paired])
	_check(worst_swap >= t.swap_gap_m - 0.01, "endless: opposite-lane hazards >= swap_gap_m apart (%.1f m)" % worst_swap)
	_check(worst_same >= t.same_lane_gap_m - 0.01, "endless: same-lane hazards don't overlap (%.1f m)" % worst_same)
	_check(paired > 0, "endless: paired potholes still appear at high difficulty (%d)" % paired)
	w.queue_free()

	var course := RoadWorld.new()
	course.setup(t, false, 1)
	add_child(course)
	var worst_course := INF
	for i in course.obstacles.size():
		for j in range(i + 1, course.obstacles.size()):
			var a := course.obstacles[i]
			var b := course.obstacles[j]
			if course.lane_of(a.lateral) != course.lane_of(b.lateral):
				worst_course = minf(worst_course, RoadWorld.clear_gap(a, b))
	_check(worst_course >= t.swap_gap_m - 0.01, "course: opposite-lane hazards >= swap_gap_m apart (%.1f m)" % worst_course)
	course.queue_free()


## 0.7.0: a pothole knocks the bike about for pothole_shaky_s, but riding on
## with centred steering still doesn't make you fall.
func _test_pothole() -> void:
	print("[pothole]")
	var t := BikeTuning.load_default()
	var bike := Bike.new()
	bike.tuning = t
	bike.assist_scale = GameSession.ASSIST_SCALES[GameSession.Assist.NORMAL]
	bike.noise_seed = 777
	add_child(bike)
	bike.respawn(Vector3.ZERO, 0.0)
	bike.state = Bike.State.RIDING
	bike.speed = 90.0 * t.speed_per_rpm
	var dt := 1.0 / 60.0
	for _i in 60:
		bike.step(dt, 0.0, 90.0)
	var k_before := bike.stability_k
	bike.hit_pothole()
	bike.step(dt, 0.0, 90.0)
	var k_after := bike.stability_k
	var peak := 0.0
	var time := 0.0
	while time < 6.0 and bike.is_upright():
		bike.step(dt, 0.0, 90.0)
		peak = maxf(peak, absf(bike.lean))
		time += dt
	print("    k %.1f -> %.1f right after, peak lean %.1f deg, shaky left %.2f" % [k_before, k_after, rad_to_deg(peak), bike.pothole_shake()])
	_check(k_after < k_before * 0.8, "pothole makes the bike less stable for a moment")
	_check(bike.is_upright(), "pothole at cruise with no steering doesn't make you fall")
	_check(rad_to_deg(peak) > 8.0, "pothole gives a noticeable lean (%.1f deg)" % rad_to_deg(peak))
	_check(bike.pothole_shake() == 0.0 and bike.stability_k > k_before * 0.95, "shakiness wears off")
	bike.queue_free()


## Pure bike physics (no road): how long until the bike falls when the riders
## stop doing their job. Cruise = 90 RPM steady state.
func _test_fall_times() -> void:
	print("[fall times]")
	var t := BikeTuning.load_default()
	var cruise := 90.0 * t.speed_per_rpm
	var stop_pedal := _fall_time(t, cruise, 0.0, "balance")
	var hands_off := _fall_time(t, cruise, 90.0, "none")
	var full_steer := _fall_time(t, cruise, 90.0, "full")
	print("    cruise %.1f km/h: stop pedalling %.1f s, hands off %.1f s, full steer %.1f s" % [
			cruise * 3.6, stop_pedal, hands_off, full_steer])
	_check(stop_pedal > 1.5 and stop_pedal < 6.5, "stop pedalling falls in 1.5-6.5 s (%.1f s)" % stop_pedal)
	# 0.2.1 restored the 0.1.0 balance: Normal self-balances at cruising speed.
	_check(hands_off > 20.0, "no steering at cruise stays up (self-balancing, %.1f s)" % hands_off)
	# 0.3.0: steering is gentler, so full steer at cruise is a steady turn, not a
	# fall. On the road that line ends at the rail instead (see [rail scrape]).
	_check(full_steer > 20.0, "full steer at cruise is a steady turn, not a fall (%.1f s)" % full_steer)


## steer_mode: "balance" = simple balancing rider, "none" = steer 0, "full" = steer +1.
func _fall_time(t: BikeTuning, start_speed: float, cadence: float, steer_mode: String) -> float:
	var bike := Bike.new()
	bike.tuning = t
	bike.assist_scale = GameSession.ASSIST_SCALES[GameSession.Assist.NORMAL]
	bike.noise_seed = 777
	add_child(bike)
	bike.respawn(Vector3.ZERO, 0.0)
	bike.state = Bike.State.RIDING
	bike.speed = start_speed
	bike.lean = deg_to_rad(0.5)
	var dt := 1.0 / 60.0
	var time := 0.0
	while time < 30.0 and bike.is_upright():
		var steer := 0.0
		if steer_mode == "balance":
			steer = clampf(3.0 * bike.lean + 0.6 * bike.lean_rate, -1.0, 1.0)
		elif steer_mode == "full":
			steer = 1.0
		bike.step(dt, steer, cadence)
		time += dt
	bike.queue_free()
	return time


## A hard hit throws the rider, the rider lands and settles, knocked cones stop
## blocking the road, and getting up puts the rider back on the bike.
func _test_crash_fx() -> void:
	print("[crash effects]")
	RiderInput.override_enabled = true
	var game := _make_game(GameSession.Mode.ENDLESS)
	# Ride until we're up to speed (the bot gets back up if it falls on the way).
	for _f in 60 * 20:
		_bot(game, 90.0)
		await get_tree().physics_frame
		if game.phase == Game.Phase.PLAY and game.bike.state == Bike.State.RIDING and game.bike.speed > 5.5:
			break
	var model := game.bike.model
	var start := model.rider_focus()
	print("    before hit: %s, %.1f km/h, rider hip %.2f m up, crashes so far %d" % [game.bike.state_name(), game.bike.speed * 3.6, start.y - game.bike.global_position.y, game.crashes])
	# Watch the whole tumble: no automatic get-up during this check.
	var auto_get_up := game.road_tuning.auto_get_up_s
	game.road_tuning.auto_get_up_s = 0.0
	game.bike.crash("test hit", 1.0, game.bike.right())
	_check(model.thrown and game.bike.impact, "hard hit throws the rider off")
	var peak := start.y
	for _f in 60 * 3:
		RiderInput.override_cadence = 0.0
		RiderInput.override_steer = 0.0
		await get_tree().physics_frame
		peak = maxf(peak, model.rider_focus().y)
	var landed := model.rider_focus()
	print("    rider: peak %.2f m, landed %.1f m from the hit, hip at %.2f m" % [peak - game.bike.global_position.y, (landed - start).length(), landed.y - game.bike.global_position.y])
	_check(peak > start.y + 0.3, "rider flies up")
	_check(landed.y - game.bike.global_position.y < 0.3, "rider ends up lying on the ground")
	var cones: Obstacle = null
	for o in game.road.obstacles:
		if o.kind == Obstacle.Kind.CONES and o.node != null:
			cones = o
			break
	if cones != null:
		game.road.knock(cones, Vector3(0, 0, -8))
		_check(game.road.is_clear(cones.s, cones.lateral, 1.0) and game.road.check_hit(cones.s, cones.lateral, 0.5, 0.3) == null, "knocked cones no longer block the road")
	game.road_tuning.auto_get_up_s = auto_get_up
	for _f in 60 * 6:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 60.0
		await get_tree().physics_frame
		if game.phase == Game.Phase.PLAY:
			break
	_check(game.phase == Game.Phase.PLAY and not model.thrown, "get-up puts the rider back on the bike")

	# No input at all: still back up automatically, quickly.
	game.bike.crash("test fall", 1.0, Vector3.ZERO)
	var waited := 0.0
	for _f in 60 * 8:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 0.0
		await get_tree().physics_frame
		waited += 1.0 / 60.0
		if game.phase == Game.Phase.PLAY:
			break
	_check(game.phase == Game.Phase.PLAY, "auto get-up with no input (%.1f s after the crash)" % waited)

	# Restart (R / Back / pause menu): straight back to the start, short countdown.
	for _f in 60 * 3:
		_bot(game, 90.0)
		await get_tree().physics_frame
	game.skip_countdown = false  # tests normally skip it; measure the real one here
	game.restart()
	var t := game.road_tuning
	_check(game.phase == Game.Phase.COUNTDOWN and is_equal_approx(game.bike_s, game.road.start_s()) \
			and game.distance == 0.0 and game.crashes == 0, "restart puts the bike back on the start line")
	var to_go := 0.0
	while game.phase == Game.Phase.COUNTDOWN and to_go < 10.0:
		await get_tree().physics_frame
		to_go += 1.0 / 60.0
	_check(to_go > 0.0 and to_go <= t.restart_countdown_s + 0.1 and t.restart_countdown_s < t.countdown_s,
			"restart countdown is short (%.1f s, first start %.1f s)" % [to_go, t.countdown_s])
	game.queue_free()
	await get_tree().process_frame


## Forgiving rails: steering into a rail scrapes along it for a while instead of
## crashing at once; letting go recovers; holding into it long enough crashes.
func _test_rail() -> void:
	print("[rail scrape]")
	RiderInput.override_enabled = true
	var game := _make_game(GameSession.Mode.ENDLESS)
	for _f in 60 * 20:
		_bot(game, 90.0)
		await get_tree().physics_frame
		if game.phase == Game.Phase.PLAY and game.bike.state == Bike.State.RIDING and game.bike.speed > 5.0:
			break
	var crashes0 := game.crashes
	var touched := false
	for _f in 60 * 1:
		RiderInput.override_cadence = 90.0
		RiderInput.override_steer = 1.0
		await get_tree().physics_frame
	# Push it onto the right rail if the steering alone hasn't got there yet.
	for _f in 60 * 2:
		RiderInput.override_cadence = 90.0
		RiderInput.override_steer = 1.0
		if game.rail_time <= 0.0 and game.bike.is_upright():
			game.bike.position = game.road.path.point_at(game.bike_s, game.road.rail_offset())
		await get_tree().physics_frame
		touched = touched or game.rail_time > 0.0
		if game.rail_time > 0.5:
			break
	_check(touched and game.crashes == crashes0 and game.bike.is_upright(), "touching the rail does not crash at once (rail time %.2f s)" % game.rail_time)
	for _f in 60 * 3:
		_bot(game, 90.0)
		await get_tree().physics_frame
	_check(game.crashes == crashes0 and game.rail_time < 0.5, "steering away from the rail recovers (rail time %.2f s, %s)" % [game.rail_time, game.bike.state_name()])
	var crashed := false
	for _f in 60 * 8:
		RiderInput.override_cadence = 90.0
		RiderInput.override_steer = 1.0
		if game.bike.is_upright():
			game.bike.position = game.road.path.point_at(game.bike_s, game.road.rail_offset())
		await get_tree().physics_frame
		if game.phase == Game.Phase.FALLEN:
			crashed = true
			break
	_check(crashed and game.bike.last_crash_reason.contains("rail"), "staying on the rail long enough crashes (%s)" % game.bike.last_crash_reason)
	game.queue_free()
	await get_tree().process_frame


func _make_game(mode: GameSession.Mode) -> Game:
	var game: Game = load("res://scenes/game.tscn").instantiate()
	game.skip_countdown = true
	game.force_mode = mode
	game.world_seed = 777
	game.record_scores = false
	game.crash_slowmo = false
	# RIDER_ASSIST=0/1/2 tries Easy/Normal/Hard (default Normal).
	var a := OS.get_environment("RIDER_ASSIST")
	GameSession.assist = (int(a) if a.is_valid_int() else 1) as GameSession.Assist
	add_child(game)
	return game


## Rider AI. Unstable bike (Normal/Hard at any speed, everything when slow):
## lane error -> lateral accel wanted -> the lean that accel needs -> the
## lateral accel (via steering) that drives the lean there. Self-stable bike
## (Easy at speed): just steer along the path and let the bike balance itself.
func _bot(game: Game, cadence: float) -> void:
	var bike := game.bike
	var road := game.road
	RiderInput.override_cadence = cadence
	if game.phase == Game.Phase.FALLEN:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 60.0
		return
	# Pick a lane with nothing in it for the next 60 m.
	var blocked := func(lane: int) -> bool:
		for o in road.obstacles:
			if o.s > game.bike_s - 1.0 and o.s < game.bike_s + 60.0 and road.lane_of(o.lateral) == lane:
				return true
		return false
	if blocked.call(_bot_lane) and not blocked.call(1 - _bot_lane):
		_bot_lane = 1 - _bot_lane
	var target := road.lane_center(_bot_lane)
	if bike.state == Bike.State.FOOT_DOWN or bike.speed < 4.0:
		target = road.lane_center(road.lane_of(game.bike_lat))  # launch straight, change lanes later

	var t := bike.tuning
	var v := maxf(bike.speed, 0.5)
	var max_steer := deg_to_rad(lerpf(t.max_steer_deg_slow, t.max_steer_deg_fast, smoothstep(0.0, t.fast_speed, bike.speed)))
	var tip := t.gravity_scale * bike.assist_scale.y * Bike.G / t.com_height_m
	var instab := tip - bike.stability_k

	# Path following (aim at a point ahead in the target lane).
	var aim := road.path.point_at(game.bike_s + maxf(6.0, bike.speed * 1.4), target)
	var to := aim - bike.position
	var heading_err := wrapf(bike.yaw - atan2(-to.x, -to.z), -PI, PI)  # + = need to go right
	var steer_path := 2.5 * heading_err - 0.25 * (bike.lean - bike.lean_eq)

	var steer_bal := 0.0
	var lean_des := 0.0
	if instab > 0.3:
		# Lane keeping plus the road's own curve (looked up a little ahead).
		var rel := wrapf(road.path.yaw_at(game.bike_s) - bike.yaw, -PI, PI)  # + = pointing right of the road
		var lat_vel := v * sin(rel)
		var pv := v * 0.8
		var curv := wrapf(road.path.yaw_at(game.bike_s + pv) - road.path.yaw_at(game.bike_s + pv + 2.0), -PI, PI) / 2.0
		var a_ref := -0.3 * (game.bike_lat - target) - 0.8 * lat_vel + v * v * curv
		lean_des = clampf(atan(a_ref / Bike.G), -0.4, 0.4)
		# Small-angle lean model: lean_acc = (tip - k) * (lean - a_lat/g) - d * lean_rate.
		# Choose a_lat for a damped return to lean_des, then undo the steering expo.
		var omega := 6.0
		var a_over_g := bike.lean + (omega * omega * (bike.lean - lean_des) + (1.6 * omega - t.lean_damping) * bike.lean_rate) / instab
		var delta := atan(clampf(a_over_g, -1.0, 1.0) * Bike.G * t.wheelbase_m / (v * v))
		var u := clampf(delta / max_steer, -1.0, 1.0)
		steer_bal = signf(u) * pow(absf(u), 1.0 / t.steer_expo)
	else:
		var yaw_rate_des := clampf(1.2 * heading_err, -0.8, 0.8)
		lean_des = clampf(atan(v * yaw_rate_des / Bike.G), -0.35, 0.35)
		var ff := clampf(atan(t.wheelbase_m * yaw_rate_des / v) / max_steer, -1.0, 1.0)
		ff = signf(ff) * pow(absf(ff), 1.0 / t.steer_expo)
		steer_bal = ff + 3.0 * (bike.lean - lean_des) + 0.6 * bike.lean_rate
	var w := clampf((bike.stability_k - tip) * 0.5 + 0.5, 0.0, 1.0)
	if bike.state == Bike.State.FOOT_DOWN:
		w = 1.0  # foot on the ground: no balancing, just point the bike
	RiderInput.override_steer = clampf(lerpf(steer_bal, steer_path, w), -1.0, 1.0)
	if trace and Engine.get_physics_frames() % 20 == 0:
		print("    t=%.1f st=%s v=%.1f lean=%.1f want=%.1f eq=%.1f k=%.1f w=%.2f s=%.1f lat=%.2f steer=%.2f" % [
				Engine.get_physics_frames() / 60.0, bike.state_name(), bike.speed, rad_to_deg(bike.lean),
				rad_to_deg(lean_des), rad_to_deg(bike.lean_eq), bike.stability_k, w, game.bike_s, game.bike_lat,
				RiderInput.override_steer])


func _test_endless() -> void:
	print("[endless ride]")
	RiderInput.override_enabled = true
	var game := _make_game(GameSession.Mode.ENDLESS)
	var top_speed := 0.0
	for _f in 60 * 45:
		_bot(game, 90.0)
		await get_tree().physics_frame
		top_speed = maxf(top_speed, game.bike.speed)
	print("    45 s: distance %.0f m, crashes %d, top speed %.1f km/h" % [game.distance, game.crashes, top_speed * 3.6])
	_check(top_speed > 5.0, "pedalling 90 RPM reaches > 18 km/h")
	_check(top_speed < 8.0, "pedalling 90 RPM stays under 29 km/h (0.3.0 slower bike)")
	var t := game.bike.tuning
	_check(minf(250.0, t.max_cadence_rpm) * t.speed_per_rpm * 3.6 >= t.max_speed_kmh - 0.5, "max_speed_kmh is reachable by pedalling (%.0f km/h)" % t.max_speed_kmh)
	_check(game.distance > 200.0, "bot rides > 200 m in 45 s")
	_check(game.crashes <= 3, "bot can balance (<= 3 crashes in 45 s)")

	# Stop pedalling -> must fall.
	var fell := false
	if game.phase == Game.Phase.PLAY:
		for _f in 60 * 30:
			_bot(game, 0.0)
			await get_tree().physics_frame
			if game.phase == Game.Phase.FALLEN:
				fell = true
				break
	_check(fell, "stopping pedalling makes the bike fall (%s)" % game.bike.last_crash_reason)

	# Co-op get-up: pedal + centred steering.
	var back_up := false
	for _f in 60 * 8:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 60.0
		await get_tree().physics_frame
		if game.phase == Game.Phase.PLAY:
			back_up = true
			break
	_check(back_up, "pedal + hold centre gets the bike back up")
	_check(game.bike.state == Bike.State.FOOT_DOWN, "respawn starts with foot down")
	game.queue_free()
	await get_tree().process_frame


func _test_course() -> void:
	print("[course ride]")
	RiderInput.override_enabled = true
	_bot_lane = 1
	var game := _make_game(GameSession.Mode.COURSE)
	var reasons := {}
	game.bike.crashed.connect(func(r: String) -> void:
		reasons[r] = int(reasons.get(r, 0)) + 1
		if trace:
			print("    CRASH %s at s=%.0f lat=%.2f lane=%d v=%.1f" % [r, game.bike_s, game.bike_lat, _bot_lane, game.bike.speed]))
	_check(game.road.finish_s > 1000.0, "course has a finish line (%.0f m)" % game.road.finish_s)
	var finished := false
	for _f in 60 * 400:
		_bot(game, 95.0)
		await get_tree().physics_frame
		if game.phase == Game.Phase.FINISHED:
			finished = true
			break
	print("    course: time %s, crashes %d, reached %.0f m" % [UiKit.format_time(game.elapsed), game.crashes, game.bike_s])
	if not reasons.is_empty():
		print("    crash reasons: ", reasons)
	_check(finished, "bot finishes the course")
	_check(game.crashes <= 6, "bot course crashes <= 6 (%d)" % game.crashes)
	game.get_tree().paused = false
	game.queue_free()
	await get_tree().process_frame

