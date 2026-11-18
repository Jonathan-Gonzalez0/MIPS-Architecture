module OR_Jump_Branch_tb;
  reg A;
  reg B;

  wire Out;

  OR_Jump_Branch dut(
    .A (A),
    .B(B),
    .Out(Out)
  );

  initial begin
    // 0 or 0 
    
    $monitor("A = %b, B = %b, Out = %b", A, B, Out);
    A = 1'b0;
    B = 1'b0;
    
    #2
    A = 1'b1;
    B = 1'b0;

    #2
    A = 1'b0;
    B = 1'b1;

    #2
    A = 1'b1;
    B = 1'b1;

  end
endmodule