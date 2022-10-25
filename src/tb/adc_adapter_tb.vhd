library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity adc_adapter_tb is
end adc_adapter_tb;

architecture rtl of adc_adapter_tb is
  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant NUM_ADC_BITS_C    : integer := 16;
  constant ADC_CLK_PERIOD_C  : time    := 8 ns; -- 125 MHz
  constant CLK_125_PERIOD_C  : time    := 8 ns; -- 125 MHz

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal rst_s             : std_logic := '1';

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

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  component adc_adapter_top is
    generic (
      NUM_ADC_BITS : integer := 16
      );
      port (
        -- Clock and reset lines
        clk_125_p     : in    std_logic;
        clk_125_n     : in    std_logic;

        reset         : in    std_logic;

        -- UART communication
        uart_txd      : in    std_logic;
        uart_rxd      : out   std_logic;

        -- Status LEDs
        up_status     : out   std_logic_vector(7 downto 0);

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
        spi_sdio      : inout std_logic
        );
  end component adc_adapter_top;

begin

  rst_s         <= '0' after 100 ns;
  clk_125_s     <= not clk_125_s    after CLK_125_PERIOD_C/2;
  adc_clk_in_s  <= not adc_clk_in_s after ADC_CLK_PERIOD_C/2;
  adc_data_or_s <= '1' after 200 ns;


  -- Differential signals
  clk_125_sn     <= not clk_125_s;
  adc_clk_in_sn  <= not adc_clk_in_s;
  adc_data_in_sn <= not adc_data_in_s;
  adc_data_or_sn <= not adc_data_or_s;

  -- u_dut: entity adc_adapter_top(rtl)
  u_dut: adc_adapter_top
    generic map (
      NUM_ADC_BITS => NUM_ADC_BITS_C
      )
    port map (
      -- Clock and reset lines
      clk_125_p     => clk_125_s,
      clk_125_n     => clk_125_sn,

      reset         => rst_s,

      -- UART communication
      uart_txd      => uart_txd_s,
      uart_rxd      => uart_rxd_s,

      -- Status LEDs
      up_status     => up_status_s,

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
      spi_sdio      => spi_sdio_s
      );

end rtl;
