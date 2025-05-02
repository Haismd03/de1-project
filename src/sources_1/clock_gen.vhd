-------------------------------------------------
--! @brief Clock enable
--! @version 1.3
--! @copyright (c) 2019-2025 Tomas Fryza, MIT license
--!
--! This VHDL file generates pulses of the clock enable signal.
--! Each pulse is one period of the clock signal wide, and its
--! repetition is determined by the N_PERIODS generic.

--! Developed using TerosHDL, Vivado 2020.2, and EDA Playground.
--! Tested on Nexys A7-50T board and xc7a50ticsg324-1L FPGA.
-------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

-------------------------------------------------

entity clock_gen is
  generic (
    n_freq : integer := 250 --! Default number of clk periodes to generate one pulse
  );
  port (
    clk   : in    std_logic; --! Main clock
    rst   : in    std_logic; --! High-active synchronous reset
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
      if (rst = '1') then                        -- High-active reset
        sig_count <= 0;
        clk_div <= '0';

      -- Counting
      elsif sig_count < (n_half_periods - 1) then
        sig_count <= sig_count + 1;             -- Increment local counter

      -- End of counter reached
      else
        sig_count <= 0;
        clk_div <= not clk_div; -- toggle the clock output
      end if;                                    -- Each `if` must end by `end if`
    end if;

  end process p_clk_enable;

  -- Generated pulse is always one clock long
  pulse <= clk_div;

end architecture behavioral;