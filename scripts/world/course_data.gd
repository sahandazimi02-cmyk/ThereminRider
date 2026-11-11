## The hand-made Course mode track. Edit freely.
##   SEGMENTS: ["S", length] straight, ["L"|"R", length, radius] curve (eased).
##   OBSTACLES: [s metres from the start line, lane 0=left 1=right, kind,
##               optional lateral nudge in metres].
##   The finish line is at the end of SEGMENTS; RUNOFF_M of road follows it.
class_name CourseData
extends RefCounted

## 0.3.0: longer straight warm-up (140 -> 300 m) and gentler first two curves.
const SEGMENTS := [
	["S", 300.0],
	["R", 90.0, 180.0],
	["S", 100.0],
	["L", 120.0, 130.0],
	["S", 60.0],
	["R", 80.0, 70.0],
	["L", 80.0, 70.0],
	["S", 150.0],
	["R", 140.0, 110.0],
	["S", 80.0],
	["L", 100.0, 60.0],
	["S", 120.0],
	["R", 70.0, 80.0],
	["L", 70.0, 80.0],
	["S", 160.0],
]

const OBSTACLES := [
	[220.0, 0, "cones"],  # warm-up: in the other lane, no need to swerve
	[340.0, 1, "cones"],
	[400.0, 0, "barrier"],
	[460.0, 1, "pothole", 0.0],
	[490.0, 0, "car"],
	[580.0, 1, "cones"],
	[630.0, 0, "cones"],
	[720.0, 1, "car"],
	[760.0, 0, "pothole", 0.3],
	[800.0, 1, "barrier"],
	[860.0, 0, "car"],
	[920.0, 1, "cones"],
	[980.0, 0, "barrier"],
	[1010.0, 1, "pothole", -0.2],  # 0.7.0: was 990, right next to the 980 barrier
	[1060.0, 1, "car"],
	[1140.0, 0, "cones"],
	[1200.0, 1, "barrier"],
	[1260.0, 0, "car"],
	[1320.0, 1, "pothole", 0.0],
	[1360.0, 1, "cones"],
	[1440.0, 0, "barrier"],
	[1500.0, 1, "car"],
	[1580.0, 0, "cones"],
	[1640.0, 1, "barrier"],
	[1700.0, 0, "car"],
]

const RUNOFF_M := 150.0
