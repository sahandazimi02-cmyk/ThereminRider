## The hand-made Course mode track. Edit freely.
##   SEGMENTS: ["S", length] straight, ["L"|"R", length, radius] curve (eased).
##   OBSTACLES: [s metres from the start line, lane 0=left 1=right, kind,
##               optional lateral nudge in metres].
##   The finish line is at the end of SEGMENTS; RUNOFF_M of road follows it.
class_name CourseData
extends RefCounted

const SEGMENTS := [
	["S", 140.0],
	["R", 90.0, 120.0],
	["S", 100.0],
	["L", 120.0, 90.0],
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
	[180.0, 1, "cones"],
	[240.0, 0, "barrier"],
	[300.0, 1, "pothole", 0.0],
	[330.0, 0, "car"],
	[420.0, 1, "cones"],
	[470.0, 0, "cones"],
	[560.0, 1, "car"],
	[600.0, 0, "pothole", 0.3],
	[640.0, 1, "barrier"],
	[700.0, 0, "car"],
	[760.0, 1, "cones"],
	[820.0, 0, "barrier"],
	[830.0, 1, "pothole", -0.2],
	[900.0, 1, "car"],
	[980.0, 0, "cones"],
	[1040.0, 1, "barrier"],
	[1100.0, 0, "car"],
	[1160.0, 1, "pothole", 0.0],
	[1200.0, 1, "cones"],
	[1280.0, 0, "barrier"],
	[1340.0, 1, "car"],
	[1420.0, 0, "cones"],
	[1480.0, 1, "barrier"],
	[1540.0, 0, "car"],
]

const RUNOFF_M := 150.0
