-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

package VGA_LIB is

  -----------------------------------------------------------------------------
  -- COUNTER VALUES FOR GENERATING H_SYNC AND V_SYNC
  
  constant H_DISPLAY_END : integer := 639;
  constant HSYNC_BEGIN   : integer := 659;
  constant H_VERT_INC    : integer := 699;
  constant HSYNC_END     : integer := 755;
  constant H_MAX         : integer := 799;

  constant V_DISPLAY_END : integer := 479;
  constant VSYNC_BEGIN   : integer := 493;
  constant VSYNC_END     : integer := 494;
  constant V_MAX         : integer := 524;

  -----------------------------------------------------------------------------
  -- CONSTANTS FOR SIGNAL WIDTHS
  
  constant ROM_ADDR_WIDTH : integer := 8;
  subtype ROM_ADDR_RANGE is natural range ROM_ADDR_WIDTH-1 downto 0;

  constant COUNT_WIDTH : integer := 10;
  subtype COUNT_RANGE is natural range COUNT_WIDTH-1 downto 0;

  -----------------------------------------------------------------------------
  -- CONSTANTS DEFINING PIXEL BOUNDARIES OF THE IMAGE FOR EACH IMAGE LOCATION
  
  constant TOP_LEFT_X_START : integer := 0;
  constant TOP_LEFT_X_END   : integer := 127;
  constant TOP_LEFT_Y_START : integer := 0;
  constant TOP_LEFT_Y_END   : integer := 127;

  constant TOP_RIGHT_X_START : integer := 512;
  constant TOP_RIGHT_X_END   : integer := 639;
  constant TOP_RIGHT_Y_START : integer := 0;
  constant TOP_RIGHT_Y_END   : integer := 127;

  constant BOTTOM_RIGHT_X_START : integer := 512;
  constant BOTTOM_RIGHT_X_END   : integer := 639;
  constant BOTTOM_RIGHT_Y_START : integer := 352;
  constant BOTTOM_RIGHT_Y_END   : integer := 479;

  constant BOTTOM_LEFT_X_START : integer := 0;
  constant BOTTOM_LEFT_X_END   : integer := 127;
  constant BOTTOM_LEFT_Y_START : integer := 352;
  constant BOTTOM_LEFT_Y_END   : integer := 479;

  constant CENTERED_X_START : integer := 256;
  constant CENTERED_X_END   : integer := 383;
  constant CENTERED_Y_START : integer := 176;
  constant CENTERED_Y_END   : integer := 303;

  -----------------------------------------------------------------------------
  -- CONSTANTS FOR BUTTON PRESSES
  
  constant CENTERED		: natural := 0;
  constant TOP_LEFT     : natural := 1;
  constant TOP_RIGHT    : natural := 2;
  constant BOTTOM_LEFT  : natural := 3;
  constant BOTTOM_RIGHT : natural := 4;
  
  ------------------------------------------------------------------------------
  --CONSTANTS FOR PONG
  
  constant Paddle_Width		: integer := 10; --edit to change widht
  constant Paddle_Height		: integer := 80; --edit to change size
  constant Paddle_offset_x	: integer := 30; --edit to change how far from edge of screen
  constant Paddle_start : integer := (V_DISPLAY_END-Paddle_Height)/2;
  constant Paddle_Traverse_Time : real := 1.5; --edit me to change speed of paddle
  constant Paddle_Move_Offset : integer := (V_DISPLAY_END + 1 - Paddle_Height)/integer((Paddle_Traverse_Time*real(60)));
  
  constant Left_Paddle_H_min : integer := Paddle_offset_x;
  constant Left_Paddle_H_max : integer := Left_Paddle_H_min + Paddle_Width;
  constant Right_Paddle_H_min : integer := H_DISPLAY_END - Paddle_offset_x - Paddle_Width;
  constant Right_Paddle_H_max : integer := H_DISPLAY_END - Paddle_offset_x;
  
  constant Ball_size : integer := 5;
  
  constant Ball_Y_Velocity_Change : integer := 2;
 
end VGA_LIB;
