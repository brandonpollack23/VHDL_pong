library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity score is
port
(
	left_score_e, right_score_e, refresh_clk, rst : in std_logic;
	left_score_out, right_score_out : out std_logic_vector(3 downto 0)
);
end score;

architecture bhv of score is

signal left_score,right_score : unsigned(3 downto 0);

begin
	process(refresh_clk, rst)
	begin
		if(rst = '1') then
			left_score <= to_unsigned(0,4);
			right_score <= to_unsigned(0,4);
			
		elsif(rising_edge(refresh_clk)) then
			if(left_score_e = '1') then
				left_score <= left_score + 1;
			elsif(right_score_e = '1') then
				right_score <= right_score + 1;
			else
				left_score <= left_score;
				right_score <= right_score;
			end if;
		end if;
	end process;
	
	left_score_out <= std_logic_vector(left_score);
	right_score_out <= std_logic_vector(right_score);
end bhv;