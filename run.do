vlib work

vlog -sv elev_ctrl.sv
vlog -sv elevator_control_tb.sv

vsim -voptargs=+acc work.elevator_control_tb
do wave.do
run -all