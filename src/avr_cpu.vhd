--Tony Antony 
--structural implementation of the AVR processor using mux's   
-- You can see that the clk is connected to the program counter and the instruction register buffer to create the two-stage pipeling
-- I also made a pwm hardware code which I will in integrate into the cpu and set aside specific bytes in data memory for the arguments for pulse width modulation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity avr_cpu is
	port(
	clk: in std_logic; 
	rst_bar: in std_logic;
	push_button: in std_logic; 
	temp_output: out std_logic;
	temp_instruct: out std_logic_vector(15 downto 0)
	);
end avr_cpu;

architecture structural of avr_cpu is
signal temp_address: std_logic_vector(15 downto 0);
signal temp_dataout: std_logic_vector(15 downto 0);
signal temp_instruction: std_logic_vector(15 downto 0);	
signal next_pc: std_logic_vector(15 downto 0);	

signal  memRead: std_logic;
signal	memWrite: std_logic;	
signal	writeRegister1: std_logic; 
signal  writeRegister2: std_logic;	
signal	wb1_type: std_logic_vector(1 downto 0);
signal	wb2_type: std_logic;	
signal	branch: std_logic;
signal	addorsub: std_logic;
signal	pclh_byte : std_logic;
signal	writeDatamux : std_logic;
signal writeDatamux2 : std_logic;
signal	iostatus: std_logic;
signal	data1ormux: std_logic;
signal	setorclr: std_logic;	
signal	stackWrite: std_logic;
signal	sregWrite: std_logic;	
signal	retlatchlo: std_logic;
signal	retlatchhi: std_logic;	
signal	datamem_address: std_logic;	
signal	pc_control: std_logic;
signal	irreg_control: std_logic;	
signal	ALU_operation: std_logic_vector(3 downto 0);	
signal	pc_operation: std_logic_vector(1 downto 0);	
signal  pc_settype: std_logic;
signal	ALU_enable: std_logic;


signal data_out1reg, data_out2reg, data_out3reg: std_logic_vector(7 downto 0);
signal selected_address: std_logic_vector(15 downto 0);
signal pc_write: std_logic_vector(7 downto 0);
signal write_data: std_logic_vector(7 downto 0);
signal statusReg: std_logic_vector(7 downto 0);	
signal prepost_data: std_logic_vector(15 downto 0);	
signal stack_pointer: std_logic_vector(15 downto 0);
signal mem_dataout: std_logic_vector(7 downto 0);


signal alu_output, cpu_flags: std_logic_vector(7 downto 0);

signal branch1_muxout, data_branch: std_logic_vector(7 downto 0);
signal branch_enable: std_logic;

signal wbdataone, wbdatatwo: std_logic_vector(7 downto 0);

signal pcfromstack: std_logic_vector(15 downto 0);

signal mux_address1: std_logic_vector(15 downto 0);

signal datamem_address2: std_logic;	 

signal alumuxoption: std_logic;

signal alu_dataone: std_logic_vector(7 downto 0); 
signal write_datafinal : std_logic_vector(7 downto 0); 
signal muxaddress1: std_logic_vector(15 downto 0);
begin 
	
pc: entity program_counter port map(clk=>clk, rst_bar=>rst_bar, pc_control => pc_control, next_address => next_pc, 
curr_address => temp_address);
fpm: entity flash_pm_memory port map(address =>temp_address, data_out => temp_dataout);
ir: entity instruction_register port map(clk =>clk, rst_bar=> rst_bar, irreg_control=>irreg_control, instruction_in => temp_dataout, 
instruction_out => temp_instruction);

control : entity control_logic port map(clk => clk, rst_bar=> rst_bar, instruction => temp_instruction, 
branch_enable => branch_enable, memRead =>memRead, memWrite =>memWrite, writeRegister1=>writeRegister1, 
writeRegister2=>writeRegister2, wb1_type=>wb1_type, wb2_type=>wb2_type,
branch=>branch, addorsub=>addorsub, pclh_byte=>pclh_byte, writeDatamux=>writeDatamux, iostatus=>iostatus, 
data1ormux =>data1ormux, setorclr=>setorclr, stackWrite=>stackWrite, sregWrite=>sregWrite, 
retlatchlo=>retlatchlo, retlatchhi=>retlatchhi, datamem_address=> datamem_address, datamem_address2=> datamem_address2, pc_control=>pc_control, 
irreg_control=>irreg_control, ALU_operation=>ALU_operation, pc_operation=>pc_operation, pc_settype=>pc_settype,
ALU_enable=>ALU_enable);   										  

