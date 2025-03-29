library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axil_slave is
    Port(S_AXI_ACLK    : in std_logic;
         S_AXI_ARESETN : in std_logic;
         -- Write Address Channel Signals
         S_AXI_AWVALID : in std_logic;
         S_AXI_AWREADY : out std_logic;
         S_AXI_AWADDR  : in std_logic_vector(23 downto 0);
         -- Write Data Channel Signals
         S_AXI_WVALID  : in std_logic;
         S_AXI_WREADY  : out std_logic;
         S_AXI_WDATA   : in std_logic_vector(31 downto 0);
         -- Write Response Channel Signals
         S_AXI_BVALID  : out std_logic;
         S_AXI_BREADY  : in std_logic;
         S_AXI_BRESP   : out std_logic_vector(1 downto 0);
         -- Read Address Channel Signals
         S_AXI_ARVALID : in std_logic;
		 S_AXI_ARREADY : out std_logic;
		 S_AXI_ARADDR  : in std_logic_vector(23 downto 0);
		 -- Read Data Channel Signals
         S_AXI_RVALID  : out std_logic;
		 S_AXI_RREADY  : in std_logic;
		 S_AXI_RDATA   : out std_logic_vector(31 downto 0);
		 S_AXI_RRESP   : out std_logic_vector(1 downto 0));
end axil_slave;

architecture Behavioral of axil_slave is

-- Protocol Response Constants
constant OKAY   : std_logic_vector(1 downto 0) := "00";  -- Successful transaction
constant DECERR : std_logic_vector(1 downto 0) := "11";  -- Decode error (invalid address)

-- Timeout Logic Constants and Signals
constant TIMEOUT : integer := 15;            -- Max wait cycles before abort/reset
signal   timer   : integer range 0 to 15;    -- Current timeout counter

-- FSM States and Control Signals
type state_type is (
    INIT, WRR_READY, WADDR_ACCEPT, WADDR_INRANGE, WADDR_ERROR,
    WRITE_READY, WRITE_OK, WRITE_ERROR,
    BRESP_VALID, BRESP_ACCEPT, BRESP_ERROR,
    RADDR_ACCEPT, RADDR_INRANGE, RADDR_ERROR,
    RDATA_VALID, RDATA_OK, RDATA_ERROR
);

signal state      : state_type;  -- Current FSM state
signal next_state : state_type;  -- Next FSM state

-- Memory Block and Addressing
type data_memory_type is array (0 to 127) of std_logic_vector(31 downto 0);
signal data_memory    : data_memory_type := (others => (others => '0'));  -- RAM block
signal memory_address : integer range 0 to 127;                           -- Address pointer

-- Control and Status Registers
signal control_register : std_logic_vector(31 downto 0);  -- Control register (writable)
signal status_register  : std_logic_vector(31 downto 0);  -- Status register (readable)

-- AXI Read/Write Internal Signals
signal read_address          : std_logic_vector(23 downto 0);  -- Captured read address
signal write_address         : std_logic_vector(23 downto 0);  -- Captured write address
signal write_data            : std_logic_vector(31 downto 0);  -- Captured write data
signal write_address_inrange : std_logic;                      -- Address range checker for write
signal read_address_inrange  : std_logic;                      -- Address range checker for read

-- Address Range Constants
constant WRITE_BASE_ADDRESS : std_logic_vector(23 downto 0) := X"000000"; -- Min write address
constant WRITE_LAST_ADDRESS : std_logic_vector(23 downto 0) := X"000200"; -- Max write address
constant READ_BASE_ADDRESS  : std_logic_vector(23 downto 0) := X"000000"; -- Min read address
constant READ_LAST_ADDRESS  : std_logic_vector(23 downto 0) := X"000200"; -- Max read address

begin

process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            state <= INIT;
        else
            state <= next_state;
        end if;
    end if;
end process;

write_address_inrange <= '1' when (write_address >= WRITE_BASE_ADDRESS) and (write_address <= WRITE_LAST_ADDRESS) else '0';

read_address_inrange <= '1' when (read_address >= READ_BASE_ADDRESS) and (read_address <= READ_LAST_ADDRESS) else '0';

process(state,S_AXI_AWVALID,S_AXI_WVALID,S_AXI_BREADY,write_address_inrange,S_AXI_ARVALID,read_address_inrange,S_AXI_RREADY)
begin
    next_state <= state;
    case state is 
        when INIT =>
            next_state <= WRR_READY;
        when WRR_READY =>
            if(S_AXI_AWVALID = '1') then
                next_state <= WADDR_ACCEPT;
            elsif(S_AXI_ARVALID = '1') then
                next_state <= RADDR_ACCEPT;
            end if;
        when WADDR_ACCEPT =>
            if(write_address_inrange = '1') then
                next_state <= WADDR_INRANGE;
            else
                next_state <= WADDR_ERROR;
            end if;
        when WADDR_INRANGE =>
            next_state <= WRITE_READY;
        when WADDR_ERROR =>
            next_state <= BRESP_VALID;
        when WRITE_READY =>
            if(S_AXI_WVALID = '1') then
                next_state <= WRITE_OK;
            elsif(timer = TIMEOUT) then
                next_state <= INIT;
            end if;
        when WRITE_OK =>
            next_state <= BRESP_VALID;
        when WRITE_ERROR =>
            next_state <= BRESP_VALID;
        when BRESP_VALID =>
            if(S_AXI_BREADY = '1') then
                next_state <= BRESP_ACCEPT;
            elsif(timer = TIMEOUT) then
                next_state <= INIT;
            end if;
        when BRESP_ACCEPT =>
            next_state <= INIT;
        when BRESP_ERROR =>
            next_state <= INIT;
        when RADDR_ACCEPT =>
            if(read_address_inrange = '1') then
                next_state <= RADDR_INRANGE;
            else
                next_state <= RADDR_ERROR;
            end if;
        when RADDR_INRANGE =>
            if(S_AXI_RREADY = '1') then
                next_state <= RDATA_VALID;
            elsif(timer = TIMEOUT) then
                next_state <= INIT;
            end if;
        when RADDR_ERROR =>
            next_state <= INIT;
        when RDATA_VALID =>
            next_state <= RDATA_OK;
        when RDATA_OK =>
            next_state <= INIT;
        when RDATA_ERROR => 
            next_state <= INIT;
        when others => 
            next_state <= INIT;
    end case;
end process;
            
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            S_AXI_AWREADY <= '0';
            S_AXI_WREADY  <= '0';
            S_AXI_BVALID  <= '0';
            S_AXI_BRESP   <= "00";
            S_AXI_ARREADY <= '0';
            S_AXI_RVALID  <= '0';
            S_AXI_RRESP   <= "00";
        else
            case next_state is
                when INIT =>
                    S_AXI_AWREADY <= '0';
                    S_AXI_WREADY  <= '0';
                    S_AXI_BVALID  <= '0';
                    S_AXI_BRESP   <= "00";
                    S_AXI_ARREADY <= '0';
                    S_AXI_RVALID  <= '0';
                    S_AXI_RRESP   <= "00";
                when WRR_READY =>
                    S_AXI_AWREADY <= '1';
                    S_AXI_ARREADY <= '1';
                    write_address <= S_AXI_AWADDR;
                    read_address  <= S_AXI_ARADDR;
                when WADDR_ACCEPT =>
                    S_AXI_AWREADY <= '0';
                    S_AXI_ARREADY <= '0';
                    write_address <= S_AXI_AWADDR;
                when WADDR_INRANGE => 

                when WADDR_ERROR =>

                when WRITE_READY =>
                    S_AXI_WREADY  <= '1';
                    write_data <= S_AXI_WDATA;
                    timer <= timer+1;
                when WRITE_OK =>
                    timer <= 0;
                    S_AXI_BRESP   <= OKAY;
                    S_AXI_WREADY  <= '0';
                when WRITE_ERROR =>
                    S_AXI_BRESP   <= DECERR;
                    S_AXI_WREADY  <= '0';
                when BRESP_VALID =>
                    S_AXI_BVALID  <= '1';
                    timer <= timer+1;
                when BRESP_ACCEPT =>
                    S_AXI_BVALID  <= '0';
                    S_AXI_BRESP   <= OKAY;
                    timer <= 0;
                when BRESP_ERROR =>

                when RADDR_ACCEPT =>
                    read_address  <= S_AXI_ARADDR;
                    S_AXI_AWREADY <= '0';
                    S_AXI_ARREADY <= '0';
                when RADDR_INRANGE =>
                    S_AXI_RRESP   <= OKAY;
                    timer <= timer+1;
                when RADDR_ERROR =>
                    S_AXI_RRESP   <= DECERR;
                when RDATA_VALID =>
                    S_AXI_RVALID  <= '1';
                    S_AXI_RRESP   <= "00";
                    timer <= 0;
                when RDATA_OK =>
                    S_AXI_RVALID  <= '0';
                when RDATA_ERROR =>
                    S_AXI_RVALID  <= '0';
                when others =>
                    null;
            end case;
        end if;
    end if;
end process;

process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(state = WRITE_OK) then
            case write_address is
                when x"000004" =>
                    control_register <= write_data;
                when others =>
                    null;
            end case;
        end if;
    end if;
end process;

process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        case read_address(23 downto 8) is
            when x"0000" =>
                case read_address(7 downto 0) is
                    when X"04" => 
                        S_AXI_RDATA <= control_register;
                    when others =>
                        null;
                end case;
            when x"0001" => 
                S_AXI_RDATA <= data_memory(to_integer(unsigned(read_address(7 downto 2))));
            when others =>
                null;
        end case;
    end if;
end process;
            
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if((state = WRITE_OK) and (write_address(23 downto 8) = x"0001")) then
            data_memory(to_integer(unsigned(write_address(7 downto 2)))) <= write_data;
        end if;
    end if;
end process;
end Behavioral;
