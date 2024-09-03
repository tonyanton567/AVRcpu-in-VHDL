--Tony Antony										 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity alu is 
	port(
	alu_enable: in std_logic; 
	sreg: in std_logic_vector(7 downto 0);
	alu_op: in std_logic_vector(3 downto 0);
	operand_1: in std_logic_vector(7 downto 0);
	operand_2: in std_logic_vector(7 downto 0);                                                                                
	alu_output: out std_logic_vector(7 downto 0);													
	cpu_flags: out std_logic_vector(7 downto 0)
	);													
	
end alu;  


architecture behavorial of alu is
begin
	process(operand_1, operand_2, alu_op, alu_enable,sreg) 
	variable output: unsigned(7 downto 0);
	variable flags: std_logic_vector(7 downto 0);
	variable temp_flag : std_logic;
	begin
		
		if alu_enable = '1' then 
			flags := sreg;
			if alu_op = "0000" then
				output := unsigned(operand_1) + unsigned(operand_2);
				if flags(0) = '1' then
					output := output +1;
				end if;
				flags(5) := (operand_1(3) and operand_2(3)) or (operand_2(3) and (not output(3))) or ((not output(3)) and operand_1(3));
				flags(3) := (operand_1(7) and operand_2(7)) or (operand_2(7) and (not output(7))) or ((not output(7)) and operand_1(7));
				
			elsif alu_op = "0001" then
				output := unsigned(operand_1) + unsigned(operand_2);  
				flags(5) := (operand_1(3) and operand_2(3)) or (operand_2(3) and (not output(3))) or ((not output(3)) and operand_1(3));
				flags(3) := (operand_1(7) and operand_2(7)) or (operand_2(7) and (not output(7))) or ((not output(7)) and operand_1(7));
				
			elsif alu_op = "0010" then
				output := unsigned(operand_1) - unsigned(operand_2);
				if flags(0) = '1' then
					output := output -1;
				end if;
				flags(5) := (operand_1(3) and operand_2(3)) or (operand_2(3) and (not output(3))) or ((not output(3)) and operand_1(3));
				flags(3) := (operand_1(7) and operand_2(7)) or (operand_2(7) and (not output(7))) or ((not output(7)) and operand_1(7));
			elsif alu_op = "0011" then
				output:= unsigned(operand_1) - unsigned(operand_2);
				flags(5) := (operand_1(3) and operand_2(3)) or (operand_2(3) and (not output(3))) or ((not output(3)) and operand_1(3));
				flags(3) := (operand_1(7) and operand_2(7)) or (operand_2(7) and (not output(7))) or ((not output(7)) and operand_1(7));
			elsif alu_op = "0100" then
				output:= unsigned(operand_1) or unsigned(operand_2);
			elsif alu_op = "0101" then
				output:= unsigned(operand_1) xor unsigned(operand_2);
			elsif alu_op = "0110" then
				output := unsigned(operand_1) and unsigned(operand_2);
			elsif alu_op = "0111" then 
				flags(0) := operand_1(7);
				output := unsigned(operand_1);
				output := output(6 downto 0) & '0';
			elsif alu_op = "1000" then
				flags(0) := operand_1(0);
			    output := unsigned(operand_1);
				output := '0' & output(7 downto 1);
			elsif alu_op = "1001" then
			    temp_flag := flags(0);
				flags(0) := operand_1(7);
				output:= unsigned(operand_1);
				output := output(6 downto 0) & temp_flag;
			elsif alu_op = "1010" then
				temp_flag := flags(0);
				flags(0) := operand_1(0);
				output:= unsigned(operand_1);
				output := output(7 downto 1) & temp_flag;
			elsif alu_op = "1011" then 
				flags(to_integer(unsigned(operand_1(2 downto 0)))) := '1'; 
			elsif alu_op = "1100" then
				output := unsigned(operand_1) and ("11111111" - unsigned(operand_2));
			end if;
		alu_output <= std_logic_vector(output);
		cpu_flags <= flags;
	  end if;
	  end process;
end behavorial;

				
				
