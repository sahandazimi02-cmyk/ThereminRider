## Main gameplay scene. Builds the world, drives the bike each physics tick,
## checks rails/obstacles/finish, runs the crash -> co-op get-up flow, and
## feeds the HUD. Mode comes from GameSession (Endless or Course).
class_name Game
extends Node3D

enum Phase { COUNTDOWN, PLAY, FALLEN, FINISHED }

const MPS_TO_KMH := 3.6

## Tests set these before adding the scene.
var skip_countdown := false
var force_mode := -1
var world_seed := 0
## Tests turn this off so bot runs don't overwrite the players' best scores.
var record_scores := true

var bike_tuning: BikeTuning
var road_tuning: RoadTuning
var mode: GameSession.Mode = GameSession.Mode.ENDLESS

var road: RoadWorld
var bike: Bike
var cam: BikeCamera
var hud: Hud
var pause_menu: PauseMenu
var ground: MeshInstance3D
var sun: DirectionalLight3D

var phase: Phase = Phase.COUNTDOWN
var bike_s := 0.0
var bike_lat := 0.0
var distance := 0.0
var streak_start_s := 0.0
var best_streak := 0.0
var elapsed := 0.0
var crashes := 0
var reset_progress := 0.0
var down_time := 0.0
var crash_s := 0.0
var crash_lat := 0.0
var new_record := false

var _countdown := 0.0
var _last_shown_count := -1


func _ready() -> void:
	bike_tuning = BikeTuning.load_default()
	road_tuning = RoadTuning.load_default()
	mode = GameSession.mode
	if force_mode >= 0:
		mode = force_mode as GameSession.Mode

	_build_environment()
	road = RoadWorld.new()
	road.name = "Road"
	road.setup(road_tuning, mode == GameSession.Mode.ENDLESS, world_seed)
	add_child(road)

	bike = Bike.new()
	bike.name = "Bike"
	bike.tuning = bike_tuning
	bike.assist_scale = GameSession.assist_scale()
	add_child(bike)
	bike.crashed.connect(_on_bike_crashed)

	cam = BikeCamera.new()
	cam.name = "Camera"
	cam.bike = bike
	cam.tuning = road_tuning
	add_child(cam)
	cam.current = true
	cam.first_person = GameSession.first_person

	hud = Hud.new()
	add_child(hud)
	pause_menu = PauseMenu.new()
	pause_menu.game = self
	add_child(pause_menu)

	_start_run()


func _start_run() -> void:
	var s0 := road.start_s()
	bike.respawn(road.path.point_at(s0, road.lane_center(1)), road.path.yaw_at(s0))
	road.path.reset_hint(s0)
	bike_s = s0
	streak_start_s = s0
	distance = 0.0
	elapsed = 0.0
	crashes = 0
	best_streak = 0.0
	new_record = false
	road.update_around(s0)
	cam.snap()
	_countdown = 0.0 if skip_countdown else road_tuning.countdown_s
	phase = Phase.COUNTDOWN
	_last_shown_count = -1
	hud.clear_message()


func restart() -> void:
	_start_run()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera", false):
		cam.first_person = not cam.first_person
		GameSession.first_person = cam.first_person
		GameSession.save()
	elif event.is_action_pressed("pause", false):
		pause_menu.open()
	elif event.is_action_pressed("toggle_debug", false):
		hud.toggle_debug()
	elif event.is_action_pressed("debug_reset", false):
		if phase == Phase.PLAY or phase == Phase.FALLEN:
			_respawn(bike_s if bike.is_upright() else crash_s)


func _physics_process(dt: float) -> void:
	var steer := RiderInput.steer
	var cadence := RiderInput.cadence_rpm
	match phase:
		Phase.COUNTDOWN:
			bike.step(dt, steer, 0.0)
			_countdown -= dt
			var n := int(ceil(_countdown))
			if _countdown <= 0.0:
				phase = Phase.PLAY
				hud.message("GO!", "", 1.0)
			elif n != _last_shown_count:
				_last_shown_count = n
				hud.message(str(n), "Pedal to start. Steer to balance.")
		Phase.PLAY:
			bike.step(dt, steer, cadence)
			elapsed += dt
			_track()
			_check_collisions()
		Phase.FALLEN:
			bike.step(dt, steer, cadence)
			elapsed += dt if mode == GameSession.Mode.COURSE else 0.0
			_track()
			_update_get_up(dt)
		Phase.FINISHED:
			bike.step(dt, steer, cadence)
			_track()
	road.update_around(bike_s)
	_update_ground()
	_update_hud()


