vlib work3

vlog -timescale 1ns/1ns mux_ui.v

vsim ui_UP

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {reset_vga} 0 0, 1 10
force {enable_control} 0 0, 1 11, 0 30


run 55000000 ns 
