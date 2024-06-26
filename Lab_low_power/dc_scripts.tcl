set_host_options -max_cores 2 

source ../../../common_setup.tcl 
set link_library  $LINK_LIBRARY_FILES_CLG 
set target_library $TARGET_LIBRARY_FILES_CLG



#set link_library {* ../models/saed32io_fc_ss0p95v25c_2p25v.db ../models/saed32io_wb_ss0p95v25c_2p25v.db ../models/saed32pll_ff1p16v125c_2p75v.db ../models/saed32pll_ss0p95v125c_2p25v.db ../models/saed32rvt_ff0p85v125c.db ../models/saed32rvt_ff1p16v125c.db ../models/saed32sram_tt1p05v25c.db ../models/saed32rvt_ss0p95v125c.db }

#set target_library { ../models/saed32io_fc_ss0p95v25c_2p25v.db ../models/saed32io_wb_ss0p95v25c_2p25v.db ../models/saed32pll_ff1p16v125c_2p75v.db ../models/saed32pll_ss0p95v125c_2p25v.db ../models/saed32rvt_ff0p85v125c.db ../models/saed32rvt_ff1p16v125c.db ../models/saed32sram_tt1p05v25c.db ../models/saed32rvt_ss0p95v125c.db }

analyze -library WORK -format verilog {../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj1/rtl/bram11.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj1/rtl/fir.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj1/rtl/user_prj1.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj1/rtl/multiplier_adder.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj2/rtl/user_prj2.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj3/rtl/user_prj3.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj0/rtl/user_prj0.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj0/rtl/spram.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/user_prj/user_prj0/rtl/concat_EdgeDetect_Top_fsic.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/la_mux/rtl/la_mux.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/irq_mux/rtl/irq_mux.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/axis_slav/rtl/axis_slav.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/axis_mstr/rtl/axis_mstr.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/axil_slav/rtl/axil_slav.v \
									   ../RTL/fsic_fpga/rtl/user/user_subsys/rtl/user_subsys.v \
									   ../RTL/fsic_fpga/rtl/user/mprj_io/rtl/fsic_mprj_io.v \
									   ../RTL/fsic_fpga/rtl/user/logic_analyzer/rtl/Sram.v \
									   ../RTL/fsic_fpga/rtl/user/logic_analyzer/rtl/LogicAnalyzer.v \
									   ../RTL/fsic_fpga/rtl/user/io_serdes/rtl/io_serdes.v \
									   ../RTL/fsic_fpga/rtl/user/io_serdes/rtl/fsic_io_serdes_rx.v\
									   ../RTL/fsic_fpga/rtl/user/io_serdes/rtl/fsic_coreclk_phase_cnt.v\
									   ../RTL/fsic_fpga/rtl/user/fsic_clkrst/rtl/fsic_clkrst.v \
									   ../RTL/fsic_fpga/rtl/user/config_ctrl/rtl/config_ctrl.v \
									   ../RTL/fsic_fpga/rtl/user/axis_switch/rtl/sw_caravel.v \
									   ../RTL/fsic_fpga/rtl/user/rtl/fsic.v \
									   ../RTL/fsic_fpga/rtl/user/testbench/fpga.v \
									   ../RTL/fsic_fpga/rtl/user/testbench/fsic_clock.v \
}
analyze -library WORK -format sverilog {../RTL/fsic_fpga/rtl/user/axilite_axis/rtl/axis_slave.sv \
									   ../RTL/fsic_fpga/rtl/user/axilite_axis/rtl/axis_master.sv \
									   ../RTL/fsic_fpga/rtl/user/axilite_axis/rtl/axilite_slave.sv \
									   ../RTL/fsic_fpga/rtl/user/axilite_axis/rtl/axilite_master.sv \
									   ../RTL/fsic_fpga/rtl/user/axilite_axis/rtl/axil_axis.sv \
									   ../RTL/fsic_fpga/rtl/user/axilite_axis/rtl/axi_ctrl_logic.sv \
}
read_file -format verilog {../RTL/fsic_fpga/rtl/user/rtl/fsic.v}

source -echo ../inputs/chiptop+_s0.sdc

set_clock_gating_registers -include_instances [all_registers -clock clock]  
#set_clock_gating_registers -include_instances [remove_from_collection  [all_registers -clock clock] [get_cells "MemYHier/MemXb MemYHier/MemXa MemXHier/MemXb MemXHier/MemXa"]]

set_operating_conditions -min ff1p16v125c -max ss0p95v125c

link
set_fix_multiple_port_nets -all -buffer_constants [get_designs FSIC]


compile	-exact_map -gate_clock

change_names -rules verilog -verbose -hier
report_clock_gating


set_fix_hold [all_clocks]
report_constraints  -min_delay
compile -incremental -only_design

###########reports##########################
report_area
report_timing
report_power 


write -f verilog -h -out   ../output/FSIC.v
write -f ddc -h -out       ../output/FSIC.ddc





