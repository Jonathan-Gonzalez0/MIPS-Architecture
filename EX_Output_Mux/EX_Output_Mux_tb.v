module EX_Output_Mux_tb;
  reg[31:0] PC;
  reg[31:0] ALU;
  reg S;

  wire[31:0] O;

  EX_Output_Mux dut(
    .PC(PC),
    .ALU(ALU),
    .S(S),

    .O(O)
  );

  initial begin
    PC = 32'd4;
    ALU = 32'd15;
    S = 1'b0;

    $monitor("O = %0d", O);

    #2
    S = 1'b1;
  end
endmodule