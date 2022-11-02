set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS18} [get_ports { reset }]; # CPU_RESET [PUSHBUTTON]

set_property -dict { PACKAGE_PIN G9 IOSTANDARD DIFF_SSTL15} [get_ports { clk_125_n }]; # CLK_125_N
set_property -dict { PACKAGE_PIN H9 IOSTANDARD DIFF_SSTL15} [get_ports { clk_125_p }]; # CLK_125_P

set_property -dict { PACKAGE_PIN AH17 IOSTANDARD LVCMOS12} [get_ports  { uart_txd }]; # UART2_TXD_O_FPGA_RXD
set_property -dict { PACKAGE_PIN AL17 IOSTANDARD LVCMOS12} [get_ports  { uart_rxd }]; # UART2_RXD_I_FPGA_TXD

set_property -dict { PACKAGE_PIN AL11 IOSTANDARD LVCMOS12} [get_ports { up_status[0] }]; # GPIO_LED_0_LS
set_property -dict { PACKAGE_PIN AL13 IOSTANDARD LVCMOS12} [get_ports { up_status[1] }]; # GPIO_LED_1_LS
set_property -dict { PACKAGE_PIN AK13 IOSTANDARD LVCMOS12} [get_ports { up_status[2] }]; # GPIO_LED_2_LS
set_property -dict { PACKAGE_PIN AE15 IOSTANDARD LVCMOS12} [get_ports { up_status[3] }]; # GPIO_LED_3_LS
set_property -dict { PACKAGE_PIN AM8  IOSTANDARD LVCMOS12} [get_ports { up_status[4] }]; # GPIO_LED_4_LS
set_property -dict { PACKAGE_PIN AM9  IOSTANDARD LVCMOS12} [get_ports { up_status[5] }]; # GPIO_LED_5_LS
set_property -dict { PACKAGE_PIN AM10 IOSTANDARD LVCMOS12} [get_ports { up_status[6] }]; # GPIO_LED_6_LS
set_property -dict { PACKAGE_PIN AM11 IOSTANDARD LVCMOS12} [get_ports { up_status[7] }]; # GPIO_LED_7_LS

set_property -dict {  PACKAGE_PIN E15   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_clk_in_p     }]; # FMC_HPC0_CLK0_M2C_P
set_property -dict {  PACKAGE_PIN E14   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_clk_in_n     }]; # FMC_HPC0_CLK0_M2C_N
set_property -dict {  PACKAGE_PIN E18   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_or_p    }]; # FMC_HPC0_LA08_P
set_property -dict {  PACKAGE_PIN E17   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_or_n    }]; # FMC_HPC0_LA08_N
set_property -dict {  PACKAGE_PIN F17   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[0] }]; # LA00_CC_P
set_property -dict {  PACKAGE_PIN F16   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[0] }]; # LA00_CC_N
set_property -dict {  PACKAGE_PIN H18   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[1] }]; # FMC_HPC0_LA01_CC_P
set_property -dict {  PACKAGE_PIN H17   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[1] }]; # FMC_HPC0_LA01_CC_N
set_property -dict {  PACKAGE_PIN L20   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[2] }]; # FMC_HPC0_LA02_P
set_property -dict {  PACKAGE_PIN K20   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[2] }]; # FMC_HPC0_LA02_N
set_property -dict {  PACKAGE_PIN K19   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[3] }]; # FMC_HPC0_LA03_P
set_property -dict {  PACKAGE_PIN K18   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[3] }]; # FMC_HPC0_LA03_N
set_property -dict {  PACKAGE_PIN L17   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[4] }]; # FMC_HPC0_LA04_P
set_property -dict {  PACKAGE_PIN L16   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[4] }]; # FMC_HPC0_LA04_N
set_property -dict {  PACKAGE_PIN K17   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[5] }]; # FMC_HPC0_LA05_P
set_property -dict {  PACKAGE_PIN J17   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[5] }]; # FMC_HPC0_LA05_N
#set_property -dict {  PACKAGE_PIN C10   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[6] }];
#set_property -dict {  PACKAGE_PIN C11   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[6] }];
set_property -dict {  PACKAGE_PIN H19   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[6] }]; # FMC_HPC0_LA06_P
set_property -dict {  PACKAGE_PIN G19   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[6] }]; # FMC_HPC0_LA06_N
set_property -dict {  PACKAGE_PIN J16   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_p[7] }]; # FMC_HPC0_LA07_P
set_property -dict {  PACKAGE_PIN J15   DIFF_TERM TRUE  IOSTANDARD LVDS} [ get_ports { adc_data_in_n[7] }]; # FMC_HPC0_LA07_N


set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS18} [ get_ports { ad9517_csn }]; # FMC_HPC0_LA33_P
set_property -dict { PACKAGE_PIN C8  IOSTANDARD LVCMOS18} [ get_ports { spi_csn    }]; # FMC_HPC0_LA33_N
set_property -dict { PACKAGE_PIN E8  IOSTANDARD LVCMOS18} [ get_ports { spi_clk    }]; # FMC_HPC0_LA32_N
set_property -dict { PACKAGE_PIN F8  IOSTANDARD LVCMOS18} [ get_ports { spi_sdio   }]; # FMC_HPC0_LA32_P
