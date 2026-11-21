module Enable_AND_tb;
  reg A;
  reg B;

  wire Out;

  Enable_AND dut(
    .A(A),
    .B(B),

    .Out(Out)
  );

  initial begin
    A = 1'b0;
    B = 1'b0;

    $monitor("Out = %b", Out);

    #2
    A = 1'b0;
    B = 1'b1;

    #2
    A = 1'b1;
    B = 1'b0;

    #2
    A = 1'b1;
    B = 1'b1;
  end


endmodule