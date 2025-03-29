library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axis_master_adc_tb is
--  Port ( );
end axis_master_adc_tb;

architecture Behavioral of axis_master_adc_tb is

component axis_master_adc is
    Port(adc_clk        : in std_logic;
         adc_data       : in std_logic_vector(13 downto 0);
         m_axis_aclk    : in std_logic;
         m_axis_aresetn : in std_logic;
         m_axis_tready  : in std_logic;
         m_axis_tdata   : out std_logic_vector(15 downto 0);
         m_axis_tstrb   : out std_logic_vector(1 downto 0);
         m_axis_tkeep   : out std_logic_vector(1 downto 0);
         m_axis_tlast   : out std_logic;
         m_axis_tvalid  : out std_logic);
end component;

component adc_model is
    Port(adc_clk  : in std_logic;
         adc_data : out std_logic_vector(13 downto 0));
end component;

signal adc_clk        : std_logic := '0';
signal adc_data       : std_logic_vector(13 downto 0);
signal m_axis_aclk	  : std_logic := '0';
signal m_axis_aresetn : std_logic;
signal m_axis_tready  : std_logic;
signal m_axis_tdata	  : std_logic_vector(15 downto 0);
signal m_axis_tstrb	  : std_logic_vector(1 downto 0);
signal m_axis_tkeep	  : std_logic_vector(1 downto 0);
signal m_axis_tlast	  : std_logic;
signal m_axis_tvalid  : std_logic;
signal lfsr           : std_logic_vector(5 downto 0):= "100000";

signal data_check     : std_logic_vector(15 downto 0);
signal rem_value      : std_logic_vector(15 downto 0);
signal error          : std_logic;
signal tlast_error    : std_logic;

begin

U1: axis_master_adc port map(adc_clk => adc_clk,
                             adc_data => adc_data,
                             m_axis_aclk => m_axis_aclk,
                             m_axis_aresetn => m_axis_aresetn,
                             m_axis_tready => m_axis_tready,
                             m_axis_tdata => m_axis_tdata,
                             m_axis_tstrb => m_axis_tstrb,
                             m_axis_tkeep => m_axis_tkeep,
                             m_axis_tlast => m_axis_tlast,
                             m_axis_tvalid => m_axis_tvalid);

U2: adc_model port map(adc_clk => adc_clk,
                       adc_data => adc_data);

adc_clk <= not adc_clk after 50ns;
m_axis_aclk <= not m_axis_aclk after 20ns;
m_axis_aresetn <= '0', '1' after 160ns;

process(m_axis_aclk)
begin
    if rising_edge(m_axis_aclk) then
        lfsr(0) <= lfsr(5) xor lfsr(4) xor '1';
        lfsr(5 downto 1) <= lfsr(4 downto 0);
    end if;
end process;

m_axis_tready <= lfsr(5);

process
begin
  wait until m_axis_aclk'event and m_axis_aclk = '1' and m_axis_tvalid = '1' and lfsr(5) = '1';
  data_check <= m_axis_tdata;
  rem_value  <= m_axis_tdata;
  wait for 1 ns;
  while TRUE loop
    data_check <= std_logic_vector(unsigned(data_check) + 1);
    wait until m_axis_aclk'event and m_axis_aclk = '1' and m_axis_tvalid = '1' and lfsr(5) = '1';
    if m_axis_tdata /= data_check then
      error <= '1';
    else
      error <= '0';
    end if;
    if ((to_integer(unsigned(m_axis_tdata)) rem 64 /= to_integer(unsigned(rem_value))) and m_axis_tlast = '1') then
      tlast_error <= '1';
    else
      tlast_error <= '0';
    end if;
  end loop;
end process;
end Behavioral;
