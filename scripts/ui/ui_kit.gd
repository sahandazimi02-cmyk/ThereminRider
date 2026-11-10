## Helpers for building UI in code with consistent styling.
class_name UiKit
extends RefCounted


static func label(text: String, font_size: int = 22, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Palette.color("hud_text"))
	l.add_theme_color_override("font_outline_color", Palette.color("hud_outline"))
	l.add_theme_constant_override("outline_size", maxi(4, font_size / 5))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func button(text: String, callback: Callable, font_size: int = 26) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 54)
	b.add_theme_font_size_override("font_size", font_size)
	b.pressed.connect(callback)
	return b


static func panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Palette.color("hud_panel")
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(18)
	p.add_theme_stylebox_override("panel", sb)
	return p


## Full-screen CenterContainer anchored to its parent.
static func centered() -> CenterContainer:
	var c := CenterContainer.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return c


## One line saying who does what in the active control profile.
static func input_profile_hint() -> String:
	match GameSession.input_profile:
		GameSession.InputProfile.THEREMIN_BIKE:
			return "Steer with the theremin, pedal the stationary bike (both through Max)."
		GameSession.InputProfile.THEREMIN_CONTROLLER:
			return "Steer with the theremin (Max). Pedal by tapping the pad's A button or Space / W / Up."
	return "Steer with the left stick or the A / D keys. Pedal by tapping the pad's A button or Space / W / Up."


static func format_time(t: float) -> String:
	var m := int(t / 60.0)
	var s := t - m * 60.0
	return "%d:%04.1f" % [m, s]
