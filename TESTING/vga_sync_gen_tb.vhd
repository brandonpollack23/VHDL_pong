library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity vga_sync_gen_tb is
end vga_sync_gen_tb;

architecture bhv of vga_sync_gen_tb is

signal clk50Mhz	: std_logic := '0';
signal clk25Mhz	: std_logic;
signal rst			: std_logic;
signal Hcount,Vcount : std_logic_vector(COUNT_WIDTH-1 downto 0);
signal Horiz_Sync,Vert_Sync,Video_on : std_logic;

signal done     : std_logic := '0';

constant A_time : time := 32 us; --period of horiz synch timer
constant B_time : time := 4 us; --pulse time of horiz synch
constant C_time : time := 2 us; --time between horiz sync false (rising edge) and end of timer(video on going true)
constant D_time : time := 25600 ns; --Video on time (rgb data)
constant E_time : time := 1 us; --Video on going false to horiz sync pulse begin(falling edge)
constant O_time : time := 166000 us; --Periode of vert sync timer
constant P_time : time := 64 us; --pulse time of vert synch (same as 2 horizontal rows)
constant Q_time : time := 10200 us; --time after end of v_sync pulse to end of timer
constant R_time : time := 152500 us; --time for all horizontal rows to complete
constant S_time : time := 3500 us; --time from last horizontal row completing to V_sync going true (low)

begin
	U_CLKDIV2: entity work.clk_div_2
	port map
	(
		rst => rst,
		clk_in => clk50Mhz,
		clk_out => clk25Mhz
	);
	
	U_VGA_SYNC_GEN: entity work. vga_sync_gen
	port map
	(
		clk => clk25Mhz,
		rst => rst,
		Hcount => Hcount,
		Vcount => Vcount,
		Horiz_Sync => Horiz_Sync,
		Vert_Sync => Vert_Sync,
		Video_on => Video_on
	);
	
	clk50MHz <= not clk50MHz and not done after 10 ns;
	
	process
	
	variable before_A,after_A,before_B,after_B,before_C,after_C,before_D,after_D,before_E,after_E : time;
	variable before_O,after_O,before_P,after_P,before_Q,after_Q,before_R,after_R,before_S,after_S : time;
	
	begin
		rst <= '1';
		wait for 50 ns;
		
		rst <= '0';
		
		before_O := now; --start measuring the period of one vertical refresh cycle
		before_R := now; --start of the horizontal refresh cycles
		for i in 1 to 480 loop --one horizontal row is one iteration, and there are 480 rows
			before_A := now; --start of period of Horizontal refresh (640 pixels)
			
			before_D := now; --start of Video_on			
			wait until Video_on = '0' for 2*D_time; --wait for twice as long as I should
			after_D := now;
			
			assert(Video_on = '0')
				report "Video_on never turns off correctly at " & time'image(now) severity error;				
			assert((after_D - before_D) <= D_time)
				report "D time took too long " & time'image(after_D - before_D) & " > " & time'image(D_time) severity warning;
				
			before_E := now;
			wait until Horiz_Sync = '0' for 2*E_time; --time to wait before horiz sync goes true after we are done with the row
			after_E := now;
			
			assert(Horiz_Sync = '0')
				report "Horiz_Sync never goes true correctly at " & time'image(now) severity error;
			assert((after_E - before_E) <= E_time)
				report "E time took too long " & time'image(after_D - before_D) & " > " & time'image(E_time) severity warning;
			
			before_B := now;
			wait until Horiz_Sync = '1' for 2*B_time;
			after_B := now;
			
			assert(Horiz_Sync = '1')
				report "Horiz_Sync never goes false correctly at " & time'image(now) severity error;
			assert((after_B - before_B) <= B_time)
				report "B time took too long " & time'image(after_B - before_B) & " > " & time'image(B_time) severity warning;
				
			before_C := now;
			wait until unsigned(Hcount) = 0 for 2*C_time;
			after_C := now;
			
			if(i /= 480) then
				assert(Video_on = '1')
					report "Video_on never goes true correctly at " & time'image(now) severity error;
			end if;
			
			assert((after_C - before_C) <= C_time)
				report "C time took too long " & time'image(after_C - before_C) & " > " & time'image(C_time) severity warning;
				
			after_A := now;
			
			assert((after_A - before_A) <= A_time)
				report "A time took too long " & time'image(after_A - before_A) & " > " & time'image(A_time) severity warning;					
		end loop;
		
		after_R := now;
		
		assert((after_R - before_R) <= R_time)
				report "R time took too long " & time'image(after_R - before_R) & " > " & time'image(R_time) severity warning;
				
		before_S := now;
		wait until Vert_Sync = '0' for 2*S_time;
		after_S := now;
		
		assert(Vert_Sync = '0')
			report "Vert_sync never goes true correctly at " & time'image(now) severity error;
		assert((after_S - before_S) <= S_time)
			report "S time took too long " & time'image(after_S - before_S) & " > " & time'image(S_time) severity warning;
			
		before_P := now;
		wait until Vert_Sync = '1' for 2*P_time;
		after_P := now;
		
		assert(Vert_Sync = '1')
			report "Vert_Sync never goes false correctly at " & time'image(now) severity error;
		assert((after_P - before_P) <= P_time)
				report "P time took too long " & time'image(after_P - before_P) & " > " & time'image(P_time) severity warning;
				
		before_Q := now;
		wait until Video_on = '1' for 2*Q_time;
		after_Q := now;
		
		assert(Video_on = '1')
			report "Video_on never goes true correctly at " & time'image(now) severity error;
		assert((after_Q - before_Q) <= Q_time)
				report "Q time took too long " & time'image(after_Q - before_Q) & " > " & time'image(Q_time) severity warning;
		
		after_O := now;
		
		assert((after_O - before_O) <= O_time)
			report "O time took too long " & time'image(after_O - before_O) & " > " & time'image(O_time) severity warning;
		
			
		done <= '1';
		
		report "DONE!!!";
		wait;
	end process;
end bhv;
	
	
	
	