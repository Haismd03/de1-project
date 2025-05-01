----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.04.2025 22:11:24
-- Design Name: 
-- Module Name: top_level - Behavioral
-- Project Name: DE1 - I2C comm
-- Target Devices: Nexys A7-50t
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    generic (
        I2C_CLK_FREQ : integer := 400000; -- 400 kHz
        START_CLK_FREQ : integer := 1 -- 1 Hz
    );
    port (
        -- clock
        CLK100MHZ : in std_logic; --! Main clock
        
        -- buttons
        BTNC      : in std_logic; -- synchronous reset
        
        -- ADT7420 I2C pins
        TMP_SDA : inout std_logic;
        TMP_SCL : out std_logic;
        
        -- 7 segment display
        CA : out std_logic; --! Cathode of segment A
        CB : out std_logic; --! Cathode of segment B
        CC : out std_logic; --! Cathode of segment C
        CD : out std_logic; --! Cathode of segment D
        CE : out std_logic; --! Cathode of segment E
        CF : out std_logic; --! Cathode of segment F
        CG : out std_logic; --! Cathode of segment G
        DP : out std_logic; --! Decimal point
        AN : out std_logic_vector(7 downto 0) --! Common anodes of all on-board displays
    );
end top_level;

architecture Behavioral of top_level is
    component clock_enable is
        generic (
            n_freq : integer -- 400 Khz
        );
        port (
            clk   : in    std_logic; --! Main clock
            rst   : in    std_logic; --! High-active synchronous reset
            pulse : out   std_logic  --! Clock enable pulse signal
        );
    end component clock_enable;
    
    component I2C_module is
        Port ( 
            address : in STD_LOGIC_VECTOR (6 downto 0);
            reg : in STD_LOGIC_VECTOR (7 downto 0);
            rw : in STD_LOGIC;
            num_bytes : in integer range 0 to 2;
            data : in STD_LOGIC_VECTOR (7 downto 0);
            clk : in STD_LOGIC; -- 400 kHz
            rst : in STD_LOGIC;
            SDA : inout  STD_LOGIC;
            SCL : out STD_LOGIC;
            response : out STD_LOGIC_VECTOR (15 downto 0);
            done : out STD_LOGIC
        );
    end component I2C_module;
    
    component ADT7420_driver is
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;
            
            response_in : in std_logic_vector(15 downto 0);
            done_request : in std_logic;
            
            address : out std_logic_vector(6 downto 0);
            read_write : out std_logic;
            register_address : out std_logic_vector(7 downto 0);
            num_bytes : out integer range 0 to 2;
            temperature : out integer;
            done_read : out std_logic
        );
    end component ADT7420_driver;
    
    component seg_drive is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            inp : in INTEGER;
            seg : out STD_LOGIC_VECTOR (6 downto 0);
            an : out STD_LOGIC_VECTOR (7 downto 0);
            dp : out STD_LOGIC
        );
    end component seg_drive;
    
    signal clk_400_kHz : std_logic;
    signal clk_1_Hz : std_logic;
    
    signal I2C_response : std_logic_vector(15 downto 0);
    signal I2C_done_request : std_logic;
    signal I2C_ADT7420_address : std_logic_vector(6 downto 0); -- I2C adress without R/W bit
    signal I2C_read_write : std_logic;
    signal I2C_register_address : std_logic_vector(7 downto 0);
    signal I2C_num_bytes : integer range 0 to 2;
    signal I2C_done_read : std_logic;
    
    signal temperature : integer; -- in 10E4 °C
    
    -- temp signals
    signal temp_I2C_data : STD_LOGIC_VECTOR (7 downto 0);
begin

    I2C_clk : component clock_enable
        generic map ( 
            n_freq => I2C_CLK_FREQ
        )
        port map (
            clk => CLK100MHZ,
            rst => BTNC,
            pulse => clk_400_kHz
        );
        
    start_clk : component clock_enable
        generic map ( 
            n_freq => START_CLK_FREQ
        )
        port map (
            clk => CLK100MHZ,
            rst => BTNC,
            pulse => clk_1_Hz
        );
        
    ADT_driver : component ADT7420_driver
        port map (
            clk => clk_400_kHz,
            rst => BTNC,
            start => clk_1_Hz,
            
            response_in => I2C_response,
            done_request => I2C_done_request,
            
            address => I2C_ADT7420_address,
            read_write => I2C_read_write,
            register_address => I2C_register_address,
            num_bytes => I2C_num_bytes,
            done_read => I2C_done_read,
            
            temperature => temperature
        );
        
    I2C_driver : component I2C_module
        port map ( 
            clk => clk_400_kHz, -- 400 kHz
            rst => BTNC,
            
            address => I2C_ADT7420_address,
            rw => I2C_read_write,
            reg => I2C_register_address,        
            num_bytes => I2C_num_bytes,
            data => temp_I2C_data,
            SDA => TMP_SDA,
            SCL => TMP_SCL,
            response => I2C_response,
            done => I2C_done_read
        );
        
--    display : component seg_drive
--        port map (
--            clk => clk_400_kHz,
--            rst => BTNC,
--            inp => temperature,
--            seg(6) => CA,
--            seg(5) => CB,
--            seg(4) => CC,
--            seg(3) => CD,
--            seg(2) => CE,
--            seg(1) => CF,
--            seg(0) => CG,
--            an => AN,
--            dp => DP
--        );

end Behavioral;
