module top_module #(parameter two_sec = 4, parameter num_floors = 10)
(
    input logic clock,
    input logic reset,
    input logic [9:0] buttons_inside,
    input logic [8:0] buttons_outside_up,
    input logic [9:1] buttons_outside_down,
    output logic up_signal,
    output logic down_signal,
    output logic open_door,  
    output logic [6:0] y;
);

elev_ctrl #(.two_sec(two_sec), .num_floors(num_floors)) elevator_controll(
    .clock(clock),
    .reset(reset),
    .buttons_inside(buttons_inside),
    .buttons_outside_down(buttons_outside_down),
    .buttons_outside_up(buttons_outside_up),
    .up_signal(up_signal),
    .down_signal(down_signal),
    .open_door(open_door),
    .floor(floor)
);
ssd seven-segment(
    .x(floor),
    .y(y);
);
    
endmodule