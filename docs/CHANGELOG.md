# Changelog

Format: newest first. Dates are YYYY-MM-DD.

## 0.10.0: 2026-11-11, game speed → Max video playback rate

### Added
- `OscSender` autoload sends `/bike/speed` (km/h, 30 /s) to UDP 127.0.0.1:9101. New `InputTuning` group *OSC output*.
- Max patch: new column 5 *VIDEO SPEED* (udpreceive 9101 → rate → `jit.movie`).

### Removed
- Max patch: Arduino (column 5) and Pedals (column 6) sections.

### Verified
- Headless import exit 0. Smoke test: same 2 failures as 0.9.0 and nothing new. Captured the UDP output with `nc`: valid OSC `/bike/speed ,f`. Max patch is valid JSON but not opened in Max.
## 0.13.1: 2026-11-11, ambience as OGG (63 MB → 3.6 MB)

### Changed
- The nature ambience is now `Assets/audio/nature_ambience.ogg` (Ogg Vorbis, quality 5, ~132 kb/s, same 3:40 length, 48 kHz stereo), encoded from the 63 MB 24-bit WAV with ffmpeg. The WAV was removed from the project; it's still in git history (commit 38b0575) if you ever need it.
- It now loops through Godot's OGG import (`loop=true` in its `.import`), which is gapless. The `finished` → `play()` restart in `Game._build_ambience()` stays as a fallback. KI-47 fixed.

### Verified
- Headless import exit 0, no errors. Smoke test: exit 1 with only the same 2 speed failures as 0.13.0; "nature ambience is loaded and playing" passes in all 5 game scenes the test opens. Not listened to.

## 0.13.0: 2026-11-11, cow moo and nature ambience

### Added
- **Cows moo.** Each cow moos once, from where it stands (3D sound), when it starts crossing the road, so you hear it 2.5–5.5 s before you reach it. The pitch is picked at random per moo (±12 %) so cows don't all sound the same. Sound: your `Assets/audio/moo.wav`. Built in `Obstacle._build_cow()` (an `AudioStreamPlayer3D` named `Moo` on the cow node), played from `RoadWorld.update_movers()` (`Obstacle.moo()`); the pitch uses its own RNG so it never changes the generated road.
- **Nature ambience.** `Assets/audio/490779__pietergrobler__nature-ambience.wav` loops quietly (−22 dB) for the whole game scene, fading in over 2 s. It keeps going through crashes, restarts and the pause menu, and stops when you go back to the main menu (`Game._build_ambience()`).
- New `RoadTuning` fields: `cow_moo_volume_db`, `cow_moo_pitch_jitter`, `cow_moo_unit_m`, `cow_moo_max_m` (Cow group) and `ambience_volume_db`, `ambience_fade_in_s` (new Audio group). See TUNING.md.
- `Assets/audio/credits.txt` lists where the two sounds come from.

### Fixed
- `moo.wav` didn't import: Godot printed `Format not supported for WAVE file (not PCM)`. The file was saved with a WAVE_FORMAT_EXTENSIBLE header, which Godot 4.7 rejects. Re-saved as plain 16-bit PCM (same audio, 48 kHz stereo, 3.08 s). The leftover `.import` file of the original download (`163727__felixblume__cow-mooing-…wav.import`, whose WAV is gone) was removed.

### Verified
- Headless import exit 0, no errors (after the moo re-save).
- Smoke test: exit 1 with only the same 2 failures as before (`full steer at cruise`, `stays under 29 km/h`). They fail with the committed `bike_tuning.tres` too, so they're not from your local speed edits or from this change. New checks pass: cow has a moo sound, cow moos when it starts crossing, ambience loaded and playing in every game scene the test opens.
- Not heard: the test runs headless (no audio output), so the volume balance, how far away the moo is audible, and the ambience loop point haven't been listened to.

## 0.12.0: 2026-11-11, handlebar model (steering.glb) with a Classic switch

