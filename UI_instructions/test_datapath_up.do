vlib work2

vlog -timescale 1ns/1ns mux_ui.v

vsim datapath_up

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 10
force {enable} 0 0, 1 10


run 101000000 ns 
