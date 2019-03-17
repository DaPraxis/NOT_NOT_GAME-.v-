vlib work

vlog -timescale 1ns/1ns control1.v

vsim random

log {/*}

add wave {/*}

force {clock} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 15
run 70 ns 
