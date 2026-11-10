## Road, rails, obstacles, endless difficulty, crash reset and cameras.
## Saved as res://data/road_tuning.tres.
class_name RoadTuning
extends Resource

const PATH := "res://data/road_tuning.tres"

@export_group("Road shape")
@export_range(1.5, 4.0, 0.05) var lane_width_m: float = 2.6
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

@export_group("Endless generator")
@export_range(20.0, 400.0, 5.0) var straight_min_m: float = 50.0
@export_range(20.0, 600.0, 5.0) var straight_max_m: float = 180.0
@export_range(20.0, 300.0, 5.0) var curve_len_min_m: float = 50.0
@export_range(20.0, 400.0, 5.0) var curve_len_max_m: float = 130.0
## Gentlest curve radius at the start.
@export_range(30.0, 800.0, 5.0) var curve_radius_easy_m: float = 160.0
## Tightest curve radius once difficulty is maxed.
@export_range(15.0, 400.0, 5.0) var curve_radius_hard_m: float = 55.0
## Curvature ramps in/out over this distance (no sudden steering jumps).
@export_range(0.0, 60.0, 1.0) var curve_ease_m: float = 20.0
## Keeps the road heading within this angle of the start so it never loops.
@export_range(10.0, 85.0, 1.0) var max_heading_drift_deg: float = 55.0
## Distance over which endless difficulty goes from easy to hard.
@export_range(200.0, 10000.0, 50.0) var difficulty_ramp_m: float = 3000.0

@export_group("Obstacles")
## Gap between obstacles at the start of endless mode.
@export_range(10.0, 300.0, 1.0) var obstacle_gap_easy_m: float = 70.0
## Gap between obstacles at max difficulty.
@export_range(5.0, 200.0, 1.0) var obstacle_gap_hard_m: float = 28.0
## Random +/- spread on each gap (fraction).
@export_range(0.0, 0.9, 0.01) var obstacle_gap_jitter: float = 0.35
## Relative chance of each obstacle type.
@export_range(0.0, 10.0, 0.1) var weight_cones: float = 3.0
@export_range(0.0, 10.0, 0.1) var weight_barrier: float = 2.0
@export_range(0.0, 10.0, 0.1) var weight_car: float = 1.5
@export_range(0.0, 10.0, 0.1) var weight_pothole: float = 1.5

@export_group("Crash & reset")
## Time on the ground before the get-up prompt starts counting.
@export_range(0.0, 5.0, 0.1) var min_down_s: float = 1.0
## Both players must hold their part this long to get back up.
@export_range(0.3, 6.0, 0.1) var reset_hold_s: float = 2.0
## Pedal player: at least this cadence.
@export_range(5.0, 120.0, 1.0) var reset_min_cadence_rpm: float = 30.0
## Steering player: within this much of centre.
@export_range(0.02, 0.6, 0.01) var reset_center_tolerance: float = 0.2
## Progress drains this many times faster than it fills when you let go.
@export_range(0.0, 4.0, 0.05) var reset_decay_rate: float = 1.0
## Respawn this far behind the crash.
@export_range(0.0, 50.0, 1.0) var respawn_back_m: float = 6.0
## Keep the respawn spot this far from obstacles in that lane.
@export_range(2.0, 40.0, 1.0) var respawn_clearance_m: float = 12.0
@export_range(0.0, 10.0, 0.5) var countdown_s: float = 3.0

@export_group("Cameras")
@export_range(2.0, 12.0, 0.1) var chase_distance_m: float = 4.6
@export_range(0.5, 6.0, 0.1) var chase_height_m: float = 2.0
@export_range(0.0, 10.0, 0.1) var chase_look_ahead_m: float = 3.0
## How quickly the chase camera catches up (1/s).
@export_range(0.5, 20.0, 0.1) var chase_follow_rate: float = 5.0
## How much of the bike's lean the chase camera copies.
@export_range(0.0, 1.0, 0.01) var chase_roll_factor: float = 0.15
@export_range(40.0, 110.0, 1.0) var chase_fov_deg: float = 70.0
## How much of the lean the first-person camera copies (1 = full).
@export_range(0.0, 1.0, 0.01) var fp_roll_factor: float = 0.65
@export_range(-40.0, 10.0, 0.5) var fp_pitch_deg: float = -9.0
@export_range(40.0, 110.0, 1.0) var fp_fov_deg: float = 78.0


static func load_default() -> RoadTuning:
	if ResourceLoader.exists(PATH):
		var res := load(PATH) as RoadTuning
		if res != null:
			return res
	return RoadTuning.new()
