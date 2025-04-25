-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Fri, 25 Apr 2025 09:36:36 GMT
-- Request id : cfwk-fed377c2-680b57a4be11a

library ieee;
use ieee.std_logic_1164.all;

entity tb_seg_drive is
end tb_seg_drive;

architecture tb of tb_seg_drive is

    component seg_drive
        port (clk : in std_logic;
              rst : in std_logic;
              inp : in integer;
              seg : out std_logic_vector (6 downto 0);
              an  : out std_logic_vector (7 downto 0);
              dp  : out std_logic);
    end component;

    signal clk : std_logic;
    signal rst : std_logic;
    signal inp : integer;
    signal seg : std_logic_vector (6 downto 0);
    signal an  : std_logic_vector (7 downto 0);
    signal dp  : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : seg_drive
    port map (clk => clk,
              rst => rst,
              inp => inp,
              seg => seg,
              an  => an,
              dp  => dp);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        inp <= -249137;
        -- Reset generation
        -- ***EDIT*** Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        wait for 100 * TbPeriod;
        
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_seg_drive of tb_seg_drive is
    for tb
    end for;
end cfg_tb_seg_drive;