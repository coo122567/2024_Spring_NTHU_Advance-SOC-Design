set_host_options -max_cores 2 
source ../../../common_setup.tcl 
set link_library  $LINK_LIBRARY_FILES_CLG 
set target_library $TARGET_LIBRARY_FILES_CLG

set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE -min_tluplus $TLUPLUS_MIN_FILE -tech2itf_map  $MAP_FILE 

create_mw_lib  -technology $TECH_FILE  -mw_reference_library $MW_REFERENCE_LIB_DIRS_CLG -bus_naming_style {[%d]}             -open  ../work/chiptop


  
#set link_library {* ../models/saed32io_fc_ss0p95v25c_2p25v.db ../models/saed32io_wb_ss0p95v25c_2p25v.db ../models/saed32pll_ff1p16v125c_2p75v.db ../models/saed32pll_ss0p95v125c_2p25v.db ../models/saed32rvt_ff0p85v125c.db ../models/saed32rvt_ff1p16v125c.db ../models/saed32sram_tt1p05v25c.db ../models/saed32rvt_ss0p95v125c.db}

#set target_library { ../models/saed32io_fc_ss0p95v25c_2p25v.db ../models/saed32io_wb_ss0p95v25c_2p25v.db ../models/saed32pll_ff1p16v125c_2p75v.db ../models/saed32pll_ss0p95v125c_2p25v.db ../models/saed32rvt_ff0p85v125c.db ../models/saed32rvt_ff1p16v125c.db ../models/saed32sram_tt1p05v25c.db ../models/saed32rvt_ss0p95v125c.db}


#create_mw_lib  -technology ../icc/ref/tech/saed32nm_1p9m_mw.tf -mw_reference_library {../ref/ref/SRAM32NM ../ref/ref/saed32_io_fc ../ref/ref/saed32_io_wb ../ref/ref/saed32nm_rvt_1p9m} -bus_naming_style {[%d]}  -open  ../work/chiptop

#set_tlu_plus_files -max_tluplus ../ref/tlup/saed32nm_1p9m_Cmax.tluplus -min_tluplus ../ref/tlup/saed32nm_1p9m_Cmin.tluplus -tech2itf_map  ../ref/tlup/saed32nm_tf_itf_tluplus.map


import_designs -format ddc {../../dc/output/FSIC.ddc }    
 
#./output/ChipTop_pads.v
create_floorplan \
  -core_utilization 0.40\
  -start_first_row\
  -flip_first_row\
  -left_io2core 50\
  -bottom_io2core 50\
  -right_io2core 50\
  -top_io2core 50

#initialize_floorplan\
 #-core_utilization 0.75\
  #-start_first_row\
  #-flip_first_row\
  #-left_io2core 50\
  #-bottom_io2core 50\
  #-right_io2core 50\
  #-top_io2core 50
                                     


set power                    "VDD"
set ground                   "VSS"
set powerPort                "VDD"
set groundPort               "VSS"
set mw_logic0_net 	     "VSS"
set mw_logic1_net 	     "VDD"

foreach net {VDD} { derive_pg_connection -power_net $net -power_pin $net -create_ports top}
foreach net {VSS} { derive_pg_connection -ground_net $net -ground_pin $net -create_ports top}

derive_pg_connection -tie

#derive_pg_connection	\
#	-power_net VDD	\
#	-power_pin VDD	\
#	-ground_net VSS	\
#	-ground_pin VSS	  
#remove_route_by_type -pg_strap

set ring_width 41
set offset 2
set hm M5
set vm M4
create_rectangular_rings  -nets  {VDD VSS}  -left_segment_layer $vm -left_segment_width $ring_width -extend_ll -extend_lh -right_segment_layer $vm -right_segment_width $ring_width -extend_rl -extend_rh -bottom_segment_layer $hm -bottom_segment_width $ring_width -extend_bl -extend_bh -top_segment_layer $hm -top_segment_width $ring_width -extend_tl -extend_th  -left_offset $offset -right_offset $offset -bottom_offset $offset -top_offset $offset -offsets absolute

#remove_route_by_type -pg_strap
fp_report_parameter -name "vfplace"
set_fp_placement_strategy 	-macros_on_edge on \
				-sliver_size 10 \
				-virtual_IPO on
set_keepout_margin  -type hard -all_macros -outer {20 20 20 20}
create_fp_placement -timing_driven -no_hierarchy_gravity
#Analyze
report_congestion -grc_based -by_layer \
                  -routing_stage global

