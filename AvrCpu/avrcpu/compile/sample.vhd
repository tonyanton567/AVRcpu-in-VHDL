-------------------------------------------------------------------------------
--
-- Title       : 
-- Design      : avrcpu
-- Author      : 
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\AvrCpu\avrcpu\compile\sample.vhd
-- Generated   : Thu Jul 11 11:29:49 2024
-- From        : C:\My_Designs\AvrCpu\avrcpu\src\sample.bde
-- By          : Bde2Vhdl ver. 2.6
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;

entity avrcpu is
  port(
       clk : in STD_LOGIC;
       rst_bar : in STD_LOGIC;
       vporta : out STD_LOGIC
  );
end avrcpu;

architecture structural of avrcpu is

---- Component declarations -----

component flash_pm_memory
  port(
       address : in STD_LOGIC_VECTOR(21 downto 0);
       data_out : out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;
component program_counter
  port(
       clk : in STD_LOGIC;
       rst_bar : in STD_LOGIC;
       next_address : in STD_LOGIC_VECTOR(15 downto 0);
       curr_address : out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

----     Constants     -----
constant DANGLING_INPUT_CONSTANT : STD_LOGIC := 'Z';

---- Signal declarations used on the diagram ----

signal BUS670 : STD_LOGIC_VECTOR(21 downto 0);

---- Declaration for Dangling input ----
signal Dangling_Input_Signal : STD_LOGIC;

begin

----  Component instantiations  ----

U1 : program_counter
  port map(
       clk => clk,
       rst_bar => rst_bar,
       next_address(15) => Dangling_Input_Signal,
       next_address(14) => Dangling_Input_Signal,
       next_address(13) => Dangling_Input_Signal,
       next_address(12) => Dangling_Input_Signal,
       next_address(11) => Dangling_Input_Signal,
       next_address(10) => Dangling_Input_Signal,
       next_address(9) => Dangling_Input_Signal,
       next_address(8) => Dangling_Input_Signal,
       next_address(7) => Dangling_Input_Signal,
       next_address(6) => Dangling_Input_Signal,
       next_address(5) => Dangling_Input_Signal,
       next_address(4) => Dangling_Input_Signal,
       next_address(3) => Dangling_Input_Signal,
       next_address(2) => Dangling_Input_Signal,
       next_address(1) => Dangling_Input_Signal,
       next_address(0) => Dangling_Input_Signal,
       curr_address(15) => BUS670(21),
       curr_address(14) => BUS670(20),
       curr_address(13) => BUS670(19),
       curr_address(12) => BUS670(18),
       curr_address(11) => BUS670(17),
       curr_address(10) => BUS670(16),
       curr_address(9) => BUS670(15),
       curr_address(8) => BUS670(14),
       curr_address(7) => BUS670(13),
       curr_address(6) => BUS670(12),
       curr_address(5) => BUS670(11),
       curr_address(4) => BUS670(10),
       curr_address(3) => BUS670(9),
       curr_address(2) => BUS670(8),
       curr_address(1) => BUS670(7),
       curr_address(0) => BUS670(6)
  );

U2 : flash_pm_memory
  port map(
       address => BUS670
  );


---- Dangling input signal assignment ----

Dangling_Input_Signal <= DANGLING_INPUT_CONSTANT;

end structural;
