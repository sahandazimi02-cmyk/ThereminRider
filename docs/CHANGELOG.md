# Changelog

Format: newest first. Dates are YYYY-MM-DD.

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
