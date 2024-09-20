--Tony Antony  
--simple two to one multiplexer with n bits
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity mux is
	generic (n : integer := 8);
	port(
	data_1: in std_logic_vector(n-1 downto 0);
	data_2: in std_logic_vector(n-1 downto 0);
	option: in std_logic;
	data_out: out std_logic_vector(n-1 downto 0)
    );
end mux;

architecture behavioral of mux is
begin
	process(data_1, data_2, option)
	begin
		if option = '0' then
			data_out <= data_1;
		else
			data_out <= data_2;
		end if;
	end process;
end behavioral;

	