vlib work2

vlog -timescale 1ns/1ns mux_ui.v

vsim test_rate_divider

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 10
force {enable} 1 


run 55000000 ns 
