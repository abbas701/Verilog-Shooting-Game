# Verilog Shooting Game

A two-player space shooting game implemented in Verilog for FPGA (VGA display).

## Features

### Game Mechanics
- **Two-Player Competitive:** Face off in a mirrored arena
- **Jet Combat:** Control your jet and fire bullets at your opponent
- **Health System:** 100 health points, lose on depletion
- **Power-ups:** Collect mystery boxes for health boosts, damage, or shields
- **Timer:** 30-second match duration
- **Shield Protection:** Temporary invincibility from bullets

### Visual Effects
- Deep-space nebula background
- Starfield with multiple sizes and colors
- Health bars with color-coded levels
- Seven-segment countdown timer
- Visual shield indication

## Controls

### Player 1 (Left Side - Cyan Jet)
- **Movement:** Joystick 1 (up, down, left, right)
- **Fire:** btn_p1_fire button
- **Direction:** Fires bullets to the right
- **Arena:** Left half of screen (x: 10-320)

### Player 2 (Right Side - Orange Jet)
- **Movement:** Joystick 2 (up, down, left, right)
- **Fire:** btn_p2_fire button
- **Direction:** Fires bullets to the left
- **Arena:** Right half of screen (x: 320-630)

## Game Rules

### Bullet System
- **Size:** 10×5 pixels (rectangular)
- **Speed:** 5 pixels per frame
- **Damage:** 1 health point per hit
- **Behavior:**
  - Fires from the nose of your jet
  - Travels horizontally (left or right)
  - Disappears when hitting boundary or opponent
  - Cannot damage shielded opponents

### Power-ups
Three types spawn every 3 seconds:
1. **Green Plus (+):** Restore 20 health points
2. **Red Minus (-):** Deal 20 damage to opponent
3. **Blue Circle (O):** Shield for 5 seconds

Power-ups spawn as purple question marks and reveal their type when collected.

### Winning Conditions
- Reduce opponent's health to 0
- Have more health when timer expires

## Hardware Requirements

### FPGA
- Xilinx FPGA (tested with Vivado toolchain)
- 100 MHz clock input
- VGA output capability

### Inputs
- 2x 4-directional joysticks (up, down, left, right for each player)
- 2x fire buttons (one per player)

### Outputs
- VGA signals (h_sync, v_sync, 4-bit RGB)
- 640×480 @ 60 Hz resolution

## File Structure

### Source Files (`Lab_11_VGA.srcs/sources_1/new/`)
- `top_level_vga.v` - Top-level module with I/O connections
- `pixel_gen.v` - Main pixel generation coordinator (215 lines)
- `jet_controller.v` - Jet movement and positioning
- `bullet_system.v` - Bullet firing and collision **[NEW]**
- `health_display.v` - Health bars and numeric display
- `powerup_system.v` - Mystery powerup spawning and effects
- `timer_display.v` - Countdown timer display
- `star_background.v` - Starfield rendering
- `nebula_background.v` - Deep-space background
- `vga_sync.v` - VGA timing and synchronization
- `clk_div.v` - Clock divider (100 MHz → 25 MHz)
- `h_counter.v` - Horizontal pixel counter
- `v_counter.v` - Vertical line counter

### Documentation
- `MODULE_DOCUMENTATION.md` - Detailed module architecture
- `README.md` - This file

## Setup Instructions

### 1. Vivado Project
1. Open `Lab_11_VGA.xpr` in Xilinx Vivado
2. Ensure all source files are included
3. Set `top_level_vga` as the top module

### 2. Pin Constraints
Create/update constraints file with:
```tcl
# Clock
set_property PACKAGE_PIN [YOUR_CLOCK_PIN] [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Player 1 Joystick
set_property PACKAGE_PIN [PIN] [get_ports up]
set_property PACKAGE_PIN [PIN] [get_ports down]
set_property PACKAGE_PIN [PIN] [get_ports left]
set_property PACKAGE_PIN [PIN] [get_ports right]

# Player 2 Joystick
set_property PACKAGE_PIN [PIN] [get_ports up2]
set_property PACKAGE_PIN [PIN] [get_ports down2]
set_property PACKAGE_PIN [PIN] [get_ports left2]
set_property PACKAGE_PIN [PIN] [get_ports right2]

# Fire Buttons
set_property PACKAGE_PIN [PIN] [get_ports btn_p1_fire]
set_property PACKAGE_PIN [PIN] [get_ports btn_p2_fire]

# VGA Output
set_property PACKAGE_PIN [PIN] [get_ports h_sync]
set_property PACKAGE_PIN [PIN] [get_ports v_sync]
set_property PACKAGE_PIN [PIN] [get_ports {red[0]}]
# ... (continue for all RGB bits)
```

### 3. Synthesis and Implementation
1. Run Synthesis
2. Run Implementation
3. Generate Bitstream
4. Program Device

## Gameplay Tips

### For Players
- **Positioning:** Stay mobile to dodge bullets
- **Firing:** Time your shots carefully (one bullet at a time)
- **Power-ups:** Prioritize collecting them for advantages
- **Shield Usage:** Use shields to rush opponent safely
- **Center Wall:** Use as cover (bullets can't pass through)

### Strategy
- **Aggressive:** Rush with shield active
- **Defensive:** Stay back and fire from distance
- **Control:** Dominate power-up spawns
- **Pressure:** Force opponent into corners

## Technical Details

### Timing
- **VGA Clock:** 25 MHz (from 100 MHz input)
- **Frame Rate:** 60 FPS
- **Resolution:** 640×480 pixels
- **Color Depth:** 12-bit (4-bit per channel)

### Performance
- **Jet Speed:** 5 pixels per frame (300 pixels/second)
- **Bullet Speed:** 5 pixels per frame
- **Power-up Duration:** 5 seconds (300 frames)
- **Shield Duration:** 5 seconds (300 frames)

### Memory Usage
- Minimal block RAM usage (only registers)
- Combinational logic for graphics
- LFSR for randomness (no external RNG needed)

## Modular Architecture

The codebase is organized into focused modules:

```
pixel_gen (coordinator)
├── jet_controller (movement)
├── bullet_system (combat)
├── health_display (UI)
├── powerup_system (pickups)
├── timer_display (countdown)
├── star_background (graphics)
└── nebula_background (graphics)
```

See `MODULE_DOCUMENTATION.md` for detailed architecture information.

## Troubleshooting

### No Display
- Check VGA cable connection
- Verify pin constraints
- Confirm 25 MHz clock generation

### Controls Not Working
- Check joystick pin assignments
- Verify active-low logic (signal inversion)
- Test individual inputs

### Bullets Not Firing
- Confirm fire button connections
- Check button debouncing (if needed)
- Verify btn_p1_fire and btn_p2_fire signals

### Graphics Glitches
- Ensure proper clock domain crossing
- Check pipeline registers
- Verify combinational logic timing

## Development

### Adding Features
The modular structure makes adding features straightforward:
1. Create new module file
2. Add instantiation in `pixel_gen.v`
3. Connect appropriate signals
4. Update color output priority

### Modifying Existing Features
Each module is self-contained:
- Bullet behavior → `bullet_system.v`
- Jet movement → `jet_controller.v`
- Health logic → `health_display.v`
- etc.

### Testing
- Use Vivado simulator for behavioral simulation
- Test modules independently
- Verify timing constraints are met

## Credits

Original game design and implementation.
Refactored and modularized with bullet system addition.

## License

Educational project for FPGA/Verilog learning.

## Version History

- **v2.0** - Modularized architecture with bullet system
  - Split 649-line monolith into 7 focused modules
  - Added bullet firing and collision system
  - Improved code maintainability
  
- **v1.0** - Original implementation
  - Basic two-player jet game
  - Power-up system
  - Health and timer mechanics
