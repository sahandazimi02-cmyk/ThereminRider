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
            1920.0,
            880.0
        ],
        "gridsize": [
            15.0,
            15.0
        ],
        "boxes": [
            {
                "box": {
                    "id": "obj-1",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        10.0,
                        900.0,
                        28.0
                    ],
                    "text": "THEREMIN RIDER  -  Max -> Godot bridge",
                    "fontsize": 18.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        42.0,
                        1500.0,
                        23.0
                    ],
                    "text": "QUICK START:  1) click the speaker in column 1 (audio on)   2) calibrate in column 2   3) check the hand light in column 4   4) start the game -> Input check",
                    "fontsize": 13.0
                }
            },
            {
                "box": {
                    "id": "obj-3",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        70.0,
                        1840.0,
                        40.0
                    ],
                    "text": "HOW TO READ THIS PATCH:  columns run left to right in signal order. Cables only connect things inside a column. Between columns, [s tr.name] sends to every [r tr.name] with the same name (no cable needed).\nMessage boxes holding a number are the defaults loaded when the patch opens - click one to restore it. Everything the game receives goes into [s tr.osc] and comes out of column 6.",
                    "fontsize": 12.0,
                    "textcolor": [
                        0.8,
                        0.8,
                        0.8,
                        1.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-4",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        12.0,
                        142.0,
                        300.0,
                        690.0
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
                    "id": "obj-5",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        150.0,
                        280.0,
                        25.0
                    ],
                    "text": "1. AUDIO IN",
                    "fontsize": 15.0,
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
                        176.0,
                        280.0,
                        40.0
                    ],
                    "text": "Theremin on your interface's input 1.\nSends: tr.pitch (Hz), tr.loudness (0..1)",
                    "fontsize": 12.0,
                    "textcolor": [
                        0.85,
                        0.85,
                        0.85,
                        1.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-7",
                    "maxclass": "ezadc~",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        20.0,
                        226.0,
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
                    "id": "obj-8",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        75.0,
                        226.0,
                        220.0,
                        22.0
                    ],
                    "text": "<- click to turn audio on/off",
                    "fontsize": 12.0
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
                        286.0,
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
                        166.0,
                        286.0,
                        146.0,
                        58.0
                    ],
                    "text": "<- monitor level (starts\nmuted). Prefer your interface's\ndirect monitor (no delay).",
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
                        342.0,
                        45.0,
                        45.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-12",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        412.0,
                        280.0,
                        22.0
                    ],
                    "text": "PITCH",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-13",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        20.0,
                        434.0,
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
                    "id": "obj-14",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        20.0,
                        466.0,
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
                    "id": "obj-15",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        120.0,
                        466.0,
                        180.0,
                        22.0
                    ],
                    "text": "<- 50 readings per second",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-16",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        20.0,
                        498.0,
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
                    "id": "obj-17",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        110.0,
                        498.0,
                        180.0,
                        22.0
                    ],
                    "text": "<- live pitch (Hz)",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-18",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        530.0,
                        84.0,
                        22.0
                    ],
                    "text": "s tr.pitch"
                }
            },
            {
                "box": {
                    "id": "obj-19",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        580.0,
                        280.0,
                        22.0
                    ],
                    "text": "LOUDNESS",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-20",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        20.0,
                        602.0,
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
                    "id": "obj-21",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        20.0,
                        634.0,
                        64.0,
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
                    "id": "obj-22",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        94.0,
                        634.0,
                        100.0,
                        22.0
                    ],
                    "text": "<- 0..1",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-23",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        20.0,
                        666.0,
                        105.0,
                        22.0
                    ],
                    "text": "s tr.loudness"
                }
            },
            {
                "box": {
                    "id": "obj-24",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        328.0,
                        142.0,
                        300.0,
                        690.0
                    ],
                    "bgcolor": [
                        0.22,
                        0.28,
                        0.22,
                        0.35
                    ],
                    "mode": 0,
                    "rounded": 8,
                    "background": 1
                }
            },
            {
                "box": {
                    "id": "obj-25",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        150.0,
                        280.0,
                        25.0
                    ],
                    "text": "2. CALIBRATE",
                    "fontsize": 15.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-26",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        176.0,
                        280.0,
                        40.0
                    ],
                    "text": "Hold your hand at each spot and click its\nset button. Sends: tr.cal.left / straight / right",
                    "fontsize": 12.0,
                    "textcolor": [
                        0.85,
                        0.85,
                        0.85,
                        1.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-27",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        226.0,
                        280.0,
                        58.0
                    ],
                    "text": "Each row is self-contained: [r tr.pitch] is the\nlive pitch, [loadbang] loads the default when\nthe patch opens, set captures the pitch.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-28",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        290.0,
                        280.0,
                        22.0
                    ],
                    "text": "FULL LEFT",
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
                        336.0,
                        314.0,
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
                        362.0,
                        314.0,
                        34.0,
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
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        400.0,
                        314.0,
                        84.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.pitch"
                }
            },
            {
                "box": {
                    "id": "obj-32",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        516.0,
                        314.0,
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
                    "id": "obj-33",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        336.0,
                        346.0,
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
                    "id": "obj-34",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        516.0,
                        346.0,
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
                    "id": "obj-35",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        558.0,
                        346.0,
                        70.0,
                        22.0
                    ],
                    "text": "<- default",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-36",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        336.0,
                        378.0,
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
                    "id": "obj-37",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        422.0,
                        378.0,
                        30.0,
                        22.0
                    ],
                    "text": "Hz",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-38",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        410.0,
                        105.0,
                        22.0
                    ],
                    "text": "s tr.cal.left"
                }
            },
            {
                "box": {
                    "id": "obj-39",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        458.0,
                        280.0,
                        22.0
                    ],
                    "text": "STRAIGHT",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-40",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        336.0,
                        482.0,
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
                    "id": "obj-41",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        362.0,
                        482.0,
                        34.0,
                        22.0
                    ],
                    "text": "set",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-42",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        400.0,
                        482.0,
                        84.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.pitch"
                }
            },
            {
                "box": {
                    "id": "obj-43",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        516.0,
                        482.0,
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
                    "id": "obj-44",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        336.0,
                        514.0,
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
                    "id": "obj-45",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        516.0,
                        514.0,
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
                    "id": "obj-46",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        558.0,
                        514.0,
                        70.0,
                        22.0
                    ],
                    "text": "<- default",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-47",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        336.0,
                        546.0,
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
                    "id": "obj-48",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        422.0,
                        546.0,
                        30.0,
                        22.0
                    ],
                    "text": "Hz",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-49",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        578.0,
                        133.0,
                        22.0
                    ],
                    "text": "s tr.cal.straight"
                }
            },
            {
                "box": {
                    "id": "obj-50",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        626.0,
                        280.0,
                        22.0
                    ],
                    "text": "FULL RIGHT",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-51",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        336.0,
                        650.0,
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
                    "id": "obj-52",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        362.0,
                        650.0,
                        34.0,
                        22.0
                    ],
                    "text": "set",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-53",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        400.0,
                        650.0,
                        84.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.pitch"
                }
            },
            {
                "box": {
                    "id": "obj-54",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        516.0,
                        650.0,
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
                    "id": "obj-55",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        336.0,
                        682.0,
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
                    "id": "obj-56",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        516.0,
                        682.0,
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
                    "id": "obj-57",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        558.0,
                        682.0,
                        70.0,
                        22.0
                    ],
                    "text": "<- default",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-58",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        336.0,
                        714.0,
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
                    "id": "obj-59",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        422.0,
                        714.0,
                        30.0,
                        22.0
                    ],
                    "text": "Hz",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-60",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        746.0,
                        112.0,
                        22.0
                    ],
                    "text": "s tr.cal.right"
                }
            },
            {
                "box": {
                    "id": "obj-61",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        336.0,
                        794.0,
                        280.0,
                        40.0
                    ],
                    "text": "Left can be the higher pitch - the\nmapping works either way round.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-62",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        644.0,
                        142.0,
                        300.0,
                        690.0
                    ],
                    "bgcolor": [
                        0.18,
                        0.3,
                        0.28,
                        0.35
                    ],
                    "mode": 0,
                    "rounded": 8,
                    "background": 1
                }
            },
            {
                "box": {
                    "id": "obj-63",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        652.0,
                        150.0,
                        280.0,
                        25.0
                    ],
                    "text": "3. STEERING",
                    "fontsize": 15.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-64",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        652.0,
                        176.0,
                        280.0,
                        40.0
                    ],
                    "text": "Pitch -> -1 (full left) .. 0 .. +1 (full right).\nSends /bike/steer to the game.",
                    "fontsize": 12.0,
                    "textcolor": [
                        0.85,
                        0.85,
                        0.85,
                        1.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-65",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        652.0,
                        226.0,
                        84.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.pitch"
                }
            },
            {
                "box": {
                    "id": "obj-66",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        682.0,
                        262.0,
                        105.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.cal.left"
                }
            },
            {
                "box": {
                    "id": "obj-67",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        797.0,
                        262.0,
                        133.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.cal.straight"
                }
            },
            {
                "box": {
                    "id": "obj-68",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        797.0,
                        290.0,
                        112.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.cal.right"
                }
            },
            {
                "box": {
                    "id": "obj-69",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "patching_rect": [
                        652.0,
                        326.0,
                        280.0,
                        52.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "expr ((($f1-$f3)*($f2-$f3))>0)*(($f3-$f1)/($f2-$f3)) + ((($f1-$f3)*($f2-$f3))<=0)*(($f1-$f3)/($f4-$f3))"
                }
            },
            {
                "box": {
                    "id": "obj-70",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        652.0,
                        386.0,
                        280.0,
                        40.0
                    ],
                    "text": "in: pitch, LEFT, STRAIGHT, RIGHT. Left half and\nright half are scaled separately.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-71",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "patching_rect": [
                        652.0,
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
                    "id": "obj-72",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        742.0,
                        430.0,
                        180.0,
                        22.0
                    ],
                    "text": "<- never past full lock",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-73",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        652.0,
                        470.0,
                        280.0,
                        22.0
                    ],
                    "text": "SMOOTHING (bigger = smoother, laggier)",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-74",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        652.0,
                        494.0,
                        32.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "3."
                }
            },
            {
                "box": {
                    "id": "obj-75",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        702.0,
                        494.0,
                        64.0,
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
                    "id": "obj-76",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        777.0,
                        494.0,
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
                    "id": "obj-77",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "patching_rect": [
                        652.0,
                        526.0,
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
                    "id": "obj-78",
                    "maxclass": "slider",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        652.0,
                        566.0,
                        270.0,
                        26.0
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
                    "id": "obj-79",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        652.0,
                        596.0,
                        280.0,
                        22.0
                    ],
                    "text": "L               straight               R",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-80",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        652.0,
                        622.0,
                        64.0,
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
                    "id": "obj-81",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        652.0,
                        658.0,
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
                    "id": "obj-82",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        652.0,
                        690.0,
                        70.0,
                        22.0
                    ],
                    "text": "s tr.osc"
                }
            },
            {
                "box": {
                    "id": "obj-83",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        960.0,
                        142.0,
                        300.0,
                        690.0
                    ],
                    "bgcolor": [
                        0.28,
                        0.26,
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
                    "id": "obj-84",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        968.0,
                        150.0,
                        280.0,
                        25.0
                    ],
                    "text": "4. HAND PRESENT",
                    "fontsize": 15.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-85",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        968.0,
                        176.0,
                        280.0,
                        40.0
                    ],
                    "text": "Is a hand playing? Sends /bike/steer/present 1/0.\nThe game treats 0 as hands off.",
                    "fontsize": 12.0,
                    "textcolor": [
                        0.85,
                        0.85,
                        0.85,
                        1.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-86",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        968.0,
                        226.0,
                        84.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.pitch"
                }
            },
            {
                "box": {
                    "id": "obj-87",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        1068.0,
                        226.0,
                        105.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.loudness"
                }
            },
            {
                "box": {
                    "id": "obj-88",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        968.0,
                        266.0,
                        280.0,
                        22.0
                    ],
                    "text": "SETTINGS",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-89",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        968.0,
                        290.0,
                        110.0,
                        22.0
                    ],
                    "text": "min pitch (Hz)",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-90",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1088.0,
                        290.0,
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
                    "id": "obj-91",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1138.0,
                        290.0,
                        64.0,
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
                    "id": "obj-92",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        968.0,
                        322.0,
                        110.0,
                        22.0
                    ],
                    "text": "min loudness",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-93",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1088.0,
                        322.0,
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
                    "id": "obj-94",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1138.0,
                        322.0,
                        64.0,
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
                    "id": "obj-95",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        968.0,
                        362.0,
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
                    "id": "obj-96",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "patching_rect": [
                        968.0,
                        402.0,
                        220.0,
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
                    "id": "obj-97",
                    "maxclass": "toggle",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        968.0,
                        438.0,
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
                    "id": "obj-98",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        998.0,
                        438.0,
                        200.0,
                        22.0
                    ],
                    "text": "<- lit = hand in range",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-99",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        968.0,
                        478.0,
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
                    "id": "obj-100",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        968.0,
                        510.0,
                        70.0,
                        22.0
                    ],
                    "text": "s tr.osc"
                }
            },
            {
                "box": {
                    "id": "obj-101",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        968.0,
                        554.0,
                        280.0,
                        58.0
                    ],
                    "text": "Set min pitch just below your FULL LEFT\n(or RIGHT) pitch. Pulling the hand away\n(zero-beat) should turn the light off.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-102",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1276.0,
                        142.0,
                        300.0,
                        690.0
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
                    "id": "obj-103",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1284.0,
                        150.0,
                        280.0,
                        25.0
                    ],
                    "text": "5. PEDALS  (stationary bike)",
                    "fontsize": 15.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-104",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1284.0,
                        176.0,
                        280.0,
                        40.0
                    ],
                    "text": "Sends /bike/cadence (RPM). Sensor not built yet.\nWhile OFF the game uses the controller A button.",
                    "fontsize": 12.0,
                    "textcolor": [
                        0.85,
                        0.85,
                        0.85,
                        1.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-105",
                    "maxclass": "toggle",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        226.0,
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
                    "id": "obj-106",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1324.0,
                        226.0,
                        200.0,
                        22.0
                    ],
                    "text": "SEND PEDAL DATA",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-107",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        270.0,
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
                    "id": "obj-108",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1364.0,
                        270.0,
                        180.0,
                        22.0
                    ],
                    "text": "<- 20 updates per second",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-109",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1284.0,
                        314.0,
                        280.0,
                        22.0
                    ],
                    "text": "(a) TEST: drag to fake pedalling (0-150 RPM)",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-110",
                    "maxclass": "slider",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        338.0,
                        200.0,
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
                    "id": "obj-111",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1494.0,
                        338.0,
                        64.0,
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
                    "id": "obj-112",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1284.0,
                        382.0,
                        280.0,
                        58.0
                    ],
                    "text": "(b) SENSOR: bang 'pulse in' once per crank\nturn (e.g. Arduino reed switch -> [serial]\n-> [sel 1] -> here). Pulse timing -> RPM.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-113",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        442.0,
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
                    "id": "obj-114",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1314.0,
                        442.0,
                        100.0,
                        22.0
                    ],
                    "text": "<- pulse in",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-115",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1284.0,
                        474.0,
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
                    "id": "obj-116",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1404.0,
                        474.0,
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
                    "id": "obj-117",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "patching_rect": [
                        1284.0,
                        506.0,
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
                    "id": "obj-118",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1404.0,
                        506.0,
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
                    "id": "obj-119",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1444.0,
                        506.0,
                        130.0,
                        22.0
                    ],
                    "text": "<- no pulse for 2 s = stopped",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-120",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 2,
                    "patching_rect": [
                        1284.0,
                        538.0,
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
                    "id": "obj-121",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1404.0,
                        538.0,
                        170.0,
                        22.0
                    ],
                    "text": "<- drop bounces / first pulse",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-122",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1284.0,
                        570.0,
                        140.0,
                        22.0
                    ],
                    "text": "pulses per crank turn",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-123",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1424.0,
                        570.0,
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
                    "id": "obj-124",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1462.0,
                        570.0,
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
                    "id": "obj-125",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        1516.0,
                        570.0,
                        56.0,
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
                    "id": "obj-126",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        602.0,
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
                    "id": "obj-127",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        634.0,
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
                    "id": "obj-128",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1284.0,
                        678.0,
                        280.0,
                        22.0
                    ],
                    "text": "Latest RPM (from a or b), sent while ON:",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-129",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        702.0,
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
                    "id": "obj-130",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "patching_rect": [
                        1334.0,
                        702.0,
                        64.0,
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
                    "id": "obj-131",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1284.0,
                        734.0,
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
                    "id": "obj-132",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1284.0,
                        766.0,
                        70.0,
                        22.0
                    ],
                    "text": "s tr.osc"
                }
            },
            {
                "box": {
                    "id": "obj-133",
                    "maxclass": "panel",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1592.0,
                        142.0,
                        300.0,
                        690.0
                    ],
                    "bgcolor": [
                        0.26,
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
                    "id": "obj-134",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1600.0,
                        150.0,
                        280.0,
                        25.0
                    ],
                    "text": "6. TO GODOT",
                    "fontsize": 15.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-135",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1600.0,
                        176.0,
                        280.0,
                        40.0
                    ],
                    "text": "Everything sent to tr.osc goes out over UDP\nas OSC. Port must match the game (9100).",
                    "fontsize": 12.0,
                    "textcolor": [
                        0.85,
                        0.85,
                        0.85,
                        1.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-136",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "patching_rect": [
                        1600.0,
                        226.0,
                        70.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "r tr.osc"
                }
            },
            {
                "box": {
                    "id": "obj-137",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1600.0,
                        270.0,
                        280.0,
                        40.0
                    ],
                    "text": "Same PC: 127.0.0.1. Other PC: edit the\nhost box to the game PC's IP, then click it.",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-138",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1600.0,
                        314.0,
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
                    "id": "obj-139",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1730.0,
                        314.0,
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
                    "id": "obj-140",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1600.0,
                        354.0,
                        168.0,
                        22.0
                    ],
                    "text": "udpsend 127.0.0.1 9100"
                }
            },
            {
                "box": {
                    "id": "obj-141",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1600.0,
                        410.0,
                        280.0,
                        22.0
                    ],
                    "text": "DEBUG: print what's sent to the Max console",
                    "fontsize": 12.0,
                    "fontface": 1
                }
            },
            {
                "box": {
                    "id": "obj-142",
                    "maxclass": "toggle",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        1600.0,
                        434.0,
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
                    "id": "obj-143",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1630.0,
                        434.0,
                        200.0,
                        22.0
                    ],
                    "text": "<- on = print (very chatty)",
                    "fontsize": 12.0
                }
            },
            {
                "box": {
                    "id": "obj-144",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "patching_rect": [
                        1600.0,
                        470.0,
                        56.0,
                        22.0
                    ],
                    "outlettype": [
                        ""
                    ],
                    "text": "gate 1"
                }
            },
            {
                "box": {
                    "id": "obj-145",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1600.0,
                        502.0,
                        98.0,
                        22.0
                    ],
                    "text": "print tr.osc"
                }
            },
            {
                "box": {
                    "id": "obj-146",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        1600.0,
                        558.0,
                        280.0,
                        112.0
                    ],
                    "text": "Messages the game understands:\n/bike/steer f          -1..1\n/bike/steer/present i  1 or 0\n/bike/cadence f        RPM\n/bike/pedal            one per stroke\n(see docs/OSC_PROTOCOL.md)",
                    "fontsize": 12.0
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "source": [
                        "obj-7",
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
                        "obj-7",
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
                        "obj-13",
                        0
                    ],
                    "destination": [
                        "obj-14",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-14",
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
                        "obj-14",
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
                        "obj-7",
                        0
                    ],
                    "destination": [
                        "obj-20",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-20",
                        0
                    ],
                    "destination": [
                        "obj-21",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-20",
                        0
                    ],
                    "destination": [
                        "obj-23",
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
                        "obj-34",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-34",
                        0
                    ],
                    "destination": [
                        "obj-36",
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
                        "obj-33",
                        0
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
                        "obj-36",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-36",
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
                        "obj-45",
                        0
                    ],
                    "destination": [
                        "obj-47",
                        0
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
                        "obj-44",
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
                        "obj-44",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-44",
                        0
                    ],
                    "destination": [
                        "obj-47",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-47",
                        0
                    ],
                    "destination": [
                        "obj-49",
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
                        "obj-56",
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
                        "obj-58",
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
                        "obj-55",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-53",
                        0
                    ],
                    "destination": [
                        "obj-55",
                        1
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
                        "obj-58",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-58",
                        0
                    ],
                    "destination": [
                        "obj-60",
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
                        "obj-69",
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
                        "obj-69",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-67",
                        0
                    ],
                    "destination": [
                        "obj-69",
                        2
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
                        "obj-69",
                        3
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-69",
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
                        "obj-76",
                        0
                    ],
                    "destination": [
                        "obj-74",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-74",
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
                        "obj-71",
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
                        "obj-75",
                        0
                    ],
                    "destination": [
                        "obj-77",
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
                        "obj-77",
                        2
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
                        "obj-78",
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
                        "obj-80",
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
                        "obj-82",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-95",
                        0
                    ],
                    "destination": [
                        "obj-90",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-95",
                        0
                    ],
                    "destination": [
                        "obj-93",
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
                        "obj-93",
                        0
                    ],
                    "destination": [
                        "obj-94",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-86",
                        0
                    ],
                    "destination": [
                        "obj-96",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-87",
                        0
                    ],
                    "destination": [
                        "obj-96",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-91",
                        0
                    ],
                    "destination": [
                        "obj-96",
                        2
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-94",
                        0
                    ],
                    "destination": [
                        "obj-96",
                        3
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-96",
                        0
                    ],
                    "destination": [
                        "obj-97",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-96",
                        0
                    ],
                    "destination": [
                        "obj-99",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-99",
                        0
                    ],
                    "destination": [
                        "obj-100",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-105",
                        0
                    ],
                    "destination": [
                        "obj-107",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-110",
                        0
                    ],
                    "destination": [
                        "obj-111",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-113",
                        0
                    ],
                    "destination": [
                        "obj-115",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-115",
                        1
                    ],
                    "destination": [
                        "obj-117",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-115",
                        0
                    ],
                    "destination": [
                        "obj-117",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-115",
                        0
                    ],
                    "destination": [
                        "obj-116",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-116",
                        0
                    ],
                    "destination": [
                        "obj-118",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-117",
                        0
                    ],
                    "destination": [
                        "obj-120",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-125",
                        0
                    ],
                    "destination": [
                        "obj-123",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-123",
                        0
                    ],
                    "destination": [
                        "obj-124",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-120",
                        0
                    ],
                    "destination": [
                        "obj-126",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-124",
                        0
                    ],
                    "destination": [
                        "obj-126",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-126",
                        0
                    ],
                    "destination": [
                        "obj-127",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-107",
                        0
                    ],
                    "destination": [
                        "obj-129",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-110",
                        0
                    ],
                    "destination": [
                        "obj-129",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-127",
                        0
                    ],
                    "destination": [
                        "obj-129",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-118",
                        0
                    ],
                    "destination": [
                        "obj-129",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-129",
                        0
                    ],
                    "destination": [
                        "obj-130",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-129",
                        0
                    ],
                    "destination": [
                        "obj-131",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-131",
                        0
                    ],
                    "destination": [
                        "obj-132",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-136",
                        0
                    ],
                    "destination": [
                        "obj-140",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-138",
                        0
                    ],
                    "destination": [
                        "obj-140",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-139",
                        0
                    ],
                    "destination": [
                        "obj-140",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-142",
                        0
                    ],
                    "destination": [
                        "obj-144",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-136",
                        0
                    ],
                    "destination": [
                        "obj-144",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-144",
                        0
                    ],
                    "destination": [
                        "obj-145",
                        0
                    ]
                }
            }
        ],
        "autosave": 0,
        "parameters": {
            "obj-9": [
                "monitor_gain",
                "monitor",
                0
            ],
            "inherited_shortname": 1
        }
    }
}