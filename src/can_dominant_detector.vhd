library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_dominant_detector is
    generic(
        CLOCK_FREQ : INTEGER;
        BAUD_RATE  : INTEGER;
        N_BIT      : INTEGER
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        rx  : in std_logic;
        enable : out std_logic
    );
end can_dominant_detector;

architecture rtl of can_dominant_detector is

    type state_type is (IDLE, CAN_BUS_WORKING, CAN_BUS_FAIL);
    signal state : state_type;

    constant limit   : integer := N_BIT * CLOCK_FREQ / BAUD_RATE;   
    signal   counter : integer := 0;

begin

   state_process: process(clk, rst)
   begin
       if rst = '1' then
           state <= IDLE;
       elsif rising_edge(clk) then
            CASE state IS
                WHEN IDLE=>
                    counter <= 0;
                    state <= CAN_BUS_WORKING;
                WHEN CAN_BUS_WORKING=>
                    if rx = '1' then
                        counter <= counter + 1;
                        if counter >= limit then
                            counter <= 0;
                            state <= CAN_BUS_FAIL;
                        end if;
                    else 
                        counter <= 0;
                    end if;
                WHEN CAN_BUS_FAIL=>
                    if rx = '0' then
                        counter <= counter + 1;
                        if counter >= limit then
                            counter <= 0;
                            state <= CAN_BUS_FAIL;
                        end if;
                    else 
                        counter <= 0;
                    end if;
            end case;       
       end if;
   end process state_process;

   enable_process: process (state)
   begin
      case state is
        when IDLE =>
            enable <= '1';
        when CAN_BUS_WORKING =>
            enable <= '1';
        when CAN_BUS_FAIL =>
            enable <= '0';
      end case;
   end process;


end architecture;