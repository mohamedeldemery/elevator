module ssd(
    input logic [3:0] x,  
    output logic [6:0] y  
);

always_comb begin
    case (x)
                4'b0000: y = 7'b1000000; // 0
                4'b0001: y = 7'b1111001; // 1
                4'b0010: y = 7'b0100100; // 2
                4'b0011: y = 7'b0110000; // 3
                4'b0100: y = 7'b0011001; // 4
                4'b0101: y = 7'b0010010; // 5
                4'b0110: y = 7'b0000010; // 6
                4'b0111: y = 7'b1111000; // 7
                4'b1000: y = 7'b0000000; // 8
                4'b1001: y = 7'b0010000; // 9
                default: y = 7'b1111111; 
    endcase
end

endmodule
