set_property  ip_repo_paths  /home/midimaster21b/src/AD9467/build/midimaster21b_dsp_ad9467_0.1.0/synth-vivado/ip_repo [current_project]
update_ip_catalog
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.4 zynq_ultra_ps_e_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list CONFIG.PSU__UART0__PERIPHERAL__IO {EMIO}] [get_bd_cells zynq_ultra_ps_e_0]
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins zynq_ultra_ps_e_0/UART_0]
endgroup
undo
startgroup
make_bd_pins_external  [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_txd]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_rxd]
endgroup
set_property name uart_txd [get_bd_ports emio_uart0_txd_0]
set_property name uart_rxd [get_bd_ports emio_uart0_rxd_0]
startgroup
create_bd_cell -type ip -vlnv midimaster21b:comm:three_wire_spi_top:1.0 three_wire_spi_top_0
endgroup
set_property location {2 566 191} [get_bd_cells three_wire_spi_top_0]
set_property location {1 605 350} [get_bd_cells three_wire_spi_top_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/three_wire_spi_top_0/s_axi_regs_p} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins three_wire_spi_top_0/s_axi_regs_p]
startgroup
make_bd_pins_external  [get_bd_pins three_wire_spi_top_0/sclk_p]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins three_wire_spi_top_0/sdio_p]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins three_wire_spi_top_0/csn_p]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins three_wire_spi_top_0/spi_clk_in_p]
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD} Slave {/three_wire_spi_top_0/s_axi_regs_p} ddr_seg {Auto} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]
undo
connect_bd_net [get_bd_pins three_wire_spi_top_0/s_axi_regs_aclk_p] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins three_wire_spi_top_0/s_axi_regs_aresetn_p] [get_bd_pins rst_ps8_0_99M/peripheral_aresetn]
set_property name spi_csn [get_bd_ports csn_p_0]
set_property name spi_clk [get_bd_ports sclk_p_0]
set_property name spi_sdio [get_bd_ports sdio_p_0]
startgroup
set_property -dict [list CONFIG.PSU__FPGA_PL1_ENABLE {1} CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {10}] [get_bd_cells zynq_ultra_ps_e_0]
endgroup
delete_bd_objs [get_bd_nets spi_clk_in_p_0_1] [get_bd_ports spi_clk_in_p_0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk1] [get_bd_pins three_wire_spi_top_0/spi_clk_in_p]
save_bd_design
generate_target all [get_files  /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
save_bd_design
validate_bd_design
save_bd_design
generate_target all [get_files  /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd]
catch { config_ip_cache -export [get_ips -all bd_cust_ip_zynq_ultra_ps_e_0_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_three_wire_spi_top_0_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_rst_ps8_0_99M_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_auto_ds_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_auto_pc_0] }
export_ip_user_files -of_objects [get_files /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd]
launch_runs bd_cust_ip_zynq_ultra_ps_e_0_0_synth_1 bd_cust_ip_three_wire_spi_top_0_0_synth_1 bd_cust_ip_rst_ps8_0_99M_0_synth_1 bd_cust_ip_auto_ds_0_synth_1 bd_cust_ip_auto_pc_0_synth_1 -jobs 8
export_simulation -of_objects [get_files /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd] -directory /home/midimaster21b/prj/bd_automation/bd_automation.ip_user_files/sim_scripts -ip_user_files_dir /home/midimaster21b/prj/bd_automation/bd_automation.ip_user_files -ipstatic_source_dir /home/midimaster21b/prj/bd_automation/bd_automation.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/modelsim} {questa=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/questa} {xcelium=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/xcelium} {vcs=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/vcs} {riviera=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
report_ip_status -name ip_status 
generate_target all [get_files  /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd]
catch { config_ip_cache -export [get_ips -all bd_cust_ip_zynq_ultra_ps_e_0_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_three_wire_spi_top_0_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_rst_ps8_0_99M_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_auto_ds_0] }
catch { config_ip_cache -export [get_ips -all bd_cust_ip_auto_pc_0] }
export_ip_user_files -of_objects [get_files /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd]
launch_runs bd_cust_ip_zynq_ultra_ps_e_0_0_synth_1 bd_cust_ip_three_wire_spi_top_0_0_synth_1 bd_cust_ip_rst_ps8_0_99M_0_synth_1 bd_cust_ip_auto_ds_0_synth_1 bd_cust_ip_auto_pc_0_synth_1 -jobs 8
export_simulation -of_objects [get_files /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd] -directory /home/midimaster21b/prj/bd_automation/bd_automation.ip_user_files/sim_scripts -ip_user_files_dir /home/midimaster21b/prj/bd_automation/bd_automation.ip_user_files -ipstatic_source_dir /home/midimaster21b/prj/bd_automation/bd_automation.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/modelsim} {questa=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/questa} {xcelium=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/xcelium} {vcs=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/vcs} {riviera=/home/midimaster21b/prj/bd_automation/bd_automation.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
make_wrapper -files [get_files /home/midimaster21b/prj/bd_automation/bd_automation.srcs/sources_1/bd/bd_cust_ip/bd_cust_ip.bd] -top
add_files -norecurse /home/midimaster21b/prj/bd_automation/bd_automation.gen/sources_1/bd/bd_cust_ip/hdl/bd_cust_ip_wrapper.vhd
update_compile_order -fileset sources_1
write_bd_tcl -force /home/midimaster21b/prj/bd_automation/bd_cust_ip.tcl
