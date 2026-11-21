module Write_Condition_Mux(
  input wire one,
  input wire not_zero,
  input wire zero,
  input wire BranchTaken,
  input wire[1:0] S,

  output reg Out
  );

  always @(*) begin
    case(S)
      2'b00: Out = one;
      2'b01: Out = not_zero;
      2'b10: Out = zero;
      2'b11: Out = BranchTaken;
    endcase
  end
endmodule