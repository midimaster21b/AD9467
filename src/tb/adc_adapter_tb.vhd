library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

use std.env.finish;

entity adc_adapter_tb is
end adc_adapter_tb;

architecture rtl of adc_adapter_tb is
  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant NUM_ADC_BITS_C        : integer := 16;
  constant ADC_CLK_PERIOD_C      : time    := 8 ns; -- 125 MHz
  constant CLK_125_PERIOD_C      : time    := 8 ns; -- 125 MHz
  constant SPI_CLK_PERIOD_C      : time    := 100 ns; -- 10 MHz
  constant AXI_REGS_ADDR_WIDTH_G : integer := 5;
  constant AXI_REGS_DATA_WIDTH_G : integer := 32;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal rst_s             : std_logic := '1';

  signal clk_spi_s         : std_logic := '0';
  signal clk_125_s         : std_logic := '0';
  signal clk_125_sn        : std_logic;

  -- UART communication
  signal uart_txd_s        : std_logic := '1';
  signal uart_rxd_s        : std_logic;

  -- Status LEDs
  signal up_status_s       : std_logic_vector(7 downto 0);

  -- ADC Data Interface
  signal adc_clk_in_s      : std_logic := '0';
  signal adc_clk_in_sn     : std_logic;
  signal adc_data_or_s     : std_logic := '0';
  signal adc_data_or_sn    : std_logic;

  signal adc_data_in_s     : std_logic_vector((NUM_ADC_BITS_C/2)-1 downto 0) := x"AB";
  signal adc_data_in_sn    : std_logic_vector((NUM_ADC_BITS_C/2)-1 downto 0);

  -- ADC Control Interface
  signal ad9517_csn_s      : std_logic;
  signal spi_csn_s         : std_logic;
  signal spi_clk_s         : std_logic;
  signal spi_sdio_s        : std_logic;

  -- AXI
  signal s_axi_regs_aclk_s    : std_logic;
  signal s_axi_regs_aresetn_s : std_logic;
  signal s_axi_regs_awaddr_s  : std_logic_vector(AXI_REGS_ADDR_WIDTH_G-1 downto 0);
  signal s_axi_regs_awprot_s  : std_logic_vector(2 downto 0);
  signal s_axi_regs_awvalid_s : std_logic;
  signal s_axi_regs_awready_s : std_logic;
  signal s_axi_regs_wdata_s   : std_logic_vector(AXI_REGS_DATA_WIDTH_G-1 downto 0);
  signal s_axi_regs_wstrb_s   : std_logic_vector((AXI_REGS_DATA_WIDTH_G/8)-1 downto 0);
  signal s_axi_regs_wvalid_s  : std_logic;
  signal s_axi_regs_wready_s  : std_logic;
  signal s_axi_regs_bresp_s   : std_logic_vector(1 downto 0);
  signal s_axi_regs_bvalid_s  : std_logic;
  signal s_axi_regs_bready_s  : std_logic;
  signal s_axi_regs_araddr_s  : std_logic_vector(AXI_REGS_ADDR_WIDTH_G-1 downto 0);
  signal s_axi_regs_arprot_s  : std_logic_vector(2 downto 0);
  signal s_axi_regs_arvalid_s : std_logic;
  signal s_axi_regs_arready_s : std_logic;
  signal s_axi_regs_rdata_s   : std_logic_vector(AXI_REGS_DATA_WIDTH_G-1 downto 0);
  signal s_axi_regs_rresp_s   : std_logic_vector(1 downto 0);
  signal s_axi_regs_rvalid_s  : std_logic;
  signal s_axi_regs_rready_s  : std_logic;


  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  component adc_adapter_top is
    generic (
      NUM_ADC_BITS : integer := 16;
      AXI_REGS_ADDR_WIDTH_G : integer := 5;
      AXI_REGS_DATA_WIDTH_G : integer := 32
      );
    port (
      -- Clock and reset lines
      clk_125_p     : in    std_logic;
      clk_125_n     : in    std_logic;
      spi_clk_in    : in    std_logic;

      reset         : in    std_logic;

      -- Status LEDs
      debug_leds_p  : out   std_logic_vector(7 downto 0);

      -- ADC Data Interface
      adc_clk_in_p  : in    std_logic;
      adc_clk_in_n  : in    std_logic;
      adc_data_or_p : in    std_logic;
      adc_data_or_n : in    std_logic;

      adc_data_in_p : in    std_logic_vector((NUM_ADC_BITS/2)-1 downto 0);
      adc_data_in_n : in    std_logic_vector((NUM_ADC_BITS/2)-1 downto 0);

      -- ADC Control Interface
      ad9517_csn    : out   std_logic;
      spi_csn       : out   std_logic;
      spi_clk       : out   std_logic;
      spi_sdio      : inout std_logic;

      -- AXI Register Interface
      s_axi_regs_aclk_p    : in    std_logic;
      s_axi_regs_aresetn_p : in    std_logic;
      s_axi_regs_awaddr_p  : in    std_logic_vector(AXI_REGS_ADDR_WIDTH_G-1 downto 0);
      s_axi_regs_awprot_p  : in    std_logic_vector(2 downto 0);
      s_axi_regs_awvalid_p : in    std_logic;
      s_axi_regs_awready_p : out   std_logic;
      s_axi_regs_wdata_p   : in    std_logic_vector(AXI_REGS_DATA_WIDTH_G-1 downto 0);
      s_axi_regs_wstrb_p   : in    std_logic_vector((AXI_REGS_DATA_WIDTH_G/8)-1 downto 0);
      s_axi_regs_wvalid_p  : in    std_logic;
      s_axi_regs_wready_p  : out   std_logic;
      s_axi_regs_bresp_p   : out   std_logic_vector(1 downto 0);
      s_axi_regs_bvalid_p  : out   std_logic;
      s_axi_regs_bready_p  : in    std_logic;
      s_axi_regs_araddr_p  : in    std_logic_vector(AXI_REGS_ADDR_WIDTH_G-1 downto 0);
      s_axi_regs_arprot_p  : in    std_logic_vector(2 downto 0);
      s_axi_regs_arvalid_p : in    std_logic;
      s_axi_regs_arready_p : out   std_logic;
      s_axi_regs_rdata_p   : out   std_logic_vector(AXI_REGS_DATA_WIDTH_G-1 downto 0);
      s_axi_regs_rresp_p   : out   std_logic_vector(1 downto 0);
      s_axi_regs_rvalid_p  : out   std_logic;
      s_axi_regs_rready_p  : in    std_logic
      );
  end component adc_adapter_top;

