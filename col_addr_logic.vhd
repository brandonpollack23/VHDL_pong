library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity col_addr_logic is
port
(
	Hcount : in std_logic_vector(COUNT_WIDTH-1 downto 0);
	position_select : in std_logic_vector(2 downto 0);
	col : out std_logic_vector(5 downto 0);
	image_enable : out std_logic
);
end col_addr_logic;

architecture bhv of col_addr_logic is

signal X_start,X_end : integer;
signal col_u : unsigned(COUNT_WIDTH-1 downto 0);

begin
	
	process(position_select) --process to get Y_start and Y_end
	begin
		if(position_select = "000") then
			X_start <= CENTERED_X_START;
			X_end <= CENTERED_X_END;
		elsif(position_select = "001") then
			X_start <= TOP_LEFT_X_START;
			X_end <= TOP_LEFT_X_END;
		elsif(position_select = "010") then
			X_start <= TOP_RIGHT_X_START;
			X_end <= TOP_RIGHT_X_END;
		elsif(position_select = "011") then
			X_start <= BOTTOM_LEFT_X_START;
			X_end <= BOTTOM_LEFT_X_END;
		elsif(position_select = "100") then
			X_start <= BOTTOM_RIGHT_X_START;
			X_end <= BOTTOM_RIGHT_X_END;
		else
			X_start <= CENTERED_X_START;
			X_end <= CenTERED_X_END;
		end if;	
	end process;
	
	process(Hcount,X_start,position_select) --process to output image_enable
	begin
		if(unsigned(Hcount) > X_start and unsigned(Hcount) <= X_end) then
			image_enable <= '1';
		else
			image_enable <= '0';
		end if;
	end process;
	
	col_u <= (unsigned(Hcount) - X_start)/2;
	col <= std_logic_vector(col_u(5 downto 0));
end bhv;