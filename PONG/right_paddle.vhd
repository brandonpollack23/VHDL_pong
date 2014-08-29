library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity right_paddle is
port
(
	Hcount,Vcount : in std_logic_vector(COUNT_WIDTH-1 downto 0);
	clk_refresh,rst	  : in std_logic;
	Right_Paddle_Up,Right_Paddle_Down : in std_logic;
	Right_Paddle_Y_out : out std_logic_vector(COUNT_WIDTH-1 downto 0);
	Paddle_Draw	  : out std_logic;
	Paddle_Color  : out std_logic_vector(11 downto 0)
);
end Right_paddle;

architecture bhv of Right_paddle is

signal Right_Paddle_Y,Right_Paddle_Y_new : unsigned(COUNT_WIDTH-1 downto 0);

begin
	process(clk_refresh, rst) --update to next position
	begin
		if(rst = '1') then
			Right_Paddle_Y <= to_unsigned(Paddle_start,COUNT_WIDTH);
		elsif(rising_edge(clk_refresh)) then
			Right_Paddle_Y <= Right_Paddle_Y_new;
		end if;
	end process;
	
	process(clk_refresh) --determine next position
	begin
		Right_Paddle_Y_new <= Right_Paddle_Y;
		if(Right_Paddle_Up = '1' and Right_Paddle_Down = '0' and Right_Paddle_Y >= 0) then --if it is already 0 then it stays, and only up is pressed
			if(signed(Right_Paddle_Y) - to_signed(Paddle_Move_Offset,COUNT_WIDTH+1) >= 0) then --minimum it can be is 0, won't go negative
				Right_Paddle_Y_new <= Right_Paddle_Y - Paddle_Move_Offset; 
			else
				Right_Paddle_Y_new <= (others => '0');
			end if;
		elsif(Right_Paddle_Down = '1' and Right_Paddle_Up = '0' and (Right_Paddle_Y + Paddle_Height) <= V_DISPLAY_END) then --if down is pressed, not up
			if((Right_Paddle_Y + Paddle_Height) + Paddle_Move_Offset <= V_DISPLAY_END) then
				Right_Paddle_Y_new <= Right_Paddle_Y + Paddle_Move_Offset;
			else
				Right_Paddle_Y_new <= V_DISPLAY_END - to_unsigned(Paddle_Height,COUNT_WIDTH);
			end if;
		end if;
	end process;
	
	process(Hcount,Vcount) --determine if drawn
	begin
		if(unsigned(Hcount) >= Right_Paddle_H_min and unsigned(Hcount) <= Right_Paddle_H_max and unsigned(Vcount) >= (Right_Paddle_Y) and unsigned(Vcount) <= ((Right_Paddle_Y) + (Paddle_Height))) then
			Paddle_Draw <= '1';
		else
			Paddle_Draw <= '0';
		end if;
	end process;
	
	--color is constant (for now, we can do disco based on Vcount later)
	Paddle_Color <= x"F80"; --orange for UF
	
	--outputing the left paddle position
	Right_Paddle_Y_out <= std_logic_vector(Right_Paddle_Y);
end bhv;
		