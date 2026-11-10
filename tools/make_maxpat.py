"""Generates max/ThereminRider.maxpat (Max 9 patcher JSON). Run: python tools/make_maxpat.py max/ThereminRider.maxpat"""
import json, sys

boxes, lines = [], []
_n = [0]

def _id():
    _n[0] += 1
    return f"obj-{_n[0]}"

def add(maxclass, x, y, w=None, h=22.0, text=None, ins=1, outs=0, otypes=None, **extra):
    i = _id()
    b = {"id": i, "maxclass": maxclass, "numinlets": ins, "numoutlets": outs,
         "patching_rect": [float(x), float(y), float(w if w is not None else 100.0), float(h)]}
    if outs:
        b["outlettype"] = otypes if otypes is not None else [""] * outs
    if text is not None:
        b["text"] = text
    b.update(extra)
    boxes.append({"box": b})
    return i

def obj(text, x, y, w=None, ins=1, outs=1, otypes=None):
    return add("newobj", x, y, w or max(40.0, 7.0 * len(text) + 14), text=text, ins=ins, outs=outs, otypes=otypes)

def msg(text, x, y, w=None):
    return add("message", x, y, w or max(32.0, 7.0 * len(text) + 14), text=text, ins=2, outs=1)

def flonum(x, y, w=60.0):
    return add("flonum", x, y, w, ins=1, outs=2, otypes=["", "bang"], format=6, parameter_enable=0)

def button(x, y):
    return add("button", x, y, 24.0, 24.0, ins=1, outs=1, otypes=["bang"], parameter_enable=0)

def toggle(x, y, size=24.0):
    return add("toggle", x, y, size, size, ins=1, outs=1, otypes=["int"], parameter_enable=0)

def comment(text, x, y, w=300.0, h=None, bold=False, size=12.0):
    nl = text.count("\n") + 1
    extra = {"fontsize": size}
    if bold:
        extra["fontface"] = 1
    return add("comment", x, y, w, h or (nl * (size + 6.0) + 4.0), text=text, ins=1, outs=0, **extra)

def panel(x, y, w, h, rgba):
    return add("panel", x, y, w, h, ins=1, outs=0, bgcolor=rgba, mode=0, rounded=8, background=1)

def slider(x, y, w, h, mn, size):
    return add("slider", x, y, w, h, ins=1, outs=1, otypes=[""], floatoutput=1, min=float(mn),
               size=float(size), orientation=1, parameter_enable=0)

def link(src, src_out, dst, dst_in):
    lines.append({"patchline": {"source": [src, src_out], "destination": [dst, dst_in]}})

# ------------------------------------------------------------------ backgrounds
panel(10, 40, 360, 330, [0.20, 0.24, 0.30, 0.35])
panel(380, 40, 720, 520, [0.18, 0.30, 0.26, 0.35])
panel(10, 580, 1090, 380, [0.32, 0.24, 0.18, 0.35])
panel(1110, 40, 330, 330, [0.25, 0.20, 0.32, 0.35])

comment("THEREMIN RIDER  -  Max -> Godot bridge.   Turn audio ON (click the speaker), play the theremin, calibrate, then start the game.", 10, 8, 1100, bold=True, size=14.0)

# ------------------------------------------------------------------ 1. audio in
comment("1. THEREMIN AUDIO IN", 20, 48, 300, bold=True, size=13.0)
comment("Click to turn audio on/off.\nUses your interface input 1.", 80, 74, 260)
adc = add("ezadc~", 20, 74, 45.0, 45.0, ins=1, outs=2, otypes=["signal", "signal"])
gain = add("live.gain~", 20, 150, 136.0, 41.0, ins=1, outs=4, otypes=["signal", "", "float", "list"],
           channels=1, lastchannelcount=0, orientation=1, parameter_enable=1, varname="monitor_gain",
           saved_attribute_attributes={"valueof": {"parameter_initial": [-70], "parameter_initial_enable": 1,
               "parameter_longname": "monitor_gain", "parameter_mmax": 6.0, "parameter_mmin": -70.0,
               "parameter_modmode": 0, "parameter_shortname": "monitor", "parameter_type": 0, "parameter_unitstyle": 4}})
comment("Monitor level (starts muted).\nUse your interface's direct monitor\ninstead if you can (no delay).", 170, 150, 190)
dac = add("ezdac~", 20, 210, 45.0, 45.0, ins=2, outs=0)
link(adc, 0, gain, 0)
link(gain, 0, dac, 0)
link(gain, 0, dac, 1)

amp = obj("peakamp~ 50", 20, 280, ins=2, outs=1, otypes=["float"])
amp_num = flonum(20, 310)
comment("Loudness (0..1). In your old patch\npeakamp~ had no input; it's wired now.", 110, 300, 250)
link(adc, 0, amp, 0)
link(amp, 0, amp_num, 0)

