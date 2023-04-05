module project(clk, A, B, opcode, C, car, sign, zero);
input clk;
input [3:0] A;
input [3:0] B;
input [2:0] opcode;
output reg [3:0] C;
reg [2:0] state = 0;
output reg car = 0, sign, zero;

always @(posedge clk) begin
    case (state)
        0: begin // Idle state
               C <= C; // Output C retains the result of last operation performed
               if (opcode == 3'b011) begin
                   state <= 1; // Move to next state for NAND operation
                   C[0] <= ~(A[0] & B[0]); // Perform NAND operation on LSBs and update C
               end
               else begin
                   state <= 0; // Stay in idle state
               end
           end
        1: begin // State 1
               C[1] <= ~(A[1] & B[1]); // Perform NAND operation on next bit and update C
               if (opcode != 3'b011) begin
                   state <= 0; // Return to idle state if opcode is not 010 NAND
               end
               else if (state == 1 && opcode == 3'b011 && A == 4'b0000 && B == 4'b0000) begin
                   state <= 0; // Return to idle state if A and B are both 0000
               end
               else begin
                   state <= 2; // Move to next state
               end
           end
        2: begin // State 2
               C[2] <= ~(A[2] & B[2]); // Perform NAND operation on next bit and update C
               if (opcode != 3'b011) begin
                   state <= 0; // Return to idle state if opcode is not 010 NAND
               end
               else if (state == 2 && opcode == 3'b011 && A == 4'b0000 && B == 4'b0000) begin
                   state <= 0; // Return to idle state if A and B are both 0000
               end
               else begin
                   state <= 3; // Move to next state
               end
           end
        3: begin // State 3
               C[3] <= ~(A[3] & B[3]); // Perform NAND operation on MSBs and update C
               sign <= C[3];
			   zero <= (C == 4'b0000);
               if (opcode != 3'b011) begin
                   state <= 0; // Return to idle state if opcode is not 010 NAND
               end
               else begin
                   state <= 0; // Return to idle state after operation is complete
               end
           end
        default: begin
                     state <= 0; // Return to idle state if undefined state is reached
                 end
    endcase
  
end

endmodule
