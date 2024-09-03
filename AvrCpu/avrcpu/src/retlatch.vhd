--Tony Antony
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity retlatch is
	port(
	clk: in std_logic;
	enable_low, enable_high: in std_logic;
	data_in: in std_logic_vector(7 downto 0);
	data_out: out std_logic_vector(15 downto 0)
	);
end retlatch;


architecture behavioral of retlatch is
begin
	double_latch: process(clk)
	begin
		if rising_edge(clk) then
			if enable_low = '1' then
				data_out(7 downto 0) <= data_in;
		    end if;
		    if enable_high = '1' then
				data_out(15 downto 8) <= data_in;
			end if;
		end if;
		
    end process;
end behavioral;