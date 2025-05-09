-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Wed, 30 Apr 2025 18:40:34 GMT
-- Request id : cfwk-fed377c2-68126ea24df27

library ieee;
use ieee.std_logic_1164.all;

entity tb_top_level is
end tb_top_level;

architecture tb of tb_top_level is
    
    component top_level
        generic (
            I2C_CLK_FREQ : integer := 400000; -- 400 kHz
            START_CLK_FREQ : integer := 1 -- 1 Hz
        );
        port (CLK100MHZ : in std_logic;
              BTNC      : in std_logic;
              TMP_SDA   : inout std_logic;
              TMP_SCL   : inout std_logic;
              CA        : out std_logic;
              CB        : out std_logic;
              CC        : out std_logic;
              CD        : out std_logic;
              CE        : out std_logic;
              CF        : out std_logic;
              CG        : out std_logic;
              DP        : out std_logic;
              AN        : out std_logic_vector (7 downto 0));
    end component;

    signal CLK100MHZ : std_logic;
    signal BTNC      : std_logic;
    signal TMP_SDA   : std_logic := 'H';
    signal TMP_SCL   : std_logic;
    signal CA        : std_logic;
    signal CB        : std_logic;
    signal CC        : std_logic;
    signal CD        : std_logic;
    signal CE        : std_logic;
    signal CF        : std_logic;
    signal CG        : std_logic;
    signal DP        : std_logic;
    signal AN        : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    
    signal scl_count : integer := 0;
    signal ack_times : integer := 0;
    signal i2c_cycle_count : integer := 0;
    signal tb_generate_ACK : std_logic := '0';
    
    signal temp_value : std_logic_vector (15 downto 0);

begin

    dut : top_level
    generic map (
        I2C_CLK_FREQ => 400000,
        START_CLK_FREQ => 5000
    )
    port map (CLK100MHZ => CLK100MHZ,
              BTNC      => BTNC,
              TMP_SDA   => TMP_SDA,
              TMP_SCL   => TMP_SCL,
              CA        => CA,
              CB        => CB,
              CC        => CC,
              CD        => CD,
              CE        => CE,
              CF        => CF,
              CG        => CG,
              DP        => DP,
              AN        => AN);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that CLK100MHZ is really your main clock signal
    CLK100MHZ <= TbClock;

    stimuli : process
    begin
    
        TMP_SDA <= 'H';
        TMP_SCL <= 'H';
    
        -- Reset sequence
        BTNC <= '1';
        wait for 8 us;
        BTNC <= '0';
        
        temp_value <= b"0000110010000111";

        -- Loop to simulate ACK timing
        while true loop
            wait until falling_edge(TMP_SCL);
            scl_count <= scl_count + 1;
            
            if (i2c_cycle_count < 2) then
                if (scl_count >= 8 and ack_times < 2) then
                    TMP_SDA <= '0';
                    scl_count <= 0;
                    tb_generate_ACK <= '1';
                    ack_times <= ack_times + 1;
                elsif (scl_count >= 9 and ack_times = 2) then
                    TMP_SDA <= '0';
                    scl_count <= 0;
                    tb_generate_ACK <= '1';
                    ack_times <= ack_times + 1;
                elsif (scl_count >= 8 and ack_times = 3) then
                    scl_count <= 0;
                    ack_times <= ack_times + 1;  
                elsif (scl_count >= 8 and ack_times = 4) then
                    scl_count <= 0;
                    ack_times <= ack_times + 1;
                elsif (scl_count >= 0 and ack_times = 5) then
                    scl_count <= 0;
                    ack_times <= 0;
                    i2c_cycle_count <= i2c_cycle_count + 1;
                else
                    TMP_SDA <= 'H'; 
                    tb_generate_ACK <= '0'; 
                end if;
                
                if (ack_times = 3 and scl_count < 8) then
                    if (temp_value(15 - scl_count) = '1') then    
                        TMP_SDA <= 'H';
                        tb_generate_ACK <= 'H';
                    else
                        TMP_SDA <= '0';
                        tb_generate_ACK <= '0';
                    end if;
                end if;
                
                if (ack_times = 4 and scl_count < 8) then
                    if (temp_value(7 - scl_count) = '1') then    
                        TMP_SDA <= 'H';
                        tb_generate_ACK <= 'H';
                    else
                        TMP_SDA <= '0';
                        tb_generate_ACK <= '0';
                    end if;
                end if;
            end if;
        end loop;
        
        -- Not reached unless you break from loop
        TbSimEnded <= '1';
        wait;
    end process;
end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_top_level of tb_top_level is
    for tb
    end for;
end cfg_tb_top_level;