### Added
- **Handlebar model.** The bike now uses your `Assets/steering.glb` handlebar instead of the generated bar. It turns with the steering and the rider's hands hold its grips (found automatically from the top of the model, so the hands follow wherever the grips end up). Built in `BikeModel._build_handlebar_model()`; the fork, head tube and front wheel are still generated.
  - The GLB doesn't fit the bike as-is: its stem is very tall (grips to dashboard ~1.1× the grip spacing) and a long steerer tube hangs below the dashboard. So the build turns it to face forward (`model_yaw_deg` 87.6), scales it to a 0.44 m grip width, shortens the vertical stem to 5 % (`model_stem_keep`), mounts the stem base 0.18 m below the head-tube top, and hides every triangle below 0.70 m (`model_cut_below`) so the steerer doesn't go through the front tyre. Result: a cruiser-style bar with the grips at 1.20 m (classic: 1.05 m).
  - Its material is shiny chrome over a light-grey colour map, which mirrored the sky and grass in-game (the bar looked blue-green, then silver once the shine was turned down). It's now darkened (`model_tint` 0.22 grey) with half the metallic shine (`model_shine` 0.5), so it reads black like the model.
  - All of these are Inspector fields on `BikeModel` (new "Handlebar model" group in `scenes/bike/bike_model.tscn`), and the model rebuilds live in the editor.
- **Main menu: Handlebar: Model / Classic.** Switches between the GLB and the old generated bar. Saved with the other settings (`GameSession.handlebar_model`, default Model); `Bike` passes it to the model when the ride starts.
- Smoke test `_test_handlebar`: both options build, both grips are within arm's reach and between head-tube and shoulder height, and the GLB has nothing drawn below the cut. Screenshots: new `first_person_classic.png`.

### Verified
- Headless import exit 0, no script errors.
- Smoke test: exit 1 with only the same 2 failures as before (`full steer at cruise`, `stays under 29 km/h`, from the `bike_tuning.tres` speed). The new handlebar checks pass (model grips 0.45 m from the shoulder, 1.20 m high; lowest drawn point 0.64 m).
- Looked at: `first_person.png`, `first_person_classic.png`, `third_person.png`, `hazards.png`, `crashed_get_up.png`, `main_menu.png`, plus side, 3/4 and steered first-person renders of the bike alone. Didn't look at the other screenshots.
- Not played by a human.

## 0.11.0: 2026-11-11, about twice as many cars, fullscreen option

### Changed
- **More cars, same amount of everything else** (`RoadTuning`). Playtest note: not enough cars, the other hazards are about right.
  - Cars: `weight_car` 2.0 → 6.0, `weight_oncoming` 1.7 → 2.2. Most of the extra cars are parked ones: each oncoming car keeps 120 m of road free, so many more of them would crowd out everything else.
  - Shorter gaps to make room: `obstacle_gap_easy_m` 80 → 53, `obstacle_gap_hard_m` 30 → 20. Hazards still keep `swap_gap_m` (18 m) of clear road for a lane change.
  - The weights are shares of each pick, so the others moved a little to keep their count per km where it was: `weight_barrier` 2.2 → 2.5, `weight_cow` 2.4 → 2.7, `weight_pothole` 1.9 → 1.5 (more non-pothole hazards bring more paired potholes).
  - Measured over 24 endless seeds, start to the end of the ramp + 2 km, per km (0.10.1 → 0.11.0): parked cars 2.4 → 7.4, oncoming 2.1 → 2.5 (cars 4.5 → 9.9), cones 3.7 → 3.9, barriers 2.8 → 2.8, potholes 4.7 → 4.7, cows 2.9 → 3.0.

### Added
- **Display: Windowed / Fullscreen** button on the main menu (`GameSession.fullscreen`, saved with the other settings). Fullscreen is borderless fullscreen. The saved choice is applied when the main menu opens (`GameSession.apply_window_mode()`), not at startup, so the test and screenshot scenes keep their window.

### Verified
- Headless import exit 0, no script errors.
- Smoke test: exit 1 with only the same 2 failures as before (`full steer at cruise`, `stays under 29 km/h`, from the `bike_tuning.tres` speed). Spacing checks pass (tightest lane swap 18.0 m). Endless: 14 oncoming cars, 6 cows. Course bot: 2 crashes.
- Main menu run windowed and looked at in a screenshot: the new button fits. Switching in code went to fullscreen (1920×1080) and back to the 1600×900 window, without saving.
- Not played by a human. Didn't look at in-game screenshots of the extra cars.

### Fixed (same day)
- User: "the Fullscreen button doesn't work". Run from the editor, Godot embeds the game in its **Game** tab, and an embedded game can't change its window mode, so the button only changed its label. The button now reads **Display: Fullscreen (not in the editor's Game tab)** in that case (`Engine.is_embedded_in_editor()`). Outside the editor (or with embedding turned off) it works: a standalone run went 1600×900 → 1920×1080 fullscreen → 1600×900. Headless import exit 0; smoke test same 2 speed failures as above. The embedded case wasn't run here.

