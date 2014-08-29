library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity row_addr_logic is
port
(
	Vcount : in std_logic_vector(COUNT_WIDTH-1 downto 0);
	position_select : in std_logic_vector(2 downto 0);
	row : out std_logic_vector(5 downto 0);
	image_enable : out std_logic
);
end row_addr_logic;

architecture bhv of row_addr_logic is

signal Y_start,Y_end : integer;
signal row_u : unsigned(COUNT_WIDTH-1 downto 0);

begin	
	process(position_select) --process to get Y_start and Y_end
	begin
		if(position_select = "000") then
			Y_start <= CENTERED_Y_START;
			Y_end <= CENTERED_Y_END;
		elsif(position_select = "001") then
			Y_start <= TOP_LEFT_Y_START;
			Y_end <= TOP_LEFT_Y_END;
		elsif(position_select = "010") then
			Y_start <= TOP_RIGHT_Y_START;
			Y_end <= TOP_RIGHT_Y_END;
		elsif(position_select = "011") then
			Y_start <= BOTTOM_LEFT_Y_START;
			Y_end <= BOTTOM_LEFT_Y_END;
		elsif(position_select = "100") then
			Y_start <= BOTTOM_RIGHT_Y_START;
			Y_end <= BOTTOM_RIGHT_Y_END;
		else
			Y_start <= CENTERED_Y_START;
			Y_end <= CENTERED_Y_END;
		end if;	
	end process;
	
	process(Vcount,Y_start,position_select) --process to output image_enable
	begin
		if(unsigned(Vcount) > Y_start and unsigned(Vcount) <= Y_end) then
			image_enable <= '1';
		else
			image_enable <= '0';
		end if;
	end process;
	
	row_u <= (unsigned(Vcount) - Y_start)/2;
	row <= std_logic_vector(row_u(5 downto 0));
end bhv;