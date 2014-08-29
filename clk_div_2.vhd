library ieee;
use ieee.std_logic_1164.all;

entity Clk_div_2 is
port
(
	clk_in,rst : in std_logic;
	clk_out : out std_logic
);
end Clk_div_2;

architecture bhv of clk_div_2 is

signal clk : std_logic;

begin
	process(clk_in,rst)
	begin
		if(rst = '1') then
			clk <= '0';
		elsif(rising_edge(clk_in)) then
			clk <= not clk;
		end if;
	end process;
	
	clk_out <= clk;
end bhv;