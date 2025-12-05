--------------------------------------------------------------------------------
-- Testbench pour Télémètre Ultrason HC-SR04
-- Date : Décembre 2024
-- Description : Tests complets avec plage 2-400 cm
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_telemetre is
end tb_telemetre;

architecture Behavioral of tb_telemetre is
    
    component telemetre_us_HC_SR04 is
        Port (
            clk      : in  STD_LOGIC;
            rst_n    : in  STD_LOGIC;
            trig     : out STD_LOGIC;
            echo     : in  STD_LOGIC;
            dist_cm  : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    
    signal clk          : STD_LOGIC := '0';
    signal rst_n        : STD_LOGIC := '0';
    signal trig         : STD_LOGIC;
    signal echo         : STD_LOGIC := '0';
    signal dist_cm      : STD_LOGIC_VECTOR(9 downto 0);
    
    constant CLK_PERIOD : time := 20 ns;
    signal sim_ended    : boolean := false;
    signal test_id      : integer := 0;
    
    function calc_echo_duration(distance_cm : integer) return time is
        variable echo_time : time;
    begin
        echo_time := distance_cm * 2941 * CLK_PERIOD;
        return echo_time;
    end function;
    
begin
    
    UUT: telemetre_us_HC_SR04
        port map (
            clk => clk,
            rst_n => rst_n,
            trig => trig,
            echo => echo,
            dist_cm => dist_cm
        );
    
    clk_process: process
    begin
        while not sim_ended loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    stimulus: process
        variable measured : integer;
    begin
        
        report "========================================";
        report "  DEBUT DES TESTS DU TELEMETRE HC-SR04";
        report "========================================";
        
        test_id <= 0;
        rst_n <= '0';
        echo <= '0';
        wait for 500 ns;
        rst_n <= '1';
        report "Reset termine";
        wait for 1 us;
        
        -- TEST 1 : Distance minimale (2 cm)
        test_id <= 1;
        report "========================================";
        report "  TEST 1 : Distance de 2 cm (minimum)";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        wait for calc_echo_duration(2);
        echo <= '0';
        
        wait for 200 us;
        measured := to_integer(unsigned(dist_cm));
        report "  Distance mesuree : " & integer'image(measured) & " cm";
        
        if measured >= 1 and measured <= 3 then
            report "  TEST 1 REUSSI !" severity note;
        else
            report "  TEST 1 ECHEC" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- TEST 2 : Distance de 10 cm
        test_id <= 2;
        report "========================================";
        report "  TEST 2 : Distance de 10 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        wait for calc_echo_duration(10);
        echo <= '0';
        
        wait for 200 us;
        measured := to_integer(unsigned(dist_cm));
        report "  Distance mesuree : " & integer'image(measured) & " cm";
        
        if measured >= 9 and measured <= 11 then
            report "  TEST 2 REUSSI !" severity note;
        else
            report "  TEST 2 ECHEC" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- TEST 3 : Distance de 50 cm
        test_id <= 3;
        report "========================================";
        report "  TEST 3 : Distance de 50 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        wait for calc_echo_duration(50);
        echo <= '0';
        
        wait for 200 us;
        measured := to_integer(unsigned(dist_cm));
        report "  Distance mesuree : " & integer'image(measured) & " cm";
        
        if measured >= 48 and measured <= 52 then
            report "  TEST 3 REUSSI !" severity note;
        else
            report "  TEST 3 ECHEC" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- TEST 4 : Distance de 100 cm
        test_id <= 4;
        report "========================================";
        report "  TEST 4 : Distance de 100 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        wait for calc_echo_duration(100);
        echo <= '0';
        
        wait for 200 us;
        measured := to_integer(unsigned(dist_cm));
        report "  Distance mesuree : " & integer'image(measured) & " cm";
        
        if measured >= 98 and measured <= 102 then
            report "  TEST 4 REUSSI !" severity note;
        else
            report "  TEST 4 ECHEC" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- TEST 5 : Distance de 200 cm
        test_id <= 5;
        report "========================================";
        report "  TEST 5 : Distance de 200 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        wait for calc_echo_duration(200);
        echo <= '0';
        
        wait for 200 us;
        measured := to_integer(unsigned(dist_cm));
        report "  Distance mesuree : " & integer'image(measured) & " cm";
        
        if measured >= 195 and measured <= 205 then
            report "  TEST 5 REUSSI !" severity note;
        else
            report "  TEST 5 ECHEC" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- TEST 6 : Distance maximale (400 cm)
        test_id <= 6;
        report "========================================";
        report "  TEST 6 : Distance de 400 cm (maximum)";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        wait for calc_echo_duration(400);
        echo <= '0';
        
        wait for 200 us;
        measured := to_integer(unsigned(dist_cm));
        report "  Distance mesuree : " & integer'image(measured) & " cm";
        
        if measured >= 390 and measured <= 410 then
            report "  TEST 6 REUSSI !" severity note;
        else
            report "  TEST 6 ECHEC" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- TEST 7 : Pas d'obstacle (timeout)
        test_id <= 7;
        report "========================================";
        report "  TEST 7 : Pas d'obstacle (timeout)";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        
        wait for 5 ms;
        measured := to_integer(unsigned(dist_cm));
        report "  Distance apres timeout : " & integer'image(measured) & " cm";
        
        wait for 2 ms;
        
        report "";
        report "========================================";
        report "  FIN DES TESTS";
        report "========================================";
        
        sim_ended <= true;
        wait;
        
    end process;
    
    monitor: process(clk)
        variable last_dist : integer := -1;
        variable curr_dist : integer := 0;
    begin
        if rising_edge(clk) then
            curr_dist := to_integer(unsigned(dist_cm));
            if curr_dist /= last_dist and curr_dist /= 0 then
                report "*** CHANGEMENT : Distance = " & 
                       integer'image(curr_dist) & " cm" severity note;
                last_dist := curr_dist;
            end if;
        end if;
    end process;
    
end Behavioral;