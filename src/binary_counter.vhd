 --Tony Antony
--Binary counter with unsigned variable
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
entity binary_counter is
	generic (n : integer := 7); -- generic for counter width
	port (
		clk : in std_logic; -- system clock
		cnten : in std_logic; -- enable counter count
		rst_bar : in std_logic; -- synchronous reset (active low)
		q : out std_logic_vector (n-1 downto 0)); -- output
end binary_counter;

architecture behavorial of binary_counter is
begin
	process (clk)
	variable output_var : unsigned(n-1 downto 0):= to_unsigned(0,n);
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				output_var := to_unsigned(0,n);
			elsif cnten = '1' then
				output_var := output_var + 1; 
			else  
				null;
		    end if;
		else 
			null;
		end if;
		q <= std_logic_vector(output_var);
	end process;
end behavorial;
				