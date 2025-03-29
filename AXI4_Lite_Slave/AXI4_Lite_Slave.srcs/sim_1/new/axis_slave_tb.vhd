library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axis_slave_tb is
--  Port ( );
end axis_slave_tb;

architecture Behavioral of axis_slave_tb is

component axis_slave is
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
end component;

signal  S_AXI_ACLK	    : std_logic := '0';
signal  S_AXI_ARESETN	: std_logic;
signal  S_AXI_AWVALID	: std_logic;
signal  S_AXI_AWREADY	: std_logic;
signal  S_AXI_AWADDR	: std_logic_vector(23 downto 0);
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
signal  S_AXI_RVALID	: std_logic;
signal  S_AXI_RREADY	: std_logic;
signal  S_AXI_RDATA 	: std_logic_vector(31 downto 0);
signal  S_AXI_RRESP 	: std_logic_vector(1 downto 0);
begin

U1: axis_slave port map (S_AXI_ACLK	    => S_AXI_ACLK,
                         S_AXI_ARESETN	=> S_AXI_ARESETN,
                         S_AXI_AWVALID	=> S_AXI_AWVALID,
                         S_AXI_AWREADY	=> S_AXI_AWREADY,
                         S_AXI_AWADDR	=> S_AXI_AWADDR,
                         S_AXI_WVALID	=> S_AXI_WVALID,
                         S_AXI_WREADY	=> S_AXI_WREADY,
                         S_AXI_WDATA 	=> S_AXI_WDATA,
                         S_AXI_BVALID	=> S_AXI_BVALID,
                         S_AXI_BREADY	=> S_AXI_BREADY,
                         S_AXI_BRESP 	=> S_AXI_BRESP,
                         S_AXI_ARVALID	=> S_AXI_ARVALID,
                         S_AXI_ARREADY	=> S_AXI_ARREADY,
                         S_AXI_ARADDR	=> S_AXI_ARADDR,
                         S_AXI_RVALID	=> S_AXI_RVALID,
                         S_AXI_RREADY	=> S_AXI_RREADY,
                         S_AXI_RDATA 	=> S_AXI_RDATA,
                         S_AXI_RRESP 	=> S_AXI_RRESP);

-- Generate Clock and Reset
S_AXI_ACLK    <= not S_AXI_ACLK after 20 ns;
S_AXI_ARESETN <= '0', '1' after 80 ns;

process
begin
    S_AXI_AWVALID	<= '0';
    S_AXI_AWADDR	<= (others => '0');
    S_AXI_WVALID	<= '0';
    S_AXI_WDATA 	<= (others => '0');
    S_AXI_WSTROBE	<= (others => '0');
    S_AXI_BREADY	<= '0';
    S_AXI_BRESP 	<= (others => '0');
    S_AXI_ARVALID	<= '0';
    S_AXI_ARADDR	<= (others => '0');
    S_AXI_RREADY	<= '0';
    
    for i in 1 to 10 loop 
        wait until S_AXI_ACLK'event and S_AXI_ACLK='1'; 
    end loop;
    
    S_AXI_AWVALID	<= '1';
    S_AXI_AWADDR	<= X"000004";
    S_AXI_WDATA 	<= X"55555555";
    S_AXI_WVALID	<= '1';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_AWREADY = '1');
        S_AXI_AWVALID	<= '0';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_WREADY = '1');
        S_AXI_WVALID	<= '0';
        S_AXI_AWADDR	<= X"000000";
        S_AXI_WDATA 	<= X"00000000";
        S_AXI_WVALID	<= '0';
        S_AXI_BREADY	<= '1';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_BVALID = '1');
        S_AXI_BREADY  <= '0';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1');
        S_AXI_ARVALID	<= '1';
        S_AXI_ARADDR	<= X"000004";
        S_AXI_RREADY	<= '1';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_ARREADY = '1');
        S_AXI_ARVALID	<= '0';
     wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_RVALID = '1');
        S_AXI_RREADY	<= '0';

    for i in 1 to 10 loop 
        wait until S_AXI_ACLK'event and S_AXI_ACLK='1'; 
    end loop;
    
    S_AXI_AWVALID	<= '1';
    S_AXI_AWADDR	<= X"000100";
    S_AXI_WDATA 	<= X"12345678";
    S_AXI_WVALID	<= '1';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_AWREADY = '1');
        S_AXI_AWVALID	<= '0';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_WREADY = '1');
        S_AXI_WVALID	<= '0';
        S_AXI_AWADDR	<= X"000000";
        S_AXI_WDATA 	<= X"00000000";
        S_AXI_WVALID	<= '0';
        S_AXI_BREADY	<= '1';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_BVALID = '1');
        S_AXI_BREADY  <= '0';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1');
        S_AXI_ARVALID	<= '1';
        S_AXI_ARADDR	<= X"000100";
        S_AXI_RREADY	<= '1';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_ARREADY = '1');
        S_AXI_ARVALID	<= '0';
    wait until (S_AXI_ACLK'event and S_AXI_ACLK='1' and S_AXI_RVALID = '1');
        S_AXI_RREADY	<= '0';
    wait;
end process;
end Behavioral;
