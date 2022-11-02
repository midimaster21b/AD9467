library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity adc_adapter_top is
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
end adc_adapter_top;

architecture rtl of adc_adapter_top is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant DDR_DATA_DELAY         : integer := 0;
  constant DDR_DELAY_REF_CLK_FREQ : real    := 500.0;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  -- Control and status lines
  signal clk_125_s          : std_logic;
  signal debug_leds_s       : std_logic_vector(7 downto 0) := x"37";
  signal rst_sn             : std_logic;

  -- DDR primitive control lines
  signal ddr_rst_s          : std_logic;

  -- ADC signals
  signal adc_data_s         : std_logic_vector((NUM_ADC_BITS/2)-1 downto 0);
  signal adc_delayed_data_s : std_logic_vector((NUM_ADC_BITS/2)-1 downto 0);
  signal adc_clk_s          : std_logic;
  signal adc_clk_sn         : std_logic;
  signal adc_sample_r       : std_logic_vector(NUM_ADC_BITS-1 downto 0);
  signal adc_data_or_s      : std_logic_vector(0 downto 0);

  -- FIFO signals
  signal s_axis_cdc_tready_s : std_logic;
  signal s_axis_cdc_tvalid_s : std_logic;
  signal m_axis_tready_s     : std_logic;

  signal almost_full_s  : std_logic;
  signal almost_empty_s : std_logic;


  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  component sample_fifo is
    port (
      s_axis_aresetn     : in  STD_LOGIC;
      s_axis_aclk        : in  STD_LOGIC;
      s_axis_tvalid      : in  STD_LOGIC;
      s_axis_tready      : out STD_LOGIC;
      s_axis_tdata       : in  STD_LOGIC_VECTOR(15 downto 0);
      s_axis_tuser       : in  STD_LOGIC_VECTOR( 0 downto 0);

      m_axis_aclk        : in  STD_LOGIC;
      m_axis_tvalid      : out STD_LOGIC;
      m_axis_tready      : in  STD_LOGIC;
      m_axis_tdata       : out STD_LOGIC_VECTOR(15 downto 0);
      m_axis_tuser       : out STD_LOGIC_VECTOR( 0 downto 0);

      axis_wr_data_count : out STD_LOGIC_VECTOR(31 downto 0);
      axis_rd_data_count : out STD_LOGIC_VECTOR(31 downto 0);
      almost_empty       : out STD_LOGIC;
      almost_full        : out STD_LOGIC
      );
  end component sample_fifo;


begin

  rst_sn              <= not reset;
  debug_leds_p        <= debug_leds_s;
  ddr_rst_s           <= reset;
  adc_clk_sn          <= adc_clk_s;
  -- s_axis_cdc_tvalid_s <= adc_data_or_s(0);
  -- m_axis_tready_s     <= adc_data_or_s(0);

  -- TODO: Drive FIFO write using register and FIFO read using internal logic
  process(clk_125_s)
  begin
    if rising_edge(clk_125_s) then
      -- almost_full_s
      s_axis_cdc_tvalid_s <= adc_data_or_s(0) and s_axis_cdc_tready_s;
      m_axis_tready_s     <= not almost_empty_s;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- Differential signal primitives
  -----------------------------------------------------------------------------
  u_IBUFDS_clk_125 : IBUFDS
    generic map (
      DQS_BIAS => "FALSE"
      )
    port map (
      O  => clk_125_s,
      I  => clk_125_p,
      IB => clk_125_n
      );

  g_ADC_DATA: for adc_bit_i in 0 to (NUM_ADC_BITS/2)-1 generate
    u_IBUFDS_data : IBUFDS
      generic map (
        DQS_BIAS => "FALSE"
        )
      port map (
        O  => adc_data_s(adc_bit_i),
        I  => adc_data_in_p(adc_bit_i),
        IB => adc_data_in_n(adc_bit_i)
        );
  end generate g_ADC_DATA;

  u_IBUFDS_clk : IBUFDS
    generic map (
      DQS_BIAS => "FALSE"
      )
    port map (
      O  => adc_clk_s,
      I  => adc_clk_in_p,
      IB => adc_clk_in_n
      );

  u_IBUFDS_data_or : IBUFDS
    generic map (
      DQS_BIAS => "FALSE"
      )
    port map (
      O  => adc_data_or_s(0),
      I  => adc_data_or_p,
      IB => adc_data_or_n
      );


  -----------------------------------------------------------------------------
  -- DDR Delay
  -----------------------------------------------------------------------------
  g_ADC_DDR_DELAY: for adc_delay_bit_i in 0 to (NUM_ADC_BITS/2)-1 generate
    IDELAYE3_inst : IDELAYE3
      generic map (
        CASCADE          => "NONE",
        DELAY_FORMAT     => "TIME",                 -- DELAY_VALUE is specified in ps
        DELAY_SRC        => "IDATAIN",              -- Delay input (IDATAIN=Logic, DATAIN=IOBUF)
        DELAY_TYPE       => "FIXED",                -- Set the type of tap delay line (FIXED, VAR_LOAD, VARIABLE)
        DELAY_VALUE      => DDR_DATA_DELAY,         -- Input delay value setting
        IS_CLK_INVERTED  => '0',                    -- Optional inversion for CLK
        IS_RST_INVERTED  => '0',                    -- Optional inversion for RST
        REFCLK_FREQUENCY => DDR_DELAY_REF_CLK_FREQ, -- IDELAYCTRL clock input frequency in MHz (VALUES)
        SIM_DEVICE       => "ULTRASCALE_PLUS",
        UPDATE_MODE      => "ASYNC"                 -- Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
        )
      port map (
        CASC_OUT    => open,
        CNTVALUEOUT => open,
        DATAOUT     => adc_delayed_data_s(adc_delay_bit_i), -- 1-bit output: Delayed data output
        CASC_IN     => '0',
        CASC_RETURN => '0',
        CE          => '0',                         -- 1-bit input: Active high enable increment/decrement input
        CLK         => adc_clk_s,                   -- 1-bit input: Clock input
        CNTVALUEIN  => "000000000",                 -- 9-bit input: Counter value input
        DATAIN      => adc_data_s(adc_delay_bit_i), -- 1-bit input: Data input from the IOBUF
        EN_VTC      => '0',                         -- 1-bit input: Keep delay constant over VT
        IDATAIN     => adc_data_s(adc_delay_bit_i), -- 1-bit input: Data input from the logic
        INC         => '0',                         -- 1-bit input: Increment / Decrement tap delay input
        LOAD        => '0',                         -- 1-bit input: Load DELAY_VALUE input
        RST         => ddr_rst_s                    -- 1-bit input: Asynchronous Reset to the DELAY_VALUE
        );

  end generate g_ADC_DDR_DELAY;


  -----------------------------------------------------------------------------
  -- DDR Sampling
  -----------------------------------------------------------------------------
  g_ADC_DDR_DATA: for adc_ddr_bit_i in 0 to (NUM_ADC_BITS/2)-1 generate
    u_IDDRE1_data : IDDRE1
      generic map (
        DDR_CLK_EDGE => "OPPOSITE_EDGE",
        IS_C_INVERTED => '0'
        )
      port map (
        Q1 => adc_sample_r(adc_ddr_bit_i*2),
        Q2 => adc_sample_r((adc_ddr_bit_i*2)+1),
        C  => adc_clk_s,
        CB => adc_clk_sn,
        D  => adc_delayed_data_s(adc_ddr_bit_i),
        R  => ddr_rst_s
        );
  end generate g_ADC_DDR_DATA;


  -----------------------------------------------------------------------------
  -- CDC FIFO
  -----------------------------------------------------------------------------
  cdc_fifo: sample_fifo
    port map (
      s_axis_aresetn     => rst_sn,
      s_axis_aclk        => adc_clk_s,
      s_axis_tvalid      => s_axis_cdc_tvalid_s,
      s_axis_tready      => s_axis_cdc_tready_s,
      s_axis_tdata       => adc_sample_r,
      s_axis_tuser       => adc_data_or_s,

      m_axis_aclk        => clk_125_s,
      m_axis_tvalid      => open,
      m_axis_tready      => m_axis_tready_s,
      m_axis_tdata       => open,
      m_axis_tuser       => open,

      axis_wr_data_count => open,
      axis_rd_data_count => open,
      almost_empty       => almost_empty_s,
      almost_full        => almost_full_s
      );


  -----------------------------------------------------------------------------
  -- SPI
  -----------------------------------------------------------------------------
  u_spi: entity work.three_wire_spi_top(rtl)
    generic map (
      NUM_ADDR_BITS_G => 13,
      NUM_DATA_BITS_G =>  8,

      AXI_REGS_ADDR_WIDTH_G =>  5,
      AXI_REGS_DATA_WIDTH_G => 32
      )
    port map (
      -- Control lines
      spi_clk_in_p         => spi_clk_in,

      -- SPI interface
      sclk_p               => spi_clk,
      sdio_p               => spi_sdio,
      csn_p                => spi_csn,

      -- AXI
      s_axi_regs_aclk_p    => s_axi_regs_aclk_p,
      s_axi_regs_aresetn_p => s_axi_regs_aresetn_p,
      s_axi_regs_awaddr_p  => s_axi_regs_awaddr_p,
      s_axi_regs_awprot_p  => s_axi_regs_awprot_p,
      s_axi_regs_awvalid_p => s_axi_regs_awvalid_p,
      s_axi_regs_awready_p => s_axi_regs_awready_p,
      s_axi_regs_wdata_p   => s_axi_regs_wdata_p,
      s_axi_regs_wstrb_p   => s_axi_regs_wstrb_p,
      s_axi_regs_wvalid_p  => s_axi_regs_wvalid_p,
      s_axi_regs_wready_p  => s_axi_regs_wready_p,
      s_axi_regs_bresp_p   => s_axi_regs_bresp_p,
      s_axi_regs_bvalid_p  => s_axi_regs_bvalid_p,
      s_axi_regs_bready_p  => s_axi_regs_bready_p,
      s_axi_regs_araddr_p  => s_axi_regs_araddr_p,
      s_axi_regs_arprot_p  => s_axi_regs_arprot_p,
      s_axi_regs_arvalid_p => s_axi_regs_arvalid_p,
      s_axi_regs_arready_p => s_axi_regs_arready_p,
      s_axi_regs_rdata_p   => s_axi_regs_rdata_p,
      s_axi_regs_rresp_p   => s_axi_regs_rresp_p,
      s_axi_regs_rvalid_p  => s_axi_regs_rvalid_p,
      s_axi_regs_rready_p  => s_axi_regs_rready_p 
      );

end rtl;
