--Tony Antony 
--This is the control logic unit implemented using an FSM
library work;
use work.functions.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity control_logic is
	port(
	rst_bar: in std_logic;
	instruction: in std_logic_vector(15 downto 0); 
	branch_enable: in std_logic;
	clk: in std_logic;
	
	memRead: out std_logic;	        --enables read from data memory
	memWrite: out std_logic;	    --enables write to data memory
									--on each clock cycle you can write to two registers in the register file
	writeRegister1: out std_logic; 	--enables write to register one
	writeRegister2: out std_logic;	--enables write to register two
	
	wb1_type: out std_logic_vector(1 downto 0);	   
	wb2_type: out std_logic;
	
	branch: out std_logic;					-- '1' if it is a branch command
	
	addorsub: out std_logic;			   -- For post or pre decrement of the stack or pointer registers
	pclh_byte : out std_logic;			   -- chooses which byte of the pc register to write to from the stack
	writeDatamux : out std_logic; 		   --muxes to direct write to data memory data 
	writeDatamux2 : out std_logic;
	
	iostatus: out std_logic;				--muxes to direct data to branch entity
	data1ormux: out std_logic;	
	
	setorclr: out std_logic;			    -- option that tells the branch entity if the bit should be set or cleared
	
	stackWrite: out std_logic;				--enables write to stack 
	sregWrite: out std_logic;			    --enables write to status register 
	
	retlatchlo: out std_logic;			    --chooses which byte of the pc register to write to from the stack
	retlatchhi: out std_logic;
	
	alu_muxoption: out std_logic;			
	
	datamem_address: out std_logic;		   --mux options for 
	datamem_address2: out std_logic;
	pc_control: out std_logic;
	
	alumuxoption: out std_logic;
	
	irreg_control: out std_logic;
	
	ALU_operation: out std_logic_vector(3 downto 0);
	
	pc_operation: out std_logic_vector(1 downto 0);	
	pc_settype: out std_logic;
	ALU_enable: out std_logic
	);
end control_logic;

architecture moore_fsm of control_logic is

type state is(state_run, rjmp_state, rcall1_state, rcall2_state, 
branch_state, ret1_state, ret2_state, ret3_state, ld_state, ldpre_state, ldpost_state, stpre_state,
SCBI_state);

signal present_state, next_state: state;	

