<!-- idioma: linha gerada por i18n.py -->
> [!NOTE]
> ### 🇧🇷 **[Leia esta página em português →](README.pt-BR.md)**

# Relativity Paradox — Interactive Teaching Instrument

> *Relativity is not difficult because of the math — it is difficult because it forces you to switch world models. This tool does not deduce the result on a blackboard: it makes the student **switch reference frames with their own body** and see the world reconfigure in front of them.*

> An interactive first-person experience designed for live presentation, intended to teach high school students about the paradoxes of Special Relativity through a theatrical demonstration led by a guide.

---

## Summary

1. [Project Overview](#1-visão-geral-do-projeto)  
2. [Scientific Foundation](#2-fundamentação-científica)  
3. [Selected Paradoxes](#3-paradoxos-selecionados)  
4. [Presentation Architecture](#4-arquitetura-da-apresentação)  
5. [Technical Stack](#5-stack-técnica)  
6. [Project Structure](#6-estrutura-do-projeto)  
7. [Central Systems](#7-sistemas-centrais)  
8. [Visual Guidelines](#8-diretrizes-visuais)  
9. [Development Roadmap](#9-roadmap-de-desenvolvimento)  
10. [Execution Principles](#10-princípios-de-execução)  
11. [Code Conventions](#11-convenções-de-código)  
12. [Technical Glossary](#12-glossário-técnico)  
13. [References](#13-referências)

---

## 1. Project Overview

### 1.1 Nature of the Project

This is **not a game in the traditional sense**. It is an **interactive teaching instrument**: a software tool operated live by a guide/teacher, while the audience (high school students) watches on a large screen. The correct mental model is that of a *portable relativity planetarium* or a *modern scientific experiment* — analogous to Faraday's demonstrations in the 19th century, modernized.

### 1.2 Presentation Format

- **Duration**: 20 minutes  
- **Audience**: High school students (~14-17 years old)  
- **Operator**: A single teacher/guide conducting  
- **Control**: Xbox gamepad (not keyboard/mouse during presentation)  
- **Screen**: Projector or large TV  
- **No internet dependency**: standalone executable

### 1.3 Design Philosophy

If the barrier is changing the world model, the most effective instrument is the one that makes the student *inhabit* a frame of reference at a time — not the one that compares two diagrams from the outside. Everything below follows from this:

- **Theater over simulation**: when exact physics clashes with visual clarity, visual clarity wins  
- **No heavy textual UI**: the instructor's voice replaces menus and tutorials  
- **Single strong mechanic**: the *change of reference frame* is the heart of the experience  
- **Controlled sandbox**: the instructor can pause, adjust, repeat, answer questions in real time  
- **Visual coherence**: 3D low-poly + pixel art sprites with unified palette

### 1.4 Pedagogical Objectives

At the end of the presentation, the student should have:

1. Abandoned **absolute simultaneity** as an intuitive concept  
2. Visually understood **Lorentz contraction**  
3. Recognized that rigid bodies **do not exist** in relativity  
4. Accepted that **apparent superluminal speeds** exist without violating causality  
5. Acknowledged that different descriptions of the same physical event can coexist consistently

---

## 2. Scientific Foundation

The conceptual content derives from a single reference article:

**Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxes of Relativity*. arXiv:2307.05503v1 [physics.pop-ph]. UFC.

Equations implemented in `scripts/lorentz_transform.gd` (quick reference to the code):

| Magnitude | Equation |
|---|---|
| Lorentz Factor | γ = 1 / √(1 − v²/c²) |
| Lorentz Contraction | L = L₀ / γ |
| Simultaneity Offset | Δt' = γ·L₀·v/c² |
| Cutting Point Speed (scissors) | v = ω·L·csc²(θ) |

> **Physical and Bibliographic Deepening** — derivation of equations, complete Lorentz transformations, the concepts that the student should *feel*, the Galilean conceptions to abandon, the glossary, and the academic bibliography are in [`FUNDAMENTACAO-CIENTIFICA.md`](FUNDAMENTACAO-CIENTIFICA.en.md). Here, only the technical core necessary for the code is maintained.

---

## 3. Selected Paradoxes

Of the seven paradoxes in the reference article, **two** are included in the presentation. Detailed physical resolution, pedagogical justification, and sections/pages of the article: [`FUNDAMENTACAO-CIENTIFICA.md §5`](FUNDAMENTACAO-CIENTIFICA.md#5-os-paradoxos-em-detalhe).

### 3.1 Main — The Relativistic Lumberyard

Torus (proper length `L₀`) slides over the conveyor at `v`; two guillotines separated by `L₀` descend. In **Alice**, the torus is contracted (`L₀/γ`) and passes through; in **Bob**, it has its proper size and "wouldn't fit" — resolved because, in Bob, the guillotines are not simultaneous (`Δt' = γ·L₀·v/c²`).

- **Implementation**: `frame_controller.gd`, `esteira.gd`, `guillotine.gd`, `tora.gd`  
- **Status**: ✅ implemented (Acts 0-3) · ~14 min

### 3.2 Climax — Superluminal Scissors

The intersection point of two blades can exceed `c` (`v = ω·L·csc²θ`) without violating causality — since it is not a material object, it does not carry information.

- **Planned Implementation**: `scissors.gd`, `observatorio.tscn`  
- **Status**: ⬜ pending (Week 5, Act 4) · ~3 min

### 3.3 Out of Scope

Bar-and-Slit 2D (discarded due to conceptual setup cost) and Bar-and-Slit with gravity (future expansion / TCC) — documented in the foundation.

---

## 4. Presentation Architecture

### 4.1 Narrative Structure (20 minutes)

#### **Act 0 — Presentation of the Galilean World** (2 min)

- Scene opens slowly in the lumberyard  
- Conveyor belt stopped, log stopped, guillotines stopped  
- Guide walks in first person, establishes dimensions  
- Starts the conveyor belt at **low speed** (0.05c)  
- Log passes, is cut normally  
- **Function**: establish Galilean normality before the break

#### **Act 1 — The Acceleration** (5 min)

- Guide increases conveyor belt speed (D-Pad Up)  
- v = 0.3c → 0.5c → 0.7c  
- Lorentz contraction becomes visible  
- v = 0.9c: beam passes through guillotines with clear margin  
- Audience accepts: "ok, it passed"

#### **Act 2 — The Paradox** (6 min)

- "What if I got on the treadmill?"  
- **Frame of Reference Change** (Left Bumper — LB)  
- Animated transition of ~2 seconds  
- World reconfigures: log returns to L₀, shed and guillotines contract  
- The log **does not fit** between the guillotines  
- Cliffhanger: "it should be cut — but you saw it pass"

#### **Act 3 — Resolution by Simultaneity** (4 min)

- Activation of **overlay mode** (Button Y)  
- Lines of simultaneity appear as pixel art sprites  
- Slow-motion replay (Button X)  
- In Bob's reference frame, guillotines descend at different times  
- Right guillotine first → beam follows → left guillotine later (beam already out)  
- Return to Alice's reference frame: everything is simultaneous  
- Message: "what changes is not what happens. It's what 'at the same time' means."

#### **Act 4 — Cosmic Climax (Scissors)** (3 min)

- Transition to second scenario (cosmic observatory, night palette)  
- Two blades crossing  
- Instructor manipulates angle  
- Cut-off speedometer: 0.5c → 0.9c → c → 2c → 10c  
- Visualization of light cone showing that causality is preserved  
- Closure

### 4.2 Xbox Control Mapping

| Input | Function |
|---|---|
| Left Analog | Movement (WASD) |
| Right Analog | Look (mouse look) |
| Left Bumper (LB) | **Change reference frame** |
| D-Pad ↑ | Increase conveyor speed |
| D-Pad ↓ | Decrease conveyor speed |
| Right Trigger (RT) | Activate guillotines / Main action |
| Button Y | Toggle overlay (lines of simultaneity) |
| Button X | Pause / Slow motion |
| Button B | Reset scene |
| Button View | Toggle isometric view / first person |
| Menu Button | Next scene (Saws) |

> Each action also has an equivalent keyboard shortcut (WASD to move, Q to switch reference frame, E/Z for speed, Space for action, O for overlay, P for slow motion, R for reset, V for view, N for next scene) for development. The keyboard is not used during the presentation.

---

## 5. Technical Stack

### 5.1 Confirmed Technologies

- **Engine**: Godot 4.x
- **Language**: GDScript
- **Target Platforms**: Windows and Linux (standalone executable on both)
- **Development Environment**: AlmaLinux 9.8 (GNOME X11) — primary development
- **Control**: Xbox Gamepad (natively tested in Godot 4)
- **Versioning**: Git
- **3D Asset Generation**: Hyper3D.ai (Rodin) — export in GLB
- **Characters and Animations**: KayKit (Kay Lousberg, kaylousberg.com) — CC0; Adventurers 2.0 FREE + Character Animations 1.1 (Rig_Medium), extracted in `assets/models/characters/` (original zips in `assets/packages/`, out of versioning)
- **2D Asset Generation**: PixelLab.ai — pixel art for sprites
- **Audio Pipeline**: to be defined (Freesound, own generation)

### 5.2 Architectural Decisions

**Implementation of Lorentz Contraction**: **Path A — Logical Contraction** (not shader-based)  
- Two representations of the world (reference frame S and S')  
- When switching frames, animate transition between pre-calculated states  
- Simpler, more predictable, sufficient for the show  
- Path B (shaders) discarded to avoid two weeks of debugging

**Speed of light in the game**: `C = 1.0` unit/second

**World scale**:  
- Warehouse: ~20 units of length  
- Tora: 4 units (proper length L₀)  
- Distance between guillotines: 4 units (proper length L₀)  
- Maximum visually used speed: 0.99c

### 5.3 Cross-Platform Compatibility (Strict Constraint)

The final executable should run on **Windows and Linux** without modifications. Presentations take place in schools (typically Windows); development occurs on AlmaLinux 9.8.

**Rules that apply to the code:**  
- **File paths**: use exclusively `res://`, `user://` and Godot APIs (`OS.get_user_data_dir()`, `ProjectSettings.globalize_path()`). Never use absolute file paths of the operating system.  
- **Asset names**: only ASCII characters without accents or spaces — Windows systems are case-insensitive and have character restrictions that Linux does not have.  
- **System calls** (`OS.execute`, `OS.shell_open`): only use if tested on both platforms.  
- **Export templates**: upon reaching Week 5, generate templates for `Windows Desktop` (.exe) and `Linux/X11` (.x86_64) from the same project.  
- **Xbox Gamepad**: works natively via XInput (Windows). On Linux, the **wired** controller works via SDL/xpad without configuration; the **wireless USB receiver (dongle)** requires the `xone` driver (DKMS) — install with `sudo bash setup-xbox-linux.sh` (AlmaLinux 9 / RHEL). No platform-specific code in Godot.

### 5.4 Development Environment

| Tool | Version | Installation |
|---|---|---|
| Godot 4 | 4.6.3 stable | Flatpak (user) — `godot4` |
| VS Code | 1.122.0 | Flatpak (user) — `code` |
| godot-tools | 2.6.1 | VS Code Extension |
| Claude Code | — | `~/.local/bin/claude` |
| Driver xone (Xbox dongle) | DKMS | `sudo bash setup-xbox-linux.sh` (deps: dkms, kernel-devel, git, cabextract) |

**Launcher**: `~/Desktop/Lab Relatividade.desktop` — opens Godot → waits for LSP (port 6005) → VS Code → terminal with Claude Code, all in the project directory. If the terminal with Claude is already open, focus the existing window instead of opening a new one.

**Flatpak Note**: VS Code and Godot run in separate sandboxes. Communication between them (opening a file in the external editor) uses the wrapper `~/.local/bin/godot4-vscode` via `flatpak-spawn --host`. The Language Server connects normally via localhost:6005.

---

## 6. Project Structure

```
ParadoxoRelatividade/
├── README.md                       # This file
├── .gitignore                      # Git ignore for Godot 4
├── project.godot                   # Main Godot file
├── setup-xbox-linux.sh             # Installs xone driver (Xbox dongle on Linux)
│
├── scenes/
│   ├── main.tscn                   # Root scene, game entry point
│   ├── world/
│   │   ├── galpao.tscn             # Sawmill scene (Acts 0-3)
│   │   ├── esteira.tscn            # Conveyor belt (physical belt, instances tora.tscn)
│   │   └── tora.tscn               # Reusable log (procedural CylinderMesh, L₀=4u)
│   └── player/
│       └── player.tscn             # First-person camera + movement
│   # observatorio.tscn (Act 4) — pending, Week 5
│
├── scripts/
│   ├── input_manager.gd            # Autoload InputBus: input abstraction
│   ├── game_state.gd               # Autoload GameState: global state
│   ├── player.gd                   # Movement, camera, and first-person embodiment
│   ├── frame_controller.gd         # Reference frame switching logic
│   ├── lorentz_transform.gd        # Relativistic calculations (γ, contraction, time offset)
│   ├── esteira.gd                  # Conveyor belt: physical belt (rollers + pulleys), instances tora.tscn
│   ├── conveyor_belt.gd            # Legacy — replaced by esteira.gd/esteira.tscn (to be removed in Week 5)
│   ├── tora.gd                     # Log: @export L₀, diameter; set_lorentz_scale(); cut into two halves
│   ├── guillotine.gd               # Guillotine behavior
│   ├── galpao.gd                   # Scene: HDRI skydome, WorldEnvironment, stylized lighting
│   ├── avatar.gd                   # Avatars Bob (Barbarian) and Alice (Rogue) — animated KayKit
│   ├── grain.gd                    # Procedural grain (runtime noise normal map)
│   └── hud.gd                      # HUD: speedometer, γ and reference frame (Labels; sprite pending)
│   # simultaneity_lines.gd (overlay) — pending, Week 4
│   # scissors.gd (scissors, Act 4) — pending, Week 5
│
├── assets/
│   ├── models/                     # .glb generated in Hyper3D + KayKit characters
│   │   ├── galpao_estrutura.glb    # ✅ integrated with trimesh collision (+ PBR textures)
│   │   ├── tora.glb                # present; tora uses procedural scene (tora.tscn)
│   │   ├── esteira.glb             # pending
│   │   ├── guilhotina.glb          # pending
│   │   ├── observatorio.glb        # pending (Act 4)
│   │   └── characters/             # KayKit (CC0): Barbarian.glb, Rogue.glb, axe_1handed, anims/
│   ├── packages/                   # Original KayKit zips — out of version control (see .gitignore)
│   ├── textures/                   # Auxiliary textures
│   │   └── hdri_galpao.hdr         # Equirectangular HDRI for sawmill skydome
│   ├── sprites/                    # Pixel art (PixelLab) — pending
│   └── audio/                      # pending
│       ├── music/
│       └── sfx/
│
├── shaders/                        # Reserved for Phase 3+ (empty)
│
└── docs/
    ├── referencia_principal.pdf    # Article by Alencar et al. (2023)
    └── referencia_principal.txt    # Extracted text from the article (quick reference)
```

---

## 7. Core Systems

### 7.1 Reference Frame System (`game_state.gd` + `frame_controller.gd`)

**Responsibility**: Manage the active reference frame (ALICE or BOB) and trigger visual transitions when switching.

**Possible states**:  
- `Frame.ALICE`: rest frame of the conveyor (stationary warehouse)  
- `Frame.BOB`: rest frame of the log (apparent motion of the conveyor)

**Operations**:  
- `toggle_frame()`: switches the current reference frame  
- `get_gamma()`: returns Lorentz factor based on `belt_velocity_fraction`  
- `is_transitioning`: blocks inputs during animated transition  
- Signals: `frame_changed`, `velocity_changed`

### 7.2 Visual Transformation System

**Function**: Apply visual contraction to objects based on reference frame and speed.

**In `Frame.ALICE`**:  
- Visually contracted tora: `tora.scale.x = 1.0 / gamma`  
- Barn and guillotines at normal scale  
- Guillotines descend simultaneously

**In `Frame.BOB`**:  
- Tora at normal scale: `tora.scale.x = 1.0`  
- Galpão and guilhotinas contracted: `scale.x = 1.0 / gamma`  
- Guilhotinas descend with temporal offset `Δt' = γ·L₀·v/c²`

**Transition Between Frames**:  
- Duration: 1.5 to 2.0 seconds  
- Easing: `Tween.EASE_IN_OUT`, `Tween.TRANS_CUBIC`  
- Blocks other inputs during transition

### 7.3 Simultaneity System (Overlay)

**Function**: Visualize the relativity of simultaneity in Act 3.

**Implementation**:  
- 2D pixel art sprites overlaid on the 3D world (via `Sprite3D` or `Decal`)  
- Floating horizontal lines representing "slices of time"  
- In Alice's reference frame: parallel lines, aligned events  
- In Bob's reference frame: lines inclined in space-time

**Activation**: Button Y (toggle)

**Status**: 🟡 planned — the action `toggle_overlay` (Button Y) is mapped, but `simultaneity_lines.gd` has not yet been implemented (Week 4 backlog). In Act 3, simultaneity is demonstrated by the temporal offset of the guillotines + slow motion; the overlay is the complementary visual layer.

### 7.4 Camera System

**Function**: Controllable first-person camera + optional isometric mode.

**Modes**:  
- **First-person**: default throughout the presentation  
- **Isometric**: activated by View Button — shows the entire scene as a diorama, useful for geometric explanations

**Details**:  
- Yaw applied to `CharacterBody3D` (rotates body)  
- Pitch applied to `CameraPivot` (only camera)  
- Sensitivity configurable (gamepad and mouse separate)  
- Pitch clamped between -π/2 + 0.05 and π/2 - 0.05  
- Gamepad input ignored when no joystick is connected (avoids drift of Xbox dongle without controller in hand)  
- Mouse events discarded for 100 ms after capture and when delta > 0.5 rad (X11 warp artifact)

**Known limitation**: mouse via AnyDesk does not move the camera — AnyDesk injects synthetic events (XTest) that do not pass through the pointer grab of Godot in `MOUSE_MODE_CAPTURED`. Touchpad and USB physical mouse work normally.

### 7.5 Conveyor Belt and Guillotines System

**Conveyor Belt (`esteira.gd` + `esteira.tscn`)**:  
- Adjustable speed from 0 to 0.99c (D-Pad ↑↓); soft-cap β ≤ 0.9 in Bob's reference frame (at 0.99c the simultaneity offset would exceed the stride duration)  
- Visual movement via **physical belt**: slats move with the same step as the log (`belt_beta × VISUAL_C × delta`), with wrap at the ends and rollers rotating (ω = v/r) — replaced the old UV scroll, which depended on an adjustment factor and didn't match the log  
- Instanciate `tora.tscn` and move it along the X axis  
- The entire conveyor belongs to the group `MovingWorld`: in `Frame.BOB`, the log stays still and the shed (with the conveyor) contracts and slides at −v

**Guillotines (`guillotine.gd`)**:  
- Two instances: left and right  
- State: `READY`, `FALLING`, `DOWN`, `RETRACTING`  
- In `Frame.ALICE`: fall simultaneously when RT is pressed  
- In `Frame.BOB`: fall with calculated temporal offset

### 7.6 Scissors System (Act 4)

**Function**: Visualize the paradox of superluminal scissors.

**Implementation**:
- Two lines (blades) in a plane
- One static (X axis), the other rotating around a pivot point
- Intersection point calculated geometrically
- Intersection point speedometer displayed in HUD
- Light cone visualized when `v_ponto > c`

**Status**: ⬜ not implemented — `scissors.gd` and `observatorio.tscn` planned for Week 5. The action `next_scene` (Menu Button) is already mapped to the transition.

---

## 8. Visual Guidelines

### 8.1 Hybrid Visual Style

**3D Low-Poly Flat Shaded for**:  
- Scenario (warehouse, conveyor, walls, beams)  
- Physical objects (torus, guillotines, blades)  
- First-person character (only hands visible, optional)

**2D Pixel Art for**:  
- HUD: speedometer, γ slider, reference indicator  
- Lines of simultaneity (overlaid on 3D world)  
- Minkowski diagram (corner of screen, optional)  
- Sparks, particles, impact effects  
- Point text ("γ = 4.2", "RT to release")

**Justification for the Division**:
- 3D represents **physical phenomena** (things that exist in the world)
- 2D represents **measurement abstractions** (observations, instruments, concepts)
- This separation didactically reinforces the difference between reality and measurement

### 8.2 Color Palette

**Scenario 1 — Sawmill Warehouse (Acts 0-3)**:  
- Wood: warm earthy tones (#8B7355, #A0826D, #6B4423)  
- Metal of guillotines: blue-gray (#4A5560, #6B7780)  
- Concrete floor: light gray (#9C9C9C)  
- Ambient light: warm golden (#FFD89B)

**Scenario 2 — Cosmic Observatory (Act 4):**  
- Space: deep blue/black (<span class="color">#0A0E27</span>, <span class="color">#1B2845</span>)  
- Blades: bright white with glow (<span class="color">#FFFFFF</span> + bloom)  
- Light cone: translucent cyan blue (<span class="color">#00D9FF</span>)  
- Stars: pale yellow (<span class="color">#FFF8DC</span>)

### 8.3 Post-Processing Effects

**Globals**:  
- SSAO enabled (visual weight in low-poly)  
- Soft bloom (especially in Act 4)  
- Directional shadows 4096px

**Contextual**:  
- Subtle motion blur at high speed (v > 0.7c)  
- Slight chromatic distortion during reference frame transition  
- Subtle vignette in slow-motion mode

### 8.4 Generation Prompts in Hyper3D

**Default Style Modifier** (attach to all prompts):  
> `"low poly, flat shaded, no textures, warm earth tones, simple geometry, game-ready, clean topology, 18k quads max"`

**Main Assets to Generate**:

1. **Structural Shed**: *"Low poly industrial sawmill warehouse interior, wooden support beams, corrugated metal walls, concrete floor"*

2. **Wooden log**: *"Low poly wooden log, cylindrical, bark suggested by faceted geometry, brown and tan colors, 200 polygons max"*

3. **Industrial guillotine**: *"Low poly industrial guillotine blade mechanism, vertical metal blade in wooden frame, sawmill cutter"*

4. **Conveyor Belt**: *"Low poly conveyor belt with metal rollers, industrial style, dark grey belt, metallic supports"*

5. **Observatory (Act 4)**: *"Low poly cosmic observatory platform, minimalist circular structure, floating in space, dark blue palette"*

---

## 9. Development Roadmap

### Week 1 — Foundation ✅ Completed

**Objectives**:  
- [x] Setup of Godot 4 project  
- [x] Input Map Configuration (17 actions)  
- [x] Folder structure  
- [x] Git initialized with `.gitignore`  
- [x] Autoloads (`InputBus`, `GameState`) working  
- [x] Scene `player.tscn` with functional FPS camera  
- [x] Scene `galpao.tscn` with primitives  
- [x] Scene `main.tscn` running  
- [x] Walking through the galpao with Xbox

**Milestone**: Walk through the empty barn in first person.

### Week 2 — Galilean World ✅ Completed

**Objectives**:  
- [x] Import Hyper3D assets (partial: `galpao_estrutura.glb` integrated with trimesh collision; `esteira.glb`, `guilhotina.glb` pending)  
- [x] Animated conveyor belt with adjustable speed (D-Pad ↑↓) — `esteira.gd` + `esteira.tscn` (UV scroll; replaces `conveyor_belt.gd`)  
- [x] Torus moving along the conveyor belt — instantiated via `esteira.gd`  
- [x] `tora.tscn` created as a reusable scene — `tora.gd` (procedural CylinderMesh, L₀=4u, diameter=0.5; `set_lorentz_scale()` prepared for Week 3)  
- [x] Skydome with HDRI added to the warehouse — `galpao.gd`  
- [x] Two guillotines descending on RT press — `guillotine.gd`  
- [x] Trivial Galilean case (low v) working  
- [x] Basic HUD: text speedometer (β, γ, bar, reference frame) — `hud.gd`; pixel art sprite pending  
- [x] Bugfix: `lorentz_transform.gd` — type inference in `clamp()` treated as error (`var b: float`)

**Milestone**: Present Acts 0 and beginning of Act 1. ✅ Achieved (without Hyper3D assets).

### Week 3 — Heart: Frame of Reference Change ✅ Completed

**Objectives**:
- [x] Logic of `Frame.ALICE` vs `Frame.BOB` in `GameState`
- [x] Lorentz contraction applied via anisotropic scaling — `frame_controller.gd` (scales `1/γ` in ALICE; group `MovingWorld` with guillotines+conveyor `1/γ` in BOB)
- [x] 2s animated transition with easing (`TRANS_CUBIC`/`EASE_IN_OUT`)
- [x] Indicator of γ in HUD updating dynamically
- [x] Blocking inputs during transition (`is_transitioning` stores frame and speed)
- [x] Subtle visual effect during transition (bluish tint in sinusoidal pulse)
- [x] Coherent relative motion in BOB: tora at rest, world slides at -v (invisible fixed floor collider supports the player)

**Checkpoint**: Switch reference frames and see the "wow effect."

### Week 4 — Simultaneity and Resolution 🟡 Partial

**Objectives**:
- [ ] Simultaneity line system (pixel art sprites)
- [x] Slow-motion mode (Button X) — `Engine.time_scale = 0.25`, slows down including the offset of the guillotines (useful in Act 3 replay)
- [x] Guillotines with temporal offset in `Frame.BOB` — right descends first, left after `Δt' = γ·L₀·v/c²` (converted by visual scale)
- [x] Cut detection and visualization — blade crosses the log's plane, geometric cut, log separates into two animated halves; indicator on HUD
- [x] Precise cut aim — cut calculated at the instant the blade crosses the top of the log, with almost instantaneous drop (~0.06s, at the limit of perception): the log moves < 0.1u between the trigger and the crossing. Blade with a wedge-shaped edge (PrismMesh); retraction and pause below also fast
- [x] Scene reset (Button B) — `reset_session()` + reload
- [x] Complete paradox scene functioning in both frames
- [x] Avatars Bob and Alice (`avatar.gd`) — Bob travels on the belt behind the log (contracts with it in ALICE); Alice at the post next to the conveyor (contracts with the world in BOB)
- [x] Animated KayKit models in avatars — Bob = Barbarian with a one-edged axe in `handslot.r` (lumberjack at 0.9c), Alice = Rogue without a cloak, idle of Rig_Medium (`general/Idle_A`); fallback low-poly procedural if the GLB is missing; `tools/Sawing` and `Working_A/B/C` available for future set design
- [x] First-person embodiment — the operator is Alice in ALICE and Bob in BOB: visible body looking down (torso, arms, legs; head hidden from the camera), walking/stopping animations, axe in Bob's hand; in the middle of the transition the player teleports to the new reference post and the embodied NPC disappears
- [x] Soft-cap on speed in BOB (β ≤ 0.9) — at 0.99c the simultaneity offset would exceed the duration of the stride; 0.99c is reserved for Act 1 in ALICE
- [x] Physical conveyor belt — slats move with the same step as the log (`belt_beta × VISUAL_C × delta`) with wrap at the ends and rotating rollers (ω = v/r); replaced the UV scroll, which depended on an adjustment factor and didn't match the log. Entire belt in MovingWorld (contracts and follows the shed in BOB); in BOB the slats move at v·γ in local coordinates, coming to rest with the log in world space
- [x] Bob completes the wood cycle — follows to the end of the conveyor, dives into the pit behind the log and falls from the chute with the new log
- [x] Stylized lighting (ref. Zelda Link's Awakening Remake) — WorldEnvironment with warm diffuse environment + Filmic tonemap, saturation adjustments (1.2) and brightness (0.95), moderate sun with soft penumbra (`light_angular_distance` + `shadow_blur`), matte materials without metallic and with procedural grain (`grain.gd`: normal map of noise at runtime — arid look, anti "plastic balloon")
- [ ] Shed ambient sound
- [ ] Point-specific sound effects (conveyor, guillotines, transition)

**Milestone**: Acts 0-3 run completely from start to finish. ✅ Achieved (without audio and without overlay lines).

### Week 5 — Scissors and Polishing

**Objectives**:  
- Scene `observatory.tscn` (Act 4)  
- Logic of superluminal scissors  
- Cut-off speedometer  
- Visualization of the light cone  
- Transition between scenes  
- Visual polish (bloom, motion blur)  
- Timed trial of the complete presentation  
- Fine-tuning  
- Technical cleanup: remove legacy `scripts/conveyor_belt.gd` (replaced by the physical belt in `esteira.gd`; only a reference remains in a comment)

**Milestone**: Complete 20-minute show running.

---

## 10. Execution Principles

Applicable at any time during development:

### 10.1 Each day ends with something runnable

Nothing like "I'm going to do the whole architecture first." There's always something to show. Even if it's ugly.

### 10.2 Assets before elegant code

A stick figure walking in the warehouse is more valuable than a perfect physics system without visuals. Visuals validate early.

### 10.3 Hardcode first, generalize later

Parameters of the paradox (speed, length, etc.) remain hardcoded until Phase 4. Premature optimization kills the project.

### 10.4 Theater > simulation

When exact physics clashes with visual clarity, **visual clarity wins**. This is a stage instrument, not a simulator.

### 10.5 Commit by Visual Milestone

Commit whenever something works visually. Progress history becomes useful material for the thesis and subsequent presentation.

### 10.6 Focus on the "wow" moment

The mechanics of reference frame change (Week 3) is the most important part of the project. If this transition is perfect, the rest can be modest and still work.

---

## 11. Coding Conventions

### 11.1 GDScript Style Guide

- Follow official Godot 4 conventions: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- Indentation: tabs (Godot standard)
- Snake_case for variables, functions, signals
- PascalCase for classes and nodes in the editor
- SCREAMING_SNAKE_CASE for constants

### 11.2 Script Structure

```gdscript
# scripts/example.gd  
extends Node3D

# 1. Constants  
const MAX_SPEED: float = 10.0

# 2. Exported (configurable in the editor)  
@export var some_value: float = 1.0

# 3. Signals  
signal something_happened

# 4. Public variables  
var current_state: int = 0

# 5. Private variables (prefix _)  
var _internal_counter: int = 0

# 6. Onready (node references)  
@onready var some_node: Node = $SomeNode

# 7. Built-in functions (life cycle order)  
func _ready() -> void: pass  
func _process(delta: float) -> void: pass  
func _physics_process(delta: float) -> void: pass  
func _input(event: InputEvent) -> void: pass

# 8. Public functions  
func do_something() -> void: pass

# 9. Private functions  
func _internal_helper() -> void: pass
```

### 11.3 Required Type Hints

Always type arguments and function returns:

```gdscript
# ✅ Correto
func calculate_gamma(velocity_fraction: float) -> float:
    return 1.0 / sqrt(1.0 - velocity_fraction * velocity_fraction)

# ❌ Evitar
func calculate_gamma(velocity_fraction):
    return 1.0 / sqrt(1.0 - velocity_fraction * velocity_fraction)
```

### 11.4 Signals for Communication Between Systems

Prefer signals over direct references between independent systems. The autoload `InputBus` is the central example of this pattern.

### 11.5 Comments

- Comment on **why**, not **what**  
- Document public functions with a comment above  
- Relativistic equations must have a reference to the article (e.g., `# Eq. 13 of the Alencar et al. article`)

---

Relevant code terms for the implementation:

| Term | Definition |
|---|---|
| **Frame (in code)** | Inertial reference frame; values: `ALICE` or `BOB` |
| **β (beta)** | Speed as a fraction of c (β = v/c, 0 to 1) — `belt_beta` in `GameState` |
| **γ (gamma)** | Lorentz factor, 1/√(1−β²), always ≥ 1 — `get_gamma()` |
| **L₀** | Proper length (torus = 4 u; distance between guillotines = 4 u) |
| **MovingWorld** | Group of nodes (warehouse + conveyor + guillotines) that contracts/slides in `BOB` |

Complete physics glossary (inertial reference frame, proper time, light cone, world line, relative simultaneity): [`FUNDAMENTACAO-CIENTIFICA.md §6`](FUNDAMENTACAO-CIENTIFICA.md#6-glossário-técnico).

---

## 13. References

### 13.1 Scientific Reference

[1] **Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxes of Relativity*. arXiv:2307.05503v1 [physics.pop-ph]. UFC.

> The complete academic bibliography (secondary references cited in the article: Rindler, Dewan, Taylor & Wheeler, Rothman, Kaushal & Nemiroff, etc.) is in [`FUNDAMENTACAO-CIENTIFICA.md §7`](FUNDAMENTACAO-CIENTIFICA.md#7-referências).

### 13.2 Visual and Game Design Inspirations

- **A Slower Speed of Light** (MIT Game Lab, 2012) — first-person with relativistic visual effects  
- **Velocity Raptor** (TestTubeGames) — 2D platformer with Lorentz contraction  
- **Universe Sandbox** — "stage instrument" model for physical phenomena  
- **Manifold Garden** — puzzle as conceptual exploration of non-Euclidean geometry  
- **Bret Victor — Stop Drawing Dead Fish** — reference on interactive instruments for demonstration

### 13.3 Tools Used

- **Godot Engine 4.x** — https://godotengine.org  
- **Hyper3D.ai (Rodin)** — 3D model generation via AI — https://hyper3d.ai  
- **PixelLab.ai** — Pixel art generation via AI — https://pixellab.ai

### 13.4 Reference Technical Documentation

- Godot 4 Documentation: <a href="https://docs.godotengine.org/en/stable/">https://docs.godotengine.org/en/stable/</a>  
- GDScript Style Guide: <a href="https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html">https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html</a>  
- Godot Input System: <a href="https://docs.godotengine.org/en/stable/tutorials/inputs/index.html">https://docs.godotengine.org/en/stable/tutorials/inputs/index.html</a>

---

## Final Notes for Claude Code

### How to Handle This Project

1. **Always validate changes against the article by Alencar et al. (2023)**. If a technical decision conflicts with the scientific explanation in the article, the scientific explanation prevails.

2. **Prioritize visual clarity over numerical accuracy**. This is not a scientific simulator — it is a theatrical teaching instrument.

3. **Maintain the 20-minute constraint as a strict limit**. If something doesn't fit in the time, cut it. The Bar and Slit 2D Paradox was discarded for this reason.

4. **Absolute focus on the change of reference frame as central mechanics**. Everything revolves around this moment. Other decisions can be modest.

5. **The audience is high school students**. Visual language and narrative should reflect this — without unnecessary technical jargon, with clear moments of visual impact.

6. **The instructor is the only "user."** There are no tutorials, no onboarding for the student. Everything must be designed for someone who knows how to operate the tool live.

7. **Commit early, commit often**. Each visual milestone deserves a commit. The history becomes documentation of progress.

8. **In case of doubt about architecture, choose the simplest option that works**. Refactoring is easy once something is running.

9. **Windows ↔ Linux compatibility is a strict constraint** (see Section 5.3). Never use absolute paths, accented filenames in assets, or system calls without cross-platform testing. Development occurs on AlmaLinux 9.8; presentations on Windows.

### Current Project Status

**Phase**: Week 4 — Simultaneity and Resolution (🟡 partial)  
**Development Environment**: AlmaLinux 9.8 + Godot 4.6.3 + VS Code 1.122.0 (both via Flatpak) — configured and functional.  
**Completed (Acts 0-3 run end-to-end)**:  
- Reference frame swap ALICE↔BOB with animated Lorentz contraction (cubic Tween, input lock during transition)  
- Physical conveyor belt (struts + rollers) replacing UV scroll; log moves and is cut at the operator's aim  
- Guillotines with temporal simultaneity offset in BOB + slow-motion mode (Button X) and reset (Button B)  
- KayKit avatars (Bob/Alice) with first-person embodiment and stylized lighting  
**Week 4 Pending Items**:  
- Simultaneity lines overlay (`simultaneity_lines.gd`, pixel art sprites)  
- Ambient sounds of the warehouse and point sound effects  
**Pending Assets**: `esteira.glb`, `guilhotina.glb`, `observatorio.glb` (Hyper3D); HUD sprites (PixelLab)  
**Immediate Next Steps**:  
1. Simultaneity lines system (Button Y) — last conceptual piece of Act 3  
2. Audio layer (ambient + SFX of conveyor, guillotines, and transition)  
3. Start Week 5: scene `observatorio.tscn` and logic of superluminal scissors (`scissors.gd`)

---

> *The instrument does not end when the tora passes. It ends when the student understands **why** it passed — and discovers that they didn't need a fantasy world to be amazed: ours, described honestly, was enough.*

*Last update: June 24, 2026*  
*Project developed as a teaching instrument for Special Relativity for Brazilian high school.*

---

## 14. License

This project uses a **dual license**:

| Component | License | File |
|---|---|---|
| Source code (`scripts/`, `scenes/`, `project.godot`) | [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html) | `LICENSE` |
| Assets and documentation (`assets/`, `docs/`, `README.md`) | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) | `LICENSE-ASSETS` |

**In summary:** you can use, study, and modify this project for educational and non-commercial purposes, as long as you maintain attribution to the original author and distribute derivatives under the same licenses.

Copyright (C) 2026 Mateus Alkimim