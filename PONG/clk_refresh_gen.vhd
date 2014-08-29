library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_refresh_gen is
port
(
	clk25Mhz,rst : in std_logic;
	clk_refresh : out std_logic
);
end clk_refresh_gen;

architecture bhv of clk_refresh_gen is

constant THIS_WIDTH : integer := integer(ceil(log2(real(208333))));
constant overflow : unsigned := to_unsigned(208333,THIS_WIDTH);
signal count,next_count : unsigned(THIS_WIDTH-1 downto 0);

signal clk,next_clk : std_logic;

begin
	process(clk25Mhz)
	begin
		if(rst = '1') then
			count <= (others => '0');
			clk <= '0';
		elsif(rising_edge(clk25Mhz)) then
			count <= next_count;
			clk <= next_clk;
		end if;
	end process;
	
	process(clk25Mhz)
	begin
		if(count /= overflow) then
			next_count <= count + 1;
			next_clk <= clk;
		else
			next_count <= to_unsigned(0,THIS_WIDTH);
			next_clk <= not clk;
		end if;
	end process;
	
	clk_refresh <= clk;
end bhv;