reg_file: entity register_file port map(clk => clk, rst_bar => rst_bar, instruction=> temp_instruction, write_en1 => writeRegister1,
write_en2=> writeRegister2, write_data1=>wbdataone, write_data2=>wbdatatwo, data_out1=>data_out1reg, data_out2=>data_out2reg, data_out3=>data_out3reg); 

alu_mux: entity mux generic map (n=>8) port map(data_1 => data_out1reg, data_2 => mem_dataout, option=>alumuxoption, data_out=>alu_dataone);
	
alu: entity alu port map(alu_enable => ALU_enable, sreg=>statusReg, alu_op => ALU_operation, operand_1=> alu_dataone, 
operand_2=>data_out2reg, alu_output=>alu_output, cpu_flags=>cpu_flags);   


address_mux: entity mux generic map (n=>16) port map(data_1 => (data_out1reg & data_out2reg), data_2 => stack_pointer, 
option=>datamem_address, data_out=>muxaddress1); 

address_mux2: entity mux generic map (n=>16) port map(data_1=> muxaddress1, data_2 =>"00000000000" & temp_instruction(7 downto 3),
	option=>datamem_address2, data_out=>selected_address);
	
write1_mux: entity mux generic map (n=>8) port map(data_1 =>temp_address(7 downto 0), data_2 => temp_address(15 downto 8), 
option=>pclh_byte, data_out=> pc_write); 

write2_mux: entity mux generic map (n=>8) port map (data_1 => pc_write, data_2=>data_out3reg, option=>writeDatamux, data_out=>write_data);
	
write3_mux: entity mux generic map (n=>8) port map (data_1 =>write_data, data_2=>alu_output, option=>writeDatamux2, data_out=>write_datafinal);
	
data_memory: entity datamem port map(clk => clk,rst_bar=>rst_bar, address =>selected_address, memRead =>memRead, memWrite =>memWrite, writeData=>write_datafinal, 
statusReg_en=>sregWrite, writeStatusReg=> cpu_flags , statusReg=>statusReg, stack_write=>stackWrite, stack_data=>prepost_data,
stack_pointer=>stack_pointer,temp_VPORTAIN=> push_button, temp_VPORTDOUT=>temp_output, dataout=>mem_dataout);   

pre_post_incrementor: entity incdec port map(data_in => selected_address, operation=> addorsub, data_out => prepost_data);
		
branch_mux1: entity mux generic map(n=>8) port map(data_1 => statusReg, data_2 => mem_dataout, option => iostatus, 
data_out => branch1_muxout); 
branch_mux2: entity mux generic map(n=>8) port map(data_1 => branch1_muxout, data_2=> data_out1reg, option =>data1ormux, 
data_out=> data_branch);
branch_entity: entity branch_en port map(data => data_branch, set => setorclr, select_bit => data_out2reg(2 downto 0), branch_type=>branch, 
branch_enable => branch_enable);

write_back: entity write_back port map(execute_contents=>alu_output, datamem_contents=>mem_dataout, rf_dataone=>data_out1reg,
rf_datatwo=>data_out2reg, incdec_one=>prepost_data(7 downto 0), incdec_two=>prepost_data(15 downto 8), byte1_options=>wb1_type, 
byte2_options=>wb2_type, output_contents1=>wbdataone, output_contents2=>wbdatatwo); 

retlatch: entity retlatch port map(clk=>clk, enable_low=>retlatchlo, enable_high=>retlatchhi, data_in=>mem_dataout, 
data_out=>pcfromstack);

next_pcen: entity new_pc port map(current_pc =>temp_address, branch_type=>branch, branch_enable=>branch_enable, 
offset=> temp_instruction(11 downto 0),	next_instruction=> temp_dataout, return_stack=>pcfromstack, set_type=>pc_settype,
operation =>pc_operation, new_pc=>next_pc);



end structural;
