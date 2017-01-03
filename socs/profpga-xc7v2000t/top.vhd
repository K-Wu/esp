------------------------------------------------------------------------------
--  ESP - profpga - TA1 - xc7v2000t
------------------------------------------------------------------------------
-- DISCLAIMER --
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.memctrl.all;
use work.memoryctrl.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
use work.jtag.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.coretypes.all;
use work.config.all;
use work.socmap.all;
use work.soctiles.all;

entity top is
  generic (
    fabtech             : integer := CFG_FABTECH;
    memtech             : integer := CFG_MEMTECH;
    padtech             : integer := CFG_PADTECH;
    disas               : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart             : integer := CFG_DUART;   -- Print UART on console
    pclow               : integer := CFG_PCLOW;
    testahb             : boolean := false;
    SIM_BYPASS_INIT_CAL : string := "OFF";
    SIMULATION          : string := "FALSE";
    USE_MIG_INTERFACE_MODEL : boolean := false;
    autonegotiation     : integer := 1
  );
  port (
    -- MMI64 interface:
    profpga_clk0_p        : in  std_ulogic;  -- 100 MHz clock
    profpga_clk0_n        : in  std_ulogic;  -- 100 MHz clock
    profpga_sync0_p       : in  std_ulogic;
    profpga_sync0_n       : in  std_ulogic;
    dmbi_h2f              : in  std_ulogic_vector(19 downto 0);
    dmbi_f2h              : out std_ulogic_vector(19 downto 0);
    --
    reset                 : in    std_ulogic;
    clkp_0          : in    std_ulogic;  -- 160 MHz clock
    clkn_0          : in    std_ulogic;  -- 160 MHz clock
    clkp_1          : in    std_ulogic;  -- 160 MHz clock
    clkn_1          : in    std_ulogic;  -- 160 MHz clock
    clk_ref_p       : in    std_ulogic;  -- 200 MHz clock
    clk_ref_n       : in    std_ulogic;  -- 200 MHz clock
    --dsu_break      : in    std_ulogic;
    --pragma translate_off
    address         : out   std_logic_vector(25 downto 0);
    data            : inout std_logic_vector(15 downto 0);
    oen             : out   std_ulogic;
    writen          : out   std_ulogic;
    romsn           : out   std_logic;
    adv             : out   std_logic;
    --pragma translate_on
    c0_ddr3_dq         : inout std_logic_vector(63 downto 0);
    c0_ddr3_dqs_p      : inout std_logic_vector(7 downto 0);
    c0_ddr3_dqs_n      : inout std_logic_vector(7 downto 0);
    c0_ddr3_addr       : out   std_logic_vector(14 downto 0);
    c0_ddr3_ba         : out   std_logic_vector(2 downto 0);
    c0_ddr3_ras_n      : out   std_logic;
    c0_ddr3_cas_n      : out   std_logic;
    c0_ddr3_we_n       : out   std_logic;
    c0_ddr3_reset_n    : out   std_logic;
    c0_ddr3_ck_p       : out   std_logic_vector(0 downto 0);
    c0_ddr3_ck_n       : out   std_logic_vector(0 downto 0);
    c0_ddr3_cke        : out   std_logic_vector(0 downto 0);
    c0_ddr3_cs_n       : out   std_logic_vector(0 downto 0);
    c0_ddr3_dm         : out   std_logic_vector(7 downto 0);
    c0_ddr3_odt        : out   std_logic_vector(0 downto 0);
    c0_calib_complete  : out   std_logic;
    c1_ddr3_dq         : inout std_logic_vector(63 downto 0);
    c1_ddr3_dqs_p      : inout std_logic_vector(7 downto 0);
    c1_ddr3_dqs_n      : inout std_logic_vector(7 downto 0);
    c1_ddr3_addr       : out   std_logic_vector(14 downto 0);
    c1_ddr3_ba         : out   std_logic_vector(2 downto 0);
    c1_ddr3_ras_n      : out   std_logic;
    c1_ddr3_cas_n      : out   std_logic;
    c1_ddr3_we_n       : out   std_logic;
    c1_ddr3_reset_n    : out   std_logic;
    c1_ddr3_ck_p       : out   std_logic_vector(0 downto 0);
    c1_ddr3_ck_n       : out   std_logic_vector(0 downto 0);
    c1_ddr3_cke        : out   std_logic_vector(0 downto 0);
    c1_ddr3_cs_n       : out   std_logic_vector(0 downto 0);
    c1_ddr3_dm         : out   std_logic_vector(7 downto 0);
    c1_ddr3_odt        : out   std_logic_vector(0 downto 0);
    c1_calib_complete  : out   std_logic;
    dsurx           : in    std_ulogic;
    dsutx           : out   std_ulogic;
    dsuctsn         : in    std_ulogic;
    dsurtsn         : out   std_ulogic;
    -- Ethernet signals
    reset_o2  : out   std_ulogic;
    etx_clk   : in    std_ulogic;
    erx_clk   : in    std_ulogic;
    erxd      : in    std_logic_vector(3 downto 0);
    erx_dv    : in    std_ulogic;
    erx_er    : in    std_ulogic;
    erx_col   : in    std_ulogic;
    erx_crs   : in    std_ulogic;
    etxd      : out   std_logic_vector(3 downto 0);
    etx_en    : out   std_ulogic;
    etx_er    : out   std_ulogic;
    emdc      : out   std_ulogic;
    emdio     : inout std_logic;
    -- DVI
    tft_nhpd        : in  std_ulogic;   -- Hot plug
    tft_clk_p       : out std_ulogic;
    tft_clk_n       : out std_ulogic;
    tft_data        : out std_logic_vector(23 downto 0);
    tft_hsync       : out std_ulogic;
    tft_vsync       : out std_ulogic;
    tft_de          : out std_ulogic;
    tft_dken        : out std_ulogic;
    tft_ctl1_a1_dk1 : out std_ulogic;
    tft_ctl2_a2_dk2 : out std_ulogic;
    tft_a3_dk3      : out std_ulogic;
    tft_isel        : out std_ulogic;
    tft_bsel        : out std_logic;
    tft_dsel        : out std_logic;
    tft_edge        : out std_ulogic;
    tft_npd         : out std_ulogic;

    LED_RED         : out   std_ulogic;
    LED_GREEN       : out   std_ulogic;
    LED_BLUE        : out   std_ulogic;
    LED_YELLOW      : out   std_ulogic;
    rst_led         : out   std_ulogic;
    rstraw_led      : out   std_ulogic;
    rstn_led        : out   std_ulogic;
    migrstn_led     : out   std_ulogic;
    diagnostic_led  : out   std_ulogic
   );
