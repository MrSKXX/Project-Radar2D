quit -sim
vdel -all -lib work

vlib work
vmap work work

echo ""
echo "=========================================="
echo "  COMPILATION DES FICHIERS VHDL"
echo "=========================================="
echo ""

vcom -93 -work work telemetre_us_HC_SR04.vhd
vcom -93 -work work tb_telemetre.vhd

echo ""
echo "=========================================="
echo "  LANCEMENT DE LA SIMULATION"
echo "=========================================="
echo ""

vsim -t 1ns -voptargs=+acc work.tb_telemetre

# ==============================================================================
# CONFIGURATION DES SIGNAUX À AFFICHER
# ==============================================================================

add wave -noupdate -divider -height 35 "CONTROLE"
add wave -noupdate -format Logic -height 20 -label "clk" -color Yellow /tb_telemetre/clk
add wave -noupdate -format Logic -height 20 -label "rst_n" -color Cyan /tb_telemetre/rst_n
add wave -noupdate -format Literal -height 20 -label "test_id" -radix unsigned /tb_telemetre/test_id

add wave -noupdate -divider -height 35 "INTERFACE HC-SR04"
add wave -noupdate -format Logic -height 25 -label "trig" -color Orange /tb_telemetre/trig
add wave -noupdate -format Logic -height 25 -label "echo" -color Magenta /tb_telemetre/echo

add wave -noupdate -divider -height 35 "RESULTAT"
add wave -noupdate -format Literal -height 30 -label "dist_cm" -radix unsigned -color Green /tb_telemetre/dist_cm

add wave -noupdate -divider -height 35 "INTERNES - TRIGGER"
add wave -noupdate -format Literal -height 20 -label "trig_count" -radix unsigned /tb_telemetre/UUT/trig_count
add wave -noupdate -format Literal -height 20 -label "gap_count" -radix unsigned /tb_telemetre/UUT/gap_count
add wave -noupdate -format Logic -height 20 -label "trig_active" /tb_telemetre/UUT/trig_active

add wave -noupdate -divider -height 35 "INTERNES - MESURE ECHO"
add wave -noupdate -format Logic -height 20 -label "echo_measuring" -color Cyan /tb_telemetre/UUT/echo_measuring
add wave -noupdate -format Literal -height 25 -label "echo_counter" -radix unsigned -color Yellow /tb_telemetre/UUT/echo_counter
add wave -noupdate -format Literal -height 25 -label "distance_result" -radix unsigned -color Green /tb_telemetre/UUT/distance_result

# ==============================================================================
# CONFIGURATION DE L'AFFICHAGE
# ==============================================================================

configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 100
configure wave -timeline 1
configure wave -timelineunits ns

# ==============================================================================
# EXECUTION DE LA SIMULATION
# ==============================================================================

echo ""
echo "=========================================="
echo "  EXECUTION: 100 ms de simulation"
echo "=========================================="
echo ""

run 100ms

wave zoom full

echo ""
echo "=========================================="
echo "  SIMULATION TERMINEE"
echo "=========================================="
echo ""
echo "Commandes utiles pour le zoom:"
echo ""
echo "  Test 1 (2 cm)   : wave zoom range 60ms 62ms"
echo "  Test 2 (10 cm)  : wave zoom range 62ms 64ms"
echo "  Test 3 (50 cm)  : wave zoom range 64ms 66ms"
echo "  Test 4 (100 cm) : wave zoom range 66ms 68ms"
echo "  Test 5 (200 cm) : wave zoom range 68ms 70ms"
echo "  Test 6 (400 cm) : wave zoom range 70ms 72ms"
echo "  Test 7 (timeout): wave zoom range 72ms 80ms"
echo ""
echo "  Vue generale    : wave zoom full"
echo "  Reset           : wave zoom range 0ms 2ms"
echo ""