begin
    state_reg: process(rst_bar, clk)
	begin 
		if rst_bar = '0' then
			present_state <= state_run;
		elsif rising_edge(clk) then
			present_state <= next_state;
		else 
			null;
		end if;
	end process;
	
	outputs: process(present_state, instruction, branch_enable)
	variable get_command : command;
	begin
	
		get_command := get_instruction(instruction_in => instruction);	  --see package.vhd
		memRead <= '0';													 --resets all instructions that should be unasserted if not used
		memWrite <= '0';
		writeRegister1 <= '0';
		writeRegister2 <= '0';
		branch <= '0';
		stackWrite <= '0';
		sregWrite <= '0';
		retlatchlo <= '0';
		retlatchhi <= '0'; 
		
		pc_control <= '1';
		irreg_control <= '1';
		pc_operation <=	"00";
		ALU_enable <= '0';
		
		if present_state = state_run then				  --Checks the instruction currently outputed by the pipeline and assigns the output signals
			if get_command = ADC then
				ALU_operation <= "0000";
				ALU_enable <= '1';
				wb1_type <= "00";
				writeRegister1 <= '1';
				sregWrite <= '1';
				alumuxoption <= '0';
			elsif get_command = ADD then	
				ALU_enable <= '1';
				wb1_type <= "00";								   
				writeRegister1 <= '1';
				ALU_operation <= "0001";  
				sregWrite <= '1';
				alumuxoption <= '0';
			elsif get_command = SBC or get_command = SBCI then			 
				ALU_enable <= '1';
				wb1_type <= "00";
				writeRegister1 <= '1';
				ALU_operation <= "0010"; 
				sregWrite <= '1';
				alumuxoption <= '0';
			elsif get_command = SUB or get_command = SUBI  then	
				ALU_enable <= '1';
				wb1_type <= "00";
				writeRegister1 <= '1';
				ALU_operation <= "0011"; 
				sregWrite <= '1'; 
				alumuxoption <= '0';
			elsif get_command = OR_COMMAND or get_command = ORI then	 --OR
				ALU_enable <= '1';
				wb1_type <= "00";
				writeRegister1 <= '1';
				ALU_operation <= "0100";
				sregWrite <= '1';
				alumuxoption <= '0';
			elsif get_command = EOR then	 --EOR
				ALU_enable <= '1';
				wb1_type <= "00";
				writeRegister1 <= '1';
				ALU_operation <= "0101"; 
				sregWrite <= '1'; 
				alumuxoption <= '0';
			elsif get_command = AND_COMMAND or get_command = ANDI then	 --AND
				ALU_enable <= '1';
				wb1_type <= "00";
				writeRegister1 <= '1';
				ALU_operation <= "0111";
				sregWrite <= '1'; 
				alumuxoption <= '0';
		    elsif get_command = CP or get_command = CPI then
				ALU_enable <= '1';
				ALU_operation <= "0011";
			    sregWrite <= '1'; 
				alumuxoption <= '0';
		    elsif get_command =  CPC then
				ALU_enable <= '1';
				ALU_operation <= "0010";
			    sregWrite <= '1';  
				alumuxoption <= '0';
			elsif get_command = MOV or get_command = LDI then
				writeRegister1 <= '1';
				wb1_type <= "10";
			elsif get_command = FLAG_SET then
				sregWrite <= '1';
				ALU_enable <= '1';
				ALU_operation <= "1011"; 
				alumuxoption <= '0';
			elsif get_command = SBI then
				pc_control <= '0';
				irreg_control <= '0';
				datamem_address2 <= '1';
				memRead <= '1';
				alumuxoption <= '1';
				ALU_enable <= '1';
				ALU_operation <= "0100";
			elsif get_command = CBI then
				pc_control <= '0';
				irreg_control <= '0';
				datamem_address2 <= '1';
				memRead <= '1';
				alumuxoption <= '1';
				ALU_enable <= '1';
				ALU_operation <= "1100";--change to CBR
			elsif get_command = SBRC then
				branch <= '1';
				pc_operation <= "10";
				data1ormux <= '1';
				setorclr <= '0';
				irreg_control <= not branch_enable;
			elsif get_command = SBRS then
				branch <= '1';
				pc_operation <= "10";
				data1ormux <= '1';
				setorclr <= '1'; 
				irreg_control <= not branch_enable;	
			elsif get_command = SBIC then
				branch <= '1';
				pc_operation <= "11";
				iostatus <= '1';
				data1ormux <= '0';
				setorclr <= '0';
				memRead <= '1';
				datamem_address2 <= '1';
				irreg_control <= not branch_enable;
			elsif get_command = SBIS then
				branch <= '1';
				pc_operation <= "11";
				iostatus <= '1';
				data1ormux <= '0';
				setorclr <= '1';
				irreg_control <= not branch_enable;
				memRead <= '1';
				datamem_address2 <= '1';
			elsif get_command = BRBC then
				branch <= '1';
				pc_operation <= "01";
				iostatus <= '0';
				data1ormux <= '0';
				setorclr <= '0';
				irreg_control <= not branch_enable;
			elsif get_command = BRBS then
				branch <= '1';
				pc_operation <= "01";
				iostatus <= '0';
				data1ormux <= '0';
				setorclr <= '1';
				irreg_control <= not branch_enable;
			elsif get_command = LD then
				memRead <= '1';
				--pc_control <= '0';
				--irreg_control <= '0';
				datamem_address <= '0';
				datamem_address2 <= '0';
				wb1_type <= "01";
				writeRegister1 <= '1';
			elsif get_command = LD_POST then
				memRead <= '1';
				pc_control <= '0';
				irreg_control <= '0';
		        wb1_type <= "01";
				writeRegister1 <= '1';
				datamem_address <= '0';
			elsif get_command = LD_PRE then
				pc_control <= '0';
				irreg_control <= '0';
				wb1_type <= "11";
				wb2_type <= '1';
				writeRegister1 <= '1';
				writeRegister2 <= '1';
				addorsub <= '1';
				datamem_address <= '0';
				datamem_address2 <= '0';
			elsif get_command = ST then
				memWrite <= '1';
				datamem_address <= '0';
				datamem_address2 <= '0';
				writeDatamux <= '0';
			elsif get_command = ST_POST then
				memWrite <= '1';
				datamem_address <= '0';
				datamem_address2 <= '0';
				addorsub <= '0';
				writeRegister1 <= '1';
				writeRegister2 <= '1';
				wb1_type <= "11";
				wb2_type <= '1';
				writeDatamux <= '0';	
				writeDatamux2 <= '0';
			elsif get_command = ST_PRE then	
				pc_control <= '0';
				irreg_control <= '0';
				addorsub <= '0';
				writeRegister1 <= '1';
				writeRegister2 <= '1';
				wb1_type <= "11";
				wb2_type <= '1';
				writeDatamux <= '0';  
				datamem_address <= '0';
				datamem_address2 <= '0';
				writeDatamux2 <= '0';
			elsif get_command = RJMP then --rjmp
				irreg_control <= '0';
				pc_operation <=  "01";
			elsif get_command = RCALL then
				irreg_control <= '0';
				pc_control <= '0';
				stackWrite <= '1';
				memWrite <= '1';
				datamem_address <= '1';
				datamem_address2 <= '0';
				addorsub <= '0';
				pclh_byte <= '0';
				writeDatamux <= '1';
				writeDatamux2 <= '0';
			elsif get_command = RET then
				irreg_control <= '0';
				pc_control <= '0';
				addorsub <= '1';
				stackWrite <= '1';
				retlatchlo <= '1'; 
				memRead <= '1';
				datamem_address <= '1';
				datamem_address2 <= '0';
				pc_settype <= '1';
			else  --NOP OR OTHER which is treated as a NOP
				null; --everything is already unasserted at the top of the process
		    end if;	
			
		elsif present_state = rjmp_state then
			irreg_control <= '1';
			pc_operation <= "00";
		elsif present_state = branch_state then
			branch <= '0';
			pc_operation <= "00";
			irreg_control <= '1';
		elsif present_state = ldpost_state then
			pc_control <= '1';
			irreg_control <= '1';
			addorsub <= '0';
			wb1_type <=  "11";
			wb2_type <= '1';
			writeRegister1 <= '1';
			writeRegister2 <= '1';
		elsif present_state = ldpre_state then
			pc_control <= '1';
			irreg_control <= '1';
			memRead <= '1';
			writeRegister1 <= '1';
			writeRegister2 <= '0';
			wb1_type <= "01";
		elsif present_state = stpre_state then
			pc_control <= '1';
			irreg_control <= '1';
			writeRegister1 <= '0';
			writeRegister2 <= '0';
			memWrite <= '1';
		elsif present_state = rcall1_state then
			irreg_control <= '0'; 
			pc_control <= '1';
			stackWrite <= '1';
			memWrite <= '1';
			pclh_byte <= '1';
			pc_operation <= "01";
			
		elsif present_state = rcall2_state then
			irreg_control <= '1';
			pc_control <= '1';
			pc_operation <= "00";
		elsif present_state = ret1_state then
			irreg_control <= '0';
			pc_control <= '0';
			retlatchhi <= '1';
			stackWrite <= '1';
			memRead <= '1';
		elsif present_state = ret2_state then
			irreg_control <= '0';
			pc_control <= '0';
			pc_operation <= "10";			  
		elsif present_state = SCBI_state then
			pc_control <= '1';
			irreg_control <= '1';
			memWrite <= '1';
			writeDatamux2 <= '1';
		elsif present_state = ret3_state then 
			null;
		else
			null;
		end if;
						
