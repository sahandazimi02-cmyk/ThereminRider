# Tuning

Every gameplay number lives in one of three Resources. Edit them in the Godot Inspector by double-clicking the `.tres`. The `.tres` files currently store only defaults, so a value you change is saved there. Defaults and ranges are in the scripts (`@export_range`), with a doc comment on each.

| File | Script | Covers |
|---|---|---|
| `data/bike_tuning.tres` | `scripts/bike/bike_tuning.gd` | Bike geometry, pedalling → speed, steering, balance, crashing, crash effects (visual only) |
| `data/input_tuning.tres` | `scripts/input/input_tuning.gd` | OSC port/addresses, theremin smoothing/deadzone/invert, pedal-stroke → RPM |
| `data/road_tuning.tres` | `scripts/world/road_tuning.gd` | Lane width, rails, endless generator, obstacles, get-up rules, cameras, crash camera and shake |

The menu's **Balance assist** multiplies two bike values (`GameSession.ASSIST_SCALES`):

| Assist | self_stability × | gravity_scale × |
|---|---|---|
| Easy | 1.5 | 0.75 |
| Normal | 1.0 | 1.0 |
| Hard | 0.2 | 1.2 |

## How the balance physics works (`scripts/bike/bike.gd`)

The bike is simulated directly rather than with Godot's physics engine; that's simpler to tune and fully predictable. Each tick:

1. **Speed.** Target = cadence × `speed_per_rpm` (0.105 → 90 RPM ≈ 34 km/h). Pedalling above the current speed accelerates toward the target (`pedal_response`, capped by `max_accel`). Pedalling slower than you're moving = coasting: `coast_decel + coast_drag·v²`, plus `stop_brake` when nobody pedals at all (0 RPM).
2. **Steering.** Input −1…1 → front-wheel angle. The maximum angle shrinks with speed (`max_steer_deg_slow` → `max_steer_deg_fast` at `fast_speed`), `steer_expo` softens the centre, and `steer_rate_deg_s` filters jitter. Turn rate = v·tan(δ)/wheelbase. **Lateral acceleration** a = v × turn rate.
3. **Lean** (positive = right):
   ```
   lean_acc = gravity_scale · g/h · (sin(lean) − cos(lean) · a/g)     ← inverted pendulum + steering
              − k(v) · (lean − lean_eq)                               ← self-stability
              − lean_damping · lean_rate
              + wobble(v)                    ← wobble_noise below wobble_speed, plus speed_wobble always
   lean_eq = atan(a / g)          (the lean a real bike holds in that turn)
   k(v)    = self_stability · smoothstep(wobble_speed, stable_speed, v)
   ```
   For small angles this is `lean_acc ≈ (T − k) · (lean − a/g) − d · lean_rate`, with T = `gravity_scale·g/h` (the tipping strength, 4.9 on Normal). The one number **T − k** decides the feel:
   Since 0.2.1 the defaults are the 0.1.0 ones (`self_stability` 6.5, `gravity_scale` 0.4 → T ≈ 3.9): Normal is T − k > 0 below ~13 km/h and T − k < 0 above it, so at cruising speed the bike holds itself up and you mostly balance when slow. 0.2.0 tried T − k > 0 at every speed and it was far too hard (KI-19).
   - **T − k clearly above 0** (slow on Normal; every speed on Hard): the bike is an inverted pendulum. Nobody steering → it tips over within a few seconds (`speed_wobble` starts the drift). Steering *toward* the fall pushes it back up. The bigger T − k, the faster both the falling and the steering response.
   - **T − k clearly below 0** (Easy and Normal above `stable_speed`): the bike holds itself up at `lean_eq`, steering simply carves turns, and hands-off never falls.
   - **T − k ≈ 0 is the dead zone:** steering barely moves the lean, so you can't balance. Don't tune an assist level onto it. (Normal passes through it at about 13 km/h; riders only cross it, so that's fine. Hard stays well below it.)
   - The smoke test prints the time to fall with no pedalling, no steering and full steer at cruising speed (`[fall times]`).
4. **Falling.** |lean| > `fall_angle_deg` → FALLING, and the bike tips to `fallen_rest_deg` and slides to a stop (`ground_friction`). Below `stall_speed` for `stall_fall_s` it tips over regardless. Rails and obstacles call `crash()`, which keeps `impact_speed_keep` of the speed. Potholes add a random `pothole_kick` to the lean rate instead.
   - **Crash effects** (visual only, "Crash effects" group in `bike_tuning`): a hard hit throws the rider (`rider_throw_keep`, `rider_throw_up`, `rider_tumble`), spins and bounces the bike (`crash_spin_deg_s`, `crash_hop`), shakes the camera (`shake_impact`) and plays slow motion (`slowmo_scale` for `slowmo_s` real seconds). Plain falls use `soft_fall_throw` and `shake_fall`. Cones and barriers you hit go flying and stop blocking the road. The crash camera (`road_tuning` "Crash camera" group) pulls back and orbits in both camera modes.
5. **Foot down** (the start, and after every respawn): the bike is held upright until `launch_speed`. Steering is weaker (`foot_down_steer_factor`).

### Knobs to reach for first

| Feels like | Change |
|---|---|
| Theremin steering too twitchy | `bike.steer_rate_deg_s` ↓, `bike.steer_expo` ↑, `input.osc_steer_smoothing_s` ↑, Max `slide` ↑ |
| Steering can't turn enough | `bike.max_steer_deg_fast` ↑ |
| Falls too fast / too slowly overall | `bike.gravity_scale` ↓/↑, `bike.lean_damping` ↑/↓ (keep T − k well away from 0) |
| Falls too fast / too slowly when nobody steers | `bike.speed_wobble` ↓/↑, `bike.self_stability` ↑/↓ (still well below T) |
| Bike falls too soon / too late after pedalling stops | `bike.stop_brake`, `bike.coast_decel`, `bike.coast_drag` (stopping time), `bike.wobble_speed`, `bike.stall_fall_s` |
| Too fast / slow overall | `bike.speed_per_rpm`, `road.speed_fov_boost_deg` (sense of speed) |
| Crashes too much / not enough drama | "Crash effects" group (`bike_tuning`), "Crash camera" group (`road_tuning`); `slowmo_s` 0 turns slow motion off |
| Pedaller has to tap/pedal too fast | `bike.speed_per_rpm` ↑ |
| Get-up too fiddly | `road.reset_center_tolerance` ↑, `road.reset_min_cadence_rpm` ↓, `road.reset_hold_s` ↓ |
| Road too narrow / rails too close | `road.lane_width_m`, `road.rail_gap_m` |
| Endless too hard too soon | `road.difficulty_ramp_m` ↑, `road.obstacle_gap_hard_m` ↑ |

## Regression check after tuning

```
D:\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 res://scenes/test/smoke_test.tscn
```
Set `RIDER_ASSIST=0/1/2` to try Easy/Normal/Hard (Normal is the pass/fail baseline; all three pass as of 0.2.0). Set `RIDER_TRACE=1` to print the bike state 3× per second and every course crash. Tests use fixed seeds (`Game.world_seed`, `Bike.noise_seed`), so a run repeats exactly.
