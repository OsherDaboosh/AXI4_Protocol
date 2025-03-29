library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axis_master_adc is
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
end axis_master_adc;

architecture Behavioral of axis_master_adc is

component async_fifo is
    Port(wr_clk     : in std_logic;
         wr_en      : in std_logic;
         wr_data    : in std_logic_vector(13 downto 0);
         rd_clk     : in std_logic;
         rd_en      : in std_logic;
         rd_data    : out std_logic_vector(13 downto 0);
         fifo_empty : out std_logic;
         fifo_full  : out std_logic);
end component;

signal fifo_empty : std_logic;
signal fifo_full  : std_logic;
signal rd_en      : std_logic;
signal rd_data    : std_logic_vector(13 downto 0);

type state_type is (INIT, VALID_DATA, STALL_DATA, SLAVE_STALL);
signal state, next_state  : state_type;
signal m_axis_aresetn_reg : std_logic;
signal data_count         : integer range 0 to 64;

signal wr_en, wr_en_sync  : std_logic;

begin

fifo_0: async_fifo port map(wr_clk     => adc_clk,
                            wr_en      => wr_en,
                            wr_data    => adc_data,
                            rd_clk     => m_axis_aclk,
                            rd_en      => rd_en,
                            rd_data    => rd_data,
                            fifo_empty => fifo_empty,
                            fifo_full  => fifo_full);

m_axis_tdata(13 downto 0)  <= rd_data;
m_axis_tdata(15 downto 14) <= "00";
m_axis_tkeep               <= "11";
m_axis_tstrb               <= "11";

process(adc_clk) 
begin
    if rising_edge(adc_clk) then
        if (state = INIT) then
            wr_en_sync <= '0';
        else
            wr_en_sync <= '1';
        end if;
        wr_en <= wr_en_sync;
    end if;
end process;

process(state, fifo_empty, m_axis_tready, m_axis_aresetn) 
begin
    next_state <= state;
    case state is
        when INIT =>
            if ((m_axis_aresetn = '0') or (m_axis_aresetn_reg = '0')) then
                next_state <= INIT;
            elsif(fifo_empty = '1') then
                next_state <= STALL_DATA;
            elsif(m_axis_tready = '0') then
                next_state <= SLAVE_STALL;
            elsif((fifo_empty = '0') and (m_axis_tready = '1')) then
                next_state <= VALID_DATA;
            end if;
        when VALID_DATA =>
            if (m_axis_tready = '0') then
                next_state <= SLAVE_STALL;
            elsif(fifo_empty = '1') then
                next_state <= STALL_DATA;
            end if;
        when STALL_DATA =>
            if ((m_axis_tready = '0') and (fifo_empty = '0')) then
                next_state <= SLAVE_STALL;
            elsif(fifo_empty = '0') then
                next_state <= VALID_DATA;
            end if;
        when SLAVE_STALL =>
            if ((m_axis_tready = '1') and (fifo_empty = '0')) then
                next_state <= VALID_DATA;
            elsif(fifo_empty = '1') then
                next_state <= STALL_DATA;
            end if;
        when others => 
            next_state <= INIT;
    end case;
end process;

process(m_axis_aclk) 
begin
    if rising_edge(m_axis_aclk) then
        m_axis_aresetn_reg <= m_axis_aresetn;
        if (m_axis_aresetn = '0') then
            state <= INIT;
        else
            state <= next_state;
        end if;
    end if;
end process;
            
process(m_axis_aclk) 
begin
    if rising_edge(m_axis_aclk) then
        if (next_state = INIT) then
            data_count <= 0;
            m_axis_tlast <= '0';
        elsif((next_state = VALID_DATA) and (data_count = 63)) then
            data_count <= 0;
            m_axis_tlast <= '1';
        elsif(next_state = VALID_DATA) then
            data_count <= data_count + 1;
            m_axis_tlast <= '0';
        end if;
    end if;
end process;

process(next_state)
begin
    case next_state is
        when INIT =>
            m_axis_tvalid <= '0';
            rd_en <= '0';
        when VALID_DATA =>
            m_axis_tvalid <= '1';
            rd_en <= '1';
        when STALL_DATA => 
            m_axis_tvalid <= '0';
            rd_en <= '0';
        when SLAVE_STALL =>
            m_axis_tvalid <= '1';
            rd_en <= '0';
        when others =>
            m_axis_tvalid <= '1';
            rd_en <= '0';
    end case;
end process;
end Behavioral;
