module jump_multiplexer_tb;
  reg S;
  reg[31:0] A1;
  reg[31:0] A0;
  wire[31:0] O;

  jump_multiplexer dut(
    .S(S),
    .A1(A1),
    .A0(A0),
    .O(O)
  );

  initial begin
    $monitor("O = %0d", O);
    A1 = 32'd1;
    A0 = 32'd0;
    S = 0;
    #1

    S=1;
  end

endmodule