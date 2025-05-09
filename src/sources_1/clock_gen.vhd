----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.04.2025 09:36:06
-- Design Name: 
-- Module Name: clock_gen - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

-------------------------------------------------

entity clock_gen is
  generic (
    n_freq : integer := 250 --! Default number of clk periodes to generate one pulse
  );
  port (
    clk   : in    std_logic; --! Main clock
    pulse : out   std_logic  --! Clock enable pulse signal
  );
end entity clock_gen;

-------------------------------------------------

architecture behavioral of clock_gen is

    --! Local counter
    signal n_half_periods : integer := (100000000 / n_freq) / 2;
    signal sig_count : integer range 0 to (((100000000 / n_freq) / 2) - 1); -- base clock 100MHz
    signal clk_div : std_logic := '0'; -- divided clock signal

    begin
    
        --! Count the number of clock pulses from zero to N_PERIODS-1.
        p_clk_enable : process (clk) is
        begin
    
        if (rising_edge(clk)) then                   -- Synchronous process
    
            -- Counting
            if sig_count < (n_half_periods - 1) then
                sig_count <= sig_count + 1;             -- Increment local counter
    
            -- End of counter reached
            else
                sig_count <= 0;
                clk_div <= not clk_div; -- toggle the clock output
            end if;
        end if;
    
    end process p_clk_enable;

    -- Generated pulse has always 50% duty cycle
    pulse <= clk_div;

end architecture behavioral;