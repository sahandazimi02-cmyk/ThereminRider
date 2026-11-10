"""Generates max/ThereminRider.maxpat (Max 9 patcher JSON).

    python tools/make_maxpat.py max/ThereminRider.maxpat

Layout: six columns, left to right in signal order. Each column is one job and
talks to the others through named [s tr.x] / [r tr.x] pairs instead of long
patch cords, so every column can be read (and changed) on its own:

    1 AUDIO IN -> 2 CALIBRATE -> 3 STEERING -> 4 HAND PRESENT -> 5 PEDALS -> 6 TO GODOT
       tr.pitch / tr.loudness     tr.cal.*                        tr.osc (everything for Godot)
"""
import json
import sys

boxes, lines = [], []
_n = [0]

COL_W = 300.0       # column width
GAP = 16.0          # space between columns
TOP = 150.0         # where the columns start
COL_H = 690.0       # column height
COLORS = [          # panel colours, one per column
    [0.20, 0.24, 0.30, 0.35],
    [0.22, 0.28, 0.22, 0.35],
    [0.18, 0.30, 0.28, 0.35],
    [0.28, 0.26, 0.18, 0.35],
    [0.32, 0.24, 0.18, 0.35],
    [0.26, 0.20, 0.32, 0.35],
]


# ------------------------------------------------------------------ box helpers

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


def link(src, src_out, dst, dst_in):
    lines.append({"patchline": {"source": [src, src_out], "destination": [dst, dst_in]}})


def comment(text, x, y, w=COL_W - 20, bold=False, size=12.0, color=None):
    n = text.count("\n") + 1
    extra = {"fontsize": size}
    if bold:
        extra["fontface"] = 1
    if color:
        extra["textcolor"] = color
    return add("comment", x, y, w, n * (size + 6.0) + 4.0, text=text, ins=1, outs=0, **extra)


class Column:
    """One numbered section. Objects stack downwards from the header."""

    def __init__(self, index, title, blurb):
        self.x = 20.0 + index * (COL_W + GAP)
        self.y = TOP
        add("panel", self.x - 8, self.y - 8, COL_W, COL_H, ins=1, outs=0, bgcolor=COLORS[index],
            mode=0, rounded=8, background=1)
        comment(f"{index + 1}. {title}", self.x, self.y, bold=True, size=15.0)
        self.y += 26
        comment(blurb, self.x, self.y, color=[0.85, 0.85, 0.85, 1.0])
        self.y += (blurb.count("\n") + 1) * 18.0 + 14

    # Each helper places one box at (x + dx, y) and returns its id.
    def obj(self, text, dx=0.0, ins=1, outs=1, otypes=None, w=None, h=22.0):
        return add("newobj", self.x + dx, self.y, w or max(40.0, 7.0 * len(text) + 14), h,
                   text=text, ins=ins, outs=outs, otypes=otypes)

    def msg(self, text, dx=0.0, w=None):
        return add("message", self.x + dx, self.y, w or max(32.0, 7.0 * len(text) + 14), text=text, ins=2, outs=1)

    def num(self, dx=0.0, w=64.0):
        return add("flonum", self.x + dx, self.y, w, ins=1, outs=2, otypes=["", "bang"], format=6, parameter_enable=0)

    def button(self, dx=0.0):
        return add("button", self.x + dx, self.y, 24.0, 24.0, ins=1, outs=1, otypes=["bang"], parameter_enable=0)

    def toggle(self, dx=0.0, size=24.0):
        return add("toggle", self.x + dx, self.y, size, size, ins=1, outs=1, otypes=["int"], parameter_enable=0)

    def slider(self, mn, size, dx=0.0, w=COL_W - 30, h=26.0):
        return add("slider", self.x + dx, self.y, w, h, ins=1, outs=1, otypes=[""], floatoutput=1,
                   min=float(mn), size=float(size), orientation=1, parameter_enable=0)

    def send(self, name, dx=0.0):
        return self.obj(f"s {name}", dx, ins=1, outs=0)

    def recv(self, name, dx=0.0):
        return self.obj(f"r {name}", dx, ins=0, outs=1)

    def note(self, text, dx=0.0, w=None, bold=False):
        return comment(text, self.x + dx, self.y, w or COL_W - 20 - dx, bold=bold)

    def down(self, dy=32.0):
        self.y += dy


