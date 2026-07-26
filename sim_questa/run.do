#=========================================================
# UART Verification
# QuestaSim Run Script
# Code Coverage + Functional Coverage
#=========================================================

transcript on

#---------------------------------------------------------
# Create Library
#---------------------------------------------------------
if {[file exists work]} {
    vdel -all
}

vlib work
vmap work work

#---------------------------------------------------------
# Compile RTL
#---------------------------------------------------------
vlog -sv -cover bcest ../rtl/uart_baud_generator.v
vlog -sv -cover bcest ../rtl/uart_tx.v
vlog -sv -cover bcest ../rtl/uart_rx.v
vlog -sv -cover bcest ../rtl/uart_top.v

#---------------------------------------------------------
# Compile Testbench
#---------------------------------------------------------
vlog -sv -cover bcest +incdir+../tb ../tb/uart_if.sv
vlog -sv -cover bcest +incdir+../tb ../tb/uart_pkg.sv
vlog -sv -cover bcest +incdir+../tb ../tb/uart_tb_top.sv

#---------------------------------------------------------
# Start Simulation
#---------------------------------------------------------
vsim \
    -coverage \
    -voptargs=+acc \
    work.uart_tb_top

#---------------------------------------------------------
# Waveform
#---------------------------------------------------------
add wave -r *

#---------------------------------------------------------
# Run Simulation
#---------------------------------------------------------
run -all

#---------------------------------------------------------
# Save Coverage Database
#---------------------------------------------------------
coverage save uart.ucdb

#---------------------------------------------------------
# Coverage Report
#---------------------------------------------------------
coverage report \
    -html \
    -htmldir coverage_report \
    -details

coverage report \
    -output coverage.txt

#---------------------------------------------------------
# Open Coverage Viewer (Optional)
#---------------------------------------------------------
coverage open uart.ucdb

echo ""
echo "==========================================="
echo "Simulation Completed Successfully"
echo "Coverage Database : uart.ucdb"
echo "Coverage Report   : coverage_report/"
echo "Text Report       : coverage.txt"
echo "==========================================="

# Ask before exiting
quit