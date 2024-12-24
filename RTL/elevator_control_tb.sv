`timescale 1ns/1ns
module elevator_control_tb;

    // Testbench signals
    logic clock;
    logic reset;
    logic [9:0] buttons_inside;
    logic [8:0] buttons_outside_up;
    logic [9:1] buttons_outside_down;
    logic up_signal;
    logic down_signal;
    logic open_door;
    logic [3:0] floor;
    wire [3:0] current_floor_debug;

    // Instantiate the elevator controller
    elev_ctrl uut (
        .clock(clock),
        .reset(reset),
        .buttons_inside(buttons_inside),
        .buttons_outside_up(buttons_outside_up),
        .buttons_outside_down(buttons_outside_down),
        .up_signal(up_signal),
        .down_signal(down_signal),
        .open_door(open_door),
        .floor(floor),
        .current_floor_debug(current_floor_debug)
    );

    initial begin
    clock = 0;
    forever #10 clock = !clock; // 50MHz Clock
    end

    initial begin
        // Initialize signals
        clock = 0;
        reset = 1;
        buttons_inside = 10'b0000000000;
        buttons_outside_up = 9'b0;
        buttons_outside_down = 9'b0;

        #10
        reset = 0;
        buttons_inside = 10'b0000000000;
        #20
        buttons_outside_down[0]=1;;

        // Apply reset
         #10 
		 reset = 0;
         buttons_inside = 10'b0000010000; //test case 4: start from floor 4
         #20

         #20
         buttons_inside = 10'b0011000000; //request to floors 6 and 7
         #20
         buttons_inside = 10'b0000000000; // clears the buttons
         #20
         buttons_outside_down = 10'b0000001000; //request from floor 3 
         #20
         buttons_outside_down = 10'b0000000000; // clears the request

        //test case 7
         #10
         reset = 0;
         buttons_inside = 10'b0000100000;
         #20
         #20
         buttons_inside = 10'b0000000000; // clears the buttons
         #20
         buttons_outside_up = 10'b0000100000;
         #20
         buttons_outside_down = 10'b0000000000;

        //test case 8
        #10
        reset = 0;
        buttons_inside = 10'b0000000100;
        buttons_inside = 10'b0000010000;
        #20
        buttons_inside = 10'b0000000000;
         #20
         buttons_outside_up = 9'b000001000;
         #20 
         buttons_outside_up = 9'b000000000;

        //test case 9
        #10
        reset = 0;
        buttons_inside = 10'b0100100000;
        #20
        buttons_inside = 10'b0000000000;
        #20
        buttons_outside_up = 9'b000001000;
        #20
        buttons_outside_up = 9'b000000000;
        #20
        buttons_outside_down = 9'b000100000;
        #20
        buttons_outside_down = 9'b000000000;
        
         #20
         buttons_outside_up[10] = 1 ;
        #(10*5*100);
        // Apply reset
   

        
        // Set multiple requests at the same time for floors 3, 5, 6 and 7
	      buttons_inside = 10'b0011101000; //3,5,6,7
         // Clear requests after setting them
          #20 
          buttons_inside = 10'b0000000000;
          #(10 * 5 * 100);
         
          buttons_inside = 10'b1100010110; //1,2,4,8,9
          #20 buttons_inside = 10'b0000000000;


        // // Wait to observe the elevator handling all the requests
        // //#500;

        // // Finish simulation
        
         #(10 * 5 * 900) $finish;
    end

    // Monitor signals to observe elevator responses
    initial begin
        $monitor("Time=%0t | Floor=%0d | Up=%b | Down=%b | Door Open=%b | Timer=%0d | Clk_count=%0d | requests=%b | flag=%b",
                 $time, floor, up_signal, down_signal, open_door, uut.timer, uut.clk_count, uut.requests, uut.flag);
    end

endmodule