# ------------------------------------------------------------------ title + legend

comment("THEREMIN RIDER  -  Max -> Godot bridge", 20, 10, 900, bold=True, size=18.0)
comment("QUICK START:  1) click the speaker in column 1 (audio on)   2) calibrate in column 2   "
        "3) check the hand light in column 4   4) start the game -> Input check", 20, 42, 1500, size=13.0)
comment("HOW TO READ THIS PATCH:  columns run left to right in signal order. Cables only connect things inside a column. "
        "Between columns, [s tr.name] sends to every [r tr.name] with the same name (no cable needed).\n"
        "Message boxes holding a number are the defaults loaded when the patch opens - click one to restore it. "
        "Everything the game receives goes into [s tr.osc] and comes out of column 6.",
        20, 70, 1840, size=12.0, color=[0.8, 0.8, 0.8, 1.0])

# ------------------------------------------------------------------ 1. audio in

c = Column(0, "AUDIO IN", "Theremin on your interface's input 1.\nSends: tr.pitch (Hz), tr.loudness (0..1)")
adc = add("ezadc~", c.x, c.y, 45.0, 45.0, ins=1, outs=2, otypes=["signal", "signal"])
c.note("<- click to turn audio on/off", 55, w=220)
c.down(60)
gain = add("live.gain~", c.x, c.y, 136.0, 41.0, ins=1, outs=4, otypes=["signal", "", "float", "list"],
           channels=1, lastchannelcount=0, orientation=1, parameter_enable=1, varname="monitor_gain",
           saved_attribute_attributes={"valueof": {"parameter_initial": [-70], "parameter_initial_enable": 1,
               "parameter_longname": "monitor_gain", "parameter_mmax": 6.0, "parameter_mmin": -70.0,
               "parameter_modmode": 0, "parameter_shortname": "monitor", "parameter_type": 0, "parameter_unitstyle": 4}})
c.note("<- monitor level (starts\nmuted). Prefer your interface's\ndirect monitor (no delay).", 146, w=146)
c.down(56)
dac = add("ezdac~", c.x, c.y, 45.0, 45.0, ins=2, outs=0)
link(adc, 0, gain, 0)
link(gain, 0, dac, 0)
link(gain, 0, dac, 1)
c.down(70)

c.note("PITCH", bold=True)
c.down(22)
pe = c.obj("abl.dsp.pitchestimator~", ins=1, outs=2, otypes=["signal", "signal"])
link(adc, 0, pe, 0)
c.down()
snap = c.obj("snapshot~ 20", ins=2, outs=1, otypes=["float"])
c.note("<- 50 readings per second", 100, w=180)
link(pe, 0, snap, 0)
c.down()
pitch_num = c.num(w=80.0)
c.note("<- live pitch (Hz)", 90, w=180)
link(snap, 0, pitch_num, 0)
c.down()
s_pitch = c.send("tr.pitch")
link(snap, 0, s_pitch, 0)
c.down(50)

c.note("LOUDNESS", bold=True)
c.down(22)
amp = c.obj("peakamp~ 50", ins=2, outs=1, otypes=["float"])
link(adc, 0, amp, 0)
c.down()
amp_num = c.num()
c.note("<- 0..1", 74, w=100)
link(amp, 0, amp_num, 0)
c.down()
s_loud = c.send("tr.loudness")
link(amp, 0, s_loud, 0)

# ------------------------------------------------------------------ 2. calibrate

