module Write_Register(
  input wire[4:0] rt,
  input wire[4:0] rd,
  input wire[4:0] r31,
  input wire[4:0] r0,
  input wire[1:0] S,

  output reg[4:0] Out
);

always@(*)begin
  case(S)
    2'b00: Out = rt;
    2'b01: Out = rd;
    2'b10: Out = r31;
    2'b11: Out = r0;
  endcase
end

endmodule