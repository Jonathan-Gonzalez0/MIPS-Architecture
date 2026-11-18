module J_Branch_Mux_tb;
  reg S;
  reg[31:0] A;
  reg[31:0] B;

  wire[31:0] O;

  J_Branch_Mux dut(
    .S(S),
    .A(A),
    .B(B),

    .O(O)
  );

  initial begin
    $monitor("S = %b, A = %b, B = %b, O = %b",S, A, B, O);

    S = 1'b0;
    A = 32'd79;
    B = 32'd2;

    #2

    S = 1'b1;
  end
endmodule