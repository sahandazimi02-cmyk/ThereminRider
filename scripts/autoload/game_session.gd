## Autoload "GameSession": what the menu picked + saved best scores/settings.
extends Node

enum Mode { ENDLESS, COURSE }
enum Assist { EASY, NORMAL, HARD }

const SAVE_PATH := "user://theremin_rider.cfg"
const ASSIST_NAMES := ["Easy", "Normal", "Hard"]
## [self_stability multiplier, gravity_scale multiplier] per assist level.
## Keep Hard's self-stability well BELOW the tipping strength (see
## docs/TUNING.md "crossover"): near-equal values make steering lose its grip
## on the lean, which feels broken rather than hard.
const ASSIST_SCALES := [Vector2(5.0, 0.75), Vector2(1.0, 1.0), Vector2(0.2, 1.2)]

var mode: Mode = Mode.ENDLESS
var assist: Assist = Assist.NORMAL
var first_person: bool = false
var best_endless_m: float = 0.0
var best_course_s: float = 0.0

var _cfg := ConfigFile.new()


func _ready() -> void:
	if _cfg.load(SAVE_PATH) == OK:
		assist = clampi(int(_cfg.get_value("settings", "assist", Assist.NORMAL)), 0, 2) as Assist
		first_person = bool(_cfg.get_value("settings", "first_person", false))
		best_endless_m = float(_cfg.get_value("best", "endless_m", 0.0))
		best_course_s = float(_cfg.get_value("best", "course_s", 0.0))


func save() -> void:
	_cfg.set_value("settings", "assist", int(assist))
	_cfg.set_value("settings", "first_person", first_person)
	_cfg.set_value("best", "endless_m", best_endless_m)
	_cfg.set_value("best", "course_s", best_course_s)
	_cfg.save(SAVE_PATH)


func assist_name() -> String:
	return ASSIST_NAMES[int(assist)]


func assist_scale() -> Vector2:
	return ASSIST_SCALES[int(assist)]


## Returns true if this is a new record.
func submit_endless(distance_m: float) -> bool:
	if distance_m > best_endless_m:
		best_endless_m = distance_m
		save()
		return true
	return false


func submit_course(time_s: float) -> bool:
	if best_course_s <= 0.0 or time_s < best_course_s:
		best_course_s = time_s
		save()
		return true
	return false
