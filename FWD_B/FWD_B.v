module FWD_B(
  input wire[31:0] RF,
  input wire[31:0] R_EX,
  input wire[31:0] R_MEM,
  input wire[31:0] R_WB,
  input wire[1:0] S,

  output reg[31:0] Out
);

always@(*)begin
  case(S)
    2'b00: Out = RF;
    2'b01: Out = R_EX;
    2'b10: Out = R_MEM;
    2'b11: Out = R_WB;
  endcase
end

endmodule