# ------------------------------------------------------------------ 2. pitch -> steer
comment("2. PITCH -> STEERING  (/bike/steer  -1 .. +1)", 390, 48, 500, bold=True, size=13.0)
pe = obj("abl.dsp.pitchestimator~", 390, 80, ins=1, outs=2, otypes=["signal", "signal"])
snap = obj("snapshot~ 20", 390, 112, ins=2, outs=1, otypes=["float"])
pitch_num = flonum(390, 144, 70.0)
comment("<- live pitch (Hz), 50x per second", 465, 144, 230)
link(adc, 0, pe, 0)
link(pe, 0, snap, 0)
link(snap, 0, pitch_num, 0)

comment("CALIBRATE: hold your hand at each spot and click its button.\nDefaults match your old patch (50 / 225 / 400 Hz).", 390, 180, 520)
lb = obj("loadbang", 390, 222, ins=1, outs=1, otypes=["bang"])
cal = {}
for k, (label, default, x) in enumerate([("FULL LEFT", "50.", 390), ("STRAIGHT", "225.", 560), ("FULL RIGHT", "400.", 730)]):
    comment(label, x, 252, 120, bold=True)
    b = button(x, 274)
    comment("set", x + 28, 276, 40)
    store = obj("f", x, 306, 40.0, ins=2, outs=1, otypes=["float"])
    m = msg(default, x + 60, 306)
    n = flonum(x, 338, 80.0)
    link(lb, 0, m, 0)
    link(m, 0, n, 0)
    link(b, 0, store, 0)
    link(snap, 0, store, 1)
    link(store, 0, n, 0)
    cal[label] = n

steer_expr = obj("expr ((($f1-$f3)*($f2-$f3))>0)*(($f3-$f1)/($f2-$f3)) + ((($f1-$f3)*($f2-$f3))<=0)*(($f1-$f3)/($f4-$f3))",
                 390, 380, 680.0, ins=4, outs=1)
comment("Piecewise map: LEFT -> -1, STRAIGHT -> 0, RIGHT -> +1 (works if left is the higher pitch too).", 390, 404, 600)
link(snap, 0, steer_expr, 0)
link(cal["FULL LEFT"], 0, steer_expr, 1)
link(cal["STRAIGHT"], 0, steer_expr, 2)
link(cal["FULL RIGHT"], 0, steer_expr, 3)
clip = obj("clip -1. 1.", 390, 430, ins=3, outs=1)
slide = obj("slide 3. 3.", 390, 460, ins=3, outs=1, otypes=["float"])
comment("<- smoothing: bigger numbers = smoother but laggier", 480, 460, 320)
link(steer_expr, 0, clip, 0)
link(clip, 0, slide, 0)
steer_slider = slider(390, 492, 360.0, 30.0, -1.0, 2.0)
steer_num = flonum(760, 496)
comment("L          straight          R", 470, 524, 220)
link(slide, 0, steer_slider, 0)
link(slide, 0, steer_num, 0)
p_steer = obj("prepend /bike/steer", 900, 496, ins=2, outs=1)
link(slide, 0, p_steer, 0)

# presence
comment("HAND PRESENT?  (/bike/steer/present 1/0)", 900, 180, 200, bold=True)
comment("min pitch (Hz)", 900, 222, 100)
pres_min_msg = msg("35.", 1000, 222)
pres_min = flonum(1040, 222)
comment("min loudness", 900, 252, 100)
pres_gate_msg = msg("0.02", 1000, 252)
pres_gate = flonum(1040, 252)
link(lb, 0, pres_min_msg, 0)
link(pres_min_msg, 0, pres_min, 0)
link(lb, 0, pres_gate_msg, 0)
link(pres_gate_msg, 0, pres_gate, 0)
pres = obj("expr ($f1 > $f3) && ($f2 > $f4)", 900, 290, 190.0, ins=4, outs=1)
link(snap, 0, pres, 0)
link(amp, 0, pres, 1)
link(pres_min, 0, pres, 2)
link(pres_gate, 0, pres, 3)
pres_tog = toggle(900, 320)
comment("<- lit = hand in range", 930, 322, 160)
p_pres = obj("prepend /bike/steer/present", 900, 350, ins=2, outs=1)
link(pres, 0, pres_tog, 0)
link(pres, 0, p_pres, 0)
comment("Set min pitch just below your\nFULL LEFT (or RIGHT) pitch. Pulling\nthe hand away (zero-beat) = absent.", 900, 384, 200)

