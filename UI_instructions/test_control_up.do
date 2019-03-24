vlib work2

vlog -timescale 1ns/1ns mux_ui.v

vsim control_up

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 10
force {enable_unit} 0 0, 1 10, 0 30


run 55000000 ns 
