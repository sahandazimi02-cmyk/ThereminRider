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
