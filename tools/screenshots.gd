## Windowed (not headless) run that saves screenshots to docs/screenshots/.
##   Godot.exe --path . --fixed-fps 60 --resolution 1600x900 res://scenes/test/screenshots.tscn
extends "res://tools/smoke_test.gd"

const OUT := "res://docs/screenshots/"


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	RiderInput.override_enabled = true
	var game := _make_game(GameSession.Mode.ENDLESS)
	game.cam.first_person = false
	for _f in 60 * 7:
		_bot(game, 90.0)
		await get_tree().physics_frame
	await _shot("third_person")
	game.cam.first_person = true
	for _f in 30:
		_bot(game, 90.0)
		await get_tree().physics_frame
	await _shot("first_person")

	# Hard hit: steer into the rail, catch the rider mid-air, then on the ground.
	game.cam.first_person = false
	var auto_get_up := game.road_tuning.auto_get_up_s
	game.road_tuning.auto_get_up_s = 0.0  # stay down long enough to photograph
	for _f in 60 * 10:
		if game.phase == Game.Phase.FALLEN:
			break
		RiderInput.override_steer = 0.6
		RiderInput.override_cadence = 90.0
		await get_tree().physics_frame
	if game.phase != Game.Phase.FALLEN:
		# Forgiving rails can scrape for ages; force the hit so the shot shows a crash.
		game.bike.crash("hit the rail", 1.0, game.bike.right())
	for _f in 14:
		await get_tree().physics_frame
	await _shot("crash_impact")
	for _f in 60 * 2:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 0.0
		await get_tree().physics_frame
	print("    rider %.1f m from the bike" % (game.bike.model.rider_focus() - game.bike.global_position).length())
	await _shot("crash_landed")
	game.road_tuning.auto_get_up_s = auto_get_up
	for _f in 80:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 60.0
		await get_tree().physics_frame
	await _shot("crashed_get_up")
	game.queue_free()
	await get_tree().process_frame

	# 0.8.0 moving hazards: a cow mid-crossing, an oncoming car and a parked truck.
	game = _make_game(GameSession.Mode.ENDLESS)
	game.cam.first_person = false
	for _f in 60 * 4:
		_bot(game, 90.0)
		await get_tree().physics_frame
	var rt := game.road_tuning
	var lane := game.road.lane_of(game.bike_lat)
	var cow := Obstacle.make(Obstacle.Kind.COW, game.bike_s + 12.0, 0.0, rt.lane_width_m)
	game.road._setup_hazard(cow)
	cow.lateral = game.road.lane_center(1 - lane) * 0.5
	cow.active = true
	cow.lead_s = 0.0
	print("    cow walking %s" % ("right" if cow.end_lateral > cow.start_lateral else "left"))
	var car := Obstacle.make(Obstacle.Kind.ONCOMING, game.bike_s + 24.0, game.road.lane_center(1 - lane), rt.lane_width_m)
	game.road._setup_hazard(car)
	car.speed = 0.0
	car.active = true
	var truck := Obstacle.make(Obstacle.Kind.CAR, game.bike_s + 38.0, game.road.lane_center(lane), rt.lane_width_m)
	truck.set_vehicle(_first_long(), rt)
	for o: Obstacle in [cow, car, truck]:
		game.road.obstacles.append(o)
	game.road.rebuild_chunks()  # so the rail gets its opening at the cow
	for _f in 20:
		RiderInput.override_cadence = 0.0
		await get_tree().physics_frame
	await _shot("hazards")
	game.cam.first_person = true
	for _f in 3:
		await get_tree().physics_frame
	await _shot("hazards_first_person")
	cow.node.visible = false  # a clear look at the oncoming car and the parked truck
	car.s = game.bike_s + 11.0
	truck.s = game.bike_s + 20.0
	game.road._place_node(car)
	game.road._place_node(truck)
	await get_tree().process_frame
	await _shot("vehicles_first_person")
	game.queue_free()
	await get_tree().process_frame

	# Course: look at the first pothole (s = 300 m) from just before it.
	_bot_lane = 1
	game = _make_game(GameSession.Mode.COURSE)
	for _f in 60 * 120:
		_bot(game, 95.0)
		await get_tree().physics_frame
		if game.bike_s >= 292.0:
			break
	await _shot("pothole")
	game.cam.first_person = true
	for _f in 3:
		await get_tree().physics_frame
	await _shot("pothole_first_person")
	game.cam.first_person = false
	for _f in 60 * 4:
		_bot(game, 95.0)
		await get_tree().physics_frame
	await _shot("course")
	game.queue_free()
	RiderInput.override_enabled = false
	await get_tree().process_frame

	var menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	for _f in 10:
		await get_tree().process_frame
	await _shot("main_menu")
	get_tree().quit(0)


func _first_long() -> int:
	for i in VehiclePack.count():
		if VehiclePack.is_long(i):
			return i
	return 0


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(OUT + name + ".png")
	print("saved ", name)
