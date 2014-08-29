library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity Pong_Game is
port
(
	Hcount,Vcount : in std_logic_vector(COUNT_WIDTH-1 downto 0);
	clk25Mhz, rst : in std_logic;
	RGB : out std_logic_vector(11 downto 0);
	Left_Paddle_Up,Left_Paddle_Down : in std_logic;
	Right_Paddle_Up,Right_Paddle_Down : in std_logic;
	left_score_out,right_score_out : out std_logic_vector(3 downto 0)
);
end Pong_Game;

architecture bhv of Pong_Game is

signal clk_refresh : std_logic;
signal Left_paddle_Y_out, Right_paddle_Y_out : std_logic_vector(COUNT_WIDTH-1 downto 0);
signal L_Paddle_Draw, R_Paddle_Draw,Ball_Draw : std_logic;
signal L_Paddle_RGB,R_Paddle_RGB,Ball_RGB : std_logic_vector(11 downto 0);

signal left_score_e,right_score_e : std_logic;

begin
	U_CLK_REFRESH: entity work.clk_refresh_gen
	port map
	(
		clk25Mhz => clk25Mhz,
		clk_refresh => clk_refresh,
		rst => rst
	);
	
	U_LEFT_PADDLE: entity work.left_paddle
	port map
	(
		Hcount => Hcount,
		Vcount => Vcount,
		clk_refresh => clk_refresh,
		Left_paddle_up => Left_paddle_up,
		Left_paddle_down => Left_paddle_down,
		Left_paddle_Y_out => Left_paddle_Y_out,
		Paddle_Draw => L_Paddle_Draw,
		Paddle_Color => L_Paddle_RGB,
		rst => rst
	);
	
	U_RIGHT_PADDLE: entity work.right_paddle
	port map
	(
		Hcount => Hcount,
		Vcount => Vcount,
		clk_refresh => clk_refresh,
		Right_Paddle_Up => Right_Paddle_Up,
		Right_Paddle_Down => Right_Paddle_Down,
		Right_Paddle_Y_out => Right_Paddle_Y_out,
		Paddle_Draw => R_Paddle_Draw,
		Paddle_Color => R_Paddle_RGB,
		rst => rst
	);
	
	U_BALL: entity work.ball
	port map
	(
		Hcount => Hcount,
		Vcount => Vcount,
		Left_paddle_Y => Left_paddle_Y_out,
		Right_Paddle_Y => Right_Paddle_Y_out,
		refresh_clk => clk_refresh,
		Draw_Ball => Ball_Draw,
		Ball_Color => Ball_RGB,
		rst => rst,
		left_score => left_score_e,
		right_score => right_score_e
	);
	
	U_SCORE: entity work.score
	port map
	(
		left_score_e => left_score_e,
		right_score_e => right_score_e,
		refresh_clk => clk_refresh,
		rst => rst,
		left_score_out => left_score_out,
		right_score_out => right_score_out
	);
	
	process(L_Paddle_Draw,R_Paddle_Draw,Ball_Draw)
	begin
		if(Ball_Draw = '1') then
			RGB <= Ball_RGB;
		elsif(L_Paddle_Draw = '1') then
			RGB <= L_Paddle_RGB;
		elsif(R_Paddle_Draw = '1') then
			RGB <= R_Paddle_RGB;
		else
			RGB <= (others => '0');
		end if;
	end process;		
end bhv;		