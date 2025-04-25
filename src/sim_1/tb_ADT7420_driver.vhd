-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Thu, 24 Apr 2025 17:54:12 GMT
-- Request id : cfwk-fed377c2-680a7ac4764d0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb_ADT7420_driver is
end tb_ADT7420_driver;

architecture tb of tb_ADT7420_driver is

    component ADT7420_driver
        port (clk              : in std_logic;
              rst              : in std_logic;
              start            : in std_logic;
              response_in      : in std_logic_vector (15 downto 0);
              done_request     : in std_logic;
              address          : out std_logic_vector (6 downto 0);
              read_write       : out std_logic;
              register_address : out std_logic_vector (7 downto 0);
              num_bytes        : out integer;
              temperature      : out integer;
              done_read        : out std_logic);
    end component;

    signal clk              : std_logic;
    signal rst              : std_logic;
    signal start            : std_logic;
    signal response_in      : std_logic_vector (15 downto 0);
    signal done_request     : std_logic;
    signal address          : std_logic_vector (6 downto 0);
    signal read_write       : std_logic;
    signal register_address : std_logic_vector (7 downto 0);
    signal num_bytes        : integer;
    signal temperature      : integer;
    signal done_read        : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : ADT7420_driver
    port map (clk              => clk,
              rst              => rst,
              start            => start,
              response_in      => response_in,
              done_request     => done_request,
              address          => address,
              read_write       => read_write,
              register_address => register_address,
              num_bytes        => num_bytes,
              temperature      => temperature,
              done_read        => done_read);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        
        response_in <= (others => '0');
        done_request <= '0';

        -- Reset generation
        -- ***EDIT*** Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        
        -- Start generation
        start <= '1';
        wait for 100 ns;
        start <= '0';
        wait for 1000 ns;
        
        -- SImulate response of I2C driver
        response_in <= std_logic_vector(to_unsigned(16#C80#, 16)); -- x"190" [15:3] expanded with 0 [2:0] to match 16 bits
        done_request <= '1';
        wait for 1000 ns;
        
        done_request <= '0';
        
        
        -- ***EDIT*** Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_ADT7420_driver of tb_ADT7420_driver is
    for tb
    end for;
end cfg_tb_ADT7420_driver;