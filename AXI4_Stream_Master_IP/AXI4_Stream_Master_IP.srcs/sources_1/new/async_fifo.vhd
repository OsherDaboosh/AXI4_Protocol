library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity async_fifo is
    Port(wr_clk     : in std_logic;
         wr_en      : in std_logic;
         wr_data    : in std_logic_vector(13 downto 0);
         rd_clk     : in std_logic;
         rd_en      : in std_logic;
         rd_data    : out std_logic_vector(13 downto 0);
         fifo_empty : out std_logic;
         fifo_full  : out std_logic);
end async_fifo;

architecture Behavioral of async_fifo is

signal wr_addr            : std_logic_vector(3 downto 0) := "0000";
signal wr_addr_grey       : std_logic_vector(3 downto 0) := "0000";
signal wr_addr_grey_sync  : std_logic_vector(3 downto 0) := "0000";
signal wr_addr_grey_sync2 : std_logic_vector(3 downto 0) := "0000";
signal wr_addr_sync       : std_logic_vector(3 downto 0) := "0000";

signal rd_addr            : std_logic_vector(3 downto 0) := "0000";
signal rd_addr_grey       : std_logic_vector(3 downto 0) := "0000";
signal rd_addr_grey_sync  : std_logic_vector(3 downto 0) := "0000";
signal rd_addr_grey_sync2 : std_logic_vector(3 downto 0) := "0000";
signal rd_addr_sync       : std_logic_vector(3 downto 0) := "0000";

signal full  : std_logic;
signal empty : std_logic;

type fifo_memory_type is array (0 to 15) of std_logic_vector(13 downto 0);
signal fifo_memory : fifo_memory_type :=(others=>(others=>'0'));

begin

wr_addr_grey <= (wr_addr(3),wr_addr(3) xor wr_addr(2),wr_addr(2) xor wr_addr(1),wr_addr(1) xor wr_addr(0));

wr_addr_sync <= (wr_addr_grey_sync2(3),wr_addr_grey_sync2(3) xor wr_addr_grey_sync2(2),
                 wr_addr_grey_sync2(3) xor wr_addr_grey_sync2(2) xor wr_addr_grey_sync2(1),
                 wr_addr_grey_sync2(3) xor wr_addr_grey_sync2(2) xor wr_addr_grey_sync2(1) xor wr_addr_grey_sync2(0));

rd_addr_grey <= (rd_addr(3),rd_addr(3) xor rd_addr(2),rd_addr(2) xor rd_addr(1),rd_addr(1) xor rd_addr(0));

rd_addr_sync <= (rd_addr_grey_sync2(3),rd_addr_grey_sync2(3) xor rd_addr_grey_sync2(2),
                 rd_addr_grey_sync2(3) xor rd_addr_grey_sync2(2) xor rd_addr_grey_sync2(1),
                 rd_addr_grey_sync2(3) xor rd_addr_grey_sync2(2) xor rd_addr_grey_sync2(1) xor rd_addr_grey_sync2(0));

full       <= '1' when (unsigned(wr_addr) - unsigned(rd_addr_sync)) > 14 else '0';
fifo_full  <= '1' when (unsigned(wr_addr) - unsigned(rd_addr_sync)) > 13 else '0';
empty      <= '1' when rd_addr = wr_addr_sync else '0';
fifo_empty <= empty;

process(wr_clk)
begin
    if rising_edge(wr_clk) then
        if ((full = '0') and (wr_en = '1')) then
            wr_addr <= std_logic_vector(unsigned(wr_addr) + 1);
        end if;
    end if;
end process;

process(wr_clk)
begin
    if rising_edge(wr_clk) then
        rd_addr_grey_sync  <= rd_addr_grey;
        rd_addr_grey_sync2 <= rd_addr_grey_sync;
    end if;
end process;

process(wr_clk)
begin
    if rising_edge(wr_clk) then
        if ((full = '0') and (wr_en = '1')) then
            fifo_memory(to_integer(unsigned(wr_addr))) <= wr_data;
        end if;
    end if;
end process;

rd_data <= fifo_memory(to_integer(unsigned(rd_addr)));

process(rd_clk)
begin
  if rising_edge(rd_clk) then
    wr_addr_grey_sync  <= wr_addr_grey;
    wr_addr_grey_sync2 <= wr_addr_grey_sync;
  end if;
end process;

process(rd_clk)
begin
    if rising_edge(rd_clk) then
        if ((empty = '0') and (rd_en = '1')) then
            rd_addr <= std_logic_vector(unsigned(rd_addr) + 1);
        end if;
    end if;
end process;
end Behavioral;
