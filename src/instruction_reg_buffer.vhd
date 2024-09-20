--Tony Antony
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity instruction_register is
	port(
	clk: in std_logic;
	rst_bar: in std_logic;
	irreg_control: in std_logic;
    instruction_in: in std_logic_vector(15 downto 0);
	instruction_out: out std_logic_vector(15 downto 0)
	);
end instruction_register;


architecture behavorial of instruction_register is
begin
	process(clk)
	begin 
		if rst_bar = '0' then
			instruction_out <= "0000000000000000";	
		elsif rising_edge(clk) then	
			if irreg_control = '1' then
				instruction_out <= instruction_in;
			end if;
		end if;	
	end process;   
end behavorial;
	
