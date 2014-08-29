library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity ball is
port
(
	Hcount,Vcount,Left_Paddle_Y,Right_Paddle_Y : in std_logic_vector(COUNT_WIDTH-1 downto 0);
	refresh_clk, rst	: in std_logic;
	Draw_Ball,left_score,right_score : out std_logic;
	Ball_Color : out std_logic_vector(11 downto 0)
);
end ball;

architecture bhv of ball is

signal Ball_X,Ball_Y,Ball_X_next,Ball_Y_next : unsigned(COUNT_WIDTH downto 0); --make it one wider so when it gets changed to signed it doesnt become negative
signal Ball_X_velocity,Ball_X_velocity_next,Ball_Y_velocity,Ball_Y_velocity_next : signed(5 downto 0); --later increase the speed over time or something  

begin	
	process(refresh_clk,rst)
	begin
		if(rst = '1') then
			Ball_X <= to_unsigned(H_DISPLAY_END/2,COUNT_WIDTH+1);
			Ball_Y <= to_unsigned(V_DISPLAY_END/2,COUNT_WIDTH+1);
			
			Ball_X_velocity <= to_signed(-2,6);
			Ball_Y_velocity <= to_signed(0,6);
		elsif(rising_edge(refresh_clk)) then
			Ball_X <= Ball_X_next;
			Ball_Y <= Ball_y_next;
			
			Ball_X_velocity <= Ball_X_velocity_next;
			Ball_Y_velocity <= Ball_Y_velocity_next;
		end if;
	end process;
	
	process(refresh_clk)	
	begin
		Ball_X_velocity_next <= Ball_X_velocity;		
		Ball_Y_velocity_next <= Ball_Y_velocity;
		Ball_X_next <= unsigned(signed(Ball_X) + Ball_X_velocity);
		Ball_Y_next <= unsigned(signed(Ball_Y) + Ball_Y_velocity);
		
		left_score <= '0';
		right_score <= '0';
		
		--SCORES TB added later, just see if the ball falls off the screen, if so, increment the other guy's score, to go to another part "score counter", mkae it just a std_logic (call it increment p1 or increment p2)
		--this test has to come first so that it doesnt always overwrite a collision detection on a paddle
		if(signed(Ball_X) <= 0 or Ball_X >= H_DISPLAY_END) then --right paddle point
			Ball_X_next <= to_unsigned(H_DISPLAY_END/2,COUNT_WIDTH+1);
			Ball_Y_next <= to_unsigned(V_DISPLAY_END/2,COUNT_WIDTH+1);
			
			Ball_Y_velocity_next <= to_signed(0,6);
			
			if(Ball_X_velocity >= 0) then
				Ball_X_velocity_next <= to_signed(2,6);
				left_score <= '1';
			else
				Ball_X_velocity_next <= to_signed(-2,6);
				right_score <= '1';
			end if;
		
		--if right paddle intersect
		elsif(signed(Ball_Y) + Ball_Y_velocity + Ball_size/4 >= signed('0' & Right_Paddle_Y) and signed(Ball_Y) + Ball_Y_velocity - Ball_size/4 <= signed('0' & Right_Paddle_Y) + Paddle_Height and signed(Ball_X) + Ball_X_velocity + ball_size >= Right_Paddle_H_min) then
			Ball_X_next <= to_unsigned(Right_Paddle_H_min-Ball_size,COUNT_WIDTH+1);
			Ball_X_velocity_next <= -(Ball_X_velocity + 1); --swap x direction, increase speed
			
			if(signed(Ball_Y) + Ball_Y_velocity <= signed('0' & Right_Paddle_Y) + Paddle_Height/3) then
				Ball_Y_velocity_next <= Ball_Y_velocity - Ball_Y_Velocity_Change;
			--if upper third give negative Y velocity increase
			elsif(signed(Ball_Y) + Ball_Y_velocity >= signed('0' & Right_Paddle_Y) + 2*Paddle_Height/3) then
				Ball_Y_velocity_next <= Ball_Y_velocity + Ball_Y_Velocity_Change;
			end if;
			
		-- if left paddle intersect and collision
		elsif(signed(Ball_Y) + Ball_Y_velocity >= signed('0' & Left_Paddle_Y) and signed(Ball_Y) + Ball_Y_velocity <= signed('0' & Left_Paddle_Y) + Paddle_Height and signed(Ball_X) + Ball_X_velocity <= Left_Paddle_H_max) then
			Ball_X_next <= to_unsigned(Left_Paddle_H_max,COUNT_WIDTH+1);
			Ball_X_velocity_next <= -(Ball_X_velocity - 1); --swap x direction, increase speed
			
			--if lower third give positive Y velocity increase
			if(signed(Ball_Y) + Ball_Y_velocity <= signed('0' & Left_Paddle_Y) + Paddle_Height/3) then
				Ball_Y_velocity_next <= Ball_Y_velocity - Ball_Y_Velocity_Change;
			--if upper third give negative Y velocity increase
			elsif(signed(Ball_Y) + Ball_Y_velocity >= signed('0' & Left_Paddle_Y) + 2*Paddle_Height/3) then
				Ball_Y_velocity_next <= Ball_Y_velocity + Ball_Y_Velocity_Change;
			end if;		
		
		--upper and lower walls
		elsif(signed(Ball_Y) + Ball_Y_velocity <= 0) then
			Ball_Y_next <= to_unsigned(0,COUNT_WIDTH+1);
			Ball_Y_velocity_next <= -Ball_Y_velocity;
		elsif(signed(Ball_Y) + Ball_Y_velocity + Ball_size >= V_DISPLAY_END) then
			Ball_Y_next <= to_unsigned(V_DISPLAY_END-Ball_size,COUNT_WIDTH+1);
			Ball_Y_velocity_next <= -Ball_Y_velocity;
		end if;
		
		--ball draw condition
		if(unsigned(Hcount) >= Ball_X and unsigned(Hcount) <= Ball_X + Ball_size and unsigned(Vcount) >= Ball_Y and unsigned(Vcount) <= Ball_Y + Ball_size) then
			Draw_Ball <= '1';
		else
			Draw_Ball <= '0';
		end if;
	end process;
	
	Ball_Color <= x"FFF"; --while ball like my pale skin
end bhv;
		
	
