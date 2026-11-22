module Writeback_Data_tb;
  reg[31:0] DO;
  reg[31:0] ALU;
  reg S;

  wire[31:0] Out;

  Writeback_Data dut(
    .DO(DO),
    .ALU(ALU),
    .S(S),

    .Out(Out)
  );

  initial begin
    DO = 32'd3;
    ALU = 32'd4;
    S = 1'b0;

    $monitor("Out = %0d", Out);

    #2
    S = 1'b1;
  end
endmodule