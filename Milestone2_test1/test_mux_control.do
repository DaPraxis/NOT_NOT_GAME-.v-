vlib work

vlog -timescale 1ns/1ns mux_ui_v3.v

vsim mux_control

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 10
force {enable} 0 0, 1 5, 0 30
force {instruction} 000
force {clear} 0 0, 1 60, 0 67
force {done} 0 0, 1 50, 0 53


run 100 ns 

