--------------------------------------------------------------------------------
-- Télémètre Ultrason HC-SR04
-- Date : Décembre 2024
-- Description : Mesure de distance avec capteur ultrason HC-SR04
--               Plage de mesure : 2 cm à 400 cm
--               Résolution : 0.3 cm
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity telemetre_us_HC_SR04 is
    Port (
        clk      : in  STD_LOGIC;
        rst_n    : in  STD_LOGIC;
        trig     : out STD_LOGIC;
        echo     : in  STD_LOGIC;
        dist_cm  : out STD_LOGIC_VECTOR(9 downto 0)
    );
end telemetre_us_HC_SR04;

architecture Behavioral of telemetre_us_HC_SR04 is
    
    -- Constantes de timing
    constant CLK_FREQ           : integer := 50_000_000;
    constant TRIG_DURATION      : integer := 500;
    constant MEASUREMENT_GAP    : integer := 3_000_000;
    
    -- Signaux de contrôle du trigger
    signal trig_count           : integer range 0 to TRIG_DURATION := 0;
    signal gap_count            : integer range 0 to MEASUREMENT_GAP := 0;
    signal trig_active          : std_logic := '0';
    
    -- Signaux de mesure de l'écho
    signal echo_measuring       : std_logic := '0';
    signal echo_counter         : integer range 0 to 120000 := 0;
    
    -- Signal de résultat
    signal distance_result      : integer range 0 to 1023 := 0;
    
begin
    
    process(clk, rst_n)
        variable temp_distance : integer range 0 to 2000 := 0;
    begin
        if rst_n = '0' then
            trig_active <= '0';
            trig_count <= 0;
            gap_count <= 0;
            echo_measuring <= '0';
            echo_counter <= 0;
            distance_result <= 0;
            
        elsif rising_edge(clk) then
            
            -- Génération du signal TRIGGER
            if gap_count < MEASUREMENT_GAP then
                gap_count <= gap_count + 1;
                trig_active <= '0';
            else
                if trig_count < TRIG_DURATION then
                    trig_count <= trig_count + 1;
                    trig_active <= '1';
                else
                    trig_active <= '0';
                    if trig_count = TRIG_DURATION then
                        gap_count <= 0;
                        trig_count <= 0;
                    end if;
                end if;
            end if;
            
            -- Mesure de la durée de l'ECHO
            if echo = '1' then
                echo_measuring <= '1';
                
                if echo_counter < 120000 then
                    echo_counter <= echo_counter + 1;
                end if;
                
            elsif echo = '0' and echo_measuring = '1' then
                echo_measuring <= '0';
                
                -- Calcul de la distance
                -- Formule : distance (cm) = temps_echo (cycles) / 2941
                -- 2941 cycles = 58.82 µs = temps pour 1 cm aller-retour
                
                temp_distance := echo_counter / 2941;
                
                if temp_distance < 2 then
                    distance_result <= 0;
                elsif temp_distance > 400 then
                    distance_result <= 1023;
                else
                    distance_result <= temp_distance;
                end if;
                
                echo_counter <= 0;
            end if;
            
        end if;
    end process;
    
    trig <= trig_active;
    dist_cm <= std_logic_vector(to_unsigned(distance_result, 10));
    
end Behavioral;