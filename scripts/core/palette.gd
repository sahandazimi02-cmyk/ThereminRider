@tool
## The only place colours are defined. Materials are cached per colour id.
class_name Palette
extends RefCounted

const COLORS := {
	"sky_top": Color(0.32, 0.55, 0.85),
	"sky_horizon": Color(0.78, 0.86, 0.93),
	"ground_horizon": Color(0.45, 0.55, 0.40),
	"fog": Color(0.74, 0.82, 0.88),
	"grass": Color(0.42, 0.62, 0.33),
	"asphalt": Color(0.24, 0.25, 0.28),
	"shoulder": Color(0.55, 0.52, 0.45),
	"line_white": Color(0.93, 0.93, 0.90),
	"line_yellow": Color(0.96, 0.78, 0.22),
	"rail": Color(0.72, 0.75, 0.78),
	"rail_post": Color(0.45, 0.47, 0.50),
	"trunk": Color(0.42, 0.29, 0.18),
	"leaves_a": Color(0.20, 0.46, 0.26),
	"leaves_b": Color(0.30, 0.55, 0.22),
	"rock": Color(0.55, 0.55, 0.53),
	"bike_frame": Color(0.86, 0.22, 0.20),
	"bike_dark": Color(0.12, 0.12, 0.14),
	"bike_metal": Color(0.70, 0.72, 0.75),
	"tire": Color(0.09, 0.09, 0.10),
	"rider_shirt": Color(0.20, 0.55, 0.85),
	"rider_pants": Color(0.18, 0.20, 0.30),
	"rider_skin": Color(0.93, 0.74, 0.60),
	"rider_glove": Color(0.14, 0.14, 0.16),
	"helmet": Color(0.98, 0.84, 0.25),
	"cone": Color(0.98, 0.45, 0.10),
	"cone_band": Color(0.96, 0.96, 0.96),
	"barrier_red": Color(0.85, 0.15, 0.15),
	"barrier_white": Color(0.95, 0.95, 0.95),
	"car_a": Color(0.25, 0.42, 0.75),
	"car_b": Color(0.80, 0.80, 0.82),
	"car_c": Color(0.35, 0.65, 0.40),
	"car_glass": Color(0.20, 0.27, 0.35),
	"pothole": Color(0.035, 0.035, 0.04),
	"pothole_deep": Color(0.0, 0.0, 0.0),
	"pothole_rim": Color(0.55, 0.53, 0.49),
	"spark": Color(1.0, 0.78, 0.30),
	"dust": Color(0.66, 0.60, 0.50),
	"debris": Color(0.30, 0.30, 0.32),
	"crash_flash": Color(0.95, 0.12, 0.08),
	"finish_a": Color(0.97, 0.97, 0.97),
	"finish_b": Color(0.08, 0.08, 0.08),
	"start_banner": Color(0.20, 0.70, 0.45),
	"hud_text": Color(0.97, 0.97, 0.95),
	"hud_outline": Color(0.05, 0.06, 0.08),
	"hud_panel": Color(0.05, 0.07, 0.10, 0.55),
	"hud_track": Color(0.85, 0.88, 0.92, 0.35),
	"hud_good": Color(0.40, 0.90, 0.50),
	"hud_warn": Color(0.98, 0.78, 0.25),
	"hud_bad": Color(0.95, 0.30, 0.25),
	"hud_accent": Color(0.45, 0.80, 0.95),
}

static var _materials: Dictionary = {}


static func color(id: String) -> Color:
	return COLORS.get(id, Color.MAGENTA)


## Shared flat-ish material for a palette colour.
static func mat(id: String, double_sided: bool = false) -> StandardMaterial3D:
	var key := id + ("_2s" if double_sided else "")
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color(id)
	m.roughness = 0.9
	m.metallic = 0.0
	if double_sided:
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_materials[key] = m
	return m


## Glowing (unshaded) material, e.g. sparks.
static func glow_mat(id: String) -> StandardMaterial3D:
	var key := id + "_glow"
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color(id)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_materials[key] = m
	return m
