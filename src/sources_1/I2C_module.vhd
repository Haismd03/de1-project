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

    Port ( address : in STD_LOGIC_VECTOR (6 downto 0); -- 0x4B => 0b1001011
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
           bit_error : out STD_LOGIC);
end I2C_module;

architecture Behavioral of I2C_module is
    
    -- read write logic constants
    constant WRITE : std_logic := '0';
    constant READ  : std_logic := 'Z';

    type  state_type is (RESET, WAIT_FOR_DATA, START_CONDITION, SEND_ADDRESS, SEND_REGISTER, STOP_CONDITION, READ_DATA,
    CHECK_ACK, SEND_ACK, SEND_NACK, NACK, SEND_DATA_TO_MASTER);
    signal state : state_type := RESET;
    signal next_state : state_type;
    
    signal bit_cnt : integer range 0 to 7 := 0;
    signal frame_1 : STD_LOGIC_VECTOR (7 downto 0);
    signal frame_2 : STD_LOGIC_VECTOR (7 downto 0);
    
begin
    p_SCL_driver : process (clk)
    begin
        if (state = SEND_ADDRESS or state = SEND_REGISTER or state = CHECK_ACK) then
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

    p_I2C_module: process (clk)
    begin
        if (rst = '1') then               
            state <= RESET;
        end if;      
        
        case state is
            when RESET =>
                SDA <= 'Z';
                SCL <= 'Z';             
                --response <= (others => RESET_LOGIC);
                frame_1 <= (others => '0');
                frame_2 <= (others => '0');
                
                bit_cnt <= 0;
                done <= '0';            
                -- next state
                if (rst /= '1') then
                    state <= WAIT_FOR_DATA;
                end if;
                
            when WAIT_FOR_DATA =>
                SDA <= 'Z';
            
                if (rising_edge(clk)) then
                    if (num_bytes /= 0) then  
                                      
                        -- frame 1       
                        for i in 0 to 6 loop
                            if address(6 - i) = '1' then
                                frame_1(7 - i) <= 'Z'; -- Z stands for 1 (open-drain com)
                            else
                                frame_1(7 - i) <= '0'; -- 0 stands for 0 
                            end if;
                        end loop;
                        frame_1(0) <= WRITE; -- bit W/R
                                                
                        -- frame 2                               
                        for i in 0 to 7 loop
                            if reg(i) = '1' then
                                frame_2(i) <= 'Z';
                            else
                                frame_2(i) <= '0';
                            end if;
                        end loop;                        
                        
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
                    if (bit_cnt < 8) then
                        SDA <= frame_1(7 - bit_cnt);
                        bit_cnt <= bit_cnt + 1;
                        
                    else --  for 8 bits you need 9 falling edges
                        bit_cnt <= 0; 
                        --SDA <= 'Z';                      
                        -- next state                    
                        state <= CHECK_ACK;                       
                        if (next_state /= READ_DATA) then
                            next_state <= SEND_REGISTER;
                        end if;
                    end if;              
                end if;
                             
            when CHECK_ACK =>           
                if (rising_edge(clk)) then
                    if (SDA = '0') then                      
                        -- ACK
                        -- next state                       
                        state <= next_state;
                    else                        
                        -- ADT7420s not responding
                        -- next state 
                        state <= NACK;
                    end if;                                                
                end if;
                                
            when SEND_REGISTER =>
                if (falling_edge(clk)) then
                    if (bit_cnt < 8) then
                        SDA <= frame_2(7 - bit_cnt);
                        bit_cnt <= bit_cnt + 1;
                       
                    else 
                        bit_cnt <= 0; 
                        -- next state
                        state <= CHECK_ACK;
                        next_state <= STOP_CONDITION;                                               
                    end if;
                end if;
                
            when STOP_CONDITION =>
                if (falling_edge(clk)) then                
                    -- SDA 0 -> 1, SCL = 1
                    SDA <= 'Z';
                    SCL <= '0';
                else
                    SCL <= 'Z';
                    -- next state
                    state <= START_CONDITION;
                    next_state <= READ_DATA; -- actually its next-next-next-next state
                end if;
                
                
            when READ_DATA =>
            
            when SEND_ACK =>
            
            when SEND_NACK =>
            
            when SEND_DATA_TO_MASTER =>
                
            when NACK => 
                bit_error <= '1';
                state <= RESET;
                
            when others =>
                state <= RESET; 
                          
        end case;
    end process p_I2C_module;
end Behavioral;
