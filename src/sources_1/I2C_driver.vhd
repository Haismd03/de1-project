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
        SCL : inout STD_LOGIC;
        response : out STD_LOGIC_VECTOR (15 downto 0);
        done : out STD_LOGIC;
        done_master_read : in STD_LOGIC;
        bit_error : out STD_LOGIC
    );
end I2C_driver;

architecture Behavioral of I2C_driver is  
    signal SDA_drive : std_logic := 'Z';
    signal SCL_drive : std_logic := 'Z';
    signal disable_auto_SCL : std_logic := '1';
    
    signal counter : integer := 0;
    signal read_counter : integer := 0;
    
    type state_type is (RESET, IDLE, START, ERROR, STOP,
                        SEND_ADDRESS_W, SEND_ADDRESS_R, SEND_REGISTER, SEND_ACK, SEND_NACK,
                        CHECK_ACK, READ_DATA,
                        SEND_TO_MASTER, END_STATE);
    type state_array is array(integer range <>) of state_type;

    constant state_sequence : state_array := (
        RESET,
        IDLE,
        START,
        SEND_ADDRESS_W,
        CHECK_ACK,
        SEND_REGISTER,
        CHECK_ACK,
        START,
        SEND_ADDRESS_R,
        CHECK_ACK,
        READ_DATA,
        SEND_ACK,
        READ_DATA,
        SEND_NACK,
        STOP,
        SEND_TO_MASTER, 
        END_STATE -- last state -> reset when done
    );

    signal state : state_type := RESET;
    signal state_idx : integer := state_sequence'low;
begin
    
    rising_process : process(clk)
        variable read_size : integer := 0;
    begin
        if (rising_edge(clk)) then
        
            if (rst = '1') then               
                state <= RESET;
            end if;  
        
            case state is
                when RESET =>
                    SDA_drive <= 'Z';
                    SCL_drive <= 'Z';  
                               
                    done <= '0';
                    bit_error <= '0';
                    response <= (others => '0');
                    
                    counter <= 0;
                    read_counter <= 0;
                             
                    -- next state
                    if (rst /= '1') then
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if;
                    
                 when IDLE =>
                    if (num_bytes /= 0) then
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if;   
                    
                when START =>
                    if (counter = 0) then
                        disable_auto_SCL <= '1';
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        
                        disable_auto_SCL <= '0';
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if;
                    
                when SEND_ADDRESS_W =>
                    if (counter < 7) then
                        counter <= counter + 1;
                    else
                        counter <= 0;
                    
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;  
                    end if; 
                    
                when SEND_ADDRESS_R =>
                    if (counter < 7) then
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if; 
                    
                when CHECK_ACK =>
                    if (SDA = '0') then
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    else
                        state <= ERROR;
                    end if; 
                    
                when SEND_REGISTER =>
                    if (counter < 7) then
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if; 
                    
                when READ_DATA =>
                    read_size := 8*(num_bytes - read_counter) - 1;
                    if (SDA = 'H') then
                        response(read_size - counter) <= '1';
                    else
                        response(read_size - counter) <= '0';
                    end if;
                    
                    if (counter < 7) then
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        read_counter <= read_counter + 1;
                        
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if; 
                    
                when SEND_ACK =>
                    state <= state_sequence(state_idx);
                    state_idx <= state_idx + 1;
                    
                WHEN SEND_NACK =>
                    state <= state_sequence(state_idx);
                    state_idx <= state_idx + 1;   
                 
                WHEN STOP =>
                    if (counter = 0) then
                        disable_auto_SCL <= '1';
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        
                        disable_auto_SCL <= '1';
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if;
                    
                WHEN SEND_TO_MASTER =>
                    done <= '1';
                    if (done_master_read = '1') then
                        state <= state_sequence(state_idx);
                        state_idx <= state_idx + 1;
                    end if;
                    
                WHEN END_STATE =>
                    state <= RESET;
                    state_idx <= state_sequence'low; 
                    
                when ERROR =>
                    bit_error <= '1';
                    state <= RESET;
                    state_idx <= state_sequence'low;                 
                    
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
                    if (counter = 0) then
                        SDA_drive <= 'Z';
                    elsif (counter = 1) then
                        SDA_drive <= '0';
                    end if;
                        
                when SEND_ADDRESS_W =>
                    if ((7 - counter) > 0) then
                        if (address(6 - counter) = '1') then    
                            SDA_drive <= 'Z';
                        else
                            SDA_drive <= '0';
                        end if;
                    else
                        SDA_drive <= '0';
                    end if;
                    
                when SEND_ADDRESS_R =>
                    if ((7 - counter) > 0) then
                        if (address(6 - counter) = '1') then    
                            SDA_drive <= 'Z';
                        else
                            SDA_drive <= '0';
                        end if;
                    else
                        SDA_drive <= 'Z';
                    end if;
                    
                when SEND_REGISTER =>
                    if (reg(7 - counter) = '1') then    
                        SDA_drive <= 'Z';
                    else
                        SDA_drive <= '0';
                    end if;
                    
                when SEND_ACK =>
                    SDA_drive <= '0';
                    
                when SEND_NACK =>
                    SDA_drive <= 'Z';
                    
                when STOP =>
                    if (counter = 0) then
                        SDA_drive <= '0';
                    elsif (counter = 1) then
                        SDA_drive <= 'Z';
                    end if;   
                     
                when others =>
                    -- do nothing
                    SDA_drive <= 'Z'; 
            end case;
        end if;
    end process;
    
    p_SCL_driver : process (clk)
    begin
        if (disable_auto_SCL = '0') then
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