# ------------------------------------------------------------------ 3. pedal
comment("3. STATIONARY BIKE  (/bike/cadence  RPM)  -  sensor not connected yet", 20, 588, 700, bold=True, size=13.0)
comment("Turn this on only when the bike sensor (or the test slider) should drive the speed.\nWhile it's OFF the game uses the controller A button / Space bar for pedalling.", 20, 612, 700)
send_tog = toggle(20, 656, 32.0)
comment("SEND PEDAL DATA", 60, 662, 160, bold=True)
metro = obj("metro 50", 20, 700, ins=2, outs=1, otypes=["bang"])
link(send_tog, 0, metro, 0)
cad_store = obj("f", 20, 820, 40.0, ins=2, outs=1, otypes=["float"])
link(metro, 0, cad_store, 0)
cad_num = flonum(20, 850)
p_cad = obj("prepend /bike/cadence", 100, 850, ins=2, outs=1)
link(cad_store, 0, cad_num, 0)
link(cad_store, 0, p_cad, 0)

comment("(a) TEST: drag to fake pedalling (0-150 RPM)", 240, 656, 320, bold=True)
cad_slider = slider(240, 680, 300.0, 26.0, 0.0, 150.0)
cad_slider_num = flonum(550, 682)
link(cad_slider, 0, cad_slider_num, 0)
link(cad_slider, 0, cad_store, 1)

comment("(b) SENSOR: bang this once per crank turn (e.g. [serial] -> [sel 1] -> here,\nor a reed/hall switch via Arduino). Converts pulse timing to RPM.", 600, 656, 480, bold=False)
pulse = button(600, 700)
comment("<- pulse in", 630, 702, 100)
tbb = obj("t b b", 600, 734, ins=1, outs=2, otypes=["bang", "bang"])
timer = obj("timer", 600, 766, ins=2, outs=2, otypes=["float", "float"])
ppr_msg = msg("1.", 760, 734)
comment("pulses per crank turn", 800, 734, 160)
ppr = flonum(700, 766, 50.0)
link(lb, 0, ppr_msg, 0)
link(ppr_msg, 0, ppr, 0)
rpm = obj("expr 60000. / ($f1 * $f2)", 600, 894, 170.0, ins=2, outs=1)
rpm_clip = obj("clip 0. 200.", 600, 926, ins=3, outs=1)
link(pulse, 0, tbb, 0)
link(tbb, 1, timer, 1)
link(tbb, 0, timer, 0)
gate_ms = obj("split 250. 5000.", 600, 862, ins=3, outs=2)
comment("<- ignores silly intervals (first pulse, bounces)", 720, 862, 300)
link(timer, 0, gate_ms, 0)
link(gate_ms, 0, rpm, 0)
link(ppr, 0, rpm, 1)
link(rpm, 0, rpm_clip, 0)
link(rpm_clip, 0, cad_store, 1)
stop_del = obj("del 2000", 800, 798, ins=2, outs=1, otypes=["bang"])
zero = msg("0.", 800, 830)
comment("no pulse for 2 s = stopped", 850, 798, 200)
link(tbb, 0, stop_del, 0)
link(stop_del, 0, zero, 0)
link(zero, 0, cad_store, 1)

# ------------------------------------------------------------------ 4. network out
comment("4. SEND TO GODOT", 1120, 48, 300, bold=True, size=13.0)
comment("Same PC: 127.0.0.1\nOther PC: click/edit host with the\ngame PC's IP. Port must match\ninput_tuning.tres (default 9100).", 1120, 74, 300)
host = msg("host 127.0.0.1", 1120, 150)
port = msg("port 9100", 1240, 150)
udp = obj("udpsend 127.0.0.1 9100", 1120, 300, ins=1, outs=0)
link(host, 0, udp, 0)
link(port, 0, udp, 0)
link(p_steer, 0, udp, 0)
link(p_pres, 0, udp, 0)
link(p_cad, 0, udp, 0)
comment("Messages sent:\n/bike/steer f   (-1..1, 50x/s)\n/bike/steer/present i  (1 or 0)\n/bike/cadence f  (RPM, 20x/s when ON)", 1120, 190, 300)

patch = {"patcher": {
    "fileversion": 1,
    "appversion": {"major": 9, "minor": 2, "revision": 0, "architecture": "x64", "modernui": 1},
    "classnamespace": "box",
    "rect": [40.0, 80.0, 1460.0, 940.0],
    "gridsize": [15.0, 15.0],
    "boxes": boxes,
    "lines": lines,
    "parameters": {},
    "autosave": 0,
}}
# register the live.gain~ parameter like Max does
patch["patcher"]["parameters"] = {gain: ["monitor_gain", "monitor", 0], "inherited_shortname": 1}

with open(sys.argv[1], "w", encoding="utf-8", newline="\n") as f:
    json.dump(patch, f, indent=4)
print(f"{len(boxes)} boxes, {len(lines)} lines")
