# Controls

## Control profiles

Pick one on the main menu (**Controls: ...** button) or press **F2** anywhere. The choice is saved.

| # | Profile | Steering | Pedalling |
|---|---|---|---|
| 1 | **Controller / keyboard** (default) | Left stick, or A / D / ← / → | Tap the pad's A button, or Space / W / ↑ |
| 2 | **Theremin + bike pedals** | Theremin (Max `/bike/steer`) | Stationary bike (Max `/bike/cadence` or `/bike/pedal`) |
| 3 | **Theremin + controller / keyboard pedal** | Theremin (Max `/bike/steer`) | Tap the pad's A button, or Space / W / ↑ |

A channel set to the theremin or bike never falls back to the controller. If Max isn't sending it, the HUD shows **NO SIGNAL** for that channel (and the bike gets no steering / no pedalling), so you know straight away the profile and the hardware don't match. Camera, pause, reset and F1/F2 keys work in every profile.

## The real thing (two players)

| Player | Does | Game effect |
|---|---|---|
| Steerer (theremin pitch hand) | Hand toward FULL LEFT / STRAIGHT / FULL RIGHT spots | Steers the front wheel. Steering is also how you **balance**: below about 13 km/h, steer *toward* the side you're falling to catch it. Above that the bike mostly holds itself up, so steer smoothly; holding full lock at speed still tips you over. |
| Steerer | Pull the hand out of range | Steering eases to straight and the HUD warns you. You can't get up after a crash without the hand present. |
| Pedaller (stationary bike) | Pedal faster or slower | Speed = cadence × 0.105 m/s per RPM (90 RPM ≈ 34 km/h) |
| Pedaller | Stop pedalling | The bike brakes quickly; below ~9 km/h it wobbles and tips over (about 4 s from cruising speed). |

**Getting back up after a crash** (both players, about 2 s): the pedaller pedals at ≥ 30 RPM **and** the steerer holds steering centred (within ±0.2). The ring fills while both are held and drains if either lets go. You respawn a few metres back, in a lane with no obstacle, with your foot down. Pedal off to start again.

## Controller (playtest)

| Input | Action |
|---|---|
| Left stick X | Steer |
| **A** (tap) | One pedal stroke. Tap faster to pedal faster: 3 taps/s ≈ 90 RPM ≈ 34 km/h. Stop tapping and the bike coasts, then falls. |
| Y | 1st / 3rd person camera |
| Start | Pause |
| Back / Select | Quick reset (debug) |

One controller can play both roles, or two people can share it. To get up after a crash: tap A **and** leave the stick centred.

## Keyboard

| Key | Action |
|---|---|
| A / D or ← / → | Steer |
| Space, W or ↑ (tap) | Pedal stroke |
| C | Camera |
| Esc | Pause |
| R | Quick reset (debug) |
| F1 | Debug overlay (physics values and OSC traffic) |
| F2 | Next control profile (see the table at the top; saved) |

## Notes

- These actions are created in code (`RiderInput._ensure_actions`), but only if they don't already exist. To rebind, add an action with the same name in *Project → Project Settings → Input Map*, and it takes priority. Names: `steer_left`, `steer_right`, `pedal`, `toggle_camera`, `pause`, `debug_reset`, `toggle_debug`, `cycle_input_mode` (= next control profile).
- Menus use Godot's built-in `ui_*` actions (A = accept). The **Input check** screen deliberately has no focused button, so A stays free for pedal taps; leave it with Esc / Start.
- After a Course finish, the results buttons wait 2 s before accepting input, so pedal taps don't skip them.