func _track() -> void:
	var loc := road.path.locate(bike.position)
	bike_s = loc.x
	bike_lat = loc.y
	distance = maxf(distance, bike_s - road.start_s())
	if bike.is_upright():
		best_streak = maxf(best_streak, bike_s - streak_start_s)


func _check_collisions() -> void:
	if not bike.is_upright():
		return
	var limit := road.rail_offset() - bike_tuning.collision_half_width_m
	if absf(bike_lat) > limit:
		var side := signf(bike_lat)
		bike.position = road.path.point_at(bike_s, side * limit)
		bike.crash("hit the rail", -side)
		return
	var o := road.check_hit(bike_s, bike_lat, bike_tuning.collision_half_length_m, bike_tuning.collision_half_width_m)
	if o != null:
		if o.crashes:
			bike.crash("hit the " + o.kind_name(), signf(bike_lat - o.lateral))
		else:
			o.hit = true
			bike.hit_pothole()
			hud.message("POTHOLE!", "", 0.8)
	if mode == GameSession.Mode.COURSE and road.finish_s > 0.0 and bike_s >= road.finish_s:
		_finish()


func _on_bike_crashed(reason: String) -> void:
	if phase != Phase.PLAY:
		return
	crashes += 1
	crash_s = bike_s
	crash_lat = bike_lat
	phase = Phase.FALLEN
	down_time = 0.0
	reset_progress = 0.0
	hud.message("CRASH!", reason.capitalize(), 0.0)


func _update_get_up(dt: float) -> void:
	if bike.state != Bike.State.DOWN:
		return
	down_time += dt
	if down_time < road_tuning.min_down_s:
		return
	var pedal_ok := RiderInput.cadence_rpm >= road_tuning.reset_min_cadence_rpm
	var steer_ok := absf(RiderInput.steer) <= road_tuning.reset_center_tolerance and RiderInput.hand_present
	if pedal_ok and steer_ok:
		reset_progress += dt / road_tuning.reset_hold_s
	else:
		reset_progress = maxf(0.0, reset_progress - dt * road_tuning.reset_decay_rate / road_tuning.reset_hold_s)
	var pedal_txt := "PEDAL  [OK]" if pedal_ok else "PEDAL  (keep pedalling)"
	var steer_txt := "STEER CENTRED  [OK]" if steer_ok else "STEER  (hold the middle)"
	hud.message("GET BACK UP", "%s      %s" % [pedal_txt, steer_txt])
	if reset_progress >= 1.0:
		_respawn(crash_s)


func _respawn(at_s: float) -> void:
	var s := maxf(road.start_s(), at_s - road_tuning.respawn_back_m)
	var preferred := road.lane_of(crash_lat if not bike.is_upright() else bike_lat)
	var chosen_s := s
	var chosen_lane := preferred
	var found := false
	for back in 12:
		var try_s := maxf(road.start_s(), s - float(back) * 4.0)
		for lane: int in [preferred, 1 - preferred]:
			if road.is_clear(try_s, road.lane_center(lane), road_tuning.respawn_clearance_m):
				chosen_s = try_s
				chosen_lane = lane
				found = true
				break
		if found:
			break
	bike.respawn(road.path.point_at(chosen_s, road.lane_center(chosen_lane)), road.path.yaw_at(chosen_s))
	road.path.reset_hint(chosen_s)
	bike_s = chosen_s
	streak_start_s = chosen_s
	reset_progress = 0.0
	phase = Phase.PLAY
	cam.snap()
	hud.message("GO!", "", 0.8)


func _finish() -> void:
	phase = Phase.FINISHED
	new_record = GameSession.submit_course(elapsed) if record_scores else false
	var best := UiKit.format_time(GameSession.best_course_s)
	hud.message("FINISH!", "Time %s    Crashes %d    Best %s%s" % [
			UiKit.format_time(elapsed), crashes, best, "  NEW RECORD!" if new_record else ""])
	pause_menu.open_results()


## Called by the pause menu before leaving the scene.
func save_scores() -> void:
	if mode == GameSession.Mode.ENDLESS and record_scores:
		new_record = GameSession.submit_endless(best_streak)


