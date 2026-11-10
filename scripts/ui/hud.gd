## In-game HUD. The game pushes values in each frame via the public vars/methods.
class_name Hud
extends CanvasLayer

var gauges: HudGauges
var score_label: Label
var speed_label: Label
var cadence_label: Label
var input_label: Label
var center_label: Label
var sub_label: Label
var debug_label: Label
var help_label: Label

var _flash_t := 0.0


func _ready() -> void:
	layer = 5
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	score_label = UiKit.label("", 26)
	score_label.position = Vector2(24, 18)
	root.add_child(score_label)

	speed_label = UiKit.label("0", 56, HORIZONTAL_ALIGNMENT_RIGHT)
	speed_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	speed_label.offset_left = -360
	speed_label.offset_right = -24
	speed_label.offset_top = 10
	root.add_child(speed_label)

	cadence_label = UiKit.label("", 24, HORIZONTAL_ALIGNMENT_RIGHT)
	cadence_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	cadence_label.offset_left = -460
	cadence_label.offset_right = -24
	cadence_label.offset_top = 84
	root.add_child(cadence_label)

	input_label = UiKit.label("", 18)
	input_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	input_label.offset_top = -120
	input_label.offset_left = 24
	input_label.offset_right = 600
	root.add_child(input_label)

	help_label = UiKit.label("", 16, HORIZONTAL_ALIGNMENT_RIGHT)
	help_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	help_label.offset_top = -96
	help_label.offset_left = -560
	help_label.offset_right = -24
	help_label.text = "C / Y: camera     Esc / Start: pause\nF2: input mode     F1: debug     R: quick reset"
	root.add_child(help_label)

	center_label = UiKit.label("", 64, HORIZONTAL_ALIGNMENT_CENTER)
	center_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center_label.offset_left = -700
	center_label.offset_right = 700
	center_label.offset_top = -120
	center_label.offset_bottom = -40
	root.add_child(center_label)

	sub_label = UiKit.label("", 28, HORIZONTAL_ALIGNMENT_CENTER)
	sub_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	sub_label.offset_left = -700
	sub_label.offset_right = 700
	sub_label.offset_top = -30
	sub_label.offset_bottom = 60
	root.add_child(sub_label)

	debug_label = UiKit.label("", 16)
	debug_label.position = Vector2(24, 130)
	debug_label.visible = false
	root.add_child(debug_label)

	gauges = HudGauges.new()
	gauges.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gauges.offset_bottom = -24
	root.add_child(gauges)


func _process(delta: float) -> void:
	if _flash_t > 0.0:
		_flash_t -= delta
		if _flash_t <= 0.0:
			center_label.text = ""


## Shows a big message; duration <= 0 keeps it until replaced.
func message(text: String, sub: String = "", duration: float = 0.0) -> void:
	center_label.text = text
	sub_label.text = sub
	_flash_t = duration


func clear_message() -> void:
	center_label.text = ""
	sub_label.text = ""
	_flash_t = 0.0


func toggle_debug() -> void:
	debug_label.visible = not debug_label.visible
