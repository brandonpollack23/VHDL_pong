library ieee;
use ieee.std_logic_1164.all;

entity top_level_tb is
end top_level_tb;

architecture bhv of top_level_tb is

signal clk50Mhz : std_logic := '0';
signal image_select : std_logic_vector(2 downto 0) := "001";
signal VGA_R,VGA_G,VGA_B : std_logic_vector(3 downto 0);
signal VGA_VS, VGA_HS : std_logic;

signal done : std_logic := '0';
signal rst : std_logic;

begin
	clk50Mhz <= not clk50Mhz and not done after 10 ns;
	
	U_TEST: entity work.top_level
	port map
	(
		clk50Mhz => clk50Mhz,
		dip_switches(2 downto 0) => image_select(2 downto 0),
		dip_switches(8 downto 3) => (others => '0'),
		dip_switches(9) => rst,
		VGA_R => VGA_R,
		VGA_G => VGA_G,
		VGA_B => VGA_B,
		VGA_VS => VGA_VS,
		VGA_HS => VGA_HS
	);
	
	process	
	begin
		rst <= '1';
		wait for 10 ns;
		rst <= '0';
		
		wait for 20 ms; --time for one fram and then some
		
		done <= '1';
		wait;
	end process;
end bhv;
	
		