begin

  rst_s         <= '0' after 100 ns;
  clk_125_s     <= not clk_125_s    after CLK_125_PERIOD_C/2;
  adc_clk_in_s  <= not adc_clk_in_s after ADC_CLK_PERIOD_C/2;
  clk_spi_s     <= not clk_spi_s    after SPI_CLK_PERIOD_C/2;
  adc_data_or_s <= '1' after 200 ns;


  -- Differential signals
  clk_125_sn     <= not clk_125_s;
  adc_clk_in_sn  <= not adc_clk_in_s;
  adc_data_in_sn <= not adc_data_in_s;
  adc_data_or_sn <= not adc_data_or_s;

  process
  begin
    wait for 100 us;
    finish;
    wait;
  end process;


  -- u_dut: entity work.adc_adapter_top(rtl)
  u_dut: adc_adapter_top
    generic map (
      NUM_ADC_BITS          => NUM_ADC_BITS_C,
      AXI_REGS_ADDR_WIDTH_G => 5,
      AXI_REGS_DATA_WIDTH_G => 32
      )
    port map (
      -- Clock and reset lines
      clk_125_p     => clk_125_s,
      clk_125_n     => clk_125_sn,
      spi_clk_in    => clk_spi_s,

      reset         => rst_s,

      -- Status LEDs
      debug_leds_p  => up_status_s,

      -- ADC Data Interface
      adc_clk_in_p  => adc_clk_in_s,
      adc_clk_in_n  => adc_clk_in_sn,
      adc_data_or_p => adc_data_or_s,
      adc_data_or_n => adc_data_or_sn,
      adc_data_in_p => adc_data_in_s,
      adc_data_in_n => adc_data_in_sn,

      -- ADC Control Interface
      ad9517_csn    => ad9517_csn_s,
      spi_csn       => spi_csn_s,
      spi_clk       => spi_clk_s,
      spi_sdio      => spi_sdio_s,

      -- AXI Register Interface
      s_axi_regs_aclk_p    => s_axi_regs_aclk_s,
      s_axi_regs_aresetn_p => s_axi_regs_aresetn_s,
      s_axi_regs_awaddr_p  => s_axi_regs_awaddr_s,
      s_axi_regs_awprot_p  => s_axi_regs_awprot_s,
      s_axi_regs_awvalid_p => s_axi_regs_awvalid_s,
      s_axi_regs_awready_p => s_axi_regs_awready_s,
      s_axi_regs_wdata_p   => s_axi_regs_wdata_s,
      s_axi_regs_wstrb_p   => s_axi_regs_wstrb_s,
      s_axi_regs_wvalid_p  => s_axi_regs_wvalid_s,
      s_axi_regs_wready_p  => s_axi_regs_wready_s,
      s_axi_regs_bresp_p   => s_axi_regs_bresp_s,
      s_axi_regs_bvalid_p  => s_axi_regs_bvalid_s,
      s_axi_regs_bready_p  => s_axi_regs_bready_s,
      s_axi_regs_araddr_p  => s_axi_regs_araddr_s,
      s_axi_regs_arprot_p  => s_axi_regs_arprot_s,
      s_axi_regs_arvalid_p => s_axi_regs_arvalid_s,
      s_axi_regs_arready_p => s_axi_regs_arready_s,
      s_axi_regs_rdata_p   => s_axi_regs_rdata_s,
      s_axi_regs_rresp_p   => s_axi_regs_rresp_s,
      s_axi_regs_rvalid_p  => s_axi_regs_rvalid_s,
      s_axi_regs_rready_p  => s_axi_regs_rready_s
      );


end rtl;