func _update_ground() -> void:
	var p := bike.global_position
	ground.global_position = Vector3(snappedf(p.x, 10.0), -0.03, snappedf(p.z, 10.0))
	sun.global_position = p


func _update_hud() -> void:
	var kmh := bike.speed * MPS_TO_KMH
	hud.speed_label.text = "%d km/h" % int(round(kmh))
	hud.cadence_label.text = "Pedal %d RPM" % int(round(RiderInput.cadence_rpm))
	if mode == GameSession.Mode.ENDLESS:
		hud.score_label.text = "ENDLESS   %d m\nStreak %d m   Best streak %d m\nCrashes %d" % [
				int(distance), int(maxf(0.0, bike_s - streak_start_s)) if bike.is_upright() else 0,
				int(maxf(best_streak, GameSession.best_endless_m)), crashes]
	else:
		var remaining := maxf(0.0, road.finish_s - bike_s)
		hud.score_label.text = "COURSE   %s\n%d m to finish\nCrashes %d" % [UiKit.format_time(elapsed), int(remaining), crashes]

	var steer_src := RiderInput.source_name(RiderInput.steer_source)
	var pedal_src := RiderInput.source_name(RiderInput.pedal_source)
	var steer_state := "THEREMIN" if steer_src == "OSC" else ("CONTROLLER (left stick)" if steer_src == "PAD" else "NO SIGNAL")
	if steer_src == "OSC" and not RiderInput.hand_present:
		steer_state = "THEREMIN - hand not detected!"
	var pedal_state := "BIKE (OSC)" if pedal_src == "OSC" else ("CONTROLLER (tap A / Space)" if pedal_src == "PAD" else "NO SIGNAL")
	hud.input_label.text = "Steer: %s\nPedal: %s\nInput mode: %s (F2)    Camera: %s (C / Y)\nAssist: %s" % [
			steer_state, pedal_state, RiderInput.mode_name(),
			"1st person" if cam.first_person else "3rd person", GameSession.assist_name()]

	var g := hud.gauges
	g.steer = RiderInput.steer
	g.steer_ok = RiderInput.hand_present and RiderInput.steer_source != RiderInput.Source.NONE
	g.lean_deg = rad_to_deg(bike.lean)
	g.lean_eq_deg = rad_to_deg(bike.lean_eq)
	g.fall_deg = bike_tuning.fall_angle_deg
	g.reset_progress = reset_progress if phase == Phase.FALLEN and bike.state == Bike.State.DOWN else -1.0

	if hud.debug_label.visible:
		hud.debug_label.text = "state %s  phase %s\nspeed %.2f m/s (target %.2f)\nlean %.1f deg  rate %.1f  eq %.1f  k %.2f\nsteer in %.2f  angle %.1f deg  yaw rate %.2f\ns %.1f  lateral %.2f  difficulty %.2f\nOSC %s  %.0f pkt/s  last %s %s\npad steer %.2f cadence %.0f | osc steer %.2f cadence %.0f" % [
				bike.state_name(), Phase.keys()[phase], bike.speed, bike.target_speed,
				rad_to_deg(bike.lean), rad_to_deg(bike.lean_rate), rad_to_deg(bike.lean_eq), bike.stability_k,
				RiderInput.steer, rad_to_deg(bike.steer_angle), bike.yaw_rate,
				bike_s, bike_lat, road.difficulty,
				"bound" if OscReceiver.bound else "NOT BOUND", OscReceiver.packets_per_s,
				OscReceiver.last_address, str(OscReceiver.last_args),
				RiderInput.pad_steer, RiderInput.pad_cadence, RiderInput.osc_steer, RiderInput.osc_cadence]


func _build_environment() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Palette.color("sky_top")
	sky_mat.sky_horizon_color = Palette.color("sky_horizon")
	sky_mat.ground_horizon_color = Palette.color("ground_horizon")
	sky_mat.ground_bottom_color = Palette.color("grass")
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Palette.color("fog")
	env.fog_density = 0.004
	env.fog_sky_affect = 0.3
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	sun = DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-50.0), deg_to_rad(-35.0), 0.0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)

	ground = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(2000.0, 2000.0)
	ground.mesh = plane
	ground.material_override = Palette.mat("grass")
	add_child(ground)
