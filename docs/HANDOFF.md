# Handoff: Theremin Rider

**Last updated:** 2026-11-10 · **Version:** 0.3.0 · **Engine:** Godot 4.7.2 (`D:\Godot_v4.7.2-stable_win64.exe`; use `_console.exe` for CLI runs) · **Repo:** `D:\drive\ThereminRider`, GitHub `sahandazimi02-cmyk/ThereminRider` (private)

## 1. What this is

A co-op bicycle game. Player 1 steers and **balances** with a theremin's pitch. Player 2 pedals a stationary bike, and their cadence is the bike's speed. Both go Max → OSC/UDP → Godot. There's a controller/keyboard version for playtesting. A 2-lane road with rails and obstacles; crash → both players cooperate to get back up. Modes: **Endless** and **Course**. Cameras: 1st and 3rd person.

## 2. State right now

| Area | State |
|---|---|
| Bike physics, crash/get-up loop, both modes, HUD, menus | Done; bot-tested headless (Easy and Normal pass; Hard fails the course, KI-03) |
| Feel (0.3.0) | Slower bike (90 RPM ≈ 24 km/h), road 25 % wider, gentler steering plus a fake steering assist (follows the road, straightens out), less sway, forgiving rails (2.5 s of scraping before a crash), long straight easy start and a slower difficulty ramp. Needs a theremin playtest. |
| Crash effects (thrown rider, spin, sparks, shake, slow motion, crash camera, knocked cones) | Done (0.2.0); checked in screenshots, not played by a human |
| Balance feel | 0.3.0: steadier than 0.1.0 (`lean_assist`, more damping). 0.2.1: back to the 0.1.0 balance (self-balancing at speed, balance by steering when slow) because 0.2.0 was far too hard (KI-19). Stop-pedalling still falls in ~4 s. Next: small tuning steps from here with the user. |
| Controller / keyboard play | Done. Not yet played by a human. |
| OSC receive in Godot | Done; tested with `tools/osc_test_sender.py` |
| Max patch (theremin → steer) | Generated and re-laid out into six columns (0.2.0), **not yet opened in Max** (KI-01) |
| Stationary bike sensor | Not built. The Max patch has a test slider and a pulse→RPM placeholder. |
| Audio, hills, art pass | Not started |

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
Autoloads:  GameSession (mode, assist, camera pref, best scores → user://theremin_rider.cfg)
            OscReceiver (UDP 9100 → latest steer / present / cadence / pedal strokes)
            RiderInput  (ONE place gameplay reads input: merges OSC + controller → steer, cadence_rpm)
```

| Folder | Contents |
|---|---|
| `scripts/autoload/` | The three autoloads above |
| `scripts/bike/` | `bike.gd` (physics), `bike_model.gd` (visual), `bike_camera.gd`, `bike_tuning.gd` |
| `scripts/input/` | `osc_parser.gd`, `stroke_cadence.gd` (taps → RPM), `input_tuning.gd` |
| `scripts/world/` | `road_path.gd` (centre line, `locate()` → s/lateral), `road_world.gd`, `obstacle.gd`, `course_data.gd`, `road_tuning.gd` |
| `scripts/game/game.gd` | Phases COUNTDOWN → PLAY → FALLEN → (get up) → PLAY / FINISHED. Collisions, scoring, HUD feed, crash effects + slow motion |
| `scripts/game/crash_fx.gd` | Particle bursts (sparks, dust, debris) and the `Tumbler` that knocks obstacle pieces flying |
| `scripts/ui/` | HUD, gauges, menus, input check, `ui_kit.gd` |
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
2. **First human playtest with the controller**, then with the theremin. 0.3.0 tuned for the theremin (slower, steering assist, forgiving rails); if it now feels too easy or "on rails", turn down `heading_assist` / `road_follow` / `rail_grace_s` first (TUNING.md knobs table). The user wants to tune balance from the 0.1.0 feel in small steps (KI-19); don't jump to 0.2.0-style "always unstable" again. Tune with TUNING.md's "Knobs to reach for first" table and log the results in CHANGELOG.
3. **Build the pedal sensor** (MAX_SETUP.md, "Adding the stationary bike later") and turn on SEND PEDAL DATA. Tune `speed_per_rpm` so a comfortable real cadence gives the speed you want (0.3.0 default: 90 RPM ≈ 24 km/h).
4. Decide Hard assist after playtesting (KI-03).
5. Nice-to-haves: audio (wind/chain/crash), hills, more course tracks (`course_data.gd` is plain data), a proper art pass (replace `BikeModel` with a GLB; keep the `update_pose` API).

## 6. Gotchas

- With Max's SEND PEDAL DATA on, the controller's pedal is ignored (Auto mode). Use F2 or turn the toggle off.
- `docs/` has a `.gdignore`, so Godot doesn't import the screenshots.
- Tests never write scores (`Game.record_scores = false`). Keep it that way.
- Default input actions are added at runtime only if missing; project Input Map entries override them.
- Crash slow motion sets `Engine.time_scale`. Tests turn it off with `Game.crash_slowmo = false`.
- The rider is its own node (`BikeModel.rider`). While thrown it's `top_level` and simulated in `BikeModel._physics_process`; `Bike.respawn()` puts it back.
