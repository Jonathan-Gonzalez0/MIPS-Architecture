module alu (
  input wire [31:0] A,
  input wire [31:0] B,
  input wire [3:0] OP,
  output reg LE,
  output reg EQ,
  output reg GT,
  output reg [31:0] Out
  );

  always@(*) begin
    case(OP)
      4'b0000: Out = A + B;
      4'b0001: Out = A - B;
      4'b0010: Out = A & B;
      4'b0011: Out = A | B; 
      4'b0100: Out = A ^ B;
      4'b0101: Out = ~(A | B);
      4'b0110: Out = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
      4'b0111: Out = A;
      4'b1000: Out = B;
      4'b1001: Out = B << A[4:0];
      4'b1010: Out = B >> A[4:0];
      4'b1011: Out = $signed(B) >>> A[4:0];
      default: Out = 32'b0;
    endcase

    if($signed(Out) < 0) 
      begin 
        LE = 1;
        EQ = 0;
        GT = 0;
      end
    else if ($signed(Out) == 0)
      begin
        LE = 0;
        EQ = 1;
        GT = 0;
      end
    else
      begin
        LE = 0;
        EQ = 0;
        GT = 1;
      end

  end 


endmodule