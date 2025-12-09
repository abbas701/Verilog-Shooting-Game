# Clock 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# VGA Red [3:0]
set_property PACKAGE_PIN N19 [get_ports {red[3]}]
set_property PACKAGE_PIN J19 [get_ports {red[2]}]
set_property PACKAGE_PIN H19 [get_ports {red[1]}]
set_property PACKAGE_PIN G19 [get_ports {red[0]}]

# VGA Green [3:0]
set_property PACKAGE_PIN D17 [get_ports {green[3]}]
set_property PACKAGE_PIN G17 [get_ports {green[2]}]
set_property PACKAGE_PIN H17 [get_ports {green[1]}]
set_property PACKAGE_PIN J17 [get_ports {green[0]}]

# VGA Blue [3:0]
set_property PACKAGE_PIN J18 [get_ports {blue[3]}]
set_property PACKAGE_PIN K18 [get_ports {blue[2]}]
set_property PACKAGE_PIN L18 [get_ports {blue[1]}]
set_property PACKAGE_PIN N18 [get_ports {blue[0]}]

# H-Sync and V-Sync
set_property PACKAGE_PIN P19 [get_ports h_sync]
set_property PACKAGE_PIN R19 [get_ports v_sync]

# I/O Standards for all VGA signals
set_property IOSTANDARD LVCMOS33 [get_ports {red[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {green[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {blue[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports h_sync]
set_property IOSTANDARD LVCMOS33 [get_ports v_sync]

# =========================================
# JOYSTICK PLAYER 1 (active-low with pull-ups)
# =========================================
set_property PACKAGE_PIN J1  [get_ports up]      ; set_property IOSTANDARD LVCMOS33 [get_ports up]      ; set_property PULLUP true [get_ports up]
set_property PACKAGE_PIN L2  [get_ports down]    ; set_property IOSTANDARD LVCMOS33 [get_ports down]    ; set_property PULLUP true [get_ports down]
set_property PACKAGE_PIN J2  [get_ports left]    ; set_property IOSTANDARD LVCMOS33 [get_ports left]    ; set_property PULLUP true [get_ports left]
set_property PACKAGE_PIN G2  [get_ports right]   ; set_property IOSTANDARD LVCMOS33 [get_ports right]   ; set_property PULLUP true [get_ports right]

# ===========================================================================
# JOYSTICK 2 (Pmod JB) ? Player 2 (Orange jet) 
# ===========================================================================
set_property PACKAGE_PIN K17  [get_ports up2]     ; set_property IOSTANDARD LVCMOS33 [get_ports up2]     ; set_property PULLUP true [get_ports up2]
set_property PACKAGE_PIN M18  [get_ports down2]   ; set_property IOSTANDARD LVCMOS33 [get_ports down2]   ; set_property PULLUP true [get_ports down2]
set_property PACKAGE_PIN N17  [get_ports left2]   ; set_property IOSTANDARD LVCMOS33 [get_ports left2]   ; set_property PULLUP true [get_ports left2]
set_property PACKAGE_PIN P18  [get_ports right2]  ; set_property IOSTANDARD LVCMOS33 [get_ports right2]  ; set_property PULLUP true [get_ports right2]

## Player 1 Fire Button (you already have this - example pin)
#set_property PACKAGE_PIN A14 [get_ports btn_p1_fire]
#set_property IOSTANDARD LVCMOS33 [get_ports btn_p1_fire]

## Player 2 Fire Button - YOUR PIN H1 (JA7)
#set_property PACKAGE_PIN H1 [get_ports btn_p2_fire]
#set_property IOSTANDARD LVCMOS33 [get_ports btn_p2_fire]