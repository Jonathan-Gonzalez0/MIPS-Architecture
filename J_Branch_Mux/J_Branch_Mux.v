module J_Branch_Mux(
  input wire[31:0] A,
  input wire[31:0] B,
  input wire S,
  output reg[31:0] O
);
  always@(*)begin
    if(S)
      O = A;
    else
      O = B;
  end
endmodule