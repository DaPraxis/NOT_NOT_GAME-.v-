vlib work2

vlog -timescale 1ns/1ns mux_ui.v

vsim instruction_shift_control

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
# force {rst_n} 0 0, 1 10, 0 40, 1 50
force {enable} 0 0, 1 10, 0 30


run 100 ns 
