library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc_model is
    Port(adc_clk  : in std_logic;
         adc_data : out std_logic_vector(13 downto 0));
end adc_model;

architecture Behavioral of adc_model is

signal int_adc_data : std_logic_vector(13 downto 0) := (others=>'0');

begin

process(adc_clk)
begin
    if rising_edge(adc_clk) then
        int_adc_data <= std_logic_vector(unsigned(int_adc_data) + 1);
    end if;
end process;

adc_data <= int_adc_data;

end Behavioral;
