# sims ("Step Into My Shoes")

sims is a Godot 4.6 game project — `project.godot` declares the engine version (Godot 4.6, Forward Plus) and a window of 1280x720. The main scene is `res://scenes/main_hub.tscn`. The project is organized into `scenes/`, `scripts/` (with autoloads: `GameState`, `ObjectiveManager`, `JuiceManager`, `AudioManager`), `player/`, `npc/`, `portals/`, `ui/`, `ARC/`, and `assets/` (with `.import` files for textures/audio).

## Build / Test / Lint Commands

- Install: Godot 4.6 (download from godotengine.org)
- Build: open the project in Godot Editor (`godot -e --path .`); the editor will compile/import assets automatically
- Test: Godot's built-in GUT/GDTest can be run from the editor; there is no headless test harness wired in this repo
- Lint: not configured (consider `gdlint` for GDScript)
- Dev / run: `godot --path .` (or `godot --path . res://scenes/main_hub.tscn` to launch the hub directly)

## Code Style Rules

- Language/version: GDScript on Godot 4.6 (Forward Plus renderer)
- Paradigm: scene-tree based; autoloaded singletons (see `project.godot` `[autoload]` section) provide cross-scene state
- Types: GDScript with static typing (`var x: int = ...`) is the convention to prefer
- Formatting: tabs (Godot convention) — match existing `.gd` files; PascalCase for nodes, snake_case for variables/functions
- Imports / module style: `class_name` for cross-script references; `preload()` for resources; `load("res://...")` for assets
- Dependencies: Godot 4.6 standard library; no external plugins detected in `project.godot`

## Verification Criteria

Before claiming any task done, Claude MUST:
1. Open the project in Godot 4.6 Editor and confirm the project loads with no parse errors.
2. Run `godot --headless --check-only --path .` if available, or verify the project from the editor's Project Settings.
3. Launch the main scene (`godot --path . res://scenes/main_hub.tscn`) and confirm it opens without errors in the Output panel.
4. Report the exact commands run and their outcomes in the final message.