c = Column(1, "CALIBRATE", "Hold your hand at each spot and click its\nset button. Sends: tr.cal.left / straight / right")
c.note("Each row is self-contained: [r tr.pitch] is the\nlive pitch, [loadbang] loads the default when\nthe patch opens, set captures the pitch.")
c.down(64)
for label, default, name in [("FULL LEFT", "50.", "tr.cal.left"),
                             ("STRAIGHT", "225.", "tr.cal.straight"),
                             ("FULL RIGHT", "400.", "tr.cal.right")]:
    c.note(label, bold=True)
    c.down(24)
    b = c.button()
    c.note("set", 26, w=34)
    rp = c.recv("tr.pitch", 64)
    lb = c.obj("loadbang", 180, ins=1, outs=1, otypes=["bang"])
    c.down()
    store = c.obj("f", ins=2, outs=1, otypes=["float"], w=40.0)
    m = c.msg(default, 180)
    c.note("<- default", 222, w=70)
    c.down()
    n = c.num(w=80.0)
    c.note("Hz", 86, w=30)
    c.down()
    snd = c.send(name)
    link(lb, 0, m, 0)
    link(m, 0, n, 0)
    link(b, 0, store, 0)
    link(rp, 0, store, 1)
    link(store, 0, n, 0)
    link(n, 0, snd, 0)
    c.down(48)
c.note("Left can be the higher pitch - the\nmapping works either way round.")

# ------------------------------------------------------------------ 3. steering

c = Column(2, "STEERING", "Pitch -> -1 (full left) .. 0 .. +1 (full right).\nSends /bike/steer to the game.")
r_pitch3 = c.recv("tr.pitch")
c.down(36)
r_left = c.recv("tr.cal.left", 30)
r_straight = c.recv("tr.cal.straight", 145)
c.down(28)
r_right = c.recv("tr.cal.right", 145)
c.down(36)
steer_expr = c.obj("expr ((($f1-$f3)*($f2-$f3))>0)*(($f3-$f1)/($f2-$f3)) + ((($f1-$f3)*($f2-$f3))<=0)*(($f1-$f3)/($f4-$f3))",
                   ins=4, outs=1, w=COL_W - 20, h=52.0)
link(r_pitch3, 0, steer_expr, 0)
link(r_left, 0, steer_expr, 1)
link(r_straight, 0, steer_expr, 2)
link(r_right, 0, steer_expr, 3)
c.down(60)
c.note("in: pitch, LEFT, STRAIGHT, RIGHT. Left half and\nright half are scaled separately.")
c.down(44)
clip = c.obj("clip -1. 1.", ins=3, outs=1)
c.note("<- never past full lock", 90, w=180)
link(steer_expr, 0, clip, 0)
c.down(40)

c.note("SMOOTHING (bigger = smoother, laggier)", bold=True)
c.down(24)
sm_msg = c.msg("3.")
sm_num = c.num(50)
lb3 = c.obj("loadbang", 125, ins=1, outs=1, otypes=["bang"])
link(lb3, 0, sm_msg, 0)
link(sm_msg, 0, sm_num, 0)
c.down()
slide = c.obj("slide 3. 3.", ins=3, outs=1, otypes=["float"])
link(clip, 0, slide, 0)
link(sm_num, 0, slide, 1)
link(sm_num, 0, slide, 2)
c.down(40)
steer_slider = c.slider(-1.0, 2.0)
link(slide, 0, steer_slider, 0)
c.down(30)
c.note("L               straight               R")
c.down(26)
steer_num = c.num()
link(slide, 0, steer_num, 0)
c.down(36)
p_steer = c.obj("prepend /bike/steer", ins=2, outs=1)
link(slide, 0, p_steer, 0)
c.down()
s_osc3 = c.send("tr.osc")
link(p_steer, 0, s_osc3, 0)

# ------------------------------------------------------------------ 4. hand present

