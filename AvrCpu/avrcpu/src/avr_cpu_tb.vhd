-- Testbench for Laboratory 11 Spring 2024
																								


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity avr_cpu_tb is
end avr_cpu_tb;

architecture testbench of avr_cpu_tb is
 signal clk: std_logic; 
 signal rst_bar: std_logic;
 signal	temp_instruct: std_logic_vector(15 downto 0); 
 signal push_button, temp_output : std_logic;
constant period : time := 4.0us;
signal end_sim : boolean := false; 
begin

UUT: entity avr_cpu port map(clk=>clk, rst_bar=>rst_bar, push_button=>push_button, temp_output => temp_output, temp_instruct=>temp_instruct);
	
rst_bar <= '0', '1' after period/4;		
pushbutton: process
	begin
		push_button <= '0';
		loop
			wait for period*3.2;
			push_button <= not push_button;
			exit when end_sim = true;
		end loop;
		wait;
end process; 
	
clock_gen : process
	begin
		clk <= '0';
		loop
			wait for period/2;
			clk <= not clk;
			exit when end_sim = true;
		end loop;
		wait;
end process; 

time_cntrl: process
begin
	for i in 0 to 15 loop
		wait for period;
	end loop;
	end_sim <= true;
	std.env.finish;		-- stop simulation
end process;

end testbench;
	
	
