library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity left_paddle is
port
(
	Hcount,Vcount : in std_logic_vector(COUNT_WIDTH-1 downto 0);
	clk_refresh,rst	  : in std_logic;
	Left_Paddle_Up,Left_Paddle_Down : in std_logic;
	Left_Paddle_Y_out : out std_logic_vector(COUNT_WIDTH-1 downto 0);
	Paddle_Draw	  : out std_logic;
	Paddle_Color  : out std_logic_vector(11 downto 0)
);
end left_paddle;

architecture bhv of left_paddle is

signal Left_Paddle_Y,Left_Paddle_Y_new : unsigned(COUNT_WIDTH-1 downto 0);

begin
	process(clk_refresh) --update to next position
	begin
		if(rst = '1') then
			Left_Paddle_Y <= to_unsigned(Paddle_start,COUNT_WIDTH);
		elsif(rising_edge(clk_refresh)) then
			Left_Paddle_Y <= Left_Paddle_Y_new;
		end if;
	end process;
	
	process(clk_refresh) --determine next position
	begin
		Left_Paddle_Y_new <= Left_Paddle_Y;
		if(Left_Paddle_Up = '1' and Left_Paddle_Down = '0' and Left_Paddle_Y >= 0) then --if it is already 0 then it stays, and only up is pressed
			if(signed(Left_Paddle_Y) - to_signed(Paddle_Move_Offset,COUNT_WIDTH+1) >= 0) then --minimum it can be is 0, won't go negative
				Left_Paddle_Y_new <= Left_Paddle_Y - Paddle_Move_Offset; 
			else
				Left_Paddle_Y_new <= to_unsigned(0,COUNT_WIDTH);
			end if;
		elsif(Left_Paddle_Down = '1' and Left_Paddle_Up = '0' and (Left_Paddle_Y + Paddle_Height) <= V_DISPLAY_END) then --if down is pressed, not up
			if((Left_Paddle_Y + Paddle_Height) + Paddle_Move_Offset <= V_DISPLAY_END) then
				Left_Paddle_Y_new <= Left_Paddle_Y + Paddle_Move_Offset;
			else
				Left_Paddle_Y_new <= V_DISPLAY_END - to_unsigned(Paddle_Height,COUNT_WIDTH);
			end if;
		end if;
	end process;
	
	process(Hcount,Vcount) --determine if drawn
	begin
		if(unsigned(Hcount) >= Left_Paddle_H_min and unsigned(Hcount) <= Left_Paddle_H_max and unsigned(Vcount) >= (Left_Paddle_Y) and unsigned(Vcount) <= ((Left_Paddle_Y) + (Paddle_Height))) then
			Paddle_Draw <= '1';
		else
			Paddle_Draw <= '0';
		end if;
	end process;
	
	--color is constant (for now, we can do disco based on Vcount later)
	Paddle_Color <= x"00F"; --blue for UF
	
	--outputing the left paddle position
	Left_Paddle_Y_out <= std_logic_vector(Left_Paddle_Y);
end bhv;
		