--Tony Antony	
--I put alot of processing in the register file 
-- The state machine is implemented specifically for LD PREDECREMENT since you have to update a register in the register file and the x,y,z pointer registers in one instruction
--which both are placed in one memory unit the register file.
library work;
use work.functions.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
																												    
entity register_file is 
	port( 
	clk: in std_logic;
	rst_bar: in std_logic;
	instruction: in std_logic_vector(15 downto 0);
	write_en1: in std_logic;
	write_en2: in std_logic;
	write_data1: in std_logic_vector(7 downto 0);
	write_data2: in std_logic_vector(7 downto 0);
	data_out1: out std_logic_vector(7 downto 0);
	data_out2: out std_logic_vector(7 downto 0);	
	data_out3: out std_logic_vector(7 downto 0)
	);
end register_file;

architecture behavioral of register_file is
type memory	is array (0 to 31) of std_logic_vector(7 downto 0); 
signal register_file : memory := (others=>(others=>'0'));	 -- presets everything to zero for convenience when testing and observing waveforms 

type state is(regular_state, update_writereg);
signal present_state, next_state: state;

signal reg_towrite: std_logic_vector(4 downto 0);
signal pointer: std_logic_vector(4 downto 0);
begin
	
	process(instruction, register_file)				--this process decides how to read from the register file based on the command type
	variable get_command : command;
	variable dummy: unsigned(7 downto 0) := "00000000";
	begin
		get_command := get_instruction(instruction_in => instruction);
		case get_command is
			when ADC | ADD | AND_COMMAND | SBC | SUB | OR_COMMAND | EOR | CP | CPC  =>
			data_out1 <= register_file(to_integer(unsigned(instruction(8 downto 4))));
			data_out2 <= register_file(to_integer(unsigned((instruction(9) & instruction(3 downto 0)))));
			when MOV =>
			data_out1 <= register_file(to_integer(unsigned((instruction(9) & instruction(3 downto 0)))));
			when ANDI | SUBI | SBCI | ORI | CPI  =>
			data_out1 <= register_file(16 + to_integer(unsigned(instruction(7 downto 4))));
			data_out2 <= instruction(12 downto 9) & instruction(3 downto 0); 
			when BRBC | BRBS | SBIC | SBIS  =>
			data_out2(2 downto 0) <= instruction(2 downto 0);
			when SBI | CBI =>
			dummy(to_integer(unsigned(instruction(2 downto 0)))) := '1';
			data_out2 <= std_logic_vector(dummy);
			dummy := "00000000";
			when SBRS | SBRC =>
			data_out1 <= register_file(to_integer(unsigned(instruction(8 downto 4))));
			data_out2(2 downto 0) <= instruction(2 downto 0);
			when LDI =>
			data_out1 <= instruction(12 downto 9) & instruction(3 downto 0);
			when LSR | ROR_COMMAND =>
			data_out1 <= register_file(to_integer(unsigned(instruction(8 downto 4)))); 
			when LD | LD_POST | LD_PRE =>
				if instruction(15 downto 9) = "1001000" and (instruction(3 downto 0) = "1100" 
					or instruction(3 downto 0) = "1101" 
					or instruction(3 downto 0) = "1110") then
				    data_out1 <= register_file(26);
					data_out2 <= register_file(26+1);
					pointer <= "11010";
				elsif (instruction(15 downto 9) = "1000000" and instruction(3 downto 0) = "1000") or
					(instruction(15 downto 9) = "1001000" and (instruction(3 downto 0) = "1001" 
					or instruction(3 downto 0) = "1010")) then
					data_out1 <= register_file(28);
					data_out2 <= register_file(28+1);
					pointer <= "11100";
				else   
					data_out1 <= register_file(30);
					data_out2 <= register_file(30+1); 
					pointer <= "11110";
				end if;	
			when ST | ST_POST | ST_PRE =>
				if instruction(15 downto 9) = "1001001" and (instruction(3 downto 0) = "1100" 
					or instruction(3 downto 0) = "1101" 
					or instruction(3 downto 0) = "1110") then
				    data_out1 <= register_file(26);
					data_out2 <= register_file(26+1);
					pointer <= "11010";
				elsif (instruction(15 downto 9) = "1000001" and instruction(3 downto 0) = "1000") or
					(instruction(15 downto 9) = "1001001" and (instruction(3 downto 0) = "1001" 
					or instruction(3 downto 0) = "1010")) then
					data_out1 <= register_file(28);
					data_out2 <= register_file(28+1); 
					pointer <= "11100";
				else
					data_out1 <= register_file(30);
					data_out2 <= register_file(30+1);
					pointer <= "11110";
				end if;
				data_out3 <= register_file(to_integer(unsigned(instruction(8 downto 4))));
			when others =>
			    null;
			end case;
			
		     	
	end process;
				
		
   write: process(clk)		  --synchronous to falling edge so in one half of a-  
		  begin																			  -- clock cycle the decode and alu is done and stabilized
			if falling_edge(clk) then	
				if write_en1 = '1' then
					register_file(to_integer(unsigned(reg_towrite))) <= write_data1;
				end if;
				if write_en2 = '1' then
					register_file(to_integer(unsigned(reg_towrite)) +1) <= write_data2;
				end if;
			end if;
		  end process;
		  
	state_reg: process(rst_bar, clk)
	begin 
		if rst_bar = '0' then
			present_state <= regular_state;
		elsif rising_edge(clk) then
			present_state <= next_state;
		else 
			null;
		end if;
	end process;
	
	reg_waddress: process(present_state, instruction) -- this fsm is implemented due to a required change in the write register address for 
	variable get_command : command;					  --pre and post decrement x,y,z commands
	begin
	
		get_command := get_instruction(instruction_in => instruction);
		if present_state = regular_state then 
			case get_command is
				when ADC | ADD | AND_COMMAND | MOV | SBC | SUB | OR_COMMAND | EOR | LSR | ROR_COMMAND | LD | LD_POST =>
				reg_towrite <= instruction(8 downto 4);
				when ANDI | SUBI | SBCI | ORI | LDI =>
				reg_towrite <= std_logic_vector(unsigned('0' & instruction(7 downto 4))+to_unsigned(16, 5));
				when ST_POST | ST_PRE => 
				reg_towrite <= pointer;
				when LD_PRE =>
				reg_towrite <= pointer;
			    when others =>
				null;
				end case;
					
			
		else 
			if get_command = LD_PRE then
				reg_towrite <= instruction(8 downto 4);
			else
				reg_towrite <= pointer;
			end if;
		end if;
	end process;
	
				
		   
			
			
	nxt_state: process(present_state, instruction)   --Based on FSM.
	variable get_command : command;
	begin
		get_command := get_instruction(instruction_in => instruction);
		if present_state = regular_state then
			case get_command is
				when LD_PRE | LD_POST  =>							 
				next_state <= update_writereg;
				when others =>
				next_state <= regular_state;
			end case;
	    else 
			next_state <= regular_state;
		end if;
	end process;
	
end behavioral;
		
																												   


	
