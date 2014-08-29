library ieee;
use ieee.std_logic_1164.all;
use work.vga_lib.all;

entity top_level_Pong is
port
(
	clk50Mhz : in std_logic;
	Dip_Switches : in std_logic_vector(9 downto 0);
	Buttons_n : in std_logic_vector(2 downto 0);
	LED_0, LED_1 : out std_logic_vector(6 downto 0);
	VGA_R,VGA_G,VGA_B : out std_logic_vector(3 downto 0);
	VGA_VS,VGA_HS	: out std_logic
);
end top_level_PONG;

architecture bhv of top_level_Pong is

signal rst : std_logic;
signal clk25Mhz,clk_refresh : std_logic;

signal Hcount,Vcount : std_logic_vector(COUNT_WIDTH-1 downto 0);
signal Video_On : std_logic;

signal RGB : std_logic_vector(11 downto 0);

signal Left_Paddle_Up,Left_Paddle_Down,Right_Paddle_Down,Right_Paddle_Up : std_logic;

signal left_score_out,right_score_out : std_logic_vector(3 downto 0);

begin
	rst <= Dip_Switches(9);
	
	Left_Paddle_Up <= Dip_Switches(1);
	Left_Paddle_Down <= Dip_Switches(0);
	Right_Paddle_Up <= not Buttons_n(2);
	Right_Paddle_Down <= not Buttons_n(1);
	
	U_CLK_DIV: entity work.clk_div_2
	port map
	(
		clk_in => clk50Mhz,
		rst => '0',
		clk_out => clk25Mhz
	);
	
	U_VGA_SYNC: entity work. vga_sync_gen
	port map
	(
		clk => clk25Mhz,
		rst => '0',
		Hcount => Hcount,
		Vcount => Vcount,
		Horiz_Sync => VGA_HS,
		Vert_Sync => VGA_VS,
		Video_On => Video_On
	);
		
	
	U_PONG_GAME: entity work.Pong_Game
	port map
	(
		Hcount => Hcount,
		Vcount => Vcount,
		clk25Mhz => clk25Mhz,
		rst => rst,
		RGB => RGB,
		Left_Paddle_Up => Left_Paddle_Up,
		Left_Paddle_Down => Left_Paddle_Down,
		Right_Paddle_Up => Right_Paddle_Up,
		Right_Paddle_Down => Right_Paddle_Down,
		left_score_out => left_score_out,
		right_score_out => right_score_out
	);
	
	U_LEFT_SCORE: entity work.decoder7seg
	port map
	(
		input => left_score_out,
		output => LED_1
	);
	
	U_RIGHT_SCORE: entity work.decoder7seg
	port map
	(
		input => right_score_out,
		output => LED_0
	);
	
	with Video_On select
		VGA_R <= RGB(11 downto 8) when '1',
					(others => '0') when others;
	with Video_On select
		VGA_G <= RGB(7 downto 4) when '1',
					(others => '0') when others;
	with Video_On select
		VGA_B <= RGB(3 downto 0) when '1',
					(others => '0') when others;
end bhv;
	
	