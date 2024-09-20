 --Tony Antony
 --This unit is responsible for calculating the next program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity new_pc is
	port(	
	current_pc: in std_logic_vector(15 downto 0);
	branch_type: in std_logic;
	branch_enable: in std_logic;
	offset: in std_logic_vector(11 downto 0);
	next_instruction: in std_logic_vector(15 downto 0);	
	return_stack: in std_logic_vector(15 downto 0);
	set_type: in std_logic;
	operation: in std_logic_vector(1 downto 0);
	new_pc: out std_logic_vector(15 downto 0)
	);
end new_pc;

architecture behavioral of new_pc is
 
begin
	process(current_pc, offset, operation, branch_type, branch_enable, next_instruction, return_stack, set_type)
	variable temp: unsigned(15 downto 0);
	variable two_word_preemptive: std_logic_vector(8 downto 0);
	begin
		if operation = "01" then
			if branch_type = '1' then  
				if branch_enable = '1' then
					if offset(9) = '1' then
						temp := unsigned(current_pc) + unsigned("11111111" & offset(9 downto 3)); --sign extend and add
					else 		 
						temp := unsigned(current_pc) + unsigned("00000000" & offset(9 downto 3));--if branch enabled then add the offset to the current pc
					end if;
				else 
					temp := unsigned(current_pc) +1;
				end if;
			else 
				if offset(11) = '1' then
					temp := unsigned(current_pc) + unsigned("1111" & offset);		   --for rjmp and rcall statements. Simply adds last 12 bits to new pc 
				else
					temp := unsigned(current_pc) + unsigned("0000" & offset);
				end if;
			end if;	
		elsif operation = "10" then
			if set_type = '0' then
				temp := unsigned(next_instruction); -- for call and jmp
			else 
				temp := unsigned(return_stack);
			end if;
		elsif operation = "11" then									   
			if branch_enable = '1' then
				two_word_preemptive := next_instruction(15 downto 9) & next_instruction(3 downto 2);
				if two_word_preemptive= "100101011" then 	--jmp or call 2-word instructions
					temp := unsigned(current_pc) + 2;
				else
					temp := unsigned(current_pc) + 1; 
				end if;
			else 
				temp := unsigned(current_pc) + 1;
			end if;
		else
			temp := unsigned(current_pc) + 1;			   
		end if;
		new_pc <= std_logic_vector(temp); 
		
	end process;
end behavioral;
			
			