## 0.10.1: 2026-11-11, fewer cars, more cows and other hazards

### Changed
- **Hazard mix rebalanced** (`RoadTuning` weights; `data/road_tuning.tres` doesn't override them). Playtest note: the number of cars was about right, but other hazards were rare, and only 1 cow showed up in a whole run.
  - Cars down a little: `weight_car` 2.5 → 2.0, `weight_oncoming` 2.2 → 1.7. Cars are now about 28 % of hazard picks (was ~38 %). Each oncoming car also keeps 120 m of road free, so fewer of them leaves more room for other hazards.
  - Cows up: `weight_cow` 1.0 → 2.4, about 18 % of picks (was ~8 %).
  - Others up a little: `weight_cones` 3.0 → 3.2, `weight_barrier` 2.0 → 2.2, `weight_pothole` 1.5 → 1.9.

### Verified
- Headless import exit 0, no script errors.
- Smoke test: exit 1 with only the same 2 failures as before (`full steer at cruise`, `stays under 29 km/h`, from the `bike_tuning.tres` speed). Endless to the end of the ramp: 13 cows (was 6) and 11 oncoming cars (was 11). 58 hazards in 3.45 km (was 42), because fewer oncoming cars block the road. Course bot: 2 crashes (truck, car). The course is hand-placed, so it hasn't changed.
- Not played by a human. Didn't look at screenshots (nothing visual changed).

## 0.10.0: 2026-11-11, roadside signs and hazard warning signs

### Added
- **Roadside signs** from your two exports in `Assets/` (new `scripts/world/road_signs.gd`). Each GLB has its signs as loose meshes; `RoadSigns` rebuilds each one at its post foot, facing the rider, scaled to a set height.
  - **Ordinary signs** (`Roaad signs used random.glb`: two-way traffic, speed limit 55, chevron, detour, route 66, no bicycles, big arrow, one way, green motorway sign) on the right of the road, one every 160–380 m (`sign_spacing_min_m` / `_max_m`), so only now and then. The random file's ROAD WORK AHEAD and digging-worker signs are the same as two of the warnings, so they're never used at random (a warning sign always means a hazard). Signs with a right arrow (chevron, big arrow, detour, one way) only stand before a right bend, so no sign points the wrong way. Left bends get no arrow: a mirrored copy rendered dark.
  - **Warning signs** (`Roaad signs hazards.glb`): `roadwork` before cones and barriers, `pothole` before potholes, `cow` before cow crossings, 40 m before the hazard (`hazard_sign_lead_m`). One sign covers a run of the same hazard: no second sign of the same kind within 90 m (`hazard_sign_repeat_m`). Parked and oncoming cars get no sign. Ordinary signs keep 30 m away from warning signs (`sign_hazard_clear_m`); a warning that would stand right next to another sign goes on the left side. Warning signs are bigger than ordinary ones (4.8 m vs 3.6 m tall) so you can read them in time. Endless and course.
  - All signs stand outside the guard rail (`sign_rail_clearance_m`); they're scenery only, no collisions. They use a separate random generator, so the road and hazards for a given seed are unchanged.
- New `RoadTuning` group **Road signs** (TUNING.md).
- Smoke test `[road signs]` (endless to 3.4 km and the course): ordinary signs appear but only now and then, at least `sign_spacing_min_m` apart; every roadwork/pothole/cow hazard has its warning sign before it; ordinary signs keep clear of warnings; no sign reaches inside the rail; warning signs never appear as ordinary signs; arrow signs only before right bends; the models load.
- Screenshots `sign_warning`, `sign_warning_first_person`, `sign_ordinary`, `sign_ordinary_first_person`.

### Verified
- Headless import exit 0, no script errors. It prints `Blender path is invalid` because of your `Assets/road signs.blend` (Godot tries to import .blend files; see KI-41).
- Smoke test: exit 1 with only the same 2 failures as at 0.9.0 HEAD (`full steer at cruise`, `stays under 29 km/h`, from the `bike_tuning.tres` speed). All 16 new sign checks pass: endless 15 ordinary signs in 3.4 km (closest 167 m apart), 30 warning signs for 42 hazards; course 6 ordinary, 12 warnings for 18 hazards.
- Looked at a render of every sign (front and back) to work out which way they face and which node is which, and at `sign_warning*` (ROAD WORK AHEAD ~24 m ahead, readable) and `sign_ordinary*`. Didn't look at the other screenshots. Haven't seen a pothole or cow warning sign in game, only in the render.
- Not played by a human.

## 0.9.0: 2026-11-11, faster difficulty, more cars, faster cows, rail gaps, score

### Added
- **Score counter, top-left** (`SCORE 1234`). You get `road.score_per_m` (1) point per metre of new road; each crash costs `road.crash_penalty` (100) points, with a red "-100" dropping in under the score. The score never goes below 0, and riding back over road after a respawn doesn't score twice. Restart resets it. The Course finish message shows it too. Not saved anywhere (best streak / course time are still what's recorded). The profile name and device warning moved down under the score.
- **Openings in the guard rail where cows cross** (`road.cow_rail_gap_m`, 7 m, both sides, with a post at each end). The cow walks through the gap instead of through the fence (was KI-35).
- New `RoadTuning` group **Score** (`score_per_m`, `crash_penalty`) and `cow_rail_gap_m` (TUNING.md).
- Smoke test: riding scores points and the HUD shows them; a crash costs `crash_penalty`; restart resets the score; the rail has an opening at a cow crossing.