end;


architecture rtl of top is

component ahb2mig_7series_profpga
  generic(
    hindex     : integer := 0;
    haddr      : integer := 0;
    hmask      : integer := 16#f00#;
    pmask      : integer := 16#fff#
  );
  port(
    app_addr          : out   std_logic_vector(28 downto 0);
    app_cmd           : out   std_logic_vector(2 downto 0);
    app_en            : out   std_logic;      
    app_wdf_data      : out   std_logic_vector(511 downto 0);
    app_wdf_end       : out   std_logic;      
    app_wdf_mask      : out   std_logic_vector(63 downto 0);
    app_wdf_wren      : out   std_logic;      
    app_rd_data       : in    std_logic_vector(511 downto 0);
    app_rd_data_end   : in    std_logic;
    app_rd_data_valid : in    std_logic;
    app_rdy           : in    std_logic;
    app_wdf_rdy       : in    std_logic;
    ahbso             : out   ahb_slv_out_type;
    ahbsi             : in    ahb_slv_in_type;
    clk_amba          : in    std_logic;
    rst_n_syn         : in    std_logic
   );
end component ;

component mig is
  port (
   c0_ddr3_dq              : inout std_logic_vector(63 downto 0);
   c0_ddr3_addr            : out   std_logic_vector(14 downto 0);
   c0_ddr3_ba              : out   std_logic_vector(2 downto 0);
   c0_ddr3_ras_n           : out   std_logic;
   c0_ddr3_cas_n           : out   std_logic;
   c0_ddr3_we_n            : out   std_logic;
   c0_ddr3_reset_n         : out   std_logic;
   c0_ddr3_dqs_n           : inout std_logic_vector(7 downto 0);
   c0_ddr3_dqs_p           : inout std_logic_vector(7 downto 0);
   c0_ddr3_ck_p            : out   std_logic_vector(0 downto 0);
   c0_ddr3_ck_n            : out   std_logic_vector(0 downto 0);
   c0_ddr3_cke             : out   std_logic_vector(0 downto 0);
   c0_ddr3_cs_n            : out   std_logic_vector(0 downto 0);
   c0_ddr3_dm              : out   std_logic_vector(7 downto 0);
   c0_ddr3_odt             : out   std_logic_vector(0 downto 0);
   c1_ddr3_dq              : inout std_logic_vector(63 downto 0);
   c1_ddr3_addr            : out   std_logic_vector(14 downto 0);
   c1_ddr3_ba              : out   std_logic_vector(2 downto 0);
   c1_ddr3_ras_n           : out   std_logic;
   c1_ddr3_cas_n           : out   std_logic;
   c1_ddr3_we_n            : out   std_logic;
   c1_ddr3_reset_n         : out   std_logic;
   c1_ddr3_dqs_n           : inout std_logic_vector(7 downto 0);
   c1_ddr3_dqs_p           : inout std_logic_vector(7 downto 0);
   c1_ddr3_ck_p            : out   std_logic_vector(0 downto 0);
   c1_ddr3_ck_n            : out   std_logic_vector(0 downto 0);
   c1_ddr3_cke             : out   std_logic_vector(0 downto 0);
   c1_ddr3_cs_n            : out   std_logic_vector(0 downto 0);
   c1_ddr3_dm              : out   std_logic_vector(7 downto 0);
   c1_ddr3_odt             : out   std_logic_vector(0 downto 0);
   c0_app_addr             : in    std_logic_vector(28 downto 0);
   c0_app_cmd              : in    std_logic_vector(2 downto 0);
   c0_app_en               : in    std_logic;
   c0_app_wdf_data         : in    std_logic_vector(511 downto 0);
   c0_app_wdf_end          : in    std_logic;
   c0_app_wdf_mask         : in    std_logic_vector(63 downto 0);
   c0_app_wdf_wren         : in    std_logic;
   c0_app_rd_data          : out   std_logic_vector(511 downto 0);
   c0_app_rd_data_end      : out   std_logic;
   c0_app_rd_data_valid    : out   std_logic;
   c0_app_rdy              : out   std_logic;
   c0_app_wdf_rdy          : out   std_logic;
   c0_app_sr_req           : in    std_logic;
   c0_app_ref_req          : in    std_logic;
   c0_app_zq_req           : in    std_logic;
   c0_app_sr_active        : out   std_logic;
   c0_app_ref_ack          : out   std_logic;
   c0_app_zq_ack           : out   std_logic;
   c0_sys_clk_p            : in    std_logic;
   c0_sys_clk_n            : in    std_logic;
   c1_app_addr             : in    std_logic_vector(28 downto 0);
   c1_app_cmd              : in    std_logic_vector(2 downto 0);
   c1_app_en               : in    std_logic;
   c1_app_wdf_data         : in    std_logic_vector(511 downto 0);
   c1_app_wdf_end          : in    std_logic;
   c1_app_wdf_mask         : in    std_logic_vector(63 downto 0);
   c1_app_wdf_wren         : in    std_logic;
   c1_app_rd_data          : out   std_logic_vector(511 downto 0);
   c1_app_rd_data_end      : out   std_logic;
   c1_app_rd_data_valid    : out   std_logic;
   c1_app_rdy              : out   std_logic;
   c1_app_wdf_rdy          : out   std_logic;
   c1_app_sr_req           : in    std_logic;
   c1_app_ref_req          : in    std_logic;
   c1_app_zq_req           : in    std_logic;
   c1_app_sr_active        : out   std_logic;
   c1_app_ref_ack          : out   std_logic;
   c1_app_zq_ack           : out   std_logic;
   c1_sys_clk_p            : in    std_logic;
   c1_sys_clk_n            : in    std_logic;
   clk_ref_p               : in    std_logic;  -- 200 MHz clock
   clk_ref_n               : in    std_logic;  -- 200 MHz clock
   c0_ui_clk               : out   std_logic;
   c0_ui_clk_sync_rst      : out   std_logic;
   c0_init_calib_complete  : out   std_logic;
   c1_ui_clk               : out   std_logic;
   c1_ui_clk_sync_rst      : out   std_logic;
   c1_init_calib_complete  : out   std_logic;
   sys_rst              : in    std_logic
   );
