--Tony Antony
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
entity program_counter is 
port( 
clk: in std_logic;
rst_bar: in std_logic;
pc_control: in std_logic;
next_address: in std_logic_vector(15 downto 0);
curr_address: out std_logic_vector(15 downto 0)
);
end program_counter;

architecture behavorial of program_counter is 
begin
	process(clk)
	begin 
		if rst_bar = '0' then
			curr_address <= (others=>'0');
		elsif rising_edge(clk) then
			  if pc_control = '1' then
				curr_address <= next_address;
			  end if;
		end if;
		
	end process;
end behavorial;
