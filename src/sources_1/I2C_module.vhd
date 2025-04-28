----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.04.2025 19:44:39
-- Design Name: 
-- Module Name: I2C_module - Behavioral
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

entity I2C_module is

    -- generics?

    Port ( address : in STD_LOGIC_VECTOR (6 downto 0); -- 0x4B => 0b1001011
           reg : in STD_LOGIC_VECTOR (7 downto 0); -- 0x00 => 0b00000000
           rw : in STD_LOGIC;
           num_bytes : in integer range 0 to 2;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC; -- 400 kHz
           rst : in STD_LOGIC;
           SDA : inout  STD_LOGIC;
           SCL : out STD_LOGIC;
           response : out STD_LOGIC_VECTOR (7 downto 0);
           done : out STD_LOGIC);
end I2C_module;

architecture Behavioral of I2C_module is

    -- reset constansts
--    constant RESET_LOGIC : STD_LOGIC := '0';
--    constant RESET_LOGIC_VECTOR : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
--    constant RESET_INT : integer := 0;
    
    -- read write logic constants
    constant WRITE : std_logic := '0';
    constant READ  : std_logic := '1';

    type  state_type is (WAIT_FOR_DATA, START_CONDITION, SEND_ADDRESS, SEND_REGISTER, STOP_CONDITION, READ_DATA, CHECK_ACK, NACK);
    signal state : state_type := WAIT_FOR_DATA;
    signal next_state : state_type;
    
    signal bit_cnt : integer range 0 to 7 := 0;
    signal frame_1 : STD_LOGIC_VECTOR (7 downto 0);
    signal frame_2 : STD_LOGIC_VECTOR (7 downto 0);
    signal i : integer := 1; -- iteration
    signal ack_wait : std_logic := '0';
    
begin
--    p_SCL_driver : process (clk, state)
--    begin
--        if (state = SEND_ADDRESS or state = SEND_REGISTER or state = CHECK_ACK or state = STOP_CONDITION) then
--            if (clk = '1') then
--                SCL <= '1';
--            elsif (clk = '0') then
--                SCL <= '0';
--            else
--                SCL <= '0'; -- Default fallback pro nevalidní clk
--            end if;
--        else
--            SCL <= '1';
--        end if;
--    end process;

    p_I2C_module: process (clk)
    begin
        if (rst = '1') then                            
--          response <= (others => RESET_LOGIC);
            frame_1 <= (others => '0');
            frame_2 <= (others => '0');
            
            bit_cnt <= 0;
            done <= '0';            
            -- next state
            state <= WAIT_FOR_DATA;
        end if;      
        
        case state is
            when WAIT_FOR_DATA =>
                SDA <= '1';
                SCL <= '1';
                
                if (rising_edge(clk)) then
                    if (num_bytes /= 0) then                                         
                        frame_1 <= address & WRITE;
                        frame_2 <= reg;
                        -- next state
                        state <= START_CONDITION;
                    end if;
                end if;
                
            when START_CONDITION =>
                -- SDA 1 -> 0, SCL = 1
                if (rising_edge(clk)) then
                    SDA <= '0';
                    -- next state                   
                    state <= SEND_ADDRESS;
                end if;
                                 
            when SEND_ADDRESS =>
                if (falling_edge(clk)) then
                    SCL <= clk; -- 400 kHz
                    SDA <= frame_1(7 - bit_cnt);                                                                      
                    
                    if (bit_cnt = 7) then
                        bit_cnt <= 0; 
                        -- next state                    
                        state <= CHECK_ACK;
                        next_state <= SEND_REGISTER;
                    else
                        bit_cnt <= bit_cnt + 1;                     
                    end if;
                else
                    SCL <= clk; -- rising_edge
                end if;
                             
            when CHECK_ACK =>
                SCL <= clk;
                
--                if (falling_edge(clk)) then
--                    SDA <= 'Z';
--                    if (SDA = '0') then
--                        -- next state
--                        state <= next_state;
--                    else
--                        -- ADT7420s not responding
--                        report "NACK";
--                        -- state <= NACK
--                    end if;
--                end if;
                
                if (falling_edge(clk)) then
                    if ack_wait = '0' then
                        SDA <= 'Z';
                        ack_wait <= '1'; -- wait for another rising_edge
                    end if;

                elsif (rising_edge(clk)) then
                    if ack_wait = '1' then
                        if SDA = '0' then
                            -- ACK
                            state <= next_state;  
                        else
                            -- ADT7420s not responding
                            report "NACK";
                            -- state <= NACK;
                        end if;
                        ack_wait <= '0'; -- reset
                    end if;
                end if;
                                
            when SEND_REGISTER =>
                if (falling_edge(clk)) then
                    SDA <= frame_2(7 - bit_cnt);
                    SCL <= clk;
                    
                    if (bit_cnt = 7) then
                        -- next state
                        state <= CHECK_ACK;
                        next_state <= STOP_CONDITION;
                    else
                        bit_cnt <= bit_cnt + 1;
                    end if;
                else
                    SCL <= clk;
                end if;
                
            when STOP_CONDITION =>
                if (falling_edge(clk)) then
                    -- SDA 0 -> 1, SCL = 1
                    SCL <= '1';
                    SDA <= '1';
                    state <= READ_DATA;
                end if;
                
            when others =>
                state <= WAIT_FOR_DATA; 
                
        end case;
    end process p_I2C_module;
end Behavioral;
