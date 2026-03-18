# Architecture Overview - Career Quest Game

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      GAME STARTUP                                │
│                                                                   │
│  project.godot → main_menu.tscn → main_hub.tscn → worlds        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    AUTOLOAD SINGLETONS                           │
│                                                                   │
│  GameManager (Global State)      AudioManager (Sound System)    │
│  ├─ Career Completion Status      ├─ SFX Players (8 concurrent) │
│  ├─ Score Tracking                ├─ Music Player              │
│  ├─ Total Progress                ├─ Sound Library             │
│  ├─ Pause State                   └─ Volume Controls           │
│  └─ Save/Load System                                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      MAIN MENU SCENE                             │
│                                                                   │
│  ┌──────────────────────────────────┐                           │
│  │   CAREER QUEST                   │                           │
│  │   [Play New Game]                │ → Resets GameManager      │
│  │   [Continue Game]                │ → Loads saved progress    │
│  │   [Settings]                     │ → Placeholder             │
│  │   [Quit]                         │ → Exits to desktop        │
│  └──────────────────────────────────┘                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      MAIN HUB SCENE                              │
│                                                                   │
│  ┌──────────────────────────────┐                               │
│  │  Progress: XX%               │ ← Updated from GameManager   │
│  │  Total Score: XXX            │ ← Updated from GameManager   │
│  │                              │                               │
│  │  [Software Engineer Portal]  │                               │
│  │  [Doctor Portal]             │                               │
│  │  [Lawyer Portal]             │                               │
│  │  [Civil Engineer Portal]     │                               │
│  │  [Soccer Player Portal]      │                               │
│  └──────────────────────────────┘                               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   CAREER WORLD SCENES                            │
│                                                                   │
│  Each World Has:                                                 │
│  ├─ Player (enhanced_player.gd)                                 │
│  │  └─ Controls with pause support                             │
│  ├─ WorldUI (enhanced_world_ui.gd)                             │
│  │  └─ Shows objectives, status, progress                     │
│  ├─ Objectives/Tasks                                           │
│  │  └─ Software: Fix 3 bugs                                   │
│  │  └─ Doctor: Diagnose 3 patients                            │
│  │  └─ Lawyer: Collect 3 evidence pieces                      │
│  │  └─ Engineer: Rotate 3 blocks                              │
│  │  └─ Soccer: Score 3 of 5 penalties                         │
│  ├─ Return Portal                                              │
│  │  └─ Glows when level complete                              │
│  └─ PauseMenu (pause_menu.gd)                                 │
│     └─ Opened with ESC key                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    PAUSE MENU SCENE                              │
│                                                                   │
│  Appears when ESC pressed:                                       │
│  ┌──────────────────────────────┐                               │
│  │        PAUSED                │                               │
│  │   [Resume Game]              │ → Continue from where paused │
│  │   [Return to Menu]           │ → Go to main menu            │
│  │   [Settings]                 │ → Placeholder               │
│  │   [Quit Game]                │ → Exit to desktop            │
│  └──────────────────────────────┘                               │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    CAREER COMPLETION                          │
│                                                               │
│  Player completes objective in world                          │
│           ↓                                                   │
│  World script calls:                                          │
│  GameManager.mark_career_complete("Career", score)          │
│           ↓                                                   │
│  GameManager:                                                │
│  ├─ Sets careers_completed["Career"] = true                 │
│  ├─ Sets career_scores["Career"] = score                   │
│  ├─ Updates total_score += score                            │
│  ├─ Calls save_progress()                                  │
│  └─ Emits score_changed signal                             │
│           ↓                                                   │
│  Main Hub UI updates:                                        │
│  ├─ Progress percentage increases                           │
│  └─ Total score increases                                   │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                     PAUSE SYSTEM                              │
│                                                               │
│  Player presses ESC                                          │
│           ↓                                                   │
│  Player script detects: Input.is_action_just_pressed("...")  │
│           ↓                                                   │
│  Calls: GameManager.toggle_pause()                          │
│           ↓                                                   │
│  GameManager:                                                │
│  ├─ Toggles is_paused flag                                 │
│  ├─ Calls get_tree().paused = is_paused                   │
│  └─ Emits paused_changed signal                            │
│           ↓                                                   │
│  PauseMenu hears signal and becomes visible                 │
│           ↓                                                   │
│  Player clicks "Resume"                                      │
│           ↓                                                   │
│  toggle_pause() called again → Game resumes                 │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                  AUDIO PLAYBACK                              │
│                                                               │
│  World script calls:                                         │
│  AudioManager.play_sfx("success")                           │
│           ↓                                                   │
│  AudioManager:                                              │
│  ├─ Finds available SFX player (max 8 concurrent)          │
│  ├─ Loads sound from sfx_library Dictionary                │
│  └─ Plays it                                               │
│           ↓                                                   │
│  Sound plays through assigned bus (SFX)                     │
│           ↓                                                   │
│  User can control volume via:                               │
│  ├─ Audio bus "SFX" in mixer                               │
│  └─ GameManager.set_sfx_volume()                           │
└──────────────────────────────────────────────────────────────┘
```

## Scene Hierarchy Example

```
MainHub (Node3D)
├── WorldEnvironment
├── DirectionalLight
├── Player
│   └── Camera3D
├── Portal (Software Engineer)
├── Portal (Doctor)
├── Portal (Lawyer)
├── Portal (Engineer)
├── Portal (Soccer)
├── ProgressUI (CanvasLayer)
│   ├── ProgressLabel
│   └── ScoreLabel
└── PauseMenu (CanvasLayer) [ADDED]
    └── PanelContainer
        └── VBoxContainer
            ├── Label (PAUSED)
            ├── Button (Resume)
            ├── Button (Menu)
            ├── Button (Settings)
            └── Button (Quit)

SoftwareEngineerWorld (Node3D) [Example]
├── Player [Uses enhanced_player.gd]
│   └── Camera3D
├── WorldUI [Uses enhanced_world_ui.gd] (CanvasLayer)
│   ├── ObjectiveLabel
│   └── StatusLabel
├── Bug1-3 (Area3D)
├── ReturnPortal
└── PauseMenu (CanvasLayer) [ADDED]
    └── [Same structure as hub]
```

## Signal Connections

```
GameManager Signals:
├─ paused_changed()
│  └─ Connected to: PauseMenu._on_pause_toggled()
│
└─ score_changed()
   └─ Connected to: [Future leaderboard systems]

Audio Bus System:
├─ Master
│  ├─ Music
│  │  └─ current_music (AudioStreamPlayer)
│  │
│  └─ SFX
│     └─ sfx_players[] (8 AudioStreamPlayers)
```

## World Completion Flow

```
┌─────────────────────────┐
│   World Starts          │
│ ├─ Sets objective text  │
│ ├─ Hides return portal  │
│ └─ Starts tasks         │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   Player Does Tasks     │
│ ├─ Complements feedback │
│ ├─ Plays sounds         │
│ └─ Updates progress     │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   All Tasks Complete    │
│ ├─ Portal becomes live  │
│ ├─ Portal glows         │
│ ├─ Mark in GameManager  │
│ └─ Update score         │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   Player Walks to Gate  │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   Portal.body_entered() │
│   Triggers scene change │
│   → Returns to MainHub  │
└─────────────────────────┘
```

---

**This architecture ensures:**
- ✅ Centralized state management
- ✅ Efficient audio handling
- ✅ Consistent pause behavior across all worlds
- ✅ Proper progress tracking
- ✅ Extensible systems for future features
