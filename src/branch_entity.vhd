--Tony Antony
--the output branch_enable decides if the branch command results in a branch
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity branch_en is
	port(
	data: in std_logic_vector(7 downto 0);
	select_bit: in std_logic_vector(2 downto 0);
	branch_type: in std_logic;
	set: in std_logic;
	branch_enable: out std_logic
	);
end branch_en;

architecture dataflow of branch_en is
signal selected_bit: std_logic;
signal x: std_logic;
begin
	selected_bit <= data(to_integer(unsigned(select_bit)));	  --logic to control branch_enable
	x <= (set and selected_bit) or (not set and not selected_bit);
	branch_enable <= x and branch_type;
end dataflow;
