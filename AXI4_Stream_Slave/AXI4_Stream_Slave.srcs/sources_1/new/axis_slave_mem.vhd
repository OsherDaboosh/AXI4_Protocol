library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axis_slave_mem is
    generic(flow_sim       : boolean := true);
       Port(s_axis_aclk    : in std_logic;
            s_axis_aresetn : in std_logic;
            s_axis_tready  : out std_logic;
            s_axis_tdata   : in std_logic_vector(31 downto 0);
            s_axis_tstrb   : in std_logic_vector(3 downto 0);
            s_axis_tkeep   : in std_logic_vector(3 downto 0);
            s_axis_tlast   : in std_logic;
            s_axis_tvalid  : in std_logic);
end axis_slave_mem;

architecture Behavioral of axis_slave_mem is

type data_memory_type is array (0 to 127) of std_logic_vector(31 downto 0);
signal data_memory : data_memory_type := (others=>(others=>'0'));
signal memory_address : integer range 0 to 127;
signal s_axis_aresetn_reg : std_logic;
signal lfsr : std_logic_vector(5 downto 0);
signal tready : std_logic;
begin

process(s_axis_aclk)
begin
    if rising_edge(s_axis_aclk) then
        s_axis_aresetn_reg <= s_axis_aresetn;
        if (s_axis_aresetn = '0') then
            lfsr <= "000111";
        elsif((s_axis_tvalid = '1') or (s_axis_tvalid = '0' and lfsr(5) = '0')) then
            lfsr(0) <= lfsr(5) xor lfsr(4) xor '1';
            lfsr(5 downto 1) <= lfsr(4 downto 0);
        end if;
    end if;
end process;

tready <= '0' when s_axis_aresetn = '0' or s_axis_aresetn_reg = '0' else lfsr(5) when flow_sim else '1';

s_axis_tready <= tready;

process(s_axis_aclk)
begin
    if rising_edge(s_axis_aclk) then
        if (s_axis_aresetn = '0') then
            memory_address <= 0;
        else
            if ((s_axis_tvalid = '1') and (tready = '1')) then
                memory_address <= memory_address + 1;
            end if;
            if ((s_axis_tlast = '1') and (s_axis_tvalid = '1') and (tready = '1')) then
                memory_address <= 0;
            end if;
        end if;
    end if;
end process;

process(s_axis_aclk)
begin
    if rising_edge(s_axis_aclk) then
        if ((s_axis_tvalid = '1') and (tready = '1')) then
            data_memory(memory_address) <= s_axis_tdata;
        end if;
    end if;
end process;
end Behavioral;
