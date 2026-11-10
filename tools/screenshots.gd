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
	for _f in 60 * 10:
		if game.phase == Game.Phase.FALLEN:
			break
		RiderInput.override_steer = 0.6
		RiderInput.override_cadence = 90.0
		await get_tree().physics_frame
	for _f in 14:
		await get_tree().physics_frame
	await _shot("crash_impact")
	for _f in 60 * 2:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 0.0
		await get_tree().physics_frame
	print("    rider %.1f m from the bike" % (game.bike.model.rider_focus() - game.bike.global_position).length())
	await _shot("crash_landed")
	for _f in 80:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 60.0
		await get_tree().physics_frame
	await _shot("crashed_get_up")
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


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(OUT + name + ".png")
	print("saved ", name)
