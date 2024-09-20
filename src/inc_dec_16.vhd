--Tony Antony	
--increments or decrements the stack pointer or x,y,z registers based on operation signal
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity incdec is
	port(
	data_in: in std_logic_vector(15 downto 0); 
	operation: in std_logic;
	data_out: out std_logic_vector(15 downto 0)
	);
end incdec;

architecture behavioral of incdec is
begin
	process(data_in, operation)	
	variable temp : unsigned(15 downto 0);	  --here the data out is going back to 
	begin
		temp := unsigned(data_in);
		if operation = '1' then
			temp := temp +1;
		else
			temp := temp -1;
		end if;
	    data_out <= std_logic_vector(temp);
	
	end process;
end behavioral;