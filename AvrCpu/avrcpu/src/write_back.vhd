--Tony Antony
library ieee;
use ieee.std_logic_1164.all;

entity write_back is
	port (
	
	execute_contents, datamem_contents: in std_logic_vector(7 downto 0);
	rf_dataone, rf_datatwo: in std_logic_vector(7 downto 0);
	incdec_one, incdec_two: in std_logic_vector(7 downto 0);
	byte1_options: in std_logic_vector(1 downto 0);
	byte2_options: in std_logic;
	output_contents1: out std_logic_vector(7 downto 0);
	output_contents2: out std_logic_vector(7 downto 0)
	);
end write_back;

architecture wb_stage of write_back is
begin
  wb_one: process(execute_contents, datamem_contents, rf_dataone, incdec_one, byte1_options)
  begin
	  if byte1_options = "00" then
		  output_contents1 <= execute_contents;
	  elsif byte1_options = "01" then
		  output_contents1 <= datamem_contents;
	  elsif byte1_options = "10" then
		  output_contents1 <= rf_dataone;
	  else 
		  output_contents1 <= incdec_one;
	  end if;	  
  end process;
  
  wb_two: process(byte2_options, rf_datatwo, incdec_two)
  begin
	  if byte2_options = '0' then
		  output_contents2 <= rf_datatwo;
	  else 
		output_contents2 <= incdec_two;
	  end if;
  end process;
	
end wb_stage;
	