### Changed
- **Difficulty ramps up faster** (`data/road_tuning.tres`): `difficulty_ramp_m` 3000 → 1800 m and `difficulty_curve` 1.15 → 1.0 (linear), so max difficulty comes 1.8 km after the intro instead of 3 km, and it climbs from the first metre. Obstacles are also closer together: `obstacle_gap_easy_m` 100 → 80, `obstacle_gap_hard_m` 35 → 30.
- **More cars, from the start**: `weight_car` (parked cars/trucks) 1.5 → 2.5 and `weight_oncoming` 1.4 → 2.2. Both are in the pool right after the intro (`oncoming_from` 0), so cars are now about 45 % of hazards (was ~30 %).
- **Cows walk faster**: `cow_speed_mps` 1.3 → 1.9 m/s, walk animation `cow_anim_speed` 1.0 → 1.45 to match.

- Screenshot scene rebuilds the road chunks after placing its hand-made cow (`RoadWorld.rebuild_chunks()`), so the rail opening shows in `hazards*.png`.

### Verified
- Headless import exit 0, no script errors. Smoke test: exit 1 with only the same 2 failures as in 0.8.0, caused by your local `bike_tuning.tres` speed edits (`full steer at cruise`, `stays under 29 km/h`; 51.8 km/h at 90 RPM). All new checks pass (score shown, crash costs points, restart resets it, rail opening at a cow). Endless spacing at max difficulty: 11 oncoming cars and 6 cows by the end of the ramp; endless bot 0 crashes in 45 s; course bot 2 crashes (truck, car; limit 6).
- Screenshots (windowed): looked at `hazards`, `hazards_first_person` (rail opening on both sides at the cow, end posts, score top-left), `crashed_get_up` and `crash_impact` (red "-100" under the score). Didn't look at the other shots.
- Not played by a human. Haven't checked how the faster ramp feels with the theremin.

## 0.8.0: 2026-11-11, oncoming cars, crossing cows, car pack models, faster difficulty

