## Round speedometer dial (bottom-left of the HUD). The game sets speed_kmh and
## max_kmh every frame; the dial range rounds max_kmh up to the next 10.
class_name HudSpeedometer
extends Control

## Dial sweep: 240 degrees, opening at the bottom.
const START_ANGLE := deg_to_rad(150.0)
const SWEEP := deg_to_rad(240.0)

var speed_kmh := 0.0
var max_kmh := 45.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var top := maxf(10.0, ceilf(max_kmh / 10.0) * 10.0)
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5 - 6.0
	var text_col := Palette.color("hud_text")
	var outline := Palette.color("hud_outline")
	var angle_of := func(kmh: float) -> float:
		return START_ANGLE + SWEEP * clampf(kmh / top, 0.0, 1.0)

	draw_circle(c, r, Palette.color("hud_panel"))
	draw_arc(c, r - 10.0, START_ANGLE, START_ANGLE + SWEEP, 48, Palette.color("hud_track"), 6.0)
	# Filled arc up to the current speed.
	var a_now: float = angle_of.call(speed_kmh)
	if speed_kmh > 0.5:
		draw_arc(c, r - 10.0, START_ANGLE, a_now, 48, Palette.color("hud_accent"), 6.0)

	# Ticks every 5 km/h, numbers every 10 (every 20 on a wide dial).
	var label_step := 10 if top <= 60.0 else 20
	var kmh := 0
	while kmh <= int(top):
		var a: float = angle_of.call(float(kmh))
		var dir := Vector2(cos(a), sin(a))
		var major := kmh % 10 == 0
		draw_line(c + dir * (r - (26.0 if major else 20.0)), c + dir * (r - 14.0), text_col, 3.0 if major else 1.5)
		if kmh % label_step == 0:
			var txt := str(kmh)
			var fs := 18
			var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			var p := c + dir * (r - 44.0) + Vector2(-tw * 0.5, fs * 0.35)
			draw_string_outline(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, outline)
			draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, text_col)
		kmh += 5

	# Needle.
	var nd := Vector2(cos(a_now), sin(a_now))
	draw_line(c - nd * 12.0, c + nd * (r - 20.0), Palette.color("hud_bad"), 4.0)
	draw_circle(c, 8.0, text_col)

	# Number + unit under the hub.
	var num := str(int(round(speed_kmh)))
	var nfs := 34
	var nw := font.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, nfs).x
	var np := c + Vector2(-nw * 0.5, r * 0.55)
	draw_string_outline(font, np, num, HORIZONTAL_ALIGNMENT_LEFT, -1, nfs, 6, outline)
	draw_string(font, np, num, HORIZONTAL_ALIGNMENT_LEFT, -1, nfs, text_col)
	var unit := "km/h"
	var ufs := 16
	var uw := font.get_string_size(unit, HORIZONTAL_ALIGNMENT_LEFT, -1, ufs).x
	draw_string(font, c + Vector2(-uw * 0.5, r * 0.55 + 22.0), unit, HORIZONTAL_ALIGNMENT_LEFT, -1, ufs, text_col)
