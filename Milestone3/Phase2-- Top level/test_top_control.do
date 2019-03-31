vlib work

vlog -timescale 1ns/1ns test_top.v

vsim game_control

log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {user_input} 0 0, 010000 60, 000000 70
force {reset_n} 0 0, 1 10
force {clear_done} 0 0, 1 46, 0 48, 1 80, 0 82, 1 96, 0 100
force {time_counter_done} 0 0, 1 40, 0 42, 1 90, 0 92
force {start} 0 0, 1 12
run 100 ns 


