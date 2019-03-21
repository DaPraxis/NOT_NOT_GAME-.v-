vlib work

vlog -timescale 1ns/1ns mux_ui.v

vsim mux_ui

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {clear_instruction} 0 0, 1 40, 0 80
force {reset_n} 0 0, 1 10, 0 40, 1 50
force {change_instruction} 0 0, 1 13, 0 16, 1 53, 0 56
run 100 ns 