### Added
- **Oncoming cars** (new hazard `ONCOMING`, endless). The car pops up `road.oncoming_trigger_m` (120 m) ahead of the bike and drives straight at you down its lane at 7 → 12 m/s (`oncoming_speed_easy_mps` → `_hard_mps`, scales with difficulty). Get out of its lane. Its whole drive is reserved in the hazard spacing (`Obstacle.zone_*`): nothing else in its lane over those 120 m, and nothing in the other lane either (plus `swap_gap_m` on both ends), so there is always somewhere to go. If you crash, oncoming cars still ahead of you brake to a stop, so nothing runs into the rider after the get-up. Parked or oncoming, the crash message says *car* or *truck*.
- **Cows crossing the road** (new hazard `COW`, endless), using `Assets/cow/source/Cow.glb` and its `walking` animation (looped; `iddle` while waiting). The cow stands in the field beside the road (`cow_side_m` outside the rail) and starts walking across when you're 2.5–5.5 s away at your current speed (`cow_lead_min_s` / `_max_s`, random per cow), at 1.3 m/s (`cow_speed_mps`). Each cow is somewhere different on the road when you reach it: read which way it's going and pass behind it. It stops on the far side. Hit box = the cow (`cow_length_m` 2.4 m, across the road). Spacing treats a cow as blocking both lanes.
- New `RoadTuning` groups **Vehicles (car pack)**, **Oncoming cars** and **Cow** (TUNING.md). `weight_oncoming` 1.4 and `weight_cow` 1.0 next to the old weights; `oncoming_from` / `cow_from` (difficulty, default 0 = right after the intro).
- Smoke test `[moving hazards]`: car pack splits into 10 vehicles, trucks stretched to `truck_length_m`; an oncoming car waits until the bike is within 120 m, is hidden until then, then drives at the bike; a cow waits outside the rail, starts walking at `lead_s`, plays `walking`, crosses and stops on the far side; restart puts both back; in a real ride an oncoming car right ahead crashes you ("hit the oncoming car") and then stays stopped. `[hazard spacing]` now counts moving hazards (9 oncoming cars and 9 cows by 5.2 km) and uses the reserved stretches. The test bot looks further ahead for oncoming cars and predicts where a cow will be.
- Screenshots `hazards`, `hazards_first_person` and `vehicles_first_person`.

### Changed
- **All car models now come from the car pack** (`Assets/10-lowpoly-cars/source/cars.fbx`, new `scripts/world/vehicle_pack.gd`). The FBX has the 10 vehicles as loose meshes side by side; `VehiclePack` groups touching meshes into vehicles once, centres them, turns them to face down the road and scales them to `vehicle_width_m` (2.0 m). **Trucks and the bus are stretched to `truck_length_m` (9.5 m)**; their wheels are moved, not squashed. Cars come out 3.8–4.3 m long. 30 % of car hazards are trucks/buses (`truck_chance`). The hit box follows the model (`vehicle_hit_width` 0.85 of the width, because of the mirrors), so trucks are much longer to get past. Parked cars face either way; oncoming ones face you. Course cars use the pack too (same positions). The old box car stays as a fallback if the FBX is missing.
- **Difficulty ramps up faster** (`data/road_tuning.tres`): `difficulty_ramp_m` 4400 → 3000 m and `difficulty_curve` 1.3 → 1.15, so it climbs sooner and more evenly. Max difficulty now comes 3 km after the intro instead of 4.4 km.
- `RoadWorld.check_hit` looks as far along the road as the hazard is long (trucks), not a fixed 6 m.

### Verified
- Headless import exit 0, no script errors. Smoke test with the committed `bike_tuning.tres`: exit 0, all checks pass (endless bot 0 crashes, course 0 crashes). With your local `bike_tuning.tres` edits (`speed_per_rpm` 0.16, 51.8 km/h at 90 RPM): the only 2 failures are the speed checks that already fail with those edits (`stays under 29 km/h`, `full steer at cruise`); the course bot hits a truck and a car once each (2 crashes, limit 6).
- Screenshots (windowed): looked at `hazards`, `hazards_first_person` and `vehicles_first_person`. The cow is textured, animated and walks head first; the oncoming car faces the bike; the pack's palette texture loads. Didn't look closely at every vehicle model, a truck side-on, or the cow clipping through the guard rail.
- Not played by a human.

## 0.7.0: 2026-11-11, no more forced potholes, harsher potholes

### Fixed
- **Potholes no longer sit right next to an obstacle in the other lane.** At higher difficulty the endless generator put a pothole in the other lane within ±4 m of an obstacle, which blocked both lanes and forced you over the pothole. Now every hazard is placed with a spacing rule (`RoadWorld._place_spaced`): two hazards in **opposite lanes** always have at least `road.swap_gap_m` (18 m) of clear road between them (back of one to front of the next), so you can pass one and swap lanes straight away. Two hazards in the same lane need `road.same_lane_gap_m` (3 m), so they never overlap. A hazard that would be too close is pushed further down the road. The paired pothole is still there at high difficulty, but now it comes `swap_gap_m` + 0–6 m (`paired_pothole_spread_m`) *after* the obstacle: pass the obstacle, then swap back. Its odds moved from hard-coded numbers to `paired_pothole_from` (0.4) / `paired_pothole_chance` (0.35).
- Course: the pothole at 990 m sat 10 m after the barrier at 980 m in the other lane; moved to 1010 m.