c = Column(3, "HAND PRESENT", "Is a hand playing? Sends /bike/steer/present 1/0.\nThe game treats 0 as hands off.")
r_pitch4 = c.recv("tr.pitch")
r_loud4 = c.recv("tr.loudness", 100)
c.down(40)
c.note("SETTINGS", bold=True)
c.down(24)
c.note("min pitch (Hz)", w=110)
pres_min_msg = c.msg("35.", 120)
pres_min = c.num(170)
c.down()
c.note("min loudness", w=110)
pres_gate_msg = c.msg("0.02", 120)
pres_gate = c.num(170)
c.down(40)
lb4 = c.obj("loadbang", ins=1, outs=1, otypes=["bang"])
link(lb4, 0, pres_min_msg, 0)
link(lb4, 0, pres_gate_msg, 0)
link(pres_min_msg, 0, pres_min, 0)
link(pres_gate_msg, 0, pres_gate, 0)
c.down(40)
pres = c.obj("expr ($f1 > $f3) && ($f2 > $f4)", ins=4, outs=1, w=220.0)
link(r_pitch4, 0, pres, 0)
link(r_loud4, 0, pres, 1)
link(pres_min, 0, pres, 2)
link(pres_gate, 0, pres, 3)
c.down(36)
pres_tog = c.toggle()
c.note("<- lit = hand in range", 30, w=200)
link(pres, 0, pres_tog, 0)
c.down(40)
p_pres = c.obj("prepend /bike/steer/present", ins=2, outs=1)
link(pres, 0, p_pres, 0)
c.down()
s_osc4 = c.send("tr.osc")
link(p_pres, 0, s_osc4, 0)
c.down(44)
c.note("Set min pitch just below your FULL LEFT\n(or RIGHT) pitch. Pulling the hand away\n(zero-beat) should turn the light off.")

# ------------------------------------------------------------------ 5. pedals

c = Column(4, "PEDALS  (stationary bike)", "Sends /bike/cadence (RPM). Sensor not built yet.\nWhile OFF the game uses the controller A button.")
send_tog = c.toggle(size=32.0)
c.note("SEND PEDAL DATA", 40, w=200, bold=True)
c.down(44)
metro = c.obj("metro 50", ins=2, outs=1, otypes=["bang"])
c.note("<- 20 updates per second", 80, w=180)
link(send_tog, 0, metro, 0)
c.down(44)

c.note("(a) TEST: drag to fake pedalling (0-150 RPM)", bold=True)
c.down(24)
cad_slider = c.slider(0.0, 150.0, w=200.0)
cad_slider_num = c.num(210)
link(cad_slider, 0, cad_slider_num, 0)
c.down(44)

c.note("(b) SENSOR: bang 'pulse in' once per crank\nturn (e.g. Arduino reed switch -> [serial]\n-> [sel 1] -> here). Pulse timing -> RPM.", bold=False)
c.down(60)
pulse = c.button()
c.note("<- pulse in", 30, w=100)
c.down()
tbb = c.obj("t b b", ins=1, outs=2, otypes=["bang", "bang"])
stop_del = c.obj("del 2000", 120, ins=2, outs=1, otypes=["bang"])
c.down()
timer = c.obj("timer", ins=2, outs=2, otypes=["float", "float"])
zero = c.msg("0.", 120)
c.note("<- no pulse for 2 s = stopped", 160, w=130)
link(pulse, 0, tbb, 0)
link(tbb, 1, timer, 1)
link(tbb, 0, timer, 0)
link(tbb, 0, stop_del, 0)
link(stop_del, 0, zero, 0)
c.down()
gate_ms = c.obj("split 250. 5000.", ins=3, outs=2)
c.note("<- drop bounces / first pulse", 120, w=170)
link(timer, 0, gate_ms, 0)
c.down()
c.note("pulses per crank turn", w=140)
ppr_msg = c.msg("1.", 140)
ppr = c.num(178, w=50.0)
lb5 = c.obj("loadbang", 232, ins=1, outs=1, otypes=["bang"], w=56.0)
link(lb5, 0, ppr_msg, 0)
link(ppr_msg, 0, ppr, 0)
c.down()
rpm = c.obj("expr 60000. / ($f1 * $f2)", ins=2, outs=1, w=170.0)
link(gate_ms, 0, rpm, 0)
link(ppr, 0, rpm, 1)
c.down()
rpm_clip = c.obj("clip 0. 200.", ins=3, outs=1)
link(rpm, 0, rpm_clip, 0)
c.down(44)

