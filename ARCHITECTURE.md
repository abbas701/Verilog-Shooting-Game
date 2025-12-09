# System Architecture Diagram

## High-Level Module Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                        top_level_vga.v                          │
│  ┌───────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │  clk_div  │→ │h_counter │→ │v_counter │→ │vga_sync  │      │
│  │ 100→25MHz │  │   0-799  │  │  0-524   │  │ h/v_sync │      │
│  └───────────┘  └──────────┘  └──────────┘  └────┬─────┘      │
│                                                    │             │
│                                                    ↓             │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                    pixel_gen.v                         │    │
└──┤              (Main Coordinator - 215 lines)            ├────┘
   └────────────────────────────────────────────────────────┘
```

## pixel_gen.v Internal Structure

```
┌──────────────────────────────────────────────────────────────────┐
│                         pixel_gen.v                              │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Input Synchronization & Frame Timing                   │   │
│  │  • 2-stage joystick sync                                │   │
│  │  • 60 FPS frame tick generator                          │   │
│  │  • Video pipeline registers                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Module Instantiations                       │  │
│  │                                                          │  │
│  │  ┌───────────────────┐        ┌──────────────────┐     │  │
│  │  │ jet_controller.v  │───────→│ bullet_system.v  │     │  │
│  │  │                   │ jet    │                  │     │  │
│  │  │ • P1 jet (cyan)   │ pos    │ • 10×5 bullets   │     │  │
│  │  │ • P2 jet (orange) │        │ • Fire detection │     │  │
│  │  │ • Movement logic  │        │ • Collision det  │     │  │
│  │  │ • Boundary check  │        │ • Hit signals    │     │  │
│  │  └─────────┬─────────┘        └────────┬─────────┘     │  │
│  │            │                            │               │  │
│  │            │ jet_pos                   │ player_hit    │  │
│  │            ↓                            ↓               │  │
│  │  ┌─────────────────────┐    ┌──────────────────────┐  │  │
│  │  │  powerup_system.v   │    │  health_display.v    │  │  │
│  │  │                     │    │                      │  │  │
│  │  │ • Mystery boxes     │    │ • Health bars        │  │  │
│  │  │ • +/- health        │───→│ • Numeric display    │  │  │
│  │  │ • Shield powerup    │ hp │ • Color coding       │  │  │
│  │  │ • LFSR random       │ mod│ • Damage handling    │  │  │
│  │  └──────────┬──────────┘    └──────────────────────┘  │  │
│  │             │                                          │  │
│  │             │ shield_active                            │  │
│  │             └──────────────────────────┐               │  │
│  │                                        ↓               │  │
│  │  ┌──────────────────┐       ┌────────────────────┐   │  │
│  │  │ timer_display.v  │──────→│ powerup_system.v   │   │  │
│  │  │                  │ sec   │ (spawn timing)     │   │  │
│  │  │ • 30s countdown  │       └────────────────────┘   │  │
│  │  │ • 7-segment      │                                │  │
│  │  └──────────────────┘                                │  │
│  │                                                       │  │
│  │  ┌──────────────────────┐  ┌────────────────────┐   │  │
│  │  │ star_background.v    │  │nebula_background.v │   │  │
│  │  │                      │  │                    │   │  │
│  │  │ • 43 stars           │  │ • Radial gradient  │   │  │
│  │  │ • Multiple sizes     │  │ • Purple/blue      │   │  │
│  │  │ • Color variety      │  │ • 30 color rings   │   │  │
│  │  └──────────────────────┘  └────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Rendering Priority (Combinational)          │   │
│  │                                                     │   │
│  │  1. Bullets (white) ━━━━━━━━━━━ Highest Priority  │   │
│  │  2. Powerups                                       │   │
│  │  3. Timer                                          │   │
│  │  4. Health bars                                    │   │
│  │  5. Jets (cyan/orange, blue if shielded)          │   │
│  │  6. Stars                                          │   │
│  │  7. Nebula ━━━━━━━━━━━━━━━━━━━ Background        │   │
│  │                                                     │   │
│  │  Output: 12-bit RGB (4 bits per channel)          │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌──────────────┐
│   Inputs     │
├──────────────┤
│ Joysticks ×2 │──────┐
│ Fire btns ×2 │      │
│ 100MHz Clock │──┐   │
└──────────────┘  │   │
                  ↓   ↓
              ┌────────────────┐
              │ Synchronization│
              └───────┬────────┘
                      ↓
        ┌─────────────────────────┐
        │   60 FPS Frame Tick     │
        └────────┬────────────────┘
                 ↓
     ┌───────────────────────┐
     │   Game State Updates   │
     │   (Sequential Logic)   │
     ├───────────────────────┤
     │ • Jet positions        │
     │ • Bullet positions     │
     │ • Health values        │
     │ • Shield timers        │
     │ • Timer countdown      │
     │ • Powerup spawning     │
     └───────┬───────────────┘
             ↓
     ┌──────────────────────┐
     │  Collision Detection │
     │  (Combinational)     │
     ├──────────────────────┤
     │ • Bullet vs Jet      │
     │ • Jet vs Powerup     │
     └───────┬──────────────┘
             ↓
     ┌──────────────────────┐
     │  Pixel Rendering     │
     │  (Combinational)     │
     ├──────────────────────┤
     │ • Position checks    │
     │ • Color selection    │
     │ • Priority muxing    │
     └───────┬──────────────┘
             ↓
     ┌──────────────────────┐
     │   VGA Output         │
     ├──────────────────────┤
     │ • h_sync             │
     │ • v_sync             │
     │ • RGB (12-bit)       │
     └──────────────────────┘
