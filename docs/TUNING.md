# Tuning

Every gameplay number lives in one of three Resources. Edit them in the Godot Inspector by double-clicking the `.tres`. The `.tres` files currently store only defaults, so a value you change is saved there. Defaults and ranges are in the scripts (`@export_range`), with a doc comment on each.

| File | Script | Covers |
|---|---|---|
| `data/bike_tuning.tres` | `scripts/bike/bike_tuning.gd` | Bike geometry, pedalling → speed, steering, balance, crashing |
| `data/input_tuning.tres` | `scripts/input/input_tuning.gd` | OSC port/addresses, theremin smoothing/deadzone/invert, pedal-stroke → RPM |
| `data/road_tuning.tres` | `scripts/world/road_tuning.gd` | Lane width, rails, endless generator, obstacles, get-up rules, cameras |

The menu's **Balance assist** multiplies two bike values (`GameSession.ASSIST_SCALES`):

| Assist | self_stability × | gravity_scale × |
|---|---|---|
| Easy | 1.5 | 0.75 |
| Normal | 1.0 | 1.0 |
| Hard | 0.2 | 1.2 |

## How the balance physics works (`scripts/bike/bike.gd`)

The bike is simulated directly rather than with Godot's physics engine; that's simpler to tune and fully predictable. Each tick:

1. **Speed.** Target = cadence × `speed_per_rpm`. Pedalling above the current speed accelerates toward the target (`pedal_response`, capped by `max_accel`). Pedalling slower than you're moving = coasting: `coast_decel + coast_drag·v²`.
2. **Steering.** Input −1…1 → front-wheel angle. The maximum angle shrinks with speed (`max_steer_deg_slow` → `max_steer_deg_fast` at `fast_speed`), `steer_expo` softens the centre, and `steer_rate_deg_s` filters jitter. Turn rate = v·tan(δ)/wheelbase. **Lateral acceleration** a = v × turn rate.
3. **Lean** (positive = right):
   ```
   lean_acc = gravity_scale · g/h · (sin(lean) − cos(lean) · a/g)     ← inverted pendulum + steering
              − k(v) · (lean − lean_eq)                               ← self-stability
              − lean_damping · lean_rate
              + wobble(v)                                             ← only below wobble_speed
   lean_eq = atan(a / g)          (the lean a real bike holds in that turn)
   k(v)    = self_stability · smoothstep(wobble_speed, stable_speed, v)
   ```
   - **Slow:** k ≈ 0, so the bike is an inverted pendulum. Steering toward the fall makes a lateral acceleration that pushes it back up, as on a real bike.
   - **Fast:** k is large, so the bike settles at `lean_eq` by itself and steering simply carves turns.
   - **Crossover.** Where k ≈ `gravity_scale·g/h` (≈ 3.9; on Normal that's around **13 km/h**), steering has almost no effect on the lean. Riders only pass through this band, but **don't set an assist level that sits on it**. That's why Hard is 0.2×, well below it, rather than 0.65×.
4. **Falling.** |lean| > `fall_angle_deg` → FALLING, and the bike tips to `fallen_rest_deg` and slides to a stop (`ground_friction`). Below `stall_speed` for `stall_fall_s` it tips over regardless. Rails and obstacles call `crash()`, which keeps `impact_speed_keep` of the speed. Potholes add a random `pothole_kick` to the lean rate instead.
5. **Foot down** (the start, and after every respawn): the bike is held upright until `launch_speed`. Steering is weaker (`foot_down_steer_factor`).

### Knobs to reach for first

| Feels like | Change |
|---|---|
| Theremin steering too twitchy | `bike.steer_rate_deg_s` ↓, `bike.steer_expo` ↑, `input.osc_steer_smoothing_s` ↑, Max `slide` ↑ |
| Steering can't turn enough | `bike.max_steer_deg_fast` ↑ |
| Falls too fast at low speed | `bike.gravity_scale` ↓, `bike.com_height_m` ↑ |
| Too easy at cruising speed | `bike.self_stability` ↓ (watch the crossover), or use Hard |
| Bike falls too soon / too late after pedalling stops | `bike.coast_decel` and `bike.coast_drag` (stopping time), `bike.wobble_speed`, `bike.stall_fall_s` |
| Pedaller has to tap/pedal too fast | `bike.speed_per_rpm` ↑ |
| Get-up too fiddly | `road.reset_center_tolerance` ↑, `road.reset_min_cadence_rpm` ↓, `road.reset_hold_s` ↓ |
| Road too narrow / rails too close | `road.lane_width_m`, `road.rail_gap_m` |
| Endless too hard too soon | `road.difficulty_ramp_m` ↑, `road.obstacle_gap_hard_m` ↑ |

## Regression check after tuning

```
D:\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 res://scenes/test/smoke_test.tscn
```
Set `RIDER_ASSIST=0/1/2` to try Easy/Normal/Hard (Normal is the pass/fail baseline). Set `RIDER_TRACE=1` to print the bike state 3× per second.
