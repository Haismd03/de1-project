library ieee;
use ieee.std_logic_1164.all;

entity tb_I2C_module is
end tb_I2C_module;

architecture tb of tb_I2C_module is

    component I2C_module
        port (
            address   : in std_logic_vector(6 downto 0);
            reg       : in std_logic_vector(7 downto 0);
            rw        : in std_logic;
            num_bytes : in integer;
            data      : in std_logic_vector(7 downto 0);
            clk       : in std_logic;
            rst       : in std_logic;
            SDA       : inout std_logic;
            SCL       : out std_logic;
            response  : out std_logic_vector(7 downto 0);
            done      : out std_logic
        );
    end component;

    -- Signály pro propojení
    signal address   : std_logic_vector(6 downto 0) := (others => '0');
    signal reg       : std_logic_vector(7 downto 0) := (others => '0');
    signal rw        : std_logic;
    signal num_bytes : integer;
    signal data      : std_logic_vector(7 downto 0) := (others => '0');
    signal clk       : std_logic := '0';
    signal rst       : std_logic;
    signal SDA       : std_logic; -- := 'Z';
    signal SCL       : std_logic;
    signal response  : std_logic_vector(7 downto 0);
    signal done      : std_logic;

    constant TbPeriod : time := 250 ns;
    signal TbSimEnded : std_logic := '0';

begin

    -- Propojení DUT
    dut : I2C_module
        port map (
            address   => address,
            reg       => reg,
            rw        => rw,
            num_bytes => num_bytes,
            data      => data,
            clk       => clk,
            rst       => rst,
            SDA       => SDA,
            SCL       => SCL,
            response  => response,
            done      => done
        );

    -- Generování hodin
    clk <= not clk after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- Stimuli process
    stimuli : process
    begin
        -- Inicializace
        address <= (others => '0');
        reg <= (others => '0');
        rw <= '0';
        SDA <= 'H'; -- weak pull up
        SCL <= 'H'; -- weak pull up
        num_bytes <= 0;
        rst <= '0';
        
        wait for 2*TbPeriod;
         
        -- Reset
--        rst <= '1'; -- resetování modulu pokud bude potřeba
--        wait for 2*TbPeriod;
--        rst <= '0';
--        wait for 2*TbPeriod;

        -- ADT7420 driver
        address <= "1001011"; -- 0x4B
        reg <= "00000000";    -- 0x00
        num_bytes <= 2;
        
        -- nepoužívá se prozatim
        --data <= (others => '0'); 
        --response <= (others => '0');
        --done <= '0';

        -- Počkat než začne odesílání adresy
        wait for 10*TbPeriod;

        -- První ACK po adrese
        SDA <= '0'; -- Slave drží sběrnici na 0
        wait for TbPeriod;
        SDA <= 'H'; -- Uvolnění sběrnice

        -- Počkat než začne odesílání registru
        wait for 2250 ns;

        -- Druhý ACK po registru
        SDA <= '0';
        wait for TbPeriod;
        SDA <= 'H';

        -- Počkáme na konec přenosu
        wait for 1250 ns;

        -- Ukončení simulace
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Konfigurace (většinou není třeba upravovat)
configuration cfg_tb_I2C_module of tb_I2C_module is
    for tb
    end for;
end cfg_tb_I2C_module;
