# OSC protocol: Max → Godot

Godot listens on **UDP port 9100**, on every network card (`*`). Change this in `data/input_tuning.tres` (`osc_port`, `osc_bind_address`). Messages can arrive one by one or inside OSC bundles; both work.

| Address | Args | Meaning | Who sends it | Rate |
|---|---|---|---|---|
| `/bike/steer` | float, −1 … +1 | −1 = full left, 0 = straight, +1 = full right | Max, from theremin pitch | ~50 /s |
| `/bike/steer/present` | int or float, 0 / 1 | 1 = the steering hand is in the theremin's range | Max | ~50 /s (sending only on change also works) |
| `/bike/cadence` | float, RPM ≥ 0 | crank revolutions per minute of the stationary bike | Max (pedal section) | ~20 /s |
| `/bike/pedal` | anything | one pedal stroke; Godot works out the RPM from the timing | alternative to `/bike/cadence` | per stroke |

You can rename all four addresses in `data/input_tuning.tres`.

## Rules Godot applies

- **Freshness:** a channel counts as "live" while messages arrive at least every `osc_timeout_s` (0.75 s). Max must therefore keep sending, not only when a value changes. The patch uses `snapshot~ 20` and `metro 50` for this.
- **Control profiles** (main menu or F2, see CONTROLS.md) decide which channels Godot takes from OSC:
  - *Controller / keyboard*: OSC is still received and shown on Input check, but not used.
  - *Theremin + bike pedals*: steering from `/bike/steer`, pedalling from `/bike/cadence` (or `/bike/pedal` if no cadence is live).
  - *Theremin + controller / keyboard pedal*: steering from `/bike/steer`; Max's pedal data is ignored, so SEND PEDAL DATA can stay on.
  - There is no automatic fallback (the old *Auto* mode is gone, 0.5.0). A channel the profile takes from OSC reads NONE while it isn't live.
- **Hand absent** (`/bike/steer/present 0`): steering eases back to straight (`steer_absent_return_s`), and the HUD shows *theremin hand not detected* under the profile name. (Since 0.6.0 getting up after a crash no longer needs the hand.)
- **Steering processing in Godot**, in `input_tuning.tres`: `osc_steer_invert`, `osc_steer_gain`, `osc_steer_deadzone` (re-scaled so it stays continuous), and `osc_steer_smoothing_s`.
- **Pedal strokes:** 2 strokes = 1 crank revolution (`strokes_per_rev`). The last 4 intervals are averaged, and cadence drops to 0 after `stroke_timeout_s` (1.2 s) without a stroke.

## Checking it

- In the game: **Main menu → Input check** shows each address, whether it's live, its value, and the last raw message.
- From the command line (no Max):
  ```
  python tools/osc_test_sender.py --steer 0.4 --cadence 77
  RIDER_OSC_PROBE=1  Godot_console.exe --headless --path . res://scenes/test/smoke_test.tscn
  ```
  The probe prints what arrived and exits with 0 if any packets arrived.
