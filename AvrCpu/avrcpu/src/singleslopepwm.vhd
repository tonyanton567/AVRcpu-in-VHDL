--Tony Antony
--Binary counter with unsigned variable
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity pwm is
	port(
	clk: in std_logic;
	rst_bar: in std_logic;
	enable: in std_logic;
	period: in std_logic_vector(15 downto 0); 
	cmp: in std_logic_vector(15 downto 0);
	pulse: out std_logic
	);
end entity pwm;

architecture behavioral of pwm is
begin
	process(clk, rst_bar)
	variable counter: unsigned(15 downto 0):= to_unsigned(0,16);
	begin
		if rst_bar = '0' then
			pulse <= '1'; 
			counter :=  to_unsigned(0,16);
		elsif rising_edge(clk) then	
			if enable = '1' then 
			  counter := counter +1;
			  if counter >= unsigned(cmp) then
				  pulse <= '0';
			  else
				  pulse <= '1';
			  end if;
			  if counter = unsigned(period) then
				  counter := to_unsigned(0,16);
			  end if;
			end if;
		end if;
	end process;
end behavioral;
				  
				  
				  
			
		
	