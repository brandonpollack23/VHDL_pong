library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.vga_lib.all;

entity VGA_sync_gen is
port
(
	clk,rst : in std_logic;
	Hcount,Vcount : out std_logic_vector(COUNT_WIDTH-1 downto 0);
	Horiz_Sync,Vert_Sync,Video_on : out std_logic
);
end VGA_sync_gen;

architecture bhv of VGA_sync_gen is

signal Hcount_temp, Vcount_temp : unsigned(COUNT_WIDTH-1 downto 0);

begin
	Hcount <= std_logic_vector(Hcount_temp);
	Vcount <= std_logic_vector(Vcount_temp);
	
	process(clk,rst)
	begin
		if(rst = '1') then
			Hcount_temp <= (others => '0');
			Vcount_temp <= (others => '0');
		elsif(rising_edge(clk)) then
			if(Hcount_temp = H_MAX) then
				Hcount_temp <= (others => '0');
			else
				Hcount_temp <= Hcount_temp + 1;
			end if;
			
			if(Vcount_temp = V_MAX) then
				Vcount_temp <= (others => '0');
			elsif(Hcount_temp = H_VERT_INC) then
				Vcount_temp <= Vcount_temp + 1;
			end if;
		end if;
	end process;
	
	process(Hcount_temp,Vcount_temp)
	begin
		if(Hcount_temp >= HSYNC_BEGIN and Hcount_temp <= HSYNC_END) then
			Horiz_Sync <= '0'; --active low
		else
			Horiz_Sync <= '1';
		end if;
		
		if(Vcount_temp >= VSYNC_BEGIN and Vcount_temp <= VSYNC_END) then
			Vert_Sync <= '0';
		else
			Vert_Sync <= '1';
		end if;
		
		if((Hcount_temp >= 0 and Hcount_temp <= H_DISPLAY_END) and (Vcount_temp >= 0 and Vcount_temp <= V_DISPLAY_END)) then
			Video_on <= '1'; --this one is active high
		else
			Video_on <= '0';
		end if;
	end process;		
end bhv;