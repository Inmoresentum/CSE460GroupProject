module project(input clk, input [3:0] A, input [3:0] B,
 input [2:0] opcode, output reg [3:0] C,
  output reg carr, output reg sign, output reg zero);
// Will be using state to indicate state of the machine.
reg [1:0] state = 0;
// Negative numbers will be represented in 2s complement.
reg signed [3:0] sub_result;
reg signed [3:0] sub_a;
reg signed [3:0] sub_b;
always @ (posedge clk) begin
    case (state)
        2'b00: begin
            case (opcode)
                3'b000: begin
                    C <= 4'b0000; //RESET operation
                    carr <= 1'b0;
                    sign <= 1'b0;
                    zero <= 1'b1;
                end
                3'b001: begin //XNOR operation on LSBs
                    C[0] <= ~(A[0] ^ B[0]);
                    zero <= C[0] == 1'b0;
                end
                3'b010: begin //SUB operation on LSBs
					sub_a <= A;
					sub_b <= B;
                    sub_result <= sub_b - sub_a;
                    C[0] <= sub_result[0];
                    zero <= C[0] == 1'b0;
               end
                3'b011: begin //NAND operation on LSBs
                    C[0] <= ~(A[0] & B[0]);
                    zero <= C[0] == 1'b0;
                end
                3'b100: begin //ADD operation on LSBs
                    {carr, C[0]} <= A[0] + B[0];
                    zero <= C[0] == 1'b0;
                end
                
            
            endcase
            if (opcode != 3'b000) begin
				state <= 2'b01;
			end
        end
        2'b01: begin
            case (opcode)
                3'b001: begin //XNOR operation on next bit
                    C[1] <= ~(A[1] ^ B[1]);
                    zero <= zero & (C[1] == 1'b0);
                end
                3'b010: begin //SUB operation on next bit
					sub_a <= A;
					sub_b <= B;
                    sub_result <= sub_b - sub_a;
                    C[1] <= sub_result[1];
                    zero <= C[1] == 1'b0;
                end 
                3'b011: begin //NAND operation on next bit
                    C[1] <= ~(A[1] & B[1]);
                    zero <= zero & (C[1] == 1'b0);
                end
                3'b100: begin //ADD operation on next bit
                    {carr, C[1]} <= A[1] + B[1] + carr;
                    zero <= zero & (C[1] == 1'b0);
                end  
                 
                    
            endcase
            state <= 2'b10;
        end
        2'b10: begin
            case (opcode)
                3'b001: begin //XNOR operation on next bit
                    C[2] <= ~(A[2] ^ B[2]);
                    zero <= zero & (C[2] == 1'b0);
                end
                3'b010: begin //SUB operation on next bit
					sub_a <= A;
					sub_b <= B;
                    sub_result <= sub_b - sub_a;
                    C[2] <= sub_result[2];
                    zero <= C[2] == 1'b0;
                end
                3'b011: begin //NAND operation on next bit
                    C[2] <= ~(A[2] & B[2]);
                    zero <= zero & (C[2] == 1'b0);
                end
                3'b100: begin //ADD operation on next bit
                    {carr, C[2]} <= A[2] + B[2] + carr;
                    zero <= zero & (C[2] == 1'b0);
                end  
                  
            endcase
            state <= 2'b11;
        end
        2'b11: begin
            case (opcode)
                3'b001: begin //XNOR operation on MSBs
                    C[3] <= ~(A[3] ^ B[3]);
                    sign <= C[3];
                    zero <= C == 4'b0000;
                end
                3'b010: begin //SUB operation on MSBs
					sub_a <= A;
					sub_b <= B;
                    {carr, sub_result} <= sub_b - sub_a;
                    C[3] <= sub_result[3];
                    zero <= C == 4'b0000;
                end
                3'b011: begin //NAND operation on MSBs
                    C[3] <= ~(A[3] & B[3]);
                    sign <= C[3];
                    zero <= C == 4'b0000;
                end
                3'b100: begin //ADD operation on MSBs
                    {carr, C[3]} <= A[3] + B[3] + carr;
                    sign <= C[3];
                    zero <= C == 4'b0000;
                end
                
            endcase
            state <= 2'b00;
        end
    endcase
end
endmodule
