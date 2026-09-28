# DDR2 SDRAM - Micron MT47H64M16HR-25E on bank 34

set_property INTERNAL_VREF 0.900 [get_iobanks 34]

# Address

set_property -dict { PACKAGE_PIN M4  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[0] }]
set_property -dict { PACKAGE_PIN P4  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[1] }]
set_property -dict { PACKAGE_PIN M6  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[2] }]
set_property -dict { PACKAGE_PIN T1  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[3] }]
set_property -dict { PACKAGE_PIN L3  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[4] }]
set_property -dict { PACKAGE_PIN P5  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[5] }]
set_property -dict { PACKAGE_PIN M2  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[6] }]
set_property -dict { PACKAGE_PIN N1  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[7] }]
set_property -dict { PACKAGE_PIN L4  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[8] }]
set_property -dict { PACKAGE_PIN N5  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[9] }]
set_property -dict { PACKAGE_PIN R2  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[10] }]
set_property -dict { PACKAGE_PIN K5  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[11] }]
set_property -dict { PACKAGE_PIN N6  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_addr[12] }]

# Bank address

set_property -dict { PACKAGE_PIN P2  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_ba[0] }]
set_property -dict { PACKAGE_PIN P3  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_ba[1] }]
set_property -dict { PACKAGE_PIN R1  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_ba[2] }]

# Command

set_property -dict { PACKAGE_PIN N4  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_ras_n }]
set_property -dict { PACKAGE_PIN L1  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_cas_n }]
set_property -dict { PACKAGE_PIN N2  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_we_n }]
set_property -dict { PACKAGE_PIN K6  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_cs_n }]
set_property -dict { PACKAGE_PIN M1  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_cke }]
set_property -dict { PACKAGE_PIN M3  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_odt }]

# Clock

set_property -dict { PACKAGE_PIN L6  IOSTANDARD DIFF_SSTL18_II SLEW FAST } [get_ports { ddr2_ck_p }]
set_property -dict { PACKAGE_PIN L5  IOSTANDARD DIFF_SSTL18_II SLEW FAST } [get_ports { ddr2_ck_n }]

# Data mask

set_property -dict { PACKAGE_PIN T6  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_dm[0] }]
set_property -dict { PACKAGE_PIN U1  IOSTANDARD SSTL18_II SLEW FAST } [get_ports { ddr2_dm[1] }]

# Data strobe

set_property -dict { PACKAGE_PIN U9  IOSTANDARD DIFF_SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dqs_p[0] }]
set_property -dict { PACKAGE_PIN V9  IOSTANDARD DIFF_SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dqs_n[0] }]
set_property -dict { PACKAGE_PIN U2  IOSTANDARD DIFF_SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dqs_p[1] }]
set_property -dict { PACKAGE_PIN V2  IOSTANDARD DIFF_SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dqs_n[1] }]

# Data

set_property -dict { PACKAGE_PIN R7  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[0] }]
set_property -dict { PACKAGE_PIN V6  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[1] }]
set_property -dict { PACKAGE_PIN R8  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[2] }]
set_property -dict { PACKAGE_PIN U7  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[3] }]
set_property -dict { PACKAGE_PIN V7  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[4] }]
set_property -dict { PACKAGE_PIN R6  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[5] }]
set_property -dict { PACKAGE_PIN U6  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[6] }]
set_property -dict { PACKAGE_PIN R5  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[7] }]
set_property -dict { PACKAGE_PIN T5  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[8] }]
set_property -dict { PACKAGE_PIN U3  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[9] }]
set_property -dict { PACKAGE_PIN V5  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[10] }]
set_property -dict { PACKAGE_PIN U4  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[11] }]
set_property -dict { PACKAGE_PIN V4  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[12] }]
set_property -dict { PACKAGE_PIN T4  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[13] }]
set_property -dict { PACKAGE_PIN V1  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[14] }]
set_property -dict { PACKAGE_PIN T3  IOSTANDARD SSTL18_II SLEW FAST IN_TERM UNTUNED_SPLIT_50 } [get_ports { ddr2_dq[15] }]

# Read capture clock is phase trained at run time, so its relation to the
# memory clock is not known at build time and must not be timed.

set clk_mem [get_clocks -of_objects [get_pins -hier -filter { NAME =~ *mmcm_comp/CLKOUT0 }]]
set clk_cap [get_clocks -of_objects [get_pins -hier -filter { NAME =~ *mmcm_comp/CLKOUT2 }]]

set_max_delay -datapath_only -from $clk_cap -to $clk_mem 8.000
set_false_path -from $clk_mem -to $clk_cap
