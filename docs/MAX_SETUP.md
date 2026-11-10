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
| No pedal input | Column 5 reads the Arduino's `p` pulses over USB serial. Column 6 turns pulses into RPM (or use a test slider), behind a **SEND PEDAL DATA** toggle |
| Everything in one tangle of cables | Seven numbered columns (below); cables stay inside a column |

## How the patch is laid out (since 0.2.0; seven columns since 0.4.1)

> **Your steering (0.4.2):** in your saved patch the steering comes from the live pitch → `ftom 0.` (Hz → MIDI note) → `zmap 60. 80. -1. 1.` → multislider → `slide` → `/bike/steer`. The piecewise calibration `expr` in column 3 is no longer connected to `slide`. The table below describes the original generated layout.

Seven columns, left to right in signal order. Each column does one job. Columns talk to each other through named **[s tr.name] → [r tr.name]** pairs instead of long cables: anything sent to `s tr.pitch` comes out of every `r tr.pitch`, with no cable needed. So you can read or change one column without following wires across the screen.

| Column | Does | Receives | Sends |
|---|---|---|---|
| 1 AUDIO IN | Audio on/off, monitor level, pitch tracking, loudness | (theremin input) | `tr.pitch`, `tr.loudness` |
| 2 CALIBRATE | FULL LEFT / STRAIGHT / FULL RIGHT: a **set** button and default per row | `tr.pitch` | `tr.cal.left`, `tr.cal.straight`, `tr.cal.right` |
| 3 STEERING | Piecewise map → clip → **smoothing** number → `/bike/steer` | `tr.pitch`, `tr.cal.*` | `tr.osc` |
| 4 HAND PRESENT | Min pitch + min loudness settings → `/bike/steer/present` | `tr.pitch`, `tr.loudness` | `tr.osc` |
| 5 ARDUINO | Serial port menu, baud rate, READ toggle. Each `p` byte from the Arduino flashes a light and sends a pulse | (USB serial) | `tr.pulse` |
| 6 PEDALS | SEND PEDAL DATA toggle, test slider, pulse → RPM → `/bike/cadence` | `tr.pulse` | `tr.osc` |
| 7 TO GODOT | `udpsend`, host/port, and a **print** toggle that shows every outgoing message in the Max console | `tr.osc` | (UDP to the game) |

- **Defaults** are the message boxes with a number in them (50 / 225 / 400 Hz, smoothing 3, min pitch 35, loudness 0.02, 1 pulse per turn). Each column has its own `loadbang` that loads them when the patch opens; click a box to restore its value.
- **To send something new to the game**, put `prepend /bike/whatever` in front of it and connect that to an `[s tr.osc]` in the same column. Godot ignores addresses it doesn't know.
- The `tr.` prefix keeps the names from clashing with other open patches (send/receive names are global in Max).

## Steps

1. Open `max/ThereminRider.maxpat` in Max 9. `abl.dsp.pitchestimator~` comes from the ABL objects package; it was already in your old patch.
2. Column 1: click the **ezadc~ speaker** to turn audio on. Pick your audio interface in *Options → Audio Status* if needed.
3. Play the theremin. The **live pitch** number in column 1 should follow your hand.
4. Column 2, **calibrate:** hold your hand at the full-left spot and click **set** under FULL LEFT. Do the same for STRAIGHT and FULL RIGHT.
5. Column 4: set **min pitch** just below your full-left pitch (or full-right, if that's the lower one). The **hand in range** toggle should light while you play, and go dark when you pull your hand away (Etherwave zero-beat → very low pitch).
6. Start the game and open **Input check**. Steering should say `LIVE` and move with your hand. If not, turn on **print** in column 7 and check the Max console.
7. **Pedal bike:** see "The Arduino pedal sensor" below.
8. Too jittery: raise the **smoothing** number in column 3, or `osc_steer_smoothing_s` in Godot. Too laggy: lower them.

## Game on another computer

Click the `host 127.0.0.1` message box after editing it to the game PC's IP (e.g. `host 192.168.1.20`). Windows may ask whether Godot may use the network the first time; allow it on private networks.

## The Arduino pedal sensor

The Arduino sends the character `p` over USB serial once per pedal turn (crank revolution). Column 5 reads it and column 6 turns the timing into RPM for `/bike/cadence`.

1. Plug the Arduino in. Close the Arduino IDE's Serial Monitor (only one program can have the port open).
2. Column 5 opens **COM7 at 9600 baud** by itself when the patch opens (`loadbang` → `port COM7`). On this PC the Arduino is COM7 ("USB Serial Device") and its sketch uses 9600. If Windows gives it another number (e.g. a different USB socket), click **list ports** and pick it in the menu, or edit the `port COM7` box and click it. The "Standard Serial over Bluetooth link" ports are not the Arduino.
3. If the sketch's `Serial.begin(...)` ever changes, click the matching **baud** box.
4. **READ** is on by default. Pedal: the light under `sel 112` should flash once per turn and **last byte received** should show 112. Garbage numbers mean the baud rate is wrong.
5. Column 6: the **pulse in** light flashes with it. Turn on **SEND PEDAL DATA**. The **Latest RPM** number shows the cadence, and the game's Input check shows `/bike/cadence` as `LIVE`.
6. Set **pulses per crank turn** if the Arduino sends more than one `p` per revolution (e.g. two magnets → 2).

How the RPM is worked out (column 6): `timer` measures the gap between pulses, `split 250. 5000.` drops gaps that are too short (switch bounce, over 240 RPM) or too long (the first pulse), and `expr 60000/(ms × pulses-per-turn)` gives RPM. The RPM updates once per pulse. If no pulse arrives for 2 s it sends 0, so the bike slows and falls once the rider stops pedalling. Below 30 RPM the pulses are more than 2 s apart, so the value drops to 0 between pulses.

Only the `p` byte (112) counts. Line endings from `println` and any other characters are ignored, so `Serial.print('p')` and `Serial.println("p")` both work.

Other sensors still fit:
- **Test slider:** turn **SEND PEDAL DATA** on and drag the slider (no hardware needed).
- BLE/ANT+ cadence sensor or smart trainer (FTMS): these report RPM directly, so feed that number into the right inlet of the `[f]` above `prepend /bike/cadence` ("Latest RPM") and skip the pulse path.
- Alternatively send `/bike/pedal` once per pedal stroke and let Godot do the maths (2 strokes per revolution).

**Remember:** while SEND PEDAL DATA is on, the game uses the bike and ignores the controller's A button (Auto mode). Turn it off to playtest with the controller.

## Regenerating the patch

**Don't regenerate (since 0.4.2).** `max/ThereminRider.maxpat` now holds the user's own Max edits (the theremin steering via `ftom` → `zmap 60. 80. -1. 1.` with multislider meters, and the moved columns). Running the generator over it would wipe that work, and the generator doesn't contain those edits. Change the patch in Max, or edit its JSON carefully and diff it against the last saved version.

Before 0.4.2: `tools/make_maxpat.py` built this patch from code: `python tools/make_maxpat.py max/ThereminRider.maxpat`. The script also checks the layout (no cable crosses columns, nothing overlaps or spills out of its column) and prints `LAYOUT:` lines if something does. If you edit the patch in Max and save it, that file is the source of truth; don't regenerate over it.
