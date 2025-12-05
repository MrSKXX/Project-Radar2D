--------------------------------------------------------------------------------
-- Testbench pour Télémètre Ultrason HC-SR04
-- Date : Décembre 2024
-- Description : Banc de test complet avec plusieurs scénarios de mesure
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_telemetre is
end tb_telemetre;

architecture Behavioral of tb_telemetre is
    
    -- Déclaration du composant à tester
    component telemetre_us_HC_SR04 is--------------------------------------------------------------------------------
-- Testbench pour Télémètre Ultrason HC-SR04
-- Date : Décembre 2024
-- Description : Banc de test complet avec plusieurs scénarios de mesure
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_telemetre is
end tb_telemetre;

architecture Behavioral of tb_telemetre is
    
    -- Déclaration du composant à tester
    component telemetre_us_HC_SR04 is
        Port (
            clk      : in  STD_LOGIC;
            rst_n    : in  STD_LOGIC;
            trig     : out STD_LOGIC;
            echo     : in  STD_LOGIC;
            dist_cm  : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    
    -- Signaux de test
    signal clk          : STD_LOGIC := '0';
    signal rst_n        : STD_LOGIC := '0';
    signal trig         : STD_LOGIC;
    signal echo         : STD_LOGIC := '0';
    signal dist_cm      : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Constantes de simulation
    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz
    signal sim_ended    : boolean := false;
    
    -- Signal pour suivre les tests
    signal test_id      : integer := 0;
    
    -- Fonction pour calculer la durée d'écho pour une distance donnée
    function calc_echo_duration(distance_cm : integer) return time is
        variable echo_time : time;
    begin
        -- Formule : temps (µs) = distance (cm) / 0.034
        -- Pour notre comptage : durée = distance_cm * 15 * 200 cycles
        echo_time := distance_cm * 15 * 200 * CLK_PERIOD;
        return echo_time;
    end function;
    
begin
    
    -- ========================================================================
    -- Instanciation du module sous test (UUT)
    -- ========================================================================
    UUT: telemetre_us_HC_SR04
        port map (
            clk => clk,
            rst_n => rst_n,
            trig => trig,
            echo => echo,
            dist_cm => dist_cm
        );
    
    -- ========================================================================
    -- Génération de l'horloge
    -- ========================================================================
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
    
    -- ========================================================================
    -- Processus de stimulation (tests)
    -- ========================================================================
    stimulus: process
    begin
        
        report "========================================";
        report "  DEBUT DES TESTS DU TELEMETRE HC-SR04";
        report "========================================";
        report "";
        
        -- ====================================================================
        -- Phase d'initialisation
        -- ====================================================================
        test_id <= 0;
        rst_n <= '0';
        echo <= '0';
        wait for 500 ns;
        rst_n <= '1';
        report "Phase 0 : Reset termine" severity note;
        wait for 1 us;
        
        -- ====================================================================
        -- TEST 1 : Distance de 10 cm
        -- ====================================================================
        test_id <= 1;
        report "========================================";
        report "  TEST 1 : Distance de 10 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        report "  [TEST 1] Trigger detecte a " & time'image(now);
        
        wait until falling_edge(trig);
        report "  [TEST 1] Fin du trigger a " & time'image(now);
        
        -- Délai réaliste du capteur
        wait for 150 us;
        
        -- Génération de l'écho pour 10 cm
        echo <= '1';
        report "  [TEST 1] Echo active a " & time'image(now);
        wait for calc_echo_duration(10);
        echo <= '0';
        report "  [TEST 1] Echo desactive a " & time'image(now);
        
        -- Attendre le calcul
        wait for 200 us;
        report "  [TEST 1] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        -- Vérification
        if to_integer(unsigned(dist_cm)) >= 9 and to_integer(unsigned(dist_cm)) <= 11 then
            report "  [TEST 1] REUSSI !" severity note;
        else
            report "  [TEST 1] ECHEC - Distance attendue: 10 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 2 : Distance de 25 cm
        -- ====================================================================
        test_id <= 2;
        report "========================================";
        report "  TEST 2 : Distance de 25 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        report "  [TEST 2] Trigger detecte";
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        report "  [TEST 2] Echo active";
        wait for calc_echo_duration(25);
        echo <= '0';
        report "  [TEST 2] Echo desactive";
        
        wait for 200 us;
        report "  [TEST 2] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 23 and to_integer(unsigned(dist_cm)) <= 27 then
            report "  [TEST 2] REUSSI !" severity note;
        else
            report "  [TEST 2] ECHEC - Distance attendue: 25 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 3 : Distance de 50 cm
        -- ====================================================================
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
        report "  [TEST 3] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 48 and to_integer(unsigned(dist_cm)) <= 52 then
            report "  [TEST 3] REUSSI !" severity note;
        else
            report "  [TEST 3] ECHEC - Distance attendue: 50 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 4 : Distance de 100 cm
        -- ====================================================================
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
        report "  [TEST 4] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 98 and to_integer(unsigned(dist_cm)) <= 102 then
            report "  [TEST 4] REUSSI !" severity note;
        else
            report "  [TEST 4] ECHEC - Distance attendue: 100 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 5 : Distance de 200 cm
        -- ====================================================================
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
        report "  [TEST 5] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 195 and to_integer(unsigned(dist_cm)) <= 205 then
            report "  [TEST 5] REUSSI !" severity note;
        else
            report "  [TEST 5] ECHEC - Distance attendue: 200 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 6 : Pas d'obstacle (timeout)
        -- ====================================================================
        test_id <= 6;
        report "========================================";
        report "  TEST 6 : Pas d'obstacle (timeout)";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        -- Pas d'écho généré
        
        wait for 5 ms;
        report "  [TEST 6] Distance apres timeout : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        -- ====================================================================
        -- Fin des tests
        -- ====================================================================
        wait for 2 ms;
        
        report "";
        report "========================================";
        report "  FIN DES TESTS";
        report "========================================";
        report "";
        report "Tous les tests sont termines.";
        report "Verifiez les resultats ci-dessus.";
        
        sim_ended <= true;
        wait;
        
    end process;
    
    -- ========================================================================
    -- Moniteur de changement de distance
    -- ========================================================================
    monitor: process(clk)
        variable last_dist : integer := -1;
        variable curr_dist : integer := 0;
    begin
        if rising_edge(clk) then
            curr_dist := to_integer(unsigned(dist_cm));
            if curr_dist /= last_dist and curr_dist /= 0 then
                report "*** CHANGEMENT : Distance = " & 
                       integer'image(curr_dist) & " cm a " & 
                       time'image(now) severity note;
                last_dist := curr_dist;
            end if;
        end if;
    end process;
    
end Behavioral;
        Port (
            clk      : in  STD_LOGIC;
            rst_n    : in  STD_LOGIC;
            trig     : out STD_LOGIC;
            echo     : in  STD_LOGIC;
            dist_cm  : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    
    -- Signaux de test
    signal clk          : STD_LOGIC := '0';
    signal rst_n        : STD_LOGIC := '0';
    signal trig         : STD_LOGIC;
    signal echo         : STD_LOGIC := '0';
    signal dist_cm      : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Constantes de simulation
    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz
    signal sim_ended    : boolean := false;
    
    -- Signal pour suivre les tests
    signal test_id      : integer := 0;
    
    -- Fonction pour calculer la durée d'écho pour une distance donnée
    function calc_echo_duration(distance_cm : integer) return time is
        variable echo_time : time;
    begin
        -- Formule : temps (µs) = distance (cm) / 0.034
        -- Pour notre comptage : durée = distance_cm * 15 * 200 cycles
        echo_time := distance_cm * 15 * 200 * CLK_PERIOD;
        return echo_time;
    end function;
    
begin
    
    -- ========================================================================
    -- Instanciation du module sous test (UUT)
    -- ========================================================================
    UUT: telemetre_us_HC_SR04
        port map (
            clk => clk,
            rst_n => rst_n,
            trig => trig,
            echo => echo,
            dist_cm => dist_cm
        );
    
    -- ========================================================================
    -- Génération de l'horloge
    -- ========================================================================
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
    
    -- ========================================================================
    -- Processus de stimulation (tests)
    -- ========================================================================
    stimulus: process
    begin
        
        report "========================================";
        report "  DEBUT DES TESTS DU TELEMETRE HC-SR04";
        report "========================================";
        report "";
        
        -- ====================================================================
        -- Phase d'initialisation
        -- ====================================================================
        test_id <= 0;
        rst_n <= '0';
        echo <= '0';
        wait for 500 ns;
        rst_n <= '1';
        report "Phase 0 : Reset termine" severity note;
        wait for 1 us;
        
        -- ====================================================================
        -- TEST 1 : Distance de 10 cm
        -- ====================================================================
        test_id <= 1;
        report "========================================";
        report "  TEST 1 : Distance de 10 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        report "  [TEST 1] Trigger detecte a " & time'image(now);
        
        wait until falling_edge(trig);
        report "  [TEST 1] Fin du trigger a " & time'image(now);
        
        -- Délai réaliste du capteur
        wait for 150 us;
        
        -- Génération de l'écho pour 10 cm
        echo <= '1';
        report "  [TEST 1] Echo active a " & time'image(now);
        wait for calc_echo_duration(10);
        echo <= '0';
        report "  [TEST 1] Echo desactive a " & time'image(now);
        
        -- Attendre le calcul
        wait for 200 us;
        report "  [TEST 1] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        -- Vérification
        if to_integer(unsigned(dist_cm)) >= 9 and to_integer(unsigned(dist_cm)) <= 11 then
            report "  [TEST 1] REUSSI !" severity note;
        else
            report "  [TEST 1] ECHEC - Distance attendue: 10 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 2 : Distance de 25 cm
        -- ====================================================================
        test_id <= 2;
        report "========================================";
        report "  TEST 2 : Distance de 25 cm";
        report "========================================";
        
        wait until rising_edge(trig);
        report "  [TEST 2] Trigger detecte";
        wait until falling_edge(trig);
        wait for 150 us;
        
        echo <= '1';
        report "  [TEST 2] Echo active";
        wait for calc_echo_duration(25);
        echo <= '0';
        report "  [TEST 2] Echo desactive";
        
        wait for 200 us;
        report "  [TEST 2] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 23 and to_integer(unsigned(dist_cm)) <= 27 then
            report "  [TEST 2] REUSSI !" severity note;
        else
            report "  [TEST 2] ECHEC - Distance attendue: 25 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 3 : Distance de 50 cm
        -- ====================================================================
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
        report "  [TEST 3] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 48 and to_integer(unsigned(dist_cm)) <= 52 then
            report "  [TEST 3] REUSSI !" severity note;
        else
            report "  [TEST 3] ECHEC - Distance attendue: 50 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 4 : Distance de 100 cm
        -- ====================================================================
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
        report "  [TEST 4] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 98 and to_integer(unsigned(dist_cm)) <= 102 then
            report "  [TEST 4] REUSSI !" severity note;
        else
            report "  [TEST 4] ECHEC - Distance attendue: 100 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 5 : Distance de 200 cm
        -- ====================================================================
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
        report "  [TEST 5] Distance mesuree : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        if to_integer(unsigned(dist_cm)) >= 195 and to_integer(unsigned(dist_cm)) <= 205 then
            report "  [TEST 5] REUSSI !" severity note;
        else
            report "  [TEST 5] ECHEC - Distance attendue: 200 cm" severity warning;
        end if;
        
        wait for 2 ms;
        
        -- ====================================================================
        -- TEST 6 : Pas d'obstacle (timeout)
        -- ====================================================================
        test_id <= 6;
        report "========================================";
        report "  TEST 6 : Pas d'obstacle (timeout)";
        report "========================================";
        
        wait until rising_edge(trig);
        wait until falling_edge(trig);
        -- Pas d'écho généré
        
        wait for 5 ms;
        report "  [TEST 6] Distance apres timeout : " & 
               integer'image(to_integer(unsigned(dist_cm))) & " cm";
        
        -- ====================================================================
        -- Fin des tests
        -- ====================================================================
        wait for 2 ms;
        
        report "";
        report "========================================";
        report "  FIN DES TESTS";
        report "========================================";
        report "";
        report "Tous les tests sont termines.";
        report "Verifiez les resultats ci-dessus.";
        
        sim_ended <= true;
        wait;
        
    end process;
    
    -- ========================================================================
    -- Moniteur de changement de distance
    -- ========================================================================
    monitor: process(clk)
        variable last_dist : integer := -1;
        variable curr_dist : integer := 0;
    begin
        if rising_edge(clk) then
            curr_dist := to_integer(unsigned(dist_cm));
            if curr_dist /= last_dist and curr_dist /= 0 then
                report "*** CHANGEMENT : Distance = " & 
                       integer'image(curr_dist) & " cm a " & 
                       time'image(now) severity note;
                last_dist := curr_dist;
            end if;
        end if;
    end process;
    
end Behavioral;