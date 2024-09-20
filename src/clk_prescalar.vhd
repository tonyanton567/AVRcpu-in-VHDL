--Tony Antony
--Binary counter with unsigned variable
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
entity clk_prescalar is
	port (
	clk : in std_logic; -- system clock	
	option: in std_logic_vector(2 downto 0);
	counter: in std_logic_vector(6 downto 0);
	new_clk: out std_logic
	);
end clk_prescalar;

architecture behavioral of clk_prescalar is
begin
	process(clk, option, counter)
	begin
		if option = "000" then
			new_clk <= clk;
		else
			new_clk <= counter(to_integer(unsigned(option))-1);
		end if;
	end process;
end behavioral;