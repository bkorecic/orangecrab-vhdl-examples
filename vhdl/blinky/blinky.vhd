library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blinky is
    Port ( clk48      : in STD_LOGIC;
    	   usr_btn    : in STD_LOGIC;
           rgb_led0_r : out STD_LOGIC);
end blinky;

architecture Behavioral of blinky is
begin
    process(clk48)
    begin
        if rising_edge(clk48) then
            if usr_btn = '0' then
                rgb_led0_r <= '0';
            else
                rgb_led0_r <= '1';
            end if;
        end if;
    end process;
end Behavioral;