### Changed
- **Potholes are more punishing (still not a crash).** On top of the sideways kick (`pothole_kick` 0.9 → 1.1) and speed loss: camera shake 0.35 → 0.6 (`shake_pothole`, now a tunable), a small jolt up (`pothole_hop`), and for 1 s (`pothole_shaky_s`) the bike is shakier: half its self-balancing gone at first (`pothole_stability_loss` 0.5), a fast lean jitter (`pothole_jitter`) and a handlebar twitch (`pothole_bar_twitch_deg`, visual only). All fade out over that second. New "Potholes" group in `bike_tuning`.

### Added
- Smoke test `[hazard spacing]`: rides the endless generator to max difficulty (6.4 km) and checks every pair of hazards; checks the course too. `[pothole]`: k drops right after a hit, the bike stays up with no steering at cruise, the lean is noticeable, and the shakiness wears off.

### Verified
- Headless import exit 0, no script errors. Smoke test with the committed tuning: exit 0, all checks pass (tightest opposite-lane gap in endless 18.0 m, course 27.1 m, 39 close obstacle → pothole swaps still generated; pothole: k 10 → 5, peak lean 10.7°). With the local `bike_tuning.tres` edits (60 km/h) the only failures are the same two speed checks as in 0.6.0.
- Not played by a human; no screenshots taken. The 18 m gap is a distance, so how much time it gives depends on speed (≈ 2.2 s at 30 km/h, ≈ 1.1 s at 60 km/h).

## 0.6.0: 2026-11-11, minimal HUD, speedometer, quick get-up and restart

