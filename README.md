# Career Quest Game - Complete Godot Project

A 3D career exploration game built with Godot 4. Players navigate through different profession worlds and complete skill-based challenges.

## Game Overview

**Main Hub**: A central meeting point with 5 career portals. Navigate the pavilion and choose which career path to explore.

### Career Worlds

#### 1. **Software Engineer World** - Server Debugging
- **Objective**: Fix 3 server bugs before the system crashes
- **Gameplay**: Walk around the office, find glowing bug indicators, press [Space] to fix them
- **Difficulty**: EASY → MODERATE
- **Skills**: Exploration, quick reflexes
- **Environment**: Modern tech office with desks, servers, whiteboards

#### 2. **Lawyer World** - Evidence Collection & Court Defense
- **Objective**: Collect 3 pieces of evidence, then present your case in court
- **Gameplay**: 
  - Explore the courthouse, find and collect evidence (glowing spheres)
  - Walk to the judge's platform when ready to present
  - Successfully defend your client with all evidence collected
- **Difficulty**: EASY → MODERATE
- **Skills**: Exploration, spatial awareness, memory
- **Environment**: Classic courtroom with judge's bench, witness stand, bookshelves

#### 3. **Doctor World** - Patient Diagnosis
- **Objective**: Diagnose 3 patients correctly
- **Gameplay**:
  - Visit each patient (glowing spheres scattered around the clinic)
  - Read their symptom and choose the correct diagnosis from 3 options using **1/2/3** keys
  - Achieve 3/3 correct diagnoses (or as many as possible)
- **Difficulty**: MODERATE (needs medical knowledge)
- **Skills**: Problem-solving, decision-making, reading comprehension
- **Environment**: Hospital clinic with operating table, surgical lights, cabinets, equipment

#### 4. **Civil Engineer World** - Block Building
- **Objective**: Rotate 3 building blocks to match the blueprint
- **Gameplay**:
  - Approach each block (A, B, C)
  - Press [Space] to rotate it 90 degrees
  - Match each block to its target rotation shown in the objective
  - Complete the building construction
- **Difficulty**: MODERATE → HARD (timing and spatial reasoning)
- **Skills**: Spatial awareness, pattern recognition, fine control
- **Environment**: Large construction site with bridge, cranes, scaffolding, building blocks

#### 5. **Soccer Player World** - Penalty Shootout
- **Objective**: Score 3 out of 5 penalty kicks
- **Gameplay**:
  - Walk to the penalty ball (yellow sphere)
  - Press [Space] to shoot
  - Ball travels in a direction with slight randomness to the goal
  - Complete 5 shots and score at least 3 to win
- **Difficulty**: MODERATE → HARD (luck + precision)
- **Skills**: Timing, prediction, dealing with randomness
- **Environment**: Outdoor soccer pitch with goal area, ball physics

---

## Difficulty Progression

| World | Difficulty | Why |
|-------|-----------|-----|
| Software Engineer | Easy | Simple exploration, clear targets |
| Lawyer | Easy-Moderate | More exploration needed, but straightforward task |
| Doctor | Moderate | Requires knowledge; 3 diagnosis challenges |
| Civil Engineer | Moderate-Hard | Spatial reasoning required; rotation mechanics |
| Soccer | Moderate-Hard | Random ball physics, needs 60% success rate |

---

## Controls

### General
- **WASD**: Move forward/backward/left/right
- **Mouse**: Look around (captured on start)
- **ESC**: Release mouse (developer mode)

### World-Specific
- **[Space]**: Interact (fix bugs, collect evidence, shoot penalty, rotate blocks)
- **1/2/3**: Select diagnosis choice in Doctor world
- **[Space]** (on Portal): Return to Main Hub

---

## Project Structure

