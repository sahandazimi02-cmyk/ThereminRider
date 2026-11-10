## Windowed (not headless) run that saves screenshots to docs/screenshots/.
##   Godot.exe --path . --fixed-fps 60 res://scenes/test/screenshots.tscn
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
	game.cam.first_person = false
	RiderInput.override_cadence = 0.0
	for _f in 60 * 20:
		if game.phase == Game.Phase.FALLEN and game.bike.state == Bike.State.DOWN:
			break
		_bot(game, 0.0)
		await get_tree().physics_frame
	for _f in 80:
		RiderInput.override_steer = 0.0
		RiderInput.override_cadence = 60.0
		await get_tree().physics_frame
	await _shot("crashed_get_up")
	game.queue_free()
	await get_tree().process_frame

	_bot_lane = 1
	game = _make_game(GameSession.Mode.COURSE)
	for _f in 60 * 24:
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
