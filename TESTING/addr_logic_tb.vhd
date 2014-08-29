library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity addr_logic_tb is
end addr_logic_tb;

architecture bhv of addr_logic_tb is

signal Vcount,Hcount : std_logic_vector(COUNT_WIDTH-1 downto 0);
signal position_select : std_logic_vector(2 downto 0);
signal row,col : std_logic_vector(5 downto 0);
signal image_enable, image_enable_col, image_enable_row : std_logic;
signal RGB : std_logic_vector(11 downto 0);
signal address : std_logic_vector(11 downto 0);

signal clk : std_logic := '0';
signal rst : std_logic;

signal done : std_logic := '0';

begin		
	address <= row(5 downto 0) & col(5 downto 0);
	
	U_col: entity work.col_addr_logic
	port map
	(
		Hcount => Hcount,
		position_select => position_select,
		col => col,
		image_enable => image_enable_col
	);
	
	U_row: entity work.row_addr_logic
	port map
	(
		Vcount => Vcount,
		position_select => position_select,
		row => row,
		image_enable => image_enable_row
	);
	
	U_vga: entity work.vga_sync_gen
	port map
	(
		clk => clk,
		rst => rst,
		Hcount => Hcount,
		Vcount => Vcount
	);
	
	U_rom: entity work.vga_rom
	port map
	(
		address => address,
		clock => clk,
		wren => '0',
		data => (others => '0'),
		q => RGB
	);
	
	clk <= not clk and not done after 20 ns;
	
	process	
	begin
		rst <= '1';
		wait for 50 ns;		
		rst <= '0';
		
		position_select <= "001";
		wait for 1 ns;
		
		assert(image_enable_col = '1' and image_enable_row = '1')
			report "Center: Video not on at origin for top left" severity warning;
		
		while (unsigned(Vcount) <= TOP_LEFT_Y_END) loop
			wait for 20 ns;
			
			if(unsigned(Hcount) > TOP_LEFT_X_END) then
				assert(image_enable_col = '0')
					report "Image enable does not go false for Hcount greater than 127 when drawing in top left" severity warning;
			else
				assert(image_enable_col = '1')
					report "Image enable not true when Hcount less than 127 when drawing in top left" severity warning;
			end if;
		end loop;
		
		assert(image_enable_row = '0')
			report "Image enable true when Vcount is greater than 127 when drawing in top left" severity warning;
	
		wait until image_enable_row = '1';
		
		--now do it for each position?
		
		done <= '1';
		
		report "DONE!!!";
		wait;
	end process;
end bhv;
		