c.note("Latest RPM (from a or b), sent while ON:", bold=True)
c.down(24)
cad_store = c.obj("f", ins=2, outs=1, otypes=["float"], w=40.0)
link(metro, 0, cad_store, 0)
link(cad_slider, 0, cad_store, 1)
link(rpm_clip, 0, cad_store, 1)
link(zero, 0, cad_store, 1)
cad_num = c.num(50)
c.down()
p_cad = c.obj("prepend /bike/cadence", ins=2, outs=1)
link(cad_store, 0, cad_num, 0)
link(cad_store, 0, p_cad, 0)
c.down()
s_osc5 = c.send("tr.osc")
link(p_cad, 0, s_osc5, 0)

# ------------------------------------------------------------------ 6. to godot

c = Column(5, "TO GODOT", "Everything sent to tr.osc goes out over UDP\nas OSC. Port must match the game (9100).")
r_osc = c.recv("tr.osc")
c.down(44)
c.note("Same PC: 127.0.0.1. Other PC: edit the\nhost box to the game PC's IP, then click it.")
c.down(44)
host = c.msg("host 127.0.0.1")
port = c.msg("port 9100", 130)
c.down(40)
udp = c.obj("udpsend 127.0.0.1 9100", ins=1, outs=0)
link(r_osc, 0, udp, 0)
link(host, 0, udp, 0)
link(port, 0, udp, 0)
c.down(56)

c.note("DEBUG: print what's sent to the Max console", bold=True)
c.down(24)
print_tog = c.toggle()
c.note("<- on = print (very chatty)", 30, w=200)
c.down(36)
gate = c.obj("gate 1", ins=2, outs=1)
link(print_tog, 0, gate, 0)
link(r_osc, 0, gate, 1)
c.down()
prn = c.obj("print tr.osc", ins=1, outs=0)
link(gate, 0, prn, 0)
c.down(56)
c.note("Messages the game understands:\n/bike/steer f          -1..1\n/bike/steer/present i  1 or 0\n/bike/cadence f        RPM\n/bike/pedal            one per stroke\n(see docs/OSC_PROTOCOL.md)")

# ------------------------------------------------------------------ write

patch = {"patcher": {
    "fileversion": 1,
    "appversion": {"major": 9, "minor": 2, "revision": 0, "architecture": "x64", "modernui": 1},
    "classnamespace": "box",
    "rect": [40.0, 80.0, 1920.0, 880.0],
    "gridsize": [15.0, 15.0],
    "boxes": boxes,
    "lines": lines,
    "autosave": 0,
}}
# Register the live.gain~ parameter like Max does.
patch["patcher"]["parameters"] = {gain: ["monitor_gain", "monitor", 0], "inherited_shortname": 1}

# Layout checks: every cable stays inside one column, nothing spills out of its
# column, and no two non-comment boxes overlap.
def _col(box):
    return int((box["patching_rect"][0] - 20.0 + 8.0) // (COL_W + GAP))
by_id = {b["box"]["id"]: b["box"] for b in boxes}
problems = []
for ln in lines:
    a_, b_ = by_id[ln["patchline"]["source"][0]], by_id[ln["patchline"]["destination"][0]]
    if _col(a_) != _col(b_):
        problems.append(f"cable crosses columns: {a_.get('text', a_['maxclass'])} -> {b_.get('text', b_['maxclass'])}")
solid = [b["box"] for b in boxes if b["box"]["maxclass"] not in ("comment", "panel") and b["box"]["patching_rect"][1] >= TOP]
for bx in solid:
    x, y, w, h = bx["patching_rect"]
    left = 20.0 + _col(bx) * (COL_W + GAP) - 8
    if x + w > left + COL_W + 1 or y + h > TOP - 8 + COL_H:
        problems.append(f"outside its column: {bx.get('text', bx['maxclass'])}")
for i, p1 in enumerate(solid):
    for p2 in solid[i + 1:]:
        x1, y1, w1, h1 = p1["patching_rect"]
        x2, y2, w2, h2 = p2["patching_rect"]
        if x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1:
            problems.append(f"overlap: {p1.get('text', p1['maxclass'])} / {p2.get('text', p2['maxclass'])}")
for pr in problems:
    print("LAYOUT:", pr)

with open(sys.argv[1], "w", encoding="utf-8", newline="\n") as f:
    json.dump(patch, f, indent=4)
print(f"{len(boxes)} boxes, {len(lines)} lines")
