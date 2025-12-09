# Verilog Shooting Game - Module Documentation

## Overview
The pixel generation logic has been refactored from a monolithic 649-line file into modular, maintainable components. This improves code organization, readability, and makes the system easier to modify and debug.

## Architecture

### Main Module: `pixel_gen.v` (215 lines)
The main coordinator module that:
- Handles input synchronization (joysticks, buttons)
- Generates frame timing (60 FPS tick)
- Instantiates all sub-modules
- Manages final pixel color output priority

### Sub-Modules

#### 1. `jet_controller.v`
**Purpose:** Manages jet movement and collision detection for both players
**Inputs:**
- Clock and frame timing
- Joystick inputs (up, down, left, right) for both players
- Current pixel position

**Outputs:**
- Jet positions (x, y coordinates)
- Jet rendering signals (jet1_on, jet2_on)

**Features:**
- Mirror arena with center wall at x=320
- Boundary checking
- Smooth 5-pixel-per-frame movement

#### 2. `bullet_system.v` ⭐ NEW
**Purpose:** Handles bullet firing, movement, and collision detection
**Inputs:**
- Clock and frame timing
- Jet positions for both players
- Fire button inputs
- Shield status
- Current pixel position

**Outputs:**
- Hit signals for collision detection
- Bullet rendering signal

**Features:**
- 10x5 pixel rectangular bullets
- Horizontal movement (right for P1, left for P2)
- 5 pixels per frame speed
- Edge detection for fire buttons
- Collision detection with opponent jets
- Respect shield status (no damage when shielded)
- Bullet disappears on boundary or collision

**Bullet Specifications:**
- Size: 10 pixels wide × 5 pixels high
- Direction: P1 fires right, P2 fires left
- Speed: 5 pixels per frame (~5 pixels per 1/60 second)
- Damage: 1 health point per hit
- Start position: Fires from jet nose, vertically centered

#### 3. `health_display.v`
**Purpose:** Manages player health bars, text display, and health changes
**Inputs:**
- Clock and frame timing
- Hit signals from bullet system
- Powerup health modifications
- Current pixel position

**Outputs:**
- Current health values
- Health bar rendering signal and colors

**Features:**
- 120×20 pixel health bars with borders
- Color-coded health levels (green/yellow/red)
- Numeric health display
- Supports both bullet damage (-1) and powerup effects (±20)

#### 4. `powerup_system.v`
**Purpose:** Spawns and manages mystery powerups
**Inputs:**
- Clock and frame timing
- Jet positions
- Timer information
- Current pixel position

**Outputs:**
- Health modification signals
- Shield activation signals
- Powerup rendering signal and colors

**Features:**
- Three types: Health boost (+), Damage (-), Shield (O)
- Question mark display before collection
- Revealed icon after collection
- Balanced spawning based on collection counts
- LFSR random positioning

#### 5. `timer_display.v`
**Purpose:** Displays countdown timer
**Inputs:**
- Clock
- Current pixel position

**Outputs:**
- Current time remaining
- Game over signal
- Timer rendering signal and colors

**Features:**
- 30-second countdown
- Seven-segment display style
- Turns red when time expires

#### 6. `star_background.v`
**Purpose:** Renders starfield background
**Inputs:**
- Current pixel position

**Outputs:**
- Star rendering signal and colors

**Features:**
- Multiple star sizes (small, medium, large, xlarge)
- Various colors for diversity
- 43 stars total
- Optimized position-based detection

#### 7. `nebula_background.v`
**Purpose:** Renders deep-space nebula background
**Inputs:**
- Current pixel position

**Outputs:**
- Nebula color based on distance from center

**Features:**
- Radial gradient effect
- Purple/indigo color scheme
- 30 distance-based color rings

## Module Interconnections

```
pixel_gen (main)
├── jet_controller → provides jet positions to:
│   ├── bullet_system (for firing position and collision)
│   └── powerup_system (for collision detection)
│
├── timer_display → provides time to:
│   └── powerup_system (for spawn timing)
│
├── powerup_system → provides:
│   ├── health modifications → health_display
│   └── shield status → bullet_system
│
├── bullet_system → provides:
│   └── hit signals → health_display
│
└── Rendering priority (top to bottom):
    1. Bullets (white, highest priority)
    2. Powerups
    3. Timer
    4. Health bars
    5. Jets (with shield coloring)
    6. Stars
    7. Nebula (background)
```

## Key Improvements

### Code Organization
- **Before:** 649 lines in single file
- **After:** 215 lines main + 7 focused modules
- **Benefit:** Easier to understand, modify, and debug

### Modularity
- Each module has a single, clear responsibility
- Clean interfaces with defined inputs/outputs
- Independent testing possible

### Bullet System Integration
- Cleanly integrated without disrupting existing code
- Properly respects game rules (shields, boundaries)
- Accurate collision detection
- Smooth animation

### Maintainability
- Changes to one feature don't affect others
- Easy to add new features
- Clear signal flow
- Well-commented code

## Usage Notes

### Fire Buttons
The bullet system requires two fire button inputs:
- `btn_p1_fire` - Player 1 fire button
- `btn_p2_fire` - Player 2 fire button

These must be connected in the top-level module (`top_level_vga.v`) to appropriate FPGA pins.

### Timing
All modules use the same 60 FPS frame tick for synchronized animation.

### Health System
Health changes can occur from two sources:
1. Bullet hits: -1 health point per hit
2. Powerups: ±20 health points
Both are handled by the `health_display` module.

### Collision Detection
Two types of collision detection:
1. Bullet-Jet collision (in `bullet_system.v`)
2. Jet-Powerup collision (in `powerup_system.v`)

## Testing Recommendations

1. **Visual Testing:** Verify all graphics render correctly
2. **Movement Testing:** Test jet controls and bullet firing
3. **Collision Testing:** Verify bullet hits reduce health
4. **Shield Testing:** Confirm bullets don't damage shielded jets
5. **Boundary Testing:** Confirm bullets disappear at screen edges
6. **Integration Testing:** Verify all systems work together

## Future Enhancements

Possible additions with this modular structure:
- Multiple bullets per player
- Different bullet types (with separate modules)
- Obstacle system (new module)
- Score tracking (new module)
- Sound effects (new module)
- Different game modes