end component mig;

-- pragma translate_off
-- Memory model for simulation purposes only
component ahbram_sim
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    tech    : integer := DEFMEMTECH; 
    kbytes  : integer := 1;
    pipe    : integer := 0;
    maccsz  : integer := AHBDW;
    fname   : string  := "ram.dat"
   );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end component ;

-- Signals for memory controller used to boot in simulation
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
-- pragma translate_on


-- constants
signal vcc, gnd   : std_logic_vector(31 downto 0);

-- Switches
signal sel0, sel1, sel2, sel3, sel4 : std_ulogic;

-- clock and reset
signal clkm, clkm_2 : std_ulogic := '0';
signal rstn, rstraw : std_ulogic;
signal lock, rst : std_ulogic;
signal migrstn : std_logic;

---mig0 signals
signal c0_app_addr          : std_logic_vector(28 downto 0);
signal c0_app_cmd           : std_logic_vector(2 downto 0);
signal c0_app_en            : std_ulogic;
signal c0_app_wdf_data      : std_logic_vector(511 downto 0);
signal c0_app_wdf_end       : std_ulogic;
signal c0_app_wdf_mask      : std_logic_vector(63 downto 0); 
signal c0_app_wdf_wren      : std_ulogic;
signal c0_app_rd_data       : std_logic_vector(511 downto 0);
signal c0_app_rd_data_end   : std_ulogic;
signal c0_app_rd_data_valid : std_ulogic;
signal c0_app_rdy           : std_ulogic;
signal c0_app_wdf_rdy       : std_ulogic;
signal c0_calib_done        : std_ulogic;
---mig0 signals
signal c1_app_addr          : std_logic_vector(28 downto 0);
signal c1_app_cmd           : std_logic_vector(2 downto 0);
signal c1_app_en            : std_ulogic;
signal c1_app_wdf_data      : std_logic_vector(511 downto 0);
signal c1_app_wdf_end       : std_ulogic;
signal c1_app_wdf_mask      : std_logic_vector(63 downto 0); 
signal c1_app_wdf_wren      : std_ulogic;
signal c1_app_rd_data       : std_logic_vector(511 downto 0);
signal c1_app_rd_data_end   : std_ulogic;
signal c1_app_rd_data_valid : std_ulogic;
signal c1_app_rdy           : std_ulogic;
signal c1_app_wdf_rdy       : std_ulogic;
signal c1_calib_done        : std_ulogic;

-- Ethernet signals
signal ethi : eth_in_type;
signal etho : eth_out_type;

-- Tiles
--pragma translate_off
signal mctrl_ahbsi : ahb_slv_in_type;
signal mctrl_ahbso : ahb_slv_out_type;
signal mctrl_apbi  : apb_slv_in_type;
signal mctrl_apbo  : apb_slv_out_type;
signal mctrl_clk   : std_ulogic;
--pragma translate_on

-- Memory controller DDR3
signal ddr0_ahbsi   : ahb_slv_in_type;
signal ddr0_ahbso   : ahb_slv_out_type;
signal ddr1_ahbsi   : ahb_slv_in_type;
signal ddr1_ahbso   : ahb_slv_out_type;

-- Ethernet
constant BOARD_FREQ : integer := 160000;   -- input frequency in KHz
constant BOARD_CLKMUL : integer := 4;
constant BOARD_CLKDIV : integer := 8;
constant CPU_FREQ : integer := BOARD_FREQ * BOARD_CLKMUL / BOARD_CLKDIV;  -- cpu frequency in KHz
signal eth0_apbi : apb_slv_in_type;
signal eth0_apbo : apb_slv_out_type;
signal sgmii0_apbi : apb_slv_in_type;
signal sgmii0_apbo : apb_slv_out_type;
signal eth0_ahbmi : ahb_mst_in_type;
signal eth0_ahbmo : ahb_mst_out_type;

-- DVI

component svga2tfp410
  generic (
    tech    : integer);
  port (
    clk         : in  std_ulogic;
    rstn        : in  std_ulogic;
    vgaclk_fb   : in  std_ulogic;
    vgao        : in  apbvga_out_type;
    vgaclk      : out std_ulogic;
    idck_p      : out std_ulogic;
    idck_n      : out std_ulogic;
    data        : out std_logic_vector(23 downto 0);
    hsync       : out std_ulogic;
    vsync       : out std_ulogic;
    de          : out std_ulogic;
    dken        : out std_ulogic;
    ctl1_a1_dk1 : out std_ulogic;
    ctl2_a2_dk2 : out std_ulogic;
    a3_dk3      : out std_ulogic;
    isel        : out std_ulogic;
    bsel        : out std_ulogic;
    dsel        : out std_ulogic;
    edge        : out std_ulogic;
    npd         : out std_ulogic);
end component;

signal dvi_apbi : apb_slv_in_type;
signal dvi_apbo : apb_slv_out_type;
signal dvi_ahbmi : ahb_mst_in_type;
signal dvi_ahbmo : ahb_mst_out_type;

