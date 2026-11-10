## Pause menu and Course results screen. Runs while the tree is paused.
class_name PauseMenu
extends CanvasLayer

const RESULTS_FOCUS_DELAY_S := 2.0

var game: Game
var _box: VBoxContainer
var _title: Label
var _buttons: Array[Button] = []
var _root: Control
var _results := false


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = UiKit.centered()
	add_child(_root)
	var panel := UiKit.panel()
	_root.add_child(panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 12)
	panel.add_child(_box)
	_title = UiKit.label("PAUSED", 44, HORIZONTAL_ALIGNMENT_CENTER)
	_box.add_child(_title)
	_buttons.append(UiKit.button("Resume", _on_resume))
	_buttons.append(UiKit.button("Restart", _on_restart))
	_buttons.append(UiKit.button("Main menu", _on_menu))
	for b in _buttons:
		_box.add_child(b)
	_root.visible = false


func open() -> void:
	Engine.time_scale = 1.0  # never leave crash slow motion running under the menu
	if _results:
		return
	if _root.visible:
		_on_resume()
		return
	_results = false
	_title.text = "PAUSED"
	_buttons[0].visible = true
	_root.visible = true
	get_tree().paused = true
	_buttons[0].grab_focus()


## Shown at the finish line. Focus waits a moment so pedal taps (A) don't
## instantly press a button.
func open_results() -> void:
	_results = true
	_title.text = "FINISHED"
	_buttons[0].visible = false
	_buttons[1].text = "Ride again"
	_root.visible = true
	for b in _buttons:
		b.disabled = true
	get_tree().create_timer(RESULTS_FOCUS_DELAY_S).timeout.connect(_enable_results)


func _enable_results() -> void:
	for b in _buttons:
		b.disabled = false
	if _root.visible:
		_buttons[1].grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and not _results and event.is_action_pressed("pause", false):
		get_viewport().set_input_as_handled()
		_on_resume()


func _on_resume() -> void:
	_root.visible = false
	get_tree().paused = false


func _on_restart() -> void:
	_root.visible = false
	_results = false
	_buttons[1].text = "Restart"
	get_tree().paused = false
	game.save_scores()
	game.restart()


func _on_menu() -> void:
	game.save_scores()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
