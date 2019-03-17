vlib work

vlog -timescale 1ns/1ns control1_only.v

vsim control1

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {rst_n} 0 0, 1 10
force {key_pressed} 0 0, 1 15, 0 20, 1 25, 0 27
force {answer} 0 0, 1 18, 0 25 
force {wait_counter} 1 0, 0 21, 1 22, 0 29, 1 31
run 70ns 
