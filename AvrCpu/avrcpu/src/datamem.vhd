--Tony Antony										 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity datamem is
	port(
	clk: in std_logic; 
	rst_bar: in std_logic;
	address: in std_logic_vector(15 downto 0);
	memRead: in std_logic;
	memWrite: in std_logic;
	writeData: in std_logic_vector(7 downto 0);	
	
	statusReg_en: in std_logic;
	writeStatusReg: in std_logic_vector(7 downto 0);
	statusReg: out std_logic_vector(7 downto 0);  
	
	stack_write: in std_logic; 
	stack_data: in std_logic_vector(15 downto 0);
	stack_pointer: out std_logic_vector(15 downto 0);
	
	temp_VPORTAIN: in std_logic;
	temp_VPORTDOUT: out std_logic;
	dataout: out std_logic_vector(7 downto 0)
	);
end datamem;

architecture behavioral of datamem is 

type memory	is array (0 to ((2**address'length) -1)) of std_logic_vector(7 downto 0);
signal dataMemory : memory;

begin
	statusReg <= dataMemory(100);
	--read for 
	stack_pointer <= dataMemory(101) & dataMemory(102);	 
	
    temp_VPORTDOUT <= dataMemory(13)(7);
	write: process(rst_bar, clk)
	begin
		dataMemory(2)(7) <= temp_VPORTAIN;
		if rst_bar = '0' then                                   
			dataMemory(101) <= x"00";
			dataMemory(102) <= x"40";
			dataMemory(100) <= x"00";
		elsif falling_edge(clk) then
			if memWrite = '1' then						  		
				dataMemory(to_integer(unsigned(address))) <= writeData;
			end if;
			if statusReg_en = '1' then
				dataMemory(100) <= writeStatusReg;
			end if;
			if stack_write = '1' then
				dataMemory(101) <= stack_data(15 downto 8);
				dataMemory(101+1) <= stack_data(7 downto 0);
			end if;
			
		end if;
	end process;

	
	read: process(address, memRead, dataMemory) 
	begin
		if memRead = '1' then
			dataout <= dataMemory(to_integer(unsigned(address)));
		else 
			null;
	    end if;
	end process;
	
	

	
end behavioral;	 


	