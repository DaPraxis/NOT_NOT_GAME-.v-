vlib work

vlog -timescale 1ns/1ns judge.v

vsim judge

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {key_pressed} 0 0, 1 15, 0 20, 1 25, 0 27
force {prepare_judge} 0 0, 1 10
force {user_input} 0000000 0, 000000010 15, 0000000000101 25, 00000000 27
run 70 ns 