```
/workspaces/sims/
├── scenes/
│   ├── main_hub.tscn          # Main hub world
│   ├── software_engineer_world.tscn  # Software world
│   ├── lawyer_world.tscn       # Lawyer world
│   ├── doctor_world.tscn       # Doctor world
│   ├── civil_engineer_world.tscn     # Civil engineer world
│   ├── politician_world.tscn   # Soccer world (renamed from politician)
│   ├── world_ui.gd            # Shared UI system for all worlds
│   ├── software_world.gd       # Software world logic
│   ├── lawyer_world.gd         # Lawyer world logic
│   ├── doctor_world.gd         # Doctor world logic
│   ├── civil_world.gd          # Civil engineer world logic
│   └── soccer_world.gd         # Soccer world logic
├── player/
│   ├── player.tscn            # Player character scene
│   └── player.gd              # Player controller (movement + camera)
├── portals/
│   ├── portal.tscn            # Teleport portal scene
│   └── portal.gd              # Portal teleportation logic
└── .git/                       # Git repository
```

---

## Technical Details

### Player System
- **CharacterBody3D** with gravity simulation
- First-person camera (smooth look with mouse sensitivity)
- Physics-based movement and jumping
- Added to "player" group for detection by worlds

### Portal System
- **Area3D** based teleportation
- Detects player collision and switches scenes
- Configurable target scenes via `target_scene` property

### World UI System
- **CanvasLayer** for overlay text
- Objective display (persistent task description)
- Status display (temporary messages with fade-out)
- Used by all 5 worlds for feedback

### Physics
- Gravity: 9.8 m/s² (Godot default)
- Soccer ball: RigidBody3D with bounce physics
- Proper collision shapes on all interactive objects

### Visual Effects
- **Bloom** enabled on all environments for polished look
- Reflection probes for realistic surfaces
- Directional sunlight with shadows
- Emissive materials for glowing UI elements and bugs

---

## World Themes & Colors

| World | Sky Color | Ground | Accent Color | Vibe |
|-------|-----------|--------|--------------|------|
| Main Hub | Bright Blue | Green Grass | Gold Marble | Classic |
| Software | Dark Blue | Dark Gray | Cyan (emission) | Tech |
| Lawyer | Dark Brown | Dark Wood | Red-Brown | Traditional |
| Doctor | Pale Gray | White/Mint | Bright Lights | Sterile |
| Civil | Daylight Blue | Dirt Brown | Concrete Gray | Industrial |
| Soccer | Bright Sky | Green Field | Yellow Ball | Athletic |

---

## Difficulty Breakdown

### Easy (Software, Lawyer early)
- Large interactive areas
- Clear visual feedback (glowing objects)
- Simple mechanics (collect, fix, present)
- Generous time windows

### Moderate (All midgame, Doctor)
- Requires learning (diagnosis options)
- Precise positioning needed
- Multiple steps required
- 60-70% success threshold

### Hard (Civil, Soccer)
- Spatial reasoning required (block rotation)
- Random elements (ball physics)
- Timing-based (penalty shootout)
- 50-60% success threshold

---

## How to Run

1. **Open Godot 4.x**
2. **Import Project**: Point to `/workspaces/sims/`
3. **Open Scene**: Open `scenes/main_hub.tscn`
4. **Run**: Press **F5** or click **Play**
5. **Explore**: Use WASD + Mouse to navigate
6. **Enter Worlds**: Walk into glowing portals
7. **Complete Tasks**: Follow on-screen objectives
8. **Return**: Use return portals to go back to hub

---

## Notes

- Each world is **independent** and can be played in any order
- Objectives and status messages guide the player
- All assets are **procedurally generated** (no external 3D models)
- Game uses **Godot 4.x GDScript** with modern async/await patterns
- All portals use **scene transitions** for seamless loading

---

## Educational Value

This game demonstrates:
- First-person character controller
- 3D scene management and portals
- Physics-based interactions (ball throwing)
- UI overlay systems
- Event-driven gameplay
- Asset-light design (procedural geometry)
- Proper Godot 4 best practices
- Career diversity education

---

**Made with Godot 4**
