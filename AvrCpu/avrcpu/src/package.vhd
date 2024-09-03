--Tony Antony										 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


package functions is
	
type command is(ADD, ADC, SUB, SUBI, SBC, SBCI, AND_COMMAND, ANDI, OR_COMMAND, ORI, EOR, 
COM, NEG, INC, DEC, RJMP, JMP, RCALL, CALL, RET, CP, CPC, CPI, SBRC, SBRS, SBIC, SBIS, BRBS, BRBC, MOV, LDI, 
LD, LD_POST, LD_PRE, ST, ST_POST, ST_PRE, IN_COMMAND, OUT_COMMAND, PUSH, POP,
LSR, ROR_COMMAND, SBI, CBI, FLAG_SET, FLAG_CLR,NOP, OTHER);
 
function get_instruction(instruction_in : std_logic_vector(15 downto 0)) return command;
--is variable returned: command;
   
end package functions;
 
-- Package Body Section
package body functions is
 
function get_instruction(instruction_in : std_logic_vector(15 downto 0)) return command is
variable returned: command;
begin
	
	if instruction_in(15 downto 12) = "1100" then	--OPCODE format: xxxx kkkk kkkk kkkk	  
		return RJMP;
	elsif instruction_in(15 downto 12) = "1101" then
		return RCALL;
	elsif instruction_in(15 downto 12) = "0111" then --OPCODE format: xxxx KKKK dddd KKKK 
		return ANDI;
	elsif instruction_in(15 downto 12) = "1110" then
		return LDI;
	elsif instruction_in(15 downto 12) = "0011" then
		return CPI;
	elsif instruction_in(15 downto 12) = "0110" then
		return ORI;
	elsif instruction_in(15 downto 12) = "0100" then
		return SBCI;
	elsif instruction_in(15 downto 12) = "0101" then
		return SUBI;
		
	elsif instruction_in(15 downto 10) = "000111" then  --OPCODE format: xxxx xxrd dddd rrrr or xxxx xx dddd dddd dddd 
		return ADC;									    -- or xxxx xxkk kkkk ksss
	elsif instruction_in(15 downto 10) = "000011" then	
		return ADD;
	elsif instruction_in(15 downto 10) = "000010" then	 
		 return SBC;
	elsif instruction_in(15 downto 10) = "000110" then	 
		 return SUB;
	elsif instruction_in(15 downto 10) = "001010" then	 
		 return OR_COMMAND;
	elsif instruction_in(15 downto 10) = "001001" then	 
		return EOR;
	elsif instruction_in(15 downto 10) = "001000" then	 
		return AND_COMMAND;	 
	elsif instruction_in(15 downto 10) = "000101" then	 
		return CP;	 
	elsif instruction_in(15 downto 10) = "000001" then	 
		return CPC;	
	elsif instruction_in(15 downto 10) = "111101" then	 
		return BRBC;	
	elsif instruction_in(15 downto 10) = "111100" then	 
		return BRBS;
	elsif instruction_in(15 downto 10) = "001011" then
		return MOV;			 
		
	elsif instruction_in(15 downto 8) = "10011001" then	  --OPCODE format: xxxx xxxx AAAA Abbb
		return SBIC;
	elsif instruction_in(15 downto 8) = "10011011" then
		return SBIS;
	elsif instruction_in(15 downto 8) = "10011010" then	 
		return SBI;
	elsif instruction_in(15 downto 8) = "10011000" then 
		return CBI;	  
		
	elsif instruction_in(15 downto 9) = "1111110" and instruction_in(3) = '0' then
		return SBRC;
	elsif instruction_in(15 downto 9) = "1111111" and instruction_in(3) = '0' then	
		return SBRS;
		
	elsif instruction_in(15 downto 9) = "1001001" and instruction_in(3 downto 0) = "1111" then
		return PUSH;
	elsif instruction_in(15 downto 9) = "1001000" and instruction_in(3 downto 0) = "1111" then
		return POP;
	elsif instruction_in(15 downto 9) = "1001010" and instruction_in(3 downto 0) = "0110" then
		return LSR;
	elsif instruction_in(15 downto 9) = "1001010" and instruction_in(3 downto 0) = "0111" then
		return ROR_COMMAND;
		
	elsif (instruction_in(15 downto 9) = "1001000" and instruction_in(3 downto 0) = "1100") or 	 --FOR LD AND ST commands
		(instruction_in(15 downto 9) = "1000000" and (instruction_in(3 downto 0) = "1000" 
		or instruction_in(3 downto 0) = "0000")) then
		return LD;
	elsif (instruction_in(15 downto 9) = "1001000" and instruction_in(3 downto 0) = "1101") or --LD with post increment
		(instruction_in(15 downto 9) = "1001000" and (instruction_in(3 downto 0) = "1001" 
		or instruction_in(3 downto 0) = "0001")) then 
		return LD_POST;
	elsif (instruction_in(15 downto 9) = "1001000" and instruction_in(3 downto 0) = "1110") or 	--LD with pre decrement
	    (instruction_in(15 downto 9) = "1001000" and (instruction_in(3 downto 0) = "1010" 
		or instruction_in(3 downto 0) = "0010")) then 
		return LD_PRE;
	elsif (instruction_in(15 downto 9) = "1001001" and instruction_in(3 downto 0) = "1100") or --Regular ST
		(instruction_in(15 downto 9) = "1000001" and (instruction_in(3 downto 0) = "1000" 
		or instruction_in(3 downto 0) = "0000")) then
		return ST;
	elsif (instruction_in(15 downto 9) = "1001001" and instruction_in(3 downto 0) = "1101") or 	 --ST with post increment
		(instruction_in(15 downto 9) = "1001001" and (instruction_in(3 downto 0) = "1001" 
		or instruction_in(3 downto 0) = "0001")) then 
		return ST_POST;
	elsif (instruction_in(15 downto 9) = "1001001" and instruction_in(3 downto 0) = "1110") or --ST with pre increment
		(instruction_in(15 downto 9) = "1001001" and (instruction_in(3 downto 0) = "1010" 
		or instruction_in(3 downto 0) = "0010")) then 
		return ST_PRE; 
		
	elsif instruction_in(15 downto 7) = "100101000" and instruction_in(3 downto 0) = "1000" then
		return FLAG_SET;
	elsif instruction_in(15 downto 7) = "100101001" and instruction_in(3 downto 0) = "1000" then
		return FLAG_CLR;
		
	elsif instruction_in = "1001010100001000" then
		return RET;
	elsif instruction_in = "0000000000000000" then
		return NOP;
	else
		return OTHER;
	end if;
end function;	
end package body functions;