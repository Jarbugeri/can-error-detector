library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_error_detector is
    generic(
        CLOCK_FREQ : INTEGER;
        BAUD_RATE  : INTEGER;
        N_BIT      : INTEGER
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        rx_p: in std_logic;
        rx_s: in std_logic;
        erro_p: out std_logic;
        erro_n: out std_logic;
        enable_p: out std_logic;
        enable_n: out std_logic        
    );
end can_error_detector;

architecture rtl of can_error_detector is

    component can_dominant_detector is
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
    end component can_dominant_detector;

    signal enable_p_temp, enable_n_temp : std_logic;
begin

    can_p : can_dominant_detector 
    generic map(
                CLOCK_FREQ => CLOCK_FREQ,
                BAUD_RATE  => BAUD_RATE,
                N_BIT      => N_BIT)
    port map(
        clk => clk,
        rst => rst,
        rx  => rx_p,
        enable => enable_p_temp
    );

    can_s : can_dominant_detector 
    generic map(
                CLOCK_FREQ => CLOCK_FREQ,
                BAUD_RATE  => BAUD_RATE,
                N_BIT      => N_BIT)
    port map(
        clk => clk,
        rst => rst,
        rx  => rx_s,
        enable => enable_n_temp
    );

    erro_p <= not enable_p_temp;
    erro_n <= not enable_n_temp;
    enable_p <= enable_p_temp;
    enable_n <= enable_n_temp;       

end architecture;