### Changed
- **HUD stripped down.** While riding you only see: the control profile name (top-left; a yellow warning line appears under it only when the profile's device is silent, e.g. *no theremin signal*), km/h (top-right), the steering bar + lean dial (bottom centre, unchanged), and centre messages. Removed: distance / streak / crashes, pedal RPM, the Steer/Pedal/Assist/Camera block and the key-hint text. F1 debug readout still there.
- **Getting up after a crash is automatic.** Back up 1.5 s after the bike lies down (`road.auto_get_up_s`), or immediately once anyone pedals ≥ 10 RPM after 0.4 s (`reset_min_cadence_rpm`, `min_down_s`). The ring now shows the auto get-up timer. The co-op hold (pedal + centred steering for 2 s) and its tunables `reset_hold_s`, `reset_center_tolerance`, `reset_decay_rate` are removed; the steering hand is no longer needed to get up.
- **R / Back restarts the ride** (was a debug "reset in place"; action renamed `debug_reset` → `restart_run`). Works while riding, while down, in the pause menu and on the Course results. Restarts use `road.restart_countdown_s` (1 s); the first ride keeps `countdown_s` (3 s). The pause menu's Restart / Ride again use the same path (`Game.restart()`, which saves scores and closes the menu).

### Added
- **Speedometer dial** bottom-left (`scripts/ui/hud_speedometer.gd`): 240° dial, range = `max_speed_kmh` rounded up to 10, ticks every 5 km/h, numbers every 10, needle, number + km/h.
- Smoke test: auto get-up with no input; restart returns to the start line with distance/crashes reset; restart countdown is real and shorter than the first one.

### Fixed
- `tools/screenshots.gd`: the "crash" shots never showed a crash (the forgiving rails just scrape for the whole 10 s window). It now forces the hit if the rail didn't, and turns auto get-up off for the two crash shots.

### Verified
- Headless import exit 0, no errors. Smoke test: all new checks pass (auto get-up 1.9 s after the crash incl. the fall; restart countdown 1.0 s vs 3.0 s). Exit 1 only for the same two speed checks as before (local `bike_tuning.tres` edits, 60 km/h).
- Looked at `third_person.png`, `first_person.png`, `crash_impact.png`, `crash_landed.png`: profile text top-left, km/h top-right, speedometer bottom-left, steering bar/lean dial bottom centre, nothing else. Not played by a human; R / Back not pressed on a real keyboard/pad.

## 0.5.0: 2026-11-11, control profiles

### Added
- **Three control profiles**, picked with the new **Controls: ...** main-menu button or **F2** (anywhere), saved in `user://theremin_rider.cfg` (`settings/input_profile`):
  1. **Controller / keyboard**: stick or A/D steers, A button / Space taps pedal. Default.
  2. **Theremin + bike pedals**: both from Max over OSC.
  3. **Theremin + controller / keyboard pedal**: theremin steers, A / Space taps pedal (Max's pedal data ignored).
- Main menu shows a one-line "who does what" hint under the buttons; Input check shows the profile and the hint; the in-game HUD says `Controls: <profile> (F2)`.
- Smoke test `[control profiles]`: sets each profile directly (no save) and checks the steer/pedal sources.

### Changed
- The old Auto / Controller only / OSC only input modes are gone (`RiderInput.Mode`, `mode`, `mode_name()` removed; use `GameSession.input_profile`, `RiderInput.profile_name()`, `steer_uses_theremin()`, `pedal_uses_bike()`). F2 (`cycle_input_mode`) now cycles profiles. No automatic fallback: an OSC channel that isn't live reads NONE. This fixes KI-14.
- CONTROLS.md (new profile table), OSC_PROTOCOL.md, HANDOFF.md updated.

### Verified
- Headless import: exit 0, no errors.
- Smoke test: the 3 new profile checks pass. Exit 1 because of the same two speed checks that already failed in 0.4.0–0.4.2 (`stays under 29 km/h`, `max_speed_kmh is reachable` at 60 km/h), from the uncommitted local `bike_tuning.tres` edits; this change doesn't touch the bike.
- Not checked: the main menu / HUD on screen, a real controller, Max.

## 0.4.2: 2026-11-10, user's Max patch saved; Arduino wired into the pedals

### Saved
- **The user's Max work is committed as-is** (commit 54e2307): theremin steering through `ftom 0.` → `zmap 60. 80. -1. 1.` with multislider meters, PEDALS and TO GODOT moved one column right, and the pasted Arduino column. A byte-identical copy was also kept outside the repo before editing. **No theremin or pitch object was changed** (diffed box by box against the saved file).

### Fixed
- The pasted Arduino column wasn't connected to anything: the PEDALS column had no `[r tr.pulse]`, so `p` pulses never reached the RPM logic. Added `[r tr.pulse]` → **pulse in** (PEDALS column), so the path is `serial → sel 112 → s tr.pulse → r tr.pulse → pulse in → t b b → timer → split → expr → clip → f → prepend /bike/cadence → udpsend`.
- Column 5 now opens **COM7** when the patch opens (`loadbang` → `port COM7`), so the Arduino works without picking a port.
- Two Arduino-column boxes that had been dragged out of place were moved back: the READ toggle (next to its `loadbang`) and the `p` light (between `sel 112` and `s tr.pulse`).
- Text only: column titles renumbered (6 PEDALS, 7 TO GODOT), quick-start line, PEDALS notes.

### Changed
- The patch is written in Max's own JSON style (4-space indent, CRLF). Round-trip of the untouched file was byte-identical apart from the final newline.
- `tools/make_maxpat.py` must no longer be run over `max/ThereminRider.maxpat` (it would wipe the user's edits). MAX_SETUP.md says so.

### Verified
- Arduino on COM7 (USB Serial Device) sends `p\r\n` (bytes 112 13 10) at 9600 baud; nothing at 115200.
- Live 20 s capture on COM7 with the patch's maths: 14 pulses, 0 stray bytes; gaps between 250 ms and 5 s give RPM values (15–172 RPM). 5 of 14 pulses came under 250 ms after the previous one and were dropped by `split` (KI-27).
- Patch JSON: 0 cables with a bad inlet/outlet index, no overlapping boxes in columns 5–6, full path traced from `serial` to `udpsend`. Not opened in Max by me.
- Godot: headless import clean; smoke test fails only the same two speed checks as 0.4.0/0.4.1 (uncommitted local `bike_tuning.tres` edits). No Godot files changed.
- `tools/make_maxpat.py` now refuses to write `max/ThereminRider.maxpat` without `--force` (tested: exits 1, patch untouched).

## 0.4.1: 2026-11-10, Arduino pedal sensor in the Max patch

### Added
- **Max patch column 5, ARDUINO (pedal sensor):** reads the Arduino's `p` byte (one per pedal turn) with `[serial]`, picks out byte 112 with `[sel 112]` and sends a pulse on `tr.pulse`. Has a port menu (**list ports** fills it from `[serial]`'s port list), an editable `port COM7` box, baud buttons (9600 / 115200, opens at 9600), a READ toggle that turns on when the patch opens (`metro 10` polls the port), a light that flashes on each `p`, and a "last byte received" number for checking the baud rate. Line endings and other bytes are ignored.
- The PEDALS column's **pulse in** now also listens to `[r tr.pulse]`, so Arduino pulses go through the existing timer → RPM → `/bike/cadence` logic unchanged.

### Changed
- The patch now has seven columns: PEDALS is column 6 and TO GODOT is column 7. Quick-start text and column notes updated.
- `[serial z 9600]` starts on a port that doesn't exist, so opening the patch never tries a Bluetooth COM port (that can freeze Max for a while). Max logs a serial error about port z until you pick the real port.
- MAX_SETUP.md: "Adding the stationary bike later" is now "The Arduino pedal sensor", with setup steps.

### Verified
- `tools/make_maxpat.py` runs with no `LAYOUT:` warnings. A script checked every cable's outlet/inlet index against the box's counts (0 bad) and traced the path `serial → sel 112 → s tr.pulse → r tr.pulse → pulse in → t b b → timer`.
- Not opened in Max and no Arduino was connected (only Bluetooth COM ports on this PC), so the serial reading itself is untested (KI-26). No Godot code changed.
- Headless import: exit 0, no script errors. Smoke test: everything passes except the same two speed checks as 0.4.0, which fail because of the uncommitted local edits in `data/bike_tuning.tres`.

## 0.4.0: 2026-11-10, true first person; bike and camera editable in Godot

### Added
- **True first-person view:** you see your own arms (shirt sleeves, bare forearms, gloved hands) holding the handlebar, the stem and the top of the front wheel. The bars, hands and arms turn with the steering. Arms now have elbows (two-bone IK, like the legs).
- **`scenes/bike/bike_model.tscn`:** the bike/rider model is now a scene. `bike_model.gd` is `@tool`, so the model shows in the editor and every shape point is an Inspector field that rebuilds live. The `FirstPersonCamera` node in it sets the first-person position, angle and FOV (tick Preview to see the view in the editor). See TUNING.md "Bike model and first-person camera".
- Palette colour `rider_glove`.

### Changed
- Rider posture is more upright (city-bike style) with a swept-back, slightly raised handlebar, so the bars and hands are in view without bending the camera straight down. The first-person eye moved back and down a little (1.56 m high), pitched 24° down, FOV 80.
- `palette.gd` and `mesh_kit.gd` are `@tool` (needed for the editor preview; no behaviour change).

### Removed
- `road_tuning.fp_pitch_deg` and `fp_fov_deg`: the `FirstPersonCamera` node replaces them. `fp_roll_factor` stays.

### Verified
- Headless import: clean. Opened `bike_model.tscn` in the headless editor: no script errors (didn't look at the editor viewport itself).
- Smoke test: every bike, camera, crash and course check passes. The two speed checks ("90 RPM stays under 29 km/h", "max_speed_kmh is reachable") fail because of uncommitted local edits in `data/bike_tuning.tres` (`speed_per_rpm` 0.09, `max_speed_kmh` 60), not this change.
- Screenshots: looked at `first_person.png` (bars, hands and arms visible above the HUD gauge), `third_person.png` and `crash_landed.png` (rider and bike look right from behind). Didn't check a fall in first person or a hard turn on screen.

## 0.3.1: 2026-11-10, rail message fix, 45 km/h top speed

### Fixed
- The "RAIL! Steer LEFT/RIGHT" subtitle stayed on screen after leaving the rail. Timed HUD messages only cleared the title, never the subtitle (`hud.gd`). Now both clear, and leaving the rail clears the rail message straight away.

### Changed
- `road_follow` 0.6 → 0.55 (the bike follows 55 % of each curve by itself).
- New `max_speed_kmh` 45: hard top speed. `max_cadence_rpm` 150 → 180 so 45 km/h is reachable (≈ 167 RPM at `speed_per_rpm` 0.075). Cruise is unchanged: 90 RPM ≈ 24 km/h.
- A bit more acceleration: `max_accel` 1.5 → 2.0, `pedal_response` 0.55 → 0.75.

### Tests
- New check: `max_speed_kmh` is reachable by pedalling.

### Verified
- Headless import: clean. Smoke test Normal: all pass (endless 290 m in 45 s, 0 crashes; course 4:01.9, 0 crashes). The HUD fix wasn't checked on screen.

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
