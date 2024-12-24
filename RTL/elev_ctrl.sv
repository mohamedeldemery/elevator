module elev_ctrl(
    input logic clock,
    input logic reset,
    input logic [9:0] buttons_inside,
    input logic [8:0] buttons_outside_up,
    input logic [9:1] buttons_outside_down,
    output logic up_signal,
    output logic down_signal,
    output logic open_door,  
    output logic [3:0] floor,  // Floors from 0->9 can be represented by only 4 bits  
    output logic [3:0] current_floor_debug 
);

parameter num_floors = 10;
logic [1:0] timer;
logic [25:0] clk_count;
bit clock_enable_1s;  // 1-second indicator
logic [3:0] current_floor;
logic [9:0] requests;
logic [3:0] next_target;
int i=0;
logic flag;

typedef enum logic [1:0] {
    IDLE,
    MOVING_UP,
    MOVING_DOWN,
    DOOR_OPEN
} elevator_state;

elevator_state current_state;
elevator_state next_state;

//assign moving_up = up_signal;
//assign moving_down = down_signal;

always_ff @(posedge clock or posedge reset) begin 
    if (reset) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        clk_count <= 0;
    end
    else if (clk_count < 5 && (current_state == MOVING_UP | current_state==MOVING_DOWN | current_state==DOOR_OPEN)) begin
        clk_count <= clk_count + 1;
    end
    else begin
        clk_count <= 0;
    end
end

always_ff @(posedge clock or posedge reset) begin
    if(reset)begin
        clock_enable_1s <= 0;
        timer<=0;
    end
    else if (clk_count == 5) begin
        clock_enable_1s <= 1;
        if (timer==1) begin
            timer<=0;
        end
        else begin
            timer<=timer+1;
        end
    end
    else begin
        clock_enable_1s<=0;
    end
end

// Handle floor requests and ignore out-of-range requests
always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        requests <= 0;
    end
    else if (current_state == DOOR_OPEN) begin
        requests [current_floor] <= 1'b0;
    end 
    else begin
        requests <= buttons_inside | buttons_outside_up | buttons_outside_down | requests;
    end
end

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        i<=0;
        next_target <= 0;
        flag <= 0;
    end
    else if ( requests != 0 && current_state == IDLE | current_state == MOVING_UP | current_state == MOVING_DOWN) begin
        if (flag == 0) begin
            if (requests[i]==1) begin
                next_target<=i;
            end
            else if (i > 9) begin
                flag <= 1;
            end
            else begin
                i <= i + 1;
            end
        end
        else if (flag == 1) begin
            if (requests[i] == 1) begin
                next_target <= i;
            end
            else if (i < 0) begin
                flag <= 0;
            end
            else begin
                i <= i - 1;
            end
        end
    end
end

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        current_floor <= 0;
    end
    else begin
        case (current_state)
            MOVING_UP: begin
                if (timer == 1 && clk_count == 5) begin
                    current_floor <= current_floor+1;
                end
            end
            MOVING_DOWN: begin
                if (timer == 1 && clk_count == 5) begin
                    current_floor<=current_floor-1;
                end
            end
        endcase
    end
end
// State machine controlling elevator operations
always_comb begin
    if (current_floor == 0 && buttons_outside_down[0]==1 | current_floor == 9 && buttons_outside_up[9]==1) begin
        $display("Checking error condition: floor=%0d, button_down[0]=%b", current_floor, buttons_outside_down[0]);
    end
    else begin
        case (current_state)
            IDLE:begin
                up_signal = 0;
                down_signal = 0;
                open_door = 0;
            end
            MOVING_UP:begin
                up_signal = 1;
                down_signal = 0;
                open_door = 0;
            end
            MOVING_DOWN:begin
                up_signal = 0;
                down_signal = 1;
                open_door = 0;
            end
            DOOR_OPEN:begin
                open_door = 1;
                up_signal = 0;
                down_signal = 0;
            end

        endcase
    end
end 
always_comb begin
    case (current_state)
            IDLE: begin
                    if (next_target > current_floor) begin
                        next_state = MOVING_UP;  
                    end else if (next_target < current_floor) begin
                        next_state = MOVING_DOWN;
                    end else begin
                        next_state <= IDLE;
                    end
                end

            MOVING_UP: begin
                    if (current_floor == next_target) begin
                        next_state = DOOR_OPEN;
                    end 
                    else begin
                        next_state = MOVING_UP;
                    end
           end
            MOVING_DOWN: begin
                    if (current_floor == next_target) begin
                        next_state = DOOR_OPEN;
                    end
                    else begin
                        next_state = MOVING_DOWN;
                    end
                end
    
            DOOR_OPEN: begin
                if (timer==1 && clk_count==5) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = DOOR_OPEN;
                end
            end
        endcase
    end
// Update floor output
assign floor = current_floor;
assign current_floor_debug = current_floor;

endmodule