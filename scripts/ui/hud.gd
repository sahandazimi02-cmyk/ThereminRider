## In-game HUD. Kept minimal on purpose: control profile (top-left), speed
## (top-right), speedometer (bottom-left), steering bar + lean dial (bottom
## centre), and the big centre messages. F1 shows the debug readout.
## The game pushes values in each frame via the public vars/methods.
class_name Hud
extends CanvasLayer

var gauges: HudGauges
var speedometer: HudSpeedometer
var profile_label: Label
var warn_label: Label
var speed_label: Label
var center_label: Label
var sub_label: Label
var debug_label: Label

var _flash_t := 0.0
var _flash_rect: ColorRect
var _flash_alpha := 0.0


func _ready() -> void:
	layer = 5
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Full-screen colour flash for crashes (drawn under the text).
	_flash_rect = ColorRect.new()
	_flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.color = Color(0, 0, 0, 0)
	root.add_child(_flash_rect)

	profile_label = UiKit.label("", 22)
	profile_label.position = Vector2(24, 18)
	root.add_child(profile_label)

	warn_label = UiKit.label("", 20)
	warn_label.add_theme_color_override("font_color", Palette.color("hud_warn"))
	warn_label.position = Vector2(24, 50)
	root.add_child(warn_label)

	speed_label = UiKit.label("0", 56, HORIZONTAL_ALIGNMENT_RIGHT)
	speed_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	speed_label.offset_left = -360
	speed_label.offset_right = -24
	speed_label.offset_top = 10
	root.add_child(speed_label)

	speedometer = HudSpeedometer.new()
	speedometer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	speedometer.offset_left = 24
	speedometer.offset_right = 24 + 250
	speedometer.offset_top = -24 - 250
	speedometer.offset_bottom = -24
	root.add_child(speedometer)

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
	if _flash_alpha > 0.0:
		_flash_alpha = maxf(_flash_alpha - delta * 1.6, 0.0)
		_flash_rect.color.a = _flash_alpha
	if _flash_t > 0.0:
		_flash_t -= delta
		if _flash_t <= 0.0:
			center_label.text = ""
			sub_label.text = ""


## Shows a big message; duration <= 0 keeps it until replaced.
func message(text: String, sub: String = "", duration: float = 0.0) -> void:
	center_label.text = text
	sub_label.text = sub
	_flash_t = duration


## Screen flash (fades out by itself).
func flash(color: Color, strength: float) -> void:
	_flash_alpha = clampf(strength, 0.0, 1.0)
	_flash_rect.color = Color(color, _flash_alpha)


## Big message that punches in (for crashes).
func slam(text: String, sub: String = "") -> void:
	message(text, sub)
	center_label.pivot_offset = center_label.size * 0.5
	center_label.scale = Vector2.ONE * 1.8
	var tw := create_tween()
	tw.tween_property(center_label, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Top-left text: the control profile, plus a warning line when its device is silent.
func set_profile(profile_name: String, warning: String) -> void:
	profile_label.text = profile_name
	warn_label.text = warning


func clear_message() -> void:
	center_label.text = ""
	sub_label.text = ""
	_flash_t = 0.0


func toggle_debug() -> void:
	debug_label.visible = not debug_label.visible
