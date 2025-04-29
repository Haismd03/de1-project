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
    Port ( address : in STD_LOGIC_VECTOR (7 downto 0);
           data : in STD_LOGIC_VECTOR (7 downto 0);
           SDA : out STD_LOGIC_VECTOR (7 downto 0);
           SCL : out STD_LOGIC;
           response : out STD_LOGIC_VECTOR (7 downto 0));
end I2C_module;

architecture Behavioral of I2C_module is

begin


end Behavioral;
