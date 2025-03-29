library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity s_axis_slave_mem_tb is
--  Port ( );
end s_axis_slave_mem_tb;

architecture Behavioral of s_axis_slave_mem_tb is

component axis_slave_mem is
    Port(s_axis_aclk    : in std_logic;
         s_axis_aresetn : in std_logic;
         s_axis_tready  : out std_logic;
         s_axis_tdata   : in std_logic_vector(31 downto 0);
         s_axis_tstrb   : in std_logic_vector(3 downto 0);
         s_axis_tkeep   : in std_logic_vector(3 downto 0);
         s_axis_tlast   : in std_logic;
         s_axis_tvalid  : in std_logic);
end component;
constant CLK_PERIOD   : time := 100ns;
signal s_axis_aclk    : std_logic := '0';
signal s_axis_aresetn : std_logic;
signal s_axis_tready  : std_logic;
signal s_axis_tvalid  : std_logic;
signal s_axis_tdata   : std_logic_vector(31 downto 0);
signal s_axis_tstrb   : std_logic_vector(3 downto 0);
signal s_axis_tkeep   : std_logic_vector(3 downto 0);
signal s_axis_tlast   : std_logic;
signal lfsr           : std_logic_vector(5 downto 0) := "110000";
signal tlast          : std_logic;
begin

U1: axis_slave_mem port map(s_axis_aclk    => s_axis_aclk,
                            s_axis_aresetn => s_axis_aresetn,
                            s_axis_tready  => s_axis_tready,
                            s_axis_tdata   => s_axis_tdata,
                            s_axis_tstrb   => s_axis_tstrb,
                            s_axis_tvalid  => s_axis_tvalid,
                            s_axis_tkeep   => s_axis_tkeep,
                            s_axis_tlast   => s_axis_tlast);

s_axis_aclk <= not s_axis_aclk after CLK_PERIOD/2;

process(s_axis_aclk)
begin
    if rising_edge(s_axis_aclk) then
        if ((s_axis_tready = '1') or (s_axis_tready = '0' and lfsr(5) = '0')) then
            lfsr(0) <= lfsr(5) xor lfsr(4) xor '1';
            lfsr(5 downto 1) <= lfsr(4 downto 0);
        end if;
    end if;
end process;

s_axis_tvalid <= lfsr(5);
s_axis_tlast  <= lfsr(5) and tlast;

process
begin
    s_axis_aresetn <= '0';
    s_axis_tstrb   <= "1111";
    s_axis_tkeep   <= "1111";
    tlast          <= '0';
    s_axis_tdata   <= (others=>'0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    s_axis_aresetn <= '1';
    wait for CLK_PERIOD;
    
    for i in 0 to 5 loop 
        for j in 0 to 127 loop 
            s_axis_tdata <= std_logic_vector(to_unsigned(j, 32));
            if (j = 127) then
                tlast <= '1';
            else
                tlast <= '0';
            end if;
            wait until rising_edge(s_axis_aclk) and s_axis_tvalid = '1' and s_axis_tready = '1';
        end loop;
    end loop;
end process;
end Behavioral;
