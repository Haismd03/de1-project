----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.05.2025 15:19:17
-- Design Name: 
-- Module Name: I2C_driver - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2C_driver is
    Port ( 
        address : in STD_LOGIC_VECTOR (6 downto 0); -- 0x4B => 0b1001011
        reg : in STD_LOGIC_VECTOR (7 downto 0); -- 0x00 => 0b00000000
        rw : in STD_LOGIC;
        num_bytes : in integer range 0 to 2;
        data : in STD_LOGIC_VECTOR (7 downto 0);
        clk : in STD_LOGIC; -- 400 kHz
        rst : in STD_LOGIC;
        SDA : inout  STD_LOGIC;
        SCL : out STD_LOGIC;
        response : out STD_LOGIC_VECTOR (15 downto 0);
        done : out STD_LOGIC;
        done_master_read : in STD_LOGIC;
        bit_error : out STD_LOGIC
    );
end I2C_driver;

architecture Behavioral of I2C_driver is
    signal frame_read : std_logic_vector(15 downto 0);
    
    signal SDA_drive : std_logic := 'Z';
    signal SCL_drive : std_logic := 'Z';
    
    signal counter : integer := 0;
    
    type  state_type is (RESET, IDLE, START, SEND_ADDRESS, CHECK_ACK, CHECK_ACK_2, SEND_REGISTER, ERROR);
    signal state : state_type := RESET;
begin
    
    rising_process : process(clk)
    begin
        if (rising_edge(clk)) then
        
            if (rst = '1') then               
                state <= RESET;
            end if;  
        
            case state is
                when RESET =>
                    SDA_drive <= 'Z';
                    SCL_drive <= 'Z';  
                               
                    response <= (others => '0');
                    frame_read <= (others => '0');
                    
                    done <= '0';   
                    bit_error <= '0';
                             
                    -- next state
                    if (rst /= '1') then
                        --state <= IDLE;
                        state <= IDLE;
                    end if;
                    
                 when IDLE =>
                    if (num_bytes /= 0) then
                        state <= START;
                    end if;   
                    
                when START =>
                    state <= SEND_ADDRESS;
                    
                when SEND_ADDRESS =>
                    if (counter < 7) then
                        counter <= counter + 1;
                    else
                        state <= CHECK_ACK;
                        counter <= 0;
                    end if; 
                    
                when CHECK_ACK =>
                    if (SDA = 'H') then
                        state <= SEND_REGISTER;
                    else
                        state <= ERROR;
                    end if; 
                    
                when SEND_REGISTER =>
                    if (counter < 7) then
                        counter <= counter + 1;
                    else
                        state <= CHECK_ACK_2;
                        counter <= 0;
                    end if;  
                    
                when CHECK_ACK_2 =>
                    if (SDA = 'H') then
                        state <= START;
                    else
                        state <= ERROR;
                    end if;               
                    
                when others =>
                    -- do nothing
                    SDA_drive <= 'Z';
            end case;
        end if;
    end process;
    
    falling_process : process(clk)
    begin
        if (falling_edge(clk)) then
            case state is
            
                when START =>
                    SDA_drive <= '0';
                        
                when SEND_ADDRESS =>
                    SDA_drive <= 'Z';   -- replace with actual value
                    
                when SEND_REGISTER =>
                    SDA_drive <= 'Z';   -- replace with actual value
                    
                when others =>
                    -- do nothing
                    SDA_drive <= 'Z'; 
            end case;
        end if;
    end process;
    
    p_SCL_driver : process (clk)
    begin
        if (state /= START and state /= IDLE and state /= RESET) then
            if (clk = '1') then
                SCL <= 'Z';
            elsif (clk = '0') then
                SCL <= '0';
            else
                SCL <= '0'; -- Default fallback for not valid clk
            end if;
        else
            SCL <= 'Z';
        end if;
    end process;
    
    SDA <= SDA_drive;
    SCL <= SCL_drive;

end Behavioral;
