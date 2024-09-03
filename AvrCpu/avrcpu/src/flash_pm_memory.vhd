--Tony Antony
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
entity flash_pm_memory is 
	port(
	address: in std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(15 downto 0)
	);
end flash_pm_memory;

architecture behavorial of flash_pm_memory is
type memory is array (0 to 5) of std_logic_vector(15 downto 0);
signal flash_memory: memory := ("1001101100010111", "1001100001101111", "1001100100010111", 
"1001101001101111", "1100111111111011", "0000000000000000");
begin																												
	process(address)
	begin 
			data_out <= flash_memory(to_integer(unsigned(address)));
	end process;
end behavorial;
		
	
	