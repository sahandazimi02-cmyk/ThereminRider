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
## 0.9.0: 100 -> 80. 0.11.0: 80 -> 53 (room for the extra cars).
@export_range(10.0, 300.0, 1.0) var obstacle_gap_easy_m: float = 53.0
## Gap between obstacles at max difficulty. 0.9.0: 35 -> 30. 0.11.0: 30 -> 20.
@export_range(5.0, 200.0, 1.0) var obstacle_gap_hard_m: float = 20.0
## Random +/- spread on each gap (fraction).
@export_range(0.0, 0.9, 0.01) var obstacle_gap_jitter: float = 0.35
## Relative chance of each obstacle type. 0.9.0: parked cars 1.5 -> 2.5.
## 0.10.1: cones 3.0 -> 3.2, barrier 2.0 -> 2.2, parked cars 2.5 -> 2.0,
## pothole 1.5 -> 1.9 (fewer cars, more of everything else).
## 0.11.0: parked cars 2.0 -> 6.0, barrier 2.2 -> 2.5, pothole 1.9 -> 1.5.
## Together with the shorter gaps this about doubles cars per km while the
## other hazards stay as often per km as in 0.10.1 (the weights are shares of
## the picks, so the others' weights move to keep their count per km).
@export_range(0.0, 10.0, 0.1) var weight_cones: float = 3.2
@export_range(0.0, 10.0, 0.1) var weight_barrier: float = 2.5
@export_range(0.0, 10.0, 0.1) var weight_car: float = 6.0
@export_range(0.0, 10.0, 0.1) var weight_pothole: float = 1.5
## Free road between two hazards in opposite lanes (back of one to front of
## the next, m), so there's always room to pass one and swap lanes before the
## next. Hazards that would sit closer are pushed further down the road. Also
## used for the paired potholes below. Raise it if swapping feels rushed.
@export_range(4.0, 60.0, 0.5) var swap_gap_m: float = 18.0
## Free road between two hazards in the same lane (m), so they never overlap.
@export_range(0.0, 20.0, 0.5) var same_lane_gap_m: float = 3.0
## From this difficulty on, an obstacle can come with a pothole in the other
## lane a little further on (pass the obstacle, then swap lanes at once).
@export_range(0.0, 1.0, 0.01) var paired_pothole_from: float = 0.4
## Chance of that paired pothole at full difficulty (scales with difficulty).
@export_range(0.0, 1.0, 0.01) var paired_pothole_chance: float = 0.35
## Extra random distance after swap_gap_m before the paired pothole (m).
@export_range(0.0, 30.0, 0.5) var paired_pothole_spread_m: float = 6.0

@export_group("Vehicles (car pack)")
## Parked cars and oncoming cars use the low-poly car pack in
## res://Assets/10-lowpoly-cars. Every vehicle is scaled to this overall width
## (mirrors included). Collision box = this width x the vehicle's length.
@export_range(1.2, 2.6, 0.05) var vehicle_width_m: float = 2.0
## Trucks and the bus are stretched to this length (wheels keep their shape).
@export_range(4.0, 16.0, 0.25) var truck_length_m: float = 9.5
## Chance that a car hazard (parked or oncoming) is a truck / bus.
@export_range(0.0, 1.0, 0.01) var truck_chance: float = 0.3
## Fraction of the model's width that counts for collisions (mirrors stick out).
@export_range(0.5, 1.0, 0.01) var vehicle_hit_width: float = 0.85

@export_group("Oncoming cars")
## Relative chance of an oncoming car (same scale as the weights above).
## 0.9.0: 1.4 -> 2.2. 0.10.1: 2.2 -> 1.7 (each one also keeps
## oncoming_trigger_m of road free, so it crowds out other hazards).
## 0.11.0: 1.7 -> 2.2 (most of the extra cars are parked: oncoming ones
## take so much road that more of them would crowd out everything else).
@export_range(0.0, 10.0, 0.1) var weight_oncoming: float = 2.2
## Oncoming cars only appear from this endless difficulty on (0 = right after the intro).
@export_range(0.0, 1.0, 0.01) var oncoming_from: float = 0.0
## The car appears this far ahead of the bike and starts driving towards it.
## Its whole lane is kept free of other hazards over this stretch, and the other
## lane too (so there's always somewhere to go).
@export_range(40.0, 300.0, 5.0) var oncoming_trigger_m: float = 120.0
## Driving speed at the start and at max difficulty (m/s).
@export_range(1.0, 30.0, 0.5) var oncoming_speed_easy_mps: float = 7.0
@export_range(1.0, 40.0, 0.5) var oncoming_speed_hard_mps: float = 12.0

