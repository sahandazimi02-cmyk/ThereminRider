# Known issues and things not verified yet

Append new entries; mark fixed ones instead of deleting them.

## Not verified (needs a human or hardware)

- **KI-01: the Max patch hasn't been opened in Max.** It was generated as JSON (`tools/make_maxpat.py`), and re-laid out in 0.2.0. The connections were checked against inlet/outlet counts and the layout was checked with a rough SVG preview, but nobody has loaded it in Max 9 yet. Check especially:
  - the long piecewise `expr` (it avoids `if()` and uses only arithmetic and comparisons);
  - `abl.dsp.pitchestimator~` loading;
  - `udpsend` reaching the game (Input check screen).
- **KI-02: no real theremin playtest.** Steering feel, latency and jitter with real pitch tracking are untested. Expect to tune `steer_rate_deg_s`, smoothing, and the Max `slide`.
- **KI-03: Hard assist is not proven clearable.** The test bot finishes the course on Easy and Normal with 0 crashes. On Hard (no self-balancing) it reaches about 1 km with many crashes, because countersteer lane changes with only 1.3 m to the rail beat its simple controller. Humans may do better; playtest before trusting Hard.
  - *0.2.0:* the bot got a better balance controller and now finishes the course on all three levels (Easy 1 crash, Normal 3, Hard 1). Still not played by a human.
  - *0.2.1:* with the 0.1.0 balance restored, the bot fails the Hard course again (58 crashes). Easy and Normal pass with 0 crashes.
- **KI-04: the stationary bike sensor doesn't exist yet.** The Max pulse→RPM path and Godot's `/bike/cadence` / `/bike/pedal` handling were tested only with the Python sender.
- **KI-05: visuals checked from 5 screenshots only** (`docs/screenshots/`). Not checked: long endless sessions (memory/streaming), every obstacle type up close, the finish gate.

## Known limitations

- **KI-10: flat road.** No hills or banking.
- **KI-11: collisions use road coordinates** (a box around the bike vs. boxes around obstacles, and |lateral| vs. the rail line), not Godot physics. The rider/bike model can visually clip into a rail while falling.
- **KI-12: first person can't see the handlebars or arms** (they're below the field of view). Lowering `fp_pitch_deg` shows more road but still not the bars.
- **KI-13: no audio at all yet** (no wind, chain, crash or UI sounds).
- **KI-14: Auto input mode prefers OSC per channel.** If Max sends `/bike/cadence 0`, the controller's A button is ignored until you switch SEND PEDAL DATA off or press F2.
- **KI-15: input actions are created at runtime**, so they don't appear in Project Settings → Input Map unless you add them there (yours then take priority).
- **KI-16: the Endless "best" score is the best crash-free streak**, not total distance (total distance has no end).
- **KI-17: scenery is placed blindly.** Trees and rocks are scattered 4–40 m beyond the rails without checking other road segments. This is safe while the heading drift limit keeps the road from looping back, but on very tight hand-made course curves a tree could land near the road on the inside.
- **KI-18: obstacles are spaced by distance only.** An endless car can sit partly in a curve, where the lane-centre box is slightly off from the visible car.
- **KI-19 (0.2.0): Normal is now much harder than 0.1.0.** You have to balance at every speed: hands-off falls in about 2.5-4.5 s, full lock in about 1 s, no pedalling in about 4 s (smoke test `[fall times]`). This was asked for ("takes too long to fall"), but nobody has played it yet. Easy keeps the old self-balancing feel at speed. If Normal is too hard, raise `self_stability` a little or lower `speed_wobble` (see TUNING.md; keep T − k well away from 0).
  - *0.2.1: reverted.* The user found 0.2.0's balance far too hard, so the balance numbers are back to 0.1.0 (hands-off holds itself up at speed). Any future "harder" tuning should be small steps from here.
- **KI-20: the thrown rider ignores the rails.** The rider is a simple ballistic body, so after a rail hit it can land on the far side of the rail or partly inside it. Visual only; the respawn is unaffected.
- **KI-21: the thrown rider keeps its riding pose** (arms forward, legs bent) while tumbling and lying down; there's no ragdoll. Limbs can poke into the ground for a moment.
- **KI-22: crash slow motion uses `Engine.time_scale`.** It's restored when the slow motion ends, on pause, on restart and when the game scene closes. If something ever runs slowly after a crash, this is where to look.
- **KI-23 (0.3.0): the steering assist can feel "on rails".** `heading_assist` and `road_follow` turn the bike for you, so the bike can't be pointed far from the road direction (with full steer it settles ~15–30° off the road). Fine for lane changes and curves; if players want more freedom lower `heading_assist`. All assist levels get the same steering assist.
- **KI-24 (0.3.0): rails no longer crash on contact.** You only crash after `rail_grace_s` of rail time. A rail hit at a steep angle still just scrapes (no bounce effect beyond sparks/shake).
- *KI-03, 0.3.0:* Hard still fails the course in the bot test (11 crashes, down from 58) and fails the rail-recovery check. Easy and Normal pass with 0 crashes.
- **KI-25 (0.4.0): generated model meshes can't be clicked in the editor.** `bike_model.gd` builds the bike and rider in code (`@tool`), so clicking them in the viewport selects nothing and they aren't listed in the Scene dock. Edit them through the `BikeModel` Inspector fields. In first person the view only copies `fp_roll_factor` of the lean, so the bars and arms tilt on screen when the bike leans (by design; set it to 1 to lock them).
- **KI-26 (0.4.1): the Arduino serial column is untested.** Generated without Max or the Arduino at hand. Check that **list ports** fills the menu (it assumes `[serial]` answers `print` with `port <name>` messages from its right outlet; if the menu stays empty, read the port names in the Max console and use the `port COM7` box instead), that the baud matches the sketch, and that the light flashes once per turn. With one `p` per turn the RPM only updates once per turn, and below 30 RPM it drops to 0 between pulses (2 s timeout).
- *KI-01 / KI-26, 0.4.2:* the user has opened and saved the patch in Max 9, and "list ports" filled the menu (COM3–COM7), so the patch loads and `[serial]`'s port list works. Steering is the user's own `ftom` → `zmap` chain now.
- **KI-27 (0.4.2): the pedal sensor gives some extra, irregular pulses.** In a 20 s capture, 5 of 14 pulses came 87–178 ms after the previous one (bursts about 126 ms apart), and gaps of ~350 ms read as 155–172 RPM. It may have been uneven test pedalling. `split 250. 5000.` drops the short gaps, but `t b b` still restarts the timer on a dropped pulse, so the next gap is measured from the extra pulse and reads too fast. Fixes, if a steady-pedalling test shows the same: debounce in the Arduino sketch (ignore the sensor for ~150 ms after a trigger), or change the Max logic to ignore pulses under ~300 ms without restarting the timer.
