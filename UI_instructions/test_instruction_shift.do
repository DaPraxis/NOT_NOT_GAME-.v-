vlib work

vlog -timescale 1ns/1ns mux_ui.v

vsim instruction_shift

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
# force {rst_n} 0 0, 1 10, 0 40, 1 50
force {change_instruction} 0 0, 1 15, 0 19, 1 55, 0 59, 1 70, 0 74, 1 79, 0 82, 1 83, 0 86

run 100 ns 
