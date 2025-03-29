library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity axil_master_tb is
-- Port()
end axil_master_tb;

architecture Behavioral of axil_master_tb is

component axil_slave
	port (
		S_AXI_ACLK	    : in std_logic;
		S_AXI_ARESETN	: in std_logic;

		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_AWADDR	: in std_logic_vector(23 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(1 downto 0);

		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_WDATA 	: in std_logic_vector(31 downto 0);
		S_AXI_WSTROBE	: in std_logic_vector(3 downto 0);

		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_BRESP 	: out std_logic_vector(1 downto 0);

		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_ARADDR	: in std_logic_vector(23 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(1 downto 0);

		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		S_AXI_RDATA 	: out std_logic_vector(31 downto 0);
		S_AXI_RRESP 	: out std_logic_vector(1 downto 0)
	);
end component;

component axil_master
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
		M_AXI_WSTROBE	: out std_logic_vector(3 downto 0);

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

        WRITE           : in  std_logic;
        WRITE_ADDRESS   : in  std_logic_vector(23 downto 0);
        WRITE_DATA      : in  std_logic_vector(31 downto 0);
        READ            : in  std_logic;
        READ_ADDRESS    : in  std_logic_vector(23 downto 0);
        READ_DATA       : out std_logic_vector(31 downto 0)
	);
end component;
 
signal  S_AXI_ACLK	    : std_logic := '0';
signal  S_AXI_ARESETN	: std_logic;
signal  S_AXI_AWVALID	: std_logic;
signal  S_AXI_AWREADY	: std_logic;
signal  S_AXI_AWADDR	: std_logic_vector(23 downto 0);
signal  S_AXI_AWPROT	: std_logic_vector(1 downto 0);
signal  S_AXI_WVALID	: std_logic;
signal  S_AXI_WREADY	: std_logic;
signal  S_AXI_WDATA 	: std_logic_vector(31 downto 0);
signal  S_AXI_WSTROBE	: std_logic_vector(3 downto 0);
signal  S_AXI_BVALID	: std_logic;
signal  S_AXI_BREADY	: std_logic;
signal  S_AXI_BRESP 	: std_logic_vector(1 downto 0);
signal  S_AXI_ARVALID	: std_logic;
signal  S_AXI_ARREADY	: std_logic;
signal  S_AXI_ARADDR	: std_logic_vector(23 downto 0);
signal  S_AXI_ARPROT	: std_logic_vector(1 downto 0);
signal  S_AXI_RVALID	: std_logic;
signal  S_AXI_RREADY	: std_logic;
signal  S_AXI_RDATA 	: std_logic_vector(31 downto 0);
signal  S_AXI_RRESP 	: std_logic_vector(1 downto 0);
signal  WRITE           : std_logic;
signal  WRITE_ADDRESS   : std_logic_vector(23 downto 0);
signal  WRITE_DATA      : std_logic_vector(31 downto 0);
signal  READ            : std_logic;
signal  READ_ADDRESS    : std_logic_vector(23 downto 0);
signal  READ_DATA       : std_logic_vector(31 downto 0);

begin

SLAVE: axil_slave 
port map (  
  S_AXI_ACLK	=> S_AXI_ACLK,
  S_AXI_ARESETN	=> S_AXI_ARESETN,
  S_AXI_AWVALID	=> S_AXI_AWVALID,
  S_AXI_AWREADY	=> S_AXI_AWREADY,
  S_AXI_AWADDR	=> S_AXI_AWADDR,
  S_AXI_AWPROT	=> S_AXI_AWPROT,
  S_AXI_WVALID	=> S_AXI_WVALID,
  S_AXI_WREADY	=> S_AXI_WREADY,
  S_AXI_WDATA 	=> S_AXI_WDATA,
  S_AXI_WSTROBE	=> S_AXI_WSTROBE,
  S_AXI_BVALID	=> S_AXI_BVALID,
  S_AXI_BREADY	=> S_AXI_BREADY,
  S_AXI_BRESP 	=> S_AXI_BRESP,
  S_AXI_ARVALID	=> S_AXI_ARVALID,
  S_AXI_ARREADY	=> S_AXI_ARREADY,
  S_AXI_ARADDR	=> S_AXI_ARADDR,
  S_AXI_ARPROT	=> S_AXI_ARPROT,
  S_AXI_RVALID	=> S_AXI_RVALID,
  S_AXI_RREADY	=> S_AXI_RREADY,
  S_AXI_RDATA 	=> S_AXI_RDATA,
  S_AXI_RRESP 	=> S_AXI_RRESP);

MASTER: axil_master 
port map (  
  M_AXI_ACLK	=> S_AXI_ACLK,
  M_AXI_ARESETN	=> S_AXI_ARESETN,
  M_AXI_AWVALID	=> S_AXI_AWVALID,
  M_AXI_AWREADY	=> S_AXI_AWREADY,
  M_AXI_AWADDR	=> S_AXI_AWADDR,
  M_AXI_AWPROT	=> S_AXI_AWPROT,
  M_AXI_WVALID	=> S_AXI_WVALID,
  M_AXI_WREADY	=> S_AXI_WREADY,
  M_AXI_WDATA 	=> S_AXI_WDATA,
  M_AXI_WSTROBE	=> S_AXI_WSTROBE,
  M_AXI_BVALID	=> S_AXI_BVALID,
  M_AXI_BREADY	=> S_AXI_BREADY,
  M_AXI_BRESP 	=> S_AXI_BRESP,
  M_AXI_ARVALID	=> S_AXI_ARVALID,
  M_AXI_ARREADY	=> S_AXI_ARREADY,
  M_AXI_ARADDR	=> S_AXI_ARADDR,
  M_AXI_ARPROT	=> S_AXI_ARPROT,
  M_AXI_RVALID	=> S_AXI_RVALID,
  M_AXI_RREADY	=> S_AXI_RREADY,
  M_AXI_RDATA 	=> S_AXI_RDATA,
  M_AXI_RRESP 	=> S_AXI_RRESP,
  WRITE         => WRITE,
  WRITE_ADDRESS => WRITE_ADDRESS,
  WRITE_DATA    => WRITE_DATA,
  READ          => READ,
  READ_ADDRESS  => READ_ADDRESS,
  READ_DATA     => READ_DATA);

S_AXI_ACLK    <= not S_AXI_ACLK after 20 ns;
S_AXI_ARESETN <= '0', '1' after 80 ns;

process
begin
for i in 1 to 10 loop 
    wait until S_AXI_ACLK'event and S_AXI_ACLK='1'; 
  end loop;
  WRITE	<= '1';
  WRITE_ADDRESS	<= X"000004";
  WRITE_DATA 	<= X"55555555";
  wait until S_AXI_ACLK'event and S_AXI_ACLK='1';
  WRITE <= '0';
  for i in 1 to 20 loop wait until S_AXI_ACLK'event and S_AXI_ACLK='1'; end loop;
  READ	<= '1';
  READ_ADDRESS	<= X"000004";
  wait until S_AXI_ACLK'event and S_AXI_ACLK='1';
  READ <= '0';
  for i in 1 to 20 loop wait until S_AXI_ACLK'event and S_AXI_ACLK='1'; end loop;
  WRITE	<= '1';
  WRITE_ADDRESS	<= X"000100";
  WRITE_DATA 	<= X"12345678";
  wait until S_AXI_ACLK'event and S_AXI_ACLK='1';
  WRITE <= '0';
  for i in 1 to 20 loop wait until S_AXI_ACLK'event and S_AXI_ACLK='1'; end loop;
  READ	<= '1';
  READ_ADDRESS	<= X"000100";
  wait until S_AXI_ACLK'event and S_AXI_ACLK='1';
  READ <= '0';
  wait;
end process;
end Behavioral;