```

## Signal Flow: Bullet System

```
Player presses fire button
         ↓
  ┌──────────────────┐
  │ btn_p1/2_fire    │ (external input)
  └────────┬─────────┘
           ↓
  ┌──────────────────┐
  │ Edge Detection   │ (in bullet_system)
  └────────┬─────────┘
           ↓
  ┌──────────────────────────┐
  │ Bullet Spawned           │
  │ • x = jet_x + JET_W (P1) │
  │   or jet_x - BULLET_W(P2)│
  │ • y = jet_y + JET_H/2    │
  │ • active = 1             │
  └───────────┬──────────────┘
              ↓
  ┌───────────────────────────┐
  │ Every Frame Tick:         │
  │ • x += 5 (P1, rightward)  │
  │ • x -= 5 (P2, leftward)   │
  └───────────┬───────────────┘
              ↓
  ┌──────────────────────────────────┐
  │ Collision Check (combinational): │
  │ if (bullet overlaps enemy_jet)   │
  │    AND !shield_active            │
  └──────────┬───────────────────────┘
             ↓
  ┌──────────────────────┐
  │ Hit Detected?        │
  └──┬──────────────┬────┘
     │YES           │NO
     ↓              ↓
┌────────────┐  ┌──────────────┐
│player_hit=1│  │ Check bounds │
│active = 0  │  │ (x < 0/640)  │
└─────┬──────┘  └──────┬───────┘
      │                │
      │                ↓
      │         ┌──────────────┐
      │         │ Out of bounds│
      │         │  active = 0  │
      │         └──────┬───────┘
      │                │
      └────────────────┴──────────→ Continue
                       │
                       ↓
              ┌─────────────────┐
              │ Pixel Rendering │
              │ (white bullet)  │
              └─────────────────┘
```

## Timing Relationships

```
100 MHz Clock
    ↓ (÷4)
25 MHz VGA Clock ───────→ h_counter, v_counter
    ↓
640×480 @ 60Hz ─────────→ 800×525 total pixels
    ↓
Frame completed ────────→ Frame Tick (pulse)
    ↓
60 FPS Updates:
├─ Jet movement (5 px/frame = 300 px/s)
├─ Bullet movement (5 px/frame = 300 px/s)
├─ Power-up countdown (300 frames = 5 seconds)
├─ Shield countdown (300 frames = 5 seconds)
└─ Timer countdown (60 frames = 1 second)
```

## Module Responsibilities Summary

| Module | Lines | Purpose | State |
|--------|-------|---------|-------|
| `pixel_gen.v` | 215 | Coordinator | Minimal state |
| `jet_controller.v` | ~70 | Movement | jet_x, jet_y |
| `bullet_system.v` | ~120 | Combat | bullet positions, active flags |
| `health_display.v` | ~180 | UI | health values |
| `powerup_system.v` | ~300 | Powerups | spawn state, LFSR |
| `timer_display.v` | ~100 | Timer | countdown state |
| `star_background.v` | ~100 | Graphics | Stateless |
| `nebula_background.v` | ~70 | Graphics | Stateless |

**Total:** ~1,155 lines (well-organized vs. 649 monolithic)

## Key Design Decisions

### 1. Modular Separation
**Decision:** Separate by functional concern, not by rendering vs. logic
**Rationale:** Each module owns its complete functionality (state + rendering)

### 2. Centralized Coordination
**Decision:** `pixel_gen` coordinates but doesn't implement game logic
**Rationale:** Clear signal flow, easy to understand system

### 3. Combinational Rendering
**Decision:** All `*_on` and `*_rgb` signals are combinational
**Rationale:** Single-cycle rendering pipeline, no display lag

### 4. Priority-Based Muxing
**Decision:** Fixed rendering priority in single always block
**Rationale:** Predictable visual behavior, easy to modify

### 5. Bullet Edge Detection
**Decision:** Edge detection for fire buttons inside bullet_system
**Rationale:** Prevents button hold from continuous firing

### 6. Shield Integration
**Decision:** Shield status provided by powerup_system to bullet_system
**Rationale:** Clean separation of concerns, bullet system queries status

## Performance Characteristics

### Resource Usage (Estimated)
- **LUTs:** ~2000-3000 (mostly rendering logic)
- **Flip-Flops:** ~500-800 (game state)
- **Block RAM:** 0 (all distributed logic)
- **Clock Domains:** 2 (100MHz, 25MHz)

### Critical Paths
1. Rendering priority mux → RGB output
2. Bullet collision detection → hit signal
3. LFSR → Powerup spawn decision

### Optimization Opportunities
- Pipeline bullet collision detection if timing fails
- Use block RAM for star positions if LUT usage high
- Simplify nebula gradient if needed
