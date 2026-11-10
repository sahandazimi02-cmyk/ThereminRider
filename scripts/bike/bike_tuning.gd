## All bike physics numbers. Saved as res://data/bike_tuning.tres; edit in the
## Inspector. Units: metres, seconds, m/s, degrees (converted at use).
class_name BikeTuning
extends Resource

const PATH := "res://data/bike_tuning.tres"

@export_group("Geometry")
## Distance between the wheel axles.
@export_range(0.6, 1.6, 0.01) var wheelbase_m: float = 1.05
## Height of the bike + rider centre of mass. Higher = falls more slowly.
@export_range(0.5, 1.6, 0.01) var com_height_m: float = 1.0
@export_range(0.2, 0.45, 0.01) var wheel_radius_m: float = 0.34
## Half the length of the collision box along the road.
@export_range(0.3, 1.2, 0.01) var collision_half_length_m: float = 0.75
## Half the width of the collision box across the road.
@export_range(0.1, 0.6, 0.01) var collision_half_width_m: float = 0.28

@export_group("Pedalling -> speed")
## Bike speed (m/s) per crank RPM. 0.105 => 90 RPM ~ 34 km/h.
@export_range(0.02, 0.2, 0.001) var speed_per_rpm: float = 0.105
## Cadence above this is ignored (stops tap-mashing from going silly).
@export_range(60.0, 250.0, 1.0) var max_cadence_rpm: float = 150.0
## How fast speed chases the pedalling target speed (1/s).
@export_range(0.1, 5.0, 0.05) var pedal_response: float = 1.1
## Cap on forward acceleration from pedalling (m/s^2).
@export_range(0.5, 6.0, 0.1) var max_accel: float = 3.0
## Speed lost per second while coasting (pedalling slower than the bike is moving).
@export_range(0.0, 3.0, 0.01) var coast_decel: float = 1.0
## Air drag while coasting: decel = coast_decel + drag * v^2.
@export_range(0.0, 0.05, 0.0005) var coast_drag: float = 0.008
## Extra braking when nobody is pedalling at all (0 RPM), so a stopped pedaller
## makes the bike slow down and fall within a few seconds (m/s^2).
@export_range(0.0, 5.0, 0.05) var stop_brake: float = 1.2

@export_group("Steering")
## Max front-wheel angle at walking speed.
@export_range(5.0, 50.0, 0.5) var max_steer_deg_slow: float = 30.0
## Max front-wheel angle at fast_speed and above (fast bikes need tiny steering).
@export_range(1.0, 20.0, 0.25) var max_steer_deg_fast: float = 6.0
@export_range(2.0, 20.0, 0.1) var fast_speed: float = 9.0
## 1 = linear, 2 = soft centre / sharp edges.
@export_range(1.0, 3.0, 0.05) var steer_expo: float = 1.3
## How fast the front wheel can turn (deg/s). Filters theremin jitter.
@export_range(20.0, 600.0, 5.0) var steer_rate_deg_s: float = 160.0

@export_group("Balance")
## Scales gravity's tipping torque. 1 = real bike, lower = slower falls (assist).
@export_range(0.05, 1.5, 0.01) var gravity_scale: float = 0.4
## Self-righting (trail + gyroscope) strength at stable_speed and above (1/s^2).
## Must beat gravity_scale * 9.81 / com_height_m to be hands-free stable. Default
## (6.5 > 3.9) is above that, so on Normal the bike holds itself up at speed and
## you mostly balance at low speed (the 0.1.0 feel, restored in 0.2.1).
@export_range(0.0, 20.0, 0.1) var self_stability: float = 6.5
## Below this speed there is no self-righting at all: wobbly zone (m/s). ~6 km/h.
@export_range(0.2, 5.0, 0.05) var wobble_speed: float = 1.7
## At and above this speed self-righting is full strength (m/s).
@export_range(1.0, 12.0, 0.1) var stable_speed: float = 5.0
## Damping of lean rate (1/s).
@export_range(0.0, 10.0, 0.05) var lean_damping: float = 2.2
## Random wobble at standstill (rad/s^2). Fades out as you reach wobble_speed.
@export_range(0.0, 5.0, 0.01) var wobble_noise: float = 0.9
## Small random wobble at every speed (rad/s^2), so a bike nobody steers drifts off
## balance instead of balancing perfectly forever. 0 = off (0.1.0 feel).
@export_range(0.0, 2.0, 0.01) var speed_wobble: float = 0.0
## Lean angle that counts as a fall.
@export_range(15.0, 80.0, 0.5) var fall_angle_deg: float = 42.0
## Below this speed for stall_fall_s the bike tips over no matter what.
@export_range(0.0, 2.0, 0.01) var stall_speed: float = 0.6
@export_range(0.2, 5.0, 0.05) var stall_fall_s: float = 0.6

@export_group("Start / foot down")
## While starting (foot on the ground) the bike stays upright until this speed.
@export_range(0.3, 5.0, 0.05) var launch_speed: float = 2.2
## Steering is this much weaker while the foot is down.
@export_range(0.0, 1.0, 0.05) var foot_down_steer_factor: float = 0.5

@export_group("Crashing")
## Lean the bike settles at once it is lying on the ground.
@export_range(60.0, 90.0, 0.5) var fallen_rest_deg: float = 80.0
## How fast the bike tips over once falling (rad/s^2).
@export_range(1.0, 40.0, 0.5) var fall_tip_accel: float = 14.0
## Sliding friction while on the ground (m/s^2).
@export_range(0.5, 20.0, 0.1) var ground_friction: float = 7.0
## Speed kept when you smack a rail or obstacle.
@export_range(0.0, 1.0, 0.01) var impact_speed_keep: float = 0.4
## Lean-rate kick from riding over a pothole (rad/s).
@export_range(0.0, 3.0, 0.01) var pothole_kick: float = 0.9
## Speed kept after a pothole.
@export_range(0.3, 1.0, 0.01) var pothole_speed_keep: float = 0.82

@export_group("Crash effects (visual only)")
## Rider is thrown off with this share of the bike's speed on rail/obstacle hits.
@export_range(0.0, 1.5, 0.01) var rider_throw_keep: float = 0.85
## Upward launch speed of the rider on a hard hit (m/s).
@export_range(0.0, 8.0, 0.1) var rider_throw_up: float = 3.6
## Tumble rate of the thrown rider (rad/s).
@export_range(0.0, 20.0, 0.1) var rider_tumble: float = 7.0
## Rider throw strength for plain balance falls (0 = stays on the bike).
@export_range(0.0, 1.0, 0.01) var soft_fall_throw: float = 0.35
## The bike spins round on the ground after a hard hit (deg/s at the start).
@export_range(0.0, 900.0, 5.0) var crash_spin_deg_s: float = 320.0
## The bike bounces up on a hard hit (m/s).
@export_range(0.0, 5.0, 0.05) var crash_hop: float = 1.8
## Slow motion right after a hard hit: time scale and real-time length (s).
@export_range(0.05, 1.0, 0.01) var slowmo_scale: float = 0.3
@export_range(0.0, 2.0, 0.05) var slowmo_s: float = 0.6
## Camera shake on a hard hit (0..1) and on a plain fall.
@export_range(0.0, 1.0, 0.01) var shake_impact: float = 1.0
@export_range(0.0, 1.0, 0.01) var shake_fall: float = 0.45


static func load_default() -> BikeTuning:
	if ResourceLoader.exists(PATH):
		var res := load(PATH) as BikeTuning
		if res != null:
			return res
	return BikeTuning.new()
