module Write_Register_tb;
reg[4:0] rt;
reg[4:0] rd;
reg[4:0] r31;
reg[4:0] r0;
reg[1:0] S;

wire[4:0] Out;

Write_Register dut(
  .rt(rt),
  .rd(rd),
  .r31(r31),
  .r0(r0),
  .S(S),

  .Out(Out)
);

initial begin
  rt = 5'd4;
  rd = 5'd27;
  r31 = 5'd31;
  r0 = 5'd0;
  S = 2'b00;

  $monitor("rt = %d, rd = %d, r31 = %d, r0 = %d, S = %b, Out = %d", rt, rd, r31, r0, S, Out);

  #2
  S = 2'b01;

  #2
  S = 2'b10;

  #2
  S = 2'b11;
end
endmodule