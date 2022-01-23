library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity can_error_detector_tb is
end can_error_detector_tb;

architecture sim of can_error_detector_tb is

    constant clk_hz : integer := 50e6;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';

    signal rx_p, rx_n, erro_p, erro_n, enable_p, enable_n : std_logic;

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.can_error_detector(rtl)
    generic map(
        CLOCK_FREQ => clk_hz,
        BAUD_RATE  =>  1e6,
        N_BIT      =>  5
    );
    port map(
        clk  => clk,
        rst  => rst,
        rx_p => rx_p,
        rx_s => rx_n,
        erro_p => erro_p,
        erro_n => erro_n,
        enable_p => enable_p,
        enable_n => enable_n      
    );

    SEQUENCER_PROC : process
    begin

        rx_p <= '0';
        rx_n <= '0';

        wait for clk_period * 2;

        rst  <= '0';

        wait for clk_period * 10;

        rx_p <= '1';

        wait for clk_period * 600;

        rx_p <= '0';

        wait for clk_period * 600;

        rx_n <= '1';

        wait for clk_period * 600;

        rx_n <= '0';

        wait for clk_period * 600;

        rx_p <= '1';
        rx_n <= '1';
        
        wait for clk_period * 1000;

        rx_p <= '0';
        rx_n <= '0';
        
        wait for clk_period * 1000;

        assert enable_p = 1 and enable_n = 1
            report "Fail to detect"
            severity failure;

        finish;
    end process;

end architecture;