report_fp_placement_strategy
# Placement


# Fix all macros
#set_dont_touch_placement [all_macro_cells]
#create_rectangular_rings	\
#	  -nets  {VDD VSS}	\
#	  -left_segment_layer M4 \
#	  -left_segment_width 4	\
#	  -right_segment_layer M4 \
#	  -right_segment_width 4 \
#	  -bottom_segment_layer M5 \
#	  -bottom_segment_width 4 \
#	  -top_segment_layer M5	\
#	  -top_segment_width 4 -extend_tl -extend_th -extend_bl -extend_bh  -extend_rl -extend_rh -extend_ll -extend_lh 

#insert_stdcell_filler	\
#	-cell_without_metal "SHFILL128 SHFILL64 SHFILL3 SHFILL2 SHFILL1"	\
#	-connect_to_power {VDD}		\
#	-connect_to_ground {VSS}	

preroute_standard_cells	\
	-connect horizontal	\
	-port_filter_mode off	\
	-cell_master_filter_mode off	\
	-cell_instance_filter_mode off	\
	-voltage_area_filter_mode off
	
remove_stdcell_filler	\
	-stdcell

	
create_fp_placement


analyze_fp_rail  -nets {VDD VSS} -power_budget 1000 -voltage_supply 1.05 -use_pins_as_pads


set_fp_rail_constraints  -skip_ring -extend_strap core_ring
set_fp_rail_constraints -add_layer  -layer M4 -direction vertical -max_pitch 60 -min_pitch 30 -max_width 6.08 -min_width 3.04 -spacing minimum
set_fp_rail_constraints -add_layer  -layer M5 -direction horizontal -max_pitch 60 -min_pitch 30 -max_width 6.08 -min_width 3.04 -spacing minimum
set_fp_block_ring_constraints -add -horizontal_layer M5 -horizontal_width 3 -horizontal_offset 0.600 -vertical_layer M6 -vertical_width 3 -vertical_offset 0.600 -block_type master  -block {SRAM1RW256x32} -net  {VDD VSS}
set_fp_rail_constraints -set_global   -no_routing_over_hard_macros -no_routing_over_soft_macros


synthesize_fp_rail  -nets {VDD VSS} -voltage_supply 1.05 -synthesize_power_plan -power_budget 100 -use_pins_as_pads
commit_fp_rail	
place_opt 

preroute_instances
preroute_standard_cells -fill_empty_rows -remove_floating_pieces -do_not_route_over_macros 

route_zrt_global
# If congested modify pnet blockages 
# and perform inc’l placem’t, as needed:
report_pnet_options
remove_pnet_options; # OR
set_pnet_options -none {M2 M3} 
set_pnet_options -partial {M2 M3}
legalize_fp_placement
route_zrt_global
# If congested goto “Reduce Congestion”
report_timing
# If timing OK skip to “Write DEF”
optimize_fp_timing 	-fix_design_rule\
                  	-effort high

route_zrt_global

################################

place_opt	\
	-effort low
	
legalize_placement	\
	-effort medium

source -echo ../input/chiptop+_s0.sdc
#source -echo ../../dc/

verify_pg_nets

clock_opt

foreach net {VDD} { derive_pg_connection -power_net $net -power_pin $net -create_ports top}
foreach net {VSS} { derive_pg_connection -ground_net $net -ground_pin $net -create_ports top}
save_mw_cel -as cts
#route_opt

set_route_mode_options -zroute true
set_route_zrt_common_options
set_route_zrt_global_options
set_route_zrt_detail_options
#route_zrt_group -all_clock_nets
route_zrt_auto
verify_zrt_route

route_zrt_eco -max_detail_route_iterations 5
verify_lvs -check_open_locator -check_short_locator


save_mw_cel -as chiptop_finished
write_stream -cells FSIC clock_gating.gdsii

#connect_tie_cells -objects [get_cells -hier *] \
#                  -obj_type cell_inst \
#                  -tie_high_lib_cell TIEH -tie_low_lib_cell TIEL 
                 # -max_fanout 1 -incremenatal true
#insert_stdcell_filler	\
	-cell_without_metal "SHFILL128 SHFILL64 SHFILL3 SHFILL2 SHFILL1"	\
	-connect_to_power {VDD}		\
	-connect_to_ground {VSS}	



#save_mw_cel -as finish 
#verify_drc
#verify_lvs


