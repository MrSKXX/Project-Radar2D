--------------------------------------------------------------------------------
-- Télémètre Ultrason HC-SR04
-- Auteur : Votre Nom
-- Date : Décembre 2024
-- Description : Mesure de distance avec capteur ultrason HC-SR04
--               Utilise une méthode de comptage hiérarchique pour le calcul
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity telemetre_us_HC_SR04 is
    Port (
        clk      : in  STD_LOGIC;                      -- Horloge 50 MHz
        rst_n    : in  STD_LOGIC;                      -- Reset actif bas
        trig     : out STD_LOGIC;                      -- Signal trigger vers HC-SR04
        echo     : in  STD_LOGIC;                      -- Signal echo depuis HC-SR04
        dist_cm  : out STD_LOGIC_VECTOR(9 downto 0)   -- Distance en centimètres
    );
end telemetre_us_HC_SR04;

architecture Behavioral of telemetre_us_HC_SR04 is
    
    -- Constantes de timing
    constant CLK_FREQ           : integer := 50_000_000;   -- 50 MHz
    constant TRIG_DURATION      : integer := 500;          -- 10 µs pour trigger
    constant MEASUREMENT_GAP    : integer := 3_000_000;    -- 60 ms entre mesures
    constant SUB_COUNT_MAX      : integer := 200;          -- Compteur de base
    
    -- Signaux de contrôle du trigger
    signal trig_count           : integer range 0 to TRIG_DURATION := 0;
    signal gap_count            : integer range 0 to MEASUREMENT_GAP := 0;
    signal trig_active          : std_logic := '0';
    
    -- Signaux de mesure de l'écho
    signal echo_measuring       : std_logic := '0';
    signal sub_counter          : integer range 0 to SUB_COUNT_MAX := 0;
    signal main_counter         : integer range 0 to 1023 := 0;
    
    -- Signal de résultat
    signal distance_result      : integer range 0 to 1023 := 0;
    
begin
    
    -- ========================================================================
    -- Processus principal de gestion du télémètre
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            -- Initialisation de tous les signaux
            trig_active <= '0';
            trig_count <= 0;
            gap_count <= 0;
            echo_measuring <= '0';
            sub_counter <= 0;
            main_counter <= 0;
            distance_result <= 0;
            
        elsif rising_edge(clk) then
            
            -- ================================================================
            -- Partie 1 : Génération du signal TRIGGER
            -- ================================================================
            
            -- Gestion de l'espacement entre deux mesures
            if gap_count < MEASUREMENT_GAP then
                gap_count <= gap_count + 1;
                trig_active <= '0';
            else
                -- Moment de générer une nouvelle impulsion trigger
                if trig_count < TRIG_DURATION then
                    trig_count <= trig_count + 1;
                    trig_active <= '1';
                else
                    trig_active <= '0';
                    -- Réinitialisation pour le prochain cycle
                    if trig_count = TRIG_DURATION then
                        gap_count <= 0;
                        trig_count <= 0;
                    end if;
                end if;
            end if;
            
            -- ================================================================
            -- Partie 2 : Mesure de la durée de l'ECHO
            -- ================================================================
            
            if echo = '1' then
                -- Début ou continuation de la mesure
                echo_measuring <= '1';
                
                -- Comptage hiérarchique : compteur principal + sous-compteur
                if sub_counter < SUB_COUNT_MAX then
                    sub_counter <= sub_counter + 1;
                else
                    -- Débordement du sous-compteur
                    sub_counter <= 0;
                    
                    -- Incrémenter le compteur principal
                    if main_counter < 1023 then
                        main_counter <= main_counter + 1;
                    end if;
                end if;
                
            elsif echo = '0' and echo_measuring = '1' then
                -- Fin de la mesure de l'écho
                echo_measuring <= '0';
                
                -- ============================================================
                -- Calcul de la distance
                -- ============================================================
                -- Formule : distance (cm) = main_counter / facteur_calibration
                -- Facteur de calibration déterminé empiriquement : 15
                -- Cette valeur correspond à la vitesse du son et à notre 
                -- méthode de comptage (blocs de 200 cycles)
                
                if main_counter < 15 then
                    -- Distance trop courte (< 1 cm)
                    distance_result <= 0;
                elsif main_counter >= 600 then
                    -- Distance hors plage (> 400 cm)
                    distance_result <= 1023;  -- Valeur d'erreur
                else
                    -- Calcul normal
                    distance_result <= main_counter / 15;
                end if;
                
                -- Réinitialisation des compteurs pour la prochaine mesure
                sub_counter <= 0;
                main_counter <= 0;
            end if;
            
        end if;
    end process;
    
    -- ========================================================================
    -- Assignation des sorties
    -- ========================================================================
    trig <= trig_active;
    dist_cm <= std_logic_vector(to_unsigned(distance_result, 10));
    
end Behavioral;