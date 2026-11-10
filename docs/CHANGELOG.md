# Changelog

Format: newest first. Dates are YYYY-MM-DD.

## 0.3.0: 2026-11-10, slower, steadier, more forgiving

Feedback: the bike is too fast and speeds up too fast; theremin steering is still too hard (steers too much, too much sway); hitting the side should not be an instant fail; the start should be a straight, easy road and difficulty should ramp more slowly (course and endless).

### Changed
- **Road 25 % wider:** `lane_width_m` 2.6 → 3.25 (range raised to 5). Cones/barriers scale with the lane, so they still leave the other lane free.
- **Slower bike:** `speed_per_rpm` 0.105 → 0.075 (90 RPM ≈ 24 km/h, was 34), `max_accel` 3.0 → 1.5, `pedal_response` 1.1 → 0.55, `launch_speed` 2.2 → 1.8.
- **Less sensitive steering:** `max_steer_deg_slow` 30 → 22, `max_steer_deg_fast` 6 → 4, `fast_speed` 9 → 7, `steer_expo` 1.3 → 1.6 (softer centre), `steer_rate_deg_s` 160 → 90 (turns slower). Theremin: `osc_steer_deadzone` 0.03 → 0.06, `osc_steer_smoothing_s` 0.05 → 0.15.
- **New "fake" steering assist** (`bike_tuning` "Steering assist" group): `road_follow` 0.6 (the bike follows 60 % of each curve by itself) and `heading_assist` 1.2/s (heading eases back to the road direction, so holding steer moves you across the road at a steady angle and letting go straightens you out). Kinematic only, never tips the bike.
- **Less sway:** new `lean_assist` 2.0 (always-on pull toward the balanced lean), `self_stability` 6.5 → 8, `lean_damping` 2.2 → 3.2, `wobble_noise` 0.9 → 0.6, `wobble_speed` 1.7 → 1.3, `stable_speed` 5 → 3.8. Cameras copy less of the lean: `chase_roll_factor` 0.15 → 0.1, `fp_roll_factor` 0.65 → 0.45.
- **Forgiving rails:** touching a rail no longer crashes. The bike scrapes along it (sparks, small shake, "RAIL! Steer LEFT/RIGHT – x.x s"), slows, is turned away and its lean is calmed. You crash only after `rail_grace_s` (2.5 s) of rail time; it drains 1.5× as fast when you're off. New `road_tuning` "Guard rails" group. Obstacles still crash you.
- **Easy start, slower ramp:**
  - Endless: new `endless_intro_m` 300 m straight after the start straight, with only a couple of obstacles; difficulty starts after it. `difficulty_ramp_m` 3000 → 6000 and new `difficulty_curve` 1.6 (stays easy longer: ~6 % after 1 km, 33 % after 3 km, max at 6 km). `obstacle_gap_easy_m` 70 → 100, `obstacle_gap_hard_m` 28 → 35, `curve_radius_easy_m` 160 → 220, `curve_radius_hard_m` 55 → 70.
  - Course: opening straight 140 → 300 m with one cone group in the other lane, first two curves gentler (radius 120 → 180, 90 → 130), all other obstacles moved 160 m later. Finish now at 1720 m.

### Tests
- New `[rail scrape]`: touching the rail doesn't crash, steering away recovers, staying on it crashes.
- Speed checks: 90 RPM reaches > 18 km/h and stays < 29 km/h.
- `[fall times]`: full steer at cruise is now a steady turn rather than a fall (gentler steering); that line now ends at the rail instead.

### Verified
- Headless import: clean. Smoke test Normal: all pass (fall times: stop pedalling 3.2 s, hands off / full steer stay up; endless 286 m in 45 s, 0 crashes, top 24.3 km/h; course 4:02.7, 0 crashes). Easy: all pass. Hard: fails the course (11 crashes) and the rail-recovery check (the bot can't hold the Hard bike up while forced onto the rail), KI-03.
- Screenshots retaken; looked at `third_person.png` (wider road, straight start) and `course.png`. Didn't look at the others. Not played by a human, and not tried with the theremin.

## 0.2.1: 2026-11-10, steering and balance back to 0.1.0

Feedback on 0.2.0: everything else is good, but steering/balancing became far too hard. Back to the 0.1.0 balance for now; we'll tune from there.

### Changed
- Balance group restored to 0.1.0: `self_stability` 1.0 → 6.5, `gravity_scale` 0.5 → 0.4, `wobble_speed` 2.5 → 1.7, `stable_speed` 6 → 5, `fall_angle_deg` 40 → 42, `speed_wobble` 0.35 → 0 (the tunable stays, just off).
- Easy assist self-stability ×5 → ×1.5 (the 0.1.0 value).
- Kept from 0.2.0: the faster speed, `stop_brake` and harsher coasting, `stall_speed` 0.6 / `stall_fall_s` 0.6, all crash effects, potholes, Max patch.
- Result at cruising speed (34 km/h): stop pedalling still falls in 4.2 s; hands off now stays up (was 2.5–4.5 s); full lock falls in 5.8 s (was ~0.8 s).

### Tests
- `[fall times]` checks now expect the restored feel: hands off at cruise stays up > 20 s, full steer still falls (< 10 s). Stop pedalling check unchanged (1.5–6.5 s).

### Verified
- Headless import: clean. Smoke test on Normal: all pass (endless 407 m in 45 s, 0 crashes; course 2:37.2, 0 crashes). Easy: all pass. Hard: fails the course again (58 crashes), the same as 0.1.0 (KI-03).
- Not played by a human. No screenshots (nothing visual changed).

## 0.2.0: 2026-11-10, faster, harsher, more dramatic

From the first feedback: bike a bit faster, crashes more dramatic, potholes more obvious, falling takes too long when the players stop, Max patch hard to read.

### Changed
- **Faster:** `speed_per_rpm` 0.085 → 0.105 (90 RPM ≈ 34 km/h, was 27.5), `max_accel` 2.5 → 3.0, `pedal_response` 0.9 → 1.1. The camera widens its field of view with speed (`speed_fov_boost_deg`).
- **Falls sooner when the players stop:**
  - Stop pedalling: new `stop_brake` (extra braking at 0 RPM), `coast_decel` 0.55 → 1.0, `coast_drag` 0.006 → 0.008, `wobble_speed` 1.7 → 2.5, `stable_speed` 5 → 6, `stall_speed` 0.35 → 0.6, `stall_fall_s` 1.2 → 0.6. From cruising speed: 12.3 s → 4.2 s.
  - Stop steering: `self_stability` 6.5 → 1.0 and `gravity_scale` 0.4 → 0.5, so on Normal the bike needs balancing at every speed. New `speed_wobble` noise starts the drift. Hands off: never fell → 2.5–4.5 s.
  - Full lock: never fell → about 0.8 s. `fall_angle_deg` 42 → 40.
  - Easy assist self-stability ×1.5 → ×5, so Easy keeps the old "holds itself up at speed" feel.
- **Potholes:** bigger (1.36 × 1.5 m, was 1.0 × 0.9 m; hit box matches), near-black with a pitch-black centre, a lighter broken-asphalt rim and rubble. Hitting one shakes the camera and kicks up debris.
- **Max patch re-laid out** into six numbered columns in signal order (audio in → calibrate → steering → hand present → pedals → to Godot). Columns connect through `[s tr.*]` / `[r tr.*]` instead of long cables. Steering smoothing is now a number box. Column 6 has a print toggle for debugging. The generator checks its own layout.
- `impact_speed_keep` 0.25 → 0.4 (the bike slides further after a hit).

### Added
- **Crash effects** (all tunable, visual only):
  - the rider is thrown off and tumbles, bounces and slides to a stop (plain balance falls topple the rider off gently);
  - the bike spins and bounces on a hard hit;
  - sparks on rails and cars, plastic bits from cones/barriers, dust when the bike lands;
  - camera shake, a red screen flash, a punch-in "CRASH!" message, and 0.6 s of slow motion;
  - a crash camera (both camera modes) that pulls back to keep bike and rider in shot and slowly orbits;
  - cones and barriers you hit go flying and no longer block the road. Restart puts them back (and potholes work again after a restart, which they didn't before).
- `Bike.noise_seed` so tests repeat exactly.

### Tests
- New `[fall times]` checks (pure bike physics at cruising speed: no pedalling, no steering, full steer).
- New `[crash effects]` checks (rider thrown, flies up, lands lying down; knocked cones stop blocking; get-up puts the rider back).
- The test bot now uses a proper balance controller (lane error → lean target → steering), launches straight after a respawn, and looks 60 m ahead for obstacles. Course check: finish with ≤ 6 crashes.

### Verified
- Headless import: clean. Smoke test on Normal: 29/29 pass (endless 301 m in 45 s with 2 crashes; course 2:56.4 with 3 rail crashes). Easy and Hard also pass all checks (course 2:42.3 and 2:44.2, 1 crash each).
- Screenshots looked at: `third_person`, `crash_impact` (rider mid-air, sparks), `crash_landed` (crash camera with bike and rider), `pothole`, `pothole_first_person`. Not looked at this time: `first_person`, `crashed_get_up`, `course`, `main_menu`.
- Max patch: inlet/outlet indices, send/receive pairs and layout checked by script, plus a rough SVG preview. **Not opened in Max.**
- Not played by a human.

## 0.1.0: 2026-11-10, first playable build

New project. It replaces the idea of reworking Frostline Freight with a separate bicycle game.

### Added
- **Bike physics** (`scripts/bike/bike.gd`):
  - pedalling cadence → speed, with coasting;
  - speed-dependent steering;
  - lean simulation: inverted pendulum + steering coupling + speed-dependent self-stability;
  - wobble and stall falls when slow, crash/fall/slide states;
  - foot-down starts.
- **Low-poly bike and rider** built from primitives: animated legs with IK on the pedals, steering bars and arms, spinning wheels (`bike_model.gd`).
- **Cameras:** 3rd-person chase and 1st-person helmet, with partial lean roll; switch with C / Y.
- **Road:** 2 lanes, white lines, guard rails with posts, shoulders, trees and rocks. Streamed in 60 m chunks.
- **Endless mode:** procedural straights and eased curves, with heading drift capped so the road never loops. Difficulty ramps (tighter curves, denser obstacles, paired potholes).
- **Course mode:** a 1.56 km hand-made track (`course_data.gd`) with 24 obstacles, a finish gate, a timer and a best time.
- **Obstacles:** cone rows, barriers, parked cars (crash) and potholes (lean kick + slow-down).
- **Crash → co-op get-up:** pedal ≥ 30 RPM *and* hold steering centred for 2 s. You respawn behind the crash in a clear lane.
- **OSC input from Max** (`OscReceiver` autoload): `/bike/steer`, `/bike/steer/present`, `/bike/cadence`, `/bike/pedal`, on UDP 9100. Its own OSC parser handles bundles.
- **Controller/keyboard fallback** (`RiderInput` autoload): left stick steers, tapping A pedals (tap rate → RPM). Auto / Controller-only / OSC-only modes (F2).
- **HUD:** speed, cadence, steering bar, lean gauge with fall zones and the turn's natural lean, input-source status, get-up ring, F1 debug overlay.
- **Menus:** main menu with live OSC status, balance assist (Easy/Normal/Hard), camera choice, best scores; pause menu; course results; Input check screen.
- **Max patch** `max/ThereminRider.maxpat` (generated by `tools/make_maxpat.py`): fixes and extends the original `bike theremin.maxpat` (see docs/MAX_SETUP.md).
- **Tools:**
  - `tools/osc_test_sender.py` (fake Max);
  - `scenes/test/smoke_test.tscn` (headless tests + balance bot + OSC probe);
  - `scenes/test/screenshots.tscn` (windowed screenshots).
- **Docs:** README, HANDOFF, MAX_SETUP, OSC_PROTOCOL, CONTROLS, TUNING, KNOWN_ISSUES, CLAUDE.md.

### Verified
- Headless import: clean.
- Smoke test on Normal: 17/17 checks pass. The bot rides 329 m in 45 s with 0 crashes, falls after it stops pedalling, gets back up with the co-op reset, and finishes the course in 3:13.9 with 0 crashes. Easy passes too; Hard does not (see KI-03).
- Python OSC sender → Godot: steer, presence and RPM all arrive; 3 strokes/s on `/bike/pedal` gives 90 RPM.
