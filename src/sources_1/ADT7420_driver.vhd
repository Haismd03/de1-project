----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2025 00:16:25
-- Design Name: 
-- Module Name: ADT7420_driver - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADT7420_driver is
    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        
        response_in : in std_logic_vector(15 downto 0);
        done_request : in std_logic;
        i2c_error : in std_logic;
        
        address : out std_logic_vector(6 downto 0);
        read_write : out std_logic;
        register_address : out std_logic_vector(7 downto 0);
        num_bytes : out integer range 0 to 2;
        temperature : out integer;
        done_read : out std_logic
    );
end ADT7420_driver;

architecture Behavioral of ADT7420_driver is

    -- read write logic constants
    constant WRITE : std_logic := '0';
    constant READ  : std_logic := '1';

    -- reset constansts
    constant RESET_LOGIC : std_logic := '0';
    constant RESET_INT : integer := 0;

    -- register map
    constant TEMP_REGISTER : std_logic_vector(7 downto 0) := x"00";

    type state_t is (RESET_STATE, WAIT_FOR_START_STATE, REQUEST_TEMP_STATE, CONVERT_TEMP_STATE);
    signal state : state_t := RESET_STATE;
    
    signal latch_start : std_logic := '0';

begin
    p_adt7420_driver : process (clk, start) is
    variable temp_temperature : integer := 0;
    begin
    
        if (rising_edge(start)) then
            latch_start <= '1';
        end if;
    
        if(rising_edge(clk)) then
            if (rst = '1') then
                state <= RESET_STATE;
            end if;
            
            case state is
                when RESET_STATE => -- reset
                    address <= (others => RESET_LOGIC);
                    read_write <= RESET_LOGIC;
                    register_address <= (others => RESET_LOGIC);
                    num_bytes <= RESET_INT;
                    done_read <= RESET_LOGIC;
                    
                    latch_start <= '0';                  
                    temperature <= RESET_INT;
                    
                    -- next state
                    if (rst /= '1') then
                        state <= WAIT_FOR_START_STATE;
                    end if;
                    
                when WAIT_FOR_START_STATE =>
                    address <= (others => RESET_LOGIC);
                    read_write <= RESET_LOGIC;
                    register_address <= (others => RESET_LOGIC);
                    num_bytes <= RESET_INT;
                    done_read <= RESET_LOGIC;
                    
                    -- next state
                    if (latch_start = '1') then
                        state <= REQUEST_TEMP_STATE;
                    end if;                              
                        
                when REQUEST_TEMP_STATE =>
                    address <= std_logic_vector(to_unsigned(16#4B#, 7)); -- I2C address
                    read_write <= READ;
                    register_address <= TEMP_REGISTER;
                    num_bytes <= 2;
                    
                    latch_start <= '0';
                    temperature <= RESET_INT;
                    
                    -- next state
                    if (done_request = '1') then
                        state <= CONVERT_TEMP_STATE;
                    elsif (i2c_error = '1') then
                        state <= WAIT_FOR_START_STATE;
                    end if;
                    
                when CONVERT_TEMP_STATE =>
                    temp_temperature := to_integer(signed(response_in(15 downto 3))) * 625; -- should be 0.0625
                    
                    if (temp_temperature <= 800000 and temp_temperature >= -400000) then
                        temperature <= temp_temperature;
                    end if;  
                    
                    done_read <= '1';
                    
                    -- next state
                    state <= WAIT_FOR_START_STATE;
            end case;
        end if;                       
    end process p_adt7420_driver;              
end architecture Behavioral;
