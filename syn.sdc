# ####################################################################

#  Created by Genus(TM) Synthesis Solution 19.11-s087_1 on Thu Sep 19 19:28:25 IST 2024

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design GCD

create_clock -name "clk" -period 2.0 -waveform {0.0 1.0} 
set_clock_transition 0.01 [get_clocks clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.05 [get_clocks clk]
set_clock_uncertainty -hold 0.05 [get_clocks clk]