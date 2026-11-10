# CLAUDE.md: working on Theremin Rider

Read `docs/HANDOFF.md` first. It covers current state, architecture and next steps.

## Engine and commands
- Godot **4.7.2**. CLI binary: `D:\Godot_v4.7.2-stable_win64_console.exe`.
- After any change, run both and report the results:
  - `--headless --path . --import` (must exit 0 with no `SCRIPT ERROR` / `Parse Error`)
  - `--headless --path . --fixed-fps 60 res://scenes/test/smoke_test.tscn` (must exit 0)
- To visually check, run `res://scenes/test/screenshots.tscn` windowed and look at `docs/screenshots/*.png`. Say what you did and did not look at.

## Conventions
- Typed GDScript, Godot 4 API only.
- **No gameplay numbers in logic.** Every tunable is an `@export` on `BikeTuning` / `InputTuning` / `RoadTuning` (with `@export_range` and a `##` doc comment). Visual-only geometry constants in `bike_model.gd` are fine.
- **Input is read only through the `RiderInput` autoload** (`steer`, `cadence_rpm`, `hand_present`). Don't read OSC or `Input` axes in gameplay code.
- **Colours only through `Palette`** (`Palette.mat(id)`, `Palette.color(id)`).
- The game drives the bike via `bike.step()`; keep that order explicit.
- Collisions are road-space (s, lateral). Don't add physics bodies unless you're deliberately changing that design; if you do, write it up in HANDOFF.
- Tests set `Game.record_scores = false`. Never let a test write the player's save file.
- Don't hand-edit `.godot/` or delete `.uid` files.

## Docs to update with every change
- `docs/CHANGELOG.md`: an entry with what changed and what you verified.
- `docs/TUNING.md` for new or changed tunables, `docs/CONTROLS.md` for input, and `docs/OSC_PROTOCOL.md` and `docs/MAX_SETUP.md` for anything touching Max/OSC.
- `docs/KNOWN_ISSUES.md`: append, don't delete.
- `docs/HANDOFF.md` § 2 "State right now" and § 5 "Next steps".

## Git
- Commit with clear messages (`feat:`, `fix:`, `tune:`, `docs:`) and push to `origin`.
- Never force-push.
