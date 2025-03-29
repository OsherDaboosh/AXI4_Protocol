library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axil_led_switch is
    Port(S_AXI_ACLK    : in std_logic;
         S_AXI_ARESETN : in std_logic;
         -- Write Address Channel Signals
         S_AXI_AWVALID : in std_logic;
         S_AXI_AWREADY : out std_logic;
         S_AXI_AWADDR  : in  std_logic_vector(3 downto 0);
         -- Write Data Channel Signals
         S_AXI_WDATA   : in std_logic_vector(31 downto 0);
         S_AXI_WSTRB   : in std_logic_vector(3 downto 0);
         S_AXI_WVALID  : in std_logic;
         S_AXI_WREADY  : out std_logic;
         -- Write Response Channel Signals
         S_AXI_BVALID  : out std_logic;
         S_AXI_BREADY  : in std_logic;
         S_AXI_BRESP   : out std_logic_vector(1 downto 0);
         -- Read Address Channel Signals
         S_AXI_ARVALID : in std_logic;
		 S_AXI_ARREADY : out std_logic;
		 S_AXI_ARADDR  : in  std_logic_vector(3 downto 0);
		 -- Read Data Channel Signals
		 S_AXI_RDATA   : out std_logic_vector(31 downto 0);
         S_AXI_RVALID  : out std_logic;
		 S_AXI_RREADY  : in std_logic;
		 S_AXI_RRESP   : out std_logic_vector(1 downto 0);
		 -- Switches and LEDs
		 sw            : in std_logic_vector(1 downto 0);
		 leds          : out std_logic_vector(3 downto 0));
end axil_led_switch;

architecture Behavioral of axil_led_switch is

constant DIV       : unsigned(31 downto 0) := x"02FAF080";  -- 50,000,000 in hex

signal clk1HZ      : std_logic := '0';

signal count       : unsigned(31 downto 0) := (others=>'0');

signal led_select  : integer range 0 to 3 := 0;

-- Write address enable signal: Ensures address handshake happens only once per write.
signal aw_en       : std_logic := '1';  
-- Indicates the slave is ready to accept the write address from the master.
signal axi_awready : std_logic := '0'; 
-- Indicates the slave is ready to accept the write data from the master.
signal axi_wready  : std_logic := '0';  
-- Indicates the write response is valid and available for the master to read.
signal axi_bvalid  : std_logic := '0';  
-- Write response code: "00" = OKAY, other values may indicate error types.
signal axi_bresp   : std_logic_vector(1 downto 0) := "00";  
-- Indicates the slave is ready to accept a read address from the master.
signal axi_arready : std_logic := '0';  
-- Indicates that valid read data is available for the master to read.
signal axi_rvalid  : std_logic := '0';  
-- Read response code: "00" = OKAY, others indicate errors.
signal axi_rresp   : std_logic_vector(1 downto 0) := "00";  
-- The actual 32-bit data returned to the master during a read transaction.
signal axi_rdata   : std_logic_vector(31 downto 0) := (others => '0');  
-- User-defined register 0: Holds the value written by the master (e.g., switch input or control).
signal slave_reg   : std_logic_vector(31 downto 0) := (others => '0');  

begin

-- AXIL signal assignments
S_AXI_AWREADY <= axi_awready;
S_AXI_WREADY  <= axi_wready;
S_AXI_BVALID  <= axi_bvalid;
S_AXI_BRESP   <= axi_bresp;
S_AXI_ARREADY <= axi_arready;
S_AXI_RVALID  <= axi_rvalid;
S_AXI_RRESP   <= axi_rresp;
S_AXI_RDATA   <= axi_rdata;

-- Clock Divider
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            clk1HZ <= '0';
            count  <= (others=>'0');
        elsif(count = DIV-1) then
            clk1HZ <= not clk1HZ;
            count  <= (others=>'0');
        else
            count  <= count + 1;
        end if;
    end if;
end process;

process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            led_select <= 0;
        elsif(clk1HZ = '1') then
            if(led_select = 3) then
                led_select <= 0;
            else
                led_select <= led_select + 1;
            end if;
        end if;
    end if;
end process;

-- LED Control Logic: Hardware override (based on switch state)
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            leds <= (others=>'0');
        else
            case sw is 
                when "00"   => leds <= slave_reg(3 downto 0); -- Software Control
                when "01"   => leds <= "0001";
                when "10"   => leds <= "0010";
                when others => 
                    case led_select is
                        when 0 => leds <= "0001";
                        when 1 => leds <= "0011";
                        when 2 => leds <= "0111";
                        when others => leds <= "1111";
                    end case;
            end case;
        end if;
    end if;
end process;

-- Write Address Handshake
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            axi_awready <= '0';
            aw_en <= '1';
        elsif((S_AXI_AWVALID = '1') and (S_AXI_WVALID = '1') and (axi_awready = '0') and (aw_en = '1')) then
            axi_awready <= '1';
            aw_en <= '0';
        else
            axi_awready <= '0';
            aw_en <= '1';
        end if;
    end if;
end process;

-- Write Data Handshake
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            axi_wready <= '0';
        elsif((S_AXI_AWVALID = '1') and (S_AXI_WVALID = '1') and (axi_wready = '0')) then
            axi_wready <= '1';
            if(S_AXI_WSTRB(0) = '1') then
                slave_reg <= S_AXI_WDATA;
            end if;
        else
            axi_wready <= '0';
        end if;
    end if;
end process;

-- Write Response Logic
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            axi_bvalid <= '0';
            axi_bresp  <= "00";
        elsif((axi_awready = '1') and (axi_wready = '1') and (axi_bvalid = '0')) then
            axi_bvalid <= '1';
            axi_bresp  <= "00"; -- OKAY
        elsif((S_AXI_BREADY = '1') and (axi_bvalid = '1')) then
            axi_bvalid <= '0';
        end if;
    end if;
end process;
            
-- Read Address Handshake
process(S_AXI_ACLK)
begin
    if rising_edge(S_AXI_ACLK) then
        if(S_AXI_ARESETN = '0') then
            axi_arready <= '0';
            axi_rvalid  <= '0';
        elsif((S_AXI_ARVALID = '1') and (axi_arready = '0')) then
            axi_arready <= '1';
            axi_rvalid  <= '1';
            axi_rresp   <= "00";
            axi_rdata   <= slave_reg;
        elsif((axi_rvalid = '1') and (S_AXI_RREADY = '1')) then
            axi_rvalid <= '0';
            axi_arready <= '0';
        end if;
    end if;
end process;
end Behavioral;
