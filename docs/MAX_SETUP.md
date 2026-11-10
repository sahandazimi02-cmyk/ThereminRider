# Max setup: `max/ThereminRider.maxpat`

Your original patch (`C:\Users\User\Desktop\What matters\bike theremin.maxpat`) is untouched. The new patch keeps its core (`abl.dsp.pitchestimator~` → map 50/225/400 Hz to −1…+1) and fixes what stopped it from driving a game.

| Old patch | New patch |
|---|---|
| No `udpsend`, so nothing reached the game | `udpsend 127.0.0.1 9100` sends `/bike/steer`, `/bike/steer/present`, `/bike/cadence` |
| `peakamp~ 40` had no input, so the loudness gate never fired | `peakamp~ 50` is wired to the theremin input |
| "Present" gate was `pitch > 200`, which cut off most of the left half (50–200 Hz) | Present = pitch above a **min pitch** you set (default 35 Hz) **and** loudness above a gate (0.02) |
| Calibration constants only loaded when you clicked the button | `loadbang` loads defaults. Each of FULL LEFT / STRAIGHT / FULL RIGHT has its own **set** button that captures the current pitch. |
| One straight line from 50 to 400 Hz (centre fixed at 225) | **Piecewise** mapping: left half and right half scale separately, so your "straight" spot can be anywhere. It also works if your left is the higher pitch. |
| No smoothing | `slide 3. 3.` smooths (Godot adds a little more) |
| No pedal input | Section 3: a test slider, plus a sensor-pulse → RPM converter, both behind a **SEND PEDAL DATA** toggle |

## Steps

1. Open `max/ThereminRider.maxpat` in Max 9. `abl.dsp.pitchestimator~` comes from the ABL objects package; it was already in your old patch.
2. Click the **ezadc~ speaker** to turn audio on. Pick your audio interface in *Options → Audio Status* if needed.
3. Play the theremin. The **live pitch** number should follow your hand.
4. **Calibrate:** hold your hand at the full-left spot and click **set** under FULL LEFT. Do the same for STRAIGHT and FULL RIGHT.
5. Set **min pitch** just below your full-left pitch (or full-right, if that's the lower one). The **hand in range** toggle should light while you play, and go dark when you pull your hand away (Etherwave zero-beat → very low pitch).
6. Start the game and open **Input check**. Steering should say `LIVE` and move with your hand.
7. Too jittery: raise the `slide` numbers in Max, or `osc_steer_smoothing_s` in Godot. Too laggy: lower them.

## Game on another computer

Click the `host 127.0.0.1` message box after editing it to the game PC's IP (e.g. `host 192.168.1.20`). Windows may ask whether Godot may use the network the first time; allow it on private networks.

## Adding the stationary bike later

The game only needs **RPM** on `/bike/cadence`. Section 3 gives you two ways in:

- **(a) Test slider:** turn **SEND PEDAL DATA** on and drag the slider. Use this to try the bike side before any sensor exists.
- **(b) Pulse input:** bang the **pulse in** button once per crank turn. `timer` measures the gap, `split 250. 5000.` drops silly intervals, and `expr 60000/(ms × pulses-per-turn)` gives RPM. If no pulse arrives for 2 s, it sends 0. Typical sources:
  - Arduino + reed or hall switch with a magnet on the crank → `serial` → `sel 1` → **pulse in**.
  - BLE/ANT+ cadence sensor: these report RPM directly, so feed that number into the right inlet of the `[f]` above `prepend /bike/cadence` and skip the pulse path.
  - Smart trainer (FTMS): same as above, send its cadence.
- Alternatively send `/bike/pedal` once per pedal stroke and let Godot do the maths (2 strokes per revolution).

**Remember:** while SEND PEDAL DATA is on, the game uses the bike and ignores the controller's A button (Auto mode). Turn it off to playtest with the controller.

## Regenerating the patch

`tools/make_maxpat.py` builds this patch from code: `python tools/make_maxpat.py max/ThereminRider.maxpat`. If you edit the patch in Max and save it, that file is the source of truth; don't regenerate over it.