end process; 
	
	nxt_state: process(present_state, instruction, branch_enable)   -- each new state represents a new clock cycle
	variable get_command : command;
	begin
		get_command := get_instruction(instruction_in => instruction);										--sets a new state based on the current state 
		case present_state is
			when state_run =>   --for case state_run														-- I put convenient names for the states and instructions so if you look at the instruction set you can follow
				if get_command = RJMP then																	-- and see whats going on in the control unit.
				  next_state <= rjmp_state;
				elsif (get_command = SBRC or get_command = SBRS or get_command = SBIC or get_command = SBIS or get_command = BRBC
					or get_command = BRBS) and branch_enable = '1' then
				  next_state <= branch_state;
				elsif get_command = LD_POST then
					next_state <= ldpost_state;
				elsif get_command = LD_PRE then
					next_state <= ldpre_state;
				elsif get_command = ST_PRE then
					next_state <= stpre_state;
				elsif get_command = RCALL then
					next_state <= rcall1_state;
				elsif get_command=RET then
					next_state <= ret1_state;
				elsif get_command = SBI or get_command = CBI then
					next_state <= SCBI_state;
				else
					next_state <= state_run;
				end if;
		    when rcall1_state =>
				next_state <= rcall2_state;
			
		    when ret1_state =>
				next_state <= ret2_state;
			
		    when ret2_state =>
				next_state <= ret3_state; 
			
		    when branch_state | ldpost_state | ldpre_state | stpre_state | rcall2_state | ret3_state | rjmp_state | SCBI_state =>
			next_state <= state_run; 
		    when others=>
			null;
		end case;
	end process;

end moore_fsm;
				
			
				
				
	
	
	 