signal dvi_nhpd        : std_ulogic;
signal dvi_data        : std_logic_vector(23 downto 0);
signal dvi_hsync       : std_ulogic;
signal dvi_vsync       : std_ulogic;
signal dvi_de          : std_ulogic;
signal dvi_dken        : std_ulogic;
signal dvi_ctl1_a1_dk1 : std_ulogic;
signal dvi_ctl2_a2_dk2 : std_ulogic;
signal dvi_a3_dk3      : std_ulogic;
signal dvi_isel        : std_ulogic;
signal dvi_bsel        : std_ulogic;
signal dvi_dsel        : std_ulogic;
signal dvi_edge        : std_ulogic;
signal dvi_npd         : std_ulogic;

signal vgao  : apbvga_out_type;
signal clkvga, clkvga_p, clkvga_n : std_ulogic;

attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of clkvga : signal is true;
attribute syn_preserve of clkvga : signal is true;
attribute keep : boolean;
attribute keep of clkvga : signal is true;

-- DSU
signal ndsuact     : std_ulogic;
signal dsuerr      : std_ulogic;

-- NOC
signal chip_rst : std_ulogic;
signal noc_clk : std_ulogic;
signal chip_refclk : std_ulogic;
signal chip_pllbypass : std_logic_vector(CFG_TILES_NUM-1 downto 0);
signal chip_pllclk : std_ulogic;


signal vdd_ivr : std_logic_vector(CFG_TILES_NUM-1 downto 0);
signal vref : std_logic_vector(CFG_TILES_NUM-1 downto 0);
attribute keep of clkm : signal is true;
attribute keep of clkm_2 : signal is true;

signal diagnostic_count : std_logic_vector(26 downto 0);
signal diagnostic_toggle : std_ulogic;

-- MMI64
signal user_rstn        : std_ulogic;
signal mon_ddr          : monitor_ddr_vector(0 to CFG_MIG_DUAL);
signal mon_noc          : monitor_noc_matrix(1 to 6, 0 to CFG_TILES_NUM-1);
signal mon_noc_actual   : monitor_noc_matrix(0 to 1, 0 to CFG_TILES_NUM-1);
signal mon_acc          : monitor_acc_vector(0 to accelerators_num-1);
signal mon_dvfs         : monitor_dvfs_vector(0 to CFG_TILES_NUM-1);

begin

  diagnostic: process (clkm, rstn)
  begin  -- process diagnostic
    if rstn = '0' then                  -- asynchronous reset (active low)
      diagnostic_count <= (others => '0');
    elsif clkm'event and clkm = '1' then  -- rising clock edge
      diagnostic_count <= diagnostic_count + 1;
    end if;
  end process diagnostic;
  diagnostic_toggle <= diagnostic_count(26);
  led_diag_pad : outpad generic map (tech => padtech, level => cmos, voltage => x15v) port map (diagnostic_led, diagnostic_toggle);

-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------

  -- From DSU 0 (on chip)
  dsuact_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v) port map (LED_GREEN, ndsuact);

  -- From CPU 0 (on chip)
  led1_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v) port map (LED_RED, dsuerr);
  --pragma translate_off
  process(clkm, rstn)
  begin  -- process
    if rstn = '1' then
      assert dsuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- From DDR controller (on FPGA)
  calib0_complete_pad : outpad generic map (tech => padtech, level => cmos, voltage => x15v) port map (c0_calib_complete, c0_calib_done);
  calib1_complete_pad : outpad generic map (tech => padtech, level => cmos, voltage => x15v) port map (c1_calib_complete, c1_calib_done);

  led3_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v) port map (LED_BLUE, lock);

  led4_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v) port map (LED_YELLOW, ddr0_ahbso.hready);

  led_rst_pad : outpad generic map (tech => padtech, level => cmos, voltage => x15v) port map (rst_led, rst);
  led_rstn_pad : outpad generic map (tech => padtech, level => cmos, voltage => x15v) port map (rstn_led, rstn);
  led_migrstn_pad : outpad generic map (tech => padtech, level => cmos, voltage => x15v) port map (migrstn_led, migrstn);
  led_rstraw_pad : outpad generic map (tech => padtech, level => cmos, voltage => x15v) port map (rstraw_led, rstraw);

-------------------------------------------------------------------------------
-- Switches -------------------------------------------------------------------
-------------------------------------------------------------------------------

  --sw0_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
  --  port map (switch(0), '0', '1', sel0);
  --sw1_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
  --  port map (switch(1), '0', '1', sel1);
  --sw2_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
  --  port map (switch(2), '0', '1', sel2);
  --sw3_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
  --  port map (switch(3), '0', '1', sel3);
  --sw4_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
  --  port map (switch(4), '0', '1', sel4);
  sel0 <= '1';
  sel1 <= '0';
  sel2 <= '0';
  sel3 <= '0';
  sel4 <= '0';

-------------------------------------------------------------------------------
-- Buttons --------------------------------------------------------------------
-------------------------------------------------------------------------------

  --pio_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
  --  port map (button(i-4), gpioi.din(i));

----------------------------------------------------------------------
--- FPGA Reset and Clock generation  ---------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');

  reset_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v) port map (reset, rst);
  rst0 : rstgen         -- reset generator
  generic map (acthigh => 1, syncin => 0)
  port map (rst, clkm, lock, rstn, rstraw);
  lock <= c0_calib_done and c1_calib_done;

  rst1 : rstgen         -- reset generator
  generic map (acthigh => 1)
  port map (rst, clkm, lock, migrstn, open);

  -- pragma translate_off
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------
  -- Memory controller is required for current testbench, because it drives a
  -- boot ROM. On the final system, instead, there is no ROM and the system
  -- boots from DRAM thanks to grmon and the DSU.
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "01";
  memi.brdyn <= '0'; memi.bexcn <= '1';

  mctrl0 : mctrl generic map (hindex => 0, pindex => 0,
                              paddr => 0, srbanks => 2, ram8 => 1,
                              ram16 => 1, sden => CFG_MCTRL_SDEN,
                              invclk => 0, sepbus => CFG_MCTRL_SEPBUS,
                              pageburst => CFG_MCTRL_PAGE, rammask => 0, iomask => 0)
    port map (rstn, mctrl_clk, memi, memo, mctrl_ahbsi, mctrl_ahbso, mctrl_apbi, mctrl_apbo, wpo, sdo);

  addr_pad : outpadv generic map (width => 26, tech => padtech, level => cmos, voltage => x18v)
    port map (address(25 downto 0), memo.address(26 downto 1));
  roms_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (romsn, memo.romsn(0));
  oen_pad  : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (oen, memo.oen);
  adv_pad  : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (adv, '0');
  wri_pad  : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (writen, memo.writen);
  data_pad : iopadvv generic map (tech => padtech, width => 16, level => cmos, voltage => x18v)
    port map (data(15 downto 0), memo.data(31 downto 16),
              memo.vbdrive(31 downto 16), memi.data(31 downto 16));
  -- pragma translate_on



