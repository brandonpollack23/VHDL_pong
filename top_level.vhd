library ieee;
use ieee.std_logic_1164.all;
use work.vga_lib.all;

entity top_level is 
port
(
	clk50Mhz : in std_logic;
	Dip_Switches : in std_logic_vector(9 downto 0);
	VGA_R,VGA_G,VGA_B		: out std_logic_vector(3 downto 0);
	VGA_VS,VGA_HS	: out std_logic
);
end top_level;

architecture bhv of top_level is

signal Hcount, Vcount : std_logic_vector(COUNT_WIDTH-1 downto 0);
signal clk25Mhz : std_logic;

signal ROM_addr : std_logic_vector(13 downto 0);

signal Video_On, image_enable_row, image_enable_col : std_logic;

signal RGB_raw : std_logic_vector(11 downto 0);

signal rst : std_logic;

begin
	rst <= Dip_Switches(9);
	
	U_CLK_DIV_2:	entity work.clk_div_2
	port map
	(
		rst => rst,
		clk_in => Clk50Mhz,
		clk_out => clk25Mhz
	);
	
	U_VGA_SYNC_GEN: entity work.vga_sync_gen
	port map
	(
		clk => clk25Mhz,
		rst => rst,
		Hcount => Hcount,
		Vcount => Vcount,
		Horiz_Sync => VGA_HS,
		Vert_Sync => VGA_VS,
		Video_On => Video_On
	);
	
	U_ROW_ADDR_LOGIC: entity work.row_addr_logic
	port map
	(
		Vcount => Vcount,
		position_select => Dip_Switches(2 downto 0),
		row => ROM_addr(11 downto 6),
		image_enable => image_enable_row
	);
	
	U_COL_ADDR_LOGIC: entity work.col_addr_logic
	port map
	(
		Hcount => Hcount,
		position_select => Dip_Switches(2 downto 0),
		col => ROM_addr(5 downto 0),
		image_enable => image_enable_col
	);
	
	U_IMAGEROM: entity work.vga_rom
	port map
	(
		data => (others => '0'),
		wren => '0',
		address => ROM_addr(11 downto 0),
		clock => clk25Mhz,
		q => RGB_raw(11 downto 0)
	);
	
	process(clk25Mhz,RGB_raw)
	begin
		if(image_enable_col = '1' and image_enable_row = '1' and video_On = '1') then
			VGA_R <= RGB_raw(11 downto 8);
			VGA_G <= RGB_raw(7 downto 4);
			VGA_B <= RGB_raw(3 downto 0);
		else
			VGA_R <= x"0";
			VGA_G <= x"0";
			VGA_B <= x"0";
		end if;
	end process;
end bhv;
		