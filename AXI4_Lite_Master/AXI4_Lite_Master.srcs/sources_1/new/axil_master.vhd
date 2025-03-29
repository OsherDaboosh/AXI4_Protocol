library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity axil_master is
	port (
		M_AXI_ACLK	    : in std_logic;
		M_AXI_ARESETN	: in std_logic;

		M_AXI_AWVALID	: out std_logic;
		M_AXI_AWREADY	: in  std_logic;
		M_AXI_AWADDR	: out std_logic_vector(23 downto 0);
		M_AXI_AWPROT	: out std_logic_vector(1 downto 0);

		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in  std_logic;
		M_AXI_WDATA 	: out std_logic_vector(31 downto 0);
		M_AXI_WSTRB 	: out std_logic_vector(3 downto 0);

		M_AXI_BVALID	: in  std_logic;
		M_AXI_BREADY	: out std_logic;
		M_AXI_BRESP 	: in  std_logic_vector(1 downto 0);

		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in  std_logic;
		M_AXI_ARADDR	: out std_logic_vector(23 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(1 downto 0);

		M_AXI_RVALID	: in  std_logic;
		M_AXI_RREADY	: out std_logic;
		M_AXI_RDATA 	: in  std_logic_vector(31 downto 0);
		M_AXI_RRESP 	: in  std_logic_vector(1 downto 0);

    WRITE         : in  std_logic;
    WRITE_ADDRESS : in  std_logic_vector(23 downto 0);
    WRITE_DATA    : in  std_logic_vector(31 downto 0);
    READ          : in  std_logic;
    READ_ADDRESS  : in  std_logic_vector(23 downto 0);
    READ_DATA     : out std_logic_vector(31 downto 0)
	);
end axil_master;
 
architecture Behavioral of axil_master is

signal timer             : integer range 0 to 15;
constant TIMEOUT         : integer := 15;

type state_type is (INIT,STANDBY,WADDR_VALID,WADDR_ACCEPT,WADDR_ERROR,WDATA_ACCEPT,
                    WDATA_ERROR,WAIT_RESPONSE,ACCEPT_RESPONSE,RESPONSE_ERROR,
                    RADDR_VALID,RADDR_ACCEPT,RDATA_VALID,RDATA_ERROR);
signal state,next_state : state_type;

begin

process(M_AXI_ACLK)
begin
  if M_AXI_ACLK'event and M_AXI_ACLK = '1' then
    if M_AXI_ARESETN = '0' then
      state <= INIT;
    else
      state <= next_state;
    end if;
  end if;
end process;

process(state,WRITE,READ,M_AXI_AWREADY,M_AXI_WREADY,timer,M_AXI_BVALID,M_AXI_ARREADY,M_AXI_RVALID)
begin
  next_state <= state;
  case state is
    when INIT =>
      next_state <= STANDBY;
    when STANDBY =>
      if WRITE = '1' then
        next_state <= WADDR_VALID;
      elsif READ = '1' then
        next_state <= RADDR_VALID;
      end if;
    when WADDR_VALID =>
      if M_AXI_AWREADY = '1' and M_AXI_WREADY = '1' then
        next_state <= WDATA_ACCEPT;
      elsif M_AXI_AWREADY = '1' then
        next_state <= WADDR_ACCEPT;
      elsif timer = TIMEOUT then
        next_state <= WADDR_ERROR;
      end if;
    when WADDR_ACCEPT =>
      if M_AXI_WREADY = '1' then
        next_state <= WDATA_ACCEPT;
      elsif timer = TIMEOUT then
        next_state <= WDATA_ERROR;
      end if;
    when WADDR_ERROR =>
      next_state <= WAIT_RESPONSE;
     when WDATA_ACCEPT =>
      if M_AXI_BVALID = '1' then
        next_state <= ACCEPT_RESPONSE;
      else
        next_state <= WAIT_RESPONSE;
      end if;
    when WAIT_RESPONSE =>
      if M_AXI_BVALID = '1' then
        next_state <= ACCEPT_RESPONSE;
      elsif timer = TIMEOUT then
        next_state <= RESPONSE_ERROR;
      end if;
    when ACCEPT_RESPONSE =>
      next_state <= INIT;
    when RESPONSE_ERROR =>
      next_state <= INIT;
    when RADDR_VALID =>
      if M_AXI_ARREADY = '1' then
        next_state <= RADDR_ACCEPT;
      elsif timer = TIMEOUT then
        next_state <= RESPONSE_ERROR;
      end if;
    when RADDR_ACCEPT =>
      if M_AXI_RVALID = '1' then
        next_state <= INIT;
      else
        next_state <= RDATA_VALID;
      end if;
    when RDATA_VALID =>
      if M_AXI_RVALID = '1' then
        next_state <= INIT;
       elsif timer = TIMEOUT then
        next_state <= RDATA_ERROR;
      end if;
    when RDATA_ERROR =>
      next_state <= INIT;
    when others =>
      next_state <= INIT;
  end case;
end process;

process(M_AXI_ACLK)
begin
if M_AXI_ACLK'event and M_AXI_ACLK = '1' then
  if M_AXI_ARESETN = '0' then
      M_AXI_AWVALID <= '0';
      M_AXI_AWADDR  <= (others => '0');
      M_AXI_AWPROT  <= (others => '0');
      M_AXI_WVALID  <= '0';
      M_AXI_WDATA   <= (others => '0');
      M_AXI_WSTRB   <= (others => '0');
      M_AXI_BREADY  <= '0';
      M_AXI_ARVALID <= '0';
      M_AXI_ARADDR  <= (others => '0');
      M_AXI_ARPROT  <= (others => '0');
      M_AXI_RREADY  <= '0';
  else    
  case next_state is
    when INIT =>
      M_AXI_AWVALID <= '0';
      M_AXI_AWADDR  <= (others => '0');
      M_AXI_AWPROT  <= (others => '0');
      M_AXI_WVALID  <= '0';
      M_AXI_WDATA   <= (others => '0');
      M_AXI_WSTRB   <= (others => '1');
      M_AXI_BREADY  <= '0';
      M_AXI_ARVALID <= '0';
      M_AXI_ARADDR  <= (others => '0');
      M_AXI_ARPROT  <= (others => '0');
      M_AXI_RREADY  <= '0';
    when STANDBY =>

    when WADDR_VALID =>
      M_AXI_AWVALID <= '1';
      M_AXI_WVALID  <= '1';
      M_AXI_AWADDR  <= WRITE_ADDRESS;
      M_AXI_WDATA   <= WRITE_DATA;
    when WADDR_ACCEPT =>
      M_AXI_AWVALID <= '0';
    when WADDR_ERROR =>

    when WDATA_ACCEPT =>
      M_AXI_AWVALID <= '0';
      M_AXI_WVALID  <= '0';
      M_AXI_WDATA   <= (others => '0');
      M_AXI_BREADY  <= '1';
    when WDATA_ERROR =>

    when WAIT_RESPONSE =>
      M_AXI_BREADY  <= '1';
    when ACCEPT_RESPONSE =>
      M_AXI_BREADY  <= '0';
    when RESPONSE_ERROR =>

    when RADDR_VALID =>
      M_AXI_ARADDR  <= read_address;
      M_AXI_ARVALID <= '1';
      M_AXI_RREADY  <= '1';
    when RADDR_ACCEPT =>
      M_AXI_ARVALID <= '0';
    when RDATA_VALID =>
      M_AXI_RREADY  <= '1';
    when RDATA_ERROR =>

  when others =>
     null;
    end case;
  end if;
end if;
end process;

end Behavioral;