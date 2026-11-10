## Draws the steering bar, the lean gauge and the get-up progress ring.
class_name HudGauges
extends Control

const LEAN_RANGE_DEG := 60.0

var steer := 0.0
var steer_ok := true
var lean_deg := 0.0
var fall_deg := 42.0
var lean_eq_deg := 0.0
var reset_progress := -1.0  # <0 hides the ring


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var bar_w := minf(w * 0.8, 560.0)
	var bar_h := 18.0
	var cx := w * 0.5
	var bar_y := h - bar_h - 4.0

	# Steering bar
	var track := Rect2(cx - bar_w * 0.5, bar_y, bar_w, bar_h)
	draw_rect(track.grow(4.0), Palette.color("hud_panel"))
	draw_rect(track, Palette.color("hud_track"))
	draw_line(Vector2(cx, bar_y - 6.0), Vector2(cx, bar_y + bar_h + 6.0), Palette.color("hud_text"), 2.0)
	var mx := cx + steer * bar_w * 0.5
	var marker_col := Palette.color("hud_accent") if steer_ok else Palette.color("hud_bad")
	draw_rect(Rect2(mx - 6.0, bar_y - 6.0, 12.0, bar_h + 12.0), marker_col)

	# Lean gauge (half dial above the bar)
	var r := 70.0
	var c := Vector2(cx, bar_y - 26.0)
	var to_angle := func(deg: float) -> float:
		return -PI * 0.5 + deg_to_rad(clampf(deg, -LEAN_RANGE_DEG, LEAN_RANGE_DEG)) * (PI * 0.5 / deg_to_rad(LEAN_RANGE_DEG))
	draw_arc(c, r, -PI, 0.0, 32, Palette.color("hud_panel"), 16.0)
	draw_arc(c, r, to_angle.call(-LEAN_RANGE_DEG), to_angle.call(-fall_deg), 12, Palette.color("hud_bad"), 10.0)
	draw_arc(c, r, to_angle.call(fall_deg), to_angle.call(LEAN_RANGE_DEG), 12, Palette.color("hud_bad"), 10.0)
	draw_arc(c, r, to_angle.call(-fall_deg), to_angle.call(fall_deg), 24, Palette.color("hud_track"), 10.0)
	var eq_a: float = to_angle.call(lean_eq_deg)
	draw_line(c + Vector2(cos(eq_a), sin(eq_a)) * (r - 10.0), c + Vector2(cos(eq_a), sin(eq_a)) * (r + 10.0), Palette.color("hud_good"), 3.0)
	var a: float = to_angle.call(lean_deg)
	var danger := absf(lean_deg) / maxf(fall_deg, 1.0)
	var needle := Palette.color("hud_text").lerp(Palette.color("hud_bad"), clampf((danger - 0.5) * 2.0, 0.0, 1.0))
	draw_line(c, c + Vector2(cos(a), sin(a)) * (r + 4.0), needle, 4.0)
	draw_circle(c, 6.0, needle)

	# Get-up ring
	if reset_progress >= 0.0:
		var rc := Vector2(cx, h * 0.5 - 140.0)
		draw_arc(rc, 40.0, 0.0, TAU, 40, Palette.color("hud_panel"), 12.0)
		if reset_progress > 0.0:
			draw_arc(rc, 40.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(reset_progress, 0.0, 1.0), 40, Palette.color("hud_good"), 10.0)