@export_group("Cow")
## Relative chance of a cow crossing the road. 0.10.1: 1.0 -> 2.4.
## 0.11.0: 2.4 -> 2.7 (keeps cows per km the same with the extra cars).
@export_range(0.0, 10.0, 0.1) var weight_cow: float = 2.7
## Cows only appear from this endless difficulty on.
@export_range(0.0, 1.0, 0.01) var cow_from: float = 0.0
## The cow waits beside the road, this far outside the rail.
@export_range(0.0, 6.0, 0.1) var cow_side_m: float = 1.5
## Cow length (the model is scaled to it).
@export_range(1.5, 4.0, 0.05) var cow_length_m: float = 2.4
## Walking speed across the road (m/s), and how fast the walk animation plays
## (1 = as authored). 0.9.0: 1.3 -> 1.9 m/s, animation 1.0 -> 1.45 to match.
@export_range(0.3, 5.0, 0.05) var cow_speed_mps: float = 1.9
@export_range(0.2, 3.0, 0.05) var cow_anim_speed: float = 1.45
## The guard rail (and its posts) has an opening this long where a cow
## crosses, so it walks through a gap instead of through the fence (m).
@export_range(0.0, 20.0, 0.5) var cow_rail_gap_m: float = 7.0
## The cow starts walking when the bike is this many seconds away (at its
## current speed). Picked at random per cow between min and max, so it's
## somewhere different on the road each time you reach it.
@export_range(0.5, 15.0, 0.1) var cow_lead_min_s: float = 2.5
@export_range(0.5, 15.0, 0.1) var cow_lead_max_s: float = 5.5
## 0.13.0: the cow moos (from where it stands, 3D sound) when it starts
## crossing. Volume in dB, and the pitch is picked at random per moo in
## 1 +/- cow_moo_pitch_jitter so cows don't all sound the same.
@export_range(-40.0, 12.0, 0.5) var cow_moo_volume_db: float = 0.0
@export_range(0.0, 0.5, 0.01) var cow_moo_pitch_jitter: float = 0.12
## The moo is at full volume within this distance and fades with distance
## beyond it (AudioStreamPlayer3D.unit_size, m); silent past cow_moo_max_m.
@export_range(1.0, 60.0, 0.5) var cow_moo_unit_m: float = 12.0
@export_range(10.0, 400.0, 5.0) var cow_moo_max_m: float = 150.0

@export_group("Audio")
## 0.13.0: nature ambience that loops quietly the whole ride (dB; -80 = off).
@export_range(-80.0, 0.0, 0.5) var ambience_volume_db: float = -22.0
## Fade-in when a game scene opens (s).
@export_range(0.0, 10.0, 0.1) var ambience_fade_in_s: float = 2.0

@export_group("Road signs")
## Ordinary roadside signs (res://Assets/Roaad signs used random.glb) are
## scaled to this height, foot of the post to the top of the sign (m).
@export_range(1.5, 8.0, 0.1) var sign_height_m: float = 3.6
## Warning signs (res://Assets/Roaad signs hazards.glb) are bigger than real
## ones so you can read them in time (m, foot of the post to the top).
@export_range(1.5, 8.0, 0.1) var hazard_sign_height_m: float = 4.8
## Ordinary signs: distance from one to the next, picked at random between
## min and max (m). Only now and then, like a real road.
@export_range(30.0, 2000.0, 10.0) var sign_spacing_min_m: float = 160.0
@export_range(30.0, 2000.0, 10.0) var sign_spacing_max_m: float = 380.0
## Warning signs (roadwork for cones/barriers, pothole, cow) stand this far
## before their hazard (m).
@export_range(5.0, 150.0, 1.0) var hazard_sign_lead_m: float = 40.0
## No second warning sign of the same kind within this distance: one sign
## covers a run of the same hazard (m).
@export_range(0.0, 500.0, 5.0) var hazard_sign_repeat_m: float = 90.0
## Ordinary signs keep at least this far from a warning sign, so it is never
## lost among them (m).
@export_range(0.0, 200.0, 5.0) var sign_hazard_clear_m: float = 30.0
## Two signs on the same side of the road keep at least this far apart; a
## warning sign that would stand closer goes on the other side (m).
@export_range(2.0, 60.0, 1.0) var sign_min_gap_m: float = 12.0
## Gap between the guard rail and the nearest edge of a sign (m).
@export_range(0.0, 5.0, 0.1) var sign_rail_clearance_m: float = 0.8

@export_group("Score")
## Points per metre of new road ridden (riding back over road after a respawn
## doesn't count twice).
@export_range(0.0, 10.0, 0.05) var score_per_m: float = 1.0
## Points lost for each crash (the score never drops below 0).
@export_range(0.0, 2000.0, 5.0) var crash_penalty: float = 100.0

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
