----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.04.2025 09:36:06
-- Design Name: 
-- Module Name: seg_drive - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seg_drive is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           inp : in INTEGER;
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           dp : out STD_LOGIC);
end seg_drive;

architecture Behavioral of seg_drive is
    signal state : integer range 0 to 6  := 0;

    signal num : integer;
begin
    process(clk)
        variable val : integer range 0 to 9 := 0; 
        variable temp : integer;
        begin
            if (rising_edge(clk)) then
                if (rst = '1') then
                    seg <= "1111111";
                    dp  <= '1';
                    an <= "00000000";
                else
                    case state is
                        when 0 =>
                            an <= "10111111";
                            dp <= '1';
                            temp := inp;
                            if temp < 0 then
                                seg <= "1111110";
                                temp := -temp;
                            end if;
                            num <= temp; 
                            state <= 1;
                        when 1 =>
                            an <= "11111110";
                            dp <= '1';
                            state <= 2;
                        when 2 =>
                            an <= "11111101";
                            dp <= '1';
                            state <= 3;
                        when 3 =>
                            an <= "11111011";
                            dp <= '1';
                            state <= 4;
                        when 4 =>
                            an <= "11110111";
                            dp <= '1';
                            state <= 5;
                        when 5 =>
                            an <= "11101111";
                            dp <= '0';
                            state <= 6;
                        when 6 =>
                            an <= "11011111";
                            dp <= '1';
                            state <= 0;
                    end case;
                    if state /=0 then
                        val := (num mod (10**state))/(10**(state-1));
                        num <= num-val*(10**(state-1));
                        case val is
                              when 0 =>
                                seg <= "0000001";
                              when 1 =>
                                seg <= "1001111";                    
                              when 2 =>
                                seg <= "0010010";
                              when 3 =>
                                seg <= "0000110";
                              when 4 =>
                                seg <= "1001100";
                              when 5 =>
                                seg <= "0100100";
                              when 6 =>
                                seg <= "0100000";
                              when 7 =>
                                seg <= "0001111";
                              when 8 =>
                                seg <= "0000000";
                              when 9 =>
                                seg <= "0000100";
                        end case;
                    end if;
                end if;
            end if;
        end process;
end Behavioral;
