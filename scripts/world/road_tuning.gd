## Road, rails, obstacles, endless difficulty, crash reset and cameras.
## Saved as res://data/road_tuning.tres.
class_name RoadTuning
extends Resource

const PATH := "res://data/road_tuning.tres"

@export_group("Road shape")
## Width of one lane (the road is two lanes). 0.3.0: 2.6 -> 3.25 (25 % wider).
@export_range(1.5, 5.0, 0.05) var lane_width_m: float = 3.25
## Gap between the road edge and the guard rail.
@export_range(0.0, 1.5, 0.05) var rail_gap_m: float = 0.3
@export_range(0.3, 1.5, 0.05) var rail_height_m: float = 0.75
@export_range(1.0, 8.0, 0.25) var rail_post_spacing_m: float = 3.0
## Road is sampled this often (metres).
@export_range(0.5, 4.0, 0.25) var sample_step_m: float = 1.0
## Length of one mesh chunk.
@export_range(20.0, 200.0, 5.0) var chunk_length_m: float = 60.0
@export_range(60.0, 600.0, 10.0) var view_ahead_m: float = 260.0
@export_range(20.0, 300.0, 10.0) var keep_behind_m: float = 80.0
## Straight, obstacle-free run at the start and after the finish.
@export_range(10.0, 200.0, 5.0) var start_straight_m: float = 50.0

@export_group("Guard rails (forgiving)")
## Touching a rail doesn't crash you: the bike scrapes along it, slows and is
## turned away. Only staying on the rail this long (s) makes you crash.
@export_range(0.0, 10.0, 0.1) var rail_grace_s: float = 2.5
## Rail time drains this many times faster than it builds once you're off it.
@export_range(0.1, 10.0, 0.1) var rail_recover_rate: float = 1.5
## Speed lost per second while scraping (m/s^2).
@export_range(0.0, 10.0, 0.1) var rail_scrape_decel: float = 2.0
## The rail turns the bike until it points this far away from the rail (deg).
@export_range(0.0, 30.0, 0.5) var rail_away_deg: float = 6.0
## How fast the rail turns the bike away (deg/s).
@export_range(5.0, 300.0, 5.0) var rail_turn_deg_s: float = 45.0
## Damps the lean rate while scraping so a rail touch doesn't tip you (1/s).
@export_range(0.0, 20.0, 0.5) var rail_lean_calm: float = 4.0

@export_group("Endless generator")
## Extra straight road after the start straight in endless mode: the easy
## warm-up. Only a few, widely spaced obstacles here and no difficulty yet.
@export_range(0.0, 1000.0, 10.0) var endless_intro_m: float = 300.0
@export_range(20.0, 400.0, 5.0) var straight_min_m: float = 50.0
@export_range(20.0, 600.0, 5.0) var straight_max_m: float = 180.0
@export_range(20.0, 300.0, 5.0) var curve_len_min_m: float = 50.0
@export_range(20.0, 400.0, 5.0) var curve_len_max_m: float = 130.0
## Gentlest curve radius at the start.
@export_range(30.0, 800.0, 5.0) var curve_radius_easy_m: float = 220.0
## Tightest curve radius once difficulty is maxed.
@export_range(15.0, 400.0, 5.0) var curve_radius_hard_m: float = 70.0
## Curvature ramps in/out over this distance (no sudden steering jumps).
@export_range(0.0, 60.0, 1.0) var curve_ease_m: float = 20.0
## Keeps the road heading within this angle of the start so it never loops.
@export_range(10.0, 85.0, 1.0) var max_heading_drift_deg: float = 55.0
## Distance (after the intro) over which endless difficulty goes from easy to hard.
@export_range(200.0, 20000.0, 50.0) var difficulty_ramp_m: float = 6000.0
## Shape of the ramp: 1 = linear, higher = stays easy longer, then climbs.
@export_range(1.0, 4.0, 0.05) var difficulty_curve: float = 1.6