----------------------------------------------------------------------
---  DDR3 memory controller ------------------------------------------
----------------------------------------------------------------------

  gen_mig : if (USE_MIG_INTERFACE_MODEL /= true) generate

     dual_mig_ahb_iface: if CFG_MIG_DUAL = 1 generate
       ddrc0 : ahb2mig_7series_profpga generic map(
         hindex => 4, haddr => 16#400#, hmask => 16#E00#)
         port map(
           app_addr          => c0_app_addr,
           app_cmd           => c0_app_cmd,
           app_en            => c0_app_en,
           app_wdf_data      => c0_app_wdf_data,
           app_wdf_end       => c0_app_wdf_end,
           app_wdf_mask      => c0_app_wdf_mask,
           app_wdf_wren      => c0_app_wdf_wren,
           app_rd_data       => c0_app_rd_data,
           app_rd_data_end   => c0_app_rd_data_end,
           app_rd_data_valid => c0_app_rd_data_valid,
           app_rdy           => c0_app_rdy,
           app_wdf_rdy       => c0_app_wdf_rdy,
           ahbsi             => ddr0_ahbsi,
           ahbso             => ddr0_ahbso,
           rst_n_syn         => migrstn,
           clk_amba          => clkm
           );

       ddrc1 : ahb2mig_7series_profpga generic map(
         hindex => 5, haddr => 16#600#, hmask => 16#E00#)
         port map(
           app_addr          => c1_app_addr,
           app_cmd           => c1_app_cmd,
           app_en            => c1_app_en,
           app_wdf_data      => c1_app_wdf_data,
           app_wdf_end       => c1_app_wdf_end,
           app_wdf_mask      => c1_app_wdf_mask,
           app_wdf_wren      => c1_app_wdf_wren,
           app_rd_data       => c1_app_rd_data,
           app_rd_data_end   => c1_app_rd_data_end,
           app_rd_data_valid => c1_app_rd_data_valid,
           app_rdy           => c1_app_rdy,
           app_wdf_rdy       => c1_app_wdf_rdy,
           ahbsi             => ddr1_ahbsi,
           ahbso             => ddr1_ahbso,
           rst_n_syn         => migrstn,
           clk_amba          => clkm_2
           );
     end generate dual_mig_ahb_iface;

     single_mig_ahb_iface: if CFG_MIG_DUAL = 0 generate
       ddrc0 : ahb2mig_7series_profpga generic map(
         hindex => 4, haddr => 16#400#, hmask => 16#C00#)
         port map(
           app_addr          => c0_app_addr,
           app_cmd           => c0_app_cmd,
           app_en            => c0_app_en,
           app_wdf_data      => c0_app_wdf_data,
           app_wdf_end       => c0_app_wdf_end,
           app_wdf_mask      => c0_app_wdf_mask,
           app_wdf_wren      => c0_app_wdf_wren,
           app_rd_data       => c0_app_rd_data,
           app_rd_data_end   => c0_app_rd_data_end,
           app_rd_data_valid => c0_app_rd_data_valid,
           app_rdy           => c0_app_rdy,
           app_wdf_rdy       => c0_app_wdf_rdy,
           ahbsi             => ddr0_ahbsi,
           ahbso             => ddr0_ahbso,
           rst_n_syn         => migrstn,
           clk_amba          => clkm
           );

       c1_app_addr <= (others => '0');
       c1_app_cmd <= (others => '0');
       c1_app_en <= '0';
       c1_app_wdf_data <= (others => '0');
       c1_app_wdf_end <= '0';
       c1_app_wdf_mask <= (others => '0');
       c1_app_wdf_wren <= '0';
       ddr1_ahbso <= ahbs_none;
     end generate single_mig_ahb_iface;


     MCB_dual_mig_inst : mig
      port map (
        c0_ddr3_dq              => c0_ddr3_dq,
        c0_ddr3_dqs_p           => c0_ddr3_dqs_p,
        c0_ddr3_dqs_n           => c0_ddr3_dqs_n,
        c0_ddr3_addr            => c0_ddr3_addr,
        c0_ddr3_ba              => c0_ddr3_ba,
        c0_ddr3_ras_n           => c0_ddr3_ras_n,
        c0_ddr3_cas_n           => c0_ddr3_cas_n,
        c0_ddr3_we_n            => c0_ddr3_we_n,
        c0_ddr3_reset_n         => c0_ddr3_reset_n,
        c0_ddr3_ck_p            => c0_ddr3_ck_p,
        c0_ddr3_ck_n            => c0_ddr3_ck_n,
        c0_ddr3_cke             => c0_ddr3_cke,
        c0_ddr3_cs_n            => c0_ddr3_cs_n,
        c0_ddr3_dm              => c0_ddr3_dm,
        c0_ddr3_odt             => c0_ddr3_odt,
        c1_ddr3_dq              => c1_ddr3_dq,
        c1_ddr3_dqs_p           => c1_ddr3_dqs_p,
        c1_ddr3_dqs_n           => c1_ddr3_dqs_n,
        c1_ddr3_addr            => c1_ddr3_addr,
        c1_ddr3_ba              => c1_ddr3_ba,
        c1_ddr3_ras_n           => c1_ddr3_ras_n,
        c1_ddr3_cas_n           => c1_ddr3_cas_n,
        c1_ddr3_we_n            => c1_ddr3_we_n,
        c1_ddr3_reset_n         => c1_ddr3_reset_n,
        c1_ddr3_ck_p            => c1_ddr3_ck_p,
        c1_ddr3_ck_n            => c1_ddr3_ck_n,
        c1_ddr3_cke             => c1_ddr3_cke,
        c1_ddr3_cs_n            => c1_ddr3_cs_n,
        c1_ddr3_dm              => c1_ddr3_dm,
        c1_ddr3_odt             => c1_ddr3_odt,
        c0_sys_clk_p            => clkp_0,
        c0_sys_clk_n            => clkn_0,
        c1_sys_clk_p            => clkp_1,
        c1_sys_clk_n            => clkn_1,
        clk_ref_p               => clk_ref_p,
        clk_ref_n               => clk_ref_n,
        c0_app_addr             => c0_app_addr,
        c0_app_cmd              => c0_app_cmd,
        c0_app_en               => c0_app_en,
        c0_app_wdf_data         => c0_app_wdf_data,
        c0_app_wdf_end          => c0_app_wdf_end,
        c0_app_wdf_mask         => c0_app_wdf_mask,
        c0_app_wdf_wren         => c0_app_wdf_wren,
        c0_app_rd_data          => c0_app_rd_data,
        c0_app_rd_data_end      => c0_app_rd_data_end,
        c0_app_rd_data_valid    => c0_app_rd_data_valid,
        c0_app_rdy              => c0_app_rdy,
        c0_app_wdf_rdy          => c0_app_wdf_rdy,
        c0_app_sr_req           => '0',
        c0_app_ref_req          => '0',
        c0_app_zq_req           => '0',
        c0_app_sr_active        => open,
        c0_app_ref_ack          => open,
        c0_app_zq_ack           => open,
        c0_ui_clk               => clkm,
        c0_ui_clk_sync_rst      => open,
        c0_init_calib_complete  => c0_calib_done,
        c1_app_addr             => c1_app_addr,
        c1_app_cmd              => c1_app_cmd,
        c1_app_en               => c1_app_en,
        c1_app_wdf_data         => c1_app_wdf_data,
        c1_app_wdf_end          => c1_app_wdf_end,
        c1_app_wdf_mask         => c1_app_wdf_mask,
        c1_app_wdf_wren         => c1_app_wdf_wren,
        c1_app_rd_data          => c1_app_rd_data,
        c1_app_rd_data_end      => c1_app_rd_data_end,
        c1_app_rd_data_valid    => c1_app_rd_data_valid,
        c1_app_rdy              => c1_app_rdy,
        c1_app_wdf_rdy          => c1_app_wdf_rdy,
        c1_app_sr_req           => '0',
        c1_app_ref_req          => '0',
        c1_app_zq_req           => '0',
        c1_app_sr_active        => open,
        c1_app_ref_ack          => open,
        c1_app_zq_ack           => open,
        c1_ui_clk               => clkm_2,
        c1_ui_clk_sync_rst      => open,
        c1_init_calib_complete  => c1_calib_done,
        sys_rst                 => rstraw
        );

  end generate gen_mig;

  gen_mig_model : if (USE_MIG_INTERFACE_MODEL = true) generate
    -- pragma translate_off

    dual_mig_sim: if CFG_MIG_DUAL = 1 generate
      mig_ahbram1 : ahbram_sim
        generic map (
          hindex   => 4,
          haddr    => 16#400#,
          hmask    => 16#E00#,
          tech     => 0,
          kbytes   => 1000,
          pipe     => 0,
          maccsz   => AHBDW,
          fname    => "ram.srec"
          )
        port map(
          rst     => rstn,
          clk     => clkm,
          ahbsi   => ddr0_ahbsi,
          ahbso   => ddr0_ahbso
          );

      mig_ahbram2 : ahbram_sim
        generic map (
          hindex   => 5,
          haddr    => 16#600#,
          hmask    => 16#E00#,
          tech     => 0,
          kbytes   => 1000,
          pipe     => 0,
          maccsz   => AHBDW,
          fname    => "ram.srec"
          )
        port map(
          rst     => rstn,
          clk     => clkm,
          ahbsi   => ddr1_ahbsi,
          ahbso   => ddr1_ahbso
          );
    end generate dual_mig_sim;

    single_mig_sim: if CFG_MIG_DUAL = 0 generate
      mig_ahbram1 : ahbram_sim
        generic map (
          hindex   => 4,
          haddr    => 16#400#,
          hmask    => 16#C00#,
          tech     => 0,
          kbytes   => 1000,
          pipe     => 0,
          maccsz   => AHBDW,
          fname    => "ram.srec"
          )
        port map(
          rst     => rstn,
          clk     => clkm,
          ahbsi   => ddr0_ahbsi,
          ahbso   => ddr0_ahbso
          );

      ddr1_ahbso <= ahbs_none;
    end generate single_mig_sim;

    c0_ddr3_dq           <= (others => 'Z');
    c0_ddr3_dqs_p        <= (others => 'Z');
    c0_ddr3_dqs_n        <= (others => 'Z');
    c0_ddr3_addr         <= (others => '0');
    c0_ddr3_ba           <= (others => '0');
    c0_ddr3_ras_n        <= '0';
    c0_ddr3_cas_n        <= '0';
    c0_ddr3_we_n         <= '0';
    c0_ddr3_reset_n      <= '1';
    c0_ddr3_ck_p         <= (others => '0');
    c0_ddr3_ck_n         <= (others => '0');
    c0_ddr3_cke          <= (others => '0');
    c0_ddr3_cs_n         <= (others => '0');
    c0_ddr3_dm           <= (others => '0');
    c0_ddr3_odt          <= (others => '0');

    c0_calib_done <= '1';

    c1_ddr3_dq           <= (others => 'Z');
    c1_ddr3_dqs_p        <= (others => 'Z');
    c1_ddr3_dqs_n        <= (others => 'Z');
    c1_ddr3_addr         <= (others => '0');
    c1_ddr3_ba           <= (others => '0');
    c1_ddr3_ras_n        <= '0';
    c1_ddr3_cas_n        <= '0';
    c1_ddr3_we_n         <= '0';
    c1_ddr3_reset_n      <= '1';
    c1_ddr3_ck_p         <= (others => '0');
    c1_ddr3_ck_n         <= (others => '0');
    c1_ddr3_cke          <= (others => '0');
    c1_ddr3_cs_n         <= (others => '0');
    c1_ddr3_dm           <= (others => '0');
    c1_ddr3_odt          <= (others => '0');

    c1_calib_done <= '1';

    --ui_clk            : out   std_logic;
    clkm <= not clkm after 6.25 ns;
    clkm_2 <= not clkm_2 after 6.25 ns;
    --ui_clk_sync_rst   : out   std_logic
    -- n/a
    -- pragma translate_on
  end generate gen_mig_model;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  reset_o2 <= rstn;
  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
    e1 : grethm
      generic map(
        hindex => CFG_NCPU+CFG_AHB_JTAG,
        pindex => 14,
        paddr => 16#800#,
        pmask => 16#f00#,
        --pindex => 15,
        --paddr => 15,
        pirq => 12,
        memtech => memtech,
        mdcscaler => CPU_FREQ/1000,
        enable_mdio => 1,
        fifosize => CFG_ETH_FIFO,
        nsync => 1,
        edcl => CFG_DSU_ETH,
        edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM,
        macaddrl => CFG_ETH_ENL,
        phyrstadr => 1,
        ipaddrh => CFG_ETH_IPM,
        ipaddrl => CFG_ETH_IPL,
        giga => CFG_GRETH1G)
      port map(
        rst => rstn,
        clk => clkm,
        ahbmi => eth0_ahbmi,
        ahbmo => eth0_ahbmo,
        apbi => eth0_apbi,
        apbo => eth0_apbo,
        ethi => ethi,
        etho => etho);
  end generate;

  ethpads : if (CFG_GRETH = 1) generate -- eth pads
    emdio_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
    etxc_pad : clkpad generic map (tech => padtech, level => cmos, voltage => x18v, arch => 2) 
      port map (etx_clk, ethi.tx_clk);
    erxc_pad : clkpad generic map (tech => padtech, level => cmos, voltage => x18v, arch => 2) 
      port map (erx_clk, ethi.rx_clk);
    erxd_pad : inpadv generic map (tech => padtech, level => cmos, voltage => x18v, width => 4)
      port map (erxd, ethi.rxd(3 downto 0));
    erxdv_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (erx_dv, ethi.rx_dv);
    erxer_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (erx_er, ethi.rx_er);
    erxco_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (erx_col, ethi.rx_col);
    erxcr_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (erx_crs, ethi.rx_crs);

    etxd_pad : outpadv generic map (tech => padtech, level => cmos, voltage => x18v, width => 4)
      port map (etxd, etho.txd(3 downto 0));
    etxen_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (etx_en, etho.tx_en);
    etxer_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (etx_er, etho.tx_er);
    emdc_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdc, etho.mdc);
  end generate;

  no_eth0: if CFG_GRETH = 0 generate
    eth0_apbo <= apb_none;
  end generate no_eth0;

  sgmii0_apbo <= apb_none;

  -----------------------------------------------------------------------------
  -- DVI
  -----------------------------------------------------------------------------

  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(
      memtech => memtech,
      pindex => 13,
      paddr => 6,
      hindex => 0,
      clk0 => 25000,
      clk1 => 25000,
      clk2 => 25000,
      clk3 => 25000,
      burstlen => 6,
      ahbaccsz => CFG_AHBDW)
      port map(
        rst => rstn,
        clk => clkm,
        vgaclk => clkvga,
        apbi => dvi_apbi,
        apbo => dvi_apbo,
        vgao => vgao,
        ahbi => dvi_ahbmi,
        ahbo => dvi_ahbmo,
        clk_sel => open);

    dvi0 : svga2tfp410
      generic map (
        tech    => fabtech)
      port map (
        clk         => clkm,
        rstn        => rstraw,
        vgao        => vgao,
        vgaclk_fb   => clkvga,
        vgaclk      => clkvga,
        idck_p      => clkvga_p,
        idck_n      => clkvga_n,
        data        => dvi_data,
        hsync       => dvi_hsync,
        vsync       => dvi_vsync,
        de          => dvi_de,
        dken        => dvi_dken,
        ctl1_a1_dk1 => dvi_ctl1_a1_dk1,
        ctl2_a2_dk2 => dvi_ctl2_a2_dk2,
        a3_dk3      => dvi_a3_dk3,
        isel        => dvi_isel,
        bsel        => dvi_bsel,
        dsel        => dvi_dsel,
        edge        => dvi_edge,
        npd         => dvi_npd);

  end generate;

  novga : if CFG_SVGA_ENABLE = 0 generate
    dvi_apbo   <= apb_none;
    dvi_ahbmo  <= ahbm_none;
    dvi_data   <= (others => '0');
    clkvga_p   <= '0';
    clkvga_n   <= '0';
    dvi_hsync  <= '0';
    dvi_vsync  <= '0';
    dvi_de     <= '0';
  end generate;

  tft_nhpd_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_nhpd, dvi_nhpd);

  tft_clkp_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_clk_p, clkvga_p);
  tft_clkn_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_clk_n, clkvga_n);

  tft_data_pad : outpadv generic map (width => 24, tech => padtech, level => cmos, voltage => x18v)
    port map (tft_data, dvi_data);
  tft_hsync_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_hsync, dvi_hsync);
  tft_vsync_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_vsync, dvi_vsync);
  tft_de_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_de, dvi_de);

  tft_dken_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_dken, dvi_dken);
  tft_ctl1_a1_dk1_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_ctl1_a1_dk1, dvi_ctl1_a1_dk1);
  tft_ctl2_a2_dk2_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_ctl2_a2_dk2, dvi_ctl2_a2_dk2);
  tft_a3_dk3_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_a3_dk3, dvi_a3_dk3);

  tft_isel_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_isel, dvi_isel);
  tft_bsel_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_bsel, dvi_bsel);
  tft_dsel_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_dsel, dvi_dsel);
  tft_edge_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_edge, dvi_edge);
  tft_npd_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (tft_npd, dvi_npd);

  -----------------------------------------------------------------------------
  -- CHIP
  -----------------------------------------------------------------------------
  chip_rst <= rstn;
  noc_clk <= clkm;
  chip_refclk <= clkm;
  chip_pllbypass <= (others => '0');

  esp_1: esp
    generic map (
      fabtech                 => CFG_FABTECH,
      memtech                 => CFG_MEMTECH,
      padtech                 => CFG_PADTECH,
      disas                   => disas,
      dbguart                 => dbguart,
      pclow                   => pclow,
      testahb                 => testahb,
      has_dvfs                => CFG_HAS_DVFS,
      has_sync                => CFG_HAS_SYNC,
      XLEN                    => CFG_XLEN,
      YLEN                    => CFG_YLEN,
      TILES_NUM               => CFG_TILES_NUM,
      SIM_BYPASS_INIT_CAL     => SIM_BYPASS_INIT_CAL,
      SIMULATION              => SIMULATION,
      USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL,
      autonegotiation         => autonegotiation)
    port map (
      rst           => chip_rst,
      noc_clk       => noc_clk,
      refclk        => chip_refclk,
      mem_clk       => clkm_2,
      pllbypass     => chip_pllbypass,
      --pragma translate_off
      mctrl_ahbsi   => mctrl_ahbsi,
      mctrl_ahbso   => mctrl_ahbso,
      mctrl_apbi    => mctrl_apbi,
      mctrl_apbo    => mctrl_apbo,
      mctrl_clk     => mctrl_clk,
      --pragma translate_on
      dsurx         => dsurx,
      dsutx         => dsutx,
      dsuctsn       => dsuctsn,
      dsurtsn       => dsurtsn,
      ndsuact       => ndsuact,
      dsuerr        => dsuerr,
      ddr0_ahbsi    => ddr0_ahbsi,
      ddr0_ahbso    => ddr0_ahbso,
      ddr1_ahbsi    => ddr1_ahbsi,
      ddr1_ahbso    => ddr1_ahbso,
      eth0_apbi     => eth0_apbi,
      eth0_apbo     => eth0_apbo,
      sgmii0_apbi   => sgmii0_apbi,
      sgmii0_apbo   => sgmii0_apbo,
      eth0_ahbmi    => eth0_ahbmi,
      eth0_ahbmo    => eth0_ahbmo,
      dvi_apbi      => dvi_apbi,
      dvi_apbo      => dvi_apbo,
      dvi_ahbmi     => dvi_ahbmi,
      dvi_ahbmo     => dvi_ahbmo,
      VDD_IVR       => VDD_IVR,
      VREF          => VREF,
      -- Monitor signals
      mon_noc       => mon_noc,
      mon_acc       => mon_acc,
      mon_dvfs      => mon_dvfs
      );


  -- MMI64
  user_rstn <= rstn;

  mon_ddr(0).clk <= clkm;
  detect_ddr_access: process (ddr0_ahbsi, ddr1_ahbsi)
  begin  -- process detect_mem_access
    mon_ddr(0).word_transfer <= '0';

    if ((ddr0_ahbsi.haddr(31 downto 20) xor conv_std_logic_vector(ddr0_haddr, 12))
        and conv_std_logic_vector(ddr0_hmask, 12)) = zero32(31 downto 20) then
      if ddr0_ahbsi.hready = '1' and ddr0_ahbsi.htrans /= HTRANS_IDLE then
        mon_ddr(0).word_transfer <= '1';
      end if;
    end if;
  end process detect_ddr_access;

  dual_mig_monitor: if CFG_MIG_DUAL = 1 generate
    mon_ddr(1).clk <= clkm_2;
    detect_ddr1_access: process (ddr1_ahbsi)
    begin  -- process detect_mem_access
      mon_ddr(1).word_transfer <= '0';

      if ((ddr1_ahbsi.haddr(31 downto 20) xor conv_std_logic_vector(ddr1_haddr, 12))
          and conv_std_logic_vector(ddr1_hmask, 12)) = zero32(31 downto 20) then
        if ddr1_ahbsi.hready = '1' and ddr1_ahbsi.htrans /= HTRANS_IDLE then
          mon_ddr(1).word_transfer <= '1';
        end if;
      end if;
    end process detect_ddr1_access;
  end generate dual_mig_monitor;


  mon_noc_map_gen: for i in 0 to CFG_TILES_NUM-1 generate
    --mon_noc_actual(0,i) <= mon_noc(1,i);
    --mon_noc_actual(1,i) <= mon_noc(3,i);
    mon_noc_actual(0,i) <= mon_noc(4,i);
    --mon_noc_actual(3,i) <= mon_noc(5,i);
    mon_noc_actual(1,i) <= mon_noc(6,i);
  end generate mon_noc_map_gen;

  monitor_1: monitor
    generic map (
      memtech                => CFG_MEMTECH,
      mmi64_width            => 32,
      ddrs_num               => 1 + CFG_MIG_DUAL,
      nocs_num               => 2,
      tiles_num              => CFG_TILES_NUM,
      accelerators_num       => accelerators_num,
      mon_ddr_en             => CFG_MON_DDR_EN,
      mon_noc_tile_inject_en => CFG_MON_NOC_INJECT_EN,
      mon_noc_queues_full_en => CFG_MON_NOC_QUEUES_EN,
      mon_acc_en             => CFG_MON_ACC_EN,
      mon_dvfs_en            => CFG_MON_DVFS_EN)
    port map (
      profpga_clk0_p  => profpga_clk0_p,
      profpga_clk0_n  => profpga_clk0_n,
      profpga_sync0_p => profpga_sync0_p,
      profpga_sync0_n => profpga_sync0_n,
      dmbi_h2f        => dmbi_h2f,
      dmbi_f2h        => dmbi_f2h,
      user_rstn       => user_rstn,
      mon_ddr         => mon_ddr,
      mon_noc         => mon_noc_actual,
      mon_acc         => mon_acc,
      mon_dvfs        => mon_dvfs);

end;
