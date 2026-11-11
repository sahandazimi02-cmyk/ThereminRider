# Handoff: Theremin Rider

**Last updated:** 2026-11-11 · **Version:** 0.13.1 · **Engine:** Godot 4.7.2 (`D:\Godot_v4.7.2-stable_win64.exe`; use `_console.exe` for CLI runs) · **Repo:** `D:\drive\ThereminRider`, GitHub `sahandazimi02-cmyk/ThereminRider` (private)

## 1. What this is

A co-op bicycle game. Player 1 steers and **balances** with a theremin's pitch. Player 2 pedals a stationary bike, and their cadence is the bike's speed. Both go Max → OSC/UDP → Godot. There's a controller/keyboard version for playtesting. A 2-lane road with rails and obstacles; crash → back up automatically after 1.5 s (or at once by pedalling); R / Back restarts the ride. Modes: **Endless** and **Course**. Cameras: 1st and 3rd person.

## 2. State right now

| Area | State |
|---|---|
| Bike physics, crash/get-up loop, both modes, HUD, menus | Done; bot-tested headless (Easy and Normal pass; Hard fails the course, KI-03) |
| Feel (0.3.0/0.3.1) | Slower bike (90 RPM ≈ 24 km/h, top speed 45 km/h), road 25 % wider, gentler steering plus a fake steering assist (follows the road, straightens out), less sway, forgiving rails (2.5 s of scraping before a crash), long straight easy start and a slower difficulty ramp. Needs a theremin playtest. |
| Crash effects (thrown rider, spin, sparks, shake, slow motion, crash camera, knocked cones) | Done (0.2.0); checked in screenshots, not played by a human |
| Balance feel | 0.3.0: steadier than 0.1.0 (`lean_assist`, more damping). 0.2.1: back to the 0.1.0 balance (self-balancing at speed, balance by steering when slow) because 0.2.0 was far too hard (KI-19). Stop-pedalling still falls in ~4 s. Next: small tuning steps from here with the user. |
| First-person view (0.4.0) | True first person: your arms, gloved hands and the handlebar are in view and turn with the steering. Model + camera are edited in `scenes/bike/bike_model.tscn` (TUNING.md). Checked in a screenshot, not played. |
| Controller / keyboard play | Done. Not yet played by a human. |
| Minimal HUD + quick restart (0.6.0) | HUD shows only the profile name (+ a warning when its device is silent), km/h top-right, a speedometer dial bottom-left (`hud_speedometer.gd`), steering bar + lean dial bottom centre, and centre messages. Get-up is automatic (`auto_get_up_s` 1.5 s) or instant by pedalling; the old co-op hold (pedal + centred steering for 2 s) is gone. R / Back restarts the ride from the start with a 1 s countdown, also from the pause menu and the results. Checked in screenshots, not played. |
| Control profiles (0.5.0) | Three saved profiles replace Auto / Controller only / OSC only: **Controller / keyboard**, **Theremin + bike pedals**, **Theremin + controller / keyboard pedal**. Main menu button or F2. `GameSession.input_profile` stores it; `RiderInput` routes by it. Smoke-tested; menu not looked at on screen. |
| Hazard spacing + potholes (0.7.0) | Hazards in opposite lanes always leave `swap_gap_m` (18 m) of clear road, so no forced potholes; paired potholes now come after the obstacle. Potholes hit harder: more shake, a jolt, and 1 s of shakier balance. Smoke-tested, not played. |
| Moving hazards + car pack (0.8.0) | Endless now has **oncoming cars** (appear 120 m ahead, drive at you in their lane; their stretch of road is kept clear in both lanes) and **cows** crossing the road (`Assets/cow`, `walking` animation; start when you're 2.5–5.5 s away). All cars are car pack models (`Assets/10-lowpoly-cars`, `vehicle_pack.gd`); trucks/bus stretched to 9.5 m. Difficulty ramp 4400 → 3000 m, curve 1.3 → 1.15. Smoke-tested, screenshots looked at, not played. Course has no moving hazards (KI-36). |
| Faster ramp, more cars, score (0.9.0) | Difficulty maxes 1.8 km after the intro (`difficulty_ramp_m` 1800, linear), obstacles closer (80 → 30 m), car weights up (parked 2.5, oncoming 2.2), cows walk 1.9 m/s, guard rail has a 7 m opening where a cow crosses (visual only, KI-39). **Score** top-left: 1 point/m, −100 per crash, never below 0, not saved (KI-40). Smoke-tested, screenshots looked at, not played. |
| Road signs (0.10.0) | Your sign GLBs in `Assets/` (`road_signs.gd`). Ordinary signs every 160–380 m on the right (arrow signs only before right bends); warning signs 40 m before roadwork (cones/barriers), potholes and cows, one per run of the same hazard (90 m). Scenery only. Smoke-tested, two screenshots looked at, not played. |
| Hazard mix (0.10.1) | After the user's playtest (cars about right, other hazards rare, only 1 cow): parked 2.0, oncoming 1.7, cow 2.4, cones 3.2, barrier 2.2, pothole 1.9. Cars ~28 % of picks, cows ~18 %. Smoke test: 13 cows on the endless ramp (was 6), 58 hazards in 3.45 km (was 42). Not played yet. |
| More cars + fullscreen (0.11.0) | User: not enough cars, other hazards right. Cars per km about doubled (4.5 → 9.9: parked 6.0, oncoming 2.2), gaps 80/30 → 53/20 m, barrier 2.5 / cow 2.7 / pothole 1.5 so the others stay as often per km. **Display: Windowed / Fullscreen** on the main menu (saved, applied when the menu opens). It can't work inside the editor's embedded Game tab; the button says so (KI-44). Smoke-tested, menu looked at, not played. |
| Handlebar model (0.12.0) | The bike uses `Assets/steering.glb` as its handlebar (cruiser-style, grips at 1.20 m), turned, scaled, stem shortened and steerer hidden in code (`BikeModel._build_handlebar_model`, Inspector group "Handlebar model"). **Handlebar: Model / Classic** on the main menu switches back to the old generated bar (saved). Smoke-tested, screenshots looked at, not played. |
| OSC receive in Godot | Done; tested with `tools/osc_test_sender.py` |
| Max patch (theremin → steer) | **Now the user's own Max-saved patch** (0.4.2). Steering: pitch → `ftom` → `zmap 60. 80. -1. 1.`. Don't run `tools/make_maxpat.py` over it. |
| Stationary bike sensor | Arduino on COM7, 9600 baud, sends `p` per pedal turn (checked live). Max column 5 opens COM7 on load and feeds pulse in → RPM → `/bike/cadence` (0.4.2). Some extra/irregular pulses seen (KI-27). |
| Audio (0.13.0) | Cows moo (3D, from the cow) when they start crossing; nature ambience (`nature_ambience.ogg`, 0.13.1) loops quietly (−22 dB) through the whole ride (RoadTuning "Cow" / "Audio"). Smoke-tested, not listened to. No bike/wind/crash sounds yet. |
| Hills, art pass | Not started |

## 3. How to run

| What | Command / action |
|---|---|
| Play | Open the project in Godot and press F5, or `D:\Godot_v4.7.2-stable_win64.exe --path D:\drive\ThereminRider` |
| Fake Max | `python tools/osc_test_sender.py` (see `--help`) |
| Tests | `D:\Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 res://scenes/test/smoke_test.tscn` → exit 0 = pass |
| Screenshots | `D:\Godot_v4.7.2-stable_win64_console.exe --path . --fixed-fps 60 --resolution 1600x900 res://scenes/test/screenshots.tscn` → `docs/screenshots/` |
| OSC probe | `RIDER_OSC_PROBE=1` + the test command above, while Max or the sender is running |
| Import check | `D:\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` |

## 4. Architecture

```
scenes/main_menu.tscn ─► scenes/game.tscn (Game) ─► builds everything in code:
                                  ├─ WorldEnvironment + sun + ground plane (follows the bike)
                                  ├─ RoadWorld   road path, chunk meshes, obstacles, endless generator
                                  ├─ Bike        physics state + BikeModel (visual)
                                  ├─ BikeCamera  chase / first person
                                  ├─ Hud (+ HudGauges)
                                  └─ PauseMenu   (also the course results)
Autoloads:  GameSession (mode, assist, camera pref, control profile, best scores → user://theremin_rider.cfg)
            OscReceiver (UDP 9100 → latest steer / present / cadence / pedal strokes)
            RiderInput  (ONE place gameplay reads input: merges OSC + controller → steer, cadence_rpm)
```

| Folder | Contents |
|---|---|
| `scripts/autoload/` | The three autoloads above |
| `scripts/bike/` | `bike.gd` (physics), `bike_model.gd` (visual), `bike_camera.gd`, `bike_tuning.gd` |
| `scripts/input/` | `osc_parser.gd`, `stroke_cadence.gd` (taps → RPM), `input_tuning.gd` |
| `scripts/world/` | `road_path.gd` (centre line, `locate()` → s/lateral), `road_world.gd` (also moves oncoming cars / cows: `update_movers`), `obstacle.gd`, `vehicle_pack.gd` (car pack FBX → 10 vehicles), `road_signs.gd` (sign GLBs → roadside + warning signs), `course_data.gd`, `road_tuning.gd` |
| `Assets/` | Third-party models: `10-lowpoly-cars` (car pack FBX + palette texture), `cow` (Cow.glb with animations). Sounds: `audio/moo.wav`, `audio/nature_ambience.ogg` (Freesound, see `audio/credits.txt`). Your own: `steering.glb` (handlebar, 0.12.0), `Roaad signs used random.glb` / `Roaad signs hazards.glb` (road signs; `road signs.blend` is their source) |
| `scripts/game/game.gd` | Phases COUNTDOWN → PLAY → FALLEN → (get up) → PLAY / FINISHED. Collisions, scoring, HUD feed, crash effects + slow motion |
| `scripts/game/crash_fx.gd` | Particle bursts (sparks, dust, debris) and the `Tumbler` that knocks obstacle pieces flying |
| `scripts/ui/` | HUD, gauges (steering bar, lean dial, get-up ring), speedometer, menus, input check, `ui_kit.gd` |
| `scripts/core/` | `palette.gd` (all colours), `mesh_kit.gd` (primitive builders) |
| `data/*.tres` | Tuning resources (all gameplay numbers) |
| `max/` | Max patch |
| `tools/` | Smoke test, screenshots, OSC sender, Max patch generator |

Key design decisions:
- **Custom bike simulation instead of RigidBody/VehicleBody.** Balance-by-steering needs a controllable lean model, and a predictable one makes theremin tuning possible. Details in TUNING.md.
- **Road-space collisions.** Everything is computed in (s, lateral) from `RoadPath.locate()`, so there are no physics colliders at all.
- **Game drives the bike explicitly** (`bike.step()` from `Game._physics_process`), so the order is deterministic and tests can step the real scene.
- **Input abstraction.** Gameplay never reads OSC or `Input` directly; it reads `RiderInput.steer` and `RiderInput.cadence_rpm`. Tests drive it via `RiderInput.override_*`.

## 5. Next steps (suggested order)

1. **Open `max/ThereminRider.maxpat` in Max 9**, fix anything that doesn't load (KI-01), calibrate, and confirm with Input check.
2. **First human playtest with the controller** (profile 1), then theremin + controller pedal (profile 3, no bike needed), then theremin + bike (profile 2). 0.3.0 tuned for the theremin (slower, steering assist, forgiving rails); if it now feels too easy or "on rails", turn down `heading_assist` / `road_follow` / `rail_grace_s` first (TUNING.md knobs table). The user wants to tune balance from the 0.1.0 feel in small steps (KI-19); don't jump to 0.2.0-style "always unstable" again. Tune with TUNING.md's "Knobs to reach for first" table and log the results in CHANGELOG.
3. **Pedal test in Max:** open the patch, check the column 5 light flashes once per turn, turn on SEND PEDAL DATA, watch Latest RPM while pedalling steadily. If it jumps around, look at KI-27 (debounce on the Arduino, or ignore pulses < 300 ms in Max). Tune `speed_per_rpm` so a comfortable real cadence gives the speed you want (0.3.0 default: 90 RPM ≈ 24 km/h).
4. Playtest 0.9.0: is the faster ramp (`difficulty_ramp_m` 1800) too much with the theremin? Is the crash penalty (`crash_penalty` 100) about right against 1 point per metre? Should the score become the saved endless record (KI-40)? Then the 0.8.0 moving hazards: is 120 m of warning enough for an oncoming car at your real speed (`oncoming_trigger_m`), can you get past a cow (`cow_speed_mps`, `cow_lead_*_s`), are trucks too long (`truck_length_m`)? Does difficulty now climb fast enough (`difficulty_ramp_m` 3000)? Consider adding a cow / oncoming car to the course (KI-36). 0.10.0 signs: are the warning signs early enough and readable (`hazard_sign_lead_m`, `hazard_sign_height_m`), and are ordinary signs about as often as you want (`sign_spacing_*_m`)? 0.10.1/0.11.0 hazard mix: enough cars now (`weight_car` 6.0, `weight_oncoming` 2.2)? If the road feels too busy, lengthen `obstacle_gap_*_m` before lowering weights. Does fullscreen work on the playtest PC?
5. Decide Hard assist after playtesting (KI-03). While playtesting, check the pothole feel (`pothole_*`, `shake_pothole`) and whether 18 m (`swap_gap_m`) is enough room to swap lanes at your real speed (KI-32).
6. Nice-to-haves: more audio (wind/chain/crash; 0.13.0 has the moo + ambience — check their volumes in a playtest: `cow_moo_*`, `ambience_volume_db`), hills, more course tracks (`course_data.gd` is plain data), a proper art pass (replace the generated meshes in `scenes/bike/bike_model.tscn` with a GLB; keep the `update_pose` / `first_person_transform` API and the `FirstPersonCamera` node).
7. First-person feel: the user may want to adjust the camera/model in `bike_model.tscn`. 0.12.0 handlebar model: are the grips at a good height in first person (they're 0.15 m higher than the classic bar)? Should the model's dashboard show (KI-45)? Tune with the "Handlebar model" fields (TUNING.md). If the view feels too wobbly or too stiff, try `fp_roll_factor` (1 = locked to the head).

## 6. Gotchas

- The control profile decides the devices (0.5.0); there's no automatic fallback. If steering or pedalling reads NO SIGNAL, check the profile on the main menu (or F2) before debugging Max.
- `docs/` has a `.gdignore`, so Godot doesn't import the screenshots.
- Tests never write scores (`Game.record_scores = false`). Keep it that way.
- Default input actions are added at runtime only if missing; project Input Map entries override them.
- Crash slow motion sets `Engine.time_scale`. Tests turn it off with `Game.crash_slowmo = false`.
- `Bike` instances `scenes/bike/bike_model.tscn` (`Bike.MODEL_SCENE`). Its meshes are generated by the `@tool` script, so they aren't in the Scene dock or the `.tscn`; the `FirstPersonCamera` node is only a marker in game (`BikeCamera` copies it). `Bike` sets the model's `position.y` every frame (crash hop), so move the model with its Inspector fields, not the root transform.
- The rider is its own node (`BikeModel.rider`). While thrown it's `top_level` and simulated in `BikeModel._physics_process`; `Bike.respawn()` puts it back.