@export_group("Obstacles")
## Gap between obstacles at the start of endless mode.
@export_range(10.0, 300.0, 1.0) var obstacle_gap_easy_m: float = 100.0
## Gap between obstacles at max difficulty.
@export_range(5.0, 200.0, 1.0) var obstacle_gap_hard_m: float = 35.0
## Random +/- spread on each gap (fraction).
@export_range(0.0, 0.9, 0.01) var obstacle_gap_jitter: float = 0.35
## Relative chance of each obstacle type.
@export_range(0.0, 10.0, 0.1) var weight_cones: float = 3.0
@export_range(0.0, 10.0, 0.1) var weight_barrier: float = 2.0
@export_range(0.0, 10.0, 0.1) var weight_car: float = 1.5
@export_range(0.0, 10.0, 0.1) var weight_pothole: float = 1.5

@export_group("Crash & reset")
## After a crash, the bike must lie still this long before pedalling can get
## you up (so the crash is readable).
@export_range(0.0, 5.0, 0.05) var min_down_s: float = 0.4
## Back up automatically after lying down this long, no input needed.
## 0 = only pedalling gets you up.
@export_range(0.0, 10.0, 0.1) var auto_get_up_s: float = 1.5
## Pedalling at least this cadence (after min_down_s) gets you up at once.
@export_range(1.0, 120.0, 1.0) var reset_min_cadence_rpm: float = 10.0
## Respawn this far behind the crash.
@export_range(0.0, 50.0, 1.0) var respawn_back_m: float = 6.0
## Keep the respawn spot this far from obstacles in that lane.
@export_range(2.0, 40.0, 1.0) var respawn_clearance_m: float = 12.0
## Countdown at the very start of a ride.
@export_range(0.0, 10.0, 0.5) var countdown_s: float = 3.0
## Countdown after Restart (R / Back, pause menu, Ride again).
@export_range(0.0, 10.0, 0.5) var restart_countdown_s: float = 1.0

@export_group("Cameras")
@export_range(2.0, 12.0, 0.1) var chase_distance_m: float = 4.6
@export_range(0.5, 6.0, 0.1) var chase_height_m: float = 2.0
@export_range(0.0, 10.0, 0.1) var chase_look_ahead_m: float = 3.0
## How quickly the chase camera catches up (1/s).
@export_range(0.5, 20.0, 0.1) var chase_follow_rate: float = 5.0
## How much of the bike's lean the chase camera copies.
@export_range(0.0, 1.0, 0.01) var chase_roll_factor: float = 0.1
@export_range(40.0, 110.0, 1.0) var chase_fov_deg: float = 70.0
## How much of the lean the first-person view copies (1 = locked to the
## rider's head, so the bars and arms stay still on screen). The first-person
## position, angle and FOV are the FirstPersonCamera node in
## scenes/bike/bike_model.tscn.
@export_range(0.0, 1.0, 0.01) var fp_roll_factor: float = 0.45
## Extra field of view at speed_fov_full_mps and above (sense of speed).
@export_range(0.0, 30.0, 0.5) var speed_fov_boost_deg: float = 8.0
@export_range(2.0, 20.0, 0.1) var speed_fov_full_mps: float = 10.0

@export_group("Crash camera")
## After a fall the camera pulls back to watch the crash (both camera modes).
@export_range(2.0, 15.0, 0.1) var crash_cam_distance_m: float = 6.5
@export_range(0.5, 8.0, 0.1) var crash_cam_height_m: float = 3.0
## Slow orbit around the crash (deg/s).
@export_range(0.0, 60.0, 0.5) var crash_cam_orbit_deg_s: float = 14.0
## Camera shake at full strength: position offset (m) and roll (deg).
@export_range(0.0, 1.5, 0.01) var shake_offset_m: float = 0.32
@export_range(0.0, 20.0, 0.1) var shake_roll_deg: float = 5.0
## How fast shake fades (strength per second).
@export_range(0.1, 5.0, 0.05) var shake_decay: float = 1.4


static func load_default() -> RoadTuning:
	if ResourceLoader.exists(PATH):
		var res := load(PATH) as RoadTuning
		if res != null:
			return res
	return RoadTuning.new()
