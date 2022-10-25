set sample_fifo [create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name sample_fifo]

set_property -dict {
    CONFIG.TDATA_NUM_BYTES {2}
    CONFIG.TUSER_WIDTH {1}
    CONFIG.IS_ACLK_ASYNC {1}
    CONFIG.HAS_WR_DATA_COUNT {1}
    CONFIG.HAS_RD_DATA_COUNT {1}
    CONFIG.HAS_AEMPTY {1}
    CONFIG.HAS_AFULL {1}
    CONFIG.FIFO_MEMORY_TYPE {block}
} [get_ips sample_fifo]

generate_target {synthesis instantiation_template simulation} [get_ips sample_fifo]
