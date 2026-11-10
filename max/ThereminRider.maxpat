{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 9,
            "minor": 2,
            "revision": 0,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [
            40.0,
            80.0,
            1460.0,
            940.0
        ],
        "gridsize": [
            15.0,
            15.0
        ],
        "boxes": [
            {
                "box": {
                    "id": "obj-1",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        10.0,
                        40.0,
                        360.0,
                        330.0
                    ],
                    "bgcolor": [
                        0.2,
                        0.24,
                        0.3,
                        0.35
                    ],
                    "mode": 0,
                    "rounded": 8,
                    "background": 1
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        380.0,
                        40.0,
                        720.0,
                        520.0
                    ],
                    "bgcolor": [
                        0.18,
                        0.3,
                        0.26,
                        0.35
                    ],
                    "mode": 0,
                    "rounded": 8,
                    "background": 1
                }
            },
            {
                "box": {
                    "id": "obj-3",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        10.0,
                        580.0,
                        1090.0,
                        380.0
                    ],
                    "bgcolor": [
                        0.32,
                        0.24,
                        0.18,
                        0.35
                    ],
                    "mode": 0,
                    "rounded": 8,
                    "background": 1
                }
            },
            {
                "box": {
                    "id": "obj-4",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1110.0,
                        40.0,
                        330.0,
                        330.0
                    ],
                    "bgcolor": [
                        0.25,
                        0.2,
                        0.32,
                        0.35
                    ],
                    "mode": 0,
                    "rounded": 8,
                    "background": 1
                }
            },
            {
                "box": {
                    "id": "obj-5",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        10.0,
                        8.0,
                        1100.0,
                        24.0
                    ],
                    "text": "THEREMIN RIDER  -  Max -> Godot bridge.   Turn audio ON (click the speaker), play the theremin, calibrate, then start the game.",
                    "fontsize": 14.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-6",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        48.0,
                        300.0,
                        23.0
                    ],
                    "text": "1. THEREMIN AUDIO IN",
                    "fontsize": 13.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-7",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        80.0,
                        74.0,
                        260.0,
                        40.0
                    ],
                    "text": "Click to turn audio on/off.\nUses your interface input 1.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-8",
                    "maxclass": "ezadc~",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        20.0,
                        74.0,
                        45.0,
                        45.0
                    ],
                    "outlettype": [
                        "signal",
                        "signal"
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-9",
                    "maxclass": "live.gain~",
                    "numinlets": 1,
                    "numoutlets": 4,
                    "patching_rect": [
                        20.0,
                        150.0,
                        136.0,
                        41.0
                    ],
                    "outlettype": [
                        "signal",
                        "",
                        "float",
                        "list"
                    ],
                    "channels": 1,
                    "lastchannelcount": 0,
                    "orientation": 1,
                    "parameter_enable": 1,
                    "varname": "monitor_gain",
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_initial": [
                                -70
                            ],
                            "parameter_initial_enable": 1,
                            "parameter_longname": "monitor_gain",
                            "parameter_mmax": 6.0,
                            "parameter_mmin": -70.0,
                            "parameter_modmode": 0,
                            "parameter_shortname": "monitor",
                            "parameter_type": 0,
                            "parameter_unitstyle": 4
                        }
                    }
                }
            },
            {
                "box": {
                    "id": "obj-10",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        170.0,
                        150.0,
                        190.0,
                        58.0
                    ],
                    "text": "Monitor level (starts muted).\nUse your interface's direct monitor\ninstead if you can (no delay).",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-11",
                    "maxclass": "ezdac~",
                    "numinlets": 2,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        210.0,
                        45.0,
                        45.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-12",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        20.0,
                        280.0,
                        91.0,
                        22.0
                    ],
                    "outlettype": [
                        "float"
                    ],
                    "text": "peakamp~ 50"
                }
            },
            {
                "box": {
                    "id": "obj-13",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        20.0,
                        310.0,
                        60.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-14",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        110.0,
                        300.0,
                        250.0,
                        40.0
                    ],
                    "text": "Loudness (0..1). In your old patch\npeakamp~ had no input; it's wired now.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-15",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        390.0,
                        48.0,
                        500.0,
                        23.0
                    ],
                    "text": "2. PITCH -> STEERING  (/bike/steer  -1 .. +1)",
                    "fontsize": 13.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-16",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        390.0,
                        80.0,
                        175.0,
                        22.0
                    ],
                    "outlettype": [
                        "signal",
                        "signal"
                    ],
                    "text": "abl.dsp.pitchestimator~"
                }
            },
            {
                "box": {
                    "id": "obj-17",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        112.0,
                        98.0,
                        22.0
                    ],
                    "outlettype": [
                        "float"
                    ],
                    "text": "snapshot~ 20"
                }
            },
            {
                "box": {
                    "id": "obj-18",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        390.0,
                        144.0,
                        70.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-19",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        465.0,
                        144.0,
                        230.0,
                        22.0
                    ],
                    "text": "<- live pitch (Hz), 50x per second",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-20",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        390.0,
                        180.0,
                        520.0,
                        40.0
                    ],
                    "text": "CALIBRATE: hold your hand at each spot and click its button.\nDefaults match your old patch (50 / 225 / 400 Hz).",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-21",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        222.0,
                        70.0,
                        22.0
                    ],
                    "outlettype": [
                        "bang"
                    ],
                    "text": "loadbang"
                }
            },
            {
                "box": {
                    "id": "obj-22",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        390.0,
                        252.0,
                        120.0,
                        22.0
                    ],
                    "text": "FULL LEFT",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-23",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        274.0,
                        24.0,
                        24.0
                    ],
                    "outlettype": [
                        "bang"
                    ],
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-24",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        418.0,
                        276.0,
                        40.0,
                        22.0
                    ],
                    "text": "set",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-25",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        306.0,
                        40.0,
                        22.0
                    ],
                    "outlettype": [
                        "float"
                    ],
                    "text": "f"
                }
            },
            {
                "box": {
                    "id": "obj-26",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        450.0,
                        306.0,
                        35.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "50."
                }
            },
            {
                "box": {
                    "id": "obj-27",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        390.0,
                        338.0,
                        80.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-28",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        560.0,
                        252.0,
                        120.0,
                        22.0
                    ],
                    "text": "STRAIGHT",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-29",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        560.0,
                        274.0,
                        24.0,
                        24.0
                    ],
                    "outlettype": [
                        "bang"
                    ],
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-30",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        588.0,
                        276.0,
                        40.0,
                        22.0
                    ],
                    "text": "set",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-31",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        560.0,
                        306.0,
                        40.0,
                        22.0
                    ],
                    "outlettype": [
                        "float"
                    ],
                    "text": "f"
                }
            },
            {
                "box": {
                    "id": "obj-32",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        620.0,
                        306.0,
                        42.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "225."
                }
            },
            {
                "box": {
                    "id": "obj-33",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        560.0,
                        338.0,
                        80.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-34",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        730.0,
                        252.0,
                        120.0,
                        22.0
                    ],
                    "text": "FULL RIGHT",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-35",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        730.0,
                        274.0,
                        24.0,
                        24.0
                    ],
                    "outlettype": [
                        "bang"
                    ],
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-36",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        758.0,
                        276.0,
                        40.0,
                        22.0
                    ],
                    "text": "set",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-37",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        730.0,
                        306.0,
                        40.0,
                        22.0
                    ],
                    "outlettype": [
                        "float"
                    ],
                    "text": "f"
                }
            },
            {
                "box": {
                    "id": "obj-38",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        790.0,
                        306.0,
                        42.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "400."
                }
            },
            {
                "box": {
                    "id": "obj-39",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        730.0,
                        338.0,
                        80.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-40",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        380.0,
                        680.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "expr ((($f1-$f3)*($f2-$f3))>0)*(($f3-$f1)/($f2-$f3)) + ((($f1-$f3)*($f2-$f3))<=0)*(($f1-$f3)/($f4-$f3))"
                }
            },
            {
                "box": {
                    "id": "obj-41",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        390.0,
                        404.0,
                        600.0,
                        22.0
                    ],
                    "text": "Piecewise map: LEFT -> -1, STRAIGHT -> 0, RIGHT -> +1 (works if left is the higher pitch too).",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-42",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        430.0,
                        91.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "clip -1. 1."
                }
            },
            {
                "box": {
                    "id": "obj-43",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        460.0,
                        91.0,
                        22.0
                    ],
                    "outlettype": [
                        "float"
                    ],
                    "text": "slide 3. 3."
                }
            },
            {
                "box": {
                    "id": "obj-44",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        480.0,
                        460.0,
                        320.0,
                        22.0
                    ],
                    "text": "<- smoothing: bigger numbers = smoother but laggier",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-45",
                    "maxclass": "slider",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        390.0,
                        492.0,
                        360.0,
                        30.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "floatoutput": 1,
                    "min": -1.0,
                    "size": 2.0,
                    "orientation": 1,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-46",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        760.0,
                        496.0,
                        60.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-47",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        470.0,
                        524.0,
                        220.0,
                        22.0
                    ],
                    "text": "L          straight          R",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-48",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        900.0,
                        496.0,
                        147.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "prepend /bike/steer"
                }
            },
            {
                "box": {
                    "id": "obj-49",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        900.0,
                        180.0,
                        200.0,
                        22.0
                    ],
                    "text": "HAND PRESENT?  (/bike/steer/present 1/0)",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-50",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        900.0,
                        222.0,
                        100.0,
                        22.0
                    ],
                    "text": "min pitch (Hz)",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-51",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1000.0,
                        222.0,
                        35.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "35."
                }
            },
            {
                "box": {
                    "id": "obj-52",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1040.0,
                        222.0,
                        60.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-53",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        900.0,
                        252.0,
                        100.0,
                        22.0
                    ],
                    "text": "min loudness",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-54",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1000.0,
                        252.0,
                        42.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "0.02"
                }
            },
            {
                "box": {
                    "id": "obj-55",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1040.0,
                        252.0,
                        60.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-56",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "patching_rect": [
                        900.0,
                        290.0,
                        190.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "expr ($f1 > $f3) && ($f2 > $f4)"
                }
            },
            {
                "box": {
                    "id": "obj-57",
                    "maxclass": "toggle",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        900.0,
                        320.0,
                        24.0,
                        24.0
                    ],
                    "outlettype": [
                        "int"
                    ],
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-58",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        930.0,
                        322.0,
                        160.0,
                        22.0
                    ],
                    "text": "<- lit = hand in range",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-59",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        900.0,
                        350.0,
                        203.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "prepend /bike/steer/present"
                }
            },
            {
                "box": {
                    "id": "obj-60",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        900.0,
                        384.0,
                        200.0,
                        58.0
                    ],
                    "text": "Set min pitch just below your\nFULL LEFT (or RIGHT) pitch. Pulling\nthe hand away (zero-beat) = absent.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-61",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        588.0,
                        700.0,
                        23.0
                    ],
                    "text": "3. STATIONARY BIKE  (/bike/cadence  RPM)  -  sensor not connected yet",
                    "fontsize": 13.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-62",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        612.0,
                        700.0,
                        40.0
                    ],
                    "text": "Turn this on only when the bike sensor (or the test slider) should drive the speed.\nWhile it's OFF the game uses the controller A button / Space bar for pedalling.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-63",
                    "maxclass": "toggle",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        20.0,
                        656.0,
                        32.0,
                        32.0
                    ],
                    "outlettype": [
                        "int"
                    ],
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-64",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        60.0,
                        662.0,
                        160.0,
                        22.0
                    ],
                    "text": "SEND PEDAL DATA",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-65",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        20.0,
                        700.0,
                        70.0,
                        22.0
                    ],
                    "outlettype": [
                        "bang"
                    ],
                    "text": "metro 50"
                }
            },
            {
                "box": {
                    "id": "obj-66",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        20.0,
                        820.0,
                        40.0,
                        22.0
                    ],
                    "outlettype": [
                        "float"
                    ],
                    "text": "f"
                }
            },
            {
                "box": {
                    "id": "obj-67",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        20.0,
                        850.0,
                        60.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-68",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        100.0,
                        850.0,
                        161.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "prepend /bike/cadence"
                }
            },
            {
                "box": {
                    "id": "obj-69",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        240.0,
                        656.0,
                        320.0,
                        22.0
                    ],
                    "text": "(a) TEST: drag to fake pedalling (0-150 RPM)",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-70",
                    "maxclass": "slider",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        240.0,
                        680.0,
                        300.0,
                        26.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "floatoutput": 1,
                    "min": 0.0,
                    "size": 150.0,
                    "orientation": 1,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-71",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        550.0,
                        682.0,
                        60.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-72",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        600.0,
                        656.0,
                        480.0,
                        40.0
                    ],
                    "text": "(b) SENSOR: bang this once per crank turn (e.g. [serial] -> [sel 1] -> here,\nor a reed/hall switch via Arduino). Converts pulse timing to RPM.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-73",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        600.0,
                        700.0,
                        24.0,
                        24.0
                    ],
                    "outlettype": [
                        "bang"
                    ],
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-74",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        630.0,
                        702.0,
                        100.0,
                        22.0
                    ],
                    "text": "<- pulse in",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-75",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        600.0,
                        734.0,
                        49.0,
                        22.0
                    ],
                    "outlettype": [
                        "bang",
                        "bang"
                    ],
                    "text": "t b b"
                }
            },
            {
                "box": {
                    "id": "obj-76",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "patching_rect": [
                        600.0,
                        766.0,
                        49.0,
                        22.0
                    ],
                    "outlettype": [
                        "float",
                        "float"
                    ],
                    "text": "timer"
                }
            },
            {
                "box": {
                    "id": "obj-77",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        760.0,
                        734.0,
                        32.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "1."
                }
            },
            {
                "box": {
                    "id": "obj-78",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        800.0,
                        734.0,
                        160.0,
                        22.0
                    ],
                    "text": "pulses per crank turn",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-79",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        700.0,
                        766.0,
                        50.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        "bang"
                    ],
                    "format": 6,
                    "parameter_enable": 0
                }
            },
            {
                "box": {
                    "id": "obj-80",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        600.0,
                        894.0,
                        170.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "expr 60000. / ($f1 * $f2)"
                }
            },
            {
                "box": {
                    "id": "obj-81",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "patching_rect": [
                        600.0,
                        926.0,
                        98.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "clip 0. 200."
                }
            },
            {
                "box": {
                    "id": "obj-82",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 2,
                    "patching_rect": [
                        600.0,
                        862.0,
                        126.0,
                        22.0
                    ],
                    "outlettype": [
                        "",
                        ""
                    ],
                    "text": "split 250. 5000."
                }
            },
            {
                "box": {
                    "id": "obj-83",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        720.0,
                        862.0,
                        300.0,
                        22.0
                    ],
                    "text": "<- ignores silly intervals (first pulse, bounces)",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-84",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        800.0,
                        798.0,
                        70.0,
                        22.0
                    ],
                    "outlettype": [
                        "bang"
                    ],
                    "text": "del 2000"
                }
            },
            {
                "box": {
                    "id": "obj-85",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        800.0,
                        830.0,
                        32.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "0."
                }
            },
            {
                "box": {
                    "id": "obj-86",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        850.0,
                        798.0,
                        200.0,
                        22.0
                    ],
                    "text": "no pulse for 2 s = stopped",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-87",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1120.0,
                        48.0,
                        300.0,
                        23.0
                    ],
                    "text": "4. SEND TO GODOT",
                    "fontsize": 13.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-88",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1120.0,
                        74.0,
                        300.0,
                        76.0
                    ],
                    "text": "Same PC: 127.0.0.1\nOther PC: click/edit host with the\ngame PC's IP. Port must match\ninput_tuning.tres (default 9100).",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-89",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1120.0,
                        150.0,
                        112.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "host 127.0.0.1"
                }
            },
            {
                "box": {
                    "id": "obj-90",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1240.0,
                        150.0,
                        77.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "port 9100"
                }
            },
            {
                "box": {
                    "id": "obj-91",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1120.0,
                        300.0,
                        168.0,
                        22.0
                    ],
                    "text": "udpsend 127.0.0.1 9100"
                }
            },
            {
                "box": {
                    "id": "obj-92",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1120.0,
                        190.0,
                        300.0,
                        76.0
                    ],
                    "text": "Messages sent:\n/bike/steer f   (-1..1, 50x/s)\n/bike/steer/present i  (1 or 0)\n/bike/cadence f  (RPM, 20x/s when ON)",
                    "fontsize": 12.0
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "source": [
                        "obj-8",
                        0
                    ],
                    "destination": [
                        "obj-9",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-9",
                        0
                    ],
                    "destination": [
                        "obj-11",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-9",
                        0
                    ],
                    "destination": [
                        "obj-11",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-8",
                        0
                    ],
                    "destination": [
                        "obj-12",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-12",
                        0
                    ],
                    "destination": [
                        "obj-13",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-8",
                        0
                    ],
                    "destination": [
                        "obj-16",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-16",
                        0
                    ],
                    "destination": [
                        "obj-17",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-17",
                        0
                    ],
                    "destination": [
                        "obj-18",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-21",
                        0
                    ],
                    "destination": [
                        "obj-26",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-26",
                        0
                    ],
                    "destination": [
                        "obj-27",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-23",
                        0
                    ],
                    "destination": [
                        "obj-25",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-17",
                        0
                    ],
                    "destination": [
                        "obj-25",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-25",
                        0
                    ],
                    "destination": [
                        "obj-27",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-21",
                        0
                    ],
                    "destination": [
                        "obj-32",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-32",
                        0
                    ],
                    "destination": [
                        "obj-33",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-29",
                        0
                    ],
                    "destination": [
                        "obj-31",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-17",
                        0
                    ],
                    "destination": [
                        "obj-31",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-31",
                        0
                    ],
                    "destination": [
                        "obj-33",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-21",
                        0
                    ],
                    "destination": [
                        "obj-38",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-38",
                        0
                    ],
                    "destination": [
                        "obj-39",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-35",
                        0
                    ],
                    "destination": [
                        "obj-37",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-17",
                        0
                    ],
                    "destination": [
                        "obj-37",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-37",
                        0
                    ],
                    "destination": [
                        "obj-39",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-17",
                        0
                    ],
                    "destination": [
                        "obj-40",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-27",
                        0
                    ],
                    "destination": [
                        "obj-40",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-33",
                        0
                    ],
                    "destination": [
                        "obj-40",
                        2
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-39",
                        0
                    ],
                    "destination": [
                        "obj-40",
                        3
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-40",
                        0
                    ],
                    "destination": [
                        "obj-42",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-42",
                        0
                    ],
                    "destination": [
                        "obj-43",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-43",
                        0
                    ],
                    "destination": [
                        "obj-45",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-43",
                        0
                    ],
                    "destination": [
                        "obj-46",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-43",
                        0
                    ],
                    "destination": [
                        "obj-48",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-21",
                        0
                    ],
                    "destination": [
                        "obj-51",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-51",
                        0
                    ],
                    "destination": [
                        "obj-52",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-21",
                        0
                    ],
                    "destination": [
                        "obj-54",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-54",
                        0
                    ],
                    "destination": [
                        "obj-55",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-17",
                        0
                    ],
                    "destination": [
                        "obj-56",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-12",
                        0
                    ],
                    "destination": [
                        "obj-56",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-52",
                        0
                    ],
                    "destination": [
                        "obj-56",
                        2
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-55",
                        0
                    ],
                    "destination": [
                        "obj-56",
                        3
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-56",
                        0
                    ],
                    "destination": [
                        "obj-57",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-56",
                        0
                    ],
                    "destination": [
                        "obj-59",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-63",
                        0
                    ],
                    "destination": [
                        "obj-65",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-65",
                        0
                    ],
                    "destination": [
                        "obj-66",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-66",
                        0
                    ],
                    "destination": [
                        "obj-67",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-66",
                        0
                    ],
                    "destination": [
                        "obj-68",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-70",
                        0
                    ],
                    "destination": [
                        "obj-71",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-70",
                        0
                    ],
                    "destination": [
                        "obj-66",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-21",
                        0
                    ],
                    "destination": [
                        "obj-77",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-77",
                        0
                    ],
                    "destination": [
                        "obj-79",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-73",
                        0
                    ],
                    "destination": [
                        "obj-75",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-75",
                        1
                    ],
                    "destination": [
                        "obj-76",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-75",
                        0
                    ],
                    "destination": [
                        "obj-76",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-76",
                        0
                    ],
                    "destination": [
                        "obj-82",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-82",
                        0
                    ],
                    "destination": [
                        "obj-80",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-79",
                        0
                    ],
                    "destination": [
                        "obj-80",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-80",
                        0
                    ],
                    "destination": [
                        "obj-81",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-81",
                        0
                    ],
                    "destination": [
                        "obj-66",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-75",
                        0
                    ],
                    "destination": [
                        "obj-84",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-84",
                        0
                    ],
                    "destination": [
                        "obj-85",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-85",
                        0
                    ],
                    "destination": [
                        "obj-66",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-89",
                        0
                    ],
                    "destination": [
                        "obj-91",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-90",
                        0
                    ],
                    "destination": [
                        "obj-91",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-48",
                        0
                    ],
                    "destination": [
                        "obj-91",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-59",
                        0
                    ],
                    "destination": [
                        "obj-91",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-68",
                        0
                    ],
                    "destination": [
                        "obj-91",
                        0
                    ]
                }
            }
        ],
        "parameters": {
            "obj-9": [
                "monitor_gain",
                "monitor",
                0
            ],
            "inherited_shortname": 1
        },
        